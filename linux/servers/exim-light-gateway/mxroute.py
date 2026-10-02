#!/usr/bin/env python3
"""
Exim queryprogram router for a lightweight MX gateway.

Input:
    mxroute.py example.com

Output:
    ACCEPT TRANSPORT=gateway_smtp HOSTS=mail1.example.com:mail2.example.com

Rules:
- Require at least one configured gateway identity in the domain's MX set.
- Remove ALL gateway identities from the MX set, regardless of priority.
- Preserve all remaining real MXes in priority order.
- Detect self by configured hostname and by configured public IP.
- DEFER on DNS trouble or when a guarded domain has no real backend.
- DECLINE when this gateway is not an MX for the domain.

Requires: dig (Debian/Ubuntu package: dnsutils)
"""

from __future__ import annotations

import ipaddress
import re
import subprocess
import sys
from pathlib import Path

SELF_FILE = Path("/etc/exim4/light-gateway-self")
DIG = "/usr/bin/dig"
DNS_TIMEOUT = 3

DOMAIN_RE = re.compile(
    r"(?=^.{1,253}\.?$)"
    r"(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)*"
    r"[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.?$"
)


def normalize_name(value: str) -> str:
    return value.strip().rstrip(".").lower()


def load_self() -> tuple[set[str], set[ipaddress._BaseAddress]]:
    names: set[str] = set()
    ips: set[ipaddress._BaseAddress] = set()

    try:
        lines = SELF_FILE.read_text(encoding="utf-8").splitlines()
    except OSError as exc:
        raise RuntimeError(f"cannot read {SELF_FILE}: {exc}") from exc

    for raw in lines:
        value = raw.split("#", 1)[0].strip()
        if not value:
            continue
        try:
            ips.add(ipaddress.ip_address(value))
        except ValueError:
            name = normalize_name(value)
            if not DOMAIN_RE.fullmatch(name):
                raise RuntimeError(f"invalid gateway identity: {value!r}")
            names.add(name)

    if not names and not ips:
        raise RuntimeError(f"{SELF_FILE} contains no gateway identities")

    return names, ips


def dig(record_type: str, name: str) -> list[str]:
    proc = subprocess.run(
        [
            DIG,
            f"+time={DNS_TIMEOUT}",
            "+tries=1",
            "+short",
            record_type,
            name,
        ],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        timeout=DNS_TIMEOUT + 2,
        check=False,
    )
    if proc.returncode != 0:
        raise RuntimeError(proc.stderr.strip() or f"dig {record_type} failed")
    return [line.strip() for line in proc.stdout.splitlines() if line.strip()]


def resolve_ips(host: str) -> set[ipaddress._BaseAddress]:
    result: set[ipaddress._BaseAddress] = set()
    for record_type in ("A", "AAAA"):
        for value in dig(record_type, host):
            try:
                result.add(ipaddress.ip_address(value))
            except ValueError:
                # Ignore non-address garbage rather than trusting it.
                continue
    return result


def is_self(
    host: str,
    self_names: set[str],
    self_ips: set[ipaddress._BaseAddress],
) -> bool:
    name = normalize_name(host)
    if name in self_names:
        return True

    # Catches alternate MX hostnames pointing to the same gateway IP.
    return bool(resolve_ips(name) & self_ips)


def get_mx(domain: str) -> list[tuple[int, str]]:
    records: list[tuple[int, str]] = []

    for line in dig("MX", domain):
        parts = line.split()
        if len(parts) != 2:
            continue

        try:
            priority = int(parts[0])
        except ValueError:
            continue

        host = normalize_name(parts[1])
        if host == "":
            continue

        # RFC 7505 null MX: "0 ."
        if parts[1] == ".":
            return []

        if DOMAIN_RE.fullmatch(host):
            records.append((priority, host))

    return sorted(set(records), key=lambda item: (item[0], item[1]))


def route(domain: str) -> str:
    domain = normalize_name(domain)
    if not DOMAIN_RE.fullmatch(domain):
        return "DECLINE invalid domain"

    self_names, self_ips = load_self()
    mx_records = get_mx(domain)

    if not mx_records:
        return "DECLINE no MX records"

    found_self = False
    backends: list[tuple[int, str]] = []

    for priority, host in mx_records:
        if is_self(host, self_names, self_ips):
            found_self = True
            continue
        backends.append((priority, host))

    if not found_self:
        return "DECLINE gateway is not an MX for domain"

    if not backends:
        return "DEFER guarded domain has no non-gateway MX backend"

    # Exim expects a colon-separated host list. Hostnames are validated above.
    hosts = ":".join(host for _, host in backends)
    return f"ACCEPT TRANSPORT=gateway_smtp HOSTS={hosts} DATA=light-gateway"


def main() -> int:
    if len(sys.argv) != 2:
        print("DEFER mxroute requires exactly one domain")
        return 0

    try:
        print(route(sys.argv[1]))
    except subprocess.TimeoutExpired:
        print("DEFER DNS lookup timed out")
    except Exception as exc:
        # Queryprogram output must stay simple and single-line.
        message = str(exc).replace("\n", " ")[:300]
        print(f"DEFER mxroute error: {message}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())

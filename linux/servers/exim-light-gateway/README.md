# Exim Light Gateway

A thin SMTP gateway in front of an existing mail server.

It does **not** scan message bodies. The backend mail server remains responsible
for ClamAV, Rspamd/SpamAssassin, DKIM/DMARC policy, mailbox delivery, etc.

## MX model

This layout is supported:

```text
10 gateway1.example.net   <- self
20 mail1.example.com      <- backend
30 mail2.example.com      <- backend
40 gateway2.example.net   <- same gateway/self
```

The embedded Perl MX router removes **all** configured gateway identities and returns:

```text
mail1.example.com
mail2.example.com
```

It never forwards to `gateway2` merely because that name appears later in MX.

## Included protection

- relay only for domains whose MX set contains this gateway
- local downloaded IPv4/IPv6/CIDR reputation list
- DNSBL scoring
- sender-domain RHSBL scoring
- PTR signal
- HELO/EHLO verification signal
- Exim-native connection/message/recipient rate limiting
- conservative reputation score
- malformed-header rejection
- self-aware MX routing and loop avoidance
- normal Exim queue/retry behavior

No ClamAV, Rspamd, Redis, SQL, or filtering daemon is required.

## Install

Debian/Ubuntu example:

```sh
apt install exim4-daemon-light
install -d -m 0755 /var/lib/exim4/light-gateway

install -m 0644 light-gateway-mxroute.pl /etc/exim4/light-gateway-mxroute.pl
install -m 0755 update-blocklists.py /usr/local/sbin/update-exim-light-blocklists

install -m 0644 light-gateway-self.example /etc/exim4/light-gateway-self
install -m 0644 light-gateway-blocklists.example /etc/exim4/light-gateway-blocklists
```

Edit `/etc/exim4/light-gateway-self` and list **all gateway MX names and public
IP addresses**.

Example:

```text
gateway1.example.net
gateway2.example.net
203.0.113.10
203.0.113.11
```

This is what prevents an alternate hostname for the same gateway from becoming
a forwarding destination.

Run the blocklist updater:

```sh
/usr/local/sbin/update-exim-light-blocklists
```

A simple cron entry is sufficient:

```cron
23 */6 * * * root /usr/local/sbin/update-exim-light-blocklists >/dev/null
```

## Exim configuration

`exim-gateway.conf` is a complete minimal gateway-oriented configuration.
Before using it:

1. change `primary_hostname`
2. review message/recipient/rate limits
3. review the DNSBL/RHSBL services and their usage terms
4. configure TLS if desired
5. confirm the Exim runtime user in the `command_user` line

On Debian the Exim user is normally `Debian-exim`.

How you install the main config depends on whether your host uses Debian's
split configuration or a monolithic configuration. Preserve a copy of the
distribution config before replacing/merging it.

## Validate before restart

```sh
exim4 -bV
exim4 -bP
exim4 -bt postmaster@example.com
```

For a guarded domain, `-bt` should show one of the real backend MX hosts, never
a gateway identity.

Embedded Perl is invoked by Exim itself. Test the function directly through
Exim's expansion engine:

```sh
exim4 -be '${perl{mxroute}{example.com}}'
```

Expected shape:

```text
mail1.example.com:mail2.example.com byname
```

Then test normal address routing:

```sh
exim4 -bt postmaster@example.com
```

If the domain does not use this gateway as an MX, the manualroute router
declines. If every MX points back to the gateway, routing is deferred instead
of looping.

## Reputation score defaults

```text
local IP/CIDR list     +4
strong DNSBL           +4
secondary DNSBL        +2
sender-domain RHSBL    +2
missing PTR            +1
bad HELO               +1
rate signal            +2
SPF pass              -1
SPF softfail          +1
SPF fail              +3
SPF permerror         +1
SPF none/neutral       0
SPF temperror          0

score 0-4   accept
score 5-6   temporary defer
score 7+    reject
```

This is intentionally conservative: one list hit alone does not permanently
reject mail.

Tune the `SCORE_*` macros near the top of `exim-gateway.conf`.



## SPF scoring

SPF is checked at SMTP `MAIL FROM` time. This uses the connecting IP, envelope
sender and HELO identity only; it does not scan the message body and requires
no daemon.

Default scoring:

```text
pass        -1
softfail    +1
fail        +3
permerror   +1
none         0
neutral      0
temperror    0
```

`fail` deliberately does not reject by itself. It combines with the other
gateway reputation signals.

Example:

```text
manual domain score   +2
SPF fail              +3
medium DNSBL          +2
-------------------------
total                 +7 -> reject
```

A successful SPF result can offset a weak signal:

```text
manual domain score   -2
SPF pass              -1
missing PTR           +1
-------------------------
total                 -2 -> accept
```

The gateway also adds:

```text
X-Light-Gateway-SPF: pass
```

The backend may log/use this header, but should only trust it when mail arrived
from the gateway itself.

### Exim SPF support

The `spf` ACL condition is only available when Exim was built with SPF support.
Check before enabling/restarting:

```sh
exim4 -bV | grep -i spf
```

If your Exim package lacks SPF support, either install a build/package with SPF
enabled or remove the SPF ACL block and `X-Light-Gateway-SPF` header. No
external SPF daemon is required when Exim has native SPF support.


## Authentication-Results for the backend

The gateway adds a standard `Authentication-Results` header using Exim's native
authentication-results formatter:

```text
Authentication-Results: gateway1.example.net;
    spf=pass ...
```

The configuration uses:

```text
GATEWAY_AUTHSERV_ID = $primary_hostname
```

and, in the DATA ACL:

```text
add_header = :at_start:${authresults {GATEWAY_AUTHSERV_ID}}
```

This is preferable to constructing the header manually because Exim formats
the available authentication results consistently.

The existing lightweight header is also retained:

```text
X-Light-Gateway-SPF: pass
```

### Backend trust rule

The backend must trust the gateway's `Authentication-Results` only when the
SMTP connection itself came from one of the gateway IP addresses.

Do **not** globally trust a header merely because its `authserv-id` says
`gateway1.example.net`; arbitrary Internet senders can create headers with the
same text before reaching the gateway.

A practical backend policy is:

```text
SMTP peer = trusted gateway IP
    -> trust gateway Authentication-Results/SPF

SMTP peer != trusted gateway IP
    -> ignore gateway Authentication-Results
```

The backend can continue doing DKIM and DMARC verification itself. The gateway
does not alter normal signed message headers or the body, so adding
`Authentication-Results`, `Received`, and `X-Light-Gateway-*` headers should
not normally invalidate DKIM.

For strongest separation, restrict backend port 25 so only gateway IPs can
reach it.

## Manual IP/domain scoring

Install the example score maps:

```sh
install -m 0644 light-gateway-ip-scores.example /etc/exim4/light-gateway-ip-scores
install -m 0644 light-gateway-domain-scores.example /etc/exim4/light-gateway-domain-scores
```

Positive values increase suspicion. Negative values increase trust.

Example domain policy:

```text
gmail.com: +2
yahoo.com: -2
*.bulk.example.com: +3
```

With the default thresholds, a Gmail envelope sender starts two points closer
to a temporary deferral/rejection, while Yahoo starts two points closer to
acceptance.

Example IP/CIDR policy:

```text
203.0.113.25: +3
198.51.100.0/24: +2
192.0.2.0/24: -2
"2001:db8:1234::/48": -2
```

IP matching uses Exim `iplsearch`. It is first-match, not longest-prefix-match,
so put specific networks before broader networks.

Domain matching uses `nwildlsearch`, supporting both exact domains and wildcard
entries such as `*.example.com`.

Important: sender-domain scoring uses the SMTP envelope sender
(`MAIL FROM`), which can be forged. Treat negative scores as a small reputation
hint, not an authentication bypass. Do not use a large negative value to
whitelist a domain such as Gmail or Yahoo.

## Large downloaded lists

Exim `iplsearch` supports CIDR directly, but it is a **linear file lookup**.
A curated list of a few thousand/tens of thousands of entries is reasonable
for a light gateway.

For very large FireHOL-style aggregates, put the hard-block list in
`nftables`/`ipset` and keep Exim's local scoring list smaller. This avoids
scanning a huge text file for every new SMTP connection.



## Embedded Perl router

The gateway no longer launches a Python routing helper.

Exim loads:

```text
/etc/exim4/light-gateway-mxroute.pl
```

through:

```text
perl_startup = do '/etc/exim4/light-gateway-mxroute.pl'
perl_taintmode = yes
```

and the router uses:

```text
route_data = ${perl{mxroute}{$domain}}
```

The Perl code uses Exim's own `dnsdb` resolver for public MX/A/AAAA lookups.
Backend hosts are returned with `byname`, so their delivery addresses use the
system resolver/NSS path and can therefore be overridden in `/etc/hosts`.

The router maintains a 5-minute in-memory cache for domain routes and MX-host
address checks. This cache is **per Exim process**, not a global daemon-wide
cache. Exim/DNS resolver caching still applies separately.

`same_domain_copy_routing = true` also prevents duplicate manual routing for
multiple recipients at the same domain within one message.

### Verify embedded Perl support

Before installing this configuration:

```sh
exim4 -bV | grep -i perl
```

The Exim binary must have embedded Perl support. If it does not, use an Exim
package/build that enables it.

The routing path no longer requires `python3` or `dig`. Python is still used
only by the optional downloaded-blocklist updater.

## Split DNS / `/etc/hosts` backend override

You can keep public MX hostnames while making the gateway deliver to private
backend IPs.

Example public DNS:

```text
10 gateway1.example.net
20 mail1.example.com
30 mail2.example.com
40 gateway2.example.net
```

On the gateway:

```text
# /etc/hosts
192.168.1.23 mail1.example.com
192.168.1.24 mail2.example.com
```

The embedded Perl router queries public DNS through Exim `dnsdb`, so MX
ordering and gateway self-detection are based on DNS rather than `/etc/hosts`.

Backend delivery does **not** force Exim's `bydns` lookup mode. The returned
backend hostnames are resolved through the system resolver/NSS path, allowing
`/etc/hosts` to override DNS.

Confirm `/etc/nsswitch.conf` includes `files` before `dns`, for example:

```text
hosts: files dns
```

Validate resolution before restarting Exim:

```sh
getent hosts mail1.example.com
getent hosts mail2.example.com
```

Those should return the private addresses.

Then confirm Exim routing:

```sh
exim4 -bt postmaster@example.com
```

The route should still name `mail1.example.com` / `mail2.example.com`; the SMTP
transport will resolve those names using the system resolver when connecting.

## Backend protection

The real mail server should normally permit inbound port 25 only from the
gateway IPs. Otherwise senders can bypass the gateway and connect directly to
`mail1`/`mail2`.

If the backend MX names/IPs must remain public because they are also fallback
MXes, firewalling SMTP to gateway sources is still recommended when your
architecture allows it.

## DNSBL note

Some DNSBL operators restrict queries coming through public resolvers or impose
usage limits. Use a resolver and DNSBL service permitted by the provider. If a
chosen DNSBL is unsuitable, remove or replace the corresponding ACL stanza;
the rest of the gateway is independent of it.

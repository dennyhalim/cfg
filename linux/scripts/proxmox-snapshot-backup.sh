#!/usr/bin/env bash
set -uo pipefail

LOG_FILE="/var/log/proxmox-snapshot-backup.log"
SHOW_STDOUT=0
MODE="snapshot"
STORAGE=""
DUMPDIR=""

usage() {
    cat <<EOF
Usage:
  $0 [options] VMID [VMID...]

Options:
  -m, --mode MODE      snapshot|backup (default: snapshot)
  -s, --storage ID     Backup storage ID (backup mode only)
  -d, --dumpdir PATH   Backup directory (backup mode only)
  -o, --stdout         Also show status on stdout
  -l, --log FILE       Log file (default: $LOG_FILE)
  -h, --help           Show this help

Examples:
  $0 100 101 102
  $0 --mode snapshot 100 101
  $0 --mode backup 100 101
  $0 --mode backup --storage backup-nfs 100 101
  $0 --mode backup --dumpdir /mnt/backup --stdout 100 101

by denny.wordpress.com
EOF
}

log() {
    local level="$1"
    shift

    local line
    line="$(date '+%Y-%m-%d %H:%M:%S') [$level] $*"

    printf '%s\n' "$line" >> "$LOG_FILE"

    if (( SHOW_STDOUT )); then
        printf '%s\n' "$line"
    fi
}

VMIDS=()

while (($#)); do
    case "$1" in
        -m|--mode)
            [[ $# -ge 2 ]] || { echo "Missing mode" >&2; exit 2; }
            MODE="$2"
            shift 2
            ;;
        -s|--storage)
            [[ $# -ge 2 ]] || { echo "Missing storage ID" >&2; exit 2; }
            STORAGE="$2"
            shift 2
            ;;
        -d|--dumpdir)
            [[ $# -ge 2 ]] || { echo "Missing dump directory" >&2; exit 2; }
            DUMPDIR="$2"
            shift 2
            ;;
        -o|--stdout)
            SHOW_STDOUT=1
            shift
            ;;
        -l|--log)
            [[ $# -ge 2 ]] || { echo "Missing log file" >&2; exit 2; }
            LOG_FILE="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --)
            shift
            VMIDS+=("$@")
            break
            ;;
        -*)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 2
            ;;
        *)
            VMIDS+=("$1")
            shift
            ;;
    esac
done

if [[ "$MODE" != "snapshot" && "$MODE" != "backup" ]]; then
    echo "Invalid mode: $MODE (must be snapshot or backup)" >&2
    exit 2
fi

if ((${#VMIDS[@]} == 0)); then
    echo "No VMID specified." >&2
    usage >&2
    exit 2
fi

if [[ -n "$STORAGE" && -n "$DUMPDIR" ]]; then
    echo "--storage and --dumpdir cannot be used together." >&2
    exit 2
fi

if [[ "$MODE" == "snapshot" && ( -n "$STORAGE" || -n "$DUMPDIR" ) ]]; then
    echo "--storage/--dumpdir only apply to backup mode." >&2
    exit 2
fi

if [[ $EUID -ne 0 ]]; then
    echo "This script must run as root." >&2
    exit 1
fi

touch "$LOG_FILE" || {
    echo "Cannot write log: $LOG_FILE" >&2
    exit 1
}

DEST_ARGS=()

if [[ -n "$STORAGE" ]]; then
    DEST_ARGS=(--storage "$STORAGE")
elif [[ -n "$DUMPDIR" ]]; then
    DEST_ARGS=(--dumpdir "$DUMPDIR")
fi

SUCCESS=0
FAILED=0

log INFO "Started: mode=$MODE VMIDs=${VMIDS[*]}"

for vmid in "${VMIDS[@]}"; do
    if [[ ! "$vmid" =~ ^[0-9]+$ ]]; then
        log ERROR "VM $vmid: invalid VMID"
        ((FAILED++))
        continue
    fi

    if [[ "$MODE" == "backup" ]]; then
        log INFO "VM $vmid: backup started"

        OUTPUT="$(
            vzdump "$vmid" \
                --mode snapshot \
                "${DEST_ARGS[@]}" \
                2>&1
        )"
        RC=$?

    else
        # Detect QEMU VM vs LXC container.
        if qm status "$vmid" &>/dev/null; then
            TYPE="VM"
            SNAP_NAME="auto-$(date '+%Y%m%d-%H%M%S')"

            log INFO "$TYPE $vmid: creating snapshot $SNAP_NAME"

            OUTPUT="$(
                qm snapshot "$vmid" "$SNAP_NAME" \
                    --description "Automated snapshot $(date '+%Y-%m-%d %H:%M:%S')" \
                    2>&1
            )"
            RC=$?

        elif pct status "$vmid" &>/dev/null; then
            TYPE="CT"
            SNAP_NAME="auto-$(date '+%Y%m%d-%H%M%S')"

            log INFO "$TYPE $vmid: creating snapshot $SNAP_NAME"

            OUTPUT="$(
                pct snapshot "$vmid" "$SNAP_NAME" \
                    --description "Automated snapshot $(date '+%Y-%m-%d %H:%M:%S')" \
                    2>&1
            )"
            RC=$?

        else
            log ERROR "VM $vmid: VM/CT not found"
            ((FAILED++))
            continue
        fi
    fi

    if (( RC == 0 )); then
        if [[ "$MODE" == "backup" ]]; then
            log SUCCESS "VM $vmid: backup completed"
        else
            log SUCCESS "$TYPE $vmid: snapshot $SNAP_NAME created"
        fi
        ((SUCCESS++))
    else
        log ERROR "VM $vmid: $MODE failed (exit=$RC)"

        while IFS= read -r line; do
            log ERROR "VM $vmid: $line"
        done <<< "$OUTPUT"

        ((FAILED++))
    fi
done

log INFO "Finished: mode=$MODE success=$SUCCESS failed=$FAILED"

(( FAILED == 0 ))

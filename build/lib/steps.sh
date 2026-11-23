# steps.sh — run the numbered step scripts of one phase folder, in order,
# each with its own log. Sourced by every phase's run.sh (after common.sh).
#
# A step is any file named <key>_<name>.sh in the phase folder, where <key> is
# the LFS book section (8.29_gcc.sh = §8.29) or a plain number (03_kernel.sh).
# The order is the version order of <key>: no list to keep in sync.
#
# run.sh arguments (handled here):
#   (none)        run every step
#   FROM          start at FROM          e.g. 8.29   (or 8.29_gcc.sh)
#   FROM TO       run FROM..TO           e.g. 5 5    (all of chapter 5)
#   --list        print the steps and exit
# A key matches itself and everything below it: "8" = all of ch. 8,
# "8.3" = "8.03" = Man-pages.
#
# Logs: one file per step in $FT_LOG_DIR/<phase>/ (default: logs/ next to the
# ft_linux copy, i.e. $LFS/sources/logs = /sources/logs in the chroot).

if [[ "$FT_ROOT" == */"$FT_LFS_SUBDIR" ]]; then
    : "${FT_LOG_DIR:=${FT_ROOT%/*}/logs}"
else
    : "${FT_LOG_DIR:=$FT_ROOT/logs}"
fi

# "8.03_glibc.sh" -> "8.3", "03_kernel.sh" -> "3", "8.59a_check.sh" -> "8.59a"
_ft_key() {
    local k="${1##*/}" out="" part
    k="${k%%_*}"
    IFS=. read -ra parts <<< "$k"
    for part in "${parts[@]}"; do
        [[ "$part" =~ ^0*([0-9].*)$ ]] && part="${BASH_REMATCH[1]}"
        out+="${out:+.}$part"
    done
    echo "$out"
}

# Does step key $1 fall under the user-given key $2?
_ft_match() { [[ "$1" == "$2" || "$1" == "$2".* ]]; }

# ft_run_steps <phase_dir> [--list | FROM [TO]]
ft_run_steps() {
    local dir="$1"; shift
    local phase steps=() keys=() i first=-1 last=-1 from to
    phase="$(basename "$dir")"

    mapfile -t steps < <(cd "$dir" && ls -1 | grep -E '^[0-9][0-9.]*[a-z]?_.+\.sh$' | sort -t_ -k1,1V)
    [ "${#steps[@]}" -gt 0 ] || ft_die "no step scripts in $dir"
    for i in "${!steps[@]}"; do keys[i]="$(_ft_key "${steps[i]}")"; done

    if [ "${1:-}" = "--list" ]; then
        echo "Steps of $phase:"
        for i in "${!steps[@]}"; do printf "  %-7s %s\n" "${keys[i]}" "${steps[i]}"; done
        return 0
    fi

    from="$(_ft_key "${1:-${steps[0]}}")"
    to="$(_ft_key "${2:-${steps[-1]}}")"
    for i in "${!steps[@]}"; do
        if _ft_match "${keys[i]}" "$from" && [ "$first" -lt 0 ]; then first=$i; fi
        if _ft_match "${keys[i]}" "$to"; then last=$i; fi
    done
    [ "$first" -ge 0 ] || ft_die "no step matches '$1' (try: $0 --list)"
    [ "$last"  -ge 0 ] || ft_die "no step matches '$2' (try: $0 --list)"
    [ "$first" -le "$last" ] || ft_die "'$1' comes after '$2'"

    local logdir="$FT_LOG_DIR/$phase" total=$((last - first + 1)) n=0 t0 tstart log
    mkdir -p "$logdir"

    echo "=== ft_linux — $phase: steps ${keys[first]} → ${keys[last]} ($total) ==="
    echo "  Logs      : $logdir"
    echo "  MAKEFLAGS : ${MAKEFLAGS:-<not set>}"
    echo ""
    tstart=$(date +%s)

    for ((i = first; i <= last; i++)); do
        n=$((n + 1))
        log="$logdir/${steps[i]%.sh}.log"
        echo "========================================"
        echo "  [$n/$total] ${keys[i]}  ${steps[i]}"
        echo "========================================"
        t0=$(date +%s)
        if ! bash "$dir/${steps[i]}" 2>&1 | tee "$log"; then
            echo ""
            echo "FAILED: ${steps[i]}   (log: $log)"
            echo "Fix it, then resume with:  bash $0 ${keys[i]}"
            return 1
        fi
        echo "  Done in $(( $(date +%s) - t0 ))s"
        echo ""
    done

    echo "=== $phase: done in $(( $(date +%s) - tstart ))s ==="
}

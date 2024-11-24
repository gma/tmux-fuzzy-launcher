#!/bin/bash

TM_ROOT="${TM_ROOT:-$HOME/Code}"
TM_DEPTH=${TM_DEPTH:-3}
TM_PROJECT_CONTAINS="${TM_PROJECT_CONTAINS:-.git}"
TM_CRITERIA="${TM_CRITERIA:--type d -name $TM_PROJECT_CONTAINS}"
TM_FILTER="${TM_FILTER:-cat}"
TM_EDITOR="${TM_EDITOR:-${EDITOR:-vi}}"


## Functions

err()
{
    echo "ERROR: $(basename "$0"): $*" 1>&2
    exit 1
}


running_within_tmux()
{
    [ -n "$TMUX" ]
}


## Main program

[ -n "$DEBUG" ] && set -x

# It's easy to run tm when you really meant to type tmux (e.g. `tm a` to
# attach to a running session). tm takes no arguments itself, so to handle
# that, if we've been passed any arguments we pass them through to tmux,
# then exit.
[ $# -gt 0 ] && exec tmux "$@"

MAX_DEPTH=$((TM_DEPTH + 1))

DIR=$(
    find "$TM_ROOT" -maxdepth $MAX_DEPTH $TM_CRITERIA 2>/dev/null | \
        sed "s,^$TM_ROOT/,,; s,/${TM_PROJECT_CONTAINS}$,," | \
        $TM_FILTER | \
        fzf
)

FZF_RC=$?

if [ -z "$DIR" ]; then
    if [ $FZF_RC -eq 1 ]; then
        err "no matching path"
    else
        exit $FZF_RC
    fi
fi

SESSION="$(basename "$DIR" | tr '[:punct:]' '-')"

if ! tmux has-session -t "=$SESSION" 2>/dev/null; then
    tmux new-session -d -s "$SESSION" -c "$TM_ROOT/$DIR" -n editor "$TM_EDITOR"
fi

if running_within_tmux; then
    tmux switch-client -t "$SESSION"
else
    tmux attach-session -t "$SESSION"
fi

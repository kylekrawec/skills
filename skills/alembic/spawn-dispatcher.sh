#!/bin/sh
# alembic — spawn the dispatcher session and wait for it deterministically.
#
#   spawn-dispatcher.sh <project-dir> <model> [timeout-seconds]
#
# Reads ~/.config/alembic/settings.json for the user's terminal, writes a
# self-checked launch script (models repeatedly drop the `cd` when emitting
# this inline, so it is never emitted inline), opens the terminal window, and
# polls for the new claude process and its session-message socket.
#
# Contact is head-initiated: the head sends the handoff to EXPECTED_SOCK. The
# boot prompt only primes the rulebook — it does not introduce itself, since
# both sides speaking first just makes messages cross; the dispatcher's
# acknowledgment of the handoff is the readiness signal.
#
# stdout: KEY=VALUE lines.
# exit 0 — REGISTERED: socket is up, send the handoff to uds:$EXPECTED_SOCK.
# exit 2 — SPAWNED_AWAITING_REGISTRATION: process up, no socket yet; the user
#          must finish the new session's startup. Re-check: test -S $EXPECTED_SOCK
# exit 1 — error / nothing spawned.

set -u

USAGE="usage: spawn-dispatcher.sh <project-dir> <model> [timeout-seconds]"
DIR=${1:?$USAGE}
MODEL=${2:?$USAGE}
TIMEOUT=${3:-180}

fail() { echo "ERROR=$1" >&2; exit 1; }

[ -d "$DIR" ] || fail "no such directory: $DIR"
CLAUDE=$(command -v claude) || fail "claude not on PATH"

# Routing tables name models like "opus-5"; the CLI wants an alias ("opus")
# or a full id ("claude-opus-5"). Normalize the table form so a session never
# boots model-less with "issue with the selected model".
case "$MODEL" in
  opus-*|sonnet-*|haiku-*|fable-*) MODEL="claude-$MODEL" ;;
esac
echo "MODEL=$MODEL"

SETTINGS="$HOME/.config/alembic/settings.json"
TERMINAL=Terminal
SPAWN_TEMPLATE=""
if [ -f "$SETTINGS" ]; then
  IFS='	' read -r T SPAWN_TEMPLATE <<EOF
$(python3 -c 'import json,sys; s=json.load(open(sys.argv[1])); print(s.get("terminal",""), s.get("spawnTemplate",""), sep="\t")' "$SETTINGS" 2>/dev/null)
EOF
  [ -n "$T" ] && TERMINAL=$T
fi

# The random suffix dodges rename-on-collision; the name is for humans (the
# window title, the from-name on the dispatcher's messages).
SKILL_DIR=$(cd "$(dirname "$0")" && pwd)
NAME="$(basename "$DIR")-dispatcher-$(od -An -N3 -tx1 /dev/urandom | tr -d ' \n')"
BOOT="You are the dispatcher (cucurbit) in an alembic pipeline, session name $NAME. Read $SKILL_DIR/DISPATCHER.md now, then wait for the head's handoff session message — it may already be waiting in your queue. Do not message anyone before it arrives."

LAUNCH=$(mktemp /tmp/alembic-launch.XXXXXX) || fail "mktemp failed"
{
  echo '#!/bin/sh'
  # The head's env leaks through `open` into the new terminal, and the
  # child-session marker it carries would boot the dispatcher with transcript
  # saving off — its context unrecoverable across restarts. The dispatcher is
  # a peer session, not a child; strip the marker.
  echo 'unset CLAUDE_CODE_CHILD_SESSION'
  printf 'cd "%s" && exec "%s" --model %s --name "%s" "%s"\n' "$DIR" "$CLAUDE" "$MODEL" "$NAME" "$BOOT"
} > "$LAUNCH"
chmod +x "$LAUNCH"
grep -q "^cd \"$DIR\" && exec" "$LAUNCH" || fail "launch script failed self-check"
echo "DISPATCHER_NAME=$NAME"
echo "LAUNCH_SCRIPT=$LAUNCH"
echo "TERMINAL=$TERMINAL"

# claude processes whose cwd is the project dir, for before/after diffing
claude_pids_in_dir() {
  for pid in $(ps -axo pid=,command= | awk '{c=$2; sub(".*/","",c); if (c=="claude") print $1}'); do
    cwd=$(lsof -a -p "$pid" -d cwd -Fn 2>/dev/null | sed -n 's/^n//p')
    [ "$cwd" = "$DIR" ] && echo "$pid"
  done
}
BEFORE=" $(claude_pids_in_dir | tr '\n' ' ') "

if [ -n "$SPAWN_TEMPLATE" ]; then
  CMD=$(printf '%s' "$SPAWN_TEMPLATE" | sed "s|{launch}|$LAUNCH|g")
  sh -c "$CMD" || fail "spawnTemplate failed: $CMD"
else
  case "$TERMINAL" in
    Ghostty)  open -na Ghostty.app --args -e "$LAUNCH" || fail "Ghostty spawn failed" ;;
    Terminal) osascript -e "tell app \"Terminal\" to do script \"$LAUNCH\"" >/dev/null || fail "Terminal spawn failed" ;;
    *) fail "no spawn recipe for terminal '$TERMINAL' — set spawnTemplate in $SETTINGS" ;;
  esac
fi

DEADLINE=$(( $(date +%s) + TIMEOUT ))
NEWPID=""
while [ "$(date +%s)" -lt "$DEADLINE" ]; do
  for pid in $(claude_pids_in_dir); do
    case "$BEFORE" in
      *" $pid "*) ;;
      *) NEWPID=$pid; break 2 ;;
    esac
  done
  sleep 1
done
[ -n "$NEWPID" ] || { echo "STATUS=NOT_SPAWNED"; exit 1; }

echo "PID=$NEWPID"
SOCK="/tmp/cc-socks/$NEWPID.sock"
echo "EXPECTED_SOCK=$SOCK"

while [ "$(date +%s)" -lt "$DEADLINE" ]; do
  [ -S "$SOCK" ] && { echo "STATUS=REGISTERED"; exit 0; }
  sleep 1
done

echo "STATUS=SPAWNED_AWAITING_REGISTRATION"
exit 2

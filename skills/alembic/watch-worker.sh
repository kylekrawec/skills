#!/bin/sh
# alembic — watch one interactive herdr worker until it is actually finished.
#
#   watch-worker.sh <agent-name> <report-path> [poll-seconds]
#
# A bare `herdr agent wait` settles on idle, done, or blocked — and blocked
# is a settle but not an end: it means more work comes after a human acts,
# so a one-shot wait retires exactly when watching matters most. This loop
# watches THROUGH blocked: one line per state transition (a block still
# surfaces promptly), exit 0 only when the report exists AND the agent is
# idle/done, exit 3 if the agent disappears.
#
# Delete the report file before spawning the worker: a stale report reads
# as instant DONE.
#
# Run backgrounded (one notification on exit) or under Monitor (a line per
# transition).

set -u
USAGE="usage: watch-worker.sh <agent-name> <report-path> [poll-seconds]"
name=${1:?$USAGE}
report=${2:?$USAGE}
poll=${3:-10}

prev=""
while :; do
	info=$(herdr agent get "$name" 2>/dev/null) || {
		echo "GONE $name — agent no longer exists"
		exit 3
	}
	st=$(printf '%s' "$info" | python3 -c 'import json,sys; print(json.load(sys.stdin)["result"]["agent"]["agent_status"])' 2>/dev/null) || st=unknown
	if [ "$st" != "$prev" ]; then
		case $st in
			blocked) echo "BLOCKED $name — approval/question waiting; human must answer (herdr pane read to see it)" ;;
			*) echo "STATE $name=$st" ;;
		esac
		prev=$st
	fi
	if [ -s "$report" ] && { [ "$st" = idle ] || [ "$st" = done ]; }; then
		echo "DONE $name — report written: $report"
		exit 0
	fi
	sleep "$poll"
done

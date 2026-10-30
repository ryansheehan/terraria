#!/bin/sh
set -u

console_dir=$(mktemp -d) || exit 1
trap '
  kill "${input_pid:-}" 2>/dev/null || :
  wait "${input_pid:-}" 2>/dev/null || :
  rm -f -- "$console_dir/input"
  rmdir -- "$console_dir"
' EXIT
mkfifo -m 600 "$console_dir/input" || exit 1
exec 3<>"$console_dir/input" || exit 1
exec 4<&0

cat <&4 >&3 3>&- 4>&- &
input_pid=$!
exec 4<&-
"$@" <&3 3>&- &
server_pid=$!
trap '
  trap "" TERM INT
  printf "exit\n" >&3
  wait "$server_pid"
  exit "$?"
' TERM INT
wait "$server_pid"
exit "$?"

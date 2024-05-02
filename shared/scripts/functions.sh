#!/bin/bash

start_fun_frontend() {
local session="fun-frontend"

if [ "$(is_session_running "$session")" = "FALSE" ]; then
tmux new-session -d -s "$session" \; pipe-pane -o "cat >> ~/shared/logs/tmux/$session.log"

tmux send-keys -t "$session" "cd /root/funttastic/frontend" C-m
tmux send-keys -t "$session" "$FUN_FRONTEND_COMMAND" C-m
fi
}

start_filebrowser() {
local session="filebrowser"

if [ "$(is_session_running "$session")" = "FALSE" ]; then
tmux new-session -d -s "$session" \; pipe-pane -o "cat >> ~/shared/logs/tmux/$session.log"

tmux send-keys -t "$session" "cd /root/filebrowser" C-m
tmux send-keys -t "$session" "$FILEBROWSER_COMMAND" C-m
fi
}

start_fun_client() {
local password="$1"
local session="fun-client"

if [ "$(is_session_running "$session")" = "FALSE" ]; then
tmux new-session -d -s "$session" \; pipe-pane -o "cat >> ~/shared/logs/tmux/$session.log"

#		tmux set-environment -t "$session" PASSWORD "$password"
#		tmux send-keys -t "$session" "export PASSWORD=\"$(tmux show-environment PASSWORD | cut -d= -f2)\"" C-m
tmux send-keys -t "$session" "export PASSWORD=\"$password\"" C-m
tmux send-keys -t "$session" "conda activate funttastic" C-m
tmux send-keys -t "$session" "cd /root/funttastic/client" C-m
tmux send-keys -t "$session" "$FUN_CLIENT_COMMAND" C-m
#		tmux set-environment -t "$session" -u PASSWORD
fi
}

start_hb_gateway() {
local password="$1"
local session="hb-gateway"

if [ "$(is_session_running "$session")" = "FALSE" ]; then
tmux new-session -d -s "$session" \; pipe-pane -o "cat >> ~/shared/logs/tmux/$session.log"

#		tmux set-environment -t "$session" GATEWAY_PASSPHRASE "$password"
#		tmux send-keys -t "$session" "export GATEWAY_PASSPHRASE=\"$(tmux show-environment GATEWAY_PASSPHRASE | cut -d= -f2)\"" C-m
tmux send-keys -t "$session" "export GATEWAY_PASSPHRASE=\"$password\"" C-m
tmux send-keys -t "$session" "cd /root/hummingbot/gateway" C-m
tmux send-keys -t "$session" "$HB_GATEWAY_COMMAND" C-m
#		tmux set-environment -t "$session" -u GATEWAY_PASSPHRASE
fi
}

start_hb_client() {
local session="hb-client"

if [ "$(is_session_running "$session")" = "FALSE" ]; then
tmux new-session -d -s "$session" \; pipe-pane -o "cat >> ~/shared/logs/tmux/$session.log"

tmux send-keys -t "$session" "conda activate hummingbot" C-m
tmux send-keys -t "$session" "cd /root/hummingbot/client" C-m
tmux send-keys -t "$session" "$HB_CLIENT_COMMAND" C-m
fi
}

keep() {
if [ "$(is_process_running "keep")" = "FALSE" ]; then
APP=keep tail -f /dev/null
fi
}

start_all() {
local username="$1"
local password="$2"

start_fun_frontend
start_filebrowser
start_fun_client "$password"
start_hb_gateway "$password"
start_hb_client
}

start() {
local credentials
local username="${1:-$ADMIN_USERNAME}"
local password="${2:-$ADMIN_PASSWORD}"

args_to_check=("--start_all" "--start_fun_frontend" "--start_filebrowser" "--start_fun_client" "--start_hb_gateway" "--start_hb_client")

for arg in "${args_to_check[@]}"; do
if [[ "$username" == "$arg" ]]; then
username=""
break
fi
done

for arg in "${args_to_check[@]}"; do
if [[ "$password" == "$arg" ]]; then
password=""
break
fi
done

source ~/.bashrc

if [[ -n "$username" && -n "$password"  ]]; then
credentials=$(authenticate "$username" "$password")
elif [ -f "/root/.temp_credentials" ]; then
# This condition is only for the first start.

username=$(grep "username" "/root/.temp_credentials" | cut -d'=' -f2)
password=$(grep "password" "/root/.temp_credentials" | cut -d'=' -f2)

credentials=$(authenticate "$username" "$password")

if [ -n "$credentials" ]; then
rm -f /root/.temp_credentials
fi
else
credentials=$(authenticate)
fi

if [ -z "$credentials" ] || echo "$credentials" | grep -iq "error"; then
echo "$credentials" >&2
return 1
else
username=$(extract_from_json "username" "$credentials")
password=$(extract_from_json "password" "$credentials")
fi

if [[ "$*" != *"--start_fun_frontend"* && \
"$*" != *"--start_filebrowser"* && \
"$*" != *"--start_fun_client"* && \
"$*" != *"--start_hb_gateway"* && \
"$*" != *"--start_hb_client"* ]]
then
start_all "$username" "$password"
return
fi

while [[ $# -gt 0 ]]; do
case "$1" in
--start_all)
start_all "$username" "$password"
return
;;
--start_fun_frontend)
start_fun_frontend
return
;;
--start_filebrowser)
start_filebrowser
return
;;
--start_fun_client)
start_fun_client
return
;;
--start_hb_gateway)
start_hb_gateway "$password"
return
;;
--start_hb_client)
start_hb_client
return
;;
*)
esac
shift
done
}

is_session_running() {
local session="$1"

tmux has-session -t "$session" 2>/dev/null

if [ $? -eq 0 ]; then
echo "TRUE"
else
echo "FALSE"
fi
}

is_process_running() {
local app="$1"
local target_pids parent_pids child_pids

target_pids=$(grep -l "\bAPP=$app\b" /proc/*/environ | cut -d/ -f3 || true)

if [ ! -z "$target_pids" ]; then
echo "TRUE"
else
echo "FALSE"
fi
}

kill_processes_and_subprocesses() {
local app="$1"
local target_pids parent_pids child_pids

target_pids=$(grep -l "\bAPP=$app\b" /proc/*/environ | cut -d/ -f3 || true)

if [ ! -z "$target_pids" ]; then
parent_pids=$(echo "$target_pids" | grep -o -E '([0-9]+)' | tr "\n" " ")

for parent_pid in $parent_pids; do
child_pids=$(pstree -p $parent_pid | grep -o -E '([0-9]+)' | tr "\n" " ")

kill -9 $parent_pid 2>/dev/null || true

for child_pid in $child_pids; do
kill -9 $child_pid 2>/dev/null || true
done
done
fi
}

stop_fun_frontend() {
tmux kill-session -t "fun-frontend"
}

stop_filebrowser() {
tmux kill-session -t "filebrowser"
}

stop_fun_client() {
tmux kill-session -t "fun-client"
}

stop_hb_gateway() {
tmux kill-session -t "hb-gateway"
}

stop_hb_client() {
tmux kill-session -t "hb-client"
}

stop_all() {
stop_fun_frontend
stop_filebrowser
stop_fun_client
stop_hb_gateway
stop_hb_client
}

stop() {
source ~/.bashrc

if [[ $# -eq 0 ]]; then
stop_all
return
fi

while [[ $# -gt 0 ]]; do
case "$1" in
--stop_all)
stop_all
return
;;
--stop_fun_frontend)
stop_fun_frontend
return
;;
--stop_filebrowser)
stop_filebrowser
return
;;
--stop_fun_client)
stop_fun_client
return
;;
--stop_hb_gateway)
stop_hb_gateway
return
;;
--stop_hb_client)
stop_hb_client
return
;;
*)
esac
shift
done
}

status() {
local fun_frontend_status=$(tmux has-session -t "fun-frontend" 2>/dev/null && echo "running" || echo "stopped")
local filebrowser_status=$(tmux has-session -t "filebrowser" 2>/dev/null && echo "running" || echo "stopped")
local fun_client_status=$(tmux has-session -t "fun-client" 2>/dev/null && echo "running" || echo "stopped")
local hb_client_status=$(tmux has-session -t "hb-client" 2>/dev/null && echo "running" || echo "stopped")
local hb_gateway_status=$(tmux has-session -t "hb-gateway" 2>/dev/null && echo "running" || echo "stopped")

output=$(cat << OUTPUT
{
"fun-frontend": "$fun_frontend_status",
"filebrowser": "$filebrowser_status",
"fun-client": "$fun_client_status",
"hb-client": "$hb_client_status",
"hb-gateway": "$hb_gateway_status"
}
OUTPUT
)

echo $output
}

encrypt_message() {
local message=$1

# After encryption, it is converted to base64 format to avoid failures in transfers between variables and programs
local encrypted_message_base64=$(echo "$message" | openssl pkeyutl -encrypt -pubin -inkey /root/.ssh/id_rsa_openssl.pub.pem -pkeyopt rsa_padding_mode:oaep | base64)

echo "$encrypted_message_base64"
}

decrypt_message() {
local encrypted_message_base64=$1

# Decode the Base64 encrypted message and decrypt it directly
local decrypted_message=$(echo "$encrypted_message_base64" | base64 --decode | openssl pkeyutl -decrypt -inkey /root/.ssh/id_rsa -pkeyopt rsa_padding_mode:oaep)

echo "$decrypted_message"
}

generate_sha256sum() {
local message=$1

#	local hash_value=$(echo -n "$message" | openssl dgst -sha256)
local hash_value=$(echo -n "$message" | sha256sum | awk '{print $1}')

echo "$hash_value"
}

escape_string() {
local string=$1
local escaped_string=""
#	local ord
local symbols='$#&|;()<>*!?[]\/\"\`'

for ((i=0; i<${#string}; i++)); do
character="${string:i:1}"
if [[ $symbols =~ "$character" ]]; then
#			ord=$(printf '%d' "'$character")
#			escaped_string+="\\$ord"
escaped_string+="\\$character"
else
escaped_string+="$character"
fi
done

echo "$escaped_string"
}

extract_from_json() {
local path=$1
local json=$2

echo $json | /usr/bin/jq -r ".$path"
}

get_credentials() {
local username="$1"
local password="$2"
local credentials_json

if [ -z "$username" ]; then
read -rp "Username: " username
username=$(escape_string "$username")
fi

if [ -z "$password" ]; then
read -rs -p "Password: " password
password=$(escape_string "$password")
fi

credentials_json="{\"username\":\"$username\",\"password\":\"$password\"}"

echo "$credentials_json"
}

authenticate() {
local username="$1"
local password="$2"

if [ ! -f "/root/.ssh/id_rsa" ] || { [[ -n "$username" ]] && [[ -n "$password" ]]; }; then
if [ -n "$NON_ENCRYPTED_CREDENTIALS_SHA256SUM" ]; then
local non_encrypted_informed_credentials_json
local non_encrypted_informed_credentials_json_sha256sum

if [[ -n "$username" && -n "$password"  ]]; then
non_encrypted_informed_credentials_json=$(get_credentials "$username" "$password")
else
non_encrypted_informed_credentials_json=$(get_credentials)
fi

non_encrypted_informed_credentials_json_sha256sum=$(generate_sha256sum "$non_encrypted_informed_credentials_json")

if [ "$non_encrypted_informed_credentials_json_sha256sum" == "$NON_ENCRYPTED_CREDENTIALS_SHA256SUM" ]; then
echo $non_encrypted_informed_credentials_json
else
>&2 echo "Error: Authentication failed. Invalid username or password."
return 1
fi
else
>&2 echo "Error: Authentication failed. No stored credentials hash found."
return 1
fi
else
if [ -n "$ENCRYPTED_CREDENTIALS" ]; then
local decrypted_stored_credentials_json

decrypted_stored_credentials_json=$(decrypt_message "$ENCRYPTED_CREDENTIALS")

echo $decrypted_stored_credentials_json
else
>&2 echo "Error: Authentication failed. No stored encrypted credentials found."
return 1
fi
fi
}

log_all () {
tail -f \
~/shared/logs/tmux/fun-frontend.log \
~/shared/logs/tmux/filebrowser.log \
~/shared/logs/tmux/fun-client.log \
~/shared/logs/tmux/hb-gateway.log \
~/shared/logs/fun-client/all.log \
~/shared/logs/hb-gateway/* \
~/shared/logs/hb-client/*
}

quick_deploy_fun_hb_client () {
set -ex

local branch="$1"

cd /root/funttastic/client || { echo "Failed to open the repository folder..."; return 1; }

unlink /root/funttastic/client/resources

git reset

git stash

if [ -n "$branch" ]; then
current_branch_name=$(git rev-parse --abbrev-ref HEAD)

if [ ! "$branch" == "$current_branch_name" ]; then
    	git switch "$current_branch_name"
    fi
fi

git fetch --all
git pull

rm -rf /root/funttastic/client/resources

ln -s /root/shared/funttastic/client/resources /root/funttastic/client/resources

git stash apply

cd ~ || return

set +ex
}


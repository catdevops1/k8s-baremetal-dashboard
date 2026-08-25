#!/bin/bash
#
# apply-netdata.sh
#
# Deploys the netdata Helm release using values.yaml as the canonical,
# git-tracked config, with the real secrets (streaming api key and
# Netdata Cloud claiming token/room) injected fresh from Vault at
# deploy time.
#
# Why this exists: values.yaml only ever contains placeholders for
# these secrets (__STREAMING_API_KEY__, __NETDATA_CLAIM_TOKEN__,
# __NETDATA_CLAIM_ROOM__) so it's safe to commit to this public repo.
# The real values live only in Vault (secret/netdata/streaming and
# secret/netdata/claiming) and are pulled in here, used for the few
# seconds this script runs, then discarded — never written to disk
# permanently and never committed anywhere.
#
# Usage: run this instead of a raw `helm upgrade` whenever you change
# something in values.yaml (resource limits, image tag, etc). Requires
# kubectl access to the vault-0 pod.
#
set -euo pipefail

STREAM_KEY=$(kubectl exec -n vault vault-0 -- vault kv get -field=API_KEY secret/netdata/streaming)
CLAIM_TOKEN=$(kubectl exec -n vault vault-0 -- vault kv get -field=TOKEN secret/netdata/claiming)
CLAIM_ROOMS=$(kubectl exec -n vault vault-0 -- vault kv get -field=ROOMS secret/netdata/claiming)

TMPFILE=$(mktemp)
cat > "$TMPFILE" <<EOC
[stream]
    enabled = yes
    destination = netdata-parent:19999
    api key = $STREAM_KEY
    timeout seconds = 60
    buffer size bytes = 1048576
    reconnect delay seconds = 5
    initial clock resync iterations = 60
EOC

helm upgrade netdata netdata/netdata -n netdata --version 3.7.145 \
  -f values.yaml \
  --set-file child.configs.stream.data="$TMPFILE" \
  --set-string child.claiming.token="$CLAIM_TOKEN" \
  --set-string child.claiming.rooms="$CLAIM_ROOMS"

shred -u "$TMPFILE" 2>/dev/null || rm -f "$TMPFILE"

#!/bin/sh
# Cada peer genera su propio par de llaves. La PrivateKey vive SOLO dentro del peer
# (/etc/wireguard, no montado). Solo la PublicKey se publica en /shared.
set -e
umask 077
mkdir -p /etc/wireguard
wg genkey > /etc/wireguard/private.key
wg pubkey < /etc/wireguard/private.key > /shared/${ME}.pub

# Esperar la llave publica del otro peer
while [ ! -s /shared/${PEER}.pub ]; do sleep 1; done

cat > /etc/wireguard/wg0.conf <<CONF
[Interface]
Address = ${TUN_IP}/24
ListenPort = 51820
PostUp = wg set %i private-key /etc/wireguard/private.key

[Peer]
PublicKey = $(cat /shared/${PEER}.pub)
Endpoint = ${PEER_ENDPOINT}:51820
# Split tunnel: solo la IP de tunel del otro peer (NO 0.0.0.0/0)
AllowedIPs = ${PEER_TUN_IP}/32
PersistentKeepalive = 25
CONF

wg-quick up wg0
echo "[$ME] tunel arriba"
exec sleep infinity

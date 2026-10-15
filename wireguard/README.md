# Túnel WireGuard — evidencia

## Topología

```
 peer-a                                         peer-b
 wg0 10.18.0.1/24  ==== túnel WireGuard ====   wg0 10.18.0.2/24
 eth0 172.30.18.10 ---- UDP 51820 (underlay) -- eth0 172.30.18.20
                   red de laboratorio aislada 172.30.18.0/24
```

- Dos peers Linux que controlamos, en una red de laboratorio privada (sin tráfico de terceros).
- Las IPs del underlay son privadas (RFC 1918), así que no hay IPs públicas que tachar.
- **Split tunnel:** `AllowedIPs = 10.18.0.2/32` en A y `10.18.0.1/32` en B. Nada de `0.0.0.0/0`, así que solo pasa por el túnel el tráfico hacia la IP del otro peer.

## Llaves (solo se intercambian las públicas)

`peer.sh` hace en cada peer:

1. `wg genkey` → la private key se queda en `/etc/wireguard/private.key` (modo 600, `umask 077`), **dentro del peer**, en un directorio que no está montado ni en el repo.
2. `wg pubkey` → se publica **solo** la public key en el directorio compartido.
3. El `wg0.conf` carga la private key con `PostUp = wg set %i private-key …`, así que la llave nunca se escribe en el config.

Al terminar destruimos los peers y, con ellos, las private keys. `.gitignore` bloquea `*.key` / `*private*`. Verificado con `grep -ri privatekey evidencia/` → sin resultados.

Public keys (se pueden publicar):
- peer-a: `49HnUIHJig36uraoTarmFQ4h1Qx6PzXVY+njoD6ZhT8=`
- peer-b: `W/EUz37rOrwH8bvTy0ALmcX8KEHxBP4JVy2Fo8VCniY=`

## Resultado

`evidencia/wg_show_peer-a.txt`:
```
peer: W/EUz37rOrwH8bvTy0ALmcX8KEHxBP4JVy2Fo8VCniY=
  endpoint: 172.30.18.20:51820
  allowed ips: 10.18.0.2/32
  latest handshake: 10 seconds ago
  transfer: 1.09 KiB received, 1.18 KiB sent
```
Ping A→B: 5/5, rtt promedio 0.73 ms. Ping B→A: 3/3 (`evidencia/ping_*.txt`).

### Captura UDP 51820 (`evidencia/udp51820_underlay.pcap`, disección: `tshark_underlay_resumen.txt`)

| # | src → dst | len | WireGuard |
|---|---|---|---|
| 1 | .10 → .20 | 190 | **Handshake Initiation**, sender=0xDD5682AA |
| 2 | .20 → .10 | 134 | **Handshake Response**, sender=0x6316374A, receiver=0xDD5682AA |
| 3 | .10 → .20 | 74 | Keepalive (transport vacío), counter=0 |
| 4–19 | ambos | 170 | **Transport Data**, datalen=96, counter 1…8 |

`handshake_initiation_detalle.txt`: el Initiation lleva una llave **efímera** en claro (Curve25519, sirve para el DH), pero la identidad estática del iniciador viaja como *Encrypted Static* y el timestamp como *Encrypted Timestamp*.

### Payload ilegible (`payload_underlay_vs_overlay.txt`)

Mandamos los pings con el patrón `ping -p` = `LAB18-SECRET0`:

| Dónde capturamos | Veces que aparece `SECRE` |
|---|---|
| `eth0` UDP 51820 (lo que ve la red) | **0**: solo bytes aleatorios después de la cabecera WG |
| `wg0` (ya descifrado, en el peer) | **10**: `4c41 4231 382d 5345 4352 4554 30` = `LAB18-SECRET0` |

Frame de 170 bytes = 14 Ethernet + 20 IP + 8 UDP + 16 cabecera WG (tipo, receiver index, counter) + 96 de ciphertext (84 del paquete ICMP interno + 12 bytes de relleno hasta un múltiplo de 16) + 16 de tag Poly1305. Para la red, ese tamaño es lo único que queda visible del ping.

### Qué ve cada quien

> **Mi ISP / la red ve** que `172.30.18.10` y `172.30.18.20` intercambian datagramas UDP en el puerto 51820, cuándo, con qué tamaños (190/134/170 B) y con qué ritmo (incluido el keepalive cada 25 s), además de los índices de sesión y los contadores. No ve las IPs internas (10.18.0.x), que es ICMP ni el contenido.
> **El otro peer del túnel ve** el paquete interno completo ya descifrado: IP de túnel origen 10.18.0.1, protocolo, destino y payload (`LAB18-SECRET0`). Además, sabe con certeza que lo mandó quien tiene la private key correspondiente a `49HnUI…`.

Como no es full-tunnel, el resto del tráfico de cada máquina sigue saliendo por la red normal. El túnel no le oculta nada a nadie sobre ese tráfico.

### Túnel abajo

`evidencia/tunel_abajo.txt`: `wg-quick down wg0` en ambos peers; `wg show` queda vacío. Después eliminamos los peers y la red de laboratorio.

## Reproducir

```sh
cd wireguard && mkdir -p shared && docker compose up -d --build
docker exec wg-peer-a wg show && docker exec wg-peer-a ping -c 3 10.18.0.2
docker exec wg-peer-a wg-quick down wg0; docker exec wg-peer-b wg-quick down wg0
docker compose down && rm -rf shared
```

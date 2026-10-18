## LAB # 18: Signal + Safety Number y túnel WireGuard

| Entregable | Archivo | Estado |
|---|---|---|
| Safety Number (qué ataque detecta) | [parte-a-safety-number.md](parte-a-safety-number.md) | ✅ verificado, captura en [evidencia-signal/](evidencia-signal/) |
| Tabla servidor-sabe / no-lee + bigbrother | [parte-b-servidor-signal.md](parte-b-servidor-signal.md) | ✅ |
| Evidencia WireGuard (sin private keys) | [wireguard/README.md](wireguard/README.md), [wireguard/evidencia/](wireguard/evidencia/) | ✅ handshake + bytes + ping + captura UDP 51820 + túnel abajo |
| E2EE.md | [E2EE.md](E2EE.md) | ✅ |

### Chat de lab
> El servidor no puede leer **el texto de mis mensajes, mis contactos ni mis grupos**, pero sí sabe **que mi cuenta existe, cuándo me conecté por última vez y, mientras estoy conectado, mi IP**.

### Evidencia WireGuard (resumen)
- `wg show`: `latest handshake: 10 seconds ago`, `transfer: 1.09 KiB received, 1.18 KiB sent`, `allowed ips: 10.18.0.2/32` (split tunnel).
- Ping 10.18.0.1 ↔ 10.18.0.2: 0 % de pérdida en ambos sentidos.
- Captura UDP 51820: **Handshake Initiation (190 B) → Handshake Response (134 B) → Transport Data (170 B)**. El patrón `LAB18-SECRET0` aparece 0 veces en el underlay y 10 veces en `wg0`.
- Private keys generadas dentro de cada peer, nunca escritas al repo y destruidas al bajar el túnel.

### Comentarios de aprendizaje

**Payload vs metadata.** En los dos sistemas vimos lo mismo: el cifrado protege el *payload* y deja expuesta la *metadata*. En la captura, el ping "secreto" es ilegible, pero cualquiera en la red sabe qué dos IPs hablan, por qué puerto, cuántos bytes y con qué ritmo. Hasta el keepalive cada 25 s delata que hay un túnel vivo. Con Signal pasa igual: el texto es inaccesible, pero el servidor necesita saber a quién entregar y cuándo estás en línea. La diferencia es que Signal además *reduce* la metadata por diseño (sealed sender, grupos con zkgroup, contact discovery en SGX) y por política (bigbrother: solo fecha de creación y última conexión).

**Quién ve destinos en el túnel.** WireGuard no anonimiza: mueve la confianza. El ISP deja de ver los destinos internos (10.18.0.x) y el protocolo, pero el **otro peer** ve el paquete interno completo. En un full-tunnel (`0.0.0.0/0`) el otro extremo vería *todos* mis destinos, que es exactamente lo que hace un proveedor de VPN. Por eso aquí usamos `AllowedIPs` /32: el túnel solo transporta tráfico hacia el peer y no le entregamos nuestra navegación a nadie. Ver quién habla con quién sin confiar en un único punto es el problema que resuelve Tor, no WireGuard.

**Autenticación ≠ cifrado.** El Safety Number y las public keys de WireGuard cumplen el mismo papel: un canal cifrado con la llave equivocada es un MITM. WireGuard lo resuelve porque las public keys se pegan a mano en el config. Signal lo delega a que el usuario compare el Safety Number fuera de banda.

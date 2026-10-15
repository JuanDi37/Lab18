# E2EE: Signal, WireGuard y acceso excepcional

## (a) Dispositivo comprometido a mitad del chat: FS y PCS

**Mensajes pasados → forward secrecy.** El Double Ratchet deriva una llave por mensaje con una KDF de un solo sentido y la borra después de usarla. Con el estado actual no se pueden recalcular las llaves anteriores, así que el ciphertext pasado que alguien haya grabado en la red sigue protegido. Hay un límite importante: la FS protege *llaves*, no el *historial*. Si la app guarda el chat en texto plano en el dispositivo (y lo guarda, para mostrarlo), el atacante simplemente lo lee. Contra eso ayudan los mensajes temporales, no la criptografía.

**Mensajes futuros → post-compromise security.** Cada vez que cambia el turno de la conversación, el ratchet Diffie-Hellman mezcla un par efímero nuevo. Si el atacante solo se llevó una copia y deja de observar, el siguiente paso DH con aleatoriedad que no conoce "cura" la sesión y vuelve a quedar fuera. Con malware persistente o un dispositivo enlazado propio, ningún protocolo lo saca: hay que revisar los *linked devices* y volver a verificar el Safety Number.

## (b) Mandato de acceso excepcional: Signal vs WireGuard

**Signal:** el servidor nunca tiene llaves, así que no hay nada que "entregar". Para cumplir un mandato habría que **cambiar los clientes**: escrow de llaves de sesión (lo que destruye FS y PCS, porque aparece una llave de larga duración que lo abre todo), un "usuario fantasma" que el servidor añade en silencio como dispositivo o miembro (lo que obliga a ocultar las alertas de cambio de Safety Number) o escaneo en el cliente antes de cifrar. Todas rompen la E2EE para todos los usuarios, no solo para el sospechoso.

**WireGuard:** no hay proveedor central. Cada peer genera sus llaves y el protocolo (Noise IK) no tiene un tercero al que obligar. El mandato tendría que **modificar el protocolo o el código de cada endpoint** para exportar las llaves efímeras a una autoridad, en un software abierto (está en el kernel de Linux) que cualquiera compila sin el cambio. En la práctica, solo queda comprometer endpoints uno por uno.

Como argumentan Abelson et al. en *Keys Under Doormats* (2015), el acceso excepcional **elimina la forward secrecy**, **añade complejidad** donde nacen las vulnerabilidades y **concentra en un solo lugar** llaves que se vuelven un blanco valioso para cualquier atacante, no solo para el Estado.
## (c) Tor vs Signal vs WireGuard para nuestro venture

Para nuestro venture: **Signal** esconde el *contenido* de las conversaciones del equipo frente al servidor y la red, pero no que usamos Signal; **WireGuard** esconde el contenido y las IPs internas del tráfico entre nuestros servidores frente al ISP y la red intermedia, pero el otro extremo del túnel lo ve todo y el ISP ve que existe el túnel; **Tor** esconde *quién habla con quién* (nuestra IP frente al destino y el destino frente a nuestro ISP), pero no protege el contenido frente al nodo de salida si no hay TLS o E2EE encima.

---
*Referencia:* H. Abelson, R. Anderson, S. Bellovin, J. Benaloh, M. Blaze, W. Diffie, J. Gilmore, M. Green, S. Landau, P. Neumann, R. Rivest, J. Schiller, B. Schneier, M. Specter, D. Weitzner. "Keys Under Doormats: Mandating insecurity by requiring government access to all data and communications." MIT CSAIL Technical Report MIT-CSAIL-TR-2015-026, 2015.

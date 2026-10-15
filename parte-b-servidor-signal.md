# Parte B: qué sabe y qué no lee el servidor de Signal

Distinguimos dos cosas:
- **En tránsito:** lo que el servidor *ve* mientras atiende la conexión.
- **Guardado / entregable:** lo que Signal *conserva* y podría entregar ante una orden judicial.

| Dato | ¿El servidor lo lee/sabe? | Por qué (diseño o fuente) | ¿Lo guarda y puede entregarlo? (bigbrother) |
|---|---|---|---|
| **Texto del mensaje** | **No lo lee** | E2EE con el Signal Protocol (PQXDH + Double Ratchet): el servidor solo transporta ciphertext y las llaves están en los dispositivos. | No. No tiene el contenido. |
| **Que la cuenta existe** | **Sí sabe** | La cuenta se registra con un número de teléfono verificado por SMS. Para entregarle mensajes, el servidor tiene que saber que la cuenta existe. | **Sí:** fecha y hora de creación de la cuenta. Es uno de los dos datos que Signal ha entregado. |
| **Cuándo se conectó el dispositivo** | **Sí sabe** (en tránsito) | El cliente abre una conexión autenticada para recibir mensajes en cola. | **Sí, pero gruesa:** solo la fecha de la *última* conexión (el día, sin historial). |
| **Tamaño aproximado** | **Sí ve** (en tránsito) | El ciphertext tiene una longitud. Signal rellena los mensajes (padding), así que la longitud solo da una idea aproximada. | No figura entre lo que Signal dice conservar. |
| **Quién envió** | **Normalmente no** (sealed sender) | Con *sealed sender*, el certificado del remitente viaja **cifrado dentro del sobre**; el servidor solo ve el **destinatario** y comprueba un *delivery token* derivado de la profile key, sin saber quién lo usa. Límite: ve la IP/conexión de quien entrega el sobre, así que podría inferir el remitente por timing o IP si lo intentara. Los primeros mensajes a desconocidos o con el modo desactivado no son sealed. | No: no hay registro de remitente→destinatario. |
| **IP mientras está conectado** | **Sí ve** (en tránsito) | Es TCP/TLS: sin la IP no puede responder. Signal afirma no registrarla. | No aparece en las respuestas publicadas de bigbrother. |
| **Lista de contactos / grupos** | **No lee** | Los contactos viven en el dispositivo. El *contact discovery* se hace dentro de un enclave SGX (CDSI) para que el operador no vea qué números consultaste. Los grupos usan el *Private Group System* (credenciales zkgroup): el servidor guarda el estado del grupo **cifrado** y no sabe quién es miembro. Nombre, foto y perfil van cifrados con la profile key. | No. |

## Contraste con signal.org/bigbrother

En cada caso publicado (p. ej. el gran jurado del Eastern District of Virginia en 2016, California en 2021 y otros), Signal solo pudo entregar **dos datos**: la fecha de **creación de la cuenta** y la fecha de **última conexión**. No pudo entregar mensajes, contactos, grupos, nombres, fotos ni IPs.

Conclusión: la columna "en tránsito" es más amplia que la de "guardado". El servidor **ve** IP, tamaño, hora y destinatario mientras ocurre la conexión, pero el diseño intenta que nada de eso **quede** guardado. Lo que protege el *contenido* es la criptografía. Lo que protege la *metadata* es, en parte, criptografía (sealed sender, grupos cifrados, SGX) y, en parte, la **política** de no guardar logs. Lo primero se puede verificar; lo segundo hay que creérselo al operador.

Fuentes: signal.org/bigbrother · signal.org/blog/sealed-sender · signal.org/blog/signal-private-group-system · signal.org/blog/private-contact-discovery · signal.org/docs (PQXDH, Double Ratchet).

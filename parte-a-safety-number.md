# Parte A: Safety Number

> ⚠️ **PENDIENTE (en persona):** este paso requiere dos teléfonos con Signal oficial y verificar cara a cara. Completar los campos marcados con `[ ]`.

## Pasos
1. Instalar Signal **oficial** desde signal.org/download (Play Store o App Store).
2. Intercambiar 1–2 mensajes de prueba con un compañero.
3. Abrir el chat → nombre del contacto → **View safety number**.
4. En persona: escanear el QR del otro, o comparar los 60 dígitos (12 bloques de 5).
5. Si coinciden → **Mark as verified**. Aparece el check de "verificado" en el chat.
6. Screenshot → **tachar números de teléfono, nombres y cualquier dato personal** → guardarlo como `img/safety-number-tachado.png`.

## Evidencia
- Safety number verified: `[ ] sí / no`
- Método: `[ ] QR / dígitos`
- Screenshot: ![Safety Number tachado](img/safety-number-tachado.png)

## ¿Qué ataque detectaría un Safety Number que no coincide?

Un **man-in-the-middle por sustitución de llaves**. El Safety Number es un fingerprint de las dos *identity keys* (la mía y la del contacto). Si el servidor de Signal (comprometido u obligado), o alguien que tomó el número con un SIM swap, nos entregara una identity key falsa para cada lado, podría descifrar y volver a cifrar todo sin que lo notáramos. En ese caso, los números que ve cada teléfono **no coinciden**, porque cada uno calcula el fingerprint con una llave distinta. Al compararlos por un canal independiente (en persona), el MITM queda al descubierto.

Una advertencia de "safety number changed" también aparece por motivos legítimos, como reinstalar la app o cambiar de teléfono. Por eso hay que volver a verificar en persona antes de confiar.

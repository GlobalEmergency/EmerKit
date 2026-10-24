# Medición de producto de EmerKit 0.1.19

Estado: implementación en revisión; no equivale a publicación de la nueva app. Colector propio instalado en GlobalEmergency y comprobado por HTTPS el 24/10/2026. Las versiones publicadas anteriores no adquieren instrumentación automáticamente.

## Qué permite responder

- Qué herramientas se abren y cuántas instalaciones participantes las utilizan.
- Cuántas sesiones y aperturas se observan entre quienes permiten medir.
- Plataforma, versión e idiomas del dispositivo y la interfaz. La interfaz instrumentada actual es española; idioma del dispositivo no significa idioma elegido en la app.
- Campaña de adquisición Android recibida mediante Google Play Install Referrer y enviada únicamente con permiso.
- Clics diarios agregados de enlaces a Android e iOS, separados por origen/campaña/pieza. iOS no vincula estos clics a instalaciones ni al uso posterior.

No mide profesión, edad, identidad, eficacia clínica ni conversiones verificadas de iOS. No se llama instalación nueva al momento en que un usuario existente acepta medir: el evento es `measurement_started`, distinto de los primeros accesos de Google Play.

## Consentimiento y datos mínimos

Aviso no modal ES/EN según idioma del dispositivo y ajuste en Acerca de. Rechazar no limita ninguna herramienta. Antes de aceptar no hay identificador persistente de analítica ni transmisión de eventos.

Eventos permitidos: measurement_started, app_open, home_ready inicial, tool_open y external_tool_open (DEA externo). Solo se envían IDs del registro de herramientas; nunca valores introducidos, resultados, búsquedas, texto libre, URLs de rutas, pacientes ni ubicación. Se incluyen identificadores aleatorios de app/sesión/evento, fecha, plataforma, versión, idioma y cuatro campos de campaña validados. No IDFA, Advertising ID ni SDK publicitario.

Los datos son seudónimos: el servidor conserva HMAC de instalación y sesión. No son datos anónimos ni representan toda la audiencia, porque el consentimiento introduce selección. No dividir clics, eventos de uso y descargas de stores para inventar tasas de cohorte.

## Funcionamiento y límites

Inicialización y envíos asíncronos: la apertura de EmerKit y sus herramientas no espera a la red. Lectura Install Referrer con límite de 2 s, HTTP con 3 s. Cola local de 50 eventos máximo; lotes de 20; eventos caducan a los 7 días. Metadatos de sesión/versión/idioma se preservan durante reintentos y actualizaciones. El servidor deduplica por event_id. Un HTTP 200 sin acuse JSON válido no elimina la cola.

Al retirar permiso se detiene la recogida, se vacía la cola y se solicita borrado del historial remoto. Si falla la conexión, queda pendiente hasta otro intento. Una nueva aceptación espera ese borrado antes de generar otra identidad. Una preferencia corrupta no concede permiso; un ID válido recuperado de ella se conserva solo para poder borrar. Si el almacenamiento falla se informa y la app continúa funcionando.

Desinstalar o borrar datos locales antes de completar la solicitud impide asociar una petición posterior al ID perdido. No se promete borrado remoto por desinstalar. El servidor elimina eventos de más de 180 días mediante tarea diaria y mantiene una marca de borrado 7 días para bloquear reintentos antiguos. Los registros técnicos del hosting son independientes de la base de analítica.

## Operación

Colector: https://emerkit.globalemergency.online/wp-json/emerkit/v1/events

Panel privado: https://emerkit.globalemergency.online/wp-admin/tools.php?page=emerkit-analytics

Acceso con los permisos administrativos existentes del WordPress de GlobalEmergency. No se crea ninguna credencial nueva. El panel ofrece periodos 7/28/90 días y CSV agregado. No expone IDs individuales.

El subdominio usa vhost y certificado independientes en srv07; el dominio público principal sigue en Vercel. No cambiar el certificado del dominio principal para mantener este servicio. La política pública y los enlaces web se actualizan en GlobalEmergency/Website. Los enlaces de YouTube ES/EN ya están etiquetados; YouTube indica que el canal necesita verificación para habilitar enlaces externos clicables.

Detalles reproducibles del servidor, contrato, pruebas y reversión: ../../backend/emerkit-analytics/01-operations.md.

La publicación móvil debe hacerse después de actualizar las declaraciones de privacidad de ambas stores y publicar la política revisada. El flujo actual de main publica Android en producción automáticamente, por lo que el PR móvil se mantiene en borrador hasta completar ese punto.

Validación final local: 248 pruebas Flutter correctas, análisis sin avisos, revisión independiente sin hallazgos P1/P2; APK debug compilado y APK release x86_64 0.1.19 probado en emulator-5556 con tres aperturas COLD y pantalla de inicio revisada. Firma local de debug únicamente para pruebas; no es un artefacto de publicación. La accesibilidad de uiautomator no proporcionó etiquetas y no se presenta como prueba automática de llegada a home; se verificó la captura. El primer intento release falló por registrante generado de desarrollo; clean + build secuencial regeneró el registrante y terminó correctamente, sin cambiar el splash. iOS no se compiló en Windows.

# Declaraciones de privacidad para 0.1.19

Preparación basada en el comportamiento implementado, no confirmación de formularios ya guardados. Las versiones 0.1.18 y anteriores no envían esta telemetría. Actualizar antes de distribuir 0.1.19 y verificar el binario final; no afirmar «no se recopilan datos» con esta función habilitada.

## Google Play

Recopilación opcional (todos pueden rechazar), transmisión cifrada HTTPS, propósito analítica. Declarar Actividad de la aplicación → Interacciones con la app; Información y rendimiento → Diagnósticos (tiempo hasta inicio); Dispositivo u otros IDs (ID aleatorio de instalación). No son tratamientos efímeros: servidor hasta 180 días. Borrado solicitado desde Acerca de, con reintento si no hay conexión.

No se comparte con redes publicitarias ni se integra Firebase Analytics. Infraestructura/hosting como proveedor del servicio, según las definiciones y excepciones de Google. No declarar valores clínicos, ubicación, email ni identificadores publicitarios para este colector, porque no se envían. Revisar por separado los registros técnicos del hosting y otros servicios que ya existan; no inventar sus plazos.

Las UTM miden canales propios de adquisición; no se usan para publicidad dirigida. Si se amplía a medir campañas pagadas, revisar también la finalidad «Publicidad o marketing» antes de ese cambio. No atribuir una instalación solo porque haya un clic en el enlace.

## App Store Connect

Declarar datos de uso → Interacción con el producto; identificadores → ID de dispositivo (ID de instalación de app); diagnósticos → Datos de rendimiento (tiempo hasta inicio). Finalidad Analítica. Tratamiento conservador: vinculados mediante el identificador de instalación; no marcar anónimos solo porque el ID sea aleatorio o se almacene un HMAC. No usados para tracking entre empresas, publicidad dirigida ni compartidos con data brokers.

No IDFA ni ATT por este diseño. Que sea opcional no permite omitir automáticamente la declaración: se recoge de forma continua tras la aceptación y persiste un ID de app. No declarar la medición de producto como «no se recopilan datos».

El paquete shared_preferences_foundation incluye PrivacyInfo.xcprivacy para UserDefaults, razón 1C8F.1. Revisar el Privacy Report del archivo iOS en CI/macOS y comprobar que el paquete final contiene ese recurso; Windows no sustituye compilar y archivar iOS.

## Política y verificación final

URL conservada: https://www.globalemergency.online/privacidad-emerkit

Debe explicar versión de inicio, opt-in, datos concretos, seudonimización, retención, cola y borrado pendiente offline. La política incluye el tratamiento independiente de logs técnicos y el límite de atribución de iOS. Enlaces/clics del subdominio se activan al publicarse cada enlace; la analítica de app solo al instalar 0.1.19 y aceptar.

Fuentes oficiales comprobadas el 24/10/2026:

- https://support.google.com/googleplay/android-developer/answer/10787469?hl=es
- https://developer.apple.com/app-store/app-privacy-details/
- https://developer.apple.com/app-store/user-privacy-and-data-use/

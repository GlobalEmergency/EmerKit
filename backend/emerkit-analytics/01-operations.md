# Operación de EmerKit Analytics

Plugin propio para el WordPress de GlobalEmergency. Base real del colector: `https://emerkit.globalemergency.online/wp-json/emerkit/v1/`. Panel: `https://emerkit.globalemergency.online/wp-admin/tools.php?page=emerkit-analytics`. PHP >=7.4, WordPress >=6.4, MySQL/MariaDB con InnoDB y `GET_LOCK`. Sin dependencias Composer. El cliente controla el consentimiento; el endpoint público no autentica instalaciones ni convierte identificadores aleatorios en identidad de usuario.

## Instalación y comprobación

Copiar esta carpeta como `wp-content/plugins/emerkit-analytics/` (excluir `tests/` en producción si se desea). El plugin no se activa al copiarlo. Ejecutar WP-CLI como el usuario del vhost:

```sh
find wp-content/plugins/emerkit-analytics -name '*.php' -exec php -l {} \;
wp plugin activate emerkit-analytics
wp plugin status emerkit-analytics
wp option get emerkit_analytics_schema
wp cron event list --fields=hook,next_run_gmt,recurrence | grep emerkit_analytics_cleanup
wp eval '$s = new \EmerKit\Analytics\Store($GLOBALS["wpdb"]); echo wp_json_encode($s->report(7), JSON_PRETTY_PRINT);'
```

La activación crea tres tablas del prefijo WordPress (`emerkit_events`, `emerkit_erased`, `emerkit_clicks`), registra el cron diario y actualiza las reglas de enlaces permanentes. La versión de esquema es `1`; las actualizaciones llaman a `dbDelta`. El panel está en **Herramientas → EmerKit Analytics**, limitado a `manage_options`. Permite 7/28/90 días y CSV agregado con nonce y protección de fórmulas. No exporta identificadores individuales.

No se debe vaciar ninguna tabla de producción para probar. Para comprobar envío/borrado reales sin contaminar datos, usar una instalación efímera de 128 bits y enviar solo `measurement_started`, borrar inmediatamente, y verificar por HMAC vía WP-CLI. No probar clics en producción: sus agregados no tienen identificador de borrado individual. El lint local se realizó con PHP 8.4; ejecutar también el comando anterior con el PHP real del vhost antes de activar.

## Host dedicado e infraestructura

La web pública está en Vercel. El colector utiliza el **subdominio Plesk independiente** `emerkit.globalemergency.online`, compartiendo el docroot del WordPress original. Tiene certificado HTTPS propio verificado. No es un alias TLS del dominio raíz: no tocar el certificado ni la configuración del vhost raíz para actualizar este plugin.

Solo cuando `HTTP_HOST` es exactamente `emerkit.globalemergency.online`, el plugin adapta URLs de site/home/content/admin y network generadas para los dominios WordPress conocidos hacia HTTPS del host dedicado, mediante filtros cargados al iniciar el plugin. No modifica opciones `home`/`siteurl` ni el comportamiento de otros hosts. Así login, formularios, CSS/JS y la vuelta al panel permanecen en WordPress y no acaban en el login inexistente de Vercel. Las cookies siguen siendo las propias de autenticación de WordPress, sin cookies nuevas de analítica.

El host añadido a `allowed_redirect_hosts` es una constante exacta, nunca una cabecera aportada libremente. Además, el redirect de login solo acepta una ruta relativa segura o HTTPS del mismo host, sin credenciales ni puerto; cualquier destino externo o ambiguo vuelve a `/wp-admin/`. Los permisos `manage_options` y nonce de exportación siguen siendo obligatorios.

Las respuestas PHP del alias llevan `X-Robots-Tag: noindex, nofollow`. Sus páginas front antiguas redirigen con 302 al destino fijo `https://www.globalemergency.online/proyectos/emerkit`; REST (incluido `?rest_route=`), login/admin, assets WordPress, cron y `/emerkit/descargar/android/` e `/ios/` permanecen operativos. Los archivos estáticos servidos directamente por nginx no pasan por PHP: si se requiere noindex en absolutamente todas esas respuestas, añadir la misma cabecera únicamente al vhost dedicado. No aplicar este cambio al vhost público de Vercel.

Tras copiar la actualización, ejecutar lint PHP en el vhost y comprobar sin iniciar sesión que `/wp-admin/tools.php?page=emerkit-analytics` redirige al `/wp-login.php` **del host dedicado**, que sus assets usan ese mismo host, que una página antigua devuelve el 302 fijo y que REST y redirects de stores conservan su contrato. No hace falta reactivar ni cambiar el esquema para pasar de plugin 1.0.0 a 1.0.1.

## Contrato

`POST https://emerkit.globalemergency.online/wp-json/emerkit/v1/events`, Content-Type `application/json`:

```json
{"schema":1,"installation_id":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","session_id":"bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb","platform":"android","app_version":"0.1.19","device_language":"es-ES","ui_language":"es","attribution":{"source":"youtube","medium":"video","campaign":"aso_202610","content":"es"},"events":[{"id":"cccccccccccccccccccccccccccccccc","name":"tool_open","tool_id":"glasgow","occurred_at":"2026-10-24T20:00:00.000Z"}]}
```

El ejemplo no debe enviarse tal cual: sustituir IDs y fecha por valores nuevos. `attribution` es opcional; si existe, debe ser un objeto (vacío permitido). Campos UTM source/medium/campaign/content: ASCII `[a-z0-9_-]{1,48}`. Idioma del dispositivo: etiqueta ASCII de hasta 35 caracteres; interfaz: es/en; plataformas: android/ios/web. Versión semver sin metadatos, tres enteros 0..9999. Los IDs son 32 hex minúsculas.

Eventos: `measurement_started`, `app_open`, `home_ready`, `tool_open`, `external_tool_open`. Solo los dos últimos requieren `tool_id`; el evento externo admite únicamente `deamap` y el interno el resto del ToolRegistry. Solo app_open/home_ready admiten `startup_ms`, entero 0..120000. Nunca se admiten campos clínicos o claves adicionales. Fecha UTC estricta con Z, segundos y fracción opcional de 1–6 dígitos, normalizada a segundos al almacenar. Ventana desde 7 días atrás hasta 5 minutos futuros. Lotes de 1–20, <=32768 bytes. Se valida todo el lote antes de acceder a las tablas y los inserts se ejecutan en una transacción.

Éxito 200 `{"accepted":N}`: N son eventos nuevos. Los duplicados globales por event_id no se modifican ni se vuelven a contar. Un lote bloqueado por borrado devuelve accepted:0, para que el cliente lo retire. Errores 400 `invalid_payload`/`json_required` y 413 `body_too_large` se descartan; 429 `rate_limited` lleva Retry-After:60 y 503 `temporarily_unavailable` requieren conservar y reintentar después. No hay secretos de app ni nonce para la app. Estas rutas eliminan los encabezados CORS reflejados que WordPress suele añadir: app nativa y web del mismo origen; no permiten Flutter web desde otro dominio sin un cambio explícito.

`POST https://emerkit.globalemergency.online/wp-json/emerkit/v1/erase`, JSON `{"installation_id":"32 hex"}` devuelve 200 `{"erased":N}`. Borrado idempotente con tombstone de 7 días. Envíos y borrados se serializan con un bloqueo MySQL por instalación: un envío previo termina antes del borrado y un envío posterior queda bloqueado por el tombstone. Si el bloqueo no se puede adquirir en 2 segundos, 503. El cliente debe esperar el envío anterior, borrar y crear un ID nuevo al volver a aceptar.

Se conserva HMAC-SHA256 de instalación con `wp_salt('auth')` y HMAC de sesión ligado a la instalación, nunca IDs de instalación en claro. No hay IP, UA, referrer completo, URL, cookies ni identificadores publicitarios en tablas de analítica. Los logs del servidor web/hosting son independientes y pueden conservar datos de red según su configuración. Una rotación de salts de WordPress rompe la relación de borrado con HMAC históricos: antes de rotarlos, purgar las tablas de analítica o completar un procedimiento de migración de clave. No rotar salts como parte de esta instalación.

## Límites y retención

- 60 peticiones de eventos/minuto por instalación; 10 borrados/minuto por instalación, con cuota separada para que retirar permiso siga funcionando.
- 1200 peticiones/10 minutos por HMAC efímero de REMOTE_ADDR. Sin confiar en X-Forwarded-For. Transients de máximo 10 minutos, sin IP en clave o valor. Ventanas fijas e incrementos aproximados bajo concurrencia; no sustituyen protección del servidor ante abuso. Revisar real-IP de nginx si un proxy concentra todas las peticiones bajo una sola IP.
- Eventos de más de 180 días por occurred_at y clics de más de 180 días se borran en cron diario. Tombstones caducados se borran en el mismo cron. WP-Cron depende del tráfico: configurar el cron real del hosting si el sitio tiene poco tráfico. Ejecutar manualmente: `wp cron event run emerkit_analytics_cleanup`.
- Cifras del panel describen participantes con consentimiento, nunca descargas ni usuarios clínicos únicos. Sesión = HMAC distinto con cualquier evento; aperturas = app_open. La atribución vacía se muestra como unknown; no se inventa orgánico ni retención. Eventos: ventana móvil UTC; clics: últimos N días UTC incluyendo hoy. El consentimiento y los reintentos pueden sesgar las cifras.

## Enlaces a stores

- `/emerkit/descargar/android/` → package fijo `online.globalemergency.emerkit`, UTM codificadas dentro de `referrer` de Google Play.
- `/emerkit/descargar/ios/` → Apple ID fijo `6760960392`; sin pt inventado ni atribución de instalación demostrada.
- Únicos parámetros: utm_source/utm_medium/utm_campaign/utm_content. source, si existe, admite web/youtube/whatsapp/instagram/qr/email. campaign puede estar ausente. Si cualquier parámetro es desconocido, array o inválido, se eliminan todos los parámetros, no se cuenta el clic y la descarga sigue funcionando.
- Respuesta 302, sin caché y con Referrer-Policy:no-referrer. Solo se cuentan GET, excluyendo bots y previews conocidos. HEAD/POST no cuentan. Los bots pueden falsificar User-Agent; son clics aproximados, no humanos verificados.
- Únicamente contador diario agregado por destino y UTM: sin registro de cada clic, sesión ni ID. Un fallo al contar no bloquea la redirección.

## Pruebas reproducibles sin WordPress

Con PHP CLI local:

```sh
php backend/emerkit-analytics/tests/contract-test.php
php backend/emerkit-analytics/tests/wp-test.php
php backend/emerkit-analytics/tests/host-alias-test.php
find backend/emerkit-analytics -name '*.php' -exec php -l {} \;
```

Contrato: allowlist idéntica al registro Dart, fechas y fracciones, claves/clínica rechazadas, tamaños, lotes, versiones, métricas, UTM, destinos fijos, bots y CSV. Adaptador WP: guardas HTTP, cuotas independientes y por instalación, acceso admin y nonce de CSV. No sustituyen probar la activación real y el panel en WordPress.

La prueba de persistencia usa una base **desechable** llamada analytics, tablas test_emerkit_*, y borra únicamente esas tablas de pruebas al comenzar. Nunca apuntarla a producción. Requiere PDO MySQL. Ejemplo Docker sin puertos y red interna:

```sh
docker network create --internal emerkit-analytics-test
docker run --detach --rm --network emerkit-analytics-test --name emerkit-analytics-db -e MARIADB_ALLOW_EMPTY_ROOT_PASSWORD=1 -e MARIADB_DATABASE=analytics mariadb:11.8.6
# Esperar a que MariaDB esté disponible. Sustituir /path/to/EmerKit y la imagen PHP por una con pdo_mysql.
docker run --rm --network emerkit-analytics-test -e DB_HOST=emerkit-analytics-db -v /path/to/EmerKit:/app:ro -w /app apuntate-php-fpm:latest php backend/emerkit-analytics/tests/store-test.php
docker stop emerkit-analytics-db
docker network rm emerkit-analytics-test
```

La imagen PHP del ejemplo ya estaba disponible en el equipo; no es una dependencia de producción. Se verifica dedup, atomicidad/rollback con error real de MariaDB, HMAC, bloqueo entre conexiones, borrado con evento posterior en vuelo, agregación, consultas de informe y limpieza de las tres tablas.

## Reversión

`wp plugin deactivate emerkit-analytics` desactiva colector/panel/redirects y elimina su cron. Las tablas se conservan para evitar pérdida involuntaria. No se incluye uninstall destructivo. Desactivar exige restaurar enlaces directos a stores si los enlaces públicos ya se han cambiado. La nueva app no se publica hasta actualizar las declaraciones de privacidad de ambas stores.


En srv07 se añadió además una tarea real horaria del usuario globalemergency.online (minuto 17), limitada a `do_action("emerkit_analytics_cleanup")`, con flock y sin salida de datos. Conserva las demás tareas y asegura limpieza aunque WP-Cron tenga poco tráfico. Plesk gestiona el certificado independiente de emerkit.globalemergency.online (emitido 24/10/2026, vencimiento inicial 22/01/2027).

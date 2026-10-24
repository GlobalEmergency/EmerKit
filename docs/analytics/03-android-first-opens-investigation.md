# Investigación de primeros accesos Android · 24/10/2026

## Resultado

El −43% mostrado en el resumen no demuestra un fallo de arranque. El resumen termina el 23/10, pero la serie diaria recuperada solo tiene registros hasta el 17/10. No se sustituyen fechas ausentes por cero. Es un indicio de cobertura reciente incompleta; no una confirmación del motivo del retraso ni de que cada fecha sin fila tuviera actividad.

Comparaciones de ventanas consecutivas de 28 días de la misma métrica:

- 26/09–23/10: 55 frente a 96 (−42,7%); ventana reciente sin registros recuperados después del 17/10.
- 20/09–17/10: 76 frente a 84 del 23/08–19/09 (−9,5%).
- 13/09–10/10: 78 frente a 71 (+9,9%).
- 06/09–03/10: 71 frente a 68 (+4,4%).

La tendencia más reciente disponible se enfría, pero el gran salto del titular está afectado por el corte de datos. No dividir primeros accesos entre adquisiciones del mismo periodo para afirmar una tasa de activación: no constituyen una misma cohorte.

## Comprobaciones técnicas

El arranque publicado llama runApp sin esperar red ni permisos. El splash lleva una espera fija de 2,5 s; supone demora hasta herramientas, pero no hay evidencia de que cause la caída. El permiso de ubicación se pide solo desde su herramienta. Que faltara INTERNET en la app anterior es compatible con una app offline y no explica la estadística de primeros accesos de Google Play.

Las consultas de Fallos y ANR de Play Console devolvieron «Datos no disponibles». Esto no significa cero errores. No hay stack de producción que permita atribuir un fallo concreto.

El historial main/release revisado muestra 0.1.17 el 05/04/2026 y 0.1.18 el 24/10/2026. No hay una release del repositorio que coincida con la semana anterior al corte del 17/10. Los recursos/categoría del 24/10 no pueden explicar un descenso anterior. El historial de releases por sí solo no confirma fechas efectivas ni cobertura de todos los binarios instalados de Play.

La nueva medición distinguirá inicio de medición, apertura y llegada inicial a home, con versión y tiempo, sin confundir consentimiento de usuario existente con instalación nueva. No permite reconstruir retrospectivamente fallos de versiones anteriores ni observar a quien rechaza el permiso.

## Próximo contraste

Cuando la serie incluya 18–23/10, repetir exactamente estas ventanas y comprobar si revisa los recuentos. Mantener el corte de fechas visible. Comparar evolución por versión/dispositivo si hay volumen suficiente, con datos de calidad disponibles. No hacer cambios de onboarding por el titular −43% sin esa comprobación.

Evidencia local conservada: serie diaria y cálculos en investigation/02-first-opens-comparisons.json; tablas originales de primeros accesos, fallos y ANR. Informe y panel de adquisición corregidos. Las comprobaciones de build/pruebas de la nueva app se documentan en el PR y no prueban ausencia de fallos en toda la población.

Definición oficial: https://support.google.com/googleplay/android-developer/answer/139628?hl=es

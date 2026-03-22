#!/usr/bin/env python3
"""Fill Google Play Store listing for EmerKit via API."""
import json, os
from google.oauth2 import service_account
from googleapiclient.discovery import build

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.dirname(SCRIPT_DIR)
PACKAGE = "online.globalemergency.emerkit"
SA_KEY = os.path.join(PROJECT_DIR, "android/app/signing/globalemergency-sa.json")

# Check if SA key exists locally, fallback to Downloads
if not os.path.exists(SA_KEY):
    SA_KEY = os.path.expanduser("~/Downloads/globalemergency-0deec5127a94.json")

print(f"Using service account: {SA_KEY}")

credentials = service_account.Credentials.from_service_account_file(
    SA_KEY,
    scopes=["https://www.googleapis.com/auth/androidpublisher"]
)

service = build("androidpublisher", "v3", credentials=credentials)

# Create an edit
print("\n1. Creating edit...")
edit = service.edits().insert(body={}, packageName=PACKAGE).execute()
edit_id = edit["id"]
print(f"   Edit ID: {edit_id}")

# Spanish listing
print("\n2. Creating Spanish (es-ES) listing...")
desc_es = (
    "EmerKit es tu kit de herramientas cl\u00ednicas de emergencia. "
    "Dise\u00f1ada por y para profesionales sanitarios de emergencias "
    "(TES, enfermer\u00eda, medicina), ofrece 24 herramientas cl\u00ednicas "
    "validadas que funcionan completamente offline.\n\n"

    "HERRAMIENTAS INCLUIDAS:\n\n"

    "\u2764\ufe0f Soporte Vital:\n"
    "\u2022 Metr\u00f3nomo RCP con gu\u00eda de compresiones y ventilaciones\n"
    "\u2022 Algoritmo SVB/SVA seg\u00fan ERC 2025\n"
    "\u2022 Mapa de desfibriladores cercanos (DEAMap)\n\n"

    "\ud83e\ude7a Valoraci\u00f3n del paciente:\n"
    "\u2022 Escala de Glasgow (GCS)\n"
    "\u2022 Triage START y JumpSTART\n"
    "\u2022 Tri\u00e1ngulo de Evaluaci\u00f3n Pedi\u00e1trica (TEP)\n"
    "\u2022 Escala Cincinnati para ictus\n"
    "\u2022 Madrid-DIRECT para activaci\u00f3n de c\u00f3digo ictus\n"
    "\u2022 NIHSS (National Institutes of Health Stroke Scale)\n"
    "\u2022 Escala de Rankin modificada\n\n"

    "\ud83d\udcca Signos y valores:\n"
    "\u2022 Constantes vitales por edad\n"
    "\u2022 Calculadora de frecuencia card\u00edaca\n"
    "\u2022 Valores de glucemia y manejo\n"
    "\u2022 Hipotermia e hipertermia: clasificaci\u00f3n y tratamiento\n\n"

    "\ud83d\udca8 Oxigenoterapia:\n"
    "\u2022 Calculadora de autonom\u00eda de O\u2082\n"
    "\u2022 Dispositivos de oxigenoterapia y FiO\u2082\n\n"

    "\ud83e\ude79 T\u00e9cnicas:\n"
    "\u2022 Colocaci\u00f3n de electrodos ECG\n"
    "\u2022 Superficie corporal quemada (Lund-Browder)\n"
    "\u2022 T\u00e9cnicas de vendaje\n"
    "\u2022 Clasificaci\u00f3n de heridas\n"
    "\u2022 Posiciones del paciente\n\n"

    "\ud83d\udee1\ufe0f Protecci\u00f3n:\n"
    "\u2022 Equipos de protecci\u00f3n individual (EPI)\n"
    "\u2022 Mercanc\u00edas peligrosas (ADR/HAZMAT)\n\n"

    "\ud83d\udcde Comunicaci\u00f3n:\n"
    "\u2022 Comunicaci\u00f3n estructurada SBAR/ISBAR\n\n"

    "\u2b50 CARACTER\u00cdSTICAS:\n"
    "\u2022 100% offline: no necesita conexi\u00f3n a internet\n"
    "\u2022 Referencias bibliogr\u00e1ficas en cada herramienta\n"
    "\u2022 Cada herramienta incluye modo consulta r\u00e1pida y modo estudio\n"
    "\u2022 Interfaz sencilla pensada para emergencias reales\n"
    "\u2022 Protocolos actualizados (ERC 2025, AHA, PHTLS)\n"
    "\u2022 Open source: c\u00f3digo disponible en GitHub\n"
    "\u2022 Gratuita y sin publicidad\n\n"

    "Desarrollada por Global Emergency (globalemergency.online).\n\n"
    "AVISO: Esta aplicaci\u00f3n es una herramienta de apoyo y consulta. "
    "No sustituye la formaci\u00f3n sanitaria ni el juicio cl\u00ednico profesional."
)

try:
    service.edits().listings().update(
        packageName=PACKAGE,
        editId=edit_id,
        language="es-ES",
        body={
            "language": "es-ES",
            "title": "EmerKit",
            "shortDescription": "24 herramientas cl\u00ednicas de emergencia validadas. 100% offline. Gratuita.",
            "fullDescription": desc_es,
        }
    ).execute()
    print("   OK")
except Exception as e:
    print(f"   ERROR: {e}")

# English listing
print("\n3. Creating English (en-US) listing...")
desc_en = (
    "EmerKit is your emergency clinical toolkit. "
    "Designed by and for emergency healthcare professionals "
    "(EMTs, nurses, physicians), it offers 24 validated clinical tools "
    "that work completely offline.\n\n"

    "TOOLS INCLUDED:\n\n"

    "\u2764\ufe0f Life Support:\n"
    "\u2022 CPR metronome with compression and ventilation guidance\n"
    "\u2022 BLS/ALS algorithm per ERC 2025\n"
    "\u2022 Nearby AED map (DEAMap)\n\n"

    "\ud83e\ude7a Patient Assessment:\n"
    "\u2022 Glasgow Coma Scale (GCS)\n"
    "\u2022 START and JumpSTART Triage\n"
    "\u2022 Pediatric Assessment Triangle (PAT)\n"
    "\u2022 Cincinnati Stroke Scale\n"
    "\u2022 Madrid-DIRECT for stroke code activation\n"
    "\u2022 NIHSS (National Institutes of Health Stroke Scale)\n"
    "\u2022 Modified Rankin Scale\n\n"

    "\ud83d\udcca Signs & Values:\n"
    "\u2022 Vital signs by age group\n"
    "\u2022 Heart rate calculator\n"
    "\u2022 Blood glucose values and management\n"
    "\u2022 Hypothermia and hyperthermia classification\n\n"

    "\ud83d\udca8 Oxygen Therapy:\n"
    "\u2022 O\u2082 autonomy calculator\n"
    "\u2022 Oxygen delivery devices and FiO\u2082\n\n"

    "\ud83e\ude79 Techniques:\n"
    "\u2022 ECG electrode placement\n"
    "\u2022 Burn surface area (Lund-Browder)\n"
    "\u2022 Bandaging techniques\n"
    "\u2022 Wound classification\n"
    "\u2022 Patient positioning\n\n"

    "\ud83d\udee1\ufe0f Protection:\n"
    "\u2022 Personal Protective Equipment (PPE)\n"
    "\u2022 Dangerous goods (ADR/HAZMAT)\n\n"

    "\ud83d\udcde Communication:\n"
    "\u2022 SBAR/ISBAR structured communication\n\n"

    "\u2b50 FEATURES:\n"
    "\u2022 100% offline: no internet connection required\n"
    "\u2022 Evidence-based references in every tool\n"
    "\u2022 Quick-reference and study modes\n"
    "\u2022 Simple interface designed for real emergencies\n"
    "\u2022 Protocol updates based on latest guidelines (ERC 2025, AHA, PHTLS)\n"
    "\u2022 Open source on GitHub\n"
    "\u2022 Free with no ads\n\n"

    "Developed by Global Emergency (globalemergency.online).\n\n"
    "DISCLAIMER: This app is a support and reference tool. "
    "It does not replace professional medical training or clinical judgment."
)

try:
    service.edits().listings().update(
        packageName=PACKAGE,
        editId=edit_id,
        language="en-US",
        body={
            "language": "en-US",
            "title": "EmerKit",
            "shortDescription": "24 validated emergency clinical tools. 100% offline. Free.",
            "fullDescription": desc_en,
        }
    ).execute()
    print("   OK")
except Exception as e:
    print(f"   ERROR: {e}")

# Contact info
print("\n4. Setting contact details...")
try:
    service.edits().details().update(
        packageName=PACKAGE,
        editId=edit_id,
        body={
            "contactEmail": "info@globalemergency.online",
            "contactWebsite": "https://www.globalemergency.online/",
            "defaultLanguage": "es-ES",
        }
    ).execute()
    print("   OK")
except Exception as e:
    print(f"   ERROR: {e}")

# Commit the edit
print("\n5. Committing edit...")
try:
    service.edits().commit(packageName=PACKAGE, editId=edit_id).execute()
    print("   OK - All changes committed!")
except Exception as e:
    print(f"   ERROR: {e}")

print("\n" + "="*50)
print("Google Play Store listing configured!")
print("="*50)
print("\nPending (require first APK/AAB upload):")
print("  - Screenshots")
print("  - Feature graphic (1024x500)")
print("  - App icon (512x512)")
print("  - Content rating questionnaire")
print("  - Privacy policy URL")
print("  - Target audience and content")
print("  - App category selection")

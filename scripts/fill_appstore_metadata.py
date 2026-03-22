#!/usr/bin/env python3
"""Fill App Store Connect metadata for EmerKit via API."""
import jwt, time, json, urllib.request, ssl, os

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.dirname(SCRIPT_DIR)

with open(os.path.join(PROJECT_DIR, "android/app/signing/AuthKey_Z68N6TKGK9.p8"), "r") as f:
    private_key = f.read()

now = int(time.time())
token = jwt.encode(
    {"iss": "90591e44-9746-48f0-b603-f19bf8d517aa", "iat": now, "exp": now + 1200, "aud": "appstoreconnect-v1"},
    private_key, algorithm="ES256",
    headers={"alg": "ES256", "kid": "Z68N6TKGK9", "typ": "JWT"}
)
ctx = ssl.create_default_context()

def api_call(method, url, data=None):
    body = json.dumps(data).encode() if data else None
    req = urllib.request.Request(url, data=body, method=method, headers={
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    })
    try:
        resp = urllib.request.urlopen(req, context=ctx)
        return json.loads(resp.read())
    except urllib.error.HTTPError as e:
        err = e.read().decode()
        print(f"  ERROR {e.code}: {err[:400]}")
        return None

APP_ID = "6760960392"
APP_INFO_ID = "70eb06d0-bd89-44b5-957b-b721ebe60a3c"
VERSION_ID = "e4cc75ea-926d-4771-8dc0-6c487f0e1663"
LOCALE_ID = "f5351159-2de4-4d50-b7bb-079dfd6ef593"

# 1. App info localization (es-ES)
print("1. Updating app info localization (es-ES)...")
result = api_call("PATCH", f"https://api.appstoreconnect.apple.com/v1/appInfoLocalizations/{LOCALE_ID}", {
    "data": {
        "type": "appInfoLocalizations",
        "id": LOCALE_ID,
        "attributes": {
            "name": "EmerKit",
            "subtitle": "Herramientas de emergencia",
            "privacyPolicyUrl": "https://www.globalemergency.online/privacy"
        }
    }
})
if result: print("  OK")

# 2. Set categories (Medical + Education)
print("\n2. Setting categories...")
result = api_call("PATCH", f"https://api.appstoreconnect.apple.com/v1/appInfos/{APP_INFO_ID}", {
    "data": {
        "type": "appInfos",
        "id": APP_INFO_ID,
        "relationships": {
            "primaryCategory": {
                "data": {"type": "appCategories", "id": "MEDICAL"}
            },
            "secondaryCategory": {
                "data": {"type": "appCategories", "id": "EDUCATION"}
            }
        }
    }
})
if result: print("  OK - Primary: Medical, Secondary: Education")

# 3. Get version localization ID
print("\n3. Getting version localization...")
ver_locs = api_call("GET", f"https://api.appstoreconnect.apple.com/v1/appStoreVersions/{VERSION_ID}/appStoreVersionLocalizations")
ver_loc_id = None
if ver_locs:
    for vl in ver_locs["data"]:
        if vl["attributes"]["locale"] == "es-ES":
            ver_loc_id = vl["id"]
            print(f"  Found es-ES: {ver_loc_id}")
            break

# 4. Fill Spanish description
if ver_loc_id:
    print("\n4. Filling Spanish description...")
    description_es = (
        "EmerKit es tu kit de herramientas clinicas de emergencia. "
        "Disenada por y para profesionales sanitarios de emergencias "
        "(TES, enfermeria, medicina), ofrece 24 herramientas clinicas "
        "validadas que funcionan completamente offline.\n\n"
        "HERRAMIENTAS INCLUIDAS:\n\n"
        "Soporte Vital:\n"
        "- Metronomo RCP con guia de compresiones y ventilaciones\n"
        "- Algoritmo SVB/SVA segun ERC 2025\n"
        "- Mapa de desfibriladores cercanos (DEAMap)\n\n"
        "Valoracion del paciente:\n"
        "- Escala de Glasgow (GCS)\n"
        "- Triage START y JumpSTART\n"
        "- Triangulo de Evaluacion Pediatrica (TEP)\n"
        "- Escala Cincinnati para ictus\n"
        "- Madrid-DIRECT para activacion de codigo ictus\n"
        "- NIHSS (National Institutes of Health Stroke Scale)\n"
        "- Escala de Rankin modificada\n\n"
        "Signos y valores:\n"
        "- Constantes vitales por edad\n"
        "- Calculadora de frecuencia cardiaca\n"
        "- Valores de glucemia y manejo\n"
        "- Hipotermia e hipertermia: clasificacion y tratamiento\n\n"
        "Oxigenoterapia:\n"
        "- Calculadora de autonomia de O2\n"
        "- Dispositivos de oxigenoterapia y FiO2\n\n"
        "Tecnicas:\n"
        "- Colocacion de electrodos ECG\n"
        "- Superficie corporal quemada (Lund-Browder)\n"
        "- Tecnicas de vendaje\n"
        "- Clasificacion de heridas\n"
        "- Posiciones del paciente\n\n"
        "Proteccion:\n"
        "- Equipos de proteccion individual (EPI)\n"
        "- Mercancias peligrosas (ADR/HAZMAT)\n\n"
        "Comunicacion:\n"
        "- Comunicacion estructurada SBAR/ISBAR\n\n"
        "CARACTERISTICAS:\n"
        "- 100% offline: no necesita conexion a internet\n"
        "- Referencias bibliograficas en cada herramienta\n"
        "- Modo consulta rapida y modo estudio\n"
        "- Interfaz sencilla pensada para emergencias reales\n"
        "- Protocolos actualizados (ERC 2025, AHA, PHTLS)\n"
        "- Open source en GitHub\n"
        "- Gratuita y sin publicidad\n\n"
        "Desarrollada por Global Emergency (globalemergency.online).\n\n"
        "AVISO: Esta aplicacion es una herramienta de apoyo y consulta. "
        "No sustituye la formacion sanitaria ni el juicio clinico profesional."
    )
    keywords_es = "emergencias,sanitario,TES,enfermeria,medicina,RCP,glasgow,triage,ictus,ECG,oxigeno,constantes,vendajes,heridas,EPI,quemados,desfibrilador,NIHSS,pediatria,soporte vital"

    result = api_call("PATCH", f"https://api.appstoreconnect.apple.com/v1/appStoreVersionLocalizations/{ver_loc_id}", {
        "data": {
            "type": "appStoreVersionLocalizations",
            "id": ver_loc_id,
            "attributes": {
                "description": description_es,
                "keywords": keywords_es,
                "whatsNew": "Primera version de EmerKit con 24 herramientas clinicas para profesionales de emergencias.",
                "supportUrl": "https://www.globalemergency.online/",
                "marketingUrl": "https://www.globalemergency.online/",
                "promotionalText": "24 herramientas clinicas de emergencia validadas. 100% offline. Gratuita."
            }
        }
    })
    if result: print("  OK")

# 5. Add English localization
print("\n5. Adding English (en-US) version localization...")
description_en = (
    "EmerKit is your emergency clinical toolkit. "
    "Designed by and for emergency healthcare professionals "
    "(EMTs, nurses, physicians), it offers 24 validated clinical tools "
    "that work completely offline.\n\n"
    "TOOLS INCLUDED:\n\n"
    "Life Support:\n"
    "- CPR metronome with compression and ventilation guidance\n"
    "- BLS/ALS algorithm per ERC 2025\n"
    "- Nearby AED map (DEAMap)\n\n"
    "Patient Assessment:\n"
    "- Glasgow Coma Scale (GCS)\n"
    "- START and JumpSTART Triage\n"
    "- Pediatric Assessment Triangle (PAT)\n"
    "- Cincinnati Stroke Scale\n"
    "- Madrid-DIRECT for stroke code activation\n"
    "- NIHSS (National Institutes of Health Stroke Scale)\n"
    "- Modified Rankin Scale\n\n"
    "Signs & Values:\n"
    "- Vital signs by age group\n"
    "- Heart rate calculator\n"
    "- Blood glucose values and management\n"
    "- Hypothermia and hyperthermia classification\n\n"
    "Oxygen Therapy:\n"
    "- O2 autonomy calculator\n"
    "- Oxygen delivery devices and FiO2\n\n"
    "Techniques:\n"
    "- ECG electrode placement\n"
    "- Burn surface area (Lund-Browder)\n"
    "- Bandaging techniques\n"
    "- Wound classification\n"
    "- Patient positioning\n\n"
    "Protection:\n"
    "- Personal Protective Equipment (PPE)\n"
    "- Dangerous goods (ADR/HAZMAT)\n\n"
    "Communication:\n"
    "- SBAR/ISBAR structured communication\n\n"
    "FEATURES:\n"
    "- 100% offline: no internet connection required\n"
    "- Evidence-based references in every tool\n"
    "- Quick-reference and study modes\n"
    "- Simple interface designed for real emergencies\n"
    "- Protocol updates based on latest guidelines (ERC 2025, AHA, PHTLS)\n"
    "- Open source on GitHub\n"
    "- Free with no ads\n\n"
    "Developed by Global Emergency (globalemergency.online).\n\n"
    "DISCLAIMER: This app is a support and reference tool. "
    "It does not replace professional medical training or clinical judgment."
)

en_result = api_call("POST", "https://api.appstoreconnect.apple.com/v1/appStoreVersionLocalizations", {
    "data": {
        "type": "appStoreVersionLocalizations",
        "attributes": {
            "locale": "en-US",
            "description": description_en,
            "keywords": "emergency,EMT,paramedic,nursing,medicine,CPR,glasgow,triage,stroke,ECG,oxygen,vitals,bandage,wounds,PPE,burns,AED,NIHSS,pediatric,life support",
            "whatsNew": "First release of EmerKit with 24 clinical tools for emergency professionals.",
            "supportUrl": "https://www.globalemergency.online/",
            "marketingUrl": "https://www.globalemergency.online/",
            "promotionalText": "24 validated emergency clinical tools. 100% offline. Free."
        },
        "relationships": {
            "appStoreVersion": {
                "data": {"type": "appStoreVersions", "id": VERSION_ID}
            }
        }
    }
})
if en_result: print("  OK")

# 6. English app info localization
print("\n6. Adding English app info localization...")
en_info = api_call("POST", "https://api.appstoreconnect.apple.com/v1/appInfoLocalizations", {
    "data": {
        "type": "appInfoLocalizations",
        "attributes": {
            "locale": "en-US",
            "name": "EmerKit",
            "subtitle": "Emergency clinical tools",
            "privacyPolicyUrl": "https://www.globalemergency.online/privacy"
        },
        "relationships": {
            "appInfo": {
                "data": {"type": "appInfos", "id": APP_INFO_ID}
            }
        }
    }
})
if en_info: print("  OK")

print("\n" + "="*50)
print("DONE! All metadata configured.")
print("="*50)
print("\nPending (require manual upload or first build):")
print("  - Screenshots (need actual app screenshots)")
print("  - App icon (uploaded with the build)")
print("  - Privacy policy page at globalemergency.online/privacy")

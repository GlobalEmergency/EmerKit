"""
Generate App Store & Google Play screenshots for EmerKit Custom Product Pages.
Style: Gradient backgrounds + bold white text + subtitles + rounded phone mockup.

Output structure:
  screenshots/custom_pages/<page_name>/<lang>/
    apple/iPhones 6.9/       (1320x2868)
    apple/iPad 13/            (2064x2752)
    android/Phones 16-9/      (1080x1920)
    android/Tablets 16-9/     (1920x1080 landscape -> we do 1200x1920 portrait)
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os

BASE = os.path.dirname(os.path.abspath(__file__))
RAW = BASE
OUTPUT = os.path.join(BASE, "custom_pages")

FONT_BOLD = "arialbd.ttf"
FONT_REGULAR = "arial.ttf"

# Device specs: (width, height, phone_w_ratio, phone_h_ratio, phone_radius, is_landscape)
DEVICES = {
    "apple/iPhones 6.9":      (1320, 2868, 0.67, 0.66, 48, False),
    "apple/iPad 13":           (2064, 2752, 0.55, 0.62, 40, False),
    "android/Phones 16-9":     (1080, 1920, 0.70, 0.65, 36, False),
    "android/Tablets 16-9":    (1200, 1920, 0.55, 0.62, 36, False),
}


def get_font(size, bold=True):
    return ImageFont.truetype(FONT_BOLD if bold else FONT_REGULAR, size)


def draw_gradient(img, w, h, color_top, color_bottom):
    draw = ImageDraw.Draw(img)
    for y in range(h):
        t = y / h
        t = t * t * (3 - 2 * t)
        r = int(color_top[0] + (color_bottom[0] - color_top[0]) * t)
        g = int(color_top[1] + (color_bottom[1] - color_top[1]) * t)
        b = int(color_top[2] + (color_bottom[2] - color_top[2]) * t)
        draw.line([(0, y), (w, y)], fill=(r, g, b))


def draw_bubbles(img, w, h, color_top):
    overlay = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    r0, g0, b0 = color_top
    c = (min(255, r0 + 40), min(255, g0 + 40), min(255, b0 + 40), 22)
    spots = [
        (0.08, 0.07, 0.12), (0.88, 0.12, 0.08), (0.15, 0.85, 0.07),
        (0.92, 0.05, 0.05), (0.04, 0.18, 0.04), (0.75, 0.25, 0.06),
    ]
    for px, py, pr in spots:
        cx, cy, rad = int(px * w), int(py * h), int(pr * w)
        draw.ellipse([cx - rad, cy - rad, cx + rad, cy + rad], fill=c)
    img.paste(Image.alpha_composite(img.convert("RGBA"), overlay).convert("RGB"), (0, 0))


def wrap_text(draw, text, font, max_width):
    words = text.split()
    lines, cur = [], ""
    for word in words:
        test = f"{cur} {word}".strip()
        if draw.textbbox((0, 0), test, font=font)[2] <= max_width:
            cur = test
        else:
            if cur:
                lines.append(cur)
            cur = word
    if cur:
        lines.append(cur)
    return lines


def fit_text(draw, text, max_w, max_h, start_size=130):
    for size in range(start_size, 36, -4):
        font = get_font(size)
        lines = wrap_text(draw, text, font, max_w)
        asc, desc = font.getmetrics()
        lh = asc + desc + 14
        if len(lines) * lh <= max_h:
            return font, lines, lh
    font = get_font(40)
    return font, wrap_text(draw, text, font, max_w), 54


def rounded_mask(size, radius):
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [(0, 0), (size[0] - 1, size[1] - 1)], radius, fill=255
    )
    return mask


def create_screenshot(grad_top, grad_bot, title, subtitle, raw_path, out_path, device_key):
    W, H, pw_ratio, ph_ratio, p_radius, is_land = DEVICES[device_key]
    PHONE_W = int(W * pw_ratio)
    PHONE_H = int(H * ph_ratio)
    PHONE_X = (W - PHONE_W) // 2
    PHONE_Y = H - PHONE_H - int(H * 0.035)
    TEXT_Y = int(H * 0.02)
    TEXT_H = PHONE_Y - TEXT_Y - int(H * 0.015)

    # Scale font sizes to device
    scale = W / 1320.0
    title_start = int(130 * scale)
    sub_size = int(48 * scale)

    img = Image.new("RGB", (W, H), grad_top)
    draw_gradient(img, W, H, grad_top, grad_bot)
    draw_bubbles(img, W, H, grad_top)
    draw = ImageDraw.Draw(img)

    # Title
    max_tw = W - int(140 * scale)
    title_max = int(TEXT_H * 0.65) if subtitle else int(TEXT_H * 0.85)
    font, lines, lh = fit_text(draw, title, max_tw, title_max, title_start)
    total_th = len(lines) * lh

    if subtitle:
        sf = get_font(sub_size, bold=False)
        s_asc, s_desc = sf.getmetrics()
        sh = s_asc + s_desc
        combined = total_th + int(16 * scale) + sh
        y = TEXT_Y + (TEXT_H - combined) // 2
    else:
        y = TEXT_Y + (TEXT_H - total_th) // 2

    for line in lines:
        bbox = draw.textbbox((0, 0), line, font=font)
        tw = bbox[2] - bbox[0]
        x = (W - tw) // 2
        draw.text((x + 2, y + 3), line, fill=(0, 0, 0, 50), font=font)
        draw.text((x, y), line, fill="white", font=font)
        y += lh

    if subtitle:
        y += int(8 * scale)
        sf = get_font(sub_size, bold=False)
        bbox = draw.textbbox((0, 0), subtitle, font=sf)
        tw = bbox[2] - bbox[0]
        x = (W - tw) // 2
        draw.text((x, y), subtitle, fill=(255, 255, 255, 220), font=sf)

    # Phone mockup
    if os.path.exists(raw_path):
        phone_img = Image.open(raw_path).convert("RGBA")
        # Cover fit: scale preserving aspect ratio, then crop center
        src_w, src_h = phone_img.size
        src_ratio = src_w / src_h
        dst_ratio = PHONE_W / PHONE_H
        if src_ratio > dst_ratio:
            # Source is wider: fit height, crop width
            new_h = PHONE_H
            new_w = int(PHONE_H * src_ratio)
        else:
            # Source is taller: fit width, crop height
            new_w = PHONE_W
            new_h = int(PHONE_W / src_ratio)
        phone_img = phone_img.resize((new_w, new_h), Image.LANCZOS)
        # Center crop
        left = (new_w - PHONE_W) // 2
        top = 0  # crop from top to keep app header visible
        phone_img = phone_img.crop((left, top, left + PHONE_W, top + PHONE_H))
        mask = rounded_mask((PHONE_W, PHONE_H), p_radius)

        phone_canvas = Image.new("RGBA", (PHONE_W, PHONE_H), (0, 0, 0, 0))
        phone_canvas.paste(phone_img, (0, 0), mask)

        # Shadow
        sp = int(25 * scale)
        shadow = Image.new("RGBA", (PHONE_W + sp * 2, PHONE_H + sp * 2), (0, 0, 0, 0))
        ImageDraw.Draw(shadow).rounded_rectangle(
            [(sp // 2, sp // 2), (PHONE_W + sp * 3 // 2, PHONE_H + sp * 3 // 2)],
            p_radius + 6, fill=(0, 0, 0, 60)
        )
        shadow = shadow.filter(ImageFilter.GaussianBlur(int(12 * scale)))

        # Border glow
        border = Image.new("RGBA", (PHONE_W + 6, PHONE_H + 6), (0, 0, 0, 0))
        ImageDraw.Draw(border).rounded_rectangle(
            [(0, 0), (PHONE_W + 5, PHONE_H + 5)], p_radius + 3, fill=(255, 255, 255, 35)
        )

        img_rgba = img.convert("RGBA")
        img_rgba.paste(shadow, (PHONE_X - sp, PHONE_Y - sp // 2), shadow)
        img_rgba.paste(border, (PHONE_X - 3, PHONE_Y - 3), border)
        img_rgba.paste(phone_canvas, (PHONE_X, PHONE_Y), phone_canvas)
        img = img_rgba.convert("RGB")

    img.save(out_path, "PNG", optimize=True)


# ============================================================
# Colors & configurations
# ============================================================
C_ORANGE = ((240, 150, 30), (200, 90, 10))
C_BLUE = ((40, 140, 255), (20, 80, 180))
C_YELLOW = ((245, 195, 30), (210, 150, 10))
C_RED = ((230, 65, 55), (170, 30, 30))
C_GREEN = ((60, 190, 70), (30, 130, 40))
C_TEAL = ((0, 165, 145), (0, 100, 100))
C_PURPLE = ((130, 80, 200), (80, 40, 140))
C_DARK = ((30, 55, 110), (15, 25, 60))
C_CORAL = ((240, 110, 80), (190, 60, 40))
C_INDIGO = ((60, 60, 160), (30, 30, 100))

S = {
    "home": os.path.join(RAW, "01_home.png"),
    "scroll": os.path.join(RAW, "02_home_scroll.png"),
    "rcp": os.path.join(RAW, "03_rcp.png"),
    "glasgow": os.path.join(RAW, "04_glasgow.png"),
    "triage": os.path.join(RAW, "05_triage.png"),
    "ictus": os.path.join(RAW, "06_ictus.png"),
    "vitals": os.path.join(RAW, "07_vitals.png"),
    "lund": os.path.join(RAW, "08_lund_browder.png"),
    "ecg": os.path.join(RAW, "09_ecg.png"),
    "check": os.path.join(RAW, "03_check.png"),
}

# (colors, title_es, subtitle_es, title_en, subtitle_en, raw_key)
PAGES = {
    "default": [
        (C_ORANGE, "Kit de Emergencias", "Todo lo que necesitas, sin conexion", "Emergency Kit", "Everything you need, offline", "home"),
        (C_BLUE, "24 Herramientas", "Clinicas y validadas", "24 Tools", "Clinical & validated", "scroll"),
        (C_YELLOW, "Modo Estudio", "Aprende mientras practicas", "Study Mode", "Learn while you practice", "glasgow"),
        (C_RED, "RCP y SVB/SVA", "Metronomo con guia en tiempo real", "CPR & BLS/ALS", "Metronome with real-time guidance", "rcp"),
        (C_GREEN, "Escalas Clinicas", "Glasgow, NIHSS, Rankin y mas", "Clinical Scales", "Glasgow, NIHSS, Rankin & more", "vitals"),
    ],
    "TES": [
        (C_RED, "Metronomo RCP", "Ratio 30:2 con guia de ciclos", "CPR Metronome", "30:2 ratio with cycle guidance", "rcp"),
        (C_ORANGE, "Triage START", "Clasifica pacientes en segundos", "START Triage", "Classify patients in seconds", "triage"),
        (C_GREEN, "Constantes Vitales", "Rangos por edad pediatrica y adulta", "Vital Signs", "Ranges by pediatric & adult age", "vitals"),
        (C_BLUE, "24 Herramientas", "Tu companero en cada guardia", "24 Tools", "Your partner on every shift", "scroll"),
        (C_DARK, "100% Offline", "Funciona sin cobertura", "100% Offline", "Works without coverage", "home"),
    ],
    "Paramedicos": [
        (C_RED, "Soporte Vital", "SVB y SVA en tu bolsillo", "Life Support", "BLS & ALS in your pocket", "rcp"),
        (C_TEAL, "Glasgow GCS", "Valoracion neurologica rapida", "Glasgow GCS", "Quick neurological assessment", "glasgow"),
        (C_ORANGE, "Triage START", "Decisiones rapidas, resultados claros", "START Triage", "Quick decisions, clear results", "triage"),
        (C_GREEN, "Constantes Vitales", "Rangos normales siempre a mano", "Vital Signs", "Normal ranges always at hand", "vitals"),
        (C_CORAL, "Quemados", "Lund-Browder por edad", "Burns", "Lund-Browder by age", "lund"),
    ],
    "Enfermeria": [
        (C_TEAL, "Glasgow GCS", "Ocular, Verbal y Motor", "Glasgow GCS", "Eye, Verbal & Motor", "glasgow"),
        (C_BLUE, "Escala Cincinnati", "Deteccion precoz de ictus", "Cincinnati Scale", "Early stroke detection", "ictus"),
        (C_GREEN, "Constantes Vitales", "Adulto, pediatria y neonatal", "Vital Signs", "Adult, pediatric & neonatal", "vitals"),
        (C_PURPLE, "Electrodos ECG", "Europeo y Americano (AHA)", "ECG Electrodes", "European & American (AHA)", "ecg"),
        (C_YELLOW, "Modo Estudio", "Referencias y evidencia clinica", "Study Mode", "References & clinical evidence", "glasgow"),
    ],
    "Medicos": [
        (C_DARK, "24 Herramientas Clinicas", "Validadas y basadas en evidencia", "24 Clinical Tools", "Validated & evidence-based", "scroll"),
        (C_YELLOW, "Modo Estudio", "Consulta referencias en cada escala", "Study Mode", "Check references on every scale", "glasgow"),
        (C_INDIGO, "Escalas Validadas", "Glasgow, NIHSS, Rankin, RACE", "Validated Scales", "Glasgow, NIHSS, Rankin, RACE", "glasgow"),
        (C_BLUE, "Deteccion de Ictus", "Cincinnati y Madrid-DIRECT", "Stroke Detection", "Cincinnati & Madrid-DIRECT", "ictus"),
        (C_GREEN, "100% Offline y Gratuita", "Sin anuncios, sin registro", "100% Offline & Free", "No ads, no sign-up", "home"),
    ],
    "RCP y Soporte Vital": [
        (C_RED, "Metronomo RCP", "110 BPM con cuenta de ciclos", "CPR Metronome", "110 BPM with cycle counter", "rcp"),
        (C_ORANGE, "Ratio 30:2", "Compresiones y ventilaciones", "30:2 Ratio", "Compressions & ventilations", "rcp"),
        (C_BLUE, "Algoritmo SVB", "Paso a paso en emergencias", "BLS Algorithm", "Step by step in emergencies", "scroll"),
        (C_GREEN, "Constantes Vitales", "Monitoriza al paciente", "Vital Signs", "Monitor your patient", "vitals"),
        (C_DARK, "Funciona Offline", "Sin depender de cobertura", "Works Offline", "No coverage needed", "home"),
    ],
    "Escalas Clinicas": [
        (C_TEAL, "Glasgow GCS", "La escala mas utilizada", "Glasgow GCS", "The most widely used scale", "glasgow"),
        (C_BLUE, "Cincinnati / Ictus", "Asimetria, Fuerza y Habla", "Cincinnati / Stroke", "Asymmetry, Strength & Speech", "ictus"),
        (C_GREEN, "Constantes Vitales", "Rangos normales por edad", "Vital Signs", "Normal ranges by age", "vitals"),
        (C_PURPLE, "ECG Electrodos", "Colocacion paso a paso", "ECG Electrodes", "Step-by-step placement", "ecg"),
        (C_YELLOW, "Modo Estudio", "Aprende con cada herramienta", "Study Mode", "Learn with every tool", "glasgow"),
    ],
    "Triage y Emergencias": [
        (C_ORANGE, "Triage START", "Clasifica en 60 segundos", "START Triage", "Classify in 60 seconds", "triage"),
        (C_CORAL, "Quemados", "Lund-Browder por grupo de edad", "Burns Assessment", "Lund-Browder by age group", "lund"),
        (C_GREEN, "Constantes Vitales", "Valores criticos destacados", "Vital Signs", "Critical values highlighted", "vitals"),
        (C_TEAL, "Glasgow GCS", "Valoracion del nivel de conciencia", "Glasgow GCS", "Level of consciousness assessment", "glasgow"),
        (C_BLUE, "24 Herramientas", "Todo en una sola app", "24 Tools", "All in one app", "scroll"),
    ],
}


def generate_all():
    total = 0
    for page_name, screenshots in PAGES.items():
        for lang in ["es-ES", "en-US"]:
            for device_key in DEVICES:
                page_dir = os.path.join(OUTPUT, page_name, lang, device_key)
                os.makedirs(page_dir, exist_ok=True)

                for i, (colors, t_es, sub_es, t_en, sub_en, raw_key) in enumerate(screenshots):
                    title = t_es if lang == "es-ES" else t_en
                    subtitle = sub_es if lang == "es-ES" else sub_en
                    out_path = os.path.join(page_dir, f"{i+1:02d}.png")
                    raw_path = S.get(raw_key, "")

                    create_screenshot(
                        colors[0], colors[1], title, subtitle,
                        raw_path, out_path, device_key
                    )
                    total += 1

            print(f"  {page_name}/{lang}: {len(screenshots)} x {len(DEVICES)} devices")

    print(f"\nTotal: {total} screenshots generated in {OUTPUT}")


if __name__ == "__main__":
    generate_all()

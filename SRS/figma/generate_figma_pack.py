#!/usr/bin/env python3
"""
Generate a Figma import pack (SVG wireframes + design tokens) for FitCoach.

Outputs:
  - FitCoach_Figma_Mini_Pack.zip

Usage (defaults approximate a dark gym theme):
  python generate_figma_pack.py
  python generate_figma_pack.py --primary "#0EA5E9" --bg "#0B1220" --surface "#121A2A" --text "#E5E7EB"

You can then unzip and drag SVGs into Figma, and import design-tokens.json with Tokens Studio.
"""

import os, io, zipfile, json, argparse, datetime

def save_svg(path, width, height, elements):
    svg_header = f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">'
    svg_footer = "</svg>"
    content = "\n".join([svg_header] + elements + [svg_footer])
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)

def mobile_frame(title, sections=None, theme=None):
    w, h = 360, 800
    t = theme or {}
    bg = t.get("bg", "#0B1220")
    surface = t.get("surface", "#121A2A")
    primary = t.get("primary", "#0EA5E9")
    text = t.get("text", "#E5E7EB")
    muted = t.get("muted", "#94A3B8")

    elems = []
    elems.append(f'<rect x="0" y="0" width="{w}" height="{h}" fill="{bg}"/>' )
    # header
    elems.append(f'<rect x="0" y="0" width="{w}" height="56" fill="{surface}" />' )
    elems.append(f'<text x="16" y="36" fill="{text}" font-size="18" font-family="Inter, Arial" font-weight="600">{title}</text>')
    # demo badge
    elems.append(f'<rect x="280" y="12" rx="10" ry="10" width="68" height="24" fill="{bg}" stroke="{primary}" />' )
    elems.append(f'<text x="294" y="28" fill="{primary}" font-size="12" font-family="Inter">Demo</text>')
    # content
    y = 72
    if not sections:
        sections = ["Primary action", "Secondary action", "List / Cards", "Footer actions"]
    for s in sections[:6]:
        elems.append(f'<rect x="16" y="{y}" rx="12" ry="12" width="328" height="64" fill="{surface}" stroke="#1F2A40"/>' )
        elems.append(f'<text x="28" y="{y+38}" fill="{muted}" font-size="14" font-family="Inter">{s}</text>')
        y += 76
        if y > h - 80:
            break
    # bottom nav
    elems.append(f'<rect x="0" y="744" width="{w}" height="56" fill="{surface}"/>' )
    for i, label in enumerate(["Home","Workout","Coach","Nutrition","Account"]):
        x = 18 + i*70
        elems.append(f'<text x="{x}" y="778" fill="{muted}" font-size="12" font-family="Inter">{label}</text>')
    return elems, w, h

def web_frame(title, sections=None, theme=None):
    w, h = 1440, 1024
    t = theme or {}
    bg = t.get("bg", "#0B1220")
    surface = t.get("surface", "#121A2A")
    panel = t.get("panel", "#0F172A")
    text = t.get("text", "#E5E7EB")
    muted = t.get("muted", "#94A3B8")

    elems = []
    elems.append(f'<rect x="0" y="0" width="{w}" height="{h}" fill="{bg}"/>' )
    # sidebar
    elems.append(f'<rect x="0" y="0" width="256" height="{h}" fill="{panel}"/>' )
    elems.append(f'<text x="24" y="48" fill="{text}" font-size="18" font-family="Inter" font-weight="600">Admin</text>')
    # header
    elems.append(f'<rect x="256" y="0" width="{w-256}" height="64" fill="{surface}"/>' )
    elems.append(f'<text x="280" y="40" fill="{text}" font-size="18" font-family="Inter" font-weight="600">{title}</text>')
    # content grid
    y = 88
    x = 280
    if not sections:
        sections = ["Primary panel","Secondary panel","Table / List","Details / Inspector","Actions"]
    for i, s in enumerate(sections[:6]):
        elems.append(f'<rect x="{x}" y="{y}" rx="12" ry="12" width="520" height="200" fill="{surface}" stroke="#1F2A40"/>' )
        elems.append(f'<text x="{x+16}" y="{y+36}" fill="{muted}" font-size="14" font-family="Inter">{s}</text>')
        if (i % 2) == 1:
            y += 216
            x = 280
        else:
            x = 824
    return elems, w, h

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--primary", default="#0EA5E9")
    parser.add_argument("--secondary", default="#22D3EE")
    parser.add_argument("--accent", default="#22C55E")
    parser.add_argument("--bg", default="#0B1220")
    parser.add_argument("--surface", default="#121A2A")
    parser.add_argument("--panel", default="#0F172A")
    parser.add_argument("--text", default="#E5E7EB")
    parser.add_argument("--muted", default="#94A3B8")
    args = parser.parse_args()

    theme = {
        "primary": args.primary,
        "secondary": args.secondary,
        "accent": args.accent,
        "bg": args.bg,
        "surface": args.surface,
        "panel": args.panel,
        "text": args.text,
        "muted": args.muted,
    }

    # Minimal but representative sets to keep the pack light
    user_screens = [
        "Splash","Login","Home","WorkoutPlan","NutritionPlan","CoachHub","Subscription","Profile"
    ]
    coach_screens = [
        "CoachLogin","Dashboard","SlotsCalendar","BookingRequests","MyUsers"
    ]
    admin_pages = [
        "AdminLogin","Dashboard","Users","Products","Orders","PlansList","Analytics","Settings"
    ]

    # Create everything in-memory and zip it
    buf = io.BytesIO()
    with zipfile.ZipFile(buf, "w", zipfile.ZIP_DEFLATED) as z:
        # README
        readme = f"""FitCoach – Figma Import Mini Pack
Generated: {datetime.datetime.utcnow().isoformat()}Z

Folders:
- user/*.svg    (mobile frames for user app, 360x800)
- coach/*.svg   (mobile frames for coach app, 360x800)
- admin/*.svg   (web frames for admin app, 1440x1024)
- design-tokens.json (Figma Tokens / Tokens Studio JSON)

How to import into Figma:
1) Unzip this archive.
2) Drag & drop the SVGs into your Figma canvas (they import as frames).
3) Install "Tokens Studio for Figma" plugin.
4) Import design-tokens.json to create color/text/spacing tokens.
5) Select frames and apply styles to backgrounds and text.

To match your reference theme:
- Replace the hex codes in design-tokens.json with the exact values from your Figma Variables or Styles.
- Or re-run this script with --primary/--bg/--surface/--text etc. to regenerate with your palette.
"""
        z.writestr("FitCoach_Figma_Mini_Pack/README.txt", readme)

        # Tokens
        tokens = {
            "version": "1.0",
            "core": {
                "color": {
                    "primary": {"value": theme["primary"]},
                    "secondary": {"value": theme["secondary"]},
                    "accent": {"value": theme["accent"]},
                    "bg": {"value": theme["bg"]},
                    "surface": {"value": theme["surface"]},
                    "panel": {"value": theme["panel"]},
                    "text": {"value": theme["text"]},
                    "muted": {"value": theme["muted"]},
                },
                "radius": {"sm":{"value":"8"},"md":{"value":"12"},"lg":{"value":"16"}},
                "spacing": {"xs":{"value":"4"},"sm":{"value":"8"},"md":{"value":"12"},"lg":{"value":"16"},"xl":{"value":"24"}},
                "font": {
                    "family":{"value":"Inter"},
                    "size":{"sm":{"value":"12"},"md":{"value":"14"},"lg":{"value":"18"},"xl":{"value":"24"}},
                    "weight":{"regular":{"value":"400"},"medium":{"value":"500"},"semibold":{"value":"600"}}
                }
            }
        }
        z.writestr("FitCoach_Figma_Mini_Pack/design-tokens.json", json.dumps(tokens, indent=2))

        # Helper to add SVG to zip
        def write_svg_to_zip(root, name, title, sections, frame_fn):
            elems, w, h = frame_fn(title, sections, theme=theme)
            svg = '\n'.join([f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">'] + elems + ["</svg>"])
            z.writestr(f"FitCoach_Figma_Mini_Pack/{root}/{name}.svg", svg)

        # User
        for name in user_screens:
            title = name.replace("_"," ")
            if "Login" in name:
                sections = ["Email", "Password", "Login", "OAuth options"]
            elif name == "Home":
                sections = ["Stats: Calories", "Stats: Workouts", "Stats: Nutrition", "Shortcuts"]
            elif name == "WorkoutPlan":
                sections = ["Exercise list", "Today card", "Start workout", "Tips"]
            elif name == "NutritionPlan":
                sections = ["Daily targets", "Macros donut", "Meals", "Supplements"]
            elif name == "CoachHub":
                sections = ["Coach card", "Chat", "Booking", "Video call"]
            elif name == "Subscription":
                sections = ["Current plan", "Compare table", "Upgrade CTA"]
            elif name == "Profile":
                sections = ["Profile summary", "Body metrics", "Security", "Orders"]
            else:
                sections = None
            write_svg_to_zip("user", name, title, sections, mobile_frame)

        # Coach
        for name in coach_screens:
            title = name.replace("_"," ")
            if name == "Dashboard":
                sections = ["KPIs", "Trends", "Tasks", "Shortcuts"]
            elif name == "SlotsCalendar":
                sections = ["Calendar", "New slot", "Recurring"]
            elif name == "BookingRequests":
                sections = ["Pending list", "Approve/Reject", "Details"]
            elif name == "MyUsers":
                sections = ["User list", "Search", "Filters"]
            else:
                sections = None
            write_svg_to_zip("coach", name, title, sections, mobile_frame)

        # Admin
        for name in admin_pages:
            title = name.replace("_"," ")
            if name in ("Users","Products","Orders","PlansList","Analytics","Settings"):
                sections = ["Filters", "Table/List", "Inspector", "Actions"]
            else:
                sections = None
            write_svg_to_zip("admin", name, title, sections, web_frame)

    # Write zip to disk
    out_path = "FitCoach_Figma_Mini_Pack.zip"
    with open(out_path, "wb") as f:
        f.write(buf.getvalue())
    print(f"Created {out_path} ({len(buf.getvalue())} bytes)")

if __name__ == "__main__":
    main()

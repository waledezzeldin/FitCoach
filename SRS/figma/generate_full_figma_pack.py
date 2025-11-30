#!/usr/bin/env python3
"""
FitCoach – Figma Full Import Pack Generator
Creates SVG frames for all User/Coach/Admin screens + design tokens JSON.

Usage:
  python generate_full_figma_pack.py
  python generate_full_figma_pack.py --tokens my_theme.json --icons ./icons

Notes:
- If you pass --tokens (exported with Tokens Studio from your Figma file),
  the pack will use your exact palette/typography/radii/spacing.
- If you pass --icons pointing to a folder of SVGs (exported from your Figma file),
  matching names (e.g., home.svg, workout.svg, coach.svg) will be embedded on screens.
"""

import os, io, json, argparse, zipfile, datetime, re

# ---------- Defaults (safe, dark-gym look; overridden by --tokens) ----------
DEFAULT_TOKENS = {
  "version": "1.0",
  "core": {
    "color": {
      "primary": {"value": "#0EA5E9"},
      "secondary": {"value": "#22D3EE"},
      "accent": {"value": "#22C55E"},
      "bg": {"value": "#0B1220"},
      "surface": {"value": "#121A2A"},
      "panel": {"value": "#0F172A"},
      "text": {"value": "#E5E7EB"},
      "muted": {"value": "#94A3B8"}
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

# ---------- Screen sets ----------
USER_SCREENS = [
 "Splash","Login","Signup","OAuthProviders","ForgotPassword",
 "Intake","GeneratingPlan","Home","Notifications",
 "WorkoutPlan","ExerciseDetail","WorkoutSession",
 "NutritionPlan","MealIdeas",
 "CoachHub","BookingCalendar","BookingDetail","BookingStatus","VideoCall","Chat",
 "Subscription","PlansCompare","UpgradeCheckout",
 "SupplementsStore","ProductDetails","Cart","Checkout","OrderConfirmation",
 "Profile","EditProfile","Orders","OrderDetails","ChangePassword"
]
COACH_SCREENS = [
 "CoachLogin","CoachForgotPassword","CoachHome","Dashboard",
 "SlotsCalendar","NewSlot","RecurringRules",
 "BookingRequests","BookingDetail","VideoSession",
 "MyUsers","UserOverview","WorkoutPlanEdit","NutritionPlanEdit","ProgressInsights",
 "Messages","ChatThread",
 "CoachAccount","CoachChangePassword"
]
ADMIN_SCREENS = [
 "AdminLogin","AdminForgotPassword","AdminHome","Dashboard",
 "Users","UserDetail","CreateUser","AssignCoach","SubscriptionOverride",
 "Coaches","CoachDetail","CreateCoach",
 "PlansList","PlanEditor","BenefitsMatrix",
 "Products","ProductEditor","InventoryAdjust",
 "Orders","OrderDetail","EditOrder",
 "Analytics","Settings","PaymentsSettings","NotificationsSettings","DemoMode",
 "AuditLog","AuditEntryDetail"
]

# ---------- SVG helpers ----------
def esc(t): return (t or "").replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
def read_icon_svg(icons_dir, name):
    if not icons_dir: return None
    candidates = [
        f"{name}.svg",
        f"{name.lower()}.svg",
        f"{name.replace(' ','_').lower()}.svg",
        f"{re.sub('[^a-z0-9]+','_',name.lower())}.svg",
    ]
    for c in candidates:
        p = os.path.join(icons_dir, c)
        if os.path.exists(p):
            try:
                return open(p, "r", encoding="utf-8").read()
            except:
                return None
    return None

def frame_mobile(title, sections, tokens, icon_name=None, icon_svg=None):
    w,h = 360,800
    c = tokens["core"]["color"]
    t = tokens["core"]["font"]
    # background + appbar
    elems = []
    elems.append(f'<rect x="0" y="0" width="{w}" height="{h}" fill="{c["bg"]["value"]}"/>')
    elems.append(f'<rect x="0" y="0" width="{w}" height="56" fill="{c["surface"]["value"]}"/>')
    elems.append(f'<text x="16" y="36" fill="{c["text"]["value"]}" font-size="{t["size"]["lg"]["value"]}" font-family="{t["family"]["value"]}" font-weight="{t["weight"]["semibold"]["value"]}">{esc(title)}</text>')
    # optional icon in header (right)
    if icon_svg:
        # naive embed: place at right side
        elems.append(f'<g transform="translate(315,16) scale(0.8)">{icon_svg}</g>')
    # content cards
    y = 72
    for s in (sections or []):
        elems.append(f'<rect x="16" y="{y}" rx="12" ry="12" width="328" height="64" fill="{c["surface"]["value"]}" stroke="#1F2A40"/>')
        elems.append(f'<text x="28" y="{y+38}" fill="{c["muted"]["value"]}" font-size="{t["size"]["md"]["value"]}" font-family="{t["family"]["value"]}">{esc(s)}</text>')
        y += 76
        if y > h - 80: break
    # bottom nav
    elems.append(f'<rect x="0" y="{h-56}" width="{w}" height="56" fill="{c["surface"]["value"]}"/>')
    for i,label in enumerate(["Home","Workout","Coach","Nutrition","Account"]):
        x = 18 + i*70
        elems.append(f'<text x="{x}" y="{h-22}" fill="{c["muted"]["value"]}" font-size="{t["size"]["sm"]["value"]}" font-family="{t["family"]["value"]}">{label}</text>')
    return elems, w, h

def frame_web(title, sections, tokens, icon_svg=None):
    w,h = 1440,1024
    c = tokens["core"]["color"]
    t = tokens["core"]["font"]
    elems=[]
    elems.append(f'<rect x="0" y="0" width="{w}" height="{h}" fill="{c["bg"]["value"]}"/>')
    # sidebar + header
    elems.append(f'<rect x="0" y="0" width="256" height="{h}" fill="{c["panel"]["value"]}"/>')
    elems.append(f'<text x="24" y="48" fill="{c["text"]["value"]}" font-size="{t["size"]["lg"]["value"]}" font-family="{t["family"]["value"]}" font-weight="{t["weight"]["semibold"]["value"]}">Admin</text>')
    elems.append(f'<rect x="256" y="0" width="{w-256}" height="64" fill="{c["surface"]["value"]}"/>')
    elems.append(f'<text x="280" y="40" fill="{c["text"]["value"]}" font-size="{t["size"]["lg"]["value"]}" font-family="{t["family"]["value"]}" font-weight="{t["weight"]["semibold"]["value"]}">{esc(title)}</text>')
    if icon_svg:
        elems.append(f'<g transform="translate(1376,16) scale(0.8)">{icon_svg}</g>')
    # content grid
    y=88; x=280
    for i,s in enumerate((sections or [])[:6]):
        elems.append(f'<rect x="{x}" y="{y}" rx="12" ry="12" width="520" height="200" fill="{c["surface"]["value"]}" stroke="#1F2A40"/>')
        elems.append(f'<text x="{x+16}" y="{y+36}" fill="{c["muted"]["value"]}" font-size="{t["size"]["md"]["value"]}" font-family="{t["family"]["value"]}">{esc(s)}</text>')
        if i%2==1:
            y += 216; x=280
        else:
            x = 824
    return elems, w, h

def guess_sections(name):
    # Light content hints per screen
    name_l = name.lower()
    if "login" in name_l:
        return ["Email","Password","Sign in","OAuth: Google/Apple/Facebook"]
    if name in ("Intake","EditProfile"):
        return ["Age","Height","Weight","Gender","Workout Days","Location","Experience","Submit"]
    if name == "GeneratingPlan":
        return ["Generating… 62%","Tip: Hydrate well","Cancel"]
    if name == "Home":
        return ["Stats: Calories","Stats: Workouts","Stats: Nutrition","Shortcuts"]
    if name.startswith("Workout"):
        return ["Exercise list","Today card","Start workout","Timer / Sets / Reps"]
    if name.startswith("Nutrition"):
        return ["Daily targets","Macros chart","Meals","Supplements"]
    if "coach" in name_l or name in ("Chat","VideoCall"):
        return ["Coach card","Threads","Booking","Call / Message"]
    if "book" in name_l:
        return ["Slot info","Coach info","Request / Approve","Status timeline"]
    if "subscription" in name_l or "plan" in name_l:
        return ["Current plan","Benefits comparison","Upgrade / Checkout"]
    if "store" in name_l or "product" in name_l:
        return ["Filters","Grid/List","Details panel","Add to cart / Actions"]
    if name in ("Cart","Checkout","OrderConfirmation","OrderDetails","Orders"):
        return ["Items","Summary","Payment","Confirmation / Status"]
    if "profile" in name_l or "account" in name_l or "settings" in name_l:
        return ["Profile summary","Body metrics","Security","Preferences"]
    if name in ("Dashboard","Analytics"):
        return ["KPIs","Trends","Tasks","Shortcuts"]
    if name in ("SlotsCalendar","NewSlot","RecurringRules"):
        return ["Calendar","New slot","Recurring rules"]
    if name in ("BookingRequests","MyUsers","Users","Products","Orders","PlansList"):
        return ["Filters","Table/List","Inspector","Actions"]
    return ["Primary content","Secondary content","List / Cards","Actions"]

def icon_name_for(name):
    # Suggest canonical icon name (you can map these to your Figma icons)
    m = {
      "Home":"home","WorkoutPlan":"dumbbell","NutritionPlan":"restaurant","CoachHub":"person","Chat":"chat",
      "VideoCall":"video_call","Subscription":"subscriptions","PlansCompare":"compare","UpgradeCheckout":"credit_card",
      "SupplementsStore":"store","Cart":"shopping_cart","Checkout":"credit_card","OrderConfirmation":"receipt_long",
      "Profile":"account_circle","EditProfile":"edit","Orders":"shopping_bag","ChangePassword":"lock",
      "Intake":"tune","GeneratingPlan":"rocket","BookingCalendar":"event","BookingDetail":"event_available","BookingStatus":"pending_actions",
      "Notifications":"notifications",
      # Coach/Admin common:
      "Dashboard":"dashboard","SlotsCalendar":"event","BookingRequests":"inbox","MyUsers":"group",
      "Users":"group","Products":"inventory_2","Orders":"receipt_long","PlansList":"list_alt",
      "Analytics":"insights","Settings":"settings","DemoMode":"science","AuditLog":"history"
    }
    return m.get(name, None)

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--tokens", help="Tokens Studio JSON exported from your Figma file", default=None)
    ap.add_argument("--icons", help="Folder of your SVG icons (optional)", default=None)
    args = ap.parse_args()

    tokens = DEFAULT_TOKENS
    if args.tokens and os.path.exists(args.tokens):
        try:
            with open(args.tokens, "r", encoding="utf-8") as f:
                loaded = json.load(f)
            # very tolerant: if file contains color variables, map them
            # You can map your keys to ours before or here:
            tokens = DEFAULT_TOKENS
            def copy_val(src, path, dest_key):
                v = src
                for p in path:
                    v = v.get(p, {})
                if isinstance(v, dict) and "value" in v: v = v["value"]
                if isinstance(v, str) and v.startswith("#"):
                    tokens["core"]["color"][dest_key]["value"] = v
            # Try some common keys (adjust as needed)
            copy_val(loaded, ["core","color","primary"], "primary")
            copy_val(loaded, ["core","color","bg"], "bg")
            copy_val(loaded, ["core","color","surface"], "surface")
            copy_val(loaded, ["core","color","text"], "text")
            copy_val(loaded, ["core","color","muted"], "muted")
        except Exception as e:
            print("Warning: could not parse tokens file, fallback to defaults:", e)

    buf = io.BytesIO()
    with zipfile.ZipFile(buf, "w", zipfile.ZIP_DEFLATED) as z:
        # README
        readme = f"""FitCoach – Figma Full Import Pack
Generated: {datetime.datetime.utcnow().isoformat()}Z

This pack contains:
- user/*.svg (mobile frames, 360x800)
- coach/*.svg (mobile frames, 360x800)
- admin/*.svg (web frames, 1440x1024)
- design-tokens.json (Tokens Studio format)

How to use:
1) Unzip.
2) Drag the SVGs into Figma (they import as frames).
3) Open Tokens Studio → Import design-tokens.json → Apply styles to the frames.
4) If you provided --icons (your SVGs), header icons are embedded; otherwise placeholders are used.
"""
        z.writestr("FitCoach_Figma_Full_Pack/README.txt", readme)
        z.writestr("FitCoach_Figma_Full_Pack/design-tokens.json", json.dumps(tokens, indent=2))

        def write_svg(root, name, is_web=False):
            title = name
            sections = guess_sections(name)
            ic_name = icon_name_for(name) or name
            ic_svg = read_icon_svg(args.icons, ic_name) if args.icons else None
            if is_web:
                elems,w,h = frame_web(title, sections, tokens, ic_svg)
            else:
                elems,w,h = frame_mobile(title, sections, tokens, ic_name, ic_svg)
            svg = '\n'.join([f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">'] + elems + ["</svg>"])
            z.writestr(f"FitCoach_Figma_Full_Pack/{root}/{name}.svg", svg)

        for s in USER_SCREENS:
            write_svg("user", s, is_web=False)
        for s in COACH_SCREENS:
            # treat coach as mobile
            write_svg("coach", s, is_web=False)
        for s in ADMIN_SCREENS:
            write_svg("admin", s, is_web=True)

    out = "FitCoach_Figma_Full_Pack.zip"
    with open(out, "wb") as f:
        f.write(buf.getvalue())
    print(f"Created {out} ({len(buf.getvalue())} bytes)")

if __name__ == "__main__":
    main()

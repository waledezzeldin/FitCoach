import base64, pathlib
b64 = pathlib.Path("fitcoach_figma_pack.b64").read_text()
pathlib.Path("FitCoach_Figma_Mini_Pack.zip").write_bytes(base64.b64decode(b64))
print("Saved FitCoach_Figma_Mini_Pack.zip")
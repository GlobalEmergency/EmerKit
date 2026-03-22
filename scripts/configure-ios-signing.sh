#!/bin/bash
# Configure Runner.xcodeproj for manual distribution signing
# Usage: PROVISIONING_PROFILE_UUID=xxx bash scripts/configure-ios-signing.sh
set -e

cd ios

python3 << 'PYEOF'
import re, os

profile_uuid = os.environ.get("PROVISIONING_PROFILE_UUID", "")

with open("Runner.xcodeproj/project.pbxproj", "r") as f:
    c = f.read()

# Switch to manual signing
c = c.replace("CODE_SIGN_STYLE = Automatic;", "CODE_SIGN_STYLE = Manual;")

# Set Apple Distribution identity
c = re.sub(
    r'"CODE_SIGN_IDENTITY\[sdk=iphoneos\*\]" = [^;]*;',
    '"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "Apple Distribution";',
    c,
)

# Add PROVISIONING_PROFILE after each DEVELOPMENT_TEAM line
if profile_uuid:
    lines = c.split("\n")
    out = []
    for i, line in enumerate(lines):
        out.append(line)
        if "DEVELOPMENT_TEAM = " in line:
            next_line = lines[i + 1] if i + 1 < len(lines) else ""
            if "PROVISIONING_PROFILE" not in next_line:
                indent = line[: len(line) - len(line.lstrip())]
                out.append(f'{indent}PROVISIONING_PROFILE = "{profile_uuid}";')
    c = "\n".join(out)

with open("Runner.xcodeproj/project.pbxproj", "w") as f:
    f.write(c)

print(f"Configured: Manual signing, profile={profile_uuid}")
PYEOF

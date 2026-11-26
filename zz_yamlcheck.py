import io
import sys

import yaml

p = sys.argv[1] if len(sys.argv) > 1 else ".github/workflows/build-ipa.yml"
raw = open(p, "rb").read()
print("bytes:", len(raw))
print("has_tab:", b"\t" in raw)
print("non_ascii:", sum(1 for b in raw if b > 127))

doc = yaml.safe_load(io.open(p, encoding="utf-8"))
print("top keys:", list(doc))
print("jobs:", list(doc["jobs"]))
job = doc["jobs"]["build"]
print("runs-on:", job["runs-on"])
steps = job["steps"]
print("steps:", len(steps))
for i, s in enumerate(steps):
    label = s.get("uses") or s.get("name") or "<unnamed>"
    print("  %2d %s" % (i, label))
print("YAML OK")
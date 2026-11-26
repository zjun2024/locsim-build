import io
import yaml

p = r".github\workflows\build-ipa.yml"
raw = open(p, "rb").read()
print("bytes:", len(raw))
print("has_tab:", b"\t" in raw)
doc = yaml.safe_load(io.open(p, encoding="utf-8"))
print("top keys:", list(doc))
print("on:", doc.get(True sense, None) or doc.get("on"))
print("jobs:", list(doc["jobs"]))
steps = doc["jobs"]["build"]["steps"]
print("steps:", len(steps))
for i, s in enumerate(steps):
    label = s.get("uses") or s.get("name") or "<unnamed>"
    print(" ", i, label)
print("YAML OK")

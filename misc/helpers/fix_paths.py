import os
import re
from glob import glob

# finds and fixed all realtive module options

PATH = "./modules/nixos"
modules = [y for x in os.walk(PATH) for y in glob(os.path.join(x[0], "*.nix"))]

print(modules)

# check possible f ups
# rg "(?<\!(cfg =)) config.modules.nixos" /persist/nixos --pcre2

for mod in modules:
    with open(mod) as f:
        print(mod)
        fixed = ""

        RE_CFG = "^  cfg = config[.]modules[^ ;]*;"
        RE_OPT = "^  options[.]modules[^ ]* ="

        correct = mod[1:].replace("/", ".")[:-4]
        if correct.endswith(".default"):
            correct = correct[: -len(".default")]
            print(correct)

        for line in f.read().split("\n"):
            line = re.sub(
                RE_CFG,
                f"  cfg = config{correct};",
                line,
            )

            line = re.sub(
                RE_OPT,
                f"  options{correct} =",
                line,
            )

            fixed += line + "\n"

    with open(mod, "w") as f:
        f.write(fixed)

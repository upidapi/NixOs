import json
from os import path

data_path = path.join(path.dirname(__file__), "data.json")


with open(data_path) as f:
    data = json.load(f)


# enable = ["Disconnect"]

for addon in data["addons"]:
    # addon["active"] = addon["defaultLocale"]["name"] in enable

    addon["active"] = True

with open(data_path, "w") as f:
    json.dump(data, f, indent=2)

print("hello")

# :imap <buffer> <F9> <esc><cmd>wa<CR><cmd>1TermExec cmd='PS1=$"\\n>>> ";clear;echo -e "pypy3 %\\n";pypy3 %' <CR>

# works
# :map <buffer> <F9> <cmd>1TermExec cmd='PS1=$"\\n>>> "; clear' <CR>

# :map <buffer> <F9> <cmd>1TermExec cmd='PS1=$"\n>>> ";clear;echo -e "python3 %\\n";python3 %' <CR>

# :map <buffer> <F9> <cmd>1TermExec cmd='PS1=$"\n>>> ";clear;echo -e "python3 %\\n";python3 %; echo -e "\\nFinished with code: $?\\n"' <CR>

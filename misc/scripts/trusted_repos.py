repos = """\
https://github.com/notashelf/nyx
https://github.com/nobbz/nixos-config
https://github.com/fufexan/dotfiles
https://github.com/mitchellh/nixos-config
https://github.com/mic92/dotfiles
https://github.com/workflow/dotfiles
https://github.com/notohh/snowflake
https://github.com/misterio77/nix-config

https://github.com/hlissner/dotfiles
https://github.com/gvolpe/nix-config
"""

parsed = [x.strip() for x in repos.split("\n") if x.strip() != ""]

data = [
    {
        "url": data,
        "host": data.split("/")[2],
        "user": data.split("/")[3],
        "name": data.split("/")[4],
    }
    for data in parsed
]


def get_github_search():
    repos = " OR ".join(
        [f"repo:{d['user']}/{d['name']}" for d in data]
    )

    print(f"lang:nix ({repos})")


# def gen_md_credits():
#     print(
#         " - ".join([f"[{d['user']}]({d['url']})" for d in data])
#     )
#
# gen_md_credits()

get_github_search()

"""
lang:nix (repo:notashelf/nyx OR repo:nobbz/nixos-config OR 
repo:fufexan/dotfiles OR repo:mitchellh/nixos-config OR 
repo:mic92/dotfiles OR repo:workflow/dotfiles OR 
repo:notohh/snowflake OR repo:misterio77/nix-config OR 
repo:hlissner/dotfiles OR repo:gvolpe/nix-config)
"""

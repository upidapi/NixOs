import os
import json
import sys

"""
# https://www.reddit.com/r/NixOS/comments/e3tn5t/reboot_after_rebuild_switch/
# Warn if the generation may have changed some options
# that only take effect after reboot. This is to avoid a
# generation from a

# maby give the option to reboot when it detects that
# it might be needed
"""

"""
qa # alias for "qs --append"
qd # alias for "qs --debug --trace"


# do this in python

# show diff since last commit
git --no-pager diff HEAD

# terminate if the nixos-rebuld fails
"""

"""
qs
  [-h | --help]
    Print this help msg

  [-m | --mesage <msg>]
    use the <msg> commit msg

  [-p | --profile <host name>]
    Select profile to switch to

  [-a | --append <name>]
    creates a new branch called <name>, with then msg of <msg>
    moves the last commit into it
    changes to said branch

  [-t | --trace] 
    adds the --show-trace to nixos-rebuild


Sub commands:
  e | edit
    cd into nixos config, open editor

  g | goto
    cd into nixos config
    
  merge <branch name>


# qe := qs e
qa <msg> := qs --message <msg> --append
qd := qs --debug --trace
"""

NIXOS_PATH = "/persist/nixos"


def run_cmd(cmd, print: bool = False):
    ret = os.system(cmd)
    return "return data"


def get_last_profile():
    return "default"


def get_profiles():
    return []


DIV_LEN = 80


def colored_centerd_text(text, color, fill):
    out = ""

    tot_pad = DIV_LEN - len(text)
    out += (fill * (tot_pad // 2))
    out += text
    out += (fill * (tot_pad // 2 + tot_pad % 2))



def print_devider(text, color=33, fill="-"):
    colored_centerd_text(text, color, fill)
    print("\n")


def print_warn(text, color=33):
    # make sure that you don't miss it
    colored_centerd_text("", color, " ")
    colored_centerd_text("", color, " ")
    colored_centerd_text(text, color, " ")
    colored_centerd_text("", color, " ")


class Parser:
    # req makes arg required if only other req args
    # are set

    @staticmethod
    def parse_opt(opt): 
        opts = {}
        raw_arg_opts = opt.get("args", [])
        for i, arg_opt in enumerate(raw_arg_opts):
            start = arg_opt.get("start", i)
            length = arg_opt.get("len", 1)
            minimum = arg_opt.get("len", length)
            
            opts[arg_opt["name"]] = {
                "start": start,
                "len": length,
                "min": minimum,
            }
            
        for names, data in opt.keys():
            arg_name = None
            for arg_alias in names:
                if not arg_alias.startswith("-"):
                    arg_name = arg_alias
                    break

                if arg_alias.startswith("--"):
                    arg_name = arg_alias[2:]
                    break
                    
            name = data.get("name", False) or arg_name    
            if name is None:
                raise TypeError(f"could not find name for {(names, data)}")

            opts[name] = {
                "aliases": names,
                "doc": data.get("doc", ""),
                "args": data.get("args", 0),
                "raw": data,
                "start": opts[name].get("start", 0),
                "len": opts[name].get("len", 0),
                "min": opts[name].get("min", 0),
            }

        for name, data in opt.items():
            opts[name] = data | {
                "need": data.get("need", set()),
                "allow": data.get("allow", set()),
                "req": data.get("req", False)
            }
        
        return opts
        
            
    @staticmethod
    def parse_sys_args(opts):
        arg_alias_map = {}
        for name, data in opts.items():
            for alias in data.aliases:
                if alias.startswith("--"):
                    arg_alias_map[alias] = name
                    continue

                if alias.startswith("-"):
                    if len(alias) == 2:
                       arg_alias_map[alias] = name
                    else:
                        raise TypeError("cant add a muilti char flag")

                    continue

                arg_alias_map[alias] = name
        
        expanded_args = []
        opt_allowed = True
        for arg in sys.argv[1:]:
            if opt_allowed:
                if arg == "--":
                    opt_allowed = False      

                if arg.startswith("--"):
                    expanded_args.append(arg)
                    continue
                    
                if arg.startswith("-"):
                    for part in arg[1:]:
                        expanded_args.append(f"-{part}")

            expanded_args.append(f"\"{arg}\"")
        
        args = {name: [] for name, _ in opts}

        capturing = 0
        arg_name = None
        arg_raw_name = None
        
        positional_args = []

        for arg in expanded_args:
            arg_is_opt = (
                arg.startswith("\"") and 
                arg.endswith("\"")
            )

            if capturing:
                if arg_is_opt:
                    tot_args = opts[arg_name]
                    supplied_args = tot_args - capturing

                    raise TypeError(
                        f"too few args ({supplied_args} of {tot_args})"
                        f"supplied to \"{arg_raw_name}\""
                    )
                
                capturing -= 1
                
                # remove the "" from it
                arg = arg[1:-1]
               
                args[arg_name][-1].append(arg)
                continue

            
            if not arg_is_opt:
                positional_args.append(arg)
                continue

                # raise TypeError(
                #     f"too many args (<{opts[arg_name].args})"
                #     f"supplied to \"{arg_raw_name}\""
                # )

            # start a opt capture
            arg_raw_name = arg
            arg_name = arg_alias_map[arg]

            capturing = opts[arg_name]["args"]
            
            args[arg_name].append([])
        
        orderd_args = sorted(
                filter(
                    lambda x: x[1]["len"], 
                    opts.items()
                ),
                key=lambda x: x[1]["start"],
            )
        
        i = 0
        for opt, data in orderd_args:
            pos_args = positional_args[i:][data["len"]:]
            if len(pos_args) < data["min"]:
                raise TypeError(
                    f"too few positionall args passed to {opt},"
                    f"only {len(positional_args)} of {data["min"]}"
                )
            
            if pos_args:
                args[opt].append(pos_args)

            i += data["len"] 

        return args


    @staticmethod
    def validate_args(args, opts):
        set_args = set()
        for arg, data in args.items():
            if data:
                set_args.add(arg) 

        req_args = set()
        for opt, data in opts.items():
            if data["req"]:
                req_args.add(opt)
        
        # if all set args are req, then make sure that all req args exist 
        if all(opts[arg]["req"] for arg in args.keys()):
            if set_args < req_args:
                raise TypeError(
                    f"missing the folowing (req) args: {req_args - set_args}"
                )
        
        allow_args = set()

        # this cant handle curcular allow / need
        for arg in set_args: 
            data = opts[arg]

            need = data["need"]
            if need > set_args:
                raise TypeError(
                    f"\"{arg}\" is missing the folowing args {need - set_args}"
                )
            
            allow_args.add(data["allow"])
            allow_args.add(data["need"])
            
            if set_args - allow_args:
                raise TypeError(
                    f"the folowing args aren't allowed: {set_args - allow_args}'"
                )
    

    @classmethod
    def parse(cls, opt_data):
        opts = cls.parse_opt(opt_data)
        args = cls.parse_sys_args(opts)
        cls.validate_args(args, opts)

        return args


def init():
    run_cmd(f"cd {NIXOS_PATH}")
    run_cmd(f"git add --all")

    print_devider("Formating Files")
    run_cmd("alejandra . || true", True)

    print_devider("Git Diff")
    run_cmd(f"git --no-pager diff HEAD", True)

    # colored_centerd_text("", color, " ")


def rebuild_nixos(profile, show_trace):
    print_devider(f"Rebuilding NixOs (profile: {profile})")
    ret_val = run_cmd(
        f"sudo nixos-rebuld switch"
        f" --flake .#{profile}"
        + (" --show-trace" * show_trace),
        True
    )

    if ret_val != "":
        print_warn("NixOs Rebuild Failed")
        exit()


def format_generation_data(profile):
    gen_data = run_cmd(
        "nixos-rebuild list-generations"
        "--json"
        # it needing this is a bug
        # TODO: submitt a pr to fix it
        "--flake /persist/nixos#default",
        print=False,
    )

    cur_gen_data = None
    for gen in json.loads(gen_data):
        if gen.current:
            cur_gen_data = gen
            break
    if cur_gen_data is None:
        raise TypeError("current gen not found")

    gen_str_data = (
        "info:"
        f"  Profile: {profile}"
        f"  Gen: {cur_gen_data.generation}\n"
        f"  NixOs: {cur_gen_data.nixosVersion}\n"
        f"  Kernel: {cur_gen_data.kernalVersion}\n"
    )

    return gen_str_data


def check_needs_reboot():
    needs_reboot = run_cmd("""
            booted="$(
                readlink /run/booted-system/{initrd,kernel,kernel-modules}
            )"
            built="$(
                readlink /nix/var/nix/profiles/system/{initrd,kernel,kernel-modules}
            )"

            if [ "$booted" = "$built" ]; 
                then echo "1"; 
                else echo "0";
            fi 
        """) == "0"

    if needs_reboot:
        print_warn("The new profile changed system files, please reboot")



APPEND_BRANCH = "idk"
DEBUG_BRANCH = "idk"


# --debug and --append never returns to the main branch
# you have to do that manually


# it assumes that your main branch is called "main"



"""
print_devider("Commiting Changes")
commit_msg = get_commit_msg(args.message)
# print(commit_msg, "\n")

run_cmd(f"git commit -am \"{commit_msg}\"")


print_devider("Pushing code to origin")
# pat = "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"
# git push https://$pat@github.com/upidapi/NixOs.git main
run_cmd("git push origin main")


print_devider("Successfullt applied nixos configuration", 32)
"""

# currently you cant have a option in args and kwargs
# might want to add that posibility
# (the kwarg would overide the arg)
def main():
    args = Parser.parse({
        "args": [
            {"name": "sub_command"}, 
        ],

        ("-h", "--help"): {
            "name": "help",
            "args": 0,
            "doc": """
            Prints this help message
            """,
        },

        ("-t", "--trace"): {},

        ("-m", "--message"): {
            "args": 1,
            "req": True,
        },
        ("-p", "--profile"): {
            "args": 1,
        },

        ("-a", "--append"): {
            "args": 1,
            "need": {"message"},
            "allow": {"trace", "profile"}
        }
    })
    
    print(args)

    sub_command = args["sub_command"][0]
    if sub_command in ("g", "goto"):
        run_cmd(f"cd {NIXOS_PATH}")
        return
        
    elif sub_command in ("e", "edit"):
        run_cmd(f"cd {NIXOS_PATH}")
        run_cmd(f"nvim .")
        return
    
    elif not sub_command == "": 
        raise TypeError(f"invallid subcommand {sub_command}")

    init()

    if args["append"]:
        current_branch = run_cmd("git rev-parse --abbrev-ref HEAD")
        
        return  
    
    profile = (args["profile"][0] or [get_last_profile()])[0]
    rebuild_nixos(profile, args["trace"])
    check_needs_reboot()
    
    commit_msg = format_generation_data()

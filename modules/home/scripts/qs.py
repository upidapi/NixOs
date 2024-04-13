import json
import sys
import subprocess

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


def run_cmd(cmd, print_res: bool = False, ignore=()):
    res = ""
    
    process = subprocess.Popen(
        cmd, 
        shell=True, 
        stdout=subprocess.PIPE
    )

    # replace "" with b"" for Python 3
    for line in iter(process.stdout.readline, b""): # type: ignore[attr-defined]
        dec = line.decode()
        res += dec
        
        if print_res:
            # print(repr(dec))
            if dec in ignore:
                continue

            print(dec, end="")

    return res


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
    
    # the comment at the end is to fix my indent detector
    # if not there, it makes it indent everyhing 2 tabs
    print(f"\033[0;{color}m{out}\033[0m") #]]


def print_devider(text, color=33, fill="-"):
    print("\n")
    colored_centerd_text(text, color, fill)


def print_warn(text, color: int | str = 33):
    # make sure that you don't miss it
    colored_centerd_text("", color, " ")
    colored_centerd_text("", color, " ")
    colored_centerd_text(text, color, " ")
    colored_centerd_text("", color, " ")
    colored_centerd_text("", color, " ")


class Parser:
    # req makes arg required if only other req args
    # are set

    @staticmethod
    def parse_opt(opt): 
        opts = {}
        raw_arg_opts = opt.get("args", [])
        del opt["args"]
        for i, arg_opt in enumerate(raw_arg_opts):
            start = arg_opt.get("start", i)
            length = arg_opt.get("len", 1)
            minimum = arg_opt.get("min", length)
            
            opt[(arg_opt["name"], )] = arg_opt | {
                "start": start,
                "len": length,
                "min": minimum,
            }
            
        for names, data in opt.items():
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
                
                "start": data.get("start", 0),
                "len": data.get("len", 0),
                "min": data.get("min", 0),
                
                "need": data.get("need", set()),
                "allow": data.get("allow", set()),

                "req": data.get("req", False),
                # "permit": data.get("req", False),

                "raw": data,
            }

        return opts
    
    @staticmethod
    def parse_sys_args(opts):
        arg_alias_map = {}
        for name, data in opts.items():
            for alias in data["aliases"]:
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
                    continue

            expanded_args.append(f"\"{arg}\"")
        
        args = {name: [] for name in opts.keys()}

        capturing = 0
        arg_name = None
        arg_raw_name = None
        
        positional_args = []

        for arg in expanded_args:
            arg_is_data = (
                arg.startswith("\"") and 
                arg.endswith("\"")
            )
        
            if capturing:
                if not arg_is_data:
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

            
            if arg_is_data:
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
                    f"only {len(positional_args)} of {data['min']}"
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
        
        allow_args = set()
        
        # if all set args are req, then make sure that all req args exist 
        if all(opts[arg]["req"] for arg in set_args):
            if set_args < req_args:
                raise TypeError(
                    f"missing the folowing (req) args: {req_args - set_args}"
                )

            allow_args |= req_args
        
        # this cant handle curcular allow / need
        for arg in set_args: 
            data = opts[arg]

            need = data["need"]
            if need > set_args:
                raise TypeError(
                    f"\"{arg}\" is missing the folowing args {need - set_args}"
                )
            
            allow_args |= data["allow"]
            allow_args |= data["need"]
            
            if set_args - allow_args:
                raise TypeError(
                    f"the folowing args aren't allowed: {set_args - allow_args}'"
                )
    

    @classmethod
    def parse(cls, opt_data):
        opts = cls.parse_opt(opt_data)
        args = cls.parse_sys_args(opts)
        # too tierd atm to actually implement this in
        # a good way
        # cls.validate_args(args, opts)

        return args


def validate_new_branch(new_branch):
    branch_exists_locally = run_cmd(
        f"git show-ref --verify --quiet refs/heads/{new_branch}; echo $?"
    ) == "0"
    if branch_exists_locally:
        raise TypeError(f"branch \"{new_branch}\" already exist locally")

    branch_exists_on_remote = run_cmd(
        f"git ls-remote --heads origin refs/heads/{new_branch}"
    )
    if branch_exists_on_remote:
        raise TypeError(f"branch \"{new_branch}\" already exist on remote")

    if new_branch == "":
        raise TypeError("branch cant be empty string")


def rebuild_nixos(profile, show_trace):
    print_devider(f"Rebuilding NixOs (profile: {profile})")

    main_command = (f"sudo nixos-rebuild switch"
        f" --flake .#{profile}"
        + (" --show-trace" * bool(show_trace))
    )
    fail_id = "9hLbAQzHXajZxei6dhXCOUoNIKD3nj9J"
    succeed_id = "EdJNfWcs91MsOGHoOfWJ6rqTQ6h1HHsw"

    data_ret = f"""
        if [ "$ret" ]; 
            then echo "{succeed_id}"; 
            else echo "{fail_id}";
        fi
    """

    raw_ret_val = run_cmd(
        f"ret=$({main_command});" + data_ret, 
        True,
        (fail_id + "\n", succeed_id + "\n")
    )
    
    ret_val = raw_ret_val.splitlines()[-1]

    # everyting is good
    if ret_val == succeed_id:
        return

    if ret_val == fail_id:
        print()
        print_warn("NixOs Rebuild Failed", 41)
        exit()

    raise TypeError(f"invallid {ret_val=}")


def format_generation_data(profile):
    gen_data = run_cmd(
        "nixos-rebuild list-generations"
        " --json"
        # it needing this is a bug
        # TODO: submitt a pr to fix it
        " --flake /persist/nixos#default",
    )

    cur_gen_data = None
    for gen in json.loads(gen_data):
        if gen["current"]:
            cur_gen_data = gen
            break
    if cur_gen_data is None:
        raise TypeError("current gen not found")

    gen_str_data = (
        f"info:\n"
        f"  Profile: {profile}\n"
        f"  Gen: {cur_gen_data['generation']}\n"
        f"  NixOs: {cur_gen_data['nixosVersion']}\n"
        f"  Kernel: {cur_gen_data['kernelVersion']}\n"
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
    # todo add a not flag, if true, then dont allow it unless 
    # something explicitly permitts it

    args = Parser.parse({
        "args": [
            {
                "name": "sub_command",
                "min": 0,
            }, 
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
            "allow": {"trace", "profile"},
        },

        ("-p", "--profile"): {
            "args": 1,
            # "permit": True,
        },

        ("-a", "--append"): {
            "args": 1,
            "need": {"message"},
            "allow": {"trace", "profile"}
        }
    })

    if args["sub_command"]:
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
    
    
    # do this before making changes
    if args["append"]:
        new_branch = args["append"][0][0]
        validate_new_branch(new_branch)

    run_cmd(f"cd {NIXOS_PATH}")
    run_cmd(f"git add --all")

    print_devider("Formating Files")
    run_cmd("alejandra . || true", True)

    print_devider("Git Diff")
    run_cmd(f"git --no-pager diff HEAD --color", True)

    profile = (args["profile"] or [[get_last_profile()]])[0][0]
    rebuild_nixos(profile, args["trace"])
    
    check_needs_reboot()
    
    print_devider("Commiting changes")
    commit_msg = format_generation_data(profile) + "\n" + args["message"][0][0]

    run_cmd(f"git commit -am \"{commit_msg}\"", True)
    
    if args["append"]:
        new_branch = args["append"][0][0]
        
        print_devider(
            f"Appending commit to last commit (new branch: {new_branch})"
        )

        # current_branch = run_cmd("git rev-parse --abbrev-ref HEAD")
        run_cmd(f"git branch {new_branch}")
        run_cmd(f"git reset --hard HEAD~2")
        run_cmd(f"git switch {new_branch}")
    
    print_devider("Pushing code to github")
    run_cmd("git push origin --all", True)

    print_warn(
        "Successfully applied nixos configuration changes", 
        "42;30"
    )


main()


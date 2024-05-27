import json
import os
import shlex
import subprocess
import sys

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

  # g | goto
  #   cd into nixos config
    
  # merge <branch name>

 qe := qs e
# qa <msg> := qs --message <msg> --append
qd := qs --debug --trace
"""
NIXOS_PATH = "/persist/nixos"


def run_cmd(
    cmd,
    print_res: bool = False,
    ignore=(),
    color: bool = False,
):

    if color:
        cmd = f"script --return --quiet -c {shlex.quote(cmd)} /dev/null"

    process = subprocess.Popen(
        cmd,
        shell=True,
        stdout=subprocess.PIPE,
    )

    res = ""
    for line in iter(process.stdout.readline, b""):  # type: ignore[attr-defined]

        dec = line.decode()
        res += dec

        if print_res:
            # print(repr(dec))
            if dec in ignore:
                continue

            print(
                dec,
                end="",
            )

    return res


def get_last_profile():
    flake_profile = os.environ.get("FLAKE_PROFILE")
    if flake_profile is None:
        raise TypeError("flake profile not found")
    return flake_profile


def get_profile(args):
    return (args["profile"] or [[get_last_profile()]])[0][0]
    

def get_profiles():
    return []


DIV_LEN = 80


def colored_centerd_text(
    text,
    color,
    fill,
):
    out = ""

    tot_pad = DIV_LEN - len(text)
    out += fill * (tot_pad // 2)
    out += text
    out += fill * (tot_pad // 2 + tot_pad % 2)

    # the comment at the end is to fix my indent detector
    # if not there, it makes it indent everyhing 2 tabs
    print(f"\033[0;{color}m{out}\033[0m")  # ]]


def print_devider(
    text,
    color=33,
    fill="-",
):
    print("\n")
    colored_centerd_text(
        text,
        color,
        fill,
    )


# rename to print banner
def print_warn(
    text,
    color: int | str = 33,
):
    # make sure that you don't miss it
    colored_centerd_text(
        "",
        color,
        " ",
    )
    colored_centerd_text(
        "",
        color,
        " ",
    )
    colored_centerd_text(
        text,
        color,
        " ",
    )
    colored_centerd_text(
        "",
        color,
        " ",
    )
    colored_centerd_text(
        "",
        color,
        " ",
    )


class Parser:
    # req makes arg required if only other req args
    # are set

    @staticmethod
    def parse_opt(
        opt,
    ):
        opts = {}
        raw_arg_opts = opt.get(
            "args",
            [],
        )
        del opt["args"]
        for (
            i,
            arg_opt,
        ) in enumerate(raw_arg_opts):
            start = arg_opt.get(
                "start",
                i,
            )
            length = arg_opt.get(
                "len",
                1,
            )
            minimum = arg_opt.get(
                "min",
                length,
            )

            opt[(arg_opt["name"],)] = arg_opt | {
                "start": start,
                "len": length,
                "min": minimum,
            }

        for (
            names,
            data,
        ) in opt.items():
            arg_name = None
            for arg_alias in names:
                if not arg_alias.startswith("-"):
                    arg_name = arg_alias
                    break

                if arg_alias.startswith("--"):
                    arg_name = arg_alias[2:]
                    break

            name = (
                data.get(
                    "name",
                    False,
                )
                or arg_name
            )
            if name is None:
                raise TypeError(
                    f"could not find name for {(names, data)}"
                )

            opts[name] = {
                "aliases": names,
                "doc": data.get(
                    "doc",
                    "",
                ),
                "args": data.get(
                    "args",
                    0,
                ),
                "start": data.get(
                    "start",
                    0,
                ),
                "len": data.get(
                    "len",
                    0,
                ),
                "min": data.get(
                    "min",
                    0,
                ),
                "need": data.get(
                    "need",
                    set(),
                ),
                "allow": data.get(
                    "allow",
                    set(),
                ),
                "req": data.get(
                    "req",
                    False,
                ),
                # "permit": data.get("req", False),
                "raw": data,
            }

        return opts

    @staticmethod
    def parse_sys_args(
        opts,
    ):
        arg_alias_map = {}
        for (
            name,
            data,
        ) in opts.items():
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

            expanded_args.append(f'"{arg}"')

        args = {name: [] for name in opts.keys()}

        capturing = 0
        arg_name = None
        arg_raw_name = None

        positional_args = []

        for arg in expanded_args:
            arg_is_data = arg.startswith('"') and arg.endswith('"')

            if capturing:
                if not arg_is_data:
                    tot_args = opts[arg_name]["args"]
                    supplied_args = tot_args - capturing

                    raise TypeError(
                        f"too few args ({supplied_args} of {tot_args})"
                        f'supplied to "{arg_raw_name}"'
                    )

                capturing -= 1

                # remove the "" from it
                arg = arg[1:-1]

                args[arg_name][-1].append(arg)
                continue

            if arg_is_data:
                positional_args.append(arg[1:-1])
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
                opts.items(),
            ),
            key=lambda x: x[1]["start"],
        )

        i = 0
        for (
            opt,
            data,
        ) in orderd_args:
            pos_args = positional_args[i:][: data["len"]]
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
        for (
            arg,
            data,
        ) in args.items():
            if data:
                set_args.add(arg)

        req_args = set()
        for (
            opt,
            data,
        ) in opts.items():
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
                    f'"{arg}" is missing the folowing args {need - set_args}'
                )

            allow_args |= data["allow"]
            allow_args |= data["need"]

            not_set = set_args - allow_args
            if not_set:
                raise TypeError(
                    f"the folowing args aren't allowed: {not_set}"
                )

    @classmethod
    def parse(
        cls,
        opt_data,
    ):
        opts = cls.parse_opt(opt_data)
        args = cls.parse_sys_args(opts)
        # too tierd atm to actually implement this in
        # a good way
        # cls.validate_args(args, opts)

        return args


def validate_new_branch(
    new_branch,
):
    branch_exists_locally = (
        run_cmd(
            "git show-ref"
            "--verify"
            f"--quiet refs/heads/{new_branch}"
            "; echo $?"
        )
        == "0"
    )

    if branch_exists_locally:
        raise TypeError(
            f'branch "{new_branch}" already exist locally'
        )

    branch_exists_on_remote = run_cmd(
        f"git ls-remote --heads origin refs/heads/{new_branch}"
    )
    if branch_exists_on_remote:
        raise TypeError(
            f'branch "{new_branch}" already exist on remote'
        )

    if new_branch == "":
        raise TypeError("branch cant be empty string")


def check_needs_reboot():
    needs_reboot = (
        run_cmd(
            """
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
    """
        )
        == "0"
    )

    if needs_reboot:
        print_warn(
            "The new profile changed system files, please reboot"
        )


# --debug and --append never returns to the main branch
# you have to do that manually


# it assumes that your main branch is called "main"



class Steps:
    @staticmethod
    def rebuild_nixos(args, profile):
        print_devider(f"Rebuilding NixOs (profile: {profile})")

        main_command = (
            # make sure that the DE continues to update
            f"nice -n 1 sudo nixos-rebuild switch"
            f" --flake .#{profile}" + (" --show-trace" * bool(args["trace"]))
        )

        fail_id = "9hLbAQzHXajZxei6dhXCOUoNIKD3nj9J"
        succeed_id = "EdJNfWcs91MsOGHoOfWJ6rqTQ6h1HHsw"

        data_ret = f"""
            if [ "$ret" ]; 
                then echo "{succeed_id}"; 
                else echo "{fail_id}";
            fi
        """
        
        full_cmd = f"ret=$({main_command});{data_ret}",

        raw_ret_val = run_cmd(
            full_cmd,
            True,
            (
                fail_id + "\n",
                succeed_id + "\n",
            ),
        )

        ret_val = raw_ret_val.splitlines()[-1]

        if ret_val == fail_id:
            print()
            print_warn(
                "NixOs Rebuild Failed",
                41,
            )
            exit()

        if ret_val != succeed_id:
            raise TypeError(f"invallid {ret_val=}")

        # everyting is good
    
    @staticmethod
    def get_gen_data():
        gen_data = run_cmd(
            "nixos-rebuild list-generations"
            " --json"
        )
        
        cur_gen_data = None
        for gen in json.loads(gen_data):
            if gen["current"]:
                cur_gen_data = gen
                break

        if cur_gen_data is None:
            raise TypeError("current gen not found")

        return cur_gen_data
    
    @staticmethod
    def _gen_commit_msg(args, profile, last_gen_data):
        gen_data = Steps.get_gen_data()

        last_gen = last_gen_data["generation"]
        cur_gen = gen_data["generation"]

        full_commit_msg = (
            f"{args['message'][0][0]}\n"
            f"\n"
            f"info:\n"
            f"  Profile: {profile}\n"
            f"  Gen: {last_gen} -> {cur_gen}\n"
            f"  NixOs: {gen_data['nixosVersion']}\n"
            f"  Kernel: {gen_data['kernelVersion']}\n"
        )

        return full_commit_msg 
    
    @staticmethod
    def commit_changes(args, profile, last_gen_data):
        print_devider("Commit msg")

        commit_msg = Steps._gen_commit_msg(args, profile, last_gen_data)

        # gen commit msg
        print(commit_msg)

        print_devider("Commiting changes")

        run_cmd(
            f'git commit --allow-empty -am {shlex.quote(commit_msg)}',
            print_res=True,
            color=True
        )
    
    @staticmethod
    def formatt_files():
        print_devider("Formating Files")
        run_cmd(
            "alejandra . || true",
            print_res=True,
            color=True
        )

    @staticmethod
    def show_diff():
        print_devider("Git Diff")
        run_cmd(
            "git --no-pager diff HEAD --color",
            print_res=True,
            color=True
        )
    
    @staticmethod
    def push_changes():
        print_devider("Pushing code to github")
        # pat = "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"
        # origin = f"https://{pat}@github.com/upidapi/NixOs.git"
        origin = "git@github.com:upidapi/NixOs.git"

        run_cmd(
            f"git push {origin} --all",
            print_res=True,
            color=True
        )
    
    @staticmethod
    def add_all_files():
        run_cmd(
            "git add --all",
            print_res=True,
            color=True
        )

    class Pull:
        @staticmethod
        def pre():
            pass


def set_commit_msg(args, commit_msg):
    if args["message"]:
        raise TypeError("this command doesn't take a msg")

    args["message"] = [[commit_msg]]
    return args 


class Recipes:
    @staticmethod
    def add_show_formatt_files():
        # nixos ignores files that are not added
    
        Steps.add_all_files()
        Steps.formatt_files()
        Steps.show_diff()


    @staticmethod
    def rebuild_and_commit(args):
        last_gen_data = Steps.get_gen_data()

        # rebuild nixos
        profile = get_profile(args)

        Steps.rebuild_nixos(args, profile)
        
        check_needs_reboot()

        # commit
        Steps.commit_changes(args, profile, last_gen_data)
    

class ParserV2:
    @staticmethod
    def parse_pos_args(pos, struct):
        pos_args = {}

        for pos_data in struct["positional"]:
            has_default = isinstance(pos_data, tuple)

            pos_name, default = pos_data if has_default else [pos_data, None]

            if pos:
                pos_args[pos_name] = pos.pop()
                continue

            if has_default:
                pos_args[pos_name] = default

            raise TypeError(f"\"{pos_name}\" is missing it's arg")

        return pos_args

    @staticmethod
    def coherse_args(args, struct):
        expanded = []
        # expand -xyz to -x -y -z
        for arg in args:
            if not arg.startswith("--") and arg.startswith("-"):
                expanded += [f"-{flag}" for flag in arg[1:]]
            else:
                expanded.append(arg)
        
        # replace shorthands and aliases
        alias_to_main = {}
        for name, data in struct["flags"]: 
            alias_to_main[name] = name
            for alias in data["alias"]:
                if alias in alias_to_main.keys():
                    # add scope info
                    raise TypeError(f"the alias \"{alias}\" is used more than once")
                
                alias_to_main[alias] = name
        
        flag_data = {}
        pos_args = {}

        pos = []

        pos_count = len(struct["positional"])

        capturing_pos = []
        capturing_arg = None
        capturing_count = 0
        for i, arg in enumerate(args):
            if arg.startswith("-"):
                if capturing_count != 0:
                    raise TypeError(
                        f"flag defined before \"{arg}\" compleated"
                        f"({capturing_count} left)"
                    )

                arg_pos = None

                if "=" in arg:
                    arg, *arg_pos = arg.split("=")

                if arg not in alias_to_main:
                    # add scope info
                    raise TypeError(f"could not find arg \"{arg}\"")
        
                arg = alias_to_main[arg]
                arg_data = struct["flags"][arg]
                capturing_count = arg_data["count"]
                
                if arg_pos is not None:
                    if len(arg_pos) != capturing_count:
                        raise TypeError(f"too few args passed to \"{arg}\"")
                        
                    flag_data[arg].append(arg_pos)
            
            if capturing_arg is None:
                if len(pos) == pos_count:
                    if not struct["sub_command"]:
                        raise TypeError("too many positionall args")
                    
                    if arg not in struct["sub_command"]:
                        raise TypeError(f"unknown sub command \"{arg}\"")

                    pos_args = ParserV2.parse_pos_args(pos, struct)

                    return {
                        "flags": flag_data,
                        "pos": pos_args,
                        "sub_command": arg,
                        "sub_data": ParserV2.parse_pos_args(
                            args[i + 1:],
                            struct["sub_commands"][arg],
                        )
                    }

                pos.append(arg)
            

            if capturing_count != 0:
                capturing_pos.append(arg)
                capturing_count -= 1
            
            if capturing_count == 0:
                flag_data[arg].append(capturing_pos)
                capturing_pos = []
                capturing_arg = None
        
        pos_args = ParserV2.parse_pos_args(pos, struct)
        return {
            "flags": flag_data,
            "pos": pos_args,
            "sub_command": None,
            "sub_data": {}
        }

            
"""
something help


something <req> <req> [optional] [optional] 
    -f  --flag         info
    -o  --other-flag   info
    
    sub-command        info
    other-sub-command  info

"""


def part(
    flags: dict | None = None,
    poss: list | None = None,
    sub: dict | None = None,
    allow_extra: bool = False,
    req_sub: bool = False,
):
    if sub is not None:
        if allow_extra:
            raise TypeError(
                "cant have arbitrary amount of args and sub commands"
            )

    if poss is None:
        poss = []
    
    setting_default = False
    for pos in poss:
        has_default = "default" in pos.keys()
        if req_sub and has_default:
            raise TypeError("cant have default args if the sub command is required")

        if not setting_default:
            if has_default:
                raise TypeError("cant have non default arg after default arg") 

        setting_default = setting_default or has_default
    

    if len(poss) != len(list(set(poss))):
        raise TypeError("can have duplicates in positional names")

    return {
        "flags": flags is not None or {},
        "positional": poss is not None or [],
        "sub_commands": sub is not None or {},
        "allow_extra": allow_extra,  # put into *args
        "req_sub": req_sub  # put into *args
    }
              
        
x = part(
    {
        "--message": {
            "alias": ["-m"],
            "info": "commit msg for the rebuild",
        
            # not needed, default behaviour
            # "allow_sub": False

            "count": 1,
            "default": None
        },

        "--profile": {
            "alias": ["-p"],
            "info": "the flake profile to build",
            "count": 1,
            "default": None
        },
    },
    [   
        "other",  # no default => required
        ("test", "default") 
    ],
    {
        # generated automatically
        # "help": {
        # },

        "edit": {
            "alias": ["e"],
            "info": "open the config in the editor"
        },

        "diff": {
            "alias": ["d"],
            "info": "show diff between HEAD and last commit"
        },

        "update": {
            "alias": ["u"],
            "info": "update flake inputs and rebuild"
        },

        "pull": {
            "alias": ["p"],
            "info": "pull for remote and rebuild"
        },
    }
)


# currently you cant have a option in args and kwargs
# might want to add that posibility
# (the kwarg would overide the arg)
def main():
    # todo add a not flag, if true, then dont allow it unless
    # something explicitly permitts it

    args = Parser.parse(
        {
            "args": [
                {
                    "name": "sub_command",
                    "min": 0,
                },
            ],
            (
                "-h",
                "--help",
            ): {
                "name": "help",
                "args": 0,
                "doc": """
            Prints this help message
            """,
            },

            (
                "-t",
                "--trace",
            ): {},

            (
                "-m",
                "--message",
            ): {
                "args": 1,
                "req": True,
                "allow": {
                    "trace",
                    "profile",
                },
            },
            
            (
                "-p",
                "--profile",
            ): {
                "args": 1,
                # "permit": True,
            },

            (
                "-a",
                "--append",
            ): {
                "args": 1,
                "need": {"message"},
                "allow": {
                    "trace",
                    "profile",
                },
            },
        }
    )

    print(args)

    # make sure that we're in the right place
    os.chdir(NIXOS_PATH)

    """
    is_up_to_date = run_cmd("git diff origin/main HEAD") == ""
    if not is_up_to_date:
        print_warn(
            "Local is not up to date with remote",
            43,
        )
    """

    if args["sub_command"]:
        sub_command = args["sub_command"][0][0]

        if sub_command in (
            "e",
            "edit",
        ):
            # subprocess.run(f"cd {NIXOS_PATH}; nvim .", shell=True)
            # os.chdir(NIXOS_PATH)
            subprocess.run(
                f"nvim {NIXOS_PATH}",
                shell=True,
            )
            return

        elif sub_command in (
            "d",
            "diff",
        ):
            return Steps.show_diff()

        elif sub_command in (
            "u",
            "update",
        ):
            run_cmd(
                "nix flake update",
                print_res=True,
                color=True
            )

            args = set_commit_msg(args, "update flake inputs")
            Recipes.add_show_formatt_files()
            Recipes.rebuild_and_commit(args)

            return

        elif sub_command in (
            "p",
            "pull",
        ):
            print_devider("Pulling Changes")

            run_cmd("git stash")
            run_cmd(
                "git pull git@github.com:upidapi/NixOs.git main",
                print_res=True,
                color=True
            )

            args["message"].append(["Pulled changes from remote"])

        elif not sub_command == "":
            raise TypeError(f"invallid subcommand {sub_command}")

    if not args["message"] or not args["message"][0]:
        raise TypeError("missing --message argument")


    Recipes.add_show_formatt_files() 
    Recipes.rebuild_and_commit(args)

    if args["sub_command"]:
        sub_command = args["sub_command"][0][0]

        if sub_command in (
            "p",
            "pull",
        ):
            run_cmd("git stash pop")
    
    Steps.push_changes()

    print("\n")
    print_warn(
        "Successfully applied nixos configuration changes",
        "42;30",
    )


main()

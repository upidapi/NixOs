import json
import os
import shlex
import subprocess
import sys


NIXOS_PATH = "/persist/nixos"


class asd:
    @staticmethod
    def Pasd():
        pass


def run_cmd(
    cmd,
    print_res: bool = False,
    ignore=(),
    color: bool = False,
):
    if color:
        cmd = (
            f"script --return --quiet -c {shlex.quote(cmd)} /dev/null"
        )

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
    return (args["--profile"] or [[get_last_profile()]])[0][0]


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
    # if not there, it makes it indent everything 2 tabs
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


def validate_new_branch(
    new_branch,
):
    branch_exists_locally = (
        run_cmd(
            "git show-ref"
            "--verify"
            f"--quiet refs/heads/{new_branch}"
            "; echo $?",
        )
        == "0"
    )

    if branch_exists_locally:
        raise TypeError(
            f'branch "{new_branch}" already exist locally',
        )

    branch_exists_on_remote = run_cmd(
        f"git ls-remote --heads origin refs/heads/{new_branch}",
    )
    if branch_exists_on_remote:
        raise TypeError(
            f'branch "{new_branch}" already exist on remote',
        )

    if new_branch == "":
        raise TypeError("branch can't be empty string")


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
    """,
        )
        == "0"
    )

    if needs_reboot:
        print_warn(
            "The new profile changed system files, please reboot",
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
            f" --flake .#{profile}"
            + (" --show-trace" * bool(args["--trace"]))
        )

        fail_id = "9hLbAQzHXajZxei6dhXCOUoNIKD3nj9J"
        succeed_id = "EdJNfWcs91MsOGHoOfWJ6rqTQ6h1HHsw"

        data_ret = f"""
            if [ "$ret" ]; 
                then echo "{succeed_id}"; 
                else echo "{fail_id}";
            fi
        """

        full_cmd = (f"ret=$({main_command});{data_ret}",)

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

        # everything is good

    @staticmethod
    def get_gen_data():
        gen_data = run_cmd("nixos-rebuild list-generations --json")

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
            f"{args['--message'][0][0]}\n"
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

        commit_msg = Steps._gen_commit_msg(
            args,
            profile,
            last_gen_data,
        )

        print(commit_msg)

        print_devider("Committing changes")

        run_cmd(
            f"git commit --allow-empty -am {shlex.quote(commit_msg)}",
            print_res=True,
            color=True,
        )

    @staticmethod
    def formatt_files():
        print_devider("Formatting Files")
        run_cmd("alejandra . || true", print_res=True, color=True)

    @staticmethod
    def show_diff():
        print_devider("Git Diff")
        run_cmd(
            "git --no-pager diff HEAD --color",
            print_res=True,
            color=True,
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
            color=True,
        )

    @staticmethod
    def add_all_files():
        run_cmd("git add --all", print_res=True, color=True)

    @staticmethod
    def print_success():
        print("\n")
        print_warn(
            "Successfully applied nixos configuration changes",
            "42;30",
        )

    class Pull:
        @staticmethod
        def pre():
            pass


def set_commit_msg(args, commit_msg):
    if args["--message"]:
        raise TypeError("this command doesn't take a msg")

    args["--message"] = [[commit_msg]]
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


class Parser:
    @staticmethod
    def _parse_pos_args(pos, struct):
        pos_args = {}

        for pos_data in struct["positional"]:
            has_default = isinstance(pos_data, tuple)

            pos_name, default = (
                pos_data if has_default else [pos_data, None]
            )

            if pos:
                pos_args[pos_name] = pos.pop()
                continue

            if has_default:
                pos_args[pos_name] = default
                continue

            raise TypeError(f'"{pos_name}" is missing it\'s arg')

        return pos_args

    @staticmethod
    def _create_alias_map(struct):
        # replace shorthands and aliases
        alias_to_main = {}
        for name, data in struct.items():
            alias_to_main[name] = name
            for alias in data["alias"]:
                if alias in alias_to_main:
                    # add scope info
                    raise TypeError(
                        f'the alias "{alias}" is used more than once',
                    )

                alias_to_main[alias] = name

        return alias_to_main

    @staticmethod
    def _validate_allow(parsed_args, struct):
        if parsed_args["sub_command"] is not None:
            for arg, data in parsed_args["flags"].items():
                if not data:
                    continue

                if not struct["flags"][arg]["allow_sub"]:
                    raise TypeError(
                        f'the "{arg}" flag can\'t be used with sub commands',
                    )

    @staticmethod
    def _coherse_args(args, struct):
        expanded = []
        # expand -xyz to -x -y -z
        for arg in args:
            if not arg.startswith("--") and arg.startswith("-"):
                expanded += [f"-{flag}" for flag in arg[1:]]
            else:
                expanded.append(arg)

        # replace shorthands and aliases
        alias_to_main = Parser._create_alias_map(struct["flags"])

        flag_data = {f: [] for f in struct["flags"].keys()}
        pos_args = {"*args": []}

        pos = []

        pos_count = len(struct["positional"])

        capturing_pos = []
        capturing_arg = None
        capturing_count = 0
        for i, arg in enumerate(args):
            if arg.startswith("-"):
                if capturing_count != 0:
                    raise TypeError(
                        f'flag defined before "{arg}" compleated'
                        f"({capturing_count} left)",
                    )

                arg_pos = None

                if "=" in arg:
                    arg, *arg_pos = arg.split("=")

                if arg not in alias_to_main:
                    # add scope info
                    raise TypeError(f'could not find arg "{arg}"')

                arg = alias_to_main[arg]
                arg_data = struct["flags"][arg]
                capturing_count = len(arg_data["args"])

                capturing_arg = arg

                if arg_pos is not None:
                    if len(arg_pos) != capturing_count:
                        raise TypeError(
                            f'too few args passed to "{arg}"',
                        )

                    flag_data[arg].append(arg_pos)

                continue

            if capturing_arg is None:
                if len(pos) == pos_count:
                    if not struct["sub_commands"]:
                        if struct["allow_extra"]:
                            pos_args["*args"].append(arg)
                            continue

                        raise TypeError("too many positionall args")

                    alias_to_sub_command = Parser._create_alias_map(
                        struct["sub_commands"],
                    )

                    if arg not in alias_to_sub_command.keys():
                        raise TypeError(
                            f'unknown sub command "{arg}"',
                        )

                    sub_command = alias_to_sub_command[arg]

                    pos_args = Parser._parse_pos_args(pos, struct)

                    parsed_args = {
                        "flags": flag_data,
                        "pos": pos_args,
                        "sub_command": sub_command,
                        "sub_data": Parser._parse_pos_args(
                            args[i + 1 :],  # noqa
                            struct["sub_commands"][sub_command][
                                "sub_options"
                            ],
                        ),
                    }

                    Parser._validate_allow(parsed_args, struct)
                    return parsed_args

                pos.append(arg)
                continue

            if capturing_count != 0:
                capturing_pos.append(arg)
                capturing_count -= 1

            if capturing_count == 0:
                flag_data[capturing_arg].append(capturing_pos)
                capturing_pos = []
                capturing_arg = None

        if capturing_count != 0:
            raise TypeError(
                f'too few args passed to "{capturing_arg}" '
                f"({capturing_count} more needed)",
            )

        pos_args = Parser._parse_pos_args(pos, struct)
        parsed_args = {
            "flags": flag_data,
            "pos": pos_args,
            "sub_command": None,
            "sub_data": {},
        }

        Parser._validate_allow(parsed_args, struct)

        return parsed_args

    @staticmethod
    def opt_part(
        flags: dict | None = None,
        poss: list | None = None,
        sub: dict | None = None,
        allow_extra: bool = False,
        req_sub: bool = False,
    ):
        if sub is not None:
            if allow_extra:
                raise TypeError(
                    "can't have arbitrary amount of args and sub commands",
                )

        if poss is None:
            poss = []

        setting_default = False
        for pos in poss:
            has_default = isinstance(pos, tuple)
            # has_default = "default" in pos.keys()

            if req_sub and has_default:
                raise TypeError(
                    "can't have default args if the sub command is required",
                )

            if setting_default:
                if not has_default:
                    raise TypeError(
                        "can't have non default arg after default arg",
                    )

            setting_default = setting_default or has_default

        if len(poss) != len(list(set(poss))):
            raise TypeError("can have duplicates in positional names")

        if flags is None:
            flags = {}

        for flag in flags.values():

            def set_default(key, val):
                if key not in flag.keys():
                    flag[key] = val

            set_default("alias", [])
            set_default("args", [])
            if isinstance(num_args := flag["args"], int):
                flag["args"] = [lambda *_: []] * num_args

            set_default("info", "")
            set_default("doc", flag["info"])
            set_default("allow_sub", False)

        if sub is None:
            sub = {}

        for sub_command in sub.values():

            def set_default(key, val):
                if key not in sub_command.keys():
                    sub_command[key] = val

            set_default("alias", [])
            set_default("info", "")
            set_default("doc", sub_command["info"])
            set_default("sub_options", Parser.opt_part())

        return {
            "flags": flags,
            "positional": poss,
            "sub_commands": sub,
            "allow_extra": allow_extra,  # put into *args
            "req_sub": req_sub,  # put into *args
        }

    @staticmethod
    def print_help():  # parsed_arg, struct):
        """Something help

        something <req> <req> [optional] [optional]
            -f  --flag         info
            -o  --other-flag   info

            sub-command        info
            other-sub-command  info

        """
        # TODO: add a help command

    @staticmethod
    def parse_sys_args(struct):
        return Parser._coherse_args(sys.argv[1:], struct)


def pp(data):
    print(json.dumps(data, indent=4))


# currently you can't have a option in args and kwargs
# might want to add that possibility
# (the kwarg would override the arg)
def main():
    # TODO add a not flag, if true, then dont allow it unless
    # something explicitly permitts it

    args = Parser.parse_sys_args(
        Parser.opt_part(
            {
                "--trace": {
                    "alias": ["-t"],
                    "info": "pass --show-trace to nixos-rebuild",
                },
                "--message": {
                    "alias": ["-m"],
                    "info": "commit msg for the rebuild",
                    # not needed, default behaviour
                    # "allow_sub": False,
                    "args": 1,
                    "default": None,
                },
                "--profile": {
                    "alias": ["-p"],
                    "info": "the flake profile to build",
                    "args": 1,
                    "default": None,
                },
            },
            [
                # "other",  # no default => required
                # ("test", "default")  # has default => not required
            ],
            {
                # generated automatically
                # "help": {
                # },
                "edit": {
                    "alias": ["e"],
                    "info": "open the config in the editor",
                },
                "diff": {
                    "alias": ["d"],
                    "info": "show diff between HEAD and last commit",
                },
                "update": {
                    "alias": ["u"],
                    "info": "update flake inputs and rebuild",
                },
                "pull": {
                    "alias": ["p"],
                    "info": "pull for remote and rebuild",
                },
            },
        ),
    )

    pp(args)

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

    sub_command = args["sub_command"]
    args = args["flags"]

    if sub_command is not None:
        if sub_command == "edit":
            # subprocess.run(f"cd {NIXOS_PATH}; nvim .", shell=True)
            # os.chdir(NIXOS_PATH)
            subprocess.run(
                f"nvim {NIXOS_PATH}",
                shell=True,
                check=False,
            )
            return None

        elif sub_command == "diff":
            return Steps.show_diff()

        elif sub_command == "update":
            run_cmd("git stash")

            run_cmd("nix flake update", print_res=True, color=True)

            args = set_commit_msg(args, "update flake inputs")

            try:
                Recipes.add_show_formatt_files()
                Recipes.rebuild_and_commit(args)
            finally:
                run_cmd("git stash pop")

            Steps.push_changes()
            Steps.print_success()

            return None

        elif sub_command == "pull":
            print_devider("Pulling Changes")

            run_cmd("git stash")
            run_cmd(
                "git pull git@github.com:upidapi/NixOs.git main",
                print_res=True,
                color=True,
            )

            args = set_commit_msg(args, "Pulled changes from remote")

            try:
                Recipes.add_show_formatt_files()
                Recipes.rebuild_and_commit(args)
            finally:
                run_cmd("git stash pop")

            Steps.push_changes()
            Steps.print_success()

            return None

    if not args["--message"] or not args["--message"][0]:
        raise TypeError("missing --message argument")

    Recipes.add_show_formatt_files()
    Recipes.rebuild_and_commit(args)

    Steps.push_changes()
    Steps.print_success()


main()

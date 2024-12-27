import os
import shlex
import subprocess
import tempfile

import json
import yaml

import atexit
import random
import re
import string
import time
from typing import Literal


try:
    from .parser import parse_sys_args, pp
except ImportError:
    from parser import parse_sys_args, pp


class Logger:
    _LOG_DIR = "~/.cache/quick-switch"

    @staticmethod
    def _create_log_file(path):
        expanded = os.path.expanduser(path)
        os.makedirs(os.path.dirname(expanded), exist_ok=True)

        new_log_file = open(expanded, "a")

        atexit.register(new_log_file.close)

        new_log_file.write("\n\n\n\n-------------start-------------")
        return new_log_file

    _full_log = _create_log_file(f"{_LOG_DIR}/commands-full.log")
    _log_file = _create_log_file(f"{_LOG_DIR}/commands.log")

    @classmethod
    def log(cls, data):
        ansi_escape = re.compile(r"\x1B[@-_][0-?]*[ -/]*[@-~]")

        # Removing ANSI escape codes from the string
        clean_string = ansi_escape.sub("", data).replace("\r", "")

        cls._log_file.write(clean_string)
        cls._full_log.write(data)


DATA_HEADER = "JkRBj0Bs-u7KFh2c9-CeL6MkHr-tp7N0hAq"


def run_cmd(
    cmd,
    print_res: bool = False,
    color: bool = False,
    data_cmd: str = "",
):
    tokens = [DATA_HEADER]

    if data_cmd:
        cmd = f"{cmd}\necho -n {DATA_HEADER}\n{data_cmd}"

    if color:
        cmd = (
            # by default it uses the shell in the $SHELL var
            # this is a unnecessary source of impurity
            f"SHELL=bash "
            f"script --return --quiet -c {shlex.quote(cmd)} /dev/null"
        )

    Logger.log(f"\n>>> {cmd}\n")

    process = subprocess.Popen(
        cmd,
        shell=True,
        stdout=subprocess.PIPE,
    )
    os.set_blocking(
        process.stdout.fileno(),  # type: ignore[attr-defined]
        False,
    )

    running = True
    p = print_res
    out = ""
    while running:
        raw_data = b""

        # get data
        while True:
            # note: the absolute first one is "always" empty
            # since the process has no time to output

            raw_part = process.stdout.read()  # type: ignore[attr-defined]

            if raw_part == b"":
                # no more data
                running = False
                break

            if raw_part is None:
                # no more data atm
                time.sleep(0.1)
                break

            # there is more data atm

            raw_data += raw_part

        if raw_data == b"":
            continue

        data = [raw_data.decode()]
        out += data[0]

        Logger.log(data[0])

        # split the data into parts
        # where each part is ether only data or only a token
        for token in tokens:
            data = sum(
                [
                    sum([[x, token] for x in d.split(token)], [])[:-1]
                    for d in data
                ],
                [],
            )

        for part in data:
            # you could add more "headers" / "signlas"
            # for example one, when echoed could turn on the printing
            # again
            if part == DATA_HEADER:
                p = False
                continue

            if p:
                print(part, end="", flush=True)

        # print(len(data))

    return out


class Print:
    _DIV_LEN = 80

    @classmethod
    def _colored_centerd_text(
        cls,
        text,
        color,
        fill,
    ):
        out = ""

        tot_pad = cls._DIV_LEN - len(text)
        out += fill * (tot_pad // 2)
        out += text
        out += fill * (tot_pad // 2 + tot_pad % 2)

        # the comment at the end is to fix my indent detector
        # if not there, it makes it indent everything 2 tabs
        print(f"\033[0;{color}m{out}\033[0m")  # ]]

    @classmethod
    def devider(
        cls,
        text,
        color=33,
        fill="-",
    ):
        print("\n")
        cls._colored_centerd_text(
            text,
            color,
            fill,
        )

    @classmethod
    def banner(
        cls,
        text,
        color: int | str,
    ):
        # make sure that you don't miss it
        empty = ["", color, " "]
        for p in [empty, empty, [text, color, " "], empty, empty]:
            cls._colored_centerd_text(*p)

    @classmethod
    def banner_warn(cls, text):
        print()
        cls.banner(text, "43;30")

    # @classmethod
    # def banner_error(cls, text):
    #     print()
    #     cls.banner(text, 41)
    #     exit()

    @classmethod
    def success(cls):
        print("\n")
        cls.banner(
            "Successfully applied nixos configuration changes",
            "42;30",
        )


class Helpers:
    @staticmethod
    def de_indent(data):
        if data == "":
            return ""

        data = data.split("\n")
        spaces = len(data[0]) - len(data[0].lstrip(" "))
        return "\n".join(d[spaces:] for d in data)

    @staticmethod
    def get_rand_id(length):
        chars = string.ascii_letters + string.digits

        return "".join(random.choice(chars) for _ in range(length))


class Part:
    def get_nixos_path():
        flake_profile = os.environ.get("NIXOS_CONFIG_PATH")
        if flake_profile is None:
            raise TypeError("nixos config path not found")
        return flake_profile

    def _get_last_profile():
        flake_profile = os.environ.get("FLAKE_PROFILE")
        if flake_profile is None:
            raise TypeError("flake profile not found")
        return flake_profile

    @staticmethod
    def get_profile(args):
        return (args["--profile"] or [[Part._get_last_profile()]])[0][
            0
        ]

    # def get_profiles():
    #     return []

    @staticmethod
    def exit_program(msg: str):
        print("\n")
        Print.banner(
            msg,
            "41;30",  # red
        )
        exit()

    def check_needs_reboot():
        # fmt: off
        computer_needs_reboot = run_cmd(""" 
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
        """).strip() == "0"
        # fmt: on

        if computer_needs_reboot:
            Print.banner_warn(
                "You have changes that cant be applied until rebooot",
            )

    @staticmethod
    def format_files():
        Print.devider("Formatting Files")
        run_cmd("alejandra . || true", print_res=True, color=True)

    # git stuff
    @staticmethod
    def show_diff(target="HEAD"):
        Print.devider("Git Diff")
        # --cached diffs with what has been staged

        run_cmd(
            f"git --no-pager diff {target} --cached --color --ignore-all-space",
            print_res=True,
            color=True,
        )

    @staticmethod
    def check_changes(args, target="HEAD --cached"):
        has_changes = run_cmd(f"git diff {target}").strip() != ""

        if not (args["--force"] or has_changes):
            print()
            print("No Changes Found")
            exit()

    @staticmethod
    def check_up_to_date_with_remote():
        run_cmd("git fetch")
        is_up_to_date = run_cmd("git diff origin/main HEAD") == ""
        if not is_up_to_date:
            Print.banner_warn(
                "Local is not up to date with remote",
            )

    @staticmethod
    def add_all_files():
        run_cmd("git add --all", print_res=True, color=True)

    @staticmethod
    def push_changes():
        Print.devider("Pushing code to github")

        exit_code = (
            run_cmd(
                "git push origin --all",
                print_res=True,
                color=True,
                data_cmd="echo $?",
            )
            .split(DATA_HEADER, 1)[1]
            .strip()
        )

        # return true if push succeeded
        return exit_code == "0"

    @staticmethod
    def pull_changes():
        Print.devider("Pulling Changes")

        # remote could be eg git@github.com:upidapi/NixOs.git
        exit_code = (
            run_cmd(
                "git pull origin main",
                print_res=True,
                color=True,
                data_cmd="echo $?",
            )
            .split(DATA_HEADER, 1)[1]
            .strip()
        )

        if exit_code != "0":
            Part.exit_program("Pull Failed")

    @staticmethod
    def update_inputs():
        Print.devider("Updating Flake Inputs")
        run_cmd("nix flake update", print_res=True, color=True)

    @staticmethod
    def set_message(args, commit_msg):
        if args["--message"]:
            raise TypeError("this command doesn't take a msg")

        args["--message"] = [[commit_msg]]

        # i don't think you have to set it to itself
        # return args

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

        """
        {
            "generation": 81,
            "date": "2024-09-20T08:01:01Z",
            "nixosVersion": "24.11.20240906.574d1ea",
            "kernelVersion": "6.10.8",
            "configurationRevision": "",
            "specialisations": [
                "*"
            ],
            "current": true
        }
        """
        return cur_gen_data

    @staticmethod
    def rebuild_nixos(args, profile):
        branch = list(
            x
            for x in run_cmd("git branch").split("\n")
            if x.startswith("*")
        )[0][2:]

        Print.devider(
            f"Rebuilding NixOs (profile: {profile}, branch: {branch})"
        )

        sudo_part = f"""
            # not necisary here but i dont whant to unlick sudo twice
            chown -R root:wheel "$NIXOS_CONFIG_PATH";
            chmod -R 770 "$NIXOS_CONFIG_PATH";

            nixos-rebuild switch \\
              --flake .#{profile} \\
              {" --show-trace" * bool(args["--trace"])}
        """

        full_cmd = f"""
            ret=$(
                nice -n 1 sudo -- sh -c {shlex.quote(sudo_part)}
            );
        """

        raw_ret_val = run_cmd(
            full_cmd,
            True,
            True,
            data_cmd="""\
            if [ "$ret" ]; 
                then echo "0";
                else echo "1";
            fi
            """,
        ).split(DATA_HEADER, 1)

        if len(raw_ret_val) == 1:
            Part.exit_program("NixOs Rebuild Failed")

        ret_val = raw_ret_val[1].strip()

        if ret_val != "0":
            Part.exit_program("NixOs Rebuild Failed")

        # everything is good

    @staticmethod
    def rebuild_and_commit(args):
        no_rebuild = bool(args["--no-rebuild"])

        if no_rebuild:
            # not used
            last_gen_data = {}
            profile = ""
        else:
            last_gen_data = Part.get_gen_data()
            profile = Part.get_profile(args)

        hash = Commit.commit_changes(args, profile, last_gen_data)

        if no_rebuild:
            return

        Part.rebuild_nixos(args, profile)

        Commit.lazy_ammend_rebuild_commit(args, hash)

    @staticmethod
    def stash_changes():
        has_changes = run_cmd("git diff HEAD").strip() != ""

        if has_changes:
            run_cmd("git stash", print_res=True, color=True)
            atexit.register(lambda: run_cmd("git stash pop"))


class Commit:
    @staticmethod
    def get_last_commit_hash():
        return run_cmd("git log HEAD --pretty=%H -1").strip()

    @staticmethod
    def _cleanup_pre_rebuild_commit(hash):
        rev_list = run_cmd("git rev-list HEAD").split("\n")

        head_hash = run_cmd("git log HEAD --pretty=%H -1").strip()

        if head_hash == hash:
            run_cmd(
                "git reset --soft HEAD~1", print_res=True, color=True
            )
        elif hash not in rev_list:
            # commit amended or removed
            return
        else:
            raise Exception(
                "The pre rebuild commit is not the last commit"
            )

    @staticmethod
    def _fmt_gen_commit_msg(
        msg,
        commit_type: Literal["manuall", "pre-ammend", "pre-rebuild"],
        profile,
        gen_data,
        extra_gens: list[str],
        empty_gen: bool = False,
    ):
        gen = " -> ".join([
            str(x)
            for x in [*extra_gens, gen_data["generation"]]
            + [""] * empty_gen
        ]).strip()

        full_commit_msg = f"{msg}\n\n" + yaml.dump(
            {
                "info": {
                    "Profile": profile,
                    "Gen": gen,
                    "NixOs": gen_data["nixosVersion"],
                    "Kernel": gen_data["kernelVersion"],
                    "Type": commit_type,
                },
            },
            indent=2,
        )

        return full_commit_msg

    _PRE_REBUILD_COMMIT_MSG = (
        "auto: pre rebuild commit [probably broken]\n\n"
        "If you see this. Then the script failed to ammend it\n"
        "i.e something broke during the update\n"
    )
    # "oarGglYzX06kMUsG2noeXhK3utMT2n56\n"

    @staticmethod
    def _gen_pre_build_commit_msg(args, profile, last_gen_data):
        last_gen = last_gen_data["generation"]

        # id = get_rand_id(32)

        msg = (
            Commit._PRE_REBUILD_COMMIT_MSG
            + "\n"
            + args["--message"][0][0]
        )
        # f"{id}\n" + \

        return Commit._fmt_gen_commit_msg(
            msg,
            "pre-rebuild",
            profile,
            Part.get_gen_data(),
            [last_gen],
            True,
        )

    @staticmethod
    def commit_changes(args, profile, last_gen_data):
        Print.devider("Commit msg")

        no_rebuild = args["--no-rebuild"]

        if no_rebuild:
            message = args["--message"][0][0]
            print(message)

        else:
            message = Commit._gen_pre_build_commit_msg(
                args,
                profile,
                last_gen_data,
            )

            # show an approximation of the final message instead
            # of the pre rebuild commit
            print(
                Commit._fmt_gen_commit_msg(
                    args["--message"][0][0],
                    "manuall",
                    profile,
                    Part.get_gen_data(),
                    [],
                    True,
                )
            )

        Print.devider(
            "Committing changes"
            if no_rebuild
            else "Pre rebuild commit"
        )
        
        # TODO: remove when i don't manually have to do this (something
        #  is wrong about my git signing config)
        #  (i changed the ssh config so it might not be needed)
        run_cmd("ssh-add ~/.ssh/id_*", print_res=False)

        run_cmd(
            f"git commit --allow-empty -m {shlex.quote(message)}",
            print_res=True,
            color=True,
        )

        # get hash for commit in case user commits during rebuild
        hash = Commit.get_last_commit_hash()

        if not no_rebuild:
            atexit.register(Commit._cleanup_pre_rebuild_commit, hash)

        return hash

    @staticmethod
    def _parse_gen_commit_msg(commit_msg: str):
        data_size = 7
        try:
            raw_msg = commit_msg.split("\n")[:-data_size]
            data = commit_msg.split("\n")[-data_size:]

            # print(data)

            # print(data)
            yaml_data = yaml.safe_load("\n".join(data))["info"]

            gens = [
                x.strip()
                for x in yaml_data["Gen"].split("->")
                if x.strip() != ""
            ]

            return (
                False,
                {
                    "msg": "\n".join(raw_msg),
                    "profile": yaml_data["Profile"],
                    "gens": gens,
                    "type": yaml_data["Type"],
                    "nixosVerson": yaml_data["NixOs"],
                    "kernelVersion": yaml_data["Kernel"],
                },
            )

        except (IndexError, KeyError):
            return (True, {"msg": commit_msg})

    @staticmethod
    def lazy_ammend_rebuild_commit(args, hash):
        # simpler version of _amend_pre_rebuild_commit that
        # can only amend it if it's the last commit

        Print.devider("Amending pre rebuild commit")

        # print(hash)

        raw_commit_msg = run_cmd(
            f"git log {hash} -1 --pretty=%B"
        ).strip()
        manual, last_gen_data = Commit._parse_gen_commit_msg(
            raw_commit_msg
        )
        if manual:
            raise Exception("wut, commit is manua!?")

        # pp(last_gen_data)
        # commit_hash, last_gen_data = Steps._find_pre_rebuild_commit(id)

        head_hash = run_cmd("git log HEAD --pretty=%H -1").strip()
        if head_hash != hash:
            raise Exception(
                "The pre rebuild commit is not the last commit"
            )

        full_commit_msg = Commit._fmt_gen_commit_msg(
            args["--message"][0][0],
            "manuall",
            Part.get_profile(args),
            Part.get_gen_data(),
            [last_gen_data["gens"][-1]],
        )

        esc_msg = shlex.quote(full_commit_msg)
        run_cmd(
            f"git commit --amend --allow-empty -m {esc_msg}",
            print_res=True,
            color=True,
        )

        print()

        print(full_commit_msg)

    # unused
    @staticmethod
    def _git_interactive_rebase(hash, command_index, cmd, data):
        # this is just so incredibly fucking cursed

        # basically emulates an editor to run the interactive rebase

        # i = 1
        # cmd = "reword"
        # data = "new commit msg"

        temp = tempfile.TemporaryFile()
        try:
            # a program that will replace the second pick with squash
            temp.write(
                Helpers.de_indent(
                    f"""\
                import sys

                file = sys.argv[1]
                with open(file, "r") as f:
                    data = f.read()

                split = data.split("\n")

                if split[0].startswith("pick"):
                    data = "\n".join([
                        split[:{command_index}],
                        # squash the selected commit
                        "{cmd}" + split[{command_index}][4:],
                        *split[{command_index + 1}:]
                    ])
                    

                    # with open("t.txt", "w") as f:
                    #     f.write("")
                else:  
                    data = {repr(data)}


                with open(file, "w") as f:
                    f.write(data)

                # with open("t.txt", "a") as f:
                #     f.write(data + "\n----------------------------\n") 
            """
                ).encode()
            )

            run_cmd(
                f'env GIT_EDITOR="python {temp}" git rebase -i {hash}'
            )
        finally:
            temp.close()

    # untested and unused
    @staticmethod
    def amend_pre_rebuild_commit(args, profile, commit_hash):
        Print.devider("Amending pre rebuild commit")

        commit_message = run_cmd(
            f"git log {commit_hash} --pretty=%H -n 1"
        )
        last_gen_data = Commit._parse_gen_commit_msg(commit_message)

        full_commit_msg = Commit._fmt_gen_commit_msg(
            args["--message"][0][0],
            "manuall",
            profile,
            Part.get_gen_data(),
            [last_gen_data["gens"][-1]],
        )

        has_changes = run_cmd("git diff HEAD").strip() != ""

        if has_changes:
            amend_commit_msg = shlex.quote(
                Commit._fmt_gen_commit_msg(
                    "auto: commit to save index before ammending the pre-commit",
                    "pre-ammend",
                    profile,
                    Part.get_gen_data(),
                    [],
                )
            )

            run_cmd(
                f"git commit -am {amend_commit_msg}",
                print_res=True,
                color=True,
            )

        Commit._git_interactive_rebase(
            commit_hash, 0, "reword", full_commit_msg
        )

        if has_changes:
            run_cmd(
                "git reset --soft HEAD~1", print_res=True, color=True
            )


def noop():
    pass


class Command:
    @staticmethod
    def add_format_show(args, cmp_target="HEAD"):
        Part.format_files()

        if not args["--no-auto-add"]:
            Part.add_all_files()

        Part.show_diff(cmp_target)

    @staticmethod
    def rebuild(args, cmp_target="HEAD", pre_rebuild_callback=noop):
        # prep
        Command.add_format_show(args, cmp_target)
        Part.check_changes(args, cmp_target)

        # rebuild
        Part.rebuild_and_commit(args)

        # exit and warn
        Print.success()

        if not Part.push_changes():
            Print.banner_warn("Push to remote failed")

        Part.check_up_to_date_with_remote()

        Part.check_needs_reboot()

    @staticmethod
    def pull(args):
        Part.stash_changes()  # un stashes at exit

        hash = Commit.get_last_commit_hash()

        run_cmd("git fetch")
        Part.check_changes(
            args,
            "HEAD origin/main",
        )

        Part.pull_changes()

        Part.set_message(args, "pull changes")

        Command.rebuild(
            args,
            hash,
            lambda: run_cmd(
                "git log --oneline --no-decorate HEAD ^HEAD~3^",
                print_res=True,
                color=True,
            ),
        )

    @staticmethod
    def update(args):
        Part.stash_changes()  # un stashes at exit

        Part.update_inputs()

        Part.set_message(args, "update flake inputs")

        Command.rebuild(args)


def main():
    args = parse_sys_args({
        "name": "qs",
        "flags": {
            "--trace": {
                "alias": ["-t"],
                "info": "pass --show-trace to nixos-rebuild",
            },
            "--message": {
                "alias": ["-m"],
                "info": "commit msg for the rebuild",
                "doc": """\
                    The message that will be put ontop of the commit 
                    should preferably start with some type of catagory.
                    
                    If you use the "debug:" tag then you can later colapse 
                    multiple commits and or pull them out into their own 
                    branch using "qs squash" for more info see "qs help 
                    squash"

                    eg:
                        feat: add spicefy
                            program to customise spotify

                    eg:
                        debug: starship
                """,
                # default
                # "count": 1,
                "args": [
                    {
                        # only for the help screen
                        "name": "message",
                        # for tab completion
                    },
                ],
                # not needed, default behaviour
                # "allow_sub": False,
            },
            "--no-rebuild": {
                "alias": ["-c"],
                "info": "only commit changes, dont rebuild",
            },
            "--no-auto-add": {
                "alias": ["-n"],
                "info": "dont auto add/commit all files",
            },
            # "--no-add-files": {
            #     "alias": ["-n"],
            #     "info": "dont add any files",
            #     # not needed, default behaviour
            #     # "allow_sub": False,
            # },
            "--profile": {
                "alias": ["-p"],
                "info": "the flake profile to build",
                "args": [{"name": "<profile>"}],
            },
            "--force": {
                "alias": ["-f"],
                "info": "force rebuild even if there are no changes",
            },
        },
        "sub_cmd": {
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
                "info": "pull from remote and rebuild",
            },
        },
    })

    pp(args)

    # make sure that we're in the right place
    nixos_path = Part.get_nixos_path()
    os.chdir(nixos_path)

    sub_command = args.sub_cmd
    args = args.flags

    if sub_command is not None:
        if sub_command == "edit":
            # subprocess.run(f"cd {NIXOS_PATH}; nvim .", shell=True)
            # os.chdir(NIXOS_PATH)
            subprocess.run(
                f"nvim {nixos_path}",
                shell=True,
                check=False,
            )
            return None

        elif sub_command == "diff":
            return Command.add_format_show(args)

        elif sub_command == "update":
            return Command.update(args)

        elif sub_command == "pull":
            return Command.pull(args)

    if not args["--message"] or not args["--message"][0]:
        raise TypeError("--message argument required")

    if args["--force"] and args["--no-rebuild"]:
        raise TypeError("using --force and --no-rebuild is a noop")

    Command.rebuild(args)


if __name__ == "__main__":
    main()

import json
import os
import shlex
import subprocess
import atexit
import yaml 
import string
import random
from typing import Literal, Tuple, Any 
import tempfile

# remove the dot for debugging
try:
    from .parser import parse_sys_args, pp
except ImportError:
    from parser import parse_sys_args, pp


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


def de_indent(data):
    if data == "":
        return ""

    data = data.split("\n")
    spaces = len(data[0]) - len(data[0].lstrip(' '))
    return "\n".join(d[spaces:] for d in data)



def get_nixos_path():
    flake_profile = os.environ.get("NIXOS_CONFIG_PATH")
    if flake_profile is None:
        raise TypeError("nixos config path not found")
    return flake_profile


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
    text, color=33,
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

def exit_program(msg: str):
    print()
    print_warn(
        msg,
        41,
    )
    exit()

def get_rand_id(length):
    chars = string.ascii_letters + string.digits

    return ''.join(random.choice(chars) for _ in range(length))

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
        branch = list(
            x for x in 
            run_cmd("git branch").split("\n") 
            if x.startswith("*")
        )[0][2:]

        print_devider(
            f"Rebuilding NixOs (profile: {profile}, branch: {branch})"
        )
        
        fail_id = "9hLbAQzHXajZxei6dhXCOUoNIKD3nj9J"
        succeed_id = "EdJNfWcs91MsOGHoOfWJ6rqTQ6h1HHsw"

        sudo_part = f"""
            # not necisary here but i dont whant to unlick sudo twice
            chown -R root:wheel "$NIXOS_CONFIG_PATH";
            chmod -R 770 "$NIXOS_CONFIG_PATH";

            ret=$(
              nixos-rebuild switch \\
                --flake .#{profile} \\
                {" --show-trace" * bool(args["--trace"])}
            );

            if [ "$ret" ]; 
                then echo "{succeed_id}"; 
                else echo "{fail_id}";
            fi
        """
 
        full_cmd = f"""
            nice -n 1 sudo -- sh -c {shlex.quote(sudo_part)}
        """

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
            exit_program("NixOs Rebuild Failed")

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
    def _parse_gen_commit_msg(commit_msg: str):
        data_size = 7 
        try:
            raw_msg = commit_msg.split("\n")[:data_size]
            data = commit_msg.split("\n")[data_size:]
                
            yaml_data = yaml.safe_load("\n".join(data))
            
            gens = [
                x.strip() for x in 
                yaml_data["Gen"].split(" -> ")
                if x.strip != ""
            ]

            return (False, {
                "msg": "\n".join(raw_msg),
                "profile": yaml_data["Profile"],
                "gens": gens,
                "type": yaml_data["Type"],
                "nixosVerson": yaml_data["NixOs"],
                "kernelVersion": yaml_data["Kernel"],
            })

        except IndexError | KeyError:
            return (True, {"msg": commit_msg})

    @staticmethod
    def _fmt_gen_commit_msg(
            msg, 
            commit_type: Literal["manuall", "pre-ammend", "pre-rebuild"], 
            profile, 
            gen_data, 
            extra_gens: list[str],
            empty_gen: bool = False
    ):

        gen = " -> ".join([
            str(x) for x in 
            [*extra_gens, gen_data["generation"]] + [""] * empty_gen
        ]).strip()

        full_commit_msg = (
            f"{msg}\n"
            f"\n"
            + yaml.dump({
                "info": {
                    "Profile": profile,
                    "Gen": gen,
                    "NixOs": gen_data['nixosVersion'],
                    "Kernel": gen_data['kernelVersion'],
                    "Type": commit_type
                },
            }, indent=2)
        )

        return full_commit_msg

    _PRE_REBUILD_COMMit_MSG = \
        "auto: pre rebuild commit [probably broken]\n\n" \
        "if you see this then the script failed to ammend it\n" \
        "i.e something broke during the update\n" 
        # "oarGglYzX06kMUsG2noeXhK3utMT2n56\n"
    

    @staticmethod
    def _gen_commit_msg(args, profile, last_gen_data):
        last_gen = last_gen_data["generation"]
        
        # id = get_rand_id(32)

        msg = Steps._PRE_REBUILD_COMMit_MSG + "\n" + args['--message'][0][0]
            # f"{id}\n" + \

    
        return Steps._fmt_gen_commit_msg(
            msg,
            "pre-rebuild",
            profile, 
            Steps.get_gen_data(),
            [last_gen],
            True,
        )
    
    @staticmethod
    def _find_pre_rebuild_commit(id):
        print_devider("Amending pre rebuild commit")

        expected_commit_msg = Steps._PRE_REBUILD_COMMit_MSG + id
        # check last 100 commits

        for i in range(100):
            i_commit_msg = run_cmd(f"git log --skip={i} -1 --pretty=%B")
            i_commit_hash = run_cmd(f"git log --skip={i} -1 --pretty=%H")

            manual, last_gen_data = Steps._parse_gen_commit_msg(i_commit_msg)

            if manual: 
                # its a manual commit
                continue
            
            # if last_gen_data["type"] != "pre-rebuild":
            #     # not a pre-rebuild commit

            if not last_gen_data["msg"].startswith(expected_commit_msg):
                # not correct commit 
                continue
             
            # found it
            
            return i_commit_hash, last_gen_data 

        raise Exception(f"could not find pre commit ({id})")     

    @staticmethod
    def lazy_ammend_pre_rebuild_commit(args, hash):
        # simpler version of _amend_pre_rebuild_commit that 
        # can only amend it if it's the last commit

        print_devider("Amending pre rebuild commit")
            
        raw_commit_msg = run_cmd(f"git log {hash} -1 --pretty=%B")
        _, last_gen_data = Steps._parse_gen_commit_msg(raw_commit_msg)
        # commit_hash, last_gen_data = Steps._find_pre_rebuild_commit(id)
        
        head_hash = run_cmd("git log HEAD --pretty=%H -1")
        if head_hash != hash:
            raise Exception("The pre rebuild commit is not the last commit")

        full_commit_msg = Steps._fmt_gen_commit_msg(
            args['--message'][0][0],
            "manuall",
            get_profile(args), 
            Steps.get_gen_data(),
            [last_gen_data["gens"][-1]],
        )

        run_cmd(f'git commit --amend -m {shlex.quote(full_commit_msg)}')

    @staticmethod
    def amend_pre_rebuild_commit(args, profile, id):
        print_devider("Amending pre rebuild commit")
        
        commit_hash, last_gen_data = Steps._find_pre_rebuild_commit(id)
        full_commit_msg = Steps._fmt_gen_commit_msg(
            args['--message'][0][0],
            "manuall",
            profile, 
            Steps.get_gen_data(),
            [last_gen_data["gens"][-1]],
        )

        amend_commit_msg = shlex.quote(Steps._fmt_gen_commit_msg(
            "auto: commit to save index before ammending the pre-commit",
            "pre-ammend",
            profile, 
            Steps.get_gen_data(),
            [],
        ))

        run_cmd(
            f"git commit -am {amend_commit_msg}", 
            print_res=True,
            color=True
        )

        Steps._git_interactive_rebase(
            commit_hash, 0, "reword", full_commit_msg
        )

        run_cmd(
            f"git reset --soft HEAD~1", 
            print_res=True,
            color=True
        )

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
            temp.write(de_indent(f"""\
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
            """).encode())

            run_cmd(f'env GIT_EDITOR="python {temp}" git rebase -i {hash}')
        finally: 
            temp.close() 

    @staticmethod 
    def _squash_pre_rebuild_commit(hash):
        commit_msg = run_cmd(f"git log {hash} -1 --pretty=%B")
       
        Steps._git_interactive_rebase(
            f"{hash}^", 
            1, 
            "squash", 
            commit_msg
        )
    
    @staticmethod
    def commit_changes(args, profile, last_gen_data):
        print_devider("Commit msg")
        
        # TODO: remove when i don't manually have to ado this 

        run_cmd("ssh-add ~/.ssh/id_*", print_res=False)
   
        no_rebuild = args["--no-rebuild"]

        if no_rebuild:
            message = args["--message"][0][0]
            print(message)

        else:
            message = Steps._gen_commit_msg(
                args,
                profile,
                last_gen_data,
            )
            
            # show the final msg not the 
            print(Steps._fmt_gen_commit_msg(
                args['--message'][0][0],
                "manuall",
                profile, 
                Steps.get_gen_data(),
                [],
                True,
            ))
    

        print_devider("Committing changes" if no_rebuild else "Pre rebuild commit")
    
        add_files = (not args['--no-auto-add']) * "--all"

        run_cmd(
            f"git commit --allow-empty {add_files} -m {shlex.quote(message)}",
            print_res=True,
            color=True,
        )

        hash = run_cmd("git log HEAD --pretty=%H -1")

        return hash

    @staticmethod
    def formatt_files():
        print_devider("Formatting Files")
        run_cmd("alejandra . || true", print_res=True, color=True)

    @staticmethod
    def show_diff():
        print_devider("Git Diff")
        run_cmd(
            "git --no-pager diff HEAD --color --ignore-all-space",
            print_res=True,
            color=True,
        )

    @staticmethod 
    def tmp_stash_changes():
        has_changes = run_cmd("git diff HEAD origin/main").strip() != ""
        
        if has_changes:
            run_cmd("git stash", print_res=True, color=True)
            atexit.register(lambda: run_cmd("git stash pop"))
    
    @staticmethod
    def check_changes(args):
        if not args["--force"]:
            if run_cmd("git diff HEAD").strip() == "":
                print("No changes found")
                exit()

    @staticmethod
    def push_changes():
        return  # TODO: 

        print_devider("Pushing code to github")

        run_cmd(
            f"git push origin --all",
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
    def add_show_formatt_files(args):
        # nixos ignores files that are not added
        
        if not args["--no-auto-add"]:
            Steps.add_all_files()

        Steps.formatt_files()
        Steps.show_diff()

    @staticmethod
    def rebuild_and_commit(args):
        if args["--no-rebuild"]:
            Steps.commit_changes(args, "", {}) 
            return
        
        last_gen_data = Steps.get_gen_data()

        # rebuild nixos
        profile = get_profile(args)

        hash = Steps.commit_changes(args, profile, last_gen_data)

        Steps.rebuild_nixos(args, profile)

        check_needs_reboot()

        # commit

        Steps.lazy_ammend_pre_rebuild_commit(args, hash)


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
                "args": [
                    {
                        "name": "<profile>"
                    }
                ],
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
    nixos_path = get_nixos_path()
    os.chdir(nixos_path)

    """
    is_up_to_date = run_cmd("git diff origin/main HEAD") == ""
    if not is_up_to_date:
        print_warn(
            "Local is not up to date with remote",
            43,
        )
    """

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
            return Recipes.add_show_formatt_files(args)

        elif sub_command == "update":
            Steps.tmp_stash_changes()

            run_cmd("nix flake update", print_res=True, color=True)

            args = set_commit_msg(args, "update flake inputs")

            Recipes.add_show_formatt_files(args)
            Recipes.rebuild_and_commit(args)

            Steps.push_changes()
            Steps.print_success()

            return None

        elif sub_command == "pull":
            run_cmd("git fetch")

            Steps.check_changes(args)

            print_devider("Pulling Changes")
            
            Steps.tmp_stash_changes()
            
            # remote could be eg git@github.com:upidapi/NixOs.git
            run_cmd(
                "git pull origin main",
                print_res=True,
                color=True,
            )

            args = set_commit_msg(args, "Pulled changes from remote")

            Recipes.add_show_formatt_files(args)
            Recipes.rebuild_and_commit(args)

            Steps.push_changes()
            Steps.print_success()

            return None
    
    if not args["--message"] or not args["--message"][0]:
        raise TypeError("--message argument required")
        
    if args["--force"] and args["--no-rebuild"]: 
        raise TypeError("using --force and --no-rebuild is a noop")

    Steps.check_changes(args)

    Recipes.add_show_formatt_files(args)
    Recipes.rebuild_and_commit(args)

    Steps.push_changes()
    Steps.print_success()


if __name__ == "__main__":
    main()

import argparse
import subprocess
import json

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
struct:



"""



"""x = 
{
    ("-t", "--trace"): {
        is_flag = True,
        desc = \"""
            pass --trace to nixos-rebuild
        \"""
    },
    ("-p", "--profile"): {
        is_flag = True,
        desc = \"""
            select profile to switch to
        \"""
        args = (
            {
                name = "profile",
                desc = "profile name",
                choices = get_profiles(),
                default = get_last_profile(),
            }
        )
    },
    ("-a", "--append"): {
        is_flag = True,
        desc = \"""
          pass --trace to nixos-rebuild
         \"""
        args = (
           ("profile", "profile name")
        )
    },
}

def parse():
"""


"""
qs
  [-m | -message <commit msg>]
    "Name of the commit with this generation"

  [-h | --help]
    Print this help msg

  [-p | --profile <host name>]
    Select profile to switch to

  [-t | --trace]
    Pass --trace to nixos-rebuild

  [-a | --append <feature (branch) name>]
    append / connect this change to the last
    should be used to fix a bug in a generation
    if last switch was a qa, then use the name from said qs

    To organice things, the first qa starts a new branch
    and adds the commit before it to it.
    The branch is remerged when a qs is used again.

  [-d | --debug <debug msg (branch name)>]
    Feature wise it's just -a but whithout having to specify 
    -m <message>. So it's soly for debuging. Using "qs -a <branch>"
    and then "as -d" contunies on the same branch

    Allows you to really quicky iterate over generations
    to find some bug, in this mode you shuld preferably only
    fix one thing



Sub commands:
  e | edit
    cd into nixos config, open editor

  g | goto
    cd into nixos config


# qe := qs e
qa <msg> := qs --message <msg> --append
qd := qs --debug
"""


NIXOS_PATH = "/persist/nixos"


def run_cmd(cmd, print: bool = True):
   ret = os.system(cmd)


def get_last_profile():
    return "default"


def get_profiles():
    return []


def parse_args():
    parser = argparse.ArgumentParser(
        prog="qs",
        description="switches and handles nixos generations"
    )

    parser.add_argument(
        "-t", "--trace",
        action=argparse.BooleanOptionalAction
    )


    parser.add_argument(
        "-m", "--message"
    )

    parser.add_argument(
        "-p", "--profile",
        choices = get_profiles(),
        default = get_last_profile(),
    )

    parser.add_argument(
        "-a", "--append",
        nargs = "?",
        default = False,
        const = True
    )

    parser.add_argument(
        "-d", "--debug",
        nargs = "?",
        default = False,
        const = True
    )


    parser.add_argument(
        "sub_command",
        choices = [
            "",
            "g", "goto",
            "e", "edit",
        ],
        default="",
        nargs="?",
    )

    return parser.parse_args()


DIV_LEN = 80    

def colored_centerd_text(text, color, fill):
    out = ""

    tot_pad = DIV_LEN - len(text)
    out += (fill * (tot_pad // 2))
    out += text
    out += (fill * (tot_pad // 2 + tot_pad % 2))

    print(f"\\033[0;m{color}{out}\\033[m")
    

def print_devider(text, color = 33, fill = "-"):
    colored_centerd_text(text, color, fill)
    print("\n")

def print_warn(text, color = 33):
    # make sure that you dont miss it 
    colored_centerd_text("", color, " ")
    colored_centerd_text("", color, " ")
    colored_centerd_text(text, color, " ")
    colored_centerd_text("", color, " ")
    colored_centerd_text("", color, " ")


def main():
    def init():
        run_cmd(f"cd {NIXOS_PATH}")
        run_cmd(f"git add --all")


        print_devider("Formating Files")
        run_cmd("alejandra . || true")


        print_devider("Git Diff")
        run_cmd(f"git --no-pager diff HEAD")


    def rebuild_nixos():
        print_devider(f"Rebuilding NixOs (profile: {args.profile})")
        ret_val = run_cmd(
            f"sudo nixos-rebuld switch --flake .#{args.profile}" \
            + "--show-trace" * args.debug
        )

        if ret_val != "":
            print_warn("NixOs Rebuild Failed")
            exit()


    def format_generation_data():
        gen_data = run_cmd(
            "nixos-rebuild list-generations"
            "--json" 
            # it needing this is a bug
            # TODO: submitt a pr to fix it
            "--flake /persist/nixos#default", 
            print = False,
        )

        cur_gen_data = None
        for gen in json.loads(cur_gen_data):
            if gen.current:
                cur_gen_data = gen
                break
        if cur_gen_data is None:
            raise TypeError("current gen not found")


         gen_str_data = f"(Gen: {cur_gen_data.generation}"
            f"NixOs: {cur_gen_data.nixosVersion}"
            f"Kernel: {cur_gen_data.kernalVersion})"
        
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
        

            

    print(parse_args())


# trace = args.trace or (args.debug is True)


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

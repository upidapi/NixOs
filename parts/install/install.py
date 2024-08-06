import argparse
import errno
import os
import shlex
import socket
import subprocess
import sys
from pathlib import Path

# this script (should) fully install my nixos config
# requiring only a nixos install (eg the installer iso) (and python)


def run_cmd(
    cmd,
    print_res: bool = True,
    ignore=(),
    color: bool = True,
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


def elavate():
    if os.getuid() == 0:
        return

    args = [sys.executable] + sys.argv
    commands = []

    commands.append(["sudo"] + args)

    for args in commands:
        try:
            os.execlp(args[0], *args)
        except OSError as e:
            if e.errno != errno.ENOENT or args[0] == "sudo":
                raise


def promt_option(promt, options):
    while True:
        print(promt)
        for i, option in enumerate(options):
            print(f"{i}) {option}")
        selected = input("#? ")

        if not selected.isnumeric() and (1 <= int(selected) <= len(options)):
            print(f"must be a number 1-{len(options)}\n")
            continue

        return options["selected"]


def has_internet(host="8.8.8.8", port=53, timeout=3):
    """Host: 8.8.8.8 (google-public-dns-a.google.com)
    OpenPort: 53/tcp
    Service: domain (DNS/TCP)
    """
    try:
        socket.setdefaulttimeout(timeout)
        socket.socket(socket.AF_INET, socket.SOCK_STREAM).connect((host, port))
        return True
    except OSError as ex:
        print(ex)
        return False


def get_hardware_cfg():
    return run_cmd(
        "nixos-generate-config "
        "--root /mnt "
        "--show-hardware-config ",
    )

def to_file(data, file_path):
    path = Path(file_path)
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(file_path, "x") as f:
        f.write(data)


def promt_create_new_host(profiles):
    new_host_name = input("name of new host: ")

    host_template_name = promt_option("host tamplate: ", ["none"] + profiles)

    if host_template_name == "none":
        run_cmd(f"mkdir ./hosts/{new_host_name}")
    else:
        run_cmd(f"cp -r ./hosts/{host_template_name} ./hosts/{new_host_name}")


    to_file(get_hardware_cfg(), f"./hosts/{new_host_name}/hardware.nix")

    print(
        "",
        "TODO:",
        "add the host to hosts/default.nix",
        "change the storage device in disko.nix",
        sep="\n",
    )


def init_bootstrap_cfg(profile):
    # store the profile in a file to preserve it to the reboot after the install
    # this will be picked upp by the bootstrap-config which will install the full system
    run_cmd(f"""
        echo "{profile}" > /mnt/persist/profile-name.txt
    """)

    # The persist modules can't persist files in a
    # folder that doesn't exist, and /persist/system is where
    # we store the system files. (the nixos installer doesn't
    # work otherwise)
    # Therefour we have to manually create this folder
    # (this took me mpabout 2 full days to figure out, :) )
    run_cmd("mkdir /mnt/persist/system")

    # now we have to create a conventional config to start,
    # since nixos-install can't handle flakes
    run_cmd("mkdir /mnt/etc/nixos/ -p")

    # generate a tmp hardware cfg that includes the files system
    # since disko doesn't work without flakes
    to_file(get_hardware_cfg(), "/mnt/etc/nixos/hardware.nix")

    # just a barebones config to start with, soly used to bootstrap
    # the real one
    run_cmd(
        "cp "
        "/mnt/persist/nixos/parts/install/bootstrap-config.nix "
        "/mnt/etc/nixos/configuration.nix ",
    )

    run_cmd(
        "nixos-install "
        "--root /mnt "
        # if you've done some fuckery with the nix path 
        # (eg pinning it to the flake inputs)
        "--extra-experimental-features \"flakes\""
        # all cores TODO: check if this is true 
        "--cores 0 "
        "--no-root-passwd ",
    )

    # the install continues using a systemd service in bootstrap-config.nix


def install_system(profile):
    run_cmd(
        "nixos-install "
        "--root /mnt "
        # all cores TODO: check if this is true
        "--cores 0 "
        "--no-root-passwd "
        f"--flake /mnt/persist/nixos#{profile}",
    )

    print("dont forget to add the age key(s) in /persist/sops-age-key.txt")


def preserv_network_connections():
    x = "etc/NetworkManager/system-connections"
    run_cmd(f"cp /{x}/* /mnt/{x}/")


def parse_args():
    parser = argparse.ArgumentParser(description="Process some arguments.")

    parser.add_argument("-p", "--profile", type=str, help="Profile name")

    parser.add_argument(
        "-s", "--silent",
        action="store_true",
        help="Run in silent mode, ei no further inputs required",
    )

    parser.add_argument(
        "-n", "--new-profile",
        action="store_true",
        help="Create a new profile",
    )

    args = parser.parse_args()

    if args.new_profile and args.silent:
        parser.error("cant create new profile in silent install")

    if args.new_profile and args.profile:
        parser.error("you cant set new-profile and profile")

    if args.silent and not args.profile:
        parser.error("--profile is required when --silent is set")

    profiles = next(os.walk("./hosts"))[1]

    if args.profile and args.profile not in profiles:
        parser.error(f"invallid profile, must be one of {profiles}")

    return args


def main():
    args = parse_args()

    def notify(data):
        if args.silent:
            return

        while True:
            res = input(f"{data} [Yn]: ")
            if res in ("y", ""):
                return

            if res == "n":
                print("cancelling install")
                exit()

            print("choice myst be one of [y, n]")

    if not has_internet():
        print("installer requires an internett connection")

    elavate()

    preserv_network_connections()

    run_cmd("mkdir /tmp/nixos -p")
    os.chdir("/tmp/nixos")

    # we can't put this directly into /mnt/persist/nixos
    # since /mnt gets wiped when reformatting the disk with disko
    run_cmd("git clone https://github.com/upidapi/NixOs /tmp/nixos")


    profiles = next(os.walk("./hosts"))[1]

    if args.new_profile:
        args.profile = promt_create_new_host(profiles)

    if not args.profile:
        selected = promt_option("select host: ", ["create new host"] + profiles)

        if selected == "create new host":
            args.profile = promt_create_new_host(profiles)


    notify("format the file system with disko")
    run_cmd("""
    nix \\
      --experimental-features "nix-command flakes" \\
      run github:nix-community/disko -- \\
      --mode disko "/tmp/nixos/hosts/$profile/disko.nix"
    """)


    # move the config to the correct place, since disko would've
    # erased it (along with everything else in /persist)
    run_cmd("mkdir /mnt/persist")
    run_cmd("cp -r /tmp/nixos /mnt/persist/nixos")

    run_cmd("touch /mnt/persist/sops-nix-key.txt")
    run_cmd("chmod 700 /mnt/persist/sops-nix-key.txt")


    mode = "flake"

    if mode == "bootstrap":
        init_bootstrap_cfg(args.profile)

    elif mode == "flake":
        install_system(args.profile)


    notify("reboot to finish install")
    run_cmd("reboot")


if __name__ == "__main__":
    main()


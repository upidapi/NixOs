import os, sys, json
from pathlib import Path


# this script (should) fully install my nixos config
# requiring only a nixos install (eg the installer iso)


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
    """
    Host: 8.8.8.8 (google-public-dns-a.google.com)
    OpenPort: 53/tcp
    Service: domain (DNS/TCP)
    """
    try:
        socket.setdefaulttimeout(timeout)
        socket.socket(socket.AF_INET, socket.SOCK_STREAM).connect((host, port))
        return True
    except socket.error as ex:
        print(ex)
        return False


def get_hardware_cfg():
    return run_cmd(
        "nixos-generate-config "
        "--root /mnt "
        "--show-hardware-config "
    )

def to_file(data, file_path):
    path = Path(file_path)
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(file_path, "x") as f:
        f.write(data)


def promt_create_new_host(profiles):
    new_host_name = input("name of new host: ")

    host_template_name = promt_options("host tamplate: ", ["none"] + profiles)
    
    if host_template == "none":
        run_cmd(f"mkdir ./hosts/{new_host_name}")
    elif: 
        run_cmd(f"cp -r ./hosts/{host_template_name} ./hosts/{new_host_name}")

    
    to_file(get_hardware_cfg(), f"./hosts/{new_host_name}/hardware.nix")

    print(
        "",
        "TODO:",
        "add the host to hosts/default.nix",
        "change the storage device in disko.nix",
        sep="\n"
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
    mkdir /mnt/etc/nixos/ -p

    # generate a tmp hardware cfg that includes the files system
    # since disko doesn't work without flakes
    to_file(get_hardware_cfg(), f"/mnt/etc/nixos/hardware.nix")

    # just a barebones config to start with, soly used to bootstrap 
    # the real one
    run_cmd(
        "cp " 
        "/mnt/persist/nixos/parts/install/bootstrap-config.nix " 
        "/mnt/etc/nixos/configuration.nix "
    )
    
    run_cmd(
        "nixos-install " 
        "--root /mnt " 
        # all cores TODO: check if this is true
        "--cores 0 " 
        "--no-root-passwd "
    )

    # the install continues using a systemd service in bootstrap-config.nix


def preserv_network_connections():
    x = "etc/NetworkManager/system-connections"
    run_cmd(f"cp /{x}/* /mnt/{x}/")


def main():
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

    selected_profile = promt_options("select host: " ["create new host"] + profiles)

    if selected == "create new host":
        promt_create_new_host(profiles)
        exit()

    # formatt the file system with disko
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
    
    if len(argv) >= 2:
        mode = argv[1]
    else:
        mode = promt_option(["bootstrap", "flake"])
     
/    run_cmd("touch /mnt/persist/sops-nix-key.txt")
    run_cmd("chmod 700 /mnt/persist/sops-nix-key.txt")

    if mode == "bootstrap":
        init_bootstrap_cfg()
        exit()

    elif mode == "flake";
        run_cmd(
            "nixos-install " 
            "--root /mnt " 
            # all cores TODO: check if this is true
            "--cores 0 " 
            "--no-root-passwd "
            f"--flake /mnt/persist/nixos#{selected_profile}"
        )

        print("dont forget to add the age key(s) in /persist/sops-age-key.txt")
        exit()

    print("invallid mode")

if __name__ == "__main__":
    main()


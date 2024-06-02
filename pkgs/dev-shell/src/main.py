import argparse
import json
import subprocess

import argcomplete


def run_command(command) -> str:
    return subprocess.check_output(
        command,
        shell=True,
    ).decode()


def pp(data):
    print(json.dumps(data, indent=4))


def get_dev_shells():
    current_system = run_command(
        "nix eval --impure --raw --expr 'builtins.currentSystem'"
    )

    raw_info = json.loads(
        run_command("nix flake show --json $NIXOS_CONFIG_PATH")
    )

    dev_shell_data = raw_info.get("devShells", {}).get(
        current_system, {}
    )

    return list(dev_shell_data.keys())


def main():
    parser = argparse.ArgumentParser(
        prog="dev-shell",
        description="open a nix devshell",
    )

    dev_shells = get_dev_shells()

    parser.add_argument(
        "devshell",
        choices=dev_shells,
        default="default",
        nargs="?",
    )

    argcomplete.autocomplete(parser)
    args = parser.parse_args()

    selected_shell = args.devshell
    if selected_shell not in dev_shells:
        print(
            f'invallid shell: "{selected_shell}" valid shells: "{dev_shells}"'
        )

    subprocess.run(
        f"nix develop $NIXOS_CONFIG_PATH#{selected_shell}",
        shell=True,
        check=False,
    )


if __name__ == "__main__":
    main()

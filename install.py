import subprocess


def run_cmd(cmd, print_res: bool = False, ignore=()):
    res = ""

    process = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)

    # replace "" with b"" for Python 3
    for line in iter(process.stdout.readline, b""):  # type: ignore[attr-defined]

        dec = line.decode()
        res += dec

        if print_res:
            # print(repr(dec))
            if dec in ignore:
                continue

            print(dec, end="")

    return res


"""


"""

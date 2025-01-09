# based on https://gist.github.com/Pyrestone/105c837f8aab14bd833d5807b2c43751

import os
import shlex

# save our current directory so we know where to write the file in the end
INITIAL_CWD = os.path.abspath(os.getcwd())

home_dir = os.environ["HOME"]

dirs = []

# get all the paths we cd'd to in the past
with open(f"{home_dir}/.config/nushell/history.txt") as file:
    for line in file:
        try:
            tokens = shlex.split(line.strip())
        except:
            continue
        if "cd" in tokens:
            save_next = False
            for t in tokens:
                if t == "cd":
                    save_next = True
                    continue
                if save_next:
                    dirs.append(t)
                    save_next = False

visited_dirs = []

# get absolute paths
cwd = os.path.abspath(home_dir)
last_cwd = cwd
for dir in dirs:
    try:
        if not os.path.isabs(dir):
            dir = os.path.join(cwd, dir)

        dir = os.path.abspath(dir)

        if not os.path.isdir(dir):
            continue

        if dir == last_cwd:
            continue

        visited_dirs.append(dir)
    except OSError:
        pass


# build one long zoxide add command:
cmd = ["zoxide", "add"] + visited_dirs
command = shlex.join(cmd)
with open("add_command.bash", "w") as file:
    file.write(command)

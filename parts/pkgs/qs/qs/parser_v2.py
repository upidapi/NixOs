from collections.abc import Sequence
import sys
from typing import Callable, Any, Self, Iterable, Union
import json
from dataclasses import dataclass, field 


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

            Parser._error(f'"{pos_name}" is missing it\'s arg')

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
                    Parser._error(
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
                    Parser._error(
                        f'the "{arg}" flag can\'t be used with sub commands',
                    )
    
    @staticmethod
    def _error(msg):
        raise TypeError(msg)
    
    @staticmethod
    def _expand_shorthands(raw_args):
        # replace shorthands

        expanded = []
        # expand -xyz to -x -y -z
        for i, arg in enumerate(raw_args):
            if arg == "--":
                expanded += raw_args[i + 1:]
                break

            if not arg.startswith("--") and arg.startswith("-"):
                expanded += [f"-{flag}" for flag in arg[1:]]
            else:
                expanded.append(arg)

        return expanded
    
    """
    x = {
        # normal arg
        "--try": [
            # --try=db1=db2
            ["db1", "db2"],

            # --try=db3
            ["db3"]
        ],
        
        # ... "some name" ...
        "name": "some name",
        
        # list of pos args
        "*args": ["val 1", "val 2"],

        # dict of extra key args
        "**kwargs": {
            "--trace": [[]],
        }
    }
    """


    @staticmethod
    def _coherse_args(raw_args, struct, parent_scope=()):
        args = Parser._expand_shorthands(raw_args) 

        alias_to_main = Parser._create_alias_map(struct["kwargs"])

        cmd_args = CmdArgs(
            args = {f: [] for f in struct["kwargs"].keys()},
        )
        
        captured = []
        cur_key = None
        cur_n_val = 0
        
        only_pos = False
        val_is_extra_kwarg = False

        i = 0;
        while True:
            if cur_key is not None and cur_n_val == 0:
                if val_is_extra_kwarg:
                    cmd_args.args["**kwargs"][cur_key].append(captured)
                    val_is_extra_kwarg = False
                else:
                    cmd_args.args[cur_key].append(captured)

                cur_key = None
                cur_n_val = 0

            if i == len(args):
                break

            arg = args[i]
            i += 1

            if arg.startswith("-") and not only_pos:
                if arg == "--":
                    only_pos = True
                    continue

                if cur_key is not None:
                    Parser._error(
                        f'flag "{arg}" defined before "{cur_key}" compleated'
                        f"({cur_n_val - len(captured)} left)",
                    )

                # handle arg=val1=val2 syntax
                if "=" in arg:
                    arg, *vals = arg.split("=")
                    arg = alias_to_main[arg]
                    cmd_args.args[arg].append(vals)
                    continue
                
                if arg not in alias_to_main:
                    if struct["allow_extra_kwargs"]:
                        if arg not in cmd_args.args["**kwargs"]:
                            cmd_args.args["**kwargs"][arg] = []

                        val_is_extra_kwarg = True

                    else:
                        scope_info = f"in --cmd-- {' '.join(parent_scope)}"
                        Parser._error(
                            f'could not find arg "{arg}" {scope_info}'
                        )

                arg = alias_to_main[arg]

                continue
            
            # capture pos arg / sub command
            if cur_key is None:
                n_pos_args = len(cmd_args.args["*args"])

                if n_pos_args < len(struct["positional"]):
                    pos_data = struct["positional"][n_pos_args]
                    cmd_args.args[pos_data]
                    continue
                
                if struct["allow_extra_args"]:
                    cmd_args.args["*args"].append(arg)
                    continue

                if struct["sub_cmd"] is None:
                    Parser._error("too many positionall args")
                    continue
                
                # handle sub command
                alias_to_sub_command = Parser._create_alias_map(
                    struct["sub_commands"],
                )

                if arg not in alias_to_sub_command.keys():
                    Parser._error(
                        f'unknown sub command "{arg}"',
                    )

                sub_command = alias_to_sub_command[arg]
                
                cmd_args.sub = Parser._coherse_args(
                    raw_args=args[i:],
                    struct=struct["sub_commands"][sub_command]["sub_options"],
                    parent_scope=parent_scope + [sub_command]
                )
                
                break

            captured.append(arg)
        
        if cur_key is not None:
            Parser._error(
                f'too few args passed to "{cur_key}" '
                f"({cur_n_val - len(captured)} more needed)",
            )
        
        
        # check count of pos args


        return cmd_args

    
    """
    @staticmethod
    def _coherse_args(raw_args, struct):
        expanded = Parser._expand_shorthands(raw_args) 

        # replace shorthands and aliases
        alias_to_main = Parser._create_alias_map(struct["kwargs"])

        flag_data = {f: [] for f in struct["kwargs"].keys()}

        pos_args = {"*args": []}

        pos = []

        pos_count = len(struct["positional"])

        capturing_pos = []
        capturing_arg = None
        capturing_count = 0
        for i, arg in enumerate(args):
            if arg.startswith("-"):
                if capturing_count != 0:
                    Parser._error(
                        f'flag defined before "{arg}" compleated'
                        f"({capturing_count} left)",
                    )

                arg_pos = None

                if "=" in arg:
                    arg, *arg_pos = arg.split("=")

                if arg not in alias_to_main:
                    # TODO: add scope info
                    Parser._error(f'could not find arg "{arg}"')

                arg = alias_to_main[arg]
                arg_data = struct["flags"][arg]
                capturing_count = len(arg_data["args"])

                capturing_arg = arg

                if arg_pos is not None:
                    if len(arg_pos) != capturing_count:
                        Parser._error(
                            f'too few args passed to "{arg}"',
                        )

                    flag_data[arg].append(arg_pos)
                
                # if it takes 0 args then we have to instantly terminate it
                if capturing_count == 0:
                    flag_data[capturing_arg].append(capturing_pos)
                    capturing_pos = []
                    capturing_arg = None
                    
                continue

            if capturing_arg is None:
                if len(pos) == pos_count:
                    if not struct["sub_commands"]:
                        if struct["allow_extra_args"]:
                            pos_args["*args"].append(arg)
                            continue

                        Parser._error("too many positionall args")

                    alias_to_sub_command = Parser._create_alias_map(
                        struct["sub_commands"],
                    )

                    if arg not in alias_to_sub_command.keys():
                        Parser._error(
                            f'unknown sub command "{arg}"',
                        )

                    sub_command = alias_to_sub_command[arg]

                    pos_args = Parser._parse_pos_args(pos, struct)

                    parsed_args = {
                        "kwargs": flag_data,
                        "args": pos_args,
                        "sub_cmd": sub_command,
                        "sub": Parser._coherse_args(
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
            Parser._error(
                f'too few args passed to "{capturing_arg}" '
                f"({capturing_count} more needed)",
            )

        pos_args = Parser._parse_pos_args(pos, struct)
        parsed_args = {
            "kwargs": flag_data,
            "args": pos_args,
            "sub_cmd": None,
            "sub": {},
        }

        Parser._validate_allow(parsed_args, struct)

        return parsed_args
    """


    @staticmethod
    def _print_help():  # parsed_arg, struct):
        """Something help

        something <req> <req> [optional] [optional]
            -f  --flag         info
            -o  --other-flag   info

            sub-command        info
            other-sub-command  info

        """
        # TODO: add a help command

    # TODO: add command completion
    


    @staticmethod
    def parse_sys_args(struct):
        return Parser._coherse_args(sys.argv[1:], struct)

@staticmethod
def _mk_flag(
    args: Sequence[Callable[..., bool]] | None | int = 0,
    fmt: Callable[..., Any] = lambda x: x,
    alias: list[str] | None = None,
    info: str = "",
    doc: str = "", 
    require: list[str] | None = None, 
    block: list[str] | None = None, 
    allow_sub: bool = False,
):
    if isinstance(args, int):
        args = [lambda *_: True] * args 

    return {
        "alias": alias or [],
        "args": args or [],
        # function that is run on args before they are given to the program
        "fmt": fmt,
        "info": info,
        "doc": doc or info,
        "allow_sub": allow_sub,
            
        # TODO: implement block and require

        # other flags required when using this one
        "require": require,
        # other flags not allowed if using this flag
        "block": block,

    }


@staticmethod
def opt_part(
    flags: dict | None = None,
    poss: list | None = None,
    sub: dict | None = None,
    allow_extra_args: bool = False,
    allow_extra_kwargs: bool = False,
    req_sub: bool = False,
):
    if sub is not None:
        if allow_extra_args:
            Parser._error(
                "can't have arbitrary amount of args and sub commands",
            )

    if poss is None:
        poss = []

    setting_default = False
    for pos in poss:
        has_default = isinstance(pos, tuple)
        # has_default = "default" in pos.keys()

        if req_sub and has_default:
            Parser._error(
                "can't have default args if the sub command is required",
            )

        if setting_default:
            if not has_default:
                Parser._error(
                    "can't have non default arg after default arg",
                )

        setting_default = setting_default or has_default

    if len(poss) != len(list(set(poss))):
        Parser._error("can have duplicates in positional names")

    if flags is None:
        flags = {}

    for flag in flags.values():
        flag = _mk_flag(**flag)

    if sub is None:
        sub = {}

    for sub_command in sub.values():

        def set_default(key, val):
            if key not in sub_command.keys():
                sub_command[key] = val

        set_default("alias", [])
        set_default("info", "")
        set_default("doc", sub_command["info"])
        set_default("sub_options", opt_part())

    return {
        "flags": flags,
        "positional": poss,
        "sub_commands": sub,
        "allow_extra_args": allow_extra_args,
        "allow_extra_kwargs": allow_extra_kwargs,
        "req_sub": req_sub,  # put into *args
    }


StrDict = dict[str, str | Iterable['StrDict']]

@dataclass 
class CmdArgs:
    raw: StrDict = field(default_factory=dict)
    args: dict[str, Any] = field(default_factory=dict)
    sub_cmd: str | None = None
    sub: Self | None = None


if __name__ == "__main__": 
    def pp(data):
        print(json.dumps(data, indent=4))

    args = Parser.parse_sys_args(
        opt_part(
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
                    "args": 1,
                },
                "--force": {
                    "alias": ["-f"],
                    "info": "force rebuild even if there are no changes",
                }
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
                    "info": "pull from remote and rebuild",
                },
                # TODO: maybe add branches to the workflow with a merge cmd
                # TODO: add a squash command to merge debug commits
            },
        ),
    )
        
    """
    raw: {
        "kwargs": {
            "force": [[]],
            "trace": [[]],
        },
        "args": ["1", "2", "3"],
        "sub_cmd": "pull",
        "sub": {
            "message": "message",
        },
    }

    args: 
        force: true
        trace: true

    sub_cmd: pull
    sub:
        args:
            message: "hello"
        sub_cmd: None 
    """
    pp(args)

import sys
from typing import Any, Self 
import json
from dataclasses import dataclass, field, is_dataclass
import dataclasses


try:
    from .parser_args import check_struct, parse_full_arg, FullArg, Flag
except ImportError:
    from parser_args import check_struct, parse_full_arg, FullArg, Flag


class _Parser:
    @staticmethod
    def _parse_pos_args(pos, struct, scope):
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

            _Parser._error(f'"{pos_name}" is missing it\'s arg', scope)

        return pos_args

    @staticmethod
    def _create_alias_map(struct, scope):
        # replace shorthands and aliases
        alias_to_main = {}
        for name, data in struct.items():
            alias_to_main[name] = name
            for alias in data["alias"]:
                if alias in alias_to_main:
                    # add scope info
                    _Parser._error(
                        f'the alias "{alias}" is used more than once',
                        scope
                    )

                alias_to_main[alias] = name

        return alias_to_main

    @staticmethod
    def _error(msg, scope):
        raise TypeError(f"{msg} ({' '.join(scope)})")
    
    @staticmethod
    def _expand_shorthands(raw_args, scope):
        # replace shorthands

        expanded = []
        # expand -xyz to -x -y -z
        for i, arg in enumerate(raw_args):
            if arg == "--":
                expanded += raw_args[i + 1:]
                break

            if not arg.startswith("--") and arg.startswith("-"):
                if arg[1] == "=":
                    _Parser._error("arg cant be literal =", scope)

                for j, flag in enumerate(arg[1:]):
                    if flag == "=":
                        expanded[-1] += arg[1:][j:]
                        break

                    expanded.append("-" + flag)
            else:
                expanded.append(arg)

        return expanded
    
    @staticmethod
    def _check_can_add_args(
            count: int,
            data: FullArg.Req | Flag.Req,
            too_few: str,
            too_many: str,
            scope: list[str]
    ):
        n_req_args = 0
        for pos_arg in data["args"]:
            if pos_arg["optional"]:
                break
            else:
                n_req_args += 1

        if count < n_req_args:
            _Parser._error(
                f"{too_few} ({n_req_args - count} more needed)",
                scope
            )

        if count > len(data["args"]) and \
            not data["extra_args"]["enable"]:

            _Parser._error(too_many, scope)

    @staticmethod
    def _add_flag_args(
            struct: FullArg.Req, 
            cmd_args: "CmdArgs", 
            flag: str, 
            args: list[str],
            scope: list[str]
    ):
        data = struct["flags"][flag]
        
        if data["count"] == len(cmd_args.flags[flag]):
            _Parser._error(
                f"you can only use the \"{flag}\" flag {data['count']} time(s)",
                scope
            )
        
        _Parser._check_can_add_args(
            len(args), 
            data, 
            f'too few args passed to "{flag}" ',
            f'too many args passed to "{flag}"',
            scope
        )
        
        cmd_args.flags[flag].append(args)

    @staticmethod
    def coherse_args(raw_args, struct: FullArg.Req, scope=None):
        scope = scope or []
        scope.append(struct["name"])
        
        def error(msg):
            _Parser._error(msg, scope)

        args = _Parser._expand_shorthands(raw_args, scope) 

        alias_to_main = _Parser._create_alias_map(struct["flags"], scope)

        cmd_args = CmdArgs(
            flags = {f: [] for f in struct["flags"].keys()},
        )
        
        captured = []
        cur_key = None
        cur_n_val = 0
        
        only_pos = False
        inf_args = False

        def conv_alias_to_name(alias: str):
            if alias not in alias_to_main:
                error(f'could not find arg "{alias}"')

            return alias_to_main[alias]

        i = 0;
        while True:
            if cur_key is not None and \
                cur_n_val - len(captured) == 0 and \
                not inf_args:

                _Parser._add_flag_args(
                    struct, 
                    cmd_args,
                    conv_alias_to_name(cur_key), 
                    captured,
                    scope
                )
                
                captured = []
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
                    if inf_args:
                        error(
                            f'flag "{arg}" defined after the flag "{cur_key}" '
                            'that takes extra_args, you can use ' 
                            f'{cur_key}=arg1=arg2=... to avoid this'
                    )

                    error(
                        f'flag "{arg}" defined before "{cur_key}" compleated'
                        f"({cur_n_val - len(captured)} left)",
                    )

                # handle arg=val1=val2 syntax
                if "=" in arg:
                    arg, *vals = arg.split("=")
                    _Parser._add_flag_args(
                        struct, 
                        cmd_args,
                        conv_alias_to_name(arg), 
                        vals,
                        scope
                    )
                    
                    arg = None
                    continue
                
                cur_key = conv_alias_to_name(arg)
                
                data = struct["flags"][cur_key]
                cur_n_val = len(data["args"])
                inf_args = data["extra_args"]["enable"]

                continue
            
            # capture pos arg / sub command
            if cur_key is None:
                n_pos_args = len(cmd_args.args)

                if n_pos_args < len(struct["args"]):
                    # use this to get data
                    # pos_data = struct["args"][n_pos_args]
                    cmd_args.args.append(arg)
                    continue
                
                if struct["extra_args"]["enable"]:
                    cmd_args.args.append(arg)
                    continue

                if struct["sub_cmd"] is None:
                    error("too many positionall arg(s)")
                    continue
                
                # handle sub command
                alias_to_sub_command = _Parser._create_alias_map(
                    struct["sub_cmd"],
                    scope
                )

                if arg not in alias_to_sub_command.keys():
                    _Parser._error(
                        f'unknown sub command "{arg}"',
                        scope
                    )

                sub_command = alias_to_sub_command[arg]
                
                cmd_args.sub_cmd = sub_command
                cmd_args.sub = _Parser.coherse_args(
                    raw_args=args[i:],
                    struct=struct["sub_cmd"][sub_command]["sub_data"],
                    scope=scope
                )
                
                break

            captured.append(arg)
        
        if cur_key is not None:
            _Parser._add_flag_args(
                struct, 
                cmd_args,
                conv_alias_to_name(cur_key), 
                captured,
                scope
            )

        _Parser._check_can_add_args(
            len(cmd_args.args),
            struct,
            "too few positional args",
            "", # cant happen
            scope
        )

        return cmd_args

    
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
    

class _Validator: 
    """
    check if its following the constraints also computes the 
    tab completions
    """

    @staticmethod
    def validate(args: "CmdArgs", struct: FullArg.Req):
        pass


class Fmt:
    @staticmethod
    def one(args: list[list[str]]):
        return args[0][0] if args else None

    @staticmethod
    def bool(args: list[list[str]]):
        return bool(args)


def parse_sys_args(struct: FullArg.Part):
    full_struct: FullArg.Req = parse_full_arg(struct)
    
    check_struct(full_struct)

    args = _Parser.coherse_args(sys.argv[1:], full_struct)
    
    _Validator.validate(args, full_struct)
    # pp(sys.argv[1:])

    return args


# StrDict = dict[str, str | Iterable['StrDict']]

@dataclass 
class CmdArgs:
    # raw: StrDict = field(default_factory=dict)
    flags: dict[str, Any] = field(default_factory=dict)
    args: list[str] = field(default_factory=list)
    sub_cmd: str | None = None
    sub: Self | None = None


def pp(data):
    def custom_serializer(obj):
        # Check if the object is callable (like a lambda or function)
        if callable(obj):  
            return "<lambda>"
    
        if is_dataclass(obj) and not isinstance(obj, type):
            return dataclasses.asdict(obj)

        raise TypeError(
            f"Object of type {type(obj).__name__} is not"
            "JSON serializable"
        )

    print(json.dumps(data, indent=4, default=custom_serializer))

if __name__ == "__main__": 
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

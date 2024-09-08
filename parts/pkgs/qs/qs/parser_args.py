# i miss typescript

from typing import Callable, Any, Required, Dict, cast
from typing import TypedDict

class Base:
    class Part(TypedDict, total=False):
        info: str
        # defaults to what info is
        doc: str 

    class Req(TypedDict):
        info: str
        # defaults to what info is
        doc: str 


class Arg:
    class Part(Base.Part, total=False):
        # only for the help screen
        name: Required[str]

        # for tab completion
        type: str # "<choice [a, b, c]>"
        
        # can it be skipped
        optional: bool

    class Req(Base.Req):
        name: str
        type: str
        optional: bool


class ExtraArgs:
    class Part(Base.Part, total=False):
        # only for the help screen
        name: Required[str]
        
        type: str 

        enable: bool
        # types: Callable[[int], str]

    class Req(Base.Req):
        name: str
        type: str
        enable: bool 

class Flag:
    class Part(Base.Part, total=False):
        # eg ["-m"]
        alias: list[str]

        # amount of times you can use this flag
        # -1 means no limit 
        count: int

        # a function to format the result 
        fmt: Callable[[list[list[str]] | None], Any] 

        # list of other flags reqired
        block: list[str]

        # list of other flags not allowed
        require: list[str]

        args: list[Arg.Part]

        extra_args: ExtraArgs.Part

    class Req(Base.Req):
        alias: list[str]
        count: int
        fmt: Callable[[list[list[str]] | None], Any] 
        block: list[str]
        require: list[str]
        args: list[Arg.Req]
        extra_args: ExtraArgs.Req


class SubCmd:
    class Part(Base.Part, total=False):
        alias: list[str]

        sub_data: "FullArg.Part"

    class Req(Base.Req):
        alias: list[str]
        sub_data: "FullArg.Req"


class FullArg:
    class Part(TypedDict, total=False):
        name: str

        flags: Dict[str, Flag.Part]

        args: list[Arg.Part]

        extra_args: ExtraArgs.Part

        sub_cmd: Dict[str, SubCmd.Part]

    class Req(TypedDict):
        name: str
        flags: Dict[str, Flag.Req]
        args: list[Arg.Req]
        extra_args: ExtraArgs.Req
        sub_cmd: Dict[str, SubCmd.Req]

# https://github.com/python/typing/issues/1454

id = lambda x: x
test_empty: FullArg.Part = {
    "name": ""
}

test_req: FullArg.Req = {
    "name": "",
    "flags": {
        "test": {
            "info": "",
            "doc": "",
            "alias": [""],
            "count": 1,
            "fmt": id,
            "block": [""],
            "require": [""],
            "args": [],
            "extra_args": {
                "info": "",
                "doc": "",
                "name": "",
                "type": "",
                "enable": False,
            },
        }
    },
    "args": [{
        "info": "",
        "doc": "",
        "name": "",
        "type": "",
        "optional": False,
    }],
    "extra_args": {
        "info": "",
        "doc": "",
        "name": "",
        "type": "",
        "enable": False,
    },
    "sub_cmd": {
        "test": {
            "info": "",
            "doc": "",
            "alias": [""],
            "sub_data": {
                "name": "",
                "sub_cmd": {},
                "flags": {},
                "args": [],
                "extra_args": {
                    "info": "",
                    "doc": "",
                    "name": "",
                    "type": "",
                    "enable": False,
                }
            },
        },
    },
}

test_part: FullArg.Part = {
    "name": "",
    "flags": {
        "test": {
            "info": "",
            "doc": "",
            "alias": [""],
            "count": 1,
            "fmt": id,
            "block": [""],
            "require": [""],
            "args": [],
            "extra_args": {
                "info": "",
                "doc": "",
                "name": "",
                "type": "",
                "enable": False,
            },
        }
    },
    "args": [{
        "info": "",
        "doc": "",
        "name": "",
        "type": "",
        "optional": False,
    }],
    "extra_args": {
        "info": "",
        "doc": "",
        "name": "",
        "type": "",
        "enable": False,
    },
    "sub_cmd": {
        "test": {
            "info": "",
            "doc": "",
            "alias": [""],
            "sub_data": {
                "name": "",
                "sub_cmd": {},
                "flags": {},
                "args": [],
                "extra_args": {
                    "info": "",
                    "doc": "",
                    "name": "",
                    "type": "",
                    "enable": False,
                }
            },
        },
    },
}

assert test_req == test_part

# def parse_opt(data: FullArg.Part) -> FullArg.Req:
#     data["args"]


example: FullArg.Part = {
    "name": "qs",
    "flags": {
        "--trace": {
            "alias": ["-t"],
            "info": "pass --show-trace to nixos-rebuild",
        },

        # >>> qs help
        # cmd 
        #   -m --message: <message> [*<tags>] commit message for rebuild 
        
        # >>> qs help --message
        #  -m --message: <message> [*<tags>]
        # 
        "--message": {
            "alias": ["-m"],
            "info": "commit msg for the rebuild",

            # defaults to the "info"
            # shown on help --message
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

            # -1 means no limit 
            # amount of times you can use this flag
            "count": 1,

            "fmt": lambda x: x,
            # list of other flags required
            "require": [
                "trace"
            ],
            # list of other flags not allowed 
            "block": [
                "profile"
            ],
            # not needed, default behaviour
            # "allow_sub": False,
            "args": [
                {
                    # only for the help screen
                    "name": "message",
                    # for tab completion
                    "type": "<choice [a, b, c]>",

                    "optional": False,
                },
            ],
            "extra_args": {
                # only for the help screen
                "name": "<tags>",
                # "count": -1, # -1 means no limit 
                "info": "some info about the extra args", 
                "type": "<dir>",
            },
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

    # positional args
    "args": [
        {
            # only for the help screen
            "name": "<message>",
            # for tab completion
            "type": "<choice [a, b, c]>",

            "optional": False,
        },
    ],

    "extra_args": {
        "name": "<tags>",
        # "count": -1, # -1 means no limit 
        "info": "some info about the extra args", 
        "type": "<dir>",
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
}


class D:
    def __init__(self, key, default, func=lambda x: x):
        self.key = key
        self.default = default
        self.func = func 


def parse_dict(data, defaults: dict[str, Any]):
    def get_default(key, default):
        if isinstance(default, D): 
            default = default.func(get_default(default.key, default.default))
        
        return data[key] if key in data else default

    for key, default in defaults.items():
        data[key] = get_default(key, default)

    return data


def parse_base(base):
    return parse_dict(base, {
        "info": "",
        "doc": D("info", ""),
    })


def parse_extra_args(extra_args: ExtraArgs.Part) -> ExtraArgs.Req:
    return cast(
        ExtraArgs.Req, 
        parse_dict(
            parse_base(extra_args), 
            {
                "name": "",
                "type": "",
                # enable if name is set
                "enable": D(
                    "name", 
                    False, 
                    lambda x: x if x is False else bool(x)
                )
            }
        )
    )


def parse_args(args: list[Arg.Part]) -> list[Arg.Req]:
    out: list = []
    
    for arg in args:
        out.append(
            parse_dict(
                parse_base(arg), 
                {
                    "name": "",
                    "type": "",
                    "optional": False,
                }
            )
        )

    return cast(list[Arg.Req], out)

import json
def pp(data):
    print(json.dumps(data, indent=4))

def parse_flags(flags: Dict[str, SubCmd.Part]) -> Dict[str, SubCmd.Req]:
    for flag, data in flags.items():
        data = parse_dict(
            parse_base(data), 
            {
                "alias": [],
                "count": 1,
                "fmt": lambda x: x,
                "block": [],
                "require": [],
                "args": [],
                "extra_args": {},
            }
        )

        data["extra_args"] = parse_extra_args(data["extra_args"])
        data["args"] = parse_args(data["args"])
        
        flags[flag] = data

    return cast(Dict[str, SubCmd.Req], flags)


def parse_sub_cmds(sub_cmds: dict[str, SubCmd.Part]) -> dict[str, SubCmd.Req]:
    for sub_cmd, data in sub_cmds.items():
        data = parse_dict(
            parse_base(data), 
            {
                "alias": [],
                "sub_data": {},
            }
        )
        data["sub_data"]["name"] = sub_cmd
        data["sub_data"] = parse_full_arg(data["sub_data"])
        
        sub_cmds[sub_cmd] = data

    return cast(dict[str, SubCmd.Req], sub_cmds)


def parse_full_arg(full_arg: FullArg.Part) -> FullArg.Req:
    out = parse_dict(
        full_arg, 
        {
            "name": "",
            "flags": {},
            "args": [],
            "extra_args": {},
            "sub_cmd": {},
        }
    )

    for key, func in {
        "flags": parse_flags,
        "args": parse_args, 
        "extra_args": parse_extra_args,
        "sub_cmd": parse_sub_cmds,
    }.items():
        out[key] = func(out[key])

    return cast(
        FullArg.Req,
        out
    )


def _error(msg):
    raise TypeError(msg)


def check_struct(full_arg: FullArg.Req, scope=None):
    scope = scope or []

    def scope_error(msg):
        _error(f"{msg} ({' '.join(scope)})")
    
    def check_base(
        data: FullArg.Req | Arg.Req | ExtraArgs.Req,
        name: str,
    ):
        if data["name"] == "":
            scope_error(f"the {name} name \"{data["name"]}\" cant be empty str")
        

    check_base(full_arg, "command")
    
    def check_extra_args(data: ExtraArgs.Req):
        if not data["enable"]:
            return
        
        check_base(data, "extra_arg")

    def check_args(data: list[Arg.Req]):
        last_opt = True

        for i, arg in enumerate(data):
            scope.append(f"[{i}]")
    
            is_opt = arg["optional"]
            if is_opt and not last_opt:
                scope_error("cant have optional arg after required arg")
            last_opt = is_opt

            check_base(arg, "arg")

            scope.pop(-1)

    for flag, data in full_arg["flags"].items():
        if not flag.startswith("-"): 
            scope_error(
                f"the flag \"{flag}\" does not start with -"
            )

        scope.append(flag)

        for x in data["block"]:
            if x not in full_arg["flags"].keys():
                scope_error(f"the blocked \"{x}\" is not in the list of flags")

        for x in data["require"]:
            if x not in full_arg["flags"].keys():
                scope_error(f"the required \"{x}\" is not in the list of flags")
        
        for alias in data["alias"]:
            if not alias.startswith("-"):
                scope_error(f"the alias \"{alias}\" does not start with -")

        if data["count"] < -1:
            scope_error(
                f"the count \"{data["count"]}\" has to be -1 or positive"
            )
        
        check_extra_args(data["extra_args"])
        check_args(data["args"])

        scope.pop(-1)

    check_extra_args(full_arg["extra_args"])
    check_args(full_arg["args"])
    
    for sub_cmd, data in full_arg["sub_cmd"].items():
        scope.append(f"[{sub_cmd}]")
        if sub_cmd.startswith("-"): 
            scope_error(
                f"the sub_cmd \"{sub_cmd}\" cant start with -"
            )
        
        for alias in data["alias"]:
            if alias.startswith("-"): 
                scope_error(
                    f"the alias \"{alias}\" cant start with -"
                )
        
        check_struct(data["sub_data"], scope)

        scope.pop(-1)

    if full_arg["extra_args"]["enable"] and full_arg["sub_cmd"]:
        scope_error("cant have both extra args and sub comands")

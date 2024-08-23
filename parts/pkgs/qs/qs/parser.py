import sys


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

            raise TypeError(f'"{pos_name}" is missing it\'s arg')

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
                    raise TypeError(
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
                    raise TypeError(
                        f'the "{arg}" flag can\'t be used with sub commands',
                    )

    @staticmethod
    def _coherse_args(args, struct):
        expanded = []
        # expand -xyz to -x -y -z
        for arg in args:
            if not arg.startswith("--") and arg.startswith("-"):
                expanded += [f"-{flag}" for flag in arg[1:]]
            else:
                expanded.append(arg)

        # replace shorthands and aliases
        alias_to_main = Parser._create_alias_map(struct["flags"])

        flag_data = {f: [] for f in struct["flags"].keys()}
        pos_args = {"*args": []}

        pos = []

        pos_count = len(struct["positional"])

        capturing_pos = []
        capturing_arg = None
        capturing_count = 0
        for i, arg in enumerate(args):
            if arg.startswith("-"):
                if capturing_count != 0:
                    raise TypeError(
                        f'flag defined before "{arg}" compleated'
                        f"({capturing_count} left)",
                    )

                arg_pos = None

                if "=" in arg:
                    arg, *arg_pos = arg.split("=")

                if arg not in alias_to_main:
                    # add scope info
                    raise TypeError(f'could not find arg "{arg}"')

                arg = alias_to_main[arg]
                arg_data = struct["flags"][arg]
                capturing_count = len(arg_data["args"])

                capturing_arg = arg

                if arg_pos is not None:
                    if len(arg_pos) != capturing_count:
                        raise TypeError(
                            f'too few args passed to "{arg}"',
                        )

                    flag_data[arg].append(arg_pos)

                continue

            if capturing_arg is None:
                if len(pos) == pos_count:
                    if not struct["sub_commands"]:
                        if struct["allow_extra"]:
                            pos_args["*args"].append(arg)
                            continue

                        raise TypeError("too many positionall args")

                    alias_to_sub_command = Parser._create_alias_map(
                        struct["sub_commands"],
                    )

                    if arg not in alias_to_sub_command.keys():
                        raise TypeError(
                            f'unknown sub command "{arg}"',
                        )

                    sub_command = alias_to_sub_command[arg]

                    pos_args = Parser._parse_pos_args(pos, struct)

                    parsed_args = {
                        "flags": flag_data,
                        "pos": pos_args,
                        "sub_command": sub_command,
                        "sub_data": Parser._parse_pos_args(
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
            raise TypeError(
                f'too few args passed to "{capturing_arg}" '
                f"({capturing_count} more needed)",
            )

        pos_args = Parser._parse_pos_args(pos, struct)
        parsed_args = {
            "flags": flag_data,
            "pos": pos_args,
            "sub_command": None,
            "sub_data": {},
        }

        Parser._validate_allow(parsed_args, struct)

        return parsed_args

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
def opt_part(
    flags: dict | None = None,
    poss: list | None = None,
    sub: dict | None = None,
    allow_extra: bool = False,
    req_sub: bool = False,
):
    if sub is not None:
        if allow_extra:
            raise TypeError(
                "can't have arbitrary amount of args and sub commands",
            )

    if poss is None:
        poss = []

    setting_default = False
    for pos in poss:
        has_default = isinstance(pos, tuple)
        # has_default = "default" in pos.keys()

        if req_sub and has_default:
            raise TypeError(
                "can't have default args if the sub command is required",
            )

        if setting_default:
            if not has_default:
                raise TypeError(
                    "can't have non default arg after default arg",
                )

        setting_default = setting_default or has_default

    if len(poss) != len(list(set(poss))):
        raise TypeError("can have duplicates in positional names")

    if flags is None:
        flags = {}

    for flag in flags.values():

        def set_default(key, val):
            if key not in flag.keys():
                flag[key] = val

        set_default("alias", [])
        set_default("args", [])
        if isinstance(num_args := flag["args"], int):
            flag["args"] = [lambda *_: []] * num_args

        set_default("info", "")
        set_default("doc", flag["info"])
        set_default("allow_sub", False)

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
        "allow_extra": allow_extra,  # put into *args
        "req_sub": req_sub,  # put into *args
    }

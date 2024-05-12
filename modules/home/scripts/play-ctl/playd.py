"""
# print all
dbus-send \
  --session \
  --type=method_call \
  --print-reply \
  --dest=org.freedesktop.DBus \
  /org/freedesktop/DBus org.freedesktop.DBus.ListNames


# get all methods
dbus-send \
  --session \
  --type=method_call \
  --print-reply \
  --dest=org.mpris.MediaPlayer2.spotify \
  /org/mpris/MediaPlayer2 org.freedesktop.DBus.Introspectable.Introspect


# send event
dbus-send \
  --session \
  --type=method_call \
  --print-reply \
  --dest=org.mpris.MediaPlayer2.spotify \
  /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause


# adding spotify
{
    "args": [
        ":1.110",
        "",
        ":1.110"
    ],
    "kwargs": {
        "sender_keyword": "org.freedesktop.DBus",
        "destination_keyword": null,
        "path_keyword": "/org/freedesktop/DBus",
        "member_keyword": "NameOwnerChanged",
        "interface_keyword": "org.freedesktop.DBus"
    }
}
{
    "args": [
        ":1.111",
        "",
        ":1.111"
    ],
    "kwargs": {
        "sender_keyword": "org.freedesktop.DBus",
        "destination_keyword": null,
        "path_keyword": "/org/freedesktop/DBus",
        "member_keyword": "NameOwnerChanged",
        "interface_keyword": "org.freedesktop.DBus"
    }
}
{
    "args": [
        "org.mpris.MediaPlayer2.spotify",
        "",
        ":1.110"
    ],
    "kwargs": {
        "sender_keyword": "org.freedesktop.DBus",
        "destination_keyword": null,
        "path_keyword": "/org/freedesktop/DBus",
        "member_keyword": "NameOwnerChanged",
        "interface_keyword": "org.freedesktop.DBus"
    }
}

array [
  string "org.freedesktop.DBus"
  string ":1.2"
  string ":1.7"
  string ":1.8"
  string ":1.9"
  string ":1.10"
  string ":1.11"
  string ":1.12"
  string ":1.13"
  string ":1.14"
  string ":1.15"
  string ":1.16"
  string ":1.17"
  string ":1.18"
  string ":1.20"
  string ":1.22"
  string ":1.34"
  string ":1.108"
  string ":1.110"
  string ":1.111"
  string ":1.112"
  string "ca.desrt.dconf"
  string "org.freedesktop.Notifications"
  string "org.freedesktop.ReserveDevice1.Audio0"
  string "org.freedesktop.ReserveDevice1.Audio1"
  string "org.freedesktop.ReserveDevice1.Audio2"
  string "org.freedesktop.ReserveDevice1.Audio3"
  string "org.freedesktop.impl.portal.PermissionStore"
  string "org.freedesktop.portal.Desktop"
  string "org.freedesktop.portal.Documents"
  string "org.freedesktop.systemd1"
  string "org.mozilla.firefox.dXBpZGFwaQ__"
  string "org.mpris.MediaPlayer2.firefox.instance_1_10"
  string "org.mpris.MediaPlayer2.spotify"
  string "org.pulseaudio.Server"
]



# removing spotify
{
    "args": [
        ":1.111",
        ":1.111",
        ""
    ],
    "kwargs": {
        "sender_keyword": "org.freedesktop.DBus",
        "destination_keyword": null,
        "path_keyword": "/org/freedesktop/DBus",
        "member_keyword": "NameOwnerChanged",
        "interface_keyword": "org.freedesktop.DBus"
    }
}


{
    "args": [
        "org.mpris.MediaPlayer2.spotify",
        ":1.110",
        ""
    ],
    "kwargs": {
        "sender_keyword": "org.freedesktop.DBus",
        "destination_keyword": null,
        "path_keyword": "/org/freedesktop/DBus",
        "member_keyword": "NameOwnerChanged",
        "interface_keyword": "org.freedesktop.DBus"
    }
}


{
    "args": [
        ":1.110",
        ":1.110",
        ""
    ],
    "kwargs": {
        "sender_keyword": "org.freedesktop.DBus",
        "destination_keyword": null,
        "path_keyword": "/org/freedesktop/DBus",
        "member_keyword": "NameOwnerChanged",
        "interface_keyword": "org.freedesktop.DBus"
    }
}

   array [
      string "org.freedesktop.DBus"
      string ":1.2"
      string ":1.7"
      string ":1.8"
      string ":1.9"
      string ":1.10"
      string ":1.11"
      string ":1.12"
      string ":1.13"
      string ":1.14"
      string ":1.15"
      string ":1.16"
      string ":1.17"
      string ":1.18"
      string ":1.20"
      string ":1.22"
      string ":1.34"
      string ":1.108"
      string ":1.113"
      string "ca.desrt.dconf"
      string "org.freedesktop.Notifications"
      string "org.freedesktop.ReserveDevice1.Audio0"
      string "org.freedesktop.ReserveDevice1.Audio1"
      string "org.freedesktop.ReserveDevice1.Audio2"
      string "org.freedesktop.ReserveDevice1.Audio3"
      string "org.freedesktop.impl.portal.PermissionStore"
      string "org.freedesktop.portal.Desktop"
      string "org.freedesktop.portal.Documents"
      string "org.freedesktop.systemd1"
      string "org.mozilla.firefox.dXBpZGFwaQ__"
      string "org.mpris.MediaPlayer2.firefox.instance_1_10"
      string "org.pulseaudio.Server"
   ]


"""

"""
{
    "args": [
        "org.mpris.MediaPlayer2.Player",
        {
            "LoopStatus": "None",
            "Shuffle": 0,
            "Volume": 1.0,
            "CanGoNext": 1,
            "CanGoPrevious": 1,
            "CanPlay": 1,
            "CanPause": 1,
            "Metadata": {
                "mpris:trackid": "/com/spotify/track/5Ds1FRxEq20yhhtVY3JukM",
                "mpris:length": 0,
                "mpris:artUrl": "https://i.scdn.co/image/ab67616d0000b273d99b154d435fb82a295853e2",
                "xesam:album": "Woman of the Hour",
                "xesam:albumArtist": [
                    ""
                ],
                "xesam:artist": [
                    ""
                ],
                "xesam:autoRating": 0.0,
                "xesam:discNumber": 0,
                "xesam:title": "Love Like Mine",
                "xesam:trackNumber": 0,
                "xesam:url": "https://open.spotify.com/track/5Ds1FRxEq20yhhtVY3JukM"
            }
        },
        []
    ],
    "kwargs": {
        "sender_keyword": ":1.127",
        "destination_keyword": null,
        "path_keyword": "/org/mpris/MediaPlayer2",
        "member_keyword": "PropertiesChanged",
        "interface_keyword": "org.freedesktop.DBus.Properties"
    }
}


{
    "args": [
        "org.mpris.MediaPlayer2.Player",
        {
            "CanGoPrevious": 0
        },
        []
    ],
    "kwargs": {
        "sender_keyword": ":1.127",
        "destination_keyword": null,
        "path_keyword": "/org/mpris/MediaPlayer2",
        "member_keyword": "PropertiesChanged",
        "interface_keyword": "org.freedesktop.DBus.Properties"
    }
}


{
    "args": [
        "org.mpris.MediaPlayer2.Player",
        {
            "CanGoPrevious": 1,
            "CanSeek": 1
        },
        []
    ],
    "kwargs": {
        "sender_keyword": ":1.127",
        "destination_keyword": null,
        "path_keyword": "/org/mpris/MediaPlayer2",
        "member_keyword": "PropertiesChanged",
        "interface_keyword": "org.freedesktop.DBus.Properties"
    }
}



# youtube
{
    "args": [
        "org.mpris.MediaPlayer2.Player",
        {
            "Metadata": {
                "mpris:trackid": "/org/mpris/MediaPlayer2/firefox",
                "xesam:title": "If Go And Rust Had A Baby",
                "xesam:album": "",
                "xesam:artist": [
                    "ThePrimeTime"
                ]
            }
        },
        []
    ],
    "kwargs": {
        "sender_keyword": ":1.129",
        "destination_keyword": null,
        "path_keyword": "/org/mpris/MediaPlayer2",
        "member_keyword": "PropertiesChanged",
        "interface_keyword": "org.freedesktop.DBus.Properties"
    }
}


{
    "args": [
        "org.mpris.MediaPlayer2.Player",
        {
            "Metadata": {
                "mpris:trackid": "/org/mpris/MediaPlayer2/firefox",
                "xesam:title": "If Go And Rust Had A Baby",
                "xesam:album": "",
                "xesam:artist": [
                    "ThePrimeTime"
                ],
                "mpris:artUrl": "file:///home/upidapi/.mozilla/firefox/firefox-mpris/38161_0.png"
            }
        },
        []
    ],
    "kwargs": {
        "sender_keyword": ":1.129",
        "destination_keyword": null,
        "path_keyword": "/org/mpris/MediaPlayer2",
        "member_keyword": "PropertiesChanged",
        "interface_keyword": "org.freedesktop.DBus.Properties"
    }
}


{
    "args": [
        "org.mpris.MediaPlayer2.Player",
        {
            "Metadata": {
                "mpris:trackid": "/org/mpris/MediaPlayer2/firefox",
                "xesam:title": "If Go And Rust Had A Baby",
                "xesam:album": "",
                "xesam:artist": [
                    "ThePrimeTime"
                ],
                "mpris:artUrl": "file:///home/upidapi/.mozilla/firefox/firefox-mpris/38161_0.png"
            }
        },
        []
    ],
    "kwargs": {
        "sender_keyword": ":1.129",
        "destination_keyword": null,
        "path_keyword": "/org/mpris/MediaPlayer2",
        "member_keyword": "PropertiesChanged",
        "interface_keyword": "org.freedesktop.DBus.Properties"
    }
}

"""

import json

import dbus
import dbus.service
from dbus.mainloop.glib import DBusGMainLoop
from gi.repository import GLib


def dbus_to_python(data):
    """
    convert dbus data types to python native data types
    """
    if isinstance(data, dbus.String):
        data = str(data)
    elif isinstance(data, dbus.Boolean):
        data = bool(data)
    elif isinstance(data, dbus.Int64):
        data = int(data)
    elif isinstance(data, dbus.Double):
        data = float(data)
    elif isinstance(data, dbus.Array | list | tuple):
        data = [dbus_to_python(value) for value in data]
    elif isinstance(data, dbus.Dictionary | dict):
        new_data = dict()
        for key in data.keys():
            new_data[dbus_to_python(key)] = dbus_to_python(data[key])
        data = new_data
    return data


def nop(*_, **__):
    pass


def p_print(data):
    print(json.dumps(data, indent=4))
    print()
    print()


class FocusHandler:
    def __init__(self, bus):
        self._bus = bus
        self._focus_order: list[str] = []
        self._set_init_focus()
        self._set_life_cycle_handler()
        self._set_interact_handler()

    def get_focus(self):
        if not self._focus_order:
            return None

        focus_name = self._focus_order[-1]

        print(focus_name)
        player = self._bus.get_object(focus_name, "/org/mpris/MediaPlayer2")
        return dbus.Interface(player, dbus_interface="org.mpris.MediaPlayer2.Player")

    def _remove(self, name):
        self._focus_order = [x for x in self._focus_order if x != str(name)]

    def _focus(self, name):
        self._remove(name)
        self._focus_order.append(str(name))

    def _set_init_focus(self):
        players_data = {}

        for service in self._bus.list_names() or ():
            if not str(service).startswith("org.mpris.MediaPlayer2"):
                continue

            player = self._bus.get_object(service, "/org/mpris/MediaPlayer2")

            # https://github.com/alvesvaren/spotify_python/blob/master/spotify/__init__.py
            props = dbus.Interface(
                player, dbus_interface="org.freedesktop.DBus.Properties"
            )
            players_data[str(player.requested_bus_name)] = dbus_to_python(
                props.GetAll("org.mpris.MediaPlayer2.Player")
            )

        for name, data in players_data.items():
            if data["PlaybackStatus"] == "Paused":
                self._focus(name)

        for name, data in players_data.items():
            if data["PlaybackStatus"] == "Playing":
                self._focus(name)

    def _set_life_cycle_handler(self):
        def handle_media_life_cycle(*args, **kwargs):
            name = str(args[0])
            if not name.startswith("org.mpris.MediaPlayer2"):
                return

            # player close
            if args[1] and not args[2]:
                self._remove(name)

            # player open
            elif not args[1] and args[2]:
                self._focus(name)

            else:
                raise TypeError(f"wut ({args, kwargs})")

            print(self._focus_order)

        # handle life cycle
        info_obj = self._bus.get_object("org.freedesktop.DBus", "/org/freedesktop/DBus")
        info_interface = dbus.Interface(info_obj, dbus_interface="org.freedesktop.DBus")
        info_interface.connect_to_signal(
            signal_name=None,
            handler_function=handle_media_life_cycle,
            # ALL THE DATA
            sender_keyword="sender_keyword",
            destination_keyword="destination_keyword",
            interface_keyword="interface_keyword",
            member_keyword="member_keyword",
            path_keyword="path_keyword",
        )

    def _set_interact_handler(self):
        def handle_interact(*args, **kwargs):
            # p_print({"args": args, "kwargs": kwargs})

            if kwargs["member_keyword"] != "PropertiesChanged":
                return

            if "PlaybackStatus" not in args[1]:
                return

            status = args[1]["PlaybackStatus"]
            if status not in ("Playing", "Paused"):
                return

            unique_name = kwargs["sender_keyword"]

            for service in self._bus.list_names() or ():
                if not str(service).startswith("org.mpris.MediaPlayer2"):
                    continue

                test_obj = self._bus.get_object(service, "/org/mpris/MediaPlayer2")
                if test_obj.bus_name == unique_name:
                    name = test_obj.requested_bus_name

                    self._focus(name)

                    print(self._focus_order)
                    return

            raise TypeError(f"could not match {unique_name=}")

        # handle play, pause, etc
        self._bus.add_signal_receiver(
            handler_function=handle_interact,
            path="/org/mpris/MediaPlayer2",
            # ALL THE DATA
            sender_keyword="sender_keyword",
            destination_keyword="destination_keyword",
            interface_keyword="interface_keyword",
            member_keyword="member_keyword",
            path_keyword="path_keyword",
        )


class CtlService(dbus.service.Object):
    def __init__(self, bus, focus_handler):
        bus_name = dbus.service.BusName("org.custom.playctl", bus=bus)
        dbus.service.Object.__init__(self, bus_name, "/org/custom/playctl")
        self._focus_handler = focus_handler

    def _call_action(self, action):
        if focus := self._focus_handler.get_focus():
            getattr(focus, action)()

    @dbus.service.method("org.custom.playctl")
    def toggle(self):
        self._call_action("PlayPause")

    @dbus.service.method("org.custom.playctl")
    def next(self):
        self._call_action("Next")

    @dbus.service.method("org.custom.playctl")
    def prev(self):
        self._call_action("Previous")


def main():
    DBusGMainLoop(set_as_default=True)
    bus = dbus.SessionBus()

    # players = get_players(bus)

    focus_handler = FocusHandler(bus)
    CtlService(bus, focus_handler)

    loop = GLib.MainLoop()
    loop.run()


if __name__ == "__main__":
    main()

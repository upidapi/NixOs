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
"""

import json

import dbus
from dbus.mainloop.glib import DBusGMainLoop
from gi.repository import GLib


def get_players(bus):
    players = []

    for service in bus.list_names() or ():
        if not str(service).startswith("org.mpris.MediaPlayer2"):
            continue

        print(service)
        players.append(bus.get_object(service, "/org/mpris/MediaPlayer2"))

    return players


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
    elif isinstance(data, dbus.Array):
        data = [dbus_to_python(value) for value in data]
    elif isinstance(data, dbus.Dictionary):
        new_data = dict()
        for key in data.keys():
            new_data[dbus_to_python(key)] = dbus_to_python(data[key])
        data = new_data
    return data


def get_player_data(players):
    player_data = {}
    for player in players:
        # https://github.com/alvesvaren/spotify_python/blob/master/spotify/__init__.py

        # x = dbus.Interface(player, dbus_interface="org.mpris.MediaPlayer2.Player")
        props = dbus.Interface(player, dbus_interface="org.freedesktop.DBus.Properties")
        # x.PlayPause()
        player_data[player.requested_bus_name] = dbus_to_python(
            props.GetAll("org.mpris.MediaPlayer2.Player")
        )
        dbus.Interface.connect_to_signal(
            props,
            signal_name="PropertiesChanged",
            handler_function=handler,
        )

    return player_data


def main():
    DBusGMainLoop(set_as_default=True)
    bus = dbus.SessionBus()
    players = get_players(bus)
    player_data = get_player_data(players)

    print(json.dumps(player_data, indent=4))


def handler(*args, **kwargs):
    print(args, kwargs)


if __name__ == "__main__":
    main()

import cmd
import sys

import dbus

# get the session bus
bus = dbus.SessionBus()
# get the object
obj = bus.get_object("org.custom.playctl", "/org/custom/playctl")
# get the interface
interface = dbus.Interface(obj, "org.custom.playctl")

# call the methods and print the results

if not len(sys.argv) == 1:
    print(
        """\
a script to interact with the "focused" media player

usage
    toggle
        toggles the focused player
    next
        plays the next track
    prev
        plays the previous track
"""
    )
    exit()

"""
opt = sys.argv[1]
if opt == "toggle":
    interface.toggle()
elif opt == "next":
    interface.next()
elif opt == "prev":
    interface.prev()
else:
    print("")
"""


"""
a script to interact with the "focused" media player

usage
    toggle
        toggles the focused player
    next
        plays the next track
    prev
        plays the previous track
"""

options = ("toggle", "next", "prev")


class Cmd(cmd.Cmd):
    def do_toggle(self, *_):
        interface.toggle()

    def do_next(self, *_):
        interface.next()

    def do_prev(self, *_):
        interface.prev()


if __name__ == "__main__":
    my_cmd = Cmd()
    my_cmd.cmdloop()

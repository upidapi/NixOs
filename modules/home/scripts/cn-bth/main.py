import bluetooth

DEV_ADDR = "AC:80:0A:2E:81:6A"


def find_dev_addr(dev_name):
    nearby_devices = bluetooth.discover_devices()
    
    for bdaddr in nearby_devices:
        if dev_name == bluetooth.lookup_name(bdaddr):
            return bdaddr
     
    raise TypeError(f"{dev_name=} not found")


# print(bd_addr)

port = 1
sock = bluetooth.BluetoothSocket(bluetooth.RFCOMM)

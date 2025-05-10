## Virsh things
### Make it show up in qemu://system
```bash
virsh define .config/libvirt/qemu/w11.xml
virsh pool-define .config/libvirt/storage/home.xml
```

### Operate on session connection
```bash
virsh -c qemu:///session ...
```

### Start vm in cli
```bash
virsh pool-define .config/libvirt/storage/home.xml
virsh pool-start home
virsh net-start default
virsh start w11

virsh destroy w11
```

### Reset the state of the vms
```bash
rm -rf persist/vms/nvram/*
rm -rf persist/vms/storage/*

virsh pool-destroy home
systemctl --user restart nixvirt
```

## Windows 11 things

### Create a debloated iso
You can download the official iso 
[here](https://www.microsoft.com/en-us/software-download/windows11)

Use `start ms-cxh:localonly` to bypass the account requirement

### Run win-utils
```bash
irm "https://christitus.com/win" | iex
```

Make sure that w11.isoName matches the iso

During first boot you have to click it to start the install



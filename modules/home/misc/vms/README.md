## Debug
Change video to QXL

## Virsh things
the config is located at .config/libvirt/qemu

virt-manager is located at /var/lib/libvirt/


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
Use `ctrl + alt + g` to escape the vm

### Create a debloated iso
You can download the official iso 
[here](https://www.microsoft.com/en-us/software-download/windows11)

selecting eng international reduces initial bloat

Use `start ms-cxh:localonly` to bypass the account requirement
- this no longer works
- this does https://www.youtube.com/watch?v=aEWb1otLVPo

### initial install
Make sure that w11.isoName matches the iso

During first boot you have to click it to start the install

Add the drivers at VIRTOI-WIN/AMD64/W11

### Run win-utils
```bash
irm "https://christitus.com/win" | iex
```

### Run install script
```ps1
Set-ExecutionPolicy Unrestricted -Force # might need this, unsure
irm "https://raw.githubusercontent/upidapi/nixos/main/modules/home/misc/vms/win.ps1" | iex
```

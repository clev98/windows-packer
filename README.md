Windows Packer I developed and maintained for ISTS-2021 and IRSeC-2020. This likely does not run as is anymore, but is a useful reference. 

## Windows
deployment user:
whiteteam

### Important Links and Where They Go
- [VirtIO drivers](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso)
- /windows_files/iso/virtio-win.iso

- [Windows Update Provisioner](https://github.com/rgl/packer-provisioner-windows-update/releases)
- With the packer executable

### Building
Here we create a windows_10 image. All other images for Windows follow a similar procedure. 

- qemu-img create -f raw qemu-drive 20G
- sed -i 's/INSERTPASSWORD/WHATEVERPASSWORDYOUWANT/g' ./windows_10/gui/Autounattend.xml
- sudo packer build -var-file="./windows_10/win10gui.pkrvars.hcl" ./win.pkr.hcl
- mv qemu-drive windows_10_gui.raw
- rm -rf ./builds 

### Building on QEMU
1. Create a qemu-image (Suggested name is `qemu-drive`, and it will be referred to as such) inside the build directory (`qemu-img create -f raw qemu-drive <DISK-SIZE>`)
  1. Ensure that this drive is new or empty - it is untested to install to the same drive twice. In theory, Windows might install. In practice, QEMU might boot from the old drive.
2. Ensure that the qemu-arg `[ "-drive", "file=./qemu-drive,if=virtio,cache=writeback,discard=ignore,format=raw,index=1" ]` is set - this is the drive that Windows will be installed to
3. Ensure that the qemu-arg `[ "-drive", "file=../iso/virtio-win.iso,media=cdrom,index=3" ]` is set - this will map the driver ISO to the qemu device as drive letter E:
4. Ensure that the qemu-arg `["-display", "none"]` is set - the build server will give you a permission denied if it isn't, and you can always view the device using VNC later.
5. Ensure that after the build, you upload qemu-drive - the output Packer places in /builds is a LIE, uploading this image **will not** work.

### Building for Openstack
These images are designed to be used with Openstack. They require "[VirtIO drivers](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso)",
which must be placed in /windows_files/iso/virtio-win.iso. If you are just building for virtualbox, you can ignore this requirement.

### Custom Provisioner
Windows builds may require "[Windows Update Provisioner](https://github.com/rgl/packer-provisioner-windows-update/releases)" to be installed. Just drop it in the same location the packer executable is in.

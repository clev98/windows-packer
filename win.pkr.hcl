packer {
  required_plugins {
    windows-update = {
      version = "0.14.0"
      source = "github.com/rgl/windows-update"
    }
  }
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "qemu" "windows" {
  accelerator      = "kvm"
  boot_wait        = "30s"
  communicator     = "winrm"
  cpus             = var.cpus
  disk_interface   = "virtio"
  disk_size        = var.str_disk_size
  floppy_files     = local.floppies
  format           = "raw"
  headless         = false
  http_directory   = var.windows_files
  iso_url          = var.iso_url
  iso_checksum     = var.iso_checksum
  memory           = var.memory
  net_device       = "virtio-net"
  output_directory = local.output_directory
  #shutdown_command = "a:/windows-execute-sysprep.bat"
  shutdown_timeout = "1h"
  vm_name          = var.vm_name
  winrm_password   = var.winrm_password
  winrm_timeout    = "1h"
  winrm_username   = var.winrm_username
  qemuargs         = [["-drive",
                       "file=./qemu-drive,if=virtio,cache=writeback,discard=ignore,format=raw,index=1"],
                      ["-drive", "file=${var.windows_files}iso/virtio-win.iso,media=cdrom,index=3"],
                      ["-drive", "file=/root/.cache/packer/5b96cd49e31c1f85416ec3198dde6c24a2792ab4.iso,media=cdrom,index=2"],
                      ["-display", "none"]
                     ]
}

build {
  sources = ["source.qemu.windows"]

  provisioner "windows-restart" {
    restart_timeout = "${var.restart_timeout}"
  }

  provisioner "powershell" {
    script = "${var.windows_files}windows-disable-hibernation.ps1"
  }

  provisioner "windows-update" {
    search_criteria = var.search_criteria
    update_limit = var.update_limit
    filters = var.update_filters
  }

  provisioner "powershell" {
    environment_vars = ["MACHINE_NAME=${var.vm_name}"]
    script           = "${var.windows_files}windows-get-unattend.ps1"
  }

  provisioner "windows-shell" {
    execute_command = "{{ .Vars }} cmd /c \"{{ .Path }}\""
    remote_path     = "/tmp/script.bat"
    scripts         = local.scripts
  }
}

variables {
  memory          = 8192
  cpus            = 4
  str_disk_size   = "20G"
  iso_url         = ""
  iso_checksum    = ""
  autounattend    = ""
  winrm_username  = "whiteteam"
  winrm_password  = "Butter!ck4379"
  windows_files   = "./windows_files/"
  vm_name         = ""
  search_criteria = "AutoSelectOnWebSites=1 and IsInstalled=0"
  update_limit    = 1000
  update_filters  = ["exclude:$_.Title -like '*Language*'", "include:$true"]
  restart_timeout = "1h"
}

locals {
  floppies = [
    "${var.autounattend}",
    "${var.windows_files}windows-disable-winrm.ps1",
    "${var.windows_files}windows-enable-winrm.ps1",
    "${var.windows_files}windows-configure-ansible_winrm.ps1",
    "${var.windows_files}windows-execute-sysprep.bat",
  ]
  ps_scripts = [
    "${var.windows_files}windows-disable-defender.ps1",
    "${var.windows_files}windows-optimize-powershell.ps1",
    "${var.windows_files}windows-allow-public_winrm.ps1",
    "${var.windows_files}windows-allow-winrm_outside_subnet.ps1",
    "${var.windows_files}windows-install-cloudbase.ps1",
    "${var.windows_files}windows-disable-hibernation.ps1",
    "${var.windows_files}windows-install-chocolatey.ps1",
    "${var.windows_files}windows-enable-high_performance.ps1",
    "${var.windows_files}windows-debloat-windows.ps1",
  ]
  bat_scripts = [
    "${var.windows_files}windows-install-dotnet452.bat", 
    "${var.windows_files}windows-compile-dotnet_assemblies.bat", 
    "${var.windows_files}windows-set-winrm_service_auto.bat", 
    "${var.windows_files}windows-enable-rdp.bat", 
    "${var.windows_files}windows-enable-uac.bat", 
    "${var.windows_files}windows-compact-disk.bat"
  ]
  output_directory = "./builds/${var.vm_name}"
}

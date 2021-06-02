$script = <<-SCRIPT
#!/bin/bash
set -e


curl -s "https://www.archlinux.org/mirrorlist/?country=US&protocol=https&use_mirror_status=on" | sed -e 's/^#Server/Server/' -e '/^#/d' > /tmp/mirrorlist

cp -v /tmp/mirrorlist /etc/pacman.d

# Update the package db
pacman --noconfirm -Syy

# Update the package signature keys
# pacman-key --refresh-keys
pacman-key --init
pacman-key --populate archlinux
pacman --noconfirm -S archlinux-keyring

# Install for the `rankmirrors` command
pacman --noconfirm -S pacman-contrib

# Use the top 5 fastest mirrors
rankmirrors -n 5 /tmp/mirrorlist > /etc/pacman.d/mirrorlist

# Update the system
pacman --noconfirm -Syu
pacman --noconfirm -S base-devel dosfstools debootstrap squashfs-tools squashfuse

# Install mkosi
# PKGBUILD from the AUR: https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=mkosi
cat <<EOF > mkosi.pkgbuild
pkgname=mkosi
pkgver=5
pkgrel=1
pkgdesc='Build Legacy-Free OS Images'
arch=('any')
url='https://github.com/systemd/mkosi'
license=('LGPL2.1')
depends=('python')
makedepends=('python-setuptools')
optdepends=('dnf: build Fedora or Mageia images'
            'debootstrap: build Debian or Ubuntu images'
            'debian-archive-keyring: build Debian images'
            'ubuntu-keyring: build Ubuntu images'
            'arch-install-scripts: build Arch images'
            'zypper-git: build openSUSE images'
            'gnupg: sign images'
            'xz: compress images with xz'
            'btrfs-progs: raw_btrfs and subvolume output formats'
            'dosfstools: build bootable images'
            'squashfs-tools: raw_squashfs output format'
            'tar: tar output format'
            'cryptsetup: add dm-verity partitions'
            'edk2-ovmf: run bootable images in QEMU'
            'qemu: run bootable images in QEMU'
            'sbsigntools: sign EFI binaries for UEFI SecureBoot')
source=("https://github.com/systemd/mkosi/archive/v\\$pkgver.tar.gz")
sha256sums=('88e995dac8dfc665d2e741bd24f94c5aeb7f11fc79f2cd8560001f68a86a4bda')

package() {
  cd "mkosi-\\$pkgver"
  python setup.py install --root="\\$pkgdir"
}
EOF
sudo -u vagrant makepkg --noconfirm -icsp mkosi.pkgbuild

# This patch is necessary because the current version of debootstrap is broken when used with --verbose
sed -i '1615d' /usr/bin/mkosi

systemctl enable systemd-networkd
SCRIPT

Vagrant.configure("2") do |config|
  config.vm.box = "archlinux/archlinux"
  config.vm.provision "shell", inline: $script
end

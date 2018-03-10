sudo zypper --non-interactive --gpg-auto-import-keys addrepo -c -f -r http://download.opensuse.org/repositories/Virtualization:/Appliances:/Builder/openSUSE_Leap_42.3/Virtualization:Appliances:Builder.repo^C
sudo zypper --non-interactive --gpg-auto-import-keys install "python3-kiwi>=9.11" man jq yum git command-not-found syslinux jing createrepo lsof xfsprogs gfxboot
mkdir works/source/ -p
cd works/source/
git clone https://github.com/journeymidnight/kiwi-descriptions.git
cd kiwi-descriptions
mkdir -p  $HOME/works/software/kiwi
APPLIANCE=suse/x86_64/suse-leap-42.3-JeOS/
APPLIANCE=centos/x86_64/centos-07.0-JeOS/
sudo kiwi-ng --debug --color-output --type oem system build --target-dir $HOME/works/software/kiwi --description $APPLIANCE
sudo rm -rf ~/works/software/kiwi/build/image-root


quickstart:
1. use rufus to create ntfs bootable flashdisk that support both legacy mbr and uefi
2. copy unattend.xml to your just created flashdisk
3. recursively copy Setup folder into \sources\\$OEM$\\$$\
4. copy all installer to \sources\\$OEM$\\$$\Setup\Files
5. edit SetupComplete.cmd accordingly
6. boot from flashdisk and start the installation

tested using Win10_1709_English_x64.iso

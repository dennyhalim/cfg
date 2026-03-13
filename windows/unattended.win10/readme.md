quickstart:
1. use rufus to create ntfs bootable flashdisk that support both legacy mbr and uefi
2. copy unattend.xml to your just created flashdisk
3. recursively copy Setup folder into \sources\\$OEM$\\$$\
4. copy all installer to \sources\\$OEM$\\$$\Setup\Files
5. edit SetupComplete.cmd accordingly
6. boot from flashdisk and start the installation

tested using Win7_Pro_SP1_English_COEM_x64.iso and Win10_1709_English_x64.iso

refs
https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-vista/cc766228(v=ws.10)


nice tools to add:
- https://www.bleepingcomputer.com/download/windows/security-utilities/
- https://filehippo.com/download_adwcleaner/74895/ #latest adwcleaner version run on xp

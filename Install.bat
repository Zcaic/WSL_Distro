SET DISTRO=Arch

SET alpineiso=alpine.tar.gz
SET archiso=Archlinux_WSL_root.tar

@echo off
echo !NEED: Microsoft Windows [10.0.18362+]
echo ======================
echo Your version:
ver
echo ======================

@echo off
:: Get Administrator Rights
set _Args=%*
if "%~1" NEQ "" (
  set _Args=%_Args:"=%
)
fltmc 1>nul 2>nul || (
  cd /d "%~dp0"
  cmd /u /c echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~dp0"" && ""%~dpnx0"" ""%_Args%""", "", "runas", 1 > "%temp%\GetAdmin.vbs"
  "%temp%\GetAdmin.vbs"
  del /f /q "%temp%\GetAdmin.vbs" 1>nul 2>nul
  exit
)

cd /d %~sdp0
echo %~sdp0
:: wsl_update_x64.msi /q
wsl --unregister %DISTRO%
wsl --unregister alpine-makerootfs
:: wsl --set-default-version 1
echo Makeing rootfs...
::del /F /S /Q Archlinux_WSL_root.tar




if not exist %archiso% (
	curl https://mirrors.tuna.tsinghua.edu.cn/archlinux/iso/latest/archlinux-bootstrap-x86_64.tar.gz --output arch_O.tar.gz
	if not exist %alpineiso% (
		curl https://mirrors.ustc.edu.cn/alpine/v3.16/releases/x86_64/alpine-minirootfs-3.16.1-x86_64.tar.gz --output %alpineiso%
	)
	rmdir /s/q alpine-makerootfs
	mkdir alpine-makerootfs
	wsl --import alpine-makerootfs alpine-makerootfs %alpineiso%
	wsl -d alpine-makerootfs -e uname -a
	
	wsl -d alpine-makerootfs -e mv arch_O.tar.gz /tmp/
	wsl -d alpine-makerootfs -e tar -xzf /tmp/arch_O.tar.gz -C /tmp/
	wsl -d alpine-makerootfs -e tar -cf /tmp/Archlinux_WSL_root.tar . -C /tmp/root.x86_64
	wsl -d alpine-makerootfs -e mv /tmp/Archlinux_WSL_root.tar %archiso%
)
::wsl -d alpine-makerootfs -e cp tar_conv.txt /tmp/tar_conv
::wsl -d alpine-makerootfs -e sh -c "sed -i $'s/\r$//' /tmp/tar_conv"
::wsl -d alpine-makerootfs -e sh /tmp/tar_conv

wsl --unregister alpine-makerootfs
rmdir /s/q alpine-makerootfs
::del /F /S /Q alpine.tar.gz
wsl --import %DISTRO% . %archiso%
::del /F /S /Q Archlinux_WSL_root.tar
wsl --set-version %DISTRO% 1
wsl -d %DISTRO% -e uname -a



::wsl -d Archlinux -e cp pacman_init.txt /tmp/pacman_init
::wsl -d Archlinux -e sh -c "sed -i $'s/\r$//' /tmp/pacman_init"
::wsl -d Archlinux -e sh /tmp/pacman_init
:: wslconfig /setdefault Archlinux

wsl -d %DISTRO% -e sed -i -e "s/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/" /etc/locale.gen 
wsl -d %DISTRO% -e sh -c "sed -i -e 's/^#zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen && locale-gen"
wsl -d %DISTRO% -e sh -c "echo 'LANG=en_US.UTF-8' > /etc/locale.conf && locale"

wsl -d %DISTRO% -e sh -c "echo 'Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch' >> /etc/pacman.d/mirrorlist"
wsl -d %DISTRO% -e sh -c "echo 'Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch' >> /etc/pacman.d/mirrorlist"

wsl -d %DISTRO% -e sed -i -e "s/^#CleanMethod = KeepInstalled/CleanMethod = KeepCurrent/" /etc/pacman.conf

wsl -d %DISTRO% -e pacman-key --init
wsl -d %DISTRO% -e pacman-key --populate
wsl -d %DISTRO% -e pacman -Sy archlinux-keyring --noconfirm

wsl -d %DISTRO% -e pacman -S --needed vim sudo wget git --noconfirm


echo # Finsh
echo Install Finshed. Type "wsl" to use.
::wsl -d Archlinux

[`English`](README_en.md)
[简体中文](README.md)

### Description

A collection of software packages for easy use. Some software packages have their cache moved to other locations. Continuously updated...

### Software Architecture Description

-- x64 (Mainly organized)
-- x86
-- arm64

### Usage Instructions

-- First, install Scoop

```powershell
$psversiontable.psversion.major #  >= 3
set-executionpolicy remotesigned -scope currentuser
[environment]::setEnvironmentVariable('SCOOP', 'D:\Applications\Scoop', 'User')
$env:SCOOP='D:\Applications\Scoop' # Set the Scoop installation directory
[environment]::setEnvironmentVariable('SCOOP_GLOBAL','F:\GlobalScoopApps','Machine')
$env:SCOOP_GLOBAL='F:\GlobalScoopApps' # Set the global Scoop installation directory
iex (new-object net.webclient).downloadstring('https://get.scoop.sh')
scoop install aria2
scoop install git
scoop bucket add extras
scoop bucket add java
scoop bucket add versions
scoop bucket add apps
scoop bucket add nonportable
scoop bucket add scoop-qzxst https://github.com/qzxst/scoop-qzxst.git
...# global software packages
scoop install --global <package>
...# global software packages
``

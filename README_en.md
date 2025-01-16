[<span style="color: red;">English</span>](README.md)
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
scoop bucket add scoop-bucket
...# Other buckets
scoop install --global <package>
...# Other software packages
```

### Contributing

1. Fork this repository

2. Create a new branch named Feat_xxx

3. Commit your changes

4. Create a Pull Request

### Copyright Notice

> All content in this repository is collected and organized from the internet. The copyright belongs to the original authors. If there are any copyright issues, please contact me for removal.
> All content in this repository is for learning and communication purposes only and shall not be used for commercial purposes.
> This repository does not involve any commercial interests. If there are any commercial uses, please contact me for removal.
> This repository does not involve any political stance. If there are any political issues, please contact me for removal.
> This repository does not involve any personal privacy. If there are any privacy concerns, please contact me for removal.
> This repository does not involve any illegal or disciplinary violations. If there are any such issues, please contact me for removal.
> This repository does not involve any infringement. If there are any infringement issues, please contact me for removal.

[English](README_en.md)
[`简体中文`](README.md)
### 描述

搜集整理的软件包，方便使用，有些软件尽量将缓存移动到其他位置，持续更新中...

### 软件架构描述

-- x64 (主要整理)
-- x86
-- arm64

### 使用说明
-- 先安装scoop
```powershell
$psversiontable.psversion.major #  >= 3
set-executionpolicy remotesigned -scope currentuser
[environment]::setEnvironmentVariable('SCOOP', 'D:\Applications\Scoop', 'User')
$env:SCOOP='D:\Applications\Scoop' # 设置scoop安装目录
[environment]::setEnvironmentVariable('SCOOP_GLOBAL','F:\GlobalScoopApps','Machine')
$env:SCOOP_GLOBAL='F:\GlobalScoopApps' # 设置scoop全局安装目录
iex (new-object net.webclient).downloadstring('https://get.scoop.sh')
scoop install aria2
scoop install git
scoop bucket add extras
scoop bucket add java
scoop bucket add versions
scoop bucket add apps
scoop bucket add nonportable
scoop bucket add scoop-qzxst https://github.com/qzxst/scoop-qzxst.git
...# 全局安装
scoop install --global <package>
...# 全局安装
```

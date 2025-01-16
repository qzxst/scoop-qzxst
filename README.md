[English](README_en.md)
[<span style="color: red;">简体中文</span>](README.md)
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
scoop bucket add scoop-bucket
...# 其他bucket
scoop install --global <package>
...# 其他软件包
```

### 参与贡献
1. Fork 本仓库
2. 新建 Feat_xxx 分支
3. 提交代码
4. 新建 Pull Request

### 版权声明
> 本仓库所有内容均来自互联网搜集整理，版权归原作者所有，如有版权问题请联系我删除。
> 本仓库所有内容仅供学习交流使用，不得用于商业用途。
> 本仓库所有内容均不涉及任何商业利益，如有商业用途请联系我删除。
> 本仓库所有内容均不涉及任何政治立场，如有政治立场请联系我删除。
> 本仓库所有内容均不涉及任何个人隐私，如有个人隐私请联系我删除。
> 本仓库所有内容均不涉及任何违法乱纪行为，如有违法乱纪行为请联系我删除。
> 本仓库所有内容均不涉及任何侵权行为，如有侵权行为请联系我删除。


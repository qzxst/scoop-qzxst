<#
.SYNOPSIS
    Update manifest, add to README.md.
.DESCRIPTION
    Use as vscode task:
        1. Open manifest in editor
        1. Be surprised
        1. Press CTRL+SHIFT+B or CTRL+F9 (IntelliJ)
.PARAMETER Manifest
    Full Path to manifest. (vscode ${file})
.PARAMETER MdDesc
    Full Path to md file. (vscode ${file})
.PARAMETER Force
    Force parameter will be passed to checkver.
.EXAMPLE
    auto-md.ps1 -Manifest "5eplay.json" -CN "README.md"
.NOTES
    Author: @lrqzxst
#>

param(
    [Alias('App')]
    [String[]] $Manifest,
    [Alias('Lang')]
    [Switch] $EN,
    [Switch] $CN,
    [Alias('ForceUpdate')]
    [Switch] $Force,
    [Switch] $Hashes
)

begin {
    function ConvertTo-Markdown {
        param (
            # JSON 数据（字符串或文件路径）
            [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
            [string]$JsonData,

            # 可选：Markdown 表格的标题
            [Parameter(Mandatory = $false)]
            [string]$Header,

            # 可选：是否将 JSON 数据作为文件路径处理
            [Parameter(Mandatory = $false)]
            [switch]$FromFile
        )
        if ($FromFile) {
            if (-not (Test-Path $JsonData)) {
                throw "文件路径 '$JsonData' 不存在。"
            }
            $JsonData = Get-Content -Path $JsonData -Raw
        }

        # 将 JSON 字符串转换为 PowerShell 对象
        try {
            $data = $JsonData | ConvertFrom-Json
        } catch {
            throw "提供的 JSON 数据无效：$_"
        }
        if ($data -is [System.Collections.IEnumerable] -and $data -isnot [string]) {
            # 获取对象的属性名作为表头
            $headers = $data[0].PSObject.Properties.Name

            # 创建 Markdown 表格
            $markdown = @()

            # 添加可选的标题
            if ($Header) {
                $markdown += "## $Header`n"
            }

            # 添加表头
            $markdown += "| " + ($headers -join " | ") + " |`n"
            $markdown += "| " + ($headers.ForEach({ "---" }) -join " | ") + " |`n"

            # 添加每一行数据
            foreach ($item in $data) {
                $row = $headers | ForEach-Object { $item.$_ }
                $markdown += "| " + ($row -join " | ") + " |`n"
            }
        } else {
            $markdown = @()
            # 添加可选的标题
            if ($Header) {
                $markdown += "## $Header`n"
            }
            $markdown += "`markdown`n"
            foreach ($property in $data.PSObject.Properties) {
                $markdown += "- **$($property.Name)**: $($property.Value)`n"
            }
            $markdown += ""
        }
        return $markdown -join "`n"
    }

    function Filter-JsonFields {
        param (
            # JSON 数据（字符串或文件路径）
            [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
            [string]$JsonData,

            # 需要保留的字段（逗号分隔的字段名）
            [Parameter(Mandatory = $true)]
            [string[]]$FieldsToKeep,

            # 可选：是否将 JSON 数据作为文件路径处理
            [Parameter(Mandatory = $false)]
            [switch]$FromFile
        )

        # 如果 FromFile 参数为 true，则从文件读取 JSON 数据
        if ($FromFile) {
            if (-not (Test-Path $JsonData)) {
                throw "文件路径 '$JsonData' 不存在。"
            }
            $JsonData = Get-Content -Path $JsonData -Raw
        }

        # 将 JSON 字符串转换为 PowerShell 对象
        try {
            $data = $JsonData | ConvertFrom-Json
        } catch {
            throw "提供的 JSON 数据无效：$_"
        }

        # 过滤字段
        if ($data -is [System.Collections.IEnumerable] -and $data -isnot [string]) {
            # 如果是数组，遍历每个对象
            $filteredData = $data | ForEach-Object {
                $obj = $_
                $filteredObj = @{}
                foreach ($field in $FieldsToKeep) {
                    if ($obj.PSObject.Properties.Name -contains $field) {
                        $filteredObj[$field] = $obj.$field
                    }
                }
                [PSCustomObject]$filteredObj
            }
        } else {
            # 如果是单个对象
            $filteredObj = @{}
            foreach ($field in $FieldsToKeep) {
                if ($data.PSObject.Properties.Name -contains $field) {
                    $filteredObj[$field] = $data.$field
                }
            }
            $filteredData = [PSCustomObject]$filteredObj
        }

        # 将过滤后的对象转换回 JSON
        $filteredJson = $filteredData | ConvertTo-Json -Depth 10
        return $filteredJson
    }

    function Convert-JsonToMarkdown {
        param (
            [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
            [string]$JsonData,

            [Parameter(Mandatory = $false)]
            [string]$Header,

            [Parameter(Mandatory = $false)]
            [switch]$FromFile
        )

        if ($FromFile) {
            if (-not (Test-Path $JsonData)) {
                throw "文件路径 '$JsonData' 不存在。"
            }
            $JsonData = Get-Content -Path $JsonData -Raw
        }

        try {
            $data = $JsonData | ConvertFrom-Json
        } catch {
            throw "提供的 JSON 数据无效：$_"
        }

        # 初始化 Markdown 内容
        $markdown = @()

        # 添加自定义标题
        if ($Header) {
            $markdown += "# $Header`n"
        }

        # 递归处理嵌套对象
        function Convert-ObjectToMarkdown {
            param (
                $InputObject,
                [int]$IndentLevel = 0
            )

            foreach ($property in $InputObject.PSObject.Properties) {
                $fieldName = $property.Name
                $fieldValue = $property.Value

                # 处理 URL 字段
                if ($fieldValue -match '^https?://') {
                    $fieldValue = "[$fieldValue]($fieldValue)"
                }

                # 处理嵌套对象
                if ($fieldValue -is [PSCustomObject]) {
                    $markdown += ("  " * $IndentLevel) + "- **$fieldName**:`n"
                    $markdown += Convert-ObjectToMarkdown -InputObject $fieldValue -IndentLevel ($IndentLevel + 1)
                } else {
                    # 普通字段
                    $markdown += ("  " * $IndentLevel) + "- **$fieldName**: $fieldValue`n"
                }
            }
            return $markdown
        }

        $markdown += Convert-ObjectToMarkdown -InputObject $data
        return $markdown -join "`n"
    }

    if (-not $Manifest) {
        Write-Host "Manifest is required."
        exit 1
    }
    Write-Host "Begin." -ForegroundColor Green
    if ($Force) { $arg = '-ForceUpdate' } else { $arg = '-Update' }
}
process {

    # if (-not $(scoop cache show php81)) {
    #     Write-Host $(scoop cache show) -ForegroundColor Green
    # }
    # Write-Host $(scoop cache show) -ForegroundColor Green
    # 接收返回的参数 scoop cache show “lm-studio” | Out-File -FilePath "cache.txt"
    # exit;

    if ($Manifest -eq "*" ) {
        # 获取bucket下的所有json
        $Manifest = Get-ChildItem -Path "bucket" -Filter "*.json" | ForEach-Object { $_.FullName }
    }

    foreach ($man in $Manifest) {
        $man = Resolve-Path $man
        $folder = Split-Path $man -Parent
        $file = Split-Path $man -Leaf
        Write-Host "Manifest: $man" -ForegroundColor Green
        Write-Host "Folder: $folder" -ForegroundColor Green
        Write-Host "File: $file" -ForegroundColor Green

        $cmd = 'checkver'
        # 打印noExt $cmd $arg
        $noExt = ($file -split '\.')[0]
        Write-Host "noExt: $noExt" -ForegroundColor Green
        Write-Host "cmd: $cmd" -ForegroundColor Green
        Write-Host "arg: $arg" -ForegroundColor Green

        if (-not (Test-Path "$PSScriptRoot\$cmd.ps1")) {
            Write-Host "Script not found: $PSScriptRoot\$cmd.ps1" -ForegroundColor Red
        }
        Invoke-Expression -Command "$PSScriptRoot\$cmd.ps1 '$noExt' $arg"
        # 从缓存中查找如果没有下载则不更新
        if (-not $(scoop cache show $noExt) -and $Force -eq $false) {
            continue
        }
        [psobject] $manifest = Get-Content -Path $man -Raw
        # Write-Host "manifest: $manifest" -ForegroundColor Green
        $filename = [System.IO.Path]::GetFileNameWithoutExtension($file)
        $mdDesc = "md/$filename.md"
        # # 将json文件的内容整理为md格式
        # homepage description version url license hash
        $manifest = Filter-JsonFields -JsonData $manifest -FieldsToKeep "homepage", "description", "version", "url", "license", "hash"

        $mdContent = Convert-JsonToMarkdown -JsonData $manifest -Header $filename
        # $mdContent = ConvertTo-Markdown -JsonData $manifest -Header  $filename
        # Write-Host $mdContent -ForegroundColor Red
        # 将md内容写入md文件
        $mdContent | Out-File -FilePath $mdDesc
        #将md文件上传到github
        git add $mdDesc
        git commit --message "update $mdDesc" --only "*$file"
        git push
        # 删除cache中的文件
        scoop cache rm $noExt
        # $mdContent | Out-File -FilePath $mdDesc -Append
    }
}
end {
    Write-Host "Done." -ForegroundColor Green

}



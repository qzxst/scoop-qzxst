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
        $markdown += "````markdown`n"
        foreach ($property in $data.PSObject.Properties) {
            $markdown += "- **$($property.Name)**: $($property.Value)`n"
        }
        $markdown += "````"
    }
    return $markdown -join "`n"
}
# 导出函数
Export-ModuleMember -Function ConvertTo-Markdown

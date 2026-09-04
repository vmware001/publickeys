# 把公钥直接粘贴到下面单引号之间，每行一条；后续新增直接加行即可
$paste_here = 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJl7jqc1dUeXAtjjYt99GmFGDxOS+muwOSru1qw21H/d vm001@admin
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIObzPFegQQDjF/i9nyBJgFKPkNK3jKedyBBKLKsUt1ol mac-mini
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO5AzNlxdjEH/gKLuHncuHG16ALel06xm90ZGU8Uhdhf lenovo
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB8R+/1Ypa+hNmxhJ6GnRLNRltFQpG1fjVckaUMBUXft u0_a439@localhost
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIy+t4sZkh5rf4DLhgpEbKHdKho1ldQNXwdrm9yue+8 u0_a330@localhost'

$sshDir = Join-Path $env:USERPROFILE ".ssh"
$authKeys = Join-Path $sshDir "authorized_keys"

if (-not (Test-Path $sshDir)) {
    New-Item -ItemType Directory -Path $sshDir -Force | Out-Null
}

if (-not (Test-Path $authKeys)) {
    New-Item -ItemType File -Path $authKeys -Force | Out-Null
}

$existingLines = @(Get-Content -Path $authKeys -ErrorAction SilentlyContinue | ForEach-Object { $_.Trim() })

$added = 0
$skipped = 0

foreach ($line in ($paste_here -split "`r?`n")) {
    $key = $line.Trim()
    if ([string]::IsNullOrWhiteSpace($key)) { continue }
    if ($key.StartsWith("#")) { continue }

    $label = ($key -split ' ')[0..1] -join ' '

    if ($existingLines -contains $key) {
        Write-Host "已存在，跳过: $label"
        $skipped++
    } else {
        Add-Content -Path $authKeys -Value $key
        Write-Host "已添加: $label"
        $added++
    }
}

Write-Host "完成。新增 $added 条，跳过 $skipped 条。"

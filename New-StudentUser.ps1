#Requires -RunAsAdministrator

$StudentName = "Student"
$LocalUser = New-Object System.Security.Principal.NTAccount("$env:COMPUTERNAME\$StudentName")

if (Get-LocalUser -Name $StudentName -ErrorAction SilentlyContinue) {
    Write-Host "  [~] User '$StudentName' already exists, skipping creation." -ForegroundColor Yellow
} else {
    net user $StudentName "" /add /passwordchg:no
    net localgroup "Users" $StudentName /add 2>$null
    Write-Host "  [+] User '$StudentName' created." -ForegroundColor Green
}

$StudentProfile = "C:\Users\$StudentName"
$DesktopPath = "$StudentProfile\Desktop"
New-Item -ItemType Directory -Path $DesktopPath -Force | Out-Null

try {
    $Acl = Get-Acl $DesktopPath
    $FullAccess = New-Object System.Security.AccessControl.FileSystemAccessRule(
        $LocalUser, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
    $Acl.SetAccessRule($FullAccess)
    Set-Acl -Path $DesktopPath -AclObject $Acl -ErrorAction Stop
    Write-Host "  [+] Full write access granted on Desktop." -ForegroundColor Green
} catch {
    Write-Host "  [!] Could not set Desktop permissions: $_" -ForegroundColor Red
}

$RestrictedPaths = @(
    "C:\Program Files",
    "C:\Program Files (x86)",
    "$StudentProfile\Documents",
    "$StudentProfile\Downloads",
    "$StudentProfile\Pictures",
    "$StudentProfile\Videos",
    "$StudentProfile\Music"
)

foreach ($Path in $RestrictedPaths) {
    if (Test-Path $Path) {
        try {
            $Acl = Get-Acl $Path
            $DenyWrite = New-Object System.Security.AccessControl.FileSystemAccessRule(
                $LocalUser, "Write,CreateFiles,CreateDirectories,Delete",
                "ContainerInherit,ObjectInherit", "None", "Deny")
            $Acl.AddAccessRule($DenyWrite)
            Set-Acl -Path $Path -AclObject $Acl -ErrorAction Stop
            Write-Host "  [+] Write/create denied on: $Path" -ForegroundColor DarkGray
        } catch {
            Write-Host "  [!] Skipped (access denied): $Path" -ForegroundColor Yellow
        }
    }
}

$InstallerPolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer"
if (-not (Test-Path $InstallerPolicyPath)) {
    New-Item -Path $InstallerPolicyPath -Force | Out-Null
}
Set-ItemProperty -Path $InstallerPolicyPath -Name "DisableMSI" -Value 1 -Type DWord
Write-Host "  [+] MSI installer blocked." -ForegroundColor Green

Write-Host ""
Write-Host "  [OK] Student account ready." -ForegroundColor Cyan
Write-Host "       Username : Student" -ForegroundColor White
Write-Host "       Password : None" -ForegroundColor White
Write-Host "       Can do   : Run apps, write on Desktop only" -ForegroundColor White
Write-Host "       Cannot   : Install software, create files/folders elsewhere" -ForegroundColor White
# win10-student-user-permissions

Creates a restricted `Student` local account on Windows 10 lab machines.

---

## What It Does

- Creates a local user named `Student` with no password
- Adds the account to the standard `Users` group
- Grants full write access on the Student's Desktop only
- Denies write, create, and delete access everywhere else (Program Files, Documents, Downloads, etc.)
- Blocks MSI software installation via registry policy

---

## Requirements

- Windows 10
- PowerShell 5.1 or later
- Administrator rights

---

## Before Running the Script

### Make sure all apps are installed system-wide

Apps installed per-user (the default for many installers) will not be visible to the Student account. You must reinstall them system-wide before setting permissions.

**VS Code** is the most common case, it installs per-user by default. Run these two commands as Administrator before running the script:

```powershell
winget uninstall Microsoft.VisualStudioCode
```

```powershell
winget install Microsoft.VisualStudioCode --scope machine --silent --accept-package-agreements --accept-source-agreements
```

The `--scope machine` flag installs VS Code to `C:\Program Files\Microsoft VS Code\` making it available to all users.

**Python** is another common case — also installs per-user by default:

```powershell
winget uninstall Python.Python.3.12
```

```powershell
winget install Python.Python.3.12 --scope machine --silent --accept-package-agreements --accept-source-agreements
```

> Apply the same logic to any other app that was installed per-user. You can check where an app is installed by running `winget list` and looking at the install location, or by checking if the app exists under `C:\Program Files\` (system-wide) vs `C:\Users\<name>\AppData\Local\Programs\` (per-user).

---

## Usage

Open PowerShell as Administrator and run:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\New-StudentUser.ps1
```

---

## What the Student Account Can and Cannot Do

| Action | Allowed |
|---|---|
| Log in without a password | Yes |
| Run installed applications | Yes |
| Create and write files on Desktop | Yes |
| Create files or folders anywhere else | No |
| Install software | No |
| Modify system or program files | No |

---

## Related

- [win10-student-setup](https://github.com/theitsnschool/win10-student-setup). Full lab machine setup: removes bloatware and installs all dev tools
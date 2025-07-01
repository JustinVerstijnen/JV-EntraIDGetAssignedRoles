# JV-EntraIDGetAssignedRoles

A great, fast and easy PowerShell script to export all assigned Entra ID (Azure AD) roles for users, groups, or service principals — developed by Justin Verstijnen.

---

## Overview and Features

**JV-EntraIDGetAssignedRoles** is a simple PowerShell script that does the following:

- Retrieves all **permanently assigned roles** from Microsoft Entra ID  
- Attempts to retrieve **eligible (PIM) assignments** if the tenant has the proper license (Entra ID P2 or Governance)  
- Includes the assigned object name, type, and assignment date  
- Identifies whether an assignment is **Permanent** or **Eligible**  
- Stores the result as a **CSV file in the same folder** as the script  
- CSV is formatted with semicolon `;` delimiter — ready for Excel  

---

## Requirements

- **Microsoft Graph PowerShell module** (v1), install using:

  ```powershell
  Install-Module Microsoft.Graph -Scope CurrentUser -Repository PSGallery -Force
  ```

- Permissions required:
  - `RoleManagement.Read.Directory`
  - `Directory.Read.All`
  - Optional: `PrivilegedAccess.Read.AzureAD` (for PIM support)

---

## How to run?

1. Download or copy the script to your desired location.  
2. Open PowerShell as Administrator (recommended).  
3. Navigate to the script path and run it like this:

   ```powershell
   .\JV-EntraIDGetAssignedRoles.ps1
   ```

If you receive an error about script execution being disabled, run:

```powershell
Set-ExecutionPolicy Unrestricted -Scope Process
```

Then execute the script again.

---

## Output

A CSV file named:

```
JV-EntraGetAssignedRoles.csv
```

…will be saved in the **same folder as the script**, containing:

- Role name  
- Role ID  
- Assigned object (user, group, service principal)  
- Assignment type (Permanent or Eligible)  
- Assignment timestamp  
- Assignment ID  

If eligible role data cannot be retrieved (due to licensing), a yellow warning is shown and the script continues with permanent assignments only.

---

© Justin Verstijnen

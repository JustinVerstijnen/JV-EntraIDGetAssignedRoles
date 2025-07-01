# Justin Verstijnen Entra ID Get Privileged Users-script
# Github page: https://github.com/JustinVerstijnen/JV-EntraIDGetAssignedRoles
# Let's start!
Write-Host "Script made by..." -ForegroundColor DarkCyan
Write-Host "     _           _   _        __     __            _   _  _                  
    | |_   _ ___| |_(_)_ __   \ \   / /__ _ __ ___| |_(_)(_)_ __   ___ _ __  
 _  | | | | / __| __| | '_ \   \ \ / / _ \ '__/ __| __| || | '_ \ / _ \ '_ \ 
| |_| | |_| \__ \ |_| | | | |   \ V /  __/ |  \__ \ |_| || | | | |  __/ | | |
 \___/ \__,_|___/\__|_|_| |_|    \_/ \___|_|  |___/\__|_|/ |_| |_|\___|_| |_|
                                                       |__/                  " -ForegroundColor DarkCyan

# === PARAMETERS ===
$exportfile = "JV-EntraIDGetAssignedRoles_report.csv"

# Step 1: Connect to Microsoft Graph
Connect-MgGraph -Scopes "RoleManagement.Read.Directory", "Directory.Read.All", "PrivilegedAccess.Read.AzureAD" -NoWelcome

# Step 2: Get all permanent role assignments
$permanentAssignments = Get-MgRoleManagementDirectoryRoleAssignment -All

# Step 3: Try to get eligible (PIM) role assignments – catch license issues
$eligibleAssignments = @()
try {
    $eligibleAssignments = Get-MgRoleManagementDirectoryRoleEligibilitySchedule -All -ErrorAction Stop
} catch {
    Write-Host "⚠️  Eligible (PIM) role assignments could not be retrieved." -ForegroundColor Red
    Write-Host "Microsoft Entra ID P2 or Governance license is required. Script will continue to fetch the rest..." -ForegroundColor Yellow
    Start-Sleep -Seconds 1
}

# Step 4: Get all role definitions
$roleDefinitions = Get-MgRoleManagementDirectoryRoleDefinition -All

# Step 5: Initialize export list
$exportList = @()

# Step 6: Process permanent assignments
foreach ($assignment in $permanentAssignments) {
    $roleDefinition = $roleDefinitions | Where-Object { $_.Id -eq $assignment.RoleDefinitionId }

    try {
        $principal = Get-MgDirectoryObject -DirectoryObjectId $assignment.PrincipalId
        $principalType = $principal.ODataType -replace '#microsoft.graph.', ''
        $principalName = $principal.AdditionalProperties.displayName
    } catch {
        $principalType = "Unknown"
        $principalName = "Not found"
    }

    $exportList += [PSCustomObject]@{
        'Role'         = $roleDefinition.DisplayName
        'Role Id'           = $assignment.RoleDefinitionId
        'Assigned to'       = $principalName
        'Assigned to Id'     = $assignment.PrincipalId
        'Assignment Id'     = $assignment.Id
        'Assignment Type'   = "Permanent"
        'Assignment Date'  = $assignment.CreatedDateTime
    }
}

# Step 7: Process eligible (PIM) assignments (if any retrieved)
foreach ($assignment in $eligibleAssignments) {
    $roleDefinition = $roleDefinitions | Where-Object { $_.Id -eq $assignment.RoleDefinitionId }

    try {
        $principal = Get-MgDirectoryObject -DirectoryObjectId $assignment.PrincipalId
        $principalType = $principal.ODataType -replace '#microsoft.graph.', ''
        $principalName = $principal.AdditionalProperties.displayName
    } catch {
        $principalType = "Unknown"
        $principalName = "Not found"
    }

    $exportList += [PSCustomObject]@{
        'Role'         = $roleDefinition.DisplayName
        'Role Id'           = $assignment.RoleDefinitionId
        'Assigned to'       = $principalName
        'Assigned to Id'     = $assignment.PrincipalId
        'Assignment Id'     = $assignment.Id
        'Assignment Type'   = "Eligible"
        'Assignment Date'  = $assignment.CreatedDateTime
    }
}

# Step 8: Export to CSV
$exportList | Export-Csv -Path $exportfile -NoTypeInformation -Encoding UTF8 -Delimiter ";" -Force

# Step 9: Done
Write-Host "✅ Export completed: $exportfile" -ForegroundColor Green
Write-Host "If no further errors occured, the script has been succesfully executed. Go check out your file. Thank you for using my script!" -Foreground Green
Start-Sleep -Seconds 3

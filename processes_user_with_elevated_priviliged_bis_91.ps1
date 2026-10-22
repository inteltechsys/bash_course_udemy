# Set the user account to check processes for
$user = "kaley"

# ------------------------------------------------------------
# PowerShell and WMI can identify process ownership, but they do NOT provide a reliable
# per-process elevated privilege check by default. This Add-Type block compiles a small
# C# helper class (TokenCheck) that calls Windows API functions to inspect a process token
# and return True/False depending on whether that process is running elevated.
# ------------------------------------------------------------
Add-Type @"
using System;
using System.Runtime.InteropServices;

public class TokenCheck {
    [DllImport("advapi32.dll", SetLastError=true)]
    public static extern bool OpenProcessToken(IntPtr ProcessHandle, UInt32 DesiredAccess, out IntPtr TokenHandle);

    [DllImport("kernel32.dll", SetLastError=true)]
    public static extern bool CloseHandle(IntPtr hObject);

    [DllImport("advapi32.dll", SetLastError=true)]
    public static extern bool GetTokenInformation(
        IntPtr TokenHandle,
        int TokenInformationClass,
        out int TokenInformation,
        int TokenInformationLength,
        out int ReturnLength
    );

    public const UInt32 TOKEN_QUERY = 0x0008;
    public const int TokenElevation = 20;

    public static bool IsProcessElevated(IntPtr processHandle) {
        IntPtr tokenHandle;
        if (!OpenProcessToken(processHandle, TOKEN_QUERY, out tokenHandle))
            return false;

        int elevation;
        int outLen;
        bool success = GetTokenInformation(tokenHandle, TokenElevation, out elevation, sizeof(int), out outLen);

        CloseHandle(tokenHandle);

        if (!success)
            return false;

        return elevation != 0;
    }
}
"@

Write-Output "Listing processes running under this user account: $user"

Get-WmiObject Win32_Process | ForEach-Object {
    $p = $_
    try {
        $owner = $p.GetOwner()
        if ($owner -and $owner.User -eq $user) {
            $proc = Get-Process -Id $p.ProcessId -ErrorAction Stop
            $isElevated = [TokenCheck]::IsProcessElevated($proc.Handle)   # We retrieve the process handle using Get-Process, then pass that handle into TokenCheck.IsProcessElevated()
            [PSCustomObject]@{
                Name        = $p.Name
                ProcessId   = $p.ProcessId
                User        = $owner.User
                Domain      = $owner.Domain
                MemoryUsage = [int]($p.WorkingSetSize / 1MB)
                IsElevated = $isElevated   # Added the elevation result to the output so we can quickly identify high-risk processes owned by the target user that are running with elev
            }
        }
    } catch {
        # "Not found", "Access is denied", etc. -> skip that process
    }
} | Sort-Object MemoryUsage -Descending

Write-Output "Filtered process listing for user $user completed."

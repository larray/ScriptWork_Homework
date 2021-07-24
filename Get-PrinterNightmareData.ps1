function Get-NightmareStatus () {
    [CmdletBinding()]
    param (
        [Parameter()]
        [int32]
        $pnpt_NoWarningNoElevationOnInstall=0,
        [Parameter()]
        [int32]
        $pnpt_UpdatePromptSettings=0,
        [Parameter()]
        [int32]
        $pnpt_RestrictDriverInstallationToAdministrators=1,
        [Parameter()]
        [int32]
        $ptrt_RegisterSpoolerRemoteRpcEndPoint=2
    )
    $Global:boh = @{}
    $strSep = "|"

    $boh['service_spooler_state'] = (Get-Service Spooler).Status
    $regPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint'
    $arrTargets = @('NoWarningNoElevationOnInstall','UpdatePromptSettings','RestrictDriverInstallationToAdministrators')
    if (Test-Path $regPath) {
        $boh["PNP_regpath"] = "VALID"
        $arrProps = (Get-ItemProperty $RegPath).PSObject.Properties.Name
        foreach ($target in $arrTargets) {
            if ($arrProps -match $target) {
                $boh["pnp_$target"] = Get-ItemPropertyValue -Path $regPath -Name $target
                if ($boh["pnp_$target"] -eq (Get-Variable -Name ("pnpt_" + $target)).value) {$boh["pnp_$target"] = "SECURE"} else {$boh["pnp_$target"] = "VULNERABLE"}
            } else {$boh["pnp_$target"] = "NotConfigured"}
        }
    } Else {
        $boh["PNP_regpath"] = "MISSING"
        foreach ($target in $arrTargets) {
            $boh["pnp_$target"] = "NotConfigured"
        }
    }

    $regPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers'
    $arrTargets = @('RegisterSpoolerRemoteRpcEndPoint')
    if (Test-Path $regPath) {
        $boh["PTR_regpath"] = "VALID"
        $arrProps = (Get-ItemProperty $RegPath).PSObject.Properties.Name
        foreach ($target in $arrTargets) {
            if ($arrProps -match $target) {
                $boh["ptr_$target"] = Get-ItemPropertyValue -Path $regPath -Name $target
                if ($boh["ptr_$target"] -eq (Get-Variable -Name ("ptrt_" + $target)).value) {$boh["ptr_$target"] = "SECURE"} else {$boh["ptr_$target"] = "VULNERABLE"}
            } else {$boh["ptr_$target"] = "NotConfigured"}
        }
    } Else {
        $boh["PTR_regpath"] = "MISSING"
        foreach ($target in $arrTargets) {
            $boh["ptr_$target"] = "NotConfigured"
        }
    }

    "$($boh.service_spooler_state)$strSep$($boh.PTR_regpath)$strSep$($boh.ptr_RegisterSpoolerRemoteRpcEndPoint)$strSep$($boh.PNP_regpath)$strSep$($boh.pnp_NoWarningNoElevationOnInstall)$strSep$($boh.pnp_UpdatePromptSettings)$strSep$($boh.pnp_RestrictDriverInstallationToAdministrators)"

 }

function Set-NightmareLogConfig () {
    $logConfig = Get-LogProperties 'Microsoft-Windows-PrintService/Operational'
    $logConfig.Enabled = $true
    $logConfig.Retention = $true
    Set-LogProperties -LogDetails $logConfig
    Get-LogProperties 'Microsoft-Windows-PrintService/Operational'
}


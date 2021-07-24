function Get-NightmareStatus () {
    $Global:boh = @{}
    $boh['service_spooler_state'] = (Get-Service Spooler).Status
    $regPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint'
    if (Test-Path $regPath) {
        $boh["PNP_regpath"] = "VALID"
        $arrProps = (Get-ItemProperty $RegPath).PSObject.Properties.Name
        $arrTargets = @('NoWarningNoElevationOnInstall','UpdatePromptSettings','RestrictDriverInstallationToAdministrators')
        foreach ($target in $arrTargets) {
            if ($arrProps -match $target) {
                $boh["pnp_$target"] = Get-ItemPropertyValue -Path $regPath -Name $target
            } else {$boh["pnp_$target"] = "NotConfigured"}
        }
    } Else {$boh["PNP_regpath"] = "MISSING"}

    $regPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers'
    if (Test-Path $regPath) {
        $boh["PTR_regpath"] = "VALID"
        $arrProps = (Get-ItemProperty $RegPath).PSObject.Properties.Name
        $arrTargets = @('RegisterSpoolerRemoteRpcEndPoint')
        foreach ($target in $arrTargets) {
            if ($arrProps -match $target) {
                $boh["ptr_$target"] = Get-ItemPropertyValue -Path $regPath -Name $target
            } else {$boh["ptr_$target"] = "NotConfigured"}
        }
    } Else {$boh["PTR_regpath"] = "MISSING"}
 }

function Set-NightmareLogConfig () {
    $logConfig = Get-LogProperties 'Microsoft-Windows-PrintService/Operational'
    $logConfig.Enabled = $true
    $logConfig.Retention = $true
    Set-LogProperties -LogDetails $logConfig
    Get-LogProperties 'Microsoft-Windows-PrintService/Operational'
}


Import-Module ActiveDirectory
$ErrorActionPreference= 'silentlycontinue'
$ou = "Accounts"
$dc = $env:UserDomain
$tld = $env:USERDNSDOMAIN.split(".")[1]
$cn = "OU=" + $ou + ",DC=" + $dc + ",DC=" + $tld

New-ADOrganizationalUnit -Name $ou -ProtectedFromAccidentalDeletion $false
New-ADOrganizationalUnit -Path $cn -Name "Employees" -ProtectedFromAccidentalDeletion $false
New-ADOrganizationalUnit -Path $cn -Name "IT Support Staff" -ProtectedFromAccidentalDeletion $false
New-ADOrganizationalUnit -Path $cn -Name "Domain Admins" -ProtectedFromAccidentalDeletion $false
New-ADOrganizationalUnit -Path $cn -Name "Server Users" -ProtectedFromAccidentalDeletion $false
New-ADOrganizationalUnit -Path $cn -Name "Service Accounts" -ProtectedFromAccidentalDeletion $false

$dc = $env:UserDomain
$tld = $env:USERDNSDOMAIN.split(".")[1]
$cn = "DC=" + $dc + ",DC=" + $tld

New-ADOrganizationalUnit -Path $cn -Name "Groups" -ProtectedFromAccidentalDeletion $false

$ou = "Accounts"
$dc = $env:UserDomain
$tld = $env:USERDNSDOMAIN.split(".")[1]
$cn = "OU=Server Users,OU=" + $ou + ",DC=" + $tld

$ou = "Devices"
$cn = "OU=" + $ou + ",DC=" + $DC + ",DC=" + $tld
New-ADOrganizationalUnit -Name $ou -ProtectedFromAccidentalDeletion $false
New-ADOrganizationalUnit -Path $cn -Name "Domain Controllers" -ProtectedFromAccidentalDeletion $false
New-ADOrganizationalUnit -Path $cn -Name "Workstations" -ProtectedFromAccidentalDeletion $false
New-ADOrganizationalUnit -Path $cn -Name "Servers" -ProtectedFromAccidentalDeletion $false
New-ADOrganizationalUnit -Path $cn -Name "Laptops" -ProtectedFromAccidentalDeletion $false
New-ADOrganizationalUnit -Path $cn -Name "Linux" -ProtectedFromAccidentalDeletion $false

# DISABLE PASSWORD POLICY
secedit /export /cfg c:\secpol.cfg
(gc C:\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0") | Out-File C:\secpol.cfg
secedit /configure /db c:\windows\security\local.sdb /cfg c:\secpol.cfg /areas SECURITYPOLICY
rm -force c:\secpol.cfg -confirm:$false

$userCount = 100
$ErrorActionPreference= 'continue'
function genPassword(){
    $Password = New-Object -TypeName PSObject
    $Password | Add-Member -MemberType ScriptProperty -Name "Password" -Value { ("!@#$%^&*0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz".tochararray() | sort {Get-Random})[0..20] -join '' }
    echo $Password
}

function createServiceAccounts(){
    $prefixes = "sv-","svc-","service-","s-","svc_","s_","sc_","sv_","SVC_","S_","SC_","SV_","SERVICE_"
    $boundPrefix = Get-Random -InputObject $prefixes
    $tld = $env:USERDNSDOMAIN.split(".")[1]
    $cn = "OU=Servers,OU=Devices,DC=" + $DC + ",DC=" + $tld
    $serverList = Get-ADComputer -Filter * -SearchBase $cn
    $services = "CIFS","HOST","DNS","IISADMIN","WWW","LDAP","MSSQL"
    $cifssuffix = "fsmgr","profiles","shareadm","psexec","profile","drivemnt","lapsinstall"
    $hostsuffix = "winrm","pscheck","psrm","rmaccess","ps","powershell","remotemgmt"
    $wwwsuffix = "iis","inet","intranet","internet","citrix","iisadm"
    $iissuffix = "iis","inet","intranet","internet","citrix","iisadm"
    $dnssuffix = "fwalldns","palodns","addns","adds","adupdater"
    $ldapsuffix = "printmgr","apacheds","freeipa","printerbind","openldap","cisco"
    $sqlsuffix = "mssql","sqlsrv","sqluat","sqldev","sqlprod","adsql","sql"
    $path = "OU=Service Accounts,OU=Accounts,DC=" + $dc + ",DC=" + $tld


    For($i = 0; $i -lt $services.Length; $i++){
     $passwd = genPassword
     $paswd = $passwd.Password
     $log = $webRequest.username  + "," + $paswd
     Write-Output $log | Out-File .\creds.csv -Append
     $creds = ConvertTo-SecureString -String $paswd -AsPlainText -Force
    if($i -eq 0){
        $cifsboundsuffix = Get-Random -InputObject $cifssuffix
        $name = $boundPrefix + $cifsboundsuffix
        New-ADUser -Name $name -DisplayName $name -AccountPassword $creds -Path $path -Enabled $true
    } 
    elseif($i -eq 1) {
        $hostboundsuffix = Get-Random -InputObject $hostsuffix
        $name = $boundPrefix + $hostboundsuffix
        New-ADUser -Name $name -DisplayName $name -AccountPassword $creds -Path $path -Enabled $true
    }
    elseif($i -eq 2) {
        $wwwboundsuffix = Get-Random -InputObject $wwwsuffix
        $name = $boundPrefix + $wwwboundsuffix
        New-ADUser -Name $name -DisplayName $name -AccountPassword $creds -Path $path -Enabled $true
    }
    elseif($i -eq 3) {
        $iisboundsuffix = Get-Random -InputObject $iissuffix
        $name = $boundPrefix + $iisboundsuffix
        New-ADUser -Name $name -DisplayName $name -AccountPassword $creds  -Path $path -Enabled $true
    }
    elseif($i -eq 4) {
        $dnsboundsuffix = Get-Random -InputObject $dnssuffix
        $name = $boundPrefix + $dnsboundsuffix
        New-ADUser -Name $name -DisplayName $name -AccountPassword $creds -Path $path -Enabled $true
    } 
    elseif($i -eq 5) {
        $ldapboundsuffix = Get-Random -InputObject $ldapsuffix
        $name = $boundPrefix + $ldapboundsuffix
        New-ADUser -Name $name -DisplayName $name -AccountPassword $creds -Path $path -Enabled $true
        $name = $boundPrefix + "join"
         $creds = ConvertTo-SecureString -String "JoinMe123!" -AsPlainText -Force
        New-ADUser -Name $name -DisplayName $name -AccountPassword $creds -Path $path -Enabled $true
        
        }
    elseif($i -eq 6){
        $sqlboundsuffix = Get-Random -InputObject $sqlsuffix
        $name = $boundPrefix + $sqlboundsuffix
        New-ADUser -name $name -DisplayName $name -AccountPassword $creds -Path $path -Enabled $true
    }
    }
}

function createWorkstationAdmin(){
    $workstationAdminCount = $userCount * 0.02

    $dc = $env:UserDomain
    $tld = $env:USERDNSDOMAIN.split(".")[1]
    $ou = "Accounts"
    $path = "OU=IT Support Staff,OU=" + $ou + ",DC=" + $dc + ",DC=" + $tld
    $searchbase = "OU=Employees,OU=" + $ou + ",DC=" + $dc + ",DC=" + $tld
    $wadmusers = Get-ADUser -Filter * -SearchBase $searchbase
    $prefixes = "wa-","wadm-","wkadm-","wk-","w-","wa_","wk_","wadm_","wkadm_","w_"
    $boundPrefix = Get-Random -InputObject $prefixes
    for ($i = 1; $i -le $workstationAdminCount; $i=$i+1) {
        $n = $i + 5
        $wkadminUsers = $wadmusers.GivenName[$n]
        
        $wkadmName = $boundPrefix + $wkadminUsers
        $upn = $wkadmName + "@" + $env:USERDNSDOMAIN

        $passwd = genPassword
        $paswd = $passwd.Password
        $log = $upn + "," + $paswd
        Write-Output $log | Out-File .\creds.csv -Append
        $creds = ConvertTo-SecureString -String $paswd -AsPlainText -Force
        New-ADUser -Name $wkadmName -GivenName $wadmusers.GivenName[$n] -DisplayName $wadmusers.GivenName[$n] -Surname $wadmusers.Surname[$n] -UserPrincipalName $upn -Enabled $true -ChangePasswordAtLogon $false -Path $path -AccountPassword $creds
    }

}

function createServerUsers(){

    $serverUserCount = $userCount * 0.03

    $ou = "Accounts"
    $dc = $env:UserDomain
    $tld = $env:USERDNSDOMAIN.split(".")[1]
    $path = "OU=Server Users,OU=" + $ou + ",DC=" + $dc + ",DC=" + $tld
    $searchBase = "OU=Employees,OU=" + $ou + ",DC=" + $dc + ",DC=" + $tld
    $prefixes = "su-","s-","srv-","srvusr-","S_","SU_","SRVUSR_","SRV_"
    $boundPrefix = Get-Random -InputObject $prefixes
    
    $allUsers = Get-ADUser -Filter * -SearchBase $searchBase
    for ($i = 1; $i -le $serverUserCount; $i=$i+1) {
        $srvUsers = $allUsers.Name[$i]

        $srvName = $boundPrefix + $srvUsers
        $upn = $srvName + "@" + $env:USERDNSDOMAIN
        $passwd = genPassword
        $paswd = $passwd.Password
        $log = $upn + "," + $paswd
        Write-Output $log | Out-File .\creds.csv -Append
        
        $creds = ConvertTo-SecureString -String $paswd -AsPlainText -Force
        New-ADUser -Name $srvName -GivenName $allUsers.GivenName[$i] -DisplayName $allUsers.GivenName[$i] -Surname $allusers.Surname[$i] -UserPrincipalName $upn -Enabled $true -ChangePasswordAtLogon $false -Path $path -AccountPassword $creds
    }

}

function createDomainAdmins(){

    $domainAdminCount = $userCount * 0.01

    $ou = "Accounts"
    $dc = $env:UserDomain
    $tld = $env:USERDNSDOMAIN.split(".")[1]
    $path = "OU=Domain Admins,OU=" + $ou + ",DC=" + $dc + ",DC=" + $tld
    $searchbase = "OU=Server Users,OU=" + $ou + ",DC=" + $dc + ",DC=" + $tld
    $serverUsers = Get-ADUser -Filter * -SearchBase $searchbase
    $prefixes = "da-","a-","doma-","domadm-","DA_","A_","DOMA_","DOMADM_"
    $boundprefix = Get-Random -InputObject $prefixes

    for ($i = 1; $i -le $domainAdminCount; $i=$i+1) {
        $serverUsers | ForEach-Object {
            $daUsers = $serverUsers.GivenName[$i]
            echo $daUsers
            $upn = $daUsers + "@" + $env:USERDNSDOMAIN
            $passwd = genPassword
            $paswd = $passwd.Password
            $log = $upn + "," + $paswd
            Write-Output $log | Out-File .\creds.csv -Append
            $creds = ConvertTo-SecureString -String $paswd -AsPlainText -Force
            New-ADUser -Name $daUsers -GivenName $serverUsers.GivenName[$i] -DisplayName $serverUsers.GivenName[$i] -Surname $serverUsers.Surname[$i] -UserPrincipalName $upn -Enabled $true -ChangePasswordAtLogon $false -Path $path -AccountPassword $creds
        }
    }
}

function Create-NormalUsers() {

    $netbiosDN = $env:USERDOMAIN
    $dnsDN = $env:USERDNSDOMAIN.ToLower()

    for ($i=1; $i -le $userCount; $i=$i+1){

        # Queries random person API, logs to CSV, then and parses JSON to PowerShell Objects
        $webRequest = Invoke-WebRequest -Uri https://random-data-api.com/api/users/random_user 
        echo $webRequest.Content | ConvertFrom-Json | ConvertTo-Csv | Out-File .\log.csv -Append 

        $webRequest = $webRequest | ConvertFrom-Json

        # Formats Display name to "Firstname Lastname"
        $displayName = $webRequest.username.replace("."," ")
        $TextInfo = (Get-Culture).TextInfo
        $displayName = $TextInfo.ToTitleCase($displayName)

        # Formats UPN Name
        $upnName = $webRequest.username + "@" + $dnsDN

        # Credentials for User
        $passwd = genPassword
        $paswd = $passwd.Password
        $log = $webRequest.username  + "," + $paswd
        Write-Output $log | Out-File .\creds.csv -Append
        $creds = ConvertTo-SecureString -String $paswd -AsPlainText -Force
        
        $ou = "Accounts"
        $dc = $env:UserDomain
        $tld = $env:USERDNSDOMAIN.split(".")[1]
        $path = "OU=Employees,OU=" + $ou + ",DC=" + $dc + ",DC=" + $tld

        New-ADUser -Name $webRequest.username -DisplayName $displayName -Surname $webRequest.last_name -GivenName $webRequest.first_name -UserPrincipalName $upnName -Enabled $true -AccountPassword $creds -ChangePasswordAtLogon $false -Path $path
    }
    # Log data to text file
    Get-Content .\log.csv | Sort-Object | Get-Unique | Out-File .\sorted-users.csv
    Remove-Item .\log.csv -Force
    $x = Get-Content -Path .\sorted-users.csv; Set-Content -Path .\sorted-users.csv -Value ($x[($x.Length-1)..0])
    (Get-Content .\sorted-users.csv | Select-Object -Skip 1) | Set-Content .\sorted-users.csv

    Write-Host "Log written to .\sorted-users.csv!"
    createServerUsers
    createDomainAdmins
    createWorkstationAdmin
    createServiceAccounts
}

function Setup-GPOs(){
    $ErrorActionPreference= 'silentlycontinue'
    $dc = $env:UserDomain
    $tld = $env:USERDNSDOMAIN.split(".")[1]
    $accountsOU = "OU=Accounts,DC=" + $dc + ",DC=" + $tld
    $svcAccOU = "OU=Service Accounts,OU=Accounts,DC="  + $dc + ",DC=" + $tld
    $employeesOU = "OU=Employees,OU=Accounts,DC=" + $dc + ",DC=" + $tld
    $wkadmOU = "OU=IT Support Staff,OU=Accounts,DC=" + $dc + ",DC=" + $tld
    $daOU =  "OU=Domain Admins,OU=Accounts,DC=" + $dc + ",DC=" + $tld
    $suOU = "OU=Server Users,OU=Accounts,DC=" + $dc + ",DC=" + $tld
    $devicesOU = "OU=Devices,DC=" + $dc + ",DC=" + $tld
    $serversOU = "OU=Servers,OU=Devices,DC=" + $dc + ",DC=" + $tld
    $workstationsOU = "OU=Workstations,OU=Devices,DC=" + $dc + ",DC=" + $tld
    $laptopsOU = "OU=Laptops,OU=Devices,DC=" + $dc + ",DC=" + $tld
    $domaincontrollerOU = "OU=Domain Controllers,OU=Devices,DC=" + $dc + ",DC=" + $tld
    $linuxOU = "OU=Linux,OU=Devices,DC=" + $dc + ",DC=" + $tld

    New-GPO -Name "Disable Firewall" | New-GPLink -Target $devicesOU
    New-GPO -Name "Deny Server User Access" | New-GPLink -Target $workstationsOU
    New-GPO -Name "Grant Server User Local Admin" | New-GPLink -Target $serversOU
    New-GPO -Name "Grant IT Support Local Admin" | New-GPLink -Target $workstationsOU
    New-GPO -Name "Enable LAPS" | New-GPLink -Target $devicesOU
    New-GPO -Name "Deny Unprivileged Logon" | New-GPLink -Target $serversOU
    New-GPO -Name "Exempt Password Policy" | New-GPLink -Target $employeesOU 
    New-GPO -Name "Force Password Policy" | New-GPLink -Target $suOU
    New-GPO -Name "Allow Net Discovery" | New-GPLink -Target $devicesOU
    New-GPO -Name "Service Account Privs" | New-GPLink -Target $svcAccOU
    New-GPO -Name "Roaming Profiles" | New-GPLink -Target $accountsOU
    New-GPO -Name "Roaming Profiles Fix" | New-GPLink -Target $accountsOU
    New-GPO -Name "Forced Updates Exempt" | New-GPLink -Target $serversOU
    New-GPO -Name "nix server policy" |New-GPLink -Target $linuxOU
    New-GPO -Name "Undock Misc" | New-GPLink -Target $laptopsOU
    Get-GPO -Name "Forced Updates Exempt" | New-GPLink -Target $domaincontrollerOU
    Get-GPO -Name "Default Domain Controllers Policy" | New-GPLink -Target $domaincontrollerOU
    Get-GPO -Name "Exempt Password Policy" | New-GPLink -Target $svcAccOU
    Get-GPO -Name "Force Password Policy" | New-GPLink -Target $wkadmOU
    Get-GPO -Name "Force Password Policy" | New-GPLink -Target $daOU
    $ErrorActionPreference = 'Continue'
}

function Generate-Groups(){
    $ErrorActionPreference= 'silentlycontinue'
    $ou = "Groups"
    $dc = $env:UserDomain
    $tld = $env:USERDNSDOMAIN.split(".")[1]
    $cn = "OU=" + $ou + ",DC=" + $dc + ",DC=" + $tld

    $groups = "Billing","CustomerService","SeniorManagers","GeneralCouncil","Marketing","Automotive","Transport","Construction","Payroll","BargainingUnit","Benefits","HR","SystemOperators","Storage","Transformers","ProjectManagement","RiverCrew","BlackStart","Payments","Railroads","Maintenance","AccountsPayable","Facilities","Dispatch","ExternalAffairs","Sales","Education","Solar","NuclearOps","OutageManagement","Transmission","Purchasing","Substatoins","Renewables","AssetRecovery","PolicyStaff","HelpDesk","Municipal","Cybersecurity","MiddleOffice","SalesForce","SupplyChain","InvestorRelations","WasteManagement","ClientSupport","HVAC","Unix","FireSupport","TestLab","Legal","CallCenter","Receiving","Cooperatives","Utilities","Budgets","Environmental","Shipping","Finance","PropertyManagement","Publicity","Federal","Telecom","CoalTeam","Generation","RemoteUsers","Board","ReliabilityOrgs","Cogen","SafetyTeam","SustainabilityOffice","Hydro","Management","HighVoltage","SCADA","Compliance","Accounting","MedicalServices","EMC","StormCrews","RepairShop","MeterReading","UtilityBills","Distribution","Recruiting","PropanePlants","Pipelines","NatGas","FieldSupport","Audit"

    $itgroups = "citrix","info tech support","information technology","it","it helpdesk","it manager","it security","it service","it servicedesk","it services","it support","it support services","it tech ops","itops","msp","msp it","msp support","msp technician","support services","technician","techops","itops","vdi manager","workstation management"    

    $itgroup = Get-Random -InputObject $itgroups
    New-ADGroup -Name $itgroup -DisplayName $itgroup -Path $cn -GroupScope Global -GroupCategory Security
    New-ADGroup -Name "Server Users" -DisplayName "Server Users" -Path $cn -GroupScope Global -GroupCategory Security
    New-ADGroup -Name "Server Admins"  -DisplayName "Server Admins" -Path $cn -GroupScope Global -GroupCategory Security
    New-ADGroup -Name "Workstation Admins"  -DisplayName "Workstation Admins" -Path $cn -GroupScope Global -GroupCategory Security
    for ($i = 0; $i -le 89; $i++){
        $group = $groups[$i]
        New-ADGroup -Name $group -DisplayName $group -Path $cn -GroupScope Global -GroupCategory Security
    }
    echo $itgroup
    $ErrorActionPreference= 'continue'
}


function Assign-Groups($itGroup){
    $groups = "Billing","CustomerService","SeniorManagers","GeneralCouncil","Marketing","Automotive","Transport","Construction","Payroll","BargainingUnit","Benefits","HR","SystemOperators","Storage","Transformers","ProjectManagement","RiverCrew","BlackStart","Payments","Railroads","Maintenance","AccountsPayable","Facilities","Dispatch","ExternalAffairs","Sales","Education","Solar","NuclearOps","OutageManagement","Transmission","Purchasing","Substatoins","Renewables","AssetRecovery","PolicyStaff","HelpDesk","Municipal","Cybersecurity","MiddleOffice","SalesForce","SupplyChain","InvestorRelations","WasteManagement","ClientSupport","HVAC","Unix","FireSupport","TestLab","Legal","CallCenter","Receiving","Cooperatives","Utilities","Budgets","Environmental","Shipping","Finance","PropertyManagement","Publicity","Federal","Telecom","CoalTeam","Generation","RemoteUsers","Board","ReliabilityOrgs","Cogen","SafetyTeam","SustainabilityOffice","Hydro","Management","HighVoltage","SCADA","Compliance","Accounting","MedicalServices","EMC","StormCrews","RepairShop","MeterReading","UtilityBills","Distribution","Recruiting","PropanePlants","Pipelines","NatGas","FieldSupport","Audit"
    $dc = $env:UserDomain
    $tld = $env:USERDNSDOMAIN.split(".")[1]
    $employeesOU = "OU=Employees,OU=Accounts,DC=" + $dc + ",DC=" + $tld 
    $users = Get-ADUser -Filter * -SearchBase $employeesOU | Select -ExpandProperty SamAccountName
    $users | ForEach-Object {
        $RandomLoop = Get-Random -Minimum 2 -Maximum 7 
        for ($i = 0; $i -le $RandomLoop; $i++){
            $userToAdd = "CN=" + $_ + "," + $employeesOU
            $toAdd = Get-Random -Input $groups
            Add-ADGroupMember -Identity $toAdd -Members $userToAdd
        }
    }
    
# Get DA and assign IT Groups
    $daOU =  "OU=Domain Admins,OU=Accounts,DC=" + $dc + ",DC=" + $tld
    echo $daOU
    $daUsers = Get-ADUser -Filter * -SearchBase $daOU
    $daUsers | ForEach-Object {
        Add-ADGroupMember -Identity $itGroup -Members $_.SamAccountName
        Add-ADGroupMember -Identity "Domain Admins" -Members $_.SamAccountName
    }

    $wkadmOU = "OU=IT Support Staff,OU=Accounts,DC=" + $dc + ",DC=" + $tld
    $wkadmUsers = Get-ADUser -Filter * -SearchBase $wkadmOU
    $wkadmUsers | ForEach-Object {
        Add-ADGroupMember -Identity $itGroup -Members $_.SamAccountName
        Add-ADGroupMember -Identity "Workstation Admins"  -Members $_.SamAccountName
    }
    $suOU = "OU=Server Users,OU=Accounts,DC=" + $dc + ",DC=" + $tld
    $srvUsers = Get-ADUser -Filter * -SearchBase $suOU
    $srvUsers | ForEach-Object {

        Add-ADGroupMember -Identity $itGroup -Members $_.SamAccountName
        Add-ADGroupMember -Identity "Server Users" -Members $_.SamAccountName
        Add-ADGroupMember -Identity "Server Admins" -Members $_.SamAccountName
    }

}

Create-NormalUsers
$itGroup = Generate-Groups
Setup-GPOs
Assign-Groups($itGroup)
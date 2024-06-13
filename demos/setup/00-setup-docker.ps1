# import the module
#Import-Module C:\Github\jpomfret\dbatools\dbatools.psd1 -Force
Import-Module dbatools

##############################
# create docker environment
##############################
# create a shared network
if (-not (docker network ls | select-string localnet)) {
    docker network create localnet
}

# create two docker containers for us
docker run -p 2500:1433  --volume shared:/shared:z --name mssql1 --hostname mssql1 --network localnet -d dbatools/sqlinstance
docker run -p 2600:1433 --volume shared:/shared:z --name mssql2 --hostname mssql2 --network localnet -d dbatools/sqlinstance2

# use aliases so we can call them by name
if (-not (Get-DbaClientAlias -ComputerName localhost  | Where-Object {$_.servername -eq 'localhost,2500' -and $_.AliasName -eq 'mssql1' -and $_.Architecture -eq '64-bit' } )) {
    New-DbaClientAlias -ComputerName localhost -ServerName 'localhost,2500' -Alias mssql1
    }
if (-not (Get-DbaClientAlias -ComputerName localhost  | Where-Object {$_.servername -eq 'localhost,2600' -and $_.AliasName -eq 'mssql2' -and $_.Architecture -eq '64-bit' } )) {
    New-DbaClientAlias -ComputerName localhost -ServerName 'localhost,2600' -Alias mssql2
}

# create the repl folder
docker exec mssql1 mkdir /var/opt/mssql/ReplData

# also need these folders for setting up replication
docker exec mssql1 mkdir /shared/data /shared/repldata

##############################

# smo defaults
Set-DbatoolsConfig -FullName sql.connection.encrypt -Value $false
Set-DbatoolsConfig -FullName sql.connection.trustcert -Value $true

##############################
# save the password for ease
##############################

$securePassword = ('dbatools.IO' | ConvertTo-SecureString -AsPlainText -Force)
$credential = New-Object System.Management.Automation.PSCredential('sqladmin', $securePassword)

$PSDefaultParameterValues = @{
    "*:SqlCredential"            = $credential
    "*:DestinationCredential"    = $credential
    "*:DestinationSqlCredential" = $credential
    "*:SourceSqlCredential"      = $credential
    "*:PublisherSqlCredential"   = $credential
    "*:SubscriberSqlCredential"   = $credential
}
##############################

######################################
# lets have some Dublin specific data
######################################

$query = "INSERT INTO dbo.Customers
(CustomerID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone, Fax)
VALUES
('DUBTS', 'Dublin Tech Solutions', 'John Doe', 'Manager', '123 Dublin Street', 'Dublin', 'Leinster', 'D01', 'Ireland', '0123456789', '0123456789'),
('IRSSV', 'Irish Software Services', 'Jane Smith', 'Director', '456 Dublin Avenue', 'Dublin', 'Leinster', 'D02', 'Ireland', '0234567891', '0234567891'),
('EMCLD', 'Emerald Cloud Computing', 'Robert Johnson', 'CEO', '789 Dublin Road', 'Dublin', 'Leinster', 'D03', 'Ireland', '0345678912', '0345678912'),
('SHADA', 'Shamrock Data Analytics', 'Emily Davis', 'CFO', '321 Dublin Lane', 'Dublin', 'Leinster', 'D04', 'Ireland', '0456789123', '0456789123'),
('CELCY', 'Celtic Cybersecurity', 'William Brown', 'CTO', '654 Dublin Park', 'Dublin', 'Leinster', 'D05', 'Ireland', '0567891234', '0567891234');
"
Invoke-DbaQuery -SqlInstance mssql1 -Database Northwind -Query $query

# tear down any repl
# remove subscriptions
$sub = @{
    SqlInstance           = 'mssql1'
    Database              = 'Northwind'
    SubscriptionDatabase  = 'Northwind'
    SubscriberSqlInstance = 'mssql2'
    PublicationName       = 'testPub'
    Confirm               = $false
}
Remove-DbaReplSubscription @sub

$sub = @{
    SqlInstance           = 'mssql1'
    Database              = 'Northwind'
    SubscriptionDatabase  = 'NorthwindMerge'
    SubscriberSqlInstance = 'mssql2'
    PublicationName       = 'Mergey'
    Confirm               = $false
}
Remove-DbaReplSubscription @sub

$sub = @{
    SqlInstance           = 'mssql1'
    Database              = 'Northwind'
    SubscriptionDatabase  = 'NorthwindSnap'
    SubscriberSqlInstance = 'mssql2'
    PublicationName       = 'snappy'
    Confirm               = $false
}
Remove-DbaReplSubscription @sub

# remove an article
$article = @{
    SqlInstance = 'mssql1'
    Database    = 'Northwind'
    Publication = 'testpub'
    Name        = 'Customers'
}
Remove-DbaReplArticle @article

# remove an article
$article = @{
    SqlInstance = 'mssql1'
    Database    = 'Northwind'
    Publication = 'Mergey'
    Name        = 'Products'
}
Remove-DbaReplArticle @article

# remove an article
$article = @{
    SqlInstance = 'mssql1'
    Database    = 'Northwind'
    Publication = 'snappy'
    Name        = 'Orders'
}
Remove-DbaReplArticle @article

## remove publications
$pub = @{
    SqlInstance = 'mssql1'
    Database    = 'Northwind'
    Name        = 'TestPub'
}
Remove-DbaReplPublication @pub

$pub = @{
    SqlInstance = 'mssql1'
    Database    = 'Northwind'
    Name        = 'Snappy'
}
Remove-DbaReplPublication @pub

$pub = @{
    SqlInstance = 'mssql1'
    Database    = 'Northwind'
    Name        = 'Mergey'
}
Remove-DbaReplPublication @pub

try {
    # disable publishing
    if (Get-DbaReplPublisher -SqlInstance mssql1) {
        Disable-DbaReplPublishing -SqlInstance mssql1 -force
    }

    # disable distribution
    if((Get-DbaReplDistributor -SqlInstance mssql1).IsDistributor -eq $true) {
        Disable-DbaReplDistributor -SqlInstance  mssql1
    }
} catch {
    write-warning 'there were warnings...'
}

# remove databases on mssql2
Get-DbaDatabase -SqlInstance mssql2 -ExcludeSystem -ExcludeDatabase ReportServer, ReportServerTempDB | Remove-DbaDatabase -Confirm:$false

# open zoomit
Invoke-Item C:\ProgramData\chocolatey\bin\ZoomIt.exe

# open SSMS
Invoke-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft SQL Server Tools 20\SQL Server Management Studio 20.lnk"

# run the tests
Invoke-Pester .\demos\tests\demo-docker.tests.ps1

# reset config
# smo defaults
Set-DbatoolsConfig -FullName sql.connection.encrypt -Value $true
Set-DbatoolsConfig -FullName sql.connection.trustcert -Value $false

Remove-Module dbatools
# import the module 
#Import-Module C:\Github\jpomfret\dbatools\dbatools.psd1 -Force
Import-Module C:\GitHub\DMM-GitHub\dbatools\dbatools.psd1 -Force

##############################
# create docker environment
##############################
# create a shared network
docker network create localnet

# create two docker containers for us 
docker run -p 2500:1433  --volume shared:/shared:z --name mssql1 --hostname mssql1 --network localnet -d dbatools/sqlinstance
docker run -p 2600:1433 --volume shared:/shared:z --name mssql2 --hostname mssql2 --network localnet -d dbatools/sqlinstance2

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


# disable publishing 
Disable-DbaReplPublishing -SqlInstance mssql1 -force

# disable distribution
Disable-DbaReplDistributor -SqlInstance  mssql1


# remove databases on mssql2
Get-DbaDatabase -SqlInstance mssql2 -ExcludeSystem -ExcludeDatabase ReportServer, ReportServerTempDB | Remove-DbaDatabase -Confirm:$false 

# run the tests
Invoke-Pester .\demos\tests\demo-docker.tests.ps1 -Output Detailed

# reset config
# smo defaults
Set-DbatoolsConfig -FullName sql.connection.encrypt -Value mandatory
Set-DbatoolsConfig -FullName sql.connection.trustcert -Value $false

Remove-Module dbatools
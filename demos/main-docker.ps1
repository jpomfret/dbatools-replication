# Import the dev module
#Import-Module C:\Github\jpomfret\dbatools\dbatools.psd1 -Force
Import-Module C:\GitHub\DMM-GitHub\dbatools\dbatools.psd1 -Force

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

# Connect test
Connect-DbaInstance -SqlInstance mssql1, mssql2

# smo defaults
Set-DbatoolsConfig -FullName sql.connection.encrypt -Value optional
Set-DbatoolsConfig -FullName sql.connection.trustcert -Value $true

# Connect test
Connect-DbaInstance -SqlInstance mssql1, mssql2

# gets

# Get the distributor
Get-DbaReplDistributor -SqlInstance mssql1

# view publications
Get-DbaReplPublication -SqlInstance mssql1

# view articles
Get-DbaReplArticle -SqlInstance mssql1

# get subscriptions
Get-DbaReplSubscription -SqlInstance mssql1



# enable distribution
Enable-DbaReplDistributor -SqlInstance mssql1

# enable publishing
Enable-DbaReplPublishing -SqlInstance mssql1

# Get the distributor
Get-DbaReplDistributor -SqlInstance mssql1

# add a transactional publication
$pub = @{
    SqlInstance = 'mssql1'
    Database    = 'AdventureWorksLT2017'
    Name        = 'testPub'
    Type        = 'Transactional'
}
New-DbaReplPublication @pub

# add a merge publication
$pub = @{
    SqlInstance = 'mssql1'
    Database    = 'AdventureWorksLT2017'
    Name        = 'mergey'
    Type        = 'Merge'
}
New-DbaReplPublication @pub

# add a snapshot publication
$pub = @{
    SqlInstance = 'mssql1'
    Database    = 'AdventureWorksLT2017'
    Name        = 'snappy'
    Type        = 'Snapshot'
}
New-DbaReplPublication @pub

# view publications
Get-DbaReplPublication -SqlInstance mssql1

# add an article to each publication
$article = @{
    SqlInstance = 'mssql1'
    Database    = 'AdventureWorksLT2017'
    Publication = 'testpub'
    Schema      = 'salesLT'
    Name        = 'customer'
    Filter      = "lastname = 'gates'"
}
Add-DbaReplArticle @article

$article = @{
    SqlInstance = 'mssql1'
    Database    = 'AdventureWorksLT2017'
    Publication = 'Mergey'
    Schema      = 'salesLT'
    Name        = 'product'
}
Add-DbaReplArticle @article

$article = @{
    SqlInstance = 'mssql1'
    Database    = 'AdventureWorksLT2017'
    Publication = 'snappy'
    Schema      = 'salesLT'
    Name        = 'address'
}
Add-DbaReplArticle @article

# view articles
Get-DbaReplArticle -SqlInstance mssql1

# and view publications
Get-DbaReplPublication -SqlInstance mssql1

# and view articles from publications - magic of objects
(Get-DbaReplPublication -SqlInstance mssql1 -Name snappy).Articles

# add subscriptions
$sub = @{
    SqlInstance           = 'mssql1'
    Database              = 'AdventureWorksLT2017'
    SubscriberSqlInstance = 'mssql2'
    SubscriptionDatabase  = 'AdventureWorksLT2017'
    PublicationName       = 'testpub'
    Type                  = 'Push'
}
New-DbaReplSubscription @sub

$sub = @{
    SqlInstance           = 'mssql1'
    Database              = 'AdventureWorksLT2017'
    SubscriberSqlInstance = 'mssql2'
    SubscriptionDatabase  = 'AdventureWorksLT2017Merge'
    PublicationName       = 'Mergey'
    Type                  = 'Push'
}
New-DbaReplSubscription @sub

$sub = @{
    SqlInstance           = 'mssql1'
    Database              = 'AdventureWorksLT2017'
    SubscriberSqlInstance = 'mssql2'
    SubscriptionDatabase  = 'AdventureWorksLT2017Snap'
    PublicationName       = 'Snappy'
    Type                  = 'Push'
}
New-DbaReplSubscription @sub

# view subscriptions
Get-DbaReplSubscription -SqlInstance mssql1

#View publications again
Get-DbaReplPublication -SqlInstance mssql1

# start snapshot agent
Get-DbaAgentJob -SqlInstance mssql1 -Category repl-snapshot | Start-DbaAgentJob

# remove subscriptions
#TODO: Why didn't this prompt for confirm?
$sub = @{
    SqlInstance           = 'mssql1'
    Database              = 'AdventureWorksLT2017'
    SubscriptionDatabase  = 'AdventureWorksLT2017'
    SubscriberSqlInstance = 'mssql2'
    PublicationName       = 'testPub'
}
Remove-DbaReplSubscription @sub

$sub = @{
    SqlInstance           = 'mssql1'
    Database              = 'AdventureWorksLT2017'
    SubscriptionDatabase  = 'AdventureWorksLT2017Merge'
    SubscriberSqlInstance = 'mssql2'
    PublicationName       = 'Mergey'
}
Remove-DbaReplSubscription @sub

$sub = @{
    SqlInstance           = 'mssql1'
    Database              = 'AdventureWorksLT2017'
    SubscriptionDatabase  = 'AdventureWorksLT2017Snap'
    SubscriberSqlInstance = 'mssql2'
    PublicationName       = 'snappy'
}
Remove-DbaReplSubscription @sub

# remove an article
$article = @{
    SqlInstance = 'mssql1'
    Database    = 'AdventureWorksLT2017'
    Publication = 'testpub'
    Schema      = 'salesLT'
    Name        = 'customer'
}
Remove-DbaReplArticle @article

# remove an article
#TODO: can these all be in one command? just a list of name?
$article = @{
    SqlInstance = 'mssql1'
    Database    = 'AdventureWorksLT2017'
    Publication = 'Mergey'
    Schema      = 'salesLT'
    Name        = 'product'
}
Remove-DbaReplArticle @article

# remove an article
$article = @{
    SqlInstance = 'mssql1'
    Database    = 'AdventureWorksLT2017'
    Publication = 'snappy'
    Schema      = 'salesLT'
    Name        = 'address'
}
Remove-DbaReplArticle @article

## remove publications
$pub = @{
    SqlInstance = 'mssql1'
    Database    = 'AdventureWorksLT2017'
    Name        = 'TestPub'
}
Remove-DbaReplPublication @pub

$pub = @{
    SqlInstance = 'mssql1'
    Database    = 'AdventureWorksLT2017'
    Name        = 'Snappy'
}
Remove-DbaReplPublication @pub

$pub = @{
    SqlInstance = 'mssql1'
    Database    = 'AdventureWorksLT2017'
    Name        = 'Mergey'
}
Remove-DbaReplPublication @pub


# disable publishing 
Disable-DbaReplPublishing -SqlInstance mssql1 -force

<#
Are you sure you want to perform this action?
Performing the operation "Disabling and removing publishing on mssql1" on target "mssql1".
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"): y
WARNING: [15:20:26][Disable-DbaReplPublishing] Unable to disable replication publishing | Cannot drop server 'mssql1' as Distribution Publisher because there are databases enabled for replication on that server.
Changed database context to 'distribution'.
#>

# disable distribution
Disable-DbaReplDistributor -SqlInstance  mssql1

# check the status
Get-DbaReplServer -SqlInstance mssql1
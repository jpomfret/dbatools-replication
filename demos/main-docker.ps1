# Import the module
Import-Module dbatools

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
    "*:SubscriberSqlCredential"  = $credential
}
##############################

# Connect test
Connect-DbaInstance -SqlInstance mssql1, mssql2

# smo defaults
Set-DbatoolsConfig -FullName sql.connection.encrypt -Value $false
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
    Database    = 'Northwind'
    Name        = 'testPub'
    Type        = 'Transactional'
}
New-DbaReplPublication @pub

# add a merge publication
$pub = @{
    SqlInstance = 'mssql1'
    Database    = 'Northwind'
    Name        = 'mergey'
    Type        = 'Merge'
}
New-DbaReplPublication @pub

# add a snapshot publication
$pub = @{
    SqlInstance = 'mssql1'
    Database    = 'Northwind'
    Name        = 'snappy'
    Type        = 'Snapshot'
}
New-DbaReplPublication @pub

# view publications
Get-DbaReplPublication -SqlInstance mssql1

# add an article to each publication
$article = @{
    SqlInstance = 'mssql1'
    Database    = 'Northwind'
    Publication = 'testpub'
    Schema      = 'dbo'
    Name        = 'Customers'
    Filter      = "City = 'Dublin'"
}
Add-DbaReplArticle @article

$article = @{
    SqlInstance = 'mssql1'
    Database    = 'Northwind'
    Publication = 'Mergey'
    Schema      = 'dbo'
    Name        = 'Products'
}
Add-DbaReplArticle @article

$article = @{
    SqlInstance = 'mssql1'
    Database    = 'Northwind'
    Publication = 'snappy'
    Schema      = 'dbo'
    Name        = 'Suppliers'
}
Add-DbaReplArticle @article

# view articles
Get-DbaReplArticle -SqlInstance mssql1

# and view publications
Get-DbaReplPublication -SqlInstance mssql1

# and view articles from publications - magic of objects
(Get-DbaReplPublication -SqlInstance mssql1 -Name testpub).Articles

# add subscriptions
$sub = @{
    SqlInstance               = 'mssql1'
    Database                  = 'Northwind'
    SubscriberSqlInstance     = 'mssql2'
    SubscriptionDatabase      = 'Northwind'
    PublicationName           = 'testpub'
    Type                      = 'Push'
    SubscriptionSqlCredential = $credential # because we want to use sqlauth in our containers
}
New-DbaReplSubscription @sub

$sub = @{
    SqlInstance               = 'mssql1'
    Database                  = 'Northwind'
    SubscriberSqlInstance     = 'mssql2'
    SubscriptionDatabase      = 'NorthwindMerge'
    PublicationName           = 'Mergey'
    Type                      = 'Push'
    SubscriptionSqlCredential = $credential # because we want to use sqlauth in our containers
}
New-DbaReplSubscription @sub

$sub = @{
    SqlInstance               = 'mssql1'
    Database                  = 'Northwind'
    SubscriberSqlInstance     = 'mssql2'
    SubscriptionDatabase      = 'NorthwindSnap'
    PublicationName           = 'Snappy'
    Type                      = 'Push'
    SubscriptionSqlCredential = $credential # because we want to use sqlauth in our containers
}
New-DbaReplSubscription @sub

# view subscriptions
Get-DbaReplSubscription -SqlInstance mssql1

#View publications again
Get-DbaReplPublication -SqlInstance mssql1

# start snapshot agent
Get-DbaAgentJob -SqlInstance mssql1 -Category repl-snapshot | Start-DbaAgentJob

# remove subscriptions
$sub = @{
    SqlInstance           = 'mssql1'
    Database              = 'Northwind'
    SubscriptionDatabase  = 'Northwind'
    SubscriberSqlInstance = 'mssql2'
    PublicationName       = 'testPub'
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
## we could do it the same way...
# but don't run this...
$article = @{
    SqlInstance = 'mssql1'
    Database    = 'Northwind'
    Publication = 'testpub'
    Schema      = 'dbo'
    Name        = 'Customers'
}
Remove-DbaReplArticle @article

# remove an article
$article = @{
    SqlInstance = 'mssql1'
    Database    = 'Northwind'
    Publication = 'Mergey'
    Schema      = 'dbo'
    Name        = 'Products'
}
Remove-DbaReplArticle @article

# remove an article
$article = @{
    SqlInstance = 'mssql1'
    Database    = 'Northwind'
    Publication = 'snappy'
    Schema      = 'dbo'
    Name        = 'Suppliers'
}
Remove-DbaReplArticle @article

# We can also use piping
# using the -WhatIf parameter
Get-DbaReplArticle -SqlInstance mssql1 | Remove-DbaReplArticle -WhatIf

# and run it for real
Get-DbaReplArticle -SqlInstance mssql1 | Remove-DbaReplArticle

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
    Confirm     = $false
}
Remove-DbaReplPublication @pub

$pub = @{
    SqlInstance = 'mssql1'
    Database    = 'Northwind'
    Name        = 'Mergey'
    Confirm     = $false
}
Remove-DbaReplPublication @pub

# remove all the publications with piping
Get-DbaReplPublication -SqlInstance mssql1 | Remove-DbaReplPublication

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
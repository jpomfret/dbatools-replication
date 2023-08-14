# smo defaults
Set-DbatoolsConfig -FullName sql.connection.encrypt -Value optional
Set-DbatoolsConfig -FullName sql.connection.trustcert -Value $true

# gets

# Get the distributor
Get-DbaReplDistributor -SqlInstance sql2017

# view publications
Get-DbaReplPublication -SqlInstance sql2017

# view articles
Get-DbaReplArticle -SqlInstance sql2017

# get subscriptions
Get-DbaReplSubscription -SqlInstance sql2017



# enable distribution
Enable-DbaReplDistributor -SqlInstance sql2017

# enable publishing
Enable-DbaReplPublishing -SqlInstance sql2017

# Get the distributor
Get-DbaReplDistributor -SqlInstance sql2017

# add a transactional publication
$pub = @{
    SqlInstance = 'sql2017'
    Database    = 'AdventureWorksLT2017'
    Name        = 'testPub'
    Type        = 'Transactional'
}
New-DbaReplPublication @pub

# add a merge publication
$pub = @{
    SqlInstance = 'sql2017'
    Database    = 'AdventureWorksLT2017'
    Name        = 'mergey'
    Type        = 'Merge'
}
New-DbaReplPublication @pub

# add a snapshot publication
$pub = @{
    SqlInstance = 'sql2017'
    Database    = 'AdventureWorksLT2017'
    Name        = 'snappy'
    Type        = 'Snapshot'
}
New-DbaReplPublication @pub

# view publications
Get-DbaReplPublication -SqlInstance sql2017

# add an article to each publication
$article = @{
    SqlInstance = 'sql2017'
    Database    = 'AdventureWorksLT2017'
    Publication = 'testpub'
    Schema      = 'salesLT'
    Name        = 'customer'
    Filter      = "lastname = 'gates'"
}
Add-DbaReplArticle @article

$article = @{
    SqlInstance = 'sql2017'
    Database    = 'AdventureWorksLT2017'
    Publication = 'Mergey'
    Schema      = 'salesLT'
    Name        = 'product'
}
Add-DbaReplArticle @article

$article = @{
    SqlInstance = 'sql2017'
    Database    = 'AdventureWorksLT2017'
    Publication = 'snappy'
    Schema      = 'salesLT'
    Name        = 'address'
}
Add-DbaReplArticle @article

# view articles
Get-DbaReplArticle -SqlInstance sql2017

# add subscriptions
$sub = @{
    SqlInstance           = 'sql2017'
    Database              = 'AdventureWorksLT2017'
    SubscriberSqlInstance = 'sql2019'
    SubscriptionDatabase  = 'AdventureWorksLT2017'
    PublicationName       = 'testpub'
    Type                  = 'Push'
}
New-DbaReplSubscription @sub

$sub = @{
    SqlInstance           = 'sql2017'
    Database              = 'AdventureWorksLT2017'
    SubscriberSqlInstance = 'sql2019'
    SubscriptionDatabase  = 'AdventureWorksLT2017Merge'
    PublicationName       = 'Mergey'
    Type                  = 'Push'
}
New-DbaReplSubscription @sub

$sub = @{
    SqlInstance           = 'sql2017'
    Database              = 'AdventureWorksLT2017'
    SubscriberSqlInstance = 'sql2019'
    SubscriptionDatabase  = 'AdventureWorksLT2017Snap'
    PublicationName       = 'Snappy'
    Type                  = 'Push'
}
New-DbaReplSubscription @sub

# start snapshot agent
Get-DbaAgentJob -SqlInstance sql2017 -Category repl-snapshot | Start-DbaAgentJob

# remove subscriptions
$sub = @{
    SqlInstance           = 'sql2017'
    Database              = 'AdventureWorksLT2017'
    SubscriptionDatabase  = 'AdventureWorksLT2017'
    SubscriberSqlInstance = 'sql2019'
    PublicationName       = 'testPub'
}
Remove-DbaReplSubscription @sub

$sub = @{
    SqlInstance           = 'sql2017'
    Database              = 'AdventureWorksLT2017'
    SubscriptionDatabase  = 'AdventureWorksLT2017Merge'
    SubscriberSqlInstance = 'sql2019'
    PublicationName       = 'Mergey'
}
Remove-DbaReplSubscription @sub

$sub = @{
    SqlInstance           = 'sql2017'
    Database              = 'AdventureWorksLT2017'
    SubscriptionDatabase  = 'AdventureWorksLT2017Snap'
    SubscriberSqlInstance = 'sql2019'
    PublicationName       = 'snappy'
}
Remove-DbaReplSubscription @sub

# remove an article
$article = @{
    SqlInstance = 'sql2017'
    Database    = 'AdventureWorksLT2017'
    Publication = 'testpub'
    Schema      = 'salesLT'
    Name        = 'customer'
}
Remove-DbaReplArticle @article

# remove an article
$article = @{
    SqlInstance = 'sql2017'
    Database    = 'AdventureWorksLT2017'
    Publication = 'Mergey'
    Schema      = 'salesLT'
    Name        = 'product'
}
Remove-DbaReplArticle @article

# remove an article
$article = @{
    SqlInstance = 'sql2017'
    Database    = 'AdventureWorksLT2017'
    Publication = 'snappy'
    Schema      = 'salesLT'
    Name        = 'address'
}
Remove-DbaReplArticle @article

## remove publications
$pub = @{
    SqlInstance = 'sql2017'
    Database    = 'AdventureWorksLT2017'
    Name        = 'TestPub'
}
Remove-DbaReplPublication @pub

$pub = @{
    SqlInstance = 'sql2017'
    Database    = 'AdventureWorksLT2017'
    Name        = 'Snappy'
}
Remove-DbaReplPublication @pub

$pub = @{
    SqlInstance = 'sql2017'
    Database    = 'AdventureWorksLT2017'
    Name        = 'Mergey'
}
Remove-DbaReplPublication @pub


# disable publishing 
Disable-DbaReplPublishing -SqlInstance sql2017 -force

<#
WARNING: [12:32:22][Disable-DbaReplPublishing] Unable to disable replication publishing | Cannot drop server 'SQL2017'
as Distribution Publisher because there are databases enabled for replication on that server.
Changed database context to 'distribution'.
#>

# disable distribution
Disable-DbaReplDistributor -SqlInstance  sql2017

Get-DbaReplServer -SqlInstance sql2017
# Import the dev module
#Import-Module C:\Github\jpomfret\dbatools\dbatools.psd1 -Force
Import-Module dbatools

# Connect test
Connect-DbaInstance -SqlInstance sql1, sql2

# smo defaults
Set-DbatoolsConfig -FullName sql.connection.encrypt -Value $false
Set-DbatoolsConfig -FullName sql.connection.trustcert -Value $true

# Connect test
Connect-DbaInstance -SqlInstance sql1, sql2

# gets

# Get the distributor
Get-DbaReplDistributor -SqlInstance sql1

# view publications
Get-DbaReplPublication -SqlInstance sql1

# view articles
Get-DbaReplArticle -SqlInstance sql1

# get subscriptions
Get-DbaReplSubscription -SqlInstance sql1



# enable distribution
Enable-DbaReplDistributor -SqlInstance sql1

# enable publishing
Enable-DbaReplPublishing -SqlInstance sql1

# Get the distributor
Get-DbaReplDistributor -SqlInstance sql1

# add a transactional publication
$pub = @{
    SqlInstance = 'sql1'
    Database    = 'AdventureWorksLT2022'
    Name        = 'testPub'
    Type        = 'Transactional'
}
New-DbaReplPublication @pub

# add a merge publication
$pub = @{
    SqlInstance = 'sql1'
    Database    = 'AdventureWorksLT2022'
    Name        = 'mergey'
    Type        = 'Merge'
}
New-DbaReplPublication @pub

# add a snapshot publication
$pub = @{
    SqlInstance = 'sql1'
    Database    = 'AdventureWorksLT2022'
    Name        = 'snappy'
    Type        = 'Snapshot'
}
New-DbaReplPublication @pub

# view publications
Get-DbaReplPublication -SqlInstance sql1

$testPub = Get-DbaReplPublication -SqlInstance sql1 -Name testPub
$testPub | Get-Member
$testPub | Format-List *

# add an article to each publication
$article = @{
    SqlInstance = 'sql1'
    Database    = 'AdventureWorksLT2022'
    Publication = 'testpub'
    Schema      = 'salesLT'
    Name        = 'customer'
    Filter      = "lastname = 'gates'"
}
Add-DbaReplArticle @article

$article = @{
    SqlInstance = 'sql1'
    Database    = 'AdventureWorksLT2022'
    Publication = 'Mergey'
    Schema      = 'salesLT'
    Name        = 'product'
}
Add-DbaReplArticle @article

$article = @{
    SqlInstance = 'sql1'
    Database    = 'AdventureWorksLT2022'
    Publication = 'snappy'
    Schema      = 'salesLT'
    Name        = 'address'
}
Add-DbaReplArticle @article

# view articles
Get-DbaReplArticle -SqlInstance sql1

# we can't see the filter - but there are more properties available
Get-DbaReplArticle -SqlInstance sql1 -Publication testPub | 
Select-Object SqlInstance, DatabaseName, PublicationName, Name, SourceObjectOwner, SourceObjectName, FilterClause

# and view publications
Get-DbaReplPublication -SqlInstance sql1

# and view articles from publications - magic of objects
(Get-DbaReplPublication -SqlInstance sql1 -Name snappy).Articles

# add subscriptions
$sub = @{
    SqlInstance           = 'sql1'
    Database              = 'AdventureWorksLT2022'
    SubscriberSqlInstance = 'sql2'
    SubscriptionDatabase  = 'AdventureWorksLT2022'
    PublicationName       = 'testpub'
    Type                  = 'Push'
}
New-DbaReplSubscription @sub

$sub = @{
    SqlInstance           = 'sql1'
    Database              = 'AdventureWorksLT2022'
    SubscriberSqlInstance = 'sql2'
    SubscriptionDatabase  = 'AdventureWorksLT2022Merge'
    PublicationName       = 'Mergey'
    Type                  = 'Push'
}
New-DbaReplSubscription @sub

$sub = @{
    SqlInstance           = 'sql1'
    Database              = 'AdventureWorksLT2022'
    SubscriberSqlInstance = 'sql2'
    SubscriptionDatabase  = 'AdventureWorksLT2022Snap'
    PublicationName       = 'Snappy'
    Type                  = 'Push'
}
New-DbaReplSubscription @sub

# view subscriptions
Get-DbaReplSubscription -SqlInstance sql1

#View publications again
Get-DbaReplPublication -SqlInstance sql1

# start snapshot agent
Get-DbaAgentJob -SqlInstance sql1 -Category repl-snapshot | Start-DbaAgentJob

# remove subscriptions
$sub = @{
    SqlInstance           = 'sql1'
    Database              = 'AdventureWorksLT2022'
    SubscriptionDatabase  = 'AdventureWorksLT2022'
    SubscriberSqlInstance = 'sql2'
    PublicationName       = 'testPub'
}
Remove-DbaReplSubscription @sub

$sub = @{
    SqlInstance           = 'sql1'
    Database              = 'AdventureWorksLT2022'
    SubscriptionDatabase  = 'AdventureWorksLT2022Merge'
    SubscriberSqlInstance = 'sql2'
    PublicationName       = 'Mergey'
    Confirm               = $false
}
Remove-DbaReplSubscription @sub

$sub = @{
    SqlInstance           = 'sql1'
    Database              = 'AdventureWorksLT2022'
    SubscriptionDatabase  = 'AdventureWorksLT2022Snap'
    SubscriberSqlInstance = 'sql2'
    PublicationName       = 'snappy'
    Confirm               = $false
}
Remove-DbaReplSubscription @sub

# remove an article
## we could do it the same way...
# but don't run this...
    $article = @{
        SqlInstance = 'sql1'
        Database    = 'AdventureWorksLT2022'
        Publication = 'testpub'
        Schema      = 'salesLT'
        Name        = 'customer'
    }
    Remove-DbaReplArticle @article

    # remove an article
    $article = @{
        SqlInstance = 'sql1'
        Database    = 'AdventureWorksLT2022'
        Publication = 'Mergey'
        Schema      = 'salesLT'
        Name        = 'product'
    }
    Remove-DbaReplArticle @article

    # remove an article
    $article = @{
        SqlInstance = 'sql1'
        Database    = 'AdventureWorksLT2022'
        Publication = 'snappy'
        Schema      = 'salesLT'
        Name        = 'address'
    }
    Remove-DbaReplArticle @article

# We can also use piping
# using the -WhatIf parameter
Get-DbaReplArticle -SqlInstance sql1 | Remove-DbaReplArticle -WhatIf

# and run it for real
Get-DbaReplArticle -SqlInstance sql1 | Remove-DbaReplArticle

## remove publications
    $pub = @{
        SqlInstance = 'sql1'
        Database    = 'AdventureWorksLT2022'
        Name        = 'TestPub'
    }
    Remove-DbaReplPublication @pub

    $pub = @{
        SqlInstance = 'sql1'
        Database    = 'AdventureWorksLT2022'
        Name        = 'Snappy'
        Confirm     = $false
    }
    Remove-DbaReplPublication @pub
    
    $pub = @{
        SqlInstance = 'sql1'
        Database    = 'AdventureWorksLT2022'
        Name        = 'Mergey'
        Confirm     = $false
    }
    Remove-DbaReplPublication @pub

# remove all the publications with piping
Get-DbaReplPublication -SqlInstance sql1 | Remove-DbaReplPublication

# disable publishing
Disable-DbaReplPublishing -SqlInstance sql1 -force

<#
Are you sure you want to perform this action?
Performing the operation "Disabling and removing publishing on sql1" on target "sql1".
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"): y
WARNING: [15:20:26][Disable-DbaReplPublishing] Unable to disable replication publishing | Cannot drop server 'sql1' as Distribution Publisher because there are databases enabled for replication on that server.
Changed database context to 'distribution'.
#>

# disable distribution
Disable-DbaReplDistributor -SqlInstance sql1

# check the status
Get-DbaReplServer -SqlInstance sql1
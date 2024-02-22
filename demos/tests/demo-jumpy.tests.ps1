Describe "SQL is ready"  {
    It "Services are running" {
        (Invoke-Command -ScriptBlock {Get-Service MSSQLSERVER, SQLSERVERAGENT} -ComputerName sql1,sql2).foreach{
            $psitem.Status | Should Be 'Running'
        }
    }
}

Describe "Environment ready for demos" -Tag docker{
    Context "Publishing\Distribution" {
        BeforeAll {
            $dist = Get-DbaReplDistributor -SqlInstance sql1
        }
        It "sql1 isn't a publisher" {
            $dist.IsPublisher | Should Be $False
        }
        It "sql1 isn't a publisher" {
            $dist.IsDistributor | Should Be $False
        }
    }

    Context "No publications\articles\subscriptions" {
        BeforeAll {
            $pubs = Get-DbaReplPublication -SqlInstance sql1
            $arts = Get-DbaReplArticle -SqlInstance sql1
            $subs = Get-DbaReplSubscription -SqlInstance sql1
        }
        It "There are no publications" {
            $pubs | Should BeNullOrEmpty
        }
        It "There are no articles" {
            $arts | Should BeNullOrEmpty
        }
        It "There are no subscriptions" {
            $subs | Should BeNullOrEmpty
        }
    }

    Context "There should be a database on sql1" {
        BeforeAll {
            $db = Get-DbaDatabase -SqlInstance sql1 -ExcludeSystem -Database AdventureWorksLT2022
        }
        It "AdventureWorksLT2022 exists on sql1" {
            $db.Name | Should Be 'AdventureWorksLT2022'
            $db.Status | Should Be 'Normal'
        }
    }

    Context "There should be no databases on sql2" {
        BeforeAll {
            $dbs = Get-DbaDatabase -SqlInstance sql2 -ExcludeSystem -ExcludeDatabase ReportServerTempDB, ReportServer
        }
        It "sql2 should have no databases" {
            $dbs | Should BeNullOrEmpty
        }
    }
    
}
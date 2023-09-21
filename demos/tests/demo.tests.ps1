BeforeAll {
    #Import-Module C:\Github\jpomfret\dbatools\dbatools.psd1 -Force
    Import-Module C:\GitHub\DMM-GitHub\dbatools\dbatools.psd1 -Force


    # smo defaults
    Set-DbatoolsConfig -FullName sql.connection.encrypt -Value optional
    Set-DbatoolsConfig -FullName sql.connection.trustcert -Value $true
}

Describe "SQL is ready"  {
    It "Services are running" {
        (Get-Service MSSQLSERVER, SQLSERVERAGENT -ComputerName sql2017,sql2019,sql2016).foreach{
            $psitem.Status | Should -Be 'Running'
        }
    }
}

Describe "Environment ready for demos" -Tag docker{
    Context "Publishing\Distribution" {
        BeforeAll {
            $dist = Get-DbaReplDistributor -SqlInstance SQL2017
        }
        It "SQL2017 isn't a publisher" {
            $dist.IsPublisher | Should -Be $False
        }
        It "SQL2017 isn't a publisher" {
            $dist.IsDistributor | Should -Be $False
        }
    }

    Context "No publications\articles\subscriptions" {
        BeforeAll {
            $pubs = Get-DbaReplPublication -SqlInstance SQL2017
            $arts = Get-DbaReplArticle -SqlInstance sql2017
            $subs = Get-DbaReplSubscription -SqlInstance sql2017
        }
        It "There are no publications" {
            $pubs | Should -BeNullOrEmpty
        }
        It "There are no articles" {
            $arts | Should -BeNullOrEmpty
        }
        It "There are no subscriptions" {
            $subs | Should -BeNullOrEmpty
        }
    }

    Context "There should be a database on SQL2017" {
        BeforeAll {
            $db = Get-DbaDatabase -SqlInstance SQL2017 -ExcludeSystem -Database AdventureWorksLT2017
        }
        It "AdventureWorksLT2017 exists on SQL2017" {
            $db.Name | Should -Be 'AdventureWorksLT2017'
            $db.Status | Should -Be 'Normal'
        }
    }

    Context "There should be no databases on SQL2019" {
        BeforeAll {
            $dbs = Get-DbaDatabase -SqlInstance SQL2019 -ExcludeSystem -ExcludeDatabase ReportServerTempDB, ReportServer
        }
        It "SQL2019 should have no databases" {
            $dbs | Should -BeNullOrEmpty
        }
    }
    
}
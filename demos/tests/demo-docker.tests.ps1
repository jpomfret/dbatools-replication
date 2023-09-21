BeforeAll {
    #Import-Module C:\Github\jpomfret\dbatools\dbatools.psd1 -Force
    Import-Module C:\GitHub\DMM-GitHub\dbatools\dbatools.psd1 -Force


    # smo defaults
    Set-DbatoolsConfig -FullName sql.connection.encrypt -Value optional
    Set-DbatoolsConfig -FullName sql.connection.trustcert -Value $true
}

Describe "Environment ready for demos" -Tag docker{
    Context "Publishing\Distribution" {
        BeforeAll {
            $dist = Get-DbaReplDistributor -SqlInstance mssql1
        }
        It "mssql1 isn't a publisher" {
            $dist.IsPublisher | Should -Be $False
        }
        It "mssql1 isn't a publisher" {
            $dist.IsDistributor | Should -Be $False
        }
    }

    Context "No publications\articles\subscriptions" {
        BeforeAll {
            $pubs = Get-DbaReplPublication -SqlInstance mssql1
            $arts = Get-DbaReplArticle -SqlInstance mssql1
            $subs = Get-DbaReplSubscription -SqlInstance mssql1
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

    Context "There should be a database on mssql1" {
        BeforeAll {
            $db = Get-DbaDatabase -SqlInstance mssql1 -ExcludeSystem -Database Northwind
        }
        It "Northwind exists on mssql1" {
            $db.Name | Should -Be 'Northwind'
            $db.Status | Should -Be 'Normal'
        }
    }

    Context "There should be no databases on mssql2" {
        BeforeAll {
            $dbs = Get-DbaDatabase -SqlInstance mssql2 -ExcludeSystem -ExcludeDatabase ReportServerTempDB, ReportServer
        }
        It "mssql2 should have no databases" {
            $dbs | Should -BeNullOrEmpty
        }
    }
    
}
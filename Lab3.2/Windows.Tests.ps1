#This demonstrates Pester by automating some the tests which students perform
#manually earlier in the exercise. It uses Context and Describe blocks to 
#logically organize the tests and results
Describe "Windows Workstation Compliance Tests" {
    Context "Local Users" {
        #This BeforeAll block will execute before any of the tests in this
        #context block are executed. The $disabledUsers variable will be available
        #to all tests
        BeforeAll {
            $disabledUsers = (Get-LocalUser | Where-Object Enabled -eq $False).Name
        }
        It "Local admin account disabled" {
            
            $disabledUsers | Should -Contain "administrator"
        }
        It "Guest user disabled" {
            $disabledUsers | Should -Contain "Guest"
        }
        It "Power users group should be empty" {
            (Get-LocalGroupMember -Name 'Power Users').Count | Should -Be 0
        }
    }
    Context "Windows Registry" {
        It "LimitBlankPasswordUse is enabled" {
            (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa").LimitBlankPasswordUse | 
                Should -Be 1
        }
        It "NoLMHash is enabled" {
            (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa").NoLMHash | 
                Should -Be 1
        }
        It "LimitBlankPasswordUse is enabled" {
            (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa").RestrictAnonymous | 
                Should -Be 1
        }
    }
    Context "Local Security Policy"{
        #Save the local policy as a text file before running the tests in this Context block
        BeforeAll {
            SecEdit.exe /export /cfg .\localSecPolicy.txt
            $localPolicy = Get-Content .\localSecPolicy.txt
        }
        #Delete the local policy export file when finished with the tests in this Context block
        AfterAll {
            Remove-Item .\localSecPolicy.txt
        }
        It "MinimumPasswordAge > 7" {
            ($localPolicy | Select-String "MinimumPasswordAge" -NoEmphasis) `
                -Replace 'MinimumPasswordAge = ', '' | 
                Should -BeGreaterOrEqual 7
        }
        It "MaximumPasswordAge > 30" {
            ($localPolicy | Select-String "MaximumPasswordAge" -NoEmphasis) `
                -Replace 'MaximumPasswordAge = ', '' | 
                Should -BeGreaterOrEqual 30
        }
    }
    Context "Services" {
        It "OSQuery service properly configured" {
            (Get-Service -Name 'osqueryd').Count | Should -Be 1
            (Get-Service -Name 'osqueryd').Status | Should -Be 'Running'
            (Get-Service -Name 'osqueryd').StartType | Should -BeLike 'Automatic*'
        }
    }
}
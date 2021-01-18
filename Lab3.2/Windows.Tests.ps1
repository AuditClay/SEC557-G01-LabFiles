#This demonstrates Pester by automating some the tests which students perform
#manually earlier in the exercise. It uses Context and Describe blocks to 
#logically organize the tests and results
Describe "Windows Workstation Compliance Tests" {
    Context "Local Users" {
        #This BeforeAll block will execute before any of the tests in this
        #context block are executed. The $disabledUsers variable will be available
        #to all tests
        BeforeAll {
            $disabledUsers = Get-LocalUser | Where-Object Enabled -eq $False
        }
        It "Local admin account disabled" {
            
            "administrator" | Should -BeIn $disabledUsers
        }
        It "Guest user disabled" {
            $disabledUsers | Should -Contain "Guest"
        }
    }
    Context "Local Security Policy"{

    }
    Context "Services" {

    }
}
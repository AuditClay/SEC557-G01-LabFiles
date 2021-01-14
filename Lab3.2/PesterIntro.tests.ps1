Describe "SEC557 Pester Example Context" {
    Context "Test Set 1" {
        It "My first Pester test" {
            $true | Should -Be $true
        }

        It "A test that will fail" {
            $true | Should -not -Be $false
        }

        It "Be is non case sensitive" {
            'SEC557' | Should -Be 'sec557'
        }

        It "BeExactly is case sensitive" {
            'SEC557' | Should -Not -BeExactly 'Sec557'
        }

        It "Demonstrate BeLike"{
            $testValue = "Test Value"            
            $testValue | Should -BeLike '*val*'
        }

        It "Demonstrate BeLike"{
            $testValue = "Test Value"            
            $testValue | Should -BeLikeExactly '*Val*'
        }

        It "Demonstrate FileContentMatch" {
Set-Content -Path '.\testFile.txt' -Value "Test`nFile"
#tests all pass
'.\testFile.txt' | Should -FileContentMatch 'test'
'.\testFile.txt' | Should -FileContentMatchExactly 'Test'
'.\testFile.txt' | Should -FileContentMatchMultiline 'Test\nFile'
        }

        It "Demonstrate -BeIn" {
            $list = 1..6
            5 | Should -BeIn $list
        }

        It "Demonstrate -Contain" {
            $list = 1..6
            $list | Should -Contain 8
        }

        It "Demonstrate BeNullOrEmpty" {
            'Hello World' | Should -Not -BeNullOrEmpty
        }
    }

    Context "Test Set 2" {
        It "Set 2 - Test 1" {
            [Math]::PI | Should -BeGreaterThan 3
        }

        It "Pi is less than 3.2" {
            [Math]::PI | Should -BeLessOrEqual 3.1
        }
    }
}
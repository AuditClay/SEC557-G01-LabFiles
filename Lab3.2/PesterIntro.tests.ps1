Context "SEC557 Pester Example Context" {
    Describe "Test Set 1" {
        It "My first Pester test" {
            $true | Should -Be $true
        }

        It "A test that will fail" {
            $true | Should -Be $false
        }
    }

    Describe "Test Set 2" {
        It "Set 2 - Test 1" {
            [Math]::PI | Should -BeGreaterThan 3
        }

        It "Set 2 - Test 2" {
            [Math]::PI | Should -BeLessOrEqual 3.1
        }
    }
}
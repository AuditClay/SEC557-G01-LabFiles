Context "SEC557 Pester Example Context" {
    Describe "Test Set 1" {
        It "My first Pester test" {
            $true | Should -Be $true
        }

        It "A test that will fail" {
            $true | Should -Be $false
        }
    }
}
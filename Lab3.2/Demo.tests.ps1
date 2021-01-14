Describe "SEC557 Pester Example Context" {
    Context "Test Set 1" {
        It "Demonstrate exactly operators" {
            #test passes
            'SEC557' | Should -Be 'Sec557'
            #test fails
            'SEC557' | Should -Be Exactly 'Sec557'
        }
    }
}
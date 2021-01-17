Describe "Local Linux Tests" {
    #Context blocks are used to group related tests. Since all of our tests
    #are for registry settings related to the user policy, we'll use
    #a single Context block
    Context "Linux OS Configuraton" {
         #It blocks contain the individual tests. If you have a paragraph number from
         #a policy, you can include it in the test name
         It "Distribution is Ubuntu 20.04.1 LTS" {
           #Get the relevant setting
           $distro = (lsb_release -d)
           #Policy calls for the distro to be Ubuntu 20.04.1 LTS
           $distro | Should -BeLike '*Ubuntu 20.04.1 LTS'
         }
     
         It "Kernel version is 5.4.0-52" {
           $kernel = (uname -r)
           $kernel | Should -Be '5.4.0-52-generic'
         }
    
         It "TCP syn cookies are enabled" {
           $setting = (sysctl net.ipv4.tcp_syncookies)
           $setting | Should -Match "= 1$"
         }
     }
 
     Context "SSH Configuration" {
       It "SSH permit root login disabled" {
         $setting = (sudo sshd -T | grep -i PermitRootLogin)
         $setting | Should  -Match "PermitRootLogin no"
       }
 
       It "SSH does not allow X11 forwarding" {
         $setting = (sudo sshd -T | grep -i X11Forwarding)
         $setting | Should  -Match "X11Forwarding no"
       }
     }
 
     Context "Installed Software" {
         It "Python is correct version" {
           $pythonVersion = (python3 -V)
           $pythonVersion | Should -BeLike '*3.8.5'
         }
    }
 }
 
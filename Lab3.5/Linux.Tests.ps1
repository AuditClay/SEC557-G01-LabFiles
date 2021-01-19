#This scripts demonstrates how to run Linux compliance checks
#on Linux using Pester. It uses Context blocks to divide the tests
#into logical groups based on the sort of information being tested.
Describe "Local Linux Tests" {
  #Tests related to the OS
  Context "Linux OS Configuraton" {
    #Check distro version against standard
    It "Distribution is Ubuntu 20.04.1 LTS" {
      #Get the relevant setting
      $distro = (lsb_release -d)
      #Policy calls for the distro to be Ubuntu 20.04.1 LTS
      $distro | Should -BeLike '*Ubuntu 20.04.1 LTS'
    }
    #Kernel version
    It "Kernel version is 5.4.0-52" {
      $kernel = (uname -r)
      $kernel | Should -Be '5.4.0-52-generic'
    }
    #TCP DoS protection 
    It "TCP syn cookies are enabled" {
      $setting = (sysctl net.ipv4.tcp_syncookies)
      $setting | Should -Match "= 1$"
    }
  }
  #SSH settings
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
  #Software
  Context "Installed Software" {
    It "Python is correct version" {
      $pythonVersion = (python3 -V)
      $pythonVersion | Should -BeLike '*3.8.5'
    }
  }
}
 
if { $argc != 10 } {
  puts "The launch script requires 8 arguments"
  exit 1
}

# Parse Flags
while {[llength $argv]} {
  #   puts $argv
  set flag [lindex $argv 0]
  #puts "flag: ($flag)"

  switch -glob $flag {
    -app_name  {
      set app_name [lindex $argv 1]
      set argv  [lrange $argv 2 end]

    } -hw_file {
      set hw_file  [lindex $argv 1]
      set argv  [lrange $argv 2 end]

    } -bit_file {
      set bit_file  [lindex $argv 1]
      set argv  [lrange $argv 2 end]

    } -elf_file {
      set elf_file  [lindex $argv 1]
      set argv  [lrange $argv 2 end]

    } -jtag_cable_name {
      set jtag_cable_name  [lindex $argv 1]
      set argv  [lrange $argv 2 end]

    } -h* {
      #help
      puts "USAGE:"
      puts "-app_name: name of the vitis project"
      puts "-hw_file: location of the .xsa hardware file"
      puts "-bit_file: location of the bit file"
      puts "-elf_file: location of the .elf executable file"
      puts "-jtag_cable_name: name of the jtag cable, fount in Vitis log"
      exit 1

    } -* {
      # unknown option
      error "unknown option [lindex $argv 0], use -h for help"

    } default break
  }
}

# check if we have all files
lindex $app_name
lindex $hw_file
lindex $bit_file
lindex $elf_file
lindex $jtag_cable_name

# give vits some more time to start up
configparams vitis-launch-timeout 180

# set the vitis worspace
setws ../vitis_workspace
cd ../vitis_workspace

connect -url tcp:127.0.0.1:3121
targets -set -nocase -filter {name =~"APU*"}
rst -system
after 3000
targets -set -filter {jtag_cable_name =~ "${jtag_cable_name}" && level==0} -index 1
fpga -file $bit_file
targets -set -nocase -filter {name =~"APU*"}
loadhw -hw $hw_file -mem-ranges [list {0x40000000 0xbfffffff}]
configparams force-mem-access 1
targets -set -nocase -filter {name =~"APU*"}
source $app_name/_ide/psinit/ps7_init.tcl
ps7_init
ps7_post_config
targets -set -nocase -filter {name =~ "*A9*#0"}
dow $elf_file
configparams force-mem-access 0
targets -set -nocase -filter {name =~ "*A9*#0"}
con


if { $argc != 6 } {
  puts "The test gui script requires 6 arguments"
  exit 1
}

# Parse Flags
while {[llength $argv]} {
  set flag [lindex $argv 0]

  switch -glob $flag {
    -xilinx_vivado  {
      set xilinx_vivado [lindex $argv 1]
      set argv  [lrange $argv 2 end]

    } -library_name  {
      set library_name [lindex $argv 1]
      set argv  [lrange $argv 2 end]

    } -tb_name  {
      set tb_name [lindex $argv 1]
      set argv  [lrange $argv 2 end]

    } -h* {
      #help
      puts "USAGE:"
      puts "-xilinx_vivado: location of the vivado installation dir"
      puts "-library_name: library the vhld files should be put in"
      puts "-tb_name: name of the testbench to open"
      exit 1

    } -* {
      # unknown option
      error "unknown option [lindex $argv 0], use -h for help"

    } default break
  }
}

# extra check if we have all arguments
lindex $xilinx_vivado
lindex $library_name
lindex $tb_name

# set environment variable so xvhdl, xsim and xelab can be found
set env(XILINX_VIVADO) $xilinx_vivado

# create a simulation project file so the compilation order is done automatically
file delete test_project.prj
set fp [open "test_project.prj" w+]
set all_src_files [glob -directory ../src/ip/vhdl/ -- "*.vhd"]
foreach path $all_src_files {
  puts $fp "vhdl $library_name \"$path\""
}
set all_test_files [glob -directory ../src/sim/vhdl/ -- "*.vhd"]
foreach path $all_test_files {
  puts $fp "vhdl test_lib \"$path\""
}
close $fp

set exit_code 0

# run xsim gui
exec xsim sim_snapshot_$tb_name -gui

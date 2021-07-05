if { $argc != 4 } {
  puts "The test script requires 4 arguments"
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

    } -h* {
      #help
      puts "USAGE:"
      puts "-xilinx_vivado: location of the vivado installation dir"
      puts "-library_name: library the vhld files should be put in"
      exit 1

    } -* {
      # unknown option
      error "unknown option [lindex $argv 0], use -h for help"

    } default break
  }
}

# check if we have all files
lindex $xilinx_vivado
lindex $library_name

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

# run tests
set all_test_benches [glob -directory ../src/sim/vhdl/ -- "*_tb.vhd"]
foreach path $all_test_benches {
  set test [file rootname [file tail $path]]
  put [exec ../../scripts/bash/pretty_print.sh " ${test} "]
  set output [exec xelab -debug all -incremental -s sim_snapshot_${test} -prj test_project.prj -R test_lib.${test}]
  put $output
  if {[regexp {\nFailure:} $output]} {
    set exit_code 1
  } elseif {[regexp {\nFATAL_ERROR:} $output]} {
    set exit_code 1
  }
}
exit $exit_code

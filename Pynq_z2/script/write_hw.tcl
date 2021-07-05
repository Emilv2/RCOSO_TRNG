if { $argc != 2 } {
  puts "The write_hw script requires 2 arguments"
  exit 1
}

# Parse Flags
while {[llength $argv]} {
  #   puts $argv
  set flag [lindex $argv 0]
  #puts "flag: ($flag)"

  switch -glob $flag {
    -ip_name  {
      set ip_name [lindex $argv 1]
      set argv  [lrange $argv 2 end]

    } -h* {
      #help
      puts "USAGE:"
      puts "-ip_name: name of the vivado ip"
      exit 1

    } -* {
      # unknown option
      error "unknown option [lindex $argv 0], use -h for help"

    } default break
  }
}

# open the post route checkpoint
open_checkpoint ../output/post_route.dcp

# allow combinatorial loops
set_property SEVERITY {Warning}  [get_drc_checks LUTLP-1]
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]

write_hw_platform -fixed -force  -include_bit -file ../output/design_1_wrapper_${ip_name}.xsa

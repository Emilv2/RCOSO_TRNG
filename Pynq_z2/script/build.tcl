if { $argc != 4 } {
  puts "The launch script requires 4 arguments"
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

    } -h* {
      #help
      puts "USAGE:"
      puts "-app_name: name of the vitis project"
      puts "-hw_file: location of the .xsa hardware file"
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

# give vits some more time to start up
configparams vitis-launch-timeout 180

# set the vitis worspace
setws ../vitis_workspace
cd ../vitis_workspace

# bug, include files are not copied when using tcl build so we copy them manually
# if you need more build the project using the Vitis IDE and copy them into src/include
# might be this, but we are using bash and not dash
# https://forums.xilinx.com/t5/Embedded-Development-Tools/Vitis-2019-2-FSBL-fatal-error/td-p/1067629
#set source_dir ../src/include
#set hw_name [file rootname [file tail $hw_file]]
#set target_dir ${hw_name}/ps7_cortexa9_0/standalone_domain/bsp/ps7_cortexa9_0/include

#foreach f [glob -directory $source_dir -nocomplain *] {
#    file copy -force $f $target_dir
#}

# make symbolic links for all the source files instead of copying them
set all_source_files [glob -directory ../src/c/ -- "*.{c,h}"]
foreach path $all_source_files {
  set f [file tail $path]
  catch {
    file link -symbolic ./$app_name/src/$f ../../$path
  }
}

app build $app_name
# needed?
#sysproj build ${app_name}_system

if { $argc != 4 } {
  puts "The setup platform script requires 4 arguments"
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

# create the vitis workspace if it doesn't exsit
file mkdir ../vitis_workspace

# recreate project
setws ../vitis_workspace
cd ../vitis_workspace

app create -name ${app_name} -hw ${hw_file} -os standalone -proc ps7_cortexa9_0 -template {Empty Application}

# make symbolic links for all the source files instead of copying them
set all_source_files [glob -directory ../src/c/ -- "*.{c,h}"]
foreach path $all_source_files {
  set f [file tail $path]
  file link -symbolic ./$app_name/src/$f ../../$path
}

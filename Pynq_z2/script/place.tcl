# open the post setup checkpoint
open_checkpoint ../output/post_synth.dcp

source init.tcl

# place the design
place_design

# write a checkpoint that we can reuse for routing
write_checkpoint -force ../output/post_place

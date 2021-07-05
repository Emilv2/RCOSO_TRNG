################################################################################
##                                    Route                                   ##
################################################################################

source init.tcl

# open the post placement checkpoint
open_checkpoint ../output/post_place.dcp

# route the design
route_design

# write a checkpoint that we can reuse for write hardware
write_checkpoint -force ../output/post_route

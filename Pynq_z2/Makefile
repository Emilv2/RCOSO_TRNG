ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
export PATH := $(ROOT_DIR)/../scripts/bash:$(PATH)

XILINX_INSTALL_DIR=/tools
XILINX_VERSION=2019.2
XILINX_VIVADO=$(XILINX_INSTALL_DIR)/Xilinx/Vivado/$(XILINX_VERSION)
VIVADO=$(XILINX_INSTALL_DIR)/Xilinx/Vivado/$(XILINX_VERSION)/bin/vivado
XSCT=$(XILINX_INSTALL_DIR)/Xilinx/Vitis/$(XILINX_VERSION)/bin/xsct
HW_SERVER=$(XILINX_INSTALL_DIR)/Xilinx/Vitis/$(XILINX_VERSION)/bin/hw_server

JTAG_CABLE_NAME="Xilinx TUL 1234-tulA"

IP_NAME=mux_ro_variance
IP_MAJOR_VERSION=1
IP_MINOR_VERSION=0
LIBRARY_NAME=coso_lib
VITIS_APP_NAME=mux_ro_variance_app
HW_SERVER_PID_FILE=hw_server.pid


output/post_synth.dcp: script/synth.tcl script/create_bd.tcl src/ip/vhdl*/*.vhd $(wildcard src/constraints/*.xdc)
	@ pretty_print.sh " Setup and Synthetisize Design "
	@ mkdir -p $(ROOT_DIR)/output
	cd $(ROOT_DIR)/script; $(VIVADO) \
		-mode batch \
		-source synth.tcl \
		-log ../output/synth.log \
		-nojournal \
		-tclargs \
			-ip_name $(IP_NAME) \
			-ip_major_version $(IP_MAJOR_VERSION) \
			-ip_minor_version $(IP_MINOR_VERSION) \
			-library_name $(LIBRARY_NAME)


synth:  output/post_synth.dcp ## synthetisize
	@ sleep 1
	@ pretty_print.sh " Synthetization finished "

post_synth_gui:  output/post_synth.dcp ## synthetisize the design and open the gui
	@ pretty_print.sh " Open Synthetisized Design "
	@ pretty_print.sh " Run write_xdc to write user constraints and add them to src/constraints/ "
	cd $(ROOT_DIR)/script; $(VIVADO) -mode batch -source post_synth_gui.tcl -tclargs


output/post_place.dcp:  script/place.tcl output/post_synth.dcp
	@ pretty_print.sh " Place Design "
	cd $(ROOT_DIR)/script; $(VIVADO) \
		-mode batch \
		-source place.tcl \
		-log ../output/place.log \
		-nojournal

place:  output/post_place.dcp ## place the design
	@ sleep 1
	@ pretty_print.sh " Placement finished "

post_place_gui:  output/post_place.dcp ## place the design and open the gui
	@ pretty_print.sh " Open Placed Design "
	cd $(ROOT_DIR)/script; $(VIVADO) -mode batch -source post_place_gui.tcl -tclargs


output/post_route.dcp:  script/route.tcl output/post_place.dcp
	@ pretty_print.sh " Route Design "
	cd $(ROOT_DIR)/script; $(VIVADO) \
		-mode batch \
		-source route.tcl \
		-log ../output/route.log \
		-nojournal

route:  output/post_route.dcp ## route the design
	@ pretty_print.sh " Routing finished "

post_route_gui:  output/post_route.dcp ## place the design and open the gui
	@ pretty_print.sh " Open Routed Design "
	cd $(ROOT_DIR)/script; $(VIVADO) -mode batch -source post_route_gui.tcl -tclargs


output/design_1_wrapper_$(IP_NAME).xsa:  script/write_hw.tcl output/post_route.dcp
	@ pretty_print.sh " Write Hardware "
	rm -rf vitis_workspace; \
	cd $(ROOT_DIR)/script; $(VIVADO) \
		-mode batch \
		-source write_hw.tcl \
		-log ../output/write_hw.log \
		-nojournal \
		-tclargs \
			-ip_name $(IP_NAME)

write_hw:  output/design_1_wrapper_$(IP_NAME).xsa ## write the xsa hw_file
	@ pretty_print.sh " Writing hardware finished "


vitis_workspace/$(VITIS_APP_NAME)/_ide/bitstream/design_1_wrapper_$(IP_NAME).bit: script/setup_platform.tcl output/design_1_wrapper_$(IP_NAME).xsa
	@ pretty_print.sh " Setup Vitis Platform "
	cd $(ROOT_DIR)/script; $(XSCT) setup_platform.tcl \
		-app_name $(VITIS_APP_NAME) \
		-hw_file ../output/design_1_wrapper_$(IP_NAME).xsa

setup_platform: vitis_workspace/$(VITIS_APP_NAME)/_ide/bitstream/design_1_wrapper_$(IP_NAME).bit ## create the vitis platform and app
	@ pretty_print.sh " Setup platform finished "


vitis_workspace/$(VITIS_APP_NAME)/Debug/$(VITIS_APP_NAME).elf: script/build.tcl vitis_workspace/$(VITIS_APP_NAME)/_ide/bitstream/design_1_wrapper_$(IP_NAME).bit src/c/*.c src/c/*.h
	@ pretty_print.sh " Build Software "
	cd $(ROOT_DIR)/script; /bin/bash build.sh \
		--xsct $(XSCT) \
		--app_name $(VITIS_APP_NAME) \
		--hw_file ../output/design_1_wrapper_$(IP_NAME).xsa \
		--elf_file ../vitis_workspace/$(VITIS_APP_NAME)/Debug/$(VITIS_APP_NAME).elf

build: vitis_workspace/$(VITIS_APP_NAME)/Debug/$(VITIS_APP_NAME).elf ## build the application software
	@ pretty_print.sh " Vitis build finished "


launch: script/launch.tcl vitis_workspace/$(VITIS_APP_NAME)/Debug/$(VITIS_APP_NAME).elf ## launch the application on the hardware
	@ pretty_print.sh " Launch on Hardware "
	/bin/bash script/start_hw_server.sh $(HW_SERVER) $(HW_SERVER_PID_FILE)
	cd $(ROOT_DIR)/script; $(XSCT) launch.tcl \
		-app_name $(VITIS_APP_NAME) \
		-hw_file ../output/design_1_wrapper_$(IP_NAME).xsa \
		-bit_file $(VITIS_APP_NAME)/_ide/bitstream/design_1_wrapper_$(IP_NAME).bit \
		-elf_file $(VITIS_APP_NAME)/Debug/$(VITIS_APP_NAME).elf \
		-jtag_cable_name $(JTAG_CABLE_NAME) \
		|| { pretty_print.sh " Launch failed "; exit 1; }
	@ pretty_print.sh " Launch finished "



test:	## run simulation tests
	@  pretty_print.sh " Running Tests "
	@ mkdir -p $(ROOT_DIR)/output
	@ mkdir -p $(ROOT_DIR)/sim
	cd $(ROOT_DIR)/sim; $(VIVADO) \
		-mode batch \
		-source ../script/test.tcl \
		-notrace \
		-log ../output/test.log \
		-nojournal \
		-tclargs \
			-xilinx_vivado $(XILINX_VIVADO) \
			-library_name $(LIBRARY_NAME)


tb_gui-%: sim/xsim.dir/sim_snapshot_% ## run simulation gui for test %
	@ pretty_print.sh " Running testbench $(subst tb_gui-,,$@) "
	cd $(ROOT_DIR)/sim; $(VIVADO)\
		-mode batch \
		-source ../script/test_gui.tcl \
		-notrace \
		-log ../output/test.log \
		-nojournal \
		-tclargs \
			-xilinx_vivado $(XILINX_VIVADO) \
			-library_name $(LIBRARY_NAME) \
			-tb_name $(subst tb_gui-,,$@)


clean: clean_vitis clean_vivado ## remove all autogenerated files


clean_vivado: ## remove vivado autogenerated files
	@  pretty_print.sh " Removing Vivado autogenerated files... "
	rm -rf ./IP
	rm -rf ./script/.srcs
	rm -rf ./script/.cache
	rm -rf ./script/.Xil
	rm -rf ./output/
	rm -rf ./sim/


clean_vitis: ## remove vitis autogenerated files
	@ pretty_print.sh " Removing Vitis autogenerated files... "
	bash script/stop_hw_server.sh $(HW_SERVER_PID_FILE)
	rm -f $(HW_SERVER_PID_FILE)
	rm -rf ./vitis_workspace/


tidy: ## autofix the c and vhdl code


help:  # http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
	@grep -P '^[%a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'


.DEFAULT_GOAL := help
.PHONY: help clean clean_vitis synth place route write_hw setup_platform build launch test tb_gui-% tidy

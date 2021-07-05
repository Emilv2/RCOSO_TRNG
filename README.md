# TRNG

This is a reference implementation for the Reconfigurable COherent Sampling ring Oscillator based True Random Number Generator.

## Running

If you have a Pynq_z2 device the code can be tested by running `make launch` in the `Pynq_z2` folder.
Edit the `XILINX_INSTALL_DIR` and `XILINX_VERSION` according to your local Xilinx installation folder and version.
Vivado and Vitis are required.
The code is tested with Vivado and Vitis 2019.2 on Linux, but should work with other versions too.

This reference implementation implements 32 TRNGs spread over the FPGA board,
change the `trng` variable in the file `Pynq_z2/src/c/main.c` to select the output of a different FPGA.

If you have another board you can add it into the `board_store` folder and update the `Pynq_z2/script/create_bd.tcl` file,
or add the files in the folder `Pynq_z2/src/ip/vhdl/` into your own project.


## Caputuring output
You can capture the output from the FPGA using uart.
A python script is available in `scripts/python/`
Install the requirements with:

```
pip3 install -r requirements.txt
```

Run the capture script with:

```
python3 scripts/python/rand_uart_control.py rand_out.bin
```

You will get a file `rand_out.bin` with 16 MiB of consecutive random bits and a text file named `rand_out.bin_throughput` with the throughput in Mb/s.
Capturing this data over uart takes about ~55 minutes.

Rerun `make launch` if you get an error like this:

```
'utf-8' codec can't decode byte 0xf9 in position 7: invalid start byte
```

You might need to rerun it several times, sometimes pulling out and reconnecting the Pynq board cable helps too.

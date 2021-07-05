#!/usr/bin/python3

import os
import re
import sys
import time

import serial
import pandas as pd
from matplotlib.ticker import EngFormatter

FREQUENCY = 100e6
DATA_LEN = 4194304 * 32
COUNT_DIV = 1000

CSCNT_PATTERN = r"^Start cscnt ([0-9]+)$"

rand_file = sys.argv[1]
throughput_txt_file = rand_file + "_throughput"

if os.path.exists(rand_file):
    print("rand file already exists!")
    exit(1)

serial = serial.serial_for_url("/dev/ttyUSB1", 115200)
print("waiting...")
while True:
    try:
        line = serial.readline().decode("utf-8").strip("\r\n")
        if line == "Start test":
            print("start test")
            break
    except UnicodeDecodeError as e:
        print(e)
i = 0
with open(rand_file, "wb") as rand_outfile, open(throughput_txt_file, "a") as throughput_file:
    while True:
        try:
            line = serial.readline().decode("utf-8").strip("\r\n")
            cscnt_match = re.match(CSCNT_PATTERN, line)

            if line == "ERROR!":
                print("Error occured!")
                break
            elif line == "End test":
                break
            elif line == "Time passed":
                current_data = "time"
            elif line == "Failed":
                print("Failed, no match found")
                # break
            elif cscnt_match:
                current_data = "cscnt"
                current_i = cscnt_match.groups()[0]
                print(f"{current_i=}")
            elif current_data == "cscnt":
                if i < 10:
                    print("{0:032b}".format(int(line, 16)))
                    i += 1
                rand_outfile.write(int(line, 16).to_bytes(4, "big"))
            elif current_data == "time":
                ticker = EngFormatter(unit="b/s")
                print(f"Time passed: {line}")
                throughput = f"Throughput: {ticker.format_data((DATA_LEN*FREQUENCY)/(int(line)*COUNT_DIV))}"
                print(throughput)
                throughput_file.write(throughput)
        except Exception as e:  # noqa E722
            print("uart error!, but we'll try to continue")
            import pdb; pdb.set_trace()
            print(e, line)
            time.sleep(0.003)

print("done")

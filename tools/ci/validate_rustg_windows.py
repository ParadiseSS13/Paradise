# Script to validate RUSTG DLL functions under windows (Running DD under windows in a CI environment is pain)
# Author: AffectedArc07
# This script is invoked by GitHub actions as part of CI to validate that the windows DLL for RUSTG works and creates proper formats

# Imports
import os, json
from ctypes import *
from datetime import datetime, timedelta

# Initial vars
ci_log_file = "ci_log.log"
ci_testing_text = "This is a test message"
ci_toml_file_location = "config/example/config.toml"

# Helpers
def success(msg):
    print("[Y] {}".format(msg))

def fail(msg):
    print("[X] {}".format(msg))
    exit(1) # Exit with 1 to fail the CI

# Cleanup
if os.path.exists(ci_log_file):
    os.remove(ci_log_file)

# Check the DLL exists at all
if os.path.exists("rust_g.dll"):
    success("RUSTG Dll exists")
else:
    fail("RUSTG Dll does NOT exist")

# Check DM header file exists
if os.path.exists("code/__DEFINES/rust_g.dm"):
    success("RUSTG DM header file exists")
else:
    fail("RUSTG DM header file does NOT exist")

# Parse the version from the DM file
f = open("code/__DEFINES/_versions.dm", "r")
lines = f.readlines()
f.close()
dm_version = None
for line in lines:
    if line.startswith("#define RUST_G_VERSION"):
        dm_version = line.split("#define RUST_G_VERSION")[1].strip().strip("\"")
        break

if not dm_version:
    fail("Could not detect RUSTG version inside DM header file")

# Begin DLL loading
rustg_dll = CDLL("./rust_g.dll")


# Set args for version retrieval
rustg_dll.get_version.restype = c_char_p
dll_version = rustg_dll.get_version().decode()

if dll_version == dm_version:
    success("DLL and DM versions match")
else:
    fail("DLL and DM version mismatch! Got {} DM version, got {} DLL version".format(dm_version, dll_version))

# Now test log writing. This hurt to write.
string_array = c_char_p * 2
sa = string_array(bytes(ci_log_file, "ascii"), bytes(ci_testing_text, "ascii"))
rustg_dll.log_write.argtypes = [c_int, c_char_p * 2]

timestamp = datetime.now()

# Generate valid results for the time now and the next 2 seconds. This is so we can account for spurious CI lag.
valid_results = []
for count in range(3):
    timestamp_text = timestamp.strftime('[%Y-%m-%dT%H:%M:%S]') # 8601 is king
    valid_results.append("{} {}".format(timestamp_text, ci_testing_text))
    timestamp = timestamp + timedelta(seconds=1)

# Invoke this now we have prepared
rustg_dll.log_write(2, sa)

# Now read the output back
logfile = open(ci_log_file, "r")
logline = logfile.readlines()[0].strip("\n") # Remove newline
logfile.close()

if logline in valid_results:
    success("Log timestamp is valid 8601")
else:
    fail("Log timestamp is not valid 8601. Got {}".format(logline))

# Make sure we can parse TOML
string_array = c_char_p * 1
sa = string_array(bytes(ci_toml_file_location, "ascii"))
rustg_dll.toml_file_to_json.argtypes = [c_int, c_char_p * 1]
# Set args for JSON retrieval
rustg_dll.toml_file_to_json.restype = c_char_p

try:
    # Run it
    output_json = rustg_dll.toml_file_to_json(1, sa).decode()
    json.loads(output_json)
    success("toml_file_to_json successful")
except Exception:
    fail("Failed to run toml_file_to_json")

exit(0) # Success

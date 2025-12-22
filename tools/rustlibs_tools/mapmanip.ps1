
# if you want to run this script but it opens in notepad
# you may want to right click it and "run with powershell"

# script explanation
echo "*****"
echo "This script will run map manipulations on every `.dmm` map that has a `.jsonc` config file,"
echo "and write it to a `.mapmanipout.dmm` file in the same location."
echo "Make sure to not commit these files to the repo."
echo "This script will not show any error messages if map manipulations have failed."
echo "Should launch the actual server to get stacktraces and the like."
echo "*****"

# find path to rustlibs.dll
if (Test-Path "./rust/target/i686-pc-windows-msvc/release/rustlibs.dll") {
	$BapiPath = "./rust/target/i686-pc-windows-msvc/release/rustlibs.dll"
}
elseif (Test-Path "./rust/target/i686-pc-windows-msvc/debug/rustlibs.dll") {
	$BapiPath = "./rust/target/i686-pc-windows-msvc/debug/rustlibs.dll"
}
elseif (Test-Path "./rustlibs.dll") {
	$BapiPath = "./rustlibs.dll"
}
else {
	echo "Cannot find rustlibs."
}

# run ffi function from rustlibs.dll
echo "Executing..."
$BapiDllFunction = "all_mapmanip_configs_execute_ffi"
$BapiExecutionTime = Measure-Command {
	# `rundll` runs a function from a dll
	# the very sad limitation is that it does not give any output from that function
	rundll32.exe $BapiPath $BapiDllFunction
}

# done
echo "Done!"
echo ("Took {0} seconds, or {1} milliseconds in total." -f $BapiExecutionTime.Seconds, $BapiExecutionTime.Milliseconds)
echo "*****"
Read-Host -Prompt "Press Enter to exit..."

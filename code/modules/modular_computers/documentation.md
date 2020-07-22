

#Modular computer programs
Ok. so a quick rundown on how to make a program. This is kind of a shitty documentation, but oh well I was asked to.


## Base setup
This is how the base program is setup. the rest is mostly tgui stuff. I'll use the ntnetmonitor as a base


```DM
/datum/computer_file/program/ntnetmonitor
	filename = "ntmonitor"	//This is obviously the name of the file itself. not much to be said
	filedesc = "NTNet Diagnostics and Monitoring"	// This is sort of the official name. it's what shows up on the main menu
	program_icon_state = "comm_monitor"	// This is what the screen will look like when the program is active
	extended_desc = "This program is a dummy. // This is a sort of a description, visible when looking on the ntnet
	size = 12	// size of the program. Big programs need more hard drive space. Don't make it too big though.
	requires_ntnet = 1	// If this is set, the program will not run without an ntnet connection, and will close if the connection is lost. Mainly for primarily online programs.
	required_access = access_network	//This is access required to run the program itself. ONLY SET THIS FOR SUPER SECURE SHIT. This also acts as transfer_access as well.
	transfer_access = access_change_ids	// This is the access needed to download from ntnet or host on the ptp program. This is what you want to use most of the time.
	available_on_ntnet = 1 //If it's available to download on ntnet. pretty self explanatory.
	available_on_syndinet = 0 // ditto but on emagged syndie net. Use this for antag programs
	usage_flags = PROGRAM_ALL			// Bitflags (PROGRAM_CONSOLE, PROGRAM_LAPTOP, PROGRAM_TABLET combination) or PROGRAM_ALL
				//^^- The comment above sorta explains it. Use this to limit what kind of machines can run the program. For example, comms program should be limited to consoles and laptops.
	var/ui_header = "downloader_finished.gif" //This one is kinda cool. If you have the program minimized, this will show up in the header of the computer screen.
											//you can even have the program change what the header is based on the situation! see alarm.dm for an example.
```

##Preinstalls
Now. for pre-installing stuff.

Primarily done for consoles, there's an install_programs() proc in the console presets file in the machines folder.

for example, the command console one.

```DM
/obj/machinery/modular_computer/console/preset/command/install_programs()
	cpu.hard_drive.store_file(new/datum/computer_file/program/chatclient())
	cpu.hard_drive.store_file(new/datum/computer_file/program/card_mod())
```
Basically, you want to do  cpu.hard_drive.store_file(new/*program path here*()) and put it in the subtype's install_programs().
Probably pretty self explanatory, but just in case.

Will probably be expanded when new features come around or I get asked to mention something.


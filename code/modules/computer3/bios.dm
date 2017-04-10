/*
	Okay so my last effort to have a central BIOS function was interesting
	but completely unmaintainable, I have scrapped it.

	The parts that were actually useful will be put here in functions instead.
	If we want a central bios function we can add one that just indexes them.
	That should at least allow sensible debugging.
*/

/obj/machinery/computer3

	/*
		interactable(user): performs all standard sanity checks
		Call in topic() and interact().
	*/
	proc/interactable(var/mob/user)
		if( !src || !user || stat || user.stat || user.lying || user.blinded )
			return 0
		if(!program)
			return 0

		if(!istype(loc,/turf) || !istype(user.loc,/turf)) // todo handheld maybe
			return 0

		if(istype(user,/mob/living/silicon))
			if(!program.ai_allowed)
				to_chat(user, "\blue You are forbidden from accessing this program.")
				return 0
		else
			if(program.human_controls)
				if(!ishuman(user))
					to_chat(user, "\red Your body can't work the controls!")
					return 0
				if(user.restrained())
					to_chat(user, "\red You need a free hand!")
					return 0

			if(!in_range(src,user))
				// telekinesis check
				if(ishuman(user) && istype(user.get_active_hand(),/obj/item/tk_grab))
					if(program.human_controls)
						to_chat(user, "\red It's too complicated to work at a distance!")
						return 0
					add_fingerprint(user)
					user.set_machine(src)
					return 1
				return 0

		add_fingerprint(user)
		user.set_machine(src)
		return 1

	/*
		Deduplicates an item list and gives you range and direction.
		This is used for networking so you can determine which of several
		identically named objects you're referring to.
	*/
	proc/format_atomlist(var/list/atoms)
		var/list/output = list()
		for(var/atom/A in atoms)
			var/title = "[A] (Range [get_dist(A,src)] meters, [dir2text(get_dir(src,A))])"
			output[title] = A
		return output

	/*
		This is used by the camera monitoring program to see if you're still in range
	*/
	check_eye(var/mob/user as mob)
		if(!interactable(user) || user.machine != src)
			if(user.machine == src)
				user.unset_machine()
			return null

		var/datum/file/program/security/S = program
		if( !istype(S) || !S.current || !S.current.status || !camnet )
			if( user.machine == src )
				user.unset_machine()
			return null

		user.reset_perspective(S.current)
		return 1

	/*
		List all files, including removable disks and data cards
		(I don't know why but I don't want to rip data cards out.
		It just seems... interesting?)
	*/
	proc/list_files(var/typekey = null)
		var/list/files = list()
		if(hdd)
			files += hdd.files
		if(floppy && floppy.inserted)
			files += floppy.inserted.files
		if(cardslot && istype(cardslot.reader,/obj/item/weapon/card/data))
			files += cardslot.reader:files
		if(!ispath(typekey))
			return files

		var/i = 1
		while(i<=files.len)
			if(istype(files[i],typekey))
				i++
				continue
			files.Cut(i,i+1)
		return files

	/*
		Crash the computer with an error.
		Todo: redo
	*/
	proc/Crash(var/errorcode = PROG_CRASH)
		if(!src)
			return null

		switch(errorcode)
			if(PROG_CRASH)
				if(usr)
					to_chat(usr, "\red The program crashed!")
					usr << browse(null,"\ref[src]")
					Reset()

			if(MISSING_PERIPHERAL)
				Reset()
				if(usr)
					usr << browse("<h2>ERROR: Missing or disabled component</h2><b>A hardware failure has occured.  Please insert or replace the missing or damaged component and restart the computer.</b>","window=\ref[src]")

			if(BUSTED_ASS_COMPUTER)
				Reset()
				os.error = BUSTED_ASS_COMPUTER
				if(usr)
					usr << browse("<h2>ERROR: Missing or disabled component</h2><b>A hardware failure has occured.  Please insert or replace the missing or damaged component and restart the computer.</b>","window=\ref[src]")

			if(MISSING_PROGRAM)
				Reset()
				if(usr)
					usr << browse("<h2>ERROR: No associated program</h2><b>This file requires a specific program to open, which cannot be located.  Please install the related program and try again.</b>","window=\ref[src]")

			if(FILE_DRM)
				Reset()
				if(usr)
					usr << browse("<h2>ERROR: File operation prohibited</h2><b>Copy protection exception: missing authorization token.</b>","window=\ref[src]")

			if(NETWORK_FAILURE)
				Reset()
				if(usr)
					usr << browse("<h2>ERROR: Networking exception: Unable to connect to remote host.</b>","window=\ref[src]")


			else
				if(usr)
					to_chat(usr, "\red The program crashed!")
					usr << browse(null,"\ref[src]")
					testing("computer/Crash() - unknown error code [errorcode]")
					Reset()
		return null

	#define ANY_DRIVE 0
	#define PREFER_FLOPPY 1
	#define PREFER_CARD 2
	#define PREFER_HDD 4


	// required_location: only put on preferred devices
	proc/writefile(var/datum/file/F, var/where = ANY_DRIVE, var/required_location = 0)
		if(where != ANY_DRIVE)
			if((where&PREFER_FLOPPY) && floppy && floppy.addfile(F))
				return 1
			if((where&PREFER_CARD) && cardslot && cardslot.addfile(F))
				return 1
			if((where&PREFER_HDD) && hdd && hdd.addfile(F))
				return 1

			if(required_location)
				return 0

		if(floppy && floppy.addfile(F))
			return 1
		if(cardslot && cardslot.addfile(F))
			return 1
		if(hdd && hdd.addfile(F))
			return 1
		return 0

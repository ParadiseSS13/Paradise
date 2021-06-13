///NAGA DUMB MACHINES STARTS HERE////
/obj/machinery/computer/nagacomputer
	name = "NT Advanced Research Computer"
	desc = "A unique kind of computer unable to be open or move without heavy lifting equipment."
	icon = 'icons/hispania/obj/machines/research.dmi'
	icon_state = "ntcomp1"
	resistance_flags = INDESTRUCTIBLE
	flags = NODECONSTRUCT
	var/used = FALSE
	var/delay = 30

/obj/machinery/computer/nagacomputer/second
	name = "NT Advanced File System Computer"
	icon_state = "ntcomp2"
	delay = 40

/obj/machinery/computer/nagacomputer/server
	name = "NT Advanced File System Computer"
	icon_state = "ntserv1"
	delay = 50

/obj/machinery/computer/nagacomputer/server2
	name = "NT Advanced File System Computer"
	icon_state = "ntserv2"
	delay = 60

/obj/machinery/computer/nagacomputer/attacked_by(obj/item/I, mob/living/user)
	if(istype(I, /obj/item/multitool)) //HACKERMAN
		if(!used)
			to_chat(user, "<span class='notice'>You start to hack into the [src]'s</span>")
			to_chat(user, "<span class='notice'>The [src]'s security system its hard but you are trying your best.</span>")
			user.visible_message("<span class='notice'>[usr] start to hack into the [src]'s</span>")
			if(!do_after(user, delay, target = src))
				playsound(loc, 'sound/machines/buzz-sigh.ogg', 30, 1)
				return TRUE
			new /obj/item/disk/nagadisks(src.drop_location())
			playsound(loc, 'sound/machines/ping.ogg', 30, 1)
			to_chat(user, "<span class='notice'>The [src]'s blinks green and gives you a disk .</span>") //idk its science lol
			used = TRUE
		else
			to_chat(user, "<span class='notice'>There's no more files useful on [src]'s</span>")

/obj/item/disk/nagadisks
	name = "NT Research Encrypted Files"
	desc = "Better keep this safe for the Decryptor."
	icon_state = "nucleardisk"
	max_integrity = 250
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 30, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/disk/nagadisks/redspaceshit
	name = "NT Results from redspace crystals"
	icon_state = "bluespacearray"
	desc = "Better keep this safe for Centcom."

/obj/machinery/computer/nagaframe
	name = "Solar Federation Code Decryptor"
	desc = "A unique kind of file system decryptor system unable to be open or move."
	icon = 'icons/hispania/obj/machines/research.dmi'
	icon_state = "ntframe1"
	resistance_flags = INDESTRUCTIBLE
	flags = NODECONSTRUCT
	var/systemdisks = 4 //Contador de discos

/obj/machinery/computer/nagaframe/attacked_by(obj/item/I, mob/living/user)
	if(istype(I, /obj/item/disk/nagadisks)) //HACKERMAN
		if(systemdisks <= 4)
			qdel(I)
			to_chat(user, "<span class='notice'>You insert the disk into [src]'s</span>")
			to_chat(user, "<span class='notice'>The [src]'s starts to process the data.</span>")
			playsound(loc, 'sound/machines/ping.ogg', 30, 1)
			systemdisks -= 1
			if(systemdisks == 0)
				atom_say("Design Ready")
				to_chat(user, "<span class='notice'>The [src]'s starts to prints the technology uncrypted disk.</span>")
				playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, 1)
				new /obj/item/disk/nagadisks/redspaceshit(src.drop_location())
			else
				atom_say("We still need [src.systemdisks] to complete decryption of the files.")
		else
			to_chat(user, "<span class='notice'>No more disks needed.</span>")

///NAGA DUMB MACHINES ENDS HERE ////

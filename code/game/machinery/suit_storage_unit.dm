//////////////////////////////////////
// SUIT STORAGE UNIT /////////////////
//////////////////////////////////////


/obj/machinery/suit_storage_unit
	name = "Suit Storage Unit"
	desc = "An industrial U-Stor-It Storage unit designed to accomodate all kinds of space suits. Its on-board equipment also allows the user to decontaminate the contents through a UV-ray purging cycle. There's a warning label dangling from the control pad, reading \"STRICTLY NO BIOLOGICALS IN THE CONFINES OF THE UNIT\"."
	icon = 'icons/obj/suitstorage.dmi'
	icon_state = "suitstorage000000100" //order is: [has helmet][has suit][has human][is open][is locked][is UV cycling][is powered][is dirty/broken] [is superUVcycling]
	anchored = 1
	density = 1
	var/mob/living/carbon/human/OCCUPANT = null
	var/obj/item/clothing/suit/space/SUIT = null
	var/SUIT_TYPE = null
	var/obj/item/clothing/head/helmet/space/HELMET = null
	var/HELMET_TYPE = null
	var/obj/item/clothing/mask/MASK = null  //All the stuff that's gonna be stored insiiiiiiiiiiiiiiiiiiide, nyoro~n
	var/MASK_TYPE = null //Erro's idea on standarising SSUs whle keeping creation of other SSU types easy: Make a child SSU, name it something then set the TYPE vars to your desired suit output. New() should take it from there by itself.
	var/isopen = 0
	var/islocked = 0
	var/isUV = 0
	var/ispowered = 1 //starts powered
	var/isbroken = 0
	var/issuperUV = 0
	var/panelopen = 0
	var/safetieson = 1
	var/cycletime_left = 0


//The units themselves/////////////////

/obj/machinery/suit_storage_unit/standard_unit
	SUIT_TYPE = /obj/item/clothing/suit/space/eva
	HELMET_TYPE = /obj/item/clothing/head/helmet/space/eva
	MASK_TYPE = /obj/item/clothing/mask/breath

/obj/machinery/suit_storage_unit/captain
	SUIT_TYPE = /obj/item/clothing/suit/space/captain
	HELMET_TYPE = /obj/item/clothing/head/helmet/space/capspace
	MASK_TYPE = /obj/item/clothing/mask/gas

/obj/machinery/suit_storage_unit/engine
	SUIT_TYPE = /obj/item/clothing/suit/space/rig/engineering
	HELMET_TYPE = /obj/item/clothing/head/helmet/space/rig/engineering
	MASK_TYPE = /obj/item/clothing/mask/breath

/obj/machinery/suit_storage_unit/ce
	SUIT_TYPE = /obj/item/clothing/suit/space/rig/elite
	HELMET_TYPE = /obj/item/clothing/head/helmet/space/rig/elite
	MASK_TYPE = /obj/item/clothing/mask/breath

/obj/machinery/suit_storage_unit/security
	SUIT_TYPE = /obj/item/clothing/suit/space/rig/security
	HELMET_TYPE = /obj/item/clothing/head/helmet/space/rig/security
	MASK_TYPE = /obj/item/clothing/mask/gas/sechailer

/obj/machinery/suit_storage_unit/atmos
	SUIT_TYPE = /obj/item/clothing/suit/space/rig/atmos
	HELMET_TYPE = /obj/item/clothing/head/helmet/space/rig/atmos
	MASK_TYPE = /obj/item/clothing/mask/gas

/obj/machinery/suit_storage_unit/mining
	SUIT_TYPE = /obj/item/clothing/suit/space/rig/mining
	HELMET_TYPE = /obj/item/clothing/head/helmet/space/rig/mining
	MASK_TYPE = /obj/item/clothing/mask/breath

/obj/machinery/suit_storage_unit/cmo
	SUIT_TYPE = /obj/item/clothing/suit/space/rig/medical
	HELMET_TYPE = /obj/item/clothing/head/helmet/space/rig/medical
	MASK_TYPE = /obj/item/clothing/mask/breath

/obj/machinery/suit_storage_unit/New()
	src.update_icon()
	if(SUIT_TYPE)
		SUIT = new SUIT_TYPE(src)
	if(HELMET_TYPE)
		HELMET = new HELMET_TYPE(src)
	if(MASK_TYPE)
		MASK = new MASK_TYPE(src)

/obj/machinery/suit_storage_unit/update_icon()
	var/hashelmet = 0
	var/hassuit = 0
	var/hashuman = 0
	if(HELMET)
		hashelmet = 1
	if(SUIT)
		hassuit = 1
	if(OCCUPANT)
		hashuman = 1
	icon_state = text("suitstorage[][][][][][][][][]",hashelmet,hassuit,hashuman,src.isopen,src.islocked,src.isUV,src.ispowered,src.isbroken,src.issuperUV)


/obj/machinery/suit_storage_unit/power_change()
	if( powered() )
		src.ispowered = 1
		stat &= ~NOPOWER
		src.update_icon()
	else
		spawn(rand(0, 15))
			src.ispowered = 0
			stat |= NOPOWER
			src.islocked = 0
			src.isopen = 1
			src.dump_everything()
			src.update_icon()


/obj/machinery/suit_storage_unit/ex_act(severity)
	switch(severity)
		if(1.0)
			if(prob(50))
				src.dump_everything() //So suits dont survive all the time
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				src.dump_everything()
				qdel(src)
			return
		else
			return
	return


/obj/machinery/suit_storage_unit/attack_hand(mob/user as mob)
	var/dat
	if(..())
		return
	if(stat & NOPOWER)
		return
	if(!user.IsAdvancedToolUser())
		return 0
	if(src.panelopen) //The maintenance panel is open. Time for some shady stuff
		dat+= "<HEAD><TITLE>Suit storage unit: Maintenance panel</TITLE></HEAD>"
		dat+= "<B>Maintenance panel controls</B><HR>"
		dat+= "<font color ='grey'>The panel is ridden with controls, button and meters, labeled in strange signs and symbols that <BR>you cannot understand. Probably the manufactoring world's language.<BR> Among other things, a few controls catch your eye.<BR><BR>"
		dat+= text("A small dial with a \"�\" symbol embroidded on it. It's pointing towards a gauge that reads [].<BR> <font color='blue'><A href='?src=[UID()];toggleUV=1'> Turn towards []</A><BR>",(src.issuperUV ? "15nm" : "185nm"),(src.issuperUV ? "185nm" : "15nm") )
		dat+= text("A thick old-style button, with 2 grimy LED lights next to it. The [] LED is on.<BR><font color ='blue'><A href='?src=[UID()];togglesafeties=1'>Press button</a></font>",(src.safetieson? "<font color='green'><B>GREEN</B></font>" : "<font color='red'><B>RED</B></font>"))
		dat+= "<HR><BR><A href='?src=[user.UID()];mach_close=suit_storage_unit'>Close panel</A>"
		//user << browse(dat, "window=ssu_m_panel;size=400x500")
		//onclose(user, "ssu_m_panel")
	else if(src.isUV) //The thing is running its cauterisation cycle. You have to wait.
		dat += "<HEAD><TITLE>Suit storage unit</TITLE></HEAD>"
		dat+= "<font color ='red'><B>Unit is cauterising contents with selected UV ray intensity. Please wait.</font></B><BR>"
		//dat+= "<font colr='black'><B>Cycle end in: [src.cycletimeleft()] seconds. </font></B>"
		//user << browse(dat, "window=ssu_cycling_panel;size=400x500")
		//onclose(user, "ssu_cycling_panel")

	else
		if(!src.isbroken)
			dat+= "<B>Welcome to the Unit control panel.</B><HR>"
			dat+= text("Helmet storage compartment: <B>[]</B><BR>",(src.HELMET ? HELMET.name : "</font><font color ='grey'>No helmet detected.") )
			if(HELMET && src.isopen)
				dat+="<A href='?src=[UID()];dispense_helmet=1'>Dispense helmet</A><BR>"
			dat+= text("Suit storage compartment: <B>[]</B><BR>",(src.SUIT ? SUIT.name : "</font><font color ='grey'>No exosuit detected.") )
			if(SUIT && src.isopen)
				dat+="<A href='?src=[UID()];dispense_suit=1'>Dispense suit</A><BR>"
			dat+= text("Breathmask storage compartment: <B>[]</B><BR>",(src.MASK ? MASK.name : "</font><font color ='grey'>No breathmask detected.") )
			if(MASK && src.isopen)
				dat+="<A href='?src=[UID()];dispense_mask=1'>Dispense mask</A><BR>"
			if(src.OCCUPANT)
				dat+= "<HR><B><font color ='red'>WARNING: Biological entity detected inside the Unit's storage. Please remove.</B></font><BR>"
				dat+= "<A href='?src=[UID()];eject_guy=1'>Eject extra load</A>"
			dat+= text("<HR>Unit is: [] - <A href='?src=[UID()];toggle_open=1'>[] Unit</A> ",(src.isopen ? "Open" : "Closed"),(src.isopen ? "Close" : "Open"))
			if(src.isopen)
				dat+="<HR>"
			else
				dat+= text(" - <A href='?src=[UID()];toggle_lock=1'>*[] Unit*</A><HR>",(src.islocked ? "Unlock" : "Lock") )
			dat+= text("Unit status: []",(src.islocked? "<font color ='red'><B>**LOCKED**</B></font><BR>" : "<font color ='green'><B>**UNLOCKED**</B></font><BR>") )
			dat+= "<A href='?src=[UID()];start_UV=1'>Start Disinfection cycle</A><BR>"
			dat += "<BR><BR><A href='?src=[user.UID()];mach_close=suit_storage_unit'>Close control panel</A>"
			//user << browse(dat, "window=Suit Storage Unit;size=400x500")
			//onclose(user, "Suit Storage Unit")
		else //Ohhhh shit it's dirty or broken! Let's inform the guy.
			dat+= "<HEAD><TITLE>Suit storage unit</TITLE></HEAD>"
			dat+= "<font color='maroon'><B>Unit chamber is too contaminated to continue usage. Please call for a qualified individual to perform maintenance.</font></B><BR><BR>"
			dat+= "<HR><A href='?src=[user.UID()];mach_close=suit_storage_unit'>Close control panel</A>"
			//user << browse(dat, "window=suit_storage_unit;size=400x500")
			//onclose(user, "suit_storage_unit")

	var/datum/browser/popup = new(user, "suit_storage_unit", name, 400, 500)
	popup.set_content(dat)
	popup.open(0)
	onclose(user, "suit_storage_unit")
	return


/obj/machinery/suit_storage_unit/Topic(href, href_list) //I fucking HATE this proc
	if(..())
		return 1
	if((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon/ai)))
		usr.set_machine(src)
		if(href_list["toggleUV"])
			src.toggleUV(usr)
			src.updateUsrDialog()
			src.update_icon()
		if(href_list["togglesafeties"])
			src.togglesafeties(usr)
			src.updateUsrDialog()
			src.update_icon()
		if(href_list["dispense_helmet"])
			src.dispense_helmet(usr)
			src.updateUsrDialog()
			src.update_icon()
		if(href_list["dispense_suit"])
			src.dispense_suit(usr)
			src.updateUsrDialog()
			src.update_icon()
		if(href_list["dispense_mask"])
			src.dispense_mask(usr)
			src.updateUsrDialog()
			src.update_icon()
		if(href_list["toggle_open"])
			src.toggle_open(usr)
			src.updateUsrDialog()
			src.update_icon()
		if(href_list["toggle_lock"])
			src.toggle_lock(usr)
			src.updateUsrDialog()
			src.update_icon()
		if(href_list["start_UV"])
			src.start_UV(usr)
			src.updateUsrDialog()
			src.update_icon()
		if(href_list["eject_guy"])
			src.eject_occupant(usr)
			src.updateUsrDialog()
			src.update_icon()
	/*if(href_list["refresh"])
		src.updateUsrDialog()*/
	src.add_fingerprint(usr)
	return


/obj/machinery/suit_storage_unit/proc/toggleUV(mob/user as mob)
//	var/protected = 0
//	var/mob/living/carbon/human/H = user
	if(!src.panelopen)
		return

	/*if(istype(H)) //Let's check if the guy's wearing electrically insulated gloves
		if(H.gloves)
			var/obj/item/clothing/gloves/G = H.gloves
			if(istype(G,/obj/item/clothing/gloves/color/yellow))
				protected = 1

	if(!protected)
		playsound(src.loc, "sparks", 75, 1, -1)
		to_chat(user, "<font color='red'>You try to touch the controls but you get zapped. There must be a short circuit somewhere.</font>")
		return*/
	else  //welp, the guy is protected, we can continue
		if(src.issuperUV)
			to_chat(user, "You slide the dial back towards \"185nm\".")
			src.issuperUV = 0
		else
			to_chat(user, "You crank the dial all the way up to \"15nm\".")
			src.issuperUV = 1
		return


/obj/machinery/suit_storage_unit/proc/togglesafeties(mob/user as mob)
//	var/protected = 0
//	var/mob/living/carbon/human/H = user
	if(!src.panelopen) //Needed check due to bugs
		return

	/*if(istype(H)) //Let's check if the guy's wearing electrically insulated gloves
		if(H.gloves)
			var/obj/item/clothing/gloves/G = H.gloves
			if(istype(G,/obj/item/clothing/gloves/color/yellow) )
				protected = 1

	if(!protected)
		playsound(src.loc, "sparks", 75, 1, -1)
		to_chat(user, "<font color='red'>You try to touch the controls but you get zapped. There must be a short circuit somewhere.</font>")
		return*/
	else
		to_chat(user, "You push the button. The coloured LED next to it changes.")
		src.safetieson = !src.safetieson


/obj/machinery/suit_storage_unit/proc/dispense_helmet(mob/user as mob)
	if(!src.HELMET)
		return //Do I even need this sanity check? Nyoro~n
	else
		src.HELMET.loc = src.loc
		src.HELMET = null
		return


/obj/machinery/suit_storage_unit/proc/dispense_suit(mob/user as mob)
	if(!src.SUIT)
		return
	else
		src.SUIT.loc = src.loc
		src.SUIT = null
		return


/obj/machinery/suit_storage_unit/proc/dispense_mask(mob/user as mob)
	if(!src.MASK)
		return
	else
		src.MASK.loc = src.loc
		src.MASK = null
		return


/obj/machinery/suit_storage_unit/proc/dump_everything()
	src.islocked = 0 //locks go free
	if(src.SUIT)
		src.SUIT.loc = src.loc
		src.SUIT = null
	if(src.HELMET)
		src.HELMET.loc = src.loc
		src.HELMET = null
	if(src.MASK)
		src.MASK.loc = src.loc
		src.MASK = null
	if(src.OCCUPANT)
		src.eject_occupant(OCCUPANT)
	return


/obj/machinery/suit_storage_unit/proc/toggle_open(mob/user as mob)
	if(src.islocked || src.isUV)
		to_chat(user, "<font color='red'>Unable to open unit.</font>")
		return
	if(src.OCCUPANT)
		src.eject_occupant(user)
		return  // eject_occupant opens the door, so we need to return
	src.isopen = !src.isopen
	return


/obj/machinery/suit_storage_unit/proc/toggle_lock(mob/user as mob)
	if(src.OCCUPANT && src.safetieson)
		to_chat(user, "<font color='red'>The Unit's safety protocols disallow locking when a biological form is detected inside its compartments.</font>")
		return
	if(src.isopen)
		return
	src.islocked = !src.islocked
	return


/obj/machinery/suit_storage_unit/proc/start_UV(mob/user as mob)
	if(src.isUV || src.isopen) //I'm bored of all these sanity checks
		return
	if(src.OCCUPANT && src.safetieson)
		to_chat(user, "<font color='red'><B>WARNING:</B> Biological entity detected in the confines of the Unit's storage. Cannot initiate cycle.</font>")
		return
	if(!src.HELMET && !src.MASK && !src.SUIT && !src.OCCUPANT ) //shit's empty yo
		to_chat(user, "<font color='red'>Unit storage bays empty. Nothing to disinfect -- Aborting.</font>")
		return
	to_chat(user, "You start the Unit's cauterisation cycle.")
	src.cycletime_left = 20
	src.isUV = 1
	if(src.OCCUPANT && !src.islocked)
		src.islocked = 1 //Let's lock it for good measure
	src.update_icon()
	src.updateUsrDialog()

	var/i //our counter
	for(i=0,i<4,i++)
		sleep(50)
		if(src.OCCUPANT)
			if(src.issuperUV)
				var/burndamage = rand(35,45)
				OCCUPANT.take_organ_damage(0,burndamage)
				OCCUPANT.emote("scream")
			else
				var/burndamage = rand(10,15)
				OCCUPANT.take_organ_damage(0,burndamage)
				OCCUPANT.emote("scream")
		if(i==3) //End of the cycle
			if(!src.issuperUV)
				if(src.HELMET)
					HELMET.clean_blood()
				if(src.SUIT)
					SUIT.clean_blood()
				if(src.MASK)
					MASK.clean_blood()
			else //It was supercycling, destroy everything
				if(src.HELMET)
					src.HELMET = null
				if(src.SUIT)
					src.SUIT = null
				if(src.MASK)
					src.MASK = null
				visible_message("<font color='red'>With a loud whining noise, the Suit Storage Unit's door grinds open. Puffs of ashen smoke come out of its chamber.</font>")
				src.isbroken = 1
				src.isopen = 1
				src.islocked = 0
				src.eject_occupant(OCCUPANT) //Mixing up these two lines causes bug. DO NOT DO IT.
			src.isUV = 0 //Cycle ends
	src.update_icon()
	src.updateUsrDialog()
	return

/*	spawn(200) //Let's clean dat shit after 20 secs  //Eh, this doesn't work
		if(src.HELMET)
			HELMET.clean_blood()
		if(src.SUIT)
			SUIT.clean_blood()
		if(src.MASK)
			MASK.clean_blood()
		src.isUV = 0 //Cycle ends
		src.update_icon()
		src.updateUsrDialog()

	var/i
	for(i=0,i<4,i++) //Gradually give the guy inside some damaged based on the intensity
		spawn(50)
			if(src.OCCUPANT)
				if(src.issuperUV)
					OCCUPANT.take_organ_damage(0,40)
					to_chat(user, "Test. You gave him 40 damage")
				else
					OCCUPANT.take_organ_damage(0,8)
					to_chat(user, "Test. You gave him 8 damage")
	return*/


/obj/machinery/suit_storage_unit/proc/cycletimeleft()
	if(src.cycletime_left >= 1)
		src.cycletime_left--
	return src.cycletime_left


/obj/machinery/suit_storage_unit/proc/eject_occupant(mob/user as mob)
	if(src.islocked)
		return

	if(!src.OCCUPANT)
		return
//	for(var/obj/O in src)
//		O.loc = src.loc

	if(src.OCCUPANT.client)
		if(user != OCCUPANT)
			to_chat(OCCUPANT, "<font color='blue'>The machine kicks you out!</font>")
		if(user.loc != src.loc)
			to_chat(OCCUPANT, "<font color='blue'>You leave the not-so-cozy confines of the SSU.</font>")

		src.OCCUPANT.client.eye = src.OCCUPANT.client.mob
		src.OCCUPANT.client.perspective = MOB_PERSPECTIVE
	src.OCCUPANT.loc = src.loc
	src.OCCUPANT = null
	if(!src.isopen)
		src.isopen = 1
	src.update_icon()
	return


/obj/machinery/suit_storage_unit/verb/get_out()
	set name = "Eject Suit Storage Unit"
	set category = "Object"
	set src in oview(1)

	if(usr.stat != 0)
		return
	src.eject_occupant(usr)
	add_fingerprint(usr)
	src.updateUsrDialog()
	src.update_icon()
	return


/obj/machinery/suit_storage_unit/verb/move_inside()
	set name = "Hide in Suit Storage Unit"
	set category = "Object"
	set src in oview(1)

	if(usr.stat != 0)
		return
	if(!src.isopen)
		to_chat(usr, "<font color='red'>The unit's doors are shut.</font>")
		return
	if(!src.ispowered || src.isbroken)
		to_chat(usr, "<font color='red'>The unit is not operational.</font>")
		return
	if( (src.OCCUPANT) || (src.HELMET) || (src.SUIT) )
		to_chat(usr, "<font color='red'>It's too cluttered inside for you to fit in!</font>")
		return
	visible_message("[usr] starts squeezing into the suit storage unit!")
	if(do_after(usr, 10, target = usr))
		usr.stop_pulling()
		usr.client.perspective = EYE_PERSPECTIVE
		usr.client.eye = src
		usr.loc = src
//		usr.metabslow = 1
		src.OCCUPANT = usr
		src.isopen = 0 //Close the thing after the guy gets inside
		src.update_icon()

//		for(var/obj/O in src)
//			qdel(O)

		src.add_fingerprint(usr)
		src.updateUsrDialog()
		return
	else
		src.OCCUPANT = null //Testing this as a backup sanity test
	return


/obj/machinery/suit_storage_unit/attackby(obj/item/I as obj, mob/user as mob, params)
	if(!src.ispowered)
		return
	if(istype(I, /obj/item/weapon/screwdriver))
		src.panelopen = !src.panelopen
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
		to_chat(user, text("<font color='blue'>You [] the unit's maintenance panel.</font>",(src.panelopen ? "open up" : "close") ))
		src.updateUsrDialog()
		return
	if( istype(I, /obj/item/weapon/grab) )
		var/obj/item/weapon/grab/G = I
		if( !(ismob(G.affecting)) )
			return
		if(!src.isopen)
			to_chat(usr, "<font color='red'>The unit's doors are shut.</font>")
			return
		if(!src.ispowered || src.isbroken)
			to_chat(usr, "<font color='red'>The unit is not operational.</font>")
			return
		if( (src.OCCUPANT) || (src.HELMET) || (src.SUIT) ) //Unit needs to be absolutely empty
			to_chat(user, "<font color='red'>The unit's storage area is too cluttered.</font>")
			return
		visible_message("[user] starts putting [G.affecting.name] into the Suit Storage Unit.")
		if(do_after(user, 20, target = G:affecting))
			if(!G || !G.affecting) return //derpcheck
			var/mob/M = G.affecting
			if(M.client)
				M.client.perspective = EYE_PERSPECTIVE
				M.client.eye = src
			M.loc = src
			src.OCCUPANT = M
			src.isopen = 0 //close ittt

			//for(var/obj/O in src)
			//	O.loc = src.loc
			src.add_fingerprint(user)
			qdel(G)
			src.updateUsrDialog()
			src.update_icon()
			return
		return
	if( istype(I,/obj/item/clothing/suit/space) )
		if(!src.isopen)
			return
		var/obj/item/clothing/suit/space/S = I
		if(src.SUIT)
			to_chat(user, "<font color='blue'>The unit already contains a suit.</font>")
			return
		to_chat(user, "You load the [S.name] into the storage compartment.")
		user.drop_item()
		S.loc = src
		src.SUIT = S
		src.update_icon()
		src.updateUsrDialog()
		return
	if( istype(I,/obj/item/clothing/head/helmet) )
		if(!src.isopen)
			return
		var/obj/item/clothing/head/helmet/H = I
		if(src.HELMET)
			to_chat(user, "<font color='blue'>The unit already contains a helmet.</font>")
			return
		to_chat(user, "You load the [H.name] into the storage compartment.")
		user.drop_item()
		H.loc = src
		src.HELMET = H
		src.update_icon()
		src.updateUsrDialog()
		return
	if( istype(I,/obj/item/clothing/mask) )
		if(!src.isopen)
			return
		var/obj/item/clothing/mask/M = I
		if(src.MASK)
			to_chat(user, "<font color='blue'>The unit already contains a mask.</font>")
			return
		to_chat(user, "You load the [M.name] into the storage compartment.")
		user.drop_item()
		M.loc = src
		src.MASK = M
		src.update_icon()
		src.updateUsrDialog()
		return
	src.update_icon()
	src.updateUsrDialog()
	return


/obj/machinery/suit_storage_unit/attack_ai(mob/user as mob)
	return src.attack_hand(user)



//////////////////////////////REMINDER: Make it lock once you place some fucker inside.

//God this entire file is fucking awful
//Suit painter for Bay's special snowflake aliums.

/obj/machinery/suit_cycler

	name = "suit cycler"
	desc = "An industrial machine for repairing, painting and equipping hardsuits."
	anchored = 1
	density = 1

	icon = 'icons/obj/suitstorage.dmi'
	icon_state = "suitstorage000000100"

	req_access = list(access_captain,access_heads)

	var/active = 0          // PLEASE HOLD.
	var/safeties = 1        // The cycler won't start with a living thing inside it unless safeties are off.
	var/irradiating = 0     // If this is > 0, the cycler is decontaminating whatever is inside it.
	var/radiation_level = 2 // 1 is removing germs, 2 is removing blood, 3 is removing plasma.
	var/model_text = ""     // Some flavour text for the topic box.
	var/locked = 1          // If locked, nothing can be taken from or added to the cycler.

	// Wiring bollocks.
	var/wires = 15
	var/electrified = 0
	var/const/WIRE_EXTEND = 1 // Safeties
	var/const/WIRE_SCANID = 2 // Locked status
	var/const/WIRE_SHOCK = 3  // What it says on the tin.

	//Departments that the cycler can paint suits to look like.
	var/list/departments = list("Engineering","Mining","Medical","Security","Atmos")
	//Species that the suits can be configured to fit.
	var/list/species = list("Human","Skrell","Unathi","Tajaran")

	var/target_department = "Engineering"
	var/target_species = "Human"

	var/mob/living/carbon/human/occupant = null
	var/obj/item/clothing/suit/space/rig/suit = null
	var/obj/item/clothing/head/helmet/space/helmet = null

/obj/machinery/suit_cycler/engineering
	name = "Engineering suit cycler"
	model_text = "Engineering"
	req_access = list(access_construction)
	departments = list("Engineering","Atmos")
	species = list("Human","Unathi","Tajaran")

/obj/machinery/suit_cycler/mining
	name = "Mining suit cycler"
	model_text = "Mining"
	req_access = list(access_mining)
	departments = list("Mining")
	species = list("Human","Unathi","Tajaran")

/obj/machinery/suit_cycler/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/suit_cycler/attackby(obj/item/I as obj, mob/user as mob, params)

	if(electrified != 0)
		if(src.shock(user, 100))
			return

	//Hacking init.
	if(istype(I, /obj/item/device/multitool) || istype(I, /obj/item/weapon/wirecutters))
		if(panel_open)
			attack_hand(user)
		return
	//Other interface stuff.
	if(istype(I, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = I

		if(!(ismob(G.affecting)))
			return

		if(locked)
			to_chat(user, "\red The suit cycler is locked.")
			return

		if(src.contents.len > 0)
			to_chat(user, "\red There is no room inside the cycler for [G.affecting.name].")
			return

		visible_message("[user] starts putting [G.affecting.name] into the suit cycler.")

		if(do_after(user, 20, target = G:affecting))
			if(!G || !G.affecting) return
			var/mob/M = G.affecting
			if(M.client)
				M.client.perspective = EYE_PERSPECTIVE
				M.client.eye = src
			M.loc = src
			src.occupant = M

			src.add_fingerprint(user)
			qdel(G)

			src.updateUsrDialog()

			return
	else if(istype(I,/obj/item/weapon/screwdriver))

		panel_open = !panel_open
		to_chat(user, "You [panel_open ?  "open" : "close"] the maintenance panel.")
		src.updateUsrDialog()
		return

	else if(istype(I,/obj/item/clothing/head/helmet/space))

		if(locked)
			to_chat(user, "\red The suit cycler is locked.")
			return

		if(helmet)
			to_chat(user, "The cycler already contains a helmet.")
			return

		to_chat(user, "You fit \the [I] into the suit cycler.")
		user.drop_item()
		I.loc = src
		helmet = I

		src.update_icon()
		src.updateUsrDialog()
		return

	else if(istype(I,/obj/item/clothing/suit/space/rig))

		if(locked)
			to_chat(user, "\red The suit cycler is locked.")
			return

		if(suit)
			to_chat(user, "The cycler already contains a hardsuit.")
			return

		var/obj/item/clothing/suit/space/rig/S = I

		if(S.helmet)
			to_chat(user, "\The [S] will not fit into the cycler with a helmet attached.")
			return

		if(S.boots)
			to_chat(user, "\The [S] will not fit into the cycler with boots attached.")
			return

		to_chat(user, "You fit \the [I] into the suit cycler.")
		user.drop_item()
		I.loc = src
		suit = I

		src.update_icon()
		src.updateUsrDialog()
		return

	..()

/obj/machinery/suit_cycler/emag_act(user as mob)
	if(emagged)
		to_chat(user, "\red The cycler has already been subverted.")
		return

	//Clear the access reqs, disable the safeties, and open up all paintjobs.
	to_chat(user, "\red You run the sequencer across the interface, corrupting the operating protocols.")
	departments = list("Engineering","Mining","Medical","Security","Atmos","^%###^%$")
	emagged = 1
	safeties = 0
	req_access = list()
	return

/obj/machinery/suit_cycler/attack_hand(mob/user as mob)

	add_fingerprint(user)

	if(..() || stat & (BROKEN|NOPOWER))
		return

	if(!user.IsAdvancedToolUser())
		return 0

	if(electrified != 0)
		if(src.shock(user, 100))
			return

	usr.set_machine(src)

	var/dat = "<HEAD><TITLE>Suit Cycler Interface</TITLE></HEAD>"

	if(src.active)
		dat+= "<br><font color='red'><B>The [model_text ? "[model_text] " : ""]suit cycler is currently in use. Please wait...</b></font>"

	else if(locked)
		dat += "<br><font color='red'><B>The [model_text ? "[model_text] " : ""]suit cycler is currently locked. Please contact your system administrator.</b></font>"
		if(src.allowed(usr))
			dat += "<br><a href='?src=[UID()];toggle_lock=1'>\[unlock unit\]</a>"
	else
		dat += "<h1>Suit cycler</h1>"
		dat += "<B>Welcome to the [model_text ? "[model_text] " : ""]suit cycler control panel. <a href='?src=[UID()];toggle_lock=1'>\[lock unit\]</a></B><HR>"

		dat += "<h2>Maintenance</h2>"
		dat += "<b>Helmet: </b> [helmet ? "\the [helmet]" : "no helmet stored" ]. <A href='?src=[UID()];eject_helmet=1'>\[eject\]</a><br/>"
		dat += "<b>Suit: </b> [suit ? "\the [suit]" : "no suit stored" ]. <A href='?src=[UID()];eject_suit=1'>\[eject\]</a>"

		if(suit && istype(suit))
			dat += "[(suit.damage ? " <A href='?src=[UID()];repair_suit=1'>\[repair\]</a>" : "")]"

		dat += "<br/><b>UV decontamination systems:</b> <font color = '[emagged ? "red'>SYSTEM ERROR" : "green'>READY"]</font><br>"
		dat += "Output level: [radiation_level]<br>"
		dat += "<A href='?src=[UID()];select_rad_level=1'>\[select power level\]</a> <A href='?src=[UID()];begin_decontamination=1'>\[begin decontamination cycle\]</a><br><hr>"

		dat += "<h2>Customisation</h2>"
		dat += "<b>Target product: <A href='?src=[UID()];select_department=1'>[target_department]</a>, <A href='?src=[UID()];select_species=1'>[target_species]</a>."
		dat += "<A href='?src=[UID()];apply_paintjob=1'><br>\[apply customisation routine\]</a><br><hr>"

/*	if(panel_open)
		var/list/vendwires = list(
			"Violet" = 1,
			"Orange" = 2,
			"Goldenrod" = 3,
			)
		dat += "<h2><B>Access Panel</B></h2>"
		for(var/wiredesc in vendwires)
			var/is_uncut = src.wires & APCWireColorToFlag[vendwires[wiredesc]]
			dat += "[wiredesc] wire: "
			if(!is_uncut)
				dat += "<a href='?src=[UID()];cutwire=[vendwires[wiredesc]]'>Mend</a>"
			else
				dat += "<a href='?src=[UID()];cutwire=[vendwires[wiredesc]]'>Cut</a> "
				dat += "<a href='?src=[UID()];pulsewire=[vendwires[wiredesc]]'>Pulse</a> "
			dat += "<br>"

		dat += "<br>"
		dat += "The orange light is [(electrified == 0) ? "off" : "on"].<BR>"
		dat += "The red light is [safeties ? "blinking" : "off"].<BR>"
		dat += "The yellow light is [locked ? "on" : "off"].<BR>" */

	var/datum/browser/popup = new(user, "suit_cycler", name, 400, 400)
	popup.set_content(dat)
	popup.open(0)
	onclose(user, "suit_cycler")
	return

/obj/machinery/suit_cycler/Topic(href, href_list)
	if(href_list["eject_suit"])
		if(!suit) return
		suit.loc = get_turf(src)
		suit = null
	else if(href_list["eject_helmet"])
		if(!helmet) return
		helmet.loc = get_turf(src)
		helmet = null
	else if(href_list["select_department"])
		var/choice = input("Please select the target department paintjob.","Suit cycler",null) as null|anything in departments
		if(choice) target_department = choice
	else if(href_list["select_species"])
		var/choice = input("Please select the target species configuration.","Suit cycler",null) as null|anything in species
		if(choice) target_species = choice
	else if(href_list["select_rad_level"])
		var/choices = list(1,2,3)
		if(emagged)
			choices = list(1,2,3,4,5)
		radiation_level = input("Please select the desired radiation level.","Suit cycler",null) as null|anything in choices
	else if(href_list["repair_suit"])

		if(!suit) return
		active = 1
		spawn(100)
			repair_suit()
			finished_job()

	else if(href_list["apply_paintjob"])

		if(!suit && !helmet) return
		active = 1
		spawn(100)
			apply_paintjob()
			finished_job()

	else if(href_list["toggle_safties"])
		safeties = !safeties

	else if(href_list["toggle_lock"])

		if(src.allowed(usr))
			locked = !locked
			to_chat(usr, "You [locked ? "" : "un"]lock \the [src].")
		else
			to_chat(usr, "\red Access denied.")

	else if(href_list["begin_decontamination"])

		if(safeties && occupant)
			to_chat(usr, "\red The cycler has detected an occupant. Please remove the occupant before commencing the decontamination cycle.")
			return

		active = 1
		irradiating = 10
		src.updateUsrDialog()

		sleep(10)

		if(helmet)
			if(radiation_level > 1)
				helmet.clean_blood()

		if(suit)
			if(radiation_level > 1)
				suit.clean_blood()

/*	else if((href_list["cutwire"]) && (src.panel_open))
		var/twire = text2num(href_list["cutwire"])
		if(!( istype(usr.get_active_hand(), /obj/item/weapon/wirecutters) ))
			to_chat(usr, "You need wirecutters!")
			return
		if(src.isWireColorCut(twire))
			src.mend(twire)
		else
			src.cut(twire)

	else if((href_list["pulsewire"]) && (src.panel_open))
		var/twire = text2num(href_list["pulsewire"])
		if(!istype(usr.get_active_hand(), /obj/item/device/multitool))
			to_chat(usr, "You need a multitool!")
			return
		if(src.isWireColorCut(twire))
			to_chat(usr, "You can't pulse a cut wire.")
			return
		else
			src.pulse(twire)*/

	src.updateUsrDialog()
	return

/obj/machinery/suit_cycler/process()

	if(electrified > 0)
		electrified--

	if(!active)
		return

	if(active && stat & (BROKEN|NOPOWER))
		active = 0
		irradiating = 0
		electrified = 0
		return

	if(irradiating == 1)
		finished_job()
		irradiating = 0
		return

	irradiating--

	if(occupant)
		if(prob(radiation_level*2)) occupant.emote("scream")
		if(radiation_level > 2)
			occupant.take_organ_damage(0,radiation_level*2 + rand(1,3))
		if(radiation_level > 1)
			occupant.take_organ_damage(0,radiation_level + rand(1,3))
		occupant.radiation += radiation_level*10

/obj/machinery/suit_cycler/proc/finished_job()
	var/turf/T = get_turf(src)
	T.visible_message("\The [src] pings loudly.")
	icon_state = initial(icon_state)
	active = 0
	src.updateUsrDialog()

/obj/machinery/suit_cycler/proc/repair_suit()
	if(!suit || !suit.damage || !suit.can_breach)
		return

	suit.breaches = list()
	suit.calc_breach_damage()

	return

/obj/machinery/suit_cycler/verb/leave()
	set name = "Eject Cycler"
	set category = "Object"
	set src in oview(1)

	if(usr.stat != 0)
		return

	eject_occupant(usr)

/obj/machinery/suit_cycler/proc/eject_occupant(mob/user as mob)

	if(locked || active)
		to_chat(user, "\red The cycler is locked.")
		return

	if(!occupant)
		return

	if(occupant.client)
		occupant.client.eye = occupant.client.mob
		occupant.client.perspective = MOB_PERSPECTIVE

	occupant.loc = get_turf(occupant)
	occupant = null

	add_fingerprint(usr)
	src.updateUsrDialog()
	src.update_icon()

	return
/*
//HACKING PROCS, MOSTLY COPIED FROM VENDING MACHINES
/obj/machinery/suit_cycler/proc/isWireColorCut(var/wireColor)
	var/wireFlag = APCWireColorToFlag[wireColor]
	return ((src.wires & wireFlag) == 0)

/obj/machinery/suit_cycler/proc/isWireCut(var/wireIndex)
	var/wireFlag = APCIndexToFlag[wireIndex]
	return ((src.wires & wireFlag) == 0)

/obj/machinery/suit_cycler/proc/cut(var/wireColor)
	var/wireFlag = APCWireColorToFlag[wireColor]
	var/wireIndex = APCWireColorToIndex[wireColor]
	src.wires &= ~wireFlag
	switch(wireIndex)

		if(WIRE_EXTEND)
			safeties = 0
		if(WIRE_SHOCK)
			electrified = -1
		if(WIRE_SCANID)
			locked = 0

/obj/machinery/suit_cycler/proc/mend(var/wireColor)
	var/wireFlag = APCWireColorToFlag[wireColor]
	var/wireIndex = APCWireColorToIndex[wireColor] //not used in this function
	src.wires |= wireFlag
	switch(wireIndex)
		if(WIRE_SHOCK)
			src.electrified = 0

/obj/machinery/suit_cycler/proc/pulse(var/wireColor)
	var/wireIndex = APCWireColorToIndex[wireColor]
	switch(wireIndex)
		if(WIRE_EXTEND)
			safeties = !locked
		if(WIRE_SHOCK)
			electrified = 30
		if(WIRE_SCANID)
			locked = !locked
*/

//There HAS to be a less bloated way to do this. TODO: some kind of table/icon name coding? ~Z
/obj/machinery/suit_cycler/proc/apply_paintjob()

	if(!target_species || !target_department)
		return

	if(target_species)
		if(helmet) helmet.refit_for_species(target_species)
		if(suit) suit.refit_for_species(target_species)

	switch(target_department)
		if("Engineering")
			if(helmet)
				helmet.name = "engineering hardsuit helmet"
				helmet.icon_state = "rig0-engineering"
				helmet.item_state = "eng_helm"
				helmet.item_color = "engineering"
			if(suit)
				suit.name = "engineering hardsuit"
				suit.icon_state = "rig-engineering"
				suit.item_state = "eng_hardsuit"
		if("Mining")
			if(helmet)
				helmet.name = "mining hardsuit helmet"
				helmet.icon_state = "rig0-mining"
				helmet.item_state = "mining_helm"
				helmet.item_color = "mining"
			if(suit)
				suit.name = "mining hardsuit"
				suit.icon_state = "rig-mining"
				suit.item_state = "mining_hardsuit"
		if("Medical")
			if(helmet)
				helmet.name = "medical hardsuit helmet"
				helmet.icon_state = "rig0-medical"
				helmet.item_state = "medical_helm"
				helmet.item_color = "medical"
			if(suit)
				suit.name = "medical hardsuit"
				suit.icon_state = "rig-medical"
				suit.item_state = "medical_hardsuit"
		if("Security")
			if(helmet)
				helmet.name = "security hardsuit helmet"
				helmet.icon_state = "rig0-sec"
				helmet.item_state = "sec_helm"
				helmet.item_color = "sec"
			if(suit)
				suit.name = "security hardsuit"
				suit.icon_state = "rig-sec"
				suit.item_state = "sec_hardsuit"
		if("Atmos")
			if(helmet)
				helmet.name = "atmospherics hardsuit helmet"
				helmet.icon_state = "rig0-atmos"
				helmet.item_state = "atmos_helm"
				helmet.item_color = "atmos"
			if(suit)
				suit.name = "atmospherics hardsuit"
				suit.icon_state = "rig-atmos"
				suit.item_state = "atmos_hardsuit"
		if("^%###^%$")
			if(helmet)
				helmet.name = "blood-red hardsuit helmet"
				helmet.icon_state = "rig0-syndie"
				helmet.item_state = "syndie_helm"
				helmet.item_color = "syndie"
			if(suit)
				suit.name = "blood-red hardsuit"
				suit.item_state = "syndie_hardsuit"
				suit.icon_state = "rig-syndie"

// SUIT STORAGE UNIT /////////////////
/obj/machinery/suit_storage_unit
	name = "suit storage unit"
	desc = "An industrial U-Stor-It Storage unit designed to accomodate all kinds of space suits. Its on-board equipment also allows the user to decontaminate the contents through a UV-ray purging cycle. There's a warning label dangling from the control pad, reading \"STRICTLY NO BIOLOGICALS IN THE CONFINES OF THE UNIT\"."
	icon = 'icons/obj/machines/suit_storage.dmi'
	icon_state = "close"
	anchored = TRUE
	density = TRUE
	max_integrity = 250

	var/obj/item/clothing/suit/space/suit = null
	var/obj/item/clothing/head/helmet/space/helmet = null
	var/obj/item/clothing/mask/mask = null
	var/obj/item/storage = null

	var/helmet_type = null
	var/suit_type = null
	var/mask_type = null
	var/storage_type = null

	var/locked = FALSE
	var/safeties = TRUE
	var/broken = FALSE

	var/uv = FALSE
	var/uv_super = FALSE
	var/uv_cycles = 6
	var/message_cooldown
	var/breakout_time = 300

	//abstract these onto machinery eventually
	var/state_open = FALSE
	var/list/occupant_typecache //if set, turned into typecache in Initialize, other wise, defaults to mob/living typecache
	var/atom/movable/occupant = null


/obj/machinery/suit_storage_unit/standard_unit
	suit_type    = /obj/item/clothing/suit/space/eva
	helmet_type  = /obj/item/clothing/head/helmet/space/eva
	mask_type    = /obj/item/clothing/mask/breath

/obj/machinery/suit_storage_unit/captain
	suit_type    = /obj/item/clothing/suit/space/captain
	helmet_type  = /obj/item/clothing/head/helmet/space/capspace
	mask_type    = /obj/item/clothing/mask/gas
	storage_type = /obj/item/tank/jetpack/oxygen/captain

/obj/machinery/suit_storage_unit/engine
	suit_type    = /obj/item/clothing/suit/space/hardsuit/engineering
	helmet_type  = /obj/item/clothing/head/helmet/space/hardsuit/engineering
	mask_type    = /obj/item/clothing/mask/breath
	storage_type = /obj/item/clothing/shoes/magboots

/obj/machinery/suit_storage_unit/ce
	suit_type    = /obj/item/clothing/suit/space/hardsuit/elite
	helmet_type  = /obj/item/clothing/head/helmet/space/hardsuit/elite
	mask_type    = /obj/item/clothing/mask/gas
	storage_type = /obj/item/clothing/shoes/magboots/advance

/obj/machinery/suit_storage_unit/security
	suit_type    = /obj/item/clothing/suit/space/hardsuit/security
	helmet_type  = /obj/item/clothing/head/helmet/space/hardsuit/security
	mask_type    = /obj/item/clothing/mask/gas/sechailer

/obj/machinery/suit_storage_unit/atmos
	suit_type    = /obj/item/clothing/suit/space/hardsuit/atmos
	helmet_type  = /obj/item/clothing/head/helmet/space/hardsuit/atmos
	mask_type    = /obj/item/clothing/mask/gas
	storage_type = /obj/item/clothing/shoes/magboots

/obj/machinery/suit_storage_unit/mining
	suit_type    = /obj/item/clothing/suit/space/hardsuit/mining
	helmet_type  = /obj/item/clothing/head/helmet/space/hardsuit/mining
	mask_type    = /obj/item/clothing/mask/breath

/obj/machinery/suit_storage_unit/cmo
	suit_type    = /obj/item/clothing/suit/space/hardsuit/medical
	helmet_type  = /obj/item/clothing/head/helmet/space/hardsuit/medical
	mask_type    = /obj/item/clothing/mask/breath

/obj/machinery/suit_storage_unit/syndicate
	suit_type    = /obj/item/clothing/suit/space/hardsuit/syndi
	helmet_type  = /obj/item/clothing/head/helmet/space/hardsuit/syndi
	mask_type    = /obj/item/clothing/mask/gas/syndicate
	storage_type = /obj/item/tank/jetpack/oxygen/harness

/obj/machinery/suit_storage_unit/ert/command
	suit_type    = /obj/item/clothing/suit/space/hardsuit/ert/commander
	helmet_type  = /obj/item/clothing/head/helmet/space/hardsuit/ert/commander
	mask_type    = /obj/item/clothing/mask/breath
	storage_type = /obj/item/tank/emergency_oxygen/double

/obj/machinery/suit_storage_unit/ert/security
	suit_type    = /obj/item/clothing/suit/space/hardsuit/ert/security
	helmet_type  = /obj/item/clothing/head/helmet/space/hardsuit/ert/security
	mask_type    = /obj/item/clothing/mask/breath
	storage_type = /obj/item/tank/emergency_oxygen/double

/obj/machinery/suit_storage_unit/ert/engineer
	suit_type    = /obj/item/clothing/suit/space/hardsuit/ert/engineer
	helmet_type  = /obj/item/clothing/head/helmet/space/hardsuit/ert/engineer
	mask_type    = /obj/item/clothing/mask/breath
	storage_type = /obj/item/tank/emergency_oxygen/double

/obj/machinery/suit_storage_unit/ert/medical
	suit_type    = /obj/item/clothing/suit/space/hardsuit/ert/medical
	helmet_type  = /obj/item/clothing/head/helmet/space/hardsuit/ert/medical
	mask_type    = /obj/item/clothing/mask/breath
	storage_type = /obj/item/tank/emergency_oxygen/double



/obj/machinery/suit_storage_unit/Initialize()
	. = ..()
	if(suit_type)
		suit = new suit_type(src)
	if(helmet_type)
		helmet = new helmet_type(src)
	if(mask_type)
		mask = new mask_type(src)
	if(storage_type)
		storage = new storage_type(src)
	update_icon()

	//move this into machinery eventually...
	if(occupant_typecache)
		occupant_typecache = typecacheof(occupant_typecache)

/obj/machinery/suit_storage_unit/Destroy()
	QDEL_NULL(suit)
	QDEL_NULL(helmet)
	QDEL_NULL(mask)
	QDEL_NULL(storage)
	return ..()

/obj/machinery/suit_storage_unit/update_icon()
	cut_overlays()

	if(uv)
		if(uv_super)
			add_overlay("super")
		else if(occupant)
			add_overlay("uvhuman")
		else
			add_overlay("uv")
	else if(state_open)
		if(stat & BROKEN)
			add_overlay("broken")
		else
			add_overlay("open")
			if(suit)
				add_overlay("suit")
			if(helmet)
				add_overlay("helm")
			if(storage)
				add_overlay("storage")
	else if(occupant)
		add_overlay("human")

/obj/machinery/suit_storage_unit/attackby(obj/item/I as obj, mob/user as mob, params)
	if(!is_operational())
		if(panel_open)
			to_chat(usr, "<span class='warning'>Close the maintenance panel first.</span>")
		else
			to_chat(usr, "<span class='warning'>The unit is not operational.</span>")
		return
	if(isscrewdriver(I))
		panel_open = !panel_open
		playsound(loc, I.usesound, 100, 1)
		to_chat(user, text("<span class='notice'>You [panel_open ? "open up" : "close"] the unit's maintenance panel.</span>"))
		updateUsrDialog()
		return
	if(state_open)
		if(store_item(I, user))
			src.update_icon()
			src.updateUsrDialog()
			to_chat(user, "<span class='notice'>You load the [I.name] into the storage compartment.</span>")
		else
			to_chat(user, "<span class='notice'>The unit already contains that item.</span>")


/obj/machinery/suit_storage_unit/proc/store_item(obj/item/I, mob/user)
	. = FALSE
	if(istype(I, /obj/item/clothing/suit/space) && !suit)
		suit = I
		. = TRUE
	if(istype(I, /obj/item/clothing/head/helmet) && !helmet)
		helmet = I
		. = TRUE
	if(istype(I, /obj/item/clothing/mask) && !mask)
		mask = I
		. = TRUE
	if((istype(I, /obj/item/tank) || istype(I, /obj/item/clothing/shoes/magboots)) && !storage)
		storage = I
		. = TRUE
	if(.)
		user.drop_item()
		I.forceMove(src)


/obj/machinery/suit_storage_unit/power_change()
	..()
	if(!is_operational() && state_open)
		open_machine()
		dump_contents()
	update_icon()


/obj/machinery/suit_storage_unit/proc/dump_contents()
	dropContents()
	helmet = null
	suit = null
	mask = null
	storage = null
	occupant = null

/obj/machinery/suit_storage_unit/deconstruct(disassembled = TRUE)
	open_machine()
	dump_contents()
	new /obj/item/stack/sheet/metal (loc, 2)
	qdel(src)

/obj/machinery/suit_storage_unit/MouseDrop_T(atom/A, mob/user)
	if(user.stat || user.lying || !Adjacent(user) || !Adjacent(A) || !isliving(A))
		return
	var/mob/living/target = A
	if(!state_open)
		to_chat(user, "<span class='warning'>The [src]'s doors are shut!</span>")
		return
	if(!is_operational())
		to_chat(user, "<span class='warning'>The [src] is not operational!</span>")
		return
	if(occupant || helmet || suit || storage)
		to_chat(user, "<span class='warning'>It's too cluttered inside to fit in!</span>")
		return

	if(target == user)
		user.visible_message("<span class='warning'>[user] starts squeezing into [src]!</span>", "<span class='notice'>You start working your way into [src]...</span>")
	else
		target.visible_message("<span class='warning'>[user] starts shoving [target] into [src]!</span>", "<span class='userdanger'>[user] starts shoving you into [src]!</span>")

	if(do_mob(user, target, 30))
		if(occupant || helmet || suit || storage)
			return
		if(target == user)
			user.visible_message("<span class='warning'>[user] slips into [src] and closes the door behind [user.p_them()]!</span>", "<span class='notice'>You slip into [src]'s cramped space and shut its door.</span>")
		else
			target.visible_message("<span class='warning'>[user] pushes [target] into [src] and shuts its door!<span>", "<span class='userdanger'>[user] shoves you into [src] and shuts the door!</span>")
		close_machine(target)
		add_fingerprint(user)

/obj/machinery/suit_storage_unit/proc/cook()
	if(uv_cycles)
		uv_cycles--
		uv = TRUE
		locked = TRUE
		update_icon()
		if(occupant)
			var/mob/living/mob_occupant = occupant
			if(uv_super)
				mob_occupant.adjustFireLoss(rand(20, 36))
			else
				mob_occupant.adjustFireLoss(rand(10, 16))
			mob_occupant.emote("scream")
		addtimer(CALLBACK(src, .proc/cook), 50)
	else
		uv_cycles = initial(uv_cycles)
		uv = FALSE
		locked = FALSE
		if(uv_super)
			visible_message("<span class='warning'>[src]'s door creaks open with a loud whining noise. A cloud of foul black smoke escapes from its chamber.</span>")
			playsound(src, 'sound/machines/airlock_alien_prying.ogg', 50, 1)
			helmet = null
			qdel(helmet)
			suit = null
			qdel(suit) // Delete everything but the occupant.
			mask = null
			qdel(mask)
			storage = null
			qdel(storage)
		else
			if(!occupant)
				visible_message("<span class='notice'>[src]'s door slides open. The glowing yellow lights dim to a gentle green.</span>")
			else
				visible_message("<span class='warning'>[src]'s door slides open, barraging you with the nauseating smell of charred flesh.</span>")
			playsound(src, 'sound/machines/airlock_close.ogg', 25, 1)
		open_machine(FALSE)
		if(occupant)
			dump_contents()

/obj/machinery/suit_storage_unit/shock(mob/user, prb)
	if(!prob(prb))
		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(5, 1, src)
		s.start()
		if(electrocute_mob(user, src, src, 1, TRUE))
			return 1

/obj/machinery/suit_storage_unit/relaymove(mob/user)
	if(locked)
		if(message_cooldown <= world.time)
			message_cooldown = world.time + 50
			to_chat(user, "<span class='warning'>[src]'s door won't budge!</span>")
		return
	open_machine()
	dump_contents()

/obj/machinery/suit_storage_unit/container_resist(mob/living/user)
	if(!locked)
		open_machine()
		dump_contents()
		return
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	user.visible_message("<span class='notice'>You see [user] kicking against the doors of [src]!</span>", \
		"<span class='notice'>You start kicking against the doors... (this will take about [DisplayTimeText(breakout_time)].)</span>", \
		"<span class='italics'>You hear a thump from [src].</span>")
	if(do_after(user,(breakout_time), target = src))
		if(!user || user.stat != CONSCIOUS || user.loc != src )
			return
		user.visible_message("<span class='warning'>[user] successfully broke out of [src]!</span>", \
			"<span class='notice'>You successfully break out of [src]!</span>")
		open_machine()
		dump_contents()

	add_fingerprint(user)
	if(locked)
		visible_message("<span class='notice'>You see [user] kicking against the doors of [src]!</span>", \
			"<span class='notice'>You start kicking against the doors...</span>")
		addtimer(CALLBACK(src, .proc/resist_open, user), 300)
	else
		open_machine()
		dump_contents()

/obj/machinery/suit_storage_unit/proc/resist_open(mob/user)
	if(!state_open && occupant && (user in src) && !user.stat) // Check they're still here.
		visible_message("<span class='notice'>You see [user] burst out of [src]!</span>", \
			"<span class='notice'>You escape the cramped confines of [src]!</span>")
		open_machine()

//eventually move these onto the parent....

/obj/machinery/suit_storage_unit/proc/open_machine(drop = TRUE)
	state_open = TRUE
	if(drop)
		dropContents()
	update_icon()
	updateUsrDialog()

/obj/machinery/suit_storage_unit/dropContents()
	var/turf/T = get_turf(src)
	for(var/atom/movable/A in contents)
		A.forceMove(T)
		if(isliving(A))
			var/mob/living/L = A
			L.update_canmove()
	occupant = null

/obj/machinery/suit_storage_unit/proc/close_machine(atom/movable/target = null)
	state_open = FALSE
	if(!target)
		for(var/am in loc)
			if(!(occupant_typecache ? is_type_in_typecache(am, occupant_typecache) : isliving(am)))
				continue
			var/atom/movable/AM = am
			if(AM.has_buckled_mobs())
				continue
			if(isliving(AM))
				var/mob/living/L = am
				if(L.buckled || L.mob_size >= MOB_SIZE_LARGE)
					continue
			target = am

	var/mob/living/mobtarget = target
	if(target && !target.has_buckled_mobs() && (!isliving(target) || !mobtarget.buckled))
		occupant = target
		target.forceMove(src)
	updateUsrDialog()
	update_icon()


////////

/obj/machinery/suit_storage_unit/attack_hand(mob/user as mob)
	var/dat
	if(..())
		return
	if(stat & NOPOWER)
		return
	if(!user.IsAdvancedToolUser())
		return FALSE
	if(panel_open) //The maintenance panel is open. Time for some shady stuff
		dat+= "<HEAD><TITLE>Suit storage unit: Maintenance panel</TITLE></HEAD>"
		dat+= "<B>Maintenance panel controls</B><HR>"
		dat+= "<font color ='grey'>The panel is ridden with controls, button and meters, labeled in strange signs and symbols that <BR>you cannot understand. Probably the manufactoring world's language.<BR> Among other things, a few controls catch your eye.<BR><BR>"
		dat+= text("A small dial with an arrow embroidered on it. It's pointing towards a gauge that reads [].<BR> <font color='blue'><A href='?src=[UID()];toggleUV=1'> Turn towards []</A><BR>",(uv_super ? "15nm" : "185nm"),(uv_super ? "185nm" : "15nm") )
		dat+= text("A thick old-style button, with 2 grimy LED lights next to it. The [] LED is on.<BR><font color ='blue'><A href='?src=[UID()];togglesafeties=1'>Press button</a></font>",(safeties ? "<font color='green'><B>GREEN</B></font>" : "<font color='red'><B>RED</B></font>"))
		dat+= "<HR><BR><A href='?src=[user.UID()];mach_close=suit_storage_unit'>Close panel</A>"
	else if(uv) //The thing is running its cauterisation cycle. You have to wait.
		dat += "<HEAD><TITLE>Suit storage unit</TITLE></HEAD>"
		dat+= "<font color ='red'><B>Unit is cauterising contents with selected UV ray intensity. Please wait.</font></B><BR>"

	else
		if(!broken)
			dat+= "<B>Welcome to the Unit control panel.</B><HR>"
			dat+= text("Helmet storage compartment: <B>[]</B><BR>",(helmet ? helmet.name : "</font><font color ='grey'>No helmet detected.") )
			if(helmet && state_open)
				dat+="<A href='?src=[UID()];dispense_helmet=1'>Dispense helmet</A><BR>"
			dat+= text("Suit storage compartment: <B>[]</B><BR>",(suit ? suit.name : "</font><font color ='grey'>No exosuit detected.") )
			if(suit && state_open)
				dat+="<A href='?src=[UID()];dispense_suit=1'>Dispense suit</A><BR>"
			dat+= text("Breathmask storage compartment: <B>[]</B><BR>",(mask ? mask.name : "</font><font color ='grey'>No breathmask detected.") )
			if(mask && state_open)
				dat+="<A href='?src=[UID()];dispense_mask=1'>Dispense mask</A><BR>"
			dat+= text("Jetpack, Magboots storage compartment: <B>[]</B><BR>",(storage ? storage.name : "</font><font color ='grey'>No storage item detected.") )
			if(storage && state_open)
				dat+="<A href='?src=[UID()];dispense_storage=1'>Dispense storage item</A><BR>"
			if(occupant)
				dat+= "<HR><B><font color ='red'>WARNING: Biological entity detected inside the Unit's storage. Please remove.</B></font><BR>"
				dat+= "<A href='?src=[UID()];eject_guy=1'>Eject extra load</A>"
			dat+= text("<HR>Unit is: [] - <A href='?src=[UID()];toggle_open=1'>[] Unit</A> ",(state_open ? "Open" : "Closed"),(state_open ? "Close" : "Open"))
			if(state_open)
				dat+="<HR>"
			else
				dat+= text(" - <A href='?src=[UID()];toggle_lock=1'>*[] Unit*</A><HR>",(locked ? "Unlock" : "Lock") )
			dat+= text("Unit status: []",(locked? "<font color ='red'><B>**LOCKED**</B></font><BR>" : "<font color ='green'><B>**UNLOCKED**</B></font><BR>") )
			dat+= "<A href='?src=[UID()];cook=1'>Start Disinfection cycle</A><BR>"
			dat += "<BR><BR><A href='?src=[user.UID()];mach_close=suit_storage_unit'>Close control panel</A>"
		else //Ohhhh shit it's dirty or broken! Let's inform the guy.
			dat+= "<HEAD><TITLE>Suit storage unit</TITLE></HEAD>"
			dat+= "<font color='maroon'><B>Unit chamber is too contaminated to continue usage. Please call for a qualified individual to perform maintenance.</font></B><BR><BR>"
			dat+= "<HR><A href='?src=[user.UID()];mach_close=suit_storage_unit'>Close control panel</A>"


	var/datum/browser/popup = new(user, "suit_storage_unit", name, 400, 500)
	popup.set_content(dat)
	popup.open(0)
	onclose(user, "suit_storage_unit")
	return


/obj/machinery/suit_storage_unit/Topic(href, href_list)
	if(..())
		return 1
	if((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon/ai)))
		usr.set_machine(src)
		if(href_list["toggleUV"])
			toggleUV(usr)
			updateUsrDialog()
			update_icon()
		if(href_list["togglesafeties"])
			togglesafeties(usr)
			updateUsrDialog()
			update_icon()
		if(href_list["dispense_helmet"])
			dispense_helmet(usr)
			updateUsrDialog()
			update_icon()
		if(href_list["dispense_suit"])
			dispense_suit(usr)
			updateUsrDialog()
			update_icon()
		if(href_list["dispense_mask"])
			dispense_mask(usr)
			updateUsrDialog()
			update_icon()
		if(href_list["dispense_storage"])
			dispense_storage(usr)
			updateUsrDialog()
			update_icon()
		if(href_list["toggle_open"])
			toggle_open(usr)
			updateUsrDialog()
			update_icon()
		if(href_list["toggle_lock"])
			toggle_lock(usr)
			updateUsrDialog()
			update_icon()
		if(href_list["cook"])
			cook(usr)
			updateUsrDialog()
			update_icon()
		if(href_list["eject_guy"])
			eject_occupant(usr)
			updateUsrDialog()
			update_icon()
	add_fingerprint(usr)
	return


/obj/machinery/suit_storage_unit/proc/toggleUV(mob/user as mob)

	if(!panel_open)
		return
	else
		if(uv_super)
			to_chat(user, "<span class='notice'>You slide the dial back towards \"185nm\".</span>")
			uv_super = FALSE
		else
			to_chat(user, "<span class='notice'>You crank the dial all the way up to \"15nm\".</span>")
			uv_super = TRUE

/obj/machinery/suit_storage_unit/proc/togglesafeties(mob/user as mob)
	if(!panel_open)
		return
	else
		to_chat(user, "<span class='notice'>You push the button. The coloured LED next to it changes.</span>")
		safeties = !safeties

/obj/machinery/suit_storage_unit/proc/dispense_helmet(mob/user as mob)
	if(!helmet)
		return
	else
		helmet.forceMove(loc)
		helmet = null

/obj/machinery/suit_storage_unit/proc/dispense_suit(mob/user as mob)
	if(!suit)
		return
	else
		suit.forceMove(loc)
		suit = null

/obj/machinery/suit_storage_unit/proc/dispense_mask(mob/user as mob)
	if(!mask)
		return
	else
		mask.forceMove(loc)
		mask = null

/obj/machinery/suit_storage_unit/proc/dispense_storage(mob/user as mob)
	if(!storage)
		return
	else
		storage.forceMove(loc)
		storage = null

/obj/machinery/suit_storage_unit/proc/toggle_open(mob/user as mob)
	if(locked || uv)
		to_chat(user, "<span class='danger'>Unable to open unit.</span>")
		return
	if(occupant)
		eject_occupant(user)
		return
	state_open = !state_open

/obj/machinery/suit_storage_unit/proc/toggle_lock(mob/user as mob)
	if(occupant && safeties)
		to_chat(user, "<span class='warning'>The unit's safety protocols disallow locking when a biological form is detected inside its compartments.</span>")
		return
	if(state_open)
		return
	locked = !locked

/obj/machinery/suit_storage_unit/proc/eject_occupant(mob/user as mob)
	if(locked)
		return

	if(!occupant)
		return

	if(user != occupant)
		to_chat(occupant, "<span class='warning'>The machine kicks you out!</span>")
	if(user.loc != loc)
		to_chat(occupant, "<span class='warning'>You leave the not-so-cozy confines of the SSU.</span>")
	occupant.forceMove(loc)
	occupant = null
	if(!state_open)
		state_open = 1
	update_icon()
	return


/obj/machinery/suit_storage_unit/verb/get_out()
	set name = "Eject Suit Storage Unit"
	set category = "Object"
	set src in oview(1)

	if(usr.stat != 0)
		return
	eject_occupant(usr)
	add_fingerprint(usr)
	updateUsrDialog()
	update_icon()
	return

/obj/machinery/suit_storage_unit/verb/move_inside()
	set name = "Hide in Suit Storage Unit"
	set category = "Object"
	set src in oview(1)

	if(usr.stat != 0)
		return
	if(!state_open)
		to_chat(usr, "<span class='warning'>The unit's doors are shut.</span>")
		return
	if(broken)
		to_chat(usr, "<span class='warning'>The unit is not operational.</span>")
		return
	if((occupant) || (helmet) || (suit) || (storage))
		to_chat(usr, "<span class='warning'>It's too cluttered inside for you to fit in!</span>")
		return
	visible_message("[usr] starts squeezing into the suit storage unit!")
	if(do_after(usr, 10, target = usr))
		usr.stop_pulling()
		usr.forceMove(src)
		occupant = usr
		state_open = FALSE //Close the thing after the guy gets inside
		update_icon()

		add_fingerprint(usr)
		updateUsrDialog()
		return
	else
		occupant = null

/obj/machinery/suit_storage_unit/attack_ai(mob/user as mob)
	return attack_hand(user)

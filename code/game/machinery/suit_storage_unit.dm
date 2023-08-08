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
	var/obj/item/clothing/shoes/magboots/magboots = null
	var/obj/item/storage = null

	var/helmet_type = null
	var/suit_type = null
	var/mask_type = null
	var/magboots_type = null
	var/storage_type = null

	var/controls_inside = FALSE
	var/locked = FALSE
	var/safeties = TRUE
	var/broken = FALSE
	var/shocked = FALSE//is it shocking anyone that touches it?
	req_access = list()	//the ID needed if ID lock is enabled
	var/datum/wires/suitstorage/wires = null

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

/obj/machinery/suit_storage_unit/standard_unit/ertamber
	name = "ERT Amber storage unit"
	suit_type    = /obj/item/clothing/suit/space/ert_eva_amber
	helmet_type  = /obj/item/clothing/head/helmet/space/ert_eva_amber
	mask_type    = /obj/item/clothing/mask/gas/sechailer
	storage_type = /obj/item/tank/internals/oxygen/red
/obj/machinery/suit_storage_unit/captain
	name = "captain's suit storage unit"
	desc = "An industrial U-Stor-It Storage unit designed to accomodate all kinds of space suits. Its on-board equipment also allows the user to decontaminate the contents through a UV-ray purging cycle. There's a warning label dangling from the control pad, reading \"STRICTLY NO BIOLOGICALS IN THE CONFINES OF THE UNIT\". This one looks kind of fancy."
	suit_type    = /obj/item/clothing/suit/space/captain
	helmet_type  = /obj/item/clothing/head/helmet/space/capspace
	mask_type    = /obj/item/clothing/mask/gas
	magboots_type = /obj/item/clothing/shoes/magboots/security/captain
	storage_type = /obj/item/tank/jetpack/oxygen/captain
	req_access = list(ACCESS_CAPTAIN)

/obj/machinery/suit_storage_unit/engine
	name = "engineering suit storage unit"
	suit_type    = /obj/item/clothing/suit/space/hardsuit/engine
	mask_type    = /obj/item/clothing/mask/breath
	magboots_type = /obj/item/clothing/shoes/magboots
	req_access = list(ACCESS_ENGINE_EQUIP)

/obj/machinery/suit_storage_unit/ce
	name = "chief engineer's suit storage unit"
	suit_type    = /obj/item/clothing/suit/space/hardsuit/engine/elite
	storage_type = /obj/item/tank/internals/oxygen
	mask_type    = /obj/item/clothing/mask/gas
	magboots_type = /obj/item/clothing/shoes/magboots/advance
	req_access = list(ACCESS_CE)

/obj/machinery/suit_storage_unit/security
	name = "security suit storage unit"
	suit_type    = /obj/item/clothing/suit/space/hardsuit/security
	mask_type    = /obj/item/clothing/mask/gas/sechailer
	storage_type = /obj/item/tank/jetpack/oxygen/security
	magboots_type = /obj/item/clothing/shoes/magboots/security
	req_access = list(ACCESS_SECURITY)

/obj/machinery/suit_storage_unit/security/hos
	name = "head of security suit storage unit"
	suit_type = /obj/item/clothing/suit/space/hardsuit/security/hos
	storage_type = /obj/item/tank/internals/oxygen/red
	req_access = list(ACCESS_HOS)

/obj/machinery/suit_storage_unit/security/warden
	name = "warden's suit storage unit"
	suit_type = /obj/item/clothing/suit/space/hardsuit/security/warden
	req_access = list(ACCESS_ARMORY)

/obj/machinery/suit_storage_unit/security/pod_pilot
	req_access = list(ACCESS_PILOT)

/obj/machinery/suit_storage_unit/brigmed
	name = "brig physician suit storage unit"
	suit_type    = /obj/item/clothing/suit/space/hardsuit/security/brigmed
	mask_type    = /obj/item/clothing/mask/gas/sechailer
	storage_type = /obj/item/tank/jetpack/oxygen
	magboots_type = /obj/item/clothing/shoes/magboots/security

/obj/machinery/suit_storage_unit/atmos
	name = "atmospherics suit storage unit"
	suit_type    = /obj/item/clothing/suit/space/hardsuit/engine/atmos
	mask_type    = /obj/item/clothing/mask/gas
	magboots_type = /obj/item/clothing/shoes/magboots/atmos
	req_access = list(ACCESS_ATMOSPHERICS)

/obj/machinery/suit_storage_unit/mining
	name = "mining suit storage unit"
	suit_type    = /obj/item/clothing/suit/space/hardsuit/mining
	mask_type    = /obj/item/clothing/mask/breath
	req_access = list(ACCESS_MINING_STATION)

/obj/machinery/suit_storage_unit/lavaland
	name = "mining suit storage unit"
	suit_type = /obj/item/clothing/suit/hooded/explorer
	mask_type = /obj/item/clothing/mask/gas/explorer
	req_access = list(ACCESS_MINING_STATION)

/obj/machinery/suit_storage_unit/cmo
	suit_type    = /obj/item/clothing/suit/space/hardsuit/medical
	storage_type = /obj/item/tank/internals/oxygen
	mask_type    = /obj/item/clothing/mask/breath
	req_access = list(ACCESS_CMO)

//version of the SSU for medbay secondary storage. Includes magboots.
/obj/machinery/suit_storage_unit/cmo/sec_storage
	name = "medical suit storage unit"
	storage_type = null
	mask_type = /obj/item/clothing/mask/gas

/obj/machinery/suit_storage_unit/clown
	name = "clown suit storage unit"
	suit_type = /obj/item/clothing/suit/space/eva/clown
	helmet_type  = /obj/item/clothing/head/helmet/space/eva/clown
	req_access = list(ACCESS_CLOWN)

/obj/machinery/suit_storage_unit/blueshield
	name = "blueshield suit storage unit"
	suit_type = /obj/item/clothing/suit/space/hardsuit/blueshield
	magboots_type = /obj/item/clothing/shoes/magboots/security
	storage_type = /obj/item/tank/internals/oxygen
	req_access = list(ACCESS_BLUESHIELD)
/obj/machinery/suit_storage_unit/rd
	name = "research director's suit storage unit"
	suit_type = /obj/item/clothing/suit/space/hardsuit/rd
	storage_type = /obj/item/tank/internals/oxygen
	mask_type = /obj/item/clothing/mask/gas
	magboots_type = /obj/item/clothing/shoes/magboots
	req_access = list(ACCESS_RD)

/obj/machinery/suit_storage_unit/mime
	name = "mime suit storage unit"
	suit_type = /obj/item/clothing/suit/space/eva/mime
	helmet_type  = /obj/item/clothing/head/helmet/space/eva/mime
	req_access = list(ACCESS_MIME)

/obj/machinery/suit_storage_unit/syndicate
	name = "syndicate suit storage unit"
	suit_type   	 = /obj/item/clothing/suit/space/hardsuit/syndi
	mask_type    	= /obj/item/clothing/mask/gas/syndicate
	storage_type 	= /obj/item/tank/jetpack/oxygen/harness
	req_access = list(ACCESS_SYNDICATE)
	safeties = FALSE	//in a syndicate base, everything can be used as a murder weapon at a moment's notice.

/obj/machinery/suit_storage_unit/syndicate/comms
	name = "syndicate suit storage unit"
	suit_type = /obj/item/clothing/suit/space/hardsuit/syndi/elite/comms
	mask_type = /obj/item/clothing/mask/gas/syndicate
	magboots_type = /obj/item/clothing/shoes/magboots/syndie/advance
	storage_type = /obj/item/tank/jetpack/oxygen/harness
	req_access = list(ACCESS_SYNDICATE_COMMS_OFFICER)

/obj/machinery/suit_storage_unit/ert
	req_access = list(ACCESS_CENT_GENERAL)

/obj/machinery/suit_storage_unit/ert/command
	suit_type    = /obj/item/clothing/suit/space/hardsuit/ert/commander
	mask_type    = /obj/item/clothing/mask/breath
	storage_type = /obj/item/tank/internals/emergency_oxygen/double

/obj/machinery/suit_storage_unit/ert/security
	suit_type    = /obj/item/clothing/suit/space/hardsuit/ert/security
	mask_type    = /obj/item/clothing/mask/breath
	storage_type = /obj/item/tank/internals/emergency_oxygen/double

/obj/machinery/suit_storage_unit/ert/engineer
	suit_type    = /obj/item/clothing/suit/space/hardsuit/ert/engineer
	mask_type    = /obj/item/clothing/mask/breath
	storage_type = /obj/item/tank/internals/emergency_oxygen/double

/obj/machinery/suit_storage_unit/ert/medical
	suit_type    = /obj/item/clothing/suit/space/hardsuit/ert/medical
	mask_type    = /obj/item/clothing/mask/breath
	storage_type = /obj/item/tank/internals/emergency_oxygen/double

//telecoms NASA SSU. Suits themselves are assigned in Initialize
/obj/machinery/suit_storage_unit/telecoms
	mask_type    = /obj/item/clothing/mask/breath
	storage_type = /obj/item/tank/jetpack/void
	req_access = list(ACCESS_TCOMSAT)

/obj/machinery/suit_storage_unit/radsuit
	name = "radiation suit storage unit"
	suit_type = /obj/item/clothing/suit/radiation
	helmet_type = /obj/item/clothing/head/radiation

//copied from /obj/effect/nasavoidsuitspawner
/obj/machinery/suit_storage_unit/telecoms/Initialize()
	switch(pick(list("red", "green", "ntblue", "purple", "yellow", "ltblue")))
		if("red")
			helmet_type = /obj/item/clothing/head/helmet/space/nasavoid
			suit_type = /obj/item/clothing/suit/space/nasavoid
		if("green")
			helmet_type =  /obj/item/clothing/head/helmet/space/nasavoid/green
			suit_type = /obj/item/clothing/suit/space/nasavoid/green
		if("ntblue")
			helmet_type =  /obj/item/clothing/head/helmet/space/nasavoid/ntblue
			suit_type = /obj/item/clothing/suit/space/nasavoid/ntblue
		if("purple")
			helmet_type = /obj/item/clothing/head/helmet/space/nasavoid/purple
			suit_type = /obj/item/clothing/suit/space/nasavoid/purple
		if("yellow")
			helmet_type =  /obj/item/clothing/head/helmet/space/nasavoid/yellow
			suit_type = /obj/item/clothing/suit/space/nasavoid/yellow
		if("ltblue")
			helmet_type =  /obj/item/clothing/head/helmet/space/nasavoid/ltblue
			suit_type = /obj/item/clothing/suit/space/nasavoid/ltblue
	..()


/obj/machinery/suit_storage_unit/New()
	..()
	wires = new(src)

/obj/machinery/suit_storage_unit/Initialize()
	. = ..()
	if(suit_type)
		suit = new suit_type(src)
	if(helmet_type)
		helmet = new helmet_type(src)
	if(mask_type)
		mask = new mask_type(src)
	if(magboots_type)
		magboots = new magboots_type(src)
	if(storage_type)
		storage = new storage_type(src)
	update_icon()

	//move this into machinery eventually...
	if(occupant_typecache)
		occupant_typecache = typecacheof(occupant_typecache)

/obj/machinery/suit_storage_unit/Destroy()
	SStgui.close_uis(wires)
	QDEL_NULL(wires)
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
	if(!locked)
		add_overlay("unlocked")

/obj/machinery/suit_storage_unit/attackby(obj/item/I, mob/user, params)
	if(shocked)
		add_fingerprint(user)
		if(shock(user, 100))
			return
	if(!is_operational())
		add_fingerprint(user)
		if(panel_open)
			to_chat(usr, span_warning("Close the maintenance panel first."))
		else
			to_chat(usr, span_warning("The unit is not operational."))
		return
	if(panel_open)
		add_fingerprint(user)
		wires.Interact(user)
		return
	if(state_open)
		add_fingerprint(user)
		if(store_item(I, user))
			update_icon()
			SStgui.update_uis(src)
			to_chat(user, span_notice("You load the [I] into the storage compartment."))
		else
			to_chat(user, span_warning("You can't fit [I] into [src]!"))
		return
	return ..()

/obj/machinery/suit_storage_unit/screwdriver_act(mob/user, obj/item/I)
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	. = TRUE
	if(shocked && !(stat & NOPOWER))
		if(shock(user, 100))
			return
	default_deconstruction_screwdriver(user, "panel", "close", I)

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
	if(istype(I, /obj/item/clothing/shoes/magboots) && !magboots)
		magboots = I
		. = TRUE
	if((istype(I, /obj/item/tank)) && !storage)
		storage = I
		. = TRUE
	if(.)
		user.drop_transfer_item_to_loc(I, src)


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
	magboots = null
	storage = null
	occupant = null

/obj/machinery/suit_storage_unit/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		open_machine()
		dump_contents()
		new /obj/item/stack/sheet/metal (loc, 2)
	qdel(src)

/obj/machinery/suit_storage_unit/MouseDrop_T(atom/A, mob/user)
	if(user.stat || user.lying || !Adjacent(user) || !Adjacent(A) || !isliving(A))
		return
	var/mob/living/target = A
	if(!state_open)
		to_chat(user, span_warning("The [src]'s doors are shut!"))
		return
	if(!is_operational())
		to_chat(user, span_warning("The [src] is not operational!"))
		return
	if(occupant || helmet || suit || storage)
		to_chat(user, span_warning("It's too cluttered inside to fit in!"))
		return

	if(target == user)
		user.visible_message(span_warning("[user] starts squeezing into [src]!"), span_notice("You start working your way into [src]..."))
	else
		target.visible_message(span_warning("[user] starts shoving [target] into [src]!"), span_userdanger("[user] starts shoving you into [src]!"))

	if(do_mob(user, target, 30))
		if(occupant || helmet || suit || storage)
			return
		if(target == user)
			user.visible_message(span_warning("[user] slips into [src] and closes the door behind [user.p_them()]!"), span_notice("You slip into [src]'s cramped space and shut its door."))
		else
			target.visible_message(span_warning("[user] pushes [target] into [src] and shuts its door!"), span_userdanger("[user] shoves you into [src] and shuts the door!"))
		close_machine(target)
		add_fingerprint(user)

/obj/machinery/suit_storage_unit/proc/cook()
	if(uv_cycles)
		uv_cycles--
		uv = TRUE
		if(occupant)
			var/mob/living/mob_occupant = occupant
			if(uv_super)
				mob_occupant.adjustFireLoss(rand(20, 36))
			else
				mob_occupant.adjustFireLoss(rand(10, 16))
			mob_occupant.emote("scream")
		addtimer(CALLBACK(src, PROC_REF(cook)), 50)
	else
		uv_cycles = initial(uv_cycles)
		uv = FALSE
		locked = FALSE
		if(uv_super)
			visible_message(span_warning("[src]'s door creaks open with a loud whining noise. A cloud of foul black smoke escapes from its chamber."))
			playsound(src, 'sound/machines/airlock_alien_prying.ogg', 50, 1)
			qdel(helmet)
			qdel(mask)
			qdel(magboots)
			qdel(storage)
			qdel(suit)
			helmet = null
			suit = null
			mask = null
			magboots = null
			storage = null

		else
			if(!occupant)
				visible_message(span_notice("[src]'s door slides open. The glowing yellow lights dim to a gentle green."))
			else
				visible_message(span_warning("[src]'s door slides open, barraging you with the nauseating smell of charred flesh."))
			playsound(src, 'sound/machines/airlock_close.ogg', 25, 1)
		if(occupant)
			dump_contents()
		update_icon()
		SStgui.update_uis(src)

/obj/machinery/suit_storage_unit/relaymove(mob/user)
	if(locked)
		if(message_cooldown <= world.time)
			message_cooldown = world.time + 50
			to_chat(user, span_warning("[src]'s door won't budge!"))
		return
	open_machine()
	dump_contents()

/obj/machinery/suit_storage_unit/container_resist(mob/living/user)
	if(!locked)
		open_machine()
		dump_contents()
		return
	user.visible_message(span_notice("You see [user] kicking against the doors of [src]!"), \
		span_notice("You start kicking against the doors... (this will take about [DisplayTimeText(breakout_time)].)"), \
		span_italics("You hear a thump from [src]."))
	if(do_after(user,(breakout_time), target = src))
		if(!user || user.stat != CONSCIOUS || user.loc != src )
			return
		user.visible_message(span_warning("[user] successfully broke out of [src]!"), \
			span_notice("You successfully break out of [src]!"))
		open_machine()
		dump_contents()

	add_fingerprint(user)
	if(locked)
		visible_message(span_notice("You see [user] kicking against the doors of [src]!"), \
			span_notice("You start kicking against the doors..."))
		addtimer(CALLBACK(src, PROC_REF(resist_open), user), 300)
	else
		open_machine()
		dump_contents()

/obj/machinery/suit_storage_unit/proc/resist_open(mob/user)
	if(!state_open && occupant && (user in src) && !user.stat) // Check they're still here.
		visible_message(span_notice("You see [user] burst out of [src]!"), \
			span_notice("You escape the cramped confines of [src]!"))
		open_machine()

//eventually move these onto the parent....

/obj/machinery/suit_storage_unit/proc/open_machine(drop = TRUE)
	state_open = TRUE
	if(drop)
		dropContents()
	update_icon()
	SStgui.update_uis(src)

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
	SStgui.update_uis(src)
	update_icon()


////////

/obj/machinery/suit_storage_unit/attack_hand(mob/user)
	if(..() || (stat & NOPOWER))
		return
	if(shocked && shock(user, 100))
		return
	if(panel_open) //The maintenance panel is open. Time for some shady stuff
		wires.Interact(user)
		return
	ui_interact(user)

/obj/machinery/suit_storage_unit/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "SuitStorage", name, 402, 268, master_ui, state)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/suit_storage_unit/ui_data(mob/user)
	var/list/data = list(
		"locked" = locked,
		"open" = state_open,
		"broken" = broken,
		"helmet" = helmet ? helmet.name : null,
		"suit" = suit ? suit.name : null,
		"magboots" = magboots ? magboots.name : null,
		"mask" = mask ? mask.name : null,
		"storage" = storage ? storage.name : null,
		"uv" = uv
	)
	return data

/obj/machinery/suit_storage_unit/ui_act(action, list/params)
	if(..())
		return
	add_fingerprint(usr)
	if(!controls_inside && usr == occupant)
		return
	if(shocked && !(stat & NOPOWER))
		if(shock(usr, 100))
			return FALSE

	. = TRUE
	switch(action)
		if("dispense_helmet")
			dispense_helmet()
		if("dispense_suit")
			dispense_suit()
		if("dispense_mask")
			dispense_mask()
		if("dispense_magboots")
			dispense_magboots()
		if("dispense_storage")
			dispense_storage()
		if("toggle_open")
			toggle_open(usr)
		if("toggle_lock")
			toggle_lock(usr)
		if("cook")
			cook()
		if("eject_occupant")
			eject_occupant(usr)
	update_icon()

/obj/machinery/suit_storage_unit/proc/dispense_helmet()
	if(!helmet)
		return
	else
		helmet.forceMove(loc)
		if(ishuman(usr))
			usr.put_in_active_hand(helmet, ignore_anim = FALSE)
		helmet = null

/obj/machinery/suit_storage_unit/proc/dispense_suit()
	if(!suit)
		return
	else
		suit.forceMove(loc)
		if(ishuman(usr))
			usr.put_in_active_hand(suit, ignore_anim = FALSE)
		suit = null

/obj/machinery/suit_storage_unit/proc/dispense_mask()
	if(!mask)
		return
	else
		mask.forceMove(loc)
		if(ishuman(usr))
			usr.put_in_active_hand(mask, ignore_anim = FALSE)
		mask = null

/obj/machinery/suit_storage_unit/proc/dispense_magboots()
	if(!magboots)
		return
	else
		magboots.forceMove(loc)
		if(ishuman(usr))
			usr.put_in_active_hand(magboots, ignore_anim = FALSE)
		magboots = null

/obj/machinery/suit_storage_unit/proc/dispense_storage()
	if(!storage)
		return
	else
		storage.forceMove(loc)
		if(ishuman(usr))
			usr.put_in_active_hand(storage, ignore_anim = FALSE)
		storage = null

/obj/machinery/suit_storage_unit/proc/toggle_open(mob/user as mob)
	if(locked || uv)
		to_chat(user, span_danger("Unable to open unit."))
		return
	if(occupant)
		eject_occupant(user)
		return
	state_open = !state_open

/obj/machinery/suit_storage_unit/proc/toggle_lock(mob/user as mob)
	if(!allowed(user))
		to_chat(user, span_warning("Access denied."))
		return
	if(occupant && safeties)
		to_chat(user, span_warning("The unit's safety protocols disallow locking when a biological form is detected inside its compartments."))
		return
	if(state_open)
		return
	if(emagged)
		to_chat(user, span_warning("Locking mechanism doesn't seem to work."))
		return
	locked = !locked

/obj/machinery/suit_storage_unit/proc/eject_occupant(mob/user as mob)
	if(locked)
		return

	if(!occupant)
		return

	if(user)
		if(user != occupant)
			to_chat(occupant, span_warning("The machine kicks you out!"))
		if(user.loc != loc)
			to_chat(occupant, span_warning("You leave the not-so-cozy confines of [src]."))
	occupant.forceMove(loc)
	occupant = null
	if(!state_open)
		state_open = 1
	update_icon()
	return

/obj/machinery/suit_storage_unit/force_eject_occupant(mob/target)
	eject_occupant()

/obj/machinery/suit_storage_unit/verb/get_out()
	set name = "Eject Suit Storage Unit"
	set category = "Object"
	set src in oview(1)

	if(usr.stat != 0)
		return
	eject_occupant(usr)
	add_fingerprint(usr)
	SStgui.update_uis(src)
	update_icon()
	return

/obj/machinery/suit_storage_unit/verb/move_inside()
	set name = "Hide in Suit Storage Unit"
	set category = "Object"
	set src in oview(1)

	if(usr.stat != 0)
		return
	if(usr.incapacitated() || usr.buckled) //are you cuffed, dying, lying, stunned or other
		return
	if(!state_open)
		to_chat(usr, span_warning("The unit's doors are shut."))
		return
	if(broken)
		to_chat(usr, span_warning("The unit is not operational."))
		return
	if((occupant) || (helmet) || (suit) || (storage))
		to_chat(usr, span_warning("It's too cluttered inside for you to fit in!"))
		return
	visible_message("[usr] starts squeezing into the suit storage unit!")
	if(do_after(usr, 10, target = usr))
		usr.stop_pulling()
		usr.forceMove(src)
		occupant = usr
		state_open = FALSE //Close the thing after the guy gets inside
		update_icon()

		add_fingerprint(usr)
		SStgui.update_uis(src)
		return
	else
		occupant = null

/obj/machinery/suit_storage_unit/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/suit_storage_unit/proc/check_electrified_callback()
	if(!wires.is_cut(WIRE_ELECTRIFY))
		shocked = FALSE

/obj/machinery/suit_storage_unit/emag_act(mob/user)
	if(emagged)
		return

	add_attack_logs(user, src, "emagged")
	locked = FALSE
	emagged = TRUE
	update_icon()
	SStgui.update_uis(src)
	to_chat(user, span_warning("You burn the locking mechanism, unlocking it forever."))
	do_sparks(5, 0, loc)
	playsound(loc, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

// SUIT STORAGE UNIT /////////////////
/obj/machinery/suit_storage_unit
	name = "suit storage unit"
	desc = "An industrial U-Stor-It Storage unit designed to accommodate all kinds of space suits. Its on-board equipment also allows the user to decontaminate the contents through a UV-ray purging cycle. There's a warning label dangling from the control pad, reading \"STRICTLY NO BIOLOGICALS IN THE CONFINES OF THE UNIT\"."
	icon = 'icons/obj/machines/suit_storage.dmi'
	icon_state = "classic"
	base_icon_state = "classic"
	anchored = TRUE
	density = TRUE
	max_integrity = 250

	var/obj/item/clothing/suit/suit = null
	var/obj/item/clothing/head/helmet = null
	var/obj/item/clothing/mask/mask = null
	var/obj/item/clothing/shoes/boots = null
	var/obj/item/storage = null

	var/helmet_type = null
	var/suit_type = null
	var/mask_type = null
	var/boots_type = null
	var/storage_type = null

	var/locked = FALSE
	/// prevent locking people in there if set to true
	var/safeties = TRUE
	var/broken = FALSE

	/// enables ID locking when set to true
	var/secure = FALSE
	/// Shocks anyone that touches it
	var/shocked = FALSE
	/// Access needed to control it, checked only if ID lock is enabled
	req_access = list(ACCESS_EVA)
	var/datum/wires/suitstorage/wires = null

	/// Is true if a uv cleaning cycle is currently running.
	var/uv = FALSE
	/// If set to true, uses much more damaging UV wavelength and fries anything inside.
	var/uv_super = FALSE
	/// How many uv cleaning cycles to do, counts down while cleaning takes place.
	var/uv_cycles = 6
	var/message_cooldown
	var/breakout_time = 300

	//abstract these onto machinery eventually
	var/state_open = FALSE
	/// If set, turned into typecache in Initialize, other wise, defaults to mob/living typecache
	var/list/occupant_typecache
	var/atom/movable/occupant = null
	var/board_type = /obj/item/circuitboard/suit_storage_unit

/obj/machinery/suit_storage_unit/industrial
	name = "industrial suit storage unit"
	icon_state = "industrial"
	base_icon_state = "industrial"
	board_type = /obj/item/circuitboard/suit_storage_unit/industrial

/obj/machinery/suit_storage_unit/standard_unit
	suit_type	= /obj/item/clothing/suit/space/eva
	helmet_type	= /obj/item/clothing/head/helmet/space/eva
	mask_type	= /obj/item/clothing/mask/breath

/obj/machinery/suit_storage_unit/standard_unit/secure
	secure = TRUE	//start with ID lock enabled

/obj/machinery/suit_storage_unit/captain
	name = "captain's suit storage unit"
	desc = "An U-Stor-It Storage unit designed to accommodate all kinds of space suits. Its on-board equipment also allows the user to decontaminate the contents through a UV-ray purging cycle. There's a warning label dangling from the control pad, reading \"STRICTLY NO BIOLOGICALS IN THE CONFINES OF THE UNIT\". This one looks kind of fancy."
	helmet_type	= /obj/item/clothing/head/helmet/space/capspace //Looks like they couldn't handle the Neutron Style
	mask_type	= /obj/item/clothing/mask/gas
	suit_type = /obj/item/mod/control/pre_equipped/magnate
	req_access	= list(ACCESS_CAPTAIN)

/obj/machinery/suit_storage_unit/captain/secure
	secure = TRUE

/obj/machinery/suit_storage_unit/engine
	name = "engineering suit storage unit"
	icon_state = "industrial"
	base_icon_state = "industrial"
	mask_type	= /obj/item/clothing/mask/breath
	boots_type = /obj/item/clothing/shoes/magboots
	suit_type = /obj/item/mod/control/pre_equipped/engineering
	req_access	= list(ACCESS_ENGINE_EQUIP)
	board_type = /obj/item/circuitboard/suit_storage_unit/industrial

/obj/machinery/suit_storage_unit/engine/secure
	secure = TRUE

/obj/machinery/suit_storage_unit/ce
	name = "chief engineer's suit storage unit"
	icon_state = "industrial"
	base_icon_state = "industrial"
	mask_type	= /obj/item/clothing/mask/gas
	boots_type = /obj/item/clothing/shoes/magboots/advance
	suit_type = /obj/item/mod/control/pre_equipped/advanced
	req_access	= list(ACCESS_CE)
	board_type = /obj/item/circuitboard/suit_storage_unit/industrial

/obj/machinery/suit_storage_unit/ce/secure
	secure = TRUE

/obj/machinery/suit_storage_unit/rd
	name = "research director's suit storage unit"
	suit_type = /obj/item/mod/control/pre_equipped/research
	mask_type	= /obj/item/clothing/mask/gas
	req_access	= list(ACCESS_RD)

/obj/machinery/suit_storage_unit/rd/secure
	secure = TRUE

/obj/machinery/suit_storage_unit/qm
	name = "quartermaster's suit storage unit"
	suit_type = /obj/item/mod/control/pre_equipped/loader
	mask_type = /obj/item/clothing/mask/breath
	req_access = list(ACCESS_QM)

/obj/machinery/suit_storage_unit/qm/secure
	secure = TRUE

/obj/machinery/suit_storage_unit/security
	name = "security suit storage unit"
	mask_type	= /obj/item/clothing/mask/gas/sechailer
	suit_type = /obj/item/mod/control/pre_equipped/security
	req_access	= list(ACCESS_SECURITY)

/obj/machinery/suit_storage_unit/security/secure
	secure = TRUE

/obj/machinery/suit_storage_unit/security/hos
	name = "Head of Security's suit storage unit"
	mask_type = /obj/item/clothing/mask/gas/sechailer/hos
	suit_type = /obj/item/mod/control/pre_equipped/safeguard
	req_access = list(ACCESS_HOS)

/obj/machinery/suit_storage_unit/security/hos/secure
	secure = TRUE

/obj/machinery/suit_storage_unit/gamma
	name = "gamma shielded suit storage unit"
	suit_type = /obj/item/clothing/suit/space/hardsuit/shielded/gamma
	mask_type = /obj/item/clothing/mask/gas/sechailer/swat
	req_access = list(ACCESS_SECURITY)

/obj/machinery/suit_storage_unit/gamma/secure
	secure = TRUE

/obj/machinery/suit_storage_unit/atmos
	name = "atmospherics suit storage unit"
	mask_type	= /obj/item/clothing/mask/gas
	boots_type = /obj/item/clothing/shoes/magboots/atmos
	suit_type = /obj/item/mod/control/pre_equipped/atmospheric
	req_access	= list(ACCESS_ATMOSPHERICS)

/obj/machinery/suit_storage_unit/atmos/secure
	secure = TRUE

/obj/machinery/suit_storage_unit/mining
	name = "mining suit storage unit"
	mask_type	= /obj/item/clothing/mask/breath
	suit_type = /obj/item/mod/control/pre_equipped/mining/asteroid
	req_access	= list(ACCESS_MINING_STATION)

/obj/machinery/suit_storage_unit/mining/secure
	secure = TRUE

/obj/machinery/suit_storage_unit/lavaland
	name = "mining suit storage unit"
	suit_type = /obj/item/clothing/suit/hooded/explorer
	mask_type = /obj/item/clothing/mask/gas/explorer
	storage_type = /obj/item/gps/mining
	req_access = list(ACCESS_MINING_STATION)

/obj/machinery/suit_storage_unit/cmo
	mask_type	= /obj/item/clothing/mask/breath
	suit_type = /obj/item/mod/control/pre_equipped/medical
	req_access	= list(ACCESS_CMO)

/obj/machinery/suit_storage_unit/cmo/secure
	secure = TRUE

//version of the SSU for medbay secondary storage. Includes magboots. //no it doesn't, it aint have shit for magboots
/obj/machinery/suit_storage_unit/cmo/secure/sec_storage
	name = "medical suit storage unit"
	mask_type = /obj/item/clothing/mask/gas

/obj/machinery/suit_storage_unit/clown
	name = "clown suit storage unit"
	suit_type = /obj/item/clothing/suit/space/eva/clown
	helmet_type  = /obj/item/clothing/head/helmet/space/eva/clown
	req_access = list(ACCESS_CLOWN)

/obj/machinery/suit_storage_unit/clown/secure
	secure = TRUE

/obj/machinery/suit_storage_unit/mime
	name = "mime suit storage unit"
	suit_type = /obj/item/clothing/suit/space/eva/mime
	helmet_type  = /obj/item/clothing/head/helmet/space/eva/mime
	req_access = list(ACCESS_MIME)

/obj/machinery/suit_storage_unit/mime/secure
	secure = TRUE

/obj/machinery/suit_storage_unit/syndicate
	name = "syndicate suit storage unit"
	mask_type		= /obj/item/clothing/mask/gas/syndicate
	storage_type	= /obj/item/mod/control/pre_equipped/nuclear
	req_access = list(ACCESS_SYNDICATE)
	safeties = FALSE	//in a syndicate base, everything can be used as a murder weapon at a moment's notice.

/obj/machinery/suit_storage_unit/syndicate/secure
	secure = TRUE

/obj/machinery/suit_storage_unit/ert
	req_access = list(ACCESS_CENT_GENERAL)

/obj/machinery/suit_storage_unit/ert/command
	suit_type	= /obj/item/clothing/suit/space/hardsuit/ert/commander
	mask_type	= /obj/item/clothing/mask/breath
	storage_type = /obj/item/tank/internals/emergency_oxygen/double

/obj/machinery/suit_storage_unit/ert/command/secure
	secure = TRUE

/obj/machinery/suit_storage_unit/ert/security
	suit_type	= /obj/item/clothing/suit/space/hardsuit/ert/security
	mask_type	= /obj/item/clothing/mask/breath
	storage_type = /obj/item/tank/internals/emergency_oxygen/double

/obj/machinery/suit_storage_unit/ert/security/secure
	secure = TRUE

/obj/machinery/suit_storage_unit/ert/engineer
	suit_type	= /obj/item/clothing/suit/space/hardsuit/ert/engineer
	mask_type	= /obj/item/clothing/mask/breath
	storage_type = /obj/item/tank/internals/emergency_oxygen/double

/obj/machinery/suit_storage_unit/ert/engineer/secure
	secure = TRUE

/obj/machinery/suit_storage_unit/ert/medical
	suit_type	= /obj/item/clothing/suit/space/hardsuit/ert/medical
	mask_type	= /obj/item/clothing/mask/breath
	storage_type = /obj/item/tank/internals/emergency_oxygen/double

/obj/machinery/suit_storage_unit/ert/medical/secure
	secure = TRUE

//telecoms NASA SSU. Suits themselves are assigned in Initialize
/obj/machinery/suit_storage_unit/telecoms
	mask_type	= /obj/item/clothing/mask/breath
	storage_type = /obj/item/tank/jetpack/void
	req_access	= list(ACCESS_TCOMSAT)

/obj/machinery/suit_storage_unit/telecoms/secure
	secure = TRUE

/obj/machinery/suit_storage_unit/radsuit
	name = "radiation suit storage unit"
	suit_type	= /obj/item/clothing/suit/radiation
	helmet_type	= /obj/item/clothing/head/radiation
	storage_type = /obj/item/geiger_counter

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

/obj/machinery/suit_storage_unit/Initialize()
	. = ..()

	component_parts = list()
	component_parts += new board_type(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stack/cable_coil(null, 3)
	if(board_type == /obj/item/circuitboard/suit_storage_unit/industrial)
		component_parts += new /obj/item/stack/sheet/plasteel(null)
		component_parts += new /obj/item/stack/sheet/plasteel(null)
		component_parts += new /obj/item/stack/sheet/plasteel(null)
		component_parts += new /obj/item/stack/sheet/plasteel(null)
		component_parts += new /obj/item/stack/sheet/plasteel(null)
	else
		component_parts += new /obj/item/stack/sheet/rglass(null)
		component_parts += new /obj/item/stack/sheet/rglass(null)
		component_parts += new /obj/item/stack/sheet/rglass(null)
		component_parts += new /obj/item/stack/sheet/rglass(null)
		component_parts += new /obj/item/stack/sheet/rglass(null)
	RefreshParts()

	wires = new(src)
	if(suit_type)
		suit = new suit_type(src)
	if(helmet_type)
		helmet = new helmet_type(src)
	if(mask_type)
		mask = new mask_type(src)
	if(boots_type)
		boots = new boots_type(src)
	if(storage_type)
		storage = new storage_type(src)
	update_icon(UPDATE_OVERLAYS)

	//move this into machinery eventually...
	if(occupant_typecache)
		occupant_typecache = typecacheof(occupant_typecache)

/obj/machinery/suit_storage_unit/Destroy()
	dump_contents()
	SStgui.close_uis(wires)
	QDEL_NULL(wires)
	return ..()

/obj/machinery/suit_storage_unit/update_overlays()
	. = ..()
	if(panel_open)
		. += "[base_icon_state]_panel"

	if(uv)
		if(uv_super)
			. += "[base_icon_state]_super"
			. += "[base_icon_state]_[occupant ? "body" : "uvstrong"]"
		else
			. += "[base_icon_state]_[occupant ? "body" : "uv"]"
		. += "[base_icon_state]_lights_red"
		return

	if(state_open)
		. += "[base_icon_state]_open"
		if(suit)
			. += "[base_icon_state]_suit"
		if(helmet)
			. += "[base_icon_state]_helm"
		if(storage)
			. += "[base_icon_state]_storage"
	else
		. += "[base_icon_state]_lights_closed"

	. += "[base_icon_state]_[occupant ? "body" : "ready"]"

/obj/machinery/suit_storage_unit/attackby(obj/item/I, mob/user, params)
	if(shocked)
		if(shock(user, 100))
			return
	if(!is_operational())
		if(user.a_intent != INTENT_HELP)
			return ..()
		if(panel_open)
			to_chat(usr, "<span class='warning'>Close the maintenance panel first.</span>")
		else
			to_chat(usr, "<span class='warning'>The unit is not operational.</span>")
		return
	if(panel_open)
		if(istype(I, /obj/item/crowbar))
			if(locked)
				to_chat(user, "<span class='warning'>The security system prevents you from deconstructing [src]!</span>")
				return
			dump_contents()
			default_deconstruction_crowbar(user, I)
			return
		wires.Interact(user)
		return
	if(state_open)
		if(store_item(I, user))
			update_icon(UPDATE_OVERLAYS)
			SStgui.update_uis(src)
			to_chat(user, "<span class='notice'>You load [I] into the storage compartment.</span>")
		else
			to_chat(user, "<span class='warning'>You can't fit [I] into [src]!</span>")
		return
	return ..()

/obj/machinery/suit_storage_unit/screwdriver_act(mob/user, obj/item/I)
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	. = TRUE
	if(shocked && !(stat & NOPOWER))
		if(shock(user, 100))
			return
	if(default_deconstruction_screwdriver(user, "[base_icon_state]", "[base_icon_state]", I))
		update_icon(UPDATE_OVERLAYS)

/**
  * Tries to store the item into whatever slot it can go, returns true if the item is stored successfully.
  *
**/
/obj/machinery/suit_storage_unit/proc/store_item(obj/item/I, mob/user)
	if((istype(I, /obj/item/clothing/suit)|| istype(I, /obj/item/mod/control)) && !suit)
		if(try_store_item(I, user))
			suit = I
			return TRUE
	if(istype(I, /obj/item/clothing/head) && !helmet)
		if(try_store_item(I, user))
			helmet = I
			return TRUE
	if(istype(I, /obj/item/clothing/mask) && !mask)
		if(try_store_item(I, user))
			mask = I
			return TRUE
	if(istype(I, /obj/item/clothing/shoes) && !boots)
		if(try_store_item(I, user))
			boots = I
			return TRUE
	if(((istype(I, /obj/item/tank) || I.w_class <= WEIGHT_CLASS_SMALL)) && !storage)
		if(try_store_item(I, user))
			storage = I
			return TRUE
	return FALSE

/**
  * Tries to store the item, returns true if it's moved successfully, false otherwise (because of nodrop etc)
  *
**/
/obj/machinery/suit_storage_unit/proc/try_store_item(obj/item/I, mob/user)
	if(user.drop_item())
		I.forceMove(src)
		return TRUE
	return FALSE


/obj/machinery/suit_storage_unit/power_change()
	..() //we don't check parent return here because `is_operational` cares about other flags in stat
	if(!is_operational() && state_open)
		open_machine()
		dump_contents()
	update_icon(UPDATE_OVERLAYS)


/obj/machinery/suit_storage_unit/proc/dump_contents()
	dropContents()
	helmet = null
	suit = null
	mask = null
	boots = null
	storage = null
	occupant = null

/obj/machinery/suit_storage_unit/MouseDrop_T(atom/A, mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user) || !Adjacent(A) || !isliving(A))
		return
	var/mob/living/target = A
	if(!state_open)
		to_chat(user, "<span class='warning'>[src]'s doors are shut!</span>")
		return TRUE
	if(!is_operational())
		to_chat(user, "<span class='warning'>[src] is not operational!</span>")
		return TRUE
	if(occupant || helmet || suit || storage)
		to_chat(user, "<span class='warning'>It's too cluttered inside to fit in!</span>")
		return TRUE

	if(target == user)
		user.visible_message("<span class='warning'>[user] starts squeezing into [src]!</span>", "<span class='notice'>You start working your way into [src]...</span>")
	else
		target.visible_message("<span class='warning'>[user] starts shoving [target] into [src]!</span>", "<span class='userdanger'>[user] starts shoving you into [src]!</span>")
	INVOKE_ASYNC(src, TYPE_PROC_REF(/obj/machinery/suit_storage_unit, put_in), user, target)
	return TRUE

/obj/machinery/suit_storage_unit/proc/put_in(mob/user, mob/living/target)
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
		for(var/atom/A in contents)
			A.clean_blood(radiation_clean = FALSE)	// we invoke the radiation cleaning proc directly
			A.clean_radiation(12)	// instead of letting clean_blood do it
		if(uv_super)
			visible_message("<span class='warning'>[src]'s door creaks open with a loud whining noise. A cloud of foul black smoke escapes from its chamber.</span>")
			playsound(src, 'sound/machines/airlock_alien_prying.ogg', 50, 1)
			if(suit && !(suit.resistance_flags & LAVA_PROOF))
				qdel(suit)
				suit = null
			if(helmet && !(helmet.resistance_flags & LAVA_PROOF))
				qdel(helmet)
				helmet = null
			if(mask && !(mask.resistance_flags & LAVA_PROOF))
				qdel(mask)
				mask = null
			if(boots && !(boots.resistance_flags & LAVA_PROOF))
				qdel(boots)
				boots = null
			if(storage && !(storage.resistance_flags & LAVA_PROOF))
				qdel(storage)
				storage = null

		else
			if(!occupant)
				visible_message("<span class='notice'>[src]'s door slides open. The glowing yellow lights dim to a gentle green.</span>")
			else
				visible_message("<span class='warning'>[src]'s door slides open, barraging you with the nauseating smell of charred flesh.</span>")
			playsound(src, 'sound/machines/airlock_close.ogg', 25, 1)
		if(occupant)
			dump_contents()
		update_icon(UPDATE_OVERLAYS)
		SStgui.update_uis(src)

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
	user.visible_message("<span class='notice'>You see [user] kicking against the doors of [src]!</span>", \
		"<span class='notice'>You start kicking against the doors... (this will take about [DisplayTimeText(breakout_time)].)</span>", \
		"<span class='italics'>You hear a thump from [src].</span>")
	if(do_after(user,(breakout_time), target = src))
		if(!user || user.stat != CONSCIOUS || user.loc != src)
			return
		user.visible_message("<span class='warning'>[user] successfully broke out of [src]!</span>", \
			"<span class='notice'>You successfully break out of [src]!</span>")
		open_machine()
		dump_contents()

	add_fingerprint(user)
	if(locked)
		visible_message("<span class='notice'>You see [user] kicking against the doors of [src]!</span>", \
			"<span class='notice'>You start kicking against the doors...</span>")
		addtimer(CALLBACK(src, PROC_REF(resist_open), user), 300)
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
	update_icon(UPDATE_OVERLAYS)
	SStgui.update_uis(src)

/obj/machinery/suit_storage_unit/dropContents()
	var/turf/T = get_turf(src)
	for(var/atom/movable/A in contents)
		A.forceMove(T)
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
	update_icon(UPDATE_OVERLAYS)


////////

/obj/machinery/suit_storage_unit/proc/check_allowed(user)
	if(!(allowed(user) || !secure))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return FALSE
	return TRUE

/obj/machinery/suit_storage_unit/attack_hand(mob/user)
	if(..() || (stat & NOPOWER))
		return
	if(shocked && shock(user, 100))
		return
	if(panel_open) //The maintenance panel is open. Time for some shady stuff
		wires.Interact(user)
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
		"magboots" = boots ? boots.name : null,
		"mask" = mask ? mask.name : null,
		"storage" = storage ? storage.name : null,
		"uv" = uv
	)
	return data

/obj/machinery/suit_storage_unit/ui_act(action, list/params)
	if(..())
		return
	add_fingerprint(usr)
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
		if("dispense_boots")
			dispense_boots()
		if("dispense_storage")
			dispense_storage()
		if("toggle_open")
			if(!check_allowed(usr))
				return FALSE
			toggle_open(usr)
		if("toggle_lock")
			if(!check_allowed(usr))
				return FALSE
			toggle_lock(usr)
		if("cook")
			cook()
		if("eject_occupant")
			eject_occupant(usr)
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/suit_storage_unit/proc/toggleUV()
	if(!panel_open)
		return
	else
		uv_super = !uv_super

/obj/machinery/suit_storage_unit/proc/togglesafeties()
	if(!panel_open)
		return
	else
		safeties = !safeties

/obj/machinery/suit_storage_unit/proc/dispense_helmet()
	if(!helmet)
		return
	else
		helmet.forceMove(loc)
		helmet = null

/obj/machinery/suit_storage_unit/proc/dispense_suit()
	if(!suit)
		return
	else
		suit.forceMove(loc)
		suit = null

/obj/machinery/suit_storage_unit/proc/dispense_mask()
	if(!mask)
		return
	else
		mask.forceMove(loc)
		mask = null

/obj/machinery/suit_storage_unit/proc/dispense_boots()
	if(!boots)
		return
	else
		boots.forceMove(loc)
		boots = null

/obj/machinery/suit_storage_unit/proc/dispense_storage()
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

	if(user)
		if(user != occupant)
			to_chat(occupant, "<span class='warning'>The machine kicks you out!</span>")
		if(user.loc != loc)
			to_chat(occupant, "<span class='warning'>You leave the not-so-cozy confines of [src].</span>")
	occupant.forceMove(loc)
	occupant = null
	if(!state_open)
		state_open = 1
	update_icon(UPDATE_OVERLAYS)
	return

/obj/machinery/suit_storage_unit/force_eject_occupant(mob/target)
	eject_occupant()

/obj/machinery/suit_storage_unit/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/suit_storage_unit/proc/check_electrified_callback()
	if(!wires.is_cut(WIRE_ELECTRIFY))
		shocked = FALSE

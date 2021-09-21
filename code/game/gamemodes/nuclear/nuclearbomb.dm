#define NUKE_INTACT 0
#define NUKE_COVER_OFF 1
#define NUKE_COVER_OPEN 2
#define NUKE_SEALANT_OPEN 3
#define NUKE_UNWRENCHED 4
#define NUKE_MOBILE 5
#define NUKE_CORE_EVERYTHING_FINE 6
#define NUKE_CORE_PANEL_EXPOSED 7
#define NUKE_CORE_PANEL_UNWELDED 8
#define NUKE_CORE_FULLY_EXPOSED 9

GLOBAL_VAR(bomb_set)

/obj/machinery/nuclearbomb
	name = "\improper Nuclear Fission Explosive"
	desc = "Uh oh. RUN!!!!"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "nuclearbomb0"
	density = 1
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	anchored = TRUE
	var/extended = TRUE
	var/lighthack = FALSE
	var/timeleft = 120
	var/timing = FALSE
	var/exploded = FALSE
	var/r_code = "ADMIN"
	var/code
	var/yes_code = FALSE
	var/safety = TRUE
	var/obj/item/disk/nuclear/auth = null
	var/obj/item/nuke_core/plutonium/core = null
	var/lastentered
	var/is_syndicate = FALSE
	use_power = NO_POWER_USE
	var/previous_level = ""
	var/datum/wires/nuclearbomb/wires = null
	var/removal_stage = NUKE_INTACT
	///The same state removal stage is, until someone opens the panel of the nuke. This way we can have someone open the front of the nuke, while keeping track of where in the world we are on the anchoring bolts.
	var/anchor_stage = NUKE_INTACT
	///This is so that we can check if the internal components are sealed up properly when the outer hatch is closed.
	var/core_stage = NUKE_CORE_EVERYTHING_FINE

/obj/machinery/nuclearbomb/syndicate
	is_syndicate = TRUE

/obj/machinery/nuclearbomb/undeployed
	extended = FALSE
	anchored = FALSE

/obj/machinery/nuclearbomb/Initialize()
	. = ..()
	r_code = rand(10000, 99999) // Creates a random code upon object spawn.
	wires = new/datum/wires/nuclearbomb(src)
	previous_level = get_security_level()
	GLOB.poi_list |= src
	core = new /obj/item/nuke_core/plutonium(src)
	STOP_PROCESSING(SSobj, core) //Let us not irradiate the vault by default.

/obj/machinery/nuclearbomb/Destroy()
	SStgui.close_uis(wires)
	QDEL_NULL(wires)
	QDEL_NULL(core)
	GLOB.poi_list.Remove(src)
	return ..()

/obj/machinery/nuclearbomb/process()
	if(timing)
		GLOB.bomb_set = TRUE // So long as there is one nuke timing, it means one nuke is armed.
		timeleft = max(timeleft - 2, 0) // 2 seconds per process()
		if(timeleft <= 0)
			INVOKE_ASYNC(src, .proc/explode)
	return

/obj/machinery/nuclearbomb/attackby(obj/item/O as obj, mob/user as mob, params)
	if(istype(O, /obj/item/disk/nuclear))
		if(extended)
			if(!user.drop_item())
				to_chat(user, "<span class='notice'>[O] is stuck to your hand!</span>")
				return
			O.forceMove(src)
			auth = O
			add_fingerprint(user)
			return attack_hand(user)
		else
			to_chat(user, "<span class='notice'>You need to deploy [src] first.</span>")
		return
	if(istype(O, /obj/item/stack/sheet/mineral/titanium) && removal_stage == NUKE_CORE_FULLY_EXPOSED)
		if(do_after(user, 2 SECONDS, target = src))
			var/obj/item/stack/S = O
			if(!loc || !S || S.get_amount() < 5)
				return
			S.use(5)
			user.visible_message("<span class='notice'>[user] repairs [src]'s inner core plate.</span>", "<span class='notice'>You repair [src]'s inner core plate. The radiation is contained.</span>")
			removal_stage = NUKE_CORE_PANEL_UNWELDED
			if(core)
				STOP_PROCESSING(SSobj, core)
			return
	if(istype(O, /obj/item/stack/sheet/metal) && removal_stage == NUKE_CORE_PANEL_EXPOSED)
		var/obj/item/stack/S = O
		if(do_after(user, 2 SECONDS, target = src))
			if(!loc || !S || S.get_amount() < 5)
				return
			S.use(5)
			user.visible_message("<span class='notice'>[user] repairs [src]'s outer core plate.</span>", "<span class='notice'>You repair [src]'s outer core plate.</span>")
			removal_stage = NUKE_CORE_EVERYTHING_FINE
			return
	if(istype(O, /obj/item/nuke_core/plutonium) && removal_stage == NUKE_CORE_FULLY_EXPOSED)
		if(do_after(user, 2 SECONDS, target = src))
			if(!user.unEquip(O))
				to_chat(user, "<span class='notice'>The [O] is stuck to your hand!</span>")
				return
			user.visible_message("<span class='notice'>[user] puts [O] back in [src].</span>", "<span class='notice'>You put [O] back in [src].</span>")
			O.forceMove(src)
			core = O

	else if(istype(O, /obj/item/disk/plantgene))
		to_chat(user, "<span class='warning'>You try to plant the disk, but despite rooting around, it won't fit! After you branch out to read the instructions, you find out where the problem stems from. You've been bamboo-zled, this isn't a nuclear disk at all!</span>")
		return
	return ..()

/obj/machinery/nuclearbomb/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if(removal_stage == NUKE_COVER_OFF)
		user.visible_message("[user] starts forcing open the bolt covers on [src].", "You start forcing open the anchoring bolt covers with [I]...")
		if(!I.use_tool(src, user, 15, volume = I.tool_volume) || removal_stage != NUKE_COVER_OFF)
			return
		user.visible_message("[user] forces open the bolt covers on [src].", "You force open the bolt covers.")
		removal_stage = NUKE_COVER_OPEN
	if(removal_stage == NUKE_CORE_EVERYTHING_FINE)
		user.visible_message("<span class='notice'>[user] starts removing [src]'s outer core plate...</span>", "<span class='notice'>You start removing [src]'s outer core plate...</span>")
		if(!I.use_tool(src, user, 4 SECONDS, volume = I.tool_volume) || removal_stage != NUKE_CORE_EVERYTHING_FINE)
			return
		user.visible_message("<span class='notice'>[user] finishes removing [src]'s outer core plate.</span>", "<span class='notice'>You finish removing [src]'s outer core plate.</span>")
		new /obj/item/stack/sheet/metal(loc, 5)
		removal_stage = NUKE_CORE_PANEL_EXPOSED

	if(removal_stage == NUKE_CORE_PANEL_UNWELDED)
		user.visible_message("<span class='notice'>[user] starts removing [src]'s inner core plate...</span>", "<span class='notice'>You start removing [src]'s inner core plate...</span>")
		if(!I.use_tool(src, user, 8 SECONDS, volume = I.tool_volume) || removal_stage != NUKE_CORE_PANEL_UNWELDED)
			return
		user.visible_message("<span class='notice'>[user] finishes removing [src]'s inner core plate.</span>", "<span class='notice'>You remove [src]'s inner core plate. You can see the core's green glow!</span>")
		removal_stage = NUKE_CORE_FULLY_EXPOSED
		new /obj/item/stack/sheet/mineral/titanium(loc, 5)
		if(core)
			START_PROCESSING(SSobj, core)
	if(removal_stage == NUKE_UNWRENCHED)
		user.visible_message("[user] begins lifting [src] off of the anchors.", "You begin lifting the device off the anchors...")
		if(!I.use_tool(src, user, 8 SECONDS, volume = I.tool_volume) || removal_stage != NUKE_UNWRENCHED)
			return
		user.visible_message("[user] crowbars [src] off of the anchors. It can now be moved.", "You jam the crowbar under the nuclear device and lift it off its anchors. You can now move it!")
		anchored = FALSE
		removal_stage = NUKE_MOBILE

/obj/machinery/nuclearbomb/wrench_act(mob/user, obj/item/I)
	if(!anchored)
		return
	if(removal_stage != NUKE_SEALANT_OPEN)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	user.visible_message("[user] begins unwrenching the anchoring bolts on [src].", "You begin unwrenching the anchoring bolts...")
	if(!I.use_tool(src, user, 50, volume = I.tool_volume) || removal_stage != NUKE_SEALANT_OPEN)
		return
	user.visible_message("[user] unwrenches the anchoring bolts on [src].", "You unwrench the anchoring bolts.")
	removal_stage = NUKE_UNWRENCHED

/obj/machinery/nuclearbomb/multitool_act(mob/user, obj/item/I)
	if(!panel_open)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	attack_hand(user)

/obj/machinery/nuclearbomb/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(auth || (istype(I, /obj/item/screwdriver/nuke)))
		if(!panel_open)
			panel_open = TRUE
			overlays += image(icon, "npanel_open")
			to_chat(user, "You unscrew the control panel of [src].")
			anchor_stage = removal_stage
			removal_stage = core_stage
		else
			panel_open = FALSE
			overlays -= image(icon, "npanel_open")
			to_chat(user, "You screw the control panel of [src] back on.")
			core_stage = removal_stage
			removal_stage = anchor_stage
	else
		if(!panel_open)
			to_chat(user, "[src] emits a buzzing noise, the panel staying locked in.")
		if(panel_open == TRUE)
			panel_open = FALSE
			overlays -= image(icon, "npanel_open")
			to_chat(user, "You screw the control panel of [src] back on.")
			core_stage = removal_stage
			removal_stage = anchor_stage
		flick("nuclearbombc", src)

/obj/machinery/nuclearbomb/wirecutter_act(mob/user, obj/item/I)
	if(!panel_open)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	attack_hand(user)

/obj/machinery/nuclearbomb/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if(removal_stage == NUKE_INTACT)
		visible_message("<span class='notice'>[user] starts cutting loose the anchoring bolt covers on [src].</span>",\
		"<span class='notice'>You start cutting loose the anchoring bolt covers with [I]...</span>",\
		"<span class='warning'>You hear welding.</span>")
		if(!I.use_tool(src, user, 40, 5, volume = I.tool_volume) || removal_stage != NUKE_INTACT)
			return
		visible_message("<span class='notice'>[user] cuts through the bolt covers on [src].</span>",\
		"<span class='notice'>You cut through the bolt cover.</span>")
		removal_stage = NUKE_COVER_OFF
	if(removal_stage == NUKE_CORE_PANEL_UNWELDED)
		user.visible_message("<span class='notice'>[user] starts welding [src]'s inner core plate...</span>", "<span class='notice'>You start welding [src]'s inner core plate...</span>")
		if(!I.use_tool(src, user, 4 SECONDS, 5, volume = I.tool_volume) || removal_stage != NUKE_CORE_PANEL_UNWELDED)
			return
		user.visible_message("<span class='notice'>[user] finishes welding [src]'s inner core plate...</span>", "<span class='notice'>You finish welding [src]'s inner core plate...</span>")
		removal_stage = NUKE_CORE_PANEL_EXPOSED

	else if(removal_stage == NUKE_CORE_PANEL_EXPOSED)
		user.visible_message("<span class='notice'>[user] starts unwelding [src]'s inner core plate...</span>", "<span class='notice'>You start unwelding [src]'s inner core plate...</span>")
		if(!I.use_tool(src, user, 4 SECONDS, 5, volume = I.tool_volume) || removal_stage != NUKE_CORE_PANEL_EXPOSED)
			return
		user.visible_message("<span class='notice'>[user] finishes unwelding [src]'s inner core plate...</span>", "<span class='notice'>You finish unwelding [src]'s inner core plate...</span>")
		removal_stage = NUKE_CORE_PANEL_UNWELDED
	if(removal_stage == NUKE_COVER_OPEN)
		visible_message("<span class='notice'>[user] starts cutting apart the anchoring system sealant on [src].</span>",\
		"<span class='notice'>You start cutting apart the anchoring system's sealant with [I]...</span>",\
		"<span class='warning'>You hear welding.</span>")
		if(!I.use_tool(src, user, 40, 5, volume = I.tool_volume) || removal_stage != NUKE_COVER_OPEN)
			return
		visible_message("<span class='notice'>[user] cuts apart the anchoring system sealant on [src].</span>",\
		"<span class='notice'>You cut apart the anchoring system's sealant.</span></span>")
		removal_stage = NUKE_SEALANT_OPEN

/obj/machinery/nuclearbomb/attack_ghost(mob/user as mob)
	attack_hand(user)

/obj/machinery/nuclearbomb/attack_hand(mob/user as mob)
	if(!panel_open)
		return ui_interact(user)
	if(removal_stage != NUKE_CORE_FULLY_EXPOSED || !core)
		return wires.Interact(user)
	if(timing) //removing the core is less risk then cutting wires, and doesnt take long, so we should not let crew do it while the nuke is armed. You can however get to it, without the special screwdriver, if you put the NAD in.
		to_chat(user, "<span class='warning'>[core] won't budge, metal clamps keep it in!</span>")
		return
	user.visible_message("<span class='notice'>[user] starts to pull [core] out of [src]!</span>", "<span class='notice'>You start to pull [core] out of [src]!</span>")
	if(do_after(user, 5 SECONDS, target = src))
		user.visible_message("<span class='notice'>[user] pulls [core] out of [src]!</span>", "<span class='notice'>You pull [core] out of [src]! Might want to put it somewhere safe.</span>")
		core.forceMove(loc)
		core = null

/obj/machinery/nuclearbomb/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.physical_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "NuclearBomb", name, 450, 300, master_ui, state)
		ui.open()

/obj/machinery/nuclearbomb/ui_data(mob/user)
	var/list/data = list()
	data["extended"] = extended
	data["authdisk"] = is_auth(user)
	data["diskname"] = auth ? auth.name : FALSE
	data["authcode"] = yes_code
	data["authfull"] = data["authdisk"] && data["authcode"]
	data["safe"] = safety ? "Safe" : "Engaged"
	data["time"] = timeleft
	data["timer"] = timing
	data["safety"] = safety
	data["anchored"] = anchored
	if(is_auth(user))
		if(yes_code)
			data["codemsg"] = "CLEAR CODE"
		else if(code)
			data["codemsg"] = "RE-ENTER CODE"
		else
			data["codemsg"] = "ENTER CODE"
	else
		data["codemsg"] = "-----"
	return data

/obj/machinery/nuclearbomb/proc/is_auth(mob/user)
	if(auth)
		return TRUE
	else if(user.can_admin_interact())
		return TRUE
	else
		return FALSE

/obj/machinery/nuclearbomb/ui_act(action, params)
	if(..())
		return
	. = TRUE
	if(exploded)
		return
	switch(action)
		if("deploy")
			if(removal_stage != NUKE_MOBILE)
				anchored = TRUE
				visible_message("<span class='warning'>With a steely snap, bolts slide out of [src] and anchor it to the flooring!</span>")
			else
				visible_message("<span class='warning'>[src] makes a highly unpleasant crunching noise. It looks like the anchoring bolts have been cut.</span>")
			if(!lighthack)
				flick("nuclearbombc", src)
				icon_state = "nuclearbomb1"
			extended = TRUE
			return
		if("auth")
			if(auth)
				if(!usr.get_active_hand() && Adjacent(usr))
					usr.put_in_hands(auth)
				else
					auth.forceMove(get_turf(src))
				yes_code = FALSE
				auth = null
			else
				var/obj/item/I = usr.get_active_hand()
				if(istype(I, /obj/item/disk/nuclear))
					usr.drop_item()
					I.forceMove(src)
					auth = I
			return
	if(!is_auth(usr)) // All requests below here require NAD inserted.
		return FALSE
	switch(action)
		if("code")
			if(yes_code) // Clear code
				code = null
				yes_code = FALSE
				return
			// If no code set, enter new one
			var/tempcode = input(usr, "Code", "Input Code", null) as num|null
			if(tempcode)
				code = min(max(round(tempcode), 0), 999999)
				if(code == r_code)
					yes_code = TRUE
					code = null
				else
					code = "ERROR"
			return
		if("toggle_anchor")
			if(removal_stage == NUKE_MOBILE)
				anchored = FALSE
				visible_message("<span class='warning'>[src] makes a highly unpleasant crunching noise. It looks like the anchoring bolts have been cut.</span>")
			else if(isinspace())
				to_chat(usr, "<span class='warning'>There is nothing to anchor to!</span>")
				return FALSE
			else
				anchored = !(anchored)
				if(anchored)
					visible_message("<span class='warning'>With a steely snap, bolts slide out of [src] and anchor it to the flooring.</span>")
				else
					visible_message("<span class='warning'>The anchoring bolts slide back into the depths of [src].</span>")
			return

	if(!yes_code) // All requests below here require both NAD inserted AND code correct
		return

	switch(action)
		if("set_time")
			var/time = input(usr, "Detonation time (seconds, min 120, max 600)", "Input Time", 120) as num|null
			if(time)
				timeleft = min(max(round(time), 120), 600)
		if("toggle_safety")
			safety = !(safety)
			if(safety)
				if(!is_syndicate)
					set_security_level(previous_level)
				timing = FALSE
				GLOB.bomb_set = FALSE
		if("toggle_armed")
			if(safety)
				to_chat(usr, "<span class='notice'>The safety is still on.</span>")
				return
			if(!core)
				to_chat(usr, "<span class='danger'>[src]'s screen blinks red! There is no plutonium core in [src]!</span>")
				return
			timing = !(timing)
			if(timing)
				if(!lighthack)
					icon_state = "nuclearbomb2"
				if(!safety)
					message_admins("[key_name_admin(usr)] engaged a nuclear bomb [ADMIN_JMP(src)]")
					if(!is_syndicate)
						set_security_level("delta")
					GLOB.bomb_set = TRUE // There can still be issues with this resetting when there are multiple bombs. Not a big deal though for Nuke
				else
					GLOB.bomb_set = TRUE
			else
				if(!is_syndicate)
					set_security_level(previous_level)
				GLOB.bomb_set = FALSE
				if(!lighthack)
					icon_state = "nuclearbomb1"


/obj/machinery/nuclearbomb/blob_act(obj/structure/blob/B)
	if(exploded)
		return
	if(timing)	//boom
		INVOKE_ASYNC(src, .proc/explode)
		return
	qdel(src)

/obj/machinery/nuclearbomb/zap_act(power, zap_flags)
	. = ..()
	if(zap_flags & ZAP_MACHINE_EXPLOSIVE)
		qdel(src)//like the singulo, tesla deletes it. stops it from exploding over and over

#define NUKERANGE 80
/obj/machinery/nuclearbomb/proc/explode()
	if(safety)
		timing = FALSE
		return
	exploded = TRUE
	yes_code = FALSE
	safety = TRUE
	if(!lighthack)
		icon_state = "nuclearbomb3"
	playsound(src,'sound/machines/alarm.ogg',100,0,5)
	if(SSticker && SSticker.mode)
		SSticker.mode.explosion_in_progress = 1
	sleep(100)

	GLOB.enter_allowed = 0

	var/off_station = 0
	var/turf/bomb_location = get_turf(src)
	var/area/A = get_area(src)
	if( bomb_location && is_station_level(bomb_location.z) )
		if( (bomb_location.x < (128 - NUKERANGE)) || (bomb_location.x > (128 + NUKERANGE)) || (bomb_location.y < (128 - NUKERANGE)) || (bomb_location.y > (128 + NUKERANGE)) && (!(A in GLOB.the_station_areas)))
			off_station = 1
	else
		off_station = 2

	if(SSticker)
		if(SSticker.mode && SSticker.mode.name == "nuclear emergency")
			var/obj/docking_port/mobile/syndie_shuttle = SSshuttle.getShuttle("syndicate")
			if(syndie_shuttle)
				SSticker.mode:syndies_didnt_escape = is_station_level(syndie_shuttle.z)
			SSticker.mode:nuke_off_station = off_station
		SSticker.station_explosion_cinematic(off_station,null)
		if(SSticker.mode)
			SSticker.mode.explosion_in_progress = 0
			if(SSticker.mode.name == "nuclear emergency")
				SSticker.mode:nukes_left --
			else if(off_station == 1)
				to_chat(world, "<b>A nuclear device was set off, but the explosion was out of reach of the station!</b>")
			else if(off_station == 2)
				to_chat(world, "<b>A nuclear device was set off, but the device was not on the station!</b>")
			else
				to_chat(world, "<b>The station was destroyed by the nuclear blast!</b>")

			SSticker.mode.station_was_nuked = (off_station < 2)	//offstation==1 is a draw. the station becomes irradiated and needs to be evacuated.
															//kinda shit but I couldn't  get permission to do what I wanted to do.

			if(!SSticker.mode.check_finished())//If the mode does not deal with the nuke going off so just reboot because everyone is stuck as is
				SSticker.reboot_helper("Station destroyed by Nuclear Device.", "nuke - unhandled ending")
				return
	return

/obj/machinery/nuclearbomb/proc/reset_lighthack_callback()
	lighthack = !lighthack

/obj/machinery/nuclearbomb/proc/reset_safety_callback()
	safety = !safety
	if(safety == 1)
		if(!is_syndicate)
			set_security_level(previous_level)
		visible_message("<span class='notice'>[src] quiets down.</span>")
		if(!lighthack)
			if(icon_state == "nuclearbomb2")
				icon_state = "nuclearbomb1"
	else
		visible_message("<span class='notice'>[src] emits a quiet whirling noise!</span>")

//==========DAT FUKKEN DISK===============
/obj/item/disk/nuclear
	name = "nuclear authentication disk"
	desc = "Better keep this safe."
	icon_state = "nucleardisk"
	max_integrity = 250
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 30, BIO = 0, RAD = 0, FIRE = 100, ACID = 100)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/disk/nuclear/unrestricted
	desc = "Seems to have been stripped of its safeties, you better not lose it."

/obj/item/disk/nuclear/New()
	..()
	START_PROCESSING(SSobj, src)
	GLOB.poi_list |= src

/obj/item/disk/nuclear/process()
	if(!check_disk_loc())
		var/holder = get(src, /mob)
		if(holder)
			to_chat(holder, "<span class='danger'>You can't help but feel that you just lost something back there...</span>")
		qdel(src)

 //station disk is allowed on the station level, escape shuttle/pods, CC, and syndicate shuttles/base, reset otherwise
/obj/item/disk/nuclear/proc/check_disk_loc()
	var/turf/T = get_turf(src)
	var/area/A = get_area(src)
	if(is_station_level(T.z))
		return TRUE
	if(A.nad_allowed)
		return TRUE
	return FALSE

/obj/item/disk/nuclear/unrestricted/check_disk_loc()
	return TRUE

/obj/item/disk/nuclear/Destroy(force)
	var/turf/diskturf = get_turf(src)

	if(force)
		message_admins("[src] has been !!force deleted!! in ([diskturf ? "[diskturf.x], [diskturf.y] ,[diskturf.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[diskturf.x];Y=[diskturf.y];Z=[diskturf.z]'>JMP</a>":"nonexistent location"]).")
		log_game("[src] has been !!force deleted!! in ([diskturf ? "[diskturf.x], [diskturf.y] ,[diskturf.z]":"nonexistent location"]).")
		GLOB.poi_list.Remove(src)
		STOP_PROCESSING(SSobj, src)
		return ..()

	if(GLOB.blobstart.len > 0)
		GLOB.poi_list.Remove(src)
		var/obj/item/disk/nuclear/NEWDISK = new(pick(GLOB.blobstart))
		transfer_fingerprints_to(NEWDISK)
		message_admins("[src] has been destroyed at ([diskturf.x], [diskturf.y], [diskturf.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[diskturf.x];Y=[diskturf.y];Z=[diskturf.z]'>JMP</a>). Moving it to ([NEWDISK.x], [NEWDISK.y], [NEWDISK.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[NEWDISK.x];Y=[NEWDISK.y];Z=[NEWDISK.z]'>JMP</a>).")
		log_game("[src] has been destroyed in ([diskturf.x], [diskturf.y], [diskturf.z]). Moving it to ([NEWDISK.x], [NEWDISK.y], [NEWDISK.z]).")
		return QDEL_HINT_HARDDEL_NOW
	else
		error("[src] was supposed to be destroyed, but we were unable to locate a blobstart landmark to spawn a new one.")
	return QDEL_HINT_LETMELIVE // Cancel destruction unless forced.

#undef NUKE_INTACT
#undef NUKE_COVER_OFF
#undef NUKE_COVER_OPEN
#undef NUKE_SEALANT_OPEN
#undef NUKE_UNWRENCHED
#undef NUKE_MOBILE
#undef NUKE_CORE_EVERYTHING_FINE
#undef NUKE_CORE_PANEL_EXPOSED
#undef NUKE_CORE_PANEL_UNWELDED
#undef NUKE_CORE_FULLY_EXPOSED

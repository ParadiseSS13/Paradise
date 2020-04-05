#define NUKE_INTACT 0
#define NUKE_COVER_OFF 1
#define NUKE_COVER_OPEN 2
#define NUKE_SEALANT_OPEN 3
#define NUKE_UNWRENCHED 4
#define NUKE_MOBILE 5

GLOBAL_VAR(bomb_set)

/obj/machinery/nuclearbomb
	name = "\improper Nuclear Fission Explosive"
	desc = "Uh oh. RUN!!!!"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "nuclearbomb0"
	density = 1
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/deployable = 0
	var/extended = 0
	var/lighthack = 0
	var/timeleft = 120
	var/timing = 0
	var/r_code = "ADMIN"
	var/code = ""
	var/yes_code = 0
	var/safety = 1
	var/obj/item/disk/nuclear/auth = null
	var/removal_stage = NUKE_INTACT
	var/lastentered
	var/is_syndicate = 0
	use_power = NO_POWER_USE
	var/previous_level = ""
	var/datum/wires/nuclearbomb/wires = null

/obj/machinery/nuclearbomb/syndicate
	is_syndicate = 1

/obj/machinery/nuclearbomb/New()
	..()
	r_code = "[rand(10000, 99999.0)]"//Creates a random code upon object spawn.
	wires = new/datum/wires/nuclearbomb(src)
	previous_level = get_security_level()
	GLOB.poi_list |= src

/obj/machinery/nuclearbomb/Destroy()
	QDEL_NULL(wires)
	GLOB.poi_list.Remove(src)
	return ..()

/obj/machinery/nuclearbomb/process()
	if(timing)
		GLOB.bomb_set = 1 //So long as there is one nuke timing, it means one nuke is armed.
		timeleft = max(timeleft - 2, 0) // 2 seconds per process()
		if(timeleft <= 0)
			spawn
				explode()
		SSnanoui.update_uis(src)
	return

/obj/machinery/nuclearbomb/attackby(obj/item/O as obj, mob/user as mob, params)
	if(istype(O, /obj/item/disk/nuclear))
		if(extended)
			if(!user.drop_item())
				to_chat(user, "<span class='notice'>\The [O] is stuck to your hand!</span>")
				return
			O.forceMove(src)
			auth = O
			add_fingerprint(user)
			return attack_hand(user)
		else
			to_chat(user, "<span class='notice'>You need to deploy \the [src] first. Right click on the sprite, select 'Make Deployable' then click on \the [src] with an empty hand.</span>")
		return
	return ..()

/obj/machinery/nuclearbomb/crowbar_act(mob/user, obj/item/I)
	if(!anchored)
		return
	if(removal_stage != NUKE_UNWRENCHED && removal_stage != NUKE_COVER_OFF)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if(removal_stage == NUKE_COVER_OFF)
		user.visible_message("[user] starts forcing open the bolt covers on [src].", "You start forcing open the anchoring bolt covers with [I]...")
		if(!I.use_tool(src, user, 15, volume = I.tool_volume) || removal_stage != NUKE_COVER_OFF)
			return
		user.visible_message("[user] forces open the bolt covers on [src].", "You force open the bolt covers.")
		removal_stage = NUKE_COVER_OPEN
	else
		user.visible_message("[user] begins lifting [src] off of the anchors.", "You begin lifting the device off the anchors...")
		if(!I.use_tool(src, user, 80, volume = I.tool_volume) || removal_stage != NUKE_UNWRENCHED)
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
	if(auth)
		if(!panel_open)
			panel_open = TRUE
			overlays += image(icon, "npanel_open")
			to_chat(user, "You unscrew the control panel of [src].")
		else
			panel_open = FALSE
			overlays -= image(icon, "npanel_open")
			to_chat(user, "You screw the control panel of [src] back on.")
	else
		if(!panel_open)
			to_chat(user, "[src] emits a buzzing noise, the panel staying locked in.")
		if(panel_open == TRUE)
			panel_open = FALSE
			overlays -= image(icon, "npanel_open")
			to_chat(user, "You screw the control panel of [src] back on.")
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
	if(removal_stage != NUKE_INTACT && removal_stage != NUKE_COVER_OPEN)
		return
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
	else if(removal_stage == NUKE_COVER_OPEN)
		visible_message("<span class='notice'>[user] starts cutting apart the anchoring system sealant on [src].</span>",\
		"<span class='notice'>You start cutting apart the anchoring system's sealant with [I]...</span>",\
		"<span class='warning'>You hear welding.</span>")
		if(!I.use_tool(src, user, 40, 5, volume = I.tool_volume) || removal_stage != NUKE_COVER_OPEN)
			return
		visible_message("<span class='notice'>[user] cuts apart the anchoring system sealant on [src].</span>",\
		"<span class='notice'>You cut apart the anchoring system's sealant.</span></span>")
		removal_stage = NUKE_SEALANT_OPEN

/obj/machinery/nuclearbomb/attack_ghost(mob/user as mob)
	if(extended)
		attack_hand(user)

/obj/machinery/nuclearbomb/attack_hand(mob/user as mob)
	if(extended)
		if(panel_open)
			wires.Interact(user)
		else
			ui_interact(user)
	else if(deployable)
		if(removal_stage != NUKE_MOBILE)
			anchored = 1
			visible_message("<span class='warning'>With a steely snap, bolts slide out of [src] and anchor it to the flooring!</span>")
		else
			visible_message("<span class='warning'>\The [src] makes a highly unpleasant crunching noise. It looks like the anchoring bolts have been cut.</span>")
		if(!lighthack)
			flick("nuclearbombc", src)
			icon_state = "nuclearbomb1"
		extended = 1
	return

/obj/machinery/nuclearbomb/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "nuclear_bomb.tmpl", "Nuke Control Panel", 450, 550, state = GLOB.physical_state)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/nuclearbomb/ui_data(mob/user, datum/topic_state/state)
	var/data[0]
	data["is_syndicate"] = is_syndicate
	data["hacking"] = 0
	data["auth"] = is_auth(user)
	if(is_auth(user))
		if(yes_code)
			data["authstatus"] = timing ? "Functional/Set" : "Functional"
		else
			data["authstatus"] = "Auth. S2"
	else
		if(timing)
			data["authstatus"] = "Set"
		else
			data["authstatus"] = "Auth. S1"
	data["safe"] = safety ? "Safe" : "Engaged"
	data["time"] = timeleft
	data["timer"] = timing
	data["safety"] = safety
	data["anchored"] = anchored
	data["yescode"] = yes_code
	data["message"] = "AUTH"
	if(is_auth(user))
		data["message"] = code
		if(yes_code)
			data["message"] = "*****"

	return data

/obj/machinery/nuclearbomb/verb/make_deployable()
	set category = "Object"
	set name = "Make Deployable"
	set src in oview(1)

	if(usr.stat || !usr.canmove || usr.restrained())
		return

	if(deployable)
		to_chat(usr, "<span class='warning'>You close several panels to make [src] undeployable.</span>")
		deployable = 0
	else
		to_chat(usr, "<span class='warning'>You adjust some panels to make [src] deployable.</span>")
		deployable = 1
	return

/obj/machinery/nuclearbomb/proc/is_auth(var/mob/user)
	if(auth)
		return 1
	else if(user.can_admin_interact())
		return 1
	else
		return 0

/obj/machinery/nuclearbomb/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["auth"])
		if(auth)
			auth.loc = loc
			yes_code = 0
			auth = null
		else
			var/obj/item/I = usr.get_active_hand()
			if(istype(I, /obj/item/disk/nuclear))
				usr.drop_item()
				I.loc = src
				auth = I
	if(is_auth(usr))
		if(href_list["type"])
			if(href_list["type"] == "E")
				if(code == r_code)
					yes_code = 1
					code = null
				else
					code = "ERROR"
			else
				if(href_list["type"] == "R")
					yes_code = 0
					code = null
				else
					lastentered = text("[]", href_list["type"])
					if(text2num(lastentered) == null)
						var/turf/LOC = get_turf(usr)
						message_admins("[key_name_admin(usr)] tried to exploit a nuclear bomb by entering non-numerical codes: <a href='?_src_=vars;Vars=[UID()]'>[lastentered]</a>! ([LOC ? "<a href='?_src_=holder;adminplayerobservecoodjump=1;X=[LOC.x];Y=[LOC.y];Z=[LOC.z]'>JMP</a>" : "null"])", 0)
						log_admin("EXPLOIT: [key_name(usr)] tried to exploit a nuclear bomb by entering non-numerical codes: [lastentered]!")
					else
						code += lastentered
						if(length(code) > 5)
							code = "ERROR"
		if(yes_code)
			if(href_list["time"])
				var/time = text2num(href_list["time"])
				timeleft += time
				timeleft = min(max(round(src.timeleft), 120), 600)
			if(href_list["timer"])
				if(timing == -1.0)
					SSnanoui.update_uis(src)
					return
				if(safety)
					to_chat(usr, "<span class='warning'>The safety is still on.</span>")
					SSnanoui.update_uis(src)
					return
				timing = !(timing)
				if(timing)
					if(!lighthack)
						icon_state = "nuclearbomb2"
					if(!safety)
						message_admins("[key_name_admin(usr)] engaged a nuclear bomb (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)")
						if(!is_syndicate)
							set_security_level("delta")
						GLOB.bomb_set = 1 //There can still be issues with this resetting when there are multiple bombs. Not a big deal though for Nuke/N
					else
						GLOB.bomb_set = 0
				else
					if(!is_syndicate)
						set_security_level(previous_level)
					GLOB.bomb_set = 0
					if(!lighthack)
						icon_state = "nuclearbomb1"
			if(href_list["safety"])
				safety = !(safety)
				if(safety)
					if(!is_syndicate)
						set_security_level(previous_level)
					timing = 0
					GLOB.bomb_set = 0
			if(href_list["anchor"])
				if(removal_stage == NUKE_MOBILE)
					anchored = 0
					visible_message("<span class='warning'>\The [src] makes a highly unpleasant crunching noise. It looks like the anchoring bolts have been cut.</span>")
					SSnanoui.update_uis(src)
					return

				if(!isinspace())
					anchored = !(anchored)
					if(anchored)
						visible_message("<span class='warning'>With a steely snap, bolts slide out of [src] and anchor it to the flooring.</span>")
					else
						visible_message("<span class='warning'>The anchoring bolts slide back into the depths of [src].</span>")
				else
					to_chat(usr, "<span class='warning'>There is nothing to anchor to!</span>")

	SSnanoui.update_uis(src)

/obj/machinery/nuclearbomb/blob_act(obj/structure/blob/B)
	if(timing == -1.0)
		return
	qdel(src)

/obj/machinery/nuclearbomb/tesla_act(power, explosive)
	..()
	if(explosive)
		qdel(src)//like the singulo, tesla deletes it. stops it from exploding over and over

#define NUKERANGE 80
/obj/machinery/nuclearbomb/proc/explode()
	if(safety)
		timing = 0
		return
	timing = -1.0
	yes_code = 0
	safety = 1
	if(!lighthack)
		icon_state = "nuclearbomb3"
	playsound(src,'sound/machines/alarm.ogg',100,0,5)
	if(SSticker && SSticker.mode)
		SSticker.mode.explosion_in_progress = 1
	sleep(100)

	GLOB.enter_allowed = 0

	var/off_station = 0
	var/turf/bomb_location = get_turf(src)
	if( bomb_location && is_station_level(bomb_location.z) )
		if( (bomb_location.x < (128-NUKERANGE)) || (bomb_location.x > (128+NUKERANGE)) || (bomb_location.y < (128-NUKERANGE)) || (bomb_location.y > (128+NUKERANGE)) )
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
				to_chat(world, "<b>The station was destoyed by the nuclear blast!</b>")

			SSticker.mode.station_was_nuked = (off_station<2)	//offstation==1 is a draw. the station becomes irradiated and needs to be evacuated.
															//kinda shit but I couldn't  get permission to do what I wanted to do.

			if(!SSticker.mode.check_finished())//If the mode does not deal with the nuke going off so just reboot because everyone is stuck as is
				world.Reboot("Station destroyed by Nuclear Device.", "end_error", "nuke - unhandled ending")
				return
	return


//==========DAT FUKKEN DISK===============
/obj/item/disk/nuclear
	name = "nuclear authentication disk"
	desc = "Better keep this safe."
	icon_state = "nucleardisk"
	max_integrity = 250
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 30, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100)
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

 //station disk is allowed on z1, escape shuttle/pods, CC, and syndicate shuttles/base, reset otherwise
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

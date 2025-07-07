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
	icon = 'icons/obj/nuclearbomb.dmi'
	icon_state = "nuclearbomb1"
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	flags_2 = NO_MALF_EFFECT_2 | CRITICAL_ATOM_2 | RAD_NO_CONTAMINATE_2 | RAD_PROTECT_CONTENTS_2
	anchored = TRUE
	power_state = NO_POWER_USE
	interact_offline = TRUE
	rad_insulation_alpha = RAD_FULL_INSULATION
	rad_insulation_beta = RAD_FULL_INSULATION
	rad_insulation_gamma = RAD_FULL_INSULATION

	/// Are our bolts *supposed* to be in the floor, may not actually cause anchoring if the bolts are cut
	var/extended = TRUE
	/// Countdown to boom
	var/timeleft = 120
	/// Are we counting down?
	var/timing = FALSE
	/// Have we gone boom yet?
	var/exploded = FALSE
	/// Random code between 10000 and 99999
	var/r_code = "ADMIN"
	/// Code entered by user
	var/code
	/// Is the most recently inputted code correct?
	var/yes_code = FALSE
	var/safety = TRUE
	/// The Nuclear Authentication Disk.
	var/obj/item/disk/nuclear/auth = null
	/// The plutonium core.
	var/obj/item/nuke_core/plutonium/core = null
	var/lastentered
	/// Is this a nuke-ops bomb?
	var/is_syndicate = FALSE
	/// If this is true you cannot unbolt the NAD with tools, only the NAD
	var/requires_NAD_to_unbolt = FALSE
	var/previous_level = ""
	var/datum/wires/nuclearbomb/wires = null
	var/removal_stage = NUKE_INTACT
	///The same state removal stage is, until someone opens the panel of the nuke. This way we can have someone open the front of the nuke, while keeping track of where in the world we are on the anchoring bolts.
	var/anchor_stage = NUKE_INTACT
	///This is so that we can check if the internal components are sealed up properly when the outer hatch is closed.
	var/core_stage = NUKE_CORE_EVERYTHING_FINE
	///How many sheets of various metals we need to fix it
	var/sheets_to_fix = 5
	/// Is this a training bomb?
	var/training = FALSE
	/// Prefix to add, if any, on icon states for this bomb
	var/sprite_prefix = ""
	///Bombs Internal Radio
	var/obj/item/radio/radio

/obj/machinery/nuclearbomb/syndicate
	is_syndicate = TRUE
	requires_NAD_to_unbolt = TRUE

/obj/machinery/nuclearbomb/undeployed
	extended = FALSE
	anchored = FALSE

/obj/machinery/nuclearbomb/Initialize(mapload)
	. = ..()
	r_code = rand(10000, 99999) // Creates a random code upon object spawn.
	wires = new/datum/wires/nuclearbomb(src)
	previous_level = SSsecurity_level.get_current_level_as_text()
	if(!training)
		GLOB.poi_list |= src
		GLOB.nuke_list |= src
		core = new /obj/item/nuke_core/plutonium(src)
		var/datum/component/inherent_radioactivity/radioactivity = core.GetComponent(/datum/component/inherent_radioactivity)
		STOP_PROCESSING(SSradiation, radioactivity)//Let us not irradiate the vault by default.
	update_icon(UPDATE_OVERLAYS)
	radio = new(src)
	radio.listening = FALSE
	radio.follow_target = src
	radio.config(list("Special Ops" = 0))

/obj/machinery/nuclearbomb/syndicate/Initialize(mapload)
	. = ..()
	wires.labelled = FALSE
	ADD_TRAIT(src, TRAIT_OBSCURED_WIRES, ROUNDSTART_TRAIT)
	GLOB.syndi_nuke_list |= src

/obj/machinery/nuclearbomb/Destroy()
	SStgui.close_uis(wires)
	QDEL_NULL(wires)
	QDEL_NULL(core)
	QDEL_NULL(radio)
	if(!training)
		GLOB.poi_list.Remove(src)
		GLOB.nuke_list.Remove(src)
	return ..()

/obj/machinery/nuclearbomb/syndicate/Destroy()
	GLOB.syndi_nuke_list.Remove(src)
	. = ..()

/obj/machinery/nuclearbomb/process()
	if(timing)
		GLOB.bomb_set = TRUE // So long as there is one nuke timing, it means one nuke is armed.
		timeleft = max(timeleft - 2, 0) // 2 seconds per process()
		if(timeleft <= 0)
			INVOKE_ASYNC(src, PROC_REF(explode))
	return

/obj/machinery/nuclearbomb/examine(mob/user)
	. = ..()
	if(training)
		. += "<span class='notice'><b>Alt-Click</b> to reset the bomb.</span>"
	if(!panel_open)
		. += "<span class='notice'>The outer panel is <b>screwed shut</b>.</span>"
	switch(removal_stage)
		if(NUKE_INTACT)
			. += "<span class='notice'>The anchoring bolt covers are <b>welded shut</b>.</span>"
		if(NUKE_COVER_OFF)
			. += "<span class='notice'>The cover plate is <b>pried into</b> place.</span>"
		if(NUKE_COVER_OPEN)
			. += "<span class='notice'>The anchoring system sealant is <b>welded shut</b>.</span>"
		if(NUKE_SEALANT_OPEN)
			. += "<span class='notice'>The bolts are <b>wrenched</b> in place.</span>"
		if(NUKE_UNWRENCHED)
			. += "<span class='notice'>The device can be <b>pried off</b> its anchors.</span>"
		if(NUKE_CORE_EVERYTHING_FINE)
			. += "<span class='notice'>The outer panel can be <b>pried open</b> or it can be <i>screwed</i> back on.</span>"
		if(NUKE_CORE_PANEL_EXPOSED)
			. += "<span class='notice'>The outer plate can be fixed by <b>[sheets_to_fix] metal sheets</b>, while the inner core plate is <i>welded shut</i>.</span>"
		if(NUKE_CORE_PANEL_UNWELDED)
			. += "<span class='notice'>The inner core plate can be <b>welded shut</b> or it can be <i>pried open</i>.</span>"
		if(NUKE_CORE_FULLY_EXPOSED)
			. += "<span class='notice'>The inner core plate can be fixed by <b>[sheets_to_fix] titanium sheets</b>, [core ? "or the plutonium core can be <i>removed</i>" : "though the plutonium core is <i>missing</i>"].</span>"

/obj/machinery/nuclearbomb/update_overlays()
	. = ..()
	underlays.Cut()
	set_light(0)

	if(!wires.is_cut(WIRE_NUKE_LIGHT))
		underlays += emissive_appearance(icon, sprite_prefix + "nukelights_lightmask")
		set_light(1, LIGHTING_MINIMUM_POWER)

	if(panel_open)
		. += sprite_prefix + "hackpanel_open"

	if(anchored) // Using anchored due to removal_stage deanchoring having multiple steps
		. += sprite_prefix + "nukebolts"

	// Selected stage lets us show the open core, even if the front panel is closed
	var/selected_stage = removal_stage
	if(removal_stage < NUKE_CORE_EVERYTHING_FINE) // Because we need to show the core
		selected_stage = core_stage
	switch(selected_stage)
		if(NUKE_CORE_PANEL_EXPOSED)
			. += "nukecore1"
		if(NUKE_CORE_PANEL_UNWELDED)
			. += "nukecore2"
		if(NUKE_CORE_FULLY_EXPOSED)
			. += core ? "nukecore3" : "nukecore4"

/obj/machinery/nuclearbomb/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/disk/nuclear))
		if(extended)
			if(auth)
				to_chat(user,  "<span class='warning'>There's already a disk in the slot!</span>")
				return ITEM_INTERACT_COMPLETE
			if((istype(used, /obj/item/disk/nuclear/training) && !training) || (training && !istype(used, /obj/item/disk/nuclear/training)))
				to_chat(user,  "<span class='warning'>[used] doesn't fit into [src]!</span>")
				return ITEM_INTERACT_COMPLETE
			if(!user.drop_item())
				to_chat(user, "<span class='notice'>[used] is stuck to your hand!</span>")
				return ITEM_INTERACT_COMPLETE
			used.forceMove(src)
			auth = used
			add_fingerprint(user)
			attack_hand(user)
			return ITEM_INTERACT_COMPLETE
		else
			to_chat(user, "<span class='notice'>You need to deploy [src] first.</span>")
		return ITEM_INTERACT_COMPLETE
	if(istype(used, /obj/item/stack/sheet/mineral/titanium) && removal_stage == NUKE_CORE_FULLY_EXPOSED)
		var/obj/item/stack/S = used
		if(S.get_amount() < sheets_to_fix)
			to_chat(user, "<span class='warning'>You need at least [sheets_to_fix] sheets of titanium to repair [src]'s inner core plate!</span>")
			return ITEM_INTERACT_COMPLETE
		if(do_after(user, 2 SECONDS, target = src))
			if(!loc || !S || S.get_amount() < sheets_to_fix)
				return ITEM_INTERACT_COMPLETE
			S.use(sheets_to_fix)
			user.visible_message("<span class='notice'>[user] repairs [src]'s inner core plate.</span>", \
								"<span class='notice'>You repair [src]'s inner core plate. The radiation is contained.</span>")
			removal_stage = NUKE_CORE_PANEL_UNWELDED
			if(core)
				var/datum/component/inherent_radioactivity/radioactivity = core.GetComponent(/datum/component/inherent_radioactivity)
				STOP_PROCESSING(SSradiation, radioactivity)
			update_icon(UPDATE_OVERLAYS)
		return ITEM_INTERACT_COMPLETE
	if(istype(used, /obj/item/stack/sheet/metal) && removal_stage == NUKE_CORE_PANEL_EXPOSED)
		var/obj/item/stack/S = used
		if(S.get_amount() < sheets_to_fix)
			to_chat(user, "<span class='warning'>You need at least [sheets_to_fix] sheets of metal to repair [src]'s outer core plate!</span>")
		else if(do_after(user, 2 SECONDS, target = src))
			if(!loc || !S || S.get_amount() < sheets_to_fix)
				return ITEM_INTERACT_COMPLETE
			S.use(sheets_to_fix)
			user.visible_message("<span class='notice'>[user] repairs [src]'s outer core plate.</span>", \
								"<span class='notice'>You repair [src]'s outer core plate.</span>")
			removal_stage = NUKE_CORE_EVERYTHING_FINE
			update_icon(UPDATE_OVERLAYS)
		return ITEM_INTERACT_COMPLETE
	if(istype(used, /obj/item/nuke_core/plutonium) && removal_stage == NUKE_CORE_FULLY_EXPOSED)
		if(do_after(user, 2 SECONDS, target = src))
			if(!user.transfer_item_to(used, src))
				to_chat(user, "<span class='notice'>The [used] is stuck to your hand!</span>")
				return
			user.visible_message("<span class='notice'>[user] puts [used] back in [src].</span>", "<span class='notice'>You put [used] back in [src].</span>")
			core = used
			update_icon(UPDATE_OVERLAYS)

		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/disk/plantgene))
		to_chat(user, "<span class='warning'>You try to plant the disk, but despite rooting around, it won't fit! After you branch out to read the instructions, you find out where the problem stems from. You've been bamboo-zled, this isn't a nuclear disk at all!</span>")
		return ITEM_INTERACT_COMPLETE

	else if(istype(used, /obj/item/disk))
		if(used.icon_state == "datadisk4") //A similar green disk icon
			to_chat(user, "<span class='warning'>You try to slot in the disk, but it won't fit! This isn't the NAD! If only you'd read the label...</span>")
			return ITEM_INTERACT_COMPLETE
		else
			to_chat(user, "<span class='warning'>You try to slot in the disk, but it won't fit. This isn't the NAD! It's not even the right colour...</span>")
			return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/nuclearbomb/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if(removal_stage == NUKE_COVER_OFF)
		user.visible_message("<span class='notice'>[user] starts forcing open the bolt covers on [src].</span>", "<span class='notice'>You start forcing open the anchoring bolt covers with [I]...</span>")
		if(!I.use_tool(src, user, 15, volume = I.tool_volume) || removal_stage != NUKE_COVER_OFF)
			return
		user.visible_message("<span class='notice'>[user] forces open the bolt covers on [src].</span>", "<span class='notice'>You force open the bolt covers.</span>")
		removal_stage = NUKE_COVER_OPEN
	if(removal_stage == NUKE_CORE_EVERYTHING_FINE)
		if(training)
			to_chat(user, "<span class='notice'>This is where you'd take off the plate to access the internal core, but this training bomb doesn't have one.</span>")
			return
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
			var/datum/component/inherent_radioactivity/radioactivity = core.GetComponent(/datum/component/inherent_radioactivity)
			START_PROCESSING(SSradiation, radioactivity)
	if(removal_stage == NUKE_UNWRENCHED)
		user.visible_message("<span class='notice'>[user] begins lifting [src] off of the anchors.</span>", "<span class='notice'>You begin lifting the device off the anchors...</span>")
		if(!I.use_tool(src, user, 8 SECONDS, volume = I.tool_volume) || removal_stage != NUKE_UNWRENCHED)
			return
		user.visible_message("<span class='notice'>[user] crowbars [src] off of the anchors. It can now be moved.</span>", "<span class='notice'>You jam the crowbar under the nuclear device and lift it off its anchors. You can now move it!</span>")
		anchored = FALSE
		removal_stage = NUKE_MOBILE
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/nuclearbomb/wrench_act(mob/user, obj/item/I)
	if(!anchored)
		return
	if(removal_stage != NUKE_SEALANT_OPEN)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	user.visible_message("<span class='notice'>[user] begins unwrenching the anchoring bolts on [src].</span>", "<span class='notice'>You begin unwrenching the anchoring bolts...</span>")
	if(!I.use_tool(src, user, 50, volume = I.tool_volume) || removal_stage != NUKE_SEALANT_OPEN)
		return
	user.visible_message("<span class='notice'>[user] unwrenches the anchoring bolts on [src].</span>", "<span class='notice'>You unwrench the anchoring bolts.</span>")
	removal_stage = NUKE_UNWRENCHED
	update_icon(UPDATE_OVERLAYS)

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
	if(auth || (istype(I, /obj/item/screwdriver/nuke) && !is_syndicate))
		if(!panel_open)
			panel_open = TRUE
			to_chat(user, "<span class='notice'>You unscrew the control panel of [src].</span>")
			anchor_stage = removal_stage
			removal_stage = core_stage
		else
			panel_open = FALSE
			to_chat(user, "<span class='notice'>You screw the control panel of [src] back on.</span>")
			core_stage = removal_stage
			removal_stage = anchor_stage
	else
		if(!panel_open)
			to_chat(user, "<span class='warning'>[src] emits a buzzing noise, the panel staying locked in.</span>")
		if(panel_open)
			panel_open = FALSE
			to_chat(user, "<span class='notice'>You screw the control panel of [src] back on.</span>")
			core_stage = removal_stage
			removal_stage = anchor_stage
		flick(sprite_prefix + "nuclearbombc", src)
	update_icon(UPDATE_OVERLAYS)

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
	if(requires_NAD_to_unbolt)
		to_chat(user, "<span class='warning'>This device seems to have additional safeguards, and cannot be forcibly moved without using the NAD!</span>")
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
		"<span class='notice'>You cut apart the anchoring system's sealant.</span>")
		removal_stage = NUKE_SEALANT_OPEN
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/nuclearbomb/attack_ghost(mob/user as mob)
	if(!panel_open)
		return ui_interact(user)
	if(removal_stage != NUKE_CORE_FULLY_EXPOSED || !core)
		return wires.Interact(user)

/obj/machinery/nuclearbomb/attack_hand(mob/user as mob)
	if(!panel_open)
		ui_interact(user)
		return FINISH_ATTACK
	if(!Adjacent(user))
		return
	if(removal_stage != NUKE_CORE_FULLY_EXPOSED || !core)
		wires.Interact(user)
		return FINISH_ATTACK
	if(timing) //removing the core is less risk then cutting wires, and doesnt take long, so we should not let crew do it while the nuke is armed. You can however get to it, without the special screwdriver, if you put the NAD in.
		to_chat(user, "<span class='warning'>[core] won't budge, metal clamps keep it in!</span>")
		return FINISH_ATTACK
	user.visible_message("<span class='notice'>[user] starts to pull [core] out of [src]!</span>", "<span class='notice'>You start to pull [core] out of [src]!</span>")
	if(do_after(user, 5 SECONDS, target = src))
		user.visible_message("<span class='notice'>[user] pulls [core] out of [src]!</span>", "<span class='notice'>You pull [core] out of [src]! Might want to put it somewhere safe.</span>")
		core.forceMove(loc)
		core = null

	update_icon(UPDATE_OVERLAYS)
	return FINISH_ATTACK

/obj/machinery/nuclearbomb/ui_state(mob/user)
	return GLOB.physical_state

/obj/machinery/nuclearbomb/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NuclearBomb", name)
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
		if(istype(auth, /obj/item/disk/nuclear/training) && !training)
			return FALSE
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
	if(wires.is_cut(WIRE_NUKE_CONTROL))
		to_chat(usr, "<span class='warning'>The control panel isn't responding! Something must be wrong with its wiring!</span>")
		return FALSE
	switch(action)
		if("deploy")
			if(removal_stage != NUKE_MOBILE)
				anchored = TRUE
				visible_message("<span class='warning'>With a steely snap, bolts slide out of [src] and anchor it to the flooring!</span>")
			else
				visible_message("<span class='warning'>[src] makes a highly unpleasant crunching noise. It looks like the anchoring bolts have been cut.</span>")
			if(!wires.is_cut(WIRE_NUKE_LIGHT))
				flick(sprite_prefix + "nuclearbombc", src)
				icon_state = sprite_prefix + "nuclearbomb1"
			update_icon(UPDATE_OVERLAYS)
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
					if((istype(I, /obj/item/disk/nuclear/training) && !training) || (training && !istype(I, /obj/item/disk/nuclear/training)))
						return
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
			var/tempcode = tgui_input_number(usr, "Code", "Input Code", max_value = 999999)
			if(isnull(tempcode))
				return
			code = tempcode
			if(code == r_code)
				yes_code = TRUE
				code = null
			else
				code = "ERROR"
			return
		if("toggle_anchor")
			if(removal_stage == NUKE_MOBILE)
				anchored = FALSE
				update_icon(UPDATE_OVERLAYS)
				visible_message("<span class='warning'>[src] makes a highly unpleasant crunching noise. It looks like the anchoring bolts have been cut.</span>")
				return

			if(!anchored && isinspace())
				to_chat(usr, "<span class='warning'>There is nothing to anchor to!</span>")
				return FALSE

			if(!yes_code && anchored && timing)
				to_chat(usr, "<span class='warning'>The code is required to unanchor [src] when armed!</span>")
				return

			anchored = !(anchored)
			update_icon(UPDATE_OVERLAYS)
			if(anchored)
				visible_message("<span class='warning'>With a steely snap, bolts slide out of [src] and anchor it to the flooring.</span>")
				return

			requires_NAD_to_unbolt = FALSE
			visible_message("<span class='warning'>The anchoring bolts slide back into the depths of [src].</span>")
			return

	if(!yes_code) // All requests below here require both NAD inserted AND code correct
		return

	switch(action)
		if("set_time")
			var/time = tgui_input_number(usr, "Detonation time (seconds, min 120, max 600)", "Input Time", 120, 600, 120)
			if(isnull(time))
				return
			timeleft = time
		if("toggle_safety")
			if(wires.is_cut(WIRE_NUKE_SAFETY))
				to_chat(usr, "<span class='warning'>The safety isn't responding! Something must be wrong with its wiring!</span>")
				return FALSE
			safety = !(safety)
			if(safety)
				if(!is_syndicate && !training)
					SSsecurity_level.set_level(previous_level)
				timing = FALSE
				if(!training)
					GLOB.bomb_set = FALSE
		if("toggle_armed")
			if(safety)
				to_chat(usr, "<span class='notice'>The safety is still on.</span>")
				return
			if(!core && !training)
				to_chat(usr, "<span class='danger'>[src]'s screen blinks red! There is no plutonium core in [src]!</span>")
				return
			if(!timing)
				if(wires.is_cut(WIRE_NUKE_DETONATOR))
					to_chat(usr, "<span class='warning'>[src] isn't arming! Something must be wrong with its wiring!</span>")
					return FALSE
				timing = TRUE
				if(!wires.is_cut(WIRE_NUKE_LIGHT))
					icon_state = sprite_prefix + "nuclearbomb2"
					update_icon(UPDATE_OVERLAYS)
				if(!safety && !training)
					message_admins("[key_name_admin(usr)] engaged a nuclear bomb [ADMIN_JMP(src)]")
					if(!is_syndicate && SSsecurity_level.get_current_level_as_number() != SEC_LEVEL_EPSILON)
						SSsecurity_level.set_level(SEC_LEVEL_DELTA)
					GLOB.bomb_set = TRUE // There can still be issues with this resetting when there are multiple bombs. Not a big deal though for Nuke
					if(SSsecurity_level.get_current_level_as_number() == SEC_LEVEL_EPSILON)
						radio.autosay("<span class='reallybig'>The Nuclear Bomb has been armed, retreat from the station immediately!</span>", name, "Special Ops")
				else if(!training)
					GLOB.bomb_set = TRUE
			else
				if(wires.is_cut(WIRE_NUKE_DISARM))
					to_chat(usr, "<span class='warning'>[src] isn't disarming! Something must be wrong with its wiring!</span>")
					return FALSE
				timing = FALSE
				if(!is_syndicate && !training)
					SSsecurity_level.set_level(previous_level)
				if(!training)
					GLOB.bomb_set = FALSE
				if(!wires.is_cut(WIRE_NUKE_LIGHT))
					icon_state = sprite_prefix + "nuclearbomb1"
					update_icon(UPDATE_OVERLAYS)

/obj/machinery/nuclearbomb/blob_act(obj/structure/blob/B)
	if(training)
		qdel(src)
		return
	if(exploded)
		return
	if(timing)	//boom
		INVOKE_ASYNC(src, PROC_REF(explode))
		return

	//if no boom then we need to let the blob capture our nuke
	var/turf/T = get_turf(src)
	if(!T)
		return
	if(locate(/obj/structure/blob) in T)
		return
	var/obj/structure/blob/captured_nuke/N = new(T, src)
	N.overmind = B.overmind
	N.adjustcolors(B.color)

/obj/machinery/nuclearbomb/zap_act(power, zap_flags)
	. = ..()
	if(zap_flags & ZAP_MACHINE_EXPLOSIVE)
		qdel(src)//like the singulo, tesla deletes it. stops it from exploding over and over

/// Determine the location of the nuke with respect to the station. Used for,
/// among other things, calculating win conditions for nukies and choosing which
/// round-end cinematic to play.
/obj/machinery/nuclearbomb/proc/get_nuke_site()
	var/turf/bomb_turf = get_turf(src)
	if(!bomb_turf)
		return NUKE_SITE_INVALID

	if(!is_station_level(bomb_turf.z))
		return NUKE_SITE_OFF_STATION_ZLEVEL

	if(get_area(src) in SSmapping.existing_station_areas)
		return NUKE_SITE_ON_STATION

	return NUKE_SITE_ON_STATION_ZLEVEL


/obj/machinery/nuclearbomb/proc/explode()
	if(training)
		atom_say("You've triggered the detonate wire. You are dead.")
		return
	if(safety)
		timing = FALSE
		return
	exploded = TRUE
	yes_code = FALSE
	safety = TRUE
	if(!wires.is_cut(WIRE_NUKE_LIGHT))
		icon_state = sprite_prefix + "nuclearbomb3"
		update_icon(UPDATE_OVERLAYS)
	playsound(src, 'sound/machines/alarm.ogg', 100, FALSE, 5)
	if(SSticker && SSticker.mode)
		SSticker.mode.explosion_in_progress = TRUE
		SSticker.record_biohazard_results()
	sleep(100)

	GLOB.enter_allowed = 0

	var/nuke_site = get_nuke_site()

	if(SSticker)
		if(SSticker.mode && SSticker.mode.name == "nuclear emergency")
			var/obj/docking_port/mobile/syndie_shuttle = SSshuttle.getShuttle("syndicate")
			if(syndie_shuttle)
				SSticker.mode:syndies_didnt_escape = is_station_level(syndie_shuttle.z)
			SSticker.mode:nuke_off_station = nuke_site
		SSticker.station_explosion_cinematic(nuke_site, null)
		if(SSticker.mode)
			SSticker.mode.explosion_in_progress = FALSE
			if(SSticker.mode.name == "nuclear emergency")
				SSticker.mode:nukes_left --
			else if(nuke_site == NUKE_SITE_ON_STATION_ZLEVEL)
				to_chat(world, "<b>A nuclear device was set off, but the explosion was out of reach of the station!</b>")
			else if(nuke_site == NUKE_SITE_OFF_STATION_ZLEVEL)
				to_chat(world, "<b>A nuclear device was set off, but the device nowhere near the station!</b>")
			else if(nuke_site == NUKE_SITE_INVALID)
				to_chat(world, "<b>A nuclear device was set off in an unknown location!</b>")
				log_admin("The nuclear device [src] detonated but was not located on a valid turf.")
			else
				to_chat(world, "<b>The station was destroyed by the nuclear blast!</b>")

			// NUKE_SITE_ON_STATION_ZLEVEL still counts as nuked for the
			// purposes of /datum/game_mode/nuclear/declare_completion() and its
			// weird logic of specifying whether the nuke blew up "something
			// that wasn't" the station.
			SSticker.mode.station_was_nuked = nuke_site == NUKE_SITE_ON_STATION || nuke_site == NUKE_SITE_ON_STATION_ZLEVEL

			if(!SSticker.mode.check_finished())//If the mode does not deal with the nuke going off so just reboot because everyone is stuck as is
				SSticker.reboot_helper("Station destroyed by Nuclear Device.", "nuke - unhandled ending")
				return
	return

/obj/machinery/nuclearbomb/Move(NewLoc, direct)
	. = ..()
	if(!.)
		return
	playsound(loc, pick('sound/items/cartwheel1.ogg', 'sound/items/cartwheel2.ogg'), 100, TRUE, ignore_walls = FALSE)

// MARK: Nuclear Disk

/obj/item/disk/nuclear
	name = "nuclear authentication disk"
	desc = "A floppy disk containing unique cryptographic identification data. Used along with a valid code to detonate the on-site nuclear fission explosive."
	icon_state = "nucleardisk"
	max_integrity = 250
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 30, RAD = 0, FIRE = 100, ACID = 100)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	/// Is the disk restricted to the station? If true, also respawns the disk when deleted
	var/restricted_to_station = TRUE
	/// Is this a training disk?
	var/training = FALSE

/obj/item/disk/nuclear/examine(mob/user)
	. = ..()
	. += "<span class='warning'>You should keep this safe...</span>"

/obj/item/disk/nuclear/examine_more(mob/user)
	. = ..()
	. += "Nuclear fission explosives are stored on all Nanotrasen stations in the system so that they may be rapidly destroyed, should the need arise."
	. += ""
	. += "Naturally, such a destructive capability requires robust safeguards to prevent accidental or malicious misuse. NT employs two mechanisms: an authorisation code from Central Command, \
	and the nuclear authentication disk. Whilst the code is normally sufficient, enemies of Nanotrasen with sufficient resources may be able to spoof, steal, or otherwise crack the authorisation code. \
	The NAD serves to protect against this. It is essentially a one-time pad that functions in tandem with the authorisation code to unlock the detonator of the fission explosive."

/obj/item/disk/nuclear/unrestricted
	name = "unrestricted nuclear authentication disk"
	restricted_to_station = FALSE

/obj/item/disk/nuclear/unrestricted/examine(mob/user)
	. = ..()
	. += "<span class='warning'>This disk has had its safeties removed. It will not teleport back to the station if taken too far away.</span>"

/obj/item/disk/nuclear/New()
	..()
	if(restricted_to_station)
		START_PROCESSING(SSobj, src)
	if(!training)
		GLOB.poi_list |= src
		GLOB.nad_list |= src
		AddElement(/datum/element/high_value_item)

/obj/item/disk/nuclear/process()
	if(!restricted_to_station)
		stack_trace("An unrestricted NAD ([src]) was processing.")
		return PROCESS_KILL
	if(!check_disk_loc())
		var/holder = get(src, /mob)
		if(holder)
			to_chat(holder, "<span class='danger'>You can't help but feel that you just lost something back there...</span>")
		qdel(src)

 //station disk is allowed on the station level, escape shuttle/pods, CC, and syndicate shuttles/base, reset otherwise
/obj/item/disk/nuclear/proc/check_disk_loc()
	if(!restricted_to_station)
		return TRUE
	var/turf/T = get_turf(src)
	var/area/A = get_area(src)
	if(is_station_level(T.z))
		return TRUE
	if(A.nad_allowed)
		return TRUE
	return FALSE

/obj/item/disk/nuclear/Destroy(force)
	var/turf/diskturf = get_turf(src)

	if(training)
		return ..()

	if(force)
		message_admins("[src] has been !!force deleted!! in ([diskturf ? "[diskturf.x], [diskturf.y] ,[diskturf.z] - <a href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[diskturf.x];Y=[diskturf.y];Z=[diskturf.z]'>JMP</a>":"nonexistent location"]).")
		log_game("[src] has been !!force deleted!! in ([diskturf ? "[diskturf.x], [diskturf.y] ,[diskturf.z]":"nonexistent location"]).")
		GLOB.poi_list.Remove(src)
		GLOB.nad_list.Remove(src)
		STOP_PROCESSING(SSobj, src)
		return ..()

	if(!restricted_to_station) // Non-restricted NADs should be allowed to be deleted, otherwise it becomes a restricted NAD when teleported
		message_admins("[src] (unrestricted) has been deleted in ([diskturf ? "[diskturf.x], [diskturf.y] ,[diskturf.z] - <a href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[diskturf.x];Y=[diskturf.y];Z=[diskturf.z]'>JMP</a>":"nonexistent location"]). It will not respawn.")
		log_game("[src] (unrestricted) has been deleted in ([diskturf ? "[diskturf.x], [diskturf.y] ,[diskturf.z]":"nonexistent location"]). It will not respawn.")
		GLOB.poi_list.Remove(src)
		GLOB.nad_list.Remove(src)
		STOP_PROCESSING(SSobj, src)
		return ..()

	var/turf/new_spawn = find_respawn()
	if(new_spawn)
		GLOB.poi_list.Remove(src)
		GLOB.nad_list.Remove(src)
		var/obj/item/disk/nuclear/NEWDISK = new(new_spawn)
		transfer_fingerprints_to(NEWDISK)
		message_admins("[src] has been destroyed at ([diskturf.x], [diskturf.y], [diskturf.z] - <a href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[diskturf.x];Y=[diskturf.y];Z=[diskturf.z]'>JMP</a>). Moving it to ([NEWDISK.x], [NEWDISK.y], [NEWDISK.z] - <a href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[NEWDISK.x];Y=[NEWDISK.y];Z=[NEWDISK.z]'>JMP</a>).")
		log_game("[src] has been destroyed in ([diskturf.x], [diskturf.y], [diskturf.z]). Moving it to ([NEWDISK.x], [NEWDISK.y], [NEWDISK.z]).")
		..()
		return QDEL_HINT_HARDDEL_NOW // We want this to be deleted ASAP, but we want refs properly cleared too
	else
		error("[src] was supposed to be destroyed, but we were unable to locate a nukedisc_respawn landmark or open surroundings to spawn a new one.")
	return QDEL_HINT_LETMELIVE // Cancel destruction unless forced.

/obj/item/disk/nuclear/proc/find_respawn()
	var/list/possible_spawns = GLOB.nukedisc_respawn
	while(length(possible_spawns))
		var/turf/current_spawn = pick_n_take(possible_spawns)
		if(!current_spawn.density)
			return current_spawn
		// Someone built a wall over it, check the surroundings
		var/list/open_turfs = current_spawn.AdjacentTurfs(open_only = TRUE)
		if(length(open_turfs))
			return pick(open_turfs)

// MARK: Training Nuke

/obj/machinery/nuclearbomb/training
	name = "training nuclear bomb"
	desc = "A fake nuke used to practice nuclear device operations. \
		The '1' key on the keypad appears to be significantly more worn than the other keys."
	icon_state = "t_nuclearbomb1"
	resistance_flags = null
	training = TRUE
	sprite_prefix = "t_"

/obj/machinery/nuclearbomb/training/Initialize(mapload)
	. = ..()
	r_code = 11111 //Uuh.. one!

/obj/machinery/nuclearbomb/training/process()
	if(timing)
		timeleft = max(timeleft - 2, 0) // 2 seconds per process()
		if(timeleft <= 0)
			INVOKE_ASYNC(src, PROC_REF(training_detonation))

/obj/machinery/nuclearbomb/training/blob_act(obj/structure/blob/B)
	qdel(src)

/obj/machinery/nuclearbomb/training/AltClick(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>You hit the reset button on [src].</span>")
	training_reset()

/obj/machinery/nuclearbomb/training/proc/training_detonation()
	atom_say("Nuclear device detonated. Resetting...")
	training_reset()

/obj/machinery/nuclearbomb/training/proc/training_reset()
	if(auth)
		auth.forceMove(get_turf(src))
	new /obj/machinery/nuclearbomb/training(get_turf(src))
	qdel(src)

/obj/item/disk/nuclear/training
	name = "training nuclear authentication disk"
	desc = "The code is 11111."
	icon_state = "trainingdisk"
	resistance_flags = null
	restricted_to_station = FALSE
	training = TRUE


/obj/item/disk/nuclear/training/examine(mob/user)
	. = ..()
	. += "<span class='warning'>For training purposes, of course.</span>"

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

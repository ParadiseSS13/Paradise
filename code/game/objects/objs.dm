/obj
	//var/datum/module/mod		//not used
	var/origin_tech = null	//Used by R&D to determine what research bonuses it grants.
	var/crit_fail = FALSE
	animate_movement = 2
	var/list/species_exception = null	// list() of species types, if a species cannot put items in a certain slot, but species type is in list, it will be able to wear that item
	var/sharp = FALSE		// whether this object cuts
	var/in_use = FALSE // If we have a user using us, this will be set on. We will check if the user has stopped using us, and thus stop updating and LAGGING EVERYTHING!
	var/damtype = "brute"
	var/force = 0
	var/datum/armor/armor
	var/obj_integrity	//defaults to max_integrity
	var/max_integrity = 500
	var/integrity_failure = 0 //0 if we have no special broken behavior
	///Damage under this value will be completely ignored
	var/damage_deflection = 0

	var/resistance_flags = NONE // INDESTRUCTIBLE

	var/acid_level = 0 //how much acid is on that obj

	var/can_be_hit = TRUE //can this be bludgeoned by items?

	var/Mtoollink = FALSE // variable to decide if an object should show the multitool menu linking menu, not all objects use it

	var/being_shocked = FALSE
	var/speed_process = FALSE

	var/on_blueprints = FALSE //Are we visible on the station blueprints at roundstart?
	var/force_blueprints = FALSE //forces the obj to be on the blueprints, regardless of when it was created.
	var/suicidal_hands = FALSE // Does it requires you to hold it to commit suicide with it?

/obj/New()
	..()
	if(obj_integrity == null)
		obj_integrity = max_integrity
	if(on_blueprints && isturf(loc))
		var/turf/T = loc
		if(force_blueprints)
			T.add_blueprints(src)
		else
			T.add_blueprints_preround(src)

/obj/Initialize(mapload)
	. = ..()
	if(islist(armor))
		armor = getArmor(arglist(armor))
	else if(!armor)
		armor = getArmor()
	else if(!istype(armor, /datum/armor))
		stack_trace("Invalid type [armor.type] found in .armor during /obj Initialize()")

/obj/Topic(href, href_list, nowindow = FALSE, datum/ui_state/state = GLOB.default_state)
	// Calling Topic without a corresponding window open causes runtime errors
	if(!nowindow && ..())
		return TRUE

	// In the far future no checks are made in an overriding Topic() beyond if(..()) return
	// Instead any such checks are made in CanUseTopic()
	if(ui_status(usr, state, href_list) == STATUS_INTERACTIVE)
		CouldUseTopic(usr)
		return FALSE

	CouldNotUseTopic(usr)
	return TRUE

/obj/proc/CouldUseTopic(mob/user)
	var/atom/host = ui_host()
	host.add_fingerprint(user)

/obj/proc/CouldNotUseTopic(mob/user)
	// Nada

/obj/Destroy()
	if(!ismachinery(src))
		if(!speed_process)
			STOP_PROCESSING(SSobj, src) // TODO: Have a processing bitflag to reduce on unnecessary loops through the processing lists
		else
			STOP_PROCESSING(SSfastprocess, src)
	SStgui.close_uis(src)
	return ..()

//user: The mob that is suiciding
//damagetype: The type of damage the item will inflict on the user
//BRUTELOSS = 1
//FIRELOSS = 2
//TOXLOSS = 4
//OXYLOSS = 8
//SHAME = 16
//OBLITERATION = 32

//Output a creative message and then return the damagetype done
/obj/proc/suicide_act(mob/user)
	return FALSE

/obj/assume_air(datum/gas_mixture/giver)
	if(loc)
		return loc.assume_air(giver)
	else
		return null

/obj/remove_air(amount)
	if(loc)
		return loc.remove_air(amount)
	else
		return null

/obj/return_air()
	if(loc)
		return loc.return_air()
	else
		return null

/obj/proc/handle_internal_lifeform(mob/lifeform_inside_me, breath_request)
	//Return: (NONSTANDARD)
	//		null if object handles breathing logic for lifeform
	//		datum/air_group to tell lifeform to process using that breath return
	//DEFAULT: Take air from turf to give to have mob process
	if(breath_request > 0)
		return remove_air(breath_request)
	else
		return null

/obj/proc/updateUsrDialog()
	if(in_use)
		var/is_in_use = FALSE
		var/list/nearby = viewers(1, src)
		for(var/mob/M in nearby)
			if((M.client && M.machine == src))
				is_in_use = TRUE
				src.attack_hand(M)
		if(istype(usr, /mob/living/silicon/ai) || istype(usr, /mob/living/silicon/robot))
			if(!(usr in nearby))
				if(usr.client && usr.machine==src) // && M.machine == src is omitted because if we triggered this by using the dialog, it doesn't matter if our machine changed in between triggering it and this - the dialog is probably still supposed to refresh.
					is_in_use = TRUE
					src.attack_ai(usr)

		// check for TK users

		if(istype(usr, /mob/living/carbon/human))
			if(istype(usr.l_hand, /obj/item/tk_grab) || istype(usr.r_hand, /obj/item/tk_grab/))
				if(!(usr in nearby))
					if(usr.client && usr.machine == src)
						is_in_use = TRUE
						src.attack_hand(usr)
		in_use = is_in_use

/obj/proc/updateDialog()
	// Check that people are actually using the machine. If not, don't update anymore.
	if(in_use)
		var/list/nearby = viewers(1, src)
		var/is_in_use = FALSE
		for(var/mob/M in nearby)
			if((M.client && M.machine == src))
				is_in_use = TRUE
				src.interact(M)
		var/ai_in_use = AutoUpdateAI(src)

		if(!ai_in_use && !is_in_use)
			in_use = FALSE

/obj/proc/interact(mob/user)
	return

/obj/proc/update_icon()
	SEND_SIGNAL(src, COMSIG_OBJ_UPDATE_ICON)

/mob/proc/unset_machine()
	if(machine)
		machine.on_unset_machine(src)
		machine = null

//called when the user unsets the machine.
/atom/movable/proc/on_unset_machine(mob/user)
	return

/mob/proc/set_machine(obj/O)
	if(src.machine)
		unset_machine()
	src.machine = O
	if(istype(O))
		O.in_use = TRUE

/obj/item/proc/updateSelfDialog()
	var/mob/M = src.loc
	if(istype(M) && M.client && M.machine == src)
		src.attack_self(M)

/obj/proc/hide(h)
	return

/obj/proc/hear_talk(mob/M, list/message_pieces)
	return

/obj/proc/hear_message(mob/M, text)

/obj/proc/multitool_menu(mob/user, obj/item/multitool/P)
	return "<b>NO MULTITOOL_MENU!</b>"

/obj/proc/linkWith(mob/user, obj/buffer, context)
	return FALSE

/obj/proc/unlinkFrom(mob/user, obj/buffer)
	return FALSE

/obj/proc/canLink(obj/O, list/context)
	return FALSE

/obj/proc/isLinkedWith(obj/O)
	return FALSE

/obj/proc/getLink(idx)
	return null

/obj/proc/linkMenu(obj/O)
	var/dat = ""
	if(canLink(O, list()))
		dat += " <a href='?src=[UID()];link=1'>\[Link\]</a> "
	return dat

/obj/proc/format_tag(label, varname, act = "set_tag")
	var/value = vars[varname]
	if(!value || value == "")
		value = "-----"
	return "<b>[label]:</b> <a href=\"?src=[UID()];[act]=[varname]\">[value]</a>"


/obj/proc/update_multitool_menu(mob/user)
	var/obj/item/multitool/P = get_multitool(user)

	if(!istype(P))
		return FALSE

	var/dat = {"<html>
	<head>
		<title>[name] Configuration</title>
		<style type="text/css">
html,body {
	font-family:courier;
	background:#999999;
	color:#333333;
}

a {
	color:#000000;
	text-decoration:none;
	border-bottom:1px solid black;
}
		</style>
	</head>
	<body>
		<h3>[name]</h3>
"}
	if(allowed(user))//no, assistants, you're not ruining all vents on the station with just a multitool
		dat += multitool_menu(user, P)
		if(Mtoollink)
			if(P)
				if(P.buffer)
					var/id = null
					if("id_tag" in P.buffer.vars)
						id = P.buffer:id_tag
					dat += "<p><b>MULTITOOL BUFFER:</b> [P.buffer] [id ? "([id])" : ""]"

					dat += linkMenu(P.buffer)

					if(P.buffer)
						dat += "<a href='?src=[UID()];flush=1'>\[Flush\]</a>"
					dat += "</p>"
				else
					dat += "<p><b>MULTITOOL BUFFER:</b> <a href='?src=[UID()];buffer=1'>\[Add Machine\]</a></p>"
	else
		dat += "<b>ACCESS DENIED</a>"
	dat += "</body></html>"
	user << browse(dat, "window=mtcomputer")
	user.set_machine(src)
	onclose(user, "mtcomputer")

/obj/proc/default_welder_repair(mob/user, obj/item/I) //Returns TRUE if the object was successfully repaired. Fully repairs an object (setting BROKEN to FALSE), default repair time = 40
	if(obj_integrity >= max_integrity)
		to_chat(user, "<span class='notice'>[src] does not need repairs.</span>")
		return
	if(I.tool_behaviour != TOOL_WELDER)
		return
	if(!I.tool_use_check(user, 0))
		return
	var/time = max(50 * (1 - obj_integrity / max_integrity), 5)
	WELDER_ATTEMPT_REPAIR_MESSAGE
	if(I.use_tool(src, user, time, volume = I.tool_volume))
		WELDER_REPAIR_SUCCESS_MESSAGE
		obj_integrity = max_integrity
		update_icon()
	return TRUE

/obj/proc/default_unfasten_wrench(mob/user, obj/item/I, time = 20)
	if(!anchored && !isfloorturf(loc))
		user.visible_message("<span class='warning'>A floor must be present to secure [src]!</span>")
		return FALSE
	if(I.tool_behaviour != TOOL_WRENCH)
		return FALSE
	if(!I.tool_use_check(user, 0))
		return FALSE
	if(!(flags & NODECONSTRUCT))
		to_chat(user, "<span class='notice'>Now [anchored ? "un" : ""]securing [name].</span>")
		if(I.use_tool(src, user, time, volume = I.tool_volume))
			to_chat(user, "<span class='notice'>You've [anchored ? "un" : ""]secured [name].</span>")
			anchored = !anchored
		return TRUE
	return FALSE

/obj/water_act(volume, temperature, source, method = REAGENT_TOUCH)
	. = ..()
	extinguish()
	acid_level = 0

/obj/singularity_pull(S, current_size)
	..()
	if(!anchored || current_size >= STAGE_FIVE)
		step_towards(src, S)

/obj/proc/container_resist(mob/living)
	return

/obj/proc/CanAStarPass(ID, dir, caller)
	. = !density

/obj/proc/on_mob_move(dir, mob/user)
	return

/obj/proc/makeSpeedProcess()
	if(speed_process)
		return
	speed_process = TRUE
	STOP_PROCESSING(SSobj, src)
	START_PROCESSING(SSfastprocess, src)

/obj/proc/makeNormalProcess()
	if(!speed_process)
		return
	speed_process = FALSE
	START_PROCESSING(SSobj, src)
	STOP_PROCESSING(SSfastprocess, src)

/obj/vv_get_dropdown()
	. = ..()
	.["Delete all of type"] = "?_src_=vars;delall=[UID()]"
	if(!speed_process)
		.["Make speed process"] = "?_src_=vars;makespeedy=[UID()]"
	else
		.["Make normal process"] = "?_src_=vars;makenormalspeed=[UID()]"
	.["Modify armor values"] = "?_src_=vars;modifyarmor=[UID()]"

/obj/proc/check_uplink_validity()
	return TRUE

/obj/proc/cult_conceal() //Called by cult conceal spell
	return

/obj/proc/cult_reveal() //Called by cult reveal spell and chaplain's bible
	return

/obj/proc/force_eject_occupant(mob/target)
	// This proc handles safely removing occupant mobs from the object if they must be teleported out (due to being SSD/AFK, by admin teleport, etc) or transformed.
	// In the event that the object doesn't have an overriden version of this proc to do it, log a runtime so one can be added.
	CRASH("Proc force_eject_occupant() is not overriden on a machine containing a mob.")


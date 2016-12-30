/obj
	//var/datum/module/mod		//not used
	var/origin_tech = null	//Used by R&D to determine what research bonuses it grants.
	var/reliability = 100	//Used by SOME devices to determine how reliable they are.
	var/crit_fail = 0
	var/unacidable = 0 //universal "unacidabliness" var, here so you can use it in any obj.
	animate_movement = 2
	var/throwforce = 1
	var/list/attack_verb = list() //Used in attackby() to say how something was attacked "[x] has been [z.attack_verb] by [y] with [z]"
	var/sharp = 0		// whether this object cuts
	var/edge = 0		// whether this object is more likely to dismember
	var/in_use = 0 // If we have a user using us, this will be set on. We will check if the user has stopped using us, and thus stop updating and LAGGING EVERYTHING!

	var/damtype = "brute"
	var/force = 0

	var/Mtoollink = 0 // variable to decide if an object should show the multitool menu linking menu, not all objects use it

	var/burn_state = FIRE_PROOF // LAVA_PROOF | FIRE_PROOF | FLAMMABLE | ON_FIRE
	var/burntime = 10 //How long it takes to burn to ashes, in seconds
	var/burn_world_time //What world time the object will burn up completely
	var/being_shocked = 0

	var/on_blueprints = FALSE //Are we visible on the station blueprints at roundstart?
	var/force_blueprints = FALSE //forces the obj to be on the blueprints, regardless of when it was created.

/obj/New()
	. = ..()

	if(on_blueprints && isturf(loc))
		var/turf/T = loc
		if(force_blueprints)
			T.add_blueprints(src)
		else
			T.add_blueprints_preround(src)

/obj/Topic(href, href_list, var/nowindow = 0, var/datum/topic_state/state = default_state)
	// Calling Topic without a corresponding window open causes runtime errors
	if(!nowindow && ..())
		return 1

	// In the far future no checks are made in an overriding Topic() beyond if(..()) return
	// Instead any such checks are made in CanUseTopic()
	if(CanUseTopic(usr, state, href_list) == STATUS_INTERACTIVE)
		CouldUseTopic(usr)
		return 0

	CouldNotUseTopic(usr)
	return 1

/obj/proc/CouldUseTopic(var/mob/user)
	var/atom/host = nano_host()
	host.add_fingerprint(user)

/obj/proc/CouldNotUseTopic(var/mob/user)
	// Nada

/obj/Destroy()
	machines -= src
	processing_objects -= src
	nanomanager.close_uis(src)
	return ..()

/obj/item/proc/is_used_on(obj/O, mob/user)

/obj/proc/process()
	set waitfor = 0
	processing_objects.Remove(src)
	return 0

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
	if(breath_request>0)
		return remove_air(breath_request)
	else
		return null

/obj/proc/updateUsrDialog()
	if(in_use)
		var/is_in_use = 0
		var/list/nearby = viewers(1, src)
		for(var/mob/M in nearby)
			if((M.client && M.machine == src))
				is_in_use = 1
				src.attack_hand(M)
		if(istype(usr, /mob/living/silicon/ai) || istype(usr, /mob/living/silicon/robot))
			if(!(usr in nearby))
				if(usr.client && usr.machine==src) // && M.machine == src is omitted because if we triggered this by using the dialog, it doesn't matter if our machine changed in between triggering it and this - the dialog is probably still supposed to refresh.
					is_in_use = 1
					src.attack_ai(usr)

		// check for TK users

		if(istype(usr, /mob/living/carbon/human))
			if(istype(usr.l_hand, /obj/item/tk_grab) || istype(usr.r_hand, /obj/item/tk_grab/))
				if(!(usr in nearby))
					if(usr.client && usr.machine==src)
						is_in_use = 1
						src.attack_hand(usr)
		in_use = is_in_use

/obj/proc/updateDialog()
	// Check that people are actually using the machine. If not, don't update anymore.
	if(in_use)
		var/list/nearby = viewers(1, src)
		var/is_in_use = 0
		for(var/mob/M in nearby)
			if((M.client && M.machine == src))
				is_in_use = 1
				src.interact(M)
		var/ai_in_use = AutoUpdateAI(src)

		if(!ai_in_use && !is_in_use)
			in_use = 0

/obj/proc/interact(mob/user)
	return

/obj/proc/update_icon()
	return

/mob/proc/unset_machine()
	if(machine)
		machine.on_unset_machine(src)
		machine = null

//called when the user unsets the machine.
/atom/movable/proc/on_unset_machine(mob/user)
	return

/mob/proc/set_machine(var/obj/O)
	if(src.machine)
		unset_machine()
	src.machine = O
	if(istype(O))
		O.in_use = 1

/obj/item/proc/updateSelfDialog()
	var/mob/M = src.loc
	if(istype(M) && M.client && M.machine == src)
		src.attack_self(M)


/obj/proc/alter_health()
	return 1

/obj/proc/hide(h)
	return


/obj/proc/hear_talk(mob/M as mob, text)
	if(talking_atom)
		talking_atom.catchMessage(text, M)

/*
	var/mob/mo = locate(/mob) in src
	if(mo)
		var/rendered = "<span class='game say'><span class='name'>[M.name]: </span> <span class='message'>[text]</span></span>"
		mo.show_message(rendered, 2)
*/

/obj/proc/hear_message(mob/M as mob, text)

/obj/proc/multitool_menu(var/mob/user,var/obj/item/device/multitool/P)
	return "<b>NO MULTITOOL_MENU!</b>"

/obj/proc/linkWith(var/mob/user, var/obj/buffer, var/link/context)
	return 0

/obj/proc/unlinkFrom(var/mob/user, var/obj/buffer)
	return 0

/obj/proc/canLink(var/obj/O, var/link/context)
	return 0

/obj/proc/isLinkedWith(var/obj/O)
	return 0

/obj/proc/getLink(var/idx)
	return null

/obj/proc/linkMenu(var/obj/O)
	var/dat=""
	if(canLink(O, list()))
		dat += " <a href='?src=[UID()];link=1'>\[Link\]</a> "
	return dat

/obj/proc/format_tag(var/label,var/varname, var/act="set_tag")
	var/value = vars[varname]
	if(!value || value=="")
		value="-----"
	return "<b>[label]:</b> <a href=\"?src=[UID()];[act]=[varname]\">[value]</a>"


/obj/proc/update_multitool_menu(mob/user as mob)
	var/obj/item/device/multitool/P = get_multitool(user)

	if(!istype(P))
		return 0
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
		dat += multitool_menu(user,P)
		if(Mtoollink)
			if(P)
				if(P.buffer)
					var/id = null
					if(istype(P.buffer, /obj/machinery/telecomms))
						id=P.buffer:id
					else if("id_tag" in P.buffer.vars)
						id=P.buffer:id_tag
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

/obj/singularity_act()
	ex_act(1.0)
	if(src && isnull(gcDestroyed))
		qdel(src)
	return 2

/obj/singularity_pull(S, current_size)
	if(anchored)
		if(current_size >= STAGE_FIVE)
			anchored = 0
			step_towards(src,S)
	else step_towards(src,S)

/obj/proc/container_resist(var/mob/living)
	return

/obj/proc/tesla_act(var/power)
	being_shocked = 1
	var/power_bounced = power * 0.5
	tesla_zap(src, 3, power_bounced)
	addtimer(src, "reset_shocked", 10)

/obj/proc/reset_shocked()
	being_shocked = 0

/obj/proc/CanAStarPass()
	. = !density

/obj/fire_act(global_overlay=1)
	if(!burn_state)
		burn_state = ON_FIRE
		fire_master.burning += src
		burn_world_time = world.time + burntime*rand(10,20)
		if(global_overlay)
			overlays += fire_overlay
		return 1

/obj/proc/burn()
	empty_object_contents(1, loc)
	var/obj/effect/decal/cleanable/ash/A = new(loc)
	A.desc = "Looks like this used to be a [name] some time ago."
	fire_master.burning -= src
	qdel(src)

/obj/proc/extinguish()
	if(burn_state == ON_FIRE)
		burn_state = FLAMMABLE
		overlays -= fire_overlay
		fire_master.burning -= src

/obj/proc/empty_object_contents(burn = 0, new_loc = loc)
	for(var/obj/item/Item in contents) //Empty out the contents
		Item.forceMove(new_loc)
		if(burn)
			Item.fire_act() //Set them on fire, too
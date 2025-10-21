

/obj/machinery/power/solar
	name = "solar panel"
	desc = "A solar panel. Generates electricity when in contact with sunlight."
	icon = 'icons/goonstation/objects/power.dmi'
	icon_state = "sp_base"
	density = TRUE
	max_integrity = 150
	integrity_failure = 50

	var/obscured = FALSE
	var/sunfrac = 0
	var/adir = SOUTH // actual dir
	var/ndir = SOUTH // target dir
	var/turn_angle = 0
	var/obj/machinery/power/solar_control/control = null

/obj/machinery/power/solar/Initialize(mapload, obj/item/solar_assembly/S)
	. = ..()
	Make(S)
	connect_to_network()

/obj/machinery/power/solar/Destroy()
	unset_control() //remove from control computer
	return ..()

//set the control of the panel to a given computer if closer than SOLAR_MACHINERY_MAX_DIST
/obj/machinery/power/solar/proc/set_control(obj/machinery/power/solar_control/SC)
	if(!SC || (get_dist(src, SC) > SOLAR_MACHINERY_MAX_DIST))
		return FALSE
	control = SC
	SC.connected_panels |= src
	return TRUE

//set the control of the panel to null and removes it from the control list of the previous control computer if needed
/obj/machinery/power/solar/proc/unset_control()
	if(control)
		control.connected_panels.Remove(src)
	control = null

/obj/machinery/power/solar/proc/Make(obj/item/solar_assembly/S)
	if(!S)
		S = new /obj/item/solar_assembly(src)
		S.glass_type = /obj/item/stack/sheet/glass
		S.anchored = TRUE
	S.loc = src
	if(S.glass_type == /obj/item/stack/sheet/rglass) //if the panel is in reinforced glass
		max_integrity *= 2 								 //this need to be placed here, because panels already on the map don't have an assembly linked to
		obj_integrity = max_integrity
	update_icon(UPDATE_OVERLAYS)


/obj/machinery/power/solar/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	playsound(loc, 'sound/machines/click.ogg', 50, 1)
	user.visible_message("[user] begins to take the glass off the solar panel.", "<span class='notice'>You begin to take the glass off the solar panel...</span>")
	if(I.use_tool(src, user, 50, volume = I.tool_volume))
		user.visible_message("[user] takes the glass off the solar panel.", "<span class='notice'>You take the glass off the solar panel.</span>")
		deconstruct(TRUE)

/obj/machinery/power/solar/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(stat & BROKEN)
				playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 60, TRUE)
			else
				playsound(loc, 'sound/effects/glasshit.ogg', 90, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/machinery/power/solar/obj_break(damage_flag)
	if(!(stat & BROKEN) && !(flags & NODECONSTRUCT))
		playsound(loc, 'sound/effects/glassbr3.ogg', 100, TRUE)
		stat |= BROKEN
		unset_control()
		update_icon(UPDATE_OVERLAYS)

/obj/machinery/power/solar/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		if(disassembled)
			var/obj/item/solar_assembly/S = locate() in src
			if(S)
				S.forceMove(loc)
				S.give_glass(stat & BROKEN)
		else
			playsound(src, "shatter", 70, TRUE)
			new /obj/item/shard(loc)
			new /obj/item/shard(loc)
	qdel(src)

/obj/machinery/power/solar/update_overlays()
	. = ..()
	if(stat & BROKEN)
		. += image('icons/goonstation/objects/power.dmi', icon_state = "solar_panel-b", layer = FLY_LAYER)
	else
		var/image/panel = image('icons/goonstation/objects/power.dmi', icon_state = "solar_panel", layer = FLY_LAYER)
		var/matrix/M = matrix()
		M.Turn(adir)
		panel.transform = M
		. += panel

//calculates the fraction of the sunlight that the panel receives
/obj/machinery/power/solar/proc/update_solar_exposure()
	if(obscured)
		sunfrac = 0
		return

	//find the smaller angle between the direction the panel is facing and the direction of the sun (the sign is not important here)
	var/p_angle = min(abs(adir - SSsun.angle), 360 - abs(adir - SSsun.angle))

	if(p_angle > 90)			// if facing more than 90deg from sun, zero output
		sunfrac = 0
		return

	sunfrac = cos(p_angle) ** 2
	//isn't the power received from the incoming light proportionnal to cos(p_angle) (Lambert's cosine law) rather than cos(p_angle)^2 ?

/obj/machinery/power/solar/process()//TODO: remove/add this from machines to save on processing as needed ~Carn PRIORITY
	if(stat & BROKEN)
		return
	if(!control) //if there's no sun or the panel is not linked to a solar control computer, no need to proceed
		return

	if(powernet)
		if(powernet == control.powernet)//check if the panel is still connected to the computer
			if(obscured) //get no light from the sun, so don't generate power
				return
			var/sgen = SSsun.solar_gen_rate * sunfrac
			produce_direct_power(sgen)
			control.gen += sgen
		else //if we're no longer on the same powernet, remove from control computer
			unset_control()

/obj/machinery/power/solar/proc/broken()
	. = (!(stat & BROKEN))
	stat |= BROKEN
	unset_control()
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/power/solar/fake/process()
	. = PROCESS_KILL
	return

//trace towards sun to see if we're in shadow
/obj/machinery/power/solar/proc/occlusion()

	var/ax = x		// start at the solar panel
	var/ay = y
	var/turf/T = null
	var/dx = SSsun.dx
	var/dy = SSsun.dy

	for(var/i = 1 to 20)		// 20 steps is enough
		ax += dx	// do step
		ay += dy

		T = locate( round(ax,0.5),round(ay,0.5),z)

		if(T.x == 1 || T.x==world.maxx || T.y==1 || T.y==world.maxy)		// not obscured if we reach the edge
			break

		if(T.density)			// if we hit a solid turf, panel is obscured
			obscured = TRUE
			return

	obscured = FALSE		// if hit the edge or stepped 20 times, not obscured
	update_solar_exposure()


//
// Solar Assembly - For construction of solar arrays.
//

/obj/item/solar_assembly
	name = "solar panel assembly"
	desc = "A solar panel assembly kit, allows constructions of a solar panel, or with a tracking circuit board, a solar tracker."
	icon = 'icons/goonstation/objects/power.dmi'
	icon_state = "sp_base"
	inhand_icon_state = "electropack"
	w_class = WEIGHT_CLASS_BULKY // Pretty big!
	var/tracker = 0
	var/glass_type = null

/obj/item/solar_assembly/attack_hand(mob/user)
	if(!anchored)
		..()

// Give back the glass type we were supplied with
/obj/item/solar_assembly/proc/give_glass()
	if(glass_type)
		var/obj/item/stack/sheet/S = new glass_type(src.loc)
		S.amount = 2
		glass_type = null

/obj/item/solar_assembly/examine(mob/user)
	. = ..()
	. += "<span class='notice'>The solar assembly is <b>[anchored ? "wrenched into place" : "unwrenched"]</b>.</span>"
	if(tracker)
		. += "<span class='notice'>The solar assembly has a tracking circuit installed. It can be <b>pried out</b>.</span>"
	else
		. += "<span class='notice'>The solar assembly has a slot for a <i>tracking circuit</i> board.</span>"
	if(anchored)
		.+= "<span class='notice'>The solar assembly needs <i>glass</i> to be completed.</span>"

/obj/item/solar_assembly/attackby__legacy__attackchain(obj/item/W, mob/user, params)

	if(anchored || !isturf(loc))
		if(istype(W, /obj/item/stack/sheet/glass) || istype(W, /obj/item/stack/sheet/rglass))
			var/obj/item/stack/sheet/S = W
			if(S.use(2))
				glass_type = S.merge_type
				playsound(loc, S.usesound, 50, 1)
				user.visible_message("[user] places the glass on the solar assembly.", "<span class='notice'>You place the glass on the solar assembly.</span>")
				if(tracker)
					new /obj/machinery/power/tracker(get_turf(src), src)
				else
					new /obj/machinery/power/solar(get_turf(src), src)
			else
				to_chat(user, "<span class='warning'>You need two sheets of glass to put them into a solar panel.</span>")
				return
			return TRUE

	if(!tracker)
		if(istype(W, /obj/item/tracker_electronics))
			if(!user.drop_item())
				return
			tracker = TRUE
			qdel(W)
			user.visible_message("[user] inserts the electronics into the solar assembly.", "<span class='notice'>You insert the electronics into the solar assembly.</span>")
			return TRUE
	else
		return ..()

/obj/item/solar_assembly/crowbar_act(mob/living/user, obj/item/I)
	if(!tracker)
		return
	. = TRUE
	if(!I.use_tool(src, user, I.tool_volume))
		return
	new /obj/item/tracker_electronics(loc)
	tracker = FALSE
	user.visible_message("[user] takes out the electronics from the solar assembly.", "<span class='notice'>You take out the electronics from the solar assembly.</span>")

/obj/item/solar_assembly/wrench_act(mob/living/user, obj/item/I)
	if(!anchored && isturf(loc))
		if(I.use_tool(src, user, I.tool_volume))
			anchored = TRUE
			user.visible_message("[user] wrenches the solar assembly into place.", "<span class='notice'>You wrench the solar assembly into place.</span>")
			return TRUE
	else
		if(I.use_tool(src, user, I.tool_volume))
			anchored = FALSE
			user.visible_message("[user] unwrenches the solar assembly from its place.", "<span class='notice'>You unwrench the solar assembly from its place.</span>")
			return TRUE

//
// Solar Control Computer
//

#define TRACKER_OFF 0
#define TRACKER_TIMED 1
#define TRACKER_AUTO 2

/obj/machinery/power/solar_control
	name = "solar panel control"
	desc = "A controller for solar panel arrays."
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer"
	density = TRUE
	power_state = IDLE_POWER_USE
	idle_power_consumption = 250
	integrity_failure = 100
	var/icon_screen = "solar"
	var/icon_keyboard = "power_key"
	var/cdir = 0
	var/targetdir = 0		// target angle in manual tracking (since it updates every game minute)
	var/gen = 0
	var/lastgen = 0
	var/track = TRACKER_OFF
	var/trackrate = 600		// 300-900 seconds
	var/nexttime = 0		// time for a panel to rotate of 1? in manual tracking
	var/autostart = FALSE	// Automatically search for connected devices
	var/obj/machinery/power/tracker/connected_tracker = null
	var/list/connected_panels = list()

// Used for mapping in solar array which automatically starts itself (telecomms, for example)
/obj/machinery/power/solar_control/autostart
	track = TRACKER_AUTO
	autostart = TRUE // Automatically search for connected devices

/obj/machinery/power/solar_control/Initialize(mapload)
	SSsun.solars |= src
	setup()
	. = ..()

/obj/machinery/power/solar_control/proc/setup()
	connect_to_network()
	set_panels(cdir)
	if(autostart)
		search_for_connected()
		if(connected_tracker && track == TRACKER_AUTO)
			connected_tracker.modify_angle(SSsun.angle)
		set_panels(cdir)

/obj/machinery/power/solar_control/Destroy()
	for(var/obj/machinery/power/solar/M in connected_panels)
		M.unset_control()
	if(connected_tracker)
		connected_tracker.unset_control()
	return ..()

/obj/machinery/power/solar_control/disconnect_from_network()
	..()
	SSsun.solars.Remove(src)

/obj/machinery/power/solar_control/connect_to_network()
	var/to_return = ..()
	if(powernet) //if connected and not already in solar list...
		SSsun.solars |= src //... add it
	return to_return

//search for unconnected panels and trackers in the computer powernet and connect them
/obj/machinery/power/solar_control/proc/search_for_connected()
	if(powernet)
		for(var/obj/machinery/power/M in powernet.nodes)
			if(istype(M, /obj/machinery/power/solar))
				var/obj/machinery/power/solar/S = M
				if(!S.control) //i.e unconnected
					S.set_control(src)
			else if(istype(M, /obj/machinery/power/tracker))
				if(!connected_tracker) //if there's already a tracker connected to the computer don't add another
					var/obj/machinery/power/tracker/T = M
					if(!T.control) //i.e unconnected
						T.set_control(src)

//called by the sun controller, update the facing angle (either manually or via tracking) and rotates the panels accordingly
/obj/machinery/power/solar_control/proc/update()
	if(stat & (NOPOWER | BROKEN))
		return

	if(track == TRACKER_AUTO && connected_tracker) // auto-tracking
		connected_tracker.modify_angle(SSsun.angle)
		set_panels(cdir)
	updateDialog()

/obj/machinery/power/solar_control/update_overlays()
	. = ..()
	if(stat & NOPOWER)
		. += "[icon_keyboard]_off"
		return
	. += icon_keyboard
	if(stat & BROKEN)
		. += "[icon_state]_broken"
	else
		. += icon_screen

/obj/machinery/power/solar_control/attack_ai(mob/user as mob)
	add_hiddenprint(user)
	ui_interact(user)

/obj/machinery/power/solar_control/attack_ghost(mob/user as mob)
	ui_interact(user)

/obj/machinery/power/solar_control/attack_hand(mob/user)
	if(..(user))
		return TRUE
	if(stat & BROKEN)
		return
	ui_interact(user)

/obj/machinery/power/solar_control/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/power/solar_control/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SolarControl", name)
		ui.open()

/obj/machinery/power/solar_control/ui_data(mob/user)
	var/list/data = list()
	data["generated"] = round(lastgen) //generated power by all connected panels
	data["generated_ratio"] = data["generated"] / round(max(length(connected_panels), 1) * SSsun.solar_gen_rate) //power generation ratio. Used for the power bar
	data["direction"] = angle2text(cdir)	//current orientation of the panels
	data["cdir"] = cdir	//current orientation of the of the panels in degrees
	data["tracking_state"] = track	//tracker status: TRACKER_OFF, TRACKER_TIMED, TRACKER_AUTO
	data["tracking_rate"] = trackrate //rotation speed of tracker in degrees/h
	data["rotating_direction"] = (trackrate < 0 ? "Counter clockwise" : "Clockwise") //direction of tracker
	data["connected_panels"] = length(connected_panels)
	data["connected_tracker"] = (connected_tracker ? TRUE : FALSE)
	return data

/obj/machinery/power/solar_control/ui_act(action, params)
	if(..())
		return
	. = TRUE

	switch(action)
		if("cdir") //change panel orientation
			var/newAngle = text2num(params["cdir"])
			if(!isnull(newAngle)) //0 is ok
				cdir = clamp(newAngle, 0, 359)
				targetdir = cdir
				set_panels(cdir)
		if("tdir") //change tracker rotation
			var/newTrackrate = text2num(params["tdir"])
			if(!newTrackrate)
				newTrackrate = 1
			trackrate = clamp(newTrackrate, -7200, 7200)
			nexttime = world.time + 36000 / abs(trackrate)
		if("track") //change tracker status
			track = text2num(params["track"])
			if(track == TRACKER_AUTO)
				if(connected_tracker)
					connected_tracker.modify_angle(SSsun.angle)
					set_panels(cdir)
			else if(track == TRACKER_TIMED)
				targetdir = cdir
				if(trackrate)
					nexttime = world.time + 36000 / abs(trackrate)
				set_panels(targetdir)
		if("refresh")
			search_for_connected()
			if(connected_tracker && track == TRACKER_AUTO)
				connected_tracker.modify_angle(SSsun.angle)
			set_panels(cdir)

/obj/machinery/power/solar_control/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if(!I.use_tool(src, user, 20, volume = I.tool_volume))
		return
	var/obj/structure/computerframe/A = new /obj/structure/computerframe(loc)
	var/obj/item/circuitboard/solar_control/M = new /obj/item/circuitboard/solar_control(A)
	for(var/obj/C in src)
		C.forceMove(loc)
	if(stat & BROKEN)
		to_chat(user, "<span class='notice'>The broken glass falls out.</span>")
		A.state = 4	// STATE_WIRES
		new /obj/item/shard(drop_location())
	else
		to_chat(user, "<span class='notice'>You disconnect the monitor.</span>")
		A.state = 5	// STATE_GLASS
	A.dir = dir
	A.circuit = M
	A.update_icon()
	A.anchored = TRUE
	qdel(src)

/obj/machinery/power/solar_control/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(stat & BROKEN)
				playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 70, TRUE)
			else
				playsound(src.loc, 'sound/effects/glasshit.ogg', 75, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/machinery/power/solar_control/obj_break(damage_flag)
	if(!(stat & BROKEN) && !(flags & NODECONSTRUCT))
		playsound(loc, 'sound/effects/glassbr3.ogg', 100, TRUE)
		stat |= BROKEN
		update_icon()

/obj/machinery/power/solar_control/process()
	lastgen = gen
	gen = 0

	if(stat & (NOPOWER | BROKEN))
		return

	if(connected_tracker && connected_tracker.powernet != powernet) //NOTE : handled here so that we don't add trackers to the processing list
		connected_tracker.unset_control()

	//manual tracking and set a rotation speed
	if(track == TRACKER_TIMED && trackrate && nexttime <= world.time) //every time we need to increase/decrease the angle by 1?...
		targetdir = (targetdir + trackrate / abs(trackrate) + 360) % 360 	//... do it
		nexttime += 36000 / abs(trackrate) //reset the counter for the next 1?
		cdir = targetdir
		set_panels(cdir)

//rotates the panel to the passed angle
/obj/machinery/power/solar_control/proc/set_panels(cdir)

	for(var/obj/machinery/power/solar/S in connected_panels)
		S.adir = cdir //instantly rotates the panel
		S.occlusion()//and
		S.update_icon(UPDATE_OVERLAYS) //update it

	update_icon()


/obj/machinery/power/solar_control/power_change()
	if(!..())
		return
	update_icon()


/obj/machinery/power/solar_control/proc/broken()
	stat |= BROKEN
	update_icon()

//
// MISC
//

/obj/item/paper/solar
	name = "paper- 'Going green! Setup your own solar array instructions.'"
	info = "<h1>Welcome</h1><p>At greencorps we love the environment, and space. With this package you are able to help mother nature and produce energy without any usage of fossil fuel or plasma! Singularity energy is dangerous while solar energy is safe, which is why it's better. Now here is how you setup your own solar array.</p><p>You can make a solar panel by wrenching the solar assembly onto a cable node. Adding a glass panel, reinforced or regular glass will do, will finish the construction of your solar panel. It is that easy!</p><p>Now after setting up 19 more of these solar panels you will want to create a solar tracker to keep track of our mother nature's gift, the sun. These are the same steps as before except you insert the tracker equipment circuit into the assembly before performing the final step of adding the glass. You now have a tracker! Now the last step is to add a computer to calculate the sun's movements and to send commands to the solar panels to change direction with the sun. Setting up the solar computer is the same as setting up any computer, so you should have no trouble in doing that. You do need to put a wire node under the computer, and the wire needs to be connected to the tracker.</p><p>Congratulations, you should have a working solar array. If you are having trouble, here are some tips. Make sure all solar equipment are on a cable node, even the computer. You can always deconstruct your creations if you make a mistake.</p><p>That's all to it, be safe, be green!</p>"

#undef TRACKER_OFF
#undef TRACKER_TIMED
#undef TRACKER_AUTO

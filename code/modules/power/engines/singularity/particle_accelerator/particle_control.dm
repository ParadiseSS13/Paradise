#define PARTICLE_LEFT 1
#define PARTICLE_CENTER 2
#define PARTICLE_RIGHT 3
#define EMITTER 1
#define POWER_BOX 2
#define FUEL_CHAMBER 3
#define END_CAP 4


/obj/machinery/particle_accelerator/control_box
	name = "Particle Accelerator Control Console"
	desc = "This part controls the density of the particles."
	icon_state = "control_box"
	reference = "control_box"
	idle_power_consumption = 500
	dir = 1
	var/strength_upper_limit = 2
	var/interface_control = 1
	var/list/obj/structure/particle_accelerator/connected_parts
	var/assembled = 0
	var/parts = null
	var/datum/wires/particle_accelerator/wires = null
	/// Layout of the particle accelerator. Used by the UI
	var/list/layout = list(
		list(list("name" = "EM Containment Grid Left", "icon_state" = "emitter_right", "status" = "", "dir" = "1"), list("name" = "Blank1", "icon_state" = "blank", "status" = "good", "dir" = "1"), list("name" = "Blank2", "icon_state" = "blank", "status" = "good", "dir" = "1"), list("name" = "Blank3", "icon_state" = "blank", "status" = "good", "dir" = "1")),
		list(list("name" = "EM Containment Grid Center", "icon_state" = "emitter_center", "status" = "", "dir" = "1"), list("name" = "Particle Focusing EM Lens", "icon_state" = "power_box", "status" = "", "dir" = "1"), list("name" = "EM Acceleration Chamber", "icon_state" = "fuel_chamber", "status" = "", "dir" = "1"), list("name" = "Alpha Particle Generation Array", "icon_state" = "end_cap", "status" = "", "dir" = "1")),
		list(list("name" = "EM Containment Grid Right", "icon_state" = "emitter_left", "status" = "", "dir" = "1"), list("name" = "Blank4", "icon_state" = "blank", "status" = "good", "dir" = "1"), list("name" = "Blank5", "icon_state" = "blank", "status" = "good", "dir" = "1"), list("name" = "Blank6", "icon_state" = "blank", "status" = "good", "dir" = "1")))
	/// The expected orientation of the accelerator this is trying to link. In text form so the UI can use it
	var/dir_text

/obj/machinery/particle_accelerator/control_box/Initialize(mapload)
	. = ..()
	wires = new(src)
	connected_parts = list()
	update_icon()

/obj/machinery/particle_accelerator/control_box/Destroy()
	SStgui.close_uis(wires)
	if(active)
		toggle_power()
	QDEL_NULL(wires)
	return ..()

/obj/machinery/particle_accelerator/control_box/attack_ghost(user as mob)
	return attack_hand(user)

/obj/machinery/particle_accelerator/control_box/attack_hand(mob/user as mob)
	if(construction_state >= 3)
		ui_interact(user)
	else if(construction_state == 2) // Wires exposed
		wires.Interact(user)

/obj/machinery/particle_accelerator/control_box/multitool_act(mob/living/user, obj/item/I)
	if(construction_state == 2) // Wires exposed
		wires.Interact(user)
		return TRUE

/obj/machinery/particle_accelerator/control_box/update_state()
	if(construction_state < 3)
		change_power_mode(NO_POWER_USE)
		assembled = 0
		active = FALSE
		for(var/obj/structure/particle_accelerator/part in connected_parts)
			part.strength = null
			part.powered = FALSE
			part.update_icon()
		connected_parts = list()
		return
	if(!part_scan())
		change_power_mode(IDLE_POWER_USE)
		active = FALSE
		connected_parts = list()

	return

/obj/machinery/particle_accelerator/control_box/update_icon_state()
	if(active)
		icon_state = "[reference]p[strength]"
	else
		if(stat & NOPOWER)
			icon_state = "[reference]w"
			return
		else if(power_state && assembled)
			icon_state = "[reference]p"
		else
			switch(construction_state)
				if(0)
					icon_state = "[reference]"
				if(1)
					icon_state = "[reference]"
				if(2)
					icon_state = "[reference]w"
				else
					icon_state = "[reference]c"

/obj/machinery/particle_accelerator/control_box/proc/strength_change()
	for(var/obj/structure/particle_accelerator/part in connected_parts)
		part.strength = strength
		part.update_icon()

/obj/machinery/particle_accelerator/control_box/proc/add_strength(s)
	if(assembled)
		strength++
		if(strength > strength_upper_limit)
			strength = strength_upper_limit
		else
			message_admins("PA Control Computer increased to [strength] by [key_name_admin(usr)] in ([x],[y],[z] - <A href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
			log_game("PA Control Computer increased to [strength] by [key_name(usr)] in ([x],[y],[z])")
			investigate_log("increased to <font color='red'>[strength]</font> by [key_name(usr)]",INVESTIGATE_SINGULO)

			investigate_log("increased to <font color='red'>[strength]</font> by [usr.key]",INVESTIGATE_SINGULO)
		strength_change()

/obj/machinery/particle_accelerator/control_box/proc/remove_strength(s)
	if(assembled)
		strength--
		if(strength < 0)
			strength = 0
		else
			message_admins("PA Control Computer decreased to [strength] by [key_name_admin(usr)] in ([x],[y],[z] - <A href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
			log_game("PA Control Computer decreased to [strength] by [key_name(usr)] in ([x],[y],[z])")
			investigate_log("decreased to <font color='green'>[strength]</font> by [key_name(usr)]",INVESTIGATE_SINGULO)

		strength_change()

/obj/machinery/particle_accelerator/control_box/power_change()
	..()
	if(stat & NOPOWER)
		active = FALSE
		change_power_mode(NO_POWER_USE)
	else if(!stat && construction_state <= 3)
		change_power_mode(IDLE_POWER_USE)
	update_icon()

	if((stat & NOPOWER) || (!stat && construction_state <= 3)) //Only update the part icons if something's changed (i.e. any of the above condition sets are met).
		for(var/obj/structure/particle_accelerator/part in connected_parts)
			part.strength = null
			part.powered = FALSE
			part.update_icon()
	return


/obj/machinery/particle_accelerator/control_box/process()
	if(active)
		//a part is missing!
		if(length(connected_parts) < 6)
			investigate_log("lost a connected part; It <font color='red'>powered down</font>.",INVESTIGATE_SINGULO)
			toggle_power()
			return
		//emit some particles
		for(var/obj/structure/particle_accelerator/particle_emitter/PE in connected_parts)
			if(PE)
				PE.emit_particle(strength)
	return


/obj/machinery/particle_accelerator/control_box/proc/part_scan()
	dir_text = null
	var/turf/T
	for(var/obj/structure/particle_accelerator/fuel_chamber/F in orange(1,src))
		dir = F.dir
		T = F.loc

	if(!T)
		return 0

	dir_text = dir2text(dir) // Only set dir_text if we found an EM acceleration chamber

	connected_parts = list()
	var/tally = 0
	var/ldir = turn(dir,-90)
	var/rdir = turn(dir,90)
	var/odir = turn(dir,180)
	if(check_part(T,/obj/structure/particle_accelerator/fuel_chamber, PARTICLE_CENTER, FUEL_CHAMBER))
		tally++
		layout[PARTICLE_CENTER][FUEL_CHAMBER]["status"] = "good"
	T = get_step(T,odir)
	if(check_part(T,/obj/structure/particle_accelerator/end_cap, PARTICLE_CENTER, END_CAP))
		tally++
		layout[PARTICLE_CENTER][END_CAP]["status"] = "good"
	T = get_step(T,dir)
	T = get_step(T,dir)
	if(check_part(T,/obj/structure/particle_accelerator/power_box, PARTICLE_CENTER, POWER_BOX))
		tally++
		layout[PARTICLE_CENTER][POWER_BOX]["status"] = "good"
	T = get_step(T,dir)
	if(check_part(T,/obj/structure/particle_accelerator/particle_emitter/center, PARTICLE_CENTER, EMITTER))
		tally++
		layout[PARTICLE_CENTER][EMITTER]["status"] = "good"
	T = get_step(T,ldir)
	if(check_part(T,/obj/structure/particle_accelerator/particle_emitter/left, PARTICLE_LEFT, EMITTER))
		tally++
		layout[PARTICLE_LEFT][EMITTER]["status"] = "good"
	T = get_step(T,rdir)
	T = get_step(T,rdir)
	if(check_part(T,/obj/structure/particle_accelerator/particle_emitter/right, PARTICLE_RIGHT, EMITTER))
		tally++
		layout[PARTICLE_RIGHT][EMITTER]["status"] = "good"
	if(tally >= 6)
		assembled = 1
		return 1
	else
		assembled = 0
		return 0

/obj/machinery/particle_accelerator/control_box/proc/check_part(turf/T, type, column, row)
	if(!(T)||!(type))
		return 0
	var/obj/structure/particle_accelerator/PA = locate(/obj/structure/particle_accelerator) in T
	if(istype(PA, type))
		if(PA.connect_master(src))
			if(PA.report_ready(src))
				connected_parts.Add(PA)
				return 1
			else if(PA)
				layout[column][row]["status"] = "Incomplete"
		else if(PA)
			layout[column][row]["status"] =  "Wrong Orientation"

		layout[column][row]["dir"] = PA.dir
		layout[column][row]["icon_state"] = PA.icon_state
	else
		layout[column][row]["status"] =  "Not In Position"

	return 0

/obj/machinery/particle_accelerator/control_box/proc/toggle_power()
	active = !active
	investigate_log("turned [active?"<font color='red'>ON</font>":"<font color='green'>OFF</font>"] by [usr ? usr.key : "outside forces"]",INVESTIGATE_SINGULO)
	if(active)
		msg_admin_attack("PA Control Computer turned ON by [key_name_admin(usr)]", ATKLOG_FEW)
		usr.create_log(MISC_LOG, "PA Control Computer turned ON", src)
		log_game("PA Control Computer turned ON by [key_name(usr)] in ([x],[y],[z])")
	if(active)
		change_power_mode(ACTIVE_POWER_USE)
		for(var/obj/structure/particle_accelerator/part in connected_parts)
			part.strength = strength
			part.powered = TRUE
			part.update_icon()
	else
		change_power_mode(IDLE_POWER_USE)
		for(var/obj/structure/particle_accelerator/part in connected_parts)
			part.strength = null
			part.powered = FALSE
			part.update_icon()
	return 1

/obj/machinery/particle_accelerator/control_box/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/particle_accelerator/control_box/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ParticleAccelerator", name)
		ui.open()

/obj/machinery/particle_accelerator/control_box/ui_data(mob/user)
	var/list/data = list()
	var/list/ui_col_1 = list()
	var/list/ui_col_2 = list()
	var/list/ui_col_3 = list()
	if(dir == NORTH || dir == WEST)
		ui_col_1 = layout[PARTICLE_RIGHT]
		ui_col_2 = layout[PARTICLE_CENTER]
		ui_col_3 = layout[PARTICLE_LEFT]
	else // If we are pointing east or south we need to reverse the order of the lists
		var/len = length(layout[PARTICLE_CENTER])
		for(var/i in 0 to (len - 1))
			ui_col_1.Add(list(layout[PARTICLE_RIGHT][len - i]))
			ui_col_2.Add(list(layout[PARTICLE_CENTER][len - i]))
			ui_col_3.Add(list(layout[PARTICLE_LEFT][len - i]))

	data["assembled"] = assembled
	data["power"] = active
	data["strength"] = strength
	data["max_strength"] = strength_upper_limit
	// If we are pointing east or south we need to reverse the order of the columns/rows
	data["layout_1"] = ui_col_1
	data["layout_2"] = ui_col_2
	data["layout_3"] = ui_col_3
	data["orientation"] = dir_text ? dir_text : FALSE
	data["icon"] = icon
	return data

/obj/machinery/particle_accelerator/control_box/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	if(!interface_control)
		to_chat(usr, "<span class='error'>ERROR: Request timed out. Check wire contacts.</span>")
		return

	switch(action)
		if("power")
			if(wires.is_cut(WIRE_PARTICLE_POWER))
				return
			toggle_power()
			. = TRUE
		if("scan")
			part_scan()
			. = TRUE
		if("add_strength")
			if(wires.is_cut(WIRE_PARTICLE_STRENGTH))
				return
			add_strength()
			. = TRUE
		if("remove_strength")
			if(wires.is_cut(WIRE_PARTICLE_STRENGTH))
				return
			remove_strength()
			. = TRUE

	if(.)
		update_icon()

#undef PARTICLE_LEFT
#undef PARTICLE_CENTER
#undef PARTICLE_RIGHT
#undef EMITTER
#undef POWER_BOX
#undef FUEL_CHAMBER
#undef END_CAP

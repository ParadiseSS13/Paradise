/obj/structure/door_assembly
	icon = 'icons/obj/doors/door_assembly.dmi'
	name = "airlock assembly"
	icon_state = "door_as_0"
	anchored = 0
	density = 1
	var/state = 0
	var/base_icon_state = ""
	var/base_name = "airlock"
	var/obj/item/weapon/airlock_electronics/electronics = null
	var/airlock_type = "" //the type path of the airlock once completed
	var/glass_type = "/glass"
	var/glass = 0 // 0 = glass can be installed. -1 = glass can't be installed. 1 = glass is already installed. Text = mineral plating is installed instead.
	var/created_name = null
	var/heat_proof_finished = 0 //whether to heat-proof the finished airlock
	var/material_type = /obj/item/stack/sheet/metal
	var/material_amt = 4

/obj/structure/door_assembly/New()
	update_state()

/obj/structure/door_assembly/Destroy()
	QDEL_NULL(electronics)
	return ..()

/obj/structure/door_assembly/door_assembly_com
	name = "command airlock assembly"
	base_icon_state = "com"
	base_name = "command airlock"
	glass_type = "/glass_command"
	airlock_type = "/command"

/obj/structure/door_assembly/door_assembly_sec
	name = "security airlock assembly"
	base_icon_state = "sec"
	base_name = "security airlock"
	glass_type = "/glass_security"
	airlock_type = "/security"

/obj/structure/door_assembly/door_assembly_eng
	name = "engineering airlock assembly"
	base_icon_state = "eng"
	base_name = "engineering airlock"
	glass_type = "/glass_engineering"
	airlock_type = "/engineering"

/obj/structure/door_assembly/door_assembly_min
	name = "mining airlock assembly"
	base_icon_state = "min"
	base_name = "mining airlock"
	glass_type = "/glass_mining"
	airlock_type = "/mining"

/obj/structure/door_assembly/door_assembly_atmo
	name = "atmospherics airlock assembly"
	base_icon_state = "atmo"
	base_name = "atmospherics airlock"
	glass_type = "/glass_atmos"
	airlock_type = "/atmos"

/obj/structure/door_assembly/door_assembly_research
	name = "research airlock assembly"
	base_icon_state = "res"
	base_name = "research airlock"
	glass_type = "/glass_research"
	airlock_type = "/research"

/obj/structure/door_assembly/door_assembly_science
	name = "science airlock assembly"
	base_icon_state = "sci"
	base_name = "science airlock"
	glass_type = "/glass_science"
	airlock_type = "/science"

/obj/structure/door_assembly/door_assembly_med
	name = "medical airlock assembly"
	base_icon_state = "med"
	base_name = "medical airlock"
	glass_type = "/glass_medical"
	airlock_type = "/medical"

/obj/structure/door_assembly/door_assembly_mai
	name = "maintenance airlock assembly"
	base_icon_state = "mai"
	base_name = "maintenance airlock"
	airlock_type = "/maintenance"
	glass = -1

/obj/structure/door_assembly/door_assembly_ext
	name = "external airlock assembly"
	base_icon_state = "ext"
	base_name = "external airlock"
	airlock_type = "/external"
	glass = -1

/obj/structure/door_assembly/door_assembly_fre
	name = "freezer airlock assembly"
	base_icon_state = "fre"
	base_name = "freezer airlock"
	airlock_type = "/freezer"
	glass = -1

/obj/structure/door_assembly/door_assembly_hatch
	name = "airtight hatch assembly"
	base_icon_state = "hatch"
	base_name = "airtight hatch"
	airlock_type = "/hatch"
	glass = -1

/obj/structure/door_assembly/door_assembly_mhatch
	name = "maintenance hatch assembly"
	base_icon_state = "mhatch"
	base_name = "maintenance hatch"
	airlock_type = "/maintenance_hatch"
	glass = -1

/obj/structure/door_assembly/door_assembly_highsecurity
	name = "high security airlock assembly"
	base_icon_state = "highsec"
	base_name = "high security airlock"
	airlock_type = "/highsecurity"
	glass = -1
	material_type = /obj/item/stack/sheet/plasteel

/obj/structure/door_assembly/door_assembly_vault
	name = "vault door assembly"
	base_icon_state = "vault"
	base_name = "vault door"
	airlock_type = "/vault"
	glass = -1
	material_type = /obj/item/stack/sheet/plasteel

/obj/structure/door_assembly/door_assembly_shuttle
	name = "shuttle airlock assembly"
	base_icon_state = "shuttle"
	base_name = "shuttle airlock"
	airlock_type = "/shuttle"
	glass = -1

/obj/structure/door_assembly/multi_tile
	icon = 'icons/obj/doors/door_assembly2x1.dmi'
	dir = EAST
	var/width = 1
	base_icon_state = "g" //Remember to delete this line when reverting "glass" var to 1.
	airlock_type = "/multi_tile/glass"
	glass = -1 //To prevent bugs in deconstruction process.

/obj/structure/door_assembly/multi_tile/New()
	if(dir in list(EAST, WEST))
		bound_width = width * world.icon_size
		bound_height = world.icon_size
	else
		bound_width = world.icon_size
		bound_height = width * world.icon_size
	update_state()

/obj/structure/door_assembly/multi_tile/Move()
	. = ..()
	if(dir in list(EAST, WEST))
		bound_width = width * world.icon_size
		bound_height = world.icon_size
	else
		bound_width = world.icon_size
		bound_height = width * world.icon_size

/obj/structure/door_assembly/door_assembly_cult
	icon = 'icons/obj/doors/Doorcult.dmi'
	base_icon_state = "construction"
	base_name = "engraved airlock"
	airlock_type = "/cult"
	glass = -1

/obj/structure/door_assembly/door_assembly_cultruned
	icon = 'icons/obj/doors/Doorcultruned.dmi'
	base_icon_state = "construction"
	base_name = "runed airlock"
	airlock_type = "/cult/runed"
	glass = -1

/obj/structure/door_assembly/door_assembly_centcom
	base_icon_state = "ele"
	airlock_type = "/centcom"
	glass = -1

/obj/structure/door_assembly/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/weapon/pen))
		var/t = copytext(stripped_input(user, "Enter the name for the door.", name, created_name),1,MAX_NAME_LEN)
		if(!t)
			return
		if(!in_range(src, usr) && loc != usr)
			return
		created_name = t
		return

	if(iswelder(W) && ((istext(glass)) || (glass == 1) || !anchored ))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0, user))
			playsound(loc, WT.usesound, 50, 1)
			if(istext(glass))
				user.visible_message("[user] welds the [glass] plating off the airlock assembly.", "You start to weld the [glass] plating off the airlock assembly...")
				if(do_after(user, 40 * WT.toolspeed, target = src))
					if(!src || !WT.isOn())
						return
					to_chat(user, "<span class='notice'>You weld the [glass] plating off.</span>")
					var/M = text2path("/obj/item/stack/sheet/mineral/[glass]")
					new M(loc, 2)
					glass = 0
			else if(glass == 1)
				user.visible_message("[user] welds the glass panel out of the airlock assembly.", "You start to weld the glass panel out of the airlock assembly...")
				if(do_after(user, 40 * WT.toolspeed, target = src))
					if(!src || !WT.isOn())
						return
					to_chat(user, "<span class='notice'>You weld the glass panel out.</span>")
					if(heat_proof_finished)
						new /obj/item/stack/sheet/rglass(get_turf(src))
						heat_proof_finished = 0
					else
						new /obj/item/stack/sheet/glass(get_turf(src))
					glass = 0
			else if(!anchored)
				user.visible_message("[user] disassembles the airlock assembly.", "You start to disassemble the airlock assembly...")
				if(do_after(user, 40 * WT.toolspeed, target = src))
					if(!src || !WT.isOn())
						return
					to_chat(user, "<span class='notice'>You disassemble the airlock assembly.</span>")
					new material_type(loc, material_amt)
					qdel(src)
		else
			to_chat(user, "<span class='notice'>You need more welding fuel.</span>")
			return

	else if(iswrench(W) && state == 0)
		playsound(loc, W.usesound, 100, 1)
		if(anchored)
			user.visible_message("[user] unsecures the airlock assembly from the floor.", "You start to unsecure the airlock assembly from the floor...")
		else
			user.visible_message("[user] secures the airlock assembly to the floor.", "You start to secure the airlock assembly to the floor...")

		if(do_after(user, 40 * W.toolspeed, target = src))
			if(!src)
				return
			to_chat(user, "<span class='notice'>You [anchored ? "un" : ""]secure the airlock assembly.</span>")
			anchored = !anchored

	else if(iscoil(W) && state == 0 && anchored)
		var/obj/item/stack/cable_coil/coil = W
		user.visible_message("[user] wires the airlock assembly.", "You start to wire the airlock assembly...")
		if(do_after(user, 40 * coil.toolspeed, target = src))
			if(!src)
				return
			coil.use(1)
			state = 1
			to_chat(user, "<span class='notice'>You wire the airlock assembly.</span>")

	else if(iswirecutter(W) && state == 1)
		playsound(loc, W.usesound, 100, 1)
		user.visible_message("[user] cuts the wires from the airlock assembly.", "You start to cut the wires from airlock assembly...")

		if(do_after(user, 40 * W.toolspeed, target = src))
			if(!src)
				return
			to_chat(user, "<span class='notice'>You cut the wires from the airlock assembly.</span>")
			if(state == 1)
				new/obj/item/stack/cable_coil(loc, 1)
			state = 0

	else if(istype(W, /obj/item/weapon/airlock_electronics) && state == 1 && W.icon_state != "door_electronics_smoked")
		playsound(loc, W.usesound, 100, 1)
		user.visible_message("[user] installs the electronics into the airlock assembly.", "You start to install electronics into the airlock assembly...")

		if(do_after(user, 40 * W.toolspeed, target = src))
			if(!src)
				return
			user.drop_item()
			W.loc = src
			to_chat(user, "<span class='notice'>You install the airlock electronics.</span>")
			state = 2
			name = "near finished airlock assembly"
			electronics = W

	else if(iscrowbar(W) && state == 2 )
		playsound(loc, W.usesound, 100, 1)
		user.visible_message("[user] removes the electronics from the airlock assembly.", "You start to remove electronics from the airlock assembly...")

		if(do_after(user, 40 * W.toolspeed, target = src))
			if(!src)
				return
			to_chat(user, "<span class='notice'>You remove the airlock electronics.</span>")
			state = 1
			name = "wired airlock assembly"
			var/obj/item/weapon/airlock_electronics/ae
			if(!electronics)
				ae = new/obj/item/weapon/airlock_electronics(loc)
			else
				ae = electronics
				electronics = null
				ae.loc = loc

	else if(istype(W, /obj/item/stack/sheet) && !glass)
		var/obj/item/stack/sheet/S = W
		if(S)
			if(S.amount>=1)
				if(istype(S, /obj/item/stack/sheet/rglass) || istype(S, /obj/item/stack/sheet/glass))
					playsound(loc, S.usesound, 100, 1)
					user.visible_message("[user] adds [S.name] to the airlock assembly.", "You start to install [S.name] into the airlock assembly...")
					if(do_after(user, 40 * S.toolspeed, target = src))
						if(S.type == /obj/item/stack/sheet/rglass)
							to_chat(user, "<span class='notice'>You install reinforced glass windows into the airlock assembly.</span>")
							heat_proof_finished = 1 //reinforced glass makes the airlock heat-proof
						else
							to_chat(user, "<span class='notice'>You install regular glass windows into the airlock assembly.</span>")
						S.use(1)
						glass = 1
				else if(istype(S, /obj/item/stack/sheet/mineral) && S.sheettype)
					var/M = S.sheettype
					if(S.amount>=2)
						playsound(loc, S.usesound, 100, 1)
						user.visible_message("[user] adds [S.name] to the airlock assembly.", "You start to install [S.name] into the airlock assembly...")
						if(do_after(user, 40 * S.toolspeed, target = src))
							to_chat(user, "<span class='notice'>You install [M] plating into the airlock assembly.</span>")
							S.use(2)
							glass = "[M]"

	else if(isscrewdriver(W) && state == 2 )
		playsound(loc, W.usesound, 100, 1)
		user.visible_message("[user] finishes the airlock.", \
							 "<span class='notice'>You start finishing the airlock...</span>")

		if(do_after(user, 40 * W.toolspeed, target = src))
			if(!src)
				return
			to_chat(user, "<span class='notice'>You finish the airlock.</span>")
			var/path
			if(istext(glass))
				path = text2path("/obj/machinery/door/airlock/[glass]")
			else if(glass == 1)
				path = text2path("/obj/machinery/door/airlock[glass_type]")
			else
				path = text2path("/obj/machinery/door/airlock[airlock_type]")
			var/obj/machinery/door/airlock/door = new path(loc)
			door.setDir(dir)
			door.assemblytype = type
			door.electronics = electronics
			door.heat_proof = heat_proof_finished
			if(electronics.one_access)
				door.req_access = null
				door.req_one_access = electronics.conf_access
			else
				door.req_access = electronics.conf_access
			if(created_name)
				door.name = created_name
			else
				door.name = "[istext(glass) ? "[glass] airlock" : base_name]"
			electronics.loc = door
			qdel(src)
	else
		..()
	update_state()

/obj/structure/door_assembly/proc/update_state()
	icon_state = "door_as_[glass == 1 ? "g" : ""][istext(glass) ? glass : base_icon_state][state]"
	name = ""
	switch(state)
		if(0)
			if(anchored)
				name = "secured "
		if(1)
			name = "wired "
		if(2)
			name = "near finished "
	name += "[heat_proof_finished ? "heat-proofed " : ""][glass == 1 ? "window " : ""][istext(glass) ? "[glass] airlock" : base_name] assembly"

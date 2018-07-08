/obj/structure/door_assembly
	name = "airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/public.dmi'
	icon_state = "construction"
	anchored = FALSE
	density = TRUE
	max_integrity = 200
	var/overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
	var/state = AIRLOCK_ASSEMBLY_NEEDS_WIRES
	var/mineral
	var/base_name = "airlock"
	var/obj/item/airlock_electronics/electronics
	var/airlock_type = /obj/machinery/door/airlock //the type path of the airlock once completed
	var/glass_type = /obj/machinery/door/airlock/glass
	var/glass = 0 // 0 = glass can be installed. 1 = glass is already installed.
	var/created_name
	var/heat_proof_finished = 0 //whether to heat-proof the finished airlock
	var/previous_assembly = /obj/structure/door_assembly
	var/noglass = FALSE //airlocks with no glass version, also cannot be modified with sheets
	var/material_type = /obj/item/stack/sheet/metal
	var/material_amt = 4

/obj/structure/door_assembly/New()
	update_icon()
	update_name()
	..()

/obj/structure/door_assembly/Destroy()
	QDEL_NULL(electronics)
	return ..()

/obj/structure/door_assembly/examine(mob/user)
	..()
	var/doorname = ""
	if(created_name)
		doorname = ", written on it is '[created_name]'"
	switch(state)
		if(AIRLOCK_ASSEMBLY_NEEDS_WIRES)
			if(anchored)
				to_chat(user, "<span class='notice'>The anchoring bolts are <b>wrenched</b> in place, but the maintenance panel lacks <i>wiring</i>.</span>")
			else
				to_chat(user, "<span class='notice'>The assembly is <b>welded together</b>, but the anchoring bolts are <i>unwrenched</i>.</span>")
		if(AIRLOCK_ASSEMBLY_NEEDS_ELECTRONICS)
			to_chat(user, "<span class='notice'>The maintenance panel is <b>wired</b>, but the circuit slot is <i>empty</i>.</span>")
		if(AIRLOCK_ASSEMBLY_NEEDS_SCREWDRIVER)
			to_chat(user, "<span class='notice'>The circuit is <b>connected loosely</b> to its slot, but the maintenance panel is <i>unscrewed and open</i>.</span>")
	if(!mineral && !glass && !noglass)
		to_chat(user, "<span class='notice'>There is a small <i>paper</i> placard on the assembly[doorname]. There are <i>empty</i> slots for glass windows and mineral covers.</span>")
	else if(!mineral && glass && !noglass)
		to_chat(user, "<span class='notice'>There is a small <i>paper</i> placard on the assembly[doorname]. There are <i>empty</i> slots for mineral covers.</span>")
	else if(mineral && !glass && !noglass)
		to_chat(user, "<span class='notice'>There is a small <i>paper</i> placard on the assembly[doorname]. There are <i>empty</i> slots for glass windows.</span>")
	else
		to_chat(user, "<span class='notice'>There is a small <i>paper</i> placard on the assembly[doorname].</span>")

/obj/structure/door_assembly/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/pen))
		var/t = copytext(stripped_input(user, "Enter the name for the door.", name, created_name),1,MAX_NAME_LEN)
		if(!t)
			return
		if(!in_range(src, usr) && loc != usr)
			return
		created_name = t
		return

	else if(iswelder(W) && (mineral || glass || !anchored ))
		var/obj/item/weldingtool/WT = W
		if(WT.remove_fuel(0, user))
			playsound(loc, WT.usesound, 50, 1)
			if(mineral)
				var/obj/item/stack/sheet/mineral/mineral_path = text2path("/obj/item/stack/sheet/mineral/[mineral]")
				user.visible_message("[user] welds the [mineral] plating off the airlock assembly.", "You start to weld the [mineral] plating off the airlock assembly...")
				if(do_after(user, 40 * WT.toolspeed, target = src))
					if(!src || !WT.isOn())
						return
					to_chat(user, "<span class='notice'>You weld the [mineral] plating off.</span>")
					new mineral_path(loc, 2)
					var/obj/structure/door_assembly/PA = new previous_assembly(loc)
					transfer_assembly_vars(src, PA)

			else if(glass)
				user.visible_message("[user] welds the glass panel out of the airlock assembly.", "You start to weld the glass panel out of the airlock assembly...")
				if(do_after(user, 40 * WT.toolspeed, target = src))
					if(!src || !WT.isOn())
						return
					to_chat(user, "<span class='notice'>You weld the glass panel out.</span>")
					if(heat_proof_finished)
						new /obj/item/stack/sheet/rglass(get_turf(src))
						heat_proof_finished = FALSE
					else
						new /obj/item/stack/sheet/glass(get_turf(src))
					glass = FALSE
			else if(!anchored)
				user.visible_message("<span class='warning'>[user] disassembles the airlock assembly.</span>", \
									"You start to disassemble the airlock assembly...")
				if(do_after(user, 40 * WT.toolspeed, target = src))
					if(!src || !WT.isOn())
						return
					to_chat(user, "<span class='notice'>You disassemble the airlock assembly.</span>")
					deconstruct(TRUE)
		else
			to_chat(user, "<span class='notice'>You need more welding fuel.</span>")
			return

	else if(iswrench(W) && state == AIRLOCK_ASSEMBLY_NEEDS_WIRES)
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

	else if(iscoil(W) && state == AIRLOCK_ASSEMBLY_NEEDS_WIRES && anchored)
		var/obj/item/stack/cable_coil/coil = W
		if(coil.get_amount() < 1)
			to_chat(user, "<span class='warning'>You need one length of cable to wire the airlock assembly!</span>")
			return
		user.visible_message("[user] wires the airlock assembly.", "You start to wire the airlock assembly...")
		if(do_after(user, 40 * coil.toolspeed, target = src))
			if(coil.get_amount() < 1 || state != AIRLOCK_ASSEMBLY_NEEDS_WIRES)
				return
			coil.use(1)
			state = AIRLOCK_ASSEMBLY_NEEDS_ELECTRONICS
			to_chat(user, "<span class='notice'>You wire the airlock assembly.</span>")

	else if(iswirecutter(W) && state == AIRLOCK_ASSEMBLY_NEEDS_ELECTRONICS)
		playsound(loc, W.usesound, 100, 1)
		user.visible_message("[user] cuts the wires from the airlock assembly.", "You start to cut the wires from airlock assembly...")

		if(do_after(user, 40 * W.toolspeed, target = src))
			if(state != AIRLOCK_ASSEMBLY_NEEDS_ELECTRONICS)
				return
			to_chat(user, "<span class='notice'>You cut the wires from the airlock assembly.</span>")
			new/obj/item/stack/cable_coil(get_turf(user), 1)
			state = AIRLOCK_ASSEMBLY_NEEDS_WIRES

	else if(istype(W, /obj/item/airlock_electronics) && state == AIRLOCK_ASSEMBLY_NEEDS_ELECTRONICS && W.icon_state != "door_electronics_smoked")
		playsound(loc, W.usesound, 100, 1)
		user.visible_message("[user] installs the electronics into the airlock assembly.", "You start to install electronics into the airlock assembly...")

		if(do_after(user, 40 * W.toolspeed, target = src))
			if(state != AIRLOCK_ASSEMBLY_NEEDS_ELECTRONICS)
				return
			user.drop_item()
			W.forceMove(src)
			to_chat(user, "<span class='notice'>You install the airlock electronics.</span>")
			state = AIRLOCK_ASSEMBLY_NEEDS_SCREWDRIVER
			name = "near finished airlock assembly"
			electronics = W

	else if(iscrowbar(W) && state == AIRLOCK_ASSEMBLY_NEEDS_SCREWDRIVER )
		playsound(loc, W.usesound, 100, 1)
		user.visible_message("[user] removes the electronics from the airlock assembly.", "You start to remove electronics from the airlock assembly...")

		if(do_after(user, 40 * W.toolspeed, target = src))
			if(state != AIRLOCK_ASSEMBLY_NEEDS_SCREWDRIVER)
				return
			to_chat(user, "<span class='notice'>You remove the airlock electronics.</span>")
			state = AIRLOCK_ASSEMBLY_NEEDS_ELECTRONICS
			name = "wired airlock assembly"
			var/obj/item/airlock_electronics/ae
			if(!electronics)
				ae = new/obj/item/airlock_electronics(loc)
			else
				ae = electronics
				electronics = null
				ae.forceMove(loc)

	else if(istype(W, /obj/item/stack/sheet) && (!glass || !mineral))
		var/obj/item/stack/sheet/S = W
		if(S)
			if(S.get_amount() >= 1)
				if(!noglass)
					if(!glass)
						if(istype(S, /obj/item/stack/sheet/rglass) || istype(S, /obj/item/stack/sheet/glass))
							playsound(loc, S.usesound, 100, 1)
							user.visible_message("[user] adds [S.name] to the airlock assembly.", "You start to install [S.name] into the airlock assembly...")
							if(do_after(user, 40 * S.toolspeed, target = src))
								if(S.get_amount() < 1 || glass)
									return
								if(S.type == /obj/item/stack/sheet/rglass)
									to_chat(user, "<span class='notice'>You install reinforced glass windows into the airlock assembly.</span>")
									heat_proof_finished = TRUE //reinforced glass makes the airlock heat-proof
								else
									to_chat(user, "<span class='notice'>You install regular glass windows into the airlock assembly.</span>")
								S.use(1)
								glass = TRUE
					if(!mineral)
						if(istype(S, /obj/item/stack/sheet/mineral) && S.sheettype)
							var/M = S.sheettype
							if(S.get_amount() >= 2)
								playsound(loc, S.usesound, 100, 1)
								user.visible_message("[user] adds [S.name] to the airlock assembly.", "You start to install [S.name] into the airlock assembly...")
								if(do_after(user, 40 * S.toolspeed, target = src))
									if(S.get_amount() < 2 || mineral)
										return
									to_chat(user, "<span class='notice'>You install [M] plating into the airlock assembly.</span>")
									S.use(2)
									var/mineralassembly = text2path("/obj/structure/door_assembly/door_assembly_[M]")
									var/obj/structure/door_assembly/MA = new mineralassembly(loc)
									transfer_assembly_vars(src, MA, TRUE)
							else
								to_chat(user, "<span class='warning'>You need at least two sheets to add a mineral cover!</span>")
					else
						to_chat(user, "<span class='warning'>You cannot add [S] to [src]!</span>")
				else
					to_chat(user, "<span class='warning'>You cannot add [S] to [src]!</span>")

	else if(isscrewdriver(W) && state == AIRLOCK_ASSEMBLY_NEEDS_SCREWDRIVER )
		playsound(loc, W.usesound, 100, 1)
		user.visible_message("[user] finishes the airlock.", \
							 "<span class='notice'>You start finishing the airlock...</span>")

		if(do_after(user, 40 * W.toolspeed, target = src))
			if(loc && state == AIRLOCK_ASSEMBLY_NEEDS_SCREWDRIVER)
				to_chat(user, "<span class='notice'>You finish the airlock.</span>")
				var/obj/machinery/door/airlock/door
				if(glass)
					door = new glass_type(loc)
				else
					door = new airlock_type(loc)
				door.setDir(dir)
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
					door.name = base_name
				door.previous_airlock = previous_assembly
				electronics.forceMove(door)
				qdel(src)
	else
		return ..()
	update_name()
	update_icon()

/obj/structure/door_assembly/update_icon()
	overlays.Cut()
	if(!glass)
		overlays += get_airlock_overlay("fill_construction", icon)
	else if(glass)
		overlays += get_airlock_overlay("glass_construction", overlays_file)
	overlays += get_airlock_overlay("panel_c[state+1]", overlays_file)

/obj/structure/door_assembly/proc/update_name()
	name = ""
	switch(state)
		if(AIRLOCK_ASSEMBLY_NEEDS_WIRES)
			if(anchored)
				name = "secured "
		if(AIRLOCK_ASSEMBLY_NEEDS_ELECTRONICS)
			name = "wired "
		if(AIRLOCK_ASSEMBLY_NEEDS_SCREWDRIVER)
			name = "near finished "
	name += "[heat_proof_finished ? "heat-proofed " : ""][glass ? "window " : ""][base_name] assembly"

/obj/structure/door_assembly/proc/transfer_assembly_vars(obj/structure/door_assembly/source, obj/structure/door_assembly/target, previous = FALSE)
	target.glass = source.glass
	target.heat_proof_finished = source.heat_proof_finished
	target.created_name = source.created_name
	target.state = source.state
	target.anchored = source.anchored
	if(previous)
		target.previous_assembly = source.type
	if(electronics)
		target.electronics = source.electronics
		source.electronics.forceMove(target)
	target.update_icon()
	target.update_name()
	qdel(source)

/obj/structure/door_assembly/deconstruct(disassembled = TRUE)
	if(can_deconstruct)
		var/turf/T = get_turf(src)
		if(!disassembled)
			material_amt = rand(2,4)
		new material_type(T, material_amt)
		if(glass)
			if(disassembled)
				if(heat_proof_finished)
					new /obj/item/stack/sheet/rglass(T)
				else
					new /obj/item/stack/sheet/glass(T)
			else
				new /obj/item/shard(T)
		if(mineral)
			var/obj/item/stack/sheet/mineral/mineral_path = text2path("/obj/item/stack/sheet/mineral/[mineral]")
			new mineral_path(T, 2)
	qdel(src)

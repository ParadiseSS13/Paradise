#define ASSEMBLY_UNBUILT		0 // Nothing done to it
#define ASSEMBLY_WRENCHED		1 // Wrenched in place
#define ASSEMBLY_WELDED		2 // Welded in place
#define ASSEMBLY_WIRED		3 // Wires attached (Upgradable now)
#define ASSEMBLY_BUILT		4 // Fully built (incl panel closed)

/obj/item/camera_assembly
	name = "camera assembly"
	desc = "A pre-fabricated security camera kit, ready to be assembled and mounted to a surface."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "cameracase"
	w_class = WEIGHT_CLASS_SMALL
	anchored = FALSE
	materials = list(MAT_METAL=400, MAT_GLASS=250)
	max_integrity = 150
	can_be_hit = TRUE
	//	Motion, EMP-Proof, X-Ray
	var/list/obj/item/possible_upgrades = list(/obj/item/assembly/prox_sensor, /obj/item/stack/sheet/mineral/plasma, /obj/item/analyzer)
	var/list/upgrades = list()
	var/state = ASSEMBLY_UNBUILT
	var/busy = FALSE


/obj/item/camera_assembly/Destroy()
	QDEL_LIST(upgrades)
	return ..()

/obj/item/camera_assembly/attackby(obj/item/I, mob/living/user, params)

	switch(state)
		if(ASSEMBLY_UNBUILT)
			// State 0
			if(iswrench(I) && isturf(loc))
				playsound(loc, I.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You wrench the assembly into place.</span>")
				anchored = 1
				state = ASSEMBLY_WRENCHED
				update_icon()
				auto_turn()
				return

		if(ASSEMBLY_WRENCHED)
			// State 1
			if(iswelder(I))
				if(weld(I, user))
					to_chat(user, "<span class='notice'>You weld the assembly securely into place.</span>")
					anchored = TRUE
					state = ASSEMBLY_WELDED
				return

			else if(iswrench(I))
				playsound(loc, I.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You unattach the assembly from it's place.</span>")
				anchored = FALSE
				update_icon()
				state = ASSEMBLY_UNBUILT
				return

		if(ASSEMBLY_WELDED)
			if(iscoil(I))
				var/obj/item/stack/cable_coil/C = I
				if(C.use(2))
					to_chat(user, "<span class='notice'>You add wires to the assembly.</span>")
					playsound(loc, I.usesound, 50, 1)
					state = ASSEMBLY_WIRED
				else
					to_chat(user, "<span class='warning'>You need 2 coils of wire to wire the assembly.</span>")
				return

			else if(iswelder(I))
				if(weld(I, user))
					to_chat(user, "<span class='notice'>You unweld the assembly from it's place.</span>")
					state = ASSEMBLY_WRENCHED
					anchored = TRUE
				return


		if(ASSEMBLY_WIRED)
			if(isscrewdriver(I))
				playsound(loc, I.usesound, 50, 1)

				var/input = strip_html(input(usr, "Which networks would you like to connect this camera to? Seperate networks with a comma. No Spaces!\nFor example: SS13,Security,Secret ", "Set Network", "SS13"))
				if(!input)
					to_chat(usr, "<span class='warning'>No input found please hang up and try your call again.</span>")
					return

				var/list/tempnetwork = splittext(input, ",")
				if(tempnetwork.len < 1)
					to_chat(usr, "<span class='warning'>No network found please hang up and try your call again.</span>")
					return

				var/area/camera_area = get_area(src)
				var/temptag = "[sanitize(camera_area.name)] ([rand(1, 999)])"
				input = strip_html(input(usr, "How would you like to name the camera?", "Set Camera Name", temptag))

				state = ASSEMBLY_BUILT
				var/obj/machinery/camera/C = new(loc)
				loc = C
				C.assembly = src

				C.auto_turn()

				C.network = uniquelist(tempnetwork)
				tempnetwork = difflist(C.network,GLOB.restricted_camera_networks)
				if(!tempnetwork.len) // Camera isn't on any open network - remove its chunk from AI visibility.
					cameranet.removeCamera(C)

				C.c_tag = input

				for(var/i = 5; i >= 0; i -= 1)
					var/direct = input(user, "Direction?", "Assembling Camera", null) in list("LEAVE IT", "NORTH", "EAST", "SOUTH", "WEST" )
					if(direct != "LEAVE IT")
						C.dir = text2dir(direct)
					if(i != 0)
						var/confirm = alert(user, "Is this what you want? Chances Remaining: [i]", "Confirmation", "Yes", "No")
						if(confirm == "Yes")
							break
				return

			else if(iswirecutter(I))
				new/obj/item/stack/cable_coil(get_turf(src), 2)
				playsound(loc, I.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You cut the wires from the circuits.</span>")
				state = ASSEMBLY_WELDED
				return

	// Upgrades!
	if(is_type_in_list(I, possible_upgrades) && !is_type_in_list(I, upgrades)) // Is a possible upgrade and isn't in the camera already.
		if(!user.unEquip(I))
			to_chat(user, "<span class='warning'>[I] is stuck!</span>")
			return
		to_chat(user, "<span class='notice'>You attach [I] into the assembly inner circuits.</span>")
		upgrades += I
		user.drop_item()
		I.loc = src
		return

	// Taking out upgrades
	else if(iscrowbar(I) && upgrades.len)
		var/obj/U = locate(/obj) in upgrades
		if(U)
			to_chat(user, "<span class='notice'>You unattach an upgrade from the assembly.</span>")
			playsound(loc, I.usesound, 50, 1)
			U.loc = get_turf(src)
			upgrades -= U
		return

	else
		return ..()

/obj/item/camera_assembly/update_icon()
	if(anchored)
		icon_state = "camera1"
	else
		icon_state = "cameracase"

/obj/item/camera_assembly/attack_hand(mob/user as mob)
	if(!anchored)
		..()

/obj/item/camera_assembly/proc/weld(obj/item/weldingtool/WT, mob/living/user)
	if(busy)
		return FALSE
	if(!WT.remove_fuel(0, user))
		return FALSE

	to_chat(user, "<span class='notice'>You start to weld the [src]...</span>")
	playsound(loc, WT.usesound, 50, 1)
	busy = TRUE
	if(do_after(user, 20 * WT.toolspeed, target = src))
		busy = FALSE
		if(!WT.isOn())
			return FALSE
		return TRUE
	busy = FALSE
	return FALSE

/obj/item/camera_assembly/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/metal(loc)
	qdel(src)


#undef ASSEMBLY_UNBUILT
#undef ASSEMBLY_WRENCHED
#undef ASSEMBLY_WELDED
#undef ASSEMBLY_WIRED
#undef ASSEMBLY_BUILT

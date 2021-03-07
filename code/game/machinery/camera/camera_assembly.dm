#define ASSEMBLY_UNBUILT		0 // Nothing done to it
#define ASSEMBLY_WRENCHED		1 // Wrenched in place
#define ASSEMBLY_WELDED		2 // Welded in place
#define ASSEMBLY_WIRED		3 // Wires attached (Upgradable now)
#define ASSEMBLY_BUILT		4 // Fully built (incl panel closed)
#define HEY_IM_WORKING_HERE	666 //So nobody can mess with the camera while we're inputting settings

/obj/item/camera_assembly
	name = "camera assembly"
	desc = "A pre-fabricated security camera kit, ready to be assembled and mounted to a surface."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "cameracase"
	w_class = WEIGHT_CLASS_SMALL
	anchored = FALSE
	materials = list(MAT_METAL=400, MAT_GLASS=250)
	//	Motion, EMP-Proof, X-Ray
	var/list/obj/item/possible_upgrades = list(/obj/item/assembly/prox_sensor, /obj/item/stack/sheet/mineral/plasma, /obj/item/analyzer)
	var/list/upgrades = list()
	var/state = ASSEMBLY_UNBUILT


/obj/item/camera_assembly/Destroy()
	QDEL_LIST(upgrades)
	return ..()

/obj/item/camera_assembly/attackby(obj/item/I, mob/living/user, params)
	if(state == ASSEMBLY_WELDED && iscoil(I))
		var/obj/item/stack/cable_coil/C = I
		if(C.use(2))
			to_chat(user, "<span class='notice'>You add wires to the assembly.</span>")
			playsound(loc, I.usesound, 50, 1)
			state = ASSEMBLY_WIRED
		else
			to_chat(user, "<span class='warning'>You need 2 coils of wire to wire the assembly.</span>")
		return

	// Upgrades!
	else if(is_type_in_list(I, possible_upgrades) && !is_type_in_list(I, upgrades)) // Is a possible upgrade and isn't in the camera already.
		if(!user.unEquip(I))
			to_chat(user, "<span class='warning'>[I] is stuck!</span>")
			return
		to_chat(user, "<span class='notice'>You attach [I] into the assembly inner circuits.</span>")
		upgrades += I
		user.drop_item()
		I.loc = src
		return
	else
		return ..()

/obj/item/camera_assembly/crowbar_act(mob/user, obj/item/I)
	if(!upgrades.len)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	var/obj/U = locate(/obj) in upgrades
	if(U)
		to_chat(user, "<span class='notice'>You unattach an upgrade from the assembly.</span>")
		playsound(loc, I.usesound, 50, 1)
		U.loc = get_turf(src)
		upgrades -= U

/obj/item/camera_assembly/screwdriver_act(mob/user, obj/item/I)
	if(state != ASSEMBLY_WIRED)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	state = HEY_IM_WORKING_HERE
	var/input = strip_html(input(usr, "Which networks would you like to connect this camera to? Seperate networks with a comma. No Spaces!\nFor example: SS13,Security,Secret ", "Set Network", "SS13"))
	if(!input)
		state = ASSEMBLY_WIRED
		to_chat(usr, "<span class='warning'>No input found please hang up and try your call again.</span>")
		return

	var/list/tempnetwork = splittext(input, ",")
	if(tempnetwork.len < 1)
		state = ASSEMBLY_WIRED
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
		GLOB.cameranet.removeCamera(C)

	C.c_tag = input

	for(var/i = 5; i >= 0; i -= 1)
		var/direct = input(user, "Direction?", "Assembling Camera", null) in list("LEAVE IT", "NORTH", "EAST", "SOUTH", "WEST" )
		if(direct != "LEAVE IT")
			C.dir = text2dir(direct)
		if(i != 0)
			var/confirm = alert(user, "Is this what you want? Chances Remaining: [i]", "Confirmation", "Yes", "No")
			if(confirm == "Yes")
				break


/obj/item/camera_assembly/wirecutter_act(mob/user, obj/item/I)
	if(state != ASSEMBLY_WIRED)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	new/obj/item/stack/cable_coil(get_turf(src), 2)
	WIRECUTTER_SNIP_MESSAGE
	state = ASSEMBLY_WELDED
	return

/obj/item/camera_assembly/wrench_act(mob/user, obj/item/I)
	if(state != ASSEMBLY_UNBUILT && state != ASSEMBLY_WRENCHED)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(state == ASSEMBLY_UNBUILT && isturf(loc))
		WRENCH_ANCHOR_TO_WALL_MESSAGE
		anchored = TRUE
		state = ASSEMBLY_WRENCHED
		update_icon()
		auto_turn()
	else if(state == ASSEMBLY_WRENCHED)
		WRENCH_UNANCHOR_WALL_MESSAGE
		anchored = FALSE
		update_icon()
		state = ASSEMBLY_UNBUILT
	else
		to_chat(user, "<span class='warning'>[src] can't fit here!</span>")

/obj/item/camera_assembly/welder_act(mob/user, obj/item/I)
	if(state == ASSEMBLY_UNBUILT)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	WELDER_ATTEMPT_WELD_MESSAGE
	if(state == ASSEMBLY_WRENCHED)
		if(!I.use_tool(src, user, 50, volume = I.tool_volume))
			return
		to_chat(user, "<span class='notice'>You weld [src] into place.</span>")
		state = ASSEMBLY_WELDED
	else if(state == ASSEMBLY_WELDED)
		if(!I.use_tool(src, user, 50, volume = I.tool_volume))
			return
		to_chat(user, "<span class='notice'>You unweld [src] from its place.</span>")
		state = ASSEMBLY_WRENCHED

/obj/item/camera_assembly/update_icon()
	if(anchored)
		icon_state = "camera1"
	else
		icon_state = "cameracase"

/obj/item/camera_assembly/attack_hand(mob/user as mob)
	if(!anchored)
		..()

/obj/item/camera_assembly/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal(loc)
	qdel(src)


#undef ASSEMBLY_UNBUILT
#undef ASSEMBLY_WRENCHED
#undef ASSEMBLY_WELDED
#undef ASSEMBLY_WIRED
#undef ASSEMBLY_BUILT
#undef HEY_IM_WORKING_HERE

///////////////////////////////////////////////
// The cable coil object, used for laying cable
///////////////////////////////////////////////

/obj/item/stack/cable_coil
	name = "cable coil"
	singular_name = "cable"
	icon = 'icons/obj/power.dmi'
	icon_state = "coil"
	item_state = "coil_red"
	belt_icon = "cable_coil"
	amount = MAXCOIL
	max_amount = MAXCOIL
	merge_type = /obj/item/stack/cable_coil // This is here to let its children merge between themselves
	throwforce = 10
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 2
	throw_range = 5
	materials = list(MAT_METAL = 15, MAT_GLASS = 10)
	flags = CONDUCT
	slot_flags = SLOT_BELT
	item_state = "coil"
	attack_verb = list("whipped", "lashed", "disciplined", "flogged")
	usesound = 'sound/items/deconstruct.ogg'
	toolspeed = 1

	/// The type path of cabling that this cable coil will create when used to construct cabling on turfs
	var/cable_structure_type = null

/obj/item/stack/cable_coil/Initialize(mapload)
	. = ..()
	pixel_x = rand(-2,2)
	pixel_y = rand(-2,2)
	update_icon()
	update_wclass()

/obj/item/stack/cable_coil/examine(mob/user)
	. = ..()
	if(!in_range(user, src) || is_cyborg)
		return
	if(get_amount() == 1)
		. += "A short piece of power cable."
	else if(get_amount() == 2)
		. += "A piece of power cable."
	else
		. += "A coil of power cables."

/obj/item/stack/cable_coil/split()
	var/obj/item/stack/cable_coil/C = ..()
	C.color = color
	return C

// Items usable on a cable coil :
//   - Wirecutters : cut them duh !
//   - Cable coil : merge cables
/obj/item/stack/cable_coil/attackby(obj/item/W, mob/user)
	. = ..()
	if(istype(W, type))
		var/obj/item/stack/cable_coil/C = W
		// Cable merging is handled by parent proc
		if(C.get_amount() >= MAXCOIL)
			to_chat(user, "The coil is as long as it will get.")
			return
		if((C.get_amount() + get_amount() <= MAXCOIL))
			to_chat(user, "You join the cable coils together.")
			return
		else
			to_chat(user, "You transfer [get_amount_transferred()] length\s of cable from one coil to the other.")
			return

/obj/item/stack/cable_coil/proc/update_wclass()
	return

///////////////////////////////////////////////
// Cable laying procedures
//////////////////////////////////////////////

/obj/item/stack/cable_coil/proc/get_new_cable(location, d2)
	var/obj/structure/cable/new_cable = new cable_structure_type(location)
	//set up the new cable
	new_cable.d2 = d2 //it's a O-X node cable by default
	new_cable.update_icon()
	return new_cable

/// Checks to see if cable to be placed can be placed on the target turf, if not, it returns FALSE, if it can, it returns TRUE
/obj/item/stack/cable_coil/proc/can_place(turf/T, mob/user, cable_direction)
	if(!isturf(user.loc))
		return FALSE
	if(!isturf(T) || !T.can_have_cabling())
		to_chat(user, "<span class='warning'>You can only lay cables on catwalks and intact plating!</span>")
		return FALSE
	if(T.intact || T.transparent_floor)	// can't place a cable if the floor is complete
		to_chat(user, "<span class='warning'>You can't lay cable there unless the floor tiles are removed!</span>")
		return
	if(get_amount() < 1) // Out of cable
		to_chat(user, "<span class='warning'>There is no cable left!</span>")
		return FALSE
	if(get_dist(T, user) > 1) // Too far
		to_chat(user, "<span class='warning'>You can't lay cable at a place that far away!</span>")
		return FALSE
	for(var/obj/structure/cable/LC in T)
		if(LC.d2 == cable_direction && LC.d1 == NO_DIRECTION) //there's already a cable here that would be exactly what we just placed!
			to_chat(user, "<span class='warning'>There's already a cable at that position!</span>")
			return FALSE
	return TRUE

/// called when cable_coil is clicked on a turf/simulated/floor
/obj/item/stack/cable_coil/proc/place_turf(turf/T, mob/user, cable_direction)
	//If we weren't given a direction, come up with one! (Called as null from catwalk.dm and floor.dm)
	if(!cable_direction)
		//If laying on the tile we're on, lay in the direction we're facing otherwise get direction from us to the turf we've clicked
		cable_direction = user.loc == T ? user.dir : get_dir(T, user)

	if(!can_place(T, user, cable_direction))
		return FALSE

	var/obj/structure/cable/C = get_new_cable(T, cable_direction)
	C.add_fingerprint(user)
	//create a new powernet with the cable, if needed it will be merged later
	new /datum/regional_powernet(C)

	//END CABLE CREATION
	//START MERGENING OF POWERNETs

	C.merge_connected_networks(C.d2) //merge the powernet with adjacents powernets
	C.merge_connected_networks_on_turf() //merge the powernet with on turf powernets
	if(IS_DIR_DIAGONAL(C.d2))// if the cable is layed diagonally, check the others 2 possible directions
		C.merge_diagonal_networks(C.d2)
	use(1)
	#warn REIMPLEMENT_CABLE_SHOCKING
	return C

/// called when cable_coil is click on an installed obj/cable or click on a turf that already contains a "node" cable
/obj/item/stack/cable_coil/proc/cable_join(obj/structure/cable/C, mob/user)
	var/turf/T = get_turf(C)
	if(user.loc == T)
		// place_turf() will handle can_place checking automatically as well as generating the direction of the cable (i.g. the dir the user is facing)
		place_turf(T, user)
		return

	var/new_direction = get_dir(C, user)
	if(!can_place(T, user, new_direction))
		return FALSE

	// one end of the clicked cable is pointing towards us
	if(C.d1 == new_direction || C.d2 == new_direction)
		// cable is pointing at us, we're standing on an open tile
		// so create a stub pointing at the clicked cable on our tile
		var/direction_flipped = turn(new_direction, 180)		// the opposite direction

		for(var/obj/structure/cable/LC in T)		// check to make sure there's not a cable there already
			if(LC.d1 == direction_flipped || LC.d2 == direction_flipped)
				to_chat(user, "<span class='warning'>There's already a cable at that position!</span>")
				return

		var/obj/structure/cable/NC = get_new_cable(T, direction_flipped)
		NC.add_fingerprint(user)

		//create a new powernet with the cable, if needed it will be merged later
		new /datum/regional_powernet(NC)
		NC.merge_connected_networks(NC.d2)	//merge the powernet with adjacents powernets
		NC.merge_connected_networks_on_turf()	//merge the powernet with on turf powernets
		if(IS_DIR_DIAGONAL(NC.d2))	// if the cable is layed diagonally, check the others 2 possible directions
			NC.merge_diagonal_networks(NC.d2)

		use(1)

		if(NC.shock(user, 50))
			if(prob(50)) //fail
				NC.deconstruct()

	// exisiting cable doesn't point at our position, so see if it's a stub
	else if(C.d1 == NO_DIRECTION)
							// if so, make it a full cable pointing from it's old direction to our new_direction
		var/nd1 = C.d2	// these will be the new directions
		var/nd2 = new_direction


		if(nd1 > nd2)		// swap directions to match icons/states
			nd1 = new_direction
			nd2 = C.d2


		for(var/obj/structure/cable/LC in T)		// check to make sure there's no matching cable
			if(LC == C)			// skip the cable we're interacting with
				continue
			if((LC.d1 == nd1 && LC.d2 == nd2) || (LC.d1 == nd2 && LC.d2 == nd1) )	// make sure no cable matches either direction
				to_chat(user, "<span class='warning'>There's already a cable at that position!</span>")
				return

		if(istype(C, /obj/structure/cable/low_voltage))
			var/obj/structure/cable/low_voltage/lv_cable = C
			lv_cable.cable_color(color)

		C.d1 = nd1
		C.d2 = nd2

		C.add_fingerprint()
		C.update_icon()


		C.merge_connected_networks(C.d1) //merge the powernets...
		C.merge_connected_networks(C.d2) //...in the two new cable directions
		C.merge_connected_networks_on_turf()

		if(IS_DIR_DIAGONAL(C.d1))// if the cable is layed diagonally, check the others 2 possible directions
			C.merge_connected_networks(C.d1)

		if(IS_DIR_DIAGONAL(C.d2))// if the cable is layed diagonally, check the others 2 possible directions
			C.merge_connected_networks(C.d2)

		use(1)
		if(C.shock(user, 50))
			if(prob(50)) //fail
				C.deconstruct()
				return
		C.denode()// this call may have disconnected some cables that terminated on the centre of the turf, if so split the powernets.

//////////////////////////////
// Misc.
/////////////////////////////

/obj/item/stack/cable_coil/suicide_act(mob/user)
	if(locate(/obj/structure/chair/stool) in user.loc)
		user.visible_message("<span class='suicide'>[user] is making a noose with [src]! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	else
		user.visible_message("<span class='suicide'>[user] is strangling [user.p_themselves()] with [src]! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	return OXYLOSS

/obj/item/stack/cable_coil/five/New(loc, new_amount = 5, merge = TRUE, paramcolor = null)
	..()

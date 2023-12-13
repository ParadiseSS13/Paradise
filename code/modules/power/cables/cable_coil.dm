///////////////////////////////////////////////
// The cable coil object, used for laying cable
///////////////////////////////////////////////

#define HEALPERCABLE 3
#define MAXCABLEPERHEAL 8
GLOBAL_LIST_INIT(cable_coil_recipes, list (new/datum/stack_recipe/cable_restraints("cable restraints", /obj/item/restraints/handcuffs/cable, 15)))

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
	color = COLOR_RED
	throwforce = 10
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 2
	throw_range = 5
	materials = list(MAT_METAL = 15, MAT_GLASS = 10)
	flags = CONDUCT
	slot_flags = SLOT_FLAG_BELT
	item_state = "coil"
	attack_verb = list("whipped", "lashed", "disciplined", "flogged")
	usesound = 'sound/items/deconstruct.ogg'
	toolspeed = 1

/obj/item/stack/cable_coil/New(location, length = MAXCOIL, paramcolor = null)
	. = ..()
	if(paramcolor)
		color = paramcolor

/obj/item/stack/cable_coil/Initialize(mapload)
	. = ..()
	update_icon()
	recipes = GLOB.cable_coil_recipes
	update_wclass()

/obj/item/stack/cable_coil/update_name()
	. = ..()
	if(amount > 2)
		name = "cable coil"
	else
		name = "cable piece"

/obj/item/stack/cable_coil/update_icon_state()
	if(!color)
		color = pick(COLOR_RED, COLOR_BLUE, COLOR_GREEN, COLOR_ORANGE, COLOR_WHITE, COLOR_PINK, COLOR_YELLOW, COLOR_CYAN)
	if(amount == 1)
		icon_state = "coil1"
	else if(amount == 2)
		icon_state = "coil2"
	else
		icon_state = "coil"

/obj/item/stack/cable_coil/proc/update_wclass()
	if(amount == 1)
		w_class = WEIGHT_CLASS_TINY
	else
		w_class = WEIGHT_CLASS_SMALL

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

//you can use wires to heal robotics
/obj/item/stack/cable_coil/attack(mob/M, mob/user)
	if(!ishuman(M))
		return ..()
	var/mob/living/carbon/human/H = M
	var/obj/item/organ/external/S = H.bodyparts_by_name[user.zone_selected]

	if(!S?.is_robotic() || user.a_intent != INTENT_HELP || S.open == ORGAN_SYNTHETIC_OPEN)
		return ..()
	if(S.burn_dam > ROBOLIMB_SELF_REPAIR_CAP)
		to_chat(user, "<span class='danger'>The damage is far too severe to patch over externally.</span>")
		return
	if(!S.burn_dam)
		to_chat(user, "<span class='notice'>Nothing to fix!</span>")
		return
	if(H == user)
		if(!do_mob(user, H, 10))
			return FALSE
	var/cable_used = 0
	var/childlist
	if(!isnull(S.children))
		childlist = S.children.Copy()
	var/parenthealed = FALSE
	while(cable_used <= MAXCABLEPERHEAL && amount >= 1)
		var/obj/item/organ/external/E
		if(S.burn_dam)
			E = S
		else if(LAZYLEN(childlist))
			E = pick_n_take(childlist)
			if(!E.burn_dam || E.burn_dam >= ROBOLIMB_SELF_REPAIR_CAP || !E.is_robotic())
				continue
		else if(S.parent && !parenthealed)
			E = S.parent
			parenthealed = TRUE
			if(!E.burn_dam ||  E.burn_dam >= ROBOLIMB_SELF_REPAIR_CAP || !E.is_robotic())
				break
		else
			break
		while(cable_used <= MAXCABLEPERHEAL && E.burn_dam && amount >= 1)
			use(1)
			cable_used += 1
			E.heal_damage(0, HEALPERCABLE, 0, TRUE)
		H.UpdateDamageIcon()
		user.visible_message("<span class='alert'>[user] repairs some burn damage on [M]'s [E.name] with [src].</span>")
	return TRUE

/obj/item/stack/cable_coil/split()
	var/obj/item/stack/cable_coil/C = ..()
	C.color = color
	return C

// Items usable on a cable coil :
//   - Wirecutters : cut them duh !
//   - Cable coil : merge cables
/obj/item/stack/cable_coil/attackby(obj/item/W, mob/user)
	. = ..()
	if(istype(W, /obj/item/stack/cable_coil))
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

	if(istype(W, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/C = W
		cable_color(C.colourName)

///////////////////////////////////////////////
// Cable laying procedures
//////////////////////////////////////////////

/obj/item/stack/cable_coil/proc/get_new_cable(location)
	var/obj/structure/cable/C = new(location)
	C.cable_color(color)

	return C

/// called when cable_coil is clicked on a turf/simulated/floor
/obj/item/stack/cable_coil/proc/place_turf(turf/T, mob/user, cable_direction)
	if(!isturf(user.loc))
		return
	if(!isturf(T) || T.intact || !T.can_have_cabling())
		to_chat(user, "<span class='warning'>You can only lay cables on catwalks and plating!</span>")
		return
	if(get_amount() < 1) // Out of cable
		to_chat(user, "<span class='warning'>There is no cable left!</span>")
		return
	if(get_dist(T, user) > 1) // Too far
		to_chat(user, "<span class='warning'>You can't lay cable at a place that far away!</span>")
		return

	if(!cable_direction) //If we weren't given a direction, come up with one! (Called as null from catwalk.dm and floor.dm)
		if(user.loc == T)
			cable_direction = user.dir //If laying on the tile we're on, lay in the direction we're facing
		else
			cable_direction = get_dir(T, user) //otherwise get direction from us to the turf we've clicked

	for(var/obj/structure/cable/LC in T)
		if(LC.d2 == cable_direction && LC.d1 == NO_DIRECTION) //there's already a cable here that would be exactly what we just placed!
			to_chat(user, "<span class='warning'>There's already a cable at that position!</span>")
			return

	var/obj/structure/cable/C = get_new_cable(T)

	//set up the new cable
	C.d1 = NO_DIRECTION //it's a O-X node cable
	C.d2 = cable_direction
	C.add_fingerprint(user)
	C.update_icon()

	//create a new powernet with the cable, if needed it will be merged later
	var/datum/regional_powernet/new_powernet = new()
	new_powernet.add_cable(C)

	C.merge_connected_networks(C.d2) //merge the powernet with adjacents powernets
	C.merge_connected_networks_on_turf() //merge the powernet with on turf powernets

	if(IS_DIR_DIAGONAL(C.d2))// if the cable is layed diagonally, check the others 2 possible directions
		C.merge_diagonal_networks(C.d2)

	use(1)

	if(C.shock(user, 50))
		if(prob(50)) //fail
			new /obj/item/stack/cable_coil(get_turf(C), 1, paramcolor = C.color)
			C.deconstruct()

	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CABLE_UPDATED, T)
	return C

/// called when cable_coil is click on an installed obj/cable or click on a turf that already contains a "node" cable
/obj/item/stack/cable_coil/proc/cable_join(obj/structure/cable/C, mob/user)
	var/turf/U = user.loc
	if(!isturf(U))
		return

	var/turf/T = get_turf(C)
	// sanity checks, also stop use interacting with T-scanner revealed cable
	if(!isturf(T) || T.intact || T.transparent_floor)
		return
	// make sure it's close enough
	if(get_dist(C, user) > 1)
		to_chat(user, "<span class='warning'>You can't lay cable at a place that far away!</span>")
		return
	//if clicked on the turf we're standing on, try to put a cable in the direction we're facing
	if(U == T)
		place_turf(T,user)
		return

	var/new_direction = get_dir(C, user)

	// one end of the clicked cable is pointing towards us
	if(C.d1 == new_direction || C.d2 == new_direction)
		if(U.intact || U.transparent_floor)						// can't place a cable if the floor is complete
			to_chat(user, "<span class='warning'>You can't lay cable there unless the floor tiles are removed!</span>")
			return
		// cable is pointing at us, we're standing on an open tile
		// so create a stub pointing at the clicked cable on our tile

		var/direction_flipped = turn(new_direction, 180)		// the opposite direction

		for(var/obj/structure/cable/LC in U)		// check to make sure there's not a cable there already
			if(LC.d1 == direction_flipped || LC.d2 == direction_flipped)
				to_chat(user, "<span class='warning'>There's already a cable at that position!</span>")
				return

		var/obj/structure/cable/NC = get_new_cable (U)

		NC.d1 = 0
		NC.d2 = direction_flipped
		NC.add_fingerprint(user)
		NC.update_icon()

		//create a new powernet with the cable, if needed it will be merged later
		var/datum/regional_powernet/newPN = new()
		newPN.add_cable(NC)

		NC.merge_connected_networks(NC.d2)	//merge the powernet with adjacents powernets
		NC.merge_connected_networks_on_turf()	//merge the powernet with on turf powernets


		if(IS_DIR_DIAGONAL(NC.d2))	// if the cable is layed diagonally, check the others 2 possible directions
			NC.merge_diagonal_networks(NC.d2)

		use(1)

		if(NC.shock(user, 50))
			if(prob(50)) //fail
				NC.deconstruct()
				return

	// exisiting cable doesn't point at our position, so see if it's a stub
	else if(C.d1 == 0)
							// if so, make it a full cable pointing from it's old direction to our new_direction
		var/nd1 = C.d2	// these will be the new directions
		var/nd2 = new_direction


		if(nd1 > nd2)		// swap directions to match icons/states
			nd1 = new_direction
			nd2 = C.d2


		for(var/obj/structure/cable/LC in T)		// check to make sure there's no matching cable
			if(LC == C)			// skip the cable we're interacting with
				continue
			if((LC.d1 == nd1 && LC.d2 == nd2) || (LC.d1 == nd2 && LC.d2 == nd1))	// make sure no cable matches either direction
				to_chat(user, "<span class='warning'>There's already a cable at that position!</span>")
				return


		C.cable_color(color)

		C.d1 = nd1
		C.d2 = nd2

		C.add_fingerprint()
		C.update_icon()


		C.merge_connected_networks(C.d1) //merge the powernets...
		C.merge_connected_networks(C.d2) //...in the two new cable directions
		C.merge_connected_networks_on_turf()

		if(C.d1 & (C.d1 - 1))// if the cable is layed diagonally, check the others 2 possible directions
			C.merge_connected_networks(C.d1)

		if(C.d2 & (C.d2 - 1))// if the cable is layed diagonally, check the others 2 possible directions
			C.merge_connected_networks(C.d2)

		use(1)

		if(C.shock(user, 50))
			if(prob(50)) //fail
				C.deconstruct()
				return

		C.denode()// this call may have disconnected some cables that terminated on the centre of the turf, if so split the powernets.
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CABLE_UPDATED, T)

//////////////////////////////
// Misc.
/////////////////////////////

/obj/item/stack/cable_coil/proc/cable_color(colorC)
	if(!colorC)
		color = COLOR_RED
	else if(colorC == "rainbow")
		color = color_rainbow()
	else if(colorC == "orange") //byond only knows 16 colors by name, and orange isn't one of them
		color = COLOR_ORANGE
	else
		color = colorC

/obj/item/stack/cable_coil/suicide_act(mob/user)
	if(locate(/obj/structure/chair/stool) in user.loc)
		user.visible_message("<span class='suicide'>[user] is making a noose with [src]! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	else
		user.visible_message("<span class='suicide'>[user] is strangling [user.p_themselves()] with [src]! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	return OXYLOSS

/obj/item/stack/cable_coil/proc/color_rainbow()
	color = pick(COLOR_RED, COLOR_BLUE, COLOR_GREEN, COLOR_PINK, COLOR_YELLOW, COLOR_CYAN)
	return color

/obj/item/stack/cable_coil/five/New(loc, new_amount = 5, merge = TRUE, paramcolor = null)
	..()

/obj/item/stack/cable_coil/yellow
	color = COLOR_YELLOW

/obj/item/stack/cable_coil/blue
	color = COLOR_BLUE

/obj/item/stack/cable_coil/green
	color = COLOR_GREEN

/obj/item/stack/cable_coil/pink
	color = COLOR_PINK

/obj/item/stack/cable_coil/orange
	color = COLOR_ORANGE

/obj/item/stack/cable_coil/cyan
	color = COLOR_CYAN

/obj/item/stack/cable_coil/white
	color = COLOR_WHITE

/obj/item/stack/cable_coil/random/New()
	color = pick(COLOR_RED, COLOR_BLUE, COLOR_GREEN, COLOR_WHITE, COLOR_PINK, COLOR_YELLOW, COLOR_CYAN, COLOR_ORANGE)
	..()

/obj/item/stack/cable_coil/cut
	item_state = "coil2"

/obj/item/stack/cable_coil/cut/Initialize(mapload)
	. = ..()
	src.amount = rand(1,2)
	update_appearance(UPDATE_NAME|UPDATE_ICON_STATE)
	update_wclass()

/obj/item/stack/cable_coil/cyborg
	energy_type = /datum/robot_energy_storage/cable
	is_cyborg = TRUE

/obj/item/stack/cable_coil/cyborg/update_icon_state()
	return // icon_state should always be a full cable

/obj/item/stack/cable_coil/cyborg/attack_self(mob/user)
	var/cablecolor = input(user,"Pick a cable color.","Cable Color") in list("red","yellow","green","blue","pink","orange","cyan","white")
	color = cablecolor
	update_icon()

#undef HEALPERCABLE
#undef MAXCABLEPERHEAL

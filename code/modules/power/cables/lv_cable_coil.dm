///////////////////////////////////////////////
// The cable coil object, used for laying cable
///////////////////////////////////////////////

#define HEALPERCABLE 3
#define MAXCABLEPERHEAL 8
GLOBAL_LIST_INIT(cable_coil_recipes, list (new/datum/stack_recipe/cable_restraints("cable restraints", /obj/item/restraints/handcuffs/cable, 15)))

/obj/item/stack/cable_coil/low_voltage
	name = "low-voltage cable coil"
	icon_state = "coil"
	item_state = "coil_red"
	belt_icon = "cable_coil"
	merge_type = /obj/item/stack/cable_coil // This is here to let its children merge between themselves
	color = COLOR_RED
	throwforce = 10
	toolspeed = 1

	cable_structure_type = /obj/structure/cable/low_voltage

/obj/item/stack/cable_coil/low_voltage/New(location, length = MAXCOIL, paramcolor = null)
	. = ..()
	if(paramcolor)
		color = paramcolor

/obj/item/stack/cable_coil/low_voltage/Initialize(mapload)
	. = ..()
	recipes = GLOB.cable_coil_recipes

/obj/item/stack/cable_coil/low_voltage/update_name()
	. = ..()
	if(amount > 2)
		name = "low-voltage cable coil"
	else
		name = "low-voltage cable piece"

/obj/item/stack/cable_coil/low_voltage/update_icon_state()
	if(!color)
		color = pick(COLOR_RED, COLOR_BLUE, COLOR_GREEN, COLOR_ORANGE, COLOR_WHITE, COLOR_PINK, COLOR_YELLOW, COLOR_CYAN)
	if(amount == 1)
		icon_state = "coil1"
	else if(amount == 2)
		icon_state = "coil2"
	else
		icon_state = "coil"

/obj/item/stack/cable_coil/low_voltage/update_wclass()
	if(amount == 1)
		w_class = WEIGHT_CLASS_TINY
	else
		w_class = WEIGHT_CLASS_SMALL

//you can use wires to heal robotics
/obj/item/stack/cable_coil/low_voltage/attack(mob/M, mob/user)
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
	var/obj/item/stack/cable_coil/low_voltage/C = ..()
	C.color = color
	return C

// Items usable on a cable coil :
//   - Wirecutters : cut them duh !
//   - Cable coil : merge cables
/obj/item/stack/cable_coil/low_voltage/attackby(obj/item/W, mob/user)
	. = ..()
	if(istype(W, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/C = W
		cable_color(C.colourName)

///////////////////////////////////////////////
// Cable laying procedures
//////////////////////////////////////////////

/obj/item/stack/cable_coil/low_voltage/get_new_cable(location, d2)
	var/obj/structure/cable/low_voltage/new_cable = new cable_structure_type(location)
	new_cable.cable_color(color)
	//set up the new cable
	new_cable.d2 = d2 //it's a O-X node cable by default
	new_cable.update_icon()
	return new_cable

//////////////////////////////
// Misc.
/////////////////////////////

/obj/item/stack/cable_coil/low_voltage/proc/cable_color(colorC)
	if(!colorC)
		color = COLOR_RED
	else if(colorC == "rainbow")
		color = color_rainbow()
	else if(colorC == "orange") //byond only knows 16 colors by name, and orange isn't one of them
		color = COLOR_ORANGE
	else
		color = colorC

/obj/item/stack/cable_coil/low_voltage/proc/color_rainbow()
	color = pick(COLOR_RED, COLOR_BLUE, COLOR_GREEN, COLOR_PINK, COLOR_YELLOW, COLOR_CYAN)
	return color

/obj/item/stack/cable_coil/low_voltage/yellow
	color = COLOR_YELLOW

/obj/item/stack/cable_coil/low_voltage/blue
	color = COLOR_BLUE

/obj/item/stack/cable_coil/low_voltage/green
	color = COLOR_GREEN

/obj/item/stack/cable_coil/low_voltage/pink
	color = COLOR_PINK

/obj/item/stack/cable_coil/low_voltage/orange
	color = COLOR_ORANGE

/obj/item/stack/cable_coil/low_voltage/cyan
	color = COLOR_CYAN

/obj/item/stack/cable_coil/low_voltage/white
	color = COLOR_WHITE

/obj/item/stack/cable_coil/low_voltage/random/New()
	color = pick(COLOR_RED, COLOR_BLUE, COLOR_GREEN, COLOR_WHITE, COLOR_PINK, COLOR_YELLOW, COLOR_CYAN, COLOR_ORANGE)
	..()

/obj/item/stack/cable_coil/low_voltage/cut
	item_state = "coil2"

/obj/item/stack/cable_coil/low_voltage/cut/Initialize(mapload)
	. = ..()
	amount = rand(1,2)
	pixel_x = rand(-2,2)
	pixel_y = rand(-2,2)
	update_appearance(UPDATE_NAME|UPDATE_ICON_STATE)
	update_wclass()

/obj/item/stack/cable_coil/low_voltage/cyborg
	energy_type = /datum/robot_energy_storage/cable
	is_cyborg = TRUE

/obj/item/stack/cable_coil/low_voltage/cyborg/update_icon_state()
	return // icon_state should always be a full cable

/obj/item/stack/cable_coil/low_voltage/cyborg/attack_self(mob/user)
	var/cablecolor = input(user,"Pick a cable color.","Cable Color") in list("red","yellow","green","blue","pink","orange","cyan","white")
	color = cablecolor
	update_icon()

#undef HEALPERCABLE
#undef MAXCABLEPERHEAL

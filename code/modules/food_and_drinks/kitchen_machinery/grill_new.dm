
/obj/machinery/kitchen_machine/grill
	name = "grill"
	desc = "Backyard grilling, IN SPACE."
	icon = 'icons/obj/cooking_machines.dmi'
	icon_state = "grill_off"
	cook_verbs = list("Grilling", "Searing", "Frying")
	recipe_type = /datum/recipe/grill
	off_icon = "grill_off"
	on_icon = "grill_on"
	broken_icon = "grill_broke"
	dirty_icon = "grill_dirty"
	open_icon = "grill_open"

// see code/modules/food/recipes_grill.dm for recipes

/*******************
*   Initialising
********************/

/obj/machinery/kitchen_machine/grill/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/grill(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()

/obj/machinery/kitchen_machine/grill/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/grill(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()

/obj/machinery/kitchen_machine/grill/RefreshParts()
	var/E
	for(var/obj/item/weapon/stock_parts/micro_laser/M in component_parts)
		E += M.rating
	efficiency = round((E/2), 1) // There's 2 lasers, so halve the effect on the efficiency to keep it balanced

/obj/machinery/kitchen_machine/grill/special_attack(obj/item/weapon/grab/G, mob/user)
	if(istype(G.affecting, /mob/living/carbon/human))
		if(G.state < GRAB_AGGRESSIVE)
			to_chat(user, "<span class='warning'>You need a better grip to do that!</span>")
			return 1
		var/mob/living/carbon/human/C = G.affecting
		var/obj/item/organ/external/head/head = C.get_organ("head")
		var/obj/item/organ/external/chest/chest = C.get_organ("chest")
		var/obj/item/organ/external/arm/l_arm = C.get_organ("l_arm")
		var/obj/item/organ/external/arm/right/r_arm = C.get_organ("r_arm")
		if(!head)
			to_chat(user, "<span class='warning'>This person doesn't have a head!</span>")
			return 1
		C.visible_message("<span class='danger'>[user] forces [C] onto [src], searing [C]'s upper body!</span>", \
						"<span class='userdanger'>[user] forces you onto [src]! It burns!</span>")
		if(!C.stat)
			C.emote("scream")
		user.changeNext_move(CLICK_CD_MELEE)
		if(!(head.status & ORGAN_ROBOT))
			C.apply_damage(10, BURN, "head") //30 overall upper body damage because your body was just placed over a hot grill!
		if(!(chest.status & ORGAN_ROBOT))
			C.apply_damage(10, BURN, "chest")
		if(!(l_arm.status & ORGAN_ROBOT))
			C.apply_damage(5, BURN, "l_arm")
		if(!(r_arm.status & ORGAN_ROBOT))
			C.apply_damage(5, BURN, "r_arm")
		add_logs(G.assailant, G.affecting, "burns on a grill")
		qdel(G) //Removes the grip to prevent rapid sears and give you a chance to run
		return 1
	else
		to_chat(user, "<span class='warning'>You can only harm carbon-based creatures this way!</span>")
		return 0
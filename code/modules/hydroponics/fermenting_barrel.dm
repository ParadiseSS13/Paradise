/obj/structure/fermenting_barrel
	name = "wooden barrel"
	desc = "A large wooden barrel. You can ferment fruits and such inside it, or just use it to hold liquid."
	icon = 'icons/obj/objects.dmi'
	icon_state = "barrel"
	density = TRUE
	anchored = TRUE
	container_type = DRAINABLE | AMOUNT_VISIBLE
	pressure_resistance = 2 * ONE_ATMOSPHERE
	var/open = FALSE
	var/speed_multiplier = 1 //How fast it distills. Defaults to 100% (1.0). Lower is better.

/obj/structure/fermenting_barrel/Initialize(mapload)
	create_reagents(300) //Bluespace beakers, but without the portability or efficiency in circuits.
	AddComponent(/datum/component/debris, DEBRIS_WOOD, -20, 10)
	. = ..()

/obj/structure/fermenting_barrel/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It is currently [open ? "open, letting you pour liquids in." : "closed, letting you draw liquids from the tap."]</span>"

/obj/structure/fermenting_barrel/proc/makeWine(obj/item/food/grown/G)
	if(G.reagents)
		G.reagents.trans_to(src, G.reagents.total_volume)
	var/amount = G.seed.potency / 4
	if(G.distill_reagent)
		reagents.add_reagent(G.distill_reagent, amount)
	else
		var/data = list()
		data["names"] = list("[initial(G.name)]" = 1)
		data["color"] = G.filling_color
		data["alcohol_perc"] = G.wine_power
		if(G.wine_flavor)
			data["tastes"] = list(G.wine_flavor = 1)
		else
			data["tastes"] = list(G.tastes[1] = 1)
		reagents.add_reagent("fruit_wine", amount, data)
	qdel(G)
	playsound(src, 'sound/effects/bubbles.ogg', 50, TRUE)

/obj/structure/fermenting_barrel/item_interaction(mob/living/user, obj/item/I, list/modifiers)
	var/obj/item/food/grown/G = I
	if(istype(G))
		if(!G.can_distill)
			to_chat(user, "<span class='warning'>You can't distill this into anything...</span>")
			return ITEM_INTERACT_COMPLETE
		else if(!user.drop_item())
			to_chat(user, "<span class='warning'>[G] is stuck to your hand!</span>")
			return ITEM_INTERACT_COMPLETE
		G.forceMove(src)
		to_chat(user, "<span class='notice'>You place [G] into [src] to start the fermentation process.</span>")
		addtimer(CALLBACK(src, PROC_REF(makeWine), G), rand(80, 120) * speed_multiplier)
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/structure/fermenting_barrel/attack_hand(mob/user)
	open = !open
	if(open)
		container_type = REFILLABLE | AMOUNT_VISIBLE
		to_chat(user, "<span class='notice'>You open [src], letting you fill it.</span>")
	else
		container_type = DRAINABLE | AMOUNT_VISIBLE
		to_chat(user, "<span class='notice'>You close [src], letting you draw from its tap.</span>")
	update_icon(UPDATE_ICON_STATE)

/obj/structure/fermenting_barrel/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0))
		return
	TOOL_ATTEMPT_DISMANTLE_MESSAGE
	if(I.use_tool(src, user, 50, volume = I.tool_volume))
		TOOL_DISMANTLE_SUCCESS_MESSAGE
		deconstruct(disassembled = TRUE)

/obj/structure/fermenting_barrel/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I, time = 20)

/obj/structure/fermenting_barrel/deconstruct(disassembled = FALSE)
	var/mat_drop = 15
	if(disassembled)
		mat_drop = 30
	new /obj/item/stack/sheet/wood(drop_location(), mat_drop)
	..()

/obj/structure/fermenting_barrel/update_icon_state()
	if(open)
		icon_state = "barrel_open"
	else
		icon_state = "barrel"

/datum/crafting_recipe/fermenting_barrel
	name = "Wooden Barrel"
	result = list(/obj/structure/fermenting_barrel)
	reqs = list(/obj/item/stack/sheet/wood = 30)
	time = 50
	category = CAT_PRIMAL

/obj/structure/fermenting_barrel
	name = "wooden barrel"
	desc = "A large wooden barrel. You can ferment fruits and such inside it, or just use it to hold liquid."
	icon = 'icons/obj/objects.dmi'
	icon_state = "barrel"
	density = TRUE
	anchored = FALSE
	container_type = DRAINABLE | AMOUNT_VISIBLE
	pressure_resistance = 2 * ONE_ATMOSPHERE
	max_integrity = 300
	var/open = FALSE
	var/speed_multiplier = 1 //How fast it distills. Defaults to 100% (1.0). Lower is better.

/obj/structure/fermenting_barrel/Initialize()
	create_reagents(300) //Bluespace beakers, but without the portability or efficiency in circuits.
	. = ..()

/obj/structure/fermenting_barrel/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It is currently [open ? "open, letting you pour liquids in." : "closed, letting you draw liquids from the tap."] </span>"

/obj/structure/fermenting_barrel/proc/makeWine(obj/item/reagent_containers/food/snacks/grown/G)
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

/obj/structure/fermenting_barrel/attackby(obj/item/I, mob/user, params)
	var/obj/item/reagent_containers/food/snacks/grown/G = I
	if(istype(G))
		if(!G.can_distill)
			to_chat(user, "<span class='warning'>You can't distill this into anything...</span>")
			return FALSE
		else if(!user.drop_item())
			to_chat(user, "<span class='warning'>[G] is stuck to your hand!</span>")
			return FALSE
		G.forceMove(src)
		to_chat(user, "<span class='notice'>You place [G] into [src] to start the fermentation process.</span>")
		addtimer(CALLBACK(src, .proc/makeWine, G), rand(80, 120) * speed_multiplier)
	else if(I.is_refillable())
		return FALSE // To refill via afterattack proc
	else
		return ..()

/obj/structure/fermenting_barrel/attack_hand(mob/user)
	open = !open
	if(open)
		container_type = REFILLABLE | AMOUNT_VISIBLE
		to_chat(user, "<span class='notice'>You open [src], letting you fill it.</span>")
	else
		container_type = DRAINABLE | AMOUNT_VISIBLE
		to_chat(user, "<span class='notice'>You close [src], letting you draw from its tap.</span>")
	update_icon()

/obj/structure/fermenting_barrel/update_icon()
	if(open)
		icon_state = "barrel_open"
	else
		icon_state = "barrel"

/datum/crafting_recipe/fermenting_barrel
	name = "Wooden Barrel"
	result = /obj/structure/fermenting_barrel
	reqs = list(/obj/item/stack/sheet/wood = 30)
	time = 50
	category = CAT_PRIMAL

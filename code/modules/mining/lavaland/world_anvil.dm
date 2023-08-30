/obj/structure/world_anvil
	name = "World Anvil"
	desc = "An anvil that is connected through lava reservoirs to the core of lavaland. Whoever was using this last was creating something powerful."
	icon = 'icons/obj/lavaland/anvil.dmi'
	icon_state = "anvil"
	density = TRUE
	anchored = TRUE
	layer = TABLE_LAYER
	climbable = TRUE
	pass_flags = LETPASSTHROW
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

	var/forge_charges = 0
	var/obj/item/gps/internal

/obj/item/gps/internal/world_anvil
	icon_state = null
	gpstag = "Tempered Signal"
	desc = "An ancient anvil rests at this location."
	invisibility = 100

/obj/structure/world_anvil/Initialize()
	. = ..()
	internal = new /obj/item/gps/internal/world_anvil(src)

/obj/structure/world_anvil/Destroy()
	QDEL_NULL(internal)
	. = ..()

/obj/structure/world_anvil/update_icon()
	icon_state = forge_charges > 0 ? "anvil_a" : "anvil"
	if(forge_charges > 0)
		set_light(4,1,LIGHT_COLOR_ORANGE)
	else
		set_light(0)

/obj/structure/world_anvil/examine(mob/user)
	. = ..()
	. += "It currently has [forge_charges] forge[forge_charges != 1 ? "s" : ""] remaining."

/obj/structure/world_anvil/attackby(obj/item/I, mob/living/user, params)
	if(istype(I,/obj/item/twohanded/required/gibtonite))
		var/obj/item/twohanded/required/gibtonite/placed_ore = I
		forge_charges = forge_charges + placed_ore.quality
		to_chat(user,"You place down the gibtonite on the World Anvil, and watch as the gibtonite melts into it. The World Anvil is now heated enough for [forge_charges] forge[forge_charges > 1 ? "s" : ""].")
		qdel(placed_ore)
		update_icon()
		return
	if(forge_charges <= 0)
		to_chat(user,"The World Anvil is not hot enough to be usable!")
		return
	var/success = FALSE
	switch(I.type)
		if(/obj/item/magmite)
			playsound(src, 'sound/effects/anvil_start.ogg', 50)
			if(do_after(user, 7 SECONDS, target = src))
				new /obj/item/magmite_parts(get_turf(src))
				qdel(I)
				to_chat(user, "You carefully forge the rough plasma magmite into plasma magmite upgrade parts.")
				success = TRUE
		if(/obj/item/magmite_parts)
			var/obj/item/magmite_parts/parts = I

			if(!parts.inert)
				to_chat(user,"The magmite upgrade parts are already glowing and usable!")
				return
			playsound(src,'sound/effects/anvil_end.ogg', 50)
			if(do_after(user, 3 SECONDS, target = src))
				parts.restore()
				to_chat(user, "You successfully reheat the magmite upgrade parts. They are now glowing and usable again.")
	if(!success)
		return
	forge_charges--
	if(forge_charges <= 0)
		visible_message("The World Anvil cools down.")
		update_icon()


/obj/item/paintkit/hispania                 // estos son los paintkit de recolor
	name = "aplu paint kit"
	desc =  "A kit that contains all the necessary tools and pieces to recolor an APLU mech"
	new_icon_carpet = 'icons/hispania/mecha/mecha.dmi'
	var/color_selected = FALSE
	//aca la lista de paintkits de recolores.
	var/list/paintkit_type = list()

/obj/item/paintkit/hispania/Initialize(mapload)
	. = ..()
	var/list/kits = subtypesof(/obj/item/paintkit/hispania)
	for(var/path in kits)
		var/obj/item/paintkit/hispania = path
		paintkit_type += list(initial(hispania.new_icon) = path)

/obj/item/paintkit/hispania/attack_self(mob/user)
	if(color_selected)
		return
	var/obj/item/paintkit/hispania/paint = input(user, "Por favor, seleccione el modelo de personalizacion.", "paintkit") as null|anything in paintkit_type
	if(!paint || (!user.is_in_active_hand(src) || user.stat || user.restrained()) || !user.drop_item())
		return
	var/path = paintkit_type[paint]
	var/obj/item/paintkit/hispania/paintkit = new path(get_turf(src))
	paintkit.color_selected = TRUE
	user.put_in_hands(paintkit)
	qdel(src)

//paintkit de solo recolor//
/obj/item/paintkit/hispania/death
	name = "Death paint kit"
	desc = "A kit that contains all the necessary tools and pieces to recolor an APLU mech"
	new_name = "APLU \"Death\""
	new_icon = "deathripley"
	new_desc = "A APLU of a dubious red tone. Make your co-workers look at you with suspicion!"
	allowed_types = list("ripley","firefighter")

/obj/item/paintkit/hispania/black
	name = "Black paint kit"
	desc = "A kit that contains all the necessary tools and pieces to recolor an APLU mech"
	new_name = "APLU \"Black\""
	new_icon = "black"
	new_desc = "A darkest night-colored APLU. Make your co-workers, for a few seconds, think that you're related to sec in some way."
	allowed_types = list("ripley","firefighter")

/obj/item/paintkit/hispania/titansfist
	name = "Mercenary APLU \"Ripley\" kit"
	desc = "A kit containing all the needed tools and parts to turn an APLU \"Ripley\" into a Titan's Fist worker mech."
	icon_state = "paintkit_2"
	new_icon = "titan"
	new_name = "APLU \"Titan's Fist\""
	new_desc = "This ordinary mining Ripley has been customized to look like a unit of the Titans Fist."
	allowed_types = list("ripley","firefighter")

/obj/item/paintkit/hispania/griffin
	name = "Griffin APLU customisation kit"
	desc = "A kit containing all the needed tools and parts to turn an ordinary APLU into a Griffin worker mech."
	icon_state = "paintkit_2"
	new_icon = "griffin"
	new_name = "APLU \"Griffin\""
	new_desc = "The mech of The Griffin, the ultimate supervillain! The station will tremble under your feet (or maybe not)."
	allowed_types = list("ripley","firefighter")

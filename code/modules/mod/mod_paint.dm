/obj/item/mod/skin_applier
	name = "MOD skin applier"
	desc = "This one-use skin applier will add a skin to MODsuits of a specific type."
	icon = 'icons/obj/clothing/modsuit/mod_construction.dmi'
	icon_state = "skinapplier"
	var/skin = "civilian"
	var/compatible_theme = /datum/mod_theme

/obj/item/mod/skin_applier/Initialize(mapload)
	. = ..()
	name = "MOD [skin] skin applier"

/obj/item/mod/skin_applier/pre_attack(atom/attacked_atom, mob/living/user, params)
	if(!istype(attacked_atom, /obj/item/mod/control))
		return ..()
	var/obj/item/mod/control/mod = attacked_atom
	if(mod.active || mod.activating)
		to_chat(user, "<span class='warning'>Deactivate the suit!</span>")
		return TRUE
	if(!istype(mod.theme, compatible_theme))
		to_chat(user, "<span class='warning'>Theme is not compatable!</span>")
		return TRUE
	mod.set_mod_skin(skin)
	to_chat(user, "<span class='warning'>You apply the theme.</span>")
	qdel(src)
	return TRUE

/obj/item/mod/skin_applier/honkerative
	skin = "honkerative"
	compatible_theme = /datum/mod_theme/syndicate

/obj/item/mod/skin_applier/asteroid
	skin = "asteroid"
	compatible_theme = /datum/mod_theme/mining

/obj/item/mod/skin_applier/corpsman
	skin = "corpsman"
	compatible_theme = /datum/mod_theme/medical

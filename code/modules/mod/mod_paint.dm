/obj/item/mod/skin_applier
	name = "MOD skin applier"
	desc = "This one-use skin applier will add a skin to MODsuits of a specific type. This one applies to standard modsuits."
	icon = 'icons/obj/clothing/modsuit/mod_construction.dmi'
	icon_state = "skinapplier"
	var/skin = "civilian"
	var/make_spaceproof = FALSE //Used on the miner asteroid skin to make the suit spaceproof when upgrading.
	var/compatible_theme = /datum/mod_theme/standard

/obj/item/mod/skin_applier/Initialize(mapload)
	. = ..()
	name = "MOD [skin] skin applier"

/obj/item/mod/skin_applier/pre_attack(atom/attacked_atom, mob/living/user, params)
	if(!ismodcontrol(attacked_atom))
		return ..()
	var/obj/item/mod/control/mod = attacked_atom
	if(mod.active || mod.activating)
		to_chat(user, "<span class='warning'>Deactivate the suit!</span>")
		return TRUE
	if(!istype(mod.theme, compatible_theme))
		to_chat(user, "<span class='warning'>Theme is not compatible!</span>")
		return TRUE
	mod.set_mod_skin(skin)
	if(make_spaceproof)
		mod.min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
		for(var/obj/item/clothing/C in mod.mod_parts)
			C.min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	to_chat(user, "<span class='notice'>You apply the theme to [mod].</span>")
	qdel(src)
	return TRUE

/obj/item/mod/skin_applier/asteroid
	skin = "asteroid"
	compatible_theme = /datum/mod_theme/mining
	desc = "This one-use skin applier will add a skin to MODsuits of a specific type. This one applies to mining modsuits, and makes them spaceproof. Enjoy the days when you had MODsuits on the asteroid. Wait a minute."
	make_spaceproof = TRUE

/obj/item/mod/skin_applier/corpsman
	skin = "corpsman"
	compatible_theme = /datum/mod_theme/medical
	desc = "This one-use skin applier will add a skin to MODsuits of a specific type. This one applies to medical modsuits. You look like a corpse, man! Or was it a corps man?"

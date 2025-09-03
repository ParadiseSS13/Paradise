/obj/item/mod/skin_applier
	name = "MOD skin applier"
	desc = "This one-use skin applier will add a skin to MODsuits of a specific type. This one applies to standard modsuits."
	icon = 'icons/obj/clothing/modsuit/mod_construction.dmi'
	icon_state = "skinapplier"
	var/skin = "civilian"
	var/compatible_theme = /datum/mod_theme/standard

/obj/item/mod/skin_applier/Initialize(mapload)
	. = ..()
	name = "MOD [skin] skin applier"

/obj/item/mod/skin_applier/pre_attack(atom/target, mob/living/user, params)
	if(!ismodcontrol(target))
		return ..()
	var/obj/item/mod/control/mod = target
	if(mod.active || mod.activating)
		to_chat(user, "<span class='warning'>Deactivate the suit!</span>")
		return FINISH_ATTACK
	if(!istype(mod.theme, compatible_theme))
		to_chat(user, "<span class='warning'>Theme is not compatible!</span>")
		return FINISH_ATTACK
	mod.set_mod_skin(skin)
	to_chat(user, "<span class='notice'>You apply the theme to [mod].</span>")
	qdel(src)
	return FINISH_ATTACK

/obj/item/mod/skin_applier/asteroid
	skin = "asteroid"
	compatible_theme = /datum/mod_theme/mining
	desc = "This one-use skin applier will add a skin to MODsuits of a specific type. This one applies to mining modsuits, and makes them spaceproof. Enjoy the days when you had MODsuits on the asteroid. Wait a minute."

/obj/item/mod/skin_applier/corpsman
	skin = "corpsman"
	compatible_theme = /datum/mod_theme/medical
	desc = "This one-use skin applier will add a skin to MODsuits of a specific type. This one applies to medical modsuits. You look like a corpse, man! Or was it a corps man?"

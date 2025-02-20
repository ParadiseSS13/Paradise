// MARK: MODsuit control
/obj/item/mod/control/proc/build_head()
	return new /obj/item/clothing/head/mod(src)

/obj/item/mod/control/proc/build_suit()
	return new /obj/item/clothing/suit/mod(src)

/obj/item/mod/control/proc/build_gloves()
	return new /obj/item/clothing/gloves/mod(src)

/obj/item/mod/control/proc/build_shoes()
	return new /obj/item/clothing/shoes/mod(src)

/obj/item/mod/control/proc/is_any_part_deployed()
	for(var/obj/item/part as anything in mod_parts)
		if(part.loc != src)
			return TRUE
	return FALSE

// This is kinda sick but we need to retract it before the actual species change.
/obj/item/mod/control/proc/pre_species_gain(datum/species/new_species)
	if(!wearer)
		return
	if(is_any_part_deployed() && !theme.is_species_allowed(new_species))
		// Deactivate MODsuit to respect the species allowed.
		to_chat(wearer, span_warning("Ошибка видовой принадлежности! Деактивация."))
		if(active)
			var/old_activation_step_time = activation_step_time
			activation_step_time = 0.1 SECONDS // gotta go fast
			toggle_activate(wearer, force_deactivate = TRUE)
			activation_step_time = old_activation_step_time
		quick_deploy(wearer)

/obj/item/mod/control/quick_deploy(mob/user)
	user = user || loc // why the fuck this is nullable
	if(!is_any_part_deployed() && !theme.is_species_allowed(user.dna.species))
		to_chat(user, span_warning("Ошибка видовой принадлежности! Развертывание недоступно."))
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	return ..()

/obj/item/mod/control/deploy(mob/user, obj/item/part, mass)
	user = user || loc // why the fuck this is nullable
	if(!mass && part.loc != user && !theme.is_species_allowed(user.dna.species))
		to_chat(user, span_warning("Ошибка видовой принадлежности! Развертывание недоступно."))
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	return ..()

/obj/item/mod/control/pre_equipped/exclusive
	icon = 'modular_ss220/mod/icons/object/mod_clothing.dmi'
	icon_override = 'modular_ss220/mod/icons/mob/mod_clothing.dmi'

/obj/item/mod/control/pre_equipped/exclusive/build_head()
	return new /obj/item/clothing/head/mod/exclusive(src)

/obj/item/mod/control/pre_equipped/exclusive/build_suit()
	return new /obj/item/clothing/suit/mod/exclusive(src)

/obj/item/mod/control/pre_equipped/exclusive/build_gloves()
	return new /obj/item/clothing/gloves/mod/exclusive(src)

/obj/item/mod/control/pre_equipped/exclusive/build_shoes()
	return new /obj/item/clothing/shoes/mod/exclusive(src)

//MARK: Corporate
/obj/item/mod/control/pre_equipped/corporate/build_head()
	return new /obj/item/clothing/head/mod/exclusive(src)

/obj/item/mod/control/pre_equipped/corporate/build_suit()
	return new /obj/item/clothing/suit/mod/exclusive(src)

/obj/item/mod/control/pre_equipped/corporate/build_gloves()
	return new /obj/item/clothing/gloves/mod/exclusive(src)

/obj/item/mod/control/pre_equipped/corporate/build_shoes()
	return new /obj/item/clothing/shoes/mod/exclusive(src)

//MARK: ERT Red
/obj/item/mod/control/pre_equipped/responsory/red/build_head()
	return new /obj/item/clothing/head/mod/exclusive(src)

/obj/item/mod/control/pre_equipped/responsory/red/build_suit()
	return new /obj/item/clothing/suit/mod/exclusive(src)

/obj/item/mod/control/pre_equipped/responsory/red/build_gloves()
	return new /obj/item/clothing/gloves/mod/exclusive(src)

/obj/item/mod/control/pre_equipped/responsory/red/build_shoes()
	return new /obj/item/clothing/shoes/mod/exclusive(src)

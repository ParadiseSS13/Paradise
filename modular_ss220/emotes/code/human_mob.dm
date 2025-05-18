/mob/living/carbon/human/set_species(datum/species/new_species, use_default_color = FALSE, delay_icon_update = FALSE, skip_same_check = FALSE, retain_damage = FALSE, transformation = FALSE, keep_missing_bodyparts = FALSE)
	. = ..()
	client?.init_verbs()

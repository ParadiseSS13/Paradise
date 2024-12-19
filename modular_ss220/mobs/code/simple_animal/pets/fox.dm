/mob/living/simple_animal/pet/dog/fox
	yelp_sound = 'modular_ss220/mobs/sound/creatures/fox_yelp.ogg' //Used on death.
	holder_type = /obj/item/holder/fox
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'

/mob/living/simple_animal/pet/dog/fox/fennec
	name = "fennec"
	real_name = "fennec"
	desc = "Миниатюрная лисичка с очень большими ушами. Фенек, фенек, зачем тебе такие большие уши? Чтобы избегать дормитория?"
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	icon_state = "fennec"
	icon_living = "fennec"
	icon_dead = "fennec_dead"
	icon_resting = "fennec_rest"
	see_in_dark = 10
	holder_type = /obj/item/holder/fennec

/mob/living/simple_animal/pet/dog/fox/forest
	name = "forest fox"
	real_name = "forest fox"
	desc = "Лесная дикая лисица. Может укусить."
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	icon_state = "fox_forest"
	icon_living = "fox_forest"
	icon_dead = "fox_forest_dead"
	icon_resting = "fox_forest_rest"
	melee_damage_type = BRUTE
	melee_damage_lower = 6
	melee_damage_upper = 12



// named

/mob/living/simple_animal/pet/dog/fox/alisa
	name = "Алиса"
	desc = "Алиса, любимый питомец любого Офицера Специальных Операций. Интересно, что она говорит?"
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	icon_state = "alisa"
	icon_living = "alisa"
	icon_dead = "alisa_dead"
	icon_resting = "alisa_rest"
	faction = list("nanotrasen")
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	melee_damage_lower = 10
	melee_damage_upper = 20

/mob/living/simple_animal/pet/dog/fox/fennec/fenya
	name = "Феня"
	desc = "Миниатюрная лисичка c важным видом и очень большими ушами. Был пойман во время разливания огромного мороженого по формочкам и теперь Магистрат держит его при себе и следит за ним. Но похоже что ему даже нравится быть частью правосудия."
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	resting = TRUE
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN

/datum/species/skeleton
	name = "Skeleton"
	name_plural = "Skeletons"

	blurb = "Spoopy and scary."

	icobase = 'icons/mob/human_races/r_skeleton.dmi'
	deform = 'icons/mob/human_races/r_skeleton.dmi'

	blood_color = "#FFFFFF"
	flesh_color = "#E6E6C6"

	species_traits = list(NO_BREATHE, NO_BLOOD, RADIMMUNE, VIRUSIMMUNE, NO_HUNGER, PIERCEIMMUNE, NO_DNA, RUNIC_MIND)
	dies_at_threshold = TRUE
	skinned_type = /obj/item/stack/sheet/bone

	taste_sensitivity = TASTE_SENSITIVITY_NO_TASTE //skeletons can't taste anything

	reagent_tag = PROCESS_ORG

	warning_low_pressure = -INFINITY
	hazard_low_pressure = -INFINITY
	hazard_high_pressure = INFINITY
	warning_high_pressure = INFINITY

	cold_level_1 = -INFINITY
	cold_level_2 = -INFINITY
	cold_level_3 = -INFINITY

	heat_level_1 = INFINITY
	heat_level_2 = INFINITY
	heat_level_3 = INFINITY

	suicide_messages = list(
		"ломает себе кости!",
		"сваливается в кучу!",
		"разваливается!",
		"откручивает себе череп!")
	has_organ = list(
		"brain" = /obj/item/organ/internal/brain/golem,
	) //Has default darksight of 2.

	toxic_food = NONE
	disliked_food = NONE
	liked_food = DAIRY

/datum/species/skeleton/handle_reagents(mob/living/carbon/human/H, datum/reagent/R)
	// Crazylemon is still silly
	if(R.id == "milk")
		H.heal_overall_damage(1, 1)
		if(prob(5)) // 5% chance per proc to find a random limb, and mend it
			var/list/our_organs = H.bodyparts.Copy()
			shuffle(our_organs)
			for(var/obj/item/organ/external/L in our_organs)
				if(L.mend_fracture())
					break // We're only checking one limb here, bucko
		if(prob(25)) //25% шанс на случайную шутливую фразу
			H.say(pick("Спасибо Мистеру Скелтал!", "От такого молока челюсть отвисает!", "Я вижу четКость своих решений!", "Надо не забыть пересчитать косточки...", "Маленькие скелеты паКостят!", "Хорошо что у меня язык без костей!", "Теперь я не буду ЧЕРЕПашкой!", "Теперь мне не нужны костыли!", "Костян плохого не посоветует!", "Ощущаешь мою ловКость?", "Я чувствую такую лёгКость!", "Большая редКость найти любимую жидКость!", "Моя любимая жидКость!", "Аж закостенел!", "Теперь я вешу скелетонну!", "Спасибо за крепкие кости!", "Ду-ду!", "Вы замечали что мы все в одной плосКости?"))
		return TRUE

	return ..()

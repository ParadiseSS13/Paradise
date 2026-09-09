/mob/living/proc/get_taste_sensitivity()
	return TASTE_SENSITIVITY_NORMAL

/mob/living/carbon/human/get_taste_sensitivity()
	if(dna.species)
		return dna.species.taste_sensitivity
	return ..()

/mob/living/proc/get_taste_category()
	return TASTE_CATEGORY_ORGANIC

/mob/living/silicon/get_taste_category()
	return TASTE_CATEGORY_SYNTHETIC

/mob/living/carbon/human/get_taste_category()
	if(HAS_TRAIT(src, TRAIT_IPC_CAN_EAT))
		return TASTE_CATEGORY_BOTH
	if(dna.species)
		return dna.species.taste_category
	return ..()

// non destructively tastes a reagent container
/mob/living/proc/taste(datum/reagents/from)
	if(last_taste_time + 50 < world.time)
		var/text_output = from.generate_taste_message(get_taste_sensitivity(), get_taste_category())
		// We dont want to spam the same message over and over again at the
		// person. Give it a bit of a buffer.
		if(AmountHallucinate() > 50 SECONDS && prob(25))
			text_output = pick("spiders","dreams","nightmares","the future","the past","victory",\
			"defeat","pain","bliss","revenge","poison","time","space","death","life","truth","lies","justice","memory",\
			"regrets","your soul","suffering","music","noise","blood","hunger","the american way")
		if(text_output != last_taste_text || last_taste_time + 100 < world.time)
			to_chat(src, SPAN_NOTICE("You can taste [text_output]."))
			// "something indescribable" -> too many tastes, not enough flavor.

			last_taste_time = world.time
			last_taste_text = text_output

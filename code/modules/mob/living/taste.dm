/mob/living
	var/last_taste_time
	var/last_taste_text

/mob/living/proc/get_taste_sensitivity()
	return TASTE_SENSITIVITY_NORMAL

/mob/living/carbon/get_taste_sensitivity()
	if(dna.species)
		return dna.species.taste_sensitivity
	else
		return TASTE_SENSITIVITY_NORMAL

/mob/living/proc/taste(datum/reagents/holder)
	if(last_taste_time + 50 >= world.time) //helps us to not spam the same message too much
		return
	var/taste_sensitivity = get_taste_sensitivity()
	var/text_output = holder.generate_taste_message(taste_sensitivity)
	if(hallucination > 50 && prob(25))
		text_output = pick("spiders","dreams","nightmares","the future","the past","victory",\
		"defeat","pain","bliss","revenge","poison","time","space","death","life","truth","lies","justice","memory",\
		"regrets","your soul","suffering","music","noise","blood","hunger","the american way")
	//the cooldown for the same taste is 100 deciseconds, but if the taste message is different there is a minimum wait of 50 deciseconds
	if(text_output != last_taste_text || (last_taste_time + 100) < world.time) 
		to_chat(src, "<span class='notice'>You can taste [text_output].</span>")
		last_taste_time = world.time
		last_taste_text = text_output
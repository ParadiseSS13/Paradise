#define SIZE_DOESNT_MATTER 	-1
#define BABIES_ONLY			0
#define ADULTS_ONLY			1

#define NO_GROWTH_NEEDED	0
#define GROWTH_NEEDED		1

#define NO_SPLIT_NEEDED		0
#define SPLIT_NEEDED		1

/datum/action/innate/slime
	check_flags = AB_CHECK_CONSCIOUS
	icon_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"
	var/needs_growth = NO_GROWTH_NEEDED
	var/needs_split = NO_SPLIT_NEEDED

/datum/action/innate/slime/IsAvailable()
	if(..())
		var/mob/living/simple_animal/slime/S = owner
		if(needs_growth == GROWTH_NEEDED)
			if(needs_split == SPLIT_NEEDED && S.amount_grown >= S.age_state.amount_grown_for_split)
				return 1
			if(S.amount_grown >= S.age_state.amount_grown)
				return 1
			return 0
		return 1

/mob/living/simple_animal/slime/verb/Feed()
	set category = "Slime"
	set desc = "This will let you feed on any valid creature in the surrounding area. This should also be used to halt the feeding process."

	if(stat)
		return 0

	var/list/choices = list()
	for(var/mob/living/C in view(1,src))
		if(C!=src && Adjacent(C))
			choices += C

	var/mob/living/M = input(src,"Who do you wish to feed on?") in null|choices
	if(!M)
		return 0
	if(CanFeedon(M))
		Feedon(M)
		return 1

/datum/action/innate/slime/feed
	name = "Feed"
	button_icon_state = "slimeeat"


/datum/action/innate/slime/feed/Activate()
	var/mob/living/simple_animal/slime/S = owner
	S.Feed()

/mob/living/simple_animal/slime/proc/CanFeedon(mob/living/M, silent = FALSE)
	if(!Adjacent(M))
		return FALSE

	if(buckled)
		Feedstop()
		return FALSE

	if(issilicon(M))
		return FALSE

	if(isanimal(M))
		var/mob/living/simple_animal/S = M
		if(S.damage_coeff[TOX] <= 0 && S.damage_coeff[CLONE] <= 0) //The creature wouldn't take any damage, it must be too weird even for us.
			if(silent)
				return FALSE
			to_chat(src, "<span class='warning'>[pick("This subject is incompatible", \
			"This subject does not have life energy", "This subject is empty", \
			"I am not satisified", "I can not feed from this subject", \
			"I do not feel nourished", "This subject is not food")]!</span>")
			return FALSE

	if(isslime(M))
		if(silent)
			return FALSE
		to_chat(src, "<span class='warning'><i>I can't latch onto another slime...</i></span>")
		return FALSE

	if(docile)
		if(silent)
			return FALSE
		to_chat(src, "<span class='notice'><i>I'm not hungry anymore...</i></span>")
		return FALSE

	if(stat)
		if(silent)
			return FALSE
		to_chat(src, "<span class='warning'><i>I must be conscious to do this...</i></span>")
		return FALSE

	if(M.stat == DEAD)
		if(silent)
			return FALSE
		to_chat(src, "<span class='warning'><i>This subject does not have a strong enough life energy...</i></span>")
		return FALSE

	if(locate(/mob/living/simple_animal/slime) in M.buckled_mobs)
		if(silent)
			return FALSE
		to_chat(src, "<span class='warning'><i>Another slime is already feeding on this subject...</i></span>")
		return FALSE
	return TRUE

/mob/living/simple_animal/slime/proc/Feedon(mob/living/M)
	M.unbuckle_all_mobs(force = TRUE) //Slimes rip other mobs (eg: shoulder parrots) off (Slimes Vs Slimes is already handled in CanFeedon())
	if(M.buckle_mob(src, force = TRUE))
		layer = M.layer + 0.01 //appear above the target mob
		M.visible_message("<span class='danger'>[name] has latched onto [M]!</span>", \
						"<span class='userdanger'>[name] has latched onto [M]!</span>")
	else
		to_chat(src, "<span class='warning'><i>I have failed to latch onto the subject!</i></span>")

/mob/living/simple_animal/slime/proc/Feedstop(silent = FALSE, living = 1)
	if(buckled)
		if(!living)
			to_chat(src, "<span class='warning'>[pick("This subject is incompatible", \
			"This subject does not have life energy", "This subject is empty", \
			"I am not satisified", "I can not feed from this subject", \
			"I do not feel nourished", "This subject is not food")]!</span>")
		if(!silent)
			visible_message("<span class='warning'>[src] has let go of [buckled]!</span>", \
							"<span class='notice'><i>I stopped feeding.</i></span>")
		layer = initial(layer)
		buckled.unbuckle_mob(src,force=TRUE)

/mob/living/simple_animal/slime/verb/Evolve()
	set category = "Slime"
	set desc = "This will let you evolve slime."

	if(stat)
		to_chat(src, "<i>I must be conscious to do this...</i>")
		return

	if(amount_grown >= age_state.amount_grown)
		switch(age_state.age)
			if(SLIME_BABY)
				age_state = new /datum/slime_age/adult
			if(SLIME_ADULT)
				age_state = new /datum/slime_age/old
			if(SLIME_OLD)
				age_state = new /datum/slime_age/elder
			if(SLIME_ELDER)
				age_state = new /datum/slime_age/slimeman
		amount_grown = 0
		update_state()
		regenerate_icons()
		update_name()
	else
		to_chat(src, "<i>I am not ready to evolve yet...</i>")

	if(age_state.age == SLIME_SLIMEMAN)
		if(amount_grown >= age_state.amount_grown)
			var/mob/living/carbon/human/slime/new_slime = src.change_mob_type(/mob/living/carbon/human/slime, null, null, TRUE)
			var/new_colour = colour_rgb(colour)
			new_slime.skin_colour = new_colour
			for(var/organname in new_slime.bodyparts_by_name)
				var/obj/item/organ/external/E = new_slime.bodyparts_by_name[organname]
				E.sync_colour_to_human(new_slime)
			new_slime.update_hair()
			new_slime.update_body()
			new_slime.blood_color = new_colour
			new_slime.dna.species.blood_color = new_slime.blood_color
		else
			to_chat(src, "<i>I am not ready to evolve yet...</i>")

/datum/action/innate/slime/evolve
	name = "Evolve"
	button_icon_state = "slimegrow"
	needs_growth = GROWTH_NEEDED

/datum/action/innate/slime/evolve/Activate()
	var/mob/living/simple_animal/slime/S = owner
	S.Evolve()
	if(S.age_state.age != SLIME_BABY && !(locate(/datum/action/innate/slime/reproduce) in S.actions))
		var/datum/action/innate/slime/reproduce/A = new
		A.Grant(S)

/mob/living/simple_animal/slime/verb/Reproduce()
	set category = "Slime"
	set desc = "This will make you split into four Slimes."

	if(stat)
		to_chat(src, "<i>I must be conscious to do this...</i>")
		return

	if(age_state.age != SLIME_BABY)
		if(amount_grown >=	age_state.amount_grown_for_split)
			if(stat)
				to_chat(src, "<i>I must be conscious to do this...</i>")
				return
			force_split(TRUE)
		else
			to_chat(src, "<i>I am not ready to reproduce yet...</i>")
	else
		to_chat(src, "<i>I am not old enough to reproduce yet...</i>")

/mob/living/simple_animal/slime/proc/force_split(var/can_mutate = TRUE)
	if(age_state.age == SLIME_BABY)
		return FALSE

	//Определяем модификатор количества детей от количества накопленных нутриентов
	var/baby_mod = 0.1
	if(nutrition >= get_max_nutrition())
		baby_mod = 1.25
	else if(nutrition >= get_grow_nutrition())
		baby_mod = 1
	else if(nutrition >= get_hunger_nutrition())
		baby_mod = 0.5
	else if(nutrition >= get_starve_nutrition())
		baby_mod = 0.25

	//Определяем какие дети родятся
	var/list/babies = list()
	var/add_counts = ((age_state.age == SLIME_OLD) ? round(age_state.baby_counts / 3) : 0) + ((age_state.age == SLIME_ELDER) ? round(age_state.baby_counts / 3) : 0)
	var/baby_counts = round(rand(3 + add_counts, age_state.baby_counts) * baby_mod)
	baby_counts = baby_counts <= 0 ? 1 : baby_counts	//даже если нутриентов по нулям, то поделится на 1-го BABY
	var/baby_counts_adult = 0
	if (age_state.age == SLIME_OLD || age_state.age == SLIME_ELDER)
		baby_counts_adult = rand(0, round(baby_counts / 2))
	var/baby_counts_old = 0
	if (age_state.age == SLIME_ELDER && baby_counts)
		baby_counts_old	= rand(0, round((baby_counts - baby_counts_adult * 2) / 3) + 1)

	baby_counts -= baby_counts_adult * 2 + baby_counts_old * 3
	var/new_nutrition = round(nutrition * 0.9 / (baby_counts + baby_counts_adult + baby_counts_old))
	var/new_powerlevel = round(powerlevel / (baby_counts + baby_counts_adult + baby_counts_old))

	//Определяем количество детей и будущее набольшее тело
	var/mob/living/simple_animal/slime/new_slime
	if (baby_counts_old)
		for(var/i in 1 to baby_counts_old)
			reproduce_baby_stats(babies, /datum/slime_age/old, new_nutrition, new_powerlevel, can_mutate)
		new_slime = pick(babies)
	if (baby_counts_adult)
		for(var/i in 1 to baby_counts_adult)
			reproduce_baby_stats(babies, /datum/slime_age/adult, new_nutrition, new_powerlevel, can_mutate)
		if (!new_slime)
			new_slime = pick(babies)
	if (baby_counts)
		for(var/i in 1 to baby_counts)
			reproduce_baby_stats(babies, /datum/slime_age/baby, new_nutrition, new_powerlevel, can_mutate)

	if (!new_slime)
		new_slime = pick(babies)

	new_slime.a_intent = INTENT_HARM
	if(src.mind)
		src.mind.transfer_to(new_slime)
	else
		new_slime.key = src.key
	qdel(src)
	return TRUE

/mob/living/simple_animal/slime/proc/reproduce_baby_stats(var/list/babies, var/datum/slime_age/baby_type, var/new_nutrition, var/new_powerlevel, var/can_mutate)
	var/child_colour = colour
	if(can_mutate)
		if(mutation_chance >= 100)
			child_colour = "rainbow"
		else if(prob(mutation_chance))
			child_colour = slime_mutation[rand(1,4)]
	var/mob/living/simple_animal/slime/M = new(loc, child_colour, new baby_type, new_nutrition)

	if(ckey)
		M.set_nutrition(new_nutrition * 1.25) //Player slimes are more robust at spliting. Once an oversight of poor copypasta, now a feature!
	M.powerlevel = new_powerlevel
	M.Friends = Friends.Copy()
	babies += M
	if(can_mutate)
		M.mutation_chance = clamp(mutation_chance+(rand(5,-5)),0,100)
	SSblackbox.record_feedback("tally", "slime_babies_born", 1, M.colour)

/datum/action/innate/slime/reproduce
	name = "Reproduce"
	button_icon_state = "slimesplit"
	needs_growth = GROWTH_NEEDED
	needs_split = SPLIT_NEEDED

/datum/action/innate/slime/reproduce/Activate()
	var/mob/living/simple_animal/slime/S = owner
	S.Reproduce()

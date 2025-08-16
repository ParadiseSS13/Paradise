/datum/disease/beesease/wizard_variant
	spread_flags = SPREAD_NON_CONTAGIOUS

/datum/disease/cold9/wizard_variant
	spread_flags = SPREAD_NON_CONTAGIOUS

/datum/disease/fluspanish/wizard_variant
	spread_flags = SPREAD_NON_CONTAGIOUS

/datum/disease/kingstons_advanced/wizard_variant
	spread_flags = SPREAD_NON_CONTAGIOUS

/datum/disease/dna_retrovirus/wizard_variant
	spread_flags = SPREAD_NON_CONTAGIOUS

/datum/disease/tuberculosis/wizard_variant
	spread_flags = SPREAD_NON_CONTAGIOUS

/datum/disease/wizarditis/wizard_variant
	spread_flags = SPREAD_NON_CONTAGIOUS

/datum/disease/anxiety/wizard_variant
	spread_flags = SPREAD_NON_CONTAGIOUS

/datum/disease/grut_gut
	name = "Grut Gut"
	max_stages = 5
	stage_prob = 5
	spread_text = "Non-contagious"
	cure_text = "Pyrotech stabilizing agents"
	agent = "Eruca Stomachum"
	cures = list("stabilizing_agent")
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "A magic-infused disease that builds up DANGEROUSLY high pressure bile within the stomach."
	severity = VIRUS_DANGEROUS
	virus_heal_resistant = TRUE

/datum/disease/grut_gut/wizard_variant
	spread_flags = SPREAD_NON_CONTAGIOUS

/datum/disease/grut_gut/stage_act()
	if(!..())
		return FALSE

	switch(stage)
		if(1)
			if(prob(3))
				to_chat(affected_mob, "<span class='danger'>Your stomach feels strange.</span>")
		if(2)
			if(prob(3))
				to_chat(affected_mob, "<span class='danger'>You feel bloated.</span>")
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>Your feel an uncomfortable pressure in your abdomen.</span>")
		if(3)
			if(prob(3))
				to_chat(affected_mob, "<span class='danger'>Your feel an uncomfortable pressure in your abdomen.</span>")
			if(prob(2))
				affected_mob.custom_emote(EMOTE_AUDIBLE, "burps")
			if(prob(1))
				affected_mob.emote("groan")
		if(4)
			if(prob(1))
				affected_mob.fakevomit(no_text = 1)
				affected_mob.adjust_nutrition(-rand(3,5))
			if(prob(2))
				affected_mob.custom_emote(EMOTE_AUDIBLE, "burps")
			if(prob(3))
				to_chat(affected_mob, "<span class='danger'>Your feel horribly bloated.</span>")
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>A deep bubbling resounds through your chest.</span>")
		if(5)
			if(prob(2))
				affected_mob.custom_emote(EMOTE_AUDIBLE, "belches loudly!")
			if(prob(1))
				affected_mob.custom_emote(EMOTE_AUDIBLE, "burps")
			if(prob(1))
				affected_mob.emote("groan")
			if(prob(3))
				to_chat(affected_mob, "<span class='danger'>Your stomach is killing you!</span>")
			if(prob(3))
				to_chat(affected_mob, "<span class='danger'>Your abdomen gurgles and bubbles with a fierce intensity!</span>")
			if(prob(2) && affected_mob.nutrition >= 100)
				affected_mob.adjustBruteLoss(5)
				affected_mob.vomit(6, 0, TRUE, 7, 0)
				affected_mob.visible_message(
					"<span class='danger'>[affected_mob] vomits with such force that [affected_mob.p_theyre(FALSE)] sent flying backwards!</span>",
					"<span class='userdanger'>You vomit a torrent of magic bile so forcefully, that you are sent flying!</span>",
					"<span class='warning'>You hear someone vomit profusely.</span>"
				)
				do_fling(affected_mob)

/datum/disease/grut_gut/proc/do_fling()
	var/fling_dir = REVERSE_DIR(affected_mob.dir)
	var/turf/general_direction = get_edge_target_turf(affected_mob, fling_dir)
	affected_mob.throw_at(general_direction, 200, 3) // YEET them til they hit something!!


/datum/disease/wand_rot
	name = "Wand Rot"
	max_stages = 5
	stage_prob = 5
	spread_text = "Non-contagious"
	cure_text = "Acetaldehyde"
	agent = "nasum magicum"
	cures = list("acetaldehyde")
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "A magic-infused disease that replaces one's nose hairs with tiny wands. Avoid nasal irritants."
	severity = VIRUS_DANGEROUS
	virus_heal_resistant = TRUE

/datum/disease/wand_rot/wizard_variant
	spread_flags = SPREAD_NON_CONTAGIOUS

/datum/disease/wand_rot/stage_act()
	if(!..())
		return FALSE

	switch(stage)
		if(1)
			if(prob(2))
				affected_mob.emote("sniff")
		if(2)
			if(prob(3))
				affected_mob.emote("sniff")
			if(prob(3))
				to_chat(affected_mob, "<span class='danger'>Your nose and throat feel uncomfortably dry.</span>")
		if(3)
			if(prob(2))
				affected_mob.emote("cough")
			if(prob(3))
				affected_mob.emote("sniff")
			if(prob(3))
				to_chat(affected_mob, "<span class='danger'>Your nose and throat feel uncomfortably dry.</span>")
		if(4)
			if(prob(2))
				affected_mob.emote("cough")
			if(prob(3))
				affected_mob.emote("sneeze")
			if(prob(3))
				to_chat(affected_mob, "<span class='danger'>Your throat burns and itches!</span>")

		if(5)
			if(prob(2))
				affected_mob.emote("cough")
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>Your nose feels like it's going to burn right off your face!</span>")
				affected_mob.adjustFireLoss(5)
			if(prob(3))
				affected_mob.emote("sniff")
			if(prob(1))
				affected_mob.emote("sneeze")
				sleep(2) // to give the audio a short time to sync with the fireball shot
				sneeze_fireballs()

//sneeze a fireball in a random direction
/datum/disease/wand_rot/proc/sneeze_fireballs()
	var/fuck_you_dir = pick(GLOB.alldirs)
	var/turf/target_tile = get_edge_target_turf(affected_mob, fuck_you_dir)
	var/obj/item/projectile/magic/fireball/FB = new /obj/item/projectile/magic/fireball(affected_mob.loc)
	FB.current = get_turf(affected_mob)
	FB.original = target_tile
	FB.firer = affected_mob
	FB.preparePixelProjectile(target_tile, affected_mob)
	FB.fire()
	playsound(affected_mob, 'sound/magic/fireball.ogg', 50, 1)

/datum/disease/mystic_malaise
	name = "Mystic Malaise"
	max_stages = 5
	stage_prob = 5
	spread_text = "Non-contagious"
	spread_flags = SPREAD_CONTACT_GENERAL
	cure_text = "liquid dark matter"
	agent = "Spatio Ventrem"
	cures = list("liquid_dark_matter")
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "A magic-infused disease that resides in the gut, converting gastric juices into space-matter."
	severity = VIRUS_DANGEROUS
	virus_heal_resistant = TRUE

/datum/disease/mystic_malaise/wizard_variant
	spread_flags = SPREAD_NON_CONTAGIOUS

/datum/disease/mystic_malaise/stage_act()
	if(!..())
		return FALSE

	switch(stage)
		if(1)
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>You feel nauseous.</span>")
		if(2)
			if(prob(3))
				to_chat(affected_mob, "<span class='danger'>Your stomach aches.</span>")
		if(3)
			if(prob(3))
				to_chat(affected_mob, "<span class='danger'>You feel a growing emptiness inside you.</span>")
			if(prob(2))
				affected_mob.emote("cough")
		if(4)
			if(prob(3))
				to_chat(affected_mob, "<span class='danger'>Your chest feels like it's going to cave in!</span>")
			if(prob(2))
				affected_mob.emote("cough")
			if(prob(2))
				affected_mob.emote("groan")
		if(5)
			if(prob(2))
				affected_mob.AdjustConfused(5 SECONDS)
				playsound(get_turf(affected_mob), 'sound/effects/splat.ogg', 50, 1)
				var/turf/T = get_turf(affected_mob)
				T.add_vomit_floor(FALSE, FALSE, /obj/effect/decal/cleanable/vomit/spacematter)

/obj/effect/decal/cleanable/vomit/spacematter
	name = "spacematter vomit"
	desc = "Despite the hazard, its dazzlingly beautiful. You should probably get away from it though."
	icon_state = "vomitnebula_1"
	random_icon_states = list("vomitnebula_1", "vomitnebula_2", "vomitnebula_3", "vomitnebula_4")
	no_scoop = TRUE
	var/time_to_live

/obj/effect/decal/cleanable/vomit/spacematter/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSprocessing, src)
	time_to_live = world.time + 15 SECONDS

/obj/effect/decal/cleanable/vomit/spacematter/process()
	var/datum/milla_safe/spacematter_vomit_process/milla = new()
	milla.invoke_async(src)
	if(world.time >= time_to_live) // dont want to remove the spot, but stop removing atmos
		STOP_PROCESSING(SSprocessing, src)
		src.visible_message("<span class='danger'>[src] evaporates into nothingness!</span>")
		qdel(src)

/datum/milla_safe/spacematter_vomit_process

/datum/milla_safe/spacematter_vomit_process/on_run(obj/effect/decal/cleanable/vomit/spacematter/splatter)
	var/turf/tile = get_turf(splatter)
	var/datum/gas_mixture/environment = get_turf_air(tile)
	var/removed_moles = environment.total_moles() * (1500 / environment.volume)
	environment.remove(removed_moles)

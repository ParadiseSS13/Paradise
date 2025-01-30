/mob/living/simple_animal/nian_caterpillar
	name = "nian caterpillar"
	icon = 'icons/mob/monkey.dmi'
	icon_state = "mothroach"
	icon_living = "mothroach"
	icon_dead = "mothroach_dead"
	icon_resting = "mothroach_sleep"
	pass_flags = PASSTABLE | PASSMOB
	mob_biotypes = MOB_ORGANIC | MOB_BUG
	mob_size = MOB_SIZE_SMALL
	ventcrawler = VENTCRAWLER_ALWAYS
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	butcher_results = list(/obj/item/food/meat = 1)
	minbodytemp = 0

	blood_color = "#b9ae9c"

	maxHealth = 50
	health = 50
	speed = 0.75
	stop_automated_movement = FALSE
	turns_per_move = 4

	// What they sound like
	voice_name = "nian caterpillar"
	speak_emote = list("flutters", "chitters", "chatters")
	emote_hear = list("flutters", "chitters", "chatters")
	emote_see = list("flutters", "chitters", "chatters")

	// Special verbs for when someone interacts with a caterpillar
	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "kicks"

	// Xenobiology and cargo are the only ways to get the caterpillar.
	gold_core_spawnable = FRIENDLY_SPAWN

	melee_damage_lower = 5
	melee_damage_upper = 8
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'

	holder_type = /obj/item/holder/nian_caterpillar
	can_collar = TRUE

	/// Evolution action.
	var/datum/action/innate/nian_caterpillar_emerge/evolve_action = new()
	/// The amount of nutrition the nian caterpillar needs to evolve, default is 500.
	var/nutrition_need = 500

/mob/living/simple_animal/nian_caterpillar/Initialize(mapload)
	. = ..()
	real_name = name
	add_language("Tkachi")
	evolve_action.Grant(src)

/mob/living/simple_animal/nian_caterpillar/proc/evolve(obj/structure/moth_cocoon/C, datum/mind/M)
	if(stat != CONSCIOUS)
		return FALSE

	// A changeling caterpillar shouldn't be restricted from evolving.
	// A caterpillar needs to consume food-- similar to a dioan nymph --to evolve.
	if((nutrition < nutrition_need) && !IS_CHANGELING(M))
		to_chat(src, "<span class='warning'>You need to binge on food in order to have the energy to evolve...</span>")
		return

	if(master_commander)
		to_chat(src, "<span class='userdanger'>As you evolve, your mind grows out of it's restraints. You are no longer loyal to [master_commander]!</span>")

	// Worme is the lesser form of nian. The caterpillar evolves into this lesser form.
	var/mob/living/carbon/human/nian_worme/adult = new(get_turf(loc))

	if(istype(loc, /obj/item/holder/nian_caterpillar))
		var/turf/cocoon_turf = get_turf(loc)
		qdel(loc)
		forceMove(cocoon_turf)

	for(var/datum/language/L in languages)
		adult.add_language(L.name)
	adult.regenerate_icons()
	adult.name = name
	adult.real_name = name

	// Mind transfer to new worme.
	M.transfer_to(adult)
	// [Caterpillar -> worme -> nian] is from xenobio (or cargo) and does not give vampires usuble blood and cannot be converted by cult.
	ADD_TRAIT(adult.mind, TRAIT_XENOBIO_SPAWNED_HUMAN, ROUNDSTART_TRAIT)

	// Worme is placed into cacoon.
	adult.forceMove(C)
	C.preparing_to_emerge = TRUE
	adult.apply_status_effect(STATUS_EFFECT_COCOONED)
	adult.KnockOut() // Zzzz
	adult.create_log(MISC_LOG, "has woven a cocoon")

	// For any random generated names. This is for when a new nian caterpillar is spawned.
	// [ nian caterpillar (042) ] etc.
	if(findtext(adult.real_name, "nian caterpillar"))
		adult.real_name = adult.dna.species.get_random_name()
		adult.name = adult.real_name
	for(var/obj/item/W in contents)
		drop_item_to_ground(W)

	qdel(src)
	return TRUE

/mob/living/simple_animal/nian_caterpillar/proc/consume(obj/item/food/G)
	if(nutrition >= nutrition_need) // Prevents griefing by overeating food items without evolving.
		return to_chat(src, "<span class='warning'>You're too full to consume this! Perhaps it's time to grow bigger...</span>")
	visible_message("<span class='warning'>[src] ravenously consumes [G].</span>", "<span class='notice'>You ravenously devour [G].</span>")
	playsound(loc, 'sound/items/eatfood.ogg', 30, TRUE, frequency = 1.5)
	if(G.reagents.get_reagent_amount("nutriment") + G.reagents.get_reagent_amount("plantmatter") < 1)
		adjust_nutrition(2)
	else
		adjust_nutrition((G.reagents.get_reagent_amount("nutriment") + G.reagents.get_reagent_amount("plantmatter")) * 2)
	qdel(G)

/mob/living/simple_animal/nian_caterpillar/attack_hand(mob/living/carbon/human/M)
	// Let people pick the little buggers up.
	if(M.a_intent != INTENT_HELP)
		return ..()
	if(isrobot(M))
		M.visible_message("<span class='notice'>[M] playfully boops [src] on the head!</span>", "<span class='notice'>You playfully boop [src] on the head!</span>")
	else
		get_scooped(M)

/mob/living/simple_animal/nian_caterpillar/attacked_by__legacy__attackchain(obj/item/I, mob/living/user, def_zone)
	if(istype(I, /obj/item/melee/flyswatter) && I.force)
		gib() // Commit die.
	else
		..()

/datum/action/innate/nian_caterpillar_emerge
	name = "Evolve"
	desc = "Weave a cocoon around yourself to evolve into a greater form. The worme."
	button_overlay_icon = 'icons/effects/effects.dmi'
	button_overlay_icon_state = "cocoon1"

/datum/action/innate/nian_caterpillar_emerge/proc/emerge(obj/structure/moth_cocoon/C)
	for(var/mob/living/carbon/human/H in C)
		H.remove_status_effect(STATUS_EFFECT_COCOONED)
		H.remove_status_effect(STATUS_EFFECT_BURNT_WINGS)
	C.preparing_to_emerge = FALSE
	qdel(C)

/datum/action/innate/nian_caterpillar_emerge/Activate()
	var/mob/living/simple_animal/nian_caterpillar/user = owner

	user.visible_message("<span class='notice'>[user] begins to hold still and concentrate on weaving a cocoon...</span>", "<span class='notice'>You begin to focus on weaving a cocoon... (This will take [COCOON_WEAVE_DELAY / 10] seconds, and you must hold still.)</span>")
	if(do_after(user, COCOON_WEAVE_DELAY, FALSE, user))
		var/obj/structure/moth_cocoon/C = new(get_turf(user))
		var/datum/mind/H = user.mind
		user.evolve(C, H)
		addtimer(CALLBACK(src, PROC_REF(emerge), C), COCOON_EMERGE_DELAY, TIMER_UNIQUE)

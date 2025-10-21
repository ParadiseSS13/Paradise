//Cat
/mob/living/simple_animal/pet/cat
	name = "cat"
	desc = "Kitty!!"
	icon_state = "cat2"
	icon_living = "cat2"
	icon_dead = "cat2_dead"
	icon_resting = "cat2_rest"
	gender = MALE
	speak = list("Meow!", "Esp!", "Purr!", "HSSSSS")
	speak_emote = list("purrs", "meows")
	emote_hear = list("meows", "mews")
	emote_see = list("shakes its head", "shivers")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	animal_species = /mob/living/simple_animal/pet/cat
	childtype = list(/mob/living/simple_animal/pet/cat/kitten)
	butcher_results = list(/obj/item/food/meat = 3)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	gold_core_spawnable = FRIENDLY_SPAWN
	var/turns_since_scan = 0
	var/mob/living/basic/mouse/movement_target
	var/eats_mice = 1
	var/collar_icon_state = "cat"
	footstep_type = FOOTSTEP_MOB_CLAW

/mob/living/simple_animal/pet/cat/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/wears_collar, collar_icon_state_ = collar_icon_state, collar_resting_icon_state_ = TRUE)

//RUNTIME IS ALIVE! SQUEEEEEEEE~
/mob/living/simple_animal/pet/cat/runtime
	name = "Runtime"
	desc = "GCAT."
	icon_state = "cat"
	icon_living = "cat"
	icon_dead = "cat_dead"
	icon_resting = "cat_rest"
	gender = FEMALE
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE
	var/list/family = list()
	var/list/children = list() //Actual mob instances of children

/mob/living/simple_animal/pet/cat/runtime/Initialize(mapload)
	. = ..()
	SSpersistent_data.register(src)

/mob/living/simple_animal/pet/cat/runtime/Destroy()
	SSpersistent_data.registered_atoms -= src
	return ..()

/mob/living/simple_animal/pet/cat/runtime/persistent_load()
	read_memory()
	deploy_the_cats()

/mob/living/simple_animal/pet/cat/runtime/persistent_save()
	if(SEND_SIGNAL(src, COMSIG_LIVING_WRITE_MEMORY) & COMPONENT_DONT_WRITE_MEMORY)
		return FALSE
	write_memory(FALSE)

/mob/living/simple_animal/pet/cat/runtime/make_babies()
	var/mob/baby = ..()
	if(baby)
		children += baby
		return baby

/mob/living/simple_animal/pet/cat/runtime/death()
	if(can_die())
		write_memory(TRUE)
	return ..()

/mob/living/simple_animal/pet/cat/runtime/proc/read_memory()
	var/savefile/S = new /savefile("data/npc_saves/Runtime.sav")
	S["family"] 			>> family

	if(isnull(family))
		family = list()
	log_debug("Persistent data for [src] loaded (family: [family ? list2params(family) : "None"])")

/mob/living/simple_animal/pet/cat/runtime/proc/write_memory(dead)
	var/savefile/S = new /savefile("data/npc_saves/Runtime.sav")
	family = list()
	if(!dead)
		for(var/mob/living/simple_animal/pet/cat/kitten/C in children)
			if(istype(C,type) || C.stat || !C.z || !C.butcher_results)
				continue
			if(C.type in family)
				family[C.type] += 1
			else
				family[C.type] = 1
	S["family"]				<< family
	log_debug("Persistent data for [src] saved (family: [family ? list2params(family) : "None"])")

/mob/living/simple_animal/pet/cat/runtime/proc/deploy_the_cats()
	for(var/cat_type in family)
		if(family[cat_type] > 0)
			for(var/i in 1 to min(family[cat_type],100)) //Limits to about 500 cats, you wouldn't think this would be needed (BUT IT IS)
				new cat_type(loc)

/mob/living/simple_animal/pet/cat/npc_safe(mob/user)
	return TRUE

/mob/living/simple_animal/pet/cat/Life()
	..()
	make_babies()

/mob/living/simple_animal/pet/cat/verb/sit()
	set name = "Sit Down"
	set category = "IC"

	if(resting)
		resting = FALSE
		stand_up()
		return

	lay_down()
	resting = TRUE
	custom_emote(EMOTE_VISIBLE, pick("sits down.", "crouches on its hind legs.", "looks alert."))
	icon_state = "[icon_living]_sit"

/mob/living/simple_animal/pet/cat/handle_automated_action()
	if(stat == CONSCIOUS && !buckled)
		if(prob(1))
			custom_emote(EMOTE_VISIBLE, pick("stretches out for a belly rub.", "wags its tail.", "lies down."))
			lay_down()
		else if(prob(1))
			sit()
		else if(prob(1))
			if(IS_HORIZONTAL(src))
				custom_emote(EMOTE_VISIBLE, pick("gets up and meows.", "walks around.", "stops resting."))
				stand_up()
			else
				custom_emote(EMOTE_VISIBLE, pick("grooms its fur.", "twitches its whiskers.", "shakes out its coat."))

	//MICE!
	if(eats_mice && isturf(loc) && !incapacitated())
		for(var/mob/living/basic/mouse/M in view(1, src))
			if(!M.stat && Adjacent(M))
				custom_emote(EMOTE_VISIBLE, "splats \the [M]!")
				M.death()
				M.splat()
				movement_target = null
				walk(src, 0)
				stop_automated_movement = FALSE
				break
		for(var/obj/item/toy/cattoy/T in view(1, src))
			if(T.cooldown < (world.time - 400))
				custom_emote(EMOTE_VISIBLE, "bats \the [T] around with its paw!")
				T.cooldown = world.time

/mob/living/simple_animal/pet/cat/handle_automated_movement()
	. = ..()
	if(stat || IS_HORIZONTAL(src) || buckled)
		return

	turns_since_scan++
	if(turns_since_scan > 5)
		GLOB.move_manager.stop_looping(src)
		turns_since_scan = 0
	if((movement_target) && !(isturf(movement_target.loc) || ishuman(movement_target.loc)))
		movement_target = null
		stop_automated_movement = FALSE
	if(!movement_target || !(movement_target.loc in oview(src, 3)))
		movement_target = null
		stop_automated_movement = FALSE
		walk(src, 0)
		for(var/mob/living/basic/mouse/snack in oview(src,3))
			if(isturf(snack.loc) && !snack.stat)
				movement_target = snack
				break
	if(movement_target)
		stop_automated_movement = TRUE
		GLOB.move_manager.move_to(src, movement_target, 0, 3)

/mob/living/simple_animal/pet/cat/proc_cat
	name = "Proc"
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE

/mob/living/simple_animal/pet/cat/var_cat
	name = "Var"
	desc = "Maintenance Cat!"
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/pet/cat/kitten
	name = "kitten"
	desc = "D'aaawwww."
	icon_state = "kitten"
	icon_living = "kitten"
	icon_dead = "kitten_dead"
	icon_resting = "kitten_rest"
	gender = NEUTER
	density = FALSE
	pass_flags = PASSMOB
	collar_icon_state = "kitten"

/mob/living/simple_animal/pet/cat/syndi
	name = "SyndiCat"
	desc = "It's a SyndiCat droid."
	icon_state = "Syndicat"
	icon_living = "Syndicat"
	icon_dead = "Syndicat_dead"
	icon_resting = "Syndicat_rest"
	gender = FEMALE
	faction = list("syndicate")
	gold_core_spawnable = NO_SPAWN
	eats_mice = 0
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	melee_damage_lower = 5
	melee_damage_upper = 15

/mob/living/simple_animal/pet/cat/syndi/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NOBREATH, SPECIES_TRAIT)

/mob/living/simple_animal/pet/cat/syndi/npc_safe(mob/user)
	if(GAMEMODE_IS_NUCLEAR)
		return TRUE
	return FALSE

/mob/living/simple_animal/pet/cat/cak
	name = "Keeki"
	desc = "It's a cat made out of cake."
	icon_state = "cak"
	icon_living = "cak"
	icon_resting = "cak_rest"
	icon_dead = "cak_dead"
	health = 50
	maxHealth = 50
	harm_intent_damage = 10
	butcher_results = list(
		/obj/item/organ/internal/brain = 1,
		/obj/item/organ/internal/heart = 1,
		/obj/item/food/sliced/birthday_cake = 3,
		/obj/item/food/meat/slab = 2
	)
	response_harm = "takes a bite out of"
	attacked_sound = "sound/items/eatfood.ogg"
	deathmessage = "loses its false life and collapses!"
	death_sound = "bodyfall"
	/// Number of times the corpse has been bitten
	var/final_bites = 0
	// In practice, this is one less than it appears, because final_bites
	// gets incremented by the bite that kills Keeki.  So total_final_bites
	// of 6 means that the 5th bite post-death will finish off Keeki.
	var/total_final_bites = 6

/mob/living/simple_animal/pet/cat/cak/Life()
	..()
	if(stat)
		return
	final_bites = 0
	if(health < maxHealth)
		adjustBruteLoss(-4)
	for(var/obj/item/food/donut/D in range(1, src))
		if(D.icon_state != "donut2")
			D.name = "frosted donut"
			D.icon_state = "donut2"
			D.reagents.add_reagent("sprinkles", 2)
			D.filling_color = "#FF69B4"

/mob/living/simple_animal/pet/cat/cak/attack_hand(mob/living/L)
	..()
	if(L.a_intent != INTENT_HARM && L.a_intent != INTENT_DISARM)
		return
	if(!L.reagents)
		return

	if(stat == DEAD)
		if(++final_bites >= total_final_bites)
			visible_message("<span class='danger'>[L] finished eating [src], there's nothing left!</span>")
			to_chat(L, "<span class='notice'>Whoa, that last bite tasted weird.</span>")
			L.reagents.add_reagent("teslium", 5)
			qdel(src)

	L.reagents.add_reagent("nutriment", 0.4)
	L.reagents.add_reagent("vitamin", 0.4)

/mob/living/simple_animal/pet/cat/cak/CheckParts(list/parts)
	..()
	var/obj/item/organ/internal/brain/B = locate(/obj/item/organ/internal/brain) in contents
	if(!B || !B.brainmob || !B.brainmob.mind)
		return
	B.brainmob.mind.transfer_to(src)
	to_chat(src, "<span class='big bold'>You are a cak!</span><b> You're a harmless cat/cake hybrid that everyone loves. People can take bites out of you if they're hungry, but you regenerate health \
	so quickly that it generally doesn't matter. You're remarkably resilient to any damage besides this and it's hard for you to really die at all. You should go around and bring happiness and \
	free cake to the station!</b>")
	var/new_name = tgui_input_text(src, "Enter your name, or press \"Cancel\" to stick with Keeki.", "Name Change", name)
	if(!new_name)
		return
	to_chat(src, "<span class='notice'>Your name is now <b>\"[new_name]\"</b>!</span>")
	name = new_name

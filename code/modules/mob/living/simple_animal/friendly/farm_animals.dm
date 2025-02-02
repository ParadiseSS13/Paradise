//goat
/mob/living/simple_animal/hostile/retaliate/goat
	name = "goat"
	desc = "Not known for their pleasant disposition."
	icon_state = "goat"
	icon_living = "goat"
	icon_dead = "goat_dead"
	speak = list("EHEHEHEHEH","eh?")
	speak_emote = list("brays")
	emote_hear = list("brays")
	emote_see = list("shakes its head", "stamps a foot", "glares around")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	butcher_results = list(/obj/item/food/meat = 4)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	faction = list("neutral", "jungle")
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	attack_same = TRUE
	attacktext = "kicks"
	attack_sound = 'sound/weapons/punch1.ogg'
	health = 40
	maxHealth = 40
	melee_damage_lower = 1
	melee_damage_upper = 2
	stop_automated_movement_when_pulled = TRUE
	can_collar = TRUE
	blood_volume = BLOOD_VOLUME_NORMAL
	var/obj/item/udder/cow/udder = null
	gender = FEMALE
	footstep_type = FOOTSTEP_MOB_SHOE

/mob/living/simple_animal/hostile/retaliate/goat/Initialize(mapload)
	. = ..()
	udder = new()

/mob/living/simple_animal/hostile/retaliate/goat/Destroy()
	QDEL_NULL(udder)
	return ..()

/mob/living/simple_animal/hostile/retaliate/goat/handle_automated_movement()
	. = ..()
	//chance to go crazy and start wacking stuff
	if(!length(enemies) && prob(1))
		Retaliate()

	if(length(enemies) && prob(10))
		enemies = list()
		LoseTarget()
		visible_message("<span class='notice'>[src] calms down.</span>")

	eat_plants()
	if(!pulledby)
		for(var/direction in shuffle(GLOB.alldirs))
			var/step = get_step(src, direction)
			if(step)
				if(locate(/obj/structure/spacevine) in step || locate(/obj/structure/glowshroom) in step)
					Move(step, get_dir(src, step))

/mob/living/simple_animal/hostile/retaliate/goat/Life(seconds, times_fired)
	. = ..()
	if(stat == CONSCIOUS)
		udder.generateMilk()

/mob/living/simple_animal/hostile/retaliate/goat/Retaliate()
	..()
	visible_message("<span class='danger'>[src] gets an evil-looking gleam in their eye.</span>")

/mob/living/simple_animal/hostile/retaliate/goat/Move()
	. = ..()
	if(stat == CONSCIOUS)
		eat_plants()

/mob/living/simple_animal/hostile/retaliate/goat/attackby__legacy__attackchain(obj/item/O as obj, mob/user as mob, params)
	if(stat == CONSCIOUS && istype(O, /obj/item/reagent_containers/glass))
		udder.milkAnimal(O, user)
	else
		return ..()

/mob/living/simple_animal/hostile/retaliate/goat/proc/eat_plants()
	var/eaten = FALSE
	var/obj/structure/spacevine/SV = locate(/obj/structure/spacevine) in loc
	if(SV)
		SV.eat(src)
		eaten = TRUE

	var/obj/structure/glowshroom/GS = locate(/obj/structure/glowshroom) in loc
	if(GS)
		qdel(GS)
		eaten = TRUE

	if(eaten && prob(10))
		say("Nom")

/mob/living/simple_animal/hostile/retaliate/goat/AttackingTarget()
	. = ..()
	if(. && isdiona(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/NB = pick(H.bodyparts)
		H.visible_message("<span class='warning'>[src] takes a big chomp out of [H]!</span>", "<span class='userdanger'>[src] takes a big chomp out of your [NB.name]!</span>")
		NB.droplimb()

/mob/living/simple_animal/hostile/retaliate/goat/chef
	name = "Pete"
	desc = "Pete, the Chef's pet goat from the Caribbean. Not known for their pleasant disposition."
	unique_pet = TRUE

//cow
/mob/living/simple_animal/cow
	name = "cow"
	desc = "Known for their milk, just don't tip them over."
	icon_state = "cow"
	icon_living = "cow"
	icon_dead = "cow_dead"
	icon_gib = "cow_gib"
	speak = list("Moo?","Moo","MOOOOOO")
	speak_emote = list("moos","moos hauntingly")
	emote_hear = list("brays")
	emote_see = list("shakes its head")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	butcher_results = list(/obj/item/food/meat/slab = 6)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	attacktext = "kicks"
	attack_sound = 'sound/weapons/punch1.ogg'
	health = 50
	maxHealth = 50
	can_collar = TRUE
	gold_core_spawnable = FRIENDLY_SPAWN
	blood_volume = BLOOD_VOLUME_NORMAL
	var/obj/item/udder/cow/udder = null
	gender = FEMALE
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	footstep_type = FOOTSTEP_MOB_SHOE

/mob/living/simple_animal/cow/Initialize(mapload)
	udder = new()
	. = ..()

/mob/living/simple_animal/cow/Destroy()
	QDEL_NULL(udder)
	return ..()

/mob/living/simple_animal/cow/attackby__legacy__attackchain(obj/item/O, mob/user, params)
	if(stat == CONSCIOUS && istype(O, /obj/item/reagent_containers/glass))
		udder.milkAnimal(O, user)
		return TRUE
	else
		return ..()

/mob/living/simple_animal/cow/Life(seconds, times_fired)
	. = ..()
	if(stat == CONSCIOUS)
		udder.generateMilk()

/mob/living/simple_animal/cow/attack_hand(mob/living/carbon/M as mob)
	if(stat == CONSCIOUS && M.a_intent == INTENT_DISARM && icon_state != icon_dead)
		M.visible_message("<span class='warning'>[M] tips over [src].</span>","<span class='notice'>You tip over [src].</span>")
		Weaken(60 SECONDS)
		icon_state = icon_dead
		spawn(rand(20,50))
			if(stat == CONSCIOUS && M)
				icon_state = icon_living
				var/list/responses = list(
					"[src] looks at you imploringly.",
					"[src] looks at you pleadingly",
					"[src] looks at you with a resigned expression.",
					"[src] seems resigned to its fate."
				)
				to_chat(M, pick(responses))
	else
		..()


/mob/living/simple_animal/cow/npc_safe(mob/user)
	return TRUE

/mob/living/simple_animal/cow/betsy
	name = "Betsy"
	real_name = "Betsy"
	unique_pet = TRUE

/mob/living/simple_animal/cow/betsy/npc_safe(mob/user) // depriving the chef of his animals is not cool
	return FALSE

/mob/living/simple_animal/chick
	name = "chick"
	desc = "Adorable! They make such a racket though."
	icon_state = "chick"
	icon_living = "chick"
	icon_dead = "chick_dead"
	icon_gib = "chick_gib"
	gender = FEMALE
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	speak = list("Cherp.","Cherp?","Chirrup.","Cheep!")
	speak_emote = list("cheeps")
	emote_hear = list("cheeps")
	emote_see = list("pecks at the ground","flaps its tiny wings")
	density = FALSE
	speak_chance = 2
	turns_per_move = 2
	butcher_results = list(/obj/item/food/meat/chicken = 1)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	attacktext = "kicks"
	health = 3
	maxHealth = 3
	ventcrawler = VENTCRAWLER_ALWAYS
	var/amount_grown = 0
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	holder_type = /obj/item/holder/chicken
	can_hide = TRUE
	can_collar = TRUE
	gold_core_spawnable = FRIENDLY_SPAWN
	footstep_type = FOOTSTEP_MOB_CLAW

/mob/living/simple_animal/chick/Initialize(mapload)
	. = ..()
	scatter_atom()

/mob/living/simple_animal/chick/scatter_atom(x_offset, y_offset)
	pixel_x = rand(-6, 6) + x_offset
	pixel_y = rand(0, 10) + y_offset

/mob/living/simple_animal/chick/Life(seconds, times_fired)
	. =..()
	if(.)
		amount_grown += rand(1,2)
		if(amount_grown >= 100)
			var/mob/living/simple_animal/chicken/C = new /mob/living/simple_animal/chicken(loc)
			if(name != initial(name))
				C.name = name
			if(mind)
				mind.transfer_to(C)
			if(pcollar)
				var/the_collar = pcollar
				drop_item_to_ground(pcollar)
				C.add_collar(the_collar)
			qdel(src)


/mob/living/simple_animal/chick/npc_safe(mob/user)
	return TRUE

/mob/living/simple_animal/chick/attack_hand(mob/living/carbon/human/M)
	if(M.a_intent == INTENT_HELP)
		get_scooped(M, TRUE)
	..()

#define MAX_CHICKENS 50
GLOBAL_VAR_INIT(chicken_count, 0)

/mob/living/simple_animal/chicken
	name = "chicken"
	desc = "Hopefully the eggs are good this season."
	gender = FEMALE
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	icon_state = "chicken_brown"
	icon_living = "chicken_brown"
	icon_dead = "chicken_brown_dead"
	speak = list("Cluck!","BWAAAAARK BWAK BWAK BWAK!","Bwaak bwak.")
	speak_emote = list("clucks","croons")
	emote_hear = list("clucks")
	emote_see = list("pecks at the ground","flaps its wings viciously")
	density = FALSE
	speak_chance = 2
	turns_per_move = 3
	butcher_results = list(/obj/item/food/meat/chicken = 2)
	var/egg_type = /obj/item/food/egg
	var/food_type = /obj/item/food/grown/wheat
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	attacktext = "kicks"
	health = 15
	maxHealth = 15
	ventcrawler = VENTCRAWLER_ALWAYS
	var/eggsleft = 0
	var/eggsFertile = TRUE
	var/body_color
	var/icon_prefix = "chicken"
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	holder_type = /obj/item/holder/chicken
	can_hide = TRUE
	can_collar = TRUE
	var/list/feedMessages = list("It clucks happily.","It clucks happily.")
	var/list/layMessage = EGG_LAYING_MESSAGES
	var/list/validColors = list("brown","black","white")
	gold_core_spawnable = FRIENDLY_SPAWN
	footstep_type = FOOTSTEP_MOB_CLAW

/mob/living/simple_animal/chicken/Initialize(mapload)
	. = ..()
	if(!body_color)
		body_color = pick(validColors)
	icon_state = "[icon_prefix]_[body_color]"
	icon_living = "[icon_prefix]_[body_color]"
	icon_dead = "[icon_prefix]_[body_color]_dead"
	scatter_atom()
	update_appearance(UPDATE_ICON_STATE)
	GLOB.chicken_count += 1

/mob/living/simple_animal/chick/scatter_atom(x_offset, y_offset)
	pixel_x = rand(-6, 6) + x_offset
	pixel_y = rand(0, 10) + y_offset

/mob/living/simple_animal/chicken/death(gibbed)
	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return
	GLOB.chicken_count -= 1

/mob/living/simple_animal/chicken/attackby__legacy__attackchain(obj/item/O, mob/user, params)
	if(istype(O, food_type)) //feedin' dem chickens
		if(stat == CONSCIOUS && eggsleft < 8)
			var/feedmsg = "[user] feeds [O] to [name]! [pick(feedMessages)]"
			user.visible_message(feedmsg)
			user.drop_item()
			qdel(O)
			eggsleft += rand(1, 4)
			//world << eggsleft
		else
			to_chat(user, "<span class='warning'>[name] doesn't seem hungry!</span>")
	else
		..()

/mob/living/simple_animal/chicken/attack_hand(mob/living/carbon/human/M)
	if(M.a_intent == INTENT_HELP)
		get_scooped(M, TRUE)
	..()

/mob/living/simple_animal/chicken/Life(seconds, times_fired)
	. = ..()
	if((. && prob(3) && eggsleft > 0) && egg_type)
		visible_message("[src] [pick(layMessage)]")
		eggsleft--
		var/obj/item/E = new egg_type(get_turf(src))
		E.scatter_atom()
		if(eggsFertile)
			if(GLOB.chicken_count < MAX_CHICKENS && prob(25))
				START_PROCESSING(SSobj, E)

/obj/item/food/egg/process()
	if(isturf(loc))
		amount_grown += rand(1,2)
		if(amount_grown >= 100)
			visible_message("[src] hatches with a quiet cracking sound.")
			new /mob/living/simple_animal/chick(get_turf(src))
			STOP_PROCESSING(SSobj, src)
			qdel(src)
	else
		STOP_PROCESSING(SSobj, src)

/mob/living/simple_animal/chicken/npc_safe(mob/user)
	return TRUE

/mob/living/simple_animal/chicken/clucky
	name = "Commander Clucky"
	real_name = "Commander Clucky"
	unique_pet = TRUE

/mob/living/simple_animal/chicken/clucky/npc_safe(mob/user) // depriving the chef of his animals is not cool
	return FALSE

/mob/living/simple_animal/chicken/kentucky
	name = "Kentucky"
	real_name = "Kentucky"
	unique_pet = TRUE

/mob/living/simple_animal/chicken/kentucky/npc_safe(mob/user)
	return FALSE

/mob/living/simple_animal/chicken/featherbottom
	name = "Featherbottom"
	real_name = "Featherbottom"
	unique_pet = TRUE

/mob/living/simple_animal/chicken/featherbottom/npc_safe(mob/user)
	return FALSE

/mob/living/simple_animal/pig
	name = "pig"
	desc = "Oink oink."
	icon_state = "pig"
	icon_living = "pig"
	icon_dead = "pig_dead"
	speak = list("oink?","oink","OINK")
	speak_emote = list("oinks")
//	emote_hear = list("brays")
	emote_see = list("rolls around")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	butcher_results = list(/obj/item/food/meat/ham = 6)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	attacktext = "kicks"
	health = 50
	maxHealth = 50
	can_collar = TRUE
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	gold_core_spawnable = FRIENDLY_SPAWN
	blood_volume = BLOOD_VOLUME_NORMAL
	footstep_type = FOOTSTEP_MOB_SHOE

/mob/living/simple_animal/turkey
	name = "turkey"
	desc = "Benjamin Franklin would be proud."
	icon_state = "turkey"
	icon_living = "turkey"
	icon_dead = "turkey_dead"
	icon_resting = "turkey_rest"
	speak = list("gobble?","gobble","GOBBLE")
	speak_emote = list("gobble")
	emote_see = list("struts around")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	butcher_results = list(/obj/item/food/meat = 4)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	attacktext = "pecks"
	health = 50
	maxHealth = 50
	can_collar = TRUE
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	gold_core_spawnable = FRIENDLY_SPAWN
	footstep_type = FOOTSTEP_MOB_CLAW

/mob/living/simple_animal/goose
	name = "goose"
	desc = "A pretty goose. Would make a nice comforter."
	icon_state = "goose"
	icon_living = "goose"
	icon_dead = "goose_dead"
	speak = list("quack?","quack","QUACK")
	speak_emote = list("quacks")
//	emote_hear = list("brays")
	emote_see = list("flaps it's wings")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	butcher_results = list(/obj/item/food/meat = 6)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	attacktext = "kicks"
	health = 50
	maxHealth = 50
	can_collar = TRUE
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	gold_core_spawnable = FRIENDLY_SPAWN
	footstep_type = FOOTSTEP_MOB_CLAW

/mob/living/simple_animal/seal
	name = "seal"
	desc = "A beautiful white seal."
	icon_state = "seal"
	icon_living = "seal"
	icon_dead = "seal_dead"
	speak = list("Urk?","urk","URK")
	speak_emote = list("urks")
//	emote_hear = list("brays")
	emote_see = list("flops around")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	butcher_results = list(/obj/item/food/meat = 6)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	attacktext = "kicks"
	health = 50
	maxHealth = 50
	can_collar = TRUE
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	gold_core_spawnable = FRIENDLY_SPAWN
	blood_volume = BLOOD_VOLUME_NORMAL

/mob/living/simple_animal/walrus
	name = "walrus"
	desc = "A big brown walrus."
	icon_state = "walrus"
	icon_living = "walrus"
	icon_dead = "walrus_dead"
	speak = list("Urk?","urk","URK")
	speak_emote = list("urks")
//	emote_hear = list("brays")
	emote_see = list("flops around")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	butcher_results = list(/obj/item/food/meat = 6)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	attacktext = "kicks"
	health = 50
	maxHealth = 50
	can_collar = TRUE
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	gold_core_spawnable = FRIENDLY_SPAWN
	blood_volume = BLOOD_VOLUME_NORMAL

/obj/item/udder
	name = "udder"

/obj/item/udder/Initialize(mapload)
	. = ..()
	create_reagents(50)

/obj/item/udder/proc/generateMilk()
	if(prob(5))
		reagents.add_reagent("milk", rand(5, 10))

/obj/item/udder/proc/milkAnimal(obj/O, mob/user)
	var/obj/item/reagent_containers/glass/G = O
	if(G.reagents.total_volume >= G.volume)
		to_chat(user, "<span class='danger'>[O] is full.</span>")
		return
	var/transfered = reagents.trans_to(O, rand(5,10))
	if(transfered)
		user.visible_message("[user] milks [src] using \the [O].", "<span class='notice'>You milk [src] using \the [O].</span>")
	else
		to_chat(user, "<span class='danger'>The udder is dry. Wait a bit longer...</span>")

/obj/item/udder/cow

/obj/item/udder/cow/Initialize(mapload)
	. = ..()
	reagents.add_reagent("milk", 20)

#undef MAX_CHICKENS

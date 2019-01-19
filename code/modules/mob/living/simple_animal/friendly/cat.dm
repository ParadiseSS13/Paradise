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
	mob_size = MOB_SIZE_SMALL
	simplespecies = /mob/living/simple_animal/pet/cat
	childtype = /mob/living/simple_animal/pet/cat/kitten
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat = 3)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	gold_core_spawnable = CHEM_MOB_SPAWN_FRIENDLY

	var/turns_since_scan = 0
	var/mob/living/simple_animal/mouse/movement_target
	var/eats_mice = 1

//RUNTIME IS ALIVE! SQUEEEEEEEE~
/mob/living/simple_animal/pet/cat/Runtime
	name = "Runtime"
	desc = "GCAT"
	icon_state = "cat"
	icon_living = "cat"
	icon_dead = "cat_dead"
	icon_resting = "cat_rest"
	gender = FEMALE
	gold_core_spawnable = CHEM_MOB_SPAWN_INVALID
	var/list/family = list()
	var/memory_saved = 0
	var/list/children = list() //Actual mob instances of children
	var/cats_deployed = 0

/mob/living/simple_animal/pet/cat/Runtime/New()
	Read_Memory()
	..()

/mob/living/simple_animal/pet/cat/Runtime/Life(seconds, times_fired)
	if(!cats_deployed && ticker.current_state >= GAME_STATE_SETTING_UP)
		Deploy_The_Cats()
	if(!stat && ticker.current_state == GAME_STATE_FINISHED && !memory_saved)
		Write_Memory()
	..()

/mob/living/simple_animal/pet/cat/Runtime/make_babies()
	var/mob/baby = ..()
	if(baby)
		children += baby
		return baby

/mob/living/simple_animal/pet/cat/Runtime/death()
	if(can_die() && !memory_saved)
		Write_Memory(1)
	return ..()

/mob/living/simple_animal/pet/cat/Runtime/proc/Read_Memory()
	var/savefile/S = new /savefile("data/npc_saves/Runtime.sav")
	S["family"] 			>> family

	if(isnull(family))
		family = list()

/mob/living/simple_animal/pet/cat/Runtime/proc/Write_Memory(dead)
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
	memory_saved = 1

/mob/living/simple_animal/pet/cat/Runtime/proc/Deploy_The_Cats()
	cats_deployed = 1
	for(var/cat_type in family)
		if(family[cat_type] > 0)
			for(var/i in 1 to min(family[cat_type],100)) //Limits to about 500 cats, you wouldn't think this would be needed (BUT IT IS)
				new cat_type(loc)


/mob/living/simple_animal/pet/cat/handle_automated_action()
	..()
	if(prob(1))
		custom_emote(1, pick("stretches out for a belly rub.", "wags its tail.", "lies down."))
		icon_state = "[icon_living]_rest"
		resting = 1
		update_canmove()
	else if (prob(1))
		custom_emote(1, pick("sits down.", "crouches on its hind legs.", "looks alert."))
		icon_state = "[icon_living]_sit"
		resting = 1
		update_canmove()
	else if (prob(1))
		if (resting)
			custom_emote(1, pick("gets up and meows.", "walks around.", "stops resting."))
			icon_state = "[icon_living]"
			resting = 0
			update_canmove()
		else
			custom_emote(1, pick("grooms its fur.", "twitches its whiskers.", "shakes out its coat."))

	//MICE!
	if(eats_mice && isturf(loc) && !incapacitated())
		for(var/mob/living/simple_animal/mouse/M in view(1,src))
			if(!M.stat && Adjacent(M))
				custom_emote(1, "splats \the [M]!")
				M.splat()
				movement_target = null
				stop_automated_movement = 0
				break
	make_babies()

/mob/living/simple_animal/pet/cat/handle_automated_movement()
	..()
	if(!stat && !resting && !buckled)
		turns_since_scan++
		if(turns_since_scan > 5)
			walk_to(src,0)
			turns_since_scan = 0
			if((movement_target) && !(isturf(movement_target.loc) || ishuman(movement_target.loc) ))
				movement_target = null
				stop_automated_movement = 0
			if( !movement_target || !(movement_target.loc in oview(src, 3)) )
				movement_target = null
				stop_automated_movement = 0
				for(var/mob/living/simple_animal/mouse/snack in oview(src,3))
					if(isturf(snack.loc) && !snack.stat)
						movement_target = snack
						break
			if(movement_target)
				stop_automated_movement = 1
				walk_to(src,movement_target,0,3)


/mob/living/simple_animal/pet/cat/Proc
	name = "Proc"

/mob/living/simple_animal/pet/cat/kitten
	name = "kitten"
	desc = "D'aaawwww"
	icon_state = "kitten"
	icon_living = "kitten"
	icon_dead = "kitten_dead"
	icon_resting = null
	gender = NEUTER
	density = 0
	pass_flags = PASSMOB

/mob/living/simple_animal/pet/cat/Syndi
	name = "SyndiCat"
	desc = "It's a SyndiCat droid."
	icon_state = "Syndicat"
	icon_living = "Syndicat"
	icon_dead = "Syndicat_dead"
	icon_resting = "Syndicat_rest"
	gender = FEMALE
	mutations = list(BREATHLESS)
	faction = list("syndicate")
	gold_core_spawnable = CHEM_MOB_SPAWN_INVALID
	eats_mice = 0
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	melee_damage_lower = 5
	melee_damage_upper = 15

/mob/living/simple_animal/pet/cat/cak
	name = "Keeki"
	desc = "It's a cat made out of cake. It looks like a brain would fit into its head."
	icon_state = "cak"
	icon_living = "cak"
	icon_resting = "cak_rest"
	icon_dead = "cak_dead"
	health = 50
	maxHealth = 50
	harm_intent_damage = 10
	butcher_results = list(
		/obj/item/organ/internal/heart = 1, 
		/obj/item/reagent_containers/food/snacks/birthdaycakeslice = 3,  
		/obj/item/reagent_containers/food/snacks/meat = 2
	)
	response_harm = "takes a bite out of"
	attacked_sound = "sound/items/eatfood.ogg"
	deathmessage = "loses its false life and collapses!"
	death_sound = "bodyfall"
	var/obj/item/organ/internal/brain/brain = null

/mob/living/simple_animal/pet/cat/cak/Life()
	..()
	if(stat)
		return
	if(health < maxHealth)
		adjustBruteLoss(-4)
	for(var/obj/item/reagent_containers/food/snacks/donut/D in range(1, src))
		if(D.icon_state != "donut2")
			D.name = "frosted donut"
			D.icon_state = "donut2"
			D.reagents.add_reagent("sprinkles", 2)
			D.filling_color = "#FF69B4"

/mob/living/simple_animal/pet/cat/cak/attackby(obj/item/O, mob/living/user, params)
	if(istype(O, /obj/item/organ/internal/brain))
		var/obj/item/organ/internal/brain/B = O
		if(brain) //There's already a brain in it.
			to_chat(user, "<span class='warning'>There's already a brain in [src]!</span>")
			return
		if(!B.brainmob.key)
			var/ghost_can_reenter = 0
			if(B.brainmob.mind)
				for(var/mob/dead/observer/G in GLOB.player_list)
					if(G.can_reenter_corpse && G.mind == B.brainmob.mind)
						ghost_can_reenter = 1
						break
				for(var/mob/living/simple_animal/S in GLOB.player_list)
					if(S in GLOB.respawnable_list)
						ghost_can_reenter = 1
						break
			if(!ghost_can_reenter)
				to_chat(user, "<span class='notice'>[B] is completely unresponsive; there's no point.</span>")
				return

		to_chat(user, "<span class='notice'>You install [B] in [src]!</span>")

		user.drop_item()
		B.forceMove(src)
		brain = B
		transfer_personality(B)

		return 1


	if(istype(O, /obj/item/kitchen/knife))
		to_chat(user, "<span class='warning'>You cut out the brain from [src].</span>")
		eject_brain()
		return 1

	else if(user.a_intent == INTENT_HARM && user.reagents)
		user.reagents.add_reagent("nutriment", 0.4)
		user.reagents.add_reagent("vitamin", 0.4)

/mob/living/simple_animal/pet/cat/cak/proc/transfer_personality(obj/item/organ/internal/brain/B)
	mind = B.brainmob.mind
	mind.key = B.brainmob.key
	ckey = B.brainmob.ckey
	name = "Keeki"
	desc = "It's a cat made out of cake. It looks like a real brain is in it's head."
	rename_self("cake cat")

/mob/living/simple_animal/pet/cat/cak/proc/eject_brain()
	var/turf/T = get_turf(src)
	brain.forceMove(T)
	desc = "It's a cat made out of cake. It looks like a brain would fit into its head."
	if(mind)
		mind.transfer_to(brain.brainmob)
	brain = null
	name = "Keeki"
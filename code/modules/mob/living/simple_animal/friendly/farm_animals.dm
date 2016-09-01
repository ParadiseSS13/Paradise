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
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat = 4)
	response_help  = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm   = "kicks the"
	faction = list("neutral")
	attack_same = 1
	attacktext = "kicks"
	attack_sound = 'sound/weapons/punch1.ogg'
	health = 40
	maxHealth = 40
	melee_damage_lower = 1
	melee_damage_upper = 2
	stop_automated_movement_when_pulled = 1
	var/milk_content = 0
	can_collar = 1

/mob/living/simple_animal/hostile/retaliate/goat/handle_automated_movement()
	..()
	if(!pulledby)
		for(var/direction in shuffle(list(1,2,4,8,5,6,9,10)))
			var/step = get_step(src, direction)
			if(step)
				if(locate(/obj/effect/plant) in step)
					Move(step, get_dir(src, step))

/mob/living/simple_animal/hostile/retaliate/goat/handle_automated_action()
	//chance to go crazy and start wacking stuff
	if(!enemies.len && prob(1))
		Retaliate()

	if(enemies.len && prob(10))
		enemies = list()
		LoseTarget()
		src.visible_message("\blue [src] calms down.")

	if(locate(/obj/effect/plant) in loc)
		var/obj/effect/plant/SV = locate(/obj/effect/plant) in loc
		qdel(SV)
		if(prob(10))
			say("Nom")

/mob/living/simple_animal/hostile/retaliate/goat/Life()
	. = ..()
	if(stat == CONSCIOUS && prob(5))
		milk_content = min(50, milk_content+rand(5, 10))


/mob/living/simple_animal/hostile/retaliate/goat/Retaliate()
	..()
	src.visible_message("\red [src] gets an evil-looking gleam in their eye.")

/mob/living/simple_animal/hostile/retaliate/goat/Move()
	..()
	if(!stat)
		if(locate(/obj/effect/plant) in loc)
			var/obj/effect/plant/SV = locate(/obj/effect/plant) in loc
			qdel(SV)
			if(prob(10))
				say("Nom")

/mob/living/simple_animal/hostile/retaliate/goat/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	if(stat == CONSCIOUS && istype(O, /obj/item/weapon/reagent_containers/glass))
		user.changeNext_move(CLICK_CD_MELEE)
		var/obj/item/weapon/reagent_containers/glass/G = O
		var/transfered = min(milk_content, rand(5,10), (G.volume - G.reagents.total_volume))
		if(transfered > 0)
			user.visible_message("<span class='notice'>[user] milks [src] using \the [O].</span>")
			G.reagents.add_reagent("milk", transfered)
			milk_content -= transfered
		else if(G.reagents.total_volume >= G.volume)
			to_chat(user, "\red \The [O] is full.")
		else
			to_chat(user, "\red The udder is dry. Wait a bit longer...")
	else
		..()

//cow
/mob/living/simple_animal/cow
	name = "cow"
	desc = "Known for their milk, just don't tip them over."
	icon_state = "cow"
	icon_living = "cow"
	icon_dead = "cow_dead"
	icon_gib = "cow_gib"
	speak = list("moo?","moo","MOOOOOO")
	speak_emote = list("moos","moos hauntingly")
	emote_hear = list("brays")
	emote_see = list("shakes its head")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat/slab = 6)
	response_help  = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm   = "kicks the"
	attacktext = "kicks"
	attack_sound = 'sound/weapons/punch1.ogg'
	health = 50
	maxHealth = 50
	var/milk_content = 0
	can_collar = 1
	gold_core_spawnable = CHEM_MOB_SPAWN_FRIENDLY

/mob/living/simple_animal/cow/New()
	..()

/mob/living/simple_animal/cow/attackby(var/obj/item/O as obj, var/mob/user as mob, params, params)
	if(stat == CONSCIOUS && istype(O, /obj/item/weapon/reagent_containers/glass))
		user.changeNext_move(CLICK_CD_MELEE)
		var/obj/item/weapon/reagent_containers/glass/G = O
		var/transfered = min(milk_content, rand(5,10), (G.volume - G.reagents.total_volume))
		if(transfered > 0)
			user.visible_message("<span class='notice'>[user] milks [src] using \the [O].</span>")
			G.reagents.add_reagent("milk", transfered)
			milk_content -= transfered
		else if(G.reagents.total_volume >= G.volume)
			to_chat(user, "\red \The [O] is full.")
		else
			to_chat(user, "\red The udder is dry. Wait a bit longer...")
	else
		..()

/mob/living/simple_animal/cow/Life()
	. = ..()
	if(stat == CONSCIOUS && prob(5))
		milk_content = min(50, milk_content+rand(5, 10))

/mob/living/simple_animal/cow/attack_hand(mob/living/carbon/M as mob)
	if(!stat && M.a_intent == I_DISARM && icon_state != icon_dead)
		M.visible_message("<span class='warning'>[M] tips over [src].</span>","<span class='notice'>You tip over [src].</span>")
		Weaken(30)
		icon_state = icon_dead
		spawn(rand(20,50))
			if(!stat && M)
				icon_state = icon_living
				var/list/responses = list(	"[src] looks at you imploringly.",
											"[src] looks at you pleadingly",
											"[src] looks at you with a resigned expression.",
											"[src] seems resigned to its fate.")
				to_chat(M, pick(responses))
	else
		..()

/mob/living/simple_animal/chick
	name = "\improper chick"
	desc = "Adorable! They make such a racket though."
	icon_state = "chick"
	icon_living = "chick"
	icon_dead = "chick_dead"
	icon_gib = "chick_gib"
	speak = list("Cherp.","Cherp?","Chirrup.","Cheep!")
	speak_emote = list("cheeps")
	emote_hear = list("cheeps")
	emote_see = list("pecks at the ground","flaps its tiny wings")
	density = 0
	speak_chance = 2
	turns_per_move = 2
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat = 1)
	response_help  = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm   = "kicks the"
	attacktext = "kicks"
	health = 3
	maxHealth = 3
	ventcrawler = 2
	var/amount_grown = 0
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	can_hide = 1
	can_collar = 1
	gold_core_spawnable = CHEM_MOB_SPAWN_FRIENDLY

/mob/living/simple_animal/chick/New()
	..()
	pixel_x = rand(-6, 6)
	pixel_y = rand(0, 10)

/mob/living/simple_animal/chick/Life()
	. =..()
	if(.)
		amount_grown += rand(1,2)
		if(amount_grown >= 100)
			var/mob/living/simple_animal/chicken/C = new /mob/living/simple_animal/chicken(loc)
			if(mind)
				mind.transfer_to(C)
			qdel(src)

var/const/MAX_CHICKENS = 50
var/global/chicken_count = 0

/mob/living/simple_animal/chicken
	name = "\improper chicken"
	desc = "Hopefully the eggs are good this season."
	icon_state = "chicken"
	icon_living = "chicken"
	icon_dead = "chicken_dead"
	speak = list("Cluck!","BWAAAAARK BWAK BWAK BWAK!","Bwaak bwak.")
	speak_emote = list("clucks","croons")
	emote_hear = list("clucks")
	emote_see = list("pecks at the ground","flaps its wings viciously")
	density = 0
	speak_chance = 2
	turns_per_move = 3
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat = 2)
	response_help  = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm   = "kicks the"
	attacktext = "kicks"
	health = 10
	maxHealth = 10
	var/eggsleft = 0
	var/chicken_color
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	can_hide = 1
	can_collar = 1
	gold_core_spawnable = CHEM_MOB_SPAWN_FRIENDLY

/mob/living/simple_animal/chicken/New()
	..()
	if(!chicken_color)
		chicken_color = pick( list("brown","black","white") )
	icon_state = "chicken_[chicken_color]"
	icon_living = "chicken_[chicken_color]"
	icon_dead = "chicken_[chicken_color]_dead"
	pixel_x = rand(-6, 6)
	pixel_y = rand(0, 10)
	chicken_count += 1

/mob/living/simple_animal/chicken/death(gibbed)
	..()
	chicken_count -= 1

/mob/living/simple_animal/chicken/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown)) //feedin' dem chickens
		var/obj/item/weapon/reagent_containers/food/snacks/grown/G = O
		if(G.seed.kitchen_tag == "wheat")
			if(!stat && eggsleft < 8)
				user.visible_message("\blue [user] feeds [O] to [name]! It clucks happily.","\blue You feed [O] to [name]! It clucks happily.")
				user.drop_item()
				qdel(O)
				eggsleft += rand(1, 4)
//				to_chat(world, eggsleft)
			else
				to_chat(user, "\blue [name] doesn't seem hungry!")
		else
			to_chat(user, "\blue [name] doesn't seem interested in [O]!")
	else
		..()

/mob/living/simple_animal/chicken/Life()
	. = ..()
	if(. && prob(3) && eggsleft > 0)
		visible_message("[src] [pick("lays an egg.","squats down and croons.","begins making a huge racket.","begins clucking raucously.")]")
		eggsleft--
		var/obj/item/weapon/reagent_containers/food/snacks/egg/E = new(get_turf(src))
		E.pixel_x = rand(-6,6)
		E.pixel_y = rand(-6,6)
		if(chicken_count < MAX_CHICKENS && prob(10))
			processing_objects.Add(E)

/obj/item/weapon/reagent_containers/food/snacks/egg/var/amount_grown = 0
/obj/item/weapon/reagent_containers/food/snacks/egg/process()
	if(isturf(loc))
		amount_grown += rand(1,2)
		if(amount_grown >= 100)
			visible_message("[src] hatches with a quiet cracking sound.")
			new /mob/living/simple_animal/chick(get_turf(src))
			processing_objects.Remove(src)
			qdel(src)
	else
		processing_objects.Remove(src)


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
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat/ham = 6)
	response_help  = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm   = "kicks the"
	attacktext = "kicks"
	health = 50
	maxHealth = 50
	can_collar = 1
	gold_core_spawnable = CHEM_MOB_SPAWN_FRIENDLY

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
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat = 4)
	response_help  = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm   = "kicks the"
	attacktext = "pecks"
	health = 50
	maxHealth = 50
	can_collar = 1
	gold_core_spawnable = CHEM_MOB_SPAWN_FRIENDLY

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
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat = 6)
	response_help  = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm   = "kicks the"
	attacktext = "kicks"
	health = 50
	maxHealth = 50
	can_collar = 1
	gold_core_spawnable = CHEM_MOB_SPAWN_FRIENDLY

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
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat = 6)
	response_help  = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm   = "kicks the"
	attacktext = "kicks"
	health = 50
	maxHealth = 50
	can_collar = 1
	gold_core_spawnable = CHEM_MOB_SPAWN_FRIENDLY

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
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat = 6)
	response_help  = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm   = "kicks the"
	attacktext = "kicks"
	health = 50
	maxHealth = 50
	can_collar = 1
	gold_core_spawnable = CHEM_MOB_SPAWN_FRIENDLY

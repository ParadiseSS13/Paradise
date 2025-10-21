//Dogs.

/mob/living/simple_animal/pet/dog
	name = "dog"
	icon_state = "blackdog"
	icon_living = "blackdog"
	icon_dead = "blackdog_dead"
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"
	speak = list("YAP", "Woof!", "Bark!", "AUUUUUU")
	speak_emote = list("barks", "woofs")
	emote_hear = list("barks!", "woofs!", "yaps.", "pants.")
	emote_see = list("shakes its head.", "chases its tail.", "shivers.")
	faction = list("neutral")
	see_in_dark = 5
	speak_chance = 1
	turns_per_move = 10
	gold_core_spawnable = FRIENDLY_SPAWN
	var/bark_sound = list('sound/creatures/dog_bark1.ogg','sound/creatures/dog_bark2.ogg') //Used in emote.
	var/yelp_sound = 'sound/creatures/dog_yelp.ogg' //Used on death.
	var/last_eaten = 0
	footstep_type = FOOTSTEP_MOB_CLAW
	var/next_spin_message = 0

/mob/living/simple_animal/pet/dog/npc_safe(mob/user)
	return TRUE

/mob/living/simple_animal/pet/dog/verb/chasetail()
	set name = "Chase your tail"
	set desc = "d'awwww."
	set category = "Dog"

	if(next_spin_message <= world.time)
		visible_message("[src] [pick("dances around", "chases [p_their()] tail")].", "[pick("You dance around", "You chase your tail")].")
		next_spin_message = world.time + 5 SECONDS
	spin(20, 1)

/mob/living/simple_animal/pet/dog/death(gibbed)
	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return
	playsound(src, yelp_sound, 75, TRUE)

/mob/living/simple_animal/pet/dog/attack_hand(mob/living/carbon/human/M)
	. = ..()
	switch(M.a_intent)
		if(INTENT_HELP)
			wuv(1, M)
		if(INTENT_HARM)
			wuv(-1, M)

/mob/living/simple_animal/pet/dog/proc/wuv(change, mob/M)
	if(change)
		if(change > 0)
			if(M && stat != DEAD) // Added check to see if this mob (the corgi) is dead to fix issue 2454
				new /obj/effect/temp_visual/heart(loc)
				custom_emote(EMOTE_VISIBLE, "yaps happily!")
		else
			if(M && stat != DEAD) // Same check here, even though emote checks it as well (poor form to check it only in the help case)
				emote("growl")

//Corgis and pugs are now under one dog subtype

/mob/living/simple_animal/pet/dog/corgi
	name = "corgi"
	real_name = "corgi"
	desc = "It's a corgi."
	icon_state = "corgi"
	icon_living = "corgi"
	icon_dead = "corgi_dead"
	butcher_results = list(/obj/item/food/meat/corgi = 3, /obj/item/stack/sheet/animalhide/corgi = 1)
	childtype = list(/mob/living/simple_animal/pet/dog/corgi/puppy = 95, /mob/living/simple_animal/pet/dog/corgi/puppy/void = 5)
	animal_species = /mob/living/simple_animal/pet/dog
	///Currently worn item on the head slot
	var/obj/item/inventory_head = null
	///Currently worn item on the back slot
	var/obj/item/inventory_back = null
	var/shaved = FALSE
	var/nofur = FALSE 		//Corgis that have risen past the material plane of existence.
	var/razor_shave_delay = 5 SECONDS
	var/collar_icon_state = "corgi"


/mob/living/simple_animal/pet/dog/corgi/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/wears_collar, collar_icon_state_ = collar_icon_state)
	regenerate_icons()

/mob/living/simple_animal/pet/dog/corgi/Destroy()
	QDEL_NULL(inventory_head)
	QDEL_NULL(inventory_back)
	return ..()

/mob/living/simple_animal/pet/dog/corgi/get_strippable_items(datum/source, list/items)
	items |= GLOB.strippable_corgi_items

/mob/living/simple_animal/pet/dog/corgi/handle_atom_del(atom/A)
	if(A == inventory_head)
		inventory_head = null
		regenerate_icons()
	if(A == inventory_back)
		inventory_back = null
		regenerate_icons()
	return ..()

/mob/living/simple_animal/pet/dog/corgi/Life(seconds, times_fired)
	. = ..()
	regenerate_icons()

/mob/living/simple_animal/pet/dog/corgi/death(gibbed)
	..(gibbed)
	regenerate_icons()

/mob/living/simple_animal/pet/dog/corgi/RangedAttack(atom/A, params)
	if(inventory_back)
		inventory_back.afterattack__legacy__attackchain(A, src)

/mob/living/simple_animal/pet/dog/corgi/UnarmedAttack(atom/A)
	if(istype(inventory_back, /obj/item/extinguisher))
		var/obj/item/extinguisher/E = inventory_back
		if(E.attempt_refill(A, src))
			return
	return ..()

/mob/living/simple_animal/pet/dog/corgi/deadchat_plays(mode = DEADCHAT_ANARCHY_MODE, cooldown = 12 SECONDS)
	. = AddComponent(/datum/component/deadchat_control/cardinal_movement, mode, list(
		"speak" = CALLBACK(src, PROC_REF(handle_automated_speech), TRUE),
		"wear_hat" = CALLBACK(src, PROC_REF(find_new_hat)),
		"drop_hat" = CALLBACK(src, PROC_REF(drop_hat)),
		"spin" = CALLBACK(src, TYPE_PROC_REF(/mob, emote), "spin")), cooldown, CALLBACK(src, PROC_REF(end_dchat_plays)))

	if(. == COMPONENT_INCOMPATIBLE)
		return

	stop_automated_movement = TRUE

///Deadchat plays command that picks a new hat for Ian.
/mob/living/simple_animal/pet/dog/corgi/proc/find_new_hat()
	if(!isturf(loc))
		return
	var/list/possible_headwear = list()
	for(var/obj/item/item in loc)
		if(ispath(item.dog_fashion, /datum/dog_fashion/head))
			possible_headwear += item
	if(!length(possible_headwear))
		for(var/obj/item/item in orange(1))
			if(ispath(item.dog_fashion, /datum/dog_fashion/head) && Adjacent(item))
				possible_headwear += item
	if(!length(possible_headwear))
		return
	if(inventory_head)
		inventory_head.forceMove(drop_location())
		inventory_head = null
	place_on_head(pick(possible_headwear))
	visible_message("<span class='notice'>[src] puts [inventory_head] on [p_their()] own head, somehow.</span>")

///Deadchat plays command that drops the current hat off Ian.
/mob/living/simple_animal/pet/dog/corgi/proc/drop_hat()
	if(!inventory_head)
		return
	visible_message("<span class='notice'>[src] vigorously shakes [p_their()] head, dropping [inventory_head] to the ground.</span>")
	inventory_head.forceMove(drop_location())
	inventory_head = null
	update_corgi_fluff()
	regenerate_icons()

/mob/living/simple_animal/pet/dog/corgi/getarmor(def_zone, armor_type)
	var/armorval = 0

	if(def_zone)
		if(def_zone == "head")
			if(inventory_head)
				armorval = inventory_head.armor.getRating(armor_type)
		else
			if(inventory_back)
				armorval = inventory_back.armor.getRating(armor_type)
		return armorval
	else
		if(inventory_head)
			armorval += inventory_head.armor.getRating(armor_type)
		if(inventory_back)
			armorval += inventory_back.armor.getRating(armor_type)
	return armorval * 0.5

/mob/living/simple_animal/pet/dog/corgi/item_interaction(mob/living/user, obj/item/O, list/modifiers)
	if(istype(O, /obj/item/razor))
		if(shaved)
			to_chat(user, "<span class='warning'>You can't shave this corgi, it's already been shaved!</span>")
			return ITEM_INTERACT_COMPLETE
		if(nofur)
			to_chat(user, "<span class='warning'>You can't shave this corgi, it doesn't have a fur coat!</span>")
			return ITEM_INTERACT_COMPLETE
		user.visible_message("<span class='notice'>[user] starts to shave [src] using \the [O].", "<span class='notice'>You start to shave [src] using \the [O]...</span>")
		if(do_after(user, razor_shave_delay, target = src))
			user.visible_message("<span class='notice'>[user] shaves [src]'s hair using \the [O].</span>")
			playsound(loc, O.usesound, 20, TRUE)
			shaved = TRUE
			icon_living = "[initial(icon_living)]_shaved"
			icon_dead = "[initial(icon_living)]_shaved_dead"
			if(stat == CONSCIOUS)
				icon_state = icon_living
			else
				icon_state = icon_dead
		update_corgi_fluff()
		return ITEM_INTERACT_COMPLETE

	return ..()

//Corgis are supposed to be simpler, so only a select few objects can actually be put
//to be compatible with them. The objects are below.
//Many  hats added, Some will probably be removed, just want to see which ones are popular.
// > some will probably be removed

/mob/living/simple_animal/pet/dog/corgi/proc/place_on_head(obj/item/item_to_add, mob/user)

	if(inventory_head)
		if(user)
			to_chat(user, "<span class='warning'>You can't put more than one hat on [src]!</span>")
		return
	if(!item_to_add)
		user.visible_message("<span class='notice'>[user] pets [src].</span>", "<span class='notice'>You rest your hand on [src]'s head for a moment.</span>")
		if(flags_2 & HOLOGRAM_2)
			return
		return

	if(user && !user.drop_item_to_ground(item_to_add))
		to_chat(user, "<span class='warning'>\The [item_to_add] is stuck to your hand, you cannot put it on [src]'s head!</span>")
		return 0

	var/valid = FALSE
	if(ispath(item_to_add.dog_fashion, /datum/dog_fashion/head))
		valid = TRUE

	//Various hats and items (worn on his head) change Ian's behaviour. His attributes are reset when a hat is removed.

	if(valid)
		if(health <= 0)
			to_chat(user, "<span class='notice'>There is merely a dull, lifeless look in [real_name]'s eyes as you put [item_to_add] on [p_them()].</span>") // :'(
		else if(user)
			user.visible_message("<span class='notice'>[user] puts [item_to_add] on [real_name]'s head. [src] looks at [user] and barks once.</span>",
				"<span class='notice'>You put [item_to_add] on [real_name]'s head. [src] gives you a peculiar look, then wags [p_their()] tail once and barks.</span>",
				"<span class='italics'>You hear a friendly-sounding bark.</span>")
		item_to_add.forceMove(src)
		inventory_head = item_to_add
		update_corgi_fluff()
		update_appearance()
	else
		to_chat(user, "<span class='warning'>You set [item_to_add] on [src]'s head, but it falls off!</span>")
		item_to_add.forceMove(drop_location())
		if(prob(25))
			step_rand(item_to_add)
		spin(7 DECISECONDS, 1)

	return valid

/mob/living/simple_animal/pet/dog/corgi/proc/update_corgi_fluff()
	// First, change back to defaults
	name = real_name
	desc = initial(desc)
	// BYOND/DM doesn't support the use of initial on lists.
	speak = list("YAP", "Woof!", "Bark!", "AUUUUUU")
	speak_emote = list("barks", "woofs")
	emote_hear = list("barks!", "woofs!", "yaps.","pants.")
	emote_see = list("shakes its head.", "chases its tail.","shivers.")
	desc = initial(desc)
	set_light(0)

	if(inventory_head && inventory_head.dog_fashion)
		var/datum/dog_fashion/DF = new inventory_head.dog_fashion(src)
		DF.apply(src)

	if(inventory_back && inventory_back.dog_fashion)
		var/datum/dog_fashion/DF = new inventory_back.dog_fashion(src)
		DF.apply(src)

/mob/living/simple_animal/pet/dog/corgi/update_overlays()
	. = ..()

	if(inventory_head)
		var/image/head_icon
		var/datum/dog_fashion/DF = new inventory_head.dog_fashion(src)

		if(!DF.obj_icon_state)
			DF.obj_icon_state = inventory_head.icon_state
		if(!DF.obj_alpha)
			DF.obj_alpha = inventory_head.alpha
		if(!DF.obj_color)
			DF.obj_color = inventory_head.color

		if(health <= 0)
			head_icon = DF.get_overlay(dir = EAST)
			head_icon.pixel_y = -8
			head_icon.transform = turn(head_icon.transform, 180)
		else
			head_icon = DF.get_overlay()

		. += head_icon

	if(inventory_back)
		var/image/back_icon
		var/datum/dog_fashion/DF = new inventory_back.dog_fashion(src)

		if(!DF.obj_icon_state)
			DF.obj_icon_state = inventory_back.icon_state
		if(!DF.obj_alpha)
			DF.obj_alpha = inventory_back.alpha
		if(!DF.obj_color)
			DF.obj_color = inventory_back.color

		if(health <= 0)
			back_icon = DF.get_overlay(dir = EAST)
			back_icon.pixel_y = -11
			back_icon.transform = turn(back_icon.transform, 180)
		else
			back_icon = DF.get_overlay()

		. += back_icon

//IAN! SQUEEEEEEEEE~
/mob/living/simple_animal/pet/dog/corgi/ian
	name = "Ian"
	real_name = "Ian"	//Intended to hold the name without altering it.
	gender = MALE
	desc = "It's the HoP's beloved corgi."
	var/turns_since_scan = 0
	var/obj/movement_target
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE
	var/age = 0
	var/record_age = 1
	var/saved_head //path

/mob/living/simple_animal/pet/dog/corgi/ian/Initialize(mapload)
	. = ..()
	SSpersistent_data.register(src)

/mob/living/simple_animal/pet/dog/corgi/ian/Destroy()
	SSpersistent_data.registered_atoms -= src
	return ..()

/mob/living/simple_animal/pet/dog/corgi/ian/death()
	write_memory(TRUE)
	..()

/mob/living/simple_animal/pet/dog/corgi/ian/persistent_load()
	read_memory()
	if(age == 0)
		var/turf/target = get_turf(loc)
		if(target)
			var/mob/living/simple_animal/pet/dog/corgi/puppy/P = new /mob/living/simple_animal/pet/dog/corgi/puppy(target)
			P.name = "Ian"
			P.real_name = "Ian"
			P.gender = MALE
			P.desc = "It's the HoP's beloved corgi puppy."
			write_memory(FALSE)
			SSpersistent_data.registered_atoms -= src // We already wrote here, dont overwrite!
			qdel(src)
			return
	else if(age == record_age)
		icon_state = "old_corgi"
		icon_living = "old_corgi"
		icon_dead = "old_corgi_dead"
		desc = "At a ripe old age of [record_age], Ian's not as spry as he used to be, but he'll always be the HoP's beloved corgi." //RIP
		turns_per_move = 20

/mob/living/simple_animal/pet/dog/corgi/ian/persistent_save()
	if(SEND_SIGNAL(src, COMSIG_LIVING_WRITE_MEMORY) & COMPONENT_DONT_WRITE_MEMORY)
		return FALSE
	write_memory(FALSE)

/mob/living/simple_animal/pet/dog/corgi/ian/proc/read_memory()
	if(fexists("data/npc_saves/Ian.sav")) //legacy compatability to convert old format to new
		var/savefile/S = new /savefile("data/npc_saves/Ian.sav")
		S["age"] 		>> age
		S["record_age"]	>> record_age
		S["saved_head"] >> saved_head
		fdel("data/npc_saves/Ian.sav")
	else
		var/json_file = file("data/npc_saves/Ian.json")
		if(!fexists(json_file))
			return
		var/list/json = json_decode(wrap_file2text(json_file))
		age = json["age"]
		record_age = json["record_age"]
		saved_head = json["saved_head"]
	if(isnull(age))
		age = 0
	if(isnull(record_age))
		record_age = 1
	if(saved_head)
		place_on_head(new saved_head)
	log_debug("Persistent data for [src] loaded (age: [age] | record_age: [record_age] | saved_head: [saved_head ? saved_head : "None"])")

/mob/living/simple_animal/pet/dog/corgi/ian/proc/write_memory(dead)
	var/json_file = file("data/npc_saves/Ian.json")
	var/list/file_data = list()
	if(!dead)
		file_data["age"] = age + 1
		if((age + 1) > record_age)
			file_data["record_age"] = record_age + 1
		else
			file_data["record_age"] = record_age
		if(inventory_head)
			file_data["saved_head"] = inventory_head.type
		else
			file_data["saved_head"] = null
	else
		file_data["age"] = 0
		file_data["record_age"] = record_age
		file_data["saved_head"] = null
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))
	log_debug("Persistent data for [src] saved (age: [age] | record_age: [record_age] | saved_head: [saved_head ? saved_head : "None"])")

/mob/living/simple_animal/pet/dog/corgi/ian/handle_automated_movement()
	. = ..()
	//Feeding, chasing food, FOOOOODDDD
	if(IS_HORIZONTAL(src) || buckled)
		return

	if(++turns_since_scan > 5)
		turns_since_scan = 0

		// Has a target, but it's not where it was before, and it wasn't picked up by someone.
		if(movement_target && !(isturf(movement_target.loc) || ishuman(movement_target.loc)))
			movement_target = null
			stop_automated_movement = FALSE

		// No current target, or current target is out of range.
		var/list/snack_range = oview(src, 3)
		if(!movement_target || !(movement_target.loc in snack_range))
			movement_target = null
			stop_automated_movement = FALSE
			var/obj/item/possible_target = null
			for(var/I in snack_range)
				if(istype(I, /obj/item/food)) // Noms
					possible_target = I
					break
				else if(istype(I, /obj/item/paper)) // Important noms
					if(prob(10))
						possible_target = I
						break
			if(possible_target && (isturf(possible_target.loc) || ishuman(possible_target.loc))) // On the ground or in someone's hand.
				movement_target = possible_target
		if(movement_target)
			INVOKE_ASYNC(src, PROC_REF(move_to_target))

	if(prob(1))
		chasetail()

/mob/living/simple_animal/pet/dog/corgi/ian/proc/move_to_target()
	stop_automated_movement = TRUE
	step_to(src, movement_target, 1)
	sleep(3)
	step_to(src, movement_target, 1)
	sleep(3)
	step_to(src, movement_target, 1)

	if(movement_target) // Not redundant due to sleeps, Item can be gone in 6 deciseconds
		// Face towards the thing
		dir = get_dir(src, movement_target)

		if(!Adjacent(movement_target)) //can't reach food through windows.
			return

		if(isturf(movement_target.loc))
			movement_target.attack_animal(src) // Eat the thing
		else if(prob(30) && ishuman(movement_target.loc)) // mean hooman has stolen it
			custom_emote(EMOTE_VISIBLE, "stares at [movement_target.loc]'s [movement_target] with a sad puppy-face.")

/mob/living/simple_animal/pet/dog/corgi/ian/narsie_act()
	playsound(src, 'sound/misc/demon_dies.ogg', 75, TRUE)
	var/mob/living/simple_animal/pet/dog/corgi/narsie/N = new(loc)
	N.setDir(dir)
	gib()

/mob/living/simple_animal/pet/dog/corgi/narsie
	name = "Nars-Ian"
	desc = "Ia! Ia!"
	icon_state = "narsian"
	icon_living = "narsian"
	icon_dead = "narsian_dead"
	faction = list("neutral", "cult")
	gold_core_spawnable = NO_SPAWN
	nofur = TRUE
	unique_pet = TRUE

/mob/living/simple_animal/pet/dog/corgi/narsie/Life()
	..()
	for(var/mob/living/simple_animal/pet/P in range(1, src))
		if(P != src && !istype(P, /mob/living/simple_animal/pet/dog/corgi/narsie))
			visible_message("<span class='warning'>[src] devours [P]!</span>", \
			"<span class='cult big bold'>DELICIOUS SOULS</span>")
			playsound(src, 'sound/misc/demon_attack1.ogg', 75, TRUE)
			narsie_act()
			P.gib()

/mob/living/simple_animal/pet/dog/corgi/narsie/update_corgi_fluff()
	..()
	speak = list("Tari'karat-pasnar!", "IA! IA!", "BRRUUURGHGHRHR")
	speak_emote = list("growls", "barks ominously")
	emote_hear = list("barks echoingly!", "woofs hauntingly!", "yaps in an eldritch manner.", "mutters something unspeakable.")
	emote_see = list("communes with the unnameable.", "ponders devouring some souls.", "shakes.")

/mob/living/simple_animal/pet/dog/corgi/narsie/narsie_act()
	adjustBruteLoss(-maxHealth)

/mob/living/simple_animal/pet/dog/corgi/puppy
	name = "corgi puppy"
	desc = "It's a corgi puppy!"
	icon_state = "puppy"
	icon_living = "puppy"
	icon_dead = "puppy_dead"
	density = FALSE
	pass_flags = PASSMOB
	collar_icon_state = "puppy"

/mob/living/simple_animal/pet/dog/corgi/puppy/get_strippable_items(datum/source, list/items)
	return

/// Tribute to the corgis born in nullspace
/mob/living/simple_animal/pet/dog/corgi/puppy/void
	name = "void puppy"
	real_name = "voidy"
	desc = "A corgi puppy that has been infused with deep space energy. It's staring back..."
	icon_state = "void_puppy"
	icon_living = "void_puppy"
	icon_dead = "void_puppy_dead"
	nofur = TRUE
	unsuitable_atmos_damage = 0
	minbodytemp = TCMB
	maxbodytemp = T0C + 40

/mob/living/simple_animal/pet/dog/corgi/puppy/void/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	return 1	//Void puppies can navigate space.

//LISA! SQUEEEEEEEEE~
/mob/living/simple_animal/pet/dog/corgi/lisa
	name = "Lisa"
	real_name = "Lisa"
	gender = FEMALE
	desc = "It's a corgi with a cute pink bow."
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE
	icon_state = "lisa"
	icon_living = "lisa"
	icon_dead = "lisa_dead"
	var/datum/strippable_item/corgi_back/corgi_strippable_back
	var/turns_since_scan = 0

/mob/living/simple_animal/pet/dog/corgi/lisa/Initialize(mapload)
	. = ..()
	// Lisa already has a cute bow, so she only needs the back slot
	corgi_strippable_back = new

/mob/living/simple_animal/pet/dog/corgi/lisa/Destroy()
	. = ..()
	QDEL_NULL(corgi_strippable_back)

/mob/living/simple_animal/pet/dog/corgi/lisa/Life()
	..()
	make_babies()

/mob/living/simple_animal/pet/dog/corgi/lisa/get_strippable_items(datum/source, list/items)
	items[STRIPPABLE_ITEM_BACK] = corgi_strippable_back

/mob/living/simple_animal/pet/dog/corgi/lisa/handle_automated_movement()
	. = ..()
	if(!IS_HORIZONTAL(src) && !buckled)
		if(prob(1))
			custom_emote(EMOTE_VISIBLE, pick("dances around.","chases her tail."))
			spin(20, 1)

/mob/living/simple_animal/pet/dog/corgi/exoticcorgi
	name = "Exotic Corgi"
	desc = "As cute as it is colorful!"
	icon_state = "corgigrey"
	icon_living = "corgigrey"
	icon_dead = "corgigrey_dead"
	animal_species = /mob/living/simple_animal/pet/dog/corgi/exoticcorgi
	nofur = TRUE

/mob/living/simple_animal/pet/dog/corgi/exoticcorgi/Initialize(mapload)
	. = ..()
	var/newcolor = rgb(rand(0, 255), rand(0, 255), rand(0, 255))
	add_atom_colour(newcolor, FIXED_COLOUR_PRIORITY)

/mob/living/simple_animal/pet/dog/corgi/borgi
	name = "E-N"
	real_name = "E-N"	//Intended to hold the name without altering it.
	desc = "It's a borgi."
	icon_state = "borgi"
	icon_living = "borgi"
	bark_sound = null	//No robo-bjork...
	yelp_sound = null	//Or robo-Yelp.
	var/emagged = FALSE
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	loot = list(/obj/effect/decal/cleanable/blood/gibs/robot)
	del_on_death = TRUE
	deathmessage = "blows apart!"
	animal_species = /mob/living/simple_animal/pet/dog/corgi/borgi
	nofur = TRUE

/mob/living/simple_animal/pet/dog/corgi/borgi/emag_act(user as mob)
	if(!emagged)
		emagged = TRUE
		visible_message("<span class='warning'>[user] swipes a card through [src].</span>", "<span class='notice'>You overload [src]s internal reactor.</span>")
		addtimer(CALLBACK(src, PROC_REF(explode)), 100 SECONDS)
		return TRUE

/mob/living/simple_animal/pet/dog/corgi/borgi/proc/explode()
	visible_message("<span class='warning'>[src] makes an odd whining noise.</span>")
	explosion(get_turf(src), 0, 1, 4, 7, cause = "Emagged E-N explosion")
	death()

/mob/living/simple_animal/pet/dog/corgi/borgi/proc/shootAt(atom/movable/target)
	var/turf/T = get_turf(src)
	var/turf/U = get_turf(target)
	if(!T || !U)
		return
	var/obj/item/projectile/beam/A = new /obj/item/projectile/beam(loc)
	A.icon = 'icons/effects/genetics.dmi'
	A.icon_state = "eyelasers"
	playsound(src.loc, 'sound/weapons/taser2.ogg', 75, 1)
	A.current = T
	A.yo = U.y - T.y
	A.xo = U.x - T.x
	A.fire()

/mob/living/simple_animal/pet/dog/corgi/borgi/Life(seconds, times_fired)
	..()
	//spark for no reason
	if(prob(5))
		do_sparks(3, 1, src)

/mob/living/simple_animal/pet/dog/corgi/borgi/handle_automated_action()
	if(emagged && prob(25))
		var/mob/living/carbon/target = locate() in view(10, src)
		if(target)
			shootAt(target)

/mob/living/simple_animal/pet/dog/corgi/borgi/death(gibbed)
	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return FALSE
	do_sparks(3, 1, src)

///Pugs

/mob/living/simple_animal/pet/dog/pug
	name = "pug"
	real_name = "pug"
	desc = "It's a pug."
	icon_state = "pug"
	icon_living = "pug"
	icon_dead = "pug_dead"
	butcher_results = list(/obj/item/food/meat/pug = 3)

/mob/living/simple_animal/pet/dog/pug/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/wears_collar, collar_icon_state_ = "pug")

/mob/living/simple_animal/pet/dog/pug/handle_automated_movement()
	. = ..()
	if(!IS_HORIZONTAL(src) && !buckled)
		if(prob(1))
			custom_emote(EMOTE_VISIBLE, pick("chases its tail."))
			spawn(0)
				for(var/i in list(1, 2, 4, 8, 4, 2, 1, 2, 4, 8, 4, 2, 1, 2, 4, 8, 4, 2))
					dir = i
					sleep(1)

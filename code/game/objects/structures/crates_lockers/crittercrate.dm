/obj/structure/closet/critter
	name = "critter crate"
	desc = "A crate designed for safe transport of animals. Only openable from the the outside."
	icon_state = "critter"
	has_opened_overlay = FALSE
	closed_door_sprite = "critter"
	door_anim_time = 0
	var/already_opened = FALSE
	var/content_mob = null
	var/amount = 1
	open_sound = 'sound/machines/wooden_closet_open.ogg'
	close_sound = 'sound/machines/wooden_closet_close.ogg'
	open_sound_volume = 25

/obj/structure/closet/critter/can_open()
	if(welded)
		return
	return TRUE

/obj/structure/closet/critter/open()
	if(!can_open())
		return

	if(content_mob == null) //making sure we don't spawn anything too eldritch
		already_opened = TRUE
		return ..()

	if(content_mob != null && already_opened == 0)
		for(var/i = 1, i <= amount, i++)
			new content_mob(loc)
		already_opened = TRUE
	. = ..()

/obj/structure/closet/critter/close()
	..()
	return TRUE


/obj/structure/closet/critter/shove_impact(mob/living/target, mob/living/attacker)
	return FALSE

/obj/structure/closet/critter/random
	name = "unmarked crate"
	desc = "A crate designed for safe transport of animals. The contents are a mystery."

/obj/structure/closet/critter/random/populate_contents()
	content_mob = pick(
	/mob/living/basic/cow,
	/mob/living/basic/deer,
	/mob/living/basic/pig,

	/mob/living/simple_animal/pet/dog/corgi,
	/mob/living/simple_animal/pet/dog/corgi/lisa,
	/mob/living/basic/goat,
	/mob/living/basic/turkey,
	/mob/living/basic/chick,
	/mob/living/simple_animal/pet/cat,
	/mob/living/simple_animal/pet/dog/pug,
	/mob/living/simple_animal/pet/dog/fox,
	/mob/living/basic/bunny)

/obj/structure/closet/critter/corgi
	name = "corgi crate"
	content_mob = /mob/living/simple_animal/pet/dog/corgi

/obj/structure/closet/critter/corgi/populate_contents()
	if(prob(50))
		content_mob = /mob/living/simple_animal/pet/dog/corgi/lisa

/obj/structure/closet/critter/cow
	name = "cow crate"
	content_mob = /mob/living/basic/cow

/obj/structure/closet/critter/pig
	name = "pig crate"
	content_mob = /mob/living/basic/pig

/obj/structure/closet/critter/goat
	name = "goat crate"
	content_mob = /mob/living/basic/goat

/obj/structure/closet/critter/turkey
	name = "turkey crate"
	content_mob = /mob/living/basic/turkey

/obj/structure/closet/critter/chick
	name = "chicken crate"
	content_mob = /mob/living/basic/chick

/obj/structure/closet/critter/chick/populate_contents()
	amount = rand(1, 3)

/obj/structure/closet/critter/cat
	name = "cat crate"
	content_mob = /mob/living/simple_animal/pet/cat

/obj/structure/closet/critter/cat/populate_contents()
	if(prob(50))
		content_mob = /mob/living/simple_animal/pet/cat/proc_cat

/obj/structure/closet/critter/pug
	name = "pug crate"
	content_mob = /mob/living/simple_animal/pet/dog/pug

/obj/structure/closet/critter/fox
	name = "fox crate"
	content_mob = /mob/living/simple_animal/pet/dog/fox

/obj/structure/closet/critter/butterfly
	name = "butterfly crate"
	content_mob = /mob/living/basic/butterfly

/obj/structure/closet/critter/nian_caterpillar
	name = "nian caterpillar crate"
	content_mob = /mob/living/basic/nian_caterpillar

/obj/structure/closet/critter/deer
	name = "deer crate"
	content_mob = /mob/living/basic/deer

/obj/structure/closet/critter/bunny
	name = "bunny crate"
	content_mob = /mob/living/basic/bunny

/obj/structure/closet/critter/gorilla
	name = "gorilla crate"
	content_mob = /mob/living/basic/gorilla

/obj/structure/closet/critter/gorilla/cargo
	name = "cargorilla crate"
	content_mob = /mob/living/basic/gorilla/cargo_domestic

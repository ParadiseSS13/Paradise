// \code\modules\mob\mob_holder.dm
/obj/item/holder
	icon_override = 'modular_ss220/mobs/icons/mob/inhead/head.dmi'
	lefthand_file = 'modular_ss220/mobs/icons/mob/inhands/mobs_lefthand.dmi'
	righthand_file = 'modular_ss220/mobs/icons/mob/inhands/mobs_righthand.dmi'
	origin_tech = "biotech=2"
	slot_flags = SLOT_HEAD

/mob/living/simple_animal/attackby(obj/item/O, mob/living/user)
	if(user.a_intent == INTENT_HELP || user.a_intent == INTENT_GRAB)
		if(istype(O, /obj/item/pet_carrier))
			var/obj/item/pet_carrier/C = O
			if(C.put_in_carrier(src, user))
				return
	return ..()








//!!!!!!!!!! Проверить работу без этого прока, а потом с этим при захвате ПИИ, мышей, Куриц разных цветов
// /mob/living/proc/get_scooped(mob/living/carbon/grabber, has_variant = FALSE)
// 	. = ..()
// 	if(.)
// 		H.icon = icon
// 		H.icon_state = icon_state

/mob/living/get_scooped(mob/living/carbon/grabber, has_variant = FALSE)
	var/obj/item/holder/H = ..()
	if(!H)
		return FALSE

	switch(mob_size)
		if(MOB_SIZE_TINY)
			H.w_class = WEIGHT_CLASS_TINY
		if(MOB_SIZE_SMALL)
			H.w_class = WEIGHT_CLASS_SMALL
		if(MOB_SIZE_HUMAN)
			H.w_class = WEIGHT_CLASS_NORMAL
		if(MOB_SIZE_LARGE)
			H.w_class = WEIGHT_CLASS_HUGE

	return H


/obj/item/holder/diona
	name = "diona nymph"
	desc = "It's a tiny plant critter."
	icon_state = "nymph"
	origin_tech = "biotech=5"
	slot_flags = SLOT_HEAD|SLOT_EARS

/obj/item/holder/pai
	name = "pAI"
	desc = "It's a little robot."
	icon_state = "pai"
	origin_tech = "materials=3;programming=4;engineering=4"
	slot_flags = SLOT_HEAD|SLOT_EARS

/obj/item/holder/bunny
	slot_flags = SLOT_HEAD|SLOT_EARS

/obj/item/holder/mouse
	name = "mouse"
	desc = "It's a small, disease-ridden rodent."
	icon = 'modular_ss220/mobs/icons/mob/animal.dmi'
	icon_state = "mouse_gray"
	slot_flags = SLOT_HEAD|SLOT_EARS

/obj/item/holder/drone
	name = "maintenance drone"
	desc = "It's a small maintenance robot."
	icon_state = "drone"
	origin_tech = "materials=3;programming=4;powerstorage=3;engineering=4"

/obj/item/holder/drone/emagged
	name = "maintenance drone"
	icon_state = "drone-emagged"
	origin_tech = "materials=3;programming=4;powerstorage=3;engineering=4;syndicate=3"

/obj/item/holder/cogscarab
	name = "cogscarab"
	desc = "A strange, drone-like machine. It constantly emits the hum of gears."
	icon_state = "cogscarab"
	origin_tech = "materials=3;magnets=4;powerstorage=9;bluespace=4"

/obj/item/holder/monkey
	name = "monkey"
	desc = "It's a monkey"
	icon_state = "monkey"
	origin_tech = "biotech=3"

/obj/item/holder/farwa
	name = "farwa"
	desc = "It's a farwa"
	icon_state = "farwa"
	origin_tech = "biotech=3"

/obj/item/holder/stok
	name = "stok"
	desc = "It's a stok"
	icon_state = "stok"
	origin_tech = "biotech=3"

/obj/item/holder/neara
	name = "neara"
	desc = "It's a neara"
	icon_state = "neara"
	origin_tech = "biotech=3"

/obj/item/holder/corgi
	name = "pet"
	desc = "It's a pet"
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	icon_state = "corgi"

/obj/item/holder/lisa
	name = "pet"
	desc = "It's a pet"
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	icon_state = "lisa"

/obj/item/holder/old_corgi
	name = "pet"
	desc = "It's a pet"
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	icon_state = "old_corgi"

/obj/item/holder/borgi
	name = "pet"
	desc = "It's a pet"
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	icon_state = "borgi"

/obj/item/holder/void_puppy
	name = "pet"
	desc = "It's a pet"
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	icon_state = "void_puppy"
	origin_tech = "biotech=4;bluespace=5"

/obj/item/holder/slime_puppy
	name = "pet"
	desc = "It's a pet"
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	icon_state = "slime_puppy"
	origin_tech = "biotech=6"

/obj/item/holder/narsian
	name = "pet"
	desc = "It's a pet"
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	icon_state = "narsian"
	slot_flags = null
	origin_tech = "bluespace=10"

/obj/item/holder/pug
	name = "pet"
	desc = "It's a pet"
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	icon_state = "pug"

/obj/item/holder/fox
	name = "pet"
	desc = "It's a pet"
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	icon_state = "fox"

/obj/item/holder/sloth
	name = "pet"
	desc = "It's a pet"
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	icon_state = "sloth"
	slot_flags = null

/obj/item/holder/cat
	name = "pet"
	desc = "It's a pet"
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	icon_state = "cat"

/obj/item/holder/cat2
	name = "pet"
	desc = "It's a pet"
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	icon_state = "cat2"

/obj/item/holder/cak
	name = "pet"
	desc = "It's a pet"
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	icon_state = "cak"
	origin_tech = "biotech=5"

/obj/item/holder/fatcat
	name = "pet"
	desc = "It's a pet"
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	icon_state = "iriska"
	origin_tech = "biotech=5"
	slot_flags = null

/obj/item/holder/crusher
	name = "pet"
	desc = "It's a pet"
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	icon_state = "crusher"

/obj/item/holder/original
	name = "pet"
	desc = "It's a pet"
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	icon_state = "original"

/obj/item/holder/spacecat
	name = "pet"
	desc = "It's a pet"
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	icon_state = "spacecat"

/obj/item/holder/bullterrier
	name = "pet"
	desc = "It's a pet"
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	icon_state = "bullterrier"
	slot_flags = null

/obj/item/holder/crab
	name = "pet"
	desc = "It's a pet"
	icon = 'modular_ss220/mobs/icons/mob/animal.dmi'
	icon_state = "crab"

/obj/item/holder/evilcrab
	name = "pet"
	desc = "It's a pet"
	icon = 'modular_ss220/mobs/icons/mob/animal.dmi'
	icon_state = "evilcrab"

/obj/item/holder/snake
	name = "pet"
	desc = "It's a pet"
	icon_state = "snake"

/obj/item/holder/parrot
	name = "pet"
	desc = "It's a pet"
	icon = 'modular_ss220/mobs/icons/mob/animal.dmi'
	icon_state = "parrot_fly"

/obj/item/holder/axolotl
	name = "pet"
	desc = "It's a pet"
	icon = 'modular_ss220/mobs/icons/mob/animal.dmi'
	icon_state = "axolotl"

/obj/item/holder/lizard
	name = "pet"
	desc = "It's a pet"
	icon = 'modular_ss220/mobs/icons/mob/animal.dmi'
	icon_state = "lizard"

/obj/item/holder/chick
	name = "pet"
	desc = "It's a small chicken"
	icon = 'modular_ss220/mobs/icons/mob/animal.dmi'
	icon_state = "chick"

/obj/item/holder/chicken
	name = "pet"
	desc = "It's a chicken"
	icon = 'modular_ss220/mobs/icons/mob/animal.dmi'
	icon_state = "chicken_brown"
	slot_flags = null

/obj/item/holder/cock
	name = "pet"
	desc = "It's a pet"
	icon = 'modular_ss220/mobs/icons/mob/animal.dmi'
	icon_state = "cock"
	slot_flags = null

/obj/item/holder/hamster
	name = "pet"
	desc = "It's a pet"
	icon = 'modular_ss220/mobs/icons/mob/animal.dmi'
	icon_state = "hamster"

/obj/item/holder/hamster_rep
	name = "Представитель Алексей"
	desc = "Уважаемый хомяк"
	icon = 'modular_ss220/mobs/icons/mob/animal.dmi'
	icon_state = "hamster_rep"

/obj/item/holder/fennec
	name = "fennec"
	desc = "It's a fennec. Yiff!"
	icon_state = "fennec"
	origin_tech = "biotech=4"

/obj/item/holder/mothroach
	name = "mothroach"
	desc = "Bzzzz"
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	icon_state = "mothroach"
	origin_tech = "biotech=4"

/obj/item/holder/moth
	name = "moth"
	desc = "Bzzzz"
	icon = 'modular_ss220/mobs/icons/mob/animal.dmi'
	icon_state = "moth"
	origin_tech = "biotech=4"

/obj/item/holder/headslug
	name = "headslug"
	desc = "It's a headslug. Ewwww..."
	icon = 'modular_ss220/mobs/icons/mob/animal.dmi'
	icon_state = "headslug"
	origin_tech = "biotech=6"

/obj/item/holder/possum
	name = "possum"
	desc = "It's a possum. Ewwww..."
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	icon_state = "possum"
	origin_tech = "biotech=3"

/obj/item/holder/possum/poppy
	name = "poppy"
	desc = "It's a possum Poppy. Ewwww..."
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	icon_state = "possum_poppy"

/obj/item/holder/frog
	name = "frog"
	desc = "It's a wednesday, my dudes."
	icon = 'modular_ss220/mobs/icons/mob/animal.dmi'
	icon_state = "frog"

/obj/item/holder/frog/toxic
	name = "rare frog"
	desc = "It's a toxic wednesday, my dudes."
	icon_state = "rare_frog"

/obj/item/holder/snail
	name = "snail"
	desc = "Slooooow"
	icon = 'modular_ss220/mobs/icons/mob/animal.dmi'
	icon_state = "snail"

/obj/item/holder/turtle
	name = "yeeslow"
	desc = "Slooooow"
	icon = 'modular_ss220/mobs/icons/mob/animal.dmi'
	icon_state = "yeeslow"

/obj/item/holder/clowngoblin
	name = "clowngoblin"
	desc = "Honk honk"
	icon = 'modular_ss220/mobs/icons/mob/animal.dmi'
	icon_state = "clowngoblin"

/obj/item/paper/fluff/henderson_report
	name = "Important Notice - Mrs. Henderson"
	info = "Nothing of interest to report."

/obj/effect/mob_spawn/human/doctor/alive/lavaland
	name = "broken rejuvenation pod"
	desc = "A small sleeper typically used to instantly restore minor wounds. This one seems broken, and its occupant is comatose."
	mob_name = "a translocated vet"
	description = "You are an intern working in an animal hospital that suddenly got transported to lavaland. Good luck."
	flavour_text = "What...? Where are you? Where are the others? This is still the animal hospital - you should know, you've been an intern here for weeks - but \
	everyone's gone. One of the cats scratched you just a few minutes ago. That's why you were in the pod - to heal the scratch. The scabs are still fresh; you see them right now. So where is \
	everyone? Where did they go? What happened to the hospital? And is that smoke you smell? You need to find someone else. Maybe they can tell you what happened."
	assignedrole = "Translocated Vet"
	allow_species_pick = TRUE

/obj/effect/mob_spawn/human/doctor/alive/lavaland/Destroy()
	var/obj/structure/fluff/empty_sleeper/S = new(drop_location())
	S.setDir(dir)
	return ..()

/obj/effect/mob_spawn/human/alive/vet_monkey
	name = "broken rejuvenation pod - monkey"
	desc = "A small sleeper typically used to instantly restore minor wounds. This one seems broken. There's a sleeping monkey inside."
	mob_name = "a translocated monkey"
	mob_species = /datum/species/monkey
	description = "You are a monkey in an animal hospital that suddenly got transported to lavaland. Ook!"
	flavour_text = "You are a monkey. You remember being put into a cold place and falling asleep. You've woken up. The air smells strange..."

/obj/effect/mob_spawn/human/alive/vet_monkey/Destroy()
	var/obj/structure/fluff/empty_sleeper/S = new(drop_location())
	S.setDir(dir)
	return ..()

/obj/effect/mob_spawn/animal_sleeper
	name = "broken rejuvenation pod - mouse"
	desc = "A small sleeper typically used to instantly restore minor wounds. This one seems broken. There's an animal sleeping inside."
	mob_name = "space mouse"
	mob_type = 	/mob/living/simple_animal/mouse
	death = FALSE
	roundstart = FALSE
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "sleeper"
	description = "You are a mouse in an animal hospital that suddenly got transported to lavaland. Squeak!"
	flavour_text = "You are a mouse. You remember being put into a cold place and falling asleep. You've woken up. The air smells strange..."

/obj/effect/mob_spawn/animal_sleeper/Destroy()
	var/obj/structure/fluff/empty_sleeper/S = new(drop_location())
	S.setDir(dir)
	return ..()


/obj/effect/mob_spawn/animal_sleeper/cow
	name = "broken rejuvenation pod - cow"
	mob_name = "a translocated cow"
	mob_type = 	/mob/living/simple_animal/cow
	mob_gender = FEMALE
	description = "You are a cow in an animal hospital that suddenly got transported to lavaland. Moo."
	flavour_text = "You are a cow. You remember being put into a cold place and falling asleep. You've woken up. The air smells strange..."

/obj/effect/mob_spawn/animal_sleeper/dog
	name = "broken rejuvenation pod - dog"
	mob_name = "a translocated dog"
	mob_type = 	/mob/living/simple_animal/pet/dog/pug
	description = "You are a dog in an animal hospital that suddenly got transported to lavaland. Woof."
	flavour_text = "You are a dog. You remember being put into a cold place and falling asleep. You've woken up. The air smells strange..."

/obj/effect/mob_spawn/animal_sleeper/cat
	name = "broken rejuvenation pod - cat"
	mob_name = "a translocated cat"
	mob_type = 	/mob/living/simple_animal/pet/cat
	description = "You are a cat in an animal hospital that suddenly got transported to lavaland. Meow."
	flavour_text = "You are a cat. You remember being put into a cold place and falling asleep. You've woken up. The air smells strange..."

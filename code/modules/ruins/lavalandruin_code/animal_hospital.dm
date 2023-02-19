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
	random = FALSE
	allow_species_pick = TRUE
	allow_prefs_prompt = TRUE
	allow_gender_pick = TRUE
	allow_name_pick = TRUE
	outfit = /datum/outfit/job/doctor/alive/lavaland

/datum/outfit/job/doctor/alive/lavaland
	name = "Medical Doctor"
	uniform = /obj/item/clothing/under/rank/medical
	suit = /obj/item/clothing/suit/storage/labcoat
	shoes = /obj/item/clothing/shoes/white
	l_ear = /obj/item/radio/headset/headset_med
	id = /obj/item/card/id/medical
	suit_store = /obj/item/flashlight/pen
	l_hand = /obj/item/storage/firstaid/doctor
	pda = /obj/item/pda/medical

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel_med
	dufflebag = /obj/item/storage/backpack/duffel/medical

/obj/effect/mob_spawn/human/doctor/alive/lavaland/Destroy()
	var/obj/structure/fluff/empty_sleeper/S = new(drop_location())
	S.setDir(dir)
	return ..()

/obj/effect/mob_spawn/human/doctor/alive/lavaland/special(mob/living/carbon/human/H)
	GLOB.human_names_list += H.real_name
	return ..()

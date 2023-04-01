/obj/item/clothing/under/punpun
	name = "fancy uniform"
	desc = "It looks like it was tailored for a monkey."
	icon_state = "punpun"
	item_color = "punpun"
	species_restricted = list("Monkey")
	species_exception = list(/datum/species/monkey)

	icon = 'icons/obj/clothing/under/misc.dmi'
	sprite_sheets = list("Monkey" = 'icons/mob/clothing/under/misc.dmi')

/mob/living/carbon/human/monkey/punpun/Initialize(mapload)
	. = ..()
	name = "Pun Pun"
	real_name = name
	equip_to_slot(new /obj/item/clothing/under/punpun(src), slot_w_uniform)

/mob/living/carbon/human/monkey/teeny/Initialize(mapload)
	. = ..()
	name = "Mr. Teeny"
	real_name = name
	resize = 0.8
	update_transform()

/mob/living/carbon/human/monkey/infect_with_monkey_virus(mob/user)
	if(!mind && !client)
		INVOKE_ASYNC(src, PROC_REF(spawn_new_monkey))
	if(!HAS_TRAIT(src, TRAIT_HAS_MONKEY_VIRUS))
		ADD_TRAIT(src, TRAIT_HAS_MONKEY_VIRUS, "Monkey virus")
		to_chat(src, "<span class='userdanger'>You are an infected monkey! The touch of your hairy hands can infect anyone, and using your harm intent bite on people will cause them to turn to your side quicker.</span>")

/mob/living/carbon/human/monkey/proc/spawn_new_monkey()
	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a monkey?", source = /mob/living/carbon/human/monkey)
	var/mob/C = null

	if(!length(candidates))
		return // no monkey :(
	C = pick(candidates)
	if(QDELETED(C))
		return // monkey left :(
	key = C.key
	mind.name =	name
	mind.assigned_role = ROLE_MONKEY
	mind.special_role = ROLE_MONKEY
	ADD_TRAIT(src, TRAIT_HAS_MONKEY_VIRUS, "Monkey virus")
	to_chat(src, "<span class='userdanger'>You are an infected monkey! The touch of your hairy hands can infect anyone, and using your harm intent bite on people will cause them to turn to your side quicker.</span>")

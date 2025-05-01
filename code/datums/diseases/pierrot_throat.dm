/datum/disease/pierrot_throat
	name = "Pierrot's Throat"
	max_stages = 4
	spread_text = "Airborne"
	cure_text = "Banana products, especially banana bread."
	cures = list("banana")
	cure_chance = 75
	agent = "H0NI<42.B4n4 Virus"
	viable_mobtypes = list(/mob/living/carbon/human)
	permeability_mod = 0.75
	desc = "If left untreated the subject will probably drive others to insanity and go insane themselves."
	severity = VIRUS_MINOR

/datum/disease/pierrot_throat/stage_act()
	if(!..())
		return FALSE
	if(stage < 2)
		return

	var/mob/living/carbon/human/H = affected_mob

	var/static/list/message_chances = list(null, 4, 2, 1)
	if(prob(message_chances[stage]))
		to_chat(H, "<span class='danger'>You feel [pick("a little silly", "like making a joke", "in the mood for giggling", "like the world is a little more vibrant")].</span>")
	if(prob(message_chances[stage]))
		to_chat(H, "<span class='danger'>You see [pick("rainbows", "puppies", "banana pies")] for a moment.</span>")

	if(stage < 3)
		return

	var/static/list/honk_chances = list(null, null, 4, 0.66)
	if(prob(honk_chances[stage]))
		to_chat(H, "<span class='danger'>Your thoughts are interrupted by a loud <b>HONK!</b></span>")
		SEND_SOUND(H, sound(pick(18; 'sound/items/bikehorn.ogg', 1; 'sound/items/airhorn.ogg', 1; 'sound/items/airhorn2.ogg'))) // 10% chance total for an airhorn

	if(stage < 4)
		return

	if(prob(5))
		H.say(pick("HONK!", "Honk!", "Honk.", "Honk?", "Honk!!", "Honk?!", "Honk..."))

	// Semi-permanent clown mask while in last stage of infection
	if(locate(/obj/item/clothing/mask/gas/clown_hat) in H)
		return
	if(!istype(H)) // Xenos don't have masks. They can still feel silly though
		return

	if(!H.has_organ_for_slot(ITEM_SLOT_MASK) || !H.canUnEquip(H.get_item_by_slot(ITEM_SLOT_MASK)))
		return

	var/saved_internals = H.internal

	H.drop_item_to_ground(H.get_item_by_slot(ITEM_SLOT_MASK))
	var/obj/item/clothing/mask/gas/clown_hat/peak_comedy = new
	peak_comedy.flags |= DROPDEL
	H.equip_to_slot_or_del(peak_comedy, ITEM_SLOT_MASK)

	if(saved_internals) // Let's not stealthily suffocate Vox/Plasmamen, this isn't a murder virus
		H.internal = saved_internals
		H.update_action_buttons_icon()

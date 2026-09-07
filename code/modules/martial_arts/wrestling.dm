/datum/martial_art/wrestling
	name = "Wrestling"
	weight = 3
	has_explaination_verb = TRUE

//	combo refence since wrestling uses a different format to sleeping carp and plasma fist.
//	Clinch "G"
//	Suplex "GD"
//	Advanced grab "G"

/datum/martial_art/wrestling/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	D.grabbedby(A,1)
	var/obj/item/grab/G = A.get_active_hand()
	if(G && prob(50))
		G.state = GRAB_AGGRESSIVE
		D.visible_message(SPAN_DANGER("[A] has [D] in a clinch!"), \
								SPAN_USERDANGER("[A] has [D] in a clinch!"))
	else
		D.visible_message(SPAN_DANGER("[A] fails to get [D] in a clinch!"), \
								SPAN_USERDANGER("[A] fails to get [D] in a clinch!"))
	return 1


/datum/martial_art/wrestling/proc/Suplex(mob/living/carbon/human/A, mob/living/carbon/human/D)

	D.visible_message(SPAN_DANGER("[A] suplexes [D]!"), \
								SPAN_USERDANGER("[A] suplexes [D]!"))
	D.forceMove(A.loc)
	var/armor_block = D.run_armor_check(armor_type = MELEE)
	D.apply_damage(30, BRUTE, null, armor_block)
	D.apply_effect(12 SECONDS, WEAKEN, armor_block)
	add_attack_logs(A, D, "Melee attacked with [src] (SUPLEX)")

	A.SpinAnimation(10,1)

	D.SpinAnimation(10,1)
	spawn(3)
		armor_block = A.run_armor_check(armor_type = MELEE)
		A.apply_effect(8 SECONDS, WEAKEN, armor_block)
	return

/datum/martial_art/wrestling/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(istype(A.get_inactive_hand(),/obj/item/grab))
		var/obj/item/grab/G = A.get_inactive_hand()
		if(G.affecting == D)
			Suplex(A,D)
			return 1
	harm_act(A,D)
	return 1

/datum/martial_art/wrestling/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	D.grabbedby(A,1)
	D.visible_message(SPAN_DANGER("[A] holds [D] down!"), \
								SPAN_USERDANGER("[A] holds [D] down!"))
	var/obj/item/organ/external/affecting = D.get_organ(ran_zone(A.zone_selected))
	var/armor_block = D.run_armor_check(affecting, MELEE)
	D.apply_damage(10, STAMINA, affecting, armor_block)
	return 1

/datum/martial_art/wrestling/explaination_header(user)
	. = ..()
	to_chat(user, "<b><i>You flex your muscles and have a revelation...</i></b>")

/datum/martial_art/wrestling/explaination_combos(user)
	. = ..()
	to_chat(user, "[SPAN_NOTICE("Clinch")]: Grab. Passively gives you a chance to immediately aggressively grab someone. Not always successful.")
	to_chat(user, "[SPAN_NOTICE("Suplex")]: Disarm someone you are grabbing. Suplexes your target to the floor. Greatly injures them and leaves both you and your target on the floor.")
	to_chat(user, "[SPAN_NOTICE("Advanced grab")]: Grab. Passively causes stamina damage when grabbing someone.")

/obj/item/storage/belt/champion/wrestling
	name = "Wrestling Belt"
	layer_over_suit = TRUE
	var/datum/martial_art/wrestling/style

/obj/item/storage/belt/champion/wrestling/Initialize(mapload)
	. = ..()
	style = new()

/obj/item/storage/belt/champion/wrestling/equipped(mob/user, slot)
	if(!ishuman(user))
		return
	if(slot == ITEM_SLOT_BELT)
		var/mob/living/carbon/human/H = user
		if(HAS_TRAIT(user, TRAIT_PACIFISM))
			to_chat(user, SPAN_WARNING("In spite of the grandiosity of the belt, you don't feel like getting into any fights."))
			return
		style.teach(H, TRUE)
		to_chat(user, SPAN_SCIRADIO("You have an urge to flex your muscles and get into a fight. You have the knowledge of a thousand wrestlers before you. You can remember more by using the verb in the martial arts tab."))
	return

/obj/item/storage/belt/champion/wrestling/dropped(mob/user)
	..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(ITEM_SLOT_BELT) == src)
		style.remove(H)
		to_chat(user, SPAN_SCIRADIO("You no longer have an urge to flex your muscles."))

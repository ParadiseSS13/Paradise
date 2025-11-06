/datum/martial_art/mimejutsu
	name = "Mimejutsu"
	weight = 6
	has_explaination_verb = TRUE
	combos = list(/datum/martial_combo/mimejutsu/mimechucks, /datum/martial_combo/mimejutsu/smokebomb, /datum/martial_combo/mimejutsu/silent_palm)

/datum/martial_art/mimejutsu/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	return TRUE

/datum/martial_art/mimejutsu/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	A.do_attack_animation(D)
	return TRUE

/obj/item/mimejutsu_scroll
	name = "Mimejutsu 'scroll'"
	desc = "Its a beret with a note stapled to it..."
	icon = 'icons/obj/clothing/head/beret.dmi'
	icon_state = "beret"
	var/used = FALSE

/obj/item/mimejutsu_scroll/attack_self__legacy__attackchain(mob/user as mob)
	if(!ishuman(user))
		return
	if(!used)
		var/mob/living/carbon/human/H = user
		var/datum/martial_art/mimejutsu/F = new/datum/martial_art/mimejutsu(null)
		F.teach(H)
		to_chat(H, "<span class='boldannounceic'>You have learned the ancient martial art of mimes.</span>")
		used = TRUE
		desc = "It used to have something stapled to it..the staple is still there."
		name = "beret with staple"
		icon_state = "beret"

/datum/martial_art/mimejutsu/explaination_header(user)
	to_chat(user, "<b><i>You make a invisible box around yourself and recall the teachings of Mimejutsu...</i></b>")

/datum/martial_art/mimejutsu
	name = "Mimejutsu"
	has_explaination_verb = TRUE
	combos = list(/datum/martial_combo/mimejutsu/mimechucks, /datum/martial_combo/mimejutsu/smokebomb, /datum/martial_combo/mimejutsu/silent_palm)

/datum/martial_art/mimejutsu/grab_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	return TRUE

/datum/martial_art/mimejutsu/harm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	A.do_attack_animation(D)
	return TRUE

/obj/item/mimejutsu_scroll
	name = "Mimejutsu 'scroll'"
	desc =	"Its a beret with a note stapled to it..."
	icon = 'icons/obj/clothing/hats.dmi'
	icon_state = "beret"
	var/used = 0

/obj/item/mimejutsu_scroll/attack_self(mob/user as mob)
	if(!ishuman(user))
		return
	if(!used)
		var/mob/living/carbon/human/H = user
		var/datum/martial_art/mimejutsu/F = new/datum/martial_art/mimejutsu(null)
		F.teach(H)
		to_chat(H, "<span class='boldannounce'>You have learned the ancient martial art of mimes.</span>")
		used = 1
		desc = "It used to have something stapled to it..the staple is still there."
		name = "beret with staple"
		icon_state = "beret"

/datum/martial_art/mimejutsu/explaination_header(user)
	to_chat(user, "<b><i>You make a invisible box around yourself and recall the teachings of Mimejutsu...</i></b>")

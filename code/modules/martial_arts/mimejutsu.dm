/datum/martial_art/mimejutsu
	name = "Мимдзюцу"
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
	name = "Берет мастера мимдзюцу"
	desc =	"Берет, к которому степлером прикреплена старая записка…"
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
		to_chat(H, "<span class='boldannounce'>Вы изучили древнее боевое искусство пантомимы…</span>")
		used = 1
		desc = "Похоже, к нему что-то было приколото степплером…"
		name = "берет со скобой"
		icon_state = "beret"
//не работает Grab. Будет пофикшено в следующих коммитах

/datum/martial_art/mimejutsu/explaination_header(user)
	to_chat(user, "<b><i>Вы создаете вокруг себя невидимый ящик, вспоминая учения Мимдзюцу...</i></b>")

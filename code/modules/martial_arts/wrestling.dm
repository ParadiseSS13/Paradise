/datum/martial_art/wrestling
	name = "Борьба"
	help_verb = /mob/living/carbon/human/proc/wrestling_help

//	combo refence since wrestling uses a different format to sleeping carp and plasma fist.
//	Clinch "G"
//	Suplex "GD"
//	Advanced grab "G"

/datum/martial_art/wrestling/harm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	D.grabbedby(A,1)
	var/obj/item/grab/G = A.get_active_hand()
	if(G && prob(50))
		G.state = GRAB_AGGRESSIVE
		D.visible_message("<span class='danger'>[A] бер[pluralize_ru(A.gender,"ёт","ут")] [D] в клинч!</span>", \
								"<span class='userdanger'>[A] попал[genderize_ru(A.gender,"","а","о","и")] в клинч [D]!</span>")
	else
		D.visible_message("<span class='danger'>[A] не смог[genderize_ru(A.gender,"","ла","ло","ли")] взять [D] в клинч!</span>", \
								"<span class='userdanger'>[A] не смог[genderize_ru(A.gender,"","ла","ло","ли")] взять [D] в клинч!</span>")
	return 1


/datum/martial_art/wrestling/proc/Suplex(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)

	D.visible_message("<span class='danger'>[A] бер[pluralize_ru(A.gender,"ёт","ут")] в суплекс [D]!</span>", \
								"<span class='userdanger'>[A] бер[pluralize_ru(A.gender,"ет","ут")] в суплекс [D]!</span>")
	D.forceMove(A.loc)
	var/armor_block = D.run_armor_check(null, "melee")
	D.apply_damage(30, BRUTE, null, armor_block)
	D.apply_effect(6, WEAKEN, armor_block)
	add_attack_logs(A, D, "Melee attacked with [src] (SUPLEX)")

	A.SpinAnimation(10,1)

	D.SpinAnimation(10,1)
	spawn(3)
		armor_block = A.run_armor_check(null, "melee")
		A.apply_effect(4, WEAKEN, armor_block)
	return

/datum/martial_art/wrestling/disarm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	if(istype(A.get_inactive_hand(),/obj/item/grab))
		var/obj/item/grab/G = A.get_inactive_hand()
		if(G.affecting == D)
			Suplex(A,D)
			return 1
	harm_act(A,D)
	return 1

/datum/martial_art/wrestling/grab_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	D.grabbedby(A,1)
	D.visible_message("<span class='danger'>[A] хвата[pluralize_ru(A.gender,"ет","ют")] [D]!</span>", \
								"<span class='userdanger'>[A] удержива[pluralize_ru(A.gender,"ет","ют")] [D]!</span>")
	var/obj/item/organ/external/affecting = D.get_organ(ran_zone(A.zone_selected))
	var/armor_block = D.run_armor_check(affecting, "melee")
	D.apply_damage(10, STAMINA, affecting, armor_block)
	return 1

/mob/living/carbon/human/proc/wrestling_help()
	set name = "Вспомнить уроки"
	set desc = "Вспомнить как бороться."
	set category = "Борьба"

	to_chat(usr, "<b><i>Вы напрягаете мускулы и испытываете озарение…</i></b>")
	to_chat(usr, "<span class='notice'>Клинч</span>: Схватить. Даёт пассивный шанс немедленно взять в агрессивный захват. Не всегда успешно.")
	to_chat(usr, "<span class='notice'>Суплекс</span>: Обезоружьте того, кого хватаете, захватывая в суплекс на полу. Сильно ранит вашу цель, оставляя её и вас на полу.")
	to_chat(usr, "<span class='notice'>Продвинутый захват</span>: Захват. Пассивно наносит урон выносливости оппонента при попытках захвата.")

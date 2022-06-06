/datum/martial_art/synthojitsu
	name = "Синтдзюцу"
	block_chance = 0
	has_explaination_verb = TRUE
	combos = list(/datum/martial_combo/synthojitsu/lock, /datum/martial_combo/synthojitsu/overload, /datum/martial_combo/synthojitsu/reanimate)

/datum/martial_art/synthojitsu/can_use(mob/living/carbon/human/H)
	if(!ismachineperson(H) || H.nutrition == 0)
		return FALSE
	return ..()

/datum/martial_art/synthojitsu/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	add_attack_logs(A, D, "Melee attacked with martial-art [src]", ATKLOG_ALL)
	A.do_attack_animation(D)
	D.apply_damage(5, BURN)
	D.apply_damage(5, BRUTE)
	A.adjust_nutrition(-10)
	playsound(get_turf(D), 'sound/weapons/cqchit1.ogg', 50, 1, -1)
	D.visible_message("<span class='danger'>[A] ударил[genderize_ru(A.gender,"","а","о","и")] током [D]!</span>", \
					  "<span class='userdanger'>[A] ударил[genderize_ru(A.gender,"","а","о","и")] вас током!</span>")
	add_attack_logs(A, D, "Melee attacked with martial-art [src]", ATKLOG_ALL)
	return TRUE

/datum/martial_art/synthojitsu/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	A.do_attack_animation(D)
	add_attack_logs(A, D, "Melee attacked with martial-art [src]", ATKLOG_ALL)
	D.apply_damage(30, STAMINA)
	A.adjust_nutrition(-10)
	playsound(get_turf(D), 'sound/weapons/contractorbatonhit.ogg', 50, 1, -1)
	D.visible_message("<span class='danger'>[A] коснул[genderize_ru(A.gender,"ся","ась","ось","ись")] [D]!</span>", \
				  "<span class='userdanger'>[A] коснул[genderize_ru(A.gender,"ся","ась","ось","ись")] вас!</span>")
	return TRUE

/obj/item/ipc_combat_upgrade
	name = "боевое улучшение КПБ"
	desc = "Продвинутая база данных, совместимая с позитронными системами. Содержит алгоритмы ближнего боя и процедуры перезаписи протоколов безопасности микробатарей."
	icon = 'icons/obj/ipc_module.dmi'
	icon_state ="viable"
	var/is_used = FALSE

/obj/item/ipc_combat_upgrade/attack_self(mob/user as mob)
	if(!ismachineperson(user) || is_used == TRUE)
		return
	to_chat(user, "<span class='notice'>Начата установка. Ожидание завершения работы…</span>")
	if(do_after(user, 100))
		var/mob/living/carbon/human/H = user
		var/datum/martial_art/synthojitsu/F = new/datum/martial_art/synthojitsu(null)
		F.teach(H)
		H.adjustBrainLoss(50)
		H.Weaken(5)
		to_chat(H, "<span class='boldannounce'>Алгоритмы ближнего боя установлены. Протоколы безопасности отключены.</span>")
		is_used = TRUE
		desc = "Продвинутая база данных, совместимая с позитронными системами. Содержит алгоритмы ближнего боя и процедуры перезаписи протоколов безопасности микробатарей. Стоит блокировка."
		name = "боевое улучшение IPC"
		icon_state = "unviable"

/datum/martial_art/synthojitsu/explaination_header(user)
	to_chat(user, "<b><i>Вы повторно загружаете основы Синдзюцу</i></b>")

/datum/martial_art/synthojitsu/explaination_footer(user)
	to_chat(user, "<b><i>Ваши атаки будут наносить дополнительный обжигающий урон. Попытки обезоруживания истощат противника. Все атаки и комбинации истощат внутреннюю батарею.</i></b>")

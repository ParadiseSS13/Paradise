/obj/machinery/wish_granter_dark
	name = "Исполнитель Желаний"
	desc = "Вы уже не уверены в этом..."
	icon = 'modular_ss220/maps220/icons/wish_granter.dmi'
	icon_state = "wish_granter"

	anchored = TRUE
	density = TRUE
	power_state = NO_POWER_USE

	/// The various mutations that are given when making a Power wish
	var/power_mutations
	/// How many times can be used
	var/charges = 1
	/// Has it been clicked once? (Need for warning users)
	var/insisting = FALSE

/obj/machinery/wish_granter_dark/Initialize(mapload)
	. = ..()
	power_mutations = list(/datum/mutation/meson_vision, /datum/mutation/night_vision, /datum/mutation/cold_resist, /datum/mutation/grant_spell/cryo)

/obj/machinery/wish_granter_dark/examine(mob/user)
	. = ..()
	if(IS_CULTIST(user))
		. += span_cultspeech("Ваше культисткое чутье подсказывает вам, что [name] искушает вас, дабы завладеть вашей душой.")
	if(!charges)
		. += span_notice("[name] не подаёт никаких признаков активности.")
	else
		. += span_notice("[name] издаётся манящим кроваво-красным светом.")

/obj/machinery/wish_granter_dark/update_icon_state()
	if(!charges)
		icon_state = initial(icon_state) + "_dormant"
	if(insisting)
		icon_state = initial(icon_state) + "_pulse"

/obj/machinery/wish_granter_dark/attack_hand(mob/living/carbon/human/user as mob)
	usr.set_machine(src)

	if(!charges)
		to_chat(user, span_notice("[name] никак не реагирует."))
		return

	else if(!ishuman(user))
		to_chat(user, span_warning("Вы чувствуете темное движение внутри [name], которого опасаются ваши инстинкты."))
		return

	else if(is_special_character(user))
		to_chat(user, span_notice("Что-то инстинктивно заставляет вас отстраниться."))
		return

	else if(!insisting)
		to_chat(user, span_cult("Ваше первое прикосновение заставляет [name] зашевелиться, прислушиваясь к вам. Вы действительно уверены, что хотите это сделать?"))
		insisting = TRUE
		update_icon_state()
		return

	insisting = FALSE
	var/wish = tgui_input_list(user, "Вы хотите...", "Желание", list("Силу", "Богатство", "Бессмертие", "Покой"))
	if(!wish)
		return
	charges--
	update_icon_state()

	var/mob/living/carbon/human/human = user
	var/become_shadow = TRUE
	var/list/output = list()
	switch(wish)
		if("Силу")
			for(var/mutation_type in power_mutations)
				var/datum/mutation/mutation = GLOB.dna_mutations[mutation_type]
				mutation.activate(human)

		if("Богатство")
			new /obj/structure/closet/syndicate/resources/everything(loc)

		if("Бессмертие")
			user.verbs |= /mob/living/carbon/human/proc/immortality

		if("Покой")
			for(var/mob/living/simple_animal/hostile/faithless/F in GLOB.mob_living_list)
				F.death()
			become_shadow = FALSE

	if(become_shadow && !isshadowperson(human))
		to_chat(user, span_warning("Ваша плоть темнеет!"))
		to_chat(user, span_warning("Ваше тело бурно реагирует на свет, однако естественным образом исцеляется в темноте..."))
		output.Add(span_userdanger("Ваше желание исполнено, но какой ценой?..."))
		output.Add(span_danger("[name] наказывает вас за ваш эгоизм, забирая душу и деформируя тело, чтобы оно соответствовало тьме в вашем сердце."))
		output.Add(span_revenbignotice("Вы теперь <b>Тень</b>, раса живущих во тьме гуманоидов."))
		output.Add(span_revenboldnotice("Помимо ваших новых качеств, вы психически не изменились и сохраняете свою прежнюю личность."))
		human.set_species(/datum/species/shadow)
		user.regenerate_icons()
	else
		output.Add(span_boldnotice("Вы чувствуете как избежали горькой судьбы..."))
		output.Add(span_notice("Каким бы инопланетным разумом ни обладал [name], оно удовлетворяет ваше желание.\nНаступает тишина..."))

	to_chat(user, chat_box_red(output.Join("<br>")))

#define TRAIT_REVIVAL_IN_PROGRESS "revival_in_progress"

/mob/living/carbon/human/proc/immortality()
	set category = "Бессмертие"
	set name = "Возрождение"

	if(stat != DEAD)
		to_chat(src, span_notice("Вы еще живы!"))
		return

	if(HAS_TRAIT(src, TRAIT_REVIVAL_IN_PROGRESS))
		to_chat(src, span_notice("Вы уже восстаёте из мертвых!"))
		return

	ADD_TRAIT(src, TRAIT_REVIVAL_IN_PROGRESS, "Immortality")
	to_chat(src, span_notice("Смерть - ещё не конец!"))
	addtimer(CALLBACK(src, TYPE_PROC_REF(/mob/living/carbon/human, resurrect)), rand(80 SECONDS, 120 SECONDS))

/mob/living/carbon/human/proc/resurrect()
	revive()
	REMOVE_TRAIT(src, TRAIT_REVIVAL_IN_PROGRESS, "Immortality")
	to_chat(src, span_notice("Вы вернулись из небытия."))
	visible_message(span_warning("[name] восстаёт из мертвых, исцелив все свои раны!"))

#undef TRAIT_REVIVAL_IN_PROGRESS

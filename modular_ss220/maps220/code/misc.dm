/obj/machinery/wish_granter_dark
	name = "Исполнитель Желаний"
	desc = "Вы уже не уверены в этом..."
	icon = 'icons/obj/device.dmi'
	icon_state = "syndbeacon"

	anchored = TRUE
	density = TRUE
	power_state = NO_POWER_USE

	var/power_mutations
	var/charges = 1
	var/insisting = FALSE

/obj/machinery/wish_granter_dark/Initialize(mapload)
	. = ..()
	power_mutations = list(/datum/mutation/meson_vision, /datum/mutation/night_vision, /datum/mutation/cold_resist, /datum/mutation/grant_spell/cryo)

/obj/machinery/wish_granter_dark/attack_hand(mob/living/carbon/human/user as mob)
	usr.set_machine(src)

	if(!charges)
		to_chat(user, "[name] никак не реагирует.")
		return

	else if(!ishuman(user))
		to_chat(user, "Вы чувствуете темное движение внутри [name], которого опасаются ваши инстинкты.")
		return

	else if(is_special_character(user))
		to_chat(user, "Что-то инстинктивно заставляет вас отстраниться.")
		return

	else if(!insisting)
		to_chat(user, "Ваше первое прикосновение заставляет [name] зашевелиться, прислушиваясь к вам. Вы действительно уверены, что хотите это сделать?")
		insisting = TRUE
		return

	insisting = FALSE
	var/wish = tgui_input_list("Вы хотите...", "Желание", list("Силу", "Богатство", "Бессмертие", "Покой"))
	if(!wish)
		return
	charges--

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
		output += "<B>Ваше желание исполнено, но какой ценой...</B>"
		output += "[name] наказывает вас за ваш эгоизм, забирая вашу душу и деформируя ваше тело, чтобы оно соответствовало тьме в вашем сердце."
		output += span_warning("Ваша плоть темнеет!")
		output += "<b>Вы теперь Тень, раса живущих во тьме гуманоидов.</b>"
		output += span_warning("Ваше тело бурно реагирует на свет.") + span_notice("Однако естественным образом исцеляется в темноте..")
		output += "Помимо ваших новых качеств, вы психически не изменились и сохраняете свою прежнюю личность."
		human.set_species(/datum/species/shadow)
		user.regenerate_icons()
	else
		output += "Вы чувствуете как избежали горькой судьбы..."
		output += "<B>Каким бы инопланетным разумом ни обладал [name], оно удовлетворяет ваше желание. Наступает тишина...</B>"

	to_chat(user, output.Join("<br>"))

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
	visible_message(span_warning("[name] восстаёт из мертвых, исцелив все свои раны"))

#undef TRAIT_REVIVAL_IN_PROGRESS

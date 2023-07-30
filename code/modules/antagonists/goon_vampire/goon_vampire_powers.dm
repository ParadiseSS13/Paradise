/**
 * Goon Vampire spell handler.
 */
/datum/spell_handler/goon_vampire
	var/required_blood


/datum/spell_handler/goon_vampire/can_cast(mob/user, charge_check, show_message, obj/effect/proc_holder/spell/spell)

	var/datum/antagonist/goon_vampire/vampire = user?.mind?.has_antag_datum(/datum/antagonist/goon_vampire)

	if(!vampire)
		return FALSE

	var/fullpower = vampire.get_ability(/datum/goon_vampire_passive/full)

	if(user.stat >= DEAD)
		if(show_message)
			to_chat(user, span_warning("Но вы же мертвы!"))
		return FALSE

	if(vampire.nullified && !fullpower)
		if(show_message)
			to_chat(user, span_warning("Что-то блокирует ваши силы!"))
		return FALSE

	if(vampire.bloodusable < required_blood)
		if(show_message)
			to_chat(user, span_warning("Для этого вам потребуется не менее [required_blood] единиц крови!"))
		return FALSE

	//chapel check
	if(is_type_in_typecache(get_area(user), GLOB.holy_areas) && !fullpower)
		if(show_message)
			to_chat(user, span_warning("Ваши силы не действуют на этой святой земле."))
		return FALSE

	return TRUE


/datum/spell_handler/goon_vampire/spend_spell_cost(mob/user, obj/effect/proc_holder/spell/spell)
	for(var/datum/action/spell_action/action in user.actions)
		action.UpdateButtonIcon()

	if(!required_blood) //don't take the blood yet if this is false!
		return

	var/datum/antagonist/goon_vampire/vamp = user?.mind?.has_antag_datum(/datum/antagonist/goon_vampire)
	vamp?.bloodusable -= required_blood


/datum/spell_handler/goon_vampire/revert_cast(mob/living/carbon/user, obj/effect/proc_holder/spell/spell)
	var/datum/antagonist/goon_vampire/vamp = user?.mind?.has_antag_datum(/datum/antagonist/goon_vampire)
	vamp?.bloodusable += required_blood


/datum/spell_handler/goon_vampire/after_cast(list/targets, mob/user, obj/effect/proc_holder/spell/spell)

	SSblackbox.record_feedback("tally", "goon_vampire_powers_used", 1, "[spell]")

	if(!required_blood)
		return

	var/datum/antagonist/goon_vampire/vamp = user?.mind?.has_antag_datum(/datum/antagonist/goon_vampire)
	to_chat(user, span_boldnotice("У Вас осталось [vamp.bloodusable] единиц крови."))


/*******************
 * Spell handler end.
 ******************/


/**
 * Basis of all vampire spells.
 */
/obj/effect/proc_holder/spell/goon_vampire
	name = "Report Me"
	desc = "You shouldn't see this!"
	panel = "Vampire"
	school = "vampire"
	action_background_icon_state = "bg_vampire_old"
	human_req = TRUE
	clothes_req = FALSE
	base_cooldown = 3 MINUTES
	gain_desc = ""
	/// How much blood this ability costs to use
	var/required_blood


/obj/effect/proc_holder/spell/goon_vampire/after_spell_init()
	update_name()


/obj/effect/proc_holder/spell/goon_vampire/proc/update_name(mob/user = usr)
	if(required_blood)
		var/new_name = "[name] ([required_blood])"
		name = new_name
		action?.name = new_name
		action?.UpdateButtonIcon()


/obj/effect/proc_holder/spell/goon_vampire/create_new_handler()
	var/datum/spell_handler/goon_vampire/H = new()
	H.required_blood = required_blood
	return H


/obj/effect/proc_holder/spell/goon_vampire/self/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/goon_vampire/targetted
	var/range = 1


/obj/effect/proc_holder/spell/goon_vampire/targetted/create_new_targeting()
	var/datum/spell_targeting/targeted/T = new()
	T.range = range
	return T


/obj/effect/proc_holder/spell/goon_vampire/proc/affects(mob/target, mob/user = usr)

	//Other vampires aren't affected
	if(isvampire(target))
		return FALSE

	//Vampires who have reached their full potential can affect nearly everything
	var/datum/antagonist/goon_vampire/vampire = user.mind?.has_antag_datum(/datum/antagonist/goon_vampire)
	if(vampire?.get_ability(/datum/goon_vampire_passive/full))
		return TRUE

	//Holy characters are resistant to vampire powers
	if(target.mind?.isholy)
		return FALSE

	return TRUE


////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/effect/proc_holder/spell/goon_vampire/self/rejuvenate
	name = "Восстановление"
	desc= "Используйте накопленную кровь, чтобы влить в тело новые силы, устраняя любое ошеломление"
	action_icon_state = "vampire_rejuvinate_old"
	base_cooldown = 20 SECONDS
	stat_allowed = UNCONSCIOUS
	var/effect_timer
	var/counter = 0


/obj/effect/proc_holder/spell/goon_vampire/self/rejuvenate/cast(list/targets, mob/living/carbon/human/user = usr)
	user.SetWeakened(0)
	user.SetStunned(0)
	user.SetParalysis(0)
	user.SetSleeping(0)
	user.adjustStaminaLoss(-60)
	user.lying = FALSE
	user.resting = FALSE
	user.update_canmove()
	to_chat(user, span_notice("Ваше тело наполняется чистой кровью, снимая все ошеломляющие эффекты."))
	var/datum/antagonist/goon_vampire/vampire = user.mind.has_antag_datum(/datum/antagonist/goon_vampire)
	if(vampire?.get_ability(/datum/goon_vampire_passive/regen))
		effect_timer = addtimer(CALLBACK(src, PROC_REF(rejuvenate_effect), user), 3.5 SECONDS, TIMER_STOPPABLE|TIMER_LOOP)


/obj/effect/proc_holder/spell/goon_vampire/self/rejuvenate/proc/rejuvenate_effect(mob/living/carbon/human/user)
	if(QDELETED(user) || counter > 5)
		deltimer(effect_timer)
		effect_timer = null
		counter = 0
		return

	counter++
	user.adjustBruteLoss(-2)
	user.adjustOxyLoss(-5)
	user.adjustToxLoss(-2)
	user.adjustFireLoss(-2)
	user.adjustStaminaLoss(-10)


/obj/effect/proc_holder/spell/goon_vampire/targetted/hypnotise
	name = "Гипноз"
	desc= "Пронзающий взгляд, ошеломляющий жертву на довольно долгое время"
	action_icon_state = "vampire_hypnotise"
	required_blood = 25


/obj/effect/proc_holder/spell/goon_vampire/targetted/hypnotise/cast(list/targets, mob/living/carbon/human/user = usr)
	var/mob/living/carbon/human/target = targets[1]

	user.visible_message(span_warning("Глаза [user] ярко вспыхивают, когда он[genderize_ru(user.gender,"","а","о","и")] пристально смотр[genderize_ru(user.gender,"ит","ит","ит","ят")] в глаза [target]."))
	if(do_mob(user, target, 6 SECONDS))
		if(!affects(target))
			to_chat(user, span_warning("Ваш пронзительный взгляд не смог заворожить [target]."))
			to_chat(target, span_notice("Невыразительный взгляд [user] ничего вам не делает."))
		else
			to_chat(user, span_warning("Ваш пронзающий взгляд завораживает [target]."))
			to_chat(target, span_warning("Вы чувствуете сильную слабость."))
			target.SetSleeping(40 SECONDS)
	else
		revert_cast(user)
		to_chat(user, span_warning("Вы смотрите в никуда."))


/obj/effect/proc_holder/spell/goon_vampire/targetted/disease
	name = "Заражающее касание"
	desc = "Ваше касание инфицирует кровь жертвы, заражая её могильной лихорадкой. Пока лихорадку не вылечат, жертва будет с трудом держаться на ногах, а её кровь будет наполняться токсинами."
	gain_desc = "Вы получили способность «Заражающее касание». Она позволит вам ослаблять тех, кого вы коснётесь до тех пор, пока их не вылечат."
	action_icon_state = "vampire_disease"
	required_blood = 50


/obj/effect/proc_holder/spell/goon_vampire/targetted/disease/cast(list/targets, mob/living/carbon/human/user = usr)
	var/mob/living/carbon/human/target = targets[1]

	to_chat(user, span_warning("Вы незаметно инфицируете [target] заражающим касанием."))
	target.help_shake_act(user)
	if(!affects(target))
		to_chat(user, span_warning("Вам кажется, что заражающее касание не подействовало на [target]."))
		return

	var/datum/disease/virus = new /datum/disease/vampire
	target.ForceContractDisease(virus)


/obj/effect/proc_holder/spell/goon_vampire/glare
	name = "Вспышка"
	desc = "Вы сверкаете глазами, ненадолго ошеломляя всех людей вокруг"
	action_icon_state = "vampire_glare_old"
	base_cooldown = 30 SECONDS
	stat_allowed = UNCONSCIOUS


/obj/effect/proc_holder/spell/goon_vampire/glare/create_new_targeting()
	var/datum/spell_targeting/aoe/T = new()
	T.range = 1
	T.allowed_type = /mob/living/carbon
	return T


/obj/effect/proc_holder/spell/goon_vampire/glare/cast(list/targets, mob/living/carbon/human/user = usr)
	if(!length(targets))
		revert_cast(user)
		return

	if(istype(user.glasses, /obj/item/clothing/glasses/sunglasses/blindfold))
		to_chat(user, span_warning("У вас на глазах повязка!"))
		return

	user.visible_message(span_warning("Глаза [user] ослепительно вспыхивают!"))

	for(var/mob/living/carbon/human/target in targets)
		if(!affects(target))
			continue

		if(isninja(target))
			var/mob/living/carbon/human/target_human = target
			var/obj/item/clothing/glasses/ninja/ninja_visor = target_human.glasses

			if(istype(ninja_visor) && ninja_visor.vamp_protection_active && ninja_visor.current_mode == "flashprotection")
				to_chat(target, span_warning("Глаза [user] засветились, но ваш визор защитил вас."))
				continue

		target.Weaken(4 SECONDS)
		target.AdjustStuttering(40 SECONDS)
		target.adjustStaminaLoss(20)
		to_chat(target, span_userdanger("Вы ослеплены вспышкой из глаз [user]."))
		add_attack_logs(user, target, "(Vampire) слепит")
		target.apply_status_effect(STATUS_EFFECT_STAMINADOT)


/obj/effect/proc_holder/spell/goon_vampire/self/shapeshift
	name = "Превращение"
	desc = "Изменяет ваше имя и внешность, тратя 50 крови, с откатом в 3 минуты."
	gain_desc = "Вы получили способность «Превращение», позволяющую навсегда обернуться другим обликом, затратив часть накопленной крови."
	action_icon_state = "genetic_poly"
	required_blood = 50


/obj/effect/proc_holder/spell/goon_vampire/self/shapeshift/cast(list/targets, mob/living/carbon/human/user = usr)
	user.visible_message(span_warning("[user] transforms!"))

	scramble(TRUE, user, 100)
	user.real_name = random_name(user.gender, user.dna.species.name) //Give them a name that makes sense for their species.
	user.sync_organ_dna(assimilate = TRUE)
	user.update_body()
	user.reset_hair() //No more winding up with hairstyles you're not supposed to have, and blowing your cover.
	user.reset_markings() //...Or markings.
	user.dna.ResetUIFrom(user)
	user.flavor_text = ""
	user.update_icons()


/obj/effect/proc_holder/spell/goon_vampire/self/screech
	name = "Визг рукокрылых"
	desc = "Невероятно громкий визг, разбивающий стёкла и ошеломляющий окружающих."
	gain_desc = "Вы получили способность «Визг рукокрылых», в большом радиусе оглушающую всех, кто может слышать, и раскалывающую стёкла."
	action_icon_state = "vampire_screech"
	required_blood = 30


/obj/effect/proc_holder/spell/goon_vampire/self/screech/cast(list/targets, mob/user = usr)

	playsound(user.loc, 'sound/effects/creepyshriek.ogg', 100, TRUE)
	user.visible_message(span_warning("[user] издаёт душераздирающий визг!"), \
						span_warning("Вы громко визжите."), \
						span_italics("Вы слышите болезненно громкий визг!"))

	for(var/mob/living/carbon/target in hearers(4))
		if(target == user)
			continue

		if(ishuman(target))
			var/mob/living/carbon/human/h_target = target
			if(h_target.check_ear_prot() >= HEARING_PROTECTION_TOTAL)
				continue

		if(!affects(target))
			continue

		if(isninja(target))
			var/obj/item/clothing/suit/space/space_ninja/ninja_suit = target.wear_suit
			if(istype(ninja_suit) && ninja_suit.vamp_protection_active && ninja_suit.s_initialized)
				to_chat(target, span_warning("<b>Вы начали слышать жуткий визг!</b> Но ваш костюм отреагировал на него и временно прикрыл вам уши, минимизируя урон"))
				target.Deaf(20 SECONDS)
				target.Jitter(100 SECONDS)
				target.adjustStaminaLoss(20)
				continue

		to_chat(target, span_warning("<font size='3'><b>Вы слышите ушераздирающий визг и ваши чувства притупляются!</font></b>"))
		target.Weaken(4 SECONDS)
		target.Deaf(40 SECONDS)
		target.Stuttering(40 SECONDS)
		target.Jitter(300 SECONDS)
		target.adjustStaminaLoss(60)

	for(var/obj/structure/window/window in view(4))
		window.deconstruct(FALSE)


/obj/effect/proc_holder/spell/goon_vampire/targetted/enthrall
	name = "Порабощение"
	desc = "Вы используете большую часть своей силы, вынуждая тех, кто ещё никому не служит, служить только вам."
	gain_desc = "Вы получили способность «Порабощение», которая тратит много крови, но позволяет вам поработить человека, который ещё никому не служит, на случайный период времени."
	action_icon_state = "vampire_enthrall_old"
	required_blood = 300


/obj/effect/proc_holder/spell/goon_vampire/targetted/enthrall/cast(list/targets, mob/living/carbon/human/user = usr)

	var/mob/living/carbon/human/target = targets[1]

	if(!ishuman(target))
		to_chat(user, span_warning("Вы можете порабощать только гуманоидов."))
		return

	user.visible_message(span_warning("[user] кусает [target] в шею!"), \
						span_warning("Вы кусаете [target] в шею и начинаете передачу части своей силы."))
	to_chat(target, span_warning("Вы ощущаете, как щупальца зла впиваются в ваш разум."))

	if(do_mob(user, target, 5 SECONDS))
		if(can_enthrall(user, target))
			handle_enthrall(user, target)
		else
			revert_cast(user)
	else
		revert_cast(user)



/obj/effect/proc_holder/spell/goon_vampire/targetted/enthrall/proc/can_enthrall(mob/living/carbon/human/user, mob/living/carbon/target)

	var/enthrall_safe = FALSE
	for(var/obj/item/implant/mindshield/implant in target)
		if(implant?.implanted)
			enthrall_safe = TRUE
			break

	for(var/obj/item/implant/traitor/implant in target)
		if(implant?.implanted)
			enthrall_safe = TRUE
			break

	if(!target)
		log_runtime(EXCEPTION("При порабощении моба случилось что-то плохое. Атакующий: [user] [user.key] \ref[user]"), user)
		return FALSE

	if(!target.mind)
		to_chat(user, span_warning("Разум [target.name] сейчас не здесь, поэтому порабощение не удастся."))
		return FALSE

	if(enthrall_safe || isvampire(target) || isvampirethrall(target))
		target.visible_message(span_warning("Похоже что [target] сопротивляется захвату!"), \
							span_notice("Вы ощущаете в голове знакомое ощущение, но оно быстро проходит."))
		return FALSE

	if(!affects(target))
		target.visible_message(span_warning("Похоже что [target] сопротивляется захвату!"), \
							span_notice("Вера в [SSticker.Bible_deity_name] защищает ваш разум от всякого зла."))
		return FALSE

	if(isninja(target))
		var/obj/item/clothing/suit/space/space_ninja/ninja_suit = target.wear_suit
		if(istype(ninja_suit) && ninja_suit.vamp_protection_active && ninja_suit.s_initialized)
			target.visible_message(span_warning("Похоже что [target] сопротивляется захвату!"), \
								span_notice("Вы ощутили сильную боль, а затем слабый укол в шею. Кажется костюм только, что защитил ваш разум..."))
			target.setBrainLoss(20)
			return FALSE

	if(!ishuman(target))
		to_chat(user, span_warning("Вы можете порабощать только гуманоидов!"))
		return FALSE

	return TRUE


/obj/effect/proc_holder/spell/goon_vampire/targetted/enthrall/proc/handle_enthrall(mob/living/user, mob/living/carbon/human/target)
	if(!istype(target))
		return FALSE

	var/greet_text = "<b>You have been Enthralled by [user.real_name]. Follow [user.p_their()] every command.</b>"
	target.mind.add_antag_datum(new /datum/antagonist/mindslave/goon_thrall(user.mind, greet_text))
	if(jobban_isbanned(target, ROLE_VAMPIRE))
		SSticker.mode.replace_jobbanned_player(target, SPECIAL_ROLE_VAMPIRE_THRALL)
	target.Stun(4 SECONDS)
	to_chat(user, span_warning("Вы успешно поработили [target]. <i>Если игрок откажется Вас слушаться, используйте adminhelp.</i>"))
	user.create_log(CONVERSION_LOG, "vampire enthralled", target)
	target.create_log(CONVERSION_LOG, "was vampire enthralled", user)


/obj/effect/proc_holder/spell/goon_vampire/self/cloak
	name = "Покров тьмы"
	desc = "Переключается, маскируя вас в темноте"
	gain_desc = "Вы получили способность «Покров тьмы», которая, будучи включённой, делает вас практически невидимым в темноте."
	action_icon_state = "vampire_cloak_old"
	base_cooldown = 1 SECONDS


/obj/effect/proc_holder/spell/goon_vampire/self/cloak/update_name(mob/user = usr)

	var/datum/antagonist/goon_vampire/vamp = user?.mind?.has_antag_datum(/datum/antagonist/goon_vampire)
	if(!vamp)
		return

	var/new_name = "[initial(name)] ([vamp.iscloaking ? "Выключить" : "Включить"])"
	name = new_name
	action?.name = new_name
	action?.UpdateButtonIcon()


/obj/effect/proc_holder/spell/goon_vampire/self/cloak/cast(list/targets, mob/living/carbon/human/user = usr)
	var/datum/antagonist/goon_vampire/vamp = user?.mind?.has_antag_datum(/datum/antagonist/goon_vampire)
	if(!vamp)
		return

	vamp.iscloaking = !vamp.iscloaking
	update_name(user)
	to_chat(user, span_notice("Теперь вас будет <b>[vamp.iscloaking ? "не видно" : "видно"]</b> в темноте."))


/obj/effect/proc_holder/spell/goon_vampire/bats
	name = "Дети ночи"
	desc = "Вы вызываете пару космолетучих мышей, которые будут биться насмерть со всеми вокруг"
	gain_desc = "Вы получили способность «Дети ночи», призывающую летучих мышей."
	action_icon_state = "vampire_bats"
	base_cooldown= 2 MINUTES
	required_blood = 50
	var/num_bats = 2


/obj/effect/proc_holder/spell/goon_vampire/bats/create_new_targeting()
	var/datum/spell_targeting/aoe/turf/T = new()
	T.selection_type = SPELL_SELECTION_RANGE
	T.use_turf_of_user = TRUE
	T.range = 1
	return T


/obj/effect/proc_holder/spell/goon_vampire/bats/valid_target(turf/target, user)
	if(target.density)
		return FALSE

	for(var/atom/check in target.contents)
		if(check.density)
			return FALSE

	return TRUE


/obj/effect/proc_holder/spell/goon_vampire/bats/cast(list/targets, mob/living/carbon/human/user = usr)
	if(length(targets) < num_bats)
		revert_cast(user)
		return

	for(var/i in 1 to num_bats)
		var/turf/target_turf = pick(targets)
		targets.Remove(target_turf)
		new /mob/living/simple_animal/hostile/scarybat(target_turf, user)


/obj/effect/proc_holder/spell/goon_vampire/self/jaunt
	name = "Облик тумана"
	desc = "Вы на короткое время превращаетесь в облако тумана"
	gain_desc = "Вы получили способность «Облик тумана», которая позволит вам превращаться в облако тумана и проходить сквозь любые препятствия."
	action_icon_state = "jaunt"
	base_cooldown = 60 SECONDS
	required_blood = 50
	centcom_cancast = FALSE
	var/jaunt_duration = 5 SECONDS //in deciseconds


/obj/effect/proc_holder/spell/goon_vampire/self/jaunt/cast(list/targets, mob/living/carbon/human/user = usr)
	spawn(0)
		var/turf/originalloc = get_turf(user.loc)
		var/obj/effect/dummy/spell_jaunt/holder = new /obj/effect/dummy/spell_jaunt(originalloc)
		var/atom/movable/overlay/animation = new /atom/movable/overlay(originalloc)
		animation.name = "water"
		animation.density = FALSE
		animation.anchored = TRUE
		animation.icon = 'icons/mob/mob.dmi'
		animation.icon_state = "liquify"
		animation.layer = 5
		animation.master = holder
		user.ExtinguishMob()
		flick("liquify", animation)
		user.forceMove(holder)
		user.client.eye = holder
		var/datum/effect_system/steam_spread/steam = new /datum/effect_system/steam_spread()
		steam.set_up(10, 0, originalloc)
		steam.start()

		sleep(jaunt_duration)
		if(QDELETED(user))
			return

		var/turf/mobloc = get_turf(user.loc)
		animation.loc = mobloc
		steam.location = mobloc
		steam.start()
		user.canmove = FALSE

		sleep(2 SECONDS)
		if(QDELETED(user))
			return

		flick("reappear",animation)

		sleep(0.5 SECONDS)
		if(QDELETED(user))
			return

		if(!user.Move(mobloc))
			for(var/direction in list(1,2,4,8,5,6,9,10))
				var/turf/check = get_step(mobloc, direction)
				if(check && user.Move(check))
					break
		user.canmove = TRUE
		user.client.eye = user
		qdel(animation)
		qdel(holder)

		for(var/datum/action/spell_action/action in user.actions)
			action.UpdateButtonIcon()


// Blink for vamps
// Less smoke spam.
/obj/effect/proc_holder/spell/goon_vampire/shadowstep
	name = "Шаг в тень"
	desc = "Растворитесь в тенях"
	gain_desc = "Вы получили способность «Шаг в тень», позволяющую вам, затратив часть крови, оказаться в ближайшей доступной тени."
	action_icon_state = "blink"
	base_cooldown = 2 SECONDS
	required_blood = 20
	centcom_cancast = FALSE
	create_attack_logs = FALSE

	// Teleport radii
	var/inner_tele_radius = 0
	var/outer_tele_radius = 6
	// Maximum lighting_lumcount.
	var/max_lum = 1


/obj/effect/proc_holder/spell/goon_vampire/shadowstep/create_new_targeting()
	var/datum/spell_targeting/aoe/turf/T = new()
	T.selection_type = SPELL_SELECTION_RANGE
	T.use_turf_of_user = TRUE
	T.range = outer_tele_radius
	return T


/obj/effect/proc_holder/spell/goon_vampire/shadowstep/valid_target(turf/target, user)
	if(target in range(user, inner_tele_radius))
		return FALSE

	if(isspaceturf(target))
		return FALSE

	if(target.density)
		return FALSE

	if(target.x > world.maxx - outer_tele_radius || target.x < outer_tele_radius)
		return FALSE	//putting them at the edge is dumb

	if(target.y > world.maxy - outer_tele_radius || target.y < outer_tele_radius)
		return FALSE

	// LIGHTING CHECK
	var/lightingcount = target.get_lumcount(0.5) * 10
	if(lightingcount > max_lum)
		return FALSE

	return TRUE


/obj/effect/proc_holder/spell/goon_vampire/shadowstep/cast(list/targets, mob/living/carbon/human/user = usr)
	if(!length(targets))
		revert_cast(user)
		to_chat(user, span_warning("Поблизости нет теней, куда можно было бы шагнуть."))
		return

	var/target_turf = pick(targets)
	spawn(0)
		user.ExtinguishMob()
		var/atom/movable/overlay/animation = new /atom/movable/overlay(get_turf(user))
		animation.name = user.name
		animation.density = FALSE
		animation.anchored = TRUE
		animation.icon = user.icon
		animation.alpha = 127
		animation.layer = 5
		//animation.master = src
		user.forceMove(target_turf)

		spawn(1 SECONDS)
			qdel(animation)


/datum/goon_vampire_passive
	var/gain_desc


/datum/goon_vampire_passive/New()
	..()
	if(!gain_desc)
		gain_desc = "Вы получили способность «[src]»."


/datum/goon_vampire_passive/regen
	gain_desc = "Ваша способность «Восстановление» улучшена. Теперь она будет постепенно исцелять вас после использования."


/datum/goon_vampire_passive/vision
	gain_desc = "Ваше вампирское зрение улучшено."


/datum/goon_vampire_passive/full
	gain_desc = "Вы достигли полной силы и ничто святое больше не может ослабить вас. Ваше зрение значительно улучшилось."


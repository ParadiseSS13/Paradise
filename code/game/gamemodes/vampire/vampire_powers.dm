/proc/isvampirethrall_goon(mob/living/user)
	return istype(user) && user.mind && SSticker && SSticker.mode && (user.mind in SSticker.mode.vampire_enthralled)

/**
 * Goon Vampire special spell handler.
 */
/datum/spell_handler/goon_vampire
	var/required_blood


/datum/spell_handler/goon_vampire/can_cast(mob/user, charge_check, show_message, obj/effect/proc_holder/spell/spell)

	var/datum/vampire/vampire = user.mind.vampire

	if(!vampire)
		return FALSE

	var/fullpower = vampire.get_ability(/datum/vampire_passive/full)

	if(user.stat >= DEAD)
		to_chat(user, "<span class='warning'>Но вы же мертвы!</span>")
		return FALSE

	if(vampire.nullified && !fullpower)
		to_chat(user, "<span class='warning'>Что-то блокирует ваши силы!</span>")
		return FALSE

	if(vampire.bloodusable < required_blood)
		to_chat(user, "<span class='warning'>Для этого вам потребуется не менее [required_blood] единиц крови!</span>")
		return FALSE

	//chapel check
	if(is_type_in_typecache(get_area(user), GLOB.holy_areas) && !fullpower)
		to_chat(user, "<span class='warning'>Ваши силы не действуют на этой святой земле.</span>")
		return FALSE

	return TRUE


/datum/spell_handler/goon_vampire/spend_spell_cost(mob/user, obj/effect/proc_holder/spell/spell)
	if(!required_blood) //don't take the blood yet if this is false!
		return

	var/datum/vampire/vampire = user.mind.vampire
	vampire.bloodusable -= required_blood


/datum/spell_handler/goon_vampire/revert_cast(mob/living/carbon/user, obj/effect/proc_holder/spell/spell)
	var/datum/vampire/vampire = user.mind.vampire
	vampire.bloodusable += required_blood


/datum/spell_handler/goon_vampire/after_cast(list/targets, mob/user, obj/effect/proc_holder/spell/spell)
	if(!spell.should_recharge_after_cast)
		return

	if(!required_blood)
		return

	var/datum/vampire/vampire = user.mind.vampire
	to_chat(user, "<span class='boldnotice'>You have [vampire.bloodusable] left to use.</span>")
	SSblackbox.record_feedback("tally", "vampire_powers_used", 1, "[spell]")

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
	action_background_icon_state = "bg_vampire"
	human_req = TRUE
	clothes_req = FALSE
	base_cooldown = 3 MINUTES
	gain_desc = ""
	/// How much blood this ability costs to use
	var/required_blood


/obj/effect/proc_holder/spell/goon_vampire/Initialize(mapload)
	. = ..()
	if(required_blood)
		name = "[name] ([required_blood])"

	if(action)
		action.UpdateButtonIcon()


/obj/effect/proc_holder/spell/goon_vampire/create_new_handler()
	var/datum/spell_handler/goon_vampire/H = new
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
	if(target.mind && target.mind.vampire)
		return FALSE

	//Vampires who have reached their full potential can affect nearly everything
	if(user.mind.vampire.get_ability(/datum/vampire_passive/full))
		return FALSE

	//Holy characters are resistant to vampire powers
	if(target.mind && target.mind.isholy)
		return FALSE

	return TRUE


/datum/vampire_passive
	var/gain_desc

/datum/vampire_passive/New()
	..()
	if(!gain_desc)
		gain_desc = "Вы получили способность «[src]»."

////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/effect/proc_holder/spell/goon_vampire/self/rejuvenate
	name = "Восстановление"
	desc= "Используйте накопленную кровь, чтобы влить в тело новые силы, устраняя любое ошеломление"
	action_icon_state = "vampire_rejuvinate"
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
	to_chat(user, "<span class='notice'>Ваше тело наполняется чистой кровью, снимая все ошеломляющие эффекты.</span>")
	if(user.mind?.vampire?.get_ability(/datum/vampire_passive/regen))
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

	user.visible_message("<span class='warning'>Глаза [user] вспыхивают, когда [user.p_they()] пристально смотрит в глаза [target]</span>")
	if(do_mob(user, target, 6 SECONDS))
		if(!affects(target))
			to_chat(user, "<span class='warning'>Ваш пронзительный взгляд не смог заворожить [target].</span>")
			to_chat(target, "<span class='notice'>Невыразительный взгляд [user] ничего вам не делает.</span>")
		else
			to_chat(user, "<span class='warning'>Ваш пронзающий взгляд завораживает [target].</span>")
			to_chat(target, "<span class='warning'>Вы чувствуете сильную слабость.</span>")
			target.SetSleeping(40 SECONDS)
	else
		revert_cast(user)
		to_chat(user, "<span class='warning'>Вы смотрите в никуда.</span>")


/obj/effect/proc_holder/spell/goon_vampire/targetted/disease
	name = "Заражающее касание"
	desc = "Ваше касание инфицирует кровь жертвы, заражая её могильной лихорадкой. Пока лихорадку не вылечат, жертва будет с трудом держаться на ногах, а её кровь будет наполняться токсинами."
	gain_desc = "Вы получили способность «Заражающее касание». Она позволит вам ослаблять тех, кого вы коснётесь до тех пор, пока их не вылечат."
	action_icon_state = "vampire_disease"
	required_blood = 50


/obj/effect/proc_holder/spell/goon_vampire/targetted/disease/cast(list/targets, mob/living/carbon/human/user = usr)
	var/mob/living/carbon/human/target = targets[1]

	to_chat(user, "<span class='warning'>Вы незаметно инфицируете [target] заражающим касанием.</span>")
	target.help_shake_act(user)
	if(!affects(target))
		to_chat(user, "<span class='warning'>Вам кажется, что заражающее касание не подействовало на [target].</span>")
		return

	var/datum/disease/virus = new /datum/disease/vampire
	target.ForceContractDisease(virus)


/obj/effect/proc_holder/spell/goon_vampire/glare
	name = "Вспышка"
	desc = "Вы сверкаете глазами, ненадолго ошеломляя всех людей вокруг"
	action_icon_state = "vampire_glare"
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
		to_chat(user, "<span class='warning'>У вас на глазах повязка!</span>")
		return

	user.visible_message("<span class='warning'>Глаза [user] ослепительно вспыхивают!</span>")

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
		to_chat(target, "<span class='warning'>Вы ослеплены вспышкой из глаз [user].</span>")
		add_attack_logs(user, target, "(Vampire) слепит")
		target.apply_status_effect(STATUS_EFFECT_STAMINADOT)


/obj/effect/proc_holder/spell/goon_vampire/self/shapeshift
	name = "Превращение"
	desc = "Изменяет ваше имя и внешность, тратя 50 крови, с откатом в 3 минуты."
	gain_desc = "Вы получили способность «Превращение», позволяющую навсегда обернуться другим обликом, затратив часть накопленной крови."
	action_icon_state = "genetic_poly"
	required_blood = 50


/obj/effect/proc_holder/spell/goon_vampire/self/shapeshift/cast(list/targets, mob/living/carbon/human/user = usr)
	user.visible_message("<span class='warning'>[user] transforms!</span>")

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
	user.visible_message("<span class='warning'>[user] издаёт ушераздирающий визг!</span>", "<span class='warning'>Вы громко визжите.</span>", "<span class='warning'>Вы слышите болезненно громкий визг!</span>")

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

		to_chat(target, "<span class='warning'><font size='3'><b>Вы слышите ушераздирающий визг и ваши чувства притупляются!</font></b></span>")
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
	action_icon_state = "vampire_enthrall"
	required_blood = 300


/obj/effect/proc_holder/spell/goon_vampire/targetted/enthrall/cast(list/targets, mob/living/carbon/human/user = usr)

	var/mob/living/carbon/human/target = targets[1]

	if(!ishuman(target))
		to_chat(user, "<span class='warning'>Вы можете порабощать только гуманоидов.</span>")
		return

	user.visible_message("<span class='warning'>[user] кусает [target] в шею!</span>", "<span class='warning'>Вы кусаете [target] в шею и начинаете передачу части своей силы.</span>")
	to_chat(target, "<span class='warning'>Вы ощущаете, как щупальца зла впиваются в ваш разум.</span>")

	if(do_mob(user, target, 5 SECONDS))
		if(can_enthrall(user, target))
			handle_enthrall(user, target)
		else
			revert_cast(user)
			to_chat(user, "<span class='warning'>Вы или цель сдвинулись, или вам не хватило запаса крови.</span>")


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
		to_chat(user, "<span class='warning'>Разум [target.name] сейчас не здесь, поэтому порабощение не удастся.</span>")
		return FALSE

	if(enthrall_safe || target.mind.vampire || isvampirethrall_goon(target))
		target.visible_message("<span class='warning'>Похоже что [target] сопротивляется захвату!</span>", "<span class='notice'>Вы ощущаете в голове знакомое ощущение, но оно быстро проходит.</span>")
		return FALSE

	if(!affects(target))
		target.visible_message("<span class='warning'>Похоже что [target] сопротивляется захвату!</span>", "<span class='notice'>Вера в [SSticker.Bible_deity_name] защищает ваш разум от всякого зла.</span>")
		return FALSE

	if(isninja(target))
		var/obj/item/clothing/suit/space/space_ninja/ninja_suit = target.wear_suit
		if(istype(ninja_suit) && ninja_suit.vamp_protection_active && ninja_suit.s_initialized)
			target.visible_message(span_warning("Похоже что [target] сопротивляется захвату!"), span_notice("Вы ощутили сильную боль, а затем слабый укол в шею. Кажется костюм только, что защитил ваш разум..."))
			target.setBrainLoss(20)
			return FALSE

	if(!ishuman(target))
		to_chat(user, "<span class='warning'>Вы можете порабощать только гуманоидов!</span>")
		return FALSE

	return TRUE


/obj/effect/proc_holder/spell/goon_vampire/targetted/enthrall/proc/handle_enthrall(mob/living/user, mob/living/carbon/human/target)

	var/datum/mind/user_mind = user.mind
	var/datum/mind/target_mind = target.mind
	var/ref = "\ref[user_mind]"
	if(!(ref in SSticker.mode.vampire_thralls))
		SSticker.mode.vampire_thralls[ref] = list(target_mind)
	else
		SSticker.mode.vampire_thralls[ref] += target_mind

	SSticker.mode.update_vampire_icons_added(target_mind)
	SSticker.mode.update_vampire_icons_added(user_mind)

	var/datum/mindslaves/slaved = user_mind.som
	target_mind.som = slaved
	slaved.serv += target
	slaved.add_serv_hud(user_mind, "vampire")//handles master servent icons
	slaved.add_serv_hud(target_mind, "vampthrall")

	SSticker.mode.vampire_enthralled.Add(target_mind)
	SSticker.mode.vampire_enthralled[target_mind] = user_mind
	target.mind.special_role = SPECIAL_ROLE_VAMPIRE_THRALL

	var/datum/objective/protect/serve_objective = new
	serve_objective.owner = user_mind
	serve_objective.target = target_mind
	serve_objective.explanation_text = "Вы были порабощены [user.real_name]. Выполняйте все [user.p_their()] приказы."
	target_mind.objectives += serve_objective

	to_chat(target, "<span class='biggerdanger'>Вы были порабощены [user.real_name]. Выполняйте все [user.p_their()] приказы.</span>")
	to_chat(user, "<span class='warning'>Вы успешно поработили [target]. <i>Если [target.p_they()] откажется вас слушаться, используйте adminhelp.</i></span>")
	target.Stun(4 SECONDS)
	add_attack_logs(user, target, "Vampire-thralled")


/obj/effect/proc_holder/spell/goon_vampire/self/cloak
	name = "Покров тьмы"
	desc = "Переключается, маскируя вас в темноте"
	gain_desc = "Вы получили способность «Покров тьмы», которая, будучи включённой, делает вас практически невидимым в темноте."
	action_icon_state = "vampire_cloak"
	base_cooldown = 1 SECONDS


/obj/effect/proc_holder/spell/goon_vampire/self/cloak/Initialize(mapload)
	. = ..()
	update_name()


/obj/effect/proc_holder/spell/goon_vampire/self/cloak/proc/update_name()
	var/mob/living/user = loc
	if(!ishuman(user) || !user.mind?.vampire)
		return

	name = "[initial(name)] ([user.mind.vampire.iscloaking ? "Выключить" : "Включить"])"


/obj/effect/proc_holder/spell/goon_vampire/self/cloak/cast(list/targets, mob/living/carbon/human/user = usr)
	var/datum/vampire/vamp = user.mind.vampire
	vamp.iscloaking = !vamp.iscloaking
	update_name()
	to_chat(user, "<span class='notice'>Теперь вас будет <b>[vamp.iscloaking ? "не видно" : "видно"]</b> в темноте.</span>")


/obj/effect/proc_holder/spell/goon_vampire/bats
	name = "Дети ночи (50)"
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
		to_chat(user, "<span class='warning'>Поблизости нет теней, куда можно было бы шагнуть.</span>")
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


/datum/vampire_passive/regen
	gain_desc = "Ваша способность «Восстановление» улучшена. Теперь она будет постепенно исцелять вас после использования."


/datum/vampire_passive/vision
	gain_desc = "Ваше вампирское зрение улучшено."


/datum/vampire_passive/full
	gain_desc = "Вы достигли полной силы и ничто святое больше не может ослабить вас. Ваше зрение значительно улучшилось."


/obj/effect/proc_holder/spell/aoe/raise_vampires
	name = "Поднятие вампиров"
	desc = "Призовите смертоносных вампиров из блюспейса"
	school = "transmutation"
	action_icon_state = "revive_thrall"
	base_cooldown = 10 SECONDS
	cooldown_min = 2 SECONDS
	clothes_req = FALSE
	human_req = TRUE
	sound = 'sound/magic/wandodeath.ogg'
	aoe_range = 3


/obj/effect/proc_holder/spell/aoe/raise_vampires/create_new_targeting()
	var/datum/spell_targeting/aoe/T = new()
	T.range = aoe_range
	return T


/obj/effect/proc_holder/spell/aoe/raise_vampires/cast(list/targets, mob/user = usr)
	new /obj/effect/temp_visual/cult/sparks(user.loc)
	to_chat(user, "<span class='warning'>Ваш зов расходится в блюспейсе, на помощь созывая других вампирских духов!</span>")
	for(var/mob/living/carbon/human/target in targets)
		target.Beam(target, "sendbeam", 'icons/effects/effects.dmi', time= 3 SECONDS, maxdistance = 7, beam_type = /obj/effect/ebeam)
		new /obj/effect/temp_visual/cult/sparks(target.loc)
		target.raise_vampire(user)


/mob/living/carbon/human/proc/raise_vampire(var/mob/M)
	if(!istype(M))
		log_debug("human/proc/raise_vampire called with invalid argument.")
		return
	if(!mind)
		visible_message("Кажется, [src] недостаёт ума, чтобы понять, о чём вы говорите.")
		return
	if(dna && (NO_BLOOD in dna.species.species_traits) || dna.species.exotic_blood || !blood_volume)
		visible_message("[src] выглядит невозмутимо!")
		return
	if(mind.vampire || mind.special_role == SPECIAL_ROLE_VAMPIRE || mind.special_role == SPECIAL_ROLE_VAMPIRE_THRALL)
		visible_message("<span class='notice'>[src] выглядит обновлённо!</span>")
		adjustBruteLoss(-60)
		adjustFireLoss(-60)
		for(var/obj/item/organ/external/E in bodyparts)
			if(prob(25))
				E.mend_fracture()

		return
	if(stat != DEAD)
		if(IsWeakened())
			visible_message("<span class='warning'>Кажется, [src] ощущает боль!</span>")
			adjustBrainLoss(60)
		else
			visible_message("<span class='warning'>Кажется, энергия оглушает [src]!</span>")
			Weaken(40 SECONDS)
		return
	for(var/obj/item/implant/mindshield/L in src)
		if(L && L.implanted)
			qdel(L)
	for(var/obj/item/implant/traitor/T in src)
		if(T && T.implanted)
			qdel(T)
	visible_message("<span class='warning'>Глаза [src] начинают светиться жутким красным светом!</span>")
	var/datum/objective/protect/protect_objective = new
	protect_objective.owner = mind
	protect_objective.target = M.mind
	protect_objective.explanation_text = "Защитите [M.real_name]."
	mind.objectives += protect_objective
	add_attack_logs(M, src, "Vampire-sired")
	mind.make_Vampire()
	revive()
	Weaken(40 SECONDS)


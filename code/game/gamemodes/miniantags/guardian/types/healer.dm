/mob/living/simple_animal/hostile/guardian/healer
	friendly = "heals"
	speed = 0
	damage_transfer = 0.7
	melee_damage_lower = 5
	melee_damage_upper = 5
	armour_penetration = 100
	playstyle_string = "Будучи <b>Поддержкой</b>, вы можете переключить свои базовые атаки в режим исцеления. Кроме того, нажатие Alt-кнопки на соседнем мобе деформирует его к вашему маяку в блюспейс пространстве с небольшой задержкой."
	magic_fluff_string = "...и берете карту Главного Врача, мощную силу жизни... и смерти."
	tech_fluff_string = "Последовательность загрузки завершена. Медицинские модули активированы. Активированы модули блюпространства. Голопаразитный рой активирован."
	bio_fluff_string = "Ваш рой скарабеев завершает мутацию и оживает, способный залечивать раны и путешествовать через блюспейс."
	var/turf/simulated/floor/beacon
	var/beacon_cooldown = 0
	var/default_beacon_cooldown = 300 SECONDS
	var/toggle = FALSE
	var/heal_cooldown = 0

/mob/living/simple_animal/hostile/guardian/healer/sealhealer
	name = "Seal Sprit"
	real_name = "Seal Sprit"
	icon = 'icons/mob/animal.dmi'
	icon_living = "seal"
	icon_state = "seal"
	attacktext = "шлёпает"
	speak_emote = list("barks")
	friendly = "heals"
	speed = 0
	melee_damage_lower = 0
	melee_damage_upper = 0
	melee_damage_type = STAMINA
	admin_spawned = TRUE

/mob/living/simple_animal/hostile/guardian/healer/New()
	..()
	AddSpell(new /obj/effect/proc_holder/spell/guardian_quickmend(summoner))

/mob/living/simple_animal/hostile/guardian/healer/Life(seconds, times_fired)
	..()
	var/datum/atom_hud/medsensor = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	medsensor.add_hud_to(src)

/mob/living/simple_animal/hostile/guardian/healer/Stat()
	..()
	if(statpanel("Status"))
		if(beacon_cooldown >= world.time)
			stat(null, "Перезарядка блюспейс маяка: [max(round((beacon_cooldown - world.time)*0.1, 0.1), 0)] секунд")

/mob/living/simple_animal/hostile/guardian/healer/AttackingTarget()
	. = ..()
	if(toggle)
		if(loc == summoner)
			to_chat(src, "<span class='danger'>Нужно явить себя для лечения!</span>")
			return
		if(iscarbon(target))
			changeNext_move(CLICK_CD_MELEE)
			if(heal_cooldown <= world.time && !stat)
				var/mob/living/carbon/human/C = target
				C.adjustBruteLoss(-5, robotic=3)
				C.adjustFireLoss(-5, robotic=3)
				C.adjustOxyLoss(-5)
				C.adjustToxLoss(-5)
				C.adjustCloneLoss(-5)
				C.adjustBrainLoss(-5)
				heal_cooldown = world.time + 20
				if(C == summoner)
					med_hud_set_health()
					med_hud_set_status()
	else
		if(loc == summoner)
			return
		var/mob/living/L = target
		if(istype(L))
			L.adjustToxLoss(15)

/mob/living/simple_animal/hostile/guardian/healer/ToggleMode()
	if(loc == summoner)
		if(toggle)
			a_intent = INTENT_HARM
			hud_used.action_intent.icon_state = a_intent
			melee_damage_lower = 5
			melee_damage_upper = 5
			to_chat(src, "<span class='danger'>Вы переключились в боевой режим.</span>")
			toggle = FALSE
		else
			a_intent = INTENT_HELP
			hud_used.action_intent.icon_state = a_intent
			melee_damage_lower = 0
			melee_damage_upper = 0
			to_chat(src, "<span class='danger'>Вы переключились в режим исцеления.</span>")
			toggle = TRUE
	else
		to_chat(src, "<span class='danger'>Нужно быть в хозяине для переключения режимов!</span>")

/mob/living/simple_animal/hostile/guardian/healer/verb/Beacon()
	set name = "Установить блюспейс маяк"
	set category = "Guardian"
	set desc = "Пометьте пол как ваш маяк, позволяя телепортировать цели на него. Ваш маяк не будет работать в небезопасных атмосферных условиях."
	if(beacon_cooldown < world.time)
		var/turf/beacon_loc = get_turf(loc)
		if(istype(beacon_loc, /turf/simulated/floor))
			var/turf/simulated/floor/F = beacon_loc
			F.icon = 'icons/turf/floors.dmi'
			F.name = "bluespace recieving pad"
			F.desc = "A recieving zone for bluespace teleportations. Building a wall over it should disable it."
			F.icon_state = "light_on-w"
			to_chat(src, "<span class='danger'>Маяк установлен! Вы можете телепортировать на него вещи и людей, нажав Alt+Click </span>")
			if(beacon)
				beacon.ChangeTurf(/turf/simulated/floor/plating)
			beacon = F
			beacon_cooldown = world.time + default_beacon_cooldown

	else
		to_chat(src, "<span class='danger'>Ваша сила на перезарядке! Нужно дождаться ещё [max(round((beacon_cooldown - world.time)*0.1, 0.1), 0)] секунд, пока вы сможете переставить маяк.</span>")

/mob/living/simple_animal/hostile/guardian/healer/AltClickOn(atom/movable/A)
	if(!istype(A))
		return
	if(loc == summoner)
		to_chat(src, "<span class='danger'>Вы должны явить себя для телепортации вещей!</span>")
		return
	if(!beacon)
		to_chat(src, "<span class='danger'>Вам нужно установить маяк чтобы телепортировать вещи!</span>")
		return
	if(!Adjacent(A))
		to_chat(src, "<span class='danger'>Вам нужно быть рядом с целью!</span>")
		return
	if((A.anchored))
		to_chat(src, "<span class='danger'>Цель прикреплена к полу. Телепортация невозможна.</span>")
		return
	to_chat(src, "<span class='danger'>Вы начинаете телепортировать [A]</span>")
	if(do_mob(src, A, 50))
		if(!A.anchored)
			if(!beacon) //Check that the beacon still exists and is in a safe place. No instant kills.
				to_chat(src, "<span class='danger'>Вам нужно установить маяк чтобы телепортировать вещи!</span>")
				return
			var/turf/T = beacon
			if(T.is_safe())
				new /obj/effect/temp_visual/guardian/phase/out(get_turf(A))
				do_teleport(A, beacon, 0)
				investigate_log("[key_name_log(src)] teleported [key_name_log(A)] to [COORD(beacon)].", INVESTIGATE_TELEPORTATION)
				new /obj/effect/temp_visual/guardian/phase(get_turf(A))
				return
			to_chat(src, "<span class='danger'>Маячок не в безопасном месте, нужен кислород для хозяина.</span>")
			return
	else
		to_chat(src, "<span class='danger'>Вам нужно стоять смирно!</span>")


/obj/effect/proc_holder/spell/guardian_quickmend
	name = "Быстрое исцеление"
	desc = "Проверяет хозяина на наличие травм. Если таковые есть, лечит случайную из них. Шанс срабатывания 50%."
	action_icon_state = "heal"
	action_background_icon_state = "bg_spell"
	base_cooldown = 35 SECONDS
	clothes_req = FALSE
	human_req = FALSE
	var/chance_to_mend = 50
	var/cast_time = 50
	var/list/possible_cures = list("bleedings","fractures","infections","embedded","damaged_organs")
	var/mob/living/carbon/human/summoner = null


/obj/effect/proc_holder/spell/guardian_quickmend/New(mob/living/carbon/human/summoned_by)
	. = ..()
	summoner = summoned_by


/obj/effect/proc_holder/spell/guardian_quickmend/Destroy()
	summoner = null
	return ..()


/obj/effect/proc_holder/spell/guardian_quickmend/create_new_targeting()
	var/datum/spell_targeting/aoe/T = new
	T.range = 1
	T.selection_type = SPELL_SELECTION_RANGE
	T.use_turf_of_user = TRUE
	T.try_auto_target = TRUE
	return T


/obj/effect/proc_holder/spell/guardian_quickmend/valid_target(target, user)
	return target == summoner


/obj/effect/proc_holder/spell/guardian_quickmend/cast(list/targets, mob/user)
	for(var/target in targets)
		if(target != summoner)
			to_chat(user, "Это не ваш хозяин.")
			return 0
	to_chat(user, "Проверка ран хозяина..")
	if(do_after(user, cast_time, target = summoner))
		if(prob(chance_to_mend))
			var/list/injures[] = list()
			injures["bleedings"] = summoner.check_internal_bleedings()
			injures["fractures"] = summoner.check_fractures()
			injures["infections"] =  summoner.check_infections()
			injures["embedded"] = summoner.check_limbs_with_embedded_objects()
			injures["damaged_organs"] = summoner.check_damaged_organs()

			var/list/available_cures = list()
			for(var/injure in injures)
				if((injures[injure]).len > 0)
					available_cures.Add(injure)
			if(!available_cures.len)
				return 0
			var/random_cure = pick(available_cures)
			to_chat(user, "Найдена травма. Попытка исцеления..")
			switch(random_cure)
				if("bleedings")
					var/obj/item/organ/external/limb = pick(injures["bleedings"])
					limb.internal_bleeding = FALSE
					to_chat(user, "Внутреннее кровотечение остановлено.")
					return 1
				if("fractures")
					var/obj/item/organ/external/limb = pick(injures["fractures"])
					limb.mend_fracture()
					to_chat(user, "Перелом зафиксирован.")
					return 1
				if("infections")
					var/obj/item/organ/internal/organ = pick(injures["infections"])
					organ.germ_level = 0
					to_chat(user, "Очищено тело хозяина от инфекции.")
					return 1
				if("embedded")
					var/obj/item/organ/external/limb = pick(injures["embedded"])
					var/turf/T = get_turf(summoner)
					var/obj/item/item = pick(limb.embedded_objects)
					limb.embedded_objects -= item
					item.forceMove(T)
					to_chat(user, "Удалось вытащить застрявший предмет.")
					return 1
				if("damaged_organs")
					var/obj/item/organ/internal/organ = pick(injures["damaged_organs"])
					organ.damage = 0
					to_chat(user, "Восстановлен поврежденный орган.")
					return 1
		else
			to_chat(user, "Проверка окончилась неудачей.")
			return 1
	else
		to_chat(user, "Нужно стоять смирно!")
		return 0

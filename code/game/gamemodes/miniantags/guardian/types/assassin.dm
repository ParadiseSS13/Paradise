/mob/living/simple_animal/hostile/guardian/assassin
	melee_damage_lower = 30
	melee_damage_upper = 30
	armour_penetration = 0
	tts_seed = "Spy"
	playstyle_string = "Как тип <b>Ассасин</b> вы наносите катастрофический урон, но не имеете сопротивления урону. Вы можете входить в невидимость, увеличивая входящий по Вам урон, значительно увеличивая урон следующей атаки и заставляя ее игнорировать броню. Скрытность нарушается, когда вы атакуете или получаете урон"
	magic_fluff_string = "...и вынимаете Космического Ниндзя, смертоносного, невидимого убийцу."
	tech_fluff_string = "Последовательность загрузки завершена. Загружен модуль ассасина. Голопаразитный рой активирован."
	bio_fluff_string = "Ваш рой скарабеев заканчивает мутировать и оживает, становясь способным к подлым и скрытным атакам."
	var/tox_damage = 5
	var/toggle = FALSE
	var/stealthcooldown = 0
	var/default_stealth_cooldown = 12 SECONDS
	var/obj/screen/alert/canstealthalert
	var/obj/screen/alert/instealthalert

/mob/living/simple_animal/hostile/guardian/assassin/Life(seconds, times_fired)
	. = ..()
	updatestealthalert()

/mob/living/simple_animal/hostile/guardian/assassin/Manifest()
	if(cooldown > world.time)
		return
	if(!summoner)
		return
	if(loc == summoner)
		forceMove(get_turf(summoner))
		cooldown = world.time + 20

/mob/living/simple_animal/hostile/guardian/assassin/Stat()
	..()
	if(statpanel("Status"))
		if(stealthcooldown >= world.time)
			stat(null, "Время до невидимости: [max(round((stealthcooldown - world.time)*0.1, 0.1), 0)] секунд")

/mob/living/simple_animal/hostile/guardian/assassin/AttackingTarget()
	var/mob/living/L = target
	if(istype(L))
		L.adjustToxLoss(tox_damage)
	. = ..()
	if(toggle && (ishuman(target)))
		if(prob(25))
			var/mob/living/carbon/human/H = target
			var/bodypart_name = pick(BODY_ZONE_CHEST,BODY_ZONE_L_ARM,BODY_ZONE_R_ARM,BODY_ZONE_L_LEG,BODY_ZONE_R_LEG,BODY_ZONE_HEAD,BODY_ZONE_TAIL, BODY_ZONE_WING)
			var/obj/item/organ/external/BP = H.bodyparts_by_name[bodypart_name]
			BP.fracture()
	ToggleMode(1)


/mob/living/simple_animal/hostile/guardian/assassin/adjustHealth(amount, updating_health = TRUE)
	. = ..()
	if(. > 0 && toggle)
		ToggleMode(1)

/mob/living/simple_animal/hostile/guardian/assassin/ToggleMode(forced = 0)
	if(toggle)
		melee_damage_lower = initial(melee_damage_lower)
		melee_damage_upper = initial(melee_damage_upper)
		armour_penetration = initial(armour_penetration)
		tox_damage = initial(tox_damage)
		obj_damage = initial(obj_damage)
		environment_smash = initial(environment_smash)
		alpha = initial(alpha)
		damage_transfer = 1
		if(!forced)
			to_chat(src, "<span class='danger'>Вы вышли из невидимости.</span>")
		else
			visible_message("<span class='danger'>[src] suddenly appears!</span>")
			stealthcooldown = world.time + default_stealth_cooldown //we were forced out of stealth and go on cooldown
			cooldown = world.time + 40 //can't recall for 4 seconds
		updatestealthalert()
		toggle = FALSE
	else if(stealthcooldown <= world.time)
		melee_damage_lower = 50
		melee_damage_upper = 50
		armour_penetration = 100
		tox_damage = 15
		obj_damage = 0
		environment_smash = ENVIRONMENT_SMASH_NONE
		alpha = 15
		damage_transfer = 1.1
		if(!forced)
			to_chat(src, "<span class='danger'>Вы вошли в невидимость, усилив свою следующую атаку.</span>")
		updatestealthalert()
		toggle = TRUE
	else if(!forced)
		to_chat(src, "<span class='danger'>Вы не можете скрыться, подождите ещё [max(round((stealthcooldown - world.time)*0.1, 0.1), 0)] секунд!</span>")

/mob/living/simple_animal/hostile/guardian/assassin/proc/updatestealthalert()
	if(stealthcooldown <= world.time)
		if(toggle)
			if(!instealthalert)
				instealthalert = throw_alert("instealth", /obj/screen/alert/instealth)
				clear_alert("canstealth")
				canstealthalert = null
		else
			if(!canstealthalert)
				canstealthalert = throw_alert("canstealth", /obj/screen/alert/canstealth)
				clear_alert("instealth")
				instealthalert = null
	else
		clear_alert("instealth")
		instealthalert = null
		clear_alert("canstealth")
		canstealthalert = null

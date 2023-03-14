/mob/living/simple_animal/hostile/guardian/charger
	melee_damage_lower = 15
	melee_damage_upper = 15
	ranged = 1 //technically
	ranged_message = "charges"
	ranged_cooldown_time = 40
	speed = -1
	damage_transfer = 0.6
	playstyle_string = "Будучи <b>Налетчиком</b> вы наносите слабый урон, имеете среднее сопротивление урону, очень быстро передвигаетесь, наносите более быстрые атаки по живым и можете атаковать цель, нанося ей урон и опрокидывая на пол. <b>Нажмите на плитку дальше одного тайла, чтобы использовать рывок!</b>"
	magic_fluff_string = ".. и вытягиваете Охотника, инопланетного мастера стремительных атак."
	tech_fluff_string = "Последовательность загрузки завершена. Скоростные модули загружены. Рой голопаразитов запущен."
	bio_fluff_string = "Ваш рой скарабеев заканчивает мутировать и оживает, готовый нанести урон."
	var/charging = 0
	var/obj/screen/alert/chargealert

/mob/living/simple_animal/hostile/guardian/charger/Life()
	. = ..()
	if(ranged_cooldown <= world.time)
		if(!chargealert)
			chargealert = throw_alert("charge", /obj/screen/alert/cancharge)
	else
		clear_alert("charge")
		chargealert = null

/mob/living/simple_animal/hostile/guardian/charger/OpenFire(atom/A)
	if(!charging)
		visible_message("<span class='danger'>[src] [ranged_message] at [A]!</span>")
		ranged_cooldown = world.time + ranged_cooldown_time
		clear_alert("charge")
		chargealert = null
		Shoot(A)

/mob/living/simple_animal/hostile/guardian/charger/AttackingTarget()
	. = ..()
	if(iscarbon(target))
		changeNext_move(CLICK_CD_RANGE)

/mob/living/simple_animal/hostile/guardian/charger/Shoot(atom/targeted_atom)
	charging = 1
	throw_at(targeted_atom, range, 1, src, 0, callback = CALLBACK(src, .proc/charging_end))

/mob/living/simple_animal/hostile/guardian/charger/proc/charging_end()
	charging = 0

/mob/living/simple_animal/hostile/guardian/charger/Move()
	if(charging)
		new /obj/effect/temp_visual/decoy/fading(loc,src)
	. = ..()

/mob/living/simple_animal/hostile/guardian/charger/snapback()
	if(!charging)
		..()

/mob/living/simple_animal/hostile/guardian/charger/throw_impact(atom/A)
	if(!charging)
		return ..()

	else if(A)
		if(isliving(A) && A != summoner)
			var/mob/living/L = A
			var/blocked = FALSE
			var/mob/living/simple_animal/hostile/guardian/G = A
			if(istype(G) && G.summoner == summoner) //if the summoner matches don't hurt them
				blocked = TRUE
			if(ishuman(A))
				var/mob/living/carbon/human/H = A
				if(H.check_shields(src, 90, "[name]", attack_type = THROWN_PROJECTILE_ATTACK))
					blocked = TRUE
			if(!blocked)
				L.Weaken(1)
				L.visible_message("<span class='danger'>[src] slams into [L]!</span>", "<span class='userdanger'>[src] slams into you!</span>")
				L.apply_damage(30, BRUTE)
				playsound(get_turf(L), 'sound/effects/meteorimpact.ogg', 100, 1)
				shake_camera(L, 4, 3)
				shake_camera(src, 2, 3)

		charging = 0


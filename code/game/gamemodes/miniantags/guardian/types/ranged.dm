/obj/item/projectile/guardian
	name = "crystal spray"
	icon_state = "guardian"
	damage = 20
	armour_penetration = 100
	damage_type = BRUTE

/mob/living/simple_animal/hostile/guardian/ranged
	friendly = "quietly assesses"
	melee_damage_lower = 10
	melee_damage_upper = 10
	damage_transfer = 1
	projectiletype = /obj/item/projectile/guardian
	ranged_cooldown_time = 5 //fast!
	projectilesound = 'sound/effects/hit_on_shattered_glass.ogg'
	ranged = 1
	range = 13
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	see_in_dark = 8
	playstyle_string = "Будучи <b>Стрелком</b>, вы не обладаете сопротивлением урону, но способны распылять осколки кристалла с невероятно высокой скоростью. Вы также можете расставлять наблюдательные силки, чтобы следить за передвижением противника. Наконец, вы можете перейти в режим разведчика, в котором вы не можете атаковать, но можете двигаться без ограничений. Следите за энергией для стрельбы и старайтесь не стрелять в хозяина!"
	magic_fluff_string = "...и вытаскиваете Дозорного, инопланетного мастера дальнего боя."
	tech_fluff_string = "Последовательность загрузки завершена. Активированы модули дальнего боя. Рой голопаразитов запущен."
	bio_fluff_string = "Ваш рой скарабеев заканчивает мутировать и оживает, способный рассыпать осколки кристалла."
	var/energy = 150
	var/list/snares = list()
	var/toggle = FALSE

/mob/living/simple_animal/hostile/guardian/ranged/Life(seconds, times_fired)
	..()
	if(energy <=145)
		energy+=5
	if(!toggle)
		if(energy>=20)
			ranged = 1
		if(energy<=5)
			to_chat(src, "<span class='danger'>Энергия на нуле. Стрельба заблокирована.</span>")
			ranged = 0

/mob/living/simple_animal/hostile/guardian/ranged/Stat()
	..()
	if(statpanel("Status"))
		stat(null, "Запас энергии: [max(round(energy, 0.1), 0)]/150")

/mob/living/simple_animal/hostile/guardian/ranged/OpenFire(atom/A)
	if(ranged)
		ranged_cooldown = world.time + ranged_cooldown_time
		Shoot(A)
		energy-=10

/mob/living/simple_animal/hostile/guardian/ranged/ToggleMode()
	if(loc == summoner)
		if(toggle)
			ranged = 1
			melee_damage_lower = 10
			melee_damage_upper = 10
			obj_damage = initial(obj_damage)
			environment_smash = initial(environment_smash)
			alpha = 255
			range = 13
			incorporeal_move = INCORPOREAL_NONE
			to_chat(src, "<span class='danger'>Вы переключились в боевой режим.</span>")
			toggle = FALSE
		else
			ranged = 0
			melee_damage_lower = 0
			melee_damage_upper = 0
			obj_damage = 0
			environment_smash = ENVIRONMENT_SMASH_NONE
			alpha = 60
			range = 255
			incorporeal_move = INCORPOREAL_NORMAL
			to_chat(src, "<span class='danger'>Вы переключились в режим разведки.</span>")
			toggle = TRUE
	else
		to_chat(src, "<span class='danger'>Нужно быть в хозяине для смены режимов!</span>")

/mob/living/simple_animal/hostile/guardian/ranged/ToggleLight()
	var/msg
	switch(lighting_alpha)
		if (LIGHTING_PLANE_ALPHA_VISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
			msg = "Вы активировали ночное зрение."
		if (LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
			msg = "Вы усилили ночное зрение."
		if (LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
			msg = "Вы увеличили ночное зрение до максимума."
		else
			lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
			msg = "Вы выключили ночное зрение."

	update_sight()

	to_chat(src, "<span class='notice'>[msg]</span>")

/mob/living/simple_animal/hostile/guardian/ranged/verb/Snare()
	set name = "Установить ловушку для слежки"
	set category = "Guardian"
	set desc = "Установите невидимую ловушку, которая оповестит вас, когда по ней пройдут живые существа. Максимум 5"
	if(snares.len <6)
		var/turf/snare_loc = get_turf(loc)
		var/obj/item/effect/snare/S = new /obj/item/effect/snare(snare_loc)
		S.spawner = src
		S.name = "[get_area(snare_loc)] trap ([rand(1, 1000)])"
		snares |= S
		to_chat(src, "<span class='danger'>Ловушка слежения установлена!</span>")
	else
		to_chat(src, "<span class='danger'>У вас установлено слишком много ловушек. Сначала удалите некоторые.</span>")

/mob/living/simple_animal/hostile/guardian/ranged/verb/DisarmSnare()
	set name = "Удалить ловушку для наблюдения"
	set category = "Guardian"
	set desc = "Обезвреживание нежелательных ловушек наблюдения."
	var/picked_snare = input(src, "Выберите ловушку для обезвреживания", "Уничтожить ловушку") as null|anything in snares
	if(picked_snare)
		snares -= picked_snare
		qdel(picked_snare)
		to_chat(src, "<span class='danger'>Ловушка убрана.</span>")

/obj/item/effect/snare
	name = "snare"
	desc = "You shouldn't be seeing this!"
	var/mob/living/spawner
	invisibility = 1

/obj/effect/snare/singularity_act()
	return

/obj/effect/snare/singularity_pull()
	return

/obj/item/effect/snare/Crossed(AM as mob|obj, oldloc)
	if(isliving(AM))
		var/turf/snare_loc = get_turf(loc)
		if(spawner)
			to_chat(spawner, "<span class='danger'>[AM] пересек вашу ловушку в [get_area(snare_loc)].</span>")
			if(istype(spawner, /mob/living/simple_animal/hostile/guardian))
				var/mob/living/simple_animal/hostile/guardian/G = spawner
				if(G.summoner)
					to_chat(G.summoner, "<span class='danger'>[AM] пересек вашу ловушку в [get_area(snare_loc)].</span>")

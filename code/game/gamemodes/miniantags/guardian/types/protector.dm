/mob/living/simple_animal/hostile/guardian/protector
	melee_damage_lower = 15
	melee_damage_upper = 15
	tts_seed = "Cairne"
	range = 15 //worse for it due to how it leashes
	damage_transfer = 0.4
	playstyle_string = "Как <b>Защитник</b>, вы заставляете своего призывателя привязываться к вам, вместо того чтобы вы привязывались к нему, и имеете два режима: боевой режим, в котором вы наносите средний урон и получаете очень малый, и режим защиты, в котором вы почти не наносите и не получаете урона, даже от взрывов. Вы так же обладаете заклинанием создания краткосрочных барьеров."
	magic_fluff_string = "..и берете Стража - непоколебимого защитника, который никогда не покидает сторону своего подопечного."
	tech_fluff_string = "Последовательность загрузки завершена. Загружены модули защиты. Голопаразитный рой в сети."
	bio_fluff_string = "Ваш рой скарабеев заканчивает мутировать и оживает, готовый защищать вас."
	var/toggle = FALSE

/mob/living/simple_animal/hostile/guardian/protector/ex_act(severity)
	if(severity == 1)
		adjustBruteLoss(400) //технически, в режиме защиты вам плевать даже на гиб. Ваш хозяин получит всего 20 урона.
	else
		..()
	if(toggle)
		visible_message("<span class='danger'>The explosion glances off [src]'s energy shielding!</span>") //FLEX

/mob/living/simple_animal/hostile/guardian/protector/New()
	..()
	AddSpell(new /obj/effect/proc_holder/spell/targeted/forcewall/greater/guardian)

/mob/living/simple_animal/hostile/guardian/protector/ToggleMode()
	if(cooldown > world.time)
		return 0
	cooldown = world.time + 10
	if(toggle)
		overlays.Cut()
		melee_damage_lower = initial(melee_damage_lower)
		melee_damage_upper = initial(melee_damage_upper)
		obj_damage = initial(obj_damage)
		speed = initial(speed)
		damage_transfer = 0.4
		to_chat(src, "<span class='danger'>Вы переключились в боевой режим.</span>")
		toggle = FALSE
	else
		var/icon/shield_overlay = icon('icons/effects/effects.dmi', "shield-grey")
		shield_overlay *= name_color
		overlays.Add(shield_overlay)
		melee_damage_lower = 2
		melee_damage_upper = 2
		damage_transfer = 0.05 //damage? what's damage?
		to_chat(src, "<span class='danger'>Вы переключились в режим защиты.</span>")
		toggle = TRUE

/mob/living/simple_animal/hostile/guardian/protector/snapback() //snap to what? snap to the guardian!
	// If the summoner dies instantly, the summoner's ghost may be drawn into null space as the protector is deleted. This check should prevent that.
	if(summoner && loc && summoner.loc)
		if(get_dist(get_turf(summoner),get_turf(src)) <= range)
			return
		else
			if(istype(summoner.loc, /obj/effect))
				to_chat(src, "<span class='holoparasite'>Вы вышли из дальности связи и вернулись обратно! Вы можете двигаться только в радиусе [range] метров от [summoner.real_name]!</span>")
				visible_message("<span class='danger'>[src] jumps back to its user.</span>")
				Recall(TRUE)
			else
				to_chat(summoner, "<span class='holoparasite'>Вы вышли из дальности связи и вернулись обратно! Вы можете двигаться только в радиусе [range] метров от <b>[src]</b>!</span>")
				summoner.visible_message("<span class='danger'>[summoner] jumps back to [summoner.p_their()] protector.</span>")
				new /obj/effect/temp_visual/guardian/phase/out(get_turf(summoner))
				summoner.forceMove(get_turf(src))
				new /obj/effect/temp_visual/guardian/phase(get_turf(summoner))//Protector

/mob/living/simple_animal/hostile/guardian/protector/adjustHealth(amount, updating_health = TRUE) //The spirit is invincible, but passes on damage to the summoner
	var/damage = amount * damage_transfer
	if(prob(85)) //15% chance of block
		if(summoner)
			if(loc == summoner)
				return
			summoner.adjustBruteLoss(damage)
			if(damage)
				to_chat(summoner, "<span class='danger'>Ваш [name] под атакой! Вы получаете урон!</span>")
				summoner.visible_message("<span class='danger'>Кровь хлещет из [summoner] ибо [src] получает урон!</span>")
			if(summoner.stat == UNCONSCIOUS)
				to_chat(summoner, "<span class='danger'>Your body can't take the strain of sustaining [src] in this condition, it begins to fall apart!</span>")
				summoner.adjustCloneLoss(damage/2)
	else
		to_chat(summoner, "<span class='danger'>Ваш [name] под атакой, поглощая урон!</span>")
		visible_message("<span class='danger'>[src] поглотил урон!</span>")

/obj/effect/proc_holder/spell/targeted/forcewall/greater/guardian
	name = "Голографическая силовая стена"
	desc = "Создает перед вами непробиваемый барьер, через который могут проходить вы и ваш хозяин."
	clothes_req = FALSE
	invocation = "YOU SHALL NOT PASS!"
	wall_type = /obj/effect/forcefield/wizard/guardian

/obj/effect/forcefield/wizard/guardian
	desc = "Непробиваемый барьер неизвестной сущности."
	name = "FORCEWALL"
	icon = 'icons/effects/effects.dmi'
	icon_state = "at_shield2"
	lifetime = 15 SECONDS

/obj/effect/forcefield/wizard/guardian/CanPass(atom/movable/mover, turf/target)
	var/mob/living/simple_animal/hostile/guardian/P = wizard
	if(mover == wizard || istype(P) && mover == P.summoner)
		return TRUE
	return FALSE

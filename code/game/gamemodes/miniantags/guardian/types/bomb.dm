/mob/living/simple_animal/hostile/guardian/bomb
	melee_damage_lower = 15
	melee_damage_upper = 15
	damage_transfer = 0.6
	range = 13
	playstyle_string = "Будучи <b>Подрывником</b> у вас весьма посредственные боевые способности, но вы можете конвертировать любой предмет вокруг себя в скрытую бомбу на Alt+Click. Даже будучи в хозяине. Помните: бомбы живут минуту!"
	magic_fluff_string = "...и вытаскиваете Ученого, мастера взрывной смерти."
	tech_fluff_string = "Последовательность загрузки завершена. Взрывные модули активны. Голопаразитный рой активирован."
	bio_fluff_string = "Ваш рой скарабеев заканчивает мутировать и оживает, способный незаметно заминировать предметы."
	var/bomb_cooldown = 0
	var/default_bomb_cooldown = 10 SECONDS

/mob/living/simple_animal/hostile/guardian/bomb/Stat()
	..()
	if(statpanel("Status"))
		if(bomb_cooldown >= world.time)
			stat(null, "Перезарядка до следующей бомбы: [max(round((bomb_cooldown - world.time)*0.1, 0.1), 0)] секунд.")

/mob/living/simple_animal/hostile/guardian/bomb/AltClickOn(atom/movable/A)
	if(!istype(A))
		return
	if(get_dist(get_turf(src), get_turf(A)) > 3)
		to_chat(src, "<span class='danger'>Слишком далеко от [A] чтобы скрыть это как бомбу.</span>")
		return
	if(istype(A, /obj/) && can_plant(A))
		if(bomb_cooldown <= world.time && !stat)
			var/obj/item/guardian_bomb/B = new /obj/item/guardian_bomb(get_turf(A))
			add_attack_logs(src, A, "booby trapped (summoner: [summoner])")
			to_chat(src, "<span class='danger'>Успех! Бомба на [A] взведена!</span>")
			if(summoner)
				to_chat(summoner, "<span class='warning'>Ваш Подрывник взвел [A] для взрыва!</span>")
			bomb_cooldown = world.time + default_bomb_cooldown
			B.spawner = src
			B.disguise (A)
		else
			to_chat(src, "<span class='danger'>Ваши силы на перезарядке! Вы должны ждать ещё [max(round((bomb_cooldown - world.time)*0.1, 0.1), 0)] секунд до установки следующей бомбы.</span>")

/mob/living/simple_animal/hostile/guardian/bomb/proc/can_plant(atom/movable/A)
	if(istype(A, /obj/mecha))
		var/obj/mecha/target = A
		if(target.occupant)
			to_chat(src, "<span class='warning'>Пилотируемые мехи непригодны для минирования!</span>")
			return FALSE
	if(istype(A, /obj/spacepod))
		var/obj/spacepod/target = A
		if(target.pilot)
			to_chat(src, "<span class='warning'>Челноки не пригодны для минирования!</span>")
			return FALSE
	if(istype(A, /obj/machinery/disposal)) // Have no idea why they just destroy themselves
		to_chat(src, "<span class='warning'>Бомбы не мусор! Нельзя минировать мусорки!</span>")
		return FALSE
	return TRUE

/obj/item/guardian_bomb
	name = "bomb"
	desc = "You shouldn't be seeing this!"
	var/obj/stored_obj
	var/mob/living/spawner

/obj/item/guardian_bomb/proc/disguise(var/obj/A)
	A.forceMove(src)
	stored_obj = A
	opacity = A.opacity
	anchored = A.anchored
	density = A.density
	appearance = A.appearance
	dir = A.dir
	move_resist = A.move_resist
	addtimer(CALLBACK(src, .proc/disable), 600)

/obj/item/guardian_bomb/proc/disable()
	add_attack_logs(null, stored_obj, "booby trap expired")
	stored_obj.forceMove(get_turf(src))
	if(spawner)
		to_chat(spawner, "<span class='danger'>Провал! Ваша мина на [stored_obj] не смогла никого поймать на сей раз.</span>")
	qdel(src)

/obj/item/guardian_bomb/proc/detonate(var/mob/living/user)
	if(!istype(user))
		return
	if(get_dist(get_turf(src), get_turf(user)) > 1)
		return
	to_chat(user, "<span class='danger'> Это ловушка! [src] был заминирован!</span>")

	if(istype(spawner, /mob/living/simple_animal/hostile/guardian))
		var/mob/living/simple_animal/hostile/guardian/G = spawner
		if(user == G.summoner)
			add_attack_logs(user, stored_obj, "booby trap defused")
			to_chat(user, "<span class='danger'>Из-за связи с вашим Подрывником вы знали о бомбе и деактивировали её.</span>")
			stored_obj.forceMove(get_turf(loc))
			qdel(src)
			qdel(src)
			return
	add_attack_logs(user, stored_obj, "booby trap TRIGGERED (spawner: [spawner])")
	to_chat(spawner, "<span class='danger'>Успех! Ваша мина на [src] поймала [user]!</span>")
	stored_obj.forceMove(get_turf(loc))
	playsound(get_turf(src),'sound/effects/bomb_activate.ogg', 200, 1)
	playsound(get_turf(src),'sound/effects/explosion1.ogg', 200, 1)
	user.ex_act(3)
	user.Weaken(3)
	if(ishuman(user))
		dead_legs(user)
	user.adjustBruteLoss(40)
	qdel(src)
	qdel(src)

/obj/item/guardian_bomb/proc/dead_legs(mob/living/carbon/human/H as mob)
	var/obj/item/organ/external/l = H.get_organ("l_leg")
	var/obj/item/organ/external/r = H.get_organ("r_leg")
	if(l && prob(50))
		l.droplimb(0, DROPLIMB_SHARP)
	if(r && prob(50))
		r.droplimb(0, DROPLIMB_SHARP)

/obj/item/guardian_bomb/attackby(obj/item/W, mob/living/user)
	detonate(user)

/obj/item/guardian_bomb/pickup(mob/living/user)
	detonate(user)
	return FALSE // Disarm or blow up. No picking up

/obj/item/guardian_bomb/MouseDrop_T(obj/item/I, mob/living/user)
	detonate(user)

/obj/item/guardian_bomb/AltClick(mob/living/user)
	detonate(user)

/obj/item/guardian_bomb/MouseDrop(mob/living/user)
	detonate(user)

/obj/item/guardian_bomb/Bumped(mob/living/user)
	detonate(user)

/obj/item/guardian_bomb/can_be_pulled(mob/living/user)
	detonate(user)

/obj/item/guardian_bomb/examine(mob/user)
	. = stored_obj.examine(user)
	if(get_dist(user, src) <= 2)
		. += "<span class='notice'>Looks odd!</span>"

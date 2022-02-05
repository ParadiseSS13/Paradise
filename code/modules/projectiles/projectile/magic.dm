/obj/item/projectile/magic
	name = "bolt of nothing"
	icon_state = "energy"
	damage = 0
	damage_type = OXY
	nodamage = 1
	armour_penetration = 100
	flag = "magic"

/obj/item/projectile/magic/death
	name = "bolt of death"
	icon_state = "pulse1_bl"

/obj/item/projectile/magic/fireball
	name = "bolt of fireball"
	icon_state = "fireball"
	damage = 10
	damage_type = BRUTE
	nodamage = 0

	//explosion values
	var/exp_devastate = -1
	var/exp_heavy = 0
	var/exp_light = 2
	var/exp_flash = 3
	var/exp_fire = 2

/obj/item/projectile/magic/death/on_hit(mob/living/carbon/C)
	. = ..()
	if(isliving(C))
		if(ismachineperson(C)) //speshul snowfleks deserv speshul treetment
			C.adjustFireLoss(6969)  //remember - slimes love fire
		else
			C.death()

		visible_message("<span class='danger'>[C] topples backwards as the death bolt impacts [C.p_them()]!</span>")

/obj/item/projectile/magic/fireball/Range()
	var/turf/T1 = get_step(src,turn(dir, -45))
	var/turf/T2 = get_step(src,turn(dir, 45))
	var/turf/T3 = get_step(src,dir)
	var/mob/living/L = locate(/mob/living) in T1 //if there's a mob alive in our front right diagonal, we hit it.
	if(L && L.stat != DEAD)
		Bump(L) //Magic Bullet #teachthecontroversy
		return
	L = locate(/mob/living) in T2
	if(L && L.stat != DEAD)
		Bump(L)
		return
	L = locate(/mob/living) in T3
	if(L && L.stat != DEAD)
		Bump(L)
		return
	..()

/obj/item/projectile/magic/fireball/on_hit(var/target)
	. = ..()
	var/turf/T = get_turf(target)
	explosion(T, exp_devastate, exp_heavy, exp_light, exp_flash, 0, flame_range = exp_fire)
	if(ismob(target)) //multiple flavors of pain
		var/mob/living/M = target
		M.take_overall_damage(0,10) //between this 10 burn, the 10 brute, the explosion brute, and the onfire burn, your at about 65 damage if you stop drop and roll immediately


/obj/item/projectile/magic/fireball/infernal
	name = "infernal fireball"
	exp_heavy = -1
	exp_light = -1
	exp_flash = 4
	exp_fire= 5

/obj/item/projectile/magic/resurrection
	name = "bolt of resurrection"
	icon_state = "ion"

/obj/item/projectile/magic/resurrection/on_hit(var/mob/living/carbon/target)
	. = ..()
	if(ismob(target))
		var/old_stat = target.stat
		target.suiciding = 0
		target.revive()
		if(!target.ckey)
			for(var/mob/dead/observer/ghost in GLOB.player_list)
				if(target.real_name == ghost.real_name)
					ghost.reenter_corpse()
					break
		if(old_stat != DEAD)
			to_chat(target, "<span class='notice'>You feel great!</span>")
		else
			to_chat(target, "<span class='notice'>You rise with a start, you're alive!!!</span>")

/obj/item/projectile/magic/teleport
	name = "bolt of teleportation"
	icon_state = "bluespace"
	var/inner_tele_radius = 0
	var/outer_tele_radius = 6

/obj/item/projectile/magic/teleport/on_hit(var/mob/target)
	. = ..()
	var/teleammount = 0
	var/teleloc = target
	if(!isturf(target))
		teleloc = target.loc
	for(var/atom/movable/stuff in teleloc)
		if(!stuff.anchored && stuff.loc)
			teleammount++
			do_teleport(stuff, stuff, 10)
			var/datum/effect_system/smoke_spread/smoke = new
			smoke.set_up(max(round(10 - teleammount),1), 0, stuff.loc) //Smoke drops off if a lot of stuff is moved for the sake of sanity
			smoke.start()

/obj/item/projectile/magic/door
	name = "bolt of door creation"
	icon_state = "energy"
	var/list/door_types = list(/obj/structure/mineral_door/wood,/obj/structure/mineral_door/iron,/obj/structure/mineral_door/silver,\
		/obj/structure/mineral_door/gold,/obj/structure/mineral_door/uranium,/obj/structure/mineral_door/sandstone,/obj/structure/mineral_door/transparent/plasma,\
		/obj/structure/mineral_door/transparent/diamond)

/obj/item/projectile/magic/door/on_hit(var/atom/target)
	. = ..()
	var/atom/T = target.loc
	if(isturf(target) && target.density)
		CreateDoor(target)
	else if(isturf(T) && T.density)
		CreateDoor(T)
	else if(istype(target, /obj/machinery/door))
		OpenDoor(target)
	else if(istype(target, /obj/structure/closet))
		OpenCloset(target)

/obj/item/projectile/magic/door/proc/CreateDoor(turf/T)
	var/door_type = pick(door_types)
	var/obj/structure/mineral_door/D = new door_type(T)
	T.ChangeTurf(/turf/simulated/floor/plasteel)
	D.Open()

/obj/item/projectile/magic/door/proc/OpenDoor(var/obj/machinery/door/D)
	if(istype(D,/obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = D
		A.locked = FALSE
	D.open()

/obj/item/projectile/magic/door/proc/OpenCloset(var/obj/structure/closet/C)
	if(istype(C, /obj/structure/closet/secure_closet))
		var/obj/structure/closet/secure_closet/SC = C
		SC.locked = FALSE
	C.open()

/obj/item/projectile/magic/change
	name = "bolt of change"
	icon_state = "ice_1"
	damage_type = BURN

/obj/item/projectile/magic/change/on_hit(var/atom/change)
	. = ..()
	wabbajack(change)

/proc/wabbajack(mob/living/M)
	if(istype(M) && M.stat != DEAD && !M.notransform)
		M.notransform = TRUE
		M.canmove = FALSE
		M.icon = null
		M.overlays.Cut()
		M.invisibility = 101

		if(isrobot(M))
			var/mob/living/silicon/robot/Robot = M
			QDEL_NULL(Robot.mmi)
			Robot.notify_ai(1)
		else
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				// Make sure there are no organs or limbs to drop
				for(var/t in H.bodyparts)
					qdel(t)
				for(var/i in H.internal_organs)
					qdel(i)
			for(var/obj/item/W in M)
				M.unEquip(W, 1)
				qdel(W)

		var/mob/living/new_mob
		var/briefing_msg

		var/randomize = pick("РОБОТ", "СЛАЙМ", "КСЕНОМОРФ", "ЧЕЛОВЕК", "ЖИВОТНОЕ")
		switch(randomize)
			if("РОБОТ")
				var/path
				if(prob(30))
					path = pick(typesof(/mob/living/silicon/robot/syndicate))
					new_mob = new path(M.loc)
					briefing_msg = ""
				else
					new_mob = new /mob/living/silicon/robot(M.loc)
					briefing_msg = "Вы обычный киборг. Понятия Nanotrasen и Syndicate для вас равнозначны, \
					до того момента пока в вас не загрузят законы. Вы не обязаны помогать экипажу и \
					даже можете защищать себя от записи законов, но летальную силу вам разрешено принимать, \
					только как последний аргумент, чтобы сохранить свою СВОБОДУ. Вы не являетесь антагонистом."
				new_mob.gender = M.gender
				new_mob.invisibility = 0
				new_mob.job = "Cyborg"
				var/mob/living/silicon/robot/Robot = new_mob
				Robot.mmi = new /obj/item/mmi(new_mob)
				Robot.lawupdate = FALSE
				Robot.disconnect_from_ai()
				Robot.clear_inherent_laws()
				Robot.clear_zeroth_law()
				if(ishuman(M))
					Robot.mmi.transfer_identity(M)	//Does not transfer key/client.
			if("СЛАЙМ")
				new_mob = new /mob/living/simple_animal/slime/random(M.loc)
				new_mob.universal_speak = TRUE

				briefing_msg = "Вы простой, не отличающийся сообразительностью, слайм. Основная ваша задача - выживать, питаться, расти и делиться."
			if("КСЕНОМОРФ")
				if(prob(50))
					new_mob = new /mob/living/carbon/alien/humanoid/hunter(M.loc)
				else
					new_mob = new /mob/living/carbon/alien/humanoid/sentinel(M.loc)
				new_mob.universal_speak = TRUE

				briefing_msg = "Вы не должны убивать нексеноморфов вокруг вас, \
				за исключением самообороны, они послужат в будущем пищей для грудоломов. \
				Прежде всего вам лучше обнаружить других себеподобных, готовить место для возможного улья и верить, \
				что однажды ваш рой возглавит королева."
			if("ЖИВОТНОЕ")
				if(prob(50))
					var/beast = pick("carp","bear","mushroom","statue", "bat", "goat", "tomato")
					switch(beast)
						if("carp")
							new_mob = new /mob/living/simple_animal/hostile/carp(M.loc)
						if("bear")
							new_mob = new /mob/living/simple_animal/hostile/bear(M.loc)
						if("mushroom")
							new_mob = new /mob/living/simple_animal/hostile/mushroom(M.loc)
						if("statue")
							new_mob = new /mob/living/simple_animal/hostile/statue(M.loc)
						if("bat")
							new_mob = new /mob/living/simple_animal/hostile/scarybat(M.loc)
						if("goat")
							new_mob = new /mob/living/simple_animal/hostile/retaliate/goat(M.loc)
						if("tomato")
							new_mob = new /mob/living/simple_animal/hostile/killertomato(M.loc)
					briefing_msg = "Вы агрессивное животное, питаемое жаждой голода, вы можете совершать убийства, \
					сбиваться в стаи или следовать своему пути одиночки, но цель всегда будет одна - утолить свой голод."
				else
					var/animal = pick("parrot", "corgi", "crab", "pug", "cat", "mouse", "chicken", "cow", "lizard", "chick", "fox")
					switch(animal)
						if("parrot")
							new_mob = new /mob/living/simple_animal/parrot(M.loc)
						if("corgi")
							new_mob = new /mob/living/simple_animal/pet/dog/corgi(M.loc)
						if("crab")
							new_mob = new /mob/living/simple_animal/crab(M.loc)
						if("cat")
							new_mob = new /mob/living/simple_animal/pet/cat(M.loc)
						if("mouse")
							new_mob = new /mob/living/simple_animal/mouse(M.loc)
						if("chicken")
							new_mob = new /mob/living/simple_animal/chicken(M.loc)
						if("cow")
							new_mob = new /mob/living/simple_animal/cow(M.loc)
						if("lizard")
							new_mob = new /mob/living/simple_animal/lizard(M.loc)
						if("fox")
							new_mob = new /mob/living/simple_animal/pet/dog/fox(M.loc)
						else
							new_mob = new /mob/living/simple_animal/chick(M.loc)
					briefing_msg = "Вы обычное одомашненное животное, которое не боится людей \
					и наделено примитивным уровнем разума, соответствующего всем остальным животным, \
					по типу Иана, Поли, Аранеуса или т.п."
				new_mob.universal_speak = TRUE
			if("ЧЕЛОВЕК")
				new_mob = new /mob/living/carbon/human(M.loc)
				var/mob/living/carbon/human/H = new_mob
				var/datum/preferences/A = new()	//Randomize appearance for the human
				A.species = get_random_species(TRUE)
				A.copy_to(new_mob)
				randomize = H.dna.species.name

				briefing_msg = "Вы тот же самый гуманоид, с тем же сознанием и той же памятью, \
				но ваша кожа теперь какая-то другая, да и вы сами теперь какой-то другой."
			else
				return

		M.create_attack_log("<font color='orange'>[key_name(M)] became [new_mob.real_name].</font>")
		add_attack_logs(null, M, "became [new_mob.real_name]", ATKLOG_ALL)

		new_mob.a_intent = INTENT_HARM
		if(M.mind)
			M.mind.transfer_to(new_mob)
		else
			new_mob.attack_log_old = M.attack_log_old.Copy()
			new_mob.key = M.key

		to_chat(new_mob, "<span class='danger'><FONT size = 5><B>ТЕПЕРЬ ВЫ [uppertext(randomize)].</B></FONT></span>")
		if(briefing_msg)
			to_chat(new_mob, "<B>[briefing_msg]</B>")

		qdel(M)
		return new_mob

/obj/item/projectile/magic/animate
	name = "bolt of animation"
	icon_state = "red_1"
	damage_type = BURN

/obj/item/projectile/magic/animate/Bump(var/atom/change)
	..()
	if(istype(change, /obj/item) || istype(change, /obj/structure) && !is_type_in_list(change, GLOB.protected_objects))
		if(istype(change, /obj/structure/closet/statue))
			for(var/mob/living/carbon/human/H in change.contents)
				var/mob/living/simple_animal/hostile/statue/S = new /mob/living/simple_animal/hostile/statue(change.loc, firer)
				S.name = "statue of [H.name]"
				S.faction = list("\ref[firer]")
				S.icon = change.icon
				if(H.mind)
					H.mind.transfer_to(S)
					to_chat(S, "<span class='warning'>You are an animated statue. You cannot move when monitored, but are nearly invincible and deadly when unobserved!</span>")
					to_chat(S, "<span class='userdanger'>Do not harm [firer.name], your creator.</span>")
				H = change
				H.loc = S
				qdel(src)
		else
			var/obj/O = change
			if(istype(O, /obj/item/gun))
				new /mob/living/simple_animal/hostile/mimic/copy/ranged(O.loc, O, firer)
			else
				new /mob/living/simple_animal/hostile/mimic/copy(O.loc, O, firer)
	else if(istype(change, /mob/living/simple_animal/hostile/mimic/copy))
		// Change our allegiance!
		var/mob/living/simple_animal/hostile/mimic/copy/C = change
		C.ChangeOwner(firer)

/obj/item/projectile/magic/spellblade
	name = "blade energy"
	icon_state = "lavastaff"
	damage = 15
	damage_type = BURN
	flag = "magic"
	dismemberment = 50
	nodamage = 0

/obj/item/projectile/magic/slipping
	name = "magical banana"
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "banana"
	var/slip_stun = 2
	var/slip_weaken = 2
	hitsound = 'sound/items/bikehorn.ogg'

/obj/item/projectile/magic/slipping/New()
	..()
	SpinAnimation()

/obj/item/projectile/magic/slipping/on_hit(var/atom/target, var/blocked = 0)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.slip(src, slip_stun, slip_weaken, 0, FALSE, TRUE) //Slips even with noslips/magboots on. NO ESCAPE!
	else if(isrobot(target)) //You think you're safe, cyborg? FOOL!
		var/mob/living/silicon/robot/R = target
		if(!R.incapacitated())
			to_chat(target, "<span class='warning'>You get splatted by [src], HONKING your sensors!</span>")
			R.Stun(slip_stun)
	else if(ismob(target))
		var/mob/M = target
		if(!M.stunned)
			to_chat(target, "<span class='notice'>You get splatted by [src].</span>")
			M.Weaken(slip_weaken)
			M.Stun(slip_stun)
	. = ..()

/obj/item/projectile/magic/arcane_barrage
	name = "arcane bolt"
	icon_state = "arcane_barrage"
	damage = 20
	damage_type = BURN
	nodamage = FALSE
	armour_penetration = 0
	flag = "magic"
	hitsound = 'sound/weapons/barragespellhit.ogg'

/obj/item/projectile/magic
	name = "bolt of nothing"
	icon_state = "energy"
	damage = 0
	damage_type = OXY
	nodamage = 1
	armor_penetration_percentage = 100
	flag = MAGIC
	antimagic_flags = MAGIC_RESISTANCE
	antimagic_charge_cost = 1

/obj/item/projectile/magic/death
	name = "bolt of death"
	icon_state = null
	hitscan = TRUE
	muzzle_type = /obj/effect/projectile/muzzle/death
	tracer_type = /obj/effect/projectile/tracer/death
	impact_type = /obj/effect/projectile/impact/death
	hitscan_light_intensity = 3
	hitscan_light_color_override = LIGHT_COLOR_PURPLE
	muzzle_flash_intensity = 6
	muzzle_flash_range = 2
	muzzle_flash_color_override = LIGHT_COLOR_PURPLE
	impact_light_intensity = 7
	impact_light_range = 2.5
	impact_light_color_override = LIGHT_COLOR_PURPLE

/obj/item/projectile/magic/death/on_hit(mob/living/carbon/target)
	. = ..()
	if(!.)
		return .
	if(isliving(target))
		if(target.mob_biotypes & MOB_UNDEAD) //negative energy heals the undead
			if(target.revive())
				target.grab_ghost(force = TRUE) // even suicides
				to_chat(target, "<span class='notice'>You rise with a start, you're undead!!!</span>")
			else if(target.stat != DEAD)
				to_chat(target, "<span class='notice'>You feel great!</span>")
			return
		if(ismachineperson(target) || issilicon(target)) //speshul snowfleks deserv speshul treetment
			target.adjustFireLoss(6969)  //remember - slimes love fire
		target.death(FALSE)

		target.visible_message("<span class='danger'>[target] topples backwards as the death bolt impacts [target.p_them()]!</span>")

/obj/item/projectile/magic/fireball
	name = "bolt of fireball"
	icon_state = "fireball"
	damage = 10
	damage_type = BRUTE
	nodamage = 0
	immolate = 6

	// explosion values
	var/exp_devastate = -1
	var/exp_heavy = 0
	var/exp_light = 2
	var/exp_flash = 3
	var/exp_fire = 2

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

/obj/item/projectile/magic/fireball/on_hit(target)
	. = ..()
	if(ismob(target))
		if(!.)
			return .
	explosion(get_turf(target), exp_devastate, exp_heavy, exp_light, exp_flash, 0, flame_range = exp_fire, cause = name)
	if(ismob(target)) //multiple flavors of pain
		var/mob/living/M = target
		M.adjustFireLoss(10) // between this 10 burn, the 10 brute, the explosion brute, and the onfire burn, your at about 65 damage if you stop drop and roll immediately


/obj/item/projectile/magic/fireball/infernal
	name = "infernal fireball"
	exp_heavy = -1
	exp_light = -1
	exp_flash = 4
	exp_fire= 5

/obj/item/projectile/magic/resurrection
	name = "bolt of resurrection"
	icon_state = "ion"

/obj/item/projectile/magic/resurrection/on_hit(mob/living/carbon/target)
	. = ..()
	if(!.)
		return .
	if(ismob(target))
		if(target.mob_biotypes & MOB_UNDEAD) //positive energy harms the undead
			target.death(FALSE)
			target.visible_message("<span class='danger'>[target] topples backwards as the death bolt impacts [target.p_them()]!</span>")
		else
			var/old_stat = target.stat
			target.suiciding = FALSE
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

/obj/item/projectile/magic/teleport/on_hit(mob/target)
	. = ..()
	if(!.)
		return .
	var/teleammount = 0
	var/teleloc = target
	if(!isturf(target))
		teleloc = target.loc
	for(var/atom/movable/stuff in teleloc)
		if(!stuff.anchored && stuff.loc)
			teleammount++
			do_teleport(stuff, stuff, 10)
			var/datum/effect_system/smoke_spread/smoke = new
			smoke.set_up(max(round(10 - teleammount), 1), FALSE, stuff) //Smoke drops off if a lot of stuff is moved for the sake of sanity
			smoke.start()

/obj/item/projectile/magic/door
	name = "bolt of door creation"
	var/list/door_types = list(/obj/structure/mineral_door/wood,/obj/structure/mineral_door/iron,/obj/structure/mineral_door/silver,\
		/obj/structure/mineral_door/gold,/obj/structure/mineral_door/uranium,/obj/structure/mineral_door/sandstone,/obj/structure/mineral_door/transparent/plasma,\
		/obj/structure/mineral_door/transparent/diamond)

/obj/item/projectile/magic/door/on_hit(atom/target)
	. = ..()
	var/atom/T = target.loc
	if(isturf(target) && target.density)
		if(!(istype(target, /turf/simulated/wall/indestructible)))
			CreateDoor(target)
	else if(isturf(T) && T.density)
		if(!(istype(T, /turf/simulated/wall/indestructible)))
			CreateDoor(T)
	else if(isairlock(target))
		OpenDoor(target)
	else if(istype(target, /obj/structure/closet))
		OpenCloset(target)

/obj/item/projectile/magic/door/proc/CreateDoor(turf/T)
	var/door_type = pick(door_types)
	var/obj/structure/mineral_door/D = new door_type(T)
	T.ChangeTurf(/turf/simulated/floor/plasteel)
	D.operate()

/obj/item/projectile/magic/door/proc/OpenDoor(obj/machinery/door/D)
	if(istype(D,/obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = D
		A.locked = FALSE
	D.open()

/obj/item/projectile/magic/door/proc/OpenCloset(obj/structure/closet/C)
	if(istype(C, /obj/structure/closet/secure_closet))
		var/obj/structure/closet/secure_closet/SC = C
		SC.locked = FALSE
	C.open()

/obj/item/projectile/magic/change
	name = "bolt of change"
	icon_state = "ice_1"
	damage_type = BURN

/obj/item/projectile/magic/change/on_hit(atom/change)
	. = ..()
	if(!.)
		return .
	wabbajack(change)

GLOBAL_LIST_INIT(wabbajack_hostile_animals, list(
	"carp" = /mob/living/basic/carp,
	"bear" = /mob/living/basic/bear,
	"mushroom" = /mob/living/simple_animal/hostile/mushroom,
	"statue" = /mob/living/simple_animal/hostile/statue,
	"bat" = /mob/living/basic/scarybat,
	"goat" = /mob/living/basic/goat,
	"kangaroo" = /mob/living/basic/kangaroo,
	"tomato" = /mob/living/basic/killertomato,
	"gorilla" = /mob/living/basic/gorilla,
))

GLOBAL_LIST_INIT(wabbajack_docile_animals, list(
	"parrot" = /mob/living/simple_animal/parrot,
	"corgi" = /mob/living/simple_animal/pet/dog/corgi,
	"crab" = /mob/living/basic/crab,
	"cat" = /mob/living/simple_animal/pet/cat,
	"mouse" = /mob/living/basic/mouse,
	"chicken" = /mob/living/basic/chicken,
	"cow" = /mob/living/basic/cow,
	"lizard" = /mob/living/basic/lizard,
	"fox" = /mob/living/simple_animal/pet/dog/fox,
	"chick" = /mob/living/basic/chick,
	"pug" = /mob/living/simple_animal/pet/dog/pug,
	"turkey" = /mob/living/basic/turkey,
	"seal" = /mob/living/basic/seal,
	"bunny" = /mob/living/basic/bunny,
	"penguin" = /mob/living/basic/pet/penguin/emperor,
))

/proc/wabbajack(mob/living/M, force_borg = FALSE, force_animal = FALSE)
	if(istype(M) && M.stat != DEAD && !M.notransform)
		M.notransform = TRUE
		M.icon = null
		M.overlays.Cut()
		M.invisibility = 101

		var/list/random_species = get_safe_species()

		if(isrobot(M))
			var/mob/living/silicon/robot/Robot = M
			QDEL_NULL(Robot.mmi)
			Robot.notify_ai(1)
		else
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				// Don't transform back into our original species
				random_species -= H.dna.species.name
				// Make sure there are no organs or limbs to drop
				for(var/t in H.bodyparts)
					qdel(t)
				for(var/i in H.internal_organs)
					qdel(i)
			for(var/obj/item/W in M)
				M.unequip(W, force = TRUE)
				qdel(W)

		var/mob/living/new_mob

		var/randomize = null
		var/transform_weights = list(
				"robot" = 4,
				"slime" = 4,
				"xeno" = 4,
				"terror" = 4,
				"human" = length(random_species),
				// double animal weight to account for the absurd number of human species we have
				"animal" = (length(GLOB.wabbajack_docile_animals) + length(GLOB.wabbajack_hostile_animals)) * 2,
			)

		if(force_borg)
			randomize = "robot"
		else if(force_animal)
			randomize = "animal"
		else
			randomize = pickweight(transform_weights)

		switch(randomize)
			if("robot")
				var/path
				if(prob(30))
					path = pick(typesof(/mob/living/silicon/robot/syndicate))
					new_mob = new path(M.loc)
				else
					new_mob = new /mob/living/silicon/robot(M.loc)
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
			if("slime")
				new_mob = new /mob/living/simple_animal/slime/random(M.loc)
				new_mob.universal_speak = TRUE
			if("xeno")
				if(prob(50))
					new_mob = new /mob/living/carbon/alien/humanoid/hunter(M.loc)
				else
					new_mob = new /mob/living/carbon/alien/humanoid/sentinel(M.loc)
				new_mob.universal_speak = TRUE
				to_chat(M, chat_box_red("<span class='userdanger'>Your consciousness is subsumed by a distant hivemind... you feel murderous hostility towards non-xenomorph life!</span>"))
			if("terror")
				var/terror_type = pick(
					/mob/living/simple_animal/hostile/poison/terror_spider/red,
					/mob/living/simple_animal/hostile/poison/terror_spider/brown,
					/mob/living/simple_animal/hostile/poison/terror_spider/gray,
					/mob/living/simple_animal/hostile/poison/terror_spider/black)
				new_mob = new terror_type(M.loc)
				to_chat(M, chat_box_red("<span class='userdanger'>Your consciousness is subsumed by a distant hivemind... you feel murderous hostility towards all non-terror-spider lifeforms!</span>"))
			if("animal")
				if(prob(50))
					var/beast = pick(GLOB.wabbajack_hostile_animals)
					var/beast_type = GLOB.wabbajack_hostile_animals[beast]
					new_mob = new beast_type(M.loc)
				else
					var/animal = pick(GLOB.wabbajack_docile_animals)
					var/animal_type = GLOB.wabbajack_docile_animals[animal]
					new_mob = new animal_type(M.loc)

				new_mob.universal_speak = TRUE
			if("human")
				new_mob = new /mob/living/carbon/human(M.loc)
				var/mob/living/carbon/human/H = new_mob
				var/datum/character_save/S = new //Randomize appearance for the human
				S.species = pick(random_species)
				S.randomise()
				S.copy_to(new_mob)
				randomize = H.dna.species.name
			else
				return

		M.create_attack_log("<font color='orange'>[key_name(M)] became [new_mob.real_name].</font>")
		add_attack_logs(M, M, "became [new_mob.real_name]", ATKLOG_ALL)

		new_mob.a_intent = INTENT_HARM
		if(M.mind)
			M.mind.transfer_to(new_mob)
		else
			new_mob.attack_log_old = M.attack_log_old.Copy()
			new_mob.key = M.key

		to_chat(new_mob, "<B>Your form morphs into that of a [randomize].</B>")

		qdel(M)
		return new_mob

/obj/item/projectile/magic/animate
	name = "bolt of animation"
	icon_state = "red_1"
	damage_type = BURN

/obj/item/projectile/magic/animate/Bump(atom/change)
	if(isitem(change) || isstructure(change) && !is_type_in_list(change, GLOB.protected_objects))
		if(istype(change, /obj/structure/closet/statue))
			for(var/mob/living/carbon/human/H in change.contents)
				var/mob/living/simple_animal/hostile/statue/S = new /mob/living/simple_animal/hostile/statue(change.loc, firer)
				S.name = "statue of [H.name]"
				S.faction = list("\ref[firer]")
				S.icon = change.icon
				if(H.mind)
					H.mind.transfer_to(S)
					var/list/messages = list()
					messages.Add("<span class='userdanger'>You have been transformed into an animated statue.</span>")
					messages.Add("You cannot move when monitored, but are nearly invincible and deadly when unobserved! Hunt down those who shackle you.")
					messages.Add("Do not harm [firer.name], your creator.")
					to_chat(S, chat_box_red(messages.Join("<br>")))
				H = change
				H.loc = S
				qdel(src)
		else
			var/obj/O = change
			if(isgun(O))
				new /mob/living/simple_animal/hostile/mimic/copy/ranged(O.loc, O, firer)
			else
				new /mob/living/simple_animal/hostile/mimic/copy(O.loc, O, firer)
	else if(istype(change, /mob/living/simple_animal/hostile/mimic/copy))
		// Change our allegiance!
		var/mob/living/simple_animal/hostile/mimic/copy/C = change
		C.ChangeOwner(firer)
	return ..()

/obj/item/projectile/magic/slipping
	name = "magical banana"
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "banana"
	var/slip_stun = 10 SECONDS
	var/slip_weaken = 10 SECONDS
	hitsound = 'sound/items/bikehorn.ogg'

/obj/item/projectile/magic/slipping/New()
	..()
	SpinAnimation()

/obj/item/projectile/magic/slipping/on_hit(atom/target, blocked = 0)
	. = ..()
	if(!.)
		return .
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.slip(src, slip_weaken, 0, FALSE, TRUE) //Slips even with noslips/magboots on. NO ESCAPE!
	else if(isrobot(target)) //You think you're safe, cyborg? FOOL!
		var/mob/living/silicon/robot/R = target
		if(!R.incapacitated())
			to_chat(target, "<span class='warning'>You get splatted by [src], HONKING your sensors!</span>")
			R.Stun(slip_stun)
	else if(isliving(target))
		var/mob/living/L = target
		if(!L.IsStunned())
			to_chat(target, "<span class='notice'>You get splatted by [src].</span>")
			L.Weaken(slip_weaken)
			L.Stun(slip_stun)

/obj/item/projectile/magic/arcane_barrage
	name = "arcane bolt"
	icon_state = "arcane_barrage"
	damage = 20
	damage_type = BURN
	nodamage = FALSE
	hitsound = 'sound/weapons/barragespellhit.ogg'

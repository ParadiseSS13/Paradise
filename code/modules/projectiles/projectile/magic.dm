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
	damage_type = BURN //OXY does not kill IPCs
	damage = 50000
	nodamage = 0

/obj/item/projectile/magic/fireball
	name = "bolt of fireball"
	icon_state = "fireball"
	damage = 10
	damage_type = BRUTE
	nodamage = 0

/obj/item/projectile/magic/fireball/Range()
	var/turf/T1 = get_step(src,turn(dir, -45))
	var/turf/T2 = get_step(src,turn(dir, 45))
	var/mob/living/L = locate(/mob/living) in T1 //if there's a mob alive in our front right diagonal, we hit it.
	if(L && L.stat != DEAD)
		Bump(L) //Magic Bullet #teachthecontroversy
		return
	L = locate(/mob/living) in T2
	if(L && L.stat != DEAD)
		Bump(L)
		return
	..()

/obj/item/projectile/magic/fireball/on_hit(var/target)
	. = ..()
	var/turf/T = get_turf(target)
	explosion(T, -1, 0, 2, 3, 0, flame_range = 2)
	if(ismob(target)) //multiple flavors of pain
		var/mob/living/M = target
		M.take_overall_damage(0,10) //between this 10 burn, the 10 brute, the explosion brute, and the onfire burn, your at about 65 damage if you stop drop and roll immediately

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
			for(var/mob/dead/observer/ghost in player_list)
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
			var/datum/effect/system/harmless_smoke_spread/smoke = new /datum/effect/system/harmless_smoke_spread()
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

/obj/item/projectile/magic/door/proc/CreateDoor(turf/T)
	var/door_type = pick(door_types)
	var/obj/structure/mineral_door/D = new door_type(T)
	T.ChangeTurf(/turf/simulated/floor/plasteel)
	D.Open()

/obj/item/projectile/magic/door/proc/OpenDoor(var/obj/machinery/door/D)
	if(istype(D,/obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = D
		A.locked = 0
	D.open()

/obj/item/projectile/magic/change
	name = "bolt of change"
	icon_state = "ice_1"
	damage_type = BURN

/obj/item/projectile/magic/change/on_hit(var/atom/change)
	. = ..()
	wabbajack(change)

proc/wabbajack(mob/living/M)
	if(istype(M))
		if(istype(M, /mob/living) && M.stat != DEAD)
			if(M.notransform)
				return
			M.notransform = 1
			M.canmove = 0
			M.icon = null
			M.overlays.Cut()
			M.invisibility = 101

			if(istype(M, /mob/living/silicon/robot))
				var/mob/living/silicon/robot/Robot = M
				if(Robot.mmi)
					qdel(Robot.mmi)
				Robot.notify_ai(1)
			else
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					// Make sure there are no organs or limbs to drop
					for(var/t in H.organs)
						qdel(t)
					for(var/i in H.internal_organs)
						qdel(i)
				for(var/obj/item/W in M)
					M.unEquip(W, 1)
					qdel(W)

			var/mob/living/new_mob

			var/randomize = pick("robot","slime","xeno","human","animal")
			switch(randomize)
				if("robot")
					if(prob(30))
						new_mob = new /mob/living/silicon/robot/syndicate(M.loc)
					else
						new_mob = new /mob/living/silicon/robot(M.loc)
					new_mob.gender = M.gender
					new_mob.invisibility = 0
					new_mob.job = "Cyborg"
					var/mob/living/silicon/robot/Robot = new_mob
					Robot.mmi = new /obj/item/device/mmi(new_mob)
					if(ishuman(M))
						Robot.mmi.transfer_identity(M)	//Does not transfer key/client.
				if("slime")
					new_mob = new /mob/living/carbon/slime(M.loc)
					new_mob.universal_speak = 1
				if("xeno")
					if(prob(50))
						new_mob = new /mob/living/carbon/alien/humanoid/hunter(M.loc)
					else
						new_mob = new /mob/living/carbon/alien/humanoid/sentinel(M.loc)
					new_mob.universal_speak = 1
				if("animal")
					if(prob(50))
						var/beast = pick("carp","bear","mushroom","statue", "bat", "goat", "tomato")
						switch(beast)
							if("carp")		new_mob = new /mob/living/simple_animal/hostile/carp(M.loc)
							if("bear")		new_mob = new /mob/living/simple_animal/hostile/bear(M.loc)
							if("mushroom")	new_mob = new /mob/living/simple_animal/hostile/mushroom(M.loc)
							if("statue")	new_mob = new /mob/living/simple_animal/hostile/statue(M.loc)
							if("bat") 		new_mob = new /mob/living/simple_animal/hostile/scarybat(M.loc)
							if("goat")		new_mob = new /mob/living/simple_animal/hostile/retaliate/goat(M.loc)
							if("tomato")	new_mob = new /mob/living/simple_animal/hostile/killertomato(M.loc)
					else
						var/animal = pick("parrot","corgi","crab","pug","cat","mouse","chicken","cow","lizard","chick","fox")
						switch(animal)
							if("parrot")	new_mob = new /mob/living/simple_animal/parrot(M.loc)
							if("corgi")		new_mob = new /mob/living/simple_animal/pet/corgi(M.loc)
							if("crab")		new_mob = new /mob/living/simple_animal/crab(M.loc)
							if("cat")		new_mob = new /mob/living/simple_animal/pet/cat(M.loc)
							if("mouse")		new_mob = new /mob/living/simple_animal/mouse(M.loc)
							if("chicken")	new_mob = new /mob/living/simple_animal/chicken(M.loc)
							if("cow")		new_mob = new /mob/living/simple_animal/cow(M.loc)
							if("lizard")	new_mob = new /mob/living/simple_animal/lizard(M.loc)
							if("fox") 		new_mob = new /mob/living/simple_animal/pet/fox(M.loc)
							else			new_mob = new /mob/living/simple_animal/chick(M.loc)
					new_mob.universal_speak = 1
				if("human")
					new_mob = new /mob/living/carbon/human/human(M.loc)
					// Include standard, whitelisted, and monkey species...
					var/list/new_species = list("Human","Tajaran","Skrell","Unathi","Diona","Vulpkanin")
					new_species |= whitelisted_species
					for(var/SN in all_species)
						var/datum/species/S = all_species[SN]
						if(S.greater_form) // Monkeys
							new_species |= SN
					new_species -= "Vox Armalis" // ... but not Armalis. They're not really designed to be playable
					new_species |= "Golem" // Also, golems, sure, why not
					var/picked_species = pick(new_species)
					var/mob/living/carbon/human/H = new_mob
					H.set_species(picked_species)
					randomize = picked_species
					var/datum/preferences/A = new()	//Randomize appearance for the human
					A.copy_to(new_mob)
				else
					return

			M.attack_log += text("\[[time_stamp()]\] <font color='orange'>[M.real_name] ([M.ckey]) became [new_mob.real_name].</font>")
			new_mob.attack_log = M.attack_log

			new_mob.a_intent = I_HARM
			if(M.mind)
				M.mind.transfer_to(new_mob)
			else
				new_mob.key = M.key

			to_chat(new_mob, "<B>Your form morphs into that of a [randomize].</B>")

			qdel(M)
			return new_mob

/obj/item/projectile/magic/animate
	name = "bolt of animation"
	icon_state = "red_1"
	damage_type = BURN

/obj/item/projectile/magic/animate/Bump(var/atom/change)
	..()
	if(istype(change, /obj/item) || istype(change, /obj/structure) && !is_type_in_list(change, protected_objects))
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
			if(istype(O, /obj/item/weapon/gun))
				new /mob/living/simple_animal/hostile/mimic/copy/ranged(O.loc, O, firer)
			else
				new /mob/living/simple_animal/hostile/mimic/copy(O.loc, O, firer)
	else if(istype(change, /mob/living/simple_animal/hostile/mimic/copy))
		// Change our allegiance!
		var/mob/living/simple_animal/hostile/mimic/copy/C = change
		C.ChangeOwner(firer)

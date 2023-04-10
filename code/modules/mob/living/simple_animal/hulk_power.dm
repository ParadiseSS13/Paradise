//Transform spell

/obj/effect/proc_holder/spell/aoe_turf/hulk/hulk_transform
	name = "Transform"
	desc = "Превращение в халка."
	panel = "Hulk"
	action_icon_state = "transformarion_hulk"
	action_background_icon_state = "bg_hulk"
	charge_max = 100
	clothes_req = 0

/obj/effect/proc_holder/spell/aoe_turf/hulk/hulk_transform/cast(list/targets, mob/user)
	if(HAS_TRAIT(user, TRAIT_PACIFISM) || GLOB.pacifism_after_gt)
		to_chat(user, "<span class='warning'>Not enough angry power.")
		return
	if(istype(user,/mob/living/simple_animal/hulk))
		to_chat(user, "<span class='warning'>You are already hulk.")
		return
	to_chat(user, "<span class='bold notice'>You can feel real POWER.</span>")
	if(istype(user.loc, /obj/machinery/dna_scannernew))
		var/obj/machinery/dna_scannernew/DSN = loc
		DSN.occupant = null
		DSN.icon_state = "scanner_0"
	var/mob/living/simple_animal/hulk/Monster
	if(CLUMSY in user.mutations)
		Monster = new /mob/living/simple_animal/hulk/clown_hulk(get_turf(user))
	else if(isunathi(user))
		Monster = new /mob/living/simple_animal/hulk/zilla(get_turf(user))
	else
		Monster = new /mob/living/simple_animal/hulk/human(get_turf(user))

	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(10, 0, user.loc)
	smoke.start()
	playsound(user, 'sound/effects/bamf.ogg', CHANNEL_BUZZ)
	Monster.original_body = user
	user.forceMove(Monster)
	user.status_flags |= GODMODE
	user.mind.transfer_to(Monster)
	Monster.say(pick("RAAAAAAAARGH!", "HNNNNNNNNNGGGGGGH!", "GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", "AAAAAAARRRGH!" ))
	return

//HUMAN HULK

//Dash
/obj/effect/proc_holder/spell/aoe_turf/hulk/hulk_dash
	name = "Dash"
	desc = "Разбег. Чем он дольше, тем больнее будет, тем кто встанет у вас на пути."
	panel = "Hulk"
	action_icon_state = "charge_hulk"
	action_background_icon_state = "bg_hulk"
	charge_max = 130
	clothes_req = 0
	range = 5

/obj/effect/proc_holder/spell/aoe_turf/hulk/hulk_dash/cast(list/targets, mob/user)
	var/turf/T = get_turf(get_step(user,user.dir))
	for(var/mob/living/M in T.contents)
		to_chat(user, "<span class='warning'>Something right in front of you!</span>")
		return
	T = get_turf(get_step(T,user.dir))
	for(var/mob/living/M in T.contents)
		to_chat(user, "<span class='warning'>Something right in front of you!</span>")
		return

	var/failure = 0
	if (istype(user.loc,/mob) || user.lying || user.stunned || user.buckled || user.stat)
		to_chat(user, "<span class='warning'>You can't dash right now!</span>")
		return

	if (istype(user.loc,/turf) && !(istype(user.loc,/turf/space)))
		for(var/mob/M in range(user, 1))
			if(M.pulling == user)
				M.stop_pulling()


		user.visible_message("<span class='warning'><b>[user.name]</b> dashes forward!</span>")
		playsound(user, 'sound/weapons/thudswoosh.ogg', CHANNEL_BUZZ)
		if(failure)
			user.Weaken(2)
			user.Stun(2)
			user.visible_message("<span class='warning'> \the [user] attempts to dash away but was interrupted!</span>",
								"<span class='warning'>You attempt to dash but suddenly interrupted!</span>",
								"<span class='notice'>You hear the flexing of powerful muscles and suddenly a crash as a body hits the floor.</span>")
			return 0

		user.say(pick("RAAAAAAAARGH!", "HNNNNNNNNNGGGGGGH!", "GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", "AAAAAAARRRGH!" ))
		var/prevLayer = user.layer
		user.layer = 9
		var/cur_dir = user.dir
		var/turf/simulated/floor/tile = user.loc
		if(tile && istype(tile))
			tile.break_tile()
		var/speed = 3
		for(var/i=0, i<30, i++)
			var/hit = 0
			T = get_turf(get_step(user,user.dir))
			if(i < 7)
				if(istype(T,/turf/simulated/wall))
					hit = 1
				else if(istype(T,/turf/simulated/floor))
					for(var/obj/structure/S in T.contents)
						if(istype(S,/obj/structure/window))
							hit = 1
						if(istype(S,/obj/structure/grille))
							hit = 1
			else if(i > 6)
				if(istype(T,/turf/simulated/floor))
					for(var/obj/structure/S in T.contents)
						if(istype(S,/obj/structure/window))
							S.ex_act(2)
						if(istype(S,/obj/structure/grille))
							qdel(S)
				if(istype(T,/turf/simulated/wall))
					var/turf/simulated/wall/W = T
					var/mob/living/carbon/human/H = user
					if(istype(T,/turf/simulated/wall/r_wall))
						playsound(H, 'sound/weapons/tablehit1.ogg', CHANNEL_BUZZ)
						hit = 1
						H.Weaken(3)
						H.take_overall_damage(25, used_weapon = "reinforced wall")
					else
						playsound(H, 'sound/weapons/tablehit1.ogg', CHANNEL_BUZZ)
						if(i > 20)
							if(prob(65))
								hit = 1
								W.dismantle_wall(1)
							else
								hit = 1
								W.take_damage(50)
								H.Weaken(2)
						else
							hit = 1
							W.take_damage(25)
							H.Weaken(2)
			if(i > 20)
				user.canmove = 0
				user.density = 0
				for(var/mob/living/M in T.contents)
					if(!M.lying)
						var/turf/target = get_turf(get_step(user,cur_dir))
						hit = 1
						playsound(M, 'sound/weapons/tablehit1.ogg', CHANNEL_BUZZ)
						for(var/o=0, o<10, o++)
							target = get_turf(get_step(target,cur_dir))
						var/mob/living/carbon/human/H = M
						if(istype(H,/mob/living/carbon/human))
							var/bodypart_name = pick(BODY_ZONE_CHEST,BODY_ZONE_L_ARM,BODY_ZONE_R_ARM,BODY_ZONE_L_LEG,BODY_ZONE_R_LEG,BODY_ZONE_HEAD,BODY_ZONE_TAIL, BODY_ZONE_WING)
							var/obj/item/organ/external/BP = H.bodyparts_by_name[bodypart_name]
							H.apply_damage(20,BRUTE,BP)
							BP.fracture()
							M.Weaken(2)
							M.Stun(2)
						else
							M.Weaken(2)
							M.Stun(2)
							M.take_overall_damage(40, used_weapon = "Hulk Foot")
						M.throw_at(target, 200, 100)
						break
			else if(i > 6)
				for(var/mob/living/M in T.contents)
					playsound(M, 'sound/misc/slip.ogg', CHANNEL_BUZZ)
					M.Weaken(2)
			if(user.lying)
				break
			if(hit)
				break
			if(i < 7)
				speed++
				if(speed > 3)
					speed = 0
					step(user, cur_dir)
			else if(i < 14)
				speed++
				if(speed > 2)
					speed = 0
					step(user, cur_dir)
			else if(i < 21)
				speed++
				if(speed > 1)
					speed = 0
					step(user, cur_dir)
			else if(i < 30)
				step(user, cur_dir)
			sleep(1)
		user.density = 1
		user.canmove = 1
		user.layer = prevLayer
	else
		to_chat(user, "<span class='warning'>You need a ground to do this!</span>")
		return

	if (istype(user.loc,/obj))
		var/obj/container = user.loc
		to_chat(user, "<span class='warning'>You dash and slam your head against the inside of [container]! Ouch!</span>")
		user.paralysis += 3
		user.weakened += 5
		container.visible_message("<span class='warning'><b>[user.loc]</b> emits a loud thump and rattles a bit.</span>")
		playsound(user, 'sound/effects/bang.ogg', CHANNEL_BUZZ)
		var/wiggle = 6
		while(wiggle > 0)
			wiggle--
			container.pixel_x = rand(-3,3)
			container.pixel_y = rand(-3,3)
			sleep(1)
		container.pixel_x = 0
		container.pixel_y = 0

	return

//Jump
/obj/effect/proc_holder/spell/aoe_turf/hulk/hulk_jump
	name = "Leap"
	desc = "Прыжок. Можно легко сломать кому-то кость при столкновении."
	panel = "Hulk"
	action_icon_state = "jump_hulk"
	action_background_icon_state = "bg_hulk"
	charge_max = 130
	clothes_req = 0
	range = 5

/obj/effect/proc_holder/spell/aoe_turf/hulk/hulk_jump/cast(list/targets , mob/user)
	//for(var/turf/T in targets)
	var/failure = 0
	if (istype(user.loc,/mob) || user.lying || user.stunned || user.buckled || user.stat)
		to_chat(user, "<span class='warning'>You can't jump right now!</span>")
		return

	if (istype(user.loc,/turf) && !(istype(user.loc,/turf/space)))

		for(var/mob/M in range(user, 1))
			if(M.pulling == user)
				M.stop_pulling()

		user.visible_message("<span class='warning'><b>[user.name]</b> takes a huge leap!</span>")
		playsound(user, 'sound/weapons/thudswoosh.ogg', CHANNEL_BUZZ)
		if(failure)
			user.Weaken(5)
			user.Stun(5)
			user.visible_message("<span class='warning'> \the [user] attempts to leap away but is slammed back down to the ground!</span>",
								"<span class='warning'>You attempt to leap away but are suddenly slammed back down to the ground!</span>",
								"<span class='notice'>You hear the flexing of powerful muscles and suddenly a crash as a body hits the floor.</span>")
			return 0

		user.say(pick("RAAAAAAAARGH!", "HNNNNNNNNNGGGGGGH!", "GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", "AAAAAAARRRGH!" ))
		var/prevLayer = user.layer
		user.layer = 9
		var/cur_dir = user.dir
		var/turf/simulated/floor/tile = user.loc
		if(tile)
			tile.break_tile()
		var/o=3
		for(var/i=0, i<14, i++)
			user.density = 0
			user.canmove = 0
			o++
			if(o == 4)
				o = 0
				step(user, cur_dir)
			if(i < 7) user.pixel_y += 8
			else user.pixel_y -= 8
			sleep(1)
		playsound(user, 'sound/effects/explosionfar.ogg', CHANNEL_BUZZ)
		for(tile in range(1, user))
			if(prob(50))
				tile.break_tile()
		for(var/mob/living/M in user.loc.contents)
			if(M != user)
				var/mob/living/carbon/human/H = M
				if(istype(H,/mob/living/carbon/human))
					playsound(H, 'sound/weapons/tablehit1.ogg', CHANNEL_BUZZ)
					var/bodypart_name = pick(BODY_ZONE_CHEST,BODY_ZONE_L_ARM,BODY_ZONE_R_ARM,BODY_ZONE_L_LEG,BODY_ZONE_R_LEG,BODY_ZONE_HEAD,BODY_ZONE_TAIL, BODY_ZONE_WING)
					var/obj/item/organ/external/BP = H.bodyparts_by_name[bodypart_name]
					H.apply_damage(20,BRUTE,BP)
					BP.fracture()
					H.Stun(5)
					H.Weaken(2)
				else
					playsound(M, 'sound/weapons/tablehit1.ogg', CHANNEL_BUZZ)
					M.Stun(2)
					M.Weaken(2)
					M.take_overall_damage(35, used_weapon = "Hulk Foot")
		var/snd = 1
		for(var/direction in GLOB.alldirs)
			var/turf/T = get_step(user,direction)
			for(var/mob/living/M in T.contents)
				if( (M != user) && !(M.stat))
					if(snd)
						snd = 0
						playsound(M, 'sound/misc/slip.ogg', CHANNEL_BUZZ)
					M.Weaken(2)
					for(var/i=0, i<6, i++)
						spawn(i)
							if(i < 3) M.pixel_y += 8
							else M.pixel_y -= 8
		user.density = 1
		user.canmove = 1
		user.layer = prevLayer
	else
		to_chat(user, "<span class='warning'>You need a ground to do this!</span>")
		return

	if (istype(user.loc,/obj))
		var/obj/container = user.loc
		to_chat(user, "<span class='warning'>You leap and slam your head against the inside of [container]! Ouch!</span>")
		user.paralysis += 3
		user.weakened += 5
		container.visible_message("<span class='warning'><b>[user.loc]</b> emits a loud thump and rattles a bit.</span>")
		playsound(user, 'sound/effects/bang.ogg', CHANNEL_BUZZ)
		var/wiggle = 6
		while(wiggle > 0)
			wiggle--
			container.pixel_x = rand(-3,3)
			container.pixel_y = rand(-3,3)
			sleep(1)
		container.pixel_x = 0
		container.pixel_y = 0

	return
//Clown-Hulk

//Hulk Honk
/obj/effect/proc_holder/spell/aoe_turf/hulk/hulk_honk
	name = "HulkHONK"
	desc = "Ваш хонк заставляет ваших врагов пасть на пол и налить под себя смазку (от страха). На ваших братьях-клоунах работает как лечение."
	panel = "Hulk"
	action_icon_state = "honk_hulk"
	action_background_icon_state = "bg_hulk"
	charge_max = 250
	clothes_req = 0
	range = 2

/obj/effect/proc_holder/spell/aoe_turf/hulk/hulk_honk/cast(list/target,mob/user)
	if (user.incapacitated())
		to_chat(user, "<span class='red'>You can't right now!</span>")
		return
	playsound(user, 'sound/items/airhorn.ogg', CHANNEL_BUZZ)
	for(var/mob/living/carbon/M in ohearers(2))
		if(CLUMSY in M.mutations)
			M.adjustBruteLoss(-10)
			M.adjustToxLoss(-10)
			M.adjustOxyLoss(-10)
			M.AdjustWeakened(-1)
			M.AdjustStunned(-1)
		else
			if(istype(M))
				var/mob/living/carbon/human/H = M
				if(istype(H.l_ear, /obj/item/clothing/ears/earmuffs) || istype(H.r_ear, /obj/item/clothing/ears/earmuffs))
					continue
			M.stuttering += 2
			M.AdjustEarDamage(rand(0, 2))
			M.Weaken(2)
			var /turf/simulated/victim_loc = M.loc
			victim_loc.MakeSlippery(TURF_WET_LUBE, 5 SECONDS)

//Hulk Joke
/obj/effect/proc_holder/spell/aoe_turf/hulk/hulk_joke
	name = "Joke"
	desc = "Пускает большое облако дыма, а так-же лечит вас. Хорошее решение если вам нужно отступить."
	panel = "Hulk"
	action_icon_state = "joke_hulk"
	action_background_icon_state = "bg_hulk"
	charge_max = 350
	clothes_req = 0
	range = 2

/obj/effect/proc_holder/spell/aoe_turf/hulk/hulk_joke/cast(list/targets,mob/user)
	if (user.incapacitated())
		to_chat(user, "<span class='warning'>You can't right now!</span>")
		return

	var/mob/living/simple_animal/hulk/clown_hulk = user
	clown_hulk.adjustBruteLoss(-50)
	clown_hulk.adjustToxLoss(-10)
	clown_hulk.adjustOxyLoss(-10)
	clown_hulk.AdjustWeakened(-1)
	clown_hulk.AdjustStunned(-1)

	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(10,0, user.loc)
	smoke.start()
	playsound(user,pick('sound/spookoween/scary_clown_appear.ogg','sound/spookoween/scary_horn.ogg','sound/spookoween/scary_horn2.ogg','sound/spookoween/scary_horn3.ogg'),CHANNEL_BUZZ, 100)


//Zilla

//Hulk Mill
/obj/effect/proc_holder/spell/aoe_turf/hulk/hulk_mill
	name = "Windmill"
	desc = "Вы начинаете крутить хвостом во все стороны и наносить им урон. Хорошим выбором будет использовать это в узких помещаниях."
	panel = "Hulk"
	action_icon_state = "mill_hulk"
	action_background_icon_state = "bg_hulk"
	charge_max = 200
	clothes_req = 0
	range = 2

/obj/effect/proc_holder/spell/aoe_turf/hulk/hulk_mill/cast(list/targets,mob/user = user)
	if (user.lying || user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	for(var/i in 1 to 45)
		if(user.dir == 1)
			user.setDir(2)
		else if(user.dir == 2)
			user.setDir(4)
		else if(user.dir == 4)
			user.setDir(8)
		else if(user.dir == 8)
			user.setDir(1)

		for(var/mob/living/M in view(2, user) - user - user.contents)
			if(istype(M, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = M
				var/bodypart_name = pick(BODY_ZONE_CHEST,BODY_ZONE_L_ARM,BODY_ZONE_R_ARM,BODY_ZONE_L_LEG,BODY_ZONE_R_LEG,BODY_ZONE_HEAD,BODY_ZONE_TAIL, BODY_ZONE_WING)
				var/obj/item/organ/external/BP = H.bodyparts_by_name[bodypart_name]
				H.apply_damage(2,BRUTE,BP)
			else
				M.apply_damage(2, used_weapon = "Tail")
			playsound(M, 'sound/weapons/tablehit1.ogg', CHANNEL_BUZZ)
			if(prob(3))
				M.Weaken(2)
		sleep(1)

//Harchok
/obj/item/projectile/energy/hulkspit
	name = "spit"
	icon = 'icons/obj/weapons/projectiles.dmi'
	icon_state = "neurotoxin"
	damage = 15
	damage_type = TOX

/obj/item/projectile/energy/hulkspit/on_hit(atom/target, def_zone = BODY_ZONE_CHEST, blocked = 0)
	if(istype(target, /mob/living/carbon))
		var/mob/living/carbon/M = target
		M.Weaken(2)
		M.adjust_fire_stacks(20)
		M.IgniteMob()

/obj/effect/proc_holder/spell/targeted/click/hulk/hulk_spit
	name = "Fire Spit"
	desc = "Вы харкаете во врага зеленой соплей и поджигаете его."
	panel = "Hulk"
	invocation_type = "shout"
	action_icon_state = "harchok_hulk"
	action_background_icon_state = "bg_hulk"
	allowed_type = /atom
	charge_max = 250
	clothes_req = 0
	range = 20

/obj/effect/proc_holder/spell/targeted/click/hulk/hulk_spit/cast(list/targets,mob/user)
	var/target = targets[1]
	if (user.lying || user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return

	var/turf/T = user.loc
	var/turf/U = get_step(user,user.dir) // Get the tile infront of the move, based on their direction
	if(!isturf(U) || !isturf(T))
		return

	var/obj/item/projectile/energy/hulkspit/HS = new /obj/item/projectile/energy/hulkspit(user.loc)
	HS.current = get_turf(user)
	HS.preparePixelProjectile(target, get_turf(target), user)
	HS.fire()
	user.newtonian_move(get_dir(U, T))
	playsound(user, 'sound/magic/fireball.ogg', CHANNEL_BUZZ)

//Laser

/obj/effect/proc_holder/spell/targeted/click/hulk/hulk_lazor
	name = "LazorZ"
	desc = "Вы стреляете из глаз слабеньким лазером. Может помочь, если хитрые СБшники прячутся за стеклами."
	panel = "Hulk"
	invocation_type = "shout"
	action_icon_state = "lazer_hulk"
	action_background_icon_state = "bg_hulk"
	allowed_type = /atom
	charge_max = 70
	clothes_req = 0
	range = 20

/obj/effect/proc_holder/spell/targeted/click/hulk/hulk_lazor/cast(list/targets,mob/user)
	var/target = targets[1]
	if (user.lying || user.incapacitated())
		to_chat(user, "<span class='warning'>You can't right now!</span>")
		return

	var/turf/T = user.loc
	var/turf/U = get_step(user, user.dir) // Get the tile infront of the move, based on their direction
	if(!isturf(U) || !isturf(T))
		return

	var/obj/item/projectile/beam/B = new /obj/item/projectile/beam(user.loc)
	playsound(user, 'sound/weapons/laser.ogg', CHANNEL_BUZZ)
	B.current = get_turf(user)
	B.preparePixelProjectile(target, get_turf(target), user)
	B.fire()
	user.newtonian_move(get_dir(U, T))

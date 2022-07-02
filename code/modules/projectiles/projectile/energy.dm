/obj/item/projectile/energy
	name = "energy"
	icon_state = "spark"
	damage = 0
	damage_type = BURN
	flag = "energy"
	reflectability = REFLECTABILITY_ENERGY

/obj/item/projectile/energy/electrode
	name = "electrode"
	icon_state = "spark"
	color = "#FFFF00"
	nodamage = 1
	weaken = 10 SECONDS
	stutter = 10 SECONDS
	jitter = 40 SECONDS
	hitsound = 'sound/weapons/tase.ogg'
	range = 7
	//Damage will be handled on the MOB side, to prevent window shattering.

/obj/item/projectile/energy/electrode/on_hit(atom/target, blocked = 0)
	. = ..()
	if(!ismob(target) || blocked >= 100) //Fully blocked by mob or collided with dense object - burst into sparks!
		do_sparks(1, 1, src)
	else if(iscarbon(target))
		var/mob/living/carbon/C = target
		SEND_SIGNAL(C, COMSIG_LIVING_MINOR_SHOCK, 33)
		if(HAS_TRAIT(C, TRAIT_HULK))
			C.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		else if(C.status_flags & CANWEAKEN)
			spawn(5)
				C.Jitter(jitter)

/obj/item/projectile/energy/electrode/on_range() //to ensure the bolt sparks when it reaches the end of its range if it didn't hit a target yet
	do_sparks(1, 1, src)
	..()

/obj/item/projectile/energy/declone
	name = "declone"
	icon_state = "declone"
	damage = 20
	damage_type = CLONE
	irradiate = 10
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser

/obj/item/projectile/energy/bolt
	name = "bolt"
	icon_state = "cbbolt"
	damage = 15
	damage_type = TOX
	nodamage = FALSE
	stamina = 60
	eyeblur = 20 SECONDS
	weaken = 2 SECONDS
	slur = 10 SECONDS

/obj/item/projectile/energy/bolt/large
	damage = 20

/obj/item/projectile/energy/shock_revolver
	name = "shock bolt"
	icon_state = "purple_laser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser
	damage = 10 //A worse lasergun
	var/zap_flags = ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE
	var/zap_range = 3
	var/power = 10000

/obj/item/ammo_casing/energy/shock_revolver/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	..()
	var/obj/item/projectile/energy/shock_revolver/P = BB
	spawn(1)
		P.chain = P.Beam(user, icon_state = "purple_lightning", icon = 'icons/effects/effects.dmi', time = 1000, maxdistance = 30)

/obj/item/projectile/energy/shock_revolver/on_hit(atom/target)
	. = ..()
	tesla_zap(src, zap_range, power, zap_flags)
	qdel(src)

/obj/item/projectile/energy/bsg
	name = "orb of pure bluespace energy"
	icon_state = "bluespace"
	impact_effect_type = /obj/effect/temp_visual/bsg_kaboom
	damage = 60
	damage_type = BURN
	range = 9
	weaken = 2 SECONDS //This is going to knock you off your feet
	eyeblur = 10 SECONDS
	speed = 2
	alwayslog = TRUE

/obj/item/ammo_casing/energy/bsg/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	..()
	var/obj/item/projectile/energy/bsg/P = BB
	addtimer(CALLBACK(P, /obj/item/projectile/energy/bsg/.proc/make_chain, P, user), 1)

/obj/item/projectile/energy/bsg/proc/make_chain(obj/item/projectile/P, mob/user)
	P.chain = P.Beam(user, icon_state = "sm_arc_supercharged", icon = 'icons/effects/beam.dmi', time = 10 SECONDS, maxdistance = 30)

/obj/item/projectile/energy/bsg/on_hit(atom/target)
	. = ..()
	kaboom()
	qdel(src)

/obj/item/projectile/energy/bsg/on_range()
	kaboom()
	new /obj/effect/temp_visual/bsg_kaboom(loc)
	..()

/obj/item/projectile/energy/bsg/proc/kaboom()
	playsound(src, 'sound/weapons/bsg_explode.ogg', 75, TRUE)
	for(var/mob/living/M in hearers(7, src)) //No stuning people with thermals through a wall.
		var/floored = FALSE
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/obj/item/gun/energy/bsg/N = locate() in H
			if(N)
				to_chat(H, "<span class='notice'>[N] deploys an energy shield to project you from [src]'s explosion.</span>")
				continue
		var/distance = (1 + get_dist(M, src))
		if(prob(min(400 / distance, 100))) //100% chance to hit with the blast up to 3 tiles, after that chance to hit is 80% at 4 tiles, 66.6% at 5, 57% at 6, and 50% at 7
			if(prob(min(150 / distance, 100)))//100% chance to upgraded to a stun as well at a direct hit, 75% at 1 tile, 50% at 2, 37.5% at 3, 30% at 4, 25% at 5, 21% at 6, and finaly 19% at 7. This is calculated after the first hit however.
				floored = TRUE
			M.apply_damage((rand(15, 30) * (1.1 - distance / 10)), BURN) //reduced by 10% per tile
			add_attack_logs(src, M, "Hit heavily by [src]")
			if(floored)
				to_chat(M, "<span class='userdanger'>You see a flash of briliant blue light as [src] explodes, knocking you to the ground and burning you!</span>")
				M.Weaken(2 SECONDS)
			else
				to_chat(M, "<span class='userdanger'>You see a flash of briliant blue light as [src] explodes, burning you!</span>")
		else
			to_chat(M, "<span class='userdanger'>You feel the heat of the explosion of [src], but the blast mostly misses you.</span>")
			add_attack_logs(src, M, "Hit lightly by [src]")
			M.apply_damage(rand(1, 5), BURN)

/obj/item/projectile/energy/weak_plasma
	name = "plasma bolt"
	icon_state = "plasma_light"
	damage = 12.5
	damage_type = BURN

/obj/item/projectile/energy/charged_plasma
	name = "charged plasma bolt"
	icon_state = "plasma_heavy"
	damage = 45
	damage_type = BURN
	armour_penetration = 10 // It can have a little armor pen, as a treat. Bigger than it looks, energy armor is often low.
	shield_buster = TRUE
	reflectability = REFLECTABILITY_PHYSICAL //I will let eswords block it like a normal projectile, but it's not getting reflected, and eshields will take the hit hard. Carp still can reflect though, screw you.

/obj/item/projectile/energy/detective
	name = "energy revolver shot"
	icon_state = "omnilaser"
	light_color = LIGHT_COLOR_CYAN
	damage = 5
	stamina = 25
	eyeblur = 2 SECONDS

/obj/item/projectile/energy/detective/overcharged
	name = "overcharged shot"
	icon_state = "spark"
	light_color = LIGHT_COLOR_DARKRED
	color = LIGHT_COLOR_DARKRED
	damage = 45
	stamina = 15
	eyeblur = 4 SECONDS

/obj/item/projectile/energy/detective/tracker_warrant_shot
	name = "tracker shot"
	icon_state = "yellow_laser"
	light_color = LIGHT_COLOR_YELLOW
	stamina = 0
	reflectability = REFLECTABILITY_PHYSICAL //No mr cult juggernaught, please don't set me to search!

/obj/item/projectile/energy/detective/tracker_warrant_shot/on_hit(atom/target)
	. = ..()
	if(!ishuman(target))
		no_worky(target)
		return
	start_tracking(target)
	set_warrant(target)

/obj/item/projectile/energy/detective/tracker_warrant_shot/proc/start_tracking(atom/target)
	var/obj/item/gun/energy/detective/D = firer_source_atom
	if(!D)
		no_worky(target)
		return
	if(D.tracking_target_UID)
		no_worky(tracking_already = TRUE)
		return
	D.start_pointing(target.UID())

/obj/item/projectile/energy/detective/tracker_warrant_shot/proc/set_warrant(atom/target)
	var/mob/living/carbon/human/target_to_mark = target
	var/perpname = target_to_mark.get_visible_name(TRUE)
	if(!perpname || perpname == "Unknown")
		no_worky(target, warrant_fail = TRUE)
		return
	var/datum/data/record/R = find_record("name", perpname, GLOB.data_core.security)
	if(!R || (R.fields["criminal"] in list(SEC_RECORD_STATUS_EXECUTE, SEC_RECORD_STATUS_ARREST)))
		no_worky(target, warrant_fail = TRUE)
		return
	set_criminal_status(firer, R, SEC_RECORD_STATUS_SEARCH, "Target tagged by Detective Revolver", "Detective Revolver")

/obj/item/projectile/energy/detective/tracker_warrant_shot/proc/no_worky(atom/target, tracking_already, warrant_fail)
	if(tracking_already)
		to_chat(firer, "<span class='danger'>Weapon Alert: You are already tracking a target!</span>")
		return
	if(warrant_fail)
		to_chat(firer, "<span class='danger'>Weapon Alert: unable to generate warrant on [target]!</span>")
		return
	to_chat(firer, "<span class='danger'>Weapon Alert: unable to track [target]!</span>")

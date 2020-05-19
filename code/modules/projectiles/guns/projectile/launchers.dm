//KEEP IN MIND: These are different from gun/grenadelauncher. These are designed to shoot premade rocket and grenade projectiles, not flashbangs or chemistry casings etc.
//Put handheld rocket launchers here if someone ever decides to make something so hilarious ~Paprika

/obj/item/gun/projectile/revolver/grenadelauncher//this is only used for underbarrel grenade launchers at the moment, but admins can still spawn it if they feel like being assholes
	desc = "A break-operated grenade launcher."
	name = "grenade launcher"
	icon_state = "dshotgun-sawn"
	item_state = "gun"
	mag_type = /obj/item/ammo_box/magazine/internal/grenadelauncher
	fire_sound = 'sound/weapons/grenadelaunch.ogg'
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/gun/projectile/revolver/grenadelauncher/attackby(var/obj/item/A, mob/user, params)
	..()
	if(istype(A, /obj/item/ammo_box) || istype(A, /obj/item/ammo_casing))
		chamber_round()

/obj/item/gun/projectile/revolver/grenadelauncher/multi
	desc = "A revolving 6-shot grenade launcher."
	name = "multi grenade launcher"
	icon_state = "bulldog"
	item_state = "bulldog"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/grenadelauncher/multi

/obj/item/gun/projectile/revolver/grenadelauncher/multi/cyborg
	desc = "A 6-shot grenade launcher."
	icon = 'icons/mecha/mecha_equipment.dmi'
	icon_state = "mecha_grenadelnchr"

/obj/item/gun/projectile/revolver/grenadelauncher/multi/cyborg/attack_self()
	return

/obj/item/gun/projectile/automatic/gyropistol
	name = "gyrojet pistol"
	desc = "A prototype pistol designed to fire self propelled rockets."
	icon_state = "gyropistol"
	fire_sound = 'sound/effects/explosion1.ogg'
	origin_tech = "combat=5"
	mag_type = /obj/item/ammo_box/magazine/m75
	burst_size = 1
	fire_delay = 0
	actions_types = list()

/obj/item/gun/projectile/automatic/gyropistol/isHandgun()
	return 1

/obj/item/gun/projectile/automatic/gyropistol/process_chamber(eject_casing = 0, empty_chamber = 1)
	..()

/obj/item/gun/projectile/automatic/gyropistol/update_icon()
	..()
	icon_state = "[initial(icon_state)][magazine ? "loaded" : ""]"
	return

/obj/item/gun/projectile/automatic/speargun
	name = "kinetic speargun"
	desc = "A weapon favored by carp hunters. Fires specialized spears using kinetic energy."
	icon_state = "speargun"
	item_state = "speargun"
	w_class = WEIGHT_CLASS_BULKY
	origin_tech = "combat=4;engineering=4"
	force = 10
	can_suppress = 0
	mag_type = /obj/item/ammo_box/magazine/internal/speargun
	fire_sound = 'sound/weapons/grenadelaunch.ogg'
	burst_size = 1
	fire_delay = 0
	select = 0
	actions_types = list()

/obj/item/gun/projectile/automatic/speargun/update_icon()
	return

/obj/item/gun/projectile/automatic/speargun/attack_self()
	return

/obj/item/gun/projectile/automatic/speargun/process_chamber(eject_casing = 0, empty_chamber = 1)
	..()

/obj/item/gun/projectile/automatic/speargun/attackby(obj/item/A, mob/user, params)
	var/num_loaded = magazine.attackby(A, user, params, 1)
	if(num_loaded)
		to_chat(user, "<span class='notice'>You load [num_loaded] spear\s into \the [src].</span>")
		update_icon()
		chamber_round()
		
#define PINNED (1<<0)
#define UNPINNED (1<<1)
#define DEPLOYED (1<<2)
#define FIRE_READY (1<<3)
#define SPENT (1<<4)

// M72-LAW(Light Anit-Tank Weapon) -> S72-LRW(Syndicate Light Rocket Weapon)
/obj/item/gun/projectile/S72LRW
	name = "S72LRW-HE"
	desc = "A portable one-shot 66-mm unguided high explosive rocket."
	icon_state = "SLRW-pinned"
	item_state = "launcher"
	w_class = WEIGHT_CLASS_NORMAL
	throw_range = 1
	flags = HANDSLOW
	mag_type = /obj/item/ammo_box/magazine/internal/S72LRW
	slot_flags = 0
	fire_sound = 'sound/weapons/grenadelaunch.ogg'
	recoil = 1
	var/handle_time = 20 // Time needed to deploy and brace the weapon.
	var/brace_slow = 3 // The movement slow penalty for a braced weapon.
	var/weapon_stage = PINNED // The current stage the weapon is in.
	var/stripe_color = rgb(50, 200, 50) // Stripe color. Green
	var/obj/item/SLRWpin/pin = new /obj/item/SLRWpin // Safety pin to pull from the weapon.
	var/deploy_lock = FALSE // Prevents spamming actions on the weapon.
	
/obj/item/gun/projectile/S72LRW/Initialize()
	update_weapon()
	
/obj/item/gun/projectile/S72LRW/rod
	name = "S72LRW-RR"
	desc = "A portable one-shot 66-mm unguided Rod rocket."
	mag_type = /obj/item/ammo_box/magazine/internal/S72LRW/rod
	stripe_color = rgb(240, 240, 240) // White-ish

/obj/item/gun/projectile/S72LRW/frag
	name = "S72LRW-F"
	desc = "A portable one-shot 66-mm unguided fragmentation rocket."
	mag_type = /obj/item/ammo_box/magazine/internal/S72LRW/frag
	stripe_color = rgb(255, 255, 50) // Stripe color. Yellow-ish
	
/obj/item/gun/projectile/S72LRW/emp
	name = "S72LRW-EMP"
	desc = "A portable one-shot 66-mm unguided EMP rocket."
	mag_type = /obj/item/ammo_box/magazine/internal/S72LRW/emp
	stripe_color = rgb(0, 190, 255) // Light blue
	
/obj/item/gun/projectile/S72LRW/incen
	name = "S72LRW-INC"
	desc = "A portable one-shot 66-mm unguided incendiary rocket."
	mag_type = /obj/item/ammo_box/magazine/internal/S72LRW/incen
	stripe_color = rgb(250, 150, 50) //Orange.

/obj/item/gun/projectile/S72LRW/update_icon()
	overlays.Cut()
	var/image/stripe = image(icon = 'icons/obj/guns/projectile.dmi', icon_state = "SLRW-stripe")
	stripe.color = stripe_color
	var/matrix/tran_stripe = matrix()

	if(weapon_stage & (DEPLOYED | FIRE_READY | SPENT))
		tran_stripe.Translate(4, 0)
		stripe.transform = tran_stripe
		if(weapon_stage == FIRE_READY)
			stripe.color = rgb(255,0,0) // Red.
		
	overlays += stripe
	
/obj/item/gun/projectile/S72LRW/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/SLRWpin))
		if(weapon_stage == SPENT)
			to_chat(user, "<span class='warning'>[src] no longer works.</span>")
			return
		var/obj/item/SLRWpin/P = I
		if(!user.is_in_inactive_hand(src))
			to_chat(user, "<span class='warning'>You must be holding [src] to add the safety pin back.</span>")
			return
		if(pin)
			to_chat(user, "<span class='warning'>[src] already has a safety pin.</span>")
			return
		else
			if(!user.is_in_active_hand(P))
				return
			user.drop_item()
			pin = P
			P.forceMove(src)
			if(weapon_stage == UNPINNED)
				playsound(user, 'sound/weapons/empty.ogg', 30, 0)
				to_chat(user, "<span class='notice'>You replace the safety pin.</span>")
			else
				playsound(user, 'sound/weapons/gun_interactions/smg_magout.ogg', 75, 0)
				to_chat(user, "<span class='notice'>You repack the [src] and return the safety pin.</span>")
			weapon_stage = PINNED
			update_weapon()
			user.client.mouse_pointer_icon = initial(user.client.mouse_pointer_icon)
			
/obj/item/gun/projectile/S72LRW/attack_self(mob/user)
	firing_cycle(user)

/obj/item/gun/projectile/S72LRW/proc/update_weapon()
	switch(weapon_stage)
		if(PINNED)
			icon_state = "SLRW-pinned"
			weapon_weight = WEAPON_LIGHT
			w_class = WEIGHT_CLASS_NORMAL
			anchored = FALSE
			slowdown = 0
			
		if(UNPINNED)
			icon_state = "SLRW-unpinned"
			weapon_weight = WEAPON_LIGHT
			w_class = WEIGHT_CLASS_NORMAL
			anchored = FALSE
			slowdown = 0
			
		if(DEPLOYED)
			icon_state = "SLRW-deployed"
			weapon_weight = WEAPON_LIGHT 
			w_class = WEIGHT_CLASS_HUGE
			anchored = FALSE
			slowdown = 0
			
		if(FIRE_READY)
			icon_state = "SLRW-deployed"
			weapon_weight = WEAPON_HEAVY 
			w_class = WEIGHT_CLASS_HUGE
			anchored = TRUE
			slowdown = brace_slow
			
		if(SPENT)
			icon_state = "SLRW-spent"
			weapon_weight = WEAPON_LIGHT
			w_class = WEIGHT_CLASS_NORMAL
			anchored = FALSE
			slowdown = 0
			
	update_icon()

/obj/item/gun/projectile/S72LRW/proc/firing_cycle(mob/user)
	if(deploy_lock)
		return
	
	switch(weapon_stage)
		if(PINNED) // Step up to unpinned.
			if(pin && !user.get_inactive_hand())
				user.put_in_hands(pin)
				pin = null
				playsound(user, 'sound/weapons/emptyclick.ogg', 50, 0)
				to_chat(user, "<span class='notice'>You pull the safety pin out of [src].</span>")
				weapon_stage = UNPINNED
				update_weapon()
			else
				to_chat(user, "<span class='warning'>Your other hand needs to be free to pull the safety pin out.</span>")
				return
			
		if(UNPINNED) // Step up to deployed.
			deploy_lock = TRUE
			if(istype(user.get_inactive_hand(), /obj/item/SLRWpin))
				user.unEquip(user.get_inactive_hand())
				to_chat(user, "<span class='warning'>You drop the safety pin.</span>")
				
			if(user.get_inactive_hand())
				to_chat(user, "<span class='warning'>Your other hand needs to be free to deploy [src].</span>")
			else
				to_chat(user, "<span class='notice'>You begin to deploy [src].</span>")
				if(do_after(user, handle_time, TRUE, target = user))
					weapon_stage = DEPLOYED
					update_weapon()
					playsound(user, 'sound/weapons/gun_interactions/selector.ogg', 75, 0)
					user.visible_message("<span class='notice'>[user] deploys [src].</span>", \
											"<span class='notice'>You deploy [src].</span>")
				else
					to_chat(user, "<span class='warning'>You stop deploying [src].</span>")
			deploy_lock = FALSE
			
		if(DEPLOYED) // Setup up to ready to fire.
			deploy_lock = TRUE
			if(user.get_inactive_hand())
				to_chat(user, "<span class='warning'>Your other hand needs to be free to ready [src].</span>")
			else
				to_chat(user, "<span class='notice'>You brace to fire [src].</span>")
				if(do_after(user, handle_time, TRUE, target = user))
					weapon_stage = FIRE_READY
					update_weapon()
					user.client.mouse_pointer_icon = file("icons/mecha/mecha_mouse.dmi")
					playsound(user, 'sound/weapons/targeton.ogg', 75, 0)
					user.visible_message("<span class='notice'>[user] is ready to fire [src].</span>", \
											"<span class='notice'>[src] is ready to fire.</span>")
				else
					to_chat(user, "<span class='warning'>Your grip is broken deploying the [src].</span>")
			deploy_lock = FALSE
				
		if(FIRE_READY) // Setup back to deployed.
			weapon_stage = DEPLOYED
			update_weapon()
			user.client.mouse_pointer_icon = initial(user.client.mouse_pointer_icon)
			playsound(user, 'sound/weapons/targetoff.ogg', 75, 0)
			user.visible_message("<span class='notice'>[user] lowers [src].</span>", \
									"<span class='notice'>You lower [src].</span>")

		if(SPENT)
			to_chat(user, "<span class='warning'>[src] is depleted.</span>")
			return
			
/obj/item/gun/projectile/S72LRW/dropped(mob/user)
	if(weapon_stage == FIRE_READY)
		weapon_stage = DEPLOYED
		update_weapon()
		user.client.mouse_pointer_icon = initial(user.client.mouse_pointer_icon)
		playsound(user, 'sound/weapons/targetoff.ogg', 75, 0)
		to_chat(user, "<span class='warning'>You drop [src].</span>")

/obj/item/SLRWpin/Initialize()
	name = "SLRW safety pin"
	desc = "A safety pin for a dangerous weapon."
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "SLRW-pin"
	w_class = WEIGHT_CLASS_TINY
	slot_flags = SLOT_EARS
	
/obj/item/SLRWpin/attack_self(mob/user)
	if(istype(user.get_inactive_hand(), /obj/item/gun/projectile/S72LRW))
		var/obj/item/gun/projectile/S72LRW/S = user.get_inactive_hand()
		S.attackby(src, user)
	
/obj/item/gun/projectile/S72LRW/process_fire(atom/target, mob/living/user, message = TRUE, params, zone_override = "")
	switch(weapon_stage)
		if(PINNED, UNPINNED, DEPLOYED )
			to_chat(user, "<span class='warning'>[src] is not ready to fire.</span>")
			return
		if(FIRE_READY)
			..() //Fire weapon.
			weapon_stage = SPENT
			update_weapon()
			user.client.mouse_pointer_icon = initial(user.client.mouse_pointer_icon)
		if(SPENT)
			..() //	Click, click, click
			
/obj/item/gun/projectile/S72LRW/process_chamber(eject_casing = TRUE, empty_chamber = TRUE)
	if(chambered)
		qdel(chambered)
		chambered = null
	..()
	
/obj/item/gun/projectile/S72LRW/can_shoot() // Over ride parent checks on firing.
	return TRUE
	
/obj/item/gun/projectile/S72LRW/Destroy()
	if(pin)
		qdel(pin)
		pin = null
	if(chambered)
		qdel(chambered)
		chambered = null
	if(magazine)
		qdel(magazine)
		magazine = null
	..()

#undef PINNED
#undef UNPINNED
#undef DEPLOYED
#undef FIRE_READY
#undef SPENT

/obj/item/SLRWdud
	name = "dud rocket"
	desc = "A rocket round that failed to explode."
	icon = 'icons/obj/grenade.dmi'
	icon_state = "rocket"
	w_class = WEIGHT_CLASS_TINY
	slot_flags = 0

/obj/item/projectile/a66mm
	name ="66mm HE rocket"
	desc = "A rocket with a high explosive payload."
	icon = 'icons/obj/grenade.dmi'
	icon_state = "SLRW-rocket"
	alwayslog = TRUE
	damage = 70
	flag = "bullet"
	hitsound = 'sound/weapons/effects/ric1.ogg'
	hitsound_wall = 'sound/weapons/effects/ric2.ogg'
	pass_flags = 0
	dismemberment = 50
	forcedodge = TRUE // Rockets don't use forcedodge anymore, but keep it anyways.
	ricochet_chance = 0
	range = 50
	var/ex_range = 3 // Range of area of effect of explosion or playload.
	var/list/rocket_stop = null // A list of types that will stop the rocket's travel.
							
/obj/item/projectile/a66mm/Initialize()
	..()
	rocket_stop = list()
	rocket_stop += /mob/living
	rocket_stop += /obj/mecha
	rocket_stop += /turf/unsimulated/wall
	rocket_stop += /turf/simulated/wall
	rocket_stop += /obj/machinery/door/poddoor
	rocket_stop += /obj/machinery/porta_turret
	rocket_stop += /obj/machinery/door/airlock/vault
	rocket_stop += /obj/machinery/door/airlock/highsecurity
	rocket_stop += /obj/structure/shuttle
	rocket_stop += /obj/structure/girder
	rocket_stop += /obj/structure/window/plasmabasic
	rocket_stop += /obj/structure/window/full/plasmabasic
	rocket_stop += /obj/structure/window/plasmareinforced
	rocket_stop += /obj/structure/window/full/plasmareinforced
	
/obj/item/projectile/a66mm/fire()
	var/spd_multi = 1 // Speed multiplayer for rocket travel.
	var/xd = loc.x // X location of next tile to move to.
	var/yd = loc.y // Y location of next tile to move to.
	transform = turn(transform, Angle)
	
	while(loc)
		xd += sin(Angle)*spd_multi
		yd += cos(Angle)*spd_multi
		if(round(xd, 1) <= 0 || round(xd,1) >= world.maxx)
			on_range()
			break
		if(round(yd, 1) <= 0 || round(yd, 1) >= world.maxy)
			on_range()
			break
		new /obj/effect/temp_visual/smoke_puff(loc)
		var/turf/next_t = locate(round(xd, 1), round(yd, 1), z)
		if(prehit(next_t))
			loc = next_t
			Range()
		else
			break
		sleep(max(1, speed))
		
/obj/item/projectile/a66mm/prehit(turf/target)
	// Check for anything that stops the rocket.
	for(var/i in rocket_stop)
		if(istype(target, i))
			on_hit(target)
			qdel(src)
			return FALSE
		for(var/atom/j in target.contents)
			if(istype(j, i) && j.density)
				on_hit(target)
				qdel(src)
				return FALSE

	// Anything that didn't stop the rocket, destroy it.
	var/fx_hit_flag = FALSE
	for(var/obj/j in target.contents)
		if(src == j)
			continue
		var/skip_obj = FALSE
		for(var/i in rocket_stop)
			if(istype(j, i))
				skip_obj = TRUE
				break
		if(skip_obj)
			continue
		if(istype(j, /obj/machinery/door))
			j.take_damage(j.obj_integrity)
			fx_hit_flag = TRUE
		if(istype(j, /obj/machinery/door/airlock/multi_tile))
			qdel(j)
			fx_hit_flag = TRUE
		else if(j.density)
			j.take_damage(j.obj_integrity)
			fx_hit_flag = TRUE
			
	if(fx_hit_flag)
		sfx_hit(50, 33)
		ffx_hit(target)

	// Destroy structures or anything that was spawned from removal.
	for(var/obj/j in target.contents)
		var/skip_obj = FALSE
		for(var/i in rocket_stop)
			if(istype(j, i))
				skip_obj = TRUE
				break
		if(skip_obj)
			continue
		if(istype(j, /obj/machinery/constructable_frame))
			qdel(j)
		else if(istype(j, /obj/structure/grille/broken))
			continue
		else if(istype(j, /obj/structure/table_frame))
			continue
		else if(istype(j, /obj/structure))
			if(j.density)
				qdel(j)

	return TRUE
	
/obj/item/projectile/a66mm/on_hit(turf/target, blocked = 0)
	if(locate(/obj/mecha) in target.contents)
		for(var/obj/mecha/M in target.contents)
			if(!is_fellow_antag(M) && M.density)
				M.take_damage(damage, BRUTE)
				break
	else if(locate(/mob/living) in target.contents)
		for(var/mob/living/L in target.contents)
			if(!is_fellow_antag(L) && L.density)
				L.apply_damage(damage, BRUTE)
				L.check_projectile_dismemberment(src, "chest")
				break
	else
		if(istype(target, /turf/simulated/wall/r_wall))
			var/turf/simulated/wall/r_wall/W = target
			W.add_dent(WALL_DENT_HIT)
		else if(istype(target, /turf/simulated/wall))
			var/turf/simulated/wall/W = target
			W.break_wall()
		else if(locate(/obj/structure/girder) in target.contents)
			var/obj/structure/girder/G = locate(/obj/structure/girder) in target.contents
			G.deconstruct(FALSE)

		target = get_turf(src)

	if(friendly_fire_dud(target, ex_range))
		return FALSE

	explosion(target, -1, -1, ex_range + 1, cause = "[type] fired by [key_name(firer)]")
	var/datum/effect_system/explosion/smoke/E = new/datum/effect_system/explosion/smoke()
	E.set_up(target)
	E.start()
	return TRUE

/obj/item/projectile/a66mm/on_range()
	on_hit(get_turf(src))
	..()

/obj/item/projectile/a66mm/rod
	name ="66mm Rod rocket"
	desc = "A rocket designed to punch through almost anything."
	icon_state = "SLRW-rocket"
	alwayslog = FALSE
	rocket_stop = null
	ex_range = 1

/obj/item/projectile/a66mm/rod/Initialize()
	..()
	rocket_stop -= /turf/simulated/wall
	rocket_stop -= /obj/structure/girder
	rocket_stop -= /obj/machinery/door/airlock/highsecurity
	rocket_stop += /turf/simulated/wall/r_wall

/obj/item/projectile/a66mm/rod/prehit(turf/target)
	if(!..())
		return FALSE
	if(istype(target, /turf/simulated/wall))
		sfx_hit(60, 40)
		target.ChangeTurf(/turf/simulated/floor/plating)
		ffx_hit(target)
	return TRUE

/obj/item/projectile/a66mm/rod/on_hit(turf/target, blocked = 0)
	if(locate(/obj/mecha) in target.contents)
		for(var/obj/mecha/M in target.contents)
			if(!is_fellow_antag(M) && M.density)
				M.take_damage(damage, BRUTE)
				break
	else if(locate(/mob/living) in target.contents)
		for(var/mob/living/L in target.contents)
			if(!is_fellow_antag(L) && L.density)
				L.apply_damage(damage, BRUTE)
				L.check_projectile_dismemberment(src, "chest")
				break

	if(friendly_fire_dud(target, ex_range))
		return FALSE

	for(var/turf/T in range(ex_range, target))
		ffx_hit(T)

	explosion(target, 1, -1, ex_range + 1, flame_range = ex_range + 1, cause = "[type] fired by [key_name(firer)]")
	var/datum/effect_system/explosion/smoke/E = new/datum/effect_system/explosion/smoke()
	E.set_up(target)
	E.start()
	return TRUE

/obj/item/projectile/a66mm/frag
	name ="66mm Frag rocket"
	desc = "A rocket designed to maim soft targets in a wide area."
	icon_state = "SLRW-rocket"
	ex_range = 3

/obj/item/projectile/a66mm/frag/on_hit(turf/target)
	if(locate(/mob/living) in target.contents)
		for(var/mob/living/L in target.contents)
			if(!is_fellow_antag(L) && L.density)
				L.apply_damage(damage, BRUTE)
				L.check_projectile_dismemberment(src, "chest")
				break
	else
		target = get_turf(src)

	if(friendly_fire_dud(target, ex_range))
		return FALSE

	for(var/mob/living/M in view(ex_range, target))
		if(istype(M, /mob/living/carbon))
			var/mob/living/carbon/C = M
			if(!C.check_eye_prot())
				C.EyeBlurry(10)
			if(C.check_ear_prot())
				C.AdjustEarDamage(5, 20)
			var/obj/item/embedded/S = new /obj/item/embedded/shrapnel
			C.hitby(S, skipcatch = TRUE)
			S.throwforce = 1
			S.throw_speed = 1
			C.bleed(25)
			to_chat(M, "<span class='warning'>You're hit by shrapnel!</span>")
		else if(istype(M, /mob/living/silicon))
			to_chat(M, "<span class='warning'>Shrapnel bounces off you!</span>")
		else
			to_chat(M, "<span class='warning'>Shrapnel misses you!</span>")

	exsfx_hit(ex_range + 4, ex_range + 10, 'sound/effects/explosion1.ogg')
	for(var/turf/T in range(ex_range, target))
		var/dist = hypotenuse(T.x, T.y, target.x, target.y)
		if(dist <= ex_range)
			ffx_hit(T)

	var/datum/effect_system/explosion/smoke/E = new/datum/effect_system/explosion/smoke()
	E.set_up(target)
	E.start()

/obj/item/projectile/a66mm/emp
	name ="66mm EMP rocket"
	desc = "A rocket designed to EMP targets in a wide area."
	icon_state = "SLRW-rocket"
	ex_range = 4

/obj/item/projectile/a66mm/emp/on_hit(turf/target)
	if(locate(/obj/mecha) in target.contents)
		for(var/obj/mecha/M in target.contents)
			if(!is_fellow_antag(M) && M.density)
				M.take_damage(damage, BRUTE)
				break
	else if(locate(/mob/living) in target.contents)
		for(var/mob/living/L in target.contents)
			if(!is_fellow_antag(L) && L.density)
				L.apply_damage(damage, BRUTE)
				L.check_projectile_dismemberment(src, "chest")
				break
	else
		target = src

	if(friendly_fire_dud(target, ex_range))
		return FALSE

	empulse(target, -1, ex_range, TRUE, cause = "[type] fired by [key_name(firer)]")
	new/obj/effect/temp_visual/emp/pulse(target)
	exsfx_hit(ex_range + 4, ex_range + 10, 'sound/effects/empulse.ogg')
	ffx_hit(target)

/obj/item/projectile/a66mm/incen
	name ="66mm Incendiary rocket"
	desc = "A rocket designed to ignite targets in a wide area."
	icon_state = "SLRW-rocket"
	ex_range = 3
	var/list/fire_stop = null // List of types that would stop the spread of a fire ball.

/obj/item/projectile/a66mm/incen/Initialize()
	..()
	fire_stop = list() // A list of turfs and objects that stop fire.
	fire_stop += /turf/unsimulated/wall // No fire inside of walls.
	fire_stop += /turf/simulated/wall // No fire inside of walls.
	fire_stop += /turf/space // No fire in space.
	fire_stop += /obj/structure/shuttle
	fire_stop += /obj/structure/window/plasmabasic
	fire_stop += /obj/structure/window/full/plasmabasic
	fire_stop += /obj/structure/window/plasmareinforced
	fire_stop += /obj/structure/window/full/plasmareinforced

/obj/item/projectile/a66mm/incen/on_hit(turf/target)
	// If the turf has a mob in it, we "hit" the mob with rocket damage.
	// The rocket also explodes in that tile.
	if(locate(/mob/living) in target.contents)
		for(var/mob/living/L in target.contents)
			if(!is_fellow_antag(L) && L.density)
				L.apply_damage(damage, BRUTE)
				L.check_projectile_dismemberment(src, "chest")
				break
	else
		// We hit something too hard for the rocket.
		// Explode infront of what was hit.
		target = get_turf(src)

	// If the rocket explodes in a tile that would stop fire, e.g. space,
	// then return, since other turfs wont catch fire.
	for(var/i in fire_stop)
		if(istype(target, i))
			return FALSE

		if(locate(i) in target.contents)
			return FALSE

	if(friendly_fire_dud(target, ex_range)) // FF check.
		return FALSE

	// Make a large fire ball that can be stopped by turfs/objects.
	// We'll "walk" from our target tile to a tile in our range.
	// If walker makes it with out being stopped then set that turf on fire.
	for(var/turf/T in range(ex_range, target))
		var/set_fire = TRUE // Flag for setting a tile on fire.
		var/turf/walker = get_turf(target) // Start at the target turf.
		var/dist = hypotenuse(T.x, T.y, walker.x, walker.y)
		
		if(dist > ex_range) // Helps turn square like explosions into round ones.
			continue

		// Keep walking until we reach our range turf or if we cross a tile that stops fire.
		while(walker != T && set_fire)
			walker = get_step_towards(walker, T) // Walk towards the range turf.
			// Stop if we cross something that stops fire.
			for(var/i in fire_stop)
				if(istype(walker, i))
					set_fire = FALSE
					break
				if(locate(i) in walker.contents)
					set_fire = FALSE
					break
			if(!set_fire) // Loops in loops break.
				break
			
			// Check walkers contents.
			for(var/obj/O in walker.contents)
				// Not sure how to handle directional windows, just destroy them.
				if(istype(O, /obj/structure/window))
					var/obj/structure/window/W = O
					W.take_damage(W.obj_integrity)
				// If we can destroy windows, destroy grilles too.
				if(istype(O, /obj/structure/grille))
					var/obj/structure/window/W = O
					W.take_damage(W.obj_integrity)
				// Fire is stopped by closed doors, but not open ones.
				if(istype(O, /obj/machinery/door))
					if(O.density)
						set_fire = FALSE
						break

		if(set_fire)
			new /obj/effect/hotspot(T) // Set tile on fire.
			ffx_hit(T) // Fire effects on tile. Break and burn.
			for(var/mob/living/L in T)
				L.EyeBlurry(10) // Stun and blind suck, so just blur eyes for now.

	exsfx_hit(ex_range + 4, ex_range + 10, 'sound/effects/explosion1.ogg') // Explosion sound effects.
	var/datum/effect_system/explosion/smoke/E = new/datum/effect_system/explosion/smoke()
	E.set_up(target)
	E.start()
	return TRUE

/obj/item/ammo_casing/rocket/a66mm
	name = "66mm HE rocket shell"
	desc = "A high explosive rocket designed to be fired from a launcher."
	icon_state = "rocketshell"
	projectile_type = /obj/item/projectile/a66mm
	caliber = "rocket"
	
/obj/item/ammo_casing/rocket/a66mm/rod
	name = "66mm Rod Round rocket shell"
	desc = "A rod rocket designed to be fired from a launcher."
	icon_state = "rocketshell"
	projectile_type = /obj/item/projectile/a66mm/rod
	caliber = "rocket"
	
/obj/item/ammo_casing/rocket/a66mm/frag
	name = "66mm Fragmentation rocket shell"
	desc = "A fragmentation rocket designed to be fired from a launcher."
	icon_state = "rocketshell"
	projectile_type = /obj/item/projectile/a66mm/frag
	caliber = "rocket"
	
/obj/item/ammo_casing/rocket/a66mm/emp
	name = "66mm EMP rocket shell"
	desc = "A emp rocket designed to be fired from a launcher."
	icon_state = "rocketshell"
	projectile_type = /obj/item/projectile/a66mm/emp
	caliber = "rocket"
	
/obj/item/ammo_casing/rocket/a66mm/incen
	name = "66mm Incendiary rocket shell"
	desc = "A incendiary rocket designed to be fired from a launcher."
	icon_state = "rocketshell"
	projectile_type = /obj/item/projectile/a66mm/incen
	caliber = "rocket"
	
/obj/item/ammo_box/magazine/internal/S72LRW
	name = "rocket launcher internal magazine"
	ammo_type = /obj/item/ammo_casing/rocket/a66mm
	caliber = "66mm"
	max_ammo = 1
	
/obj/item/ammo_box/magazine/internal/S72LRW/rod
	ammo_type = /obj/item/ammo_casing/rocket/a66mm/rod
	
/obj/item/ammo_box/magazine/internal/S72LRW/frag
	ammo_type = /obj/item/ammo_casing/rocket/a66mm/frag
	
/obj/item/ammo_box/magazine/internal/S72LRW/emp
	ammo_type = /obj/item/ammo_casing/rocket/a66mm/emp
	
/obj/item/ammo_box/magazine/internal/S72LRW/incen
	ammo_type = /obj/item/ammo_casing/rocket/a66mm/incen

/obj/item/projectile/a66mm/proc/ffx_hit(atom/A)
	if(!A)
		return
	var/turf/T = get_turf(A)
	if(isfloorturf(T))
		var/turf/simulated/floor/F = T
		F.break_tile()
		F.burn_tile()
		
/obj/item/projectile/a66mm/proc/friendly_fire_dud(turf/target, in_range)
	var/atom/friendly_hit = friendly_fire_area(target, in_range)
	if(friendly_hit)
		new /obj/item/SLRWdud(get_turf(src))
		visible_message("<span class='warning'>[src] duds, because of friendly fire, on [friendly_hit]</span>")
		playsound(src, 'sound/weapons/sonic_jackhammer.ogg', 50, 1)
		return friendly_hit
	return FALSE
	
/obj/item/projectile/a66mm/proc/friendly_fire_area(turf/target, in_range)
	for(var/atom/A in range(in_range, target))
		if(istype(A, /obj/machinery/nuclearbomb) || is_fellow_antag(A))
			return A
	return FALSE
	
/obj/item/projectile/a66mm/proc/is_fellow_antag(atom/target)
	if(istype(target, /mob/living))
		var/mob/living/L = target
		if(L.mind && (L.mind in SSticker.mode.syndicates))
			return L
	else if(istype(target, /obj/mecha))
		var/obj/mecha/M = target
		if(M.occupant)
			return is_fellow_antag(M.occupant)
	else
		return FALSE
		
/obj/item/projectile/a66mm/proc/exsfx_hit(near_range=1, far_range=1, in_sfx)
	for(var/mob/living/L in range(far_range, src))
		if(L && L.client)
			if(in_sfx && get_dist(src, L) <= near_range)
				playsound(L, in_sfx, 75, 0)
			else
				playsound(L, 'sound/effects/explosionfar.ogg', 100, 0)
				
/obj/item/projectile/a66mm/proc/sfx_hit(hit_vol, hit_prob)
	if(!prob(hit_prob))
		return
	
	var/sfx = pick('sound/effects/bang.ogg', 'sound/effects/clang.ogg')
	playsound(src, sfx, hit_vol, 1)

/obj/effect/temp_visual/smoke_puff
	opacity = FALSE
	icon_state = "smoke"
	duration = 20 //in deciseconds

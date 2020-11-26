/obj/item/twohanded/kinetic_crusher/cursed
	name = "cursed-kinetic crusher"
	desc = "This kinetic crusher... it's alive?"
	icon = 'icons/hispania/obj/kinetic_crusherc.dmi'
	icon_state = "cursed_crasher"
	item_state = "crusher0"
	lefthand_file = 'icons/hispania/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/hispania/mob/inhands/items_righthand.dmi'
	charge_time = 5
	force_wielded = 30
	detonation_damage = 90
	backstab_bonus = 80
	flags = NODROP

/obj/item/twohanded/kinetic_crusher/afterattack(atom/target, mob/living/user, proximity_flag, clickparams)
	. = ..()
	if(!wielded)
		return
	if(!proximity_flag && charged)
		var/turf/proj_turf = user.loc
		if(!isturf(proj_turf))
			return
		var/obj/item/projectile/destabilizer/cursed/D = new /obj/item/projectile/destabilizer/cursed(proj_turf)
		for(var/t in trophies)
			var/obj/item/crusher_trophy/T = t
			T.on_projectile_fire(D, user)
		D.preparePixelProjectile(target, get_turf(target), user, clickparams)
		D.firer = user
		D.hammer_synced = src
		playsound(user, 'sound/weapons/plasma_cutter.ogg', 100, 1)
		D.fire()
		charged = FALSE
		update_icon()
		addtimer(CALLBACK(src, .proc/Recharge), charge_time)
		return
	if(proximity_flag && isliving(target))
		var/mob/living/L = target
		var/datum/status_effect/crusher_mark/CM = L.has_status_effect(STATUS_EFFECT_CRUSHERMARK)
		if(!CM || CM.hammer_synced != src || !L.remove_status_effect(STATUS_EFFECT_CRUSHERMARK))
			return
		var/datum/status_effect/crusher_damage/C = L.has_status_effect(STATUS_EFFECT_CRUSHERDAMAGETRACKING)
		if(!C)
			C = L.apply_status_effect(STATUS_EFFECT_CRUSHERDAMAGETRACKING)
		var/target_health = L.health
		for(var/t in trophies)
			var/obj/item/crusher_trophy/T = t
			T.on_mark_detonation(target, user)
		if(!QDELETED(L))
			if(!QDELETED(C))
				C.total_damage += target_health - L.health //we did some damage, but let's not assume how much we did
			new /obj/effect/temp_visual/kinetic_blast(get_turf(L))
			var/backstab_dir = get_dir(user, L)
			var/def_check = L.getarmor(type = "bomb")
			if((user.dir & backstab_dir) && (L.dir & backstab_dir))
				if(!QDELETED(C))
					C.total_damage += detonation_damage + backstab_bonus //cheat a little and add the total before killing it, so certain mobs don't have much lower chances of giving an item
				L.apply_damage(detonation_damage + backstab_bonus, BRUTE, blocked = def_check)
				playsound(user, 'sound/weapons/kenetic_accel.ogg', 100, 1) //Seriously who spelled it wrong
			else
				if(!QDELETED(C))
					C.total_damage += detonation_damage
				L.apply_damage(detonation_damage, BRUTE, blocked = def_check)

/obj/item/projectile/destabilizer/cursed
	name = "cursed force"
	icon = 'icons/hispania/obj/projectiles.dmi'
	icon_state = "cursed_force"


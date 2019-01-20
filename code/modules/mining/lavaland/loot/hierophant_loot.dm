/obj/item/hierophant_staff
	name = "Hierophant's staff"
	desc = "A large club with intense magic power infused into it."
	icon_state = "hierophant_staff"
	item_state = "hierophant_staff"
	icon = 'icons/obj/guns/magic.dmi'
	slot_flags = SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	force = 20
	hitsound = "swing_hit"
	//hitsound = 'sound/weapons/sonic_jackhammer.ogg'
	actions_types = list(/datum/action/item_action/vortex_recall, /datum/action/item_action/toggle_unfriendly_fire)
	var/cooldown_time = 20 //how long the cooldown between non-melee ranged attacks is
	var/chaser_cooldown = 101 //how long the cooldown between firing chasers at mobs is
	var/chaser_timer = 0 //what our current chaser cooldown is
	var/timer = 0 //what our current cooldown is
	var/blast_range = 3 //how long the cardinal blast's walls are
	var/obj/effect/hierophant/rune //the associated rune we teleport to
	var/teleporting = FALSE //if we ARE teleporting
	var/friendly_fire_check = FALSE //if the blasts we make will consider our faction against the faction of hit targets

/obj/item/hierophant_staff/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	..()
	var/turf/T = get_turf(target)
	if(!T || timer > world.time)
		return
	timer = world.time + CLICK_CD_MELEE //by default, melee attacks only cause melee blasts, and have an accordingly short cooldown
	if(proximity_flag)
		spawn(0)
			aoe_burst(T, user)
		add_attack_logs(user, target, "Fired 3x3 blast at [src]")
	else
		if(ismineralturf(target) && get_dist(user, target) < 6) //target is minerals, we can hit it(even if we can't see it)
			spawn(0)
				cardinal_blasts(T, user)
			timer = world.time + cooldown_time
		else if(target in view(5, get_turf(user))) //if the target is in view, hit it
			timer = world.time + cooldown_time
			if(isliving(target) && chaser_timer <= world.time) //living and chasers off cooldown? fire one!
				chaser_timer = world.time + chaser_cooldown
				new /obj/effect/temp_visual/hierophant/chaser(get_turf(user), user, target, 1.5, friendly_fire_check)
				add_attack_logs(user, target, "Fired a chaser at [src]")
			else
				spawn(0)
					cardinal_blasts(T, user) //otherwise, just do cardinal blast
				add_attack_logs(user, target, "Fired cardinal blast at [src]")
		else
			to_chat(user, "<span class='warning'>That target is out of range!</span>") //too far away

/obj/item/hierophant_staff/ui_action_click(mob/user, actiontype)
	if(actiontype == /datum/action/item_action/toggle_unfriendly_fire) //toggle friendly fire...
		friendly_fire_check = !friendly_fire_check
		to_chat(user, "<span class='warning'>You toggle friendly fire [friendly_fire_check ? "off":"on"]!</span>")
		return
	if(user.is_in_active_hand(src) && user.is_in_inactive_hand(src)) //you need to hold the staff to teleport
		to_chat(user, "<span class='warning'>You need to hold the staff in your hands to [rune ? "teleport with it" : "create a rune"]!</span>")
		return
	if(!rune)
		if(isturf(user.loc))
			user.visible_message("<span class='hierophant_warning'>[user] holds [src] carefully in front of [user.p_them()], moving it in a strange pattern...</span>", \
			"<span class='notice'>You start creating a hierophant rune to teleport to...</span>")
			timer = world.time + 51
			if(do_after(user, 50, target = user))
				var/turf/T = get_turf(user)
				playsound(T,'sound/magic/blind.ogg', 200, 1, -4)
				new /obj/effect/temp_visual/hierophant/telegraph/teleport(T, user)
				var/obj/effect/hierophant/H = new/obj/effect/hierophant(T)
				rune = H
				user.update_action_buttons_icon()
				user.visible_message("<span class='hierophant_warning'>[user] creates a strange rune beneath [user.p_them()]!</span>", \
				"<span class='hierophant'>You create a hierophant rune, which you can teleport yourself and any allies to at any time!</span>\n\
				<span class='notice'>You can remove the rune to place a new one by striking it with the staff.</span>")
			else
				timer = world.time
		else
			to_chat(user, "<span class='warning'>You need to be on solid ground to produce a rune!</span>")
		return
	if(get_dist(user, rune) <= 2) //rune too close abort
		to_chat(user, "<span class='warning'>You are too close to the rune to teleport to it!</span>")
		return
	if(is_blocked_turf(get_turf(rune)))
		to_chat(user, "<span class='warning'>The rune is blocked by something, preventing teleportation!</span>")
		return
	teleporting = TRUE //start channel
	user.update_action_buttons_icon()
	user.visible_message("<span class='hierophant_warning'>[user] starts to glow faintly...</span>")
	timer = world.time + 50
	if(do_after(user, 40, target = user) && rune)
		var/turf/T = get_turf(rune)
		var/turf/source = get_turf(user)
		if(is_blocked_turf(T))
			teleporting = FALSE
			to_chat(user, "<span class='warning'>The rune is blocked by something, preventing teleportation!</span>")
			user.update_action_buttons_icon()
			return
		new /obj/effect/temp_visual/hierophant/telegraph(T, user)
		new /obj/effect/temp_visual/hierophant/telegraph(source, user)
		playsound(T,'sound/magic/blink.ogg', 200, 1)
		//playsound(T,'sound/magic/wand_teleport.ogg', 200, 1)
		playsound(source,'sound/magic/blink.ogg', 200, 1)
		//playsound(source,'sound/machines/AirlockOpen.ogg', 200, 1)
		if(!do_after(user, 3, target = user) || !rune) //no walking away shitlord
			teleporting = FALSE
			if(user)
				user.update_action_buttons_icon()
			return
		if(is_blocked_turf(T))
			teleporting = FALSE
			to_chat(user, "<span class='warning'>The rune is blocked by something, preventing teleportation!</span>")
			user.update_action_buttons_icon()
			return
		add_attack_logs(user, rune, "Teleported self from ([source.x],[source.y],[source.z]) to ([T.x],[T.y],[T.z])")
		new /obj/effect/temp_visual/hierophant/telegraph/teleport(T, user)
		new /obj/effect/temp_visual/hierophant/telegraph/teleport(source, user)
		for(var/t in RANGE_TURFS(1, T))
			var/obj/effect/temp_visual/hierophant/blast/B = new /obj/effect/temp_visual/hierophant/blast(t, user, TRUE) //blasts produced will not hurt allies
			B.damage = 30
		for(var/t in RANGE_TURFS(1, source))
			var/obj/effect/temp_visual/hierophant/blast/B = new /obj/effect/temp_visual/hierophant/blast(t, user, TRUE) //but absolutely will hurt enemies
			B.damage = 30
		for(var/mob/living/L in range(1, source))
			spawn(0)
				teleport_mob(source, L, T, user) //regardless, take all mobs near us along
		sleep(6) //at this point the blasts detonate
	else
		timer = world.time
	teleporting = FALSE
	if(user)
		user.update_action_buttons_icon()

/obj/item/hierophant_staff/proc/teleport_mob(turf/source, mob/M, turf/target, mob/user)
	var/turf/turf_to_teleport_to = get_step(target, get_dir(source, M)) //get position relative to caster
	if(!turf_to_teleport_to || is_blocked_turf(turf_to_teleport_to))
		return
	animate(M, alpha = 0, time = 2, easing = EASE_OUT) //fade out
	sleep(1)
	if(!M)
		return
	M.visible_message("<span class='hierophant_warning'>[M] fades out!</span>")
	sleep(2)
	if(!M)
		return
	M.forceMove(turf_to_teleport_to)
	sleep(1)
	if(!M)
		return
	animate(M, alpha = 255, time = 2, easing = EASE_IN) //fade IN
	sleep(1)
	if(!M)
		return
	M.visible_message("<span class='hierophant_warning'>[M] fades in!</span>")
	if(user != M)
		add_attack_logs(user, M, "Teleported from ([source.x],[source.y],[source.z])")

/obj/item/hierophant_staff/proc/cardinal_blasts(turf/T, mob/living/user) //fire cardinal cross blasts with a delay
	if(!T)
		return
	new /obj/effect/temp_visual/hierophant/telegraph/cardinal(T, user)
	playsound(T,'sound/magic/blink.ogg', 200, 1)
	//playsound(T,'sound/effects/bin_close.ogg', 200, 1)
	sleep(2)
	new /obj/effect/temp_visual/hierophant/blast(T, user, friendly_fire_check)
	for(var/d in cardinal)
		spawn(0)
			blast_wall(T, d, user)

/obj/item/hierophant_staff/proc/blast_wall(turf/T, dir, mob/living/user) //make a wall of blasts blast_range tiles long
	if(!T)
		return
	var/range = blast_range
	var/turf/previousturf = T
	var/turf/J = get_step(previousturf, dir)
	for(var/i in 1 to range)
		if(!J)
			return
		new /obj/effect/temp_visual/hierophant/blast(J, user, friendly_fire_check)
		previousturf = J
		J = get_step(previousturf, dir)

/obj/item/hierophant_staff/proc/aoe_burst(turf/T, mob/living/user) //make a 3x3 blast around a target
	if(!T)
		return
	new /obj/effect/temp_visual/hierophant/telegraph(T, user)
	playsound(T,'sound/magic/blink.ogg', 200, 1)
	//playsound(T,'sound/effects/bin_close.ogg', 200, 1)
	sleep(2)
	for(var/t in RANGE_TURFS(1, T))
		new /obj/effect/temp_visual/hierophant/blast(t, user, friendly_fire_check)

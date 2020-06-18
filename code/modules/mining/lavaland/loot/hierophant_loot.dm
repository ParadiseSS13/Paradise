#define HIEROPHANT_CLUB_CARDINAL_DAMAGE 30

/obj/item/hierophant_club
	name = "hierophant club"
	desc = "The strange technology of this large club allows various nigh-magical feats. It used to beat you, but now you can set the beat."
	icon_state = "hierophant_club_ready_beacon"
	item_state = "hierophant_club_ready_beacon"
	icon = 'icons/obj/lavaland/artefacts.dmi'
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	slot_flags = SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	force = 15
	attack_verb = list("clubbed", "beat", "pummeled")
	hitsound = 'sound/weapons/sonic_jackhammer.ogg'
	actions_types = list(/datum/action/item_action/vortex_recall, /datum/action/item_action/toggle_unfriendly_fire)
	var/cooldown_time = 20 //how long the cooldown between non-melee ranged attacks is
	var/chaser_cooldown = 81 //how long the cooldown between firing chasers at mobs is
	var/chaser_timer = 0 //what our current chaser cooldown is
	var/chaser_speed = 0.8 //how fast our chasers are
	var/timer = 0 //what our current cooldown is
	var/blast_range = 13 //how long the cardinal blast's walls are
	var/obj/effect/hierophant/beacon //the associated beacon we teleport to
	var/teleporting = FALSE //if we ARE teleporting
	var/friendly_fire_check = FALSE //if the blasts we make will consider our faction against the faction of hit targets

/obj/item/hierophant_club/examine(mob/user)
	. = ..()
	. += "<span class='hierophant_warning'>The[beacon ? " beacon is not currently":"re is a beacon"] attached.</span>"

/obj/item/hierophant_club/suicide_act(mob/living/user)
	atom_say("Xverwpsgexmrk...")
	user.visible_message("<span class='suicide'>[user] holds [src] into the air! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	new/obj/effect/temp_visual/hierophant/telegraph(get_turf(user))
	playsound(user,'sound/machines/airlock_open.ogg', 75, TRUE)
	user.visible_message("<span class='hierophant_warning'>[user] fades out, leaving [user.p_their()] belongings behind!</span>")
	for(var/obj/item/I in user)
		if(I != src)
			user.unEquip(I)
	for(var/turf/T in RANGE_TURFS(1, user))
		var/obj/effect/temp_visual/hierophant/blast/B = new(T, user, TRUE)
		B.damage = 0
	user.unEquip(src) //Drop us last, so it goes on top of their stuff
	qdel(user)
	return OBLITERATION


/obj/item/hierophant_club/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	..()
	var/turf/T = get_turf(target)
	if(!T || timer > world.time)
		return
	calculate_anger_mod(user)
	timer = world.time + CLICK_CD_MELEE //by default, melee attacks only cause melee blasts, and have an accordingly short cooldown
	if(proximity_flag)
		INVOKE_ASYNC(src, .proc/aoe_burst, T, user)
		if(is_station_level(T.z))
			add_attack_logs(user, target, "Fired 3x3 blast at [src]")
		else
			add_attack_logs(user, target, "Fired 3x3 blast at [src]", ATKLOG_ALL)
	else
		if(ismineralturf(target) && get_dist(user, target) < 6) //target is minerals, we can hit it(even if we can't see it)
			INVOKE_ASYNC(src, .proc/cardinal_blasts, T, user)
			timer = world.time + cooldown_time
		else if(target in view(5, get_turf(user))) //if the target is in view, hit it
			timer = world.time + cooldown_time
			if(isliving(target) && chaser_timer <= world.time) //living and chasers off cooldown? fire one!
				chaser_timer = world.time + chaser_cooldown
				var/obj/effect/temp_visual/hierophant/chaser/C = new(get_turf(user), user, target, chaser_speed, friendly_fire_check)
				C.damage = 30
				C.monster_damage_boost = FALSE
				if(is_station_level(T.z))
					add_attack_logs(user, target, "Fired a chaser at [src]")
				else
					add_attack_logs(user, target, "Fired a chaser at [src]", ATKLOG_ALL)
			else
				INVOKE_ASYNC(src, .proc/cardinal_blasts, T, user) //otherwise, just do cardinal blast
				if(is_station_level(T.z))
					add_attack_logs(user, target, "Fired cardinal blast at [src]")
				else
					add_attack_logs(user, target, "Fired cardinal blast at [src]", ATKLOG_ALL)
		else
			to_chat(user, "<span class='warning'>That target is out of range!</span>" )
			timer = world.time
	INVOKE_ASYNC(src, .proc/prepare_icon_update)

/obj/item/hierophant_club/proc/calculate_anger_mod(mob/user) //we get stronger as the user loses health
	chaser_cooldown = initial(chaser_cooldown)
	cooldown_time = initial(cooldown_time)
	chaser_speed = initial(chaser_speed)
	blast_range = initial(blast_range)
	if(isliving(user))
		var/mob/living/L = user
		var/health_percent = L.health / L.maxHealth
		chaser_cooldown += round(health_percent * 20) //two tenths of a second for each missing 10% of health
		cooldown_time += round(health_percent * 10) //one tenth of a second for each missing 10% of health
		chaser_speed = max(chaser_speed + health_percent, 0.5) //one tenth of a second faster for each missing 10% of health
		blast_range -= round(health_percent * 10) //one additional range for each missing 10% of health

/obj/item/hierophant_club/update_icon()
	icon_state = "hierophant_club[timer <= world.time ? "_ready":""][(beacon && !QDELETED(beacon)) ? "":"_beacon"]"
	item_state = icon_state
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_l_hand()
		M.update_inv_r_hand()
		M.update_inv_back()

/obj/item/hierophant_club/proc/prepare_icon_update()
	update_icon()
	sleep(timer - world.time)
	update_icon()

/obj/item/hierophant_club/ui_action_click(mob/user, actiontype)
	if(actiontype == /datum/action/item_action/toggle_unfriendly_fire) //toggle friendly fire...
		friendly_fire_check = !friendly_fire_check
		to_chat(user, "<span class='warning'>You toggle friendly fire [friendly_fire_check ? "off":"on"]!</span>")
		return
	if(timer > world.time)
		return
	if(user.is_in_active_hand(src) && user.is_in_inactive_hand(src)) //you need to hold the staff to teleport
		to_chat(user, "<span class='warning'>You need to hold the club in your hands to [beacon ? "teleport with it":"detach the beacon"]!</span>")
		return
	if(is_in_teleport_proof_area(user))
		to_chat(user, "<span class='warning'>[src] sparks and fizzles.</span>")
		return
	if(!beacon || QDELETED(beacon))
		if(isturf(user.loc))
			user.visible_message("<span class='hierophant_warning'>[user] starts fiddling with [src]'s pommel...</span>", \
			"<span class='notice'>You start detaching the hierophant beacon...</span>")
			timer = world.time + 51
			INVOKE_ASYNC(src, .proc/prepare_icon_update)
			if(do_after(user, 50, target = user) && !beacon)
				var/turf/T = get_turf(user)
				playsound(T,'sound/magic/blind.ogg', 200, TRUE, -4)
				new /obj/effect/temp_visual/hierophant/telegraph/teleport(T, user)
				beacon = new/obj/effect/hierophant(T)
				user.update_action_buttons_icon()
				user.visible_message("<span class='hierophant_warning'>[user] places a strange machine beneath [user.p_their()] feet!</span>", \
				"<span class='hierophant'>You detach the hierophant beacon, allowing you to teleport yourself and any allies to it at any time!</span>\n\
				<span class='notice'>You can remove the beacon to place it again by striking it with the club.</span>")
			else
				timer = world.time
				INVOKE_ASYNC(src, .proc/prepare_icon_update)
		else
			to_chat(user, "<span class='warning'>You need to be on solid ground to detach the beacon!</span>")
		return
	if(get_dist(user, beacon) <= 2) //beacon too close abort
		to_chat(user, "<span class='warning'>You are too close to the beacon to teleport to it!</span>")
		return
	if(is_blocked_turf(get_turf(beacon), TRUE))
		to_chat(user, "<span class='warning'>The beacon is blocked by something, preventing teleportation!</span>")
		return
	if(!isturf(user.loc))
		to_chat(user, "<span class='warning'>You don't have enough space to teleport from here!</span>")
		return
	teleporting = TRUE //start channel
	user.update_action_buttons_icon()
	user.visible_message("<span class='hierophant_warning'>[user] starts to glow faintly...</span>")
	timer = world.time + 50
	INVOKE_ASYNC(src, .proc/prepare_icon_update)
	beacon.icon_state = "hierophant_tele_on"
	var/obj/effect/temp_visual/hierophant/telegraph/edge/TE1 = new /obj/effect/temp_visual/hierophant/telegraph/edge(user.loc)
	var/obj/effect/temp_visual/hierophant/telegraph/edge/TE2 = new /obj/effect/temp_visual/hierophant/telegraph/edge(beacon.loc)
	if(do_after(user, 40, target = user) && user && beacon)
		var/turf/T = get_turf(beacon)
		var/turf/source = get_turf(user)
		if(is_blocked_turf(T, TRUE))
			teleporting = FALSE
			to_chat(user, "<span class='warning'>The beacon is blocked by something, preventing teleportation!</span>")
			user.update_action_buttons_icon()
			timer = world.time
			INVOKE_ASYNC(src, .proc/prepare_icon_update)
			beacon.icon_state = "hierophant_tele_off"
			return
		new /obj/effect/temp_visual/hierophant/telegraph(T, user)
		new /obj/effect/temp_visual/hierophant/telegraph(source, user)
		playsound(T,'sound/magic/wand_teleport.ogg', 200, TRUE)
		playsound(source,'sound/machines/airlock_open.ogg', 200, TRUE)
		if(!do_after(user, 3, target = user) || !user || !beacon || QDELETED(beacon)) //no walking away shitlord
			teleporting = FALSE
			if(user)
				user.update_action_buttons_icon()
			timer = world.time
			INVOKE_ASYNC(src, .proc/prepare_icon_update)
			if(beacon)
				beacon.icon_state = "hierophant_tele_off"
			return
		if(is_blocked_turf(T, TRUE))
			teleporting = FALSE
			to_chat(user, "<span class='warning'>The beacon is blocked by something, preventing teleportation!</span>")
			user.update_action_buttons_icon()
			timer = world.time
			INVOKE_ASYNC(src, .proc/prepare_icon_update)
			beacon.icon_state = "hierophant_tele_off"
			return
		add_attack_logs(user, beacon, "Teleported self from ([AREACOORD(source)]) to ([AREACOORD(beacon)])")
		new /obj/effect/temp_visual/hierophant/telegraph/teleport(T, user)
		new /obj/effect/temp_visual/hierophant/telegraph/teleport(source, user)
		for(var/t in RANGE_TURFS(1, T))
			var/obj/effect/temp_visual/hierophant/blast/B = new /obj/effect/temp_visual/hierophant/blast(t, user, TRUE) //blasts produced will not hurt allies
			B.damage = 30
		for(var/t in RANGE_TURFS(1, source))
			var/obj/effect/temp_visual/hierophant/blast/B = new /obj/effect/temp_visual/hierophant/blast(t, user, TRUE) //but absolutely will hurt enemies
			B.damage = 30
		for(var/mob/living/L in range(1, source))
			INVOKE_ASYNC(src, .proc/teleport_mob, source, L, T, user) //regardless, take all mobs near us along
		sleep(6) //at this point the blasts detonate
		if(beacon)
			beacon.icon_state = "hierophant_tele_off"
	else
		qdel(TE1)
		qdel(TE2)
		timer = world.time
		INVOKE_ASYNC(src, .proc/prepare_icon_update)
	if(beacon)
		beacon.icon_state = "hierophant_tele_off"
	teleporting = FALSE
	if(user)
		user.update_action_buttons_icon()

/obj/item/hierophant_club/proc/teleport_mob(turf/source, mob/M, turf/target, mob/user)
	var/turf/turf_to_teleport_to = get_step(target, get_dir(source, M)) //get position relative to caster
	if(!turf_to_teleport_to || is_blocked_turf(turf_to_teleport_to, TRUE))
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

/obj/item/hierophant_club/proc/cardinal_blasts(turf/T, mob/living/user) //fire cardinal cross blasts with a delay
	if(!T)
		return
	new /obj/effect/temp_visual/hierophant/telegraph/cardinal(T, user)
	playsound(T,'sound/effects/bin_close.ogg', 200, TRUE)
	sleep(2)
	var/obj/effect/temp_visual/hierophant/blast/B = new(T, user, friendly_fire_check)
	B.damage = HIEROPHANT_CLUB_CARDINAL_DAMAGE
	B.monster_damage_boost = FALSE
	for(var/d in GLOB.cardinal)
		INVOKE_ASYNC(src, .proc/blast_wall, T, d, user)

/obj/item/hierophant_club/proc/blast_wall(turf/T, dir, mob/living/user) //make a wall of blasts blast_range tiles long
	if(!T)
		return
	var/range = blast_range
	var/turf/previousturf = T
	var/turf/J = get_step(previousturf, dir)
	for(var/i in 1 to range)
		if(!J)
			return
		var/obj/effect/temp_visual/hierophant/blast/B = new(J, user, friendly_fire_check)
		B.damage = HIEROPHANT_CLUB_CARDINAL_DAMAGE
		B.monster_damage_boost = FALSE
		previousturf = J
		J = get_step(previousturf, dir)

/obj/item/hierophant_club/proc/aoe_burst(turf/T, mob/living/user) //make a 3x3 blast around a target
	if(!T)
		return
	new /obj/effect/temp_visual/hierophant/telegraph(T, user)
	playsound(T,'sound/effects/bin_close.ogg', 200, TRUE)
	sleep(2)
	for(var/t in RANGE_TURFS(1, T))
		var/obj/effect/temp_visual/hierophant/blast/B = new(t, user, friendly_fire_check)
		B.damage = 15 //keeps monster damage boost due to lower damage

#undef HIEROPHANT_CLUB_CARDINAL_DAMAGE

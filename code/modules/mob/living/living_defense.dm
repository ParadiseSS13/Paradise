/**
 * Returns final, affected by `armor_penetration_flat` and `armor_penetration_percentage`, armor value of specific armor type
 *
 * * def_zone - What part is getting hit, if not set will check armor of entire body
 * * armor_type - What type of armor is used. MELEE, BULLET, MAGIC etc.
 * * absorb_text - Text displayed when your armor makes you immune (armor is INFINITY)
 * * soften_text - Text displayed when 0 < armor < INFINITY. So armor protected us from some damage
 * * penetrated_text - Text displayed when armor penetration decreases non 0 armor to 0. So it's completely penetrated
 * * armor_penetration_percentage - % of armor value that is penetrated. Does nothing if armor <= 0. Happens before flat AP
 * * armor_penetration_flat - armor value that is penetrated. Does nothing if armor <= 0. Occurs after percentage AP
*/
/mob/living/proc/run_armor_check(
	def_zone,
	armor_type = MELEE,
	absorb_text = "Your armor absorbs the blow!",
	soften_text = "Your armor softens the blow!",
	penetrated_text = "Your armor was penetrated!",
	armor_penetration_flat,
	armor_penetration_percentage,
)
	. = getarmor(def_zone, armor_type)

	if(. == INFINITY)
		to_chat(src, "<span class='userdanger'>[absorb_text]</span>")
		return
	if(. <= 0)
		return
	if(!armor_penetration_flat && !armor_penetration_percentage)
		to_chat(src, "<span class='userdanger'>[soften_text]</span>")
		return

	. = max(0, . * (100 - armor_penetration_percentage) / 100 - armor_penetration_flat)
	if(.)
		to_chat(src, "<span class='userdanger'>[soften_text]</span>")
	else
		to_chat(src, "<span class='userdanger'>[penetrated_text]</span>")

/// Returns armor value of our mob.
/// As u can see, mobs have no armor by default so we override this proc on mob subtypes if we add them any armor
/mob/living/proc/getarmor(def_zone, armor_type)
	return 0

/mob/living/proc/is_mouth_covered(head_only = FALSE, mask_only = FALSE)
	return FALSE

/mob/living/proc/is_eyes_covered(check_glasses = TRUE, check_head = TRUE, check_mask = TRUE)
	return FALSE

/mob/living/bullet_act(obj/item/projectile/P, def_zone)
	SEND_SIGNAL(src, COMSIG_ATOM_BULLET_ACT, P, def_zone)
	//Armor
	var/armor = run_armor_check(def_zone, P.flag, armor_penetration_flat = P.armor_penetration_flat, armor_penetration_percentage = P.armor_penetration_percentage)
	if(!P.nodamage)
		apply_damage(P.damage, P.damage_type, def_zone, armor)
		if(P.dismemberment)
			check_projectile_dismemberment(P, def_zone)
	return P.on_hit(src, armor, def_zone)

/// Tries to dodge incoming bullets if we aren't disabled for any reasons. Advised to overide with advanced effects, this is as basic example admins can apply.
/mob/living/proc/advanced_bullet_dodge(mob/living/source, obj/item/projectile/hitting_projectile)
	SIGNAL_HANDLER

	if(HAS_TRAIT(source, TRAIT_IMMOBILIZED))
		return NONE
	if(source.stat != CONSCIOUS)
		return NONE
	if(!prob(advanced_bullet_dodge_chance))
		return NONE

	source.visible_message(
		"<span class='danger'>[source] [pick("dodges","jumps out of the way of","evades","dives out of the way of")] [hitting_projectile]!</span>",
		"<span class='userdanger'>You evade [hitting_projectile]!</span>",
	)
	playsound(source, pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg'), 75, TRUE)
	// Chance to dodge multiple shotgun spreads, but not likely. Mainly: Infinite loop prevention from admins setting it to 100 and doing something stupid.
	// If you want to set your dodge chance to 100 on a subtype, no issue: Just make sure the subtype does not step in a direction, otherwise you'll have the mob move a large distance to dodge rubbershot.
	if(prob(50))
		addtimer(VARSET_CALLBACK(src, advanced_bullet_dodge_chance, advanced_bullet_dodge_chance), 0.25 SECONDS) // Returns fast enough for multiple laser shots.
		advanced_bullet_dodge_chance = 0
	return ATOM_PREHIT_FAILURE

/mob/living/proc/check_projectile_dismemberment(obj/item/projectile/P, def_zone)
	return 0

///As the name suggests, this should be called to apply electric shocks.
/mob/living/proc/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE)
	SEND_SIGNAL(src, COMSIG_LIVING_ELECTROCUTE_ACT, shock_damage, source, siemens_coeff, flags)
	if(status_flags & GODMODE)	//godmode
		return FALSE
	if((flags & SHOCK_TESLA) && HAS_TRAIT(src, TRAIT_TESLA_SHOCKIMMUNE))
		return FALSE
	if(HAS_TRAIT(src, TRAIT_SHOCKIMMUNE))
		return FALSE
	shock_damage *= siemens_coeff
	if(shock_damage < 1)
		return FALSE
	if(!(flags & SHOCK_ILLUSION))
		take_overall_damage(0, shock_damage, TRUE, used_weapon = "Electrocution")
		if(shock_damage > 200)
			visible_message(
				"<span class='danger'>[src] was arc flashed by \the [source]!</span>",
				"<span class='userdanger'>\The [source] arc flashes and electrocutes you!</span>",
				"<span class='italics'>You hear a lightning-like crack!</span>")
			playsound(loc, 'sound/effects/eleczap.ogg', 50, TRUE, -1)
			explosion(loc, -1, 1, 3, 3, cause = "Extreme Electrocution from [source]")
	else
		apply_damage(shock_damage, STAMINA)
	visible_message(
		"<span class='danger'>[src] was shocked by \the [source]!</span>", \
		"<span class='userdanger'>You feel a powerful shock coursing through your body!</span>", \
		"<span class='hear'>You hear a heavy electrical crack.</span>" \
	)
	return shock_damage

/mob/living/emp_act(severity)
	..()
	for(var/obj/O in contents)
		O.emp_act(severity)

/obj/item/proc/get_volume_by_throwforce_and_or_w_class()
	if(throwforce && w_class)
		return clamp((throwforce + w_class) * 5, 30, 100)// Add the item's throwforce to its weight class and multiply by 5, then clamp the value between 30 and 100
	else if(w_class)
		return clamp(w_class * 8, 20, 100) // Multiply the item's weight class by 8, then clamp the value between 20 and 100
	else
		return 0

//this proc handles being hit by a thrown atom
/mob/living/hitby(atom/movable/AM, skipcatch, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	if(isitem(AM))
		var/obj/item/thrown_item = AM
		var/zone = ran_zone(BODY_ZONE_CHEST, 65)//Hits a random part of the body, geared towards the chest
		var/nosell_hit = SEND_SIGNAL(thrown_item, COMSIG_MOVABLE_IMPACT_ZONE, src, zone, throwingdatum) // TODO: find a better way to handle hitpush and skipcatch for humans
		if(nosell_hit)
			skipcatch = TRUE
			hitpush = FALSE

		if(blocked)
			return TRUE
		var/mob/thrower = locateUID(thrown_item.thrownby)
		if(thrower)
			add_attack_logs(thrower, src, "Hit with thrown [thrown_item]", !thrown_item.throwforce ? ATKLOG_ALMOSTALL : null) // Only message if the person gets damages
		if(nosell_hit)
			return ..()
		visible_message("<span class='danger'>[src] is hit by [thrown_item]!</span>", "<span class='userdanger'>You're hit by [thrown_item]!</span>")
		if(!thrown_item.throwforce)
			return
		var/armor = run_armor_check(
			def_zone = zone,
			armor_type = MELEE,
			absorb_text = "Your armor has protected your [parse_zone(zone)].",
			soften_text = "Your armor has softened hit to your [parse_zone(zone)].",
			armor_penetration_flat = thrown_item.armor_penetration_flat,
			armor_penetration_percentage = thrown_item.armor_penetration_percentage,
		)
		apply_damage(thrown_item.throwforce, thrown_item.damtype, zone, armor, thrown_item.sharp, thrown_item)
		if(QDELETED(src)) //Damage can delete the mob.
			return
		return ..()

	playsound(loc, 'sound/weapons/genhit.ogg', 50, TRUE, -1) //Item sounds are handled in the item itself
	return ..()


/mob/living/mech_melee_attack(obj/mecha/M)
	if(M.occupant.a_intent == INTENT_HARM)
		if(HAS_TRAIT(M.occupant, TRAIT_PACIFISM))
			to_chat(M.occupant, "<span class='warning'>You don't want to harm other living beings!</span>")
			return
		M.do_attack_animation(src)
		if(M.damtype == "brute")
			step_away(src,M,15)
		switch(M.damtype)
			if("brute")
				Paralyse(2 SECONDS)
				take_overall_damage(rand(M.force/2, M.force))
				playsound(src, 'sound/weapons/punch4.ogg', 50, TRUE)
			if("fire")
				take_overall_damage(0, rand(M.force/2, M.force))
				playsound(src, 'sound/items/welder.ogg', 50, TRUE)
			if("tox")
				M.mech_toxin_damage(src)
			else
				return
		updatehealth("mech melee attack")
		M.occupant_message("<span class='danger'>You hit [src].</span>")
		visible_message("<span class='danger'>[M.name] hits [src]!</span>", "<span class='userdanger'>[M.name] hits you!</span>")
		add_attack_logs(M.occupant, src, "Mecha-meleed with [M]")
	else
		step_away(src,M)
		add_attack_logs(M.occupant, src, "Mecha-pushed with [M]", ATKLOG_ALL)
		M.occupant_message("<span class='warning'>You push [src] out of the way.</span>")
		visible_message("<span class='warning'>[M] pushes [src] out of the way.</span>")

//Mobs on Fire
/mob/living/proc/IgniteMob()
	if(fire_stacks > 0 && !on_fire && !HAS_TRAIT(src, TRAIT_NOFIRE))
		on_fire = TRUE
		visible_message("<span class='warning'>[src] catches fire!</span>", "<span class='userdanger'>You're set on fire!</span>")
		set_light(light_range + 3,l_color = "#ED9200")
		throw_alert("fire", /atom/movable/screen/alert/fire)
		update_fire()
		SEND_SIGNAL(src, COMSIG_LIVING_IGNITED)
		return TRUE
	return FALSE

/mob/living/proc/ExtinguishMob()
	if(on_fire)
		on_fire = 0
		fire_stacks = 0
		set_light(max(0,light_range - 3))
		clear_alert("fire")
		update_fire()

/mob/living/proc/update_fire()
	return

/mob/living/proc/adjust_fire_stacks(add_fire_stacks) //Adjusting the amount of fire_stacks we have on person
	fire_stacks = clamp(fire_stacks + add_fire_stacks, -20, 20)
	if(on_fire && fire_stacks <= 0)
		ExtinguishMob()

/**
 * Burns a mob and slowly puts the fires out. Returns TRUE if the mob is on fire
 */
/mob/living/proc/handle_fire()
	if(fire_stacks < 0) //If we've doused ourselves in water to avoid fire, dry off slowly
		fire_stacks = min(0, fire_stacks + 1)//So we dry ourselves back to default, nonflammable.
	if(!on_fire)
		return FALSE
	if(fire_stacks > 0)
		adjust_fire_stacks(-0.1) //the fire is slowly consumed
		for(var/obj/item/clothing/C in contents)
			C.catch_fire()
	else
		ExtinguishMob()
		return FALSE
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/G = T?.get_readonly_air() // Check if we're standing in an oxygenless environment
	if(!G || G.oxygen() < 1)
		ExtinguishMob() //If there's no oxygen in the tile we're on, put out the fire
		return FALSE
	T.hotspot_expose(700, 10)
	SEND_SIGNAL(src, COMSIG_LIVING_FIRE_TICK)
	return TRUE

/mob/living/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	..()
	adjust_fire_stacks(3)
	IgniteMob()

//Share fire evenly between the two mobs
//Called in MobBump() and Crossed()
/mob/living/proc/spreadFire(mob/living/L)
	if(!istype(L))
		return
	var/L_old_on_fire = L.on_fire

	if(on_fire) //Only spread fire stacks if we're on fire
		fire_stacks /= 2
		L.fire_stacks += fire_stacks
		if(L.IgniteMob())
			log_game("[key_name(src)] bumped into [key_name(L)] and set them on fire")

	if(L_old_on_fire) //Only ignite us and gain their stacks if they were onfire before we bumped them
		L.fire_stacks /= 2
		fire_stacks += L.fire_stacks
		IgniteMob()

/mob/living/can_be_pulled(user, grab_state, force, show_message = FALSE)
	return ..() && !(buckled && buckled.buckle_prevents_pull)

/mob/living/water_act(volume, temperature, source, method = REAGENT_TOUCH)
	. = ..()
	adjust_fire_stacks(-(volume * 0.2))
	if(method == REAGENT_TOUCH)
		// 100 volume - 20 seconds of lost sleep
		AdjustSleeping(-(volume * 0.2 SECONDS), bound_lower = 1 SECONDS) // showers cannot save you from sleeping gas, 1 second lower boundary

/mob/living/proc/near_wall(direction, distance=1)
	var/turf/T = get_step(get_turf(src),direction)
	var/turf/last_turf = src.loc
	var/i = 1

	while(i>0 && i<=distance)
		if(T.density) //Turf is a wall!
			return last_turf
		i++
		last_turf = T
		T = get_step(T,direction)

	return 0

// End BS12 momentum-transfer code.

/mob/living/proc/grabbedby(mob/living/carbon/user, supress_message = FALSE)
	if(user == src && ishuman(user))
		var/mob/living/carbon/human/self = user
		INVOKE_ASYNC(self, TYPE_PROC_REF(/mob/living/carbon/human, peel_off_synthetic_skin))
		return
	if(anchored)
		return FALSE
	if(!(status_flags & CANPUSH))
		return FALSE
	if(user.pull_force < move_force)
		return FALSE
	// This if-statement checks if the user is horizontal, and if the user either has no martial art, or has judo, drunk fighting or krav, in which case it should also fail
	if(IS_HORIZONTAL(user) && (!user.mind.martial_art || !user.mind.martial_art.can_horizontally_grab))
		to_chat(user, "<span class='warning'>You fail to get a good grip on [src]!</span>")
		return

	for(var/obj/item/grab/G in grabbed_by)
		if(G.assailant == user)
			to_chat(user, "<span class='notice'>You already grabbed [src].</span>")
			return

	add_attack_logs(user, src, "Grabbed passively", ATKLOG_ALL)

	var/obj/item/grab/G = new /obj/item/grab(user, src)
	if(!G)	//the grab will delete itself in New if src is anchored
		return 0
	user.put_in_active_hand(G)
	G.synch()

	playsound(src.loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
	/*if(user.dir == src.dir)
		G.state = GRAB_AGGRESSIVE
		G.last_upgrade = world.time
		if(!supress_message)
			visible_message("<span class='warning'>[user] has grabbed [src] from behind!</span>")
	else*///This is an example of how you can make special types of grabs simply based on direction.
	if(!supress_message)
		visible_message("<span class='warning'>[user] has grabbed [src] passively!</span>")

	return G

/mob/living/attack_slime(mob/living/simple_animal/slime/M)
	if(SSticker.current_state < GAME_STATE_PLAYING)
		to_chat(M, "You cannot attack people before the game has started.")
		return

	if(M.buckled)
		if(M in buckled_mobs)
			M.Feedstop()
		return // can't attack while eating!

	if(HAS_TRAIT(src, TRAIT_PACIFISM))
		to_chat(M, "<span class='warning'>You don't want to hurt anyone!</span>")
		return FALSE

	if(stat != DEAD)
		add_attack_logs(M, src, "Slime'd")
		M.do_attack_animation(src)
		visible_message("<span class='danger'>\The [M.name] glomps [src]!</span>", "<span class='userdanger'>\The [M.name] glomps you!</span>")
		return TRUE

/mob/living/attack_animal(mob/living/simple_animal/M)
	. = ..()

	M.face_atom(src)
	if((M.a_intent == INTENT_HELP && M.ckey) || M.melee_damage_upper == 0)
		M.custom_emote(EMOTE_VISIBLE, "[M.friendly] [src].")
		return FALSE
	if(HAS_TRAIT(M, TRAIT_PACIFISM))
		to_chat(M, "<span class='warning'>You don't want to hurt anyone!</span>")
		return FALSE

	if(M.attack_sound)
		playsound(loc, M.attack_sound, 50, TRUE, 1)
	M.do_attack_animation(src)
	visible_message("<span class='danger'>\The [M] [M.attacktext] [src]!</span>", \
					"<span class='userdanger'>\The [M] [M.attacktext] [src]!</span>")
	add_attack_logs(M, src, "Animal attacked")
	return TRUE

// TODO: Probably a bunch of this shit doesn't need to be here but I don't feel
// like sorting it out right now
/mob/living/handle_basic_attack(mob/living/basic/attacker, modifiers)
	if((attacker.a_intent == INTENT_HELP && attacker.ckey) || attacker.melee_damage_upper == 0)
		attacker.custom_emote(EMOTE_VISIBLE, "[attacker.friendly_verb_continuous] [src].")
		return FALSE
	if(HAS_TRAIT(attacker, TRAIT_PACIFISM))
		to_chat(attacker, "<span class='warning'>You don't want to hurt anyone!</span>")
		return FALSE

	if(attacker.attack_sound)
		playsound(loc, attacker.attack_sound, 50, TRUE, 1)
	attacker.do_attack_animation(src)
	visible_message("<span class='danger'>[attacker] [attacker.attack_verb_continuous] [src]!</span>", \
					"<span class='userdanger'>[attacker] [attacker.attack_verb_continuous] [src]!</span>")
	add_attack_logs(attacker, src, "Basicmob attacked")
	return TRUE

/mob/living/attack_larva(mob/living/carbon/alien/larva/L)
	switch(L.a_intent)
		if(INTENT_HELP)
			visible_message("<span class='notice'>[L.name] rubs its head against [src].</span>")
			return 0

		else
			if(HAS_TRAIT(L, TRAIT_PACIFISM))
				to_chat(L, "<span class='warning'>You don't want to hurt anyone!</span>")
				return

			L.do_attack_animation(src)
			if(prob(90))
				add_attack_logs(L, src, "Larva attacked")
				visible_message("<span class='danger'>[L.name] bites [src]!</span>", \
						"<span class='userdanger'>[L.name] bites [src]!</span>")
				playsound(loc, 'sound/weapons/bite.ogg', 50, TRUE, -1)
				return 1
			else
				visible_message("<span class='danger'>[L.name] has attempted to bite [src]!</span>", \
					"<span class='userdanger'>[L.name] has attempted to bite [src]!</span>")
	return 0

/mob/living/attack_alien(mob/living/carbon/alien/humanoid/M)
	switch(M.a_intent)
		if(INTENT_HELP)
			visible_message("<span class='notice'>[M] caresses [src] with its scythe like arm.</span>")
			return FALSE
		if(INTENT_GRAB)
			grabbedby(M)
			return FALSE
		if(INTENT_HARM)
			if(HAS_TRAIT(M, TRAIT_PACIFISM))
				to_chat(M, "<span class='warning'>You don't want to hurt anyone!</span>")
				return FALSE
			M.do_attack_animation(src)
			return TRUE
		if(INTENT_DISARM)
			M.do_attack_animation(src, ATTACK_EFFECT_DISARM)
			return TRUE

/mob/living/proc/cult_self_harm(damage)
	return FALSE

/mob/living/shove_impact(mob/living/target, mob/living/attacker)
	if(IS_HORIZONTAL(src))
		return FALSE
	add_attack_logs(attacker, target, "pushed into [src]", ATKLOG_ALL)
	playsound(src, 'sound/weapons/punch1.ogg', 50, 1)
	target.KnockDown(1 SECONDS) // knock them both down
	KnockDown(1 SECONDS)
	return TRUE

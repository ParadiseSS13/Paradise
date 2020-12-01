#define BAR_COLOR_NORMAL "#AA5500"
#define BAR_COLOR_OVERHEATED "#AA0000"

/obj/item/projectile/guardian
	name = "crystal spray"
	icon_state = "guardian"
	damage = 25
	damage_type = BRUTE
	armour_penetration = 50

/mob/living/simple_animal/hostile/guardian/ranged
	friendly = "quietly assesses"
	melee_damage_lower = 10
	melee_damage_upper = 10
	damage_transfer = 1.2
	projectiletype = /obj/item/projectile/guardian
	ranged_cooldown_time = 5 //fast!
	projectilesound = 'sound/effects/hit_on_shattered_glass.ogg'
	ranged = 1
	range = 13
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	see_in_dark = 8
	playstyle_string = "As a <b>Ranged</b> type, you have only light damage resistance, but are capable of spraying shards of crystal at incredibly high speed. You can also deploy surveillance snares to monitor enemy movement. Finally, you can switch to scout mode, in which you can't attack, but can move without limit."
	magic_fluff_string = "..And draw the Sentinel, an alien master of ranged combat."
	tech_fluff_string = "Boot sequence complete. Ranged combat modules active. Holoparasite swarm online."
	bio_fluff_string = "Your scarab swarm finishes mutating and stirs to life, capable of spraying shards of crystal."
	var/list/snares = list()
	var/toggle = FALSE
	// Overheating
	/// The threshold at which too many subsequent attacks will provide overheat, preventing ranged attacks for a while.
	var/overheat_threshold = 10
	/// The rate at which overheat value increases per attack.
	var/overheat_per_attack = 1.25
	/// The rate at which overheat value decreases per cycle.
	var/overheat_decay = 1.5
	/// The rate at which overheat value decreases per cycle when overheated.
	var/overheat_decay_overheated = 1
	/// The current overheat value.
	var/cur_overheat = 0
	/// Whether we overheated and can no longer fire until back to 0.
	var/overheated = FALSE
	/// The overheat UI bar.
	var/image/overheat_bar = null

/mob/living/simple_animal/hostile/guardian/ranged/Login()
	. = ..()
	QDEL_NULL(overheat_bar)

/mob/living/simple_animal/hostile/guardian/ranged/Life(seconds, times_fired)
	. = ..()
	// Cool off
	if(cur_overheat > 0)
		cur_overheat = max(cur_overheat - (overheated ? overheat_decay_overheated : overheat_decay), 0)
		if(cur_overheat == 0)
			overheated = FALSE
			to_chat(src, "<span class='notice'>You can fire again.</span>")
			SEND_SOUND(src, 'sound/magic/charge.ogg')
		update_overheat_bar()

/mob/living/simple_animal/hostile/guardian/ranged/OpenFire(atom/A)
	if(overheated)
		to_chat(src, "<span class='danger'>You must regenerate wait and energy before firing again.</span>")
		return
	return ..()

/mob/living/simple_animal/hostile/guardian/ranged/Shoot(atom/targeted_atom)
	. = ..()
	if(.)
		cur_overheat += overheat_per_attack
		if(cur_overheat >= overheat_threshold)
			overheated = TRUE
			playsound(loc, 'sound/magic/teleport_app.ogg', 50, TRUE)
			to_chat(src, "<span class='userdanger'>Your energy has been depleted from too many successive attacks!</span>")
		update_overheat_bar()

/**
  * Updates (or deletes) the overheat bar based on the current overheat value.
  */
/mob/living/simple_animal/hostile/guardian/ranged/proc/update_overheat_bar()
	if(cur_overheat == 0)
		if(overheat_bar)
			animate(overheat_bar, time = 0.5 SECONDS, alpha = 0, easing = SINE_EASING)
			addtimer(CALLBACK(src, .proc/destroy_overheat_bar, overheat_bar), 0.5 SECONDS)
			overheat_bar = null
		return
	if(!overheat_bar)
		overheat_bar = image('icons/effects/progessbar.dmi', src, "prog_bar_0", HUD_LAYER)
		overheat_bar.plane = HUD_PLANE
		overheat_bar.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
		overheat_bar.filters = filter(type = "color", color = list(COLOR_WHITE, COLOR_WHITE, COLOR_WHITE))
		overheat_bar.alpha = 0
		animate(overheat_bar, time = 0.5 SECONDS, alpha = 255, easing = SINE_EASING)
		client?.images += overheat_bar
	overheat_bar.icon_state = "prog_bar_[round(((cur_overheat / overheat_threshold) * 100), 5)]"
	overheat_bar.color = overheated ? BAR_COLOR_OVERHEATED : BAR_COLOR_NORMAL

/**
  * Destroy the overheat bar.
  *
  * Longer detailed paragraph about the proc
  * including any relevant detail
  * Arguments:
  * * bar - The overheat bar image to delete.
  */
/mob/living/simple_animal/hostile/guardian/ranged/proc/destroy_overheat_bar(image/bar)
	if(!bar)
		return
	client?.images -= bar
	qdel(bar)

/mob/living/simple_animal/hostile/guardian/ranged/ToggleMode()
	if(loc == summoner)
		if(toggle)
			ranged = 1
			melee_damage_lower = 10
			melee_damage_upper = 10
			obj_damage = initial(obj_damage)
			environment_smash = initial(environment_smash)
			alpha = 255
			range = 13
			incorporeal_move = 0
			to_chat(src, "<span class='danger'>You switch to combat mode.</span>")
			toggle = FALSE
		else
			ranged = 0
			melee_damage_lower = 0
			melee_damage_upper = 0
			obj_damage = 0
			environment_smash = ENVIRONMENT_SMASH_NONE
			alpha = 60
			range = 255
			incorporeal_move = 1
			to_chat(src, "<span class='danger'>You switch to scout mode.</span>")
			toggle = TRUE
	else
		to_chat(src, "<span class='danger'>You have to be recalled to toggle modes!</span>")

/mob/living/simple_animal/hostile/guardian/ranged/ToggleLight()
	var/msg
	switch(lighting_alpha)
		if (LIGHTING_PLANE_ALPHA_VISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
			msg = "You activate your night vision."
		if (LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
			msg = "You increase your night vision."
		if (LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
			msg = "You maximize your night vision."
		else
			lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
			msg = "You deactivate your night vision."

	update_sight()

	to_chat(src, "<span class='notice'>[msg]</span>")

/mob/living/simple_animal/hostile/guardian/ranged/verb/Snare()
	set name = "Set Surveillance Trap"
	set category = "Guardian"
	set desc = "Set an invisible trap that will alert you when living creatures walk over it. Max of 5"
	if(snares.len <6)
		var/turf/snare_loc = get_turf(loc)
		var/obj/item/effect/snare/S = new /obj/item/effect/snare(snare_loc)
		S.spawner = src
		S.name = "[get_area(snare_loc)] trap ([rand(1, 1000)])"
		snares |= S
		to_chat(src, "<span class='danger'>Surveillance trap deployed!</span>")
	else
		to_chat(src, "<span class='danger'>You have too many traps deployed. Delete some first.</span>")

/mob/living/simple_animal/hostile/guardian/ranged/verb/DisarmSnare()
	set name = "Remove Surveillance Trap"
	set category = "Guardian"
	set desc = "Disarm unwanted surveillance traps."
	var/picked_snare = input(src, "Pick which trap to disarm", "Disarm Trap") as null|anything in snares
	if(picked_snare)
		snares -= picked_snare
		qdel(picked_snare)
		to_chat(src, "<span class='danger'>Snare disarmed.</span>")

/obj/item/effect/snare
	name = "snare"
	desc = "You shouldn't be seeing this!"
	var/mob/living/spawner
	invisibility = 1

/obj/effect/snare/singularity_act()
	return

/obj/effect/snare/singularity_pull()
	return

/obj/item/effect/snare/Crossed(AM as mob|obj, oldloc)
	if(isliving(AM))
		var/turf/snare_loc = get_turf(loc)
		if(spawner)
			to_chat(spawner, "<span class='danger'>[AM] has crossed your surveillance trap at [get_area(snare_loc)].</span>")
			if(istype(spawner, /mob/living/simple_animal/hostile/guardian))
				var/mob/living/simple_animal/hostile/guardian/G = spawner
				if(G.summoner)
					to_chat(G.summoner, "<span class='danger'>[AM] has crossed your surveillance trap at [get_area(snare_loc)].</span>")

#undef BAR_COLOR_NORMAL
#undef BAR_COLOR_OVERHEATED

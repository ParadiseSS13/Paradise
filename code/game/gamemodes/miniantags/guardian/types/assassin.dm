/mob/living/simple_animal/hostile/guardian/assassin
	melee_damage_lower = 15
	melee_damage_upper = 15
	armour_penetration = 0
	playstyle_string = "As an <b>Assassin</b> type you do medium damage and have no damage resistance, but can enter stealth, massively increasing the damage of your next attack and causing it to ignore armor. Stealth is broken when you attack or take damage."
	magic_fluff_string = "..And draw the Space Ninja, a lethal, invisible assassin."
	tech_fluff_string = "Boot sequence complete. Assassin modules loaded. Holoparasite swarm online."
	bio_fluff_string = "Your scarab swarm finishes mutating and stirs to life, capable of sneaking and stealthy attacks."
	var/toggle = FALSE
	var/default_stealth_cooldown = 16 SECONDS
	COOLDOWN_DECLARE(stealth_cooldown)
	var/obj/screen/alert/canstealthalert
	var/obj/screen/alert/instealthalert

/mob/living/simple_animal/hostile/guardian/assassin/Life(seconds, times_fired)
	. = ..()
	updatestealthalert()
	if(loc == summoner && toggle)
		ToggleMode(0)

/mob/living/simple_animal/hostile/guardian/assassin/Stat()
	..()
	if(statpanel("Status"))
		var/time_left = round(COOLDOWN_TIMELEFT(src, stealth_cooldown) / 10)
		if(time_left)
			stat(null, "Stealth Cooldown Remaining: [time_left] second\s")

/mob/living/simple_animal/hostile/guardian/assassin/AttackingTarget()
	. = ..()
	if(.)
		if(toggle && (isliving(target) || istype(target, /obj/structure/window) || istype(target, /obj/structure/grille)))
			ToggleMode(1)

/mob/living/simple_animal/hostile/guardian/assassin/adjustHealth(amount, updating_health = TRUE)
	. = ..()
	if(. > 0 && toggle)
		ToggleMode(1)

/mob/living/simple_animal/hostile/guardian/assassin/Recall()
	..()
	if(toggle)
		ToggleMode(0)

/mob/living/simple_animal/hostile/guardian/assassin/ToggleMode(forced = 0)
	if(toggle)
		melee_damage_lower = initial(melee_damage_lower)
		melee_damage_upper = initial(melee_damage_upper)
		armour_penetration = initial(armour_penetration)
		obj_damage = initial(obj_damage)
		environment_smash = initial(environment_smash)
		alpha = initial(alpha)
		if(!forced)
			to_chat(src, "<span class='danger'>You exit stealth.</span>")
		else
			visible_message("<span class='danger'>[src] suddenly appears!</span>")
			COOLDOWN_START(src, stealth_cooldown, default_stealth_cooldown) //we were forced out of stealth and go on cooldown
			COOLDOWN_START(src, manifest_cooldown, 4 SECONDS) //can't recall for 4 seconds
		updatestealthalert()
		toggle = FALSE
	else if(COOLDOWN_FINISHED(src, stealth_cooldown))
		if(loc == summoner)
			to_chat(src, "<span class='danger'>You have to be manifested to enter stealth!</span>")
			return
		melee_damage_lower = 50
		melee_damage_upper = 50
		armour_penetration = 100
		obj_damage = 0
		environment_smash = ENVIRONMENT_SMASH_NONE
		new /obj/effect/temp_visual/guardian/phase/out(get_turf(src))
		alpha = 15
		if(!forced)
			to_chat(src, "<span class='danger'>You enter stealth, empowering your next attack.</span>")
		updatestealthalert()
		toggle = TRUE
	else if(!forced)
		to_chat(src, "<span class='danger'>You cannot yet enter stealth, wait another [round(COOLDOWN_TIMELEFT(src, stealth_cooldown) / 10)] second\s!</span>")

/mob/living/simple_animal/hostile/guardian/assassin/proc/updatestealthalert()
	if(COOLDOWN_FINISHED(src, stealth_cooldown))
		if(toggle)
			if(!instealthalert)
				instealthalert = throw_alert("instealth", /obj/screen/alert/instealth)
				clear_alert("canstealth")
				canstealthalert = null
		else
			if(!canstealthalert)
				canstealthalert = throw_alert("canstealth", /obj/screen/alert/canstealth)
				clear_alert("instealth")
				instealthalert = null
	else
		clear_alert("instealth")
		instealthalert = null
		clear_alert("canstealth")
		canstealthalert = null

/mob/living/simple_animal/hostile/guardian/assassin
	melee_damage_lower = 25
	melee_damage_upper = 25
	damage_transfer = 0.6
	playstyle_string = "As an <b>Assassin</b> type you do medium damage and have moderate damage resistance, but can enter stealth, massively increasing the damage of your next attack and causing it to ignore armor. Stealth is broken when you attack or take damage."
	magic_fluff_string = "..And draw the Space Ninja, a lethal, invisible assassin."
	tech_fluff_string = "Boot sequence complete. Assassin modules loaded. Holoparasite swarm online."
	bio_fluff_string = "Your scarab swarm finishes mutating and stirs to life, capable of sneaking and stealthy attacks."
	stealthy_deploying = TRUE
	attacktext = "slashes"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	var/toggle = FALSE
	var/stealthcooldown = 0
	var/default_stealth_cooldown = 10 SECONDS
	var/atom/movable/screen/alert/canstealthalert
	var/atom/movable/screen/alert/instealthalert

/mob/living/simple_animal/hostile/guardian/assassin/Initialize(mapload, mob/living/host)
	. = ..()
	remove_from_all_data_huds()
	if(loc == summoner && toggle)
		ToggleMode(0)

/mob/living/simple_animal/hostile/guardian/assassin/Life(seconds, times_fired)
	. = ..()
	updatestealthalert()

/mob/living/simple_animal/hostile/guardian/assassin/get_status_tab_items()
	var/list/status_tab_data = ..()
	. = status_tab_data
	if(stealthcooldown >= world.time)
		status_tab_data[++status_tab_data.len] = list("Stealth Cooldown Remaining:", "[max(round((stealthcooldown - world.time) * 0.1, 0.1), 0)] seconds")

/mob/living/simple_animal/hostile/guardian/assassin/AttackingTarget()
	. = ..()
	if(.)
		if(toggle && (isliving(target) || istype(target, /obj/structure/window) || istype(target, /obj/structure/grille)))
			ToggleMode(1)

/mob/living/simple_animal/hostile/guardian/assassin/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!no_effect && !visual_effect_icon)
		visual_effect_icon = ATTACK_EFFECT_CLAW
	return ..()

/mob/living/simple_animal/hostile/guardian/assassin/adjustHealth(amount, updating_health = TRUE)
	. = ..()
	if(. > 0 && toggle)
		ToggleMode(1)

/mob/living/simple_animal/hostile/guardian/assassin/Manifest()
	. = ..()
	ToggleMode(FALSE)

/mob/living/simple_animal/hostile/guardian/assassin/ToggleMode(forced = 0)
	if(toggle)
		melee_damage_lower = initial(melee_damage_lower)
		melee_damage_upper = initial(melee_damage_upper)
		armor_penetration_percentage = initial(armor_penetration_percentage)
		obj_damage = initial(obj_damage)
		environment_smash = initial(environment_smash)
		alpha = initial(alpha)
		if(!forced)
			to_chat(src, "<span class='danger'>You exit stealth.</span>")
		else
			visible_message("<span class='danger'>[src] suddenly appears!</span>")
			stealthcooldown = world.time + default_stealth_cooldown //we were forced out of stealth and go on cooldown
			cooldown = world.time + 40 //can't recall for 4 seconds
		updatestealthalert()
		toggle = FALSE
	else if(stealthcooldown <= world.time)
		if(loc == summoner)
			to_chat(src, "<span class='notice'>You automatically deploy stealthed!</span>")
			return
		melee_damage_lower = 50
		melee_damage_upper = 50
		armor_penetration_percentage = 100
		obj_damage = 0
		environment_smash = ENVIRONMENT_SMASH_NONE
		alpha = 10
		if(!forced)
			to_chat(src, "<span class='danger'>You enter stealth, becoming mostly invisible, empowering your next attack.</span>")
		updatestealthalert()
		toggle = TRUE
	else if(!forced)
		to_chat(src, "<span class='danger'>You cannot yet enter stealth, wait another [max(round((stealthcooldown - world.time)*0.1, 0.1), 0)] seconds!</span>")

/mob/living/simple_animal/hostile/guardian/assassin/proc/updatestealthalert()
	if(stealthcooldown <= world.time)
		if(toggle)
			if(!instealthalert)
				instealthalert = throw_alert("instealth", /atom/movable/screen/alert/instealth)
				clear_alert("canstealth")
				canstealthalert = null
		else
			if(!canstealthalert)
				canstealthalert = throw_alert("canstealth", /atom/movable/screen/alert/canstealth)
				clear_alert("instealth")
				instealthalert = null
	else
		clear_alert("instealth")
		instealthalert = null
		clear_alert("canstealth")
		canstealthalert = null

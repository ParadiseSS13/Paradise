/mob/living/simple_animal/hostile/guardian/protector
	melee_damage_lower = 15
	melee_damage_upper = 15
	range = 15 //worse for it due to how it leashes
	damage_transfer = 0.4
	playstyle_string = "As a <b>Protector</b> type you cause your summoner to leash to you instead of you leashing to them and have two modes; Combat Mode, where you do and take medium damage, and Protection Mode, where you do and take almost no damage, but move slightly slower."
	magic_fluff_string = "..And draw the Guardian, a stalwart protector that never leaves the side of its charge."
	tech_fluff_string = "Boot sequence complete. Protector modules loaded. Holoparasite swarm online."
	bio_fluff_string = "Your scarab swarm finishes mutating and stirs to life, ready to defend you."
	var/toggle = FALSE

/mob/living/simple_animal/hostile/guardian/protector/ex_act(severity)
	if(severity == 1)
		adjustBruteLoss(400) //if in protector mode, will do 20 damage and not actually necessarily kill the summoner
	else
		..()
	if(toggle)
		visible_message("<span class='danger'>The explosion glances off [src]'s energy shielding!</span>")

/mob/living/simple_animal/hostile/guardian/protector/ToggleMode()
	if(cooldown > world.time)
		return 0
	cooldown = world.time + 10
	if(toggle)
		overlays.Cut()
		melee_damage_lower = initial(melee_damage_lower)
		melee_damage_upper = initial(melee_damage_upper)
		speed = initial(speed)
		damage_transfer = 0.4
		to_chat(src, "<span class='danger'>You switch to combat mode.</span>")
		toggle = FALSE
	else
		var/icon/shield_overlay = icon('icons/effects/effects.dmi', "shield-grey")
		shield_overlay *= name_color
		overlays.Add(shield_overlay)
		melee_damage_lower = 2
		melee_damage_upper = 2
		speed = 1
		damage_transfer = 0.05 //damage? what's damage?
		to_chat(src, "<span class='danger'>You switch to protection mode.</span>")
		toggle = TRUE

/mob/living/simple_animal/hostile/guardian/protector/snapback() //snap to what? snap to the guardian!
	if(summoner)
		if(get_dist(get_turf(summoner),get_turf(src)) <= range)
			return
		else
			if(istype(summoner.loc, /obj/effect))
				to_chat(src, "<span class='holoparasite'>You moved out of range, and were pulled back! You can only move [range] meters from [summoner.real_name]!</span>")
				visible_message("<span class='danger'>[src] jumps back to its user.</span>")
				Recall(TRUE)
			else
				to_chat(summoner, "<span class='holoparasite'>You moved out of range, and were pulled back! You can only move [range] meters from <b>[src]</b>!</span>")
				summoner.visible_message("<span class='danger'>[summoner] jumps back to [summoner.p_their()] protector.</span>")
				new /obj/effect/temp_visual/guardian/phase/out(get_turf(summoner))
				summoner.forceMove(get_turf(src))
				new /obj/effect/temp_visual/guardian/phase(get_turf(summoner))//Protector
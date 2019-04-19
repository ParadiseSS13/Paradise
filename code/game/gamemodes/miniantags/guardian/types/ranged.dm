/obj/item/projectile/guardian
	name = "crystal spray"
	icon_state = "guardian"
	damage = 5
	damage_type = BRUTE
	armour_penetration = 100

/mob/living/simple_animal/hostile/guardian/ranged
	friendly = "quietly assesses"
	melee_damage_lower = 10
	melee_damage_upper = 10
	damage_transfer = 0.9
	projectiletype = /obj/item/projectile/guardian
	ranged_cooldown_time = 10
	projectilesound = 'sound/effects/hit_on_shattered_glass.ogg'
	ranged = 1
	rapid = 1
	range = 13
	see_invisible = SEE_INVISIBLE_MINIMUM
	see_in_dark = 8
	playstyle_string = "As a <b>Ranged</b> type, you have only light damage resistance, but are capable of spraying shards of crystal at incredibly high speed. You can also deploy surveillance snares to monitor enemy movement. Finally, you can switch to scout mode, in which you can't attack, but can move without limit."
	magic_fluff_string = "..And draw the Sentinel, an alien master of ranged combat."
	tech_fluff_string = "Boot sequence complete. Ranged combat modules active. Holoparasite swarm online."
	bio_fluff_string = "Your scarab swarm finishes mutating and stirs to life, capable of spraying shards of crystal."
	var/list/snares = list()
	var/toggle = FALSE

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
	if(see_invisible == SEE_INVISIBLE_MINIMUM)
		to_chat(src, "<span class='notice'>You deactivate your night vision.</span>")
		see_invisible = SEE_INVISIBLE_LIVING
	else
		to_chat(src, "<span class='notice'>You activate your night vision.</span>")
		see_invisible = SEE_INVISIBLE_MINIMUM

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


/obj/item/effect/snare/Crossed(AM as mob|obj)
	if(isliving(AM))
		var/turf/snare_loc = get_turf(loc)
		if(spawner)
			to_chat(spawner, "<span class='danger'>[AM] has crossed your surveillance trap at [get_area(snare_loc)].</span>")
			if(istype(spawner, /mob/living/simple_animal/hostile/guardian))
				var/mob/living/simple_animal/hostile/guardian/G = spawner
				if(G.summoner)
					to_chat(G.summoner, "<span class='danger'>[AM] has crossed your surveillance trap at [get_area(snare_loc)].</span>")

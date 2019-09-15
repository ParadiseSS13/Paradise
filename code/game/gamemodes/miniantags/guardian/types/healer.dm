/mob/living/simple_animal/hostile/guardian/healer
	friendly = "heals"
	speed = 0
	melee_damage_lower = 15
	melee_damage_upper = 15
	playstyle_string = "As a <b>Support</b> type, you may toggle your basic attacks to a healing mode. In addition, Alt-Clicking on an adjacent mob will warp them to your bluespace beacon after a short delay."
	magic_fluff_string = "..And draw the CMO, a potent force of life...and death."
	tech_fluff_string = "Boot sequence complete. Medical modules active. Bluespace modules activated. Holoparasite swarm online."
	bio_fluff_string = "Your scarab swarm finishes mutating and stirs to life, capable of mending wounds and travelling via bluespace."
	var/turf/simulated/floor/beacon
	var/beacon_cooldown = 0
	var/default_beacon_cooldown = 300 SECONDS
	var/toggle = FALSE
	var/heal_cooldown = 0

/mob/living/simple_animal/hostile/guardian/healer/sealhealer
	name = "Seal Sprit"
	real_name = "Seal Sprit"
	icon = 'icons/mob/animal.dmi'
	icon_living = "seal"
	icon_state = "seal"
	attacktext = "slaps"
	speak_emote = list("barks")
	friendly = "heals"
	speed = 0
	melee_damage_lower = 0
	melee_damage_upper = 0
	melee_damage_type = STAMINA
	adminseal = TRUE

/mob/living/simple_animal/hostile/guardian/healer/New()
	..()

/mob/living/simple_animal/hostile/guardian/healer/Life(seconds, times_fired)
	..()
	var/datum/atom_hud/medsensor = huds[DATA_HUD_MEDICAL_ADVANCED]
	medsensor.add_hud_to(src)

/mob/living/simple_animal/hostile/guardian/healer/Stat()
	..()
	if(statpanel("Status"))
		if(beacon_cooldown >= world.time)
			stat(null, "Bluespace Beacon Cooldown Remaining: [max(round((beacon_cooldown - world.time)*0.1, 0.1), 0)] seconds")

/mob/living/simple_animal/hostile/guardian/healer/AttackingTarget()
	. = ..()
	if(toggle == TRUE)
		if(loc == summoner)
			to_chat(src, "<span class='danger'>You must be manifested to heal!</span>")
			return
		if(iscarbon(target))
			changeNext_move(CLICK_CD_MELEE)
			if(heal_cooldown <= world.time && !stat)
				var/mob/living/carbon/C = target
				C.adjustBruteLoss(-5, robotic=1)
				C.adjustFireLoss(-5, robotic=1)
				C.adjustOxyLoss(-5)
				C.adjustToxLoss(-5)
				heal_cooldown = world.time + 20
				if(C == summoner)
					med_hud_set_health()
					med_hud_set_status()

/mob/living/simple_animal/hostile/guardian/healer/ToggleMode()
	if(loc == summoner)
		if(toggle)
			a_intent = INTENT_HARM
			hud_used.action_intent.icon_state = a_intent;
			speed = 0
			damage_transfer = 0.7
			if(adminseal)
				damage_transfer = 0
			melee_damage_lower = 15
			melee_damage_upper = 15
			to_chat(src, "<span class='danger'>You switch to combat mode.</span>")
			toggle = FALSE
		else
			a_intent = INTENT_HELP
			hud_used.action_intent.icon_state = a_intent;
			speed = 1
			damage_transfer = 1
			if(adminseal)
				damage_transfer = 0
			melee_damage_lower = 0
			melee_damage_upper = 0
			to_chat(src, "<span class='danger'>You switch to healing mode.</span>")
			toggle = TRUE
	else
		to_chat(src, "<span class='danger'>You have to be recalled to toggle modes!</span>")

/mob/living/simple_animal/hostile/guardian/healer/verb/Beacon()
	set name = "Place Bluespace Beacon"
	set category = "Guardian"
	set desc = "Mark a floor as your beacon point, allowing you to warp targets to it. Your beacon will not work in unfavorable atmospheric conditions."
	if(beacon_cooldown < world.time)
		var/turf/beacon_loc = get_turf(loc)
		if(istype(beacon_loc, /turf/simulated/floor))
			var/turf/simulated/floor/F = beacon_loc
			F.icon = 'icons/turf/floors.dmi'
			F.name = "bluespace recieving pad"
			F.desc = "A recieving zone for bluespace teleportations. Building a wall over it should disable it."
			F.icon_state = "light_on-w"
			to_chat(src, "<span class='danger'>Beacon placed! You may now warp targets to it, including your user, via Alt+Click. </span>")
			if(beacon)
				beacon.ChangeTurf(/turf/simulated/floor/plating)
			beacon = F
			beacon_cooldown = world.time + default_beacon_cooldown

	else
		to_chat(src, "<span class='danger'>Your power is on cooldown! You must wait another [max(round((beacon_cooldown - world.time)*0.1, 0.1), 0)] seconds before you can place another beacon.</span>")

/mob/living/simple_animal/hostile/guardian/healer/AltClickOn(atom/movable/A)
	if(!istype(A))
		return
	if(loc == summoner)
		to_chat(src, "<span class='danger'>You must be manifested to warp a target!</span>")
		return
	if(!beacon)
		to_chat(src, "<span class='danger'>You need a beacon placed to warp things!</span>")
		return
	if(!Adjacent(A))
		to_chat(src, "<span class='danger'>You must be adjacent to your target!</span>")
		return
	if((A.anchored))
		to_chat(src, "<span class='danger'>Your target can not be anchored!</span>")
		return
	to_chat(src, "<span class='danger'>You begin to warp [A]</span>")
	if(do_mob(src, A, 50))
		if(!A.anchored)
			if(beacon) //Check that the beacon still exists and is in a safe place. No instant kills.
				if(beacon.air)
					var/datum/gas_mixture/Z = beacon.air
					if(Z.oxygen >= 16 && !Z.toxins && Z.carbon_dioxide < 10 && !Z.trace_gases.len)
						if((Z.temperature > 270) && (Z.temperature < 360))
							var/pressure = Z.return_pressure()
							if((pressure > 20) && (pressure < 550))
								new /obj/effect/temp_visual/guardian/phase/out(get_turf(A))
								do_teleport(A, beacon, 0)
								new /obj/effect/temp_visual/guardian/phase(get_turf(A))
						else
							to_chat(src, "<span class='danger'>The beacon isn't in a safe location!</span>")
					else
						to_chat(src, "<span class='danger'>The beacon isn't in a safe location!</span>")
			else
				to_chat(src, "<span class='danger'>You need a beacon to warp things!</span>")
	else
		to_chat(src, "<span class='danger'>You need to hold still!</span>")

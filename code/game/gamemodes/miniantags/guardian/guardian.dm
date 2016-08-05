/mob/living/simple_animal/hostile/guardian
	name = "Guardian Spirit"
	real_name = "Guardian Spirit"
	desc = "A mysterious being that stands by it's charge, ever vigilant."
	speak_emote = list("intones")
	response_help  = "passes through"
	response_disarm = "flails at"
	response_harm   = "punches"
	icon = 'icons/mob/guardian.dmi'
	icon_state = "magicOrange"
	icon_living = "magicOrange"
	icon_dead = "magicOrange"
	speed = 0
	a_intent = I_HARM
	stop_automated_movement = 1
	floating = 1
	attack_sound = 'sound/weapons/punch1.ogg'
	minbodytemp = 0
	maxbodytemp = INFINITY
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	attacktext = "punches"
	maxHealth = INFINITY //The spirit itself is invincible
	health = INFINITY
	environment_smash = 0
	melee_damage_lower = 15
	melee_damage_upper = 15
	AIStatus = AI_OFF
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/ectoplasm = 1)
	var/summoned = FALSE
	var/cooldown = 0
	var/damage_transfer = 1 //how much damage from each attack we transfer to the owner
	var/light_on = 0
	var/luminosity_on = 3
	var/mob/living/summoner
	var/range = 10 //how far from the user the spirit can be
	var/playstyle_string = "You are a standard Guardian. You shouldn't exist!"
	var/magic_fluff_string = " You draw the Coder, symbolizing bugs and errors. This shouldn't happen! Submit a bug report!"
	var/tech_fluff_string = "BOOT SEQUENCE COMPLETE. ERROR MODULE LOADED. THIS SHOULDN'T HAPPEN. Submit a bug report!"
	var/bio_fluff_string = "Your scarabs fail to mutate. This shouldn't happen! Submit a bug report!"
	var/admin_fluff_string = "URK URF!"//the wheels on the bus...
	var/adminseal = FALSE

/mob/living/simple_animal/hostile/guardian/Life() //Dies if the summoner dies
	..()
	if(summoner)
		if(summoner.stat == DEAD)
			to_chat(src, "<span class='danger'>Your summoner has died!</span>")
			visible_message("<span class='danger'><B>The [src] dies along with its user!</B></span>")
			ghostize()
			qdel(src)
	if(summoner)
		if(get_dist(get_turf(summoner),get_turf(src)) <= range)
			return
		else
			to_chat(src, "You moved out of range, and were pulled back! You can only move [range] meters from [summoner.real_name]")
			visible_message("<span class='danger'>The [src] jumps back to its user.</span>")
			Recall()
	if(summoned && !summoner && !adminseal)
		to_chat(src, "<span class='danger'>You somehow lack a summoner! As a result, you dispel!</span>")
		ghostize()
		qdel()

/mob/living/simple_animal/hostile/guardian/Move() //Returns to summoner if they move out of range
	..()
	if(summoner)
		if(get_dist(get_turf(summoner),get_turf(src)) <= range)
			return
		else
			to_chat(src, "You moved out of range, and were pulled back! You can only move [range] meters from [summoner.real_name]")
			visible_message("<span class='danger'>The [src] jumps back to its user.</span>")
			Recall()

/mob/living/simple_animal/hostile/guardian/death(gibbed)
	..()
	to_chat(summoner, "<span class='danger'><B>Your [name] died somehow!</span></B>")
	summoner.death()


/mob/living/simple_animal/hostile/guardian/handle_hud_icons_health()
	if(summoner)
		var/resulthealth
		if(iscarbon(summoner))
			resulthealth = round((abs(config.health_threshold_dead - summoner.health) / abs(config.health_threshold_dead - summoner.maxHealth)) * 100)
		else
			resulthealth = round((summoner.health / summoner.maxHealth) * 100)
		hud_used.guardianhealthdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#efeeef'>[resulthealth]%</font></div>"


/mob/living/simple_animal/hostile/guardian/adjustHealth(amount) //The spirit is invincible, but passes on damage to the summoner
	var/damage = amount * damage_transfer
	if(summoner)
		if(loc == summoner)
			return
		summoner.adjustBruteLoss(damage)
		if(damage)
			to_chat(summoner, "<span class='danger'><B>Your [name] is under attack! You take damage!</span></B>")
			summoner.visible_message("<span class='danger'><B>Blood sprays from [summoner] as [src] takes damage!</B></span>")
		if(summoner.stat == UNCONSCIOUS)
			to_chat(summoner, "<span class='danger'><B>Your body can't take the strain of sustaining [src] in this condition, it begins to fall apart!</span></B>")
			summoner.adjustCloneLoss(damage/2)

/mob/living/simple_animal/hostile/guardian/ex_act(severity, target)
	switch(severity)
		if(1)
			gib()
			return
		if(2)
			adjustBruteLoss(60)

		if(3)
			adjustBruteLoss(30)

/mob/living/simple_animal/hostile/guardian/gib()
	if(summoner)
		to_chat(summoner, "<span class='danger'><B>Your [src] was blown up!</span></B>")
		summoner.Weaken(10)// your fermillier has died! ROLL FOR CON LOSS!
	ghostize()
	qdel(src)

//Manifest, Recall, Communicate

/mob/living/simple_animal/hostile/guardian/proc/Manifest()
	if(cooldown > world.time)
		return
	if(!summoner) return
	if(loc == summoner)
		forceMove(get_turf(summoner))
		src.client.eye = loc
		cooldown = world.time + 30

/mob/living/simple_animal/hostile/guardian/proc/Recall()
	if(cooldown > world.time)
		return
	if(!summoner) return
	new /obj/effect/overlay/temp/guardian/phase/out(get_turf(src))
	forceMove(summoner)
	buckled = null
	cooldown = world.time + 30

/mob/living/simple_animal/hostile/guardian/proc/Communicate()
	var/input = stripped_input(src, "Please enter a message to tell your summoner.", "Guardian", "")
	if(!input) return


	for(var/mob/M in mob_list)
		if(M == summoner)
			to_chat(M, "<span class='changeling'><i>[src]:</i> [input]</span>")
			log_say("Guardian Communication: [key_name(src)] -> [key_name(M)] : [input]")
		else if(M in dead_mob_list)
			to_chat(M, "<span class='changeling'><i>Guardian Communication from <b>[src]</b> ([ghost_follow_link(src, ghost=M)]): [input]</i>")
	to_chat(src, "<span class='changeling'><i>[src]:</i> [input]</span>")

/mob/living/simple_animal/hostile/guardian/proc/ToggleMode()
	to_chat(src, "<span class='danger'><B>You dont have another mode!</span></B>")


/mob/living/proc/guardian_comm()
	set name = "Communicate"
	set category = "Guardian"
	set desc = "Communicate telepathically with your guardian."
	var/input = stripped_input(src, "Please enter a message to tell your guardian.", "Message", "")
	if(!input) return

	for(var/mob/M in mob_list)
		if(istype (M, /mob/living/simple_animal/hostile/guardian))
			var/mob/living/simple_animal/hostile/guardian/G = M
			if(G.summoner == src)
				to_chat(G, "<span class='changeling'><i>[src]:</i> [input]</span>")
				log_say("Guardian Communication: [key_name(src)] -> [key_name(G)] : [input]")

		else if(M in dead_mob_list)
			to_chat(M, "<span class='changeling'><i>Guardian Communication from <b>[src]</b> ([ghost_follow_link(src, ghost=M)]): [input]</i>")
	to_chat(src, "<span class='changeling'><i>[src]:</i> [input]</span>")

/mob/living/proc/guardian_recall()
	set name = "Recall Guardian"
	set category = "Guardian"
	set desc = "Forcibly recall your guardian."
	for(var/mob/living/simple_animal/hostile/guardian/G in mob_list)
		if(G.summoner == src)
			G.Recall()

/mob/living/proc/guardian_reset()
	set name = "Reset Guardian Player (One Use)"
	set category = "Guardian"
	set desc = "Re-rolls which ghost will control your Guardian. One use."

	src.verbs -= /mob/living/proc/guardian_reset
	for(var/mob/living/simple_animal/hostile/guardian/G in mob_list)
		if(G.summoner == src)
			var/list/mob/dead/observer/candidates = pollCandidates("Do you want to play as [G.real_name]?", ROLE_GUARDIAN, 0, 100)
			var/mob/dead/observer/new_stand = null
			if(candidates.len)
				new_stand = pick(candidates)
				to_chat(G, "Your user reset you, and your body was taken over by a ghost. Looks like they weren't happy with your performance.")
				to_chat(src, "Your guardian has been successfully reset.")
				message_admins("[key_name_admin(new_stand)] has taken control of ([key_name_admin(G)])")
				G.ghostize(0)
				G.key = new_stand.key
			else
				to_chat(src, "There were no ghosts willing to take control. Looks like you're stuck with your Guardian for now.")
				spawn(3000)
					verbs += /mob/living/proc/guardian_reset


/mob/living/simple_animal/hostile/guardian/proc/ToggleLight()
	if(!light_on)
		set_light(luminosity_on)
		to_chat(src, "<span class='notice'>You activate your light.</span>")
	else
		set_light(0)
		to_chat(src, "<span class='notice'>You deactivate your light.</span>")
	light_on = !light_on

//////////////////////////TYPES OF GUARDIANS


//Fire. Low damage, low resistance, sets mobs on fire when bumping

/mob/living/simple_animal/hostile/guardian/fire
	a_intent = I_HELP
	melee_damage_lower = 10
	melee_damage_upper = 10
	attack_sound = 'sound/items/Welder.ogg'
	attacktext = "sears"
	damage_transfer = 0.8
	range = 10
	playstyle_string = "As a Chaos type, you have only light damage resistance, but will ignite any enemy you bump into. In addition, your melee attacks will randomly teleport enemies."
	environment_smash = 1
	magic_fluff_string = "..And draw the Wizard, bringer of endless chaos!"
	tech_fluff_string = "Boot sequence complete. Crowd control modules activated. Holoparasite swarm online."
	bio_fluff_string = "Your scarab swarm finishes mutating and stirs to life, ready to sow havoc at random."
	var/toggle = FALSE

/mob/living/simple_animal/hostile/guardian/fire/Life() //Dies if the summoner dies
	..()
	if(summoner)
		summoner.ExtinguishMob()
		summoner.adjust_fire_stacks(-20)

/mob/living/simple_animal/hostile/guardian/fire/ToggleMode()
	if(src.loc == summoner)
		if(toggle)
			to_chat(src, "You switch to dispersion mode, and will teleport victims away from your master.")
			toggle = FALSE
		else
			to_chat(src, "You  switch to deception mode, and will turn your victims against their allies.")
			toggle = TRUE

/mob/living/simple_animal/hostile/guardian/fire/AttackingTarget()
	if(..())
		if(toggle)
			if(ishuman(target) && !summoner)
				spawn(0)
					new /obj/effect/hallucination/delusion(target.loc, target, force_kind="custom", duration=200, skip_nearby=0, custom_icon = src.icon_state, custom_icon_file = src.icon)
		else
			if(prob(45))
				if(istype(target, /atom/movable))
					var/atom/movable/M = target
					if(!M.anchored && M != summoner)
						new /obj/effect/overlay/temp/guardian/phase/out(get_turf(M))
						do_teleport(M, M, 10)
						new /obj/effect/overlay/temp/guardian/phase/out(get_turf(M))

/mob/living/simple_animal/hostile/guardian/fire/Crossed(AM as mob|obj)
	..()
	collision_ignite(AM)

/mob/living/simple_animal/hostile/guardian/fire/Bumped(AM as mob|obj)
	..()
	collision_ignite(AM)

/mob/living/simple_animal/hostile/guardian/fire/Bump(AM as mob|obj)
	..()
	collision_ignite(AM)

/mob/living/simple_animal/hostile/guardian/fire/proc/collision_ignite(AM as mob|obj)
	if(istype(AM, /mob/living/))
		var/mob/living/M = AM
		if(AM != summoner && M.fire_stacks < 7)
			M.fire_stacks = 7
			M.IgniteMob()

/mob/living/simple_animal/hostile/guardian/fire/Bump(AM as mob|obj)
	..()
	collision_ignite(AM)
//Standard

/mob/living/simple_animal/hostile/guardian/punch
	melee_damage_lower = 20
	melee_damage_upper = 20
	damage_transfer = 0.5
	playstyle_string = "As a standard type you have no special abilities, but have a high damage resistance and a powerful attack capable of smashing through walls."
	environment_smash = 2
	magic_fluff_string = "..And draw the Assistant, faceless and generic, but never to be underestimated."
	tech_fluff_string = "Boot sequence complete. Standard combat modules loaded. Holoparasite swarm online."
	bio_fluff_string = "Your scarab swarm stirs to life, ready to tear apart your enemies."
	var/battlecry = "AT"


/mob/living/simple_animal/hostile/guardian/punch/sealpunch
	name = "Seal Sprit"
	real_name = "Seal Sprit"
	icon = 'icons/mob/animal.dmi'
	icon_living = "seal"
	icon_state = "seal"
	attacktext = "slaps"
	speak_emote = list("barks")
	melee_damage_lower = 0
	melee_damage_upper = 0
	melee_damage_type = STAMINA
	damage_transfer = 0
	playstyle_string = "As a standard type you have no special abilities, but have a high damage resistance and a powerful attack capable of smashing through walls."
	environment_smash = 2
	battlecry = "URK"
	adminseal = TRUE

/mob/living/simple_animal/hostile/guardian/punch/verb/Battlecry()
	set name = "Set Battlecry"
	set category = "Guardian"
	set desc = "Choose what you shout as you punch"
	var/input = stripped_input(src,"What do you want your battlecry to be? Max length of 5 characters.", ,"", 6)
	if(input)
		battlecry = input



/mob/living/simple_animal/hostile/guardian/punch/AttackingTarget()
	..()
	if(iscarbon(target) && target != summoner)
		if(length(battlecry) > 11)//no more then 11 letters in a battle cry.
			src.visible_message("<span class='danger'><B>[src] punches [target]!</B></span>")
		else
			src.say("[src.battlecry][src.battlecry][src.battlecry][src.battlecry][src.battlecry]")
		playsound(loc, src.attack_sound, 50, 1, 1)
		playsound(loc, src.attack_sound, 50, 1, 1)
		playsound(loc, src.attack_sound, 50, 1, 1)
		playsound(loc, src.attack_sound, 50, 1, 1)

//Healer

/mob/living/simple_animal/hostile/guardian/healer
	a_intent = I_HARM
	friendly = "heals"
	speed = 0
	melee_damage_lower = 15
	melee_damage_upper = 15
	playstyle_string = "As a Support type, you may toggle your basic attacks to a healing mode. In addition, Alt-Clicking on an adjacent mob will warp them to your bluespace beacon after a short delay."
	magic_fluff_string = "..And draw the CMO, a potent force of life...and death."
	tech_fluff_string = "Boot sequence complete. Medical modules active. Bluespace modules activated. Holoparasite swarm online."
	bio_fluff_string = "Your scarab swarm finishes mutating and stirs to life, capable of mending wounds and travelling via bluespace."
	var/turf/simulated/floor/beacon
	var/beacon_cooldown = 0
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
	a_intent = I_HARM
	friendly = "heals"
	speed = 0
	melee_damage_lower = 0
	melee_damage_upper = 0
	melee_damage_type = STAMINA
	adminseal = TRUE


/mob/living/simple_animal/hostile/guardian/healer/New()
	..()

/mob/living/simple_animal/hostile/guardian/healer/Life()
	..()
	var/datum/atom_hud/medsensor = huds[DATA_HUD_MEDICAL_ADVANCED]
	medsensor.add_hud_to(src)

/mob/living/simple_animal/hostile/guardian/healer/AttackingTarget()
	..()
	if(toggle == TRUE)
		if(src.loc == summoner)
			to_chat(src, "<span class='danger'><B>You must be manifested to heal!</span></B>")
			return
		if(iscarbon(target))
			src.changeNext_move(CLICK_CD_MELEE)
			if(heal_cooldown <= world.time && !stat)
				var/mob/living/carbon/C = target
				C.adjustBruteLoss(-5)
				C.adjustFireLoss(-5)
				C.adjustOxyLoss(-5)
				C.adjustToxLoss(-5)
				heal_cooldown = world.time + 20

/mob/living/simple_animal/hostile/guardian/healer/ToggleMode()
	if(src.loc == summoner)
		if(toggle)
			a_intent = I_HARM
			speed = 0
			damage_transfer = 0.7
			if(src.adminseal)
				damage_transfer = 0
			melee_damage_lower = 15
			melee_damage_upper = 15
			to_chat(src, "<span class='danger'><B>You switch to combat mode.</span></B>")
			toggle = FALSE
		else
			a_intent = I_HELP
			speed = 1
			damage_transfer = 1
			if(src.adminseal)
				damage_transfer = 0
			melee_damage_lower = 0
			melee_damage_upper = 0
			to_chat(src, "<span class='danger'><B>You switch to healing mode.</span></B>")
			toggle = TRUE
	else
		to_chat(src, "<span class='danger'><B>You have to be recalled to toggle modes!</span></B>")


/mob/living/simple_animal/hostile/guardian/healer/verb/Beacon()
	set name = "Place Bluespsace Beacon"
	set category = "Guardian"
	set desc = "Mark a floor as your beacon point, allowing you to warp targets to it. Your beacon will not work in unfavorable atmospheric conditions."
	if(beacon_cooldown<world.time)
		var/turf/beacon_loc = get_turf(src.loc)
		if(istype(beacon_loc, /turf/simulated/floor))
			var/turf/simulated/floor/F = beacon_loc
			F.icon = 'icons/turf/floors.dmi'
			F.name = "bluespace recieving pad"
			F.desc = "A recieving zone for bluespace teleportations. Building a wall over it should disable it."
			F.icon_state = "light_on-w"
			to_chat(src, "<span class='danger'><B>Beacon placed! You may now warp targets to it, including your user, via Alt+Click. </span></B>")
			if(beacon)
				beacon.ChangeTurf(/turf/simulated/floor/plating)
			beacon = F
			beacon_cooldown = world.time+3000

	else
		to_chat(src, "<span class='danger'><B>Your power is on cooldown. You must wait five minutes between placing beacons.</span></B>")

/mob/living/simple_animal/hostile/guardian/healer/AltClickOn(atom/movable/A)
	if(!istype(A))
		return
	if(src.loc == summoner)
		to_chat(src, "<span class='danger'><B>You must be manifested to warp a target!</span></B>")
		return
	if(!beacon)
		to_chat(src, "<span class='danger'><B>You need a beacon placed to warp things!</span></B>")
		return
	if(!Adjacent(A))
		to_chat(src, "<span class='danger'><B>You must be adjacent to your target!</span></B>")
		return
	if((A.anchored))
		to_chat(src, "<span class='danger'><B>Your target can not be anchored!</span></B>")
		return
	to_chat(src, "<span class='danger'><B>You begin to warp [A]</span></B>")
	if(do_mob(src, A, 50))
		if(!A.anchored)
			if(src.beacon) //Check that the beacon still exists and is in a safe place. No instant kills.
				if(beacon.air)
					var/datum/gas_mixture/Z = beacon.air
					if(Z.oxygen >= 16 && !Z.toxins && Z.carbon_dioxide < 10 && !Z.trace_gases.len)
						if((Z.temperature > 270) && (Z.temperature < 360))
							var/pressure = Z.return_pressure()
							if((pressure > 20) && (pressure < 550))
								new /obj/effect/overlay/temp/guardian/phase/out(get_turf(A))
								do_teleport(A, beacon, 0)
								new /obj/effect/overlay/temp/guardian/phase(get_turf(A))
						else
							to_chat(src, "<span class='danger'><B>The beacon isn't in a safe location!</span></B>")
					else
						to_chat(src, "<span class='danger'><B>The beacon isn't in a safe location!</span></B>")
			else
				to_chat(src, "<span class='danger'><B>You need a beacon to warp things!</span></B>")
	else
		to_chat(src, "<span class='danger'><B>You need to hold still!</span></B>")


///////////////////Ranged

/obj/item/projectile/guardian
	name = "crystal spray"
	icon_state = "guardian"
	damage = 5
	damage_type = BRUTE
	armour_penetration = 100

/mob/living/simple_animal/hostile/guardian/ranged
	a_intent = I_HELP
	friendly = "quietly assesses"
	melee_damage_lower = 10
	melee_damage_upper = 10
	damage_transfer = 0.9
	projectiletype = /obj/item/projectile/guardian
	ranged_cooldown_cap = 1
	projectilesound = 'sound/effects/hit_on_shattered_glass.ogg'
	ranged = 1
	rapid = 1
	range = 13
	see_invisible = SEE_INVISIBLE_MINIMUM
	see_in_dark = 8
	playstyle_string = "As a ranged type, you have only light damage resistance, but are capable of spraying shards of crystal at incredibly high speed. You can also deploy surveillance snares to monitor enemy movement. Finally, you can switch to scout mode, in which you can't attack, but can move without limit."
	magic_fluff_string = "..And draw the Sentinel, an alien master of ranged combat."
	tech_fluff_string = "Boot sequence complete. Ranged combat modules active. Holoparasite swarm online."
	bio_fluff_string = "Your scarab swarm finishes mutating and stirs to life, capable of spraying shards of crystal."
	var/list/snares = list()
	var/toggle = FALSE

/mob/living/simple_animal/hostile/guardian/ranged/ToggleMode()
	if(src.loc == summoner)
		if(toggle)
			ranged = 1
			melee_damage_lower = 10
			melee_damage_upper = 10
			alpha = 255
			range = 13
			incorporeal_move = 0
			to_chat(src, "<span class='danger'><B>You switch to combat mode.</span></B>")
			toggle = FALSE
		else
			ranged = 0
			melee_damage_lower = 0
			melee_damage_upper = 0
			alpha = 60
			range = 255
			incorporeal_move = 1
			to_chat(src, "<span class='danger'><B>You switch to scout mode.</span></B>")
			toggle = TRUE
	else
		to_chat(src, "<span class='danger'><B>You have to be recalled to toggle modes!</span></B>")

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
	if(src.snares.len <6)
		var/turf/snare_loc = get_turf(src.loc)
		var/obj/item/effect/snare/S = new /obj/item/effect/snare(snare_loc)
		S.spawner = src
		S.name = "[get_area(snare_loc)] trap ([rand(1, 1000)])"
		src.snares |= S
		to_chat(src, "<span class='danger'><B>Surveillance trap deployed!</span></B>")
	else
		to_chat(src, "<span class='danger'><B>You have too many traps deployed. Delete some first.</span></B>")

/mob/living/simple_animal/hostile/guardian/ranged/verb/DisarmSnare()
	set name = "Remove Surveillance Trap"
	set category = "Guardian"
	set desc = "Disarm unwanted surveillance traps."
	var/picked_snare = input(src, "Pick which trap to disarm", "Disarm Trap") as null|anything in src.snares
	if(picked_snare)
		src.snares -= picked_snare
		qdel(picked_snare)
		to_chat(src, "<span class='danger'><B>Snare disarmed.</span></B>")

/obj/item/effect/snare
	name = "snare"
	desc = "You shouldn't be seeing this!"
	var/mob/living/spawner
	invisibility = 1


/obj/item/effect/snare/Crossed(AM as mob|obj)
	if(istype(AM, /mob/living/))
		var/turf/snare_loc = get_turf(src.loc)
		if(spawner)
			to_chat(spawner, "<span class='danger'><B>[AM] has crossed your surveillance trap at [get_area(snare_loc)].</span></B>")
			if(istype(spawner, /mob/living/simple_animal/hostile/guardian))
				var/mob/living/simple_animal/hostile/guardian/G = spawner
				if(G.summoner)
					to_chat(G.summoner, "<span class='danger'><B>[AM] has crossed your surveillance trap at [get_area(snare_loc)].</span></B>")

////Bomb

/mob/living/simple_animal/hostile/guardian/bomb
	melee_damage_lower = 15
	melee_damage_upper = 15
	damage_transfer = 0.6
	range = 13
	playstyle_string = "As an explosive type, you have only moderate close combat abilities, but are capable of converting any adjacent item into a disguised bomb via alt click."
	magic_fluff_string = "..And draw the Scientist, master of explosive death."
	tech_fluff_string = "Boot sequence complete. Explosive modules active. Holoparasite swarm online."
	bio_fluff_string = "Your scarab swarm finishes mutating and stirs to life, capable of stealthily booby trapping items."
	var/bomb_cooldown = 0

/mob/living/simple_animal/hostile/guardian/bomb/AltClickOn(atom/movable/A)
	if(!istype(A))
		return
	if(src.loc == summoner)
		to_chat(src, "<span class='danger'><B>You must be manifested to create bombs!</B></span>")
		return
	if(istype(A, /obj/))
		if(bomb_cooldown <= world.time && !stat)
			var/obj/item/weapon/guardian_bomb/B = new /obj/item/weapon/guardian_bomb(get_turf(A))
			to_chat(src, "<span class='danger'><B>Success! Bomb on \the [A] armed!</B></span>")
			if(summoner)
				to_chat(summoner, "<span class='warning'>Your guardian has primed \the [A] to explode!</span>")
			bomb_cooldown = world.time + 200
			B.spawner = src
			B.disguise (A)
		else
			to_chat(src, "<span class='danger'><B>Your powers are on cooldown! You must wait 20 seconds between bombs.</B></span>")

/obj/item/weapon/guardian_bomb
	name = "bomb"
	desc = "You shouldn't be seeing this!"
	var/obj/stored_obj
	var/mob/living/spawner


/obj/item/weapon/guardian_bomb/proc/disguise(var/obj/A)
	A.loc = src
	stored_obj = A
	anchored = A.anchored
	density = A.density
	appearance = A.appearance
	spawn(600)
		if(src)
			stored_obj.loc = get_turf(src.loc)
			to_chat(spawner, "<span class='danger'><B>Failure! Your trap on \the [stored_obj] didn't catch anyone this time.</B></span>")
			qdel(src)

/obj/item/weapon/guardian_bomb/proc/detonate(var/mob/living/user)
	to_chat(user, "<span class='danger'><B>The [src] was boobytrapped!</B></span>")
	if(istype(spawner, /mob/living/simple_animal/hostile/guardian))
		var/mob/living/simple_animal/hostile/guardian/G = spawner
		if(user == G.summoner)
			to_chat(user, "<span class='danger'>You knew this because of your link with your guardian, so you smartly defuse the bomb.</span>")
			stored_obj.loc = get_turf(src.loc)
			qdel(src)
			return
	to_chat(spawner, "<span class='danger'><B>Success! Your trap on \the [src] caught [user]!</B></span>")
	stored_obj.loc = get_turf(src.loc)
	playsound(get_turf(src),'sound/effects/Explosion2.ogg', 200, 1)
	user.ex_act(2)
	qdel(src)

/obj/item/weapon/guardian_bomb/attackby(mob/living/user)
	detonate(user)
	return

/obj/item/weapon/guardian_bomb/pickup(mob/living/user)
	detonate(user)
	return

/obj/item/weapon/guardian_bomb/examine(mob/user)
	stored_obj.examine(user)
	if(get_dist(user,src)<=2)
		to_chat(user, "<span class='notice'>Looks odd!</span>")


////////Creation

/obj/item/weapon/guardiancreator
	name = "deck of tarot cards"
	desc = "An enchanted deck of tarot cards, rumored to be a source of unimaginable power. "
	icon = 'icons/obj/toy.dmi'
	icon_state = "deck_syndicate_full"
	var/used = FALSE
	var/theme = "magic"
	var/mob_name = "Guardian Spirit"
	var/use_message = "You shuffle the deck..."
	var/used_message = "All the cards seem to be blank now."
	var/failure_message = "..And draw a card! It's...blank? Maybe you should try again later."
	var/ling_failure = "The deck refuses to respond to a souless creature such as you."
	var/list/possible_guardians = list("Chaos", "Standard", "Ranged", "Support", "Explosive")
	var/random = TRUE

/obj/item/weapon/guardiancreator/attack_self(mob/living/user)
	for(var/mob/living/simple_animal/hostile/guardian/G in living_mob_list)
		if(G.summoner == user)
			to_chat(user, "You already have a [mob_name]!")
			return
	if(user.mind && (user.mind.changeling || user.mind.vampire))
		to_chat(user, "[ling_failure]")
		return
	if(used == TRUE)
		to_chat(user, "[used_message]")
		return
	used = TRUE
	to_chat(user, "[use_message]")
	var/list/mob/dead/observer/candidates = pollCandidates("Do you want to play as the [mob_name] of [user.real_name]?", ROLE_GUARDIAN, 0, 100)
	var/mob/dead/observer/theghost = null

	if(candidates.len)
		theghost = pick(candidates)
		spawn_guardian(user, theghost.key)
	else
		to_chat(user, "[failure_message]")
		used = FALSE


/obj/item/weapon/guardiancreator/proc/spawn_guardian(var/mob/living/user, var/key)
	var/gaurdiantype = "Standard"
	if(random)
		gaurdiantype = pick(possible_guardians)
	else
		gaurdiantype = input(user, "Pick the type of [mob_name]", "[mob_name] Creation") as null|anything in possible_guardians
	var/pickedtype = /mob/living/simple_animal/hostile/guardian/punch
	switch(gaurdiantype)

		if("Chaos")
			pickedtype = /mob/living/simple_animal/hostile/guardian/fire

		if("Standard")
			pickedtype = /mob/living/simple_animal/hostile/guardian/punch

		if("Ranged")
			pickedtype = /mob/living/simple_animal/hostile/guardian/ranged

		if("Support")
			pickedtype = /mob/living/simple_animal/hostile/guardian/healer

		if("Explosive")
			pickedtype = /mob/living/simple_animal/hostile/guardian/bomb

	var/mob/living/simple_animal/hostile/guardian/G = new pickedtype(user)
	G.summoner = user
	G.summoned = TRUE
	G.key = key
	to_chat(G, "You are a [mob_name] bound to serve [user.real_name].")
	to_chat(G, "You are capable of manifesting or recalling to your master with verbs in the Guardian tab. You will also find a verb to communicate with them privately there.")
	to_chat(G, "While personally invincible, you will die if [user.real_name] does, and any damage dealt to you will have a portion passed on to them as you feed upon them to sustain yourself.")
	to_chat(G, "[G.playstyle_string]")
	G.faction = user.faction
	user.verbs += /mob/living/proc/guardian_comm
	user.verbs += /mob/living/proc/guardian_recall
	user.verbs += /mob/living/proc/guardian_reset

	var/color
	var/picked_name
	var/picked_color = pick("#FFFFFF","#000000","#808080","#A52A2A","#FF0000","#8B0000","#DC143C","#FFA500","#FFFF00","#008000","#00FF00","#006400","#00FFFF","#0000FF","#000080","#008080","#800080","#4B0082")

	switch(theme)
		if("magic")
			color = pick("Pink", "Red", "Orange", "Green", "Blue")
			picked_name = pick("Aries", "Leo", "Sagittarius", "Taurus", "Virgo", "Capricorn", "Gemini", "Libra", "Aquarius", "Cancer", "Scorpio", "Pisces")

			G.name = "[picked_name] [color]"
			G.real_name = "[picked_name] [color]"
			G.icon_living = "[theme][color]"
			G.icon_state = "[theme][color]"
			G.icon_dead = "[theme][color]"

			to_chat(user, "[G.magic_fluff_string].")
		if("tech")
			color = pick("Rose", "Peony", "Lily", "Daisy", "Zinnia", "Ivy", "Iris", "Petunia", "Violet", "Lilac", "Orchid") //technically not colors, just flowers that can be specific colors
			picked_name = pick("Gallium", "Indium", "Thallium", "Bismuth", "Aluminium", "Mercury", "Iron", "Silver", "Zinc", "Titanium", "Chromium", "Nickel", "Platinum", "Tellurium", "Palladium", "Rhodium", "Cobalt", "Osmium", "Tungsten", "Iridium")

			G.name = "[picked_name] [color]"
			G.real_name = "[picked_name] [color]"
			G.icon_living = "[theme][color]"
			G.icon_state = "[theme][color]"
			G.icon_dead = "[theme][color]"

			to_chat(user, "[G.tech_fluff_string].")
			G.speak_emote = list("states")
		if("bio")
			G.icon = 'icons/mob/mob.dmi'
			picked_name = pick("brood", "hive", "nest")
			to_chat(user, "[G.bio_fluff_string].")
			G.name = "[picked_name] swarm"
			G.color = picked_color
			G.real_name = "[picked_name] swarm"
			G.icon_living = "headcrab"
			G.icon_state = "headcrab"
			G.attacktext = "swarms"
			G.speak_emote = list("chitters")

/obj/item/weapon/guardiancreator/choose
	random = FALSE

/obj/item/weapon/guardiancreator/tech
	name = "holoparasite injector"
	desc = "It contains alien nanoswarm of unknown origin. Though capable of near sorcerous feats via use of hardlight holograms and nanomachines, it requires an organic host as a home base and source of fuel."
	icon = 'icons/obj/hypo.dmi'
	icon_state = "combat_hypo"
	theme = "tech"
	mob_name = "Holoparasite"
	use_message = "You start to power on the injector..."
	used_message = "The injector has already been used."
	failure_message = "<B>...ERROR. BOOT SEQUENCE ABORTED. AI FAILED TO INTIALIZE. PLEASE CONTACT SUPPORT OR TRY AGAIN LATER.</B>"
	ling_failure = "The holoparasites recoil in horror. They want nothing to do with a creature like you."

/obj/item/weapon/guardiancreator/tech/choose
	random = FALSE

/obj/item/weapon/guardiancreator/biological
	name = "scarab egg cluster"
	desc = "A parasitic species that will nest in the closest living creature upon birth. While not great for your health, they'll defend their new 'hive' to the death."
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "eggs"
	theme = "bio"
	mob_name = "Scarab Swarm"
	use_message = "The eggs begin to twitch..."
	used_message = "The cluster already hatched."
	failure_message = "<B>...but soon settles again. Guess they weren't ready to hatch after all.</B>"

/obj/item/weapon/guardiancreator/biological/choose
	random = FALSE


/obj/item/weapon/paper/guardian
	name = "Holoparasite Guide"
	icon_state = "paper"
	info = {"<b>A list of Holoparasite Types</b><br>

 <br>
 <b>Chaos</b>: Ignites mobs on touch. teleports them at random on attack. Automatically extinguishes the user if they catch fire.<br>
 <br>
 <b>Standard</b>:Devestating close combat attacks and high damage resist. No special powers.<br>
 <br>
 <b>Ranged</b>: Has two modes. Ranged: Extremely weak, highly spammable projectile attack. Scout: Can not attack, but can move through walls. Can lay surveillance snares in either mode.<br>
 <br>
 <b>Support</b>:Has two modes. Combat: Medium power attacks and damage resist. Healer: Attacks heal damage, but low damage resist and slow movemen. Can deploy a bluespace beacon and warp targets to it (including you) in either mode.<br>
 <br>
 <b>Explosive</b>: High damage resist and medium power attack. Can turn any object into a bomb, dealing explosive damage to the next person to touch it. The object will return to normal after the trap is triggered.<br>
"}

/obj/item/weapon/paper/guardian/update_icon()
	return


/obj/item/weapon/storage/box/syndie_kit/guardian
	name = "holoparasite injector kit"

/obj/item/weapon/storage/box/syndie_kit/guardian/New()
	..()
	new /obj/item/weapon/guardiancreator/tech/choose(src)
	new /obj/item/weapon/paper/guardian(src)
	return

#define COMBAT 0
#define HEALING 1
#define SURGICAL 2

/mob/living/simple_animal/hostile/guardian/healer
	friendly = "heals"
	speed = 0
	damage_transfer = 0.7
	melee_damage_lower = 15
	melee_damage_upper = 15
	playstyle_string = "As a <b>Support</b> type, you may toggle your basic attacks to a healing mode, or a surgical mode. In addition, Alt-Clicking on an adjacent mob will warp them to your bluespace beacon after a short delay."
	magic_fluff_string = "..And draw the CMO, a potent force of life...and death."
	tech_fluff_string = "Boot sequence complete. Medical modules active. Bluespace modules activated. Holoparasite swarm online."
	bio_fluff_string = "Your scarab swarm finishes mutating and stirs to life, capable of mending wounds and travelling via bluespace."
	var/obj/effect/bluespace_beacon/beacon
	var/beacon_cooldown = 0
	var/default_beacon_cooldown = 300 SECONDS
	var/toggle = COMBAT
	var/heal_cooldown = 0
	var/surgical_cooldown = 0

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
	admin_spawned = TRUE

/mob/living/simple_animal/hostile/guardian/healer/Initialize(mapload, mob/living/host)
	. = ..()
	AddSpell(new /obj/effect/proc_holder/spell/summon_guardian_beacon(null))

/mob/living/simple_animal/hostile/guardian/healer/Destroy()
	QDEL_NULL(beacon)
	return ..()

/mob/living/simple_animal/hostile/guardian/healer/Life(seconds, times_fired)
	..()
	var/datum/atom_hud/medsensor = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	medsensor.add_hud_to(src)

/mob/living/simple_animal/hostile/guardian/healer/Stat()
	..()
	if(statpanel("Status"))
		if(beacon_cooldown >= world.time)
			stat(null, "Bluespace Beacon Cooldown Remaining: [max(round((beacon_cooldown - world.time) * 0.1, 0.1), 0)] seconds")
		if(surgical_cooldown >= world.time)
			stat(null, "Surgical Cooldown Remaining: [max(round((surgical_cooldown - world.time) * 0.1, 0.1), 0)] seconds")

/mob/living/simple_animal/hostile/guardian/healer/AttackingTarget()
	. = ..()
	if(loc == summoner)
		to_chat(src, "<span class='danger'>You must be manifested to heal!</span>")
		return
	if(toggle == HEALING)
		if(iscarbon(target))
			changeNext_move(1.5 SECONDS)
			if(heal_cooldown <= world.time && !stat)
				var/mob/living/carbon/human/C = target
				C.adjustBruteLoss(-5, robotic=1)
				C.adjustFireLoss(-5, robotic=1)
				C.adjustOxyLoss(-5)
				C.adjustToxLoss(-5)
				heal_cooldown = world.time + 1.5 SECONDS
				if(C == summoner)
					med_hud_set_health()
					med_hud_set_status()
	if(toggle == SURGICAL)
		if(!iscarbon(target))
			return
		var/mob/living/carbon/human/C = target
		if(surgical_cooldown <= world.time && !stat)
			to_chat(src, "<span class='notice'>You begin to do a mass repair on [C], keep them still!</span>")
			surgical_cooldown  = world.time + 10 SECONDS
			if(!do_after_once(src, 10 SECONDS, target = src))
				return
			for(var/obj/item/organ/external/E in C.bodyparts)
				if(E.status & (ORGAN_INT_BLEEDING | ORGAN_BROKEN | ORGAN_SPLINTED | ORGAN_BURNT))
					E.rejuvenate() //Repair it completely.
			surgical_cooldown = world.time + 3 MINUTES


/mob/living/simple_animal/hostile/guardian/healer/ToggleMode()
	if(loc == summoner)
		switch(toggle)
			if(SURGICAL)
				a_intent = INTENT_HARM
				hud_used.action_intent.icon_state = a_intent
				speed = 0
				melee_damage_lower = 15
				melee_damage_upper = 15
				to_chat(src, "<span class='danger'>You switch to combat mode.</span>")
				toggle = COMBAT
			if(COMBAT)
				a_intent = INTENT_HELP
				hud_used.action_intent.icon_state = a_intent
				speed = 1
				melee_damage_lower = 0
				melee_damage_upper = 0
				to_chat(src, "<span class='danger'>You switch to healing mode.</span>")
				toggle = HEALING
			if(HEALING)
				to_chat(src, "<span class='danger'>You switch to surgical. You no longer heal on punch, but can do a big critical injury healing on a long cooldown.</span>")
				toggle = SURGICAL
	else
		to_chat(src, "<span class='danger'>You have to be recalled to toggle modes!</span>")

/obj/effect/bluespace_beacon
	name = "bluespace receiving pad"
	desc = "A receiving zone for bluespace teleportations. Building a wall over it should disable it."
	icon = 'icons/turf/floors.dmi'
	icon_state = "light_on"
	plane = FLOOR_PLANE

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
	if(do_mob(src, A, 5 SECONDS))
		if(!A.anchored)
			if(!beacon) //Check that the beacon still exists and is in a safe place. No instant kills.
				to_chat(src, "<span class='danger'>You need a beacon to warp things!</span>")
				return
			var/turf/T = get_turf(beacon)
			if(T.is_safe()) // Walls always return false
				new /obj/effect/temp_visual/guardian/phase/out(get_turf(A))
				do_teleport(A, beacon, 0)
				new /obj/effect/temp_visual/guardian/phase(get_turf(A))
				return
			to_chat(src, "<span class='danger'>The beacon isn't in a safe location!</span>")
			return
	else
		to_chat(src, "<span class='danger'>You need to hold still!</span>")


#undef COMBAT
#undef HEALING
#undef SURGICAL

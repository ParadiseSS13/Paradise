/obj/effect/proc_holder/spell/wizard/targeted/projectile/magic_missile
	name = "Magic Missile"
	desc = "This spell fires several, slow moving, magic projectiles at nearby targets."

	school = "evocation"
	charge_max = 150
	clothes_req = 1
	invocation = "FORTI GY AMA"
	invocation_type = "shout"
	range = 7
	cooldown_min = 90 //15 deciseconds reduction per rank

	max_targets = 0

	proj_icon_state = "magicm"
	proj_name = "a magic missile"
	proj_lingering = 1
	proj_type = "/obj/effect/proc_holder/spell/wizard/targeted/inflict_handler/magic_missile"

	proj_lifespan = 20
	proj_step_delay = 5

	proj_trail = 1
	proj_trail_lifespan = 5
	proj_trail_icon_state = "magicmd"

	action_icon_state = "magicm"

/obj/effect/proc_holder/spell/wizard/targeted/inflict_handler/magic_missile
	amt_weakened = 3
	amt_dam_fire = 10

/obj/effect/proc_holder/spell/wizard/noclothes
	name = "No Clothes"
	desc = "This always-on spell allows you to cast magic without your garments."

/obj/effect/proc_holder/spell/wizard/targeted/genetic/mutate
	name = "Mutate"
	desc = "This spell causes you to turn into a hulk and gain laser vision for a short while."

	school = "transmutation"
	charge_max = 400
	clothes_req = 1
	invocation = "BIRUZ BENNAR"
	invocation_type = "shout"
	message = "\blue You feel strong! You feel a pressure building behind your eyes!"
	range = -1
	include_user = 1
	centcom_cancast = 0

	mutations = list(LASER, HULK)
	duration = 300
	cooldown_min = 300 //25 deciseconds reduction per rank

	action_icon_state = "mutate"

/obj/effect/proc_holder/spell/wizard/targeted/inflict_handler/disintegrate
	name = "Disintegrate"
	desc = "This spell instantly kills somebody adjacent to you with the vilest of magick."

	school = "evocation"
	charge_max = 600
	clothes_req = 1
	invocation = "EI NATH"
	invocation_type = "shout"
	range = 1
	cooldown_min = 200 //100 deciseconds reduction per rank

	destroys = "gib_brain"

	sparks_spread = 1
	sparks_amt = 4

	action_icon_state = "gib"

/obj/effect/proc_holder/spell/wizard/targeted/smoke
	name = "Smoke"
	desc = "This spell spawns a cloud of choking smoke at your location and does not require wizard garb."

	school = "conjuration"
	charge_max = 120
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = -1
	include_user = 1
	cooldown_min = 20 //25 deciseconds reduction per rank

	smoke_spread = 2
	smoke_amt = 10

	action_icon_state = "smoke"

/obj/effect/proc_holder/spell/wizard/targeted/emplosion/disable_tech
	name = "Disable Tech"
	desc = "This spell disables all weapons, cameras and most other technology in range."
	charge_max = 400
	clothes_req = 1
	invocation = "NEC CANTIO"
	invocation_type = "shout"
	range = -1
	include_user = 1
	cooldown_min = 200 //50 deciseconds reduction per rank

	emp_heavy = 6
	emp_light = 10

	action_icon_state = "tech"

/obj/effect/proc_holder/spell/wizard/targeted/turf_teleport/blink
	name = "Blink"
	desc = "This spell randomly teleports you a short distance."

	school = "abjuration"
	charge_max = 20
	clothes_req = 1
	invocation = "none"
	invocation_type = "none"
	range = -1
	include_user = 1
	cooldown_min = 5 //4 deciseconds reduction per rank


	smoke_spread = 1
	smoke_amt = 1

	inner_tele_radius = 0
	outer_tele_radius = 6

	centcom_cancast = 0 //prevent people from getting to centcom

	action_icon_state = "blink"

/obj/effect/proc_holder/spell/wizard/targeted/area_teleport/teleport
	name = "Teleport"
	desc = "This spell teleports you to a type of area of your selection."

	school = "abjuration"
	charge_max = 600
	clothes_req = 1
	invocation = "SCYAR NILA"
	invocation_type = "shout"
	range = -1
	include_user = 1
	cooldown_min = 200 //100 deciseconds reduction per rank

	smoke_spread = 1
	smoke_amt = 5

	action_icon_state = "spell_teleport"

/obj/effect/proc_holder/spell/wizard/aoe_turf/conjure/forcewall
	name = "Forcewall"
	desc = "This spell creates an unbreakable wall that lasts for 30 seconds and does not need wizard garb."

	school = "transmutation"
	charge_max = 100
	clothes_req = 0
	invocation = "TARCOL MINTI ZHERI"
	invocation_type = "whisper"
	range = 0
	cooldown_min = 50 //12 deciseconds reduction per rank

	summon_type = list("/obj/effect/forcefield")
	summon_lifespan = 300

	action_icon_state = "spell_forcewall"

/obj/effect/proc_holder/spell/wizard/aoe_turf/conjure/carp
	name = "Summon Carp"
	desc = "This spell conjures a simple carp."

	school = "conjuration"
	charge_max = 1200
	clothes_req = 1
	invocation = "NOUK FHUNMM SACP RISSKA"
	invocation_type = "shout"
	range = 1

	summon_type = list(/mob/living/simple_animal/hostile/carp)


/obj/effect/proc_holder/spell/wizard/aoe_turf/conjure/construct
	name = "Artificer"
	desc = "This spell conjures a construct which may be controlled by Shades"

	school = "conjuration"
	charge_max = 600
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = 0

	summon_type = list(/obj/structure/constructshell)

	action_icon_state = "artificer"

/obj/effect/proc_holder/spell/wizard/aoe_turf/conjure/creature
	name = "Summon Creature Swarm"
	desc = "This spell tears the fabric of reality, allowing horrific daemons to spill forth"

	school = "conjuration"
	charge_max = 1200
	clothes_req = 0
	invocation = "IA IA"
	invocation_type = "shout"
	summon_amt = 10
	range = 3

	summon_type = list(/mob/living/simple_animal/hostile/creature)

/obj/effect/proc_holder/spell/wizard/targeted/trigger/blind
	name = "Blind"
	desc = "This spell temporarily blinds a single person and does not require wizard garb."

	school = "transmutation"
	charge_max = 300
	clothes_req = 0
	invocation = "STI KALY"
	invocation_type = "whisper"
	message = "\blue Your eyes cry out in pain!"
	cooldown_min = 50 //12 deciseconds reduction per rank

	starting_spells = list("/obj/effect/proc_holder/spell/wizard/targeted/inflict_handler/blind","/obj/effect/proc_holder/spell/wizard/targeted/genetic/blind")

	action_icon_state = "blind"

/obj/effect/proc_holder/spell/wizard/targeted/inflict_handler/blind
	amt_eye_blind = 10
	amt_eye_blurry = 20

/obj/effect/proc_holder/spell/wizard/targeted/genetic/blind
	disabilities = 1
	duration = 300

/obj/effect/proc_holder/spell/wizard/targeted/inflict_handler/flesh_to_stone
	name = "Flesh to Stone"
	desc = "This spell turns a single person into an inert statue for a long period of time."

	school = "transmutation"
	charge_max = 600
	clothes_req = 1
	range = 2
	invocation = "STAUN EI"
	invocation_type = "shout"
	amt_stunned = 2//just exists to make sure the statue "catches" them
	cooldown_min = 200 //100 deciseconds reduction per rank

	summon_type = "/obj/structure/closet/statue"

	action_icon_state = "statue"

/obj/effect/proc_holder/spell/wizard/dumbfire/fireball
	name = "Fireball"
	desc = "This spell fires a fireball at a target and does not require wizard garb."

	school = "evocation"
	charge_max = 60
	clothes_req = 0
	invocation = "ONI SOMA"
	invocation_type = "shout"
	range = 20
	cooldown_min = 20 //10 deciseconds reduction per rank

	proj_icon_state = "fireball"
	proj_name = "a fireball"
	proj_type = "/obj/effect/proc_holder/spell/wizard/turf/fireball"

	proj_lifespan = 200
	proj_step_delay = 1

	action_icon_state = "fireball"

/obj/effect/proc_holder/spell/wizard/turf/fireball/cast(var/turf/T)
	explosion(T, -1, 0, 2, 3, 0)


/obj/effect/proc_holder/spell/wizard/targeted/inflict_handler/fireball
	amt_dam_brute = 20
	amt_dam_fire = 25

/obj/effect/proc_holder/spell/wizard/targeted/explosion/fireball
	ex_severe = -1
	ex_heavy = -1
	ex_light = 2

/obj/effect/proc_holder/spell/wizard/aoe_turf/repulse
	name = "Repulse"
	desc = "This spell throws everything around the user away."
	charge_max = 400
	clothes_req = 1
	invocation = "GITTAH WEIGH"
	invocation_type = "shout"
	range = 5
	cooldown_min = 150
	selection_type = "view"
	var/maxthrow = 5

	action_icon_state = "repulse"

/obj/effect/proc_holder/spell/wizard/aoe_turf/repulse/cast(list/targets)
	var/mob/user = usr
	var/list/thrownatoms = list()
	var/atom/throwtarget
	var/distfromcaster
	for(var/turf/T in targets) //Done this way so things don't get thrown all around hilariously.
		for(var/atom/movable/AM in T)
			thrownatoms += AM

	for(var/atom/movable/AM in thrownatoms)
		if(AM == user || AM.anchored) continue

		var/obj/effect/overlay/targeteffect	= new /obj/effect/overlay{icon='icons/effects/effects.dmi'; icon_state="shieldsparkles"; mouse_opacity=0; density = 0}()
		AM.overlays += targeteffect
		throwtarget = get_edge_target_turf(user, get_dir(user, get_step_away(AM, user)))
		distfromcaster = get_dist(user, AM)
		spawn(10)
			AM.overlays -= targeteffect
			qdel(targeteffect)
		if(distfromcaster == 0)
			if(istype(AM, /mob/living))
				var/mob/living/M = AM
				M.Weaken(5)
				M.adjustBruteLoss(5)
				M << "<span class='userdanger'>You're slammed into the floor by a mystical force!</span>"
		else
			if(istype(AM, /mob/living))
				var/mob/living/M = AM
				M.Weaken(2)
				M << "<span class='userdanger'>You're thrown back by a mystical force!</span>"
			spawn(0) AM.throw_at(throwtarget, ((Clamp((maxthrow - (Clamp(distfromcaster - 2, 0, distfromcaster))), 3, maxthrow))), 1)//So stuff gets tossed around at the same time.

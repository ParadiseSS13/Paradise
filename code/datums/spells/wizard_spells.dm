/datum/spell/projectile/magic_missile
	name = "Magic Missile"
	desc = "This spell fires several, slow moving, magic projectiles at nearby targets."

	base_cooldown = 200
	invocation = "FORTI GY AMA"
	invocation_type = "shout"
	cooldown_min = 60 //35 deciseconds reduction per rank

	proj_icon_state = "magicm"
	proj_name = "a magic missile"
	proj_lingering = 1
	proj_type = /obj/item/projectile/magic/magic_missile

	proj_lifespan = 20
	proj_step_delay = 2

	proj_trail = 1
	proj_trail_lifespan = 5
	proj_trail_icon_state = "magicmd"

	action_icon_state = "magicm"

	sound = 'sound/magic/magic_missile.ogg'

/datum/spell/projectile/magic_missile/create_new_targeting()
	var/datum/spell_targeting/targeted/T = new()
	T.allowed_type = /mob/living
	T.max_targets = INFINITY
	return T

/obj/item/projectile/magic/magic_missile
	name = "Magic Missile"
	hitsound = 'sound/magic/mm_hit.ogg'
	weaken = 6 SECONDS

/datum/spell/projectile/honk_missile
	name = "Honk Missile"
	desc = "This spell fires several, slow moving, magic bike horns at nearby targets."

	base_cooldown = 6 SECONDS
	clothes_req = FALSE
	invocation = "HONK GY AMA"
	invocation_type = "shout"
	cooldown_min = 6 SECONDS

	proj_icon = 'icons/obj/items.dmi'
	proj_icon_state = "bike_horn"
	proj_name = "A bike horn"
	proj_lingering = 1
	proj_type = /obj/item/projectile/magic/magic_missile/honk_missile

	proj_lifespan = 20
	proj_step_delay = 5

	proj_trail_icon = 'icons/obj/items.dmi'
	proj_trail = 1
	proj_trail_lifespan = 5
	proj_trail_icon_state = "bike_horn"

	action_icon_state = "magicm"

	sound = 'sound/items/bikehorn.ogg'

/datum/spell/projectile/honk_missile/create_new_targeting()
	var/datum/spell_targeting/targeted/T = new()
	T.allowed_type = /mob/living
	T.max_targets = INFINITY
	return T

/obj/item/projectile/magic/magic_missile/honk_missile
	name = "Funny Missile"
	hitsound = 'sound/items/bikehorn.ogg'

/datum/spell/noclothes
	name = "No Clothes"
	desc = "This always-on spell allows you to cast magic without your garments."
	action_icon_state = "no_clothes"

/datum/spell/noclothes/create_new_targeting()
	return new /datum/spell_targeting/self // Dummy value

/datum/spell/genetic/mutate
	name = "Mutate"
	desc = "This spell causes you to turn into a hulk and gain laser vision for a short while."

	base_cooldown = 400
	invocation = "BIRUZ BENNAR"
	invocation_type = "shout"
	message = "<span class='notice'>You feel strong! You feel a pressure building behind your eyes!</span>"
	centcom_cancast = FALSE

	traits = list(TRAIT_LASEREYES)
	duration = 300
	cooldown_min = 300 //25 deciseconds reduction per rank

	action_icon_state = "mutate"
	sound = 'sound/magic/mutate.ogg'

/datum/spell/genetic/mutate/New()
	..()
	mutations = list(GLOB.hulkblock)

/datum/spell/genetic/mutate/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/smoke
	name = "Smoke"
	desc = "This spell spawns a cloud of choking smoke at your location and does not require wizard garb."

	base_cooldown = 120
	clothes_req = FALSE
	invocation = "none"
	cooldown_min = 20 //25 deciseconds reduction per rank

	smoke_type = SMOKE_COUGHING
	smoke_amt = 10

	action_icon_state = "smoke"

/datum/spell/smoke/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/emplosion/disable_tech
	name = "Disable Tech"
	desc = "This spell disables all weapons, cameras and most other technology in range."
	base_cooldown = 40 SECONDS
	invocation = "NEC CANTIO"
	invocation_type = "shout"
	cooldown_min = 200 //50 deciseconds reduction per rank

	emp_heavy = 6
	emp_light = 10

	sound = 'sound/magic/disable_tech.ogg'

/datum/spell/turf_teleport/blink
	name = "Blink"
	desc = "This spell randomly teleports you a short distance."

	base_cooldown = 20
	invocation = "none"
	cooldown_min = 5 //4 deciseconds reduction per rank


	smoke_type = SMOKE_HARMLESS
	smoke_amt = 1

	inner_tele_radius = 0
	outer_tele_radius = 6

	centcom_cancast = FALSE //prevent people from getting to centcom

	action_icon_state = "blink"

	sound1 = 'sound/magic/blink.ogg'
	sound2 = 'sound/magic/blink.ogg'

/datum/spell/turf_teleport/blink/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/area_teleport/teleport
	name = "Teleport"
	desc = "This spell teleports you to a type of area of your selection."

	base_cooldown = 600
	invocation = "SCYAR NILA"
	invocation_type = "shout"
	cooldown_min = 200 //100 deciseconds reduction per rank

	smoke_amt = 5
	action_icon_state = "spell_teleport"

	sound1 = 'sound/magic/teleport_diss.ogg'
	sound2 = 'sound/magic/teleport_app.ogg'

/datum/spell/area_teleport/teleport/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/return_to_teacher
	name = "Return to Teacher"
	desc = "This spell teleports you back to your teacher."

	base_cooldown = 30 SECONDS
	invocation = "SCYAR TESO"
	invocation_type = "shout"
	cooldown_min = 10 SECONDS

	action_icon_state = "spell_teleport"
	var/datum/mind/teacher

/datum/spell/return_to_teacher/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/return_to_teacher/cast(list/targets, mob/living/user = usr)
	if(!(teacher && teacher.current))
		to_chat(user, "<span class='danger'>The link to your teacher is broken!</span>")
		return
	do_teleport(user, teacher.current, 1, sound_in = 'sound/magic/blink.ogg', sound_out = 'sound/magic/blink.ogg', safe_turf_pick = TRUE)

/datum/spell/forcewall
	name = "Force Wall"
	desc = "This spell creates a 3 tile wide unbreakable wall that only you can pass through, and does not need wizard garb. Lasts 30 seconds."

	base_cooldown = 15 SECONDS
	clothes_req = FALSE
	invocation = "TARCOL MINTI ZHERI"
	invocation_type = "whisper"
	sound = 'sound/magic/forcewall.ogg'
	action_icon_state = "shield"
	cooldown_min = 5 SECONDS //25 deciseconds reduction per rank
	var/wall_type = /obj/effect/forcefield/wizard

/datum/spell/forcewall/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/forcewall/cast(list/targets, mob/user = usr)
	new wall_type(get_turf(user), user)
	if(user.dir == SOUTH || user.dir == NORTH)
		new wall_type(get_step(user, EAST), user)
		new wall_type(get_step(user, WEST), user)
	else
		new wall_type(get_step(user, NORTH), user)
		new wall_type(get_step(user, SOUTH), user)

/datum/spell/aoe/conjure/timestop
	name = "Stop Time"
	desc = "This spell stops time for everyone except for you, allowing you to move freely while your enemies and even projectiles are frozen."
	base_cooldown = 50 SECONDS
	invocation = "TOKI WO TOMARE"
	invocation_type = "shout"
	cooldown_min = 100
	delay = 0
	action_icon_state = "time"

	summon_type = list(/obj/effect/timestop/wizard)
	aoe_range = 0


/datum/spell/aoe/conjure/carp
	name = "Summon Carp"
	desc = "This spell conjures a simple carp."

	base_cooldown = 1200
	invocation = "NOUK FHUNMM SACP RISSKA"
	invocation_type = "shout"

	summon_type = list(/mob/living/basic/carp)

	cast_sound = 'sound/magic/summon_karp.ogg'
	aoe_range = 1

/datum/spell/aoe/conjure/construct
	name = "Artificer"
	desc = "This spell conjures a construct which may be controlled by Shades."

	base_cooldown = 600
	clothes_req = FALSE
	invocation = "none"

	summon_type = list(/obj/structure/constructshell)

	action_icon_state = "artificer"
	cast_sound = 'sound/magic/summonitems_generic.ogg'
	aoe_range = 0

/datum/spell/aoe/conjure/creature
	name = "Summon Creature Swarm"
	desc = "This spell tears the fabric of reality, allowing horrific daemons to spill forth."

	base_cooldown = 1200
	clothes_req = FALSE
	invocation = "IA IA"
	invocation_type = "shout"
	summon_amt = 10

	summon_type = list(/mob/living/basic/creature)
	cast_sound = 'sound/magic/summonitems_generic.ogg'
	aoe_range = 3

/datum/spell/blind
	name = "Blind"
	desc = "This spell temporarily blinds a single person and does not require wizard garb."
	base_cooldown = 15 SECONDS
	clothes_req = FALSE
	invocation = "STI KALY"
	invocation_type = "whisper"
	message = "<span class='notice'>Your eyes cry out in pain!</span>"
	cooldown_min = 2 SECONDS
	sound = 'sound/magic/blind.ogg'

/datum/spell/blind/create_new_targeting()
	var/datum/spell_targeting/click/C = new()
	C.selection_type = SPELL_SELECTION_RANGE
	C.allowed_type = /mob/living
	return C

/datum/spell/blind/cast(list/targets, mob/living/user)
	if(!length(targets))
		to_chat(user, "<span class='notice'>No target found in range.</span>")
		return

	var/mob/living/target = targets[1]
	if(target.can_block_magic(antimagic_flags))
		to_chat(target, "<span class='notice'>Your eye itches, but it passes momentarily.</span>")
		to_chat(user, "<span class='notice'>The spell had no effect!</span>")
		return FALSE
	target.EyeBlurry(40 SECONDS)
	target.EyeBlind(30 SECONDS)

	SEND_SOUND(target, sound('sound/magic/blind.ogg'))
	return TRUE

/datum/spell/fireball
	name = "Fireball"
	desc = "This spell fires a fireball at a target and does not require wizard garb."

	base_cooldown = 60
	clothes_req = FALSE
	invocation = "ONI SOMA"
	invocation_type = "shout"
	cooldown_min = 20 //10 deciseconds reduction per rank

	selection_activated_message		= "<span class='notice'>You prepare to cast your fireball spell! <B>Left-click to cast at a target!</B></span>"
	selection_deactivated_message	= "<span class='notice'>You extinguish your fireball...for now.</span>"

	var/fireball_type = /obj/item/projectile/magic/fireball
	action_icon_state = "fireball0"
	sound = 'sound/magic/fireball.ogg'


/datum/spell/fireball/apprentice
	centcom_cancast = FALSE

/datum/spell/fireball/create_new_targeting()
	var/datum/spell_targeting/clicked_atom/external/C = new()
	C.range = 20
	return C

/datum/spell/fireball/update_spell_icon()
	if(!action)
		return
	action.button_icon_state = "fireball[active]"
	action.build_all_button_icons()

/datum/spell/fireball/cast(list/targets, mob/living/user = usr)
	var/target = targets[1] //There is only ever one target for fireball
	var/turf/T = user.loc
	var/turf/U = get_step(user, user.dir) // Get the tile infront of the move, based on their direction
	if(!isturf(U) || !isturf(T))
		return FALSE

	var/obj/item/projectile/magic/fireball/FB = new fireball_type(user.loc)
	FB.current = get_turf(user)
	FB.original = target
	FB.firer = user
	FB.preparePixelProjectile(target, user)
	FB.fire()
	user.newtonian_move(get_dir(U, T))

	return TRUE

/datum/spell/fireball/toolbox
	name = "Homing Toolbox"
	desc = "This spell summons and throws a magical homing toolbox at your opponent."
	sound = 'sound/weapons/smash.ogg'
	fireball_type = /obj/item/projectile/homing/magic/toolbox
	invocation = "ROBUSTIO!"

	selection_activated_message		= "<span class='notice'>You prepare to cast your homing toolbox! <B>Left-click to cast at a target!</B></span>"
	selection_deactivated_message	= "<span class='notice'>You unrobust your toolbox...for now.</span>"

/datum/spell/fireball/homing
	name = "Greater Homing Fireball"
	desc = "This spell fires a strong homing fireball at a target."
	invocation = "ZI-ONI SOMA"
	fireball_type = /obj/item/projectile/homing/magic/homing_fireball

	selection_activated_message = "<span class='notice'>You prepare to cast your greater homing fireball spell! <B>Left-click to cast at a target!</B></span>"

/datum/spell/aoe/repulse
	name = "Repulse"
	desc = "This spell throws everything around the user away."
	base_cooldown = 40 SECONDS
	invocation = "GITTAH WEIGH"
	invocation_type = "shout"
	cooldown_min = 150
	sound = 'sound/magic/repulse.ogg'
	var/maxthrow = 5
	var/sparkle_path = /obj/effect/temp_visual/gravpush
	action_icon_state = "repulse"
	aoe_range = 5

/datum/spell/aoe/repulse/create_new_targeting()
	var/datum/spell_targeting/aoe/turf/targeting = new()
	targeting.range = aoe_range
	return targeting

/datum/spell/aoe/repulse/cast(list/targets, mob/user = usr, stun_amt = 4 SECONDS)
	var/list/thrownatoms = list()
	var/atom/throwtarget
	var/distfromcaster
	playMagSound()
	for(var/turf/T in targets) //Done this way so things don't get thrown all around hilariously.
		for(var/atom/movable/AM in T)
			if(ismob(AM))
				var/mob/victim_mob = AM
				if(victim_mob.can_block_magic(antimagic_flags))
					continue
			thrownatoms += AM

	for(var/am in thrownatoms)
		var/atom/movable/AM = am
		if(AM == user || AM.anchored || AM.move_resist == INFINITY)
			continue

		throwtarget = get_edge_target_turf(user, get_dir(user, get_step_away(AM, user)))
		distfromcaster = get_dist(user, AM)
		if(distfromcaster == 0)
			if(isliving(AM))
				var/mob/living/M = AM
				M.Weaken(10 SECONDS)
				M.adjustBruteLoss(5)
				to_chat(M, "<span class='userdanger'>You're slammed into the floor by a mystical force!</span>")
		else
			new sparkle_path(get_turf(AM), get_dir(user, AM)) //created sparkles will disappear on their own
			if(isliving(AM))
				var/mob/living/M = AM
				M.Weaken(stun_amt)
				to_chat(M, "<span class='userdanger'>You're thrown back by a mystical force!</span>")
			spawn(0)
				AM.throw_at(throwtarget, ((clamp((maxthrow - (clamp(distfromcaster - 2, 0, distfromcaster))), 3, maxthrow))), 1)//So stuff gets tossed around at the same time.

/datum/spell/sacred_flame
	name = "Sacred Flame"
	desc = "Makes everyone around you more flammable, and lights yourself on fire."
	base_cooldown = 6 SECONDS
	clothes_req = FALSE
	invocation = "FI'RAN DADISKO"
	invocation_type = "shout"
	action_icon_state = "sacredflame"
	sound = 'sound/magic/fireball.ogg'

/datum/spell/sacred_flame/create_new_targeting()
	var/datum/spell_targeting/aoe/A = new()
	A.include_user = TRUE
	A.range = 6
	A.allowed_type = /mob/living
	return A

/datum/spell/sacred_flame/cast(list/targets, mob/user = usr)
	for(var/mob/living/L in targets)
		if(L.can_block_magic(antimagic_flags))
			continue
		L.adjust_fire_stacks(20)
	if(isliving(user))
		var/mob/living/U = user
		U.IgniteMob()

/datum/spell/corpse_explosion
	name = "Corpse Explosion"
	desc = "Fills a corpse with energy, causing it to explode violently."
	base_cooldown = 5 SECONDS
	invocation = "JAH ITH BER"
	invocation_type = "whisper"
	selection_activated_message = "<span class='notice'>You prepare to detonate a corpse. Click on a target to cast the spell.</span>"
	selection_deactivated_message = "<span class='notice'>You cancel the spell.</span>"
	action_icon_state = "corpse_explosion"

/datum/spell/corpse_explosion/create_new_targeting()
	var/datum/spell_targeting/click/T = new
	T.click_radius = 0
	T.try_auto_target = FALSE
	T.allowed_type = /mob/living
	return T

/datum/spell/corpse_explosion/cast(list/targets, mob/user)
	var/mob/living/target = targets[1]
	if(!target || target.stat != DEAD)
		return
	var/turf/corpse_turf = get_turf(target)
	new /obj/effect/temp_visual/corpse_explosion(get_turf(target))
	target.gib()
	explosion(corpse_turf, 0, 0, 0, 0, silent = TRUE, cause = name, breach = FALSE)
	for(var/mob/living/M in range(4, corpse_turf))
		if(M == user)
			continue
		var/range = get_dist_euclidian(M, corpse_turf)
		range = max(1, range)
		M.apply_damage(100 / range, BRUTE)
		if(issilicon(M))
			to_chat(M, "<span class='userdanger'>Your sensors are disabled, and your carapace is ripped apart by the violent dark magic!</span>")
			M.Weaken(6 SECONDS / range)
			continue

		to_chat(M, "<span class='userdanger'>You are eviscerated by the violent dark magic!</span>")
		if(ishuman(M))
			if(range < 4)
				M.KnockDown(4 SECONDS / range)
			M.EyeBlurry(40 SECONDS / range)
			M.AdjustConfused(6 SECONDS / range)

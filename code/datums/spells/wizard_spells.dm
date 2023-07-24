/obj/effect/proc_holder/spell/projectile/magic_missile
	name = "Magic Missile"
	desc = "This spell fires several, slow moving, magic projectiles at nearby targets."

	school = "evocation"
	base_cooldown = 200
	clothes_req = TRUE
	invocation = "FORTI GY AMA"
	invocation_type = "shout"
	cooldown_min = 60 //35 deciseconds reduction per rank

	proj_icon_state = "magicm"
	proj_name = "a magic missile"
	proj_lingering = 1
	proj_type = "/obj/effect/proc_holder/spell/inflict_handler/magic_missile"

	proj_lifespan = 20
	proj_step_delay = 5

	proj_trail = 1
	proj_trail_lifespan = 5
	proj_trail_icon_state = "magicmd"

	action_icon_state = "magicm"

	sound = 'sound/magic/magic_missile.ogg'

/obj/effect/proc_holder/spell/projectile/magic_missile/create_new_targeting()
	var/datum/spell_targeting/targeted/T = new()
	T.allowed_type = /mob/living
	T.max_targets = INFINITY
	return T

/obj/effect/proc_holder/spell/inflict_handler/magic_missile
	amt_weakened = 6 SECONDS
	sound = 'sound/magic/mm_hit.ogg'


/obj/effect/proc_holder/spell/projectile/honk_missile
	name = "Honk Missile"
	desc = "This spell fires several, slow moving, magic bikehorns at nearby targets."

	school = "evocation"
	base_cooldown = 60
	clothes_req = FALSE
	invocation = "HONK GY AMA"
	invocation_type = "shout"
	cooldown_min = 60 //35 deciseconds reduction per rank

	proj_icon = 'icons/obj/items.dmi'
	proj_icon_state = "bike_horn"
	proj_name = "A bike horn"
	proj_lingering = 1
	proj_type = "/obj/effect/proc_holder/spell/inflict_handler/honk_missile"

	proj_lifespan = 20
	proj_step_delay = 5

	proj_trail_icon = 'icons/obj/items.dmi'
	proj_trail = 1
	proj_trail_lifespan = 5
	proj_trail_icon_state = "bike_horn"

	action_icon_state = "magicm"

	sound = 'sound/items/bikehorn.ogg'

/obj/effect/proc_holder/spell/projectile/honk_missile/create_new_targeting()
	var/datum/spell_targeting/targeted/T = new()
	T.allowed_type = /mob/living
	T.max_targets = INFINITY
	return T

/obj/effect/proc_holder/spell/inflict_handler/honk_missile
	amt_weakened = 6 SECONDS
	sound = 'sound/items/bikehorn.ogg'

/obj/effect/proc_holder/spell/noclothes
	name = "No Clothes"
	desc = "This always-on spell allows you to cast magic without your garments."
	action_icon_state = "no_clothes"

/obj/effect/proc_holder/spell/noclothes/create_new_targeting()
	return new /datum/spell_targeting/self // Dummy value

/obj/effect/proc_holder/spell/genetic/mutate
	name = "Mutate"
	desc = "This spell causes you to turn into a hulk and gain laser vision for a short while."

	school = "transmutation"
	base_cooldown = 400
	clothes_req = TRUE
	invocation = "BIRUZ BENNAR"
	invocation_type = "shout"
	message = "<span class='notice'>You feel strong! You feel a pressure building behind your eyes!</span>"
	centcom_cancast = FALSE

	traits = list(TRAIT_LASEREYES)
	duration = 300
	cooldown_min = 300 //25 deciseconds reduction per rank

	action_icon_state = "mutate"
	sound = 'sound/magic/mutate.ogg'

/obj/effect/proc_holder/spell/genetic/mutate/Initialize(mapload)
	. = ..()
	mutations = list(GLOB.hulkblock)

/obj/effect/proc_holder/spell/genetic/mutate/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/smoke
	name = "Smoke"
	desc = "This spell spawns a cloud of choking smoke at your location and does not require wizard garb."

	school = "conjuration"
	base_cooldown = 120
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	cooldown_min = 20 //25 deciseconds reduction per rank

	smoke_type = SMOKE_COUGHING
	smoke_amt = 10

	action_icon_state = "smoke"

/obj/effect/proc_holder/spell/smoke/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/emplosion/disable_tech
	name = "Disable Tech"
	desc = "This spell disables all weapons, cameras and most other technology in range."
	base_cooldown = 400
	clothes_req = TRUE
	invocation = "NEC CANTIO"
	invocation_type = "shout"
	cooldown_min = 200 //50 deciseconds reduction per rank

	emp_heavy = 6
	emp_light = 10

	sound = 'sound/magic/disable_tech.ogg'

/obj/effect/proc_holder/spell/turf_teleport/blink
	name = "Blink"
	desc = "This spell randomly teleports you a short distance."

	school = "abjuration"
	base_cooldown = 20
	clothes_req = TRUE
	invocation = "none"
	invocation_type = "none"
	cooldown_min = 5 //4 deciseconds reduction per rank


	smoke_type = SMOKE_HARMLESS
	smoke_amt = 1

	inner_tele_radius = 0
	outer_tele_radius = 6

	centcom_cancast = FALSE //prevent people from getting to centcom

	action_icon_state = "blink"

	sound1 = 'sound/magic/blink.ogg'
	sound2 = 'sound/magic/blink.ogg'

/obj/effect/proc_holder/spell/turf_teleport/blink/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/area_teleport/teleport
	name = "Teleport"
	desc = "This spell teleports you to a type of area of your selection."

	school = "abjuration"
	base_cooldown = 600
	clothes_req = TRUE
	invocation = "SCYAR NILA"
	invocation_type = "shout"
	cooldown_min = 200 //100 deciseconds reduction per rank

	smoke_amt = 5
	action_icon_state = "spell_teleport"

	sound1 = 'sound/magic/teleport_diss.ogg'
	sound2 = 'sound/magic/teleport_app.ogg'

/obj/effect/proc_holder/spell/area_teleport/teleport/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/forcewall
	name = "Force Wall"
	desc = "This spell creates a 3 tile wide unbreakable wall that only you can pass through, and does not need wizard garb. Lasts 30 seconds."

	school = "transmutation"
	base_cooldown = 15 SECONDS
	clothes_req = FALSE
	invocation = "TARCOL MINTI ZHERI"
	invocation_type = "whisper"
	sound = 'sound/magic/forcewall.ogg'
	action_icon_state = "shield"
	cooldown_min = 5 SECONDS //25 deciseconds reduction per rank
	var/wall_type = /obj/effect/forcefield/wizard

/obj/effect/proc_holder/spell/forcewall/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/forcewall/cast(list/targets, mob/user = usr)
	new wall_type(get_turf(user), user)
	if(user.dir == SOUTH || user.dir == NORTH)
		new wall_type(get_step(user, EAST), user)
		new wall_type(get_step(user, WEST), user)
	else
		new wall_type(get_step(user, NORTH), user)
		new wall_type(get_step(user, SOUTH), user)

/obj/effect/proc_holder/spell/aoe/conjure/timestop
	name = "Stop Time"
	desc = "This spell stops time for everyone except for you, allowing you to move freely while your enemies and even projectiles are frozen."
	base_cooldown = 500
	clothes_req = TRUE
	invocation = "TOKI WO TOMARE"
	invocation_type = "shout"
	cooldown_min = 100
	summon_amt = 1
	action_icon_state = "time"

	summon_type = list(/obj/effect/timestop/wizard)
	aoe_range = 0

/obj/effect/proc_holder/spell/aoe/conjure/carp
	name = "Summon Carp"
	desc = "This spell conjures a simple carp."

	school = "conjuration"
	base_cooldown = 1200
	clothes_req = TRUE
	invocation = "NOUK FHUNMM SACP RISSKA"
	invocation_type = "shout"

	summon_type = list(/mob/living/simple_animal/hostile/carp)

	cast_sound = 'sound/magic/summon_karp.ogg'
	aoe_range = 1

/obj/effect/proc_holder/spell/aoe/conjure/construct
	name = "Artificer"
	desc = "This spell conjures a construct which may be controlled by Shades"

	school = "conjuration"
	base_cooldown = 600
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"

	summon_type = list(/obj/structure/constructshell)

	action_icon_state = "artificer"
	cast_sound = 'sound/magic/summonitems_generic.ogg'
	aoe_range = 0

/obj/effect/proc_holder/spell/aoe/conjure/creature
	name = "Summon Creature Swarm"
	desc = "This spell tears the fabric of reality, allowing horrific daemons to spill forth"

	school = "conjuration"
	base_cooldown = 1200
	clothes_req = FALSE
	invocation = "IA IA"
	invocation_type = "shout"
	summon_amt = 10

	summon_type = list(/mob/living/simple_animal/hostile/creature)
	cast_sound = 'sound/magic/summonitems_generic.ogg'
	aoe_range = 3

/obj/effect/proc_holder/spell/trigger/blind
	name = "Blind"
	desc = "This spell temporarily blinds a single person and does not require wizard garb."

	school = "transmutation"
	base_cooldown = 300
	clothes_req = FALSE
	invocation = "STI KALY"
	invocation_type = "whisper"
	message = "<span class='notice'>Your eyes cry out in pain!</span>"
	cooldown_min = 50 //12 deciseconds reduction per rank

	starting_spells = list("/obj/effect/proc_holder/spell/inflict_handler/blind","/obj/effect/proc_holder/spell/genetic/blind")

	action_icon_state = "blind"

/obj/effect/proc_holder/spell/trigger/blind/create_new_targeting()
	var/datum/spell_targeting/click/C = new()
	C.allowed_type = /mob/living
	return C

/obj/effect/proc_holder/spell/inflict_handler/blind
	amt_eye_blind = 10
	amt_eye_blurry = 20
	sound = 'sound/magic/blind.ogg'

/obj/effect/proc_holder/spell/genetic/blind
	traits = list(TRAIT_BLIND)
	duration = 300
	sound = 'sound/magic/blind.ogg'

/obj/effect/proc_holder/spell/genetic/blind/create_new_targeting()
	return new /datum/spell_targeting/self // Dummy value since it is never used by an user directly

/obj/effect/proc_holder/spell/fireball
	name = "Fireball"
	desc = "This spell fires a fireball at a target and does not require wizard garb."

	school = "evocation"
	base_cooldown = 60
	clothes_req = FALSE
	invocation = "ONI SOMA"
	invocation_type = "shout"
	cooldown_min = 20 //10 deciseconds reduction per rank

	selection_activated_message		= "<span class='notice'>Your prepare to cast your fireball spell! <B>Left-click to cast at a target!</B></span>"
	selection_deactivated_message	= "<span class='notice'>You extinguish your fireball...for now.</span>"

	var/fireball_type = /obj/item/projectile/magic/fireball
	action_icon_state = "fireball0"
	sound = 'sound/magic/fireball.ogg'

	active = FALSE

/obj/effect/proc_holder/spell/fireball/create_new_targeting()
	var/datum/spell_targeting/clicked_atom/C = new()
	C.range = 20
	return C

/obj/effect/proc_holder/spell/fireball/update_icon_state()
	if(!action)
		return
	action.button_icon_state = "fireball[active]"
	action.UpdateButtonIcon()

/obj/effect/proc_holder/spell/fireball/cast(list/targets, mob/living/user = usr)
	var/target = targets[1] //There is only ever one target for fireball
	var/turf/T = user.loc
	var/turf/U = get_step(user, user.dir) // Get the tile infront of the move, based on their direction
	if(!isturf(U) || !isturf(T))
		return FALSE

	var/obj/item/projectile/magic/fireball/FB = new fireball_type(user.loc)
	FB.current = get_turf(user)
	FB.original = target
	FB.firer = user
	FB.preparePixelProjectile(target, get_turf(target), user)
	FB.fire()
	user.newtonian_move(get_dir(U, T))

	return TRUE

/obj/effect/proc_holder/spell/fireball/toolbox
	name = "Homing Toolbox"
	desc = "This spell summons and throws a magical homing toolbox at your opponent."
	sound = 'sound/weapons/smash.ogg'
	fireball_type = /obj/item/projectile/homing/magic/toolbox
	invocation = "ROBUSTIO!"

	selection_activated_message		= "<span class='notice'>Your prepare to cast your homing toolbox! <B>Left-click to cast at a target!</B></span>"
	selection_deactivated_message	= "<span class='notice'>You unrobust your toolbox...for now.</span>"

/obj/effect/proc_holder/spell/aoe/repulse
	name = "Repulse"
	desc = "This spell throws everything around the user away."
	base_cooldown = 400
	clothes_req = TRUE
	invocation = "GITTAH WEIGH"
	invocation_type = "shout"
	cooldown_min = 150
	sound = 'sound/magic/repulse.ogg'
	var/maxthrow = 5
	var/sparkle_path = /obj/effect/temp_visual/gravpush
	action_icon_state = "repulse"
	aoe_range = 5

/obj/effect/proc_holder/spell/aoe/repulse/create_new_targeting()
	var/datum/spell_targeting/aoe/turf/targeting = new()
	targeting.range = aoe_range
	return targeting

/obj/effect/proc_holder/spell/aoe/repulse/cast(list/targets, mob/user = usr, stun_amt = 4 SECONDS)
	var/list/thrownatoms = list()
	var/atom/throwtarget
	var/distfromcaster
	playMagSound()
	for(var/turf/T in targets) //Done this way so things don't get thrown all around hilariously.
		for(var/atom/movable/AM in T)
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

/obj/effect/proc_holder/spell/sacred_flame
	name = "Sacred Flame"
	desc = "Makes everyone around you more flammable, and lights yourself on fire."
	base_cooldown = 60
	clothes_req = FALSE
	invocation = "FI'RAN DADISKO"
	invocation_type = "shout"
	action_icon_state = "sacredflame"
	sound = 'sound/magic/fireball.ogg'

/obj/effect/proc_holder/spell/sacred_flame/create_new_targeting()
	var/datum/spell_targeting/aoe/A = new()
	A.include_user = TRUE
	A.range = 6
	A.allowed_type = /mob/living
	return A

/obj/effect/proc_holder/spell/sacred_flame/cast(list/targets, mob/user = usr)
	for(var/mob/living/L in targets)
		L.adjust_fire_stacks(20)
	if(isliving(user))
		var/mob/living/U = user
		U.IgniteMob()

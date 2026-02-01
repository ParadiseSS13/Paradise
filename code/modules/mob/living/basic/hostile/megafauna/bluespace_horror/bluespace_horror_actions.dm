/datum/action/cooldown/mob_cooldown/bluespace_horror/summon_mobs
	name = "Summon Mobs"
	button_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "telerune"
	desc = "Summon a series of servants from bluespace to assist you."
	click_to_activate = FALSE
	melee_cooldown_time = CLICK_CD_CLICK_ABILITY
	cooldown_time = 90 SECONDS
	shared_cooldown = NONE

/datum/action/cooldown/mob_cooldown/bluespace_horror/summon_mobs/Activate(atom/target)
	var/mob/living/basic/megafauna/bluespace_horror/summoner = owner
	if(!istype(summoner))
		to_chat(owner, "<span class='warning'>I am unable to summon servants!</span>")
		return

	var/amount_to_spawn = rand(2, 5)
	var/list/all_possible_dirs = GLOB.alldirs
	for(var/i in 1 to amount_to_spawn)
		var/mob/living/new_mob
		var/spawn_loc = get_step(summoner, pick_n_take(all_possible_dirs))
		new_mob = create_random_mob(spawn_loc, HOSTILE_SPAWN)
		new /obj/effect/temp_visual/emp/pulse/cult(spawn_loc)
		new_mob.faction = summoner.faction
	StartCooldown()

/datum/action/cooldown/mob_cooldown/bluespace_horror/charge
	name = "Violent Charge"
	button_icon_state = "OH_YEAAAAH"
	desc = "Fully materialize in the material plane and charge forward!"
	melee_cooldown_time = CLICK_CD_CLICK_ABILITY
	cooldown_time = 20 SECONDS
	shared_cooldown = NONE

/datum/action/cooldown/mob_cooldown/bluespace_horror/charge/Activate(atom/target)
	. = ..()
	var/dir_to_target = get_dir(get_turf(owner), get_turf(target))
	var/turf/T = get_step(get_turf(owner), dir_to_target)
	for(var/i in 1 to 9)
		new /obj/effect/temp_visual/dragon_swoop/bluespace_horror(T)
		T = get_step(T, dir_to_target)
	owner.visible_message("<span class='danger'>[owner] prepares to charge!</span>")
	addtimer(CALLBACK(src, PROC_REF(charge_to), dir_to_target, 0), 4)
	StartCooldown()

/datum/action/cooldown/mob_cooldown/bluespace_horror/charge/proc/charge_to(move_dir, times_ran, list/hit_targets = list())
	var/mob/living/basic/horror = owner
	if(times_ran >= 9)
		return
	var/turf/T = get_step(get_turf(owner), move_dir)
	if(ismineralturf(T))
		var/turf/simulated/mineral/M = T
		M.gets_drilled()
	if(iswallturf(T))
		T.dismantle_wall(TRUE)
	for(var/obj/structure/window/W in T.contents)
		W.take_damage(horror.obj_damage, BRUTE)
	for(var/obj/machinery/door/D in T.contents)
		D.take_damage(horror.obj_damage, BRUTE)
	if(T.x > world.maxx - 2 || T.x < 2) // Keep them from runtiming
		return
	if(T.y > world.maxy - 2 || T.y < 2)
		return
	owner.forceMove(T)
	playsound(owner, 'sound/effects/bang.ogg', 200, 1)
	var/throwtarget = get_edge_target_turf(owner, move_dir)
	for(var/mob/living/L in T.contents - owner)
		if(owner.faction_check_mob(L))
			continue
		owner.visible_message("<span class='danger'>[owner] tramples and kicks [L]!</span>")
		to_chat(L, "<span class='userdanger'>[owner] tramples you and kicks you away!</span>")
		L.throw_at(throwtarget, 10, 1, owner)
		L.Weaken(1 SECONDS) // Pain Train has no breaks.
		if(L in hit_targets)
			L.adjustBruteLoss(15)
		else
			hit_targets += L
			L.adjustBruteLoss(25)
	addtimer(CALLBACK(src, PROC_REF(charge_to), move_dir, (times_ran + 1), hit_targets), 0.7)

// The visual effect which appears in front of the horror when it goes to charge.
/obj/effect/temp_visual/dragon_swoop/bluespace_horror
	icon_state = "rune_large_distorted"
	color = "#000099"

/obj/effect/temp_visual/dragon_swoop/bluespace_horror/Initialize(mapload)
	. = ..()
	transform *= 0.33

/datum/action/cooldown/mob_cooldown/bluespace_horror/magic_missile
	name = "Bluespace Missile"
	button_icon_state = "magicm"
	desc = "Conjure bluespace projectiles to seek nearby victims!"
	melee_cooldown_time = CLICK_CD_CLICK_ABILITY
	cooldown_time = 40 SECONDS
	shared_cooldown = NONE

/datum/action/cooldown/mob_cooldown/bluespace_horror/magic_missile/Activate(atom/target)
	. = ..()
	var/mob/living/basic/megafauna/bluespace_horror/horror = owner
	if(!istype(horror))
		return

	for(var/T in RANGE_TURFS(12, horror.loc) - horror.loc)
		if(prob(10))
			horror.shoot_projectile(T, /obj/projectile/magic/magic_missile/lesser/horror)
			playsound(horror, 'sound/magic/magic_missile.ogg', 40, TRUE)
			sleep(1)
	horror.shoot_projectile(target, /obj/projectile/magic/magic_missile/lesser/horror)
	playsound(horror, 'sound/magic/magic_missile.ogg', 40, TRUE)
	StartCooldown()

/obj/projectile/magic/magic_missile/lesser/horror
	damage = 15
	damage_type = BRUTE
	nodamage = FALSE

/datum/action/cooldown/mob_cooldown/bluespace_horror/fireball_fan
	name = "Fireball Fan"
	button_icon_state = "fireball"
	desc = "Concentrate bluespace energy into a volatile volley of flame!"
	melee_cooldown_time = CLICK_CD_CLICK_ABILITY
	cooldown_time = 20 SECONDS
	shared_cooldown = NONE

/datum/action/cooldown/mob_cooldown/bluespace_horror/fireball_fan/Activate(atom/target)
	. = ..()
	var/mob/living/basic/megafauna/bluespace_horror/horror = owner
	if(!istype(horror))
		return
	var/angle_to_target = get_angle(horror, target)

	var/variance = -90
	for(var/i in 1 to 5)
		horror.shoot_projectile(target, /obj/projectile/magic/fireball, angle_to_target + variance)
		variance += 45
	playsound(horror, 'sound/magic/fireball.ogg', 200, TRUE, 2)
	StartCooldown()

/datum/action/cooldown/mob_cooldown/bluespace_horror/lifesteal_bolt
	name = "Lifesteal Bolt"
	button_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "revive"
	desc = "Fire a fast-moving bolt that drains the vitality of those that live on the material plane."
	melee_cooldown_time = CLICK_CD_CLICK_ABILITY
	cooldown_time = 10 SECONDS
	shared_cooldown = NONE

/datum/action/cooldown/mob_cooldown/bluespace_horror/lifesteal_bolt/Activate(atom/target)
	. = ..()
	var/mob/living/basic/megafauna/bluespace_horror/horror = owner
	if(!istype(horror))
		return

	horror.shoot_projectile(target, /obj/projectile/magic/lifesteal_bolt)
	playsound(horror, 'sound/magic/invoke_general.ogg', 200, TRUE, 2)
	StartCooldown()

/obj/projectile/magic/lifesteal_bolt
	name = "lifesteal bolt"
	icon_state = "arcane_barrage"
	damage = 25
	damage_type = BRUTE
	nodamage = FALSE

/obj/projectile/magic/lifesteal_bolt/on_hit(mob/living/carbon/target)
	. = ..()
	if(!.)
		return .
	if(isliving(target) && isliving(firer))
		var/mob/living/LF = firer
		target.apply_damage(5, CLONE)
		LF.adjustBruteLoss(-25)
		target.Beam(LF, icon_state = "drain_life", icon = 'icons/effects/effects.dmi', time = 2 SECONDS)

/datum/action/cooldown/mob_cooldown/bluespace_horror/blink
	name = "Blink"
	button_icon_state = "blink"
	desc = "Teleport away from your current location."
	click_to_activate = FALSE
	melee_cooldown_time = CLICK_CD_CLICK_ABILITY
	cooldown_time = 6 SECONDS
	shared_cooldown = NONE

/datum/action/cooldown/mob_cooldown/bluespace_horror/blink/Activate(atom/target)
	. = ..()
	var/list/turfs = list()
	for(var/turf/T in range(target, 7))
		if(T in range(target, 2))
			continue
		if(isspaceturf(T))
			continue
		if(T.density)
			continue
		turfs += T
	var/turf/picked = pick(turfs)
	var/datum/effect_system/smoke_spread/smoke
	smoke = new /datum/effect_system/smoke_spread/bad()
	smoke.set_up(2, FALSE, owner.loc)
	smoke.start()
	owner.forceMove(picked)
	playsound(owner, 'sound/magic/blink.ogg', 150, TRUE, 2)
	StartCooldown()

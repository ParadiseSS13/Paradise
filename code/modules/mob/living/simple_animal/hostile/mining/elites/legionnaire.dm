#define LEGIONNAIRE_CHARGE 1
#define HEAD_DETACH 2
#define BONFIRE_TELEPORT 3
#define THROW_BONE 4

/**
 * # Legionnaire
 *
 * A towering skeleton, embodying the power of Legion.
 * As it's health gets lower, the head does more damage.
 * It's attacks are as follows:
 * - Charges at the target after a telegraph, throwing them across the arena should it connect.
 * - Legionnaire's head detaches, attacking as it's own entity.  Has abilities of it's own later into the fight.  Once dead, regenerates after a brief period.  If the skill is used while the head is off, it will be killed.
 * - Leaves a pile of bones at your location.  Upon using this skill again, you'll swap locations with the bone pile.
 * - Spews a cloud of smoke from it's maw, wherever said maw is.
 * A unique fight incorporating the head mechanic of legion into a whole new beast.  Combatants will need to make sure the tag-team of head and body don't lure them into a deadly trap.
 */

/mob/living/simple_animal/hostile/asteroid/elite/legionnaire
	name = "legionnaire"
	desc = "A towering skeleton, embodying the terrifying power of Legion."
	icon_state = "legionnaire"
	icon_living = "legionnaire"
	icon_aggro = "legionnaire"
	icon_dead = "legionnaire_dead"
	icon_gib = "syndicate_gib"
	maxHealth = 1400
	health = 1400
	melee_damage_lower = 35
	melee_damage_upper = 35
	armour_penetration = 40
	attacktext = "slashes its arms at"
	attack_sound = 'sound/effects/hit_punch.ogg'
	throw_message = "doesn't affect the sturdiness of"
	speed = 0.5 //Since it is mainly melee, this *should* be right
	move_to_delay = 3
	mouse_opacity = MOUSE_OPACITY_ICON
	death_sound = 'sound/hallucinations/wail.ogg'
	deathmessage = "'s arms reach out before it falls apart onto the floor, lifeless."
	sight = SEE_MOBS // So it can see through smoke / charge through walls like the kool aid man.
	var/datum/effect_system/smoke_spread/bad/smoke
	loot_drop = /obj/item/crusher_trophy/legionnaire_spine
	tts_seed = "Volibear"

	attack_action_types = list(/datum/action/innate/elite_attack/legionnaire_charge,
								/datum/action/innate/elite_attack/head_detach,
								/datum/action/innate/elite_attack/bonfire_teleport,
								/datum/action/innate/elite_attack/throw_bone)

	var/mob/living/simple_animal/hostile/asteroid/elite/legionnairehead/myhead = null
	var/obj/structure/legionnaire_bonfire/mypile = null
	var/has_head = TRUE
	/// Whether or not the legionnaire is currently charging, used to deny movement input if he is
	var/charging = FALSE
	var/charge_damage = 15
	var/charge_damage_first = 25

/mob/living/simple_animal/hostile/asteroid/elite/legionnaire/scale_stats(list/activators)
	. = ..()
	charge_damage = charge_damage * dif_mult_dmg

/datum/action/innate/elite_attack/legionnaire_charge
	name = "Legionnaire Charge"
	button_icon_state = "legionnaire_charge"
	chosen_message = "<span class='boldwarning'>You will attempt to grab your opponent and throw them.</span>"
	chosen_attack_num = LEGIONNAIRE_CHARGE

/datum/action/innate/elite_attack/head_detach
	name = "Release Head"
	button_icon_state = "head_detach"
	chosen_message = "<span class='boldwarning'>You will now detach your head or kill it if it is already released.</span>"
	chosen_attack_num = HEAD_DETACH

/datum/action/innate/elite_attack/bonfire_teleport
	name = "Bonfire Teleport"
	button_icon_state = "bonfire_teleport"
	chosen_message = "<span class='boldwarning'>You will leave a bonfire. Second use will let you swap positions with it indefintiely. Using this move on the same tile as your active bonfire removes it.</span>"
	chosen_attack_num = BONFIRE_TELEPORT

/datum/action/innate/elite_attack/throw_bone
	name = "Throw bone"
	icon_icon = 'icons/obj/mining.dmi'
	button_icon_state = "bone"
	chosen_message = "<span class='boldwarning'>You throw a heavy bone.</span>"
	chosen_attack_num = THROW_BONE

/mob/living/simple_animal/hostile/asteroid/elite/legionnaire/Destroy()
	myhead = null
	mypile = null
	return ..()

/mob/living/simple_animal/hostile/asteroid/elite/legionnaire/OpenFire()
	if(client)
		switch(chosen_attack)
			if(LEGIONNAIRE_CHARGE)
				legionnaire_charge(target)
			if(HEAD_DETACH)
				head_detach(target)
			if(BONFIRE_TELEPORT)
				bonfire_teleport()
			if(THROW_BONE)
				throw_bone()
		return
	var/aiattack = rand(1,4)
	switch(aiattack)
		if(LEGIONNAIRE_CHARGE)
			legionnaire_charge(target)
		if(HEAD_DETACH)
			head_detach(target)
		if(BONFIRE_TELEPORT)
			bonfire_teleport()
		if(THROW_BONE)
			throw_bone()

/mob/living/simple_animal/hostile/asteroid/elite/legionnaire/Move()
	if(charging)
		return FALSE
	. = ..()

/mob/living/simple_animal/hostile/asteroid/elite/legionnaire/MiddleClickOn(atom/A)
	. = ..()
	if(!myhead)
		return
	var/turf/T = get_turf(A)
	if(T)
		myhead.LoseTarget()
		myhead.Goto(T, myhead.move_to_delay)

/mob/living/simple_animal/hostile/asteroid/elite/legionnaire/proc/legionnaire_charge(target)
	ranged_cooldown = world.time + 3 SECONDS * revive_multiplier()
	charging = TRUE
	var/dir_to_target = get_dir(get_turf(src), get_turf(target))
	var/turf/T = get_step(get_turf(src), dir_to_target)
	for(var/i in 1 to 6)
		new /obj/effect/temp_visual/dragon_swoop/legionnaire(T)
		T = get_step(T, dir_to_target)
	playsound(src, 'sound/misc/demon_attack1.ogg', 200, 1)
	visible_message("<span class='danger'>[src] prepares to charge!</span>")
	addtimer(CALLBACK(src, .proc/legionnaire_charge_to, dir_to_target, 0), 2)

/mob/living/simple_animal/hostile/asteroid/elite/legionnaire/proc/legionnaire_charge_to(move_dir, times_ran, list/hit_targets = list())
	if(times_ran >= 6)
		charging = FALSE
		return
	var/turf/T = get_step(get_turf(src), move_dir)
	if(ismineralturf(T))
		var/turf/simulated/mineral/M = T
		M.gets_drilled()
	if(T.density)
		charging = FALSE
		return
	for(var/obj/structure/window/W in T.contents)
		charging = FALSE
		return
	for(var/obj/machinery/door/D in T.contents)
		if(D.density)
			charging = FALSE
			return
	if(T.x > world.maxx - 2 || T.x < 2) //Keep them from runtiming
		charging = FALSE
		return
	if(T.y > world.maxy - 2 || T.y < 2)
		charging = FALSE
		return
	forceMove(T)
	playsound(src,'sound/effects/bang.ogg', 200, 1)
	var/throwtarget = get_edge_target_turf(src, move_dir)
	for(var/mob/living/L in T.contents - src)
		if(faction_check_mob(L))
			return
		visible_message("<span class='danger'>[src] tramples and kicks [L]!</span>")
		to_chat(L, "<span class='userdanger'>[src] tramples you and kicks you away!</span>")
		if(L in hit_targets)
			L.adjustBruteLoss(charge_damage)
		else
			hit_targets += L
			L.throw_at(throwtarget, 8, 1.3, src)
			L.Slowed(3 SECONDS)
			L.Weaken(0.1 SECONDS)
			L.adjustBruteLoss(charge_damage_first)

	addtimer(CALLBACK(src, .proc/legionnaire_charge_to, move_dir, (times_ran + 1), hit_targets), 0.3)

/mob/living/simple_animal/hostile/asteroid/elite/legionnaire/proc/head_detach(target)
	ranged_cooldown = world.time + 1 SECONDS * revive_multiplier()
	if(myhead != null)
		myhead.adjustBruteLoss(600)
		return
	if(has_head)
		has_head = FALSE
		icon_state = "legionnaire_headless"
		icon_living = "legionnaire_headless"
		icon_aggro = "legionnaire_headless"
		visible_message("<span class='warning'>[src]'s head flies off!")
		var/mob/living/simple_animal/hostile/asteroid/elite/legionnairehead/newhead = new(loc)
		newhead.GiveTarget(target)
		newhead.faction = faction.Copy()
		myhead = newhead
		myhead.body = src
		if(health < maxHealth * 0.25)
			myhead.melee_damage_lower = 40
			myhead.melee_damage_upper = 40
		else if(health < maxHealth * 0.5)
			myhead.melee_damage_lower = 30
			myhead.melee_damage_upper = 30

/mob/living/simple_animal/hostile/asteroid/elite/legionnaire/proc/onHeadDeath()
	myhead = null
	addtimer(CALLBACK(src, .proc/regain_head), 5 SECONDS)

/mob/living/simple_animal/hostile/asteroid/elite/legionnaire/proc/regain_head()
	has_head = TRUE
	if(stat == DEAD)
		return
	icon_state = "legionnaire"
	icon_living = "legionnaire"
	icon_aggro = "legionnaire"
	visible_message("<span class='danger'>The top of [src]'s spine leaks a black liquid, forming into a skull!</span>")

/mob/living/simple_animal/hostile/asteroid/elite/legionnaire/proc/bonfire_teleport()
	ranged_cooldown = world.time + 2 SECONDS * revive_multiplier()
	if(isnull(mypile))
		var/obj/structure/legionnaire_bonfire/newpile = new(loc)
		mypile = newpile
		mypile.myowner = src
		playsound(get_turf(src),'sound/items/fultext_deploy.ogg', 200, 1)
		visible_message("<span class='warning'>[src] summons a bonfire on [get_turf(src)]!</span>")
		return
	else
		var/turf/legionturf = get_turf(src)
		var/turf/pileturf = get_turf(mypile)
		if(legionturf == pileturf)
			QDEL_NULL(mypile)
			return
		playsound(pileturf,'sound/items/fultext_deploy.ogg', 200, 1)
		playsound(legionturf,'sound/items/fultext_deploy.ogg', 200, 1)
		visible_message("<span class='danger'>[src] melts down into a burning pile of bones!</span>")
		forceMove(pileturf)
		visible_message("<span class='danger'>[src] forms from the bonfire!</span>")
		mypile.forceMove(legionturf)

/mob/living/simple_animal/hostile/asteroid/elite/legionnaire/proc/throw_bone()
	ranged_cooldown = world.time + 2.5 SECONDS * revive_multiplier()
	var/target_turf = get_turf(target)
	shoot_projectile(target_turf)

//The legionnaire's head.  Basically the same as any legion head, but we have to tell our creator when we die so they can generate another head.
/mob/living/simple_animal/hostile/asteroid/elite/legionnairehead
	name = "legionnaire head"
	desc = "The legionnaire's head floating by itself. One shouldn't get too close, though once it sees you, you really don't have a choice."
	icon_state = "legionnaire_head"
	icon_living = "legionnaire_head"
	icon_aggro = "legionnaire_head"
	icon_dead = "legionnaire_dead"
	icon_gib = "syndicate_gib"
	maxHealth = 200
	health = 200
	melee_damage_lower = 20
	melee_damage_upper = 20
	attacktext = "bites at"
	attack_sound = 'sound/hallucinations/growl1.ogg'
	throw_message = "simply misses"
	speed = 0
	move_to_delay = 2
	aggro_vision_range = 18
	del_on_death = 1
	deathmessage = "crumbles away!"
	faction = list()
	ranged = FALSE
	var/mob/living/simple_animal/hostile/asteroid/elite/legionnaire/body = null

/mob/living/simple_animal/hostile/asteroid/elite/legionnairehead/death()
	. = ..()
	if(body)
		body.onHeadDeath()

//The legionnaire's bonfire, which can be swapped positions with.  Also sets flammable living beings on fire when they walk over it.
/obj/structure/legionnaire_bonfire
	name = "bone pile"
	desc = "A pile of bones which seems to occasionally move a little.  It's probably a good idea to smash them."
	icon = 'icons/obj/lavaland/legionnaire_bonfire.dmi'
	icon_state = "bonfire"
	max_integrity = 100
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	anchored = TRUE
	density = FALSE
	light_range = 4
	light_color = LIGHT_COLOR_RED
	var/mob/living/simple_animal/hostile/asteroid/elite/legionnaire/myowner = null

/obj/structure/legionnaire_bonfire/Crossed(datum/source, atom/movable/mover)
	if(isobj(source))
		var/obj/object = source
		object.fire_act(1000, 500)
	if(isliving(source))
		var/mob/living/fire_walker = source
		fire_walker.adjust_fire_stacks(5)
		fire_walker.IgniteMob()

/obj/structure/legionnaire_bonfire/Destroy()
	if(myowner != null)
		myowner.mypile = null
	. = ..()

/obj/item/projectile/legionnaire
	name = "bone"
	icon = 'icons/obj/mining.dmi'
	icon_state = "bone"
	damage = 25
	armour_penetration = 70
	speed = 1.2

/mob/living/simple_animal/hostile/asteroid/elite/legionnaire/proc/shoot_projectile(turf/marker)
	var/turf/startloc = get_turf(src)
	var/obj/item/projectile/legionnaire/P = new(startloc)
	P.preparePixelProjectile(marker, marker, src)
	P.firer = src
	P.damage = P.damage * dif_mult_dmg
	if(target)
		P.original = target
	P.fire()

//The visual effect which appears in front of legionnaire when he goes to charge.
/obj/effect/temp_visual/dragon_swoop/legionnaire
	duration = 10

/obj/effect/temp_visual/dragon_swoop/legionnaire/Initialize(mapload)
	. = ..()
	transform *= 0.33

// Legionnaire's loot: Legionnaire Spine

/obj/item/crusher_trophy/legionnaire_spine
	name = "legionnaire spine"
	desc = "The spine of a legionnaire. With some creativity, you could use it as a crusher trophy. Alternatively, shaking it might do something as well."
	icon = 'icons/obj/lavaland/elite_trophies.dmi'
	icon_state = "legionnaire_spine"
	denied_type = /obj/item/crusher_trophy/legionnaire_spine
	bonus_value = 75 // listen this dies in one hit, this can be a high chance.
	/// Time at which the item becomes usable again
	var/next_use_time

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion/legionnaire
	health = 25
	maxHealth = 25
	melee_damage_lower = 15
	melee_damage_upper = 15

/obj/item/crusher_trophy/legionnaire_spine/effect_desc()
	return "mark detonation to have a <b>[bonus_value]%</b> chance to summon a loyal legion skull"

/obj/item/crusher_trophy/legionnaire_spine/on_mark_detonation(mob/living/target, mob/living/user)
	if(!prob(bonus_value) || target.stat == DEAD)
		return
	var/mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion/A = new(user.loc)
	A.GiveTarget(target)
	A.friends += user
	A.faction = user.faction.Copy()

/obj/item/crusher_trophy/legionnaire_spine/attack_self(mob/user)
	if(!isliving(user))
		return
	var/mob/living/LivingUser = user
	if(next_use_time > world.time)
		LivingUser.visible_message("<span class='warning'>[LivingUser] shakes the [src], but nothing happens...</span>")
		to_chat(LivingUser, "<b>You need to wait longer to use this again.</b>")
		return
	LivingUser.visible_message("<span class='warning'>[LivingUser] shakes the [src] and summons a legion skull!</span>")
	var/mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion/legionnaire/LegionSkull = new(LivingUser.loc)
	LegionSkull.friends += LivingUser
	LegionSkull.faction = LivingUser.faction.Copy()
	next_use_time = world.time + 4 SECONDS

#undef LEGIONNAIRE_CHARGE
#undef HEAD_DETACH
#undef BONFIRE_TELEPORT
#undef THROW_BONE

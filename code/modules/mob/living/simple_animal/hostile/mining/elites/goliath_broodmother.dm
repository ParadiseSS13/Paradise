#define TENTACLE_PATCH 1
#define SPAWN_CHILDREN 2
#define RAGE 3
#define CALL_CHILDREN 4

/**
 * # Goliath Broodmother
 *
 * A stronger, faster variation of the goliath.  Has the ability to spawn baby goliaths, which it can later detonate at will.
 * When it's health is below half, tendrils will spawn randomly around it.  When it is below a quarter of health, this effect is doubled.
 * It's attacks are as follows:
 * - Spawns a 3x3/plus shape of tentacles on the target location
 * - Spawns 2 baby goliaths on its tile, up to a max of 8.  Children blow up when they die.
 * - The broodmother lets out a noise, and is able to move faster for 6.5 seconds.
 * - Summons your children around you.
 * The broodmother is a fight revolving around stage control, as the activator has to manage the baby goliaths and the broodmother herself, along with all the tendrils.
 */

/mob/living/simple_animal/hostile/asteroid/elite/broodmother
	name = "goliath broodmother"
	desc = "An example of sexual dimorphism, this female goliath looks much different than the males of her species.  She is, however, just as dangerous, if not more."
	gender = FEMALE
	icon_state = "broodmother"
	icon_living = "broodmother"
	icon_aggro = "broodmother"
	icon_dead = "egg_sac"
	icon_gib = "syndicate_gib"
	maxHealth = 1000
	health = 1000
	melee_damage_lower = 30
	melee_damage_upper = 30
	armour_penetration_percentage = 50
	attacktext = "beats down on"
	attack_sound = 'sound/weapons/punch1.ogg'
	throw_message = "does nothing to the rocky hide of the"
	speed = 2
	move_to_delay = 5
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	mouse_opacity = MOUSE_OPACITY_ICON
	deathmessage = "explodes into gore!"
	loot_drop = /obj/item/crusher_trophy/broodmother_tongue

	attack_action_types = list(/datum/action/innate/elite_attack/tentacle_patch,
								/datum/action/innate/elite_attack/spawn_children,
								/datum/action/innate/elite_attack/rage,
								/datum/action/innate/elite_attack/call_children)

	var/rand_tent = 0
	var/list/mob/living/simple_animal/hostile/asteroid/elite/broodmother_child/children_list = list()

/datum/action/innate/elite_attack/tentacle_patch
	name = "Tentacle Patch"
	button_icon_state = "tentacle_patch"
	chosen_message = "<span class='boldwarning'>You are now attacking with a patch of tentacles.</span>"
	chosen_attack_num = TENTACLE_PATCH

/datum/action/innate/elite_attack/spawn_children
	name = "Spawn Children"
	button_icon_state = "spawn_children"
	chosen_message = "<span class='boldwarning'>You will spawn two children at your location to assist you in combat.  You can have up to 8.</span>"
	chosen_attack_num = SPAWN_CHILDREN

/datum/action/innate/elite_attack/rage
	name = "Rage"
	button_icon_state = "rage"
	chosen_message = "<span class='boldwarning'>You will temporarily increase your movement speed.</span>"
	chosen_attack_num = RAGE

/datum/action/innate/elite_attack/call_children
	name = "Call Children"
	button_icon_state = "call_children"
	chosen_message = "<span class='boldwarning'>You will summon your children to your location.</span>"
	chosen_attack_num = CALL_CHILDREN

/mob/living/simple_animal/hostile/asteroid/elite/broodmother/Destroy()
	for(var/mob/living/simple_animal/hostile/asteroid/elite/broodmother_child/C in children_list)
		C.mother = null
	children_list.Cut()
	children_list = null
	return ..()

/mob/living/simple_animal/hostile/asteroid/elite/broodmother/OpenFire()
	if(client)
		switch(chosen_attack)
			if(TENTACLE_PATCH)
				tentacle_patch(target)
			if(SPAWN_CHILDREN)
				spawn_children()
			if(RAGE)
				rage()
			if(CALL_CHILDREN)
				call_children()
		return
	var/aiattack = rand(1,4)
	switch(aiattack)
		if(TENTACLE_PATCH)
			tentacle_patch(target)
		if(SPAWN_CHILDREN)
			spawn_children()
		if(RAGE)
			rage()
		if(CALL_CHILDREN)
			call_children()

/mob/living/simple_animal/hostile/asteroid/elite/broodmother/Life(seconds, times_fired)
	. = ..()
	if(!.) //Checks if they are dead as a rock.
		return
	if(health < maxHealth * 0.5 && rand_tent < world.time)
		rand_tent = world.time + 30
		var/tentacle_amount = 5
		if(health < maxHealth * 0.25)
			tentacle_amount = 10
		var/tentacle_loc = spiral_range_turfs(5, get_turf(src))
		for(var/i in 1 to tentacle_amount)
			var/turf/t = pick_n_take(tentacle_loc)
			new /obj/effect/temp_visual/goliath_tentacle/broodmother(t, src)

/mob/living/simple_animal/hostile/asteroid/elite/broodmother/proc/tentacle_patch(target)
	ranged_cooldown = world.time + 2.5 SECONDS * revive_multiplier()
	var/tturf = get_turf(target)
	if(!isturf(tturf))
		return
	visible_message("<span class='warning'>[src] digs its tentacles under [target]!</span>")
	new /obj/effect/temp_visual/goliath_tentacle/broodmother/patch(tturf, src)

/mob/living/simple_animal/hostile/asteroid/elite/broodmother/proc/spawn_children(target)
	ranged_cooldown = world.time + 3 SECONDS * revive_multiplier()
	visible_message("<span class='danger'>The ground churns behind [src]!</span>")
	for(var/i in 1 to 2)
		if(length(children_list) >= 8)
			return
		var/mob/living/simple_animal/hostile/asteroid/elite/broodmother_child/newchild = new /mob/living/simple_animal/hostile/asteroid/elite/broodmother_child(loc)
		newchild.GiveTarget(target)
		newchild.faction = faction.Copy()
		visible_message("<span class='danger'>[newchild] appears below [src]!</span>")
		newchild.mother = src
		children_list += newchild

/mob/living/simple_animal/hostile/asteroid/elite/broodmother/proc/rage()
	ranged_cooldown = world.time + 5 SECONDS * revive_multiplier()
	visible_message("<span class='warning'>[src] starts picking up speed!</span>")
	color = "#FF0000"
	speed = 0
	move_to_delay = 3
	addtimer(CALLBACK(src, PROC_REF(reset_rage)), 5 SECONDS)

/mob/living/simple_animal/hostile/asteroid/elite/broodmother/proc/reset_rage()
	color = "#FFFFFF"
	speed = 2
	move_to_delay = 5

/mob/living/simple_animal/hostile/asteroid/elite/broodmother/proc/call_children()
	ranged_cooldown = world.time + 4 SECONDS * revive_multiplier()
	visible_message("<span class='warning'>The ground shakes near [src]!</span>")
	var/list/directions = GLOB.cardinal.Copy() + GLOB.diagonals.Copy()
	for(var/mob/living/child in children_list)
		var/spawndir = pick_n_take(directions)
		var/turf/T = get_step(src, spawndir)
		if(T)
			child.forceMove(T)
			child.revive() // at most this is a 49 hp heal.
			playsound(src, 'sound/effects/bamf.ogg', 100, 1)

//The goliath's children.  Pretty weak, simple mobs which are able to put a single tentacle under their target when at range.
/mob/living/simple_animal/hostile/asteroid/elite/broodmother_child
	name = "baby goliath"
	desc = "A young goliath recently born from it's mother.  While they hatch from eggs, said eggs are incubated in the mother until they are ready to be born."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "goliath_baby"
	icon_living = "goliath_baby"
	icon_aggro = "goliath_baby"
	icon_dead = "goliath_baby_dead"
	icon_gib = "syndicate_gib"
	maxHealth = 50
	health = 50
	melee_damage_lower = 12.5
	melee_damage_upper = 12.5
	armour_penetration_percentage = 50
	attacktext = "bashes against"
	attack_sound = 'sound/weapons/punch1.ogg'
	throw_message = "does nothing to the rocky hide of the"
	speed = 2
	move_to_delay = 5
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	mouse_opacity = MOUSE_OPACITY_ICON
	deathmessage = "falls to the ground."
	status_flags = CANPUSH
	var/mob/living/simple_animal/hostile/asteroid/elite/broodmother/mother = null


/mob/living/simple_animal/hostile/asteroid/elite/broodmother_child/Destroy()
	if(!QDELETED(mother))
		mother.children_list -= src
	mother = null
	return ..()

/mob/living/simple_animal/hostile/asteroid/elite/broodmother_child/OpenFire(target)
	ranged_cooldown = world.time + 40
	var/tturf = get_turf(target)
	if(!isturf(tturf))
		return
	if(get_dist(src, target) <= 7)//Screen range check, so it can't attack people off-screen
		visible_message("<span class='warning'>[src] digs its tentacles under [target]!</span>")
		new /obj/effect/temp_visual/goliath_tentacle/broodmother(tturf, src)

/mob/living/simple_animal/hostile/asteroid/elite/broodmother_child/death()
	. = ..()
	if(!QDELETED(mother))
		mother.children_list -= src
	visible_message("<span class='warning'>[src] explodes!</span>")
	explosion(src, flame_range = 3, adminlog = FALSE)
	new /obj/item/stack/sheet/animalhide/goliath_hide(loc)
	new /obj/effect/gibspawner/human(get_turf(src))
	qdel(src)

//Tentacles stun WAY less compared to regular variant, to balance being able to use them much more often. Also, 10 more damage.
/obj/effect/temp_visual/goliath_tentacle/broodmother/trip()
	var/latched = FALSE
	for(var/mob/living/L in loc)
		if((!QDELETED(spawner) && spawner.faction_check_mob(L)) || L.stat == DEAD)
			continue
		visible_message("<span class='danger'>[src] grabs hold of [L]!</span>")
		L.Stun(1 SECONDS)
		L.KnockDown(2.5 SECONDS)
		L.adjustBruteLoss(rand(20,25))
		latched = TRUE
	if(!latched)
		retract()
	else
		deltimer(timerid)
		timerid = addtimer(CALLBACK(src, PROC_REF(retract)), 1 SECONDS, TIMER_STOPPABLE)

/obj/effect/temp_visual/goliath_tentacle/broodmother/patch/Initialize(mapload, new_spawner)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(createpatch))

/obj/effect/temp_visual/goliath_tentacle/broodmother/patch/proc/createpatch()
	var/tentacle_locs = spiral_range_turfs(1, get_turf(src))
	for(var/T in tentacle_locs)
		new /obj/effect/temp_visual/goliath_tentacle/broodmother(T, spawner)
	var/list/directions = GLOB.cardinal.Copy()
	for(var/i in directions)
		var/turf/T = get_step(get_turf(src), i)
		T = get_step(T, i)
		new /obj/effect/temp_visual/goliath_tentacle/broodmother(T, spawner)

// Broodmother's loot: Broodmother Tongue
/obj/item/crusher_trophy/broodmother_tongue
	name = "broodmother tongue"
	desc = "The tongue of a broodmother. If attached a certain way, makes for a suitable crusher trophy. It also feels very spongey, I wonder what would happen if you squeezed it?..."
	icon = 'icons/obj/lavaland/elite_trophies.dmi'
	icon_state = "broodmother_tongue"
	denied_type = /obj/item/crusher_trophy/broodmother_tongue
	bonus_value = 75 // same reasoning as legionnaire trophy, target if moving will dodge it, and things like hiero trophy does more anyway.
	/// Time at which the item becomes usable again
	var/use_time

/obj/item/crusher_trophy/broodmother_tongue/effect_desc()
	return "mark detonation to have a <b>[bonus_value]%</b> chance to summon a patch of goliath tentacles at the target's location"

/obj/item/crusher_trophy/broodmother_tongue/on_mark_detonation(mob/living/target, mob/living/user)
	if(prob(bonus_value) && target.stat != DEAD)
		new /obj/effect/temp_visual/goliath_tentacle/broodmother/patch(get_turf(target), user)

/obj/item/crusher_trophy/broodmother_tongue/attack_self(mob/user)
	if(!isliving(user))
		return
	var/mob/living/living_user = user
	if(use_time > world.time)
		to_chat(living_user, "<b>The tongue looks dried out. You'll need to wait longer to use it again.</b>")
		return
	else if("lava" in living_user.weather_immunities)
		to_chat(living_user, "<b>You stare at the tongue. You don't think this is any use to you.</b>")
		return
	living_user.weather_immunities += "lava"
	to_chat(living_user, "<b>You squeeze the tongue, and some transluscent liquid shoots out all over you.</b>")
	addtimer(CALLBACK(src, PROC_REF(remove_lava), living_user), 20 SECONDS)
	use_time = world.time + 60 SECONDS

/obj/item/crusher_trophy/broodmother_tongue/proc/remove_lava(mob/living/user)
	user.weather_immunities -= "lava"

#undef TENTACLE_PATCH
#undef SPAWN_CHILDREN
#undef RAGE
#undef CALL_CHILDREN

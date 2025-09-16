/// Place some grappling tentacles underfoot
/datum/action/cooldown/mob_cooldown/goliath_tentacles
	name = "Unleash Tentacles"
	desc = "Unleash burrowed tentacles at a targeted location, grappling targets after a delay."
	button_icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	button_icon_state = "Goliath_tentacle_wiggle"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"
	cooldown_time = 12 SECONDS
	shared_cooldown = NONE
	/// Furthest range we can activate ability at
	var/max_range = 7

/datum/action/cooldown/mob_cooldown/goliath_tentacles/PreActivate(atom/target)
	target = get_turf(target)
	if(get_dist(owner, target) > max_range)
		return FALSE
	return ..()

/datum/action/cooldown/mob_cooldown/goliath_tentacles/Activate(atom/target)
	new /obj/effect/temp_visual/goliath_tentacle(target)
	var/list/directions = GLOB.cardinal.Copy()
	for(var/i in 1 to 3)
		var/spawndir = pick_n_take(directions)
		var/turf/adjacent_target = get_step(target, spawndir)
		if(adjacent_target)
			new /obj/effect/temp_visual/goliath_tentacle(adjacent_target)

	if(isliving(target))
		owner.visible_message("<span class='warning'>[owner] digs its tentacles under [target]!</span>")
	StartCooldown()
	return TRUE

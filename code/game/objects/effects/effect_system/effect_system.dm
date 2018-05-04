/* This is an attempt to make some easily reusable "particle" type effect, to stop the code
constantly having to be rewritten. An item like the jetpack that uses the ion_trail_follow system, just has one
defined, then set up when it is created with New(). Then this same system can just be reused each time
it needs to create more trails.A beaker could have a steam_trail_follow system set up, then the steam
would spawn and follow the beaker, even if it is carried or thrown.
*/

/obj/effect/particle_effect
	name = "particle effect"
	mouse_opacity = 0
	unacidable = 1//So effects are not targeted by alien acid.
	pass_flags = PASSTABLE | PASSGRILLE

/obj/effect/particle_effect/New()
	..()
	if(ticker)
		cameranet.updateVisibility(src)

/obj/effect/particle_effect/Destroy()
	if(ticker)
		cameranet.updateVisibility(src)
	return ..()

/datum/effect_system
	var/number = 3
	var/cardinals = 0
	var/turf/location
	var/atom/holder
	var/effect_type
	var/total_effects = 0

/datum/effect_system/Destroy()
	holder = null
	location = null
	return ..()

/datum/effect_system/proc/set_up(n = 3, c = 0, loca)
	if(n > 10)
		n = 10
	number = n
	cardinals = c
	if(isturf(loca))
		location = loca
	else
		location = get_turf(loca)

/datum/effect_system/proc/attach(atom/atom)
	holder = atom

/datum/effect_system/proc/start()
	for(var/i in 1 to number)
		if(total_effects > 20)
			return
		INVOKE_ASYNC(src, .proc/generate_effect)

/datum/effect_system/proc/generate_effect()
	if(holder)
		location = get_turf(holder)
	var/obj/effect/E = new effect_type(location)
	total_effects++
	var/direction
	if(cardinals)
		direction = pick(cardinal)
	else
		direction = pick(alldirs)
	var/steps_amt = pick(1,2,3)
	for(var/j in 1 to steps_amt)
		sleep(5)
		step(E,direction)
	addtimer(CALLBACK(src, .proc/decrement_total_effect), 20)

/datum/effect_system/proc/decrement_total_effect()
	total_effects--

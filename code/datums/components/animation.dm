/datum/component/animation
	var/list/animations
	var/random_animation
	var/random_animation_min_delay
	var/random_animation_max_delay
	var/animation_going_on = FALSE

/datum/component/animation/Initialize(list/animation_list, random_animation, random_animation_duration, random_animation_min_delay, random_animation_max_delay)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	animations = animation_list.Copy()

	if(random_animation)
		src.random_animation = random_animation
		src.random_animation_min_delay = random_animation_min_delay
		src.random_animation_max_delay = random_animation_max_delay
		animations["RANDOM"] = list(random_animation, random_animation_duration)
		addtimer(CALLBACK(src, .proc/flick_animation, "RANDOM", TRUE), rand(random_animation_min_delay, random_animation_max_delay))

	if(length(animation_list))
		for(var/signal in animation_list)
			RegisterSignal(parent, signal, CALLBACK(src, .proc/flick_animation, signal, FALSE))

/datum/component/animation/proc/flick_animation(animation_index, random = FALSE)
	if(!animation_going_on)
		animation_going_on = TRUE
		var/list/animation_list = animations[animation_index]
		flick(animation_list[1], parent)
		addtimer(CALLBACK(src, .proc/animation_ended), animation_list[2])
		// flick animation

	if(random)
		addtimer(CALLBACK(src, .proc/flick_animation, animation_index, TRUE), rand(random_animation_min_delay, random_animation_max_delay))

/datum/component/animation/proc/animation_ended()
	animation_going_on = FALSE

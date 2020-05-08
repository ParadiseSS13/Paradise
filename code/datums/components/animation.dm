/datum/component/animation
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/list/animations				// Assoc List of animation_objects paired to their signal list(signal = animation_object)
	var/list/random_animations		// Weighted list of animations. list(animation_object = weight)
	var/random_animation_min_delay	// How long at a minimum in between random animations
	var/random_animation_max_delay	// How long at a maximum in between random animations
	var/animation_going_on = FALSE	// Prevents animations from disrupting one another


/* This component will flick animations on objects defined in the input
 * animation_list assoc list of animations with the signal as key
 * random_animation_list weighted list of animations
 * random_animation_min_delay the minimum delay between random animations
 * random_animation_max_delay the maximum delay between random animations
 */
/datum/component/animation/Initialize(list/datum/animation_object/animation_list, list/datum/animation_object/random_animation_list, random_animation_min_delay, random_animation_max_delay)
	if(!isatom(parent))
		log_debug("/datum/component/animation initialized with non atom parent: [parent] ([parent.type])")
		return COMPONENT_INCOMPATIBLE

	if(!length(animation_list) && !length(random_animation_list))
		log_debug("/datum/component/animation initialized without animations: [parent] ([parent.type])")
		return COMPONENT_INCOMPATIBLE

	if(length(random_animation_list) && (isnull(random_animation_min_delay) || isnull(random_animation_max_delay)))
		log_debug("/datum/component/animation initialized with random animations without proper timing : [parent] ([parent.type]), ([random_animation_min_delay] - [random_animation_max_delay])")
		return COMPONENT_INCOMPATIBLE

	if(length(animation_list))
		animations = animation_list.Copy()
		for(var/signal in animation_list)
			if(animation_list[signal])
				RegisterSignal(parent, signal, CALLBACK(src, .proc/flick_animation, animation_list[signal]))

	if(length(random_animation_list))
		src.random_animations = random_animation_list.Copy()
		src.random_animation_min_delay = random_animation_min_delay
		src.random_animation_max_delay = random_animation_max_delay
		addtimer(CALLBACK(src, .proc/pick_random_animation), rand(random_animation_min_delay, random_animation_max_delay))

/datum/component/animation/proc/pick_random_animation()
	flick_animation(pickweight(random_animations))
	addtimer(CALLBACK(src, .proc/pick_random_animation), rand(random_animation_min_delay, random_animation_max_delay))

/datum/component/animation/proc/flick_animation(datum/animation_object/animation)
	if(!animation_going_on)
		animation_going_on = TRUE
		flick(animation.icon_state, animation.owner)
		addtimer(CALLBACK(src, .proc/animation_ended), animation.animation_duration)
		// flick animation

/datum/component/animation/proc/animation_ended()
	animation_going_on = FALSE

// Holder object for the animation data
/datum/animation_object
	var/atom/owner				// Who the animation should be done on
	var/icon_state				// icon state of the animation
	var/animation_duration		// How long the animation lasts

/datum/animation_object/New(atom/owner, icon_state, animation_duration)
	if(!istype(owner))
		log_debug("/datum/animation_object newed with invalid owner [owner]")
		qdel(src)
		return
	src.owner = owner
	src.icon_state = icon_state
	src.animation_duration = animation_duration

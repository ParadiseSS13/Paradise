/obj/effect/simon_says
	name = "strange platform"
	desc = "A strange platform of alien design."
	icon = 'icons/effects/simon_says_32x32.dmi'
	icon_state = "pad"
	var/fail_sound = 'sound/effects/simon_says_wrong.ogg'
	var/success_sound = 'sound/effects/simon_says_success.ogg'
	/// The chosen rhythm to play
	var/list/rhythm = list()
	/// List of all rhythms to choose from, made from lists of time from the start in deciseconds
	var/static/list/rhythms = list(
		// 7 Elevens are like the greatest thing
		list(0, 7, 11, 14, 21, 22, 28, 33, 35, 42, 44, 49, 55, 56, 63, 66, 70),
		list(0, 2.5, 7.5, 10, 15, 17.5, 22.5, 27.5, 30, 35, 40),
		list(0, 8, 10, 16, 20, 24, 30, 32, 40),
		list(0, 6, 10, 12, 18, 20, 24, 30),
		list(0, 3, 6, 12, 18, 30, 33, 36, 39, 45, 51),
	)
	var/static/list/pad_colors = list(
									"#b45e5e",
									"#3c6474",
									"#8a7d44",
									"#b45e5e",
									"#3c6474",
									"#8a7d44",
									)
	var/static/list/pad_sounds = list(
									'sound/effects/simon_says_1.ogg',
									'sound/effects/simon_says_2.ogg',
									'sound/effects/simon_says_3.ogg',
									'sound/effects/simon_says_4.ogg',
									'sound/effects/simon_says_5.ogg',
									'sound/effects/simon_says_6.ogg',)
	/// The time at which we should finish playing the sequence
	var/playing_until = 0
	/// Buttons pressed by the player so far
	var/list/pressed_buttons = list()
	/// The sequence we generated
	var/list/sequence = list()
	/// List of connected pads(normally generated on init)
	var/list/pads = list()
	/// current index in the sequence we check our pressed button against
	var/current_index = 0
	/// ID for autolinking an airlock on init
	var/autolink_id
	/// UID of the linked airlock
	var/airlock_uid

/obj/effect/simon_says/Initialize(mapload)
	. = ..()
	var/turf/place = get_turf(src)
	place = locate(place.x, place.y + 4, place.z)
	if(place.x >= world.maxx - 1 || place.x <= 2 || place.y >= world.maxy - 1 || place.y <= 2)
		qdel(src)
		return
	var/id = 1
	for(var/cardinal in list(NORTHWEST, NORTHEAST, EAST, SOUTHEAST, SOUTHWEST, WEST))
		var/turf/curr_place = place
		if(cardinal & (NORTH | SOUTH))
			curr_place = get_step(place, cardinal & (NORTH | SOUTH))
		else
			curr_place = get_step(place, cardinal & (EAST | WEST))
		pads += new /obj/effect/simon_says_pad(get_step(curr_place, cardinal), id++, src)

/obj/effect/simon_says/Destroy()
	for(var/obj/effect/simon_says_pad/pad in pads)
		qdel(pad)
	return ..()

/obj/effect/simon_says/Cross(atom/movable/crossed_atom)
	. = ..()
	if(!ismob(crossed_atom) || (playing_until >= world.time))
		return
	play_music()

/obj/effect/simon_says/proc/reset_buttons()
	pressed_buttons = list()
	current_index = 0

/obj/effect/simon_says/proc/play_music()
	if(!length(sequence))
		generate_sequence()
	playing_until = world.time + rhythm[length(rhythm)]
	reset_buttons()
	for(var/i in 1 to length(sequence))
		var/obj/effect/simon_says_pad/curr_pad = pads[sequence[i]]
		addtimer(CALLBACK(curr_pad, TYPE_PROC_REF(/obj/effect/simon_says_pad, play_note)), rhythm[i])
	for(var/obj/machinery/door/airlock/to_link in range(10, get_turf(src)))
		if(to_link.id_tag == autolink_id)
			airlock_uid = to_link.UID()

/obj/effect/simon_says/proc/generate_sequence()
	sequence = list()
	if(!length(rhythm))
		rhythm = pick(rhythms)
	var/list/pad_options = list()

	// The reason we do all this instead of just rand(1, length(pads)) is so we can exclude pads that were played too recently
	for(var/i in 1 to length(pads))
		pad_options += list(list(i, -5))

	for(var/beat in rhythm)
		// Exclude pads that have played too recently
		var/list/excluded = list()
		for(var/option in pad_options)
			if(beat - option[2] < 3)
				excluded += list(option)
		pad_options -= excluded
		var/picked = pick(pad_options)
		sequence += picked[1]
		picked[2] = beat
		pad_options += excluded

/obj/effect/simon_says/proc/check_completion()
	if(!sequence || !length(sequence))
		return
	if(sequence[current_index] != pressed_buttons[current_index])
		do_failure()
		return
	if(current_index == length(sequence))
		do_success()


/obj/effect/simon_says/proc/play_sound(sound, blink_color)
	animate_flash(src, blink_color, 2)
	playsound(src, sound, 100, FALSE, falloff_exponent = SOUND_FALLOFF_EXPONENT / 4)

/obj/effect/simon_says/proc/do_failure()
	reset_buttons()
	play_sound(fail_sound, "#ff1100")

/obj/effect/simon_says/proc/do_success()
	reset_buttons()
	play_sound(success_sound, "#00e600")
	var/obj/machinery/door/airlock/activated = locateUID(airlock_uid)
	activated.airlock_cycle_callback("secure_open")


/obj/effect/simon_says_pad
	name = "strange platform"
	desc = "A strange platform of alien design, it looks like something will happen if you stand on it"
	icon = 'icons/effects/simon_says_32x32.dmi'
	icon_state = "pad"
	//pixel_x = -8
	//pixel_y = -8
	/// The simon says minigame we are a part of
	var/obj/effect/simon_says/owner
	/// Sound we make when playing
	var/sound = 'sound/effects/simon_says_1.ogg'
	/// ID used for comparing what we pressed against the sequence
	var/id = 1
	/// Time the pad was last played
	var/last_played = 0

/obj/effect/simon_says_pad/Initialize(mapload, _id, _owner)
	. = ..()
	owner = _owner
	id = _id
	if(owner)
		color = owner.pad_colors[id]
		sound = owner.pad_sounds[id]

/obj/effect/simon_says_pad/proc/play_note()
	last_played = world.time
	var/list/hsl = rgb2num(color, COLORSPACE_HSL)
	hsl[3] = hsl[3] + (100 - hsl[3]) * 0.7
	var/target = rgb(hsl[1], hsl[2], hsl[3], space= COLORSPACE_HSL)
	playsound(src, sound, 100, FALSE, falloff_exponent = SOUND_FALLOFF_EXPONENT / 4)
	animate_flash(src, target, 1.5)

/obj/effect/simon_says_pad/Cross(atom/movable/crossed_atom)
	. = ..()
	if(!ismob(crossed_atom)  || (owner.playing_until >= world.time) || world.time < last_played + 3)
		return
	play_note()
	owner.pressed_buttons += id
	owner.current_index++
	owner.check_completion()

/proc/animate_flash(atom/to_flash , color, length)
	var/my_color = to_flash.color
	animate(to_flash, color = color, time = length, easing = SINE_EASING)
	spawn(length)
		animate(to_flash, color = my_color, time = length, easing = SINE_EASING)

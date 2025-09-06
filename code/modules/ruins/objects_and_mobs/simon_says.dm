#define simon_pad_id_to_sound(id) (id == 1 ? 'sound/effects/simon_says_1.ogg' : id == 2 ? 'sound/effects/simon_says_3.ogg' : id == 3 ? 'sound/effects/simon_says_2.ogg' : 'sound/effects/simon_says_4.ogg')
#define simon_pad_id_to_color(id) (id == 1 ? "#ac0064" : id == 2 ? "#00597c" : id == 3 ? "#ac0064" : "#00597c")

/obj/effect/simon_says
	name = "strange platform"
	desc = "A strange platform of alien design, it looks like something will happen if you stand on it"
	icon = 'icons/effects/simon_says.dmi'
	icon_state = "pad"
	pixel_x = -8
	pixel_y = -8
	var/fail_sound = 'sound/effects/simon_says_wrong.ogg'
	var/success_sound = 'sound/effects/simon_says_success.ogg'
	/// The chosen rhythm to play
	var/list/rhythm = list()
	/// List of all rhythms to choose from, made from lists of time from the start in deciseconds
	var/static/list/rhythms = list(
		// 7 Elevens are like the greatest thing
		list(0, 7, 11, 14, 21, 22, 28, 33, 35, 42, 44, 49, 55, 56, 63, 66, 70),
		list(0, 5, 15, 20, 30, 35, 45, 55, 60, 70, 80),
		list(0, 8, 10, 16, 20, 24, 30, 32, 40),
		list(0, 6, 10, 12, 18, 20, 24, 30),
		list(0, 3, 6, 12, 18, 30, 33, 36, 39, 45, 51),
	)
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
	color = "#00CCB7"
	var/turf/place = get_turf(src)
	place = locate(place.x, place.y + 4, place.z)
	if(place.x >= world.maxx - 1 || place.x <= 2 || place.y >= world.maxy - 1 || place.y <= 2)
		qdel(src)
		return
	var/id = 1
	for(var/cardinal in list(NORTHWEST, NORTHEAST, SOUTHEAST, SOUTHWEST))
		pads += new /obj/effect/simon_says_pad(get_step(get_step(place, cardinal), cardinal), id++, src)

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
	for(var/beat in rhythm)
		sequence += rand(1, 4)

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
	icon = 'icons/effects/simon_says.dmi'
	icon_state = "pad"
	pixel_x = -8
	pixel_y = -8
	var/obj/effect/simon_says/owner
	var/sound = 'sound/effects/simon_says_1.ogg'
	var/id = 1

/obj/effect/simon_says_pad/Initialize(mapload, _id, _owner)
	. = ..()
	owner = _owner
	id = _id
	color = simon_pad_id_to_color(id)
	sound = simon_pad_id_to_sound(id)

/obj/effect/simon_says_pad/proc/play_note()
	var/list/hsl = rgb2num(color, COLORSPACE_HSL)
	hsl[3] = hsl[3] + (100 - hsl[3]) * 0.4
	var/target = rgb(hsl[1], hsl[2], hsl[3], space= COLORSPACE_HSL)
	playsound(src, sound, 100, FALSE, falloff_exponent = SOUND_FALLOFF_EXPONENT / 4)
	animate_flash(src, target, 2)

/obj/effect/simon_says_pad/Cross(atom/movable/crossed_atom)
	. = ..()
	if(!ismob(crossed_atom)  || (owner.playing_until >= world.time))
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

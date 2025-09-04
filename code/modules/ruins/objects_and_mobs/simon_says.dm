#define simon_pad_dir_to_color(dir) (dir & NORTH ? "#a200ff" : dir & SOUTH ? "#59a7ff" : dir & EAST ? "#00b18a" : "#ff6600")
#define simon_pad_dir_to_id(dir) (dir & NORTH ? 1 : dir & SOUTH ? 3 : dir & EAST ? 2 : 4)

/obj/effect/simon_says
	icon = 'icons/effects/simon_says'
	icon_state = "center"
	var/list/rhythm = list()
	var/static/list/rhythms = list(
		// 7 Elevens are like the greatest thing
		list(14, 22, 28, 42, 44, 56, 66, 70, 84, 88, 98, 110, 112, 126, 132, 140, 154),

	)
	/// The time at which we should finish playing the sequence
	var/playing_until = 0
	/// Buttons pressed by the player
	var/list/pressed_buttons = list()
	var/list/sequence = list()
	var/list/pads = list()

/obj/effect/simon_says/Initialize(mapload)
	. = ..()
	var/turf/place = get_turf(src)
	if(place.x >= world.maxx - 1 || place.x <= 2 || place.y <= world.maxy - 1 || place.y <= 2)
		qdel(src)
		return
	for(var/cardinal in list(NORTH, EAST, SOUTH, WEST))
		pads += new /obj/effect/simon_says_pad(get_step(get_step(src, cardinal), cardinal), cardinal, src)


/obj/effect/simon_says/Bumped(atom/movable/AM)
	. = ..()
	if(!ismob(AM) || (playing_until >= world.time))
		return


/obj/effect/simon_says/proc/play_music()
	if(!length(sequence))
		generate_sequence()
	playing_until = world.time + rhythm[length(rhythm)]
	pressed_buttons = list()
	for(var/i in 1 to length(rhythm))
		var/obj/effect/simon_says_pad/curr_pad = pads[sequence[i]]
		addtimer(CALLBACK(curr_pad, PROC_REF(play_note)), rhythm[i])

/obj/effect/simon_says/proc/press_button()

/obj/effect/simon_says/proc/generate_sequence()
	sequence = list()
	if(!length(rhythm))
		rhythm = pick(rhythms)
	for(var/beat in rhythm)
		sequence += rand(1, 4)

/obj/effect/simon_says_pad
	icon = 'icons/effects/simon_says'
	icon_state = "pad_0"
	var/obj/effect/simon_says/owner
	var/sound = 'sound/effects/simon_says_1'
	var/id = 1

/obj/effect/simon_says_pad/Initialize(mapload, direction, _owner)
	. = ..()
	owner = _owner
	dir = direction
	id = simon_pad_dir_to_id(dir)
	color = simon_pad_dir_to_color(dir)

/obj/effect/simon_says_pad/proc/play_note()
	playsound(src, sound)

/obj/effect/simon_says_pad/Bumped(atom/movable/AM)
	. = ..()
	if(!ismob(AM))
		return
	playsound(src, sound)
	owner.pressed_buttons += src.dir

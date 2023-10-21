/obj/structure/closet/cardboard
	name = "large cardboard box"
	desc = "Just a box..."
	icon = 'icons/obj/cardboard_boxes.dmi'
	icon_state = "cardboard"
	open_door_sprite = null
	resistance_flags = FLAMMABLE
	max_integrity = 70
	integrity_failure = 0
	open_sound = 'sound/machines/cardboard_box.ogg'
	close_sound = 'sound/machines/cardboard_box.ogg'
	open_sound_volume = 35
	close_sound_volume = 35
	material_drop = /obj/item/stack/sheet/cardboard
	/// How fast a mob can move inside this box.
	var/move_speed_multiplier = 1
	var/amt = 4
	var/move_delay = FALSE
	var/egged = 0

/obj/structure/closet/cardboard/relaymove(mob/living/user, direction)
	if(!istype(user) || opened || move_delay || user.incapacitated() || !isturf(loc) || !has_gravity(loc))
		return
	move_delay = TRUE
	var/oldloc = loc
	step(src, direction)
	// By default, while inside a box, we move at walk speed times the speed multipler of the box.
	var/delay = GLOB.configuration.movement.base_walk_speed * move_speed_multiplier
	if(IS_DIR_DIAGONAL(direction))
		delay *= SQRT_2 // Moving diagonal counts as moving 2 tiles, we need to slow them down accordingly.
	if(oldloc != loc)
		addtimer(CALLBACK(src, PROC_REF(ResetMoveDelay)), delay)
	else
		move_delay = FALSE

/obj/structure/closet/cardboard/proc/ResetMoveDelay()
	move_delay = FALSE

/obj/structure/closet/cardboard/open()
	if(opened || !can_open())
		return 0
	if(!egged)
		var/mob/living/Snake = null
		for(var/mob/living/L in src.contents)
			Snake = L
			break
		if(Snake)
			var/list/alerted = viewers(7,src)
			if(alerted)
				for(var/mob/living/L in alerted)
					if(!L.stat)
						L.do_alert_animation(L)
						egged = 1
				SEND_SOUND(alerted, sound('sound/machines/chime.ogg'))
	return ..()

/mob/living/proc/do_alert_animation(atom/A)
	var/image/I
	I = image('icons/obj/cardboard_boxes.dmi', A, "cardboard_special", A.layer+1)
	var/list/viewing = list()
	for(var/mob/M in viewers(A))
		if(M.client)
			viewing |= M.client
	flick_overlay(I,viewing,8)
	I.alpha = 0
	animate(I, pixel_z = 32, alpha = 255, time = 5, easing = ELASTIC_EASING)

/obj/structure/closet/cardboard/welder_act()
	return

/obj/structure/closet/cardboard/attackby(obj/item/W as obj, mob/user as mob, params)
	if(src.opened)
		if(istype(W, /obj/item/wirecutters))
			var/obj/item/wirecutters/WC = W
			new /obj/item/stack/sheet/cardboard(src.loc, amt)
			for(var/mob/M in viewers(src))
				M.show_message("<span class='notice'>\The [src] has been cut apart by [user] with \the [WC].</span>", 3, "You hear cutting.", 2)
			qdel(src)
			return
		if(is_pen(W))
			var/decalselection = input("Please select a decal") as null|anything in list("Atmospherics", "Bartender", "Barber", "Blueshield", "Captain",
			"Cargo", "Chief Engineer",	"Chaplain",	"Chef", "Chemist", "Assistant", "Clown", "CMO", "Coroner", "Detective", "Engineering", "Genetics", "HOP",
			"HOS", "Hydroponics", "Internal Affairs Agent", "Janitor",	"Magistrate", "Medical", "Mime", "Mining", "NT Representative", "Paramedic",
			"Prisoner",	"Research Director", "Security", "Syndicate", "Therapist", "Virology", "Warden", "Xenobiology")
			if(!decalselection)
				return
			if(user.incapacitated())
				to_chat(user, "You're in no condition to perform this action.")
				return
			if(W != user.get_active_hand())
				to_chat(user, "You must be holding the pen to perform this action.")
				return
			if(!Adjacent(user))
				to_chat(user, "You have moved too far away from the cardboard box.")
				return
			decalselection = replacetext(decalselection, " ", "_")
			decalselection = lowertext(decalselection)
			icon_opened = ("cardboard_open_"+decalselection)
			icon_closed = ("cardboard_"+decalselection)
			update_icon() // a proc declared in the closets parent file used to update opened/closed sprites on normal closets

#define MACHINE_ANIMATION 1
#define PICKUP_ANIMATION 2

/obj/item/attack_hand(mob/user as mob)
	var/in_something = src.in_inventory || src.in_storage
	var/atom/itm_loc = src.loc
	. = ..()
	if(. && !in_something)
		do_item_animation(user, src, itm_loc, PICKUP_ANIMATION, FALSE)

/obj/machinery/disposal/attackby(obj/item/I, mob/user)
	. = ..()
	if(!I.in_inventory) do_item_animation(user, I, src)

/obj/machinery/kitchen_machine/add_item(obj/item/I, mob/user)
	. = ..()
	if(!I.in_inventory) do_item_animation(user, I, src)

/obj/machinery/chem_master/attackby(obj/item/I, mob/user)
	. = ..()
	if(!I.in_inventory) do_item_animation(user, I, src)

/obj/machinery/chem_dispenser/attackby(obj/item/I, mob/user)
	. = ..()
	if(!I.in_inventory) do_item_animation(user, I, src)

/obj/machinery/chem_heater/attackby(obj/item/I, mob/user)
	. = ..()
	if(!I.in_inventory) do_item_animation(user, I, src)

/obj/machinery/photocopier/attackby(obj/item/O, mob/user)
	. = ..()
	if(!O.in_inventory) do_item_animation(user, O, src)

/obj/machinery/mineral/ore_redemption/attackby(obj/item/I, mob/user)
	. = ..()
	if(!I.in_inventory) do_item_animation(user, I, src)

/proc/do_item_animation(mob/user, obj/item/itm, atom/A, anim_type = MACHINE_ANIMATION, reverse = TRUE)
	var/image/I = image(icon = itm, loc = user, layer = user.layer + 0.1)
	I.plane = GAME_PLANE
	I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	I.pixel_x = A.pixel_x - user.pixel_x
	I.pixel_y = A.pixel_y - user.pixel_y

	var/direction = get_dir(user, A)
	if(direction & EAST) I.pixel_x += 32
	else if(direction & WEST) I.pixel_x -= 32
	if(direction & NORTH) I.pixel_y += 32
	else if(direction & SOUTH) I.pixel_y -= 32

	if(reverse)
		I.loc = A
		I.pixel_x*=-1
		I.pixel_y*=-1

	I.appearance_flags |= RESET_TRANSFORM | KEEP_APART
	var/list/viewing = list()
	for(var/mob/M in viewers(user))
		if(M.client)
			viewing += M.client
	flick_overlay(I, viewing, 3)

	var/matrix/new_transform = matrix()
	switch(anim_type)
		if(PICKUP_ANIMATION)
			I.pixel_x += itm.pixel_x
			I.pixel_y += itm.pixel_y
			new_transform.Scale(0.5)

			animate(I, pixel_x = 0, pixel_y = 0, transform = new_transform, time = 2)
			animate(alpha = 0, time = 2, easing = CUBIC_EASING | EASE_IN, flags = ANIMATION_PARALLEL)
		if(MACHINE_ANIMATION)
			I.transform *= 0.75
			var/target_y = 0

			if(istype(A, /obj/machinery/disposal))
				new_transform.Turn(I.pixel_x<0?120:-120)
				if(A.parent_type != /obj/machinery/disposal)
					target_y = 7;
				animate(I,  transform = new_transform, time = 2)
			animate(I, pixel_x = 0, pixel_y = target_y, time = 2, flags = ANIMATION_PARALLEL)
			animate(I, alpha = 0, time = 2, easing = CIRCULAR_EASING | EASE_IN, flags = ANIMATION_PARALLEL)

/obj/structure/table/attackby(obj/item/I, mob/user)
	. = ..()
	if(!I.in_inventory)
		var/transform_old = I.transform
		var/alpha_old = I.alpha
		var/pixel_x_old = I.pixel_x
		var/pixel_y_old = I.pixel_y

		I.pixel_x = user.pixel_x
		I.pixel_y = user.pixel_y

		var/direction = get_dir(I, user)
		if(direction & EAST) I.pixel_x = 32
		else if(direction & WEST) I.pixel_x = -32
		if(direction & NORTH)I.pixel_y = 32
		else if(direction & SOUTH) I.pixel_y = -32

		I.transform *= 0.5
		I.alpha = 0
		animate(I, alpha = alpha_old, pixel_x = pixel_x_old, pixel_y = pixel_y_old, transform = transform_old, time = 0.12 SECONDS, easing = QUAD_EASING)

#undef MACHINE_ANIMATION
#undef PICKUP_ANIMATION

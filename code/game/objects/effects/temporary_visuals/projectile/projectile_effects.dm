//This is the parent of all projectile effects, impact muzzle and tracer.

/obj/effect/projectile
	name = "pew"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "nothing"
	layer = HITSCAN_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = LONG_GLIDE

/obj/effect/projectile/singularity_pull()
	return

/obj/effect/projectile/singularity_act()
	return

/obj/effect/projectile/proc/scale_to(nx,ny,override=TRUE)
	var/matrix/M
	if(!override)
		M = transform
	else
		M = new
	M.Scale(nx, ny)
	transform = M

/obj/effect/projectile/proc/turn_to(angle,override=TRUE)
	var/matrix/M
	if(!override)
		M = transform
	else
		M = new
	M.Turn(angle)
	transform = M

/obj/effect/projectile/New(angle_override, p_x, p_y, color_override, scaling = 1)
	if(angle_override && p_x && p_y && color_override && scaling)
		apply_vars(angle_override, p_x, p_y, color_override, scaling)
	return ..()

/obj/effect/projectile/proc/apply_vars(angle_override, p_x = 0, p_y = 0, color_override, scaling = 1, new_loc, increment = 0)
	var/mutable_appearance/look = new(src)
	look.appearance_flags = RESET_COLOR | RESET_ALPHA
	look.pixel_x = p_x
	look.pixel_y = p_y
	if(color_override)
		look.color = color_override
		look.appearance_flags = RESET_ALPHA
	else
		look.appearance_flags = RESET_COLOR | RESET_ALPHA
	icon_state = null
	add_overlay(look)
	scale_to(1, scaling, FALSE)
	turn_to(angle_override, FALSE)
	if(!isnull(new_loc)) //If you want to null it just delete it...
		forceMove(new_loc)
	for(var/i in 1 to increment)
		pixel_x += round((sin(angle_override) + 16 * sin(angle_override) * 2), 1)
		pixel_y += round((cos(angle_override) + 16 * cos(angle_override) * 2), 1)

/obj/effect/projectile_lighting
	var/owner

/obj/effect/projectile_lighting/Initialize(mapload, color, range, intensity, owner_key)
	. = ..()
	set_light(range, intensity, color)
	owner = owner_key

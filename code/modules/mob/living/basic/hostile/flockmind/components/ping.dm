/datum/component/flock_ping
	var/duration = 5 SECONDS
	var/outline_color = "#00ff9d"
	var/outline_thickness = 1
	var/animate = TRUE

	var/datum/atom_hud/alternate_appearance/basic/flock/hud_ref
	var/obj/effect/abstract/dummy

/datum/component/flock_ping/Initialize(duration)
	. = ..()
	if(!ismovable(parent) && !isturf(parent))
		return COMPONENT_INCOMPATIBLE

	if(duration)
		src.duration = duration

/datum/component/flock_ping/Destroy()
	QDEL_NULL(dummy)
	return ..()

/datum/component/flock_ping/RegisterWithParent()
	. = ..()
	//this cast looks horribly unsafe, but we've guaranteed that parent is a type with vis_contents in Initialize
	var/atom/movable/target = parent

	target.render_target = REF(target)

	var/image/outline_container = new()
	outline_container.plane = HUD_PLANE
	outline_container.loc = target
	outline_container.appearance_flags = PIXEL_SCALE | RESET_TRANSFORM | RESET_COLOR | KEEP_APART | NO_CLIENT_COLOR

	dummy ||= new()
	dummy.vis_flags = VIS_INHERIT_PLANE | VIS_INHERIT_LAYER
	dummy.appearance_flags = PIXEL_SCALE | RESET_TRANSFORM | RESET_COLOR | PASS_MOUSE
	dummy.render_source = REF(target)

	dummy.add_filter("outline", 1, outline_filter(size = outline_thickness, color = outline_color))
	if (isturf(target))
		dummy.add_filter("mask", 2, alpha_mask_filter(render_source = target.render_target, flags = MASK_INVERSE))

	outline_container.vis_contents += dummy

	if(animate)
		animate(dummy, time = 0.5 SECONDS, alpha = 100, loop = -1)
		animate(time = 0.5 SECONDS, alpha = 255)

	hud_ref = target.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/flock, "ping-[type]-[REF(target)]", outline_container)

	if(duration == INFINITY)
		return

	addtimer(CALLBACK(src, PROC_REF(cleanup)), duration)

/datum/component/flock_ping/UnregisterFromParent()
	. = ..()
	var/atom/movable/target = parent
	target.remove_alt_appearance(hud_ref.appearance_key)

/datum/component/flock_ping/proc/cleanup()
	qdel(src)

/datum/component/flock_ping/apc_power
	duration = 5 SECONDS
	outline_color = "#ffff00"

/datum/component/flock_ping/selected
	animate = FALSE
	outline_thickness = 3
	duration = INFINITY

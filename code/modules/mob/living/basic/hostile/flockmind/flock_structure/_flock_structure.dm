TYPEINFO_DEF(/obj/structure/flock)
	default_armor = list(BLUNT = -20, PUNCTURE = -20, SLASH = -20, LASER = 80, ENERGY = 80, BOMB = 0, BIO = 100, FIRE = 80, ACID = 100)

/obj/structure/flock

	name = "CALL A CODER AAAAAAAAAA"
	icon = 'goon/icons/mob/featherzone.dmi'
	anchored = TRUE
	density = TRUE

	max_integrity = 50

	var/datum/flock/flock

	/// Info tag for the flock name of the structure.
	var/obj/effect/abstract/info_tag/flock/name_tag
	/// Info tag for the actual information of the structure.
	var/obj/effect/abstract/info_tag/flock/info/info_tag

	var/flock_id
	/// Shown in the flockmind UI
	var/flock_desc

	/// How much juice it takes to construct
	var/resource_cost = 0
	/// How long it takes to build
	var/build_time = 0
	/// Is the tealprint cancellable
	var/cancellable = TRUE
	/// Is the structure finished?
	var/fully_built = FALSE
	/// If TRUE, flockdrones cannot deconstruct this.
	var/no_flock_decon = FALSE

	/// world.time this was created at
	var/spawn_time
	/// How much bandwidth this structure provides to the Flock.
	var/bandwidth_provided = 0

	/// Whether or not the turret is active. The state of the Flock can change this.
	var/active = FALSE
	/// The bandwidth cost while active
	var/active_bandwidth_cost = 0

	/// Allows flockdrones to pass through.
	var/allow_flockpass = TRUE

	COOLDOWN_DECLARE(scream_cd)

/obj/structure/flock/Initialize(mapload, datum/flock/join_flock)
	. = ..()

	spawn_time = world.time

	join_flock ||= get_default_flock()
	if(join_flock)
		join_flock.add_structure(src)
		AddComponent(/datum/component/flock_object, join_flock)

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_crossed),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

	if(build_time)
		START_PROCESSING(SSobj, src)
	else
		finish_building()

	ADD_TRAIT(src, TRAIT_FLOCK_EXAMINE, INNATE_TRAIT)
	if(no_flock_decon)
		ADD_TRAIT(src, TRAIT_FLOCK_NODECON, INNATE_TRAIT)

	name_tag = new()
	name_tag.set_parent(src)
	name_tag.set_text(flock_id)

	info_tag = new()
	info_tag.set_parent(src)
	return INITIALIZE_HINT_LATELOAD

/obj/structure/flock/LateInitialize()
	. = ..()
	update_info_tag()

/obj/structure/flock/Destroy()
	STOP_PROCESSING(SSobj, src)
	flock?.free_structure(src)
	QDEL_NULL(name_tag)
	QDEL_NULL(info_tag)
	return ..()

/obj/structure/flock/get_flock_id()
	return flock_id

// /obj/structure/flock/on_mouse_enter(client/client)
// 	. = ..()
// 	if(client?.keys_held?["Shift"])
// 		return

// 	var/mob/M = client.mob
// 	if(info_tag.mob_should_see(M))
// 		info_tag.show_to(M)

// /obj/structure/flock/MouseExited(location, control, params)
// 	. = ..()
// 	if(!usr.client?.keys_held?["Shift"])
// 		info_tag.hide_from(usr)

/obj/structure/flock/cage/do_hurt_animation()
	for(var/i in 1 to 3)
		animate(src, pixel_x = rand(-2, 2), pixel_y = rand(-2, 2), time = 0.5, flags = ANIMATION_RELATIVE | ANIMATION_CONTINUE)

	animate(src, pixel_x = base_pixel_x, pixel_y = base_pixel_y, time = 0.5, flags = ANIMATION_CONTINUE)

/obj/structure/flock/proc/get_flock_data()
	. = list()
	.["ref"] = ref(src)
	.["name"] = flock_id
	.["health"] = get_integrity_percentage()
	.["compute"] = active ? -active_bandwidth_cost : bandwidth_provided
	.["desc"] = flock_desc
	.["area"] = get_area_name(src, TRUE) || "???"

/obj/structure/flock/deconstruct(disassembled)
	visible_message(span_warning("[src] dissolves into nothingness."))
	var/refund = round(get_integrity_percentage() * (disassembled ? 1 : 0.5) * resource_cost, 1)
	if(refund)
		var/obj/item/flock_cube/cube = new(drop_location())
		cube.substrate = refund

	return ..()

/obj/structure/flock/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(allow_flockpass)
		return isflockdrone(mover)

/obj/structure/flock/try_flock_convert(datum/flock/flock, force)
	return

/obj/structure/flock/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return

	if(user.combat_mode)
		user.visible_message(span_danger("<b>[user]</b> punches <b>[src]."))
		user.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
		//playsound(src, 'sound/impact_sounds/Crystal_Hit_1.ogg', 50, TRUE, -1)
		bitch_and_moan()
		take_damage(1, BRUTE, BLUNT)
		return TRUE

/obj/structure/flock/attacked_by(obj/item/attacking_item, mob/living/user)
	. = ..()
	if(!.)
		return

	bitch_and_moan()
	// if (. < 5)
	// 	playsound(src, 'sound/impact_sounds/Crystal_Hit_1.ogg', 50, TRUE)
	// else
	// 	playsound(src, 'sound/impact_sounds/Glass_Shards_Hit_1.ogg', 50, TRUE)

/obj/structure/flock/update_integrity(new_value)
	. = ..()
	if(isnull(.))
		return

	if(!flock)
		return

	var/datum/atom_hud/alternate_appearance/basic/flock/notice = get_alt_appearance(FLOCK_NOTICE_HEALTH)
	if(!notice)
		notice = flock.add_notice(src, FLOCK_NOTICE_HEALTH)

	var/image/I = notice.image
	I.icon_state = "hp-[get_integrity_percentage()]"

/obj/structure/flock/process(delta_time)
	update_info_tag()
	if(spawn_time + build_time <= world.time)
		finish_building()
		return

/// Returns the number of seconds remaining for the build.
/obj/structure/flock/proc/build_time_left()
	return ((spawn_time + build_time) - world.time) / 10

/obj/structure/flock/proc/set_active(new_state)
	if(active == new_state)
		return

	active = new_state
	update_appearance()

	if(active)
		flock.remove_bandwidth_influence(bandwidth_provided)
		flock.add_bandwidth_influence(-active_bandwidth_cost)
	else
		flock.remove_bandwidth_influence(-active_bandwidth_cost)
		flock.add_bandwidth_influence(bandwidth_provided)

	return new_state

/// Called when an object finishes construction
/obj/structure/flock/proc/finish_building()
	SHOULD_CALL_PARENT(TRUE)
	STOP_PROCESSING(SSobj, src)
	fully_built = TRUE

/obj/structure/flock/examine(mob/user)
	if(!isflockmob(user))
		return ..()

	. = list(
		span_flocksay("<b>###=- Ident confirmed, data packet received.</b>"),
		span_flocksay("<b>ID:</b> [get_flock_id()]"),
		span_flocksay("<b>Flock:</b> [flock?.name || "N/A"]"),
		span_flocksay("<b>System Integrity:</b> [get_integrity_percentage()]%"),
	)

	if(!fully_built)
		. += span_flocksay("<b>Time Left:</b> [build_time_left()] seconds")

	var/list/additional_lines = flock_structure_examine(user)
	if(length(additional_lines))
		. += additional_lines

	. += span_flocksay("<b>###=-</b>")

/obj/structure/flock/proc/flock_structure_examine(mob/user)
	return

/// Stub for children to set their info in process() and initialize()
/obj/structure/flock/proc/update_info_tag()
	return

/obj/structure/flock/proc/on_crossed(atom/source, atom/movable/crosser)
	SIGNAL_HANDLER

	if(!allow_flockpass || !isflockdrone(crosser))
		return

	if(!HAS_TRAIT(crosser, TRAIT_FLOCKPHASE))
		animate_flockpass(crosser)

/obj/structure/flock/proc/bitch_and_moan()
	if(!COOLDOWN_FINISHED(src, scream_cd))
		return

	COOLDOWN_START(src, scream_cd, 10 SECONDS)
	flock_talk(src, "WARNING: Under attack", flock)

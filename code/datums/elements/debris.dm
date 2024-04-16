/*
 * In this file you can find the particle component for bullet hits
 * Originally from https://github.com/tgstation/TerraGov-Marine-Corps/pull/12752
 */

/particles/debris
	icon = 'icons/effects/particles/generic_particles.dmi'
	width = 500
	height = 500
	count = 10
	spawning = 10
	lifespan = 0.7 SECONDS
	fade = 0.4 SECONDS
	drift = generator("circle", 0, 7)
	scale = 0.7
	velocity = list(50, 0)
	friction = generator("num", 0.1, 0.15)
	spin = generator("num", -20, 20)

/particles/impact_smoke
	icon = 'icons/effects/effects.dmi'
	icon_state = "smoke"
	width = 500
	height = 500
	count = 20
	spawning = 20
	lifespan = 0.7 SECONDS
	fade = 8 SECONDS
	grow = 0.1
	scale = 0.2
	spin = generator("num", -20, 20)
	velocity = list(50, 0)
	friction = generator("num", 0.1, 0.5)

/datum/component/debris
	/// Icon state of debris when impacted by a projectile
	var/debris
	/// Velocity of debris particles
	var/debris_velocity = -15
	/// Amount of debris particles
	var/debris_amount = 8
	/// Scale of particle debris
	var/debris_scale = 0.7

/datum/component/debris/Initialize(_debris_icon_state, _debris_velocity = -15, _debris_amount = 8, _debris_scale = 0.7)
	. = ..()
	debris = _debris_icon_state
	debris_velocity = _debris_velocity
	debris_amount = _debris_amount
	debris_scale = _debris_scale
	RegisterSignal(parent, COMSIG_ATOM_BULLET_ACT, PROC_REF(register_for_impact))

/datum/component/debris/Destroy(force)
	. = ..()
	UnregisterSignal(parent, COMSIG_ATOM_BULLET_ACT)

/datum/component/debris/proc/register_for_impact(datum/source, obj/item/projectile/proj)
	SIGNAL_HANDLER // COMSIG_ATOM_BULLET_ACT
	INVOKE_ASYNC(src, PROC_REF(on_impact), proj)

/datum/component/debris/proc/on_impact(obj/item/projectile/P)
	var/angle = !isnull(P.Angle) ? P.Angle : round(get_angle(P.starting, parent), 1)
	var/x_component = sin(angle) * debris_velocity
	var/y_component = cos(angle) * debris_velocity
	var/x_component_smoke = sin(angle) * -15
	var/y_component_smoke = cos(angle) * -15

	var/obj/effect/abstract/particle_holder/debris_visuals
	var/obj/effect/abstract/particle_holder/smoke_visuals
	var/position_offset = rand(-6, 6)

	smoke_visuals = new(parent, /particles/impact_smoke)
	smoke_visuals.particles.position = list(position_offset, position_offset)
	smoke_visuals.particles.velocity = list(x_component_smoke, y_component_smoke)

	if(debris && !(P.damage_type == BURN))
		debris_visuals = new(parent, /particles/debris)
		debris_visuals.particles.position = generator("circle", position_offset, position_offset)
		debris_visuals.particles.velocity = list(x_component, y_component)
		debris_visuals.layer = ABOVE_OBJ_LAYER + 0.02
		debris_visuals.particles.icon_state = debris
		debris_visuals.particles.count = debris_amount
		debris_visuals.particles.spawning = debris_amount
		debris_visuals.particles.scale = debris_scale
	smoke_visuals.layer = ABOVE_OBJ_LAYER + 0.01

	addtimer(CALLBACK(src, PROC_REF(remove_ping), src, smoke_visuals, debris_visuals), 0.7 SECONDS)

/datum/component/debris/proc/remove_ping(hit, obj/effect/abstract/particle_holder/smoke_visuals, obj/effect/abstract/particle_holder/debris_visuals)
	QDEL_NULL(smoke_visuals)
	if(debris_visuals)
		QDEL_NULL(debris_visuals)

/obj/effect/abstract/particle_holder
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = ABOVE_ALL_MOB_LAYER
	vis_flags = VIS_INHERIT_PLANE
	///typepath of the last location we're in, if it's different when moved then we need to update vis contents
	var/last_attached_location_type
	/// The main item we're attached to at the moment, particle holders hold particles for something
	var/atom/parent
	/// The mob that is holding our item
	var/mob/holding_parent

/obj/effect/abstract/particle_holder/Initialize(mapload, particle_path = null)
	. = ..()
	if(!loc)
		stack_trace("particle holder was created with no loc!")
		return INITIALIZE_HINT_QDEL
	parent = loc

	if(ismovable(parent))
		RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(parent, COMSIG_PARENT_QDELETING, PROC_REF(on_qdel))

	particles = new particle_path
	update_visual_contents(parent)

/obj/effect/abstract/particle_holder/Destroy(force)
	if(parent)
		UnregisterSignal(parent, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING))
	QDEL_NULL(particles)
	return ..()

///signal called when parent is moved
/obj/effect/abstract/particle_holder/proc/on_move(atom/movable/attached, atom/oldloc, direction)
	SIGNAL_HANDLER
	if(parent.loc.type != last_attached_location_type)
		update_visual_contents(attached)

///signal called when parent is deleted
/obj/effect/abstract/particle_holder/proc/on_qdel(atom/movable/attached, force)
	SIGNAL_HANDLER
	qdel(src)//our parent is gone and we need to be as well

///logic proc for particle holders, aka where they move.
///subtypes of particle holders can override this for particles that should always be turf level or do special things when repositioning.
///this base subtype has some logic for items, as the loc of items becomes mobs very often hiding the particles
/obj/effect/abstract/particle_holder/proc/update_visual_contents(atom/movable/attached_to)
	// Remove old
	if(holding_parent && !(QDELETED(holding_parent)))
		holding_parent.vis_contents -= src

	// Add new
	if(isitem(attached_to) && ismob(attached_to.loc)) //special case we want to also be emitting from the mob
		var/mob/particle_mob = attached_to.loc
		last_attached_location_type = attached_to.loc
		particle_mob.vis_contents += src

	// Readd to ourselves
	attached_to.vis_contents |= src

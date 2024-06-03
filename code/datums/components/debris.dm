/*
 * In this file you can find the particle component for bullet hits
 * Originally from https://github.com/tgstation/TerraGov-Marine-Corps/pull/12752
 */

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
	if(parent)
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

	if(debris && P.damage_type == BRUTE)
		debris_visuals = new(parent, /particles/debris)
		debris_visuals.particles.position = generator(GEN_CIRCLE, position_offset, position_offset)
		debris_visuals.particles.velocity = list(x_component, y_component)
		debris_visuals.layer = ABOVE_OBJ_LAYER + 0.02
		debris_visuals.particles.icon_state = debris
		debris_visuals.particles.count = debris_amount
		debris_visuals.particles.spawning = debris_amount
		debris_visuals.particles.scale = debris_scale
	smoke_visuals.layer = ABOVE_OBJ_LAYER + 0.01

	addtimer(CALLBACK(src, PROC_REF(remove_ping), src, smoke_visuals, debris_visuals), 0.5 SECONDS)

/datum/component/debris/proc/remove_ping(hit, obj/effect/abstract/particle_holder/smoke_visuals, obj/effect/abstract/particle_holder/debris_visuals)
	QDEL_NULL(smoke_visuals)
	if(debris_visuals)
		QDEL_NULL(debris_visuals)

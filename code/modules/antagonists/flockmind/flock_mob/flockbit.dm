/mob/living/basic/flock/bit
	name = "flockbit"
	icon_state = "flockbit"
	icon_dormant = "bit-dormant"

	move_force = MOVE_FORCE_VERY_WEAK
	maxHealth = 10
	health = 10
	density = FALSE
	pass_flags = PASSTABLE

	// Flockbits don't get specific AI behaviors that would make this broken.
	point_holder_type = /datum/point_holder/infinite

/mob/living/basic/flock/bit/Initialize(mapload)
	. = ..()
	flock?.stat_bits_made++
	AddComponent(/datum/component/flock_protection)
	set_real_name(flock_realname(FLOCK_TYPE_BIT))
	name = flock_name(FLOCK_TYPE_BIT)

/mob/living/basic/flock/bit/examine(mob/user)
	if(!isflockmob(user))
		return ..()

	. = list(
		span_flocksay("<b>###=- Ident confirmed, data packet received.</b>"),
		span_flocksay("<b>ID:</b> [real_name]"),
		span_flocksay("<b>Flock:</b> [flock?.name || "N/A"]"),
		span_flocksay("<b>System Integrity: [round(health / maxHealth, 0.1) * 100]</b>"),
		span_flocksay("<b>Cognition:</b> [HAS_TRAIT(src, TRAIT_AI_PAUSED) ? "AWARE" : "PREDEFINED"]"),
		span_flocksay("<b>###=-</b>"),
	)

/mob/living/basic/flock/bit/proc/i_just_split(turf/avoid)
	ai_controller.PauseAi(0.3 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(step_away_from), avoid), 0.2 SECONDS)

/mob/living/basic/flock/bit/proc/step_away_from(turf/avoid)
	if(avoid == get_turf(src))
		step(src, pick(GLOB.alldirs))
		return

	var/list/turfs = RANGE_TURFS(1, src) - get_turf(src)
	step(src, get_dir(src, pick(turfs)))

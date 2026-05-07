/mob/living/basic/flock/bit
	name = "flockbit"
	icon_state = "flockbit"
	icon_dormant = "bit-dormant"
	desc = "The simplest partition of the flockmind, working autonomously without heed for itself as it dutifully serves the flockmind."

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
	real_name = flock_realname(FLOCK_TYPE_BIT)
	name = flock_name(FLOCK_TYPE_BIT)

/mob/living/basic/flock/bit/examine(mob/user)
	if(!isflockmob(user))
		return ..()

	. = list(
		SPAN_FLOCKSAY("<b>###=- Ident confirmed, data packet received.</b>"),
		SPAN_FLOCKSAY("<b>ID:</b> [real_name]"),
		SPAN_FLOCKSAY("<b>Flock:</b> [flock?.name || "N/A"]"),
		SPAN_FLOCKSAY("<b>System Integrity: [round(health / maxHealth, 0.1) * 100]</b>"),
		SPAN_FLOCKSAY("<b>Cognition:</b> [HAS_TRAIT(src, TRAIT_AI_PAUSED) ? "AWARE" : "PREDEFINED"]"),
		SPAN_FLOCKSAY("<b>###=-</b>"),
	)

/mob/living/basic/flock/bit/proc/i_just_split(turf/avoid)
	ai_controller.pause_ai(0.3 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(step_away_from), avoid), 0.2 SECONDS)

/mob/living/basic/flock/bit/proc/step_away_from(turf/avoid)
	if(avoid == get_turf(src))
		step(src, pick(GLOB.alldirs))
		return

	var/list/turfs = RANGE_TURFS(1, src) - get_turf(src)
	step(src, get_dir(src, pick(turfs)))

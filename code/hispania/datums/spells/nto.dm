/obj/effect/proc_holder/spell/aoe_turf/conjure/timestop/nto
	name = "Time Bubble"
	desc = "This spell stops time for everyone except for you, allowing you to move freely while your enemies and even projectiles are frozen."
	charge_max = 500
	clothes_req = 1
	invocation = "TEMPUS FUGIT"
	invocation_type = "shout"
	range = 0
	cooldown_min = 20
	summon_amt = 1
	action_icon_state = "time"
	summon_type = list(/obj/effect/timestop/nto)

/obj/effect/timestop/nto
	anchored = TRUE
	name = "timebubble"
	desc = "ZA WARUDO"
	icon = 'icons/hispania/effects/chronoshield.dmi'
	icon_state = "chron1"
	layer = FLY_LAYER
	pixel_x = -64
	pixel_y = -64
	unacidable = 1
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	mob/living/immune = list() // the one who creates the timestop is immune
	list/stopped_atoms = list()
	freezerange = 2
	duration = 300
	alpha = 125
	duration = 100

/obj/effect/timestop/nto/New()
	..()
	for(var/mob/living/M in GLOB.player_list)
		for(var/obj/effect/proc_holder/spell/aoe_turf/conjure/timestop/nto/T in M.mind.spell_list) //People who can stop time are immune to timestop
			immune |= M

/obj/effect/timestop/nto/New()
	..()
	timestop()

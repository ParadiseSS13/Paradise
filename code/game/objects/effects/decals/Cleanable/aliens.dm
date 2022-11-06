/obj/effect/decal/cleanable/blood/alien
	name = "alien blood"
	desc = "It's green and acidic. It looks like... <i>blood?</i>"
	icon = 'icons/effects/blood.dmi'
	basecolor = "#05EE05"
	bloodiness = BLOOD_AMOUNT_PER_DECAL
	blood_state = BLOOD_STATE_ALIEN

/obj/effect/decal/cleanable/blood/alien/splatter
	random_icon_states = list("mgibbl1", "mgibbl2", "mgibbl3", "mgibbl4", "mgibbl5")
	amount = 2

/obj/effect/decal/cleanable/blood/gibs/alien
	name = "alien gibs"
	desc = "Gnarly..."
	icon_state = "xgib1"
	random_icon_states = list("xgib1", "xgib2", "xgib3", "xgib4", "xgib5", "xgib6")
	basecolor = "#05EE05"

/obj/effect/decal/cleanable/blood/gibs/alien/update_icon()
	color = "#FFFFFF"
	. = ..(NONE)

/obj/effect/decal/cleanable/blood/gibs/alien/up
	random_icon_states = list("xgib1", "xgib2", "xgib3", "xgib4", "xgib5", "xgib6", "xgibup1", "xgibup1", "xgibup1")

/obj/effect/decal/cleanable/blood/gibs/alien/down
	random_icon_states = list("xgib1", "xgib2", "xgib3", "xgib4", "xgib5", "xgib6", "xgibdown1", "xgibdown1", "xgibdown1")

/obj/effect/decal/cleanable/blood/gibs/alien/body
	random_icon_states = list("xgibhead", "xgibtorso")

/obj/effect/decal/cleanable/blood/gibs/alien/limb
	random_icon_states = list("xgibleg", "xgibarm")

/obj/effect/decal/cleanable/blood/gibs/alien/core
	random_icon_states = list("xgibmid1", "xgibmid2", "xgibmid3")

/obj/effect/decal/cleanable/blood/xtracks
	basecolor = "#05EE05"

/obj/effect/decal/cleanable/blood/slime // this is the alien blood file, slimes are aliens.
	name = "slime jelly"
	desc = "It's a transparent semi-liquid from a slime or slime person. Don't lick it."
	basecolor = "#0b8f70"
	bloodiness = MAX_SHOE_BLOODINESS
	alpha = BLOOD_SPLATTER_ALPHA_SLIME

/obj/effect/decal/cleanable/blood/slime/can_bloodcrawl_in()
	return FALSE

/obj/effect/decal/cleanable/blood/slime/dry()
	return

/obj/effect/decal/cleanable/blood/slime/streak
	random_icon_states = list("mgibbl1", "mgibbl2", "mgibbl3", "mgibbl4", "mgibbl5")
	amount = 2

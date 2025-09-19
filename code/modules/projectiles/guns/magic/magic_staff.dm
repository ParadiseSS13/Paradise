/obj/item/gun/magic/staff
	inhand_icon_state = null
	slot_flags = ITEM_SLOT_BACK
	ammo_type = /obj/item/ammo_casing/magic
	flags_2 = NO_MAT_REDEMPTION_2
	execution_speed = 3 SECONDS

/obj/item/gun/magic/staff/change
	name = "staff of change"
	desc = "An artefact that spits bolts of coruscating energy which cause the target's very form to reshape itself."
	icon_state = "staffofchange"
	worn_icon_state = "staffofchange"
	ammo_type = /obj/item/ammo_casing/magic/change
	fire_sound = 'sound/magic/Staff_Change.ogg'

/obj/item/gun/magic/staff/animate
	name = "staff of animation"
	desc = "An artefact that spits bolts of life-force which causes objects which are hit by it to animate and come to life! This magic doesn't affect machines."
	icon_state = "staffofanimation"
	ammo_type = /obj/item/ammo_casing/magic/animate
	fire_sound = 'sound/magic/staff_animation.ogg'

/obj/item/gun/magic/staff/healing
	name = "staff of healing"
	desc = "An artefact that spits bolts of restoring magic which can remove ailments of all kinds and even raise the dead."
	icon_state = "staffofhealing"
	ammo_type = /obj/item/ammo_casing/magic/heal
	fire_sound = 'sound/magic/staff_healing.ogg'

/obj/item/gun/magic/staff/healing/handle_suicide() //Stops people trying to commit suicide to heal themselves
	return

/obj/item/gun/magic/staff/chaos
	name = "staff of chaos"
	desc = "Random bullshit go!"
	icon_state = "staffofchaos"
	ammo_type = /obj/item/ammo_casing/magic/chaos
	max_charges = 10
	recharge_rate = 2
	no_den_usage = TRUE
	fire_sound = 'sound/magic/staff_chaos.ogg'

/obj/item/gun/magic/staff/door
	name = "staff of door creation"
	desc = "An artefact that spits bolts of transformative magic that can create doors in walls."
	icon_state = "staffofdoor"
	ammo_type = /obj/item/ammo_casing/magic/door
	max_charges = 10
	recharge_rate = 2
	no_den_usage = 1
	fire_sound = 'sound/magic/staff_door.ogg'

/obj/item/gun/magic/staff/slipping
	name = "staff of slipping"
	desc = "An artefact that spits... bananas?"
	icon_state = "staffofslipping"
	worn_icon_state = "staffofslipping"
	ammo_type = /obj/item/ammo_casing/magic/slipping
	fire_sound = 'sound/items/bikehorn.ogg'

/obj/item/gun/magic/staff/slipping/honkmother
	name = "staff of the honkmother"
	desc = "An ancient artefact, sought after by clowns everywhere."
	fire_sound = 'sound/items/airhorn.ogg'

/obj/item/gun/magic/staff/focus
	name = "mental focus"
	desc = "An artefact that channels the will of the user into destructive bolts of force. If you aren't careful with it, you might poke someone's brain out."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "focus"
	ammo_type = /obj/item/ammo_casing/magic/forcebolt

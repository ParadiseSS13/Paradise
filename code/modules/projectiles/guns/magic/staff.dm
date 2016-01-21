obj/item/weapon/gun/magic/staff/
	slot_flags = SLOT_BACK

obj/item/weapon/gun/magic/staff/change
	name = "staff of change"
	desc = "An artefact that spits bolts of coruscating energy which cause the target's very form to reshape itself"
	projectile_type = "/obj/item/projectile/magic/change"
	icon_state = "staffofchange"
	item_state = "staffofchange"

obj/item/weapon/gun/magic/staff/animate
	name = "staff of animation"
	desc = "An artefact that spits bolts of life-force which causes objects which are hit by it to animate and come to life! This magic doesn't affect machines."
	projectile_type = "/obj/item/projectile/magic/animate"
	icon_state = "staffofanimation"
	item_state = "staffofanimation"

obj/item/weapon/gun/magic/staff/healing
	name = "staff of healing"
	desc = "An artefact that spits bolts of restoring magic which can remove ailments of all kinds and even raise the dead."
	projectile_type = "/obj/item/projectile/magic/resurrection"
	icon_state = "staffofhealing"
	item_state = "staffofhealing"

obj/item/weapon/gun/magic/staff/chaos
	name = "staff of chaos"
	desc = "An artefact that spits bolts of chaotic magic that can potentially do anything."
	projectile_type = "/obj/item/projectile/magic"
	icon_state = "staffofchaos"
	item_state = "staffofchaos"
	max_charges = 10
	recharge_rate = 2

	no_den_usage = 1

/obj/item/weapon/gun/magic/staff/chaos/process_chambered() //Snowflake proc, because this uses projectile_type instead of ammo_casing for whatever reason.
	projectile_type = pick(typesof(/obj/item/projectile/magic))
	if(in_chamber)	return 1
	if(!charges)	return 0
	in_chamber = new projectile_type(src)
	return 1

obj/item/weapon/gun/magic/staff/door
	name = "staff of door creation"
	desc = "An artefact that spits bolts of transformative magic that can create doors in walls."
	projectile_type = "/obj/item/projectile/magic/door"
	icon_state = "staffofdoor"
	item_state = "staffofdoor"
	max_charges = 10
	recharge_rate = 2

	no_den_usage = 1
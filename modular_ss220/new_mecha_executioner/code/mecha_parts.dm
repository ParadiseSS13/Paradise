//////////// Executioner

/obj/item/mecha_parts/chassis/executioner
	name = "\improper Executioner Chassis"

/obj/item/mecha_parts/chassis/executioner/New()
	..()
	construct = new /datum/construction/mecha/executioner_chassis(src)

/obj/item/mecha_parts/part/executioner_torso
	name="\improper Executioner Torso"
	icon = 'modular_ss220/new_mecha_executioner/icons/mech_construct.dmi'
	icon_state = "durand_harness"
	origin_tech = "programming=2;materials=3;biotech=3;engineering=3"

/obj/item/mecha_parts/part/executioner_head
	name="\improper Executioner Head"
	icon = 'modular_ss220/new_mecha_executioner/icons/mech_construct.dmi'
	icon_state = "durand_head"
	origin_tech = "programming=2;materials=3;magnets=3;engineering=3"

/obj/item/mecha_parts/part/executioner_left_arm
	name="\improper Executioner Left Arm"
	icon = 'modular_ss220/new_mecha_executioner/icons/mech_construct.dmi'
	icon_state = "durand_l_arm"
	origin_tech = "programming=2;materials=3;engineering=3"

/obj/item/mecha_parts/part/executioner_right_arm
	name="\improper Executioner Right Arm"
	icon = 'modular_ss220/new_mecha_executioner/icons/mech_construct.dmi'
	icon_state = "durand_r_arm"
	origin_tech = "programming=2;materials=3;engineering=3"

/obj/item/mecha_parts/part/executioner_left_leg
	name="\improper Executioner Left Leg"
	icon = 'modular_ss220/new_mecha_executioner/icons/mech_construct.dmi'
	icon_state = "durand_l_leg"
	origin_tech = "programming=2;materials=3;engineering=3"

/obj/item/mecha_parts/part/executioner_right_leg
	name="\improper Executioner Right Leg"
	icon = 'modular_ss220/new_mecha_executioner/icons/mech_construct.dmi'
	icon_state = "durand_r_leg"
	origin_tech = "programming=2;materials=3;engineering=3"

/obj/item/mecha_parts/part/executioner_armor
	name="\improper Executioner Armour Plates"
	icon = 'modular_ss220/new_mecha_executioner/icons/mech_construct.dmi'
	icon_state = "executioner_armor"
	origin_tech = "materials=5;combat=4;engineering=4"

/obj/item/circuitboard/mecha/executioner
	origin_tech = "programming=5;combat=4;engineering=4"

/obj/item/circuitboard/mecha/executioner/peripherals
	name = "Circuit board (Executioner Peripherals Control module)"
	icon_state = "mcontroller"

/obj/item/circuitboard/mecha/executioner/targeting
	name = "Circuit board (Executionerurand Weapon Control and Targeting module)"
	icon_state = "mcontroller"
	origin_tech = "programming=5;combat=5;engineering=4"

/obj/item/circuitboard/mecha/executioner/main
	name = "Circuit board (Executioner Central Control module)"
	icon_state = "mainboard"

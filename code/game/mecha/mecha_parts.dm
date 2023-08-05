/////////////////////////
////// Mecha Parts //////
/////////////////////////

/obj/item/mecha_parts
	name = "mecha part"
	icon = 'icons/mecha/mech_construct.dmi'
	icon_state = "blank"
	w_class = WEIGHT_CLASS_GIGANTIC
	flags = CONDUCT
	origin_tech = "programming=2;materials=2;engineering=2"

/obj/item/mecha_parts/core
	name = "mech power core"
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = "mech_core"
	desc = "A complex piece of electronics used to regulate the large amounts of power used by a combat mech's delicate components."
	w_class = WEIGHT_CLASS_SMALL

/obj/item/mecha_parts/chassis
	name = "mecha chassis"
	icon_state = "backbone"
	var/datum/construction/construct
	flags = CONDUCT

/obj/item/mecha_parts/chassis/Destroy()
	QDEL_NULL(construct)
	return ..()

/obj/item/mecha_parts/chassis/attackby(obj/item/W, mob/user, params)
	if(!construct || !construct.action(W, user))
		return ..()

/obj/item/mecha_parts/chassis/attack_hand()
	return

/////////// Ripley

/obj/item/mecha_parts/chassis/ripley
	name = "\improper Ripley chassis"

/obj/item/mecha_parts/chassis/ripley/New()
	..()
	construct = new /datum/construction/mecha/ripley_chassis(src)

/obj/item/mecha_parts/part/ripley_torso
	name = "\improper Ripley torso"
	desc = "A torso part of Ripley APLU. Contains power unit, processing core and life support systems."
	icon_state = "ripley_harness"
	origin_tech = "programming=2;materials=2;biotech=2;engineering=2"

/obj/item/mecha_parts/part/ripley_left_arm
	name = "\improper Ripley left arm"
	desc = "A Ripley APLU left arm. Data and power sockets are compatible with most exosuit tools."
	icon_state = "ripley_l_arm"

/obj/item/mecha_parts/part/ripley_right_arm
	name = "\improper Ripley right arm"
	desc = "A Ripley APLU right arm. Data and power sockets are compatible with most exosuit tools."
	icon_state = "ripley_r_arm"

/obj/item/mecha_parts/part/ripley_left_leg
	name = "\improper Ripley left leg"
	desc = "A Ripley APLU left leg. Contains somewhat complex servodrives and balance maintaining systems."
	icon_state = "ripley_l_leg"

/obj/item/mecha_parts/part/ripley_right_leg
	name = "\improper Ripley right leg"
	desc = "A Ripley APLU right leg. Contains somewhat complex servodrives and balance maintaining systems."
	icon_state = "ripley_r_leg"

///////// Gygax

/obj/item/mecha_parts/chassis/gygax
	name = "\improper Gygax chassis"

/obj/item/mecha_parts/chassis/gygax/New()
	..()
	construct = new /datum/construction/mecha/gygax_chassis(src)

/obj/item/mecha_parts/part/gygax_torso
	name = "\improper Gygax torso"
	desc = "A torso part of Gygax. Contains power unit, processing core and life support systems. Has an additional equipment slot."
	icon_state = "gygax_harness"
	origin_tech = "programming=2;materials=4;biotech=3;engineering=3"

/obj/item/mecha_parts/part/gygax_head
	name = "\improper Gygax head"
	desc = "A Gygax head. Houses advanced surveillance and targeting sensors."
	icon_state = "gygax_head"
	origin_tech = "programming=2;materials=4;magnets=3;engineering=3"

/obj/item/mecha_parts/part/gygax_left_arm
	name = "\improper Gygax left arm"
	desc = "A Gygax left arm. Data and power sockets are compatible with most exosuit tools and weapons."
	icon_state = "gygax_l_arm"
	origin_tech = "programming=2;materials=4;engineering=3"

/obj/item/mecha_parts/part/gygax_right_arm
	name = "\improper Gygax right arm"
	desc = "A Gygax right arm. Data and power sockets are compatible with most exosuit tools and weapons."
	icon_state = "gygax_r_arm"
	origin_tech = "programming=2;materials=4;engineering=3"

/obj/item/mecha_parts/part/gygax_left_leg
	name = "\improper Gygax left leg"
	icon_state = "gygax_l_leg"
	origin_tech = "programming=2;materials=4;engineering=3"

/obj/item/mecha_parts/part/gygax_right_leg
	name = "\improper Gygax right leg"
	icon_state = "gygax_r_leg"
	origin_tech = "programming=2;materials=4;engineering=3"

/obj/item/mecha_parts/part/gygax_armour
	name = "\improper Gygax armour plates"
	icon_state = "gygax_armour"
	origin_tech = "materials=6;combat=4;engineering=4"


//////////// Durand

/obj/item/mecha_parts/chassis/durand
	name = "\improper Durand chassis"

/obj/item/mecha_parts/chassis/durand/New()
	..()
	construct = new /datum/construction/mecha/durand_chassis(src)

/obj/item/mecha_parts/part/durand_torso
	name = "\improper Durand torso"
	icon_state = "durand_harness"
	origin_tech = "programming=2;materials=3;biotech=3;engineering=3"

/obj/item/mecha_parts/part/durand_head
	name = "\improper Durand head"
	icon_state = "durand_head"
	origin_tech = "programming=2;materials=3;magnets=3;engineering=3"

/obj/item/mecha_parts/part/durand_left_arm
	name = "\improper Durand left arm"
	icon_state = "durand_l_arm"
	origin_tech = "programming=2;materials=3;engineering=3"

/obj/item/mecha_parts/part/durand_right_arm
	name = "\improper Durand right arm"
	icon_state = "durand_r_arm"
	origin_tech = "programming=2;materials=3;engineering=3"

/obj/item/mecha_parts/part/durand_left_leg
	name = "\improper Durand left leg"
	icon_state = "durand_l_leg"
	origin_tech = "programming=2;materials=3;engineering=3"

/obj/item/mecha_parts/part/durand_right_leg
	name = "\improper Durand right leg"
	icon_state = "durand_r_leg"
	origin_tech = "programming=2;materials=3;engineering=3"

/obj/item/mecha_parts/part/durand_armor
	name = "\improper Durand armour plates"
	icon_state = "durand_armor"
	origin_tech = "materials=5;combat=4;engineering=4"



////////// Firefighter

/obj/item/mecha_parts/chassis/firefighter
	name = "\improper Firefighter chassis"

/obj/item/mecha_parts/chassis/firefighter/New()
	..()
	construct = new /datum/construction/mecha/firefighter_chassis(src)

////////// HONK

/obj/item/mecha_parts/chassis/honker
	name = "\improper H.O.N.K chassis"

/obj/item/mecha_parts/chassis/honker/New()
	..()
	construct = new /datum/construction/mecha/honker_chassis(src)

/obj/item/mecha_parts/part/honker_torso
	name = "\improper H.O.N.K torso"
	icon_state = "honker_harness"

/obj/item/mecha_parts/part/honker_head
	name = "\improper H.O.N.K head"
	icon_state = "honker_head"

/obj/item/mecha_parts/part/honker_left_arm
	name = "\improper H.O.N.K left arm"
	icon_state = "honker_l_arm"

/obj/item/mecha_parts/part/honker_right_arm
	name = "\improper H.O.N.K right arm"
	icon_state = "honker_r_arm"

/obj/item/mecha_parts/part/honker_left_leg
	name = "\improper H.O.N.K left leg"
	icon_state = "honker_l_leg"

/obj/item/mecha_parts/part/honker_right_leg
	name = "\improper H.O.N.K right leg"
	icon_state = "honker_r_leg"


////////// Reticence

/obj/item/mecha_parts/chassis/reticence
	name = "\improper Reticence chassis"

/obj/item/mecha_parts/chassis/reticence/New()
	..()
	construct = new /datum/construction/mecha/reticence_chassis(src)

/obj/effect/dummy/mecha_emote_step
	var/emote

/obj/effect/dummy/mecha_emote_step/New(e)
	. = ..()
	emote = e

/obj/item/mecha_parts/chassis/reticence/hear_message(mob/living/M, msg)
	if(!istype(M) || !istype(construct, /datum/construction/reversible/mecha/reticence))
		return
	// is the current step the dummy emote object?
	var/list/steps = construct.steps
	if(steps[construct.index]["key"] == /obj/effect/dummy/mecha_emote_step)
		construct.action(new /obj/effect/dummy/mecha_emote_step(msg), M)

/obj/item/mecha_parts/part/reticence_torso
	name = "\improper Reticence torso"
	icon_state = "reticence_harness"

/obj/item/mecha_parts/part/reticence_head
	name = "\improper Reticence head"
	icon_state = "reticence_head"

/obj/item/mecha_parts/part/reticence_left_arm
	name = "\improper Reticence left arm"
	icon_state = "reticence_l_arm"

/obj/item/mecha_parts/part/reticence_right_arm
	name = "\improper Reticence right arm"
	icon_state = "reticence_r_arm"

/obj/item/mecha_parts/part/reticence_left_leg
	name = "\improper Reticence left leg"
	icon_state = "reticence_l_leg"

/obj/item/mecha_parts/part/reticence_right_leg
	name = "\improper Reticence right leg"
	icon_state = "reticence_r_leg"


////////// Phazon

/obj/item/mecha_parts/chassis/phazon
	name = "\improper Phazon chassis"

/obj/item/mecha_parts/chassis/phazon/New()
	..()
	construct = new /datum/construction/mecha/phazon_chassis(src)

/obj/item/mecha_parts/chassis/phazon/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/assembly/signaler/anomaly) && !istype(I, /obj/item/assembly/signaler/anomaly/bluespace))
		to_chat(user, "<span class='warning'>The anomaly core socket only accepts bluespace anomaly cores!</span>")

/obj/item/mecha_parts/part/phazon_torso
	name = "\improper Phazon torso"
	icon_state = "phazon_harness"
	origin_tech = "programming=4;materials=4;bluespace=4;plasmatech=5"

/obj/item/mecha_parts/part/phazon_head
	name = "\improper Phazon head"
	icon_state = "phazon_head"
	origin_tech = "programming=3;materials=3;magnets=3"

/obj/item/mecha_parts/part/phazon_left_arm
	name = "\improper Phazon left arm"
	icon_state = "phazon_l_arm"
	origin_tech = "materials=3;bluespace=3;magnets=3"

/obj/item/mecha_parts/part/phazon_right_arm
	name = "\improper Phazon right arm"
	icon_state = "phazon_r_arm"
	origin_tech = "materials=3;bluespace=3;magnets=3"

/obj/item/mecha_parts/part/phazon_left_leg
	name = "\improper Phazon left leg"
	icon_state = "phazon_l_leg"
	origin_tech = "materials=3;bluespace=3;magnets=3"

/obj/item/mecha_parts/part/phazon_right_leg
	name = "\improper Phazon right leg"
	icon_state = "phazon_r_leg"
	origin_tech = "materials=3;bluespace=3;magnets=3"

/obj/item/mecha_parts/part/phazon_armor
	name = "\improper Phazon armor"
	desc = "Phazon armor plates. They are layered with plasma to protect the pilot from the stress of phasing and have unusual properties."
	icon_state = "phazon_armor"
	origin_tech = "materials=4;bluespace=4;plasmatech=5"

///////// Odysseus
/obj/item/mecha_parts/chassis/odysseus
	name = "\improper Odysseus Chassis"

/obj/item/mecha_parts/chassis/odysseus/New()
	..()
	construct = new /datum/construction/mecha/odysseus_chassis(src)

/obj/item/mecha_parts/part/odysseus_head
	name = "\improper Odysseus head"
	icon_state = "odysseus_head"

/obj/item/mecha_parts/part/odysseus_torso
	name = "\improper Odysseus torso"
	desc = "A torso part of Odysseus. Contains power unit, processing core and life support systems."
	icon_state = "odysseus_torso"
	origin_tech = "programming=2;materials=2;biotech=2;engineering=2"

/obj/item/mecha_parts/part/odysseus_left_arm
	name = "\improper Odysseus left arm"
	desc = "An Odysseus left arm. Data and power sockets are compatible with most exosuit tools."
	icon_state = "odysseus_l_arm"

/obj/item/mecha_parts/part/odysseus_right_arm
	name = "\improper Odysseus right arm"
	desc = "An Odysseus right arm. Data and power sockets are compatible with most exosuit tools."
	icon_state = "odysseus_r_arm"

/obj/item/mecha_parts/part/odysseus_left_leg
	name = "\improper Odysseus left leg"
	desc = "An Odysseus left leg. Contains somewhat complex servodrives and balance maintaining systems."
	icon_state = "odysseus_l_leg"

/obj/item/mecha_parts/part/odysseus_right_leg
	name = "\improper Odysseus right leg"
	desc = "A Odysseus right leg. Contains somewhat complex servodrives and balance maintaining systems."
	icon_state = "odysseus_r_leg"

/*/obj/item/mecha_parts/part/odysseus_armour
	name = "\improper Odysseus carapace"
	icon_state = "odysseus_armour"
	origin_tech = "materials=3;engineering=3")*/


///////// Circuitboards

/obj/item/circuitboard/mecha
	icon_state = "std_mod"
	board_type = "other"
	flags = CONDUCT
	force = 5
	throwforce = 5
	throw_speed = 3
	throw_range = 15


/obj/item/circuitboard/mecha/ripley
	origin_tech = "programming=2"

/obj/item/circuitboard/mecha/ripley/main
	board_name = "Ripley Central Control Module"
	icon_state = "mainboard"

/obj/item/circuitboard/mecha/ripley/peripherals
	board_name = "Ripley Peripherals Control Module"
	icon_state = "mcontroller"


/obj/item/circuitboard/mecha/gygax
	origin_tech = "programming=4;combat=3;engineering=3"

/obj/item/circuitboard/mecha/gygax/main
	board_name = "Gygax Central Control Module"
	icon_state = "mainboard"

/obj/item/circuitboard/mecha/gygax/peripherals
	board_name = "Gygax Peripherals Control Module"
	icon_state = "mcontroller"

/obj/item/circuitboard/mecha/gygax/targeting
	board_name = "Gygax Weapon Control and Targeting Module"
	icon_state = "mcontroller"
	origin_tech = "programming=4;combat=4"


/obj/item/circuitboard/mecha/durand
	origin_tech = "programming=4;combat=3;engineering=3"

/obj/item/circuitboard/mecha/durand/main
	board_name = "Durand Central Control Module"
	icon_state = "mainboard"

/obj/item/circuitboard/mecha/durand/peripherals
	board_name = "Durand Peripherals Control Module"
	icon_state = "mcontroller"

/obj/item/circuitboard/mecha/durand/targeting
	board_name = "Durand Weapon Control and Targeting Module"
	icon_state = "mcontroller"
	origin_tech = "programming=4;combat=4;engineering=3"


/obj/item/circuitboard/mecha/phazon
	origin_tech = "programming=5;plasmatech=4"

/obj/item/circuitboard/mecha/phazon/main
	board_name = "Phazon Central Control Module"
	icon_state = "mainboard"

/obj/item/circuitboard/mecha/phazon/peripherals
	board_name = "Phazon Peripherals Control Module"
	icon_state = "mcontroller"

/obj/item/circuitboard/mecha/phazon/targeting
	board_name = "Phazon Weapon Control and Targeting Module"
	icon_state = "mcontroller"


/obj/item/circuitboard/mecha/honker
	origin_tech = "programming=3;engineering=3"

/obj/item/circuitboard/mecha/honker/main
	board_name = "H.O.N.K Central Control Module"
	icon_state = "mainboard"

/obj/item/circuitboard/mecha/honker/peripherals
	board_name = "H.O.N.K Peripherals Control Module"
	icon_state = "mcontroller"

/obj/item/circuitboard/mecha/honker/targeting
	board_name = "H.O.N.K Weapon Control and Targeting Module"
	icon_state = "mcontroller"


/obj/item/circuitboard/mecha/reticence
	origin_tech = "programming=3;engineering=3"

/obj/item/circuitboard/mecha/reticence/main
	board_name = "Reticence Central Control Module"
	icon_state = "mainboard"

/obj/item/circuitboard/mecha/reticence/peripherals
	board_name = "Reticence Peripherals Control Module"
	icon_state = "mcontroller"

/obj/item/circuitboard/mecha/reticence/targeting
	board_name = "Reticence Weapon Control and Targeting Module"
	icon_state = "mcontroller"


/obj/item/circuitboard/mecha/odysseus
	origin_tech = "programming=3;biotech=3"

/obj/item/circuitboard/mecha/odysseus/main
	board_name = "Odysseus Central Control Module"
	icon_state = "mainboard"

/obj/item/circuitboard/mecha/odysseus/peripherals
	board_name = "Odysseus Peripherals Control Module"
	icon_state = "mcontroller"

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


/obj/item/mecha_parts/chassis
	name="Mecha Chassis"
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
	name = "Ripley Chassis"

/obj/item/mecha_parts/chassis/ripley/New()
	..()
	construct = new /datum/construction/mecha/ripley_chassis(src)

/obj/item/mecha_parts/part/ripley_torso
	name="Ripley Torso"
	desc="A torso part of Ripley APLU. Contains power unit, processing core and life support systems."
	icon_state = "ripley_harness"
	origin_tech = "programming=2;materials=2;biotech=2;engineering=2"

/obj/item/mecha_parts/part/ripley_left_arm
	name="Ripley Left Arm"
	desc="A Ripley APLU left arm. Data and power sockets are compatible with most exosuit tools."
	icon_state = "ripley_l_arm"

/obj/item/mecha_parts/part/ripley_right_arm
	name="Ripley Right Arm"
	desc="A Ripley APLU right arm. Data and power sockets are compatible with most exosuit tools."
	icon_state = "ripley_r_arm"

/obj/item/mecha_parts/part/ripley_left_leg
	name="Ripley Left Leg"
	desc="A Ripley APLU left leg. Contains somewhat complex servodrives and balance maintaining systems."
	icon_state = "ripley_l_leg"

/obj/item/mecha_parts/part/ripley_right_leg
	name="Ripley Right Leg"
	desc="A Ripley APLU right leg. Contains somewhat complex servodrives and balance maintaining systems."
	icon_state = "ripley_r_leg"

///////// Gygax

/obj/item/mecha_parts/chassis/gygax
	name = "Gygax Chassis"

/obj/item/mecha_parts/chassis/gygax/New()
	..()
	construct = new /datum/construction/mecha/gygax_chassis(src)

/obj/item/mecha_parts/part/gygax_torso
	name="Gygax Torso"
	desc="A torso part of Gygax. Contains power unit, processing core and life support systems. Has an additional equipment slot."
	icon_state = "gygax_harness"
	origin_tech = "programming=2;materials=4;biotech=3;engineering=3"

/obj/item/mecha_parts/part/gygax_head
	name="Gygax Head"
	desc="A Gygax head. Houses advanced surveilance and targeting sensors."
	icon_state = "gygax_head"
	origin_tech = "programming=2;materials=4;magnets=3;engineering=3"

/obj/item/mecha_parts/part/gygax_left_arm
	name="Gygax Left Arm"
	desc="A Gygax left arm. Data and power sockets are compatible with most exosuit tools and weapons."
	icon_state = "gygax_l_arm"
	origin_tech = "programming=2;materials=4;engineering=3"

/obj/item/mecha_parts/part/gygax_right_arm
	name="Gygax Right Arm"
	desc="A Gygax right arm. Data and power sockets are compatible with most exosuit tools and weapons."
	icon_state = "gygax_r_arm"
	origin_tech = "programming=2;materials=4;engineering=3"

/obj/item/mecha_parts/part/gygax_left_leg
	name="Gygax Left Leg"
	icon_state = "gygax_l_leg"
	origin_tech = "programming=2;materials=4;engineering=3"

/obj/item/mecha_parts/part/gygax_right_leg
	name="Gygax Right Leg"
	icon_state = "gygax_r_leg"
	origin_tech = "programming=2;materials=4;engineering=3"

/obj/item/mecha_parts/part/gygax_armour
	name="Gygax Armour Plates"
	icon_state = "gygax_armour"
	origin_tech = "materials=6;combat=4;engineering=4"


//////////// Durand

/obj/item/mecha_parts/chassis/durand
	name = "Durand Chassis"

/obj/item/mecha_parts/chassis/durand/New()
	..()
	construct = new /datum/construction/mecha/durand_chassis(src)

/obj/item/mecha_parts/part/durand_torso
	name="Durand Torso"
	icon_state = "durand_harness"
	origin_tech = "programming=2;materials=3;biotech=3;engineering=3"

/obj/item/mecha_parts/part/durand_head
	name="Durand Head"
	icon_state = "durand_head"
	origin_tech = "programming=2;materials=3;magnets=3;engineering=3"

/obj/item/mecha_parts/part/durand_left_arm
	name="Durand Left Arm"
	icon_state = "durand_l_arm"
	origin_tech = "programming=2;materials=3;engineering=3"

/obj/item/mecha_parts/part/durand_right_arm
	name="Durand Right Arm"
	icon_state = "durand_r_arm"
	origin_tech = "programming=2;materials=3;engineering=3"

/obj/item/mecha_parts/part/durand_left_leg
	name="Durand Left Leg"
	icon_state = "durand_l_leg"
	origin_tech = "programming=2;materials=3;engineering=3"

/obj/item/mecha_parts/part/durand_right_leg
	name="Durand Right Leg"
	icon_state = "durand_r_leg"
	origin_tech = "programming=2;materials=3;engineering=3"

/obj/item/mecha_parts/part/durand_armor
	name="Durand Armour Plates"
	icon_state = "durand_armor"
	origin_tech = "materials=5;combat=4;engineering=4"



////////// Firefighter

/obj/item/mecha_parts/chassis/firefighter
	name = "Firefighter Chassis"

/obj/item/mecha_parts/chassis/firefighter/New()
	..()
	construct = new /datum/construction/mecha/firefighter_chassis(src)

////////// HONK

/obj/item/mecha_parts/chassis/honker
	name = "H.O.N.K Chassis"

/obj/item/mecha_parts/chassis/honker/New()
	..()
	construct = new /datum/construction/mecha/honker_chassis(src)

/obj/item/mecha_parts/part/honker_torso
	name="H.O.N.K Torso"
	icon_state = "honker_harness"

/obj/item/mecha_parts/part/honker_head
	name="H.O.N.K Head"
	icon_state = "honker_head"

/obj/item/mecha_parts/part/honker_left_arm
	name="H.O.N.K Left Arm"
	icon_state = "honker_l_arm"

/obj/item/mecha_parts/part/honker_right_arm
	name="H.O.N.K Right Arm"
	icon_state = "honker_r_arm"

/obj/item/mecha_parts/part/honker_left_leg
	name="H.O.N.K Left Leg"
	icon_state = "honker_l_leg"

/obj/item/mecha_parts/part/honker_right_leg
	name="H.O.N.K Right Leg"
	icon_state = "honker_r_leg"


////////// Reticence

/obj/item/mecha_parts/chassis/reticence
	name = "Reticence Chassis"

/obj/item/mecha_parts/chassis/reticence/New()
	..()
	construct = new /datum/construction/mecha/reticence_chassis(src)

/obj/effect/dummy/mecha_emote_step
	var/emote

/obj/effect/dummy/mecha_emote_step/New(e)
	emote = e

/obj/item/mecha_parts/chassis/reticence/hear_message(mob/living/M, msg)
	if(!istype(M) || !istype(construct, /datum/construction/mecha/reticence))
		return
	// is the current step the dummy emote object?
	var/list/steps = construct.steps
	if(steps[steps.len]["key"] == /obj/effect/dummy/mecha_emote_step)
		construct.action(new /obj/effect/dummy/mecha_emote_step(msg), M)

/obj/item/mecha_parts/part/reticence_torso
	name = "Reticence Torso"
	icon_state = "reticence_harness"

/obj/item/mecha_parts/part/reticence_head
	name = "Reticence Head"
	icon_state = "reticence_head"

/obj/item/mecha_parts/part/reticence_left_arm
	name = "Reticence Left Arm"
	icon_state = "reticence_l_arm"

/obj/item/mecha_parts/part/reticence_right_arm
	name = "Reticence Right Arm"
	icon_state = "reticence_r_arm"

/obj/item/mecha_parts/part/reticence_left_leg
	name = "Reticence Left Leg"
	icon_state = "reticence_l_leg"

/obj/item/mecha_parts/part/reticence_right_leg
	name = "Reticence Right Leg"
	icon_state = "reticence_r_leg"


////////// Phazon

/obj/item/mecha_parts/chassis/phazon
	name = "Phazon Chassis"

/obj/item/mecha_parts/chassis/phazon/New()
	..()
	construct = new /datum/construction/mecha/phazon_chassis(src)

/obj/item/mecha_parts/part/phazon_torso
	name="Phazon Torso"
	icon_state = "phazon_harness"
	origin_tech = "programming=4;materials=4;bluespace=4;plasmatech=5"

/obj/item/mecha_parts/part/phazon_head
	name="Phazon Head"
	icon_state = "phazon_head"
	origin_tech = "programming=3;materials=3;magnets=3"

/obj/item/mecha_parts/part/phazon_left_arm
	name="Phazon Left Arm"
	icon_state = "phazon_l_arm"
	origin_tech = "materials=3;bluespace=3;magnets=3"

/obj/item/mecha_parts/part/phazon_right_arm
	name="Phazon Right Arm"
	icon_state = "phazon_r_arm"
	origin_tech = "materials=3;bluespace=3;magnets=3"

/obj/item/mecha_parts/part/phazon_left_leg
	name="Phazon Left Leg"
	icon_state = "phazon_l_leg"
	origin_tech = "materials=3;bluespace=3;magnets=3"

/obj/item/mecha_parts/part/phazon_right_leg
	name="Phazon Right Leg"
	icon_state = "phazon_r_leg"
	origin_tech = "materials=3;bluespace=3;magnets=3"

/obj/item/mecha_parts/part/phazon_armor
	name="Phazon armor"
	desc="Phazon armor plates. They are layered with plasma to protect the pilot from the stress of phasing and have unusual properties."
	icon_state = "phazon_armor"
	origin_tech = "materials=4;bluespace=4;plasmatech=5"

///////// Odysseus
/obj/item/mecha_parts/chassis/odysseus
	name = "Odysseus Chassis"

/obj/item/mecha_parts/chassis/odysseus/New()
	..()
	construct = new /datum/construction/mecha/odysseus_chassis(src)

/obj/item/mecha_parts/part/odysseus_head
	name="Odysseus Head"
	icon_state = "odysseus_head"

/obj/item/mecha_parts/part/odysseus_torso
	name="Odysseus Torso"
	desc="A torso part of Odysseus. Contains power unit, processing core and life support systems."
	icon_state = "odysseus_torso"
	origin_tech = "programming=2;materials=2;biotech=2;engineering=2"

/obj/item/mecha_parts/part/odysseus_left_arm
	name="Odysseus Left Arm"
	desc="An Odysseus left arm. Data and power sockets are compatible with most exosuit tools."
	icon_state = "odysseus_l_arm"

/obj/item/mecha_parts/part/odysseus_right_arm
	name="Odysseus Right Arm"
	desc="An Odysseus right arm. Data and power sockets are compatible with most exosuit tools."
	icon_state = "odysseus_r_arm"

/obj/item/mecha_parts/part/odysseus_left_leg
	name="Odysseus Left Leg"
	desc="An Odysseus left leg. Contains somewhat complex servodrives and balance maintaining systems."
	icon_state = "odysseus_l_leg"

/obj/item/mecha_parts/part/odysseus_right_leg
	name="Odysseus Right Leg"
	desc="A Odysseus right leg. Contains somewhat complex servodrives and balance maintaining systems."
	icon_state = "odysseus_r_leg"

/*/obj/item/mecha_parts/part/odysseus_armour
	name="Odysseus Carapace"
	icon_state = "odysseus_armour"
	origin_tech = "materials=3;engineering=3")*/


///////// Circuitboards

/obj/item/circuitboard/mecha
	name = "Exosuit Circuit board"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	item_state = "electronic"
	board_type = "other"
	flags = CONDUCT
	force = 5.0
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 5.0
	throw_speed = 3
	throw_range = 15

/obj/item/circuitboard/mecha/ripley
	origin_tech = "programming=2"

/obj/item/circuitboard/mecha/ripley/peripherals
	name = "Circuit board (Ripley Peripherals Control module)"
	icon_state = "mcontroller"

/obj/item/circuitboard/mecha/ripley/main
	name = "Circuit board (Ripley Central Control module)"
	icon_state = "mainboard"

/obj/item/circuitboard/mecha/gygax
	origin_tech = "programming=4;combat=3;engineering=3"

/obj/item/circuitboard/mecha/gygax/peripherals
	name = "Circuit board (Gygax Peripherals Control module)"
	icon_state = "mcontroller"

/obj/item/circuitboard/mecha/gygax/targeting
	name = "Circuit board (Gygax Weapon Control and Targeting module)"
	icon_state = "mcontroller"
	origin_tech = "programming=4;combat=4"

/obj/item/circuitboard/mecha/gygax/main
	name = "Circuit board (Gygax Central Control module)"
	icon_state = "mainboard"

/obj/item/circuitboard/mecha/durand
	origin_tech = "programming=4;combat=3;engineering=3"

/obj/item/circuitboard/mecha/durand/peripherals
	name = "Circuit board (Durand Peripherals Control module)"
	icon_state = "mcontroller"

/obj/item/circuitboard/mecha/durand/targeting
	name = "Circuit board (Durand Weapon Control and Targeting module)"
	icon_state = "mcontroller"
	origin_tech = "programming=4;combat=4;engineering=3"

/obj/item/circuitboard/mecha/durand/main
	name = "Circuit board (Durand Central Control module)"
	icon_state = "mainboard"

/obj/item/circuitboard/mecha/phazon
	origin_tech = "programming=5;plasmatech=4"

/obj/item/circuitboard/mecha/phazon/peripherals
	name = "Circuit board (Phazon Peripherals Control module)"
	icon_state = "mcontroller"

/obj/item/circuitboard/mecha/phazon/targeting
	name = "Circuit board (Phazon Weapon Control and Targeting module)"
	icon_state = "mcontroller"

/obj/item/circuitboard/mecha/phazon/main
	name = "Circuit board (Phazon Central Control module)"
	icon_state = "mainboard"

/obj/item/circuitboard/mecha/honker
	origin_tech = "programming=3;engineering=3"

/obj/item/circuitboard/mecha/honker/peripherals
	name = "Circuit board (H.O.N.K Peripherals Control module)"
	icon_state = "mcontroller"

/obj/item/circuitboard/mecha/honker/targeting
	name = "Circuit board (H.O.N.K Weapon Control and Targeting module)"
	icon_state = "mcontroller"

/obj/item/circuitboard/mecha/honker/main
	name = "Circuit board (H.O.N.K Central Control module)"
	icon_state = "mainboard"

/obj/item/circuitboard/mecha/reticence
	origin_tech = "programming=3;engineering=3"

/obj/item/circuitboard/mecha/reticence/peripherals
	name = "circuit board (Reticence Peripherals Control module)"
	icon_state = "mcontroller"

/obj/item/circuitboard/mecha/reticence/targeting
	name = "circuit board (Reticence Weapon Control and Targeting module)"
	icon_state = "mcontroller"

/obj/item/circuitboard/mecha/reticence/main
	name = "circuit board (Reticence Central Control module)"
	icon_state = "mainboard"

/obj/item/circuitboard/mecha/odysseus
	origin_tech = "programming=3;biotech=3"

/obj/item/circuitboard/mecha/odysseus/peripherals
	name = "Circuit board (Odysseus Peripherals Control module)"
	icon_state = "mcontroller"

/obj/item/circuitboard/mecha/odysseus/main
	name = "Circuit board (Odysseus Central Control module)"
	icon_state = "mainboard"

/obj/item/circuitboard/mecha/pod
	name = "Circuit board (Space Pod Mainboard)"
	icon_state = "mainboard"

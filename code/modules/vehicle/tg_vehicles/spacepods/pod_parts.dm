/obj/item/spacepod_part
	name = "space pod part"
	desc = ABSTRACT_TYPE_DESC
	icon = 'icons/obj/spacepods/pod_parts.dmi'
	w_class = WEIGHT_CLASS_GIGANTIC
	flags = CONDUCT
	new_attack_chain = TRUE

/obj/item/spacepod_part/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_ATTACK_HAND, PROC_REF(prevent_pickup))

// Trying to pick up these parts, which are 96x96 sprites, is goofy and
// unrealistic. Just prevent it happening at all.
/obj/item/spacepod_part/proc/prevent_pickup(datum/source)
	SIGNAL_HANDLER // COMSIG_ATOM_ATTACK_HAND
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/item/spacepod_part/wing
	name = "space pod wing"
	desc = "A wing for a space pod hull. Drag onto a frame to attach."
	icon_state = "wing"

/obj/item/spacepod_part/nacelle
	name = "space pod nacelle"
	desc = "An engine nacelle for a space pod hull. Drag onto a frame to attach."
	icon_state = "nacelle"

/obj/item/spacepod_part/frame
	name = "space pod frame"
	desc = "The core frame of a space pod hull. Drag onto a frame to attach."
	icon = 'icons/obj/spacepods/pod_preconstruct.dmi'
	icon_state = "frame"
	pixel_x = -32
	pixel_y = -32
	var/datum/construction/construct

/obj/item/spacepod_part/frame/Initialize(mapload)
	. = ..()
	construct = new /datum/construction/space_pod/basic(src)

/obj/item/spacepod_part/frame/MouseDrop_T(obj/item/used, mob/user)
	if(construct && construct.action(used, user))
		return TRUE

	return ..()

/obj/item/spacepod_part/engine
	name = "space pod engine"
	desc = "A jet engine for a space pod hull. Drag onto a frame to attach."
	icon_state = "engine"

/obj/item/spacepod_part/cockpit
	name = "space pod cockpit"
	desc = "A cockpit for a space pod hull. Drag onto a frame to attach."
	icon_state = "cockpit"

/obj/item/spacepod_plate
	name = "standard armor plate"
	desc = "A standard space pod armor plate. Doesn't guarantee much protection."
	icon = 'icons/obj/spacepods/plate.dmi'
	icon_state = "plate"
	new_attack_chain = TRUE

/obj/item/spacepod_plate/sci
	name = "expeditor armor plate"
	desc = "Has average defense. Just right for space exploration."
	icon = 'icons/obj/spacepods/plate.dmi'
	icon_state = "plate_sci"

/obj/item/spacepod_plate/sec
	name = "security armor plate"
	desc = "Well-fortified protection for your Pod. Sold only under license!"
	icon = 'icons/obj/spacepods/plate.dmi'
	icon_state = "plate_sec"

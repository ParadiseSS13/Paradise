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

/obj/item/spacepod_part/examine(mob/user)
	. = ..()
	. += SPAN_NOTICE("You can <b>Click-drag</b> this onto a space pod frame to install it.")

// Trying to pick up these parts, which are 96x96 sprites, is goofy and
// unrealistic. Just prevent it happening at all.
/obj/item/spacepod_part/proc/prevent_pickup(datum/source)
	SIGNAL_HANDLER // COMSIG_ATOM_ATTACK_HAND
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/item/spacepod_part/wing
	name = "space pod wing"
	desc = "One wing of a space pod. Why does it need these, anyway?"
	icon_state = "wing"

/obj/item/spacepod_part/nacelle
	name = "space pod nacelle"
	desc = "The outer covering for one of a space pod's engines."
	icon_state = "nacelle"

/obj/item/spacepod_part/frame
	name = "space pod frame"
	desc = "The skeleton of what will eventually be a space pod."
	icon = 'icons/obj/spacepods/pod_preconstruct.dmi'
	icon_state = "frame"
	pixel_x = -32
	pixel_y = -32
	var/datum/construction/construct

/obj/item/spacepod_part/frame/Initialize(mapload)
	. = ..()
	construct = new /datum/construction/space_pod/basic(src)

/obj/item/spacepod_part/frame/examine(mob/user)
	. = ..()

/obj/item/spacepod_part/frame/MouseDrop_T(obj/item/used, mob/user)
	if(construct && construct.action(used, user))
		return TRUE

	return ..()

/obj/item/spacepod_part/engine
	name = "space pod engine"
	desc = "A plasma-fueled engine commonly used for small spacecraft. Most space pods have two."
	icon_state = "engine"

/obj/item/spacepod_part/cockpit
	name = "space pod cockpit"
	desc = "The frame of a space pod's cockpit."
	icon_state = "cockpit"

/obj/item/spacepod_plate
	name = "standard armor plate"
	desc = "Armor plating for a civilian space pod. It keeps out the solar winds, but not much else..."
	icon = 'icons/obj/spacepods/plate.dmi'
	icon_state = "plate"
	new_attack_chain = TRUE

/obj/item/spacepod_plate/sci
	name = "expedition armor plate"
	desc = "Moderately-armored plating for space pods used in hazardous environments."
	icon_state = "plate_sci"

/obj/item/spacepod_plate/sec
	name = "security armor plate"
	desc = "Heavily-reinforced, proprietary armor plating designed for space pods used in security work."
	icon_state = "plate_sec"

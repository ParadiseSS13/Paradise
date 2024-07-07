/obj/item/gripper/engineering/Initialize(mapload)
	. = ..()
	can_hold |= list(
		/obj/item/mounted/frame/light_fixture,
		/obj/item/mounted/frame/apc_frame,
		/obj/item/mounted/frame/alarm_frame,
		/obj/item/mounted/frame/firealarm,
		/obj/item/mounted/frame/display/newscaster_frame,
		/obj/item/mounted/frame/intercom,
		/obj/item/mounted/frame/extinguisher,
		/obj/item/mounted/frame/light_switch,
		/obj/item/flash,
	)

/obj/item/gripper/medical
	actions_types = list(/datum/action/item_action/drop_gripped_item)
	can_hold = list(
		/obj/item/organ,
		/obj/item/reagent_containers/iv_bag,
		/obj/item/robot_parts,
		/obj/item/stack/sheet/mineral/plasma, // For repair plasmemes
		/obj/item/mmi,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/patch,
		/obj/item/reagent_containers/drinks,
		/obj/item/reagent_containers/glass,
		/obj/item/reagent_containers/syringe,
	)

/obj/item/gripper/medical/attack_self(mob/user)
	return

/obj/item/gripper/service/Initialize(mapload)
	. = ..()
	can_hold |= list(
		/obj/item/card,
		/obj/item/camera_film,
		/obj/item/disk/data,
		/obj/item/disk/design_disk,
		/obj/item/disk/plantgene,
	)

/obj/structure/morgue/attack_ai(mob/user)
	add_hiddenprint(user)
	return attack_hand(user)

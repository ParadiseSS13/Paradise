/obj/item/stack/bone_rods
	name = "bone rod"
	desc = "Some bone rods. Can be used for cooking."
	singular_name = "bone rod"
	icon = 'icons/obj/stacks/minerals.dmi'
	icon_state = "bone_rods-5"
	inhand_icon_state = "bone_rods"
	force = 9.0
	throwforce = 10.0
	throw_speed = 3
	attack_verb = list("hit", "bludgeoned", "whacked")
	hitsound = 'sound/weapons/grenadelaunch.ogg'
	usesound = 'sound/items/deconstruct.ogg'
	merge_type = /obj/item/stack/bone_rods

/obj/item/stack/bone_rods/update_icon_state()
	var/amount = get_amount()
	icon_state = "bone_rods-[clamp(amount, 1, 5)]"

/obj/item/stack/bone_rods/ten
	amount = 10

/obj/item/stack/bone_rods/twentyfive
	amount = 25

/obj/item/stack/bone_rods/fifty
	amount = 50

/obj/item/stack/seaweed
	name = "seaweed sheet"
	desc = "Weed.. from the Sea!"
	singular_name = "seaweed sheet"
	icon = 'icons/obj/stacks/organic.dmi'
	icon_state = "seaweed"
	w_class = WEIGHT_CLASS_TINY
	attack_verb = list("slapped")
	hitsound = 'sound/weapons/grenadelaunch.ogg'
	usesound = 'sound/items/deconstruct.ogg'
	merge_type = /obj/item/stack/seaweed

/obj/item/stack/seaweed/attack_self__legacy__attackchain(mob/user)
	return

/obj/item/stack/seaweed/attack_self_tk()
	return


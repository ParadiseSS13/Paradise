/obj/item/clothing/glasses/prism_glasses
	name = "prism glasses"
	desc = "The lenses seem to glow slightly, and reflect light into dazzling colors."
	icon = 'icons/hispania/obj/slimecrossing.dmi'
	icon_state = "prismglasses"
	actions_types = list(/datum/action/item_action/change_prism_colour, /datum/action/item_action/place_light_prism)
	var/glasses_color = "#FFFFFF"

/obj/item/clothing/glasses/prism_glasses/item_action_slot_check(slot)
	if(slot == SLOT_EYES)
		return TRUE

/obj/structure/light_prism
	name = "light prism"
	desc = "A shining crystal of semi-solid light. Looks fragile."
	icon = 'icons/hispania/obj/slimecrossing.dmi'
	icon_state = "lightprism"
	density = FALSE
	anchored = TRUE
	max_integrity = 10

/obj/structure/light_prism/Initialize(mapload, newcolor)
	. = ..()
	color = newcolor
	light_color = newcolor
	set_light(5)

/obj/structure/light_prism/attack_hand(mob/user)
	to_chat(user, "<span class='notice'>You dispel [src]</span>")
	qdel(src)

/datum/action/item_action/change_prism_colour
	name = "Adjust Prismatic Lens"
	icon_icon = 'icons/hispania/obj/slimecrossing.dmi'
	button_icon_state = "prismcolor"

/datum/action/item_action/change_prism_colour/Trigger()
	if(!IsAvailable())
		return
	var/obj/item/clothing/glasses/prism_glasses/glasses = target
	var/new_color = input(owner, "Choose the lens color:", "Color change",glasses.glasses_color) as color|null
	if(!new_color)
		return
	glasses.glasses_color = new_color

/datum/action/item_action/place_light_prism
	name = "Fabricate Light Prism"
	icon_icon = 'icons/hispania/obj/slimecrossing.dmi'
	button_icon_state = "lightprism"

/datum/action/item_action/place_light_prism/Trigger()
	if(!IsAvailable())
		return
	var/obj/item/clothing/glasses/prism_glasses/glasses = target
	if(locate(/obj/structure/light_prism) in get_turf(owner))
		to_chat(owner, "<span class='warning'>There isn't enough ambient energy to fabricate another light prism here.</span>")
		return
	if(istype(glasses))
		if(!glasses.glasses_color)
			to_chat(owner, "<span class='warning'>The lens is oddly opaque...</span>")
			return
		to_chat(owner, "<span class='notice'>You channel nearby light into a glowing, ethereal prism.</span>")
		new /obj/structure/light_prism(get_turf(owner), glasses.glasses_color)

/obj/item/clothing/head/peaceflower
	name = "heroine bud"
	desc = "An extremely addictive flower, full of peace magic."
	icon = 'icons/hispania/obj/slimecrossing.dmi'
	icon_state = "peaceflower"
	item_state = "peaceflower"
	slot_flags = slot_head
	body_parts_covered = NONE
	force = 0
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 1
	throw_range = 3

/obj/item/clothing/head/peaceflower/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(slot == slot_head)
		ADD_TRAIT(user, TRAIT_PACIFISM, "peaceflower_[(src)]")

/obj/item/clothing/head/peaceflower/dropped(mob/living/carbon/human/user)
	..()
	REMOVE_TRAIT(user, TRAIT_PACIFISM, "peaceflower_[(src)]")

/obj/item/clothing/head/peaceflower/attack_hand(mob/user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(src == C.head)
			to_chat(user, "<span class='warning'>You feel at peace. <b style='color:pink'>Why would you want anything else?</b></span>")
			return
	return ..()

/obj/item/clothing/suit/armor/heavy/adamantine
	name = "adamantine armor"
	desc = "A full suit of adamantine plate armor. Impressively resistant to damage, but weighs about as much as you do."
	icon_state = "adamsuit"
	item_state = "adamsuit"
	flags_inv = NONE
	slowdown = 4
	var/hit_reflect_chance = 40
	hispania_icon = TRUE

/obj/item/clothing/suit/armor/heavy/adamantine/IsReflect(def_zone)
	if(def_zone in list(BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG) && prob(hit_reflect_chance))
		return TRUE
	else
		return FALSE

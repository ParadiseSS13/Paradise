/* Geiger */
#define RAD_LEVEL_NORMAL 9
#define RAD_LEVEL_MODERATE 100
#define RAD_LEVEL_HIGH 400
#define RAD_LEVEL_VERY_HIGH 800
#define RAD_LEVEL_CRITICAL 1500

/obj/item/geiger_counter
	icon = 'modular_ss220/aesthetics/goonstation/icons/geiger.dmi'
	item_state = "geiger"
	lefthand_file = 'modular_ss220/aesthetics/goonstation/icons/items_lefthand.dmi'
	righthand_file = 'modular_ss220/aesthetics/goonstation/icons/items_righthand.dmi'

/obj/item/geiger_counter/update_icon_state()
	if(!scanning)
		icon_state = "geiger_off"
	else if(emagged)
		icon_state = "geiger_on_emag"
	else
		switch(radiation_count)
			if(-INFINITY to RAD_LEVEL_NORMAL)
				icon_state = "geiger_on_0"
			if(RAD_LEVEL_NORMAL + 1 to RAD_LEVEL_MODERATE)
				icon_state = "geiger_on_1"
			if(RAD_LEVEL_MODERATE + 1 to RAD_LEVEL_HIGH)
				icon_state = "geiger_on_2"
			if(RAD_LEVEL_HIGH + 1 to RAD_LEVEL_VERY_HIGH)
				icon_state = "geiger_on_3"
			if(RAD_LEVEL_VERY_HIGH + 1 to RAD_LEVEL_CRITICAL)
				icon_state = "geiger_on_4"
			if(RAD_LEVEL_CRITICAL + 1 to INFINITY)
				icon_state = "geiger_on_5"

#undef RAD_LEVEL_NORMAL
#undef RAD_LEVEL_MODERATE
#undef RAD_LEVEL_HIGH
#undef RAD_LEVEL_VERY_HIGH
#undef RAD_LEVEL_CRITICAL

/* Igniter */
/obj/item/assembly/igniter
	icon = 'modular_ss220/aesthetics/goonstation/icons/igniter.dmi'
	item_state = "igniter"
	lefthand_file = 'modular_ss220/aesthetics/goonstation/icons/items_lefthand.dmi'
	righthand_file = 'modular_ss220/aesthetics/goonstation/icons/items_righthand.dmi'

/* Penlight */
/obj/item/flashlight/pen
	icon = 'modular_ss220/aesthetics/goonstation/icons/penlight.dmi'
	item_state = "pen"
	lefthand_file = 'modular_ss220/aesthetics/goonstation/icons/items_lefthand.dmi'
	righthand_file = 'modular_ss220/aesthetics/goonstation/icons/items_righthand.dmi'

/obj/item/flashlight/pen/update_icon_state()
	. = ..()
	if(on)
		item_state = "[initial(item_state)]-on"
	else
		item_state = "[initial(item_state)]"

/* Hand teleporter */
/obj/item/hand_tele
	icon = 'modular_ss220/aesthetics/goonstation/icons/hand_tele.dmi'
	item_state = "hand_tele"
	lefthand_file = 'modular_ss220/aesthetics/goonstation/icons/items_lefthand.dmi'
	righthand_file = 'modular_ss220/aesthetics/goonstation/icons/items_righthand.dmi'

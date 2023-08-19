/obj/structure/extinguisher_cabinet
	icon = 'modular_ss220/aesthetics/extinguisher/icons/extinguisher.dmi'

/obj/structure/extinguisher_cabinet/update_icon_state()
	if(!opened)
		if(has_extinguisher)
			icon_state = "extinguisher_closed"
		else
			icon_state = "extinguisher_empty_closed"
		return
	if(has_extinguisher)
		if(istype(has_extinguisher, /obj/item/extinguisher/mini))
			icon_state = "extinguisher_mini"
		else
			icon_state = "extinguisher_full"
	else
		icon_state = "extinguisher_empty"
	//TODO: Frame

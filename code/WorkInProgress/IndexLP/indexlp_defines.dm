//Clothing
/obj/item/clothing/suit/storage/centcomm_jacket
	name = "Central Command Jacket"
	desc = "A black jacket embroidered with the Central Command dress print."
	icon = 'code/WorkInProgress/IndexLP/indexlp_icons.dmi'
	icon_state = "mob_centcomm_jacket_open"
	item_state = "mob_centcomm_jacket"
	sprite_sheets = list(
	"Human" = 'code/WorkInProgress/IndexLP/indexlp_icons.dmi'
	)
	blood_overlay_type = "coat"
	body_parts_covered = UPPER_TORSO|ARMS

	verb/toggle()
		set name = "Toggle Coat Buttons"
		set category = "Object"
		set src in usr

		if(!usr.canmove || usr.stat || usr.restrained())
			return 0

		switch(icon_state)
			if("mob_centcomm_jacket_open")
				src.icon_state = "mob_centcomm_jacket"
				usr << "You button up the jacket."
			if("mob_centcomm_jacket")
				src.icon_state = "mob_centcomm_jacket_open"
				usr << "You unbutton the jacket."
			else
				usr << "You attempt to button-up your [src], before promptly realising how retarded you are."
				return
		usr.update_inv_wear_suit()	//so our overlays update
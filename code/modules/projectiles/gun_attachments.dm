//Put all your tacticool gun gadgets here. So far it's pretty empty


/obj/item/suppressor
	name = "suppressor"
	desc = "A universal syndicate small-arms suppressor for maximum espionage."
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "suppressor"
	item_state = "suppressor"
	w_class = WEIGHT_CLASS_SMALL
	var/oldsound = null
	var/initial_w_class = null
	origin_tech = "combat=2;engineering=2"

/obj/item/suppressor/specialoffer
	name = "cheap suppressor"
	desc = "A foreign knock-off suppressor, it feels flimsy, cheap, and brittle. Still fits all weapons."
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "suppressor"

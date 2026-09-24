//Put all your tacticool gun gadgets here. So far it's pretty empty


/obj/item/suppressor
	name = "universal suppressor"
	desc = "A universal syndicate small-arms suppressor for maximum espionage."
	icon = 'icons/tgmc/objects/attachments.dmi'
	icon_state = "suppressor"
	w_class = WEIGHT_CLASS_SMALL
	var/oldsound = null
	var/initial_w_class = null
	materials = list(MAT_METAL = 2000, MAT_SILVER = 500)
	origin_tech = "combat=5;engineering=4;syndicate=2"

/obj/item/suppressor/specialoffer
	name = "cheap suppressor"
	desc = "A foreign knock-off suppressor, it feels flimsy, cheap, and brittle. Still fits all weapons."
	materials = list(MAT_METAL = 1000, MAT_PLASTIC = 1500) // It's cheap plastic crap.
	origin_tech = "combat=2;engineering=2"

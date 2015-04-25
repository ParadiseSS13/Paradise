/obj/structure/sign/double/barsign
	icon = 'icons/obj/barsigns.dmi'
	icon_state = "empty"
	anchored = 1
	var/nopick = 0
	New()
		ChangeSign(pick("magmasea", "limbo", "rustyaxe", "armokbar", "brokendrum", "meadbay", "thecavern", "cindikate", "theorchard", "lv426", "zocalo", "4theemprah", "ishimura", "tardis", "quarks", "tenforward", "thepranicngpony", "vault13", "solaris", "thehive", "cantina", "theouterspess", "milliways42", "thetimeofeve", "spaceasshole", "dwarffortress", "thebark", "thedrunkcarp", "theharmbaton", "thenest", "officerbeersky", "thesingulo"))
		return
	proc/ChangeSign(var/Text)
		src.icon_state = "[Text]"
		//on = 0
		//brightness_on = 4 //uncomment these when the lighting fixes get in
		return

/obj/structure/sign/double/barsign/attackby(obj/item/I, mob/user)
	if(nopick)
		return

	if(istype(I, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/card = I
		if(access_bar in card.GetAccess())
			var/sign_type = input(user, "What would you like to change the barsign to?") as null|anything in list("Off", "Magma Sea", "Limbo", "Rusty Axe", "Armok Bar", "Broken Drum", "Mead bay", "The Cavern", "Cindi Kate", "The Orchard", "LV 426", "Zocalo", "4 The Emprah", "Ishimura", "Tardis", "Quarks", "Ten Forward", "The Pranicng Pony", "Vault 13", "Solaris", "The Hive", "Cantina", "The Outer Spess", "Milliways 42", "The Time Of Eve", "Space Asshole", "Dwarf Fortress", "The Bark", "The Drunk Carp", "The Harm Baton", "The Nest", "Officer Beersky", "The Singulo", "On")
			if(sign_type == null)
				return
			else
				sign_type = replacetext(lowertext(sign_type), " ", "") // lowercase, strip spaces - along with choices for user options, avoids huge if-else-else
				src.ChangeSign(sign_type)
				user << "You change the barsign."
/obj/structure/sign/double/barsign
	icon = 'icons/obj/barsigns.dmi'
	icon_state = "empty"
	anchored = 1
	New()
		ChangeSign(pick("magmasea", "limbo", "rustyaxe", "armokbar", "brokendrum", "meadbay", "thecavern", "cindikate", "theorchard", "lv426", "zocalo", "4theemprah", "ishimura", "tardis", "quarks", "tenforward", "thepranicngpony", "vault13", "solaris", "thehive", "cantina", "theouterspess", "milliways42", "thetimeofeve", "spaceasshole", "dwarffortress", "thebark", "thedrunkcarp", "theharmbaton", "thenest", "officerbeersky", "thesingulo"))
		return
	proc/ChangeSign(var/Text)
		src.icon_state = "[Text]"
		//on = 0
		//brightness_on = 4 //uncomment these when the lighting fixes get in
		return

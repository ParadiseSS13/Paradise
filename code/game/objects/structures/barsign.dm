/obj/structure/sign/barsign // All Signs are 64 by 32 pixels, they take two tiles
	name = "bar sign"
	desc = "A bar sign with no writing on it"
	icon = 'icons/obj/barsigns.dmi'
	icon_state = "empty"
	req_access = list(ACCESS_BAR)
	max_integrity = 500
	integrity_failure = 250
	armor = list("melee" = 20, "bullet" = 20, "laser" = 20, "energy" = 100, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	var/list/barsigns = list()
	var/list/hiddensigns = list()
	var/panel_open = FALSE
	var/datum/barsign/prev_sign
	var/datum/barsign/sign_holder	//I feel this could be done with one variable instead of two, but I'm not sure.

/obj/structure/sign/barsign/Initialize(mapload)
	. = ..()
	//Filling the lists
	for(var/bartype in subtypesof(/datum/barsign))
		var/datum/barsign/signinfo = new bartype
		if(!signinfo.hidden)
			barsigns += signinfo
		else
			hiddensigns += signinfo
	//Randomly assigning a sign unless there is a prev_sign
	prev_sign = pick(barsigns)
	set_sign(prev_sign)

/obj/structure/sign/barsign/proc/set_sign(datum/barsign/S)
	if(!istype(S))
		return
	if(sign_holder)	// Set this before changing sign_holder
		prev_sign = sign_holder
	sign_holder = S
	icon_state = S.icon
	name = S.name
	if(S.desc)
		desc = S.desc
	else
		desc = "It displays \"[name]\"."

/obj/structure/sign/barsign/proc/pick_sign()
	var/new_sign
	if(!broken)
		new_sign = input("Available Signage: ", "Bar Sign", null) as null|anything in (barsigns + (emagged ? hiddensigns : list()))
		if(!new_sign)
			return
		set_sign(new_sign)
	else
		set_sign(new /datum/barsign/empbarsign)

/obj/structure/sign/barsign/obj_break(damage_flag)
	if(!broken && !(flags & NODECONSTRUCT))
		broken = TRUE

/obj/structure/sign/barsign/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/metal(drop_location(), 2)
	new /obj/item/stack/cable_coil(drop_location(), 2)
	qdel(src)

/obj/structure/sign/barsign/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(loc, 'sound/effects/glasshit.ogg', 75, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/sign/barsign/attack_ai(mob/user)
	return attack_hand(user)

/obj/structure/sign/barsign/attack_hand(mob/user)
	if(panel_open)
		if(allowed(user))
			if(broken)
				to_chat(user, "<span class='warning'>The controls seem unresponsive.</span>")
				return
			else
				pick_sign()
				to_chat(user, "<span class='notice'>You set the bar sign and close the maintenance panel.</span>")
				panel_open = FALSE
				return
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")
			return
	else
		to_chat(user, "<span class='warning'>The maintenance panel is currently closed.</span>")
		return

/obj/structure/sign/barsign/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/stack/cable_coil) && panel_open)
		var/obj/item/stack/cable_coil/C = I
		if(broken && emagged) //Emagged, not broken by EMP
			to_chat(user, "<span class='warning'>Sign has been damaged beyond repair!</span>")
			return
		else if(broken && !emagged)
			if(C.use(2))
				to_chat(user, "<span class='notice'>You replace the burnt wiring.</span>")
				broken = FALSE
			else
				to_chat(user, "<span class='warning'>You need at least two lengths of cable!</span>")
		else if(!broken && !emagged)
			to_chat(user, "<span class='warning'>This sign is functioning properly!</span>")
			return
	else
		return ..()

/obj/structure/sign/barsign/screwdriver_act(mob/user, /obj/item/I)
	. = TRUE
	if(!panel_open)
		to_chat(user, "<span class='notice'>You open the maintenance panel.</span>")
		set_sign(new /datum/barsign/signoff)
		panel_open = TRUE
	else
		if(prev_sign.icon != icon_state)
			set_sign(prev_sign)
		to_chat(user, "<span class='notice'>You close the maintenance panel.</span>")
		panel_open = FALSE
	return

/obj/structure/sign/barsign/wrench_act(mob/user)
	. = TRUE
	if(!panel_open)
		to_chat(user, "<span_class='notice'>You must first open the maintenance panel before trying to unbolt the bar sign.</span>")
		return
	else
		var/obj/item/sign/barsign/S = new(user.loc)
		S.name = name
		S.desc = desc
		S.icon_state = icon_state	//The only sprite direction that exists is South.
		S.broken = broken
		S.emagged = emagged
		S.req_access = req_access
		S.panel_open = !panel_open
		S.prev_sign = prev_sign
		qdel(src)

/obj/item/sign/barsign
	name = "bar sign"
	desc = ""
	icon = 'icons/obj/barsigns.dmi'
	w_class = WEIGHT_CLASS_HUGE		// Don't put this in your backpack!
	resistance_flags = FLAMMABLE
	var/panel_open
	var/broken
	var/datum/barsign/prev_sign

/obj/item/sign/barsign/wrench_act(mob/user)	//construction
	if(QDELETED(src))
		return
	var/direction = input("In which direction?", "Select direction.") as null|anything in list("North", "East", "South", "West")
	if(!direction)
		return
	if(isturf(user.loc))
		var/obj/structure/sign/barsign/S = new(user.loc)
		switch(direction)
			if("North")
				S.pixel_y = 32
			if("East")
				S.pixel_x = 32
			if("South")
				S.pixel_y = -32
			if("West")
				S.pixel_x = -32
		S.name = name
		S.desc = desc
		S.broken = broken
		S.emagged = emagged
		S.req_access = req_access
		S.panel_open = panel_open
		S.prev_sign = prev_sign
		S.icon_state = prev_sign.icon
		S.sign_holder = null
		to_chat(user, "<span_class='notice>You bolt bar sign with your wrench, closing the maintenance panel in the process.</span>")
		qdel(src)
	else
		return

/obj/structure/sign/barsign/emp_act(severity)
	broken = TRUE

/obj/structure/sign/barsign/emag_act(mob/user)
	if(broken || emagged)
		to_chat(user, "<span class='warning'>Nothing interesting happens!</span>")
		return
	to_chat(user, "<span class='notice'>You emag bar sign. Takeover in progress ... </span>")
	addtimer(CALLBACK(src, .proc/post_emag), 100)

/obj/structure/sign/barsign/proc/post_emag()
	if(broken || emagged)
		return
	set_sign(new /datum/barsign/syndibarsign)
	emagged = TRUE
	req_access += list(ACCESS_SYNDICATE)

//Code below is to define useless variables for datums. It errors without these
/datum/barsign
	var/name = "Name"
	var/icon = "Icon"
	var/desc = "desc"
	var/hidden = FALSE


//Anything below this is where all the specific signs are. If people want to add more signs, add them below.
/datum/barsign/maltesefalcon
	name = "Maltese Falcon"
	icon = "maltesefalcon"
	desc = "The Maltese Falcon, Space Bar and Grill."

/datum/barsign/thebark
	name = "The Bark"
	icon = "thebark"
	desc = "Ian's bar of choice."

/datum/barsign/harmbaton
	name = "The Harmbaton"
	icon = "theharmbaton"
	desc = "A great dining experience for both security members and assistants."

/datum/barsign/thesingulo
	name = "The Singulo"
	icon = "thesingulo"
	desc = "Where people go that'd rather not be called by their name."

/datum/barsign/thedrunkcarp
	name = "The Drunk Carp"
	icon = "thedrunkcarp"
	desc = "Don't drink and swim."

/datum/barsign/scotchservinwill
	name = "Scotch Servin Willy's"
	icon = "scotchservinwill"
	desc = "Willy sure moved up in the world from clown to bartender."

/datum/barsign/officerbeersky
	name = "Officer Beersky's"
	icon = "officerbeersky"
	desc = "Man eat a dong, these drinks are great."

/datum/barsign/thecavern
	name = "The Cavern"
	icon = "thecavern"
	desc = "Fine drinks while listening to some fine tunes."

/datum/barsign/theouterspess
	name = "The Outer Spess"
	icon = "theouterspess"
	desc = "This bar isn't actually located in outer space."

/datum/barsign/slipperyshots
	name = "Slippery Shots"
	icon = "slipperyshots"
	desc = "Slippery slope to drunkeness with our shots!"

/datum/barsign/thegreytide
	name = "The Grey Tide"
	icon = "thegreytide"
	desc = "Abandon your toolboxing ways and enjoy a lazy beer!"

/datum/barsign/honkednloaded
	name = "Honked 'n' Loaded"
	icon = "honkednloaded"
	desc = "Honk."

/datum/barsign/thenest
	name = "The Nest"
	icon = "thenest"
	desc = "A good place to retire for a drink after a long night of crime fighting."

/datum/barsign/thecoderbus
	name = "The Coderbus"
	icon = "thecoderbus"
	desc = "A very controversial bar known for its wide variety of constantly-changing drinks."

/datum/barsign/theadminbus
	name = "The Adminbus"
	icon = "theadminbus"
	desc = "An establishment visited mainly by space-judges. It isn't bombed nearly as much as court hearings."

/datum/barsign/oldcockinn
	name = "The Old Cock Inn"
	icon = "oldcockinn"
	desc = "Something about this sign fills you with despair."

/datum/barsign/thewretchedhive
	name = "The Wretched Hive"
	icon = "thewretchedhive"
	desc = "Legally obligated to instruct you to check your drinks for acid before consumption."

/datum/barsign/robustacafe
	name = "The Robusta Cafe"
	icon = "robustacafe"
	desc = "Holder of the 'Most Lethal Barfights' record 5 years uncontested."

/datum/barsign/emergencyrumparty
	name = "The Emergency Rum Party"
	icon = "emergencyrumparty"
	desc = "Still serving drinks that were banned years ago."

/datum/barsign/combocafe
	name = "The Combo Cafe"
	icon = "combocafe"
	desc = "Renowned system-wide for their utterly uncreative drink combinations."

/datum/barsign/vladssaladbar
	name = "Vlad's Salad Bar"
	icon = "vladssaladbar"
	desc = "Under new management. Vlad was always a bit too trigger happy with that shotgun."

/datum/barsign/theshaken
	name = "The Shaken"
	icon = "theshaken"
	desc = "This establishment does not serve stirred drinks."

/datum/barsign/thealenath
	name = "The Ale' Nath"
	icon = "thealenath"
	desc = "All right, buddy. I think you've had EI NATH. Time to get a cab."

/datum/barsign/thealohasnackbar
	name = "The Aloha Snackbar"
	icon = "alohasnackbar"
	desc = "A tasteful, inoffensive tiki bar sign."

/datum/barsign/thenet
	name = "The Net"
	icon = "thenet"
	desc = "The sea of drinkformation." //you couldn't come up with something better?

/datum/barsign/armok
	name = "Armok's Bar and Grill"
	icon = "armokbar"
	desc = "Dorfs need not apply."

/datum/barsign/meadbay
	name = "Mead Bay"
	icon = "meadbay"
	desc = "Still probably a better place to get treated than the real one."

/datum/barsign/whiskeyimplant
	name = "Whiskey Implant"
	icon = "whiskeyimplant"
	desc = "A bar known for its unconventional means of serving you drinks,whether you want them or not."

/datum/barsign/redshirt
	name = "The Red Shirt"
	icon = "theredshirt"
	desc = "A number of famous patrons have attended this bar, including:..."

/datum/barsign/lv426
	name = "LV-426"
	icon = "lv426"
	desc = "Drinking with fancy facemasks is clearly more important than going to medbay."

/datum/barsign/zocalo
	name = "Zocalo"
	icon = "zocalo"
	desc = "Anteriormente ubicado en Spessmerica."

/datum/barsign/fourtheemprah
	name = "4 The Emprah"
	icon = "4theemprah"
	desc = "Enjoyed by fanatics, heretics, and brain-damaged patrons alike."

/datum/barsign/ishimura
	name = "Ishimura"
	icon = "ishimura"
	desc = "Well known for their quality brownstar and delicious crackers."

/datum/barsign/tardis
	name = "Tardis"
	icon = "tardis"
	desc = "This establishment has been through at least 5,343 iterations."

/datum/barsign/quarks
	name = "Quark's"
	icon = "quarks"
	desc = "Frequenters of this establishment are often seen wearing meson scanners; how quaint."

/datum/barsign/tenforward
	name = "Ten Forward"
	icon = "tenforward"
	desc = "Totally not a rip-off of an established bar or anything like that."

/datum/barsign/thepranicngpony
	name = "The Prancing Pony"
	icon = "thepranicngpony"
	desc = "Ok, we don't take to kindly to you short folk pokin' round looking for some ranger scum."

/datum/barsign/vault13
	name = "Vault 13"
	icon = "vault13"
	desc = "Coincidence is intentional."

/datum/barsign/solaris
	name = "Solaris"
	icon = "solaris"
	desc = "When is a plasma giant not a plasma giant? When it's a bar serving plasma from a plasma giant."

/datum/barsign/thehive
	name = "The Hive"
	icon = "thehive"
	desc = "Dedicated to and founded in memory of those who died aboard the NT Class 4407 Research Stations."

/datum/barsign/cantina
	name = "Chalmun's Cantina"
	icon = "cantina"
	desc = "The bar was founded on the principles of originality; they have the same music playing 24/7."

/datum/barsign/milliways42
	name = "Milliways 42"
	icon = "milliways42"
	desc = "It's not really the end; it's the beginning, meaning, and answer for all your beverage needs."

/datum/barsign/timeofeve
	name = "The Time of Eve"
	icon = "thetimeofeve"
	desc = "Vintage drinks from 2453!."

/datum/barsign/spaceasshole
	name = "Space Asshole"
	icon = "spaceasshole"
	desc = "Open since 2125, Not much has changed since then; the engineers still release the singulo and the damn miners still are more likely to cave your face in that deliver ores."


//Hidden signs list below this point
/datum/barsign/empbarsign
	name = "Haywire Barsign"
	icon = "empbarsign"
	desc = "Something has gone very wrong."
	hidden = TRUE

/datum/barsign/syndibarsign
	name = "Syndi Cat Takeover"
	icon = "syndibarsign"
	desc = "Syndicate or die."
	hidden = TRUE

/datum/barsign/signoff
	name = "bar sign"
	icon = "off"
	desc = "This sign doesn't seem to be on."
	hidden = TRUE

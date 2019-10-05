/obj/structure/sign/barsign // All Signs are 64 by 32 pixels, they take two tiles
	name = "Bar Sign"
	desc = "A bar sign with no writing on it"
	icon = 'icons/obj/barsigns.dmi'
	icon_state = "empty"
	req_access = list(access_bar)
	max_integrity = 500
	integrity_failure = 250
	armor = list("melee" = 20, "bullet" = 20, "laser" = 20, "energy" = 100, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	var/list/barsigns=list()
	var/list/hiddensigns
	var/emagged = 0
	var/state = 0
	var/prev_sign = ""
	var/panel_open = 0

/obj/structure/sign/barsign/New()
	..()


//filling the barsigns list
	for(var/bartype in subtypesof(/datum/barsign))
		var/datum/barsign/signinfo = new bartype
		if(!signinfo.hidden)
			barsigns += signinfo


//randomly assigning a sign
	set_sign(pick(barsigns))



/obj/structure/sign/barsign/proc/set_sign(var/datum/barsign/sign)
	if(!istype(sign))
		return
	icon_state = sign.icon
	name = sign.name
	if(sign.desc)
		desc = sign.desc
	else
		desc = "It displays \"[name]\"."

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
			playsound(src.loc, 'sound/effects/glasshit.ogg', 75, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/sign/barsign/attack_ai(mob/user as mob)
	return src.attack_hand(user)



/obj/structure/sign/barsign/attack_hand(mob/user as mob)
	if(!src.allowed(user))
		to_chat(user, "<span class = 'info'>Access denied.</span>")
		return
	if(broken)
		to_chat(user, "<span class ='danger'>The controls seem unresponsive.</span>")
		return
	pick_sign()




/obj/structure/sign/barsign/attackby(var/obj/item/I, var/mob/user)
	if( istype(I, /obj/item/screwdriver))
		if(!panel_open)
			to_chat(user, "<span class='notice'>You open the maintenance panel.</span>")
			set_sign(new /datum/barsign/hiddensigns/signoff)
			panel_open = 1
		else
			to_chat(user, "<span class='notice'>You close the maintenance panel.</span>")
			if(!broken && !emagged)
				set_sign(pick(barsigns))
			else if(emagged)
				set_sign(new /datum/barsign/hiddensigns/syndibarsign)
			else
				set_sign(new /datum/barsign/hiddensigns/empbarsign)
			panel_open = 0

	if(istype(I, /obj/item/stack/cable_coil) && panel_open)
		var/obj/item/stack/cable_coil/C = I
		if(emagged) //Emagged, not broken by EMP
			to_chat(user, "<span class='warning'>Sign has been damaged beyond repair!</span>")
			return
		else if(!broken)
			to_chat(user, "<span class='warning'>This sign is functioning properly!</span>")
			return

		if(C.use(2))
			to_chat(user, "<span class='notice'>You replace the burnt wiring.</span>")
			broken = 0
		else
			to_chat(user, "<span class='warning'>You need at least two lengths of cable!</span>")
	else
		return ..()



/obj/structure/sign/barsign/emp_act(severity)
    set_sign(new /datum/barsign/hiddensigns/empbarsign)
    broken = 1




/obj/structure/sign/barsign/emag_act(mob/user)
	if(broken || emagged)
		to_chat(user, "<span class='warning'>Nothing interesting happens!</span>")
		return
	to_chat(user, "<span class='notice'>You emag the barsign. Takeover in progress...</span>")
	addtimer(CALLBACK(src, .proc/post_emag), 100)

/obj/structure/sign/barsign/proc/post_emag()
	if(broken || emagged)
		return
	set_sign(new /datum/barsign/hiddensigns/syndibarsign)
	emagged = 1
	req_access = list(access_syndicate)




/obj/structure/sign/barsign/proc/pick_sign()
	var/picked_name = input("Available Signage", "Bar Sign") as null|anything in barsigns
	if(!picked_name)
		return
	set_sign(picked_name)



//Code below is to define useless variables for datums. It errors without these



/datum/barsign
	var/name = "Name"
	var/icon = "Icon"
	var/desc = "desc"
	var/hidden = 0


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

/datum/barsign/hiddensigns
	hidden = 1


//Hidden signs list below this point



/datum/barsign/hiddensigns/empbarsign
	name = "Haywire Barsign"
	icon = "empbarsign"
	desc = "Something has gone very wrong."



/datum/barsign/hiddensigns/syndibarsign
	name = "Syndi Cat Takeover"
	icon = "syndibarsign"
	desc = "Syndicate or die."



/datum/barsign/hiddensigns/signoff
	name = "Bar Sign"
	icon = "empty"
	desc = "This sign doesn't seem to be on."


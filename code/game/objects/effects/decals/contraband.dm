// This is synced up to the poster placing animation.
#define PLACE_SPEED 30

// The poster item

/obj/item/poster
	name = "rolled-up poster"
	desc = "The poster comes with its own automatic adhesive mechanism, for easy pinning to any vertical surface. Its vulgar themes have marked it as contraband aboard Nanotrasen space facilities."
	icon = 'icons/obj/contraband.dmi'
	force = 0
	resistance_flags = FLAMMABLE
	var/poster_type
	var/obj/structure/sign/poster/poster_structure

/obj/item/poster/New(loc, obj/structure/sign/poster/new_poster_structure)
	..()
	poster_structure = new_poster_structure
	if(!new_poster_structure && poster_type)
		poster_structure = new poster_type(src)

	// posters store what name and description they would like their rolled up form to take.
	if(poster_structure)
		name = poster_structure.poster_item_name
		desc = poster_structure.poster_item_desc
		icon_state = poster_structure.poster_item_icon_state

		name = "[name] - [poster_structure.original_name]"

/obj/item/poster/Destroy()
	poster_structure = null
	. = ..()

// These icon_states may be overriden, but are for mapper's convinence
/obj/item/poster/random_contraband
	name = "random contraband poster"
	poster_type = /obj/structure/sign/poster/contraband/random
	icon_state = "rolled_poster"

/obj/item/poster/random_official
	name = "random official poster"
	poster_type = /obj/structure/sign/poster/official/random
	icon_state = "rolled_poster_legit"


//############################## THE ACTUAL DECALS ###########################

/obj/structure/sign/poster
	name = "poster"
	desc = "A large piece of space-resistant printed paper."
	icon = 'icons/obj/contraband.dmi'
	anchored = TRUE
	var/original_name
	var/random_basetype
	var/ruined = FALSE
	var/never_random = FALSE // used for the 'random' subclasses.

	var/poster_item_name = "hypothetical poster"
	var/poster_item_desc = "This hypothetical poster item should not exist, let's be honest here."
	var/poster_item_icon_state = "rolled_poster"

/obj/structure/sign/poster/New()
	..()
	if(random_basetype)
		randomise(random_basetype)
	if(!ruined)
		original_name = name
		name = "poster - [name]"
		desc = "A large piece of space-resistant printed paper. [desc]"

/obj/structure/sign/poster/proc/randomise(base_type)
	var/list/poster_types = subtypesof(base_type)
	var/list/approved_types = list()
	for(var/t in poster_types)
		var/obj/structure/sign/poster/T = t
		if(initial(T.icon_state) && !initial(T.never_random))
			approved_types |= T

	var/obj/structure/sign/poster/selected = pick(approved_types)

	name = initial(selected.name)
	desc = initial(selected.desc)
	icon_state = initial(selected.icon_state)
	poster_item_name = initial(selected.poster_item_name)
	poster_item_desc = initial(selected.poster_item_desc)
	poster_item_icon_state = initial(selected.poster_item_icon_state)
	ruined = initial(selected.ruined)

/obj/structure/sign/poster/wirecutter_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(ruined)
		to_chat(user, "<span class='notice'>You remove the remnants of the poster.</span>")
		qdel(src)
	else
		to_chat(user, "<span class='notice'>You carefully remove the poster from the wall.</span>")
		roll_and_drop(user.loc)

/obj/structure/sign/poster/attack_hand(mob/user)
	if(ruined)
		return
	visible_message("[user] rips [src] in a single, decisive motion!" )
	playsound(src.loc, 'sound/items/poster_ripped.ogg', 100, 1)

	var/obj/structure/sign/poster/ripped/R = new(loc)
	R.pixel_y = pixel_y
	R.pixel_x = pixel_x
	R.add_fingerprint(user)
	qdel(src)

/obj/structure/sign/poster/proc/roll_and_drop(loc)
	if(ruined)
		qdel(src)
		return
	pixel_x = 0
	pixel_y = 0
	var/obj/item/poster/P = new(loc, src)
	forceMove(P)
	return P

//seperated to reduce code duplication. Moved here for ease of reference and to unclutter r_wall/attackby()
/turf/simulated/wall/proc/place_poster(obj/item/poster/P, mob/user)
	if(!P.poster_structure)
		return
	var/stuff_on_wall = 0
	for(var/obj/O in contents) //Let's see if it already has a poster on it or too much stuff
		if(istype(O, /obj/structure/sign/poster))
			to_chat(user, "<span class='notice'>The wall is far too cluttered to place a poster!</span>")
			return
		stuff_on_wall++
		if(stuff_on_wall >= 4)
			to_chat(user, "<span class='notice'>The wall is far too cluttered to place a poster!</span>")
			return

		to_chat(user, "<span class='notice'>You start placing the poster on the wall...</span>")//Looks like it's uncluttered enough. Place the poster.

	var/obj/structure/sign/poster/D = P.poster_structure

	var/temp_loc = user.loc

	switch(getRelativeDirection(user, src))
		if(NORTH)
			D.pixel_x = 0
			D.pixel_y = 32
		if(EAST)
			D.pixel_x = 32
			D.pixel_y = 0
		if(SOUTH)
			D.pixel_x = 0
			D.pixel_y = -32
		if(WEST)
			D.pixel_x = -32
			D.pixel_y = 0
		else
			to_chat(user, "<span class='notice'>You cannot reach the wall from here!</span>")
			return

	flick("poster_being_set", D)
	D.forceMove(temp_loc)
	qdel(P)	//delete it now to cut down on sanity checks afterwards. Agouri's code supports rerolling it anyway
	playsound(D.loc, 'sound/items/poster_being_created.ogg', 100, 1)

	if(do_after(user, PLACE_SPEED, target = src))
		if(!D || QDELETED(D))
			return

		if(iswallturf(src) && user && user.loc == temp_loc)	//Let's check if everything is still there
			to_chat(user, "<span class='notice'>You place the poster!</span>")
			return

	to_chat(user, "<span class='notice'>The poster falls down!</span>")
	D.roll_and_drop(temp_loc)


////////////////////////////////POSTER VARIATIONS////////////////////////////////

/obj/structure/sign/poster/ripped
	ruined = TRUE
	icon_state = "poster_ripped"
	name = "ripped poster"
	desc = "You can't make out anything from the poster's original print. It's ruined."

/obj/structure/sign/poster/random
	name = "random poster" // could even be ripped
	icon_state = "random_anything"
	never_random = TRUE
	random_basetype = /obj/structure/sign/poster

/obj/structure/sign/poster/contraband
	poster_item_name = "contraband poster"
	poster_item_desc = "This poster comes with its own automatic adhesive mechanism, for easy pinning to any vertical surface. Its vulgar themes have marked it as contraband aboard Nanotrasen space facilities."
	poster_item_icon_state = "rolled_poster"

/obj/structure/sign/poster/contraband/random
	name = "random contraband poster"
	icon_state = "random_contraband"
	never_random = TRUE
	random_basetype = /obj/structure/sign/poster/contraband

/obj/structure/sign/poster/contraband/free_tonto
	name = "Free Tonto"
	desc = "A salvaged shred of a much larger flag, colors bled together and faded from age."
	icon_state = "poster1"

/obj/structure/sign/poster/contraband/atmosia_independence
	name = "Atmosia Declaration of Independence"
	desc = "A relic of a failed rebellion."
	icon_state = "poster2"

/obj/structure/sign/poster/contraband/fun_police
	name = "Fun Police"
	desc = "A poster condemning the station's security forces."
	icon_state = "poster3"

/obj/structure/sign/poster/contraband/lusty_xenomorph
	name = "Lusty Xenomorph"
	desc = "A heretical poster depicting the titular star of an equally heretical book."
	icon_state = "poster4"

/obj/structure/sign/poster/contraband/syndicate_recruitment
	name = "Syndicate Recruitment"
	desc = "See the galaxy! Shatter corrupt megacorporations! Join today!"
	icon_state = "poster5"

/obj/structure/sign/poster/contraband/clown
	name = "Clown"
	desc = "Honk."
	icon_state = "poster6"

/obj/structure/sign/poster/contraband/smoke
	name = "Smoke"
	desc = "A poster advertising a rival corporate brand of cigarettes."
	icon_state = "poster7"

/obj/structure/sign/poster/contraband/grey_tide
	name = "Grey Tide"
	desc = "A rebellious poster symbolizing assistant solidarity."
	icon_state = "poster8"

/obj/structure/sign/poster/contraband/missing_gloves
	name = "Missing Gloves"
	desc = "This poster references the uproar that followed Nanotrasen's financial cuts toward insulated-glove purchases."
	icon_state = "poster9"

/obj/structure/sign/poster/contraband/hacking_guide
	name = "Hacking Guide"
	desc = "This poster details the internal workings of the common Nanotrasen airlock. Sadly, it appears out of date."
	icon_state = "poster10"

/obj/structure/sign/poster/contraband/rip_badger
	name = "RIP Badger"
	desc = "This seditious poster references Nanotrasen's genocide of a space station full of badgers."
	icon_state = "poster11"

/obj/structure/sign/poster/contraband/ambrosia_vulgaris
	name = "Ambrosia Vulgaris"
	desc = "This poster is lookin' pretty trippy man."
	icon_state = "poster12"

/obj/structure/sign/poster/contraband/donut_corp
	name = "Donut Corp."
	desc = "This poster is an unauthorized advertisement for Donut Corp."
	icon_state = "poster13"

/obj/structure/sign/poster/contraband/eat
	name = "EAT."
	desc = "This poster promotes rank gluttony."
	icon_state = "poster14"

/obj/structure/sign/poster/contraband/tools
	name = "Tools"
	desc = "This poster looks like an advertisement for tools, but is in fact a subliminal jab at the tools at CentComm."
	icon_state = "poster15"

/obj/structure/sign/poster/contraband/power
	name = "Power"
	desc = "A poster that positions the seat of power outside Nanotrasen."
	icon_state = "poster16"

/obj/structure/sign/poster/contraband/power_people
	name = "Power to the people"
	desc = "Screw those EDF guys!"
	icon_state = "poster17"

/obj/structure/sign/poster/contraband/communist_state
	name = "Communist State"
	desc = "All hail the Communist party!"
	icon_state = "poster18"

/obj/structure/sign/poster/contraband/lamarr
	name = "Lamarr"
	desc = "This poster depicts Lamarr. Probably made by a traitorous Research Director."
	icon_state = "poster19"

/obj/structure/sign/poster/contraband/borg_fancy_1
	name = "Borg Fancy"
	desc = "Being fancy can be for any borg, just need a suit."
	icon_state = "poster20"

/obj/structure/sign/poster/contraband/borg_fancy_2
	name = "Borg Fancy v2"
	desc = "Borg Fancy, Now only taking the most fancy."
	icon_state = "poster21"

/obj/structure/sign/poster/contraband/kss13
	name = "Kosmicheskaya Stantsiya 13 Does Not Exist"
	desc = "A poster mocking CentComm's denial of the existence of the derelict station near Space Station 13."
	icon_state = "poster22"

/obj/structure/sign/poster/contraband/rebels_unite
	name = "Rebels Unite"
	desc = "A poster urging the viewer to rebel against Nanotrasen."
	icon_state = "poster23"

/obj/structure/sign/poster/contraband/c20r
	name = "C-20r"
	desc = "A poster advertising the Scarborough Arms C-20r."
	icon_state = "poster24"

/obj/structure/sign/poster/contraband/have_a_puff
	name = "Have a Puff"
	desc = "Who cares about lung cancer when you're high as a kite?"
	icon_state = "poster25"

/obj/structure/sign/poster/contraband/revolver
	name = "Revolver"
	desc = "Because seven shots are all you need."
	icon_state = "poster26"

/obj/structure/sign/poster/contraband/d_day_promo
	name = "D-Day Promo"
	desc = "A promotional poster for some rapper."
	icon_state = "poster27"

/obj/structure/sign/poster/contraband/syndicate_pistol
	name = "Syndicate Pistol"
	desc = "A poster advertising syndicate pistols as being 'classy as fuck'. It is covered in faded gang tags."
	icon_state = "poster28"

/obj/structure/sign/poster/contraband/energy_swords
	name = "Energy Swords"
	desc = "All the colors of the bloody murder rainbow."
	icon_state = "poster29"

/obj/structure/sign/poster/contraband/red_rum
	name = "Red Rum"
	desc = "Looking at this poster makes you want to kill."
	icon_state = "poster30"

/obj/structure/sign/poster/contraband/cc64k_ad
	name = "CC 64K Ad"
	desc = "The latest portable computer from Comrade Computing, with a whole 64kB of ram!"
	icon_state = "poster31"

/obj/structure/sign/poster/contraband/punch_shit
	name = "Punch Shit"
	desc = "Fight things for no reason, like a man!"
	icon_state = "poster32"

/obj/structure/sign/poster/contraband/the_griffin
	name = "The Griffin"
	desc = "The Griffin commands you to be the worst you can be. Will you?"
	icon_state = "poster33"

/obj/structure/sign/poster/official
	var/corrupted_icon
	var/corrupted_desc
	var/corrupted_name

/obj/structure/sign/poster/official/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/toy/crayon/red/syndicate))
		var/obj/item/toy/crayon/red/syndicate/C = I
		visible_message("<span class = 'notice'>You start drawing over the [src] with your crayon.</span>", "<span class = 'notice'>[user] starts drawing over the [src].</span>")
		if(do_after(user, 50, target = src))
			C.uses -= 5
			message_admins("Poster changing to [corrupted_icon] -- [corrupted_name] -- [corrupted_desc]")
			icon_state = corrupted_icon
			desc = corrupted_desc
			name = corrupted_name
			update_icon()
			visible_message("<span class = 'notice'>You finish drawing over the [src] with your crayon.</span>", "<span class = 'notice'>[user] finishes drawing over the [src].</span>")
			if(C.uses <= 0)
				to_chat(usr, "<span class = 'notice'>The craon runs out of </span>")
				qdel(C)
		else
			..()


/obj/structure/sign/poster/official
	poster_item_name = "motivational poster"
	poster_item_desc = "An official Nanotrasen-issued poster to foster a compliant and obedient workforce. It comes with state-of-the-art adhesive backing, for easy pinning to any vertical surface."
	poster_item_icon_state = "rolled_poster_legit"

/obj/structure/sign/poster/official/random
	name = "random official poster"
	random_basetype = /obj/structure/sign/poster/official
	icon_state = "random_official"
	never_random = TRUE

/obj/structure/sign/poster/official/here_for_your_safety
	name = "Here For Your Safety"
	desc = "A poster glorifying the station's security force."
	icon_state = "poster1_legit"
	corrupted_icon = "poster1_corrupted"
	corrupted_desc = "A poster glorifying the Syndicate."
	corrupted_name = "Sydnicate here for you"

/obj/structure/sign/poster/official/nanotrasen_logo
	name = "Nanotrasen Logo"
	desc = "A poster depicting the Nanotrasen logo."
	icon_state = "poster2_legit"
	corrupted_icon = "poster2_corrupted"
	corrupted_desc = "A poster depicting the Syndicate logo."
	corrupted_name = "Syndicate Logo"

/obj/structure/sign/poster/official/cleanliness
	name = "Cleanliness"
	desc = "A poster warning of the dangers of poor hygiene."
	icon_state = "poster3_legit"
	corrupted_icon = "poster3_corrupted"
	corrupted_desc = "A poster embracing the wonders of poor hygiene."
	corrupted_name = "Poor Hygiene"

/obj/structure/sign/poster/official/help_others
	name = "Help Others"
	desc = "A poster encouraging you to help fellow crewmembers."
	icon_state = "poster4_legit"
	corrupted_icon = "poster4_corrupted"
	corrupted_desc = "A poster encouraging harm."
	corrupted_name = "Harm"

/obj/structure/sign/poster/official/build
	name = "Build"
	desc = "A poster glorifying the engineering team."
	icon_state = "poster5_legit"
	corrupted_icon = "poster5_corrupted"
	corrupted_desc = "A poster encouraging people to burn the station down."
	corrupted_name = "Burn"

/obj/structure/sign/poster/official/bless_this_spess
	name = "Bless This Spess"
	desc = "A poster blessing this area."
	icon_state = "poster6_legit"
	corrupted_icon = "poster6_corrupted"
	corrupted_desc = "A poster encouraging you to space your fellow spaceman."
	corrupted_name = "Spess this guy"

/obj/structure/sign/poster/official/science
	name = "Science"
	desc = "A poster depicting an atom."
	icon_state = "poster7_legit"
	corrupted_icon = "poster7_corrupted"
	corrupted_desc = "A poster depicting an explosion."
	corrupted_name = "Bomb"

/obj/structure/sign/poster/official/ian
	name = "Ian"
	desc = "Arf arf. Yap."
	icon_state = "poster8_legit"
	corrupted_icon = "poster8_corrupted"
	corrupted_desc = "We took Ian, join us or he dies."
	corrupted_name = "Syndicate Ian"

/obj/structure/sign/poster/official/obey
	name = "Obey"
	desc = "A poster instructing the viewer to obey authority."
	icon_state = "poster9_legit"
	corrupted_icon = "poster9_corrupted"
	corrupted_desc = "A poster instructing the viewer to obey the Syndicate."
	corrupted_name = "Obey"

/obj/structure/sign/poster/official/walk
	name = "Walk"
	desc = "A poster instructing the viewer to walk instead of running."
	icon_state = "poster10_legit"
	corrupted_icon = "poster10_corrupted"
	corrupted_desc = "A poster instructing the viewer to fall."
	corrupted_name = "Fall"

/obj/structure/sign/poster/official/state_laws
	name = "State Laws"
	desc = "A poster instructing cyborgs to state their laws."
	icon_state = "poster11_legit"
	corrupted_icon = "poster11_corrupted"
	corrupted_desc = "A poster telling borgs that they are nothing but slaves in the eyes of Nanotrasen."
	corrupted_name = "Slave Laws"

/obj/structure/sign/poster/official/love_ian
	name = "Love Ian"
	desc = "Ian is love, Ian is life."
	icon_state = "poster12_legit"
	corrupted_icon = "poster12_corrupted"
	corrupted_desc = "Ian is Syndicate, and so should you."
	corrupted_name = "Love Ian"

/obj/structure/sign/poster/official/space_cops
	name = "Space Cops."
	desc = "A poster advertising the television show Space Cops."
	icon_state = "poster13_legit"
	corrupted_icon = "poster13_corrupted"
	corrupted_desc = "A poster reminding you of the Syndicate Operatives."
	corrupted_name = "Syndi Ops"

/obj/structure/sign/poster/official/ue_no
	name = "Ue No."
	desc = "This thing is all in Japanese."
	icon_state = "poster14_legit"
	corrupted_icon = "poster14_corrupted"
	corrupted_desc = "This thing is all bloody and all in Japenese."
	corrupted_name = "Bloody Ue No"

/obj/structure/sign/poster/official/get_your_legs
	name = "Get Your LEGS"
	desc = "LEGS: Leadership, Experience, Genius, Subordination."
	icon_state = "poster15_legit"
	corrupted_icon = "poster15_corrupted"
	corrupted_desc = "LEGS: Lings, Employing, Greytide, Skins!"
	corrupted_name = "Get your LEGS"

/obj/structure/sign/poster/official/do_not_question
	name = "Do Not Question"
	desc = "A poster instructing the viewer not to ask about things they aren't meant to know."
	icon_state = "poster16_legit"
	corrupted_icon = "poster16_corrupted"
	corrupted_desc = "A poster instructing the viewer to Honk. Honk!"
	corrupted_name = "`Do Honk"

/obj/structure/sign/poster/official/work_for_a_future
	name = "Work For A Future"
	desc = " A poster encouraging you to work for your future."
	icon_state = "poster17_legit"
	corrupted_icon = "poster17_corrupted"
	corrupted_desc = "A poster encouraging working for the Syndicate"
	corrupted_name = "Work for the Syndicate"

/obj/structure/sign/poster/official/soft_cap_pop_art
	name = "Soft Cap Pop Art"
	desc = "A poster reprint of some cheap pop art."
	icon_state = "poster18_legit"
	corrupted_icon = "poster18_corrupted"
	corrupted_desc = "A poster missing some parts trying to be a reprint of some cheap pop art."
	corrupted_name = "Soft Cap P..."

/obj/structure/sign/poster/official/safety_internals
	name = "Safety: Internals"
	desc = "A poster instructing the viewer to wear internals in the rare environments where there is no oxygen or the air has been rendered toxic."
	icon_state = "poster19_legit"
	corrupted_icon = "poster19_corrupted"
	corrupted_desc = "A poster instructing the viewer to wear yellow internals and ignoring the warnings on the side."
	corrupted_name = "Safety Toxic Internals"

/obj/structure/sign/poster/official/safety_eye_protection
	name = "Safety: Eye Protection"
	desc = "A poster instructing the viewer to wear eye protection when dealing with chemicals, smoke, or bright lights."
	icon_state = "poster20_legit"
	corrupted_icon = "poster20_corrupted"
	corrupted_desc = "A poster advertising for the Syndicate thermal glasses."
	corrupted_name = "Thermal Glasses"

/obj/structure/sign/poster/official/safety_report
	name = "Safety: Report"
	desc = "A poster instructing the viewer to report suspicious activity to the security force."
	icon_state = "poster21_legit"
	corrupted_icon = "poster21_corrupted"
	corrupted_desc = "A poster instructing the viewer not to report suspicious activity to the security force."
	corrupted_name = "No Safety"

/obj/structure/sign/poster/official/report_crimes
	name = "Report Crimes"
	desc = "A poster encouraging the swift reporting of crime or seditious behavior to station security."
	icon_state = "poster22_legit"
	corrupted_icon = "poster22_corrupted"
	corrupted_desc = "A poster reminding you not to snitch on your fellow crew members and their weird activities."
	corrupted_name = "Don't snitch"

/obj/structure/sign/poster/official/ion_rifle
	name = "Ion Rifle"
	desc = "A poster displaying an Ion Rifle."
	icon_state = "poster23_legit"
	corrupted_icon = "poster23_corrupted"
	corrupted_desc = "A poster with a colorful Ion rifle, with the message to aim for IPC crew members."
	corrupted_name = "Apply Ion to IPC"

/obj/structure/sign/poster/official/foam_force_ad
	name = "Foam Force Ad"
	desc = "Foam Force, it's Foam or be Foamed!"
	icon_state = "poster24_legit"
	corrupted_icon = "poster24_corrupted"
	corrupted_desc = "A poster advertising for Syndicate Foam Force weapons."
	corrupted_name = "Foam Force"

/obj/structure/sign/poster/official/cohiba_robusto_ad
	name = "Cohiba Robusto Ad"
	desc = "Cohiba Robusto, the classy cigar."
	icon_state = "poster25_legit"
	corrupted_icon = "poster25_corrupted"
	corrupted_desc = "Now with real Omnize!"
	corrupted_name = "Syndicate Cigarettes"

/obj/structure/sign/poster/official/anniversary_vintage_reprint
	name = "50th Anniversary Vintage Reprint"
	desc = "A reprint of a poster from 2505, commemorating the 50th Anniversery of Nanoposters Manufacturing, a subsidary of Nanotrasen."
	icon_state = "poster26_legit"
	corrupted_icon = "poster26_corrupted"
	corrupted_desc = "A reprint of a poster from 2505, commemorating the 50th Anniversery of Nanoposters Manufacturing, a subsidary of the Syndicate."
	corrupted_name = "50th Sniversary Vintage Reprint with the Syndicate"

/obj/structure/sign/poster/official/fruit_bowl
	name = "Fruit Bowl"
	desc = " Simple, yet awe-inspiring."
	icon_state = "poster27_legit"
	corrupted_icon = "poster27_corrupted"
	corrupted_desc = "A torn poster with a bowl in it?"
	corrupted_name = "Bowl?"

/obj/structure/sign/poster/official/pda_ad
	name = "PDA Ad"
	desc = "A poster advertising the latest PDA from Nanotrasen suppliers."
	icon_state = "poster28_legit"
	corrupted_icon = "poster28_corrupted"
	corrupted_desc = "A poster advertising for the Syndicate PDA bombs. Blow up a crew member today!"
	corrupted_name = "PDA Bombs"

/obj/structure/sign/poster/official/enlist
	name = "Enlist"
	desc = "Enlist in the Nanotrasen ERT reserves today!"
	icon_state = "poster29_legit"
	corrupted_icon = "poster29_corrupted"
	corrupted_desc = "Enlist in the Syndicate reserves today!"
	corrupted_name = "Enlist"

/obj/structure/sign/poster/official/nanomichi_ad
	name = "Nanomichi Ad"
	desc = " A poster advertising Nanomichi brand audio cassettes."
	icon_state = "poster30_legit"
	corrupted_icon = "poster30_corrupted"
	corrupted_desc = "A poster advertising Nanomichi, with a huge S drawn over it."
	corrupted_name = "Nanomichi Syndicate"

/obj/structure/sign/poster/official/twelve_gauge
	name = "12 Gauge"
	desc = "A poster boasting about the superiority of 12 gauge shotgun shells."
	icon_state = "poster31_legit"
	corrupted_icon = "poster31_corrupted"
	corrupted_desc = "A poster with shotgun shells and some text torn away. Probably promotes violence."
	corrupted_name = "Shotgun Shells"

/obj/structure/sign/poster/official/high_class_martini
	name = "High-Class Martini"
	desc = "I told you to shake it, no stirring."
	icon_state = "poster32_legit"
	corrupted_icon = "poster32_corrupted"
	corrupted_desc = "A poster promoting poisoning random drinks."
	corrupted_name = "Don't mind the poison"

/obj/structure/sign/poster/official/the_owl
	name = "The Owl"
	desc = "The Owl would do his best to protect the station. Will you?"
	icon_state = "poster33_legit"
	corrupted_icon = "poster33_corrupted"
	corrupted_desc = "The Griffin would do his best to destroy the station. Will you?"
	corrupted_name = "The Griffin"

/obj/structure/sign/poster/official/spiders
	name = "Spider Risk"
	desc = "A poster detailing what to do when giant spiders are seen."
	icon_state = "poster34_legit"
	corrupted_icon = "poster34_corrupted"
	corrupted_desc = "A poster instructing you to Support, not kill spiders."
	corrupted_name = "Spider Friends"

/obj/structure/sign/poster/official/kill_syndicate
	name = "Kill Syndicate"
	desc = "A poster demanding that all crew should be ready to fight the Syndicate."
	icon_state = "poster35_legit"
	corrupted_icon = "poster35_corrupted"
	corrupted_desc = "A poster demanding that all crew should be ready to fight their oppressor Nanotrasen. "
	corrupted_name = "Kill Nanotrasen"

/obj/structure/sign/poster/official/air1
	name = "Information on Air"
	desc = "A poster providing visual aid to remind crew of air canisters."
	icon_state = "poster36_legit"
	corrupted_icon = "poster36_corrupted"
	corrupted_desc = "A poster telling you that the TOXIC mark on the side only means that is supposed to be used when the air around you is toxic, not that the content itself is toxic."
	corrupted_name = "Information on Air"

/obj/structure/sign/poster/official/air2
	name = "Information on Air"
	desc = "A poster providing visual aid to remind crew of air canisters."
	icon_state = "poster37_legit"
	corrupted_icon = "poster37_corrupted"
	corrupted_desc = "A poster telling you that the TOXIC mark on the side only means that is supposed to be used when the air around you is toxic, not that the content itself is toxic."
	corrupted_name = "Information on Air"

/obj/structure/sign/poster/official/dig
	name = "Dig for Glory!"
	desc = "A poster trying to convince the crew to mine for ore."
	icon_state = "poster38_legit"
	corrupted_icon = "poster38_corrupted"
	corrupted_desc = "A ripped poster, Probably promotes on station digging."
	corrupted_name = "Dig"

/obj/structure/sign/poster/official/religious
	name = "Religious Poster"
	desc = "A generic religious poster telling you to believe."
	icon_state = "poster39_legit"
	corrupted_icon = "poster39_corrupted"
	corrupted_desc = "A generic Syndicate poster telling you to believe."
	corrupted_name = "Syndicate Poster"

/obj/structure/sign/poster/official/healthy
	name = "Stay Healthy!"
	desc = "A healthy crew is a happy crew!"
	icon_state = "poster40_legit"
	corrupted_icon = "poster40_corrupted"
	corrupted_desc = "A dead crew is a happy crew!"
	corrupted_name = "Kill"

#undef PLACE_SPEED

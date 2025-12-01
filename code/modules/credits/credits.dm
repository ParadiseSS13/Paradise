#define CREDIT_ROLL_SPEED 100
#define CREDIT_SPAWN_SPEED 20
#define CREDIT_ANIMATE_HEIGHT (14 * world.icon_size)
#define CREDIT_EASE_DURATION 22

GLOBAL_VAR_INIT(end_credits_song, null)
GLOBAL_VAR_INIT(end_credits_title, null)
GLOBAL_LIST(end_titles)

/datum/controller/subsystem/ticker/proc/generate_credits()

	if(!GLOB.end_titles)
		GLOB.end_titles = generate_titles()

	for(var/client/C as anything in GLOB.clients)
		if(!C)
			continue
		if(!length(C.credits))
			C.roll_credits()

/client/proc/roll_credits()
	if(!mob.get_preference(PREFTOGGLE_3_POSTCREDS))
		return

	verbs += /client/proc/clear_credits
	for(var/I in GLOB.end_titles)
		if(!length(credits))
			return
		var/atom/movable/screen/credit/T = new(null, null, I, src)
		credits += T
		T.rollem()
		sleep(CREDIT_SPAWN_SPEED)
	addtimer(CALLBACK(src, PROC_REF(end_credits)), CREDIT_ROLL_SPEED - CREDIT_SPAWN_SPEED)

/client/proc/end_credits()
	clear_credits()
	verbs -= /client/proc/clear_credits

/client/proc/clear_credits()
	set name = "Stop End Titles"
	set category = "OOC"
	verbs -= /client/proc/clear_credits
	QDEL_LIST_CONTENTS(credits)

/atom/movable/screen/credit
	icon_state = "blank"
	mouse_opacity = 0
	alpha = 0
	screen_loc = "CENTER-7,CENTER-7"
	layer = ABOVE_ALL_MOB_LAYER
	var/client/parent
	var/matrix/target

/atom/movable/screen/credit/Initialize(mapload, datum/hud/hud_owner, credited, client/attached_client)
	. = ..()
	parent = attached_client
	maptext = {"<div style="font:'Small Fonts'">[credited]</div>"}
	maptext_height = world.icon_size * 2
	maptext_width = world.icon_size * 14

/atom/movable/screen/credit/proc/rollem()
	var/matrix/direction = matrix(transform)
	direction.Translate(0, CREDIT_ANIMATE_HEIGHT)
	animate(src, transform = direction, time = CREDIT_ROLL_SPEED)
	animate(src, alpha = 255, time = CREDIT_EASE_DURATION, flags = ANIMATION_PARALLEL)
	UNLINT(animate(src, alpha = 0, flags = ANIMATION_PARALLEL, time = CREDIT_EASE_DURATION, delay = CREDIT_ROLL_SPEED - CREDIT_EASE_DURATION))
	parent?.screen += src

/atom/movable/screen/credit/proc/fadeout(matrix/direction)
	QDEL_IN(src, CREDIT_EASE_DURATION)

/atom/movable/screen/credit/Destroy()
	var/client/P = parent
	if(parent)
		P.screen -= src
		P.credits -= src
	parent = null
	return ..()

/proc/generate_titles()
	var/list/titles = list()
	var/list/cast = list()
	var/list/chunk = list()
	var/list/possible_titles = list()
	var/chunksize = 0
	if(!GLOB.end_credits_title)
		/* Establish a big-ass list of potential titles for the "episode". */
		possible_titles += "THE [pick("DOWNFALL OF ", "RISE OF ", "TROUBLE WITH ", "FINAL STAND OF ", "DARK SIDE OF ", "DESOLATION OF ", "DESTRUCTION OF ", "CRISIS OF ")]\
							[pick("SPACEMEN", "HUMANITY", "DIGNITY", "SANITY", "THE CHIMPANZEES", "THE VENDOMAT PRICES", "GIANT ARMORED", "THE GAS JANITOR",\
							"THE SUPERMATTER CRYSTAL", "MEDICAL", "ENGINEERING", "SECURITY", "RESEARCH", "THE SERVICE DEPARTMENT", "COMMAND", "THE CLOWNS", "CARGO")]"

		possible_titles += "THE CREW GETS [pick("TINGLED", "PICKLED", "AN INCURABLE DISEASE", "PIZZA", "A VALUABLE HISTORY LESSON", "A BREAK", "HIGH", "TO LIVE", "TO RELIVE THEIR CHILDHOOD", "EMBROILED IN CIVIL WAR", "A BAD HANGOVER", "SERIOUS ABOUT [pick("DRUG ABUSE", "CRIME", "PRODUCTIVITY", "ANCIENT AMERICAN CARTOONS", "SPACEBALL", "DECOMPRESSION PROCEDURES")]")]"
		possible_titles += "THE CREW LEARNS ABOUT [pick("LOVE", "DRUGS", "THE DANGERS OF MONEY LAUNDERING", "XENIC SENSITIVITY", "INVESTMENT FRAUD", "KELOTANE ABUSE", "RADIATION PROTECTION", "SACRED GEOMETRY", "STRING THEORY", "ABSTRACT MATHEMATICS", "ANCIENT SKRELLIAN MEDICINE")]"
		possible_titles += "A VERY [pick("CORPORATE", "NANOTRASEN", "FLEET", "CLOWN", "SYNDICATE", "EXPEDITIONARY", "EXPLORATORY", "PLASMA", "MARTIAN", "UNITED")] [pick("CHRISTMAS", "EASTER", "HOLIDAY", "WEEKEND", "THURSDAY", "VACATION")]"
		possible_titles += "[pick("GUNS, GUNS EVERYWHERE", "THE LITTLEST PRIMALIS", "WHAT HAPPENS WHEN YOU MIX MAINTENANCE DRONES AND COMMERCIAL-GRADE PACKING FOAM", "ATTACK! ATTACK! ATTACK!", "HOLY SHIT A BOMB", "THE LEGEND OF THE ALIEN ARTIFACT: PART [pick("I","II","III","IV","V","VI","VII","VIII","IX", "X", "C","M","L")]")]"
		possible_titles += "[pick("SPACE", "TERRIFYING", "DRAGON", "WARLOCK", "LAUNDRY", "GUN", "ADVERTISING", "DOG", "CARBON MONOXIDE", "NINJA", "WIZARD", "SOCRATIC", "JUVENILE DELIQUENCY", "POLITICALLY MOTIVATED", "RADTACULAR SICKNASTY")] [pick("QUEST", "FORCE", "ADVENTURE")]"
		possible_titles += "[pick("THE DAY [pick("NANOTRASEN", "THE SYNDICATE", "ARMADYNE CORPORATION", "THE CLOWN",)] STOOD STILL", "HUNT FOR THE GREEN WEENIE", "ALIEN VS VENDOMAT", "SPACE TRACK")]"
		titles += "<center><h1>EPISODE [rand(1, 1000)]<br>[pick(possible_titles)]<h1></h1></h1></center>"
	else
		titles += "<center><h1>EPISODE [rand(1, 1000)]<br>[GLOB.end_credits_title]<h1></h1></h1></center>"

	// The Living
	for(var/mob/living/carbon/human/H in GLOB.human_list)
		if(!H.mind)
			continue
		if(!length(cast) && !chunksize)
			chunk += "CREW:"
		var/jobtitle = H.mind?.assigned_role || "No title"
		var/used_name = H.mind?.current?.name
		var/antag_string
		for(var/datum/antagonist/antagonist as anything in H.mind?.antag_datums)
			antag_string ? (antag_string += ", ") : (antag_string += "...")
			antag_string += "[antagonist?.name]"
		chunk += "[used_name] as the [H.mind?.antag_datums ? "[antag_string] and [jobtitle]" : jobtitle]"
		chunksize++

		if(chunksize > 2)
			cast += "<center>[jointext(chunk,"<br>")]</center>"
			chunk.Cut()
			chunksize = 0
	if(length(chunk))
		cast += "<center>[jointext(chunk,"<br>")]</center>"

	titles += cast

	// The Dead
	var/list/corpses = list()
	var/list/monkies = list()
	for(var/mob/living/carbon/human/H in GLOB.dead_mob_list)
		if(H.timeofdeath < 5 MINUTES) // no prespawned corpses
			continue
		if(ismonkeybasic(H))
			monkies[H?.name] += 1
		else if(H?.real_name in GLOB.crew_list) // Only crew deaths
			corpses += H?.real_name
	if(length(corpses))
		titles += "<center>BASED ON REAL EVENTS<br>In memory of [english_list(corpses)].</center>"

	// CKEYS
	var/list/staff = list("PRODUCTION STAFF:")
	var/static/list/staffjobs = list("Coffee Fetcher", "Cameraman", "Angry Yeller", "Chair Operator", "Choreographer", "Historical Consultant", "Costume Designer", "Chief Editor", "Executive Assistant")
	var/list/goodboys = list()
	for(var/client/C in GLOB.clients)
		if(!C?.holder)
			continue
		if(C?.holder?.fakekey) // No stealthmins
			continue
		if(C?.holder?.big_brother) // No big brother admins
			continue
		if(C?.holder)
			staff += "[uppertext(pick(staffjobs))] a.k.a. '[C?.key]'"

	titles += "<center>[jointext(staff,"<br>")]</center>"

	if(length(goodboys))
		titles += "<center>STAFF'S GOOD BOYS:<br>[english_list(goodboys)]</center><br>"

	var/disclaimer = "<br>Sponsored by [pick("Nanotrasen", "The Syndicate", "The Changeling Hivemind", "The Vampire Coven", "The Cultist Library", "YOU, THE PLAYER",)].<br>All rights reserved.<br>\
					This motion picture is protected under the copyright laws of the Trans-Solar Federation, <br> and other nations throughout the galaxy.<br>\
					Planet of First Publication: [pick("Earth", "Luna", "Mars", "Moghes", "Hoorlm", "Kelune", "Mauna-b", "Votum-Accorium", "Ahdomai", "New Canaan", "Boron 2", \
					"Qerballak", "Xarxis", "Altam", "Dõm", "Strend", "Tirstein", "Isueth", "Skkula-Accorium", "Blackgate Prime", "Nova Cygni")].<br>"
	disclaimer += pick("Use for parody prohibited. PROHIBITED.",
					"All stunts were performed by underpaid interns. Do NOT try at home.",
					"[pick("Nanotrasen", "The Syndicate", "The Trans-Solar Federation", "The USSP", "The Technocracy", "The Changeling Hivemind", "The Vampire Coven", "The Cultist Library", )] \
					does not endorse behaviour depicted. Attempt at your own risk.",
					"Any unauthorized exhibition, distribution, or copying of this film or any part thereof (including soundtrack)<br>\
					may result in an ERT being called to storm your home and take it back by force.",
					"The story, all names, characters, and incidents portrayed in this production are fictitious. No identification with actual<br>\
					persons (living or deceased), places, buildings, and products is intended or should be inferred.<br>\
					This film is based on a true story and all individuals depicted are based on real people, despite what we just said.",
					"No person or entity associated with this film received payment or anything of value, or entered into any agreement, in connection<br>\
					with the depiction of tobacco products, despite the copious amounts of smoking depicted within.<br>\
					(This disclaimer sponsored by [pick("Nanotrasen - Have a Nanotrasen day!", "The Syndicate - kill first, ask questions never!", "The Changeling Hivemind - we see, hear, and observe all!", \
					"The Vampire Coven - operating from the shadows!", "The Cultist Library - spreading true knowledge!", "You, and other players like you!",)](TM)).",
					"No animals were harmed in the making of this motion picture except for those listed previously as dead. Do not try this at home before signing a waiver.")
	titles += "<hr>"
	titles += "<center><span style='font-size:6pt;'>[disclaimer]</span></center>"

	return titles

#undef CREDIT_ROLL_SPEED
#undef CREDIT_SPAWN_SPEED
#undef CREDIT_ANIMATE_HEIGHT
#undef CREDIT_EASE_DURATION

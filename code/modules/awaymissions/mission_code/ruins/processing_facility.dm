/obj/item/paper/fluff/ruins/althland/journal
	name = "Journal Entry"
	info = "Today is the day, a full month since I arrived in this dump and ive come to tolerate my bunkmate. \
	He still causes me issues with his horrid snoring and disgusting eating habits on the occasion, \
	Maybe it's the state of the facility, which can be downright filthy on some days, or perhaps it's the persistent ringing in my ears. \
	Either way, ive gotten used to it, and we even shared a donk earlier out in the field, \
	not as bad as when we first met. But better to have someone watching my back then that feeling when I first arrived.<br><br>\
	\
	The heat, the smoke, even my co-workers, makes me realize how far from home I am. \
	Wish I didnt take the hazard pay, but that decision is far past due... Five more months to go before my contract is over. \
	Hopefully by the time I make it back, I'll be able to see her again. \
	Just gotta keep my nerves cool and keep working, in a few months I'll be back home and more secure than I ever was in Sol. \
	<br><br>Signed, <i>Harper Wynn.</i>"

/obj/machinery/computer/loreconsole/althland_processing
	name = "ancient communications console"
	entries = list(
		new/datum/lore_console_entry(
			"ALERT LEVEL ELEVATED: OMEGA",
			{"!!OMEGA ALERT!!<br><br>\
			\
			SECURITY LEVEL OMEGA REACHED AT ALTHLAND STATION W4.<br><br>\
			\
			AUTHORIZING OFFICERS: SITE MANAGER FIONA CATLOW.<br><br>\
			\
			REASON FOR EMERGENCY: "THE EARTH IS SPLITTING OPEN WE NEED TO GET OUT NOW SEND THE FASTEST SHUTTLE YOU HAVE!".<br><br>\
			\
			EMERGENCY EVACUATION REQUESTED<br><br>\
			\
			AWAITING RESPONSE...<br><br>"}),

		new/datum/lore_console_entry(
			"ALERT LEVEL UPDATED: ALPHA",
			{"ALL OPERATIONS TO RESUME AS NORMAL<br><br>\
			\
			AUTHORIZING OFFICERS: SITE MANAGER FIONA CATLOW.<br><br>\
			\
			POST-EMERGENCY REPORT: "Farragus? Please respond, I am Anastasia Kamaras from Site B3. B3 is gone. I think I'm the only survivor. \
			I've not been able to find anyone alive here either. Everything is damaged, but the power is still on for now. Please send help, I can't get any of the other stations on the line."<br><br>\
			\
			RESPONSE RECIEVED FROM FARRAGUS: \"It's been 3 weeks, I didn't think anyone was still alive down there! We've sent a shuttle to pick you up. \
			The area you are in is NOT SAFE. EVACUATE W4 AT ONCE. There is a clearing 350 meters away, bearing 120. Meet up with the shuttle. \
			Communication may be spotty. Grab all the flares you can find and set them off at the clearing so the pilot can see you. Farragus out.\""}),

		new/datum/lore_console_entry(
			"Site Manager Log 1:",
			{"Quarterly reports indicate that production is up by 37%. Plasma yields are especially high, but we also have notable increases in gold, titanium, and uranium. \
			Consistently with other sectors, we've also uncovered a number of strange blue gemstones. Farragus says they're called \"bluespace crystals\", apparently they're super rare. \
			They do weird shit, Harper tossed one at Qualxly, and she suddenly disappeared! Poor bastard reappeared outside. Thankfully she still had most of her gear on \
			and was right next to an airlock that was open to the outside, so she escaped pretty quickly and got away with only minor burns. We're handling those things super carefully from now on.<br><br>\
			\
			Obviously I've had to repremand Harper, but it's not as any of us knew it was going to happen. I'm just glad it didn't turn out worse.
			<i>Fiona Catlow</i>, Site Whisky 4 Manager"}),

		new/datum/lore_console_entry(
			"Site Manager Log 2:",
			{"Today we got a delivery from a mech sent from Excavation Site Bravo 3. Two huge canisters of unidentified gas they apparently found deep down in that giant sinkhole they're exploring. \
			They wanted to fly it directly to Farragus, but their landing pad got swallowed up when a smaller sinkhole opened up underneath it. \
			Apparently one of their subsurface miners fucked up when they set off a demolition charge, the base itself is reportedly fine. \
			The miner's having 2 months of hazard pay docked to cover it, ouch!<br><br>\
			\
			<i>Fiona Catlow</i>, Site Whisky 4 Manager"}),

		new/datum/lore_console_entry(
			"Site Manager Log 3:",
			{"Reports indicate a volcanic ash storm is to smutter our entire region. Our position indicates we should be taking reduced impact from the weather, but the other sectors are having issues. \
			Sector Five, and Six in the highlands are currently undergoing possible evac from the severity. Farragus says we should shelter in place and cease operations until conditions return to normal.<br><br>\
			\
			I've got most of the men reinforcing our structural plating, and we've recieved a shipment of supplies to help us sit tight and and wait for the storm to pass. \
			Ash storms have started feeling more frequent, didn't used to be this dangerous when I first got positioned to command this facility. \
			Either way, once its done, we can get back to work. I'll inform Farragus about the conditions and see if we can get some geologists down here once flights resume.<br><br>\
			\
			<i>Fiona Catlow</i>, Site Whisky 4 Manager"}))

/area/ruin/unpowered/althland_processing
	name = "Site W4 Processing Facility"
	icon_state = "mining_production"

/area/ruin/unpowered/althland_processing/dorms
	name = "Site W4 Dorms"
	icon_state = "mining_living"

/area/ruin/unpowered/althland_processing/utilities
	name = "Site W4 Utilities Building"
	icon_state = "engi"

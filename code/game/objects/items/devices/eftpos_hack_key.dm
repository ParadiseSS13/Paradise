/obj/item/eftpos_hack_key
	name = "EFTPOS Hacking Key"
	desc = "A small key for hacking EFTPOS diveses to steal clints personal information" // TODO
	icon = 'icons/obj/radio.dmi'
	icon_state = "cypherkey"
	item_state = ""
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "engineering=2;bluespace=1" // TODO
	var/list/access = list(ACCESS_SYNDICATE, ACCESS_SYNDICATE_LEADER, ACCESS_SYNDICATE_COMMAND, ACCESS_EXTERNAL_AIRLOCKS) // TODO
	var/list/stolen_data = list()


/obj/item/eftpos_hack_key/proc/read_agent_card(card, mob/living/user)
	if(istype(card, /obj/item/card/id/syndicate))
		var/obj/item/card/id/syndicate/agent_card = card
		if(isliving(user) && user?.mind?.special_role)
			to_chat(usr, "<span class='notice'>The card's microscanners activate as you pass it throw terminal, adding access.</span>")
			var/list/new_access = access - (agent_card.access & access)
			for(var/i = 3, i<3, i++)
				agent_card.access += pick(new_access)

/obj/item/eftpos_hack_key/proc/generate_print_text()

	var/victim_number = length(stolen_data)
	var/victim_text

	switch(victim_number)
		if(0)       	victim_text = "GO WORK AGENT!"
		if(1 to 3)      victim_text = "Ok, it's working, now you can start doing your job!"
		if(4 to 9)    	victim_text = "Good start, agent"
		if(10 to 20) 	victim_text = "Keep up the good work"
		if(21 to 50) 	victim_text = "Maybe...maybe you are usfull after all"
		if(50 to 100) 	victim_text = "You did not forget, you have actial job to do?"
		if(101 to 150) 	victim_text = "At this point, i just don't beleave you"
		else       		victim_text = "AGENT, STOP BRAKING MY STUF!!!"

	var/victim_rank
	var/rank_text


	if(ACCESS_CENT_COMMANDER in access)
		rank_text = "Ehh, do they even have bank accounts?"
		victim_rank = "Central Command"

	else if(ACCESS_CENT_SPECOPS in access)
		rank_text = "Where do they find the free time for you."
		victim_rank = "ERT"

	else if(ACCESS_CAPTAIN in access)
		rank_text = "A big catch, not bad."
		victim_rank = "Captain"

	else if(ACCESS_BLUESHIELD in access)
		rank_text = "Another fearless mountain of muscle."
		victim_rank = "Blueshield"

	else if(ACCESS_MAGISTRATE in access)
		rank_text = "Treyzon's watch dog"
		victim_rank = "Magistrate"

	else if(ACCESS_NTREP in access)
		rank_text = "Looks like he's here to watch over their slaves."
		victim_rank = "Nanotrasen Representative"

	else if(ACCESS_QM in access)
		rank_text = "Old good, working class."
		victim_rank = "Quartermaster"

	else if(ACCESS_CE in access)
		rank_text = "Does he even take breaks from working?"
		victim_rank = "Chief Engineer"

	else if(ACCESS_HOP in access)
		rank_text = "We both know – he was easy prey."
		victim_rank = "Head of Staff"

	else if(ACCESS_CMO in access)
		rank_text = "Sorry, doc, today we’re going to cause some serious harm."
		victim_rank = "Chief Medical Officer"

	else if(ACCESS_RD in access)
		rank_text = "Judging by the database... His doctoral is boring as hell."
		victim_rank = "Director of Research"

	else if(ACCESS_HOS in access)
		rank_text = "If only he knew what you just did to him."
		victim_rank = "Head of Security"

	else if(ACCESS_CLOWN in access)
		rank_text = "Mission has been failed successfully."
		victim_rank = "Clown"

	else if(ACCESS_MIME in access)
		rank_text = "..."
		victim_rank = "Mime"

	else if((ACCESS_BAR in access) || (ACCESS_LIBRARY in access) || (ACCESS_KITCHEN in access) || (ACCESS_HYDROPONICS in access))
		rank_text = "You were my brother, Anakin! I loved you!"
		victim_rank = "Service Staff"

	else if(ACCESS_VIROLOGY in access)
		rank_text = "Oh yes! Oh yes! I think I know what you're up to!"
		victim_rank = "Virologist"

	else if((ACCESS_ENGINE_EQUIP in access) || (ACCESS_ATMOSPHERICS in access))
		rank_text = "In our time it is so hard to find crafty guys."
		victim_rank = "Engineer"

	else if(ACCESS_MEDICAL in access)
		rank_text = "You know? I have nothing against these guys."
		victim_rank = "Medic"

	else if(ACCESS_RESEARCH in access)
		rank_text = "Not smart enough to notice the trick, haha!"
		victim_rank = "Scientist"

	else if(ACCESS_SECURITY in access)
		rank_text = "Now it’s not so safe, thanks to you."
		victim_rank = "Security Staff"

	else if(ACCESS_CARGO in access)
		rank_text = "Looks like you have a lot in common! For example, it’s time for both of you to get to work!"
		victim_rank = "Cargo Handler"

	else
		rank_text = "Not sure how this will help you"
		victim_rank = "Not sure who this is"


	var/text_to_print = {"
		<b>N@m3 Er0r r3f3r3nc3</b><br>
		<b>4cc3ss c0d3: @#_#@ </b><br>
		<b>Do n0t l0s3 or m1spl@ce this c0d3.</b><br>
		<center>Glory to syndicate! Here is your report agent</center>
		<center>Agent, you have stolen data [victim_number] times </center>
		<center>[victim_text]</center>
		<br>
		<center>Your most important target was: [victim_rank]</center>
		<center>[rank_text]</center>
		<br>
		<center>Here is your victims accounts details:</center><br>
		"}

	for(var/i = 1, length(stolen_data) >= i, i++)
		text_to_print += "[stolen_data[i]]<BR>"

	text_to_print+="Do not forget to tell you agent friends how useful my gadget is!"

	return text_to_print


/obj/item/eftpos_hack_key/proc/on_key_insert()


/obj/item/paper/eftpos_hack_key
	name = "EFTPOS Hack Key Guide"
	icon_state = "paper"
	info = {"<b>Hello, agent! You made a great purchase, I already like you!</b><br>
	<br>
	First, find a working EFTPOS terminal, then insert the hacking key into it.<br>
	<br>
	Now, whenever someone makes a transaction with their card, my device will steal their account information and provide access to up to three areas.<br>
	<br>
	<b>To copy all the accesses, just use your agent card and swipe it. Yep, those are sold separately!</b><br>
	<br>
	You can also use a screwdriver to remove the key if that wasn't obvious.<br>
	<br><hr>
"}

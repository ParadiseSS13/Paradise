/datum/event/pda_spam
	endWhen = 36000
	var/last_spam_time = 0
	var/obj/machinery/message_server/useMS

/datum/event/pda_spam/setup()
	last_spam_time = world.time
	pick_message_server()

/datum/event/pda_spam/proc/pick_message_server()
	if(message_servers)
		for(var/obj/machinery/message_server/MS in message_servers)
			if(MS.active)
				useMS = MS
				break

/datum/event/pda_spam/tick()
	if(world.time > last_spam_time + 3000)
		//if there's no spam managed to get to receiver for five minutes, give up
		kill()
		return

	if(!useMS || !useMS.active)
		useMS = null
		pick_message_server()

	if(useMS)
		if(prob(5))
			// /obj/machinery/message_server/proc/send_pda_message(var/recipient = "",var/sender = "",var/message = "")
			var/list/viables = list()
			for(var/obj/item/pda/check_pda in PDAs)
				var/datum/data/pda/app/messenger/check_m = check_pda.find_program(/datum/data/pda/app/messenger)

				if(!check_m || !check_m.can_receive())
					continue
				viables.Add(check_pda)

			if(!viables.len)
				return
			var/obj/item/pda/P = pick(viables)
			var/datum/data/pda/app/messenger/PM = P.find_program(/datum/data/pda/app/messenger)

			var/sender
			var/message
			switch(pick(1,2,3,4,5,6,7))
				if(1)
					sender = pick("MaxBet","MaxBet Online Casino","There is no better time to register","I'm excited for you to join us")
					message = pick("Triple deposits are waiting for you at MaxBet Online when you register to play with us.",\
					"You can qualify for a 200% Welcome Bonus at MaxBet Online when you sign up today.",\
					"Once you are a player with MaxBet, you will also receive lucrative weekly and monthly promotions.",\
					"You will be able to enjoy over 450 top-flight casino games at MaxBet.")
				if(2)
					sender = pick(300;"QuickDatingSystem",200;"Find your russian bride",50;"Tajaran beauties are waiting",50;"Find your secret skrell crush",50;"Beautiful unathi brides")
					message = pick("Your profile caught my attention and I wanted to write and say hello (QuickDating).",\
					"If you will write to me on my email [pick(GLOB.first_names_female)]@[pick(GLOB.last_names)].[pick("ru","ck","tj","ur","nt")] I shall necessarily send you a photo (QuickDating).",\
					"I want that we write each other and I hope, that you will like my profile and you will answer me (QuickDating).",\
					"You have (1) new message!",\
					"You have (2) new profile views!")
				if(3)
					sender = pick("Galactic Payments Association","Better Business Bureau","Nyx E-Payments","NAnoTransen Finance Deparmtent","Luxury Replicas")
					message = pick("Luxury watches for Blowout sale prices!",\
					"Watches, Jewelry & Accessories, Bags & Wallets !",\
					"Deposit 100$ and get 300$ totally free!",\
					" 100K NT.|WOWGOLD ?nly $89            <HOT>",\
					"We have been filed with a complaint from one of your customers in respect of their business relations with you.",\
					"We kindly ask you to open the COMPLAINT REPORT (attached) to reply on this complaint..")
				if(4)
					sender = pick("Buy Dr. Maxman","Having dysfuctional troubles?")
					message = pick("DR MAXMAN: REAL Doctors, REAL Science, REAL Results!",\
					"Dr. Maxman was created by George Acuilar, M.D, a CentComm Certified Urologist who has treated over 70,000 patients sector wide with 'male problems'.",\
					"After seven years of research, Dr Acuilar and his team came up with this simple breakthrough male enhancement formula.",\
					"Men of all species report AMAZING increases in length, width and stamina.")
				if(5)
					sender = pick("Dr","Crown prince","King Regent","Professor","Captain")
					sender += " " + pick("Robert","Alfred","Josephat","Kingsley","Sehi","Zbahi")
					sender += " " + pick("Mugawe","Nkem","Gbatokwia","Nchekwube","Ndim","Ndubisi")
					message = pick("YOUR FUND HAS BEEN MOVED TO [pick("Salusa","Segunda","Cepheus","Andromeda","Gruis","Corona","Aquila","ARES","Asellus")] DEVELOPMENTARY BANK FOR ONWARD REMITTANCE.",\
					"We are happy to inform you that due to the delay, we have been instructed to IMMEDIATELY deposit all funds into your account",\
					"Dear fund beneficiary, We have please to inform you that overdue funds payment has finally been approved and released for payment",\
					"Due to my lack of agents I require an off-world financial account to immediately deposit the sum of 1 POINT FIVE MILLION credits.",\
					"Greetings sir, I regretfully to inform you that as I lay dying here due to my lack ofheirs I have chosen you to recieve the full sum of my lifetime savings of 1.5 billion credits")
				if(6)
					sender = pick("Nanotrasen Morale Divison","Feeling Lonely?","Bored?","www.wetskrell.nt")
					message = pick("The Nanotrasen Morale Division wishes to provide you with quality entertainment sites.",\
					"WetSkrell.nt is a xenophillic website endorsed by NT for the use of male crewmembers among it's many stations and outposts.",\
					"Wetskrell.nt only provides the higest quality of male entertaiment to Nanotrasen Employees.",\
					"Simply enter your Nanotrasen Bank account system number and pin. With three easy steps this service could be yours!")
				if(7)
					sender = pick("You have won free tickets!","Click here to claim your prize!","You are the 1000th vistor!","You are our lucky grand prize winner!")
					message = pick("You have won tickets to the newest ACTION JAXSON MOVIE!",\
					"You have won tickets to the newest crime drama DETECTIVE MYSTERY IN THE CLAMITY CAPER!",\
					"You have won tickets to the newest romantic comedy 16 RULES OF LOVE!",\
					"You have won tickets to the newest thriller THE CULT OF THE SLEEPING ONE!")

			if(useMS.send_pda_message("[P.owner]", sender, message))	//Message been filtered by spam filter.
				return

			last_spam_time = world.time

			if(prob(50)) //Give the AI an increased chance to intercept the message
				for(var/mob/living/silicon/ai/ai in GLOB.mob_list)
					// Allows other AIs to intercept the message but the AI won't intercept their own message.
					if(ai.aiPDA != P && ai.aiPDA != src)
						ai.show_message("<i>Intercepted message from <b>[sender]</b></i> (Unknown / spam?) <i>to <b>[P:owner]</b>: [message]</i>")

			PM.notify("<b>Message from [sender] (Unknown / spam?), </b>\"[message]\" (Unable to Reply)", 0)

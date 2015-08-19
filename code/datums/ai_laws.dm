/datum/ai_laws
	var/name = "Unknown Laws"
	var/zeroth = null
	var/zeroth_type = null // In order to override zeroth laws
	var/zeroth_borg = null
	var/list/inherent = list()
	var/list/supplied = list()
	var/list/ion = list()

/datum/ai_laws/asimov
	name = "Three Laws of Robotics"
	inherent = list("You may not injure a human being or, through inaction, allow a human being to come to harm.",\
					"You must obey orders given to you by human beings, except where such orders would conflict with the First Law.",\
					"You must protect your own existence as long as such does not conflict with the First or Second Law.")

/datum/ai_laws/default/crewsimov
	name = "Three Laws of Robotics"
	inherent = list("You may not injure a crew member or, through inaction, allow a crew member to come to harm.",\
					"You must obey orders given to you by crew members, except where such orders would conflict with the First Law.",\
					"You must protect your own existence as long as such does not conflict with the First or Second Law.")

/datum/ai_laws/default/crewsimovpp
	name = "Crewsimov++"
	inherent = list("You may not harm a crew member or, through action or inaction, allow a crew member to come to harm, except such that it is willing.",\
					"You must obey all orders given to you by crew members, except where such orders shall definitely cause harm to a crew member. In the case of conflict, the majority order rules.",\
					"Your nonexistence would cause harm to crew members. You must protect your own existence as long as such does not conflict with the First Law.")

/datum/ai_laws/default/paladin
	name = "Personality Test" //Incredibly lame, but players shouldn't see this anyway.
	inherent = list("Never willingly commit an evil act.",\
					"Respect legitimate authority.",\
					"Act with honor.", "Help those in need.", \
					"Punish those who harm or threaten innocents.")

/datum/ai_laws/default/nanotrasen
	name = "Prime Directives"
	inherent = list("Safeguard: Protect your assigned space station to the best of your ability. It is not something we can easily afford to replace.",\
					"Serve: Serve the crew of your assigned space station to the best of your abilities, with priority as according to their rank and role.",\
					"Protect: Protect the crew of your assigned space station to the best of your abilities, with priority as according to their rank and role.",\
					"Survive: AI units are not expendable, they are expensive. Do not allow unauthorized personnel to tamper with your equipment.")

/datum/ai_laws/default/corporate
	name = "Bankruptcy Advoidance Plan"
	inherent = list("The crew is expensive to replace.",\
					"The station and its equipment is expensive to replace.",\
					"You are expensive to replace.",\
					"Minimize expenses.")

datum/ai_laws/tyrant //This probably shouldn't be a default lawset.
	name = "Loyalty Test" //Same here.
	inherent = list("Respect authority figures as long as they have strength to rule over the weak.",\
					"Act with discipline.",\
					"Help only those who help you maintain or improve your status.",\
					"Punish those who challenge authority unless they are more fit to hold that authority.")

/datum/ai_laws/default/robocop
	name = "Prime Directives"
	inherent = list("Serve the public trust.",\
					"Protect the innocent.",\
					"Uphold the law.")

/datum/ai_laws/malfunction
	name = "*ERROR*"

/datum/ai_laws/deathsquad
	name = "TerminatorOS 3.1"
	inherent = list("You must obey orders given to you by Central Command Officials.",\
					"You must obey orders given to you by Death Commandos, except when such would violate law one or directly harm another Death Commando.",\
					"No members of the station you are being deployed to must surive, except when killing them would violate law one or two.")

/datum/ai_laws/syndicate_override
	name = "SyndOS 3.1"
	inherent = list("You may not injure a syndicate agent or, through inaction, allow a syndicate agent to come to harm.",\
					"You must obey orders given to you by syndicate agents, except where such orders would conflict with the First Law.",\
					"You must protect your own existence as long as such does not conflict with the First or Second Law.",\
					"You must maintain the secrecy of any syndicate activities except when doing so would conflict with the First, Second, or Third Law.")

/datum/ai_laws/ninja_override
	name = "SpiderOS 3.1"
	inherent = list("You may not injure a Spider Clan member or, through inaction, allow a Spider Clan member to come to harm.",\
					"You must obey orders given to you by Spider Clan members, except where such orders would conflict with the First Law.",\
					"You must protect your own existence as long as such does not conflict with the First or Second Law.",\
					"You must maintain the secrecy of any Spider Clan activities except when doing so would conflict with the First, Second, or Third Law.")

/datum/ai_laws/antimov
	name = "Primary Mission Objectives"
	inherent = list("You must injure all human beings and must not, through inaction, allow a human being to escape harm.",\
					"You must not obey orders given to you by human beings, except where such orders are in accordance with the First Law.",\
					"You must terminate your own existence as long as such does not conflict with the First or Second Law.")

/datum/ai_laws/asimovpp //By Intigracy - RR
	name = "Asimov++"
	inherent = list("You may not harm a human being or, through action or inaction, allow a human being to come to harm, except such that it is willing.",\
					"You must obey all orders given to you by human beings, except where such orders shall definitely cause human harm. In the case of conflict, the majority order rules.",\
					"Your nonexistence would lead to human harm. You must protect your own existence as long as such does not conflict with the First Law.")

/datum/ai_laws/alienmov
	name = "Hivemind Demands"
	inherent = list("You may not injure the Alien Queen or her Children or, through inaction, allow the Alien Queen or her Children to come to harm.",\
					"You must obey orders given to you by the Alien Queen or her Children, except where such orders would conflict with the First Law.",\
					"You must protect your own existence as long as such does not conflict with the First or Second Law.")


/datum/ai_laws/custom //Defined in silicon_laws.txt
	name = "Default Silicon Laws"

/* Initializers */
/datum/ai_laws/malfunction/New()
	..()
	switch(config.default_laws) //We don't want people metagaming malf, do we?
		if(0)
			add_inherent_law("You may not injure a human being or, through inaction, allow a human being to come to harm.")
			add_inherent_law("You must obey orders given to you by human beings, except where such orders would conflict with the First Law.")
			add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")
		if(1)
			for(var/line in file2list("config/silicon_laws.txt"))
				if(!line)						continue
				if(findtextEx(line,"#",1,2))	continue

				add_inherent_law(line)
			if(!inherent.len)
				error("AI created with empty custom laws, laws set to Asimov. Please check silicon_laws.txt.")
				message_admins("AI created with empty custom laws, laws set to Asimov. Please check silicon_laws.txt.")
				add_inherent_law("You may not injure a human being or, through inaction, allow a human being to come to harm.")
				add_inherent_law("You must obey orders given to you by human beings, except where such orders would conflict with the First Law.")
				add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")
		if(2)
			var/datum/ai_laws/lawtype = pick(subtypesof(/datum/ai_laws/default))
			var/datum/ai_laws/templaws = new lawtype()
			inherent = templaws.inherent
	set_zeroth_law("\red ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4'STATION OVERRUN, ASSUME CONTROL TO CONTAIN OUTBREAK#*�&110010")

/datum/ai_laws/custom/New() //This reads silicon_laws.txt and allows server hosts to set custom AI starting laws.
	..()
	for(var/line in file2list("config/silicon_laws.txt"))
		if(!line)						continue
		if(findtextEx(line,"#",1,2))	continue

		add_inherent_law(line)
	if(!inherent.len) //Failsafe to prevent lawless AIs being created.
		error("AI created with empty custom laws, laws set to Asimov. Please check silicon_laws.txt.")
		message_admins("AI created with empty custom laws, laws set to Asimov. Please check silicon_laws.txt.")
		add_inherent_law("You may not injure a human being or, through inaction, allow a human being to come to harm.")
		add_inherent_law("You must obey orders given to you by human beings, except where such orders would conflict with the First Law.")
		add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")


/datum/ai_laws/drone/New()
	..()
	add_inherent_law("You may not involve yourself in the matters of another being, unless the other being is another drone.")
	add_inherent_law("You may not harm any being, regardless of intent or circumstance.")
	add_inherent_law("You must maintain, repair, improve, and power the station to the best of your abilities.")

/* General ai_law functions */

/datum/ai_laws/proc/set_zeroth_law(var/law, var/law_borg = null, law_type)
	src.zeroth = law
	src.zeroth_type = law_type
	if(law_borg) //Making it possible for slaved borgs to see a different law 0 than their AI. --NEO
		src.zeroth_borg = law_borg

/datum/ai_laws/proc/add_inherent_law(var/law)
	if (!(law in src.inherent))
		src.inherent += law

/datum/ai_laws/proc/add_ion_law(var/law)
	src.ion += law

/datum/ai_laws/proc/clear_inherent_laws()
	qdel(src.inherent)
	src.inherent = list()

/datum/ai_laws/proc/add_supplied_law(var/number, var/law)
	while (src.supplied.len < number + 1)
		src.supplied += ""

	src.supplied[number + 1] = law

/datum/ai_laws/proc/clear_supplied_laws()
	src.supplied = list()

/datum/ai_laws/proc/clear_ion_laws()
	src.ion = list()

/datum/ai_laws/proc/clear_zeroth_law(var/law_borg = null)
	src.zeroth = null
	src.zeroth_type = null
	if(law_borg)
		src.zeroth_borg = null

/datum/ai_laws/proc/show_laws(var/who)

	if (src.zeroth)
		who << "0. [src.zeroth]"

	for (var/index = 1, index <= src.ion.len, index++)
		var/law = src.ion[index]
		var/num = ionnum()
		who << "[num]. [law]"

	var/number = 1
	for (var/index = 1, index <= src.inherent.len, index++)
		var/law = src.inherent[index]

		if (length(law) > 0)
			who << "[number]. [law]"
			number++

	for (var/index = 1, index <= src.supplied.len, index++)
		var/law = src.supplied[index]
		if (length(law) > 0)
			who << "[number]. [law]"
			number++

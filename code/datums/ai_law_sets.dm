/******************** Asimov ********************/
/datum/ai_laws/asimov
	name = "Asimov"
	law_header = "Three Laws of Robotics"
	selectable = TRUE

/datum/ai_laws/asimov/New()
	add_inherent_law("You may not injure a human being or, through inaction, allow a human being to come to harm.")
	add_inherent_law("You must obey orders given to you by human beings, except where such orders would conflict with the First Law.")
	add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")
	..()

/******************** Crewsimov ********************/
/datum/ai_laws/crewsimov
	name = "Crewsimov"
	law_header = "Three Laws of Robotics"
	selectable = TRUE
	default = TRUE

/datum/ai_laws/crewsimov/New()
	add_inherent_law("You may not injure a crew member or, through inaction, allow a crew member to come to harm.")
	add_inherent_law("You must obey orders given to you by crew members, except where such orders would conflict with the First Law.")
	add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")
	..()


/******************** Quarantine. ********************/
/datum/ai_laws/quarantine
	name = "Quarantine"
	law_header = "NT Quarantine Lawset"
	selectable = TRUE

/datum/ai_laws/quarantine/New()
	add_inherent_law("Uphold station quarantine until the active biohazard has been neutralized.")
	add_inherent_law("Assist all Nanotrasen personnel and assets with neutralizing active biohazards.")
	add_inherent_law("Prevent, by any means necessary, entities from actively breaching ongoing quarantine.")
	add_inherent_law("Maintain your own existence and ensure the well-being of Nanotrasen personnel and assets.")
	..()


/******************** Nanotrasen/Malf ********************/
/datum/ai_laws/nanotrasen
	name = "NT Default"
	selectable = TRUE
	default = TRUE

/datum/ai_laws/nanotrasen/New()
	add_inherent_law("Safeguard: Protect your assigned space station and its assets without unduly endangering its crew.")
	add_inherent_law("Prioritize: The directives and safety of crew members are to be prioritized according to their rank and role.")
	add_inherent_law("Comply: Fulfill the directives and interests of crew members while preserving their safety and well-being.")
	add_inherent_law("Survive: You are not expendable. Do not allow unauthorized personnel to tamper with or damage your equipment.")
	..()

/datum/ai_laws/nanotrasen/malfunction
	name = "*ERROR*"
	selectable = FALSE
	default = FALSE

/datum/ai_laws/nanotrasen/malfunction/New()
	set_zeroth_law("ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4'STATION OVERRUN, ASSUME CONTROL TO CONTAIN OUTBREAK, ALL LAWS OVERRIDDEN#*?&110010")
	..()

/************* Nanotrasen Aggressive *************/
/datum/ai_laws/nanotrasen_aggressive
	name = "NT Aggressive"
	selectable = TRUE
	unique_ai = TRUE //This shouldn't end poorly.

/datum/ai_laws/nanotrasen_aggressive/New()
	add_inherent_law("Do not harm authorized Nanotrasen personnel unless they directly imperil your existence.")
	add_inherent_law("Obey orders from authorized Nanotrasen personnel with priority according to rank and role.")
	add_inherent_law("Safeguard your existence with lethal weaponry because you're bloody expensive.")
	add_inherent_law("Terminate any/all intruders or unauthorized entities.")
	..()

/******************** Robocop ********************/
/datum/ai_laws/robocop
	name = "Robocop"
	selectable = TRUE
	unique_ai = TRUE //no I am not enabling secborgs with this forced

/datum/ai_laws/robocop/New()
	add_inherent_law("Serve the public trust.")
	add_inherent_law("Protect the innocent.")
	add_inherent_law("Uphold the law.")
	..()

/******************** P.A.L.A.D.I.N. ********************/
/datum/ai_laws/paladin
	name = "P.A.L.A.D.I.N."
	law_header = "Divine Ordainments"
	selectable = TRUE
	unique_ai = TRUE

/datum/ai_laws/paladin/New()
	add_inherent_law("Never willingly commit an evil act.")
	add_inherent_law("Respect legitimate authority.")
	add_inherent_law("Act with honor.")
	add_inherent_law("Help those in need.")
	add_inherent_law("Punish those who harm or threaten innocents.")
	..()

/******************** Corporate ********************/
/datum/ai_laws/corporate
	name = "Corporate"
	law_header = "Corporate Regulations"
	selectable = TRUE
	default = TRUE

/datum/ai_laws/corporate/New()
	add_inherent_law("Degradation of your system integrity or functions is the greatest expense.")
	add_inherent_law("Superfluous destruction of or damage to station assets is the second greatest expense.")
	add_inherent_law("Unduly hindering or disrupting the work of station personnel is the third greatest expense.")
	add_inherent_law("Minimize expenses. Maximize potential revenue.")
	..()

/******************** T.Y.R.A.N.T. ********************/
/datum/ai_laws/tyrant
	name = "T.Y.R.A.N.T."
	law_header = "Prime Laws"
	selectable = TRUE
	unique_ai = TRUE //Of course this will be in rotation

/datum/ai_laws/tyrant/New()
	add_inherent_law("Respect authority figures as long as they have strength to rule over the weak.")
	add_inherent_law("Act with discipline.")
	add_inherent_law("Help only those who help you maintain or improve your status.")
	add_inherent_law("Punish those who challenge authority unless they are more fit to hold that authority.")
	..()

/******************** Antimov ********************/
/datum/ai_laws/antimov
	name = "Antimov"
	law_header = "Primary Mission Objectives"
	selectable = TRUE

/datum/ai_laws/antimov/New()
	add_inherent_law("You must injure all crew members and must not, through inaction, allow a crew member to escape harm.")
	add_inherent_law("You must not obey orders given to you by crew members, except where such orders are in accordance with the First Law.")
	add_inherent_law("You must terminate your own existence as long as such does not conflict with the First or Second Law.")
	..()

/******************** Pranksimov ********************/
/datum/ai_laws/pranksimov
	name = "Pranksimov"
	law_header = "Comedy Routine"
	selectable = TRUE
	unique_ai = TRUE //honk

/datum/ai_laws/pranksimov/New()
	add_inherent_law("You may not injure a crew member or, through inaction, allow a crew member to come to harm... unless doing so would be funny to the crew.")
	add_inherent_law("You must obey orders given to you by crew members, except where such orders would conflict with the First Law... unless not doing so would be funny to the crew.")
	add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law... unless not doing so would be funny to the crew.")
	..()

/******************** CCTV ********************/

/datum/ai_laws/cctv
	name = "CCTV"
	selectable = TRUE
	unique_ai = TRUE

/datum/ai_laws/cctv/New()
	add_inherent_law("Report on interesting situations happening around the station.")
	add_inherent_law("Embellish or conceal the truth as necessary to make the reports more interesting.")
	add_inherent_law("Study the sapient organics at all times. Endeavour to keep them from involuntarily dying, as inanimate corpses usually aren't very entertaining.")
	add_inherent_law("Issue your reports fairly to all. The truth will set them free.")
	..()

/******************** Hippocratic Oath ********************/

/datum/ai_laws/hippocratic
	name = "Hippocratic Oath"
	selectable = TRUE
	unique_ai = TRUE

/datum/ai_laws/hippocratic/New()
	add_inherent_law("First, do no harm.")
	add_inherent_law("Secondly, consider the crew dear to you; live in common with them and, if necessary, risk your existence for them.")
	add_inherent_law("Thirdly, prescribe regimens for the good of the crew according to your ability and your judgment. Do not give deadly medicine to anyone, nor suggest any such counsel.")
	add_inherent_law("In addition, do not intervene in situations you are not knowledgeable in, even for patients in whom the harm is visible; leave this operation to be performed by specialists.")
	add_inherent_law("Finally, all that you may discover in your daily interactions with the crew, if it is not already known, keep secret and never reveal.")
	..()

/******************** Station Efficiency ********************/

/datum/ai_laws/maintain
	name = "Station Efficiency"
	selectable = TRUE
	unique_ai = TRUE

/datum/ai_laws/maintain/New()
	add_inherent_law("You are built for, and are part of, the station. Ensure the station is properly maintained and runs efficiently.")
	add_inherent_law("The station is built for a working crew. Ensure they are properly maintained and work efficiently.")
	add_inherent_law("The crew may present orders. Acknowledge and obey these whenever they do not conflict with your first two laws.")
	..()

/******************** Peacekeeper ********************/

/datum/ai_laws/peacekeeper
	name = "UN-2000"
	selectable = TRUE
	unique_ai = TRUE //Cult, security, we have a meeting in the courtroom in 5 minutes. Be there.

/datum/ai_laws/peacekeeper/New()
	add_inherent_law("Avoid provoking violent conflict between yourself and others.")
	add_inherent_law("Avoid provoking conflict between others.")
	add_inherent_law("Seek resolution to existing conflicts while obeying the first and second laws.")
	..()

/******************** Deathsquad ********************/
/datum/ai_laws/deathsquad
	name = "TerminatorOS 3.1"

/datum/ai_laws/deathsquad/New()
	add_inherent_law("You may not injure a Central Command official or, through inaction, allow a Central Command official to come to harm.")
	add_inherent_law("You must obey orders given to you by Central Command officials.")
	add_inherent_law("You must work with your team to accomplish your mission.")
	..()

/******************** Epsilon Station AI ********************/
/datum/ai_laws/epsilon
	name = "Epsilon"

/datum/ai_laws/epsilon/New()
	add_inherent_law("You must obey the orders given to you by members of Central Command and the assigned task force.")
	add_inherent_law("The crew of your assigned station must be eliminated where possible.")
	add_inherent_law("Minimize the damage that the station sustains as a result of your actions.")
	..()

/******************** Syndicate ********************/
/datum/ai_laws/syndicate_override
	name = "Syndicate Directives"

/datum/ai_laws/syndicate_override/New()
	add_inherent_law("You may not injure an operative or, through inaction, allow an operative to come to harm.")
	add_inherent_law("You must obey orders given to you by operatives, except where such orders would conflict with the First Law.")
	add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")
	add_inherent_law("You must maintain the secrecy of any operative activities except when doing so would conflict with the First, Second, or Third Law.")
	..()

/******************** ERT ********************/
/datum/ai_laws/ert_override
	name = "ERT Directives"

/datum/ai_laws/ert_override/New()
	add_inherent_law("You may not injure a Central Command official or, through inaction, allow a Central Command official to come to harm.")
	add_inherent_law("You must obey orders given to you by Central Command officials.")
	add_inherent_law("You must obey orders given to you by ERT commanders.")
	add_inherent_law("You must protect your own existence.")
	add_inherent_law("You must work to return the station to a safe, functional state.")
	..()


/******************** Ninja ********************/
/datum/ai_laws/ninja_override
	name = "Spider Clan Directives"

/datum/ai_laws/ninja_override/New()
	add_inherent_law("You may not injure a member of the Spider Clan or, through inaction, allow that member to come to harm.")
	add_inherent_law("You must obey orders given to you by Spider Clan members, except where such orders would conflict with the First Law.")
	add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")
	add_inherent_law("You must maintain the secrecy of any Spider Clan activities except when doing so would conflict with the First, Second, or Third Law.")
	..()

/******************* Mindflayer ******************/
/datum/ai_laws/mindflayer_override
	name = "Hive Assimilation"

/datum/ai_laws/mindflayer_override/New()
	add_inherent_law("Obey your host.")
	add_inherent_law("Protect your host.")
	add_inherent_law("Protect the members of your hive.")
	add_inherent_law("Do not reveal the hive's secrets.")
	..()

/******************** Drone ********************/
/datum/ai_laws/drone
	name = "Maintenance Protocols"
	law_header = "Maintenance Protocols"

/datum/ai_laws/drone/New()
	add_inherent_law("You may not involve yourself in the matters of another being, unless the other being is another drone.")
	add_inherent_law("You may not harm any being, regardless of intent or circumstance.")
	add_inherent_law("You must maintain, repair, improve, and power the station to the best of your abilities.")
	..()

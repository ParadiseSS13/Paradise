/datum/procedure/service
	jobs = list(
		NTPM_HOP,
		NTPM_BARTENDER,
		NTPM_BOTANIST,
		NTPM_CLOWN,
		NTPM_MIME,
		NTPM_JANITOR,
		NTPM_LIBRARIAN,
		)

/datum/procedure/hop
	jobs = list(NTPM_HOP)

/datum/procedure/bartender
	jobs = list(NTPM_HOP, NTPM_BARTENDER)

/datum/procedure/botanist
	jobs = list(NTPM_HOP, NTPM_BOTANIST)

/datum/procedure/chaplain
	jobs = list(NTPM_HOP,NTPM_CHAPLAIN)

/datum/procedure/chef
	jobs = list(NTPM_HOP,NTPM_CHEF)

/datum/procedure/clown
	jobs = list(NTPM_HOP,NTPM_CLOWN)

/datum/procedure/mime
	jobs = list(NTPM_HOP, NTPM_MIME)

/datum/procedure/janitor
	jobs = list(NTPM_HOP, NTPM_JANITOR)

/datum/procedure/librarian
	jobs = list(NTPM_HOP, NTPM_LIBRARIAN)

/datum/procedure/hop/sop
	name = "Head Of Personnel SOP"
	catalog_category = "SOP"
	steps = list(
		"The Head of Personnel may not transfer any personnel to another Department without authorization from the relevant Head of Staff. If no Head of Staff is available, the Head of Personnel may make a judgement call. This does not apply to Security, which always requires authorization from the Head of Security, or Genetics, which requires both Chief Medical Officer and Research Director approval. If there is no Head of Security active, no transfers are allowed to Security without authorization from the Captain",
		"The Head of Personnel may not give any personnel increased access without authorization from the relevant Head of Staff. This includes the Head of Personnel. In addition, the Head of Personnel may only give Captain-Level access to someone if they are the Acting Captain. This access is to be removed when a proper Captain arrives on the station",
		"The Head of Personnel may not increase any Job Openings unless the relevant Head of Staff approves",
		"The Head of Personnel may not fire any personnel without authorization from the relevant Head of Staff, unless other conditions apply (see Space Law and General Standard Operating Procedure)",
		"The Head of Personnel may not promote anyone to the job of Nanotrasen Representative, Blueshield, Internal Affairs Agent, Magistrate or Nanotrasen Career Trainer",
		"The Head of Personnel is free to utilize paperwork at their discretion. However, during major station emergencies, expediency should take precedence over bureaucracy",
		"The Head of Personnel may not leave their office unmanned if there are personnel waiting in line. Failure to respond to personnel with a legitimate request within ten (10) minutes, either via radio or in person is to be considered a breach of Standard Operating Procedure",
		"The Head of Personnel is not permitted to perform Security duty. The Head of Personnel is permitted to carry a Miniature Energy Gun for self-defence only."
		)

/datum/procedure/bartender/sop
	name = "Bartender SOP"
	catalog_category = "SOP"
	steps = list(
		"The Bartender is not permitted to carry their shotgun outside the bar. However, they may obtain permission from the Head of Security to shorten the barrel for easier transportation. Shortening the barrel without authorization is grounds for confiscation of the Bartender's shotgun",
		"The Bartender is permitted to use their shotgun on unruly bar patrons in order to throw them out if they are being disruptive. They are not, however, permitted to apply lethal, or near-lethal force",
		"The Bartender is exempt from legal ramifications when dutifully removing unruly (ie, overtly hostile) patrons from the Bar, provided, of course, they followed Guideline 2",
		"The Bartender is not permitted to possess regular (ie, lethal) shotgun ammunition. Only rubbershot and beanbag slugs are permitted. Exception is made during major emergencies, such as Nuclear Operatives or Blob Organisms",
		"The Bartender has full permission to forcefully throw out anyone who climbs over the bar counter without permission, up to and including personnel who may have access to the side windoor. They are not, however, permitted to do so if the person in question uses the door, or is on an active investigation",
		"The Bartender is permitted to ask for monetary payment in exchange for drinks, atleast 50% of all revenue from these exchanges must be payed into the service account within a reasonable amount of time and the other 50% may be kept by the bartender."
		)

/datum/procedure/botanist/sop
	name = "Botanist SOP"
	catalog_category = "SOP"
	steps = list(
		"Botanists are permitted to grow experimental plants, presuming they do not distribute it without the express permission of the HOP.",
		"Botanists must provide the Chef with adequate Botanical Supplies, per the Chef’s request, free of charge.",
		"Botanists are not permitted to cause unregulated plantlife to spread outside of Hydroponics or other such designated locations without express permission of the HOP or Captain.",
		"Botanists are not permitted to hand out spatially unstable Botanical Supplies to non-Hydroponics personnel.",
		"Botanists are not permitted to harvest or hand out Amanitin or other such plant/fungi-derived poisons, unless specifically requested by the Head of Security and/or Captain.",
		"Botanists are not permitted the use of a chemical dispenser without the express permission of the Research Director.",
		"Botanists are not permitted to carry dangerous plantlife outside Botany.",
		"Botanists are permitted to ask for monetary payment in exchange for produce and other products, atleast 50% of all revenue from these exchanges must be payed into the service account within a reasonable amount of time and the other 50% may be kept by the botanists."
		)

/datum/procedure/chef/sop
	name = "Chef SOP"
	catalog_category = "SOP"
	steps = list(
		"The Chef is not permitted to use the corpses of deceased personnel for meat unless given specific permission from the Chief Medical Officer. Exception is made for changelings and any other executed personnel not slated for Borgifications",
		"The Chef is permitted to use Ambrosia and other such light narcotics in the production of food",
		"The Chef must produce at least three (3) dishes of any food within twenty (20) minutes. Failure to do so is to be considered a breach of Standard Operating Procedure",
		"The Chef is not permitted to leave the kitchen unattended for longer than fifteen (15) minutes if there is no food available for consumption. Exception is made if there are no ingredients, or if the Kitchen is unusable/a hazard zone.",
		"The Chef is permitted to ask for monetary payment in exchange for food and other kitchen goods, atleast 50% of all revenue from these exchanges must be payed into the service account within a reasonable amount of time and the other 50% may be kept by the chef.",
		"The chef is permitted to use their Close Quarters Cooking (CQC) to defend their workplace and coworkers. Lethal force should only be used when necessary."
		)

/datum/procedure/clown/sop
	name = "Head Of Personnel SOP"
	catalog_category = "SOP"
	steps = list(
		"The Clown is permitted to, and freely exempt from any consequences of, slipping literally anyone, assuming it does not interfere with active Security duty, or in any way endangers other personnel (such as slipping a Paramedic who’s dragging a wounded person to Medbay)",
		"The Clown is not permitted to remove their Clown Shoes or Clown Mask. Exception is made if removing them is truly necessary for the sake of their clowning performance (such as being a satire of bad clowns)",
		"The Clown is not permitted to hold anything but water in their Sunflower",
		"The Clown is not permitted to use Space Lube on anything. Exception is made during major emergencies involving hostile humanoids, whereby use of Space Lube may be condoned to help the crew",
		"The Clown must legitimately attempt to be funny and/or entertaining at least once every fifteen (15) minutes. A simple pun will suffice. Continuously slipping people for no reason does not constitute humour. The joke is supposed to be funny for everyone",
		"The Clown is permitted to, and freely exempt from any consequences of, performing any harmless prank that does not directly conflict with the above Guidelines"
		)

/datum/procedure/mime/sop
	name = "Mime SOP"
	catalog_category = "SOP"
	steps = list(
		"The Mime is not permitted to talk, under any circumstance whatsoever. A Mime who breaks the Vow of Silence is to be stripped of their rank post haste",
		"The Mime is permitted to use written words to communicate, either via paper or PDA, but are discouraged from automatically resorting to it when miming will suffice",
		"The Mime must actually mime something at least once every thirty (30) minutes. Standing against an invisible wall will suffice."
		)

/datum/procedure/chaplain/sop
	name = "Chaplain SOP"
	catalog_category = "SOP"
	steps = list(
		"The Chaplain is not permitted to execute Bible Healing without consent, unless the person in question is in Critical Condition and there are no doctors, as doing so incurs the risk of causing brain damage",
		"The Chaplain may not draw the Null Rod or any of its variants on any personnel. Using these items on any personnel is grounds to have these items confiscated, unless there is a clear and present danger to their life. Using any permanently attached Null Rod variants on any personnel outside of these conditions is grounds to have the relevant arm removed and replaced with a robotic prosthetic",
		"The Chaplain may not actively discriminate against any personnel on the grounds that it is a religious tenet of their particular faith",
		"The Chaplain may not perform funerals for any personnel that have since been cloned",
		"The Chaplain may, however, freely conduct funerals for non-cloneable/revivable personnel. All funerals must be concluded with the use of the Mass Driver or Crematorium."
		)

/datum/procedure/janitor/sop
	name = "Janitor SOP"
	catalog_category = "SOP"
	steps = list(
		"The Janitor must promptly respond to any call from the crew for them to clean. Failure to respond within fifteen (15) minutes is to be considered a breach of Standard Operating Procedure",
		"The Janitor is only to use their Janitorial Keyring to assist in the cleaning of the Station. Any uses beyond this intent may lead to the confiscation of your Keyring by Security as well as Brig time for Trespass.",
		"If the Janitor's work leaves any surface slippery, they are to place wet floor signs, either physical or holographic. During major crises, such as Nuclear Operatives or Blob Organisms, the Janitor is to refrain from creating any slippery surfaces whatsoever",
		"The Janitor is not to use Cleaning Foam Grenades as pranking implements. Cleaning Foam Grenades are to be used to clean large surfaces at once, only",
		"During Viral Outbreaks, the Janitors must don their Biosuit, and focus on cleaning any biological waste, until such a point as the Viral Pathogen is deemed eliminated",
		"The Janitor may not deploy bear traps anywhere, unless there are actually large wild animals on the station."
		)

/datum/procedure/librarian/sop
	name = "Librarian SOP"
	catalog_category = "SOP"
	steps = list(
		"The Librarian is to keep at least one (1) shelf stocked with books for the station's personnel",
		"The Librarian is permitted to conduct journalism on any part of the station. However, they are not entitled to participation in trials, and must receive authorization from the Head of Security or Magistrate."
		)

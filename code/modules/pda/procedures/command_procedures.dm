/datum/procedure/command
	jobs = list(JOBGUIDE_CAPTAIN, JOBGUIDE_BLUESHIELD, JOBGUIDE_CE, JOBGUIDE_CMO, JOBGUIDE_HOP, JOBGUIDE_HOS, JOBGUIDE_NTR, JOBGUIDE_QM, JOBGUIDE_CMO)

/datum/procedure/captain
	jobs = list(JOBGUIDE_CAPTAIN)

/datum/procedure/blueshield
	jobs = list(JOBGUIDE_BLUESHIELD)

/datum/procedure/ntr
	jobs = list(JOBGUIDE_NTR)

/datum/procedure/captain/sop
	name = "Captain SOP"
	catalog_category = "SOP"
	steps = list(
		"The Captain is not permitted to perform regular Security Duty. However, they may still assist Security if they are understaffed, or if they see a crime being committed. However, the Captain is not permitted to take items from the Armory under normal circumstances, unless authorized by the Head of Security. In addition, the Captain may not requisition weaponry for themselves from Cargo and/or Science, unless there's an immediate threat to station and/or crew",
		"If a Department lacks a Head of Staff, the Captain should make reasonable efforts to appoint an Acting Head of Staff, if there are available personnel to fill the position",
		"The Captain is to ensure that Space Law is being correctly applied. This should be done in cooperation with the Head of Security",
		"The Captain is not to leave the Station unless given specific permission by Central Command, or it happens to be the end of the shift. To do so is to be considered abandoning their posts and is grounds for termination",
		"The Captain must keep the Nuclear Authentication Disk on their person at all times or failing that, in the possession of the Head of Security or Blueshield",
		"The Captain is to attempt to resolve every issue that arises in Command locally before contacting Central Command",
		"The Captain is not permitted to carry their Antique Laser Gun unless there's an immediate threat on their life",
		"The Captain is not permitted to wear their Magnate MODSuit unless there's an active environmental danger or threat on their life",
		"The Captain, despite being in charge of the Station, is not independent from Nanotrasen. Any attempts to disregard general company policy are to be considered an instant condition for contract termination",
		"The Captain may only promote personnel to a Acting Head of Staff position if there is no assigned Head of Staff associated with the Department. Said Acting Head of Staff must be a member of the Department they are to lead. See below for more information on Chain of Command",
		"The Captain may not fire any Head of Staff without reasonable justification (i.e., incompetency, criminal activity, or otherwise any action that endangers or compromises the station and/or crew). The Captain may not fire any Central Command VIPs (i.e., Blueshield, Magistrate and Nanotrasen Representative) without permission from Central Command, unless they are blatantly acting against the well-being and safety of the crew and station. The Captain must also follow HoP SOP point"
		)

/datum/procedure/blueshield/sop
	name = "Blueshield SOP"
	catalog_category = "SOP"
	steps = list(
		"The Blueshield may not conduct arrests under the same conditions as Security. However, they may apprehend any personnel that trespass on a Head of Staff Office or Command Area, any personnel that steal from those locations, or any personnel that steal from and/or injure any Head of Staff or Central Command VIP. However, all apprehended personnel are to be processed by Security personnel",
		"The Blueshield is to put the lives of Command over those of any other personnel, the Blueshield included. Their continued well-being is the Blueshield's top priority. This includes applying basic first aid and making sure they are revived if killed",
		"The Blueshield is to protect the lives of Command personnel, not follow their orders to a fault. The Blueshield is not to interfere with legal demotions or arrests. To do so is to place themselves under the Special Modifier Aiding and Abetting",
		"The Blueshield is not to apply Lethal Force unless there is a clear and present danger to their life, or to the life of a member of Command and the assailant cannot be non-lethally detained."
		)

/datum/procedure/ntr/sop
	name = "Nanotrasen Repressentative SOP"
	catalog_category = "SOP"
	steps = list(
		"The Nanotrasen Representative is to ensure that every Department is following Standard Operating Procedure, up to and including the respective Head of Staff. If a Head of Staff is not available for a Department, the Nanotrasen Representative must ensure that the Captain appoints an Acting Head of Staff for said Department",
		"The Nanotrasen Representative must attempt to resolve any breach of Standard Operating Procedure locally before contacting Central Command. This is an imperative: Standard Operating Procedure should always be followed unless there is a very good reason not to",
		"The Nanotrasen Representative must, together with the Magistrate and Head of Security, ensure that Space Law is being followed and correctly applied",
		"The Nanotrasen Representative may not threaten the use of a fax in order to gain leverage over any personnel, up to and including Command. In addition they may not threaten to fire or have Central Command fire anyone, unless they actually possess a demotion note",
		"The Nanotrasen Representative is permitted to carry their flash and a Stun-Cane, or a Telescopic Baton if the Stun-Cane is lost."
		)

/datum/procedure/command/ai_maintenance
	name = "AI maintenance SOP"
	catalog_category = "SOP"
	steps = list(
		"Only the Captain or Research Director may enter the AI Upload to perform Law Changes (see below), and only the Captain, Research Director or Chief Engineer may enter the AI Core to perform a Carding (see below)",
		"No Law Changes are to be performed without approval from the Captain and Research Director. The only Lawsets to be used are those provided by Nanotrasen. Failure to legally perform a Law Change is to be considered Sabotage. Command must be informed prior to the Law Change, and all objections must be taken into consideration. If the number of Command personnel opposing the Law Change is greater than the number of Command personnel in favour, the Law Change is not to be done. If the Law Change is performed, the crew is to be immediately informed of the new Law(s)",
		"The AI may not be Carded unless it is clearly malfunctioning or subverted. However, any member of Command may card it if the AI agrees to it, either at the end of the shift, or due to external circumstances (such as massive damage to the AI Satellite)",
		"The AI Upload and Minisat Antechamber Turrets are to be kept on Non-Lethal in Code Green and Code Blue. The AI Core Turrets are to be kept on Lethal at all times. If a legal Law Change or Carding is occurring, the Turrets are to be disabled",
		"If the AI Unit is not malfunctioning or subverted, any attempt at performing an illegal Carding or Law Change is to be responded to with non-lethal force. If the illegal attempts persist, and the perpetrator is demonstrably hostile, lethal force from Command/Security is permitted",
		"Freeform Laws are only to be added if absolutely necessary due to external circumstances (such as major station emergencies). Adding unnecessary Freeform Laws is not permitted. Exception is made if the AI Unit and majority of Command agree to the Freeform Law that is proposed",
		"Any use of the \"Purge\" Module is to be followed by the upload of a Nanotrasen-approved Lawset immediately. AI Units must be bound to a Lawset at all times."
		)

/datum/procedure/security
	jobs = list(
		JOBGUIDE_HOS,
		JOBGUIDE_WARDEN,
		JOBGUIDE_SECURITY_OFFICER,
		JOBGUIDE_DETECTIVE,
		)

/datum/procedure/hos
	jobs = list(JOBGUIDE_HOS)

/datum/procedure/secoff
	jobs = list(JOBGUIDE_HOS ,JOBGUIDE_SECURITY_OFFICER)

/datum/procedure/warden
	jobs = list(JOBGUIDE_HOS ,JOBGUIDE_WARDEN)

/datum/procedure/detective
	jobs = list(JOBGUIDE_HOS ,JOBGUIDE_DETECTIVE)

/datum/procedure/hos/sop_green
	name = "Head Of Security SOP 1(Code Green)"
	catalog_category = "SOP"
	steps = list(
		"The Head of Security is permitted to carry out arrests under the same conditions as their Security Officers",
		"The Head of Security is permitted to carry a standard disabler, a flash, a telescopic baton, a flashbang, a standard energy gun, and a can of pepperspray. While permitted to carry their unique Energy Gun, they are discouraged from doing so for safety concerns, and should keep it on Stun/Disable",
		"The Head of Security is not permitted to wear their Safeguard MODSuit unless there's an active environmental danger or threat on their life",
		"The Head of Security is not obligated to provide a trial, but is encouraged to allow legal representation should the suspect request it. This only applies to Capital Crimes",
		"The Head of Security may not overrule a Magistrate, unless their decisions are blatantly breaking Standard Operating Procedure and/or Space Law. In which case Central Command is to be contacted as well",
		"The Head of Security must follow the same guidelines as the Warden for Armory equipment, portable flashers and deployable barriers",
		"The Head of Security is not permitted to collect equipment from the Armory to carry on their person",
		"The Head of Security is permitted to either use their regular coat, or armored trenchcoat",
		"The Head of Security is permitted to wear their unique gas mask",
		"The Head of Security may not overrule established sentences, unless further evidence is brought to light or the prisoner in question attempts to escape",
		"The Head of Security must follow the same guidelines as Security Officers for attire, with the exception that their own assigned attire is also acceptable for any of the attire mentioned for Security Officers."
		)

/datum/procedure/hos/sop_blue
	name = "Head Of Security SOP 2(Code Blue)"
	catalog_category = "SOP"
	steps = list(
		"The Head of Security is permitted to carry out arrests under the same conditions as their Security Officers",
		"The Head of Security is permitted to carry a standard disabler, a flash, a telescopic baton, a flashbang, a standard energy gun, and a can of pepperspray.",
		"The Head of Security is not permitted to wear their Safeguard MODSuit unless there's an active environmental danger or threat on their life",
		"The Head of Security is not obligated to provide a trial, but is encouraged to allow legal representation should the suspect request it. This only applies to Capital Crimes",
		"The Head of Security may not overrule a Magistrate, unless their decisions are blatantly breaking Standard Operating Procedure and/or Space Law. In which case Central Command is to be contacted as well",
		"The Head of Security must follow the same guidelines as the Warden for Armory equipment, portable flashers and deployable barriers",
		"The Head of Security is not permitted to collect equipment from the Armory to carry on their person",
		"The Head of Security is permitted to either use their regular coat, or armored trenchcoat",
		"The Head of Security is permitted to wear their unique gas mask",
		"The Head of Security may not overrule established sentences, unless further evidence is brought to light or the prisoner in question attempts to escape",
		"The Head of Security must follow the same guidelines as Security Officers for attire, with the exception that their own assigned attire is also acceptable for any of the attire mentioned for Security Officers.",
		"The Head of Security is permitted to wear their Safeguard MODSuit at all times."
		)

/datum/procedure/hos/sop_red
	name = "Head Of Security SOP 3(Code Red)"
	catalog_category = "SOP"
	steps = list(
		"The Head of Security is permitted to carry out arrests under the same conditions as their Security Officers",
		"The Head of Security is not obligated to provide a trial, but is encouraged to allow legal representation should the suspect request it. This only applies to Capital Crimes",
		"The Head of Security may not overrule a Magistrate, unless their decisions are blatantly breaking Standard Operating Procedure and/or Space Law. In which case Central Command is to be contacted as well",
		"The Head of Security must follow the same guidelines as the Warden for Armory equipment, portable flashers and deployable barriers",
		"The Head of Security is permitted to either use their regular coat, or armored trenchcoat",
		"The Head of Security is permitted to wear their unique gas mask",
		"The Head of Security may not overrule established sentences, unless further evidence is brought to light or the prisoner in question attempts to escape",
		"The Head of Security must follow the same guidelines as Security Officers for attire, with the exception that their own assigned attire is also acceptable for any of the attire mentioned for Security Officers.",
		"The Head of Security is permitted to wear their Safeguard MODSuit at all times.",
		"Guideline 2 is carried over from Code Blue",
		"The Head of Security is required to make a Station Announcement regarding the nature of the confirmed threat that caused Code Red. The Captain may perform this duty in the place of the Head of Security."
		)

/datum/procedure/secoff/sop_green
	name = "Security Officer SOP 1(Code Green)"
	catalog_category = "SOP"
	steps = list(
		"Security Officers are required to state the reasons behind an arrest before any further action is taken. Exception is made if the suspect refuses to stop",
		"Security Officers must attempt to bring all suspects or witnesses to the Brig without handcuffing or incapacitating them. Should the suspect not cooperate, the officer may proceed as usual",
		"No weapons are to be unholstered until the suspect attempts to run away or becomes actively hostile",
		"Security Officers are permitted to carry a standard disabler, a flash, a flashbang, a stunbaton and a can of pepperspray",
		"Security Officers may not demand access to the interior of other Departments during regular patrols. However, asking for access from the Head of Personnel is still acceptable",
		"Security officers are not permitted to have weapons drawn during regular patrols",
		"Security officers are permitted to conduct searches, provided there is reasonable evidence/suspicion that the person in question has committed a crime. Any further searches require a warrant from the Head of Security, Captain or Magistrate",
		"Security Officers are required to wear at least one (1) identifiable and visible piece of security equipment on their person at all times. Acceptable items are: any security jumpsuit, any security armor, any security jacket or security winter coat, any security helmet or headwear."
		)

/datum/procedure/secoff/sop_blue
	name = "Security Officer SOP 2(Code Blue)"
	catalog_category = "SOP"
	steps = list(
		"Security Officers are required to state the reasons behind an arrest before any further action is taken. Exception is made if the suspect refuses to stop",
		"Security Officers must attempt to bring all suspects or witnesses to the Brig without handcuffing or incapacitating them. Should the suspect not cooperate, the officer may proceed as usual",
		"Security Officers are permitted to carry a standard disabler, a flash, a flashbang, a stunbaton and a can of pepperspray",
		"Security Officers are required to wear at least one (1) identifiable and visible piece of security equipment on their person at all times. Acceptable items are: any security jumpsuit, any security armor, any security jacket or security winter coat, any security helmet or headwear.",
		"Security Officers are permitted to carry around any weapons or equipment available in the Armory, at the Warden's discretion, but never more than one at a time. Exception is made for severe emergencies, such as Blob Organisms or Nuclear Operatives",
		"Security Officers are permitted to carry weapons in hand during regular patrols, although this is not advised",
		"Security Officers are permitted to present weapons during arrests",
		"Security Officers may demand entry to specific Departments during regular patrols",
		"Security Officers may randomly search crewmembers, but are not allowed to apply any degree of force unless said crewmember acts overtly hostile. Crew who refuse to be searched may be stunned and cuffed for the search",
		"Security Officers are permitted to leave prisoners bucklecuffed should they act hostile."
		)

/datum/procedure/secoff/sop_red
	name = "Security Officer SOP 3(Code Red)"
	catalog_category = "SOP"
	steps = list(
		"Security Officers are required to wear at least one (1) identifiable and visible piece of security equipment on their person at all times. Acceptable items are: any security jumpsuit, any security armor, any security jacket or security winter coat, any security helmet or headwear.",
		"Security Officers are permitted to carry around any weapons or equipment available in the Armory, at the Warden's discretion, but never more than one at a time. Exception is made for severe emergencies, such as Blob Organisms or Nuclear Operatives",
		"Security Officers are permitted to carry weapons in hand during regular patrols, although this is not advised",
		"Security Officers are permitted to present weapons during arrests",
		"Security Officers may demand entry to specific Departments during regular patrols",
		"Security Officers may randomly search crewmembers, but are not allowed to apply any degree of force unless said crewmember acts overtly hostile. Crew who refuse to be searched may be stunned and cuffed for the search",
		"Security Officers are permitted to leave prisoners bucklecuffed should they act hostile.",
		"Security Officers may arrest crewmembers with no stated reason if there is evidence they are involved in criminal activities",
		"Security Officers may forcefully relocate crewmembers to their respective Departments if necessary."
		)

/datum/procedure/warden/sop_green
	name = "Warden SOP 1(Code Green)"
	catalog_category = "SOP"
	steps = list(
		"The Warden may not perform arrests if there are Security Officers active",
		"The Warden must conduct a thorough search of every prisoner’s belongings, including pockets, PDA slots, any coat pockets and suit storage slots",
		"The Warden is not obligated to provide a trial, but is encouraged to allow legal representation should the suspect request it. This only applies to Capital Crimes",
		"The Warden may not hand out any weapons or armour from the Armory, except for extra disablers. Modsuits may be issued if emergency E.V.A action is required. Exception is made if there is an immediate threat that requires attention, such as Nuclear Operatives, or rioters",
		"The Warden is permitted to carry a standard disabler, a flash, a stunbaton, a flashbang and a can of pepperspray",
		"The Warden may not place the portable flashers within the Brig",
		"The Warden may not place the deployable barriers within the Brig",
		"The Warden must read to every prisoner the crimes they are sentenced to",
		"The Warden is not permitted to leave prisoners bucklecuffed to their beds. An exception is made if the prisoners acts overtly hostile or attempts to breach the cell in order to escape",
		"The Warden must follow the same guidelines as Security Officers for attire, with the exception that their own assigned attire is also acceptable for any of the attire mentioned for Security Officers."
		)

/datum/procedure/warden/sop_blue
	name = "Warden SOP 2(Code Blue)"
	catalog_category = "SOP"
	steps = list(
		"The Warden may not perform arrests if there are Security Officers active",
		"The Warden must conduct a thorough search of every prisoner’s belongings, including pockets, PDA slots, any coat pockets and suit storage slots",
		"The Warden is not obligated to provide a trial, but is encouraged to allow legal representation should the suspect request it. This only applies to Capital Crimes",
		"The Warden is permitted to carry a standard disabler, a flash, a stunbaton, a flashbang and a can of pepperspray",
		"The Warden must read to every prisoner the crimes they are sentenced to",
		"The Warden must follow the same guidelines as Security Officers for attire, with the exception that their own assigned attire is also acceptable for any of the attire mentioned for Security Officers.",
		"The Warden is permitted to hand out all equipment from the Armory. Energy and Laser guns are only to be handed out with Head of Security or Captain's approval, as they present a lethal risk, or if there is an immediate threat, such as Blob Organisms or Nuclear Operatives",
		"The Warden is permitted to place the portable flashers inside the Brig",
		"The Warden is permitted to place the deployable barriers inside the Brig."
		)

/datum/procedure/warden/sop_red
	name = "Warden SOP 3(Code Red)"
	catalog_category = "SOP"
	steps = list(
		"The Warden must conduct a thorough search of every prisoner’s belongings, including pockets, PDA slots, any coat pockets and suit storage slots",
		"The Warden is not obligated to provide a trial, but is encouraged to allow legal representation should the suspect request it. This only applies to Capital Crimes",
		"The Warden is permitted to place the portable flashers inside the Brig",
		"The Warden is permitted to carry a standard disabler, a flash, a stunbaton, a flashbang and a can of pepperspray",
		"The Warden must read to every prisoner the crimes they are sentenced to",
		"The Warden must follow the same guidelines as Security Officers for attire, with the exception that their own assigned attire is also acceptable for any of the attire mentioned for Security Officers.",
		"The Warden is permitted to place the deployable barriers inside the Brig.",
		"The Warden is permitted to distribute any weapon or piece of equipment in the Armory. This includes whatever Research has provided",
		"The Warden is permitted to carry out arrests freely."
		)

/datum/procedure/detective/sop_green
	name = "Detective SOP 1(Code Green)"
	catalog_category = "SOP"
	steps = list(
		"The Detective is permitted to assist Security Officers with all Patrol Duties. This includes stops, searches, and arrests as per the current Alert Code. They should, however, prioritize investigations and the collection of forensic evidence",
		"The Detective is to follow all Standard Operating Procedures as outlined by the Security Officer SoP in regards to stops, searches and arrests as per the current Alert Code",
		"The Detective may carry their DL-88 Energy Revolver, spare charge packs, and crew pinpointer",
		"The Detective may carry their telescopic baton",
		"The Detective is permitted to unholster and use their energy revolver on tracker mode for the sole purpose of marking criminals to search",
		"The Detective is not permitted to overcharge their energy revolver without permission from the Head of Security",
		"The Detective is permitted to wear non-Security clothing with permission from the Head of Security for the purpose of undercover investigations. They are, however, expected to carry with them a Holobadge and their Security ID on their person at all times.",
		"When not undercover, the Detective must follow the same guidelines as Security Officers for attire, with the exception that their own assigned attire is also acceptable for any of the attire mentioned for Security Officers."
		)

/datum/procedure/detective/sop_blue
	name = "Detective SOP 2(Code Blue)"
	catalog_category = "SOP"
	steps = list(
		"The Detective is permitted to assist Security Officers with all Patrol Duties. This includes stops, searches, and arrests as per the current Alert Code. They should, however, prioritize investigations and the collection of forensic evidence",
		"The Detective is to follow all Standard Operating Procedures as outlined by the Security Officer SoP in regards to stops, searches and arrests as per the current Alert Code",
		"The Detective may carry their DL-88 Energy Revolver, spare charge packs, and crew pinpointer",
		"The Detective may carry their telescopic baton",
		"The Detective is permitted to unholster and use their energy revolver on tracker mode for the sole purpose of marking criminals to search",
		"The Detective is not permitted to overcharge their energy revolver without permission from the Head of Security",
		"The Detective is permitted to wear non-Security clothing with permission from the Head of Security for the purpose of undercover investigations. They are, however, expected to carry with them a Holobadge and their Security ID on their person at all times.",
		"When not undercover, the Detective must follow the same guidelines as Security Officers for attire, with the exception that their own assigned attire is also acceptable for any of the attire mentioned for Security Officers.",
		"The Detective may pull aside any suspect for an interrogation during the course of their time in Processing. No detainee is to be held for longer than ten (10) minutes in Processing if no evidence against them is readily available.",
		"The Detective may use their energy revolver on standard mode during arrests."
		)

/datum/procedure/detective/sop_red
	name = "Detective SOP 3(Code Red)"
	catalog_category = "SOP"
	steps = list(
		"The Detective is permitted to assist Security Officers with all Patrol Duties. This includes stops, searches, and arrests as per the current Alert Code. They should, however, prioritize investigations and the collection of forensic evidence",
		"The Detective is to follow all Standard Operating Procedures as outlined by the Security Officer SoP in regards to stops, searches and arrests as per the current Alert Code",
		"The Detective may carry their DL-88 Energy Revolver, spare charge packs, and crew pinpointer",
		"The Detective may carry their telescopic baton",
		"The Detective is permitted to unholster and use their energy revolver on tracker mode for the sole purpose of marking criminals to search",
		"The Detective is permitted to wear non-Security clothing with permission from the Head of Security for the purpose of undercover investigations. They are, however, expected to carry with them a Holobadge and their Security ID on their person at all times.",
		"The Detective may pull aside any suspect for an interrogation during the course of their time in Processing. No detainee is to be held for longer than ten (10) minutes in Processing if no evidence against them is readily available.",
		"The Detective may use their energy revolver on standard mode during arrests.",
		"The Detective is permitted to overcharge their energy revolver and freely discharge it when handling deadly threats in accordance with Space Law's ruling on Use of Deadly Force",
		"The Detective is permitted to carry around any weapons or equipment available in the Armory, at the Warden's discretion, but never more than one at a time. Exception is made for severe emergencies, such as Blob Organisms or Nuclear Operatives"
		)
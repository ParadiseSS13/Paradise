/datum/procedure/science
	jobs = list(
		NTPM_RD,
		NTPM_SCIENTIST,
		NTPM_ROBOTICIST,
		NTPM_GENETICIST
		)

/datum/procedure/rd
	jobs = list(NTPM_RD)

/datum/procedure/scientist
	jobs = list(NTPM_RD, NTPM_SCIENTIST)

/datum/procedure/roboticist
	jobs = list(NTPM_RD, NTPM_ROBOTICIST)

/datum/procedure/geneticist
	jobs = list(NTPM_RD, NTPM_GENETICIST)

/datum/procedure/rd/sop_green
	name = "Research Director SOP 1(code green)"
	catalog_category = "SOP"
	steps = list(
		"The Research Director must make sure Research is being done. Research must be completed by the end of the shift, assuming Science is provided the materials for it by Supply",
		"The Research Director is permitted to carry a telescopic baton and a flash",
		"The Research Director is not permitted to bring harmful chemicals outside of Science",
		"The Research Director is permitted to carry their Reactive Teleport Armour on their person. However, it is highly recommended they keep it inactive unless necessary, for personal safety",
		"The Research Director is not permitted to authorize the construction of AI Units without the Captain’s approval. An exception is made if the station was not provided with an AI Unit, or a previous AI Unit had to be destroyed. If an AI does exist already, it's permission is required before constructing a new AI, unless it is clearly malfunctioning or subverted.",
		"The Research Director must keep the Communications Decryption Key on their person at all times, or at least somewhere safe and out of reach",
		"The Research Director is permitted to change the AI Unit’s lawset, provided they receive general approval from the Captain and another Head of Staff. If there are no other Heads of Staff available, Captain approval will suffice",
		"The Research Director must work with Robotics to make sure all Cyborgs remain slaved to the station’s AI Unit, except in such a situation where the AI Unit has been subverted or is malfunctioning."
		)

/datum/procedure/rd/sop_blue
	name = "Research Director SOP 2(code blue)"
	catalog_category = "SOP"
	steps = list(
		"All Guidelines carry over from Code Green."
		)

/datum/procedure/rd/sop_red
	name = "Research Director SOP 3(code red)"
	catalog_category = "SOP"
	steps = list(
		"Guidelines 1, 4, 5, 6, 7, 8 and 9 carry over from Code Green",
		"In addition to the a telescopic baton and flash, the Research Director is permitted to carry a single weapon created in the Protolathe, provided they receive authorization from the Head of Security. Exception is made during extreme emergencies, such as Nuclear Operatives or Blob Organisms.",
		"The Research Director is permitted to bring harmful chemicals outside of Science for delivery to security personnel, so long as either the Head of Security or Captain authorises it. Said chemicals must be for security-oriented purposes (thermite, controlled explosives, crowd control, biohazard containment, etc.)."
		)

/datum/procedure/scientist/sop
	name = "Scientist SOP 1(code green)"
	catalog_category = "SOP"
	steps = list(
		"Scientists are not permitted to bring grenades outside of Science",
		"Scientists are not permitted to bring harmful chemicals outside of Science",
		"Scientists are not permitted to bring Toxins bombs outside of Science. Exception is made if the Toxins Bomb is handed to Mining, as it can be useful for mining operations",
		"While not mandatory, it is highly recommended that Scientists give a prior warning before a Toxins test. This must be done via the Common Communication Channel, with at least ten (10) seconds between the warning and detonation",
		"Scientists must, at all times, keep live slimes and Golden Extract-based lifeforms inside Xenobiology pens, except when transporting them to new cells. Peaceful Golden Extract lifeforms may be released with the express permission of the Research Director. In addition, injecting plasma into Golden Extract is strictly forbidden",
		"Scientists are not permitted to construct the Portable Wormhole Generator without express permission from the Research Director. In addition, Scientists are not to hand out Weapon Lockboxes to any non-Security or non-Command personnel without express permission from the Head of Security",
		"Scientists are not permitted to create AI Core Boards without express permission from the Captain and/or Research Director."
		)

/datum/procedure/scientist/sop_blue
	name = "Scientist SOP 2(code blue)"
	catalog_category = "SOP"
	steps = list(
		"Guidelines 2, 4, 5, 6, and 7 carry over from Code Green",
		"Scientists are permitted to bring Grenades outside of Science, but only for delivery to the Armory",
		"Scientists are permitted to bring Toxins Bombs outside of Science, but only for delivery to the Armory. In addition, the Mining exception still applies."
		)

/datum/procedure/scientist/sop_red
	name = "Scientist SOP 3(code red)"
	catalog_category = "SOP"
	steps = list(
		"Guidelines 4, 5, 6, and 7 carry over from Code Green",
		"All Guidelines carry over from Code Blue."
		)

/datum/procedure/roboticist/sop_green
	name = "Roboticist SOP 1(code green)"
	catalog_category = "SOP"
	steps = list(
		"The Roboticist is not permitted to construct Combat Mechs without express permission from the Captain and/or Head of Security. This refers to the Durand, Gygax and Phazon. If permitted, the Mechs is to be delivered to the Armory for storage. The Research Director is placed under the same restrictions",
		"The Roboticist is freely permitted to construct Utility Mechs, along with any assorted Utility Equipment. This refers to Ripleys (to be handed to Mining), Firefighting Ripleys (to be handed to Atmospherics) and the Odysseus Medical Mech (to be handed to Medical). The HONK Mech or Reticence is not to be constructed without full approval by the Research Director and Captain",
		"The Roboticist is freely permitted to construct Cyborgs and all assorted equipment",
		"The Roboticist is not permitted to transfer personnel MMIs into Cyborgs without express written consent from the person in question. The consent form should be kept safe",
		"The Roboticist is to follow RD Green SOP #5 in constructing new AIs as well as requiring the Research Director's approval.",
		"The Roboticist must place a Tracking Beacon on all constructed Mechs",
		"The Roboticist must work together with the Research Director to make sure all Cyborgs remain slaved to the station’s AI Unit, except in such a situation where the AI Unit has been subverted or is malfunctioning",
		"The Roboticist must DNA-Lock all parked Mechs prior to delivery. DNA-Lock must be removed when the Mech is delivered to its final destination."
		)

/datum/procedure/roboticist/sop_blue
	name = "Roboticist SOP 2(code blue)"
	catalog_category = "SOP"
	steps = list(
		"Guidelines 2, 3, 4, 5, 6, 7 and 8 carry over from Code Green",
		"The Roboticist is permitted to construct Combat Mechs without prior consent, but must deliver them to the Armory for storage. Failure to comply will result in the Combat Mech being destroyed. Exception is made for extreme emergencies, such as a Blob Organism or Nuclear Operatives, where the Roboticist may pilot the Mech themselves. However, even in these circumstances, the Mech must be delivered to the Armory after the emergency is over. The Research Director is placed under the same restrictions."
		)

/datum/procedure/roboticist/sop_red
	name = "Roboticist SOP 3(code red)"
	catalog_category = "SOP"
	steps = list(
		"Guidelines 3, 4, 5, 6, 7, and 8 carry over from Code Green",
		"All Guidelines carry over from Code Blue."
		)

/datum/procedure/geneticist/sop_green
	name = "Geneticist SOP 1(code green)"
	catalog_category = "SOP"
	steps = list(
		"The Geneticist is not permitted to ignore Cloning, and must provide Clean SE Injectors when required, as well as humanized animals if required for Surgery. In addition, the Geneticist must make sure that Cloning is stocked with Biomass",
		"The Geneticist is permitted to test Genetic Powers on themselves. However, they are not to utilize these powers on any crewmembers, nor abuse them to obtain items/personnel outside their access",
		"The Geneticist is permitted to grant Genetic Powers to Command Staff at their discretion, provided prior permission is requested and granted. All staff must be warned of the full effects of the SE Injector. The Geneticist is not, however, obligated to grant powers, unless the Research Director issues a direct order",
		"The Geneticist is not permitted to grant Powers to non-Command Staff without express verbal consent from the Research Director. Both the Chief Medical Officer and the Research Director maintain full authority to forcefully remove these Powers if they are abused",
		"The Geneticist must place all discarded humanized animals in the Morgue. It is recommended that said discarded humanized animals be directed to the Crematorium",
		"The Geneticist is not permitted to provide body doubles, unless the Research Director approves it. In addition, Security is to be notified of all doubles",
		"The Geneticist is not permitted to alter personnel’s UI Status, unless it has been previously tampered with by hostile elements, or permission is given",
		"The Geneticist is not permitted to use sentient humanoids as test subjects unless the sentient humanoid has granted their permission, on paper."
		)

/datum/procedure/geneticist/sop_blue
	name = "Geneticist SOP 2(code blue)"
	catalog_category = "SOP"
	steps = list(
		"All Guidelines carry over from Code Green."
		)

/datum/procedure/geneticist/sop_red
	name = "Geneticist SOP 3(code red)"
	catalog_category = "SOP"
	steps = list(
		"All Guidelines carry over from Code Green. In regards to Guideline 4, the Geneticist is now permitted to grant Powers to Security personnel, under the same conditions as detailed in Guideline"
		)

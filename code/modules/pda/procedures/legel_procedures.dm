/datum/procedure/legal
	jobs = list(JOBGUIDE_MAGISTRATE, JOBGUIDE_IAA)

/datum/procedure/magistrate
	jobs = list(JOBGUIDE_MAGISTRATE)

/datum/procedure/iaa
	jobs = list(JOBGUIDE_IAA)

/datum/procedure/magistrate/sop
	name = "Magistrate SOP"
	catalog_category = "SOP"
	steps = list(
		"Magistrates are to ensure that Space Law is applied correctly. If it is not, they are to make it so",
		"Magistrates have the final say on whether or not Trials take place, and should ensure they should only occur for Capital Sentences. Similarly, Magistrates are to ensure that Trials do not happen for Defendants that are self-evidently guilty",
		"Magistrates can overrule anyone in all matters concerning Space Law. This does not extend to Emergency Response Teams, Central Command Officials or direct Central Command communications",
		"The Magistrate is permitted to carry their flash and a telescopic baton.",
		"Magistrates are not above Space Law. Similarly, they cannot overrule Security on a sentence imposed against themselves. If a Magistrate attempts to do this, contact Central Command immediately",
		"In the absence of Internal Affairs Agents or a Nanotrasen Representative, the Magistrate may elect to handle matters of Standard Operating Procedure. Otherwise, they are only to ensure that the Internal Affairs Agents under their command are handling such matters",
		"Magistrates may not impede the expedient functioning of Security for the sake of micromanaging every aspect it. They should only concern themselves with crimes that either have fuzzy evidence, or require careful deliberation of circumstances",
		"Magistrates are to contact Central Command immediately if their decisions are being ignored, provided said decision actually match up with Space Law and Standard Operating Procedure. Please see this guide for more information on how to write a good fax."
		)

/datum/procedure/iaa/sop
	name = "Internal Afairs Agent SOP"
	catalog_category = "SOP"
	steps = list(
		"Internal Affairs Agents are only to provide legal representation for personnel facing a Capital Sentence. They should, however, ensure that their timed sentence is applied correctly, and alert Security if it is not. In addition, Internal Affairs Agents are permitted to provide legal advice for Security and prisoners, as well as investigating whether or not arrests were done properly",
		"Internal Affairs Agents must request permission from any potential client before serving as their legal representative, as said client may choose to either represent themselves, or request someone else",
		"Internal Affairs Agents are not to deliberately halt or slow down prisoner processing or ongoing investigations. If Security is acting in a demonstrably incompetent manner, contacting the Head of Security or the Captain is highly recommended. If more information about the crime in question is needed, Agents should wait until the person in question was brigged",
		"Internal Affairs Agents are permitted to carry their flash.",
		"Internal Affairs Agents are to ensure that Standard Operating Procedure is being properly followed, when applicable, and to contact the relevant Head of Staff when it is not",
		"Internal Affairs Agents are to attempt to resolve all Standard Operating Procedure issues locally before contacting Central Command. This should be done in tandem with Command and, if possible, personnel in the relevant Department. If a valid report is ignored by the relevant Head of Staff, the Captain is to be contacted. If the Captain ignores the report, then Central Command and/or the NanoTrasen Representative must be contacted."
		)

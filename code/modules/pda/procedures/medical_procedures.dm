/datum/procedure/medical
	jobs = list(
		JOBGUIDE_CMO,
		JOBGUIDE_DOCTOR,
		JOBGUIDE_PARAMED,
		JOBGUIDE_CORONER,
		JOBGUIDE_CHEMIST,
		JOBGUIDE_VIROLOGIST,
		JOBGUIDE_PSYCHAIATRIST)

/datum/procedure/cmo
	jobs = list(JOBGUIDE_CMO)

/datum/procedure/doctor
	jobs = list(JOBGUIDE_CMO, JOBGUIDE_DOCTOR)

/datum/procedure/paramedic
	jobs = list(JOBGUIDE_CMO, JOBGUIDE_PARAMED)

/datum/procedure/chemist
	jobs = list(JOBGUIDE_CMO, JOBGUIDE_CHEMIST)

/datum/procedure/virologist
	jobs = list(JOBGUIDE_CMO, JOBGUIDE_VIROLOGIST)

/datum/procedure/psychaiatrist
	jobs = list(JOBGUIDE_CMO, JOBGUIDE_PSYCHAIATRIST)

/datum/procedure/coroner
	jobs = list(JOBGUIDE_CMO, JOBGUIDE_CORONER)

/datum/procedure/cmo/sop
	name = "Chief Medical Officer SOP"
	catalog_category = "SOP"
	steps = list(
		"The Chief Medical Officer is permitted to carry a regular Defibrillator or a Compact Defibrillator on their person at all times",
		"The Chief Medical Officer is permitted to carry a telescopic baton and a flash. In case Genetic Powers need to be forcefully removed, they are cleared to carry a Syringe Gun",
		"The Chief Medical Officer is not permitted to allow the creation of poisonous or explosive mixtures in Chemistry without express consent from the Captain or, failing that, the presence of a clear and urgent danger to the integrity of the station, except of course in situations where Chemical Implants are required",
		"The Chief Medical Officer is not permitted to allow the release of any virus without a full list of its symptoms, and they must have a vaccine of the virus on hand to be given out on request. The virus may not have any harmful symptoms whatsoever, though neutral/harmless symptoms are permitted",
		"The Chief Medical Officer must make sure that any cloneable corpses are cloned."
		)

/datum/procedure/doctor/sop
	name = "Medical Doctor SOP"
	catalog_category = "SOP"
	steps = list(
		"Though not mandatory, it is recommended that Doctors wear Sterile Masks and Latex/Nitrile gloves when handling patients. This Guideline becomes mandatory during Viral Outbreaks",
		"Nurses should focus on helping Medical Doctors and Surgeons in whatever they require, and tending to patients that require light care. If necessary, they can stand in for regular Medical Doctor duties",
		"Surgeons are expected to fulfill the duties of regular Medical Doctors if there are no active Surgical Procedures undergoing",
		"Medical Doctors must ensure there is at least one (1) Defibrillator available for use next to or near the Cryotubes",
		"Medical Doctors must maintain the entirety of Medbay in an hygienic state. This includes, but is not limited to, cleaning organic residue, fluids and/or corpses",
		"Medical Doctors must place all corpses inside body bags. If there is an assigned Coroner, the Morgue Trays must be correctly tagged",
		"Medical Doctors must work together with Geneticists and Chemists to make sure that Cloning is stocked with Biomass, Osseous Reagent and Sanguine Reagent. In addition, Medical Doctors must make sure that the Morgue does not contain cloneable corpses",
		"Medical Doctors must certify that all cloned personnel are free from clone damage if not, they are to be put into a Cryotube. In addition, Medical Doctors must ensure cloned personnel are fully healed and any damage or missing organs are fixed before being released",
		"Medical Doctors are not permitted to leave Medbay to perform recreational activities if there are unattended patients requiring treatment",
		"Medical Doctors must stabilize patients before delivering them to Surgery. If the patient presents Internal Bleeding, they are to be taken to Surgery post haste.",
		"Medical Doctors are not obliged to treat patients who are actively and intentionally harming themselves. If treated, refer the patient to the on-station Psychologist."
		)

/datum/procedure/paramedic/sop
	name = "Paramedic SOP"
	catalog_category = "SOP"
	steps = list(
		"The Paramedic is not permitted to perform Field Surgery unless there are no available Medical Doctors or the Operating Rooms are unusable",
		"The Paramedic is permitted to perform Surgical Procedures inside an Operating Room. However, Doctors/Surgeons should take precedence",
		"The Paramedic is fully permitted to carry a Defibrillator on their person at all times, provided they leave at least one (1) Defibrillator for use in Medbay",
		"The Paramedic must stabilize all patients before bringing them to the Medical Bay. If the patient presents with Internal Bleeding, they are to be taken to Surgery post haste",
		"In such a case as a patient is found dead, and cannot be brought back via Defibrillation, the Paramedic must ensure that said patient is brought to Cloning and Medbay is notified",
		"The Paramedic must carry enough materials to provide for adequate first aid of all Major Injury Types (Brute, Burn, Toxic, Respiratory and Brain)."
		)

/datum/procedure/chemist/sop
	name = "Chemist SOP"
	catalog_category = "SOP"
	steps = list(
		"The Chemist is not permitted to experiment with explosive mixtures",
		"The Chemist is not permitted to experiment with poisonous mixtures and/or narcotics",
		"The Chemist is not permitted to experiment with Life or other Omnizine-derived mixtures apart from Omnizine, Lazarus Reagent or Sanguine Reagent",
		"The Chemist is not permitted to produce alcoholic beverages",
		"Chemists in conjuction with Medical Doctors and/or Geneticists must make sure that Cloning is stocked with Biomass, Osseous Reagent and Sanguine Reagent",
		"The Chemist must ensure that the Medical Fridge is stocked with at least enough medication to handle Brute, Burn, Respiratory, Toxic and Brain damage. Failure to follow this Guideline or attempting to follow this Guideline within thirty (30) minutes is to be considered a breach of Standard Operating Procedure",
		"The Chemist is not allowed to leave Chemistry unattended if the Medical Fridge is devoid of Medication, except in such a case that Chemistry is unusable or if Fungus needs to be collected."
		)

/datum/procedure/virologist/sop
	name = "Virologist SOP"
	catalog_category = "SOP"
	steps = list(
		"The Virologist must always wear adequate protection (such as a Biosuit and Internals for Airborne Viruses) when handling infected personnel and Test Animals. Exception is made for IPC Virologists, for obvious reasons",
		"The Virologist must only test viral samples on the provided Test Animals. Said Test Animals are to be maintained inside their pen, and disposed of via Virology's Disposals Chutes if dead, to prevent possible contamination. In addition, the Virologist is not permitted to leave Virology while infected by a Viral Pathogen that spreads by Contact or Airborne means, unless permitted by the Chief Medical Officer",
		"The Virologist may not release an active virus without prior consent from Chief Medical Officer. Contact and/or Airborne viruses may only be released with consent from the Chief Medical officer and Captain. In the event a Contact and/or Airborne virus is released, the crew must be informed, and Vaccines should be ready for any personnel that choose to opt out of being infected",
		"The Virologist must ensure that all Viral Samples are kept on their person at all times, or at the very least in a secure location (such as the Virology Fridge)",
		"All visitors to Virology must be warned if there is an active Airborne/Contact Viral Pathogen being tested. This includes Medical Personnel",
		"The Virologist must work together with Medical Staff, especially Chemistry, if there is a cure that requires manufacturing",
		"In the event of a lethal Viral Outbreak, the Virologist must work together with the Chief Medical Officer and/or Chemists and/or Bartender to produce a cure. Failure to keep casualties down to, at most, 25% of the station's crew is to be considered a breach of Standard Operating Procedure for everyone involved."
		)

/datum/procedure/psychaiatrist/sop
	name = "Psychiatrist SOP"
	catalog_category = "SOP"
	steps = list(
		"The Psychologist may perform a full psychological evaluation on anyone, along with any potential treatment, provided the person in question seeks them out",
		"The Psychologist may not force someone to receive therapy if the person does not want it. Exception is made for violent criminals and only if the Head of Security, Magistrate or Captain orders it",
		"The Psychologist is not permitted to administer any medication without consent from their patient",
		"The Psychologist is not permitted to muzzle or straightjacket anyone without express permission from the Chief Medical Officer or Head of Security. An exception is made for violent and/or out of control patients",
		"The Psychologist may recommend a patient's demotion if they find their psychological condition to render them unfit to fulfill their duties",
		"The Psychologist may request to consult prisoners in Permanent Imprisonment. This must happen inside the Brig, preferably inside the Permabrig, and only with Warden and/or Head of Security authorization. This should be done under the supervision of a member of Security with Permabrig access."
		)

/datum/procedure/coroner/sop
	name = "Coroner SOP"
	catalog_category = "SOP"
	steps = list(
		"The Coroner must, along with the Chief Medical Officer, make sure that any cloneable corpses are cloned",
		"The Coroner must contact the relevant Head of Staff to report on any deaths, reporting on any personnel that won't be returning to duty",
		"The Coroner must safely store all non-cosmetic departmental materials, tools and clothes. Heads of Staff must then report to the Morgue to recover these items. All IDs must be returned to the Head of Personnel. The Coroner may not keep any of these items, under penalty of Petty Theft or Theft",
		"If the Morgue becomes full, the deceased of lowest rank may be entrusted to the Chaplain for burial",
		"For the sake of hygiene, the Coroner should wear a Sterile Mask when handling corpses",
		"The Coroner must inject/apply Formaldehyde to all corpses, and place them in body bags",
		"The Coroner must perform a full autopsy on all corpses, and keep a record of it, in written format. If foul play is suspected, Security must be contacted",
		"The Coroner must correctly tag the Morgue Trays in order to identify the corpse within, as well as Cause of Death",
		"The Coroner must ensure Security-based DNR Notices (such as executed personnel, for instance) are respected.",
		"The Coroner may treat suicide victims as DNR unless otherwise directed by the CMO. They are to be labelled clearly as suicides, so they are not mistaken with Security-based DNR Notices",
		)

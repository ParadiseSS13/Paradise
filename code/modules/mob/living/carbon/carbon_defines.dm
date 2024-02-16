/mob/living/carbon
	gender = MALE
	pressure_resistance = 15

	var/list/stomach_contents
	var/last_stomach_attack

	var/list/processing_patches
	var/list/internal_organs = list()
	var/list/internal_organs_slot = list()	//Same as above, but stores "slot ID" - "organ" pairs for easy access.
	/// An associated list of strings that associate it with the organ datum, e.g. [ORGAN_DATUM_HEART] = /datum/organ/heart
	var/list/internal_organ_datums = list()

	var/life_tick = 0      // The amount of life ticks that have processed on this mob.

	/// Whether or not the mob is handcuffed, restraints/handcuffs/ required for var/cuffed_state
	var/obj/item/restraints/handcuffs/handcuffed = null
	/// Same as handcuffs but for legs. Bear traps use this.
	var/obj/item/restraints/legcuffs/legcuffed = null

	var/obj/item/head = null
	var/obj/item/clothing/suit/wear_suit = null		//TODO: necessary? Are they even used? ~Carn

	//Active emote/pose
	var/pose = null

	var/pulse = PULSE_NORM	//current pulse level

	var/wetlevel = 0 //how wet the mob is

	var/co2overloadtime = null
	var/dreaming = 0 //How many dream images we have left to send
	var/nightmare = 0

	blood_volume = BLOOD_VOLUME_NORMAL

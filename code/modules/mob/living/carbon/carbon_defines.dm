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

	/// The amount of life ticks that have processed on this mob.
	var/life_tick = 0

	/*
	Clothing Vars
	*/
	/// Whether or not the mob is handcuffed, restraints/handcuffs/ required for var/cuffed_state
	var/obj/item/restraints/handcuffs/handcuffed = null
	/// Same as handcuffs but for legs. Bear traps use this.
	var/obj/item/restraints/legcuffs/legcuffed = null

	/// The object stored on the head of the mob. Strangly not on the Human level
	var/obj/item/head = null
	/// The object stored on the exosuit slot of the mob. Strangly not on the Human level
	var/obj/item/clothing/suit/wear_suit = null

	/// Active emote/pose. Similar to flavor text
	var/pose = null

	/// Current pulse of this mob. Updated by handle_pulse on life
	var/pulse = PULSE_NORM

	/// Tracks how wet the mob is. Only used for examining the mob
	var/wetlevel = 0

	/// Used to track how much CO2 is in our system. Too much CO2 means you get stunned and die
	var/co2overloadtime = null

	/*
	Dream Vars
	*/
	/// How many dream messages we have left to send
	var/dreaming = 0
	/// How many nightmare messages we have left to send
	var/nightmare = 0

	blood_volume = BLOOD_VOLUME_NORMAL

	/*
	* Pain variables
	*/
	/// Stores the last pain message we got. used to prevent chatspam from pain
	var/last_pain_message = ""
	/// Stores the last time we sent a pain message. used to prevent chatspam from pain
	var/next_pain_time = 0

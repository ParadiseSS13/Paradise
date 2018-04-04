/mob/living/carbon
	gender = MALE
	var/list/stomach_contents = list()
	var/list/internal_organs	= list()
	var/list/internal_organs_slot	= list()	//Same as above, but stores "slot ID" - "organ" pairs for easy access.
	var/antibodies = 0

	var/life_tick = 0      // The amount of life ticks that have processed on this mob.

	var/obj/item/handcuffed = null //Whether or not the mob is handcuffed
	var/obj/item/legcuffed = null  //Same as handcuffs but for legs. Bear traps use this.

	var/obj/item/head = null
	var/obj/item/clothing/suit/wear_suit = null		//TODO: necessary? Are they even used? ~Carn

	var/mob/living/simple_animal/borer/borer = null

	//Active emote/pose
	var/pose = null

	var/pulse = PULSE_NORM	//current pulse level

	var/wetlevel = 0 //how wet the mob is

	var/failed_last_breath = FALSE //This is used to determine if the mob failed a breath. If they did fail a brath, they will attempt to breathe each tick, otherwise just once per 4 ticks.
	var/co2overloadtime = null
	var/dreaming = 0 //How many dream images we have left to send
	var/nightmare = 0

	blood_volume = BLOOD_VOLUME_NORMAL

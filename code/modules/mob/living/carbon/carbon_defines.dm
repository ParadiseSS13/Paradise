/mob/living/carbon
	gender = MALE
	hud_possible = list(HEALTH_HUD,STATUS_HUD,SPECIALROLE_HUD)
	var/list/stomach_contents = list()
	var/list/internal_organs	= list()
	var/antibodies = 0

	var/life_tick = 0      // The amount of life ticks that have processed on this mob.

	var/crit_health = 0 // Health level that will cause a carbon to fall unconscious
	var/softcrit_health = 0
	var/low_oxy_ko = 50 // Amount of oxygen damage needed to score a knockout

	// total amount of wounds on mob, used to spread out healing and the like over all wounds
	var/number_wounds = 0
	var/embedded_flag = 0	//To check if we've need to roll for damage on movement while an item is imbedded in us.
	var/obj/item/handcuffed = null //Whether or not the mob is handcuffed
	var/obj/item/legcuffed = null  //Same as handcuffs but for legs. Bear traps use this.

	var/obj/item/head = null
	var/obj/item/clothing/suit/wear_suit = null		//TODO: necessary? Are they even used? ~Carn

	//Active emote/pose
	var/pose = null

	var/pulse = PULSE_NORM	//current pulse level

	var/heart_attack = 0
	var/wetlevel = 0 //how wet the mob is

	var/oxygen_alert = 0
	var/toxins_alert = 0
	var/co2_alert = 0
	var/fire_alert = 0

	var/failed_last_breath = 0 //This is used to determine if the mob failed a breath. If they did fail a brath, they will attempt to breathe each tick, otherwise just once per 4 ticks.
	var/co2overloadtime = null

	// Used for animating carbons lying down (rotating 90 degrees)
	var/lying_prev = 0

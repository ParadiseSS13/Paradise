/mob/living/carbon/
	gender = MALE
	hud_possible = list(HEALTH_HUD,STATUS_HUD,SPECIALROLE_HUD)
	var/list/stomach_contents = list()
	var/list/internal_organs	= list()
	var/brain_op_stage = 0.0
	var/list/datum/disease2/disease/virus2 = list()
	var/antibodies = 0
	var/last_eating = 0 	//Not sure what this does... I found it hidden in food.dm

	var/life_tick = 0      // The amount of life ticks that have processed on this mob.
	var/analgesic = 0 // when this is set, the mob isn't affected by shock or pain
					  // life should decrease this by 1 every tick
	// total amount of wounds on mob, used to spread out healing and the like over all wounds
	var/number_wounds = 0
	var/obj/item/handcuffed = null //Whether or not the mob is handcuffed
	var/obj/item/legcuffed = null  //Same as handcuffs but for legs. Bear traps use this.

	var/obj/item/head = null
	var/obj/item/clothing/suit/wear_suit = null		//TODO: necessary? Are they even used? ~Carn

	//Surgery info
	var/datum/surgery_status/op_stage = new/datum/surgery_status
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
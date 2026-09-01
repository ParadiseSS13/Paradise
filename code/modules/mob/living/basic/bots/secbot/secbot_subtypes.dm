/mob/living/basic/bot/secbot/beepsky/officer
	name = "Officer Beepsky"
	desc = "It's Officer Beepsky! Powered by a potato and a shot of whiskey, and with a sturdier reinforced chassis, too."
	health = 45

/mob/living/basic/bot/secbot/beepsky/ofitser
	name = "Prison Ofitser"
	desc = "Powered by the tears and sweat of laborers."
	bot_mode_flags = ~(BOT_MODE_CAN_BE_SAPIENT|BOT_MODE_AUTOPATROL)

/mob/living/basic/bot/secbot/beepsky/armsky
	name = "Sergeant-At-Armsky"
	desc = "It's Sergeant-At-Armsky! He's a disgruntled assistant to the warden that would probably shoot you if he had hands."
	health = 45
	security_mode_flags = SECBOT_DECLARE_ARRESTS | SECBOT_CHECK_IDS | SECBOT_CHECK_RECORDS | SECBOT_CHECK_WEAPONS

/mob/living/basic/bot/secbot/beepsky/jr
	name = "Officer Pipsqueak"
	desc = "It's Commander Beep O'sky's smaller, just-as aggressive cousin, Pipsqueak."

/mob/living/basic/bot/secbot/beepsky/jr/Initialize(mapload)
	. = ..()
	update_transform(0.8)

/mob/living/basic/bot/secbot/pingsky
	name = "Officer Pingsky"
	desc = "It's Officer Pingsky! Delegated to satellite guard duty for harbouring anti-human sentiment."
	light_color = "#62baf5"
	radio_channel = "AI Private"
	bot_mode_flags = ~(BOT_MODE_CAN_BE_SAPIENT|BOT_MODE_AUTOPATROL)
	security_mode_flags = SECBOT_DECLARE_ARRESTS | SECBOT_CHECK_IDS | SECBOT_CHECK_RECORDS

/mob/living/basic/bot/secbot/beepsky/explode()
	var/turf/Tsec = get_turf(src)
	new /obj/item/stock_parts/cell/potato(Tsec)
	var/obj/item/reagent_containers/drinks/drinkingglass/S = new(Tsec)
	S.reagents.add_reagent("whiskey", 15)
	S.on_reagent_change()
	return ..()

/mob/living/basic/bot/secbot/buzzsky
	name = "Officer Buzzsky"
	desc = "It's Officer Buzzsky! Rusted and falling apart, he seems less than thrilled with the crew for leaving him in his current state."
	base_icon = "rustbot"
	icon_state = "rustbot0"
	bot_mode_flags = BOT_MODE_ON
	security_mode_flags = NONE
	emagged = TRUE

/mob/living/basic/bot/secbot/buzzsky/Initialize(mapload)
	. = ..()
	bot_access_flags |= BOT_COVER_EMAGGED
	bot_access_flags |= BOT_COVER_LOCKED

/obj/item/suspiciousphone
	name = "suspicious phone"
	desc = "This device is connected to the interstellar stock exchange. With but a single sentence, you can start a chain reaction to crash the market - dump it."
	icon = 'icons/obj/items.dmi'
	icon_state = "suspiciousphone"
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = "dump"
	new_attack_chain = TRUE
	/// Has the phone been used already?
	var/dumped = FALSE
	/// Accounts to remove from the hack list
	var/list/safe_accounts = list()

/obj/item/suspiciousphone/activate_self(mob/living/carbon/user)
	. = ..()
	if(!ishuman(user))
		to_chat(user, SPAN_WARNING("This device is too advanced for you!"))
		return
	add_fingerprint(user)
	if(dumped)
		to_chat(user, SPAN_WARNING("You already activated Protocol CRAB-17."))
		return FALSE
	if(tgui_alert(user, "Are you sure you want to crash the interstellar market with no survivors?", "Protocol CRAB-17", list("Yes", "No")) == "Yes")
		if(dumped || QDELETED(src)) // Prevents fuckers from cheesing alert
			return FALSE
		var/impact_area = findMaintananceEventArea()
		var/list/area_turfs = get_area_turfs(impact_area)
		var/turf/targetturf
		for(var/i in 1 to length(area_turfs))
			targetturf = pick_n_take(area_turfs)
			if(targetturf.is_blocked_turf())
				shuffle(area_turfs)
				continue
		if(!targetturf)
			to_chat(user, SPAN_WARNING("There is no valid area to deploy a money machine."))
			return FALSE

		var/datum/money_account_database/main_station/station_db = GLOB.station_money_database
		var/list/accounts_to_rob = station_db.get_all_accounts()
		accounts_to_rob -= safe_accounts
		var/obj/item/storage/box/crab_box/money_box = new(src)
		user.put_in_hands(money_box)
		new /obj/effect/dumpeet_target(targetturf, user, money_box, accounts_to_rob)

		to_chat(user, SPAN_NOTICE("You have activated Protocol CRAB-17."))
		dumped = TRUE

/obj/item/suspiciousphone/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!istype(used, /obj/item/card/id))
		return ..()
	var/obj/item/card/id/card = used
	var/datum/money_account/account = card.get_card_account()
	if(!account)
		to_chat(user, SPAN_WARNING("[card] does not have a linked account!"))
		return ITEM_INTERACT_COMPLETE
	if(account in safe_accounts)
		to_chat(user, SPAN_NOTICE("[card]'s account is already secure!"))
		return ITEM_INTERACT_COMPLETE
	to_chat(user, SPAN_NOTICE("You swipe [card] on [src]."))
	safe_accounts += account
	return ITEM_INTERACT_COMPLETE

/obj/structure/checkoutmachine
	name = "\improper remote market exchange"
	desc = "This mobile device steals credits from local accounts and dumps them into the interstellar stock exchange."
	icon = 'icons/obj/machines/money_machine.dmi'
	icon_state = "money_machine"
	layer = ABOVE_ALL_MOB_LAYER
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = TRUE
	light_power = 2
	light_range = 4
	light_color = LIGHT_COLOR_CYAN
	pixel_z = -8
	max_integrity = 5000 // Needs to be hard to destroy manually to incentivise swiping cards
	/// List of bank accounts to take money from, determines in start_dumping()
	var/list/accounts_to_rob
	/// The original user of the suspicious phone
	var/mob/living/thief
	/// The box to send money
	var/obj/item/storage/box/moneybox
	/// Are we able to start moving?
	var/canwalk = FALSE
	/// How much money do we have?
	var/held_credits

/obj/structure/checkoutmachine/Initialize(mapload, mob/living/user, money_box, list/accounts)
	. = ..()
	if(QDELETED(src))
		return
	thief = user
	moneybox = money_box
	accounts_to_rob = accounts

/obj/structure/checkoutmachine/examine(mob/living/user)
	. = ..()
	. += SPAN_INFO("It has a flashing <b>ID card reader</b> for convenient cashing out.")

/**
 * Check whether any accounts in the accounts_to_rob list are still being drained.
 * Returns TRUE if no accounts are being drained, FALSE otherwise
 */
/obj/structure/checkoutmachine/proc/check_if_finished()
	var/datum/money_account_database/main_station/station_db = GLOB.station_money_database
	var/accounts_to_check = accounts_to_rob - station_db.get_all_department_accounts() // Accounts_to_check should just be the crew accounts still on the list
	if(length(accounts_to_check) <= (length(GLOB.crew_list) * 0.3))
		return TRUE
	return FALSE

/obj/structure/checkoutmachine/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!canwalk)
		to_chat(user, SPAN_WARNING("[src] is not ready to accept transactions!"))
		return ..()

	if(check_if_finished())
		Destroy(src)
		return ITEM_INTERACT_COMPLETE

	var/obj/item/card/id/card = tool
	if(!istype(card))
		return ..()

	var/datum/money_account/account = card.get_card_account()
	if(!account)
		to_chat(user, SPAN_WARNING("[card] has no registered account!"))
		return ITEM_INTERACT_COMPLETE

	if(!accounts_to_rob.Find(account))
		to_chat(user, SPAN_WARNING("Your funds are already safe!"))
		return ITEM_INTERACT_COMPLETE

	to_chat(user, SPAN_WARNING("You quickly cash out your funds to a more secure banking location."))
	accounts_to_rob -= account

	if(check_if_finished())
		Destroy()

	return ITEM_INTERACT_COMPLETE

/obj/structure/checkoutmachine/proc/setup_siphoning()
	overlays += "flaps"
	overlays += "hatch"
	overlays += "legs_retracted"
	update_icon(UPDATE_OVERLAYS)
	addtimer(CALLBACK(src, PROC_REF(startUp)), 5 SECONDS)
	QDEL_IN(src, 8 MINUTES) // Self-destruct after 8 min

/**
 * Starts the dumping process and plays a start-up animation before the checkout starts walking.
 */
/obj/structure/checkoutmachine/proc/startUp() // very VERY snowflake code that adds a neat animation when the pod lands.
	sleep(1 SECONDS)
	if(QDELETED(src))
		return
	playsound(src, 'sound/machines/click.ogg', 15, TRUE, -3)
	overlays -= "flaps"
	update_icon(UPDATE_OVERLAYS)
	sleep(1 SECONDS)
	if(QDELETED(src))
		return
	playsound(src, 'sound/machines/click.ogg', 15, TRUE, -3)
	overlays -= "hatch"
	update_icon(UPDATE_OVERLAYS)
	sleep(3 SECONDS)
	if(QDELETED(src))
		return
	playsound(src,'sound/machines/twobeep.ogg',50,FALSE)
	var/mutable_appearance/hologram = mutable_appearance(icon, "hologram")
	hologram.pixel_z = 16
	overlays += hologram
	var/mutable_appearance/holosign = mutable_appearance(icon, "holosign")
	holosign.pixel_z = 16
	overlays += holosign
	overlays += "legs_extending"
	overlays -= "legs_retracted"
	pixel_z += 4
	update_icon(UPDATE_OVERLAYS)
	sleep(0.5 SECONDS)
	if(QDELETED(src))
		return
	overlays += "legs_extended"
	overlays -= "legs_extending"
	pixel_z += 4
	update_icon(UPDATE_OVERLAYS)
	sleep(2 SECONDS)
	if(QDELETED(src))
		return
	overlays += "screen_lines"
	update_icon(UPDATE_OVERLAYS)
	sleep(0.5 SECONDS)
	if(QDELETED(src))
		return
	overlays -= "screen_lines"
	update_icon(UPDATE_OVERLAYS)
	sleep(0.5 SECONDS)
	if(QDELETED(src))
		return
	overlays += "screen_lines"
	overlays += "screen"
	update_icon(UPDATE_OVERLAYS)
	sleep(0.5 SECONDS)
	if(QDELETED(src))
		return
	playsound(src,'sound/machines/triple_beep.ogg', 50, FALSE)
	overlays += "text"
	update_icon(UPDATE_OVERLAYS)
	sleep(1 SECONDS)
	if(QDELETED(src))
		return
	overlays += "legs"
	overlays -= "legs_extended"
	update_icon(UPDATE_OVERLAYS)
	START_PROCESSING(SSmachines, src)
	canwalk = TRUE

/obj/structure/checkoutmachine/Destroy()
	STOP_PROCESSING(SSmachines, src)
	if(held_credits)
		expel_cash()
	explosion(src, 0, 0, 1, 2, flame_range = 2, cause = "CRAB-17 Shutdown")
	return ..()

/**
 * For each account being drained, pulls a random percentage of cash out the account and sends it to the machine.
 * Then, send a portion to the money box. If there is no money box, just hold onto the money
 * Sets a timer to call itself again after an interval.
 */
/obj/structure/checkoutmachine/proc/dump()
	var/num_accounts_to_rob = rand(1, 4)
	var/accounts = accounts_to_rob.Copy()
	// First we drain
	if(accounts)
		for(var/i in 1 to num_accounts_to_rob)
			var/credits_lost = rand(50, 100)
			var/datum/money_account/B = pick_n_take(accounts)
			if(!B)
				break
			B.set_credits(B.credit_balance - credits_lost)
			if(B.credit_balance <= 0)
				accounts_to_rob -= B
			held_credits += credits_lost
	// Then we pay
	if(moneybox && held_credits > 0)
		var/money_sent = min(held_credits, rand(50, 100))
		new /obj/item/stack/spacecash(moneybox, money_sent)
		held_credits -= money_sent
	// We robbed everyone and paid all the money. We're done.
	if(length(accounts_to_rob) == 0 && held_credits == 0)
		Destroy()

/obj/structure/checkoutmachine/process()
	dump()
	var/anydir = pick(GLOB.cardinal)
	if(Process_Spacemove(anydir))
		Move(get_step(src, anydir), anydir)

/**
 * Splits the balance of the internal_account into several smaller piles of cash and scatters them around the area.
 */
/obj/structure/checkoutmachine/proc/expel_cash()
	while(held_credits)
		var/amount_to_remove = rand(1, floor(held_credits / 8))
		var/obj/item/stack/spacecash/money = new (get_turf(src), amount_to_remove)
		held_credits -= amount_to_remove
		if(!QDELETED(money))
			money.throw_at(get_random_perimeter_turf(get_turf(src), 7), 10, 3)

/obj/effect/dumpeet_fall // Falling pod
	name = ""
	icon = 'icons/obj/machines/money_machine_64.dmi'
	pixel_z = 300
	desc = "Get out of the way!"
	layer = FLY_LAYER // that wasn't flying, that was falling with style!
	icon_state = "missile_blur"

/obj/effect/dumpeet_target
	name = "Landing Zone Indicator"
	desc = "A holographic projection designating the landing zone of something. It's probably best to stand back."
	icon = 'icons/mob/telegraphing/telegraph_holographic.dmi'
	icon_state = "target_circle"
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER
	light_range = 2
	/// The effect
	var/obj/effect/dumpeet_fall/DF
	/// The machine
	var/obj/structure/checkoutmachine/dump
	/// The user
	var/mob/living/thief
	/// The box
	var/obj/item/storage/box/money_box

/obj/effect/dumpeet_target/Initialize(mapload, user, money_box, list/accounts_to_rob)
	. = ..()
	thief = user
	dump = new /obj/structure/checkoutmachine(null, thief, money_box, accounts_to_rob)
	addtimer(CALLBACK(src, PROC_REF(startLaunch)), 10 SECONDS)
	sound_to_playing_players_on_station_level('sound/items/dump_it.ogg', 20)
	var/image/alert_overlay = image('icons/obj/machines/money_machine.dmi', "money_machine")
	notify_ghosts("Protocol CRAB-17 has been activated. A remote market has been launched at the station!", title = "CRAB-17", source = src, alert_overlay = alert_overlay, flashwindow = FALSE, action = NOTIFY_FOLLOW)

/**
 * Sets up the falling animation for the checkout machine.
 */
/obj/effect/dumpeet_target/proc/startLaunch()
	DF = new /obj/effect/dumpeet_fall(drop_location())
	dump.setup_siphoning()
	GLOB.minor_announcement.Announce("The market bubble has popped! Get to the credit deposit machine at [get_area(src)] and cash out before you lose all of your funds!", "CRAB-17 Protocol")
	animate(DF, pixel_z = -8, time = 5, , easing = LINEAR_EASING)
	playsound(src, 'sound/weapons/mortar_whistle.ogg', 70, TRUE, 6)
	addtimer(CALLBACK(src, PROC_REF(end_launch)), 5, TIMER_CLIENT_TIME) // Go onto the last step after a very short falling animation

/**
 * Cleans up after the falling animation.
 */
/obj/effect/dumpeet_target/proc/end_launch()
	QDEL_NULL(DF) // Delete the falling machine effect, because at this point its animation is over. We dont use temp_visual because we want to manually delete it as soon as the pod appears
	playsound(src, 'sound/effects/explosion1.ogg', 80, TRUE, ignore_walls = TRUE)
	dump.forceMove(get_turf(src))
	qdel(src) // The target's purpose is complete. It can rest easy now

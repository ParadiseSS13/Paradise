/obj/item/clothing/shoes/magboots
	name = "magboots"
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle."
	icon_state = "magboots0"
	inhand_icon_state = "magboots"
	origin_tech = "materials=3;magnets=4;engineering=4"
	dyeable = FALSE
	actions_types = list(/datum/action/item_action/toggle)
	strip_delay = 7 SECONDS
	put_on_delay = 7 SECONDS
	resistance_flags = FIRE_PROOF
	var/magboot_state = "magboots"
	var/magpulse = FALSE
	var/slowdown_active = 2
	var/slowdown_passive = SHOES_SLOWDOWN
	var/magpulse_name = "mag-pulse traction system"
	///If a pair of magboots has different icons for being on or off
	var/multiple_icons = TRUE

/obj/item/clothing/shoes/magboots/water_act(volume, temperature, source, method)
	. = ..()
	if(magpulse && slowdown_active > SHOES_SLOWDOWN)
		slowdown = slowdown_active

/obj/item/clothing/shoes/magboots/equipped(mob/user, slot, initial)
	. = ..()
	if(slot != ITEM_SLOT_SHOES || !ishuman(user))
		return
	check_mag_pulse(user)

/obj/item/clothing/shoes/magboots/dropped(mob/user, silent)
	. = ..()
	if(!ishuman(user))
		return
	check_mag_pulse(user, removing = TRUE)

/obj/item/clothing/shoes/magboots/attack_self__legacy__attackchain(mob/user)
	toggle_magpulse(user)

/obj/item/clothing/shoes/magboots/proc/toggle_magpulse(mob/user, no_message)
	if(magpulse) //magpulse and no_slip will always be the same value unless VV happens
		REMOVE_TRAIT(user, TRAIT_NOSLIP, UID())
		slowdown = slowdown_passive
	else
		if(user.get_item_by_slot(ITEM_SLOT_SHOES) == src)
			ADD_TRAIT(user, TRAIT_NOSLIP, UID())
		slowdown = slowdown_active
	magpulse = !magpulse
	no_slip = !no_slip
	if(multiple_icons)
		icon_state = "[magboot_state][magpulse]"
	if(!no_message)
		to_chat(user, "You [magpulse ? "enable" : "disable"] the [magpulse_name].")
	user.update_inv_shoes()	//so our mob-overlays update
	user.update_gravity(user.mob_has_gravity())
	update_action_buttons()
	check_mag_pulse(user, removing = (user.get_item_by_slot(ITEM_SLOT_SHOES) != src))

/obj/item/clothing/shoes/magboots/proc/check_mag_pulse(mob/user, removing = FALSE)
	if(!user)
		return
	if(magpulse && !removing)
		ADD_TRAIT(user, TRAIT_MAGPULSE, "magboots[UID()]")
		return
	if(HAS_TRAIT(user, TRAIT_MAGPULSE)) // User has trait and the magboots were turned off, remove trait
		REMOVE_TRAIT(user, TRAIT_MAGPULSE, "magboots[UID()]")

/obj/item/clothing/shoes/magboots/examine(mob/user)
	. = ..()
	. += "Its [magpulse_name] appears to be [magpulse ? "enabled" : "disabled"]."

/obj/item/clothing/shoes/magboots/atmos
	name = "atmospheric magboots"
	desc = "Magnetic boots, made to withstand gusts of space wind over 500k mph."
	icon_state = "atmosmagboots0"
	magboot_state = "atmosmagboots"

/obj/item/clothing/shoes/magboots/advance
	name = "advanced magboots"
	desc = "Experimental magnetic boots. They automatically activate and deactivate their magnetic pull as the user walks."
	icon_state = "advmag0"
	magboot_state = "advmag"
	slowdown_active = SHOES_SLOWDOWN
	origin_tech = null
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/clothing/shoes/magboots/advance/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[src] will not slow you down when active.</span>"

/obj/item/clothing/shoes/magboots/advance/examine_more(mob/user)
	. = ..()
	. += "Nanotrasen's advanced magboots are an experimental development on commercially available designs. Using a combination of haptic feedback sensors and predictive algorithms, \
	the electromagnets in the boots deactivate themselves when they detect the user trying to lift their feet up, whilst also remaining active if unexpected forces act upon the user. \
	The predictive action occurs in less than 60 milliseconds, making it appear instant from the perspective of the user."
	. += ""
	. += "The rapid activation/deactivation action of the magboots allows users to sprint, jump, or perform any other actions they wish as if the boots were not there, \
	whilst still providing unrivalled traction and grip both in zero-G and full gravity."

/obj/item/clothing/shoes/magboots/advance/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/high_value_item)

/obj/item/clothing/shoes/magboots/syndie
	name = "blood-red magboots"
	desc = "Reverse-engineered magnetic boots. Property of Gorlex Marauders."
	icon_state = "syndiemag0"
	magboot_state = "syndiemag"
	origin_tech = "magnets=4;syndicate=2"

/// For the Syndicate Strike Team/SolGov/Tactical Teams
/obj/item/clothing/shoes/magboots/elite
	name = "elite tactical magboots"
	desc = "Advanced magboots used by strike teams across the system. Allows for tactical insertion into low-gravity areas of operation."
	icon_state = "elitemag0"
	magboot_state = "elitemag"
	origin_tech = null
	slowdown_active = SHOES_SLOWDOWN
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/clothing/shoes/magboots/elite/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[src] will not slow you down when active.</span>"

/obj/item/clothing/shoes/magboots/clown
	name = "clown shoes"
	desc = "The prankster's standard-issue clowning shoes. Damn they're huge! There's a red light on the side."
	icon_state = "clownmag0"
	magboot_state = "clownmag"
	inhand_icon_state = "clown_shoes"
	slowdown = SHOES_SLOWDOWN+1
	slowdown_active = SHOES_SLOWDOWN+1
	slowdown_passive = SHOES_SLOWDOWN+1
	magpulse_name = "honk-powered traction system"
	origin_tech = "magnets=4;syndicate=2"
	var/enabled_waddle = TRUE

/obj/item/clothing/shoes/magboots/clown/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/effects/clownstep1.ogg' = 1, 'sound/effects/clownstep2.ogg' = 1), 50, falloff_exponent = 20) //die off quick please

/obj/item/clothing/shoes/magboots/clown/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_SHOES && enabled_waddle)
		user.AddElement(/datum/element/waddling)

/obj/item/clothing/shoes/magboots/clown/dropped(mob/user)
	. = ..()
	user.RemoveElement(/datum/element/waddling)

/obj/item/clothing/shoes/magboots/clown/CtrlClick(mob/living/user)
	if(!isliving(user))
		return
	if(user.get_active_hand() != src)
		to_chat(user, "You must hold [src] in your hand to do this.")
		return
	if(!enabled_waddle)
		to_chat(user, "<span class='notice'>You switch off the waddle dampeners!</span>")
		enabled_waddle = TRUE
	else
		to_chat(user, "<span class='notice'>You switch on the waddle dampeners!</span>")
		enabled_waddle = FALSE

/// bundled with the wiz hardsuit
/obj/item/clothing/shoes/magboots/wizard
	name = "boots of gripping"
	desc = "These magical boots, once activated, will stay gripped to any surface without slowing you down."
	icon_state = "wizmag0"
	magboot_state = "wizmag"
	slowdown_active = SHOES_SLOWDOWN //wiz hardsuit already slows you down, no need to double it
	magpulse_name = "gripping ability"
	magical = TRUE

/obj/item/clothing/shoes/magboots/wizard/toggle_magpulse(mob/user, no_message)
	if(!user)
		return
	if(!iswizard(user))
		to_chat(user, "<span class='notice'>You poke the gem on [src]. Nothing happens.</span>")
		return
	..()
	if(magpulse) //faint blue light when shoes are turned on gives a reason to turn them off when not needed in maint
		set_light(2, 1, LIGHT_COLOR_LIGHTBLUE)
	else
		set_light(0)


/obj/item/clothing/shoes/magboots/gravity
	name = "gravitational boots"
	desc = "These experimental boots try to get around the restrictions of magboots by installing miniature gravitational generators in the soles. Sadly, power hungry, and needs a gravitational anomaly core."
	icon_state = "gravboots0"
	origin_tech = "materials=6;magnets=6;engineering=6"
	actions_types = list(/datum/action/item_action/toggle, /datum/action/item_action/gravity_jump) //In other news, combining magboots with jumpboots is a mess
	strip_delay = 10 SECONDS
	put_on_delay = 10 SECONDS
	slowdown_active = SHOES_SLOWDOWN
	magboot_state = "gravboots"
	magpulse_name = "micro gravitational traction system"
	var/datum/martial_art/grav_stomp/style //Only works with core and cell installed.
	var/jumpdistance = 5
	var/jumpspeed = 3
	var/recharging_rate = 6 SECONDS
	var/recharging_time = 0 // Time until next dash
	var/dash_cost = 1000 // Cost to dash.
	var/power_consumption_rate = 30 // How much power is used by the boots each cycle when magboots are active
	var/obj/item/assembly/signaler/anomaly/grav/core = null
	var/obj/item/stock_parts/cell/cell = null

/obj/item/clothing/shoes/magboots/gravity/Initialize(mapload)
	. = ..()
	style = new()

/obj/item/clothing/shoes/magboots/gravity/Destroy()
	QDEL_NULL(style)
	QDEL_NULL(cell)
	QDEL_NULL(core)
	return ..()

/obj/item/clothing/shoes/magboots/gravity/examine(mob/user)
	. = ..()
	if(core && cell)
		. += "<span class='notice'>[src] are fully operational!</span>"
		. += "<span class='notice'>The boots are [round(cell.percent())]% charged.</span>"
	else if(core)
		. += "<span class='warning'>It has a gravitational anomaly core installed, but no power cell installed.</span>"
	else if(cell)
		. += "<span class='warning'>It has a power installed, but no gravitational anomaly core installed.</span>"
	else
		. += "<span class='warning'>It is missing a gravitational anomaly core and a power cell.</span>"

/obj/item/clothing/shoes/magboots/gravity/toggle_magpulse(mob/user, no_message)
	if(!cell)
		to_chat(user, "<span class='warning'>Your boots do not have a power cell!</span>")
		return
	else if(cell.charge <= power_consumption_rate && !magpulse)
		to_chat(user, "<span class='warning'>Your boots do not have enough charge!</span>")
		return
	if(!core)
		to_chat(user, "<span class='warning'>There's no core installed!</span>")
		return

	..()

/obj/item/clothing/shoes/magboots/gravity/process()
	if(!cell) //There should be a cell here, but safety first
		return
	if(cell.charge <= power_consumption_rate * 2)
		if(ishuman(loc))
			var/mob/living/carbon/human/user = loc
			to_chat(user, "<span class='warning'>[src] has ran out of charge, and turned off!</span>")
			toggle_magpulse(user, TRUE)
	else
		cell.use(power_consumption_rate)

/obj/item/clothing/shoes/magboots/gravity/screwdriver_act(mob/living/user, obj/item/I)
	if(!cell)
		to_chat(user, "<span class='warning'>There's no cell installed!</span>")
		return

	if(magpulse)
		to_chat(user, "<span class='warning'>Turn off the boots first!</span>")
		return

	if(!I.use_tool(src, user, volume = I.tool_volume))
		return

	user.put_in_hands(cell)
	to_chat(user, "<span class='notice'>You remove [cell] from [src].</span>")
	cell.update_icon()
	cell = null
	update_icon()

/obj/item/clothing/shoes/magboots/gravity/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stock_parts/cell))
		if(cell)
			to_chat(user, "<span class='warning'>[src] already has a cell!</span>")
			return
		if(!user.drop_item_to_ground(I))
			return
		I.forceMove(src)
		cell = I
		to_chat(user, "<span class='notice'>You install [I] into [src].</span>")
		update_icon()
		return

	if(istype(I, /obj/item/assembly/signaler/anomaly/grav))
		if(core)
			to_chat(user, "<span class='notice'>[src] already has a [I]!</span>")
			return
		if(!user.drop_item())
			to_chat(user, "<span class='warning'>[I] is stuck to your hand!</span>")
			return
		to_chat(user, "<span class='notice'>You insert [I] into [src], and [src] starts to warm up.</span>")
		I.forceMove(src)
		core = I
	else
		return ..()

/obj/item/clothing/shoes/magboots/gravity/equipped(mob/user, slot)
	..()
	if(!ishuman(user))
		return
	if(slot == ITEM_SLOT_SHOES && cell && core)
		style.teach(user, TRUE)

/obj/item/clothing/shoes/magboots/gravity/dropped(mob/user)
	..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(ITEM_SLOT_SHOES) == src)
		style.remove(H)
		if(magpulse)
			to_chat(user, "<span class='notice'>As [src] are removed, they deactivate.</span>")
			toggle_magpulse(user, TRUE)

/obj/item/clothing/shoes/magboots/gravity/item_action_slot_check(slot)
	if(slot == ITEM_SLOT_SHOES)
		return TRUE

/obj/item/clothing/shoes/magboots/gravity/proc/dash(mob/user, action)
	if(!isliving(user))
		return

	if(cell)
		if(cell.charge <= dash_cost)
			to_chat(user, "<span class='warning'>Your boots do not have enough charge to dash!</span>")
			return
	else
		to_chat(user, "<span class='warning'>Your boots do not have a power cell!</span>")
		return

	if(!core)
		to_chat(user, "<span class='warning'>There's no core installed!</span>")
		return

	if(recharging_time > world.time)
		to_chat(user, "<span class='warning'>The boot's gravitational pulse needs to recharge still!</span>")
		return

	var/atom/target = get_edge_target_turf(user, user.dir) //gets the user's direction
	ADD_TRAIT(user, TRAIT_FLYING, "gravity_boots")
	if(user.throw_at(target, jumpdistance, jumpspeed, spin = FALSE, diagonals_first = TRUE, callback = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(callback_remove_trait), user, TRAIT_FLYING, "gravity_boots")))
		playsound(src, 'sound/effects/stealthoff.ogg', 50, TRUE, 1)
		user.visible_message("<span class='warning'>[usr] dashes forward into the air!</span>")
		recharging_time = world.time + recharging_rate
		cell.use(dash_cost)
	else
		REMOVE_TRAIT(user, TRAIT_FLYING, "gravity_boots")
		to_chat(user, "<span class='warning'>Something prevents you from dashing forward!</span>")

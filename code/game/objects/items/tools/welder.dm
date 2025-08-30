#define GET_FUEL reagents.get_reagent_amount("fuel")

/obj/item/weldingtool
	name = "welding tool"
	desc = "A basic, handheld welding tool. Useful for welding bits together, and cutting them apart."
	icon = 'icons/obj/tools.dmi'
	icon_state = "welder"
	inhand_icon_state = "welder"
	belt_icon = "welder"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	force = 3
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	hitsound = "swing_hit"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 100, ACID = 30)
	resistance_flags = FIRE_PROOF
	materials = list(MAT_METAL = 400, MAT_GLASS = 100)
	origin_tech = "engineering=1;plasmatech=1"
	tool_behaviour = TOOL_WELDER
	tool_enabled = FALSE
	usesound = 'sound/items/welder.ogg'
	drop_sound = 'sound/items/handling/weldingtool_drop.ogg'
	pickup_sound =  'sound/items/handling/weldingtool_pickup.ogg'
	var/maximum_fuel = 20
	/// Set to FALSE if it doesn't need fuel, but serves equally well as a cost modifier.
	var/requires_fuel = TRUE
	/// If TRUE, fuel will regenerate over time.
	var/refills_over_time = FALSE
	/// Sound played when turned on.
	var/activation_sound = 'sound/items/welderactivate.ogg'
	/// Sound played when turned off.
	var/deactivation_sound = 'sound/items/welderdeactivate.ogg'
	/// The brightness of the active flame.
	var/light_intensity = 2
	/// Does the icon_state change if the fuel is low?
	var/low_fuel_changes_icon = TRUE
	/// How often does the tool flash the user's eyes?
	var/progress_flash_divisor = 1 SECONDS
	/// If FALSE, welding tools wont appear prefilled by default
	var/prefilled = TRUE

/obj/item/weldingtool/Initialize(mapload)
	. = ..()
	create_reagents(maximum_fuel)
	if(prefilled)
		reagents.add_reagent("fuel", maximum_fuel)
	update_icon()
	RegisterSignal(src, COMSIG_BIT_ATTACH, PROC_REF(add_bit))
	RegisterSignal(src, COMSIG_CLICK_ALT, PROC_REF(remove_bit))

/obj/item/weldingtool/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/weldingtool/examine(mob/user)
	. = ..()
	if(get_dist(user, src) <= 0)
		. += "It contains [GET_FUEL] unit\s of fuel out of [maximum_fuel]."

/obj/item/weldingtool/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] welds [user.p_their()] every orifice closed! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return FIRELOSS

/obj/item/weldingtool/can_enter_storage(obj/item/storage/S, mob/user)
	if(tool_enabled)
		to_chat(user, "<span class='warning'>[S] can't hold [src] while it's lit!</span>")
		return FALSE
	else
		return TRUE

/obj/item/weldingtool/process()
	if(tool_enabled)
		var/turf/T = get_turf(src)
		if(T) // Implants for instance won't find a turf
			T.hotspot_expose(2500, 1)
		if(prob(5))
			remove_fuel(1)
	if(refills_over_time)
		if(GET_FUEL < maximum_fuel)
			reagents.add_reagent("fuel", 1)
	..()

/obj/item/weldingtool/extinguish_light(force)
	if(!force)
		return
	if(!tool_enabled)
		return
	remove_fuel(maximum_fuel)

/obj/item/weldingtool/attack_self__legacy__attackchain(mob/user)
	if(tool_enabled) //Turn off the welder if it's on
		to_chat(user, "<span class='notice'>You switch off [src].</span>")
		toggle_welder()
		return
	else if(GET_FUEL) //The welder is off, but we need to check if there is fuel in the tank
		to_chat(user, "<span class='notice'>You switch on [src].</span>")
		toggle_welder()
	else //The welder is off and unfuelled
		to_chat(user, "<span class='notice'>[src] is out of fuel!</span>")

/obj/item/weldingtool/proc/toggle_welder(turn_off = FALSE) //Turn it on or off, forces it to deactivate
	tool_enabled = turn_off ? FALSE : !tool_enabled
	if(tool_enabled)
		START_PROCESSING(SSobj, src)
		damtype = BURN
		force = 15
		hitsound = 'sound/items/welder.ogg'
		playsound(loc, activation_sound, 50, 1)
		set_light(light_intensity)
	else
		if(!refills_over_time)
			STOP_PROCESSING(SSobj, src)
		damtype = BRUTE
		force = 3
		hitsound = "swing_hit"
		playsound(loc, deactivation_sound, 50, 1)
		set_light(0)
	update_icon()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_r_hand()
		M.update_inv_l_hand()

// If welding tool ran out of fuel during a construction task, construction fails.
/obj/item/weldingtool/tool_use_check(mob/living/user, amount, silent = FALSE)
	if(!tool_enabled)
		if(!silent)
			to_chat(user, "<span class='notice'>[src] has to be on to complete this task!</span>")
		return FALSE
	if(GET_FUEL >= amount * requires_fuel)
		return TRUE
	else
		if(!silent)
			to_chat(user, "<span class='warning'>You need more welding fuel to complete this task!</span>")
		return FALSE

// When welding is about to start, run a normal tool_use_check, then flash a mob if it succeeds.
/obj/item/weldingtool/tool_start_check(atom/target, mob/living/user, amount=0)
	. = tool_use_check(user, amount)
	if(. && user && !ismob(target)) // Don't flash the user if they're repairing robo limbs or repairing a borg etc. Only flash them if the target is an object
		user.flash_eyes(light_intensity)

/obj/item/weldingtool/use(amount)
	amount = amount * bit_efficiency_mod
	if(GET_FUEL < amount * requires_fuel)
		return
	remove_fuel(amount)
	return TRUE

/obj/item/weldingtool/afterattack__legacy__attackchain(atom/target, mob/user, proximity, params)
	. = ..()
	if(!tool_enabled)
		return
	if(!proximity || isturf(target)) // We don't want to take away fuel when we hit something far away
		return
	remove_fuel(0.5)

/obj/item/weldingtool/attack__legacy__attackchain(mob/living/target, mob/living/user, def_zone)
	if(cigarette_lighter_act(user, target))
		return
	if(tool_enabled && target.IgniteMob())
		message_admins("[key_name_admin(user)] set [key_name_admin(target)] on fire")
		log_game("[key_name(user)] set [key_name(target)] on fire")
	return ..()

/obj/item/weldingtool/cigarette_lighter_act(mob/living/user, mob/living/target, obj/item/direct_attackby_item)
	var/obj/item/clothing/mask/cigarette/cig = ..()
	if(!cig)
		return !isnull(cig)

	if(!tool_enabled)
		to_chat(user, "<span class='warning'>You need to activate [src] before you can light anything with it!</span>")
		return TRUE

	if(target == user)
		user.visible_message(
			"<span class='notice'>[user] casually lights [cig] with [src], what a badass.</span>",
			"<span class='notice'>You light [cig] with [src].</span>"
		)
	else
		user.visible_message(
			"<span class='notice'>[user] holds out [src] out for [target], and casually lights [cig]. What a badass.</span>",
			"<span class='notice'>You light [cig] for [target] with [src].</span>"
		)
	cig.light(user, target)
	return TRUE

/obj/item/weldingtool/use_tool(atom/target, user, delay, amount, volume, datum/callback/extra_checks)
	target.add_overlay(GLOB.welding_sparks)
	var/did_thing = ..()
	if(did_thing)
		remove_fuel(1) //Consume some fuel after we do a welding action
	if(delay)
		progress_flash_divisor = initial(progress_flash_divisor)
	target.cut_overlay(GLOB.welding_sparks)
	return did_thing

/obj/item/weldingtool/tool_check_callback(mob/living/user, amount, datum/callback/extra_checks)
	. = ..()
	if(!. && user)
		if(progress_flash_divisor == 0)
			user.flash_eyes(min(light_intensity, 1))
			progress_flash_divisor = initial(progress_flash_divisor)
		else
			progress_flash_divisor--

/obj/item/weldingtool/proc/remove_fuel(amount) //NB: doesn't check if we have enough fuel, it just removes however much is left if there's not enough
	reagents.remove_reagent("fuel", amount * requires_fuel)
	if(!GET_FUEL)
		toggle_welder(TRUE)

/obj/item/weldingtool/refill(mob/user, atom/A, amount)
	if(!A.reagents)
		return
	if(GET_FUEL >= maximum_fuel)
		to_chat(user, "<span class='notice'>[src] is already full!</span>")
		return
	var/amount_transferred = A.reagents.trans_id_to(src, "fuel", amount)
	if(amount_transferred)
		to_chat(user, "<span class='notice'>You refuel [src] by [amount_transferred] unit\s.</span>")
		playsound(src, 'sound/effects/refill.ogg', 50, 1)
		update_icon()
		return amount_transferred
	else
		to_chat(user, "<span class='warning'>There's not enough fuel in [A] to refuel [src]!</span>")

/obj/item/weldingtool/update_icon_state()
	if(low_fuel_changes_icon)
		var/ratio = GET_FUEL / maximum_fuel
		ratio = CEILING(ratio*4, 1) * 25
		if(ratio == 100)
			icon_state = initial(icon_state)
		else
			icon_state = "[initial(icon_state)][ratio]"
	inhand_icon_state = "[initial(inhand_icon_state)][tool_enabled || ""]"

/obj/item/weldingtool/update_overlays()
	. = ..()
	if(tool_enabled)
		. += "[initial(icon_state)]-on"

/obj/item/weldingtool/cyborg_recharge(coeff, emagged)
	if(reagents.check_and_add("fuel", maximum_fuel, 2 * coeff))
		update_icon()

/obj/item/weldingtool/get_heat()
	return tool_enabled * 2500

/obj/item/weldingtool/empty
	prefilled = FALSE

/obj/item/weldingtool/largetank
	name = "industrial welding tool"
	desc = "A heavier welding tool with an expanded fuel reservoir. Otherwise identical to a normal welder."
	icon_state = "indwelder"
	belt_icon = "welder_ind"
	maximum_fuel = 40
	materials = list(MAT_METAL = 400, MAT_GLASS = 300)
	origin_tech = "engineering=2;plasmatech=2"

/obj/item/weldingtool/largetank/empty
	prefilled = FALSE

/obj/item/weldingtool/largetank/cyborg
	name = "integrated welding tool"
	desc = "An integrated industrial welding tool used by construction and engineering robots. "
	toolspeed = 0.5

/obj/item/weldingtool/research
	name = "research welding tool"
	desc = "A scratched-up welding tool that's been the subject of numerous aftermarket enhancements. It has a larger fuel tank, and a more focused torch than a standard welder. A label on the side reads, \"Property of Theseus\"."
	icon_state = "welder_research"
	inhand_icon_state = "welder_research"
	belt_icon = "welder_research"
	maximum_fuel = 40
	toolspeed = 0.75
	light_intensity = 1

/obj/item/weldingtool/research/suicide_act(mob/living/user)

	if(!user)
		return

	user.visible_message("<span class='suicide'>[user] is tinkering with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")

	to_chat(user, "<span class='notice'>You begin tinkering with [src]...")
	user.Immobilize(10 SECONDS)
	sleep(2 SECONDS)
	add_fingerprint(user)

	user.visible_message("<span class='danger'>[src] blows up in [user]'s face!</span>", "<span class='userdanger'>Oh, shit!</span>")
	playsound(loc, "sound/effects/explosion1.ogg", 50, TRUE, -1)
	user.gib()

	return OBLITERATION

/obj/item/weldingtool/mini
	name = "emergency welding tool"
	desc = "A small, stripped down welding tool for emergency use only."
	icon_state = "miniwelder"
	maximum_fuel = 10
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL = 200, MAT_GLASS = 50)
	low_fuel_changes_icon = FALSE

/obj/item/weldingtool/mini/empty
	prefilled = FALSE

/obj/item/weldingtool/hugetank
	name = "upgraded welding tool"
	desc = "A large industrial welding tool with an even further upgraded fuel reservoir."
	icon_state = "upindwelder"
	inhand_icon_state = "upindwelder"
	belt_icon = "welder_upg"
	maximum_fuel = 80
	materials = list(MAT_METAL=70, MAT_GLASS=120)
	origin_tech = "engineering=3;plasmatech=2"

/obj/item/weldingtool/hugetank/empty
	prefilled = FALSE

/obj/item/weldingtool/experimental
	name = "experimental welding tool"
	desc = "A prototype welding tool which uses an experimental fuel breeder to create a near-infinite reserve of fuel. The unusual fuel mixture also means that the flame is less intense on the eyes."
	icon_state = "exwelder"
	inhand_icon_state = "exwelder"
	belt_icon = "welder_exp"
	maximum_fuel = 40
	materials = list(MAT_METAL=70, MAT_GLASS=120)
	origin_tech = "materials=4;engineering=4;bluespace=3;plasmatech=4"
	light_intensity = 1
	toolspeed = 0.5
	refills_over_time = TRUE
	low_fuel_changes_icon = FALSE

/obj/item/weldingtool/experimental/brass
	name = "brass welding tool"
	desc = "A brass welder that seems to constantly refuel itself. It is faintly warm to the touch."
	icon_state = "brasswelder"
	inhand_icon_state = "brasswelder"
	belt_icon = "welder_brass"
	resistance_flags = FIRE_PROOF | ACID_PROOF

#undef GET_FUEL

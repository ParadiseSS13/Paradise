#define GET_FUEL reagents.get_reagent_amount("fuel")

/obj/item/weldingtool
	name = "welding tool"
	desc = "A standard edition welder provided by Nanotrasen."
	icon = 'icons/obj/tools.dmi'
	icon_state = "welder"
	item_state = "welder"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 3
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	hitsound = "swing_hit"
	w_class = WEIGHT_CLASS_SMALL
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 30)
	resistance_flags = FIRE_PROOF
	materials = list(MAT_METAL=70, MAT_GLASS=30)
	origin_tech = "engineering=1;plasmatech=1"
	tool_behaviour = TOOL_WELDER
	toolspeed = 1
	tool_enabled = FALSE
	usesound = 'sound/items/welder.ogg'
	var/maximum_fuel = 20
	var/requires_fuel = TRUE //Set to FALSE if it doesn't need fuel, but serves equally well as a cost modifier
	var/refills_over_time = FALSE //Do we regenerate fuel?
	var/activation_sound = 'sound/items/welderactivate.ogg'
	var/deactivation_sound = 'sound/items/welderdeactivate.ogg'
	var/light_intensity = 2
	var/low_fuel_changes_icon = TRUE//More than one icon_state due to low fuel?
	var/progress_flash_divisor = 10 //Length of time between each "eye flash"

/obj/item/weldingtool/Initialize(mapload)
	..()
	create_reagents(maximum_fuel)
	reagents.add_reagent("fuel", maximum_fuel)
	if(refills_over_time)
		reagents.reagents_generated_per_cycle += list("fuel" = 1)
	update_icon()

/obj/item/weldingtool/examine(mob/user)
	. = ..()
	if(get_dist(user, src) <= 0)
		. += "It contains [GET_FUEL] unit\s of fuel out of [maximum_fuel]."

/obj/item/weldingtool/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] welds [user.p_their()] every orifice closed! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return FIRELOSS

/obj/item/weldingtool/process()
	var/turf/T = get_turf(src)
	T.hotspot_expose(2500, 5)
	if(prob(5))
		remove_fuel(1)
	..()

/obj/item/weldingtool/attack_self(mob/user)
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
/obj/item/weldingtool/tool_use_check(mob/living/user, amount)
	if(!tool_enabled)
		to_chat(user, "<span class='notice'>[src] has to be on to complete this task!</span>")
		return FALSE
	if(GET_FUEL >= amount * requires_fuel)
		return TRUE
	else
		to_chat(user, "<span class='warning'>You need more welding fuel to complete this task!</span>")
		return FALSE

// When welding is about to start, run a normal tool_use_check, then flash a mob if it succeeds.
/obj/item/weldingtool/tool_start_check(mob/living/user, amount=0)
	. = tool_use_check(user, amount)
	if(. && user)
		user.flash_eyes(light_intensity)

/obj/item/weldingtool/use(amount)
	if(GET_FUEL < amount * requires_fuel)
		return
	remove_fuel(amount)
	return TRUE

/obj/item/weldingtool/use_tool(target, user, delay, amount, volume, datum/callback/extra_checks)
	var/did_thing = ..()
	if(did_thing)
		remove_fuel(1) //Consume some fuel after we do a welding action
	if(delay)
		progress_flash_divisor = initial(progress_flash_divisor)
	return did_thing

/obj/item/weldingtool/tool_check_callback(mob/living/user, amount, datum/callback/extra_checks)
	. = ..()
	if(. && user)
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

/obj/item/weldingtool/proc/update_torch()
	overlays.Cut()
	if(tool_enabled)
		overlays += "[initial(icon_state)]-on"
		item_state = "[initial(item_state)]1"
	else
		item_state = "[initial(item_state)]"

/obj/item/weldingtool/update_icon()
	if(low_fuel_changes_icon)
		var/ratio = GET_FUEL / maximum_fuel
		ratio = Ceiling(ratio*4) * 25
		if(ratio == 100)
			icon_state = initial(icon_state)
		else
			icon_state = "[initial(icon_state)][ratio]"
	update_torch()
	..()


/obj/item/weldingtool/largetank
	name = "industrial welding tool"
	desc = "A slightly larger welder with a larger tank."
	icon_state = "indwelder"
	maximum_fuel = 40
	materials = list(MAT_METAL=70, MAT_GLASS=60)
	origin_tech = "engineering=2;plasmatech=2"

/obj/item/weldingtool/largetank/cyborg
	name = "integrated welding tool"
	desc = "An advanced welder designed to be used in robotic systems."
	toolspeed = 0.5

/obj/item/weldingtool/mini
	name = "emergency welding tool"
	desc = "A miniature welder used during emergencies."
	icon_state = "miniwelder"
	maximum_fuel = 10
	w_class = WEIGHT_CLASS_TINY
	materials = list(MAT_METAL=30, MAT_GLASS=10)
	low_fuel_changes_icon = FALSE

/obj/item/weldingtool/abductor
	name = "alien welding tool"
	desc = "An alien welding tool. Whatever fuel it uses, it never runs out."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "welder"
	toolspeed = 0.1
	light_intensity = 0
	origin_tech = "plasmatech=5;engineering=5;abductor=3"
	requires_fuel = FALSE
	refills_over_time = TRUE
	low_fuel_changes_icon = FALSE

/obj/item/weldingtool/hugetank
	name = "upgraded welding tool"
	desc = "An upgraded welder based off the industrial welder."
	icon_state = "upindwelder"
	item_state = "upindwelder"
	maximum_fuel = 80
	materials = list(MAT_METAL=70, MAT_GLASS=120)
	origin_tech = "engineering=3;plasmatech=2"

/obj/item/weldingtool/experimental
	name = "experimental welding tool"
	desc = "An experimental welder capable of self-fuel generation and less harmful to the eyes."
	icon_state = "exwelder"
	item_state = "exwelder"
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
	item_state = "brasswelder"
	resistance_flags = FIRE_PROOF | ACID_PROOF

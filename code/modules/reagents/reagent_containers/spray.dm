/obj/item/reagent_containers/spray
	name = "spray bottle"
	desc = "A spray bottle, with an unscrewable top."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "cleaner"
	belt_icon = "space_cleaner"
	flags = NOBLUDGEON
	container_type = OPENCONTAINER
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	// TRUE if spray amount and range can be toggled via `attack_self()`.
	var/adjustable = TRUE
	var/adjust_action = "turn the nozzle"
	//sprayer alternates between assigning this and `spray_minrange` to `spray_currentrange` via `attack_self()`.
	var/spray_maxrange = 2
	//the range of tiles the sprayer will reach when in fixed mode.
	var/spray_currentrange = 2
	var/spray_minrange = 1
	volume = 250
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = null
	var/delay = CLICK_CD_RANGE * 2

/obj/item/reagent_containers/spray/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_CAN_POINT_WITH, ROUNDSTART_TRAIT)

/obj/item/reagent_containers/spray/ranged_interact_with_atom(atom/target, mob/living/user, list/modifiers)
	return interact_with_atom(target, user, modifiers)

/obj/item/reagent_containers/spray/normal_act(atom/A, mob/living/user)
	. = TRUE
	if(isstorage(A) || ismodcontrol(A) || istype(A, /obj/structure/table) || istype(A, /obj/structure/rack) || istype(A, /obj/structure/closet) \
	|| istype(A, /obj/item/reagent_containers) || istype(A, /obj/structure/sink) || istype(A, /obj/structure/janitorialcart) || istype(A, /obj/machinery/hydroponics))
		return FALSE

	if(loc != user)
		return

	if(istype(A, /obj/structure/reagent_dispensers) && get_dist(src,A) <= 1) //this block copypasted from reagent_containers/glass, for lack of a better solution
		if(!A.reagents.total_volume && A.reagents)
			to_chat(user, "<span class='notice'>[A] is empty.</span>")
			return

		if(reagents.total_volume >= reagents.maximum_volume)
			to_chat(user, "<span class='notice'>[src] is full.</span>")
			return

		if(!is_open_container())
			to_chat(user, "<span class='notice'>[src] cannot be refilled.</span>")
			return

		var/trans = A.reagents.trans_to(src, 50) //This is a static amount, otherwise, it'll take forever to fill.
		to_chat(user, "<span class='notice'>You fill [src] with [trans] units of the contents of [A].</span>")
		return

	if(reagents.total_volume < amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>[src] is empty!</span>")
		return

	var/contents_log = reagents.reagent_list.Join(", ")
	INVOKE_ASYNC(src, PROC_REF(spray), A)

	playsound(loc, 'sound/effects/spray2.ogg', 50, TRUE, -6)
	user.changeNext_move(delay)
	user.newtonian_move(get_dir(A, user))

	var/attack_log_type = ATKLOG_ALMOSTALL

	if(reagents.chem_temp > 300 || reagents.chem_temp < 280)	//harmful temperature
		attack_log_type = ATKLOG_MOST

	if(length(reagents.reagent_list) == 1 && reagents.has_reagent("cleaner")) // Only create space cleaner logs if it's burning people from being too hot or cold
		if(attack_log_type == ATKLOG_ALMOSTALL)
			return

	//commonly used for griefing or just very annoying and dangerous
	if(reagents.has_reagent("sacid") || reagents.has_reagent("facid") || reagents.has_reagent("lube"))
		attack_log_type = ATKLOG_FEW

	add_attack_logs(user, A, "Used a spray bottle. Contents: [contents_log] - Temperature: [reagents.chem_temp]K", attack_log_type)
	return


/obj/item/reagent_containers/spray/proc/spray(atom/A)
	var/spray_divisor = 1 / clamp(round(get_dist_euclidian(get_turf(A), get_turf(src))), 1, spray_currentrange)
	var/obj/effect/decal/chempuff/chem_puff = new /obj/effect/decal/chempuff(get_turf(src))
	chem_puff.create_reagents(amount_per_transfer_from_this)
	reagents.trans_to(chem_puff, amount_per_transfer_from_this, spray_divisor)
	chem_puff.icon += mix_color_from_reagents(chem_puff.reagents.reagent_list)

	var/datum/move_loop/our_loop = GLOB.move_manager.move_towards_legacy(chem_puff, A, 3 DECISECONDS, timeout = spray_currentrange * 3 DECISECONDS, flags = MOVEMENT_LOOP_START_FAST, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
	chem_puff.RegisterSignal(our_loop, COMSIG_PARENT_QDELETING, TYPE_PROC_REF(/obj/effect/decal/chempuff, loop_ended))
	chem_puff.RegisterSignal(our_loop, COMSIG_MOVELOOP_POSTPROCESS, TYPE_PROC_REF(/obj/effect/decal/chempuff, check_move))

/obj/item/reagent_containers/spray/activate_self(mob/user)
	if(..())
		return FINISH_ATTACK
	if(!adjustable)
		return FINISH_ATTACK
	amount_per_transfer_from_this = (amount_per_transfer_from_this == 10 ? 5 : 10)
	spray_currentrange = (amount_per_transfer_from_this == 10 ? spray_maxrange : spray_minrange)
	to_chat(user, "<span class='notice'>You [adjust_action]. You'll now use [amount_per_transfer_from_this] units per spray.</span>")

/obj/item/reagent_containers/spray/examine(mob/user)
	. = ..()
	if(get_dist(user, src) && user == loc)
		. += "[round(reagents.total_volume)] units left."
	. += "<span class='notice'><b>Alt-Shift-Click</b> to empty it.</span>"

/obj/item/reagent_containers/spray/AltShiftClick(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return
	if(tgui_alert(user, "Are you sure you want to empty that?", "Empty Bottle", list("Yes", "No")) != "Yes")
		return
	if(isturf(user.loc) && loc == user)
		to_chat(user, "<span class='notice'>You empty [src] onto the floor.</span>")
		reagents.reaction(user.loc)
		reagents.clear_reagents()

/obj/item/reagent_containers/spray/empty
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'

//space cleaner
/obj/item/reagent_containers/spray/cleaner
	name = "space cleaner"
	desc = "Your standard spritz cleaner bottle designed to keep ALL of your workplaces spotless."
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	list_reagents = list("cleaner" = 250)

/obj/item/reagent_containers/spray/cleaner/advanced
	name = "advanced space cleaner"
	desc = "BLAM!-brand non-foaming space cleaner!"
	icon_state = "adv_cleaner"
	volume = 500
	spray_maxrange = 3
	spray_currentrange = 3
	list_reagents = list("cleaner" = 500)

/obj/item/reagent_containers/spray/cleaner/safety
	desc = "BLAM!-brand non-foaming space cleaner! This spray bottle can only accept space cleaner."

/obj/item/reagent_containers/spray/cleaner/safety/on_reagent_change()
	for(var/filth in reagents.reagent_list)
		var/datum/reagent/R = filth
		if(R.id != "cleaner") //all chems other than space cleaner are filthy.
			reagents.del_reagent(R.id)
			if(ismob(loc))
				to_chat(loc, "<span class='warning'>[src] identifies and removes a filthy substance.</span>")
			else
				visible_message("<span class='warning'>[src] identifies and removes a filthy substance.</span>")

/obj/item/reagent_containers/spray/cleaner/drone
	desc = "BLAM!-brand non-foaming space cleaner!"
	spray_maxrange = 3
	spray_currentrange = 3
	adjustable = FALSE
	amount_per_transfer_from_this = 5
	volume = 50
	list_reagents = list("cleaner" = 50)

/obj/item/reagent_containers/spray/cleaner/drone/cyborg_recharge(coeff, emagged)
	reagents.check_and_add("cleaner", volume, 3 * coeff)

/obj/item/reagent_containers/spray/cyborg_lube
	name = "lube spray"
	spray_maxrange = 3
	spray_currentrange = 3
	adjustable = FALSE
	list_reagents = list("lube" = 250)

/obj/item/reagent_containers/spray/cyborg_lube/cyborg_recharge(coeff, emagged)
	if(emagged)
		reagents.check_and_add("lube", volume, 2 * coeff)

//spray tan
/obj/item/reagent_containers/spray/spraytan
	name = "spray tan"
	volume = 50
	desc = "Gyaro brand spray tan. Do not spray near eyes or other orifices."
	list_reagents = list("spraytan" = 50)

//pepperspray
/obj/item/reagent_containers/spray/pepper
	name = "pepperspray"
	desc = "Manufactured by UhangInc, used to blind and down an opponent quickly."
	icon = 'icons/obj/items.dmi'
	icon_state = "pepperspray"
	belt_icon = null
	volume = 40
	spray_maxrange = 4
	spray_currentrange = 4
	spray_minrange = 2
	list_reagents = list("condensedcapsaicin" = 40)

//water flower
/obj/item/reagent_containers/spray/waterflower
	name = "water flower"
	desc = "A seemingly innocent sunflower...with a twist."
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "sunflower"
	belt_icon = null
	adjustable = FALSE
	amount_per_transfer_from_this = 1
	volume = 10
	list_reagents = list("water" = 10)

//chemsprayer
/obj/item/reagent_containers/spray/chemsprayer
	name = "chem sprayer"
	desc = "A utility used to spray large amounts of reagents in a given area."
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "chemsprayer"
	w_class = WEIGHT_CLASS_NORMAL
	spray_maxrange = 7
	spray_currentrange = 7
	spray_minrange = 4
	adjust_action = "adjust the output switch"
	volume = 600
	origin_tech = "combat=3;materials=3;engineering=3"


/obj/item/reagent_containers/spray/chemsprayer/spray(atom/A)
	var/Sprays[3]
	for(var/i=1, i<=3, i++) // intialize sprays
		if(reagents.total_volume < 1) break
		var/obj/effect/decal/chempuff/D = new/obj/effect/decal/chempuff(get_turf(src))
		D.create_reagents(amount_per_transfer_from_this)
		reagents.trans_to(D, amount_per_transfer_from_this)

		D.icon += mix_color_from_reagents(D.reagents.reagent_list)

		Sprays[i] = D

	var/direction = get_dir(src, A)
	var/turf/T = get_turf(A)
	var/turf/T1 = get_step(T,turn(direction, 90))
	var/turf/T2 = get_step(T,turn(direction, -90))
	var/list/the_targets = list(T,T1,T2)

	for(var/i=1, i<=length(Sprays), i++)
		spawn()
			var/obj/effect/decal/chempuff/D = Sprays[i]
			if(!D) continue

			// Spreads the sprays a little bit
			var/turf/my_target = pick(the_targets)
			the_targets -= my_target

			for(var/j=0, j<=spray_currentrange, j++)
				step_towards(D, my_target)
				D.reagents.reaction(get_turf(D))
				for(var/atom/t in get_turf(D))
					D.reagents.reaction(t)
				sleep(2)
			qdel(D)


/// Plant-B-Gone
/// -- Skie
/obj/item/reagent_containers/spray/plantbgone
	name = "Plant-B-Gone"
	desc = "Kills those pesky weeds!"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "plantbgone"
	belt_icon = null
	volume = 100
	list_reagents = list("glyphosate" = 100)

/// Sticky tar spray
/obj/item/reagent_containers/spray/sticky_tar
	name = "sticky tar applicator"
	desc = "A suspicious looking spraycan filled with an extremely viscous and sticky fluid."
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	icon_state = "syndie_spraycan"
	container_type = AMOUNT_VISIBLE
	list_reagents = list("sticky_tar" = 100)


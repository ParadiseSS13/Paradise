/obj/tgvehicle/scooter
	name = "scooter"
	desc = "A fun way to get around."
	icon_state = "scooter"
	are_legs_exposed = TRUE

/obj/tgvehicle/scooter/Initialize(mapload)
	. = ..()
	make_ridable()

/obj/tgvehicle/scooter/proc/make_ridable()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/scooter)

/obj/tgvehicle/scooter/wrench_act(mob/living/user, obj/item/I)
	..()
	to_chat(user, "<span class='notice'>You begin to remove the handlebars...</span>")
	if(!I.use_tool(src, user, 40, volume = 50))
		return TRUE
	var/obj/tgvehicle/scooter/skateboard/improvised/skater = new(drop_location())
	new /obj/item/stack/rods(drop_location(), 2)
	to_chat(user, "<span class='notice'>You remove the handlebars from [src].</span>")
	if(has_buckled_mobs())
		var/mob/living/carbon/carbons = buckled_mobs[1]
		unbuckle_mob(carbons)
		skater.buckle_mob(carbons)
	qdel(src)
	return TRUE

/obj/tgvehicle/scooter/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	for(var/mob/living/buckled_mob as anything in buckled_mobs)
		if(buckled_mob.get_num_legs() > 0)
			buckled_mob.pixel_y = 5
		else
			buckled_mob.pixel_y = -4
		if(istype(get_turf(src), /turf/simulated/floor/plating/asteroid)) //Rocks are bad for wheels mkay?
			if(!HAS_TRAIT(src, TRAIT_NO_BREAK_GLASS_TABLES))
				buckled_mob.adjustStaminaLoss(2)
				if(prob(7)) //Not to much spam.
					to_chat(buckled_mob, "<span class='warning'>The rocky terrain you are riding on is tiring you out!</span>")

/obj/tgvehicle/scooter/skateboard
	name = "skateboard"
	desc = "An old, battered skateboard. It's still rideable, but probably unsafe."
	icon_state = "skateboard"
	density = FALSE
	///Sparks datum for when we grind on tables
	var/datum/effect_system/spark_spread/sparks
	///Whether the board is currently grinding
	var/grinding = FALSE
	///Stores the time of the last crash plus a short cooldown, affects availability and outcome of certain actions
	COOLDOWN_DECLARE(next_crash)
	///The handheld item counterpart for the board
	var/board_item_type = /obj/item/melee/skateboard
	///Stamina drain multiplier
	var/instability = 10
	///If true, riding the skateboard with walk intent on will prevent crashing.
	var/can_slow_down = TRUE
	///Is this board cursed, preventing the cheeser from picking it up right away and using it again. Can not get on it while cursed either.
	var/cursed = FALSE

/obj/tgvehicle/scooter/skateboard/Initialize(mapload)
	. = ..()
	sparks = new
	sparks.set_up(1, 0, src)
	sparks.attach(src)

/obj/tgvehicle/scooter/skateboard/make_ridable()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/scooter/skateboard)

/obj/tgvehicle/scooter/skateboard/Destroy()
	if(sparks)
		QDEL_NULL(sparks)
	return ..()

/obj/tgvehicle/scooter/skateboard/relaymove(mob/living/user, direction)
	if(grinding || !COOLDOWN_FINISHED(src, next_crash))
		return FALSE
	return ..()

/obj/tgvehicle/scooter/skateboard/generate_actions()
	. = ..()
	initialize_controller_action_type(/datum/action/vehicle/skateboard/ollie, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/skateboard/kickflip, VEHICLE_CONTROL_DRIVE)

/obj/tgvehicle/scooter/skateboard/post_buckle_mob(mob/living/M)//allows skateboards to be non-dense but still allows 2 skateboarders to collide with each other
	if(M.pulling)
		M.stop_pulling()
		to_chat(M, "<span class='warning'>You can't pull things along while skateboarding!</span>")
	set_density(TRUE)
	return ..()

/obj/tgvehicle/scooter/skateboard/post_unbuckle_mob(mob/living/M)
	if(!has_buckled_mobs())
		set_density(FALSE)
	return ..()

/obj/tgvehicle/scooter/skateboard/Bump(atom/bumped_thing)
	. = ..()
	if(!bumped_thing.density || !has_buckled_mobs() || !COOLDOWN_FINISHED(src, next_crash))
		return
	var/mob/living/rider = buckled_mobs[1]
	if(rider.m_intent == MOVE_INTENT_WALK && can_slow_down) //Going slow prevents you from crashing.
		return

	COOLDOWN_START(src, next_crash, 1 SECONDS)
	rider.adjustStaminaLoss(instability * 6)
	playsound(src, 'sound/effects/bang.ogg', 40, TRUE)
	if(!iscarbon(rider) || rider.getStaminaLoss() >= 100 || grinding || iscarbon(bumped_thing))
		var/atom/throw_target = get_edge_target_turf(rider, pick(NORTH, SOUTH, EAST, WEST))
		unbuckle_mob(rider)
		if((istype(bumped_thing, /obj/machinery/disposal)))
			rider.Weaken(8 SECONDS)
			rider.forceMove(bumped_thing)
			forceMove(bumped_thing)
			visible_message("<span class='danger'>[src] crashes into [bumped_thing], and gets dumped straight into it!</span>")
			return
		if((istype(bumped_thing, /obj/machinery/economy/vending)))
			var/obj/machinery/economy/vending/V = bumped_thing
			rider.Weaken(8 SECONDS)
			visible_message("<span class='danger'>[src] crashes into [V]!</span>")
			V.tilt(rider, from_combat = TRUE)
			return
		rider.throw_at(throw_target, 3, 2)
		var/head_slot = rider.get_item_by_slot(ITEM_SLOT_HEAD)
		if(!head_slot || !(istype(head_slot, /obj/item/clothing/head/helmet) || istype(head_slot, /obj/item/clothing/head/hardhat)))
			rider.adjustBrainLoss(5)
			rider.updatehealth()
		visible_message("<span class='danger'>[src] crashes into [bumped_thing], sending [rider] flying!</span>")
		rider.Weaken(6 SECONDS)
		if(iscarbon(bumped_thing))
			var/mob/living/carbon/victim = bumped_thing
			var/grinding_mulitipler = 1
			if(grinding)
				grinding_mulitipler = 2
				victim.Weaken(2.5 SECONDS) // This is easier said than done, so probably fine. If officers or crew weaponize it I'll kill it fully.
			victim.KnockDown(4 * grinding_mulitipler SECONDS)
	else
		var/backdir = REVERSE_DIR(dir)
		step(src, backdir)
		rider.spin(4, 1)

///Moves the vehicle forward and if it lands on a table, repeats
/obj/tgvehicle/scooter/skateboard/proc/grind()
	if(!has_buckled_mobs())
		grinding = FALSE
		icon_state = "[initial(icon_state)]"
		return
	var/mob/living/skater = buckled_mobs[1]
	var/old_pass = skater.pass_flags //Re-do this, so railings don't fuck with the grinder
	var/old_v_pass = pass_flags
	skater.pass_flags |= PASSTABLE | PASSFENCE
	pass_flags |= PASSTABLE | PASSFENCE
	step(src, dir)
	skater.pass_flags = old_pass
	pass_flags = old_v_pass
	var/piping_hot = FALSE
	for(var/obj/machinery/atmospherics/P in loc.contents)
		if(P.invisibility == 0 && (loc.layer == PLATING_LAYER || P.layer >= GAS_PIPE_VISIBLE_LAYER))
			piping_hot = TRUE
			break
	if(!(locate(/obj/structure/table) in loc.contents) && !(locate(/obj/structure/railing) in loc.contents) && !piping_hot)
		grinding = FALSE
		icon_state = "[initial(icon_state)]"
		return
	skater.adjustStaminaLoss(instability * 0.3)
	if(skater.getStaminaLoss() >= 100)
		playsound(src, 'sound/effects/bang.ogg', 20, TRUE)
		unbuckle_mob(skater)
		var/atom/throw_target = get_edge_target_turf(src, pick(NORTH, SOUTH, EAST, WEST))
		skater.throw_at(throw_target, 2, 2)
		visible_message("<span class='danger'>[skater] loses [skater.p_their()] footing and slams on the ground!</span>")
		skater.Weaken(4 SECONDS)
		grinding = FALSE
		icon_state = "[initial(icon_state)]"
		return
	playsound(src, 'sound/effects/skateboard_roll.ogg', 50, TRUE)
	var/turf/location = get_turf(src)

	if(location)
		if(prob(33))
			location.hotspot_expose(1000, 1)
			sparks.start() //the most radical way to start plasma fires
	for(var/mob/living/carbon/victim in location)
		if(victim.body_position == LYING_DOWN)
			playsound(location, 'sound/items/trayhit2.ogg', 40)
			victim.apply_damage(damage = 25, damagetype = BRUTE, def_zone = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
			victim.Weaken(1.5 SECONDS)
			skater.adjustStaminaLoss(instability)
			victim.visible_message("<span class='danger'>[victim] straight up gets grinded into the ground by [skater]'s [src]! Radical!</span>")
	addtimer(CALLBACK(src, PROC_REF(grind)), 1 DECISECONDS)

/obj/tgvehicle/scooter/skateboard/MouseDrop(atom/over_object)
	. = ..()
	var/mob/living/carbon/skater = usr
	if(!istype(skater))
		return
	if(over_object == skater)
		pick_up_board(skater)

/obj/tgvehicle/scooter/skateboard/proc/pick_up_board(mob/living/carbon/skater)
	if(skater.incapacitated() || !Adjacent(skater))
		return
	if(cursed)
		to_chat(skater, "<span class='danger'>Some magic burns your hands whenever you go to pick [src] up!</span>")
		return
	if(has_buckled_mobs())
		to_chat(skater, "<span class='warning'>You can't lift this up when somebody's on it.</span>")
		return
	skater.put_in_hands(new board_item_type(get_turf(skater)))
	qdel(src)

/obj/tgvehicle/scooter/skateboard/pro
	name = "pro skateboard"
	desc = "An EightO brand professional skateboard. Looks a lot more stable than the average board."
	icon_state = "skateboardpro"
	board_item_type = /obj/item/melee/skateboard/pro
	instability = 6

/obj/tgvehicle/scooter/skateboard/pro/make_ridable()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/scooter/skateboard/pro)

/obj/tgvehicle/scooter/skateboard/hoverboard
	name = "hoverboard"
	desc = "A blast from the past, so retro!"
	board_item_type = /obj/item/melee/skateboard/hoverboard
	instability = 3
	icon_state = "hoverboard_red"
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	var/mutable_appearance/curse_overlay

/obj/tgvehicle/scooter/skateboard/hoverboard/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_BREAK_GLASS_TABLES, ROUNDSTART_TRAIT)

/obj/tgvehicle/scooter/skateboard/hoverboard/make_ridable()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/scooter/skateboard/hover)

/obj/tgvehicle/scooter/skateboard/hoverboard/proc/necropolis_curse()
	cursed = TRUE
	can_buckle = FALSE
	addtimer(CALLBACK(src, PROC_REF(remove_rider)), 5 SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE|TIMER_DELETE_ME)
	curse_overlay = mutable_appearance('icons/effects/cult_effects.dmi', "cult-mark", ABOVE_MOB_LAYER)
	curse_overlay.pixel_y = -10

	add_overlay(curse_overlay)

/obj/tgvehicle/scooter/skateboard/hoverboard/proc/remove_rider()
	visible_message("<span class='warning'>The boosters on [src] burn out as the magic extinguishes it!</span>")
	if(has_buckled_mobs())
		var/mob/living/carbon/skaterboy = buckled_mobs[1]
		unbuckle_mob(skaterboy)
	addtimer(CALLBACK(src, PROC_REF(clear_curse)), 30 SECONDS,TIMER_UNIQUE|TIMER_STOPPABLE|TIMER_DELETE_ME)

/obj/tgvehicle/scooter/skateboard/hoverboard/proc/clear_curse()
	can_buckle = TRUE
	cursed = FALSE
	cut_overlay(curse_overlay)

/obj/tgvehicle/scooter/skateboard/hoverboard/admin
	name = "\improper Board Of Directors"
	desc = "The engineering complexity of a spaceship concentrated inside of a board. Just as expensive, too."
	board_item_type = /obj/item/melee/skateboard/hoverboard/admin
	instability = 0
	icon_state = "hoverboard_nt"

/obj/tgvehicle/scooter/skateboard/improvised
	name = "improvised skateboard"
	desc = "An unfinished scooter which can only barely be called a skateboard. It's still rideable, but probably unsafe. Looks like you'll need to add a few rods to make handlebars."
	board_item_type = /obj/item/melee/skateboard/improvised
	instability = 12

//CONSTRUCTION
/obj/item/scooter_frame
	name = "scooter frame"
	desc = "A metal frame for building a scooter. Looks like you'll need to add some iron to make wheels."
	icon = 'icons/obj/tgvehicles.dmi'
	icon_state = "scooter_frame"

/obj/item/scooter_frame/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/stack/sheet/metal))
		return ..()
	var/obj/item/stack/S = I
	if(S.get_amount() < 5)
		return
	to_chat(user, "<span class='notice'>You begin to add wheels to [src].</span>")
	if(do_after(user, 5 SECONDS, target = src))
		if(!loc || !S || S.get_amount() < 2)
			return
	S.use(2)
	to_chat(user, "<span class='notice'>You finish making wheels for [src].</span>")
	new /obj/tgvehicle/scooter/skateboard/improvised(user.loc)
	qdel(src)

/obj/item/scooter_frame/wrench_act(mob/living/user, obj/item/I)
	..()
	to_chat(user, "<span class='notice'>You deconstruct [src].</span>")
	new /obj/item/stack/rods(drop_location(), 10)
	I.play_tool_sound(src)
	qdel(src)
	return TRUE

/obj/tgvehicle/scooter/skateboard/wrench_act(mob/living/user, obj/item/I)
	return

/obj/tgvehicle/scooter/skateboard/improvised/item_interaction(mob/living/user, obj/item/I, list/modifiers)
	if(!istype(I, /obj/item/stack/rods))
		return ..()
	var/obj/item/stack/S = I
	if(S.get_amount() < 2)
		return ITEM_INTERACT_COMPLETE
	to_chat(user, "<span class='notice'>You begin making handlebars for [src].</span>")
	if(do_after(user, 2.5 SECONDS, target = src))
		if(!loc || !S || S.get_amount() < 2 || !S.use(2))
			return ITEM_INTERACT_COMPLETE
	to_chat(user, "<span class='notice'>You add the rods to [src], creating handlebars.</span>")
	var/obj/tgvehicle/scooter/skaterskoot = new(loc)
	if(has_buckled_mobs())
		var/mob/living/carbon/skaterboy = buckled_mobs[1]
		unbuckle_mob(skaterboy)
		skaterskoot.buckle_mob(skaterboy)
	qdel(src)

/obj/tgvehicle/scooter/skateboard/improvised/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(.)
		return
	to_chat(user, "<span class='notice'>You begin to deconstruct and remove the wheels on [src]...</span>")
	if(!I.use_tool(src, user, 20, volume = 50))
		return
	to_chat(user, "<span class='notice'>You deconstruct the wheels on [src].</span>")
	new /obj/item/stack/sheet/metal(drop_location(), 5)
	new /obj/item/scooter_frame(drop_location())
	if(has_buckled_mobs())
		var/mob/living/carbon/skatergirl = buckled_mobs[1]
		unbuckle_mob(skatergirl)
	qdel(src)
	return TRUE

/obj/item/melee/skateboard
	name = "skateboard"
	desc = "A skateboard. It can be placed on its wheels and ridden, or used as a radical weapon."
	icon = 'icons/obj/tgvehicles.dmi'
	icon_state = "skateboard_held"
	inhand_icon_state = "skateboard"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	force = 12
	throwforce = 4
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	attack_verb = list("smacks", "whacks", "slams", "smashes")
	///The vehicle counterpart for the board
	var/board_item_type = /obj/tgvehicle/scooter/skateboard

/obj/item/melee/skateboard/attack_self__legacy__attackchain(mob/user)
	var/obj/tgvehicle/scooter/skateboard/S = new board_item_type(get_turf(user))//this probably has fucky interactions with telekinesis but for the record it wasn't my fault
	S.buckle_mob(user)
	qdel(src)

/obj/item/melee/skateboard/improvised
	name = "improvised skateboard"
	desc = "A jury-rigged skateboard. It can be placed on its wheels and ridden, or used as a radical weapon."
	board_item_type = /obj/tgvehicle/scooter/skateboard/improvised

/obj/item/melee/skateboard/pro
	name = "pro skateboard"
	desc = "An EightO brand professional skateboard. It looks sturdy and well made."
	icon_state = "skateboardpro_held"
	inhand_icon_state = "skateboardpro"
	board_item_type = /obj/tgvehicle/scooter/skateboard/pro

/obj/item/melee/skateboard/hoverboard
	name = "hoverboard"
	desc = "A blast from the past, so retro!"
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "hoverboard_red_held"
	inhand_icon_state = "hoverboard_red"
	board_item_type = /obj/tgvehicle/scooter/skateboard/hoverboard

/obj/item/melee/skateboard/hoverboard/admin
	name = "Board Of Directors"
	desc = "The engineering complexity of a spaceship concentrated inside of a board. Just as expensive, too."
	icon_state = "hoverboard_nt_held"
	inhand_icon_state = "hoverboard_nt"
	board_item_type = /obj/tgvehicle/scooter/skateboard/hoverboard/admin

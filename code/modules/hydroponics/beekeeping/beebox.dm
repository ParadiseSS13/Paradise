
#define BEEBOX_MAX_FRAMES				3		//Max frames per box
#define BEES_RATIO						0.5 	//Multiplied by the max number of honeycombs to find the max number of bees
#define BEE_PROB_NEW_BEE				20		//The chance for spare bee_resources to be turned into new bees
#define BEE_RESOURCE_HONEYCOMB_COST		100		//The amount of bee_resources for a new honeycomb to be produced, percentage cost 1-100
#define BEE_RESOURCE_NEW_BEE_COST		50		//The amount of bee_resources for a new bee to be produced, percentage cost 1-100



/mob/proc/bee_friendly()
	return FALSE


/mob/living/basic/bee/bee_friendly()
	return TRUE

/mob/living/simple_animal/bot/bee_friendly()
	if(paicard)
		return FALSE
	return TRUE

/mob/living/basic/diona_nymph/bee_friendly()
	return TRUE

/mob/living/carbon/human/bee_friendly()
	if(isdiona(src)) //bees pollinate plants, duh.
		return TRUE
	if((wear_suit && (wear_suit.flags & THICKMATERIAL)) && (head && (head.flags & THICKMATERIAL)))
		return TRUE
	return FALSE


/obj/structure/beebox
	name = "apiary"
	desc = "Dr. Miles Manners is just your average wasp-themed super hero by day, but by night he becomes DR. BEES!"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "beebox"
	anchored = TRUE
	density = TRUE
	var/mob/living/basic/bee/queen/queen_bee = null
	var/list/bees = list() //bees owned by the box, not those inside it
	var/list/honeycombs = list()
	var/list/honey_frames = list()
	var/bee_resources = 0


/obj/structure/beebox/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)


/obj/structure/beebox/Destroy()
	STOP_PROCESSING(SSobj, src)
	for(var/mob/living/basic/bee/B in bees)
		B.beehome = null
	bees.Cut()
	bees = null
	QDEL_LIST_CONTENTS(honeycombs)
	QDEL_LIST_CONTENTS(honey_frames)
	QDEL_NULL(queen_bee)
	return ..()


//Premade apiaries can spawn with a random reagent
/obj/structure/beebox/premade
	var/random_reagent = FALSE


/obj/structure/beebox/premade/Initialize(mapload)
	. = ..()
	var/datum/reagent/R = null
	if(random_reagent)
		R = GLOB.chemical_reagents_list[get_random_reagent_id()]

	queen_bee = new(src)
	queen_bee.beehome = src
	bees += queen_bee
	queen_bee.assign_reagent(R)

	for(var/i in 1 to BEEBOX_MAX_FRAMES)
		var/obj/item/honey_frame/HF = new(src)
		honey_frames += HF

	for(var/i in 1 to get_max_bees())
		var/mob/living/basic/bee/B = new(src)
		bees += B
		B.beehome = src
		B.assign_reagent(R)

/obj/structure/beebox/premade/random
	random_reagent = TRUE


/obj/structure/beebox/process()
	if(queen_bee)
		if(bee_resources >= BEE_RESOURCE_HONEYCOMB_COST && length(honeycombs) < get_max_honeycomb())
			bee_resources = max(bee_resources-BEE_RESOURCE_HONEYCOMB_COST, 0)
			var/obj/item/food/honeycomb/HC = new(src)
			if(queen_bee.beegent)
				HC.set_reagent(queen_bee.beegent.id)
			honeycombs += HC

		if(length(bees) < get_max_bees())
			var/freebee = FALSE //a freebee, geddit?, hahaha HAHAHAHA
			if(length(bees) <= 1) //there's always one set of worker bees, this isn't colony collapse disorder its 2d spessmen
				freebee = TRUE
			if((bee_resources >= BEE_RESOURCE_NEW_BEE_COST && prob(BEE_PROB_NEW_BEE)) || freebee)
				if(!freebee)
					bee_resources = max(bee_resources - BEE_RESOURCE_NEW_BEE_COST, 0)
				var/mob/living/basic/bee/B = new(get_turf(src))
				B.beehome = src
				B.assign_reagent(queen_bee.beegent)
				bees += B


/obj/structure/beebox/proc/get_max_honeycomb()
	. = 0
	for(var/hf in honey_frames)
		var/obj/item/honey_frame/HF = hf
		. += HF.honeycomb_capacity


/obj/structure/beebox/proc/get_max_bees()
	. = get_max_honeycomb() * BEES_RATIO


/obj/structure/beebox/examine(mob/user)
	. = ..()

	if(!queen_bee)
		. += SPAN_WARNING("There is no queen bee! There won't bee any honeycomb without a queen!")

	var/half_bee = get_max_bees()*0.5
	if(half_bee && (length(bees) >= half_bee))
		. += SPAN_NOTICE("This place is a BUZZ with activity... there are lots of bees!")

	. += SPAN_NOTICE("[bee_resources]/100 resource supply.")
	. += SPAN_NOTICE("[bee_resources]% towards a new honeycomb.")
	. += SPAN_NOTICE("[bee_resources*2]% towards a new bee.")

	if(length(honeycombs))
		var/plural = length(honeycombs) > 1
		. += SPAN_NOTICE("There [plural? "are" : "is"] [length(honeycombs)] uncollected honeycomb[plural ? "s":""] in the apiary.")

	if(length(honeycombs) >= get_max_honeycomb())
		. += SPAN_WARNING("there's no room for more honeycomb!")


/obj/structure/beebox/item_interaction(mob/living/user, obj/item/I, list/modifiers)
	. = ITEM_INTERACT_COMPLETE
	if(istype(I, /obj/item/honey_frame))
		var/obj/item/honey_frame/HF = I
		if(length(honey_frames) < BEEBOX_MAX_FRAMES)
			if(!user.unequip(HF))
				return
			visible_message(SPAN_NOTICE("[user] adds a frame to the apiary."))
			HF.forceMove(src)
			honey_frames += HF
		else
			to_chat(user, SPAN_WARNING("There's no room for anymore frames in the apiary!"))
		return

	if(istype(I, /obj/item/queen_bee))
		if(queen_bee)
			to_chat(user, SPAN_WARNING("This hive already has a queen!"))
			return

		var/obj/item/queen_bee/qb = I
		if(!user.transfer_item_to(qb, src))
			return
		qb.queen.forceMove(src)
		bees += qb.queen
		queen_bee = qb.queen
		queen_bee.beehome = src
		qb.queen = null

		if(queen_bee)
			visible_message(SPAN_NOTICE("[user] sets [qb] down inside the apiary, making it [qb.p_their()] new home."))
			var/relocated = 0
			for(var/b in bees)
				var/mob/living/basic/bee/B = b
				if(B.reagent_incompatible(queen_bee))
					bees -= B
					B.beehome = null
					if(B.loc == src)
						B.forceMove(drop_location())
					relocated++
			if(relocated)
				to_chat(user, SPAN_WARNING("This queen has a different reagent to some of the bees who live here, those bees will not return to this apiary!"))

		else
			to_chat(user, SPAN_WARNING("The queen bee disappeared! bees disappearing has been in the news lately..."))

		qdel(qb)
		return
	return ..()

/obj/structure/beebox/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0))
		return
	TOOL_ATTEMPT_DISMANTLE_MESSAGE
	if(I.use_tool(src, user, 50, volume = I.tool_volume))
		TOOL_DISMANTLE_SUCCESS_MESSAGE
		deconstruct(disassembled = TRUE)

/obj/structure/beebox/wrench_act(mob/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I, time = 20)

/obj/structure/beebox/attack_animal(mob/living/simple_animal/M)
	if(!istype(M, /mob/living/basic/bee))
		return ..()

	M.forceMove(src)
	bees += M

/obj/structure/beebox/relaymove(mob/user)
	user.forceMove(get_turf(src))
	bees -= user

/obj/structure/beebox/attack_hand(mob/user)
	if(ishuman(user))
		if(!user.bee_friendly())
			// Time to get stung!
			var/bees = FALSE
			for(var/b in bees) // everyone who's ever lived here now instantly hates you, suck it assistant!
				var/mob/living/basic/bee/B = b
				if(B.is_queen)
					continue
				if(B.loc == src)
					B.forceMove(drop_location())
				B.ai_controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, user)
				bees = TRUE
			if(bees)
				visible_message(SPAN_DANGER("[user] disturbs the bees!"))
		else
			var/option = tgui_input_list(user, "What Action do you wish to perform?", "Apiary", list("Remove a Honey Frame", "Remove the Queen Bee"))
			if(!Adjacent(user) || !option)
				return
			switch(option)
				if("Remove a Honey Frame")
					if(!length(honey_frames))
						to_chat(user, SPAN_WARNING("There are no honey frames to remove!"))
						return

					var/obj/item/honey_frame/HF = pick_n_take(honey_frames)
					if(HF)
						if(!user.put_in_active_hand(HF))
							HF.forceMove(get_turf(src))
						visible_message(SPAN_NOTICE("[user] removes a frame from the apiary."))

						var/amtH = HF.honeycomb_capacity
						var/fallen = 0
						while(length(honeycombs) && amtH) //let's pretend you always grab the frame with the most honeycomb on it
							var/obj/item/food/honeycomb/HC = pick_n_take(honeycombs)
							if(HC)
								HC.forceMove(get_turf(src))
								amtH--
								fallen++
						if(fallen)
							var/multiple = fallen > 1
							visible_message(SPAN_NOTICE("[user] scrapes [multiple ? "[fallen]" : "a"] honeycomb[multiple ? "s" : ""] off of the frame."))

				if("Remove the Queen Bee")
					if(!queen_bee || queen_bee.loc != src)
						to_chat(user, SPAN_WARNING("There is no queen bee to remove!"))
						return
					var/obj/item/queen_bee/QB = new()
					queen_bee.forceMove(QB)
					bees -= queen_bee
					QB.queen = queen_bee
					QB.name = queen_bee.name
					if(!user.put_in_active_hand(QB))
						QB.forceMove(get_turf(src))
					visible_message(SPAN_NOTICE("[user] removes the queen from the apiary."))
					queen_bee = null

/obj/structure/beebox/deconstruct(disassembled = FALSE)
	var/mat_drop = 20
	if(disassembled)
		mat_drop = 40
	new /obj/item/stack/sheet/wood(loc, mat_drop)
	for(var/mob/living/basic/bee/B in bees)
		if(B.loc == src)
			B.forceMove(drop_location())
	for(var/obj/item/honey_frame/HF in honey_frames)
		HF.forceMove(drop_location())
		honey_frames -= HF
	..()

/obj/structure/beebox/unwrenched
	anchored = FALSE

/obj/structure/beebox/proc/habitable(mob/living/basic/target)
	if(!istype(target, /mob/living/basic/bee))
		return FALSE
	var/mob/living/basic/bee/citizen = target
	if(citizen.reagent_incompatible(queen_bee) || bees.len >= get_max_bees())
		return FALSE
	return TRUE

#undef BEEBOX_MAX_FRAMES
#undef BEES_RATIO
#undef BEE_PROB_NEW_BEE
#undef BEE_RESOURCE_HONEYCOMB_COST
#undef BEE_RESOURCE_NEW_BEE_COST

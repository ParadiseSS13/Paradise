////////////////////////////////////////////////////////////////////////////////
/// (Mixing)Glass.
////////////////////////////////////////////////////////////////////////////////
/obj/item/reagent_containers/glass
	name = " "
	var/base_name = " "
	desc = " "
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30,50)
	volume = 50
	container_type = OPENCONTAINER
	has_lid = TRUE
	resistance_flags = ACID_PROOF
	blocks_emissive = FALSE
	usesound = 'sound/items/deconstruct.ogg'
	var/label_text = ""

/obj/item/reagent_containers/glass/Initialize(mapload)
	. = ..()
	base_name = name

/obj/item/reagent_containers/glass/examine(mob/user)
	. = ..()
	if(get_dist(user, src) <= 2 && !is_open_container())
		. += "<span class='notice'>Airtight lid seals it completely.</span>"

	. += "<span class='notice'>[src] can hold up to [reagents.maximum_volume] units.</span>"

/obj/item/reagent_containers/glass/mob_act(mob/target, mob/living/user)
	. = TRUE
	if(!is_open_container())
		return

	if(!reagents || !reagents.total_volume)
		to_chat(user, "<span class='warning'>[src] is empty!</span>")
		return

	if(istype(target))
		var/list/transferred = list()
		for(var/datum/reagent/R in reagents.reagent_list)
			transferred += R.name
		var/contained = english_list(transferred)

		if(user.a_intent == INTENT_HARM)
			target.visible_message("<span class='danger'>[user] splashes the contents of [src] onto [target]!</span>", \
							"<span class='userdanger'>[user] splashes the contents of [src] onto [target]!</span>")
			add_attack_logs(user, target, "Splashed with [name] containing [contained]", !!target.ckey ? null : ATKLOG_ALL)

			reagents.reaction(target, REAGENT_TOUCH)
			reagents.clear_reagents()
		else
			if(!iscarbon(target)) // Non-carbons can't process reagents
				to_chat(user, "<span class='warning'>You cannot find a way to feed [target].</span>")
				return
			if(target != user)
				target.visible_message("<span class='danger'>[user] attempts to feed something to [target].</span>", \
							"<span class='userdanger'>[user] attempts to feed something to you.</span>")
				if(!do_mob(user, target))
					return
				if(!reagents || !reagents.total_volume)
					return // The drink might be empty after the delay, such as by spam-feeding
				target.visible_message("<span class='danger'>[user] feeds something to [target].</span>", "<span class='userdanger'>[user] feeds something to you.</span>")
				add_attack_logs(user, target, "Fed with [name] containing [contained]", !!target.ckey ? null : ATKLOG_ALL)
			else
				to_chat(user, "<span class='notice'>You swallow a gulp of [src].</span>")
			var/fraction = min(5 / reagents.total_volume, 1)
			reagents.reaction(target, REAGENT_INGEST, fraction)
			addtimer(CALLBACK(reagents, TYPE_PROC_REF(/datum/reagents, trans_to), target, 5), 5)
			playsound(target.loc,'sound/items/drink.ogg', rand(10,50), TRUE)
			// Add viruses where needed
			if(length(target.viruses))
				AddComponent(/datum/component/viral_contamination, target.viruses)
			// Infect contained blood as well for splash reactions
			var/datum/reagent/blood/blood_contained = locate() in reagents.reagent_list
			if(blood_contained?.data["viruses"])
				var/list/blood_viruses = blood_contained.data["viruses"]
				blood_viruses |= target.viruses.Copy()
				blood_contained.data["viruses"] = blood_viruses
			SEND_SIGNAL(src, COMSIG_MOB_REAGENT_EXCHANGE, target)

/obj/item/reagent_containers/glass/normal_act(atom/target, mob/living/user)
	if(!check_allowed_items(target, target_self = TRUE) || !is_open_container() || !reagents)
		return

	. = TRUE
	if(target.is_refillable()) //Something like a glass. Player probably wants to transfer TO it.
		if(!reagents.total_volume)
			to_chat(user, "<span class='warning'>[src] is empty!</span>")
			return

		if(target.reagents.holder_full())
			to_chat(user, "<span class='warning'>[target] is full.</span>")
			return

		var/trans = reagents.trans_to(target, amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You transfer [trans] unit\s of the solution to [target].</span>")
		return

	else if(target.is_drainable()) //A dispenser. Transfer FROM it TO us.
		if(!target.reagents.total_volume)
			to_chat(user, "<span class='warning'>[target] is empty and can't be refilled!</span>")
			return

		if(reagents.holder_full())
			to_chat(user, "<span class='warning'>[src] is full.</span>")
			return

		var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You fill [src] with [trans] unit\s of the contents of [target].</span>")
		return
	else if(reagents.total_volume)
		if(user.a_intent == INTENT_HARM)
			user.visible_message("<span class='danger'>[user] splashes the contents of [src] onto [target]!</span>", \
								"<span class='notice'>You splash the contents of [src] onto [target].</span>")
			reagents.reaction(target, REAGENT_TOUCH)
			reagents.clear_reagents()
			return

	return FALSE

/obj/item/reagent_containers/glass/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(is_pen(used))
		var/t = rename_interactive(user, used)
		if(!isnull(t))
			label_text = t
		return ITEM_INTERACT_COMPLETE
	return ..()

/obj/item/reagent_containers/glass/beaker
	name = "beaker"
	desc = "A simple glass beaker, nothing special."
	icon_state = "beaker"
	inhand_icon_state = "beaker"
	belt_icon = "beaker"
	materials = list(MAT_GLASS = 1000)
	var/obj/item/assembly_holder/assembly = null
	var/can_assembly = 1

/obj/item/reagent_containers/glass/beaker/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_atom_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/item/reagent_containers/glass/beaker/examine(mob/user)
	. = ..()
	if(assembly)
		. += "<span class='notice'>There is an [assembly] attached to it, use a screwdriver to remove it.</span>"

/obj/item/reagent_containers/glass/beaker/on_reagent_change()
	update_icon(UPDATE_OVERLAYS)

/obj/item/reagent_containers/glass/beaker/update_overlays()
	. = ..()
	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "[icon_state]1")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(1 to 19)
				filling.icon_state = "[icon_state]1"
			if(20 to 39)
				filling.icon_state = "[icon_state]20"
			if(40 to 59)
				filling.icon_state = "[icon_state]40"
			if(60 to 79)
				filling.icon_state = "[icon_state]60"
			if(80 to 99)
				filling.icon_state = "[icon_state]80"
			if(100 to INFINITY)
				filling.icon_state = "[icon_state]100"

		filling.icon += mix_color_from_reagents(reagents.reagent_list)
		. += filling

	if(!is_open_container())
		. += "lid_[initial(icon_state)]"
		if(!blocks_emissive)
			. += emissive_blocker(icon, "lid_[initial(icon_state)]")
	if(assembly)
		. += "assembly"

/obj/item/reagent_containers/glass/beaker/proc/heat_beaker()
	if(reagents)
		reagents.temperature_reagents(4000)

/obj/item/reagent_containers/glass/beaker/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/assembly_holder) && can_assembly)
		if(assembly)
			to_chat(usr, "<span class='warning'>[src] already has an assembly.</span>")
		else
			assembly = used
			user.drop_item()
			used.forceMove(src)
			update_icon(UPDATE_OVERLAYS)
		return ITEM_INTERACT_COMPLETE
	return ..()

/obj/item/reagent_containers/glass/beaker/HasProximity(atom/movable/AM)
	if(assembly)
		assembly.HasProximity(AM)

/obj/item/reagent_containers/glass/beaker/proc/on_atom_entered(datum/source, atom/movable/entered)
	if(assembly)
		assembly.on_atom_entered(source, entered)

/obj/item/reagent_containers/glass/beaker/on_found(mob/finder) //for mousetraps
	if(assembly)
		assembly.on_found(finder)

/obj/item/reagent_containers/glass/beaker/hear_talk(mob/living/M, list/message_pieces)
	if(assembly)
		assembly.hear_talk(M, message_pieces)

/obj/item/reagent_containers/glass/beaker/hear_message(mob/living/M, msg)
	if(assembly)
		assembly.hear_message(M, msg)

/obj/item/reagent_containers/glass/beaker/screwdriver_act(mob/living/user, obj/item/I)
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(assembly)
		to_chat(user, "<span class='notice'>You detach [assembly] from [src]</span>")
		user.put_in_hands(assembly)
		assembly = null
		update_icon(UPDATE_OVERLAYS)
	else
		to_chat(user, "<span class='notice'>There is no assembly to remove.</span>")

/obj/item/reagent_containers/glass/beaker/large
	name = "large beaker"
	desc = "A large glass beaker with twice the capacity of a normal beaker."
	icon_state = "beakerlarge"
	materials = list(MAT_GLASS=2500)
	volume = 100
	possible_transfer_amounts = list(5,10,15,25,30,50,100)

/obj/item/reagent_containers/glass/beaker/vial
	name = "vial"
	desc = "A small glass vial, often used by virologists of the 25th century."
	icon_state = "vial"
	belt_icon = "vial"
	materials = list(MAT_GLASS=250)
	volume = 25
	possible_transfer_amounts = list(5,10,15,25)
	can_assembly = 0

/obj/item/reagent_containers/glass/beaker/drugs
	name = "baggie"
	desc = "A small plastic baggie, often used by pharmaceutical \"entrepreneurs\"."
	icon_state = "baggie"
	amount_per_transfer_from_this = 2
	possible_transfer_amounts = null
	volume = 10
	can_assembly = 0

/obj/item/reagent_containers/glass/beaker/noreact
	name = "cryostasis beaker"
	desc = "A cryostasis beaker that allows for chemical storage without reactions."
	icon_state = "beakernoreact"
	materials = list(MAT_METAL=3000)
	origin_tech = "materials=2;engineering=3;plasmatech=3"
	blocks_emissive = EMISSIVE_BLOCK_GENERIC

/obj/item/reagent_containers/glass/beaker/noreact/Initialize(mapload)
	. = ..()
	reagents.set_reacting(FALSE)

/obj/item/reagent_containers/glass/beaker/bluespace
	name = "bluespace beaker"
	desc = "A bleeding-edge beaker that uses experimental bluespace technology to store massive quantities of liquid."
	icon_state = "beakerbluespace"
	materials = list(MAT_GLASS=3000)
	volume = 300
	possible_transfer_amounts = list(5,10,15,25,30,50,100,300)
	blocks_emissive = EMISSIVE_BLOCK_GENERIC
	origin_tech = "bluespace=5;materials=4;plasmatech=4"

/obj/item/reagent_containers/glass/beaker/cryoxadone
	list_reagents = list("cryoxadone" = 30)

/obj/item/reagent_containers/glass/beaker/sulphuric
	list_reagents = list("sacid" = 50)


/obj/item/reagent_containers/glass/beaker/slime
	list_reagents = list("slimejelly" = 50)

/obj/item/reagent_containers/glass/beaker/drugs/meth
	list_reagents = list("methamphetamine" = 10)

/obj/item/reagent_containers/glass/bucket
	name = "bucket"
	desc = "Useful for moving liquids, or having a helmet in the zombie apocalypse."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "bucket"
	materials = list(MAT_METAL=200)
	w_class = WEIGHT_CLASS_NORMAL
	amount_per_transfer_from_this = 20
	possible_transfer_amounts = list(5,10,15,20,25,30,50,80,100,120)
	volume = 120
	armor = list(MELEE = 10, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 75, ACID = 50) //Weak melee protection, because you can wear it on your head
	slot_flags = ITEM_SLOT_HEAD
	body_parts_covered = HEAD
	prefered_slot_flags = ITEM_SLOT_IN_BACKPACK
	resistance_flags = NONE
	blocks_emissive = EMISSIVE_BLOCK_GENERIC
	dog_fashion = /datum/dog_fashion/head/bucket

/obj/item/reagent_containers/glass/bucket/update_overlays()
	. = ..()
	if(!is_open_container())
		. += "lid_[initial(icon_state)]"

/obj/item/reagent_containers/glass/bucket/wooden
	name = "wooden bucket"
	icon_state = "woodbucket"
	materials = null
	armor = list(MELEE = 10, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 0, ACID = 50)
	resistance_flags = FLAMMABLE

/obj/item/reagent_containers/glass/bucket/equipped(mob/user, slot)
	..()
	if(slot == ITEM_SLOT_HEAD && reagents.total_volume)
		to_chat(user, "<span class='userdanger'>[src]'s contents spill all over you!</span>")
		reagents.reaction(user, REAGENT_TOUCH)
		reagents.clear_reagents()

/obj/item/reagent_containers/glass/bucket/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/mop))
		var/obj/item/mop/mop = used
		mop.wet_mop(src, user)
		return ITEM_INTERACT_COMPLETE
	if(isprox(used))
		to_chat(user, "<span class='notice'>You add [used] to [src].</span>")
		qdel(used)
		user.put_in_hands(new /obj/item/bucket_sensor)
		user.unequip(src)
		qdel(src)
		return ITEM_INTERACT_COMPLETE
	return ..()

/obj/item/reagent_containers/glass/beaker/waterbottle
	name = "bottle of water"
	desc = "A bottle of water filled at an old Earth bottling facility."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "smallbottle"
	inhand_icon_state = "bottle"
	list_reagents = list("water" = 49.5, "fluorine" = 0.5) //see desc, don't think about it too hard
	materials = list()

/obj/item/reagent_containers/glass/beaker/waterbottle/empty
	list_reagents = list()

/obj/item/reagent_containers/glass/beaker/waterbottle/large
	desc = "A fresh commercial-sized bottle of water."
	icon_state = "largebottle"
	materials = list(MAT_GLASS = 0)
	list_reagents = list("water" = 100)
	volume = 100
	amount_per_transfer_from_this = 20

/obj/item/reagent_containers/glass/beaker/waterbottle/large/empty
	list_reagents = list()

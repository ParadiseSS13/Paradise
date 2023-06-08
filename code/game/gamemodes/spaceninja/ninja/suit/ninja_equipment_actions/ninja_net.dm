/datum/action/item_action/advanced/ninja/ninjanet
	name = "Energy Net"
	desc = "Captures an opponent in a net of energy. Energy cost: 4000"
	check_flags = AB_CHECK_STUNNED|AB_CHECK_LYING|AB_CHECK_CONSCIOUS
	charge_type = ADV_ACTION_TYPE_TOGGLE
	use_itemicon = FALSE
	button_icon_state = "energynet"
	icon_icon = 'icons/mob/actions/actions_ninja.dmi'
	button_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon_state = "background_green"
	action_initialisation_text = "Pure Energy Net Generator"

/obj/item/clothing/suit/space/space_ninja/proc/toggle_ninja_net_emitter()
	var/mob/living/carbon/human/ninja = affecting
	if(net_emitter)
		qdel(net_emitter)
		net_emitter = null
	else
		net_emitter = new
		net_emitter.my_suit = src
		for(var/datum/action/item_action/advanced/ninja/ninjanet/ninja_action in actions)
			net_emitter.my_action = ninja_action
			ninja_action.action_ready = TRUE
			ninja_action.use_action()
			break
		ninja.put_in_hands(net_emitter)
/obj/item/ninja_net_emitter
	name = "Energy Net Emitter"
	desc = "A device sneakily hidden inside Spider Clan ninja suits. Emits a powerfull energy net that instantly ensnares a person"
	icon = 'icons/obj/ninjaobjects.dmi'
	icon_state = "net_emitter"
	item_state = ""
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = 0
	flags = DROPDEL | ABSTRACT | NOBLUDGEON | NOPICKUP
	var/obj/item/clothing/suit/space/space_ninja/my_suit = null
	var/datum/action/item_action/advanced/ninja/ninjanet/my_action = null

/obj/item/ninja_net_emitter/Destroy()
	. = ..()
	my_suit.net_emitter = null
	my_suit = null
	my_action.action_ready = FALSE
	my_action.use_action()
	my_action = null

/obj/item/ninja_net_emitter/equip_to_best_slot(mob/M)
	qdel(src)

/obj/item/ninja_net_emitter/attack_self(mob/user)
	return


/obj/item/ninja_net_emitter/afterattack(atom/target, mob/living/user, proximity)
	var/mob/target_mob = get_mob_in_atom_without_warning(target)
	ensnare(target_mob, user)


/obj/item/ninja_net_emitter/proc/ensnare(mob/living/target, mob/living/ninja)
	if(isnull(target))
		return
	if(QDELETED(target) || !(target in oview(ninja)) || !isliving(target) || ninja.incapacitated())
		return
	for(var/turf/between_turf in get_line(get_turf(ninja), get_turf(target)))
		if(between_turf.density)//Don't want them shooting nets through walls. It's kind of cheesy.
			to_chat(ninja, span_warning("You may not use an energy net through solid obstacles!"))
			return
	if(locate(/obj/structure/energy_net) in get_turf(target))//Check if they are already being affected by an energy net.
		to_chat(ninja, span_warning("[target] is already trapped inside an energy net!"))
		return
	if(!my_suit.ninjacost(4000, N_STEALTH_CANCEL))
		ninja.Beam(target, "n_beam", time = 15)
		var/obj/structure/energy_net/net = new /obj/structure/energy_net(target.drop_location())
		net.affected_mob = target
		ninja.visible_message(span_danger("[ninja] caught [target] with an energy net!"),span_notice("You caught [target] with an energy net!"))
		if(target.buckled)
			target.buckled.unbuckle_mob(target, TRUE)
		net.buckle_mob(target, TRUE) //No moving for you!
		qdel(src)

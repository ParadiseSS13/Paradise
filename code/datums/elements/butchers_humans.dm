/// An element for items that butcher human corpses into meat when attacked on
/// harm intent.
/datum/element/butchers_humans
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY

/datum/element/butchers_humans/Attach(datum/target)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(target, COMSIG_ATTACK, PROC_REF(on_attack))

/datum/element/butchers_humans/Detach(datum/source, force)
	. = ..()
	UnregisterSignal(source, list(COMSIG_PARENT_EXAMINE, COMSIG_ATTACK))

/datum/element/butchers_humans/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER // COMSIG_PARENT_EXAMINE
	examine_list += "<span class='warning'>Can be used to butcher dead people into meat while on harm intent.</span>"

/datum/element/butchers_humans/proc/on_attack(datum/source, mob/living/victim, mob/living/user, params)
	SIGNAL_HANDLER // COMSIG_ATTACK

	if(!ishuman(victim) || !isitem(source))
		return

	var/mob/living/carbon/human/human = victim
	var/obj/item/item = source

	if(human.stat == DEAD && user.a_intent == INTENT_HARM)
		var/obj/item/food/meat/human/newmeat = new human.dna.species.meat_type(get_turf(human))
		newmeat.name = human.real_name + newmeat.name
		newmeat.reagents.add_reagent("nutriment", (human.nutrition / 15) / 3)
		human.reagents.trans_to(newmeat, round((human.reagents.total_volume) / 3, 1))
		human.add_mob_blood(human)
		human.meatleft--

		if(human.meatleft)
			to_chat(user, "<span class='warning'>You hack off a chunk of meat from [human]!</span>")
			// fallthrough so we get side-effects like blood splatter and limb
			// flyoff from human attacked_by while we still have a corpse around
			return
		human.send_item_attack_message(item, user)

		// Handle a few tiny things normally done in attack chain
		user.do_attack_animation(human)
		item.add_fingerprint(user)
		if(item.hitsound)
			playsound(get_turf(item), item.hitsound, item.get_clamped_volume(), TRUE, extrarange = item.stealthy_audio ? SILENCED_SOUND_EXTRARANGE : -1, falloff_distance = 0)
		add_attack_logs(user, human, "Chopped up into meat with [item.name] ([uppertext(user.a_intent)])", human.ckey ? null : ATKLOG_ALMOSTALL)
		to_chat(user, "<span class='warning'>You reduce [human] to a pile of meat!</span>")
		qdel(human)
		return COMPONENT_CANCEL_ATTACK_CHAIN

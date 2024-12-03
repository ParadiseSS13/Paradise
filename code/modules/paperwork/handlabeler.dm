/obj/item/hand_labeler
	name = "hand labeler"
	desc = "A combined label printer, applicator, and remover, all in a single portable device. Designed to be easy to operate and use."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "labeler0"
	item_state = "flight"
	var/label = null
	var/labels_left = 30
	var/mode = LABEL_MODE_OFF

	new_attack_chain = TRUE

/obj/item/hand_labeler/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(..())
		return NONE

	if(mode == LABEL_MODE_OFF)	//if it's off, give up.
		return ITEM_INTERACT_SUCCESS

	if(!labels_left)
		to_chat(user, "<span class='warning'>No labels left!</span>")
		return ITEM_INTERACT_BLOCKING
	if(!label || !length(label))
		to_chat(user, "<span class='warning'>No text set!</span>")
		return ITEM_INTERACT_BLOCKING
	if(ismob(target))
		to_chat(user, "<span class='warning'>You can't label creatures!</span>") // use a collar
		return ITEM_INTERACT_BLOCKING

	if(mode == LABEL_MODE_GOAL)
		if(istype(target, /obj/item))
			to_chat(user, "<span class='warning'>Put it in a personal crate instead!</span>")
			return ITEM_INTERACT_BLOCKING
		user.visible_message("<span class='notice'>[user] labels [target] as part of a secondary goal for [label].</span>", \
							"<span class='notice'>You label [target] as part of a secondary goal for [label].</span>")
		target.AddComponent(/datum/component/label/goal, label)
		return ITEM_INTERACT_SUCCESS

	if(length(target.name) + length(label) > 64)
		to_chat(user, "<span class='warning'>Label too big!</span>")
		return ITEM_INTERACT_BLOCKING

	user.visible_message("<span class='notice'>[user] labels [target] as [label].</span>", \
						"<span class='notice'>You label [target] as [label].</span>")
	investigate_log("[key_name(user)] ([ADMIN_FLW(user,"FLW")]) labelled \"[target]\" ([ADMIN_VV(target, "VV")]) with \"[label]\" at [COORD(target.loc)] [ADMIN_JMP(target)].", INVESTIGATE_RENAME) // Investigate goes BEFORE rename so the original name is preserved in the log
	target.AddComponent(/datum/component/label, label)
	playsound(target, 'sound/items/handling/component_pickup.ogg', 20, TRUE)
	labels_left--
	return ITEM_INTERACT_SUCCESS

/obj/item/hand_labeler/activate_self(mob/user)
	if(..())
		return
	
	// off -> normal
	// normal or goal -> off
	mode = !mode
	icon_state = "labeler[mode]"
	if(mode)
		to_chat(user, "<span class='notice'>You turn on \the [src].</span>")
		//Now let them chose the text.
		var/str = reject_bad_text(tgui_input_text(user,"Label text?", "Set label"))
		if(!str || !length(str))
			to_chat(user, "<span class='notice'>Invalid text.</span>")
			return
		label = str
		to_chat(user, "<span class='notice'>You set the text to '[str]'.</span>")
	else
		to_chat(user, "<span class='notice'>You turn off \the [src].</span>")

/obj/item/hand_labeler/attack_by(obj/item/I, mob/user, params)
	if(..())
		return FINISH_ATTACK

	if(istype(I, /obj/item/hand_labeler_refill))
		to_chat(user, "<span class='notice'>You insert [I] into [src].</span>")
		user.drop_item()
		qdel(I)
		labels_left = initial(labels_left)	//Yes, it's capped at its initial value
	else if(istype(I, /obj/item/card/id))
		var/obj/item/card/id/id = I
		if(istype(id, /obj/item/card/id/guest) || !id.registered_name)
			to_chat(user, "<span class='warning'>Invalid ID card.</span>")
		else
			label = id.registered_name
			mode = LABEL_MODE_GOAL
			to_chat(user, "<span class='notice'>You configure the hand labeler with [I].</span>")
			icon_state = "labeler1"
	return FINISH_ATTACK

/obj/item/hand_labeler_refill
	name = "hand labeler paper roll"
	icon = 'icons/obj/bureaucracy.dmi'
	desc = "A roll of paper. Use it on a hand labeler to refill it."
	icon_state = "labeler_refill"
	item_state = "electropack"
	w_class = WEIGHT_CLASS_TINY

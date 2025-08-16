#define LABEL_MODE_OFF 0
#define LABEL_MODE_NORMAL 1
#define LABEL_MODE_GOAL 2

/obj/item/hand_labeler
	name = "hand labeler"
	desc = "A combined label printer, applicator, and remover, all in a single portable device. Designed to be easy to operate and use."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "labeler0"
	var/label = null
	var/labels_left = 30
	var/mode = LABEL_MODE_OFF
	new_attack_chain = TRUE

/obj/item/hand_labeler/examine(mob/user)
	. = ..()
	. += "<span class='notice'>There [labels_left == 1 ? "is" : "are"] [labels_left] label\s remaining.</span>"
	if(label)
		. += "<span class='notice'>The label is currently set to \"[label]\".</span>"

/obj/item/hand_labeler/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(iseffect(target))
		to_chat(user, "<span class='warning'>\The [target] doesn't seem solid enough to label!</span>")
		return ITEM_INTERACT_COMPLETE
	if(!mode == LABEL_MODE_OFF)
		apply_label(target, user)
		return ITEM_INTERACT_COMPLETE
	if(remove_label(target, user))
		return ITEM_INTERACT_COMPLETE

/obj/item/hand_labeler/proc/remove_label(atom/target, mob/living/user)
	if(SEND_SIGNAL(target, COMSIG_LABEL_REMOVE)) // sends a signal to label.dm
		playsound(target, 'sound/items/poster_ripped.ogg', 20, TRUE)
		to_chat(user, "<span class='warning'>You remove the label from [target].</span>")
		return TRUE

/obj/item/hand_labeler/proc/apply_label(atom/target, mob/living/user)
	if(!labels_left)
		to_chat(user, "<span class='warning'>No labels left!</span>")
		return
	if(!label || !length(label))
		to_chat(user, "<span class='warning'>No text set!</span>")
		return
	if(ismob(target))
		to_chat(user, "<span class='warning'>You can't label creatures!</span>") // use a collar
		return

	if(mode == LABEL_MODE_GOAL)
		if(isturf(target))
			to_chat(user, "<span class='warning'>You can't just claim a bit of [target] as yours!</span>")
			return
		user.visible_message("<span class='notice'>[user] labels [target] as part of a secondary goal for [label].</span>", \
							"<span class='notice'>You label [target] as part of a secondary goal for [label].</span>")
		target.AddComponent(/datum/component/label/goal, label)
		return

	if(length(target.name) + length(label) > 64)
		to_chat(user, "<span class='warning'>Label too big!</span>")
		return

	user.visible_message("<span class='notice'>[user] labels [target] as [label].</span>", \
						"<span class='notice'>You label [target] as [label].</span>")
	investigate_log("[key_name(user)] ([ADMIN_FLW(user,"FLW")]) labelled \"[target]\" ([ADMIN_VV(target, "VV")]) with \"[label]\" at [COORD(target.loc)] [ADMIN_JMP(target)].", INVESTIGATE_RENAME) // Investigate goes BEFORE rename so the original name is preserved in the log
	target.AddComponent(/datum/component/label, label)
	playsound(target, 'sound/items/handling/component_pickup.ogg', 20, TRUE)
	labels_left--

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

/obj/item/hand_labeler/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(..())
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/hand_labeler_refill))
		to_chat(user, "<span class='notice'>You insert [used] into [src].</span>")
		user.drop_item()
		qdel(used)
		labels_left = initial(labels_left)	//Yes, it's capped at its initial value
		return ITEM_INTERACT_COMPLETE
	else if(istype(used, /obj/item/card/id))
		var/obj/item/card/id/id = used
		if(istype(id, /obj/item/card/id/guest) || !id.registered_name)
			to_chat(user, "<span class='warning'>Invalid ID card.</span>")
			return ITEM_INTERACT_COMPLETE
		else
			label = id.registered_name
			mode = LABEL_MODE_GOAL
			to_chat(user, "<span class='notice'>You configure the hand labeler with [used].</span>")
			icon_state = "labeler1"
			return ITEM_INTERACT_COMPLETE

/obj/item/hand_labeler_refill
	name = "hand labeler paper roll"
	desc = "A roll of paper. Use it on a hand labeler to refill it."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "labeler_refill"
	inhand_icon_state = "electropack"
	w_class = WEIGHT_CLASS_TINY

#undef LABEL_MODE_OFF
#undef LABEL_MODE_NORMAL
#undef LABEL_MODE_GOAL

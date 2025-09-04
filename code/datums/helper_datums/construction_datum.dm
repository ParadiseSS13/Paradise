
/datum/construction
	var/list/steps
	var/atom/holder
	var/result
	var/index
	var/list/steps_desc
	///Path of job objective completed.
	var/taskpath

/datum/construction/New(atom)
	..()
	holder = atom
	if(!holder) //don't want this without a holder
		spawn
			qdel(src)
	set_desc(length(steps))
	return

/datum/construction/proc/next_step(mob/user as mob)
	steps.len--
	if(!length(steps))
		spawn_result(user)
	else
		set_desc(length(steps))
	return

/datum/construction/proc/action(atom/used_atom,mob/user as mob)
	return

/datum/construction/proc/check_step(atom/used_atom,mob/user as mob) //check last step only
	var/valid_step = is_right_key(used_atom)
	if(valid_step)
		if(custom_action(valid_step, used_atom, user))
			next_step(user)
			return 1
	return 0

/datum/construction/proc/is_right_key(atom/used_atom) // returns current step num if used_atom is of the right type.
	var/list/L = steps[length(steps)]
	if(do_tool_or_atom_check(used_atom, L["key"]))
		return length(steps)
	return 0


/datum/construction/proc/custom_action(step, used_atom, user)
	if(istype(used_atom, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = used_atom
		if(C.get_amount() < 4)
			to_chat(user, ("<span class='warning'>There's not enough cable to finish the task.</span>"))
			return 0
		else
			C.use(4)
			playsound(holder, C.usesound, 50, 1)
	else if(istype(used_atom, /obj/item/stack))
		var/obj/item/stack/S = used_atom
		if(S.get_amount() < 5)
			to_chat(user, ("<span class='warning'>There's not enough material in this stack.</span>"))
			return 0
		else
			S.use(5)
	else if(isitem(used_atom))
		var/obj/item/I = used_atom
		if(I.tool_behaviour in CONSTRUCTION_TOOL_BEHAVIOURS)
			if(!I.use_tool(holder, user, 0, volume = I.tool_volume))
				return 0
	return 1

/datum/construction/proc/check_all_steps(atom/used_atom,mob/user as mob) //check all steps, remove matching one.
	for(var/i=1;i<=length(steps);i++)
		var/list/L = steps[i]
		if(do_tool_or_atom_check(used_atom, L["key"]) && custom_action(i, used_atom, user))
			steps[i]=null;//stupid byond list from list removal...
			listclearnulls(steps)
			if(!length(steps))
				spawn_result(user)
			return 1
	return 0


/datum/construction/proc/spawn_result(mob/user, result_name)
	if(result)
		if(taskpath)
			var/datum/job_objective/task = user.mind.find_job_task(taskpath)
			if(istype(task))
				task.completed = TRUE

		new result(get_turf(holder))
		spawn()
			qdel(holder)
	return

/datum/construction/proc/set_desc(index as num)
	var/list/step = steps[index]
	holder.desc = step["desc"]
	return

/datum/construction/proc/try_consume(mob/user as mob, atom/used_atom, amount)
	if(amount > 0)
		// CABLES
		if(istype(used_atom,/obj/item/stack/cable_coil))
			var/obj/item/stack/cable_coil/coil=used_atom
			if(!coil.use(amount))
				to_chat(user, "<span class='warning'>You don't have enough cable! You need at least [amount] coils.</span>")
				return 0
		// TOOLS
		if(isitem(used_atom))
			var/obj/item/I = used_atom
			if(I.tool_behaviour in CONSTRUCTION_TOOL_BEHAVIOURS)
				if(!I.use(amount))
					return 0
		// STACKS
		if(istype(used_atom,/obj/item/stack))
			var/obj/item/stack/stack=used_atom
			if(stack.get_amount() < amount)
				to_chat(user, "<span class='warning'>You don't have enough [stack]! You need at least [amount].</span>")
				return 0
			stack.use(amount)
	return 1

/datum/construction/proc/do_tool_or_atom_check(used_atom, thing_to_check) //Checks if an atom is either a required thing; or if it's a required tool
	if(istype(used_atom, thing_to_check))
		return TRUE
	else if(isitem(used_atom))
		var/obj/item/I = used_atom
		if(I.tool_behaviour == thing_to_check)
			return TRUE

/datum/construction/reversible

/datum/construction/reversible/New(atom)
	..()
	index = length(steps)
	return

/datum/construction/reversible/proc/update_index(diff as num, mob/user as mob)
	index+=diff
	if(index==0)
		spawn_result(user)
	else
		set_desc(index)
	return

/datum/construction/reversible/is_right_key(atom/used_atom) // returns index step
	var/list/L = steps[index]
	if(do_tool_or_atom_check(used_atom, L["key"]))
		return CONSTRUCTION_PATH_FORWARDS //to the first step -> forward
	else if(L["backkey"] && do_tool_or_atom_check(used_atom, L["backkey"]))
		return CONSTRUCTION_PATH_BACKWARDS //to the last step -> backwards
	return 0

/datum/construction/reversible/check_step(atom/used_atom,mob/user as mob)
	var/diff = is_right_key(used_atom)
	if(diff)
		if(custom_action(index, diff, used_atom, user))
			update_index(diff, user)
			return 1
	return 0

/datum/construction/reversible/custom_action(index, diff, used_atom, user)
	if(!..(index,used_atom,user))
		return 0
	return 1

#define STATE_NEXT "next"
#define STATE_PREV "prev"

/datum/construction/reversible2
	var/base_icon = "durand"

/datum/construction/reversible2/New(atom)
	..()
	index = 1
	return

/datum/construction/reversible2/proc/update_index(diff as num, mob/user as mob)
	index-=diff
	if(index==steps.len+1)
		spawn_result(user)
	else
		set_desc(index)
	return

/datum/construction/reversible2/proc/update_icon()
	holder.icon_state="[base_icon]_[index]"

/datum/construction/reversible2/is_right_key(mob/user as mob,atom/used_atom) // returns index step
	var/list/state = steps[index]
	if(STATE_NEXT in state)
		var/list/step = state[STATE_NEXT]
		if(do_tool_or_atom_check(used_atom, step["key"]))
			//if(L["consume"] && !try_consume(used_atom,L["consume"]))
			//	return 0
			return CONSTRUCTION_PATH_FORWARDS //to the first step -> forward
	else if(STATE_PREV in state)
		var/list/step = state[STATE_PREV]
		if(do_tool_or_atom_check(used_atom, step["key"]))
			//if(L["consume"] && !try_consume(used_atom,L["consume"]))
			//	return 0
			return CONSTRUCTION_PATH_BACKWARDS //to the first step -> forward
	return 0

/datum/construction/reversible2/check_step(atom/used_atom,mob/user as mob)
	var/diff = is_right_key(user,used_atom)
	if(diff)
		if(custom_action(index, diff, used_atom, user))
			update_index(diff,user)
			update_icon()
			return 1
	return 0

/datum/construction/reversible2/proc/fixText(text,user)
	text = replacetext(text,"{USER}","[user]")
	text = replacetext(text,"{HOLDER}","[holder]")
	return text

/datum/construction/reversible2/custom_action(index, diff, used_atom, mob/user)
	if(!..(index,used_atom,user))
		return 0

	var/list/step = steps[index]
	var/list/state = step[diff==CONSTRUCTION_PATH_FORWARDS ? STATE_NEXT : STATE_PREV]
	user.visible_message(fixText(state["vis_msg"],user),fixText(state["self_msg"],user))

	if("delete" in state)
		qdel(used_atom)
	else if("spawn" in state)
		var/spawntype=state["spawn"]
		var/atom/A = new spawntype(holder.loc)
		if("amount" in state)
			if(istype(A,/obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C=A
				C.amount=state["amount"]
			if(istype(A,/obj/item/stack))
				var/obj/item/stack/S=A
				S.amount=state["amount"]

	return 1

/datum/construction/reversible2/action(used_atom,user)
	return check_step(used_atom,user)

#undef STATE_NEXT
#undef STATE_PREV

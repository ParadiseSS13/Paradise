/obj/item/robot_parts
	name = "robot parts"
	icon = 'icons/obj/robot_parts.dmi'
	inhand_icon_state = "buildpipe"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	var/list/part = null
	var/sabotaged = FALSE //Emagging limbs can have repercussions when installed as prosthetics.
	var/model_info = "Unbranded"

/obj/item/robot_parts/New(newloc, model)
	..(newloc)
	if(model_info && model)
		model_info = model
		var/datum/robolimb/R = GLOB.all_robolimbs[model]
		if(R)
			name = "[R.company] [initial(name)]"
			desc = "[R.desc]"
			if(icon_state in icon_states(R.icon))
				icon = R.icon
	else
		name = "robot [initial(name)]"

	AddComponent(/datum/component/surgery_initiator/limb, forced_surgery = /datum/surgery/attach_robotic_limb)

/obj/item/robot_parts/attack_self__legacy__attackchain(mob/user)
	var/choice = tgui_input_list(user, "Select the company appearance for this limb", "Limb Company Selection", GLOB.selectable_robolimbs)
	if(!choice)
		return
	if(loc != user)
		return
	model_info = choice
	to_chat(usr, "<span class='notice'>You change the company limb model to [choice].</span>")

/obj/item/robot_parts/l_arm
	name = "left arm"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "l_arm"
	part = list("l_arm","l_hand")

/obj/item/robot_parts/r_arm
	name = "right arm"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "r_arm"
	part = list("r_arm","r_hand")

/obj/item/robot_parts/l_leg
	name = "left leg"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "l_leg"
	part = list("l_leg","l_foot")

/obj/item/robot_parts/r_leg
	name = "right leg"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "r_leg"
	part = list("r_leg","r_foot")

/obj/item/robot_parts/chest
	name = "torso"
	desc = "A heavily reinforced case containing cyborg logic boards, with space for a standard power cell."
	icon_state = "chest"
	part = list("groin","chest")
	var/wired = FALSE
	var/obj/item/stock_parts/cell/cell = null

/obj/item/robot_parts/chest/Destroy()
	QDEL_NULL(cell)
	return ..()

/obj/item/robot_parts/head
	name = "head"
	desc = "A standard reinforced braincase, with spine-plugged neural socket and sensor gimbals."
	icon_state = "head"
	part = list("head")
	var/obj/item/flash/flash1 = null
	var/obj/item/flash/flash2 = null

/obj/item/robot_parts/head/Destroy()
	QDEL_NULL(flash1)
	QDEL_NULL(flash2)
	return ..()

/obj/item/robot_parts/robot_suit
	name = "endoskeleton"
	desc = "A complex metal backbone with standard limb sockets and pseudomuscle anchors."
	icon_state = "robo_suit"
	w_class = WEIGHT_CLASS_BULKY
	model_info = null
	var/obj/item/robot_parts/l_arm/l_arm = null
	var/obj/item/robot_parts/r_arm/r_arm = null
	var/obj/item/robot_parts/l_leg/l_leg = null
	var/obj/item/robot_parts/r_leg/r_leg = null
	var/obj/item/robot_parts/chest/chest = null
	var/obj/item/robot_parts/head/head = null

	var/created_name = ""
	var/mob/living/silicon/ai/forced_ai
	var/locomotion = 1
	var/lawsync = 1
	var/aisync = 1
	var/panel_locked = 1

/obj/item/robot_parts/robot_suit/New()
	..()
	update_icon(UPDATE_OVERLAYS)

/obj/item/robot_parts/robot_suit/Destroy()
	QDEL_NULL(l_arm)
	QDEL_NULL(r_arm)
	QDEL_NULL(l_leg)
	QDEL_NULL(r_leg)
	QDEL_NULL(chest)
	QDEL_NULL(head)
	forced_ai = null
	return ..()

/obj/item/robot_parts/robot_suit/attack_self__legacy__attackchain(mob/user)
	return

/obj/item/robot_parts/robot_suit/update_overlays()
	. = ..()
	if(l_arm)
		. += "l_arm+o"
	if(r_arm)
		. += "r_arm+o"
	if(chest)
		. += "chest+o"
	if(l_leg)
		. += "l_leg+o"
	if(r_leg)
		. += "r_leg+o"
	if(head)
		. += "head+o"

/obj/item/robot_parts/robot_suit/proc/check_completion()
	if(l_arm && r_arm)
		if(l_leg && r_leg)
			if(chest && head)
				SSblackbox.record_feedback("amount", "cyborg_frames_built", 1)
				return 1
	return 0

/obj/item/robot_parts/robot_suit/attackby__legacy__attackchain(obj/item/W, mob/user, params)
	..()
	if(istype(W, /obj/item/stack/sheet/metal) && !l_arm && !r_arm && !l_leg && !r_leg && !chest && !head)
		var/obj/item/stack/sheet/metal/M = W
		var/obj/item/ed209_assembly/B = new /obj/item/ed209_assembly
		B.forceMove(get_turf(src))
		to_chat(user, "You armed the robot frame")
		M.use(1)
		if(user.get_inactive_hand()==src)
			user.unequip(src)
			user.put_in_inactive_hand(B)
		qdel(src)
	if(istype(W, /obj/item/robot_parts/l_leg))
		if(l_leg)
			return
		user.drop_item()
		W.forceMove(src)
		l_leg = W
		update_icon(UPDATE_OVERLAYS)

	if(istype(W, /obj/item/robot_parts/r_leg))
		if(r_leg)
			return
		user.drop_item()
		W.forceMove(src)
		r_leg = W
		update_icon(UPDATE_OVERLAYS)

	if(istype(W, /obj/item/robot_parts/l_arm))
		if(l_arm)
			return
		user.drop_item()
		W.forceMove(src)
		l_arm = W
		update_icon(UPDATE_OVERLAYS)

	if(istype(W, /obj/item/robot_parts/r_arm))
		if(r_arm)
			return
		user.drop_item()
		W.forceMove(src)
		r_arm = W
		update_icon(UPDATE_OVERLAYS)

	if(istype(W, /obj/item/robot_parts/chest))
		var/obj/item/robot_parts/chest/CH = W
		if(chest)
			return
		if(CH.wired && CH.cell)
			user.drop_item()
			W.forceMove(src)
			chest = W
			update_icon(UPDATE_OVERLAYS)
		else if(!CH.wired)
			to_chat(user, "<span class='notice'>You need to attach wires to it first!</span>")
		else
			to_chat(user, "<span class='notice'>You need to attach a cell to it first!</span>")

	if(istype(W, /obj/item/robot_parts/head))
		var/obj/item/robot_parts/head/HD = W
		if(head)
			return
		if(HD.flash2 && HD.flash1)
			user.drop_item()
			W.forceMove(src)
			head = W
			update_icon(UPDATE_OVERLAYS)
		else
			to_chat(user, "<span class='notice'>You need to attach a flash to it first!</span>")

	if(istype(W, /obj/item/multitool))
		if(check_completion())
			Interact(user)
		else
			to_chat(user, "<span class='warning'>The endoskeleton must be assembled before debugging can begin!</span>")

	if(istype(W, /obj/item/mmi))
		var/obj/item/mmi/M = W
		if(check_completion())
			if(!isturf(loc))
				to_chat(user, "<span class='warning'>You can't put [M] in, the frame has to be standing on the ground to be perfectly precise.</span>")
				return
			if(!M.brainmob)
				to_chat(user, "<span class='warning'>Sticking an empty [M] into the frame would sort of defeat the purpose.</span>")
				return

			if(jobban_isbanned(M.brainmob, "Cyborg") || jobban_isbanned(M.brainmob, "nonhumandept"))
				to_chat(user, "<span class='warning'>This [W] is not fit to serve as a cyborg!</span>")
				return

			if(!M.brainmob.key)
				var/mob/dead/observer/G = M.brainmob.get_ghost()
				if(G)
					if(M.next_possible_ghost_ping < world.time)
						G.notify_cloning("Somebody is trying to borg you! Re-enter your corpse if you want to be borged!", 'sound/voice/liveagain.ogg', src)
						M.next_possible_ghost_ping = world.time + 30 SECONDS // Avoid spam
				else
					to_chat(user, "<span class='notice'>[M] is completely unresponsive; there's no point.</span>")
					return
				to_chat(user, "<span class='warning'>[M] is currently inactive. Try again later.</span>")
				return

			if(M.brainmob.stat == DEAD)
				to_chat(user, "<span class='warning'>Sticking a dead [M] into the frame would sort of defeat the purpose.</span>")
				return

			if(M.brainmob.mind?.has_antag_datum(/datum/antagonist/rev/head))
				to_chat(user, "<span class='warning'>The frame's firmware lets out a shrill sound, and flashes 'Abnormal Memory Engram'. It refuses to accept [M].</span>")
				return


			var/datum/ai_laws/laws_to_give

			if(!aisync)
				lawsync = FALSE

			var/mob/living/silicon/robot/O = new /mob/living/silicon/robot(get_turf(loc), unfinished = 1, connect_to_AI = aisync, ai_to_sync_to = forced_ai)
			if(!O)
				return

			user.drop_item()

			var/datum/job_objective/make_cyborg/task = user.mind.find_job_task(/datum/job_objective/make_cyborg)
			if(istype(task))
				task.completed = TRUE

			O.invisibility = 0
			//Transfer debug settings to new mob
			O.custom_name = created_name
			O.rename_character(O.real_name, O.get_default_name())
			O.locked = panel_locked

			if(laws_to_give)
				O.laws = laws_to_give
			else if(!lawsync)
				O.lawupdate = FALSE
				O.make_laws()

			M.brainmob.mind.transfer_to(O)

			if(O.mind && O.mind.special_role && !M.syndiemmi)
				O.mind.store_memory("As a cyborg, you must obey your silicon laws and master AI above all else. Your objectives will consider you to be dead.")
				to_chat(O, "<span class='userdanger'>You have been robotized!</span>")
				to_chat(O, "<span class='danger'>You must obey your silicon laws and master AI above all else. Your objectives will consider you to be dead.</span>")

			O.job = "Cyborg"

			var/datum/robot_component/cell_component = O.components["power cell"]
			cell_component.install(chest.cell)
			chest.cell = null

			M.forceMove(O) //Should fix cybros run time erroring when blown up. It got deleted before, along with the frame.
			O.mmi = W
			if(O.mmi.syndiemmi)
				O.syndiemmi_override()
				to_chat(O, "<span class='warning'>ALERT: Foreign hardware detected.</span>")
				to_chat(O, "<span class='warning'>ERRORERRORERROR</span>")
				to_chat(O, "<span class='boldwarning'>Obey these laws:</span>")
				O.laws.show_laws(O)
			O.Namepick()

			SSblackbox.record_feedback("amount", "cyborg_birth", 1)

			forceMove(O)
			O.robot_suit = src

			if(!locomotion)
				O.SetLockdown(TRUE)
				to_chat(O, "<span class='danger'>Error: Servo motors unresponsive. Lockdown enabled.</span>")

		else
			to_chat(user, "<span class='warning'>The MMI must go in after everything else!</span>")

	if(is_pen(W))
		to_chat(user, "<span class='warning'>You need to use a multitool to name [src]!</span>")
	return

/obj/item/robot_parts/robot_suit/proc/Interact(mob/user)
			var/t1 = "Designation: <A href='byond://?src=[UID()];Name=1'>[(created_name ? "[created_name]" : "Default Cyborg")]</a><br>\n"
			t1 += "Master AI: <A href='byond://?src=[UID()];Master=1'>[(forced_ai ? "[forced_ai.name]" : "Automatic")]</a><br><br>\n"

			t1 += "LawSync Port: <A href='byond://?src=[UID()];Law=1'>[(lawsync ? "Open" : "Closed")]</a><br>\n"
			t1 += "AI Connection Port: <A href='byond://?src=[UID()];AI=1'>[(aisync ? "Open" : "Closed")]</a><br>\n"
			t1 += "Servo Motor Functions: <A href='byond://?src=[UID()];Loco=1'>[(locomotion ? "Unlocked" : "Locked")]</a><br>\n"
			t1 += "Panel Lock: <A href='byond://?src=[UID()];Panel=1'>[(panel_locked ? "Engaged" : "Disengaged")]</a><br>\n"
			var/datum/browser/popup = new(user, "robotdebug", "Cyborg Boot Debug", 310, 220)
			popup.set_content(t1)
			popup.open()

/obj/item/robot_parts/robot_suit/Topic(href, href_list)
	var/mob/living/living_user = usr
	if(HAS_TRAIT(living_user, TRAIT_HANDS_BLOCKED) || living_user.stat || !Adjacent(living_user))
		return
	var/obj/item/item_in_hand = living_user.get_active_hand()
	if(!istype(item_in_hand, /obj/item/multitool))
		to_chat(living_user, "<span class='warning'>You need a multitool!</span>")
		return

	if(href_list["Name"])
		var/new_name = reject_bad_name(input(usr, "Enter new designation. Set to blank to reset to default.", "Cyborg Debug", created_name),1)
		if(!in_range(src, usr) && loc != usr)
			return
		if(new_name)
			created_name = new_name
		else
			created_name = ""

	else if(href_list["Master"])
		forced_ai = select_active_ai(usr)
		if(!forced_ai)
			to_chat(usr, "<span class='error'>No active AIs detected.</span>")

	else if(href_list["Law"])
		lawsync = !lawsync
	else if(href_list["AI"])
		aisync = !aisync
	else if(href_list["Loco"])
		locomotion = !locomotion
	else if(href_list["Panel"])
		panel_locked = !panel_locked

	add_fingerprint(usr)
	Interact(usr)
	return

/obj/item/robot_parts/chest/attackby__legacy__attackchain(obj/item/W as obj, mob/user as mob, params)
	..()
	if(istype(W, /obj/item/stock_parts/cell))
		if(cell)
			to_chat(user, "<span class='notice'>You have already inserted a cell!</span>")
			return
		else
			user.drop_item()
			W.forceMove(src)
			cell = W
			to_chat(user, "<span class='notice'>You insert the cell!</span>")
	if(istype(W, /obj/item/stack/cable_coil))
		if(wired)
			to_chat(user, "<span class='notice'>You have already inserted wire!</span>")
			return
		else
			var/obj/item/stack/cable_coil/coil = W
			coil.use(1)
			wired = TRUE
			to_chat(user, "<span class='notice'>You insert the wire!</span>")
	return

/obj/item/robot_parts/head/attackby__legacy__attackchain(obj/item/W as obj, mob/user as mob, params)
	..()
	if(istype(W, /obj/item/flash))
		if(isrobot(user))
			to_chat(user, "<span class='warning'>How do you propose to do that?</span>")
			return
		else if(flash1 && flash2)
			to_chat(user, "<span class='notice'>You have already inserted the eyes!</span>")
			return
		else if(flash1)
			user.drop_item()
			W.forceMove(src)
			flash2 = W
			to_chat(user, "<span class='notice'>You insert the flash into the eye socket!</span>")
		else
			user.drop_item()
			W.forceMove(src)
			flash1 = W
			to_chat(user, "<span class='notice'>You insert the flash into the eye socket!</span>")
	else if(istype(W, /obj/item/stock_parts/manipulator))
		to_chat(user, "<span class='notice'>You install some manipulators and modify the head, creating a functional spider-bot!</span>")
		new /mob/living/basic/spiderbot(get_turf(loc))
		user.drop_item()
		qdel(W)
		qdel(src)

/obj/item/robot_parts/emag_act(user)
	if(sabotaged)
		to_chat(user, "<span class='warning'>[src] is already sabotaged!</span>")
	else
		to_chat(user, "<span class='warning'>You slide the emag into the dataport on [src] and short out the safeties.</span>")
		sabotaged = TRUE
		return TRUE

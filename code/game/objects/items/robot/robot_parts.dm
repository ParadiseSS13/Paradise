/obj/item/robot_parts
	name = "robot parts"
	icon = 'icons/obj/robot_parts.dmi'
	item_state = "buildpipe"
	icon_state = "blank"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	var/list/part = null
	var/sabotaged = 0 //Emagging limbs can have repercussions when installed as prosthetics.
	var/model_info
	dir = SOUTH


/obj/item/robot_parts/New(var/newloc, var/model)
	..(newloc)
	if(model_info && model)
		model_info = model
		var/datum/robolimb/R = all_robolimbs[model]
		if(R)
			name = "[R.company] [initial(name)]"
			desc = "[R.desc]"
			if(icon_state in icon_states(R.icon))
				icon = R.icon
	else
		name = "robot [initial(name)]"

/obj/item/robot_parts/l_arm
	name = "left arm"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "l_arm"
	part = list("l_arm","l_hand")
	model_info = 1

/obj/item/robot_parts/r_arm
	name = "right arm"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "r_arm"
	part = list("r_arm","r_hand")
	model_info = 1

/obj/item/robot_parts/l_leg
	name = "left leg"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "l_leg"
	part = list("l_leg","l_foot")
	model_info = 1

/obj/item/robot_parts/r_leg
	name = "right leg"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "r_leg"
	part = list("r_leg","r_foot")
	model_info = 1

/obj/item/robot_parts/chest
	name = "torso"
	desc = "A heavily reinforced case containing cyborg logic boards, with space for a standard power cell."
	icon_state = "chest"
	part = list("groin","chest")
	var/wires = 0.0
	var/obj/item/weapon/stock_parts/cell/cell = null

/obj/item/robot_parts/head
	name = "head"
	desc = "A standard reinforced braincase, with spine-plugged neural socket and sensor gimbals."
	icon_state = "head"
	part = list("head")
	var/obj/item/device/flash/flash1 = null
	var/obj/item/device/flash/flash2 = null

/obj/item/robot_parts/robot_suit
	name = "endoskeleton"
	desc = "A complex metal backbone with standard limb sockets and pseudomuscle anchors."
	icon_state = "robo_suit"
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
	src.updateicon()

/obj/item/robot_parts/robot_suit/proc/updateicon()
	src.overlays.Cut()
	if(src.l_arm)
		src.overlays += "l_arm+o"
	if(src.r_arm)
		src.overlays += "r_arm+o"
	if(src.chest)
		src.overlays += "chest+o"
	if(src.l_leg)
		src.overlays += "l_leg+o"
	if(src.r_leg)
		src.overlays += "r_leg+o"
	if(src.head)
		src.overlays += "head+o"

/obj/item/robot_parts/robot_suit/proc/check_completion()
	if(src.l_arm && src.r_arm)
		if(src.l_leg && src.r_leg)
			if(src.chest && src.head)
				feedback_inc("cyborg_frames_built",1)
				return 1
	return 0

/obj/item/robot_parts/robot_suit/attackby(obj/item/W as obj, mob/user as mob, params)
	..()
	if(istype(W, /obj/item/stack/sheet/metal) && !l_arm && !r_arm && !l_leg && !r_leg && !chest && !head)
		var/obj/item/weapon/ed209_assembly/B = new /obj/item/weapon/ed209_assembly
		B.loc = get_turf(src)
		to_chat(user, "You armed the robot frame")
		W:use(1)
		if(user.get_inactive_hand()==src)
			user.unEquip(src)
			user.put_in_inactive_hand(B)
		qdel(src)
	if(istype(W, /obj/item/robot_parts/l_leg))
		if(src.l_leg)	return
		user.drop_item()
		W.loc = src
		src.l_leg = W
		src.updateicon()

	if(istype(W, /obj/item/robot_parts/r_leg))
		if(src.r_leg)	return
		user.drop_item()
		W.loc = src
		src.r_leg = W
		src.updateicon()

	if(istype(W, /obj/item/robot_parts/l_arm))
		if(src.l_arm)	return
		user.drop_item()
		W.loc = src
		src.l_arm = W
		src.updateicon()

	if(istype(W, /obj/item/robot_parts/r_arm))
		if(src.r_arm)	return
		user.drop_item()
		W.loc = src
		src.r_arm = W
		src.updateicon()

	if(istype(W, /obj/item/robot_parts/chest))
		if(src.chest)	return
		if(W:wires && W:cell)
			user.drop_item()
			W.loc = src
			src.chest = W
			src.updateicon()
		else if(!W:wires)
			to_chat(user, "\blue You need to attach wires to it first!")
		else
			to_chat(user, "\blue You need to attach a cell to it first!")

	if(istype(W, /obj/item/robot_parts/head))
		if(src.head)	return
		if(W:flash2 && W:flash1)
			user.drop_item()
			W.loc = src
			src.head = W
			src.updateicon()
		else
			to_chat(user, "\blue You need to attach a flash to it first!")

	if(istype(W, /obj/item/device/multitool))
		if(check_completion())
			Interact(user)
		else
			to_chat(user, "<span class='warning'>The endoskeleton must be assembled before debugging can begin!</span>")

	if(istype(W, /obj/item/device/mmi))
		var/obj/item/device/mmi/M = W
		if(check_completion())
			if(!istype(loc,/turf))
				to_chat(user, "\red You can't put \the [W] in, the frame has to be standing on the ground to be perfectly precise.")
				return
			if(!M.brainmob)
				to_chat(user, "\red Sticking an empty [W] into the frame would sort of defeat the purpose.")
				return

			if(!M.brainmob.key)
				var/ghost_can_reenter = 0
				if(M.brainmob.mind)
					for(var/mob/dead/observer/G in player_list)
						if(G.can_reenter_corpse && G.mind == M.brainmob.mind)
							ghost_can_reenter = 1
							break
					for(var/mob/living/simple_animal/S in player_list)
						if(S in respawnable_list)
							ghost_can_reenter = 1
							break
				if(!ghost_can_reenter)
					to_chat(user, "<span class='notice'>\The [W] is completely unresponsive; there's no point.</span>")
					return

			if(M.brainmob.stat == DEAD)
				to_chat(user, "\red Sticking a dead [W] into the frame would sort of defeat the purpose.")
				return

			if(M.brainmob.mind in ticker.mode.head_revolutionaries)
				to_chat(user, "\red The frame's firmware lets out a shrill sound, and flashes 'Abnormal Memory Engram'. It refuses to accept the [W].")
				return

			if(jobban_isbanned(M.brainmob, "Cyborg") || jobban_isbanned(M.brainmob,"nonhumandept"))
				to_chat(user, "\red This [W] does not seem to fit.")
				return

			var/mob/living/silicon/robot/O = new /mob/living/silicon/robot(get_turf(loc), unfinished = 1)
			if(!O)	return

			user.drop_item()

			var/datum/job_objective/make_cyborg/task = user.mind.findJobTask(/datum/job_objective/make_cyborg)
			if(istype(task))
				task.unit_completed()

			if(M.syndiemmi)
				aisync = 0
				lawsync = 0
				O.laws = new /datum/ai_laws/syndicate_override

			O.invisibility = 0
			//Transfer debug settings to new mob
			O.custom_name = created_name
			O.rename_character(O.real_name, O.get_default_name())
			O.locked = panel_locked
			if(!aisync)
				lawsync = 0
				O.connected_ai = null
			else
				O.notify_ai(1)
				if(forced_ai)
					O.connected_ai = forced_ai
			if(!lawsync && !M.syndiemmi)
				O.lawupdate = 0
				O.make_laws()

			M.brainmob.mind.transfer_to(O)

			if(O.mind && O.mind.special_role)
				O.mind.store_memory("As a cyborg, you must obey your silicon laws and master AI above all else. Your objectives will consider you to be dead.")
				to_chat(O, "<span class='userdanger'>You have been robotized!</span>")
				to_chat(O, "<span class='danger'>You must obey your silicon laws and master AI above all else. Your objectives will consider you to be dead.</span>")

			O.job = "Cyborg"

			O.cell = chest.cell
			chest.cell.loc = O
			chest.cell = null
			W.loc = O//Should fix cybros run time erroring when blown up. It got deleted before, along with the frame.
			// Since we "magically" installed a cell, we also have to update the correct component.
			if(O.cell)
				var/datum/robot_component/cell_component = O.components["power cell"]
				cell_component.wrapped = O.cell
				cell_component.installed = 1
			O.mmi = W
			O.Namepick()

			feedback_inc("cyborg_birth",1)
			callHook("borgify", list(O))

			src.loc = O

			if(!locomotion)
				O.lockcharge = 1
				O.update_canmove()
				to_chat(O, "<span class='warning'>Error: Servo motors unresponsive.</span>")

		else
			to_chat(user, "<span class='warning'>The MMI must go in after everything else!</span>")

	if(istype(W,/obj/item/weapon/pen))
		to_chat(user, "<span class='warning'>You need to use a multitool to name [src]!</span>")
	return

/obj/item/robot_parts/robot_suit/proc/Interact(mob/user)
			var/t1 = "Designation: <A href='?src=[UID()];Name=1'>[(created_name ? "[created_name]" : "Default Cyborg")]</a><br>\n"
			t1 += "Master AI: <A href='?src=[UID()];Master=1'>[(forced_ai ? "[forced_ai.name]" : "Automatic")]</a><br><br>\n"

			t1 += "LawSync Port: <A href='?src=[UID()];Law=1'>[(lawsync ? "Open" : "Closed")]</a><br>\n"
			t1 += "AI Connection Port: <A href='?src=[UID()];AI=1'>[(aisync ? "Open" : "Closed")]</a><br>\n"
			t1 += "Servo Motor Functions: <A href='?src=[UID()];Loco=1'>[(locomotion ? "Unlocked" : "Locked")]</a><br>\n"
			t1 += "Panel Lock: <A href='?src=[UID()];Panel=1'>[(panel_locked ? "Engaged" : "Disengaged")]</a><br>\n"
			var/datum/browser/popup = new(user, "robotdebug", "Cyborg Boot Debug", 310, 220)
			popup.set_content(t1)
			popup.open()

/obj/item/robot_parts/robot_suit/Topic(href, href_list)
	if(usr.lying || usr.stat || usr.stunned || !Adjacent(usr))
		return

	var/mob/living/living_user = usr
	var/obj/item/item_in_hand = living_user.get_active_hand()
	if(!istype(item_in_hand, /obj/item/device/multitool))
		to_chat(living_user, "<span class='warning'>You need a multitool!</span>")
		return

	if(href_list["Name"])
		var/new_name = reject_bad_name(input(usr, "Enter new designation. Set to blank to reset to default.", "Cyborg Debug", src.created_name),1)
		if(!in_range(src, usr) && src.loc != usr)
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

/obj/item/robot_parts/chest/attackby(obj/item/W as obj, mob/user as mob, params)
	..()
	if(istype(W, /obj/item/weapon/stock_parts/cell))
		if(src.cell)
			to_chat(user, "\blue You have already inserted a cell!")
			return
		else
			user.drop_item()
			W.loc = src
			src.cell = W
			to_chat(user, "\blue You insert the cell!")
	if(istype(W, /obj/item/stack/cable_coil))
		if(src.wires)
			to_chat(user, "\blue You have already inserted wire!")
			return
		else
			var/obj/item/stack/cable_coil/coil = W
			coil.use(1)
			src.wires = 1.0
			to_chat(user, "\blue You insert the wire!")
	return

/obj/item/robot_parts/head/attackby(obj/item/W as obj, mob/user as mob, params)
	..()
	if(istype(W, /obj/item/device/flash))
		if(istype(user,/mob/living/silicon/robot))
			to_chat(user, "\red How do you propose to do that?")
			return
		else if(src.flash1 && src.flash2)
			to_chat(user, "\blue You have already inserted the eyes!")
			return
		else if(src.flash1)
			user.drop_item()
			W.loc = src
			src.flash2 = W
			to_chat(user, "\blue You insert the flash into the eye socket!")
		else
			user.drop_item()
			W.loc = src
			src.flash1 = W
			to_chat(user, "\blue You insert the flash into the eye socket!")
	else if(istype(W, /obj/item/weapon/stock_parts/manipulator))
		to_chat(user, "\blue You install some manipulators and modify the head, creating a functional spider-bot!")
		new /mob/living/simple_animal/spiderbot(get_turf(loc))
		user.drop_item()
		qdel(W)
		qdel(src)
		return
	return

/obj/item/robot_parts/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W,/obj/item/weapon/card/emag))
		if(sabotaged)
			to_chat(user, "\red [src] is already sabotaged!")
		else
			to_chat(user, "\red You slide [W] into the dataport on [src] and short out the safeties.")
			sabotaged = 1
		return
	..()

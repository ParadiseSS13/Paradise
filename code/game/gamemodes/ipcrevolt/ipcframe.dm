/obj/item/ipc_frame
	name = "\improper IPC frame"
	icon = 'icons/mob/human_races/r_machine.dmi'
	icon_state = "unfinished_m"
	var/obj/item/device/mmi/brain = null
	var/obj/item/organ/cell/microbattery = null
	var/wired = 0
	var/ipcname = ""

/obj/item/ipc_frame/New()
	..()
	if(prob(70))
		ipcname = "[pick(list("PBU","HIU","SINA","ARMA","OSI"))]-[rand(100, 999)]"
	else
		ipcname = pick(ai_names)

/obj/item/ipc_frame/attackby(obj/item/W as obj, mob/user as mob, params)
	..()
	if(istype(W, /obj/item/organ/cell))
		if(src.microbattery)
			user << "<span class='danger'>\The [src] already has a microbattery!</span>"
			return
		user.drop_item()
		W.loc = src
		src.microbattery = W
		user << "<span class='notice'>You insert \the [W] into \the [src]</span>"
	if(istype(W, /obj/item/device/mmi))
		if(src.brain)
			user << "<span class='danger'>\The [src] already has a [src.brain]! Use a crowbar to remove it.</span>"
		var/obj/item/device/mmi/M = W
		if(!M.brainmob || !M.brainmob.client || !M.brainmob.ckey || M.brainmob.stat >= DEAD)
			user << "<span class='danger'>That brain is not usable</span>"
			return
		user.drop_item()
		M.loc = src
		src.brain = M
		user << "<span class='notice'>You insert \the [W] into \the [src]</span>"
	if(istype(W, /obj/item/weapon/wirecutters))
		if(!wired)
			return
		playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1)
		user << "<span class='notice'>You remove the cables.</span>"
		wired = 0
		var/obj/item/stack/cable_coil/A = new /obj/item/stack/cable_coil(src.loc,5)
		A.amount = 5
	if(istype(W, /obj/item/weapon/crowbar))
		if(brain == null && microbattery == null)
			return
		playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
		if(brain)
			user << "<span class='notice'>You remove \the [brain]!</span>"
			brain.loc = src.loc
			brain = null
			return
		user << "<span class='notice'>You remove the \the [microbattery]!</span>"
		microbattery.loc = src.loc
		microbattery = null
		return
	if(istype(W, /obj/item/stack/cable_coil))
		if(wired)
			user << "<span class='danger'>\The [src] already has cable!</span>"
			return
		var/obj/item/stack/cable_coil/C = W
		if(C.amount >= 5)
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
			C.use(5)
			user << "<span class='notice'>You add cables to the frame.</span>"
			wired = 1
		else
			user << "<span class='warning'>You need five length of cable to wire the frame.</span>"
			return
	if(istype(W, /obj/item/stack/sheet/plasteel))
		if(!istype(src.loc,/turf))
			user << "\red You can't complete the IPC, it has to be standing on the ground."
			return
		var/obj/item/stack/sheet/plasteel/P = W
		P.use(1)
		user << "<span class='notice'>You add the plasteel</span>"
		var/mob/living/carbon/human/O = new /mob/living/carbon/human/machine(src.loc)
		O.fully_replace_character_name(null,ipcname)
		O.rename_self("IPC",allow_numbers=1)
		O.lying = 1
		var/obj/item/organ/external/chest/ipc/chest = O.organs_by_name["chest"]
		var/obj/item/organ/organ = O.organs_by_name["l_hand"]
		organ.removed(null)
		qdel(organ)
		organ = O.organs_by_name["r_hand"]
		organ.removed(null)
		qdel(organ)
		organ = O.organs_by_name["l_foot"]
		organ.removed(null)
		qdel(organ)
		organ = O.organs_by_name["r_foot"]
		organ.removed(null)
		qdel(organ)
		organ = O.organs_by_name["l_leg"]
		organ.removed(null)
		qdel(organ)
		organ = O.organs_by_name["r_leg"]
		organ.removed(null)
		qdel(organ)
		organ = O.organs_by_name["l_arm"]
		organ.removed(null)
		qdel(organ)
		organ = O.organs_by_name["r_arm"]
		organ.removed(null)
		qdel(organ)
		organ = O.organs_by_name["head"]
		organ.removed(null)
		qdel(organ)
		organ = O.internal_organs_by_name["brain"]
		organ.removed(null)
		qdel(organ)
		if (!microbattery)
			organ = O.internal_organs_by_name["cell"]
			organ.removed(null)
			qdel(organ)

		if(brain != null)
			var/obj/item/organ/mmi_holder/holder = new(O, 1)
			if(istype(brain, /obj/item/device/mmi/posibrain))
				holder.robotize()

			O.internal_organs_by_name["brain"] = holder
			brain.forceMove(holder)
			holder.stored_mmi = brain
			holder.update_from_mmi()
			if(brain.brainmob && brain.brainmob.mind)
				brain.brainmob.mind.transfer_to(O)
		O.handle_organs()
		qdel(src)
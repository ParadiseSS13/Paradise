//Cloning revival method.
//The pod handles the actual cloning while the computer manages the clone profiles

//Potential replacement for genetics revives or something I dunno (?)

#define CLONE_BIOMASS 150

/obj/machinery/clonepod
	anchored = 1
	name = "cloning pod"
	desc = "An electronically-lockable pod for growing organic tissue."
	density = 1
	icon = 'icons/obj/cloning.dmi'
	icon_state = "pod_0"
	req_access = list(access_genetics) //For premature unlocking.
	var/mob/living/occupant
	var/heal_level = 90 //The clone is released once its health reaches this level.
	var/locked = 0
	var/obj/machinery/computer/cloning/connected = null //So we remember the connected clone machine.
	var/mess = 0 //Need to clean out it if it's full of exploded clone.
	var/attempting = 0 //One clone attempt at a time thanks
	var/eject_wait = 0 //Don't eject them as soon as they are created fuckkk
	var/biomass = 0
	var/speed_coeff
	var/efficiency

	light_color = LIGHT_COLOR_PURE_GREEN
	power_change()
		..()
		if(!(stat & (BROKEN|NOPOWER)))
			set_light(2)
		else
			set_light(0)

/obj/machinery/clonepod/biomass
	biomass = CLONE_BIOMASS

/obj/machinery/clonepod/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/clonepod(null)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module(null)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()
	update_icon()

/obj/machinery/clonepod/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/clonepod(null)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module/phasic(null)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module/phasic(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	biomass = CLONE_BIOMASS
	RefreshParts()

/obj/machinery/clonepod/Destroy()
	if(connected)
		connected.pods -= src
	..()

/obj/machinery/clonepod/RefreshParts()
	speed_coeff = 0
	efficiency = 0
	for(var/obj/item/weapon/stock_parts/scanning_module/S in component_parts)
		efficiency += S.rating
	for(var/obj/item/weapon/stock_parts/manipulator/P in component_parts)
		speed_coeff += P.rating
	heal_level = min((efficiency * 15) + 10, 100)

//The return of data disks?? Just for transferring between genetics machine/cloning machine.
//TO-DO: Make the genetics machine accept them.
/obj/item/weapon/disk/data
	name = "Cloning Data Disk"
	icon = 'icons/obj/cloning.dmi'
	icon_state = "datadisk0" //Gosh I hope syndies don't mistake them for the nuke disk.
	item_state = "card-id"
	w_class = 1.0
	var/datum/dna2/record/buf=null
	var/read_only = 0 //Well,it's still a floppy disk

/obj/item/weapon/disk/data/proc/Initialize()
	buf = new
	buf.dna=new

/obj/item/weapon/disk/data/demo
	name = "data disk - 'God Emperor of Mankind'"
	read_only = 1

	New()
		Initialize()
		buf.types=DNA2_BUF_UE|DNA2_BUF_UI
		//data = "066000033000000000AF00330660FF4DB002690"
		//data = "0C80C80C80C80C80C8000000000000161FBDDEF" - Farmer Jeff
		buf.dna.real_name="God Emperor of Mankind"
		buf.dna.unique_enzymes = md5(buf.dna.real_name)
		buf.dna.UI=list(0x066,0x000,0x033,0x000,0x000,0x000,0xAF0,0x033,0x066,0x0FF,0x4DB,0x002,0x690)
		//buf.dna.UI=list(0x0C8,0x0C8,0x0C8,0x0C8,0x0C8,0x0C8,0x000,0x000,0x000,0x000,0x161,0xFBD,0xDEF) // Farmer Jeff
		buf.dna.UpdateUI()

/obj/item/weapon/disk/data/monkey
	name = "data disk - 'Mr. Muggles'"
	read_only = 1

	New()
		Initialize()
		buf.types=DNA2_BUF_SE
		var/list/new_SE=list(0x098,0x3E8,0x403,0x44C,0x39F,0x4B0,0x59D,0x514,0x5FC,0x578,0x5DC,0x640,0x6A4)
		for(var/i=new_SE.len;i<=DNA_SE_LENGTH;i++)
			new_SE += rand(1,1024)
		buf.dna.SE=new_SE
		buf.dna.SetSEValueRange(MONKEYBLOCK,0xDAC, 0xFFF)


//Find a dead mob with a brain and client.
/proc/find_dead_player(var/find_key)
	if (isnull(find_key))
		return

	var/mob/selected = null
	for(var/mob/M in player_list)
		//Dead people only thanks!
		if ((M.stat != 2) || (!M.client))
			continue
		//They need a brain!
		if ((istype(M, /mob/living/carbon/human)) && (M:brain_op_stage >= 4.0))
			continue

		if (M.ckey == find_key)
			selected = M
			break
	return selected

//Disk stuff.
/obj/item/weapon/disk/data/New()
	..()
	var/diskcolor = pick(0,1,2)
	src.icon_state = "datadisk[diskcolor]"

/obj/item/weapon/disk/data/attack_self(mob/user as mob)
	src.read_only = !src.read_only
	user << "You flip the write-protect tab to [src.read_only ? "protected" : "unprotected"]."

/obj/item/weapon/disk/data/examine()
	set src in oview(5)
	..()
	usr << text("The write-protect tab is set to [src.read_only ? "protected" : "unprotected"].")
	return

//Health Tracker Implant

/obj/item/weapon/implant/health
	name = "health implant"
	var/healthstring = ""

/obj/item/weapon/implant/health/proc/sensehealth()
	if (!src.implanted)
		return "ERROR"
	else
		if(isliving(src.implanted))
			var/mob/living/L = src.implanted
			src.healthstring = "[round(L.getOxyLoss())] - [round(L.getFireLoss())] - [round(L.getToxLoss())] - [round(L.getBruteLoss())]"
		if (!src.healthstring)
			src.healthstring = "ERROR"
		return src.healthstring

/obj/machinery/clonepod/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/clonepod/attack_hand(mob/user as mob)
	if ((isnull(src.occupant)) || (stat & NOPOWER))
		return
	if ((!isnull(src.occupant)) && (src.occupant.stat != 2))
		var/completion = (100 * ((src.occupant.health + 100) / (src.heal_level + 100)))
		user << "Current clone cycle is [round(completion)]% complete."
	return

//Clonepod

//Start growing a human clone in the pod!
/obj/machinery/clonepod/proc/growclone(var/datum/dna2/record/R)
	if(mess || attempting || panel_open)
		return 0
	var/datum/mind/clonemind = locate(R.mind)
	if(!istype(clonemind))	//not a mind
		return 0
	if( clonemind.current && clonemind.current.stat != DEAD )	//mind is associated with a non-dead body
		return 0
	if(clonemind.active)	//somebody is using that mind
		if( ckey(clonemind.key)!=R.ckey )
			return 0
	else
		for(var/mob/M in player_list)
			if(M.ckey == R.ckey)
				if(istype(M, /mob/dead/observer))
					var/mob/dead/observer/G = M
					if(G.can_reenter_corpse)
						break
				if(istype(M, /mob/living/simple_animal))
					if(M in respawnable_list)
						break
				return 0

	if(biomass >= CLONE_BIOMASS)
		src.biomass -= CLONE_BIOMASS
	else
		return 0

	src.attempting = 1 //One at a time!!
	src.locked = 1

	src.eject_wait = 1
	spawn(30)
		src.eject_wait = 0

	var/mob/living/carbon/human/H = new /mob/living/carbon/human(src, R.dna.species)
	occupant = H

	if(!R.dna.real_name)	//to prevent null names
		R.dna.real_name = "clone ([rand(0,999)])"
	H.real_name = R.dna.real_name

	//Get the clone body ready
	H.adjustCloneLoss(190) //new damage var so you can't eject a clone early then stab them to abuse the current damage system --NeoFite
	H.adjustBrainLoss(90) // The rand(10, 30) will come out as extra brain damage
	H.Paralyse(4)

	//Here let's calculate their health so the pod doesn't immediately eject them!!!
	H.updatehealth()

	clonemind.transfer_to(H)
	H.ckey = R.ckey
	H << "<span class='notice'><b>Consciousness slowly creeps over you as your body regenerates.</b><br><i>So this is what cloning feels like?</i></span>"

	// -- Mode/mind specific stuff goes here
	callHook("clone", list(H))

	if((H.mind in ticker.mode:revolutionaries) || (H.mind in ticker.mode:head_revolutionaries))
		ticker.mode.update_all_rev_icons() //So the icon actually appears
	if(H.mind in ticker.mode.syndicates)
		ticker.mode.update_all_synd_icons()
	if (H.mind in ticker.mode.cult)
		ticker.mode.add_cult_viewpoint(H)
		ticker.mode.add_cultist(src.occupant.mind)
		ticker.mode.update_all_cult_icons() //So the icon actually appears
	if(("\ref[H.mind]" in ticker.mode.implanter) || (H.mind in ticker.mode.implanted))
		ticker.mode.update_traitor_icons_added(H.mind) //So the icon actually appears
	if(("\ref[H.mind]" in ticker.mode.vampire_thralls) || (H.mind in ticker.mode.vampire_enthralled))
		ticker.mode.update_vampire_icons_added(H.mind)
 	if(("\ref[H.mind]" in ticker.mode.shadowling_thralls) || (H.mind in ticker.mode.shadows))
 		ticker.mode.update_shadow_icons_added(H.mind)

	// -- End mode specific stuff

	if(!R.dna)
		H.dna = new /datum/dna()
		H.dna.real_name = H.real_name
	else
		H.dna=R.dna
	H.UpdateAppearance()
	if(efficiency > 2 && efficiency < 5 && prob(25))
		randmutb(H)
	if(efficiency > 5 && prob(20))
		randmutg(H)
	if(efficiency < 3 && prob(50))
		randmutb(H)
	H.dna.UpdateSE()
	H.dna.UpdateUI()

/* //let's not make people waste even more time after being cloned.
	H.f_style = "Shaved"
	if(R.dna.species == "Human") //no more xenos losing ears/tentacles
		H.h_style = pick("Bedhead", "Bedhead 2", "Bedhead 3") */

	H.set_species(R.dna.species)

	update_icon()

	for(var/datum/language/L in R.languages)
		H.add_language(L.name)

	H.suiciding = 0
	src.attempting = 0
	return 1

//Grow clones to maturity then kick them out.  FREELOADERS
/obj/machinery/clonepod/process()

	if(stat & NOPOWER) //Autoeject if power is lost
		if (src.occupant)
			src.locked = 0
			src.go_out()
		return

	if((src.occupant) && (src.occupant.loc == src))
		if((src.occupant.stat == DEAD) || (src.occupant.suiciding) || !occupant.key)  //Autoeject corpses and suiciding dudes.
			src.locked = 0
			src.go_out()
			src.connected_message("Clone Rejected: Deceased.")
			return

		else if(src.occupant.cloneloss > (100 - src.heal_level))
			src.occupant.Paralyse(4)

			 //Slowly get that clone healed and finished.
			src.occupant.adjustCloneLoss(-((speed_coeff/2)))

			//Premature clones may have brain damage.
			src.occupant.adjustBrainLoss(-((speed_coeff/20)*efficiency))

			//So clones don't die of oxyloss in a running pod.
			if (src.occupant.reagents.get_reagent_amount("salbutamol") < 5)
				src.occupant.reagents.add_reagent("salbutamol", 5)

			//Also heal some oxyloss ourselves just in case!!
			src.occupant.adjustOxyLoss(-4)

			use_power(7500) //This might need tweaking.
			return

		else if((src.occupant.cloneloss <= (100 - src.heal_level)) && (!src.eject_wait))
			src.connected_message("Cloning Process Complete.")
			src.locked = 0
			src.go_out()
			return

	else if ((!src.occupant) || (src.occupant.loc != src))
		src.occupant = null
		if (src.locked)
			src.locked = 0
		//use_power(200)
		return

	return

//Let's unlock this early I guess.  Might be too early, needs tweaking.
/obj/machinery/clonepod/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if (istype(W, /obj/item/weapon/screwdriver))
		if(occupant || mess || locked)
			user << "<span class='notice'>The maintenance panel is locked.</span>"
			return
		default_deconstruction_screwdriver(user, "[icon_state]_maintenance", "[initial(icon_state)]", W)
		return

	if(exchange_parts(user, W))
		return

	if(istype(W, /obj/item/weapon/crowbar))
		if(panel_open)
			default_deconstruction_crowbar(W)
		return

	if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if (!src.check_access(W))
			user << "\red Access Denied."
			return
		if ((!src.locked) || (isnull(src.occupant)))
			return
		if ((src.occupant.health < -20) && (src.occupant.stat != 2))
			user << "\red Access Refused."
			return
		else
			src.locked = 0
			user << "System unlocked."

//Removing cloning pod biomass
	else if (istype(W, /obj/item/weapon/reagent_containers/food/snacks/meat))
		user << "\blue \The [src] processes \the [W]."
		biomass += 50
		user.drop_item()
		qdel(W)
		return
	else if (istype(W, /obj/item/weapon/wrench))
		if(src.locked && (src.anchored || src.occupant))
			user << "\red Can not do that while [src] is in use."
		else
			if(src.anchored)
				src.anchored = 0
				connected.pods -= src
				connected = null
			else
				src.anchored = 1
			playsound(src.loc, 'sound/items/Ratchet.ogg', 100, 1)
			if(anchored)
				user.visible_message("[user] secures [src] to the floor.", "You secure [src] to the floor.")
			else
				user.visible_message("[user] unsecures [src] from the floor.", "You unsecure [src] from the floor.")
	else if(istype(W, /obj/item/device/multitool))
		var/obj/item/device/multitool/M = W
		M.buffer = src
		user << "<span class='notice'>You load connection data from [src] to [M].</span>"
		return
	else
		..()

/obj/machinery/clonepod/emag_act(user as mob)
	if (isnull(src.occupant))
		return
	user << "You force an emergency ejection."
	src.locked = 0
	src.go_out()
	return

//Put messages in the connected computer's temp var for display.
/obj/machinery/clonepod/proc/connected_message(var/message)
	if ((isnull(src.connected)) || (!istype(src.connected, /obj/machinery/computer/cloning)))
		return 0
	if (!message)
		return 0

	src.connected.temp = "[name] : [message]"
	src.connected.updateUsrDialog()
	return 1

/obj/machinery/clonepod/verb/eject()
	set name = "Eject Cloner"
	set category = "Object"
	set src in oview(1)

	if(!usr)
		return
	if (usr.stat != 0)
		return
	src.go_out(usr)
	add_fingerprint(usr)
	return

/obj/machinery/clonepod/proc/go_out(user)
	if (src.mess) //Clean that mess and dump those gibs!
		src.mess = 0
		gibs(src.loc)
		update_icon()
		return

	if (!(src.occupant))
		user << "<span class=\"warning\">The cloning pod is empty!</span>"
		return

	if (src.locked)
		user << "<span class=\"warning\">The cloning pod is locked!</span>"
		return

	if (src.occupant.client)
		src.occupant.client.eye = src.occupant.client.mob
		src.occupant.client.perspective = MOB_PERSPECTIVE
	src.occupant.loc = src.loc
	src.eject_wait = 0 //If it's still set somehow.
	domutcheck(src.occupant) //Waiting until they're out before possible notransform.
	src.occupant = null
	update_icon()
	return

/obj/machinery/clonepod/proc/malfunction()
	if(src.occupant)
		src.connected_message("Critical Error!")
		src.mess = 1
		update_icon()
		src.occupant.ghostize()
		spawn(5)
			qdel(src.occupant)
	return

/obj/machinery/clonepod/update_icon()
	..()
	icon_state = "pod_0"
	if (occupant && !(stat & NOPOWER))
		icon_state = "pod_1"
	else if (mess && !panel_open)
		icon_state = "pod_g"

/obj/machinery/clonepod/relaymove(mob/user as mob)
	if (user.stat)
		return
	src.go_out()
	return

/obj/machinery/clonepod/emp_act(severity)
	if(prob(100/(severity*efficiency))) malfunction()
	..()

/obj/machinery/clonepod/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.loc
				ex_act(severity)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				qdel(src)
				return
		if(3.0)
			if (prob(25))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				qdel(src)
				return
		else
	return

/*
 *	Diskette Box
 */

/obj/item/weapon/storage/box/disks
	name = "Diskette Box"
	icon_state = "disk_kit"

/obj/item/weapon/storage/box/disks/New()
	..()
	new /obj/item/weapon/disk/data(src)
	new /obj/item/weapon/disk/data(src)
	new /obj/item/weapon/disk/data(src)
	new /obj/item/weapon/disk/data(src)
	new /obj/item/weapon/disk/data(src)
	new /obj/item/weapon/disk/data(src)
	new /obj/item/weapon/disk/data(src)

/*
 *	Manual -- A big ol' manual.
 */

/obj/item/weapon/paper/Cloning
	name = "paper - 'H-87 Cloning Apparatus Manual"
	info = {"<h4>Getting Started</h4>
	Congratulations, your station has purchased the H-87 industrial cloning device!<br>
	Using the H-87 is almost as simple as brain surgery! Simply insert the target humanoid into the scanning chamber and select the scan option to create a new profile!<br>
	<b>That's all there is to it!</b><br>
	<i>Notice, cloning system cannot scan inorganic life or small primates.  Scan may fail if subject has suffered extreme brain damage.</i><br>
	<p>Clone profiles may be viewed through the profiles menu. Scanning implants a complementary HEALTH MONITOR IMPLANT into the subject, which may be viewed from each profile.
	Profile Deletion has been restricted to \[Station Head\] level access.</p>
	<h4>Cloning from a profile</h4>
	Cloning is as simple as pressing the CLONE option at the bottom of the desired profile.<br>
	Per your company's EMPLOYEE PRIVACY RIGHTS agreement, the H-87 has been blocked from cloning crewmembers while they are still alive.<br>
	<br>
	<p>The provided CLONEPOD SYSTEM will produce the desired clone.  Standard clone maturation times (With SPEEDCLONE technology) are roughly 90 seconds.
	The cloning pod may be unlocked early with any \[Medical Researcher\] ID after initial maturation is complete.</p><br>
	<i>Please note that resulting clones may have a small DEVELOPMENTAL DEFECT as a result of genetic drift.</i><br>
	<h4>Profile Management</h4>
	<p>The H-87 (as well as your station's standard genetics machine) can accept STANDARD DATA DISKETTES.
	These diskettes are used to transfer genetic information between machines and profiles.
	A load/save dialog will become available in each profile if a disk is inserted.</p><br>
	<i>A good diskette is a great way to counter aforementioned genetic drift!</i><br>
	<br>
	<font size=1>This technology produced under license from Thinktronic Systems, LTD.</font>"}

//SOME SCRAPS I GUESS
/* EMP grenade/spell effect
		if(istype(A, /obj/machinery/clonepod))
			A:malfunction()
*/

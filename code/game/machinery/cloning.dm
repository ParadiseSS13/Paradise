//Cloning revival method.
//The pod handles the actual cloning while the computer manages the clone profiles

//Potential replacement for genetics revives or something I dunno (?)

#define CLONE_BIOMASS 150
#define BIOMASS_MEAT_AMOUNT 50

/obj/machinery/clonepod
	anchored = 1
	name = "cloning pod"
	desc = "An electronically-lockable pod for growing organic tissue."
	density = 1
	icon = 'icons/obj/cloning.dmi'
	icon_state = "pod_0"
	req_access = list(access_genetics) //For premature unlocking.
	var/mob/living/carbon/human/occupant
	var/heal_level = 90 //The clone is released once its health reaches this level.
	var/locked = 0
	var/obj/machinery/computer/cloning/connected = null //So we remember the connected clone machine.
	var/mess = 0 //Need to clean out it if it's full of exploded clone.
	var/attempting = 0 //One clone attempt at a time thanks
	var/eject_wait = 0 //Don't eject them as soon as they are created fuckkk
	var/biomass = 0
	var/speed_coeff
	var/efficiency

	var/datum/mind/clonemind
	var/grab_ghost_when = CLONER_MATURE_CLONE

	var/obj/item/device/radio/Radio
	var/radio_announce = 0

	var/obj/effect/countdown/clonepod/countdown

	light_color = LIGHT_COLOR_PURE_GREEN

/obj/machinery/clonepod/power_change()
	..()
	if(!(stat & (BROKEN|NOPOWER)))
		set_light(2)
	else
		set_light(0)

/obj/machinery/clonepod/biomass
	biomass = CLONE_BIOMASS

/obj/machinery/clonepod/New()
	..()
	countdown = new(src)

	Radio = new /obj/item/device/radio(src)
	Radio.listening = 0
	Radio.config(list("Medical" = 0))

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
	if(Radio)
		qdel(Radio)
		Radio = null
	if(countdown)
		qdel(countdown)
		countdown = null
	return ..()

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
	w_class = 1
	var/datum/dna2/record/buf=null
	var/read_only = 0 //Well,it's still a floppy disk

/obj/item/weapon/disk/data/proc/Initialize()
	buf = new
	buf.dna=new

/obj/item/weapon/disk/data/demo
	name = "data disk - 'God Emperor of Mankind'"
	read_only = 1

/obj/item/weapon/disk/data/demo/New()
	Initialize()
	buf.types=DNA2_BUF_UE|DNA2_BUF_UI
	//data = "066000033000000000AF00330660FF4DB002690"
	//data = "0C80C80C80C80C80C8000000000000161FBDDEF" - Farmer Jeff
	buf.dna.real_name="God Emperor of Mankind"
	buf.dna.unique_enzymes = md5(buf.dna.real_name)
	buf.dna.UI=list(0x066,0x000,0x033,0x000,0x000,0x000,0xAF0,0x000,0x000,0x000,0x000,0x000,0x000,0x000,0x000,0x000,0x033,0x066,0x0FF,0x4DB,0x002,0x690,0x000,0x000)
	//buf.dna.UI=list(0x0C8,0x0C8,0x0C8,0x0C8,0x0C8,0x0C8,0x000,0x000,0x000,0x000,0x161,0xFBD,0xDEF) // Farmer Jeff
	buf.dna.UpdateUI()

/obj/item/weapon/disk/data/monkey
	name = "data disk - 'Mr. Muggles'"
	read_only = 1

/obj/item/weapon/disk/data/monkey/New()
	Initialize()
	buf.types=DNA2_BUF_SE
	var/list/new_SE=list(0x098,0x3E8,0x403,0x44C,0x39F,0x4B0,0x59D,0x514,0x5FC,0x578,0x5DC,0x640,0x6A4)
	for(var/i=new_SE.len;i<=DNA_SE_LENGTH;i++)
		new_SE += rand(1,1024)
	buf.dna.SE=new_SE
	buf.dna.SetSEValueRange(MONKEYBLOCK,0xDAC, 0xFFF)

//Disk stuff.
/obj/item/weapon/disk/data/New()
	..()
	var/diskcolor = pick(0,1,2)
	icon_state = "datadisk[diskcolor]"

/obj/item/weapon/disk/data/attack_self(mob/user as mob)
	read_only = !read_only
	to_chat(user, "You flip the write-protect tab to [read_only ? "protected" : "unprotected"].")

/obj/item/weapon/disk/data/examine(mob/user)
	..(user)
	to_chat(user, "The write-protect tab is set to [read_only ? "protected" : "unprotected"].")


//Health Tracker Implant

/obj/item/weapon/implant/health
	name = "health implant"
	var/healthstring = ""

/obj/item/weapon/implant/health/proc/sensehealth()
	if(!implanted)
		return "ERROR"
	else
		if(isliving(implanted))
			var/mob/living/L = implanted
			healthstring = "[round(L.getOxyLoss())] - [round(L.getFireLoss())] - [round(L.getToxLoss())] - [round(L.getBruteLoss())]"
		if(!healthstring)
			healthstring = "ERROR"
		return healthstring

//Clonepod

/obj/machinery/clonepod/examine(mob/user)
	..()
	if(mess)
		to_chat(user, "It's filled with blood and viscera. You swear you can see it moving...")
	if(!occupant || stat & (NOPOWER|BROKEN))
		return
	if(occupant && occupant.stat != DEAD)
		to_chat(user,  "Current clone cycle is [round(get_completion())]% complete.")

/obj/machinery/clonepod/proc/get_completion()
	. = (100 * ((occupant.health + 100) / (heal_level + 100)))

/obj/machinery/clonepod/attack_ai(mob/user)
	return examine(user)

//Radio Announcement

/obj/machinery/clonepod/proc/announce_radio_message(message)
	if(radio_announce)
		Radio.autosay(message, name, "Medical", list(z))


//Start growing a human clone in the pod!
/obj/machinery/clonepod/proc/growclone(datum/dna2/record/R)
	if(mess || attempting || panel_open || stat & (NOPOWER|BROKEN))
		return 0
	clonemind = locate(R.mind)
	if(!istype(clonemind))	//not a mind
		return 0
	if( clonemind.current && clonemind.current.stat != DEAD )	//mind is associated with a non-dead body
		return 0
	if(clonemind.active)	//somebody is using that mind
		if(ckey(clonemind.key) != R.ckey)
			return 0
	else
		// get_ghost() will fail if they're unable to reenter their body
		var/mob/dead/observer/G = clonemind.get_ghost()
		if(!G)
			return 0

	if(biomass >= CLONE_BIOMASS)
		biomass -= CLONE_BIOMASS
	else
		return 0

	attempting = 1 //One at a time!!
	locked = 1
	countdown.start()

	eject_wait = 1
	spawn(30)
		eject_wait = 0

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

	if(grab_ghost_when == CLONER_FRESH_CLONE)
		clonemind.transfer_to(H)
		H.ckey = R.ckey
		to_chat(H, {"<span class='notice'><b>Consciousness slowly creeps over you
			as your body regenerates.</b><br><i>So this is what cloning
			feels like?</i></span>"})
	else if(grab_ghost_when == CLONER_MATURE_CLONE)
		to_chat(clonemind.current, {"<span class='notice'>Your body is
			beginning to regenerate in a cloning pod. You will
			become conscious when it is complete.</span>"})

	// -- Mode/mind specific stuff goes here
	callHook("clone", list(H))

	if((H.mind in ticker.mode:revolutionaries) || (H.mind in ticker.mode:head_revolutionaries))
		ticker.mode.update_rev_icons_added() //So the icon actually appears
	if(H.mind in ticker.mode.syndicates)
		ticker.mode.update_synd_icons_added()
	if(H.mind in ticker.mode.cult)
		ticker.mode.add_cult_viewpoint(H)
		ticker.mode.add_cultist(occupant.mind)
		ticker.mode.update_cult_icons_added() //So the icon actually appears
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
		H.dna.ready_dna(H)
	else
		H.dna = R.dna.Clone()
	if(efficiency > 2 && efficiency < 5 && prob(25))
		randmutb(H)
	if(efficiency > 5 && prob(20))
		randmutg(H)
	if(efficiency < 3 && prob(50))
		randmutb(H)
	H.dna.UpdateSE()
	H.dna.UpdateUI()

	H.set_species(R.dna.species)
	H.sync_organ_dna(1) // It's literally a fresh body as you can get, so all organs properly belong to it
	H.UpdateAppearance()

	H.update_body()
	update_icon()

	for(var/datum/language/L in R.languages)
		H.add_language(L.name)

	H.suiciding = 0
	attempting = 0
	return 1

//Grow clones to maturity then kick them out.  FREELOADERS
/obj/machinery/clonepod/process()
	var/show_message = 0
	for(var/obj/item/weapon/reagent_containers/food/snacks/meat/meat in range(1, src))
		qdel(meat)
		biomass += BIOMASS_MEAT_AMOUNT
		show_message = 1
	if(show_message)
		visible_message("[src] sucks in and processes the nearby biomass.")

	if(stat & NOPOWER) //Autoeject if power is lost
		if(occupant)
			locked = 0
			go_out()
			connected_message("Clone Ejected: Loss of power.")

	else if((occupant) && (occupant.loc == src))
		if((occupant.stat == DEAD) || (occupant.suiciding))  //Autoeject corpses and suiciding dudes.
			locked = 0
			announce_radio_message("The cloning of <b>[occupant]</b> has been aborted due to unrecoverable tissue failure.")
			go_out()
			connected_message("Clone Rejected: Deceased.")

		else if(occupant.cloneloss > (100 - heal_level))
			occupant.Paralyse(4)

			 //Slowly get that clone healed and finished.
			occupant.adjustCloneLoss(-((speed_coeff/2)))

			//Premature clones may have brain damage.
			occupant.adjustBrainLoss(-((speed_coeff/20)*efficiency))

			//So clones don't die of oxyloss in a running pod.
			if(occupant.reagents.get_reagent_amount("salbutamol") < 5)
				occupant.reagents.add_reagent("salbutamol", 5)

			//Also heal some oxyloss ourselves just in case!!
			occupant.adjustOxyLoss(-4)

			use_power(7500) //This might need tweaking.

		else if((occupant.cloneloss <= (100 - heal_level)) && (!eject_wait))
			connected_message("Cloning Process Complete.")
			announce_radio_message("The cloning cycle of <b>[occupant]</b> is complete.")
			locked = 0
			go_out()

	else if((!occupant) || (occupant.loc != src))
		occupant = null
		if(locked)
			locked = 0
		update_icon()
		use_power(200)

//Let's unlock this early I guess.  Might be too early, needs tweaking.
/obj/machinery/clonepod/attackby(obj/item/weapon/W, mob/user, params)
	if(!(occupant || mess || locked))
		if(default_deconstruction_screwdriver(user, "[icon_state]_maintenance", "[initial(icon_state)]", W))
			return

	if(exchange_parts(user, W))
		return

	if(default_deconstruction_crowbar(W))
		return

	if(W.GetID())
		if(!check_access(W))
			to_chat(user, "<span class='danger'>Access Denied.</span>")
			return
		if (!locked || !occupant)
			return
		if(occupant.health < -20 && occupant.stat != DEAD)
			to_chat(user, "<span class='danger'>Access Refused. Patient status still unstable.</span>")
			return
		else
			locked = 0
			to_chat(user, "System unlocked.")

//Removing cloning pod biomass
	else if(istype(W, /obj/item/weapon/reagent_containers/food/snacks/meat))
		to_chat(user, "\blue \The [src] processes \the [W].")
		biomass += BIOMASS_MEAT_AMOUNT
		user.drop_item()
		qdel(W)
		return
	else if(istype(W, /obj/item/weapon/wrench))
		if(locked && (anchored || occupant))
			to_chat(user, "\red Can not do that while [src] is in use.")
		else
			if(anchored)
				anchored = 0
				connected.pods -= src
				connected = null
			else
				anchored = 1
			playsound(loc, 'sound/items/Ratchet.ogg', 100, 1)
			if(anchored)
				user.visible_message("[user] secures [src] to the floor.", "You secure [src] to the floor.")
			else
				user.visible_message("[user] unsecures [src] from the floor.", "You unsecure [src] from the floor.")
	else if(istype(W, /obj/item/device/multitool))
		var/obj/item/device/multitool/M = W
		M.buffer = src
		to_chat(user, "<span class='notice'>You load connection data from [src] to [M].</span>")
		return
	else
		..()

/obj/machinery/clonepod/emag_act(user)
	if(isnull(occupant))
		return
	to_chat(user, "You force an emergency ejection.")
	locked = 0
	go_out()

//Put messages in the connected computer's temp var for display.
/obj/machinery/clonepod/proc/connected_message(message)
	if((isnull(connected)) || (!istype(connected, /obj/machinery/computer/cloning)))
		return 0
	if(!message)
		return 0

	connected.temp = "[name] : [message]"
	connected.updateUsrDialog()
	return 1

/obj/machinery/clonepod/verb/eject()
	set name = "Eject Cloner"
	set category = "Object"
	set src in oview(1)

	if(!usr)
		return
	if(usr.incapacitated())
		return
	go_out()
	add_fingerprint(usr)

/obj/machinery/clonepod/proc/go_out()
	if(locked)
		return
	countdown.stop()

	if(mess) //Clean that mess and dump those gibs!
		mess = 0
		gibs(loc)
		playsound(loc, 'sound/effects/splat.ogg', 50, 1)
		update_icon()
		return

	if(!occupant)
		return

	if(grab_ghost_when == CLONER_MATURE_CLONE)
		clonemind.transfer_to(occupant)
		occupant.grab_ghost()
		to_chat(occupant, "<span class='notice'><b>There is a bright flash!</b><br>\
			<i>You feel like a new being.</i></span>")
		occupant.flash_eyes(visual = 1)

	occupant.forceMove(get_turf(src))
	eject_wait = 0 //If it's still set somehow.
	domutcheck(occupant) //Waiting until they're out before possible notransform.
	occupant.shock_stage = 0 //Reset Shock
	occupant = null
	update_icon()

/obj/machinery/clonepod/proc/malfunction()
	if(occupant)
		connected_message("Critical Error!")
		announce_radio_message("Critical error! Please contact a Thinktronic Systems technician, as your warranty may be affected.")
		mess = 1
		update_icon()
		if(occupant.mind != clonemind)
			clonemind.transfer_to(occupant)
		occupant.grab_ghost() // We really just want to make you suffer.
		to_chat(occupant, {"<span class='warning'><b>Agony blazes across your
			consciousness as your body is torn apart.</b><br>
			<i>Is this what dying is like? Yes it is.</i></span>"})
		playsound(loc, 'sound/machines/warning-buzzer.ogg', 50, 0)
		occupant << sound('sound/hallucinations/veryfar_noise.ogg',0,1,50)
		spawn(40)
			qdel(occupant)

/obj/machinery/clonepod/update_icon()
	..()
	icon_state = "pod_0"
	if(occupant && !(stat & NOPOWER))
		icon_state = "pod_1"
	else if(mess && !panel_open)
		icon_state = "pod_g"

/obj/machinery/clonepod/relaymove(mob/user)
	if(user.stat == CONSCIOUS)
		go_out()

/obj/machinery/clonepod/emp_act(severity)
	if(prob(100/(severity*efficiency))) malfunction()
	..()

/obj/machinery/clonepod/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.forceMove(src.loc)
				A.ex_act(severity)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.forceMove(src.loc)
					A.ex_act(severity)
				qdel(src)
				return
		if(3.0)
			if(prob(25))
				for(var/atom/movable/A as mob|obj in src)
					A.forceMove(src.loc)
					A.ex_act(severity)
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

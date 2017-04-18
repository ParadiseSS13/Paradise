//Cloning revival method.
//The pod handles the actual cloning while the computer manages the clone profiles

//Potential replacement for genetics revives or something I dunno (?)

//#define CLONE_BIOMASS 150
//#define BIOMASS_MEAT_AMOUNT 50
#define MEAT_NEEDED_TO_CLONE	16
#define MAXIMUM_MEAT_LEVEL		100
#define MEAT_USED_PER_TICK		0.6
#define MEAT_LOW_LEVEL			MAXIMUM_MEAT_LEVEL * 0.15
#define MAX_FAILED_CLONE_TICKS	200 // vOv

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
	//var/biomass = 0

	var/meat_level = 0
	var/failed_tick_counter = 0 // goes up while someone is stuck in there and there's not enough meat to clone them, after so many ticks they'll get dumped out

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
	meat_level = MAXIMUM_MEAT_LEVEL / 4

/obj/machinery/clonepod/New()
	..()
	countdown = new(src)

	Radio = new /obj/item/device/radio(src)
	Radio.listening = 0
	Radio.config(list("Medical" = 0))

	create_reagents(100)

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
	meat_level = MAXIMUM_MEAT_LEVEL / 4
	RefreshParts()

/obj/machinery/clonepod/Destroy()
	if(connected)
		connected.pods -= src
	QDEL_NULL(Radio)
	QDEL_NULL(countdown)
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
	icon_state = "datadisk0" //Gosh I hope syndies don't mistake them for the nuke disk.
	var/datum/dna2/record/buf = null
	var/read_only = 0 //Well,it's still a floppy disk

/obj/item/weapon/disk/data/proc/Initialize()
	buf = new
	buf.dna=new

/obj/item/weapon/disk/data/Destroy()
	QDEL_NULL(buf)
	return ..()

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
	buf.dna.UI=list(0x066,0x000,0x033,0x000,0x000,0x000,0x000,0x000,0x000,0x000,0x000,0x000,0xAF0,0x000,0x000,0x000,0x000,0x000,0x000,0x000,0x000,0x000,0x033,0x066,0x0FF,0x4DB,0x002,0x690,0x000,0x000,0x000,0x328,0x045,0x5FC,0x053,0x035,0x035,0x035)
	//buf.dna.UI=list(0x0C8,0x0C8,0x0C8,0x0C8,0x0C8,0x0C8,0x000,0x000,0x000,0x000,0x161,0xFBD,0xDEF) // Farmer Jeff
	if(buf.dna.UI.len != DNA_UI_LENGTH) //If there's a disparity b/w the dna UI string lengths, 0-fill the extra blocks in this UI.
		for(var/i in buf.dna.UI.len to DNA_UI_LENGTH)
			buf.dna.UI += 0x000
	buf.dna.ResetSE()
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

	to_chat(user, "Biomatter reserves are [round(100 * meat_level / MAXIMUM_MEAT_LEVEL)]% full.")

	if(meat_level <= 0)
		to_chat(user, "<span class='warning'>Alert: Biomatter reserves depleted.</span>")
	else if(meat_level <= MEAT_LOW_LEVEL)
		to_chat(user, "<span class='warning'>Alert: Biomatter reserves low.</span>")

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
	if(clonemind.current && clonemind.current.stat != DEAD)	//mind is associated with a non-dead body
		return 0
	if(clonemind.active)	//somebody is using that mind
		if(ckey(clonemind.key) != R.ckey)
			return 0
	else
		// get_ghost() will fail if they're unable to reenter their body
		var/mob/dead/observer/G = clonemind.get_ghost()
		if(!G)
			return 0

	if(meat_level < MEAT_NEEDED_TO_CLONE)
		connected_message("Insufficient biomatter to begin.")
		return 0

	attempting = 1 //One at a time!!
	locked = 1
	failed_tick_counter = 0 // make sure we start here
	countdown.start()

	eject_wait = 1
	spawn(30)
		eject_wait = 0

	if(!R.dna)
		R.dna = new /datum/dna()

	var/mob/living/carbon/human/H = new /mob/living/carbon/human(src, R.dna.species)
	occupant = H

	if(!R.dna.real_name)	//to prevent null names
		R.dna.real_name = H.real_name
	else
		H.real_name = R.dna.real_name

	H.dna = R.dna.Clone()

	for(var/datum/language/L in R.languages)
		H.add_language(L.name)

	//Get the clone body ready
	H.adjustCloneLoss(190) //new damage var so you can't eject a clone early then stab them to abuse the current damage system --NeoFite
	H.adjustBrainLoss(90) // The rand(10, 30) will come out as extra brain damage
	H.Paralyse(4)

	//Here let's calculate their health so the pod doesn't immediately eject them!!!
	H.updatehealth()

	if(grab_ghost_when == CLONER_FRESH_CLONE)
		clonemind.transfer_to(H)
		H.ckey = R.ckey
		update_clone_antag(H) //Since the body's got the mind, update their antag stuff right now. Otherwise, wait until they get kicked out (as per the CLONER_MATURE_CLONE business) to do it.
		to_chat(H, {"<span class='notice'><b>Consciousness slowly creeps over you
			as your body regenerates.</b><br><i>So this is what cloning
			feels like?</i></span>"})
	else if(grab_ghost_when == CLONER_MATURE_CLONE)
		to_chat(clonemind.current, {"<span class='notice'>Your body is
			beginning to regenerate in a cloning pod. You will
			become conscious when it is complete.</span>"})

	domutcheck(H, null, MUTCHK_FORCED) //Ensures species that get powers by the species proc handle_dna keep them

	if(efficiency > 2 && efficiency < 5 && prob(25))
		randmutb(H)
	if(efficiency > 5 && prob(20))
		randmutg(H)
	if(efficiency < 3 && prob(50))
		randmutb(H)

	H.dna.UpdateSE()
	H.dna.UpdateUI()

	H.sync_organ_dna(1) // It's literally a fresh body as you can get, so all organs properly belong to it
	H.UpdateAppearance()

	update_icon()

	H.suiciding = 0
	attempting = 0

	if(reagents && reagents.total_volume)
		reagents.reaction(occupant, 2, 1000)
		reagents.trans_to(occupant, 1000)

	return 1

//Grow clones to maturity then kick them out.  FREELOADERS
/obj/machinery/clonepod/process()
	if(stat & NOPOWER) //Autoeject if power is lost
		if(occupant)
			locked = 0
			go_out()
			connected_message("Clone Ejected: Loss of power.")
		return

	if(occupant && occupant.loc == src)
		if(occupant.stat == DEAD || occupant.suiciding) // Autoeject corpses and suiciding dudes.
			locked = 0
			announce_radio_message("The cloning of <b>[occupant]</b> has been aborted due to unrecoverable tissue failure.")
			go_out()
			connected_message("Clone Rejected: Deceased.")
			return

		if(failed_tick_counter >= MAX_FAILED_CLONE_TICKS) // you been in there too long, get out
			locked = 0
			announce_radio_message("The cloning of <b>[occupant]</b> has been aborted due to low biomatter.")
			go_out()
			connected_message("Clone Ejected: Low Biomatter.")
			return

		if(meat_level <= 0)
			failed_tick_counter++
			if(failed_tick_counter == (MAX_FAILED_CLONE_TICKS / 2)) // halfway to ejection.
				connected_message("Low Biomatter: Preparing to Eject Clone")
				announce_radio_message("Low Biomatter: Preparing to Eject <b>[occupant]</b>")
				use_power(200)
				return

		if(occupant.cloneloss > (100 - heal_level))
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

			meat_level = round(max(0, meat_level - MEAT_USED_PER_TICK), 0.1)
			if(meat_level <= 0)
				connected_message("Additional biomatter required to continue.")
				announce_radio_message("Low Biomatter.")
				visible_message("<span class='danger'>[src] emits an urgent boop!</span>")
				playsound(loc, 'sound/machines/buzz-two.ogg', 50, 0)
				failed_tick_counter++

			use_power(7500) //This might need tweaking.

		else if(occupant.cloneloss <= (100 - heal_level) && !eject_wait)
			connected_message("Cloning Process Complete.")
			announce_radio_message("The cloning cycle of <b>[occupant]</b> is complete.")
			locked = 0
			go_out()
			return

	else
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
			playsound(loc, W.usesound, 100, 1)
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

var/list/clonepod_accepted_reagents = list("blood" = 0.5, "synthflesh" = 1, "beff" = 0.75, "pepperoni" = 0.5, "meatslurry" = 1)
/obj/machinery/clonepod/on_reagent_change()
	for(var/datum/reagent/R in reagents.reagent_list)
		if(R && R.id in clonepod_accepted_reagents)
			meat_level = round(min(meat_level + (R.volume * clonepod_accepted_reagents[R.id]), MAXIMUM_MEAT_LEVEL), 0.1)
			reagents.del_reagent(R.id)

	if(occupant)
		reagents.reaction(occupant, 1000) // why was there a 2 here? it was injecting ice cold reagents that burn people
		reagents.trans_to(occupant, 1000)

/obj/machinery/clonepod/emag_act(user)
	if(isnull(occupant))
		return
	to_chat(user, "You force an emergency ejection.")
	locked = 0
	go_out()

/obj/machinery/clonepod/proc/update_clone_antag(var/mob/living/carbon/human/H)
	// Check to see if the clone's mind is an antagonist of any kind and handle them accordingly to make sure they get their spells, HUD/whatever else back.
	callHook("clone", list(H))
	if((H.mind in ticker.mode:revolutionaries) || (H.mind in ticker.mode:head_revolutionaries))
		ticker.mode.update_rev_icons_added() //So the icon actually appears
	if(H.mind in ticker.mode.syndicates)
		ticker.mode.update_synd_icons_added()
	if(H.mind in ticker.mode.cult)
		ticker.mode.add_cultist(occupant.mind)
		ticker.mode.update_cult_icons_added() //So the icon actually appears
	if((H.mind in ticker.mode.implanter) || (H.mind in ticker.mode.implanted))
		ticker.mode.update_traitor_icons_added(H.mind) //So the icon actually appears
	if(H.mind.vampire)
		H.mind.vampire.update_owner(H)
	if((H.mind in ticker.mode.vampire_thralls) || (H.mind in ticker.mode.vampire_enthralled))
		ticker.mode.update_vampire_icons_added(H.mind)
	if(H.mind in ticker.mode.changelings)
		ticker.mode.update_change_icons_added(H.mind)
 	if((H.mind in ticker.mode.shadowling_thralls) || (H.mind in ticker.mode.shadows))
 		ticker.mode.update_shadow_icons_added(H.mind)

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
		update_clone_antag(occupant)
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

//WHAT DO YOU WANT FROM ME(AT)
/obj/machinery/clonegrinder
	name = "enzymatic reclaimer"
	desc = "A tank resembling a rather large blender, designed to recover biomatter for use in cloning."
	icon = 'icons/goonstation/objects/cloning.dmi'
	icon_state = "grinder0"
	anchored = 1
	density = 1

	var/process_timer = 0
	var/mob/living/occupant = null
	var/list/meats = list() //Meat that we want to reclaim
	var/max_meat = 4 //To be honest, I added the meat reclamation thing in part because I wanted a "max_meat" var.

/obj/machinery/clonegrinder/New()
	..()
	create_reagents()
	update_icon(1)

/obj/machinery/clonegrinder/verb/eject()
	set name = "Eject Grinder"
	set category = "Object"
	set src in oview(1)

	if(!usr)
		return
	if(usr.incapacitated())
		return
	if(process_timer > 0)
		return
	go_out()
	add_fingerprint(usr)

/obj/machinery/clonegrinder/relaymove(mob/user)
	go_out()

/obj/machinery/clonegrinder/proc/go_out()
	if(!occupant)
		return
	for(var/obj/O in src)
		O.forceMove(get_turf(src))
	occupant.forceMove(get_turf(src))
	occupant = null

/obj/machinery/clonegrinder/process()
	if(process_timer-- < 1)
		update_icon(1)

		var/list/pods = list()
		for(var/obj/machinery/clonepod/pod in orange(4, src))
			pods += pod
		if(pods.len)
			for(var/obj/machinery/clonepod/pod in pods)
				reagents.trans_to(pod, (reagents.total_volume / max(pods.len, 1))) // give an equal amount of reagents to each pod that happens to be around

		return PROCESS_KILL

	reagents.add_reagent("blood", 2)
	reagents.add_reagent("meatslurry", 2)

/obj/machinery/clonegrinder/on_reagent_change()
	update_icon(0)

/obj/machinery/clonegrinder/attack_hand(mob/user)
	if(process_timer > 0)
		to_chat(user, "<span class='warning'>[src] is already running!</span>")
		return

	if(!meats.len && !occupant)
		to_chat(user, "<span class='warning'>There is nothing loaded to reclaim!</span>")
		return

	user.visible_message("<span class='notice'>[user] activates [src]!</span>", "<span class='notice'>You activate [src].</span>")
	if(istype(occupant))
		add_logs(user, occupant, "enzymatically reclaimed", print_attack_log = 0)
		if(occupant.stat != DEAD && occupant.ckey)
			msg_admin_attack("[key_name_admin(user)] activated [src] with [key_name_admin(occupant)] alive inside at [ADMIN_COORDJMP(src)]!")
		occupant.death(1)

		var/humanOccupant = !issmall(occupant)
		if(occupant.mind)
			occupant.ghostize()
		qdel(occupant)

		process_timer = (humanOccupant ? 2 : 1) * rand(4, 8)

	if(meats.len)
		for(var/obj/item/theMeat in meats)
			if(theMeat.reagents)
				theMeat.reagents.trans_to(src, 5)

			qdel(theMeat)
			process_timer += 2

		meats.Cut()

	update_icon(1)
	addAtProcessing()

/obj/machinery/clonegrinder/attackby(obj/item/I, mob/user, params)
	if(process_timer > 0)
		to_chat(user, "<span class='warning'>[src] is still running, hold your horses!</span>")
		return

	if(istype(I, /obj/item/weapon/reagent_containers/food/snacks/meat) || istype(I, /obj/item/organ))
		if(meats.len >= max_meat)
			to_chat(user, "<span class='danger'>There is already enough meat in there! You should not exceed the maximum safe meat level!</span>")
			return

		if(!user.unEquip(I))
			return

		meats += I
		I.forceMove(src)
		user.visible_message("<span class='notice'>[user] loads [I] into [src].", "<span class='notice'>You load [I] into [src].</span>")
		return

	if(istype(I, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = I
		if(!iscarbon(G.affecting))
			to_chat(user, "<span class='warning'>This item is not suitable for [src].</span>")
			return
		var/mob/living/carbon/C = G.affecting
		if(occupant)
			to_chat(user, "<span class='warning'>There is already somebody in there.</span>")
			return

		C.visible_message("<span class='danger'>[user] starts to put [C] into [src]!</span>", "<span class='userdanger'>[user] starts putting you into [src]!</span>")
		add_fingerprint(user)
		if(do_after(user, 30, target = C) && !occupant)
			C.visible_message("<span class='danger'>[user] stuffs [C] into [src]!</span>", "<span class='userdanger'>[user] stuffs you into [src]!</span>")
			add_logs(user, C, "put", addition = " into [src] at [COORD(src)]", print_attack_log = 0)
			if(C.stat != DEAD && C.ckey)
				msg_admin_attack("[key_name_admin(user)] forced [key_name_admin(C)] alive into [src] at [ADMIN_COORDJMP(src)]")
			//C.unequip_all()
			C.forceMove(src)
			occupant = C
			qdel(G)

/obj/machinery/clonegrinder/update_icon(var/update_grindpaddle = 0)
	var/fluid_level = ((reagents.total_volume >= (reagents.maximum_volume * 0.6)) ? 2 : (reagents.total_volume >= (reagents.maximum_volume * 0.2) ? 1 : 0))

	icon_state = "grinder[fluid_level]"

	if(update_grindpaddle)
		overlays.Cut()
		overlays += "grindpaddle[process_timer > 0 ? 1 : 0]"

		overlays += "grindglass[fluid_level]"

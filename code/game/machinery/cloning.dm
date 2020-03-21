//Cloning revival method.
//The pod handles the actual cloning while the computer manages the clone profiles

//Potential replacement for genetics revives or something I dunno (?)

#define CLONE_BIOMASS 150
#define BIOMASS_MEAT_AMOUNT 50
#define MINIMUM_HEAL_LEVEL 40
#define CLONE_INITIAL_DAMAGE 190
#define BRAIN_INITIAL_DAMAGE 90 // our minds are too feeble for 190

/obj/machinery/clonepod
	anchored = 1
	name = "cloning pod"
	desc = "An electronically-lockable pod for growing organic tissue."
	density = 1
	icon = 'icons/obj/cloning.dmi'
	icon_state = "pod_0"
	req_access = list(ACCESS_GENETICS) //For premature unlocking.
	var/mob/living/carbon/human/occupant
	var/heal_level //The clone is released once its health reaches this level.
	var/obj/machinery/computer/cloning/connected = null //So we remember the connected clone machine.
	var/mess = 0 //Need to clean out it if it's full of exploded clone.
	var/attempting = 0 //One clone attempt at a time thanks
	var/biomass = 0
	var/speed_coeff
	var/efficiency

	var/datum/mind/clonemind
	var/grab_ghost_when = CLONER_MATURE_CLONE

	var/obj/item/radio/Radio
	var/radio_announce = 0

	var/obj/effect/countdown/clonepod/countdown

	var/list/brine_types = list("corazone", "perfluorodecalin", "epinephrine", "salglu_solution") //stops heart attacks, heart failure, shock, and keeps their O2 levels normal
	var/list/missing_organs
	var/organs_number = 0

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

	Radio = new /obj/item/radio(src)
	Radio.listening = 0
	Radio.config(list("Medical" = 0))

	component_parts = list()
	component_parts += new /obj/item/circuitboard/clonepod(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()
	update_icon()

/obj/machinery/clonepod/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/clonepod(null)
	component_parts += new /obj/item/stock_parts/scanning_module/phasic(null)
	component_parts += new /obj/item/stock_parts/scanning_module/phasic(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	biomass = CLONE_BIOMASS
	RefreshParts()

/obj/machinery/clonepod/Destroy()
	if(connected)
		connected.pods -= src
	for(var/s in sharedSoulhooks)
		var/datum/soullink/S = s
		S.removeSoulsharer(src) //If a sharer is destroy()'d, they are simply removed
	sharedSoulhooks = null
	QDEL_NULL(Radio)
	QDEL_NULL(countdown)
	QDEL_LIST(missing_organs)
	return ..()

/obj/machinery/clonepod/RefreshParts()
	speed_coeff = 0
	efficiency = 0
	for(var/obj/item/stock_parts/scanning_module/S in component_parts)
		efficiency += S.rating
	for(var/obj/item/stock_parts/manipulator/P in component_parts)
		speed_coeff += P.rating
	heal_level = max(min((efficiency * 15) + 10, 100), MINIMUM_HEAL_LEVEL)

//The return of data disks?? Just for transferring between genetics machine/cloning machine.
//TO-DO: Make the genetics machine accept them.
/obj/item/disk/data
	name = "Cloning Data Disk"
	icon_state = "datadisk0" //Gosh I hope syndies don't mistake them for the nuke disk.
	var/datum/dna2/record/buf = null
	var/read_only = 0 //Well,it's still a floppy disk

/obj/item/disk/data/proc/initialize()
	buf = new
	buf.dna=new

/obj/item/disk/data/Destroy()
	QDEL_NULL(buf)
	return ..()

/obj/item/disk/data/demo
	name = "data disk - 'God Emperor of Mankind'"
	read_only = 1

/obj/item/disk/data/demo/New()
	..()
	initialize()
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

/obj/item/disk/data/monkey
	name = "data disk - 'Mr. Muggles'"
	read_only = 1

/obj/item/disk/data/monkey/New()
	..()
	initialize()
	buf.types=DNA2_BUF_SE
	var/list/new_SE=list(0x098,0x3E8,0x403,0x44C,0x39F,0x4B0,0x59D,0x514,0x5FC,0x578,0x5DC,0x640,0x6A4)
	for(var/i=new_SE.len;i<=DNA_SE_LENGTH;i++)
		new_SE += rand(1,1024)
	buf.dna.SE=new_SE
	buf.dna.SetSEValueRange(GLOB.monkeyblock,0xDAC, 0xFFF)

//Disk stuff.
/obj/item/disk/data/New()
	..()
	var/diskcolor = pick(0,1,2)
	icon_state = "datadisk[diskcolor]"

/obj/item/disk/data/attack_self(mob/user as mob)
	read_only = !read_only
	to_chat(user, "You flip the write-protect tab to [read_only ? "protected" : "unprotected"].")

/obj/item/disk/data/examine(mob/user)
	. = ..()
	. += "The write-protect tab is set to [read_only ? "protected" : "unprotected"]."

//Clonepod

/obj/machinery/clonepod/examine(mob/user)
	. = ..()
	if(mess)
		. += "It's filled with blood and viscera. You swear you can see it moving..."
	if(!occupant || stat & (NOPOWER|BROKEN))
		return
	if(occupant && occupant.stat != DEAD)
		. +=  "Current clone cycle is [round(get_completion())]% complete."

/obj/machinery/clonepod/return_air() //non-reactive air
	var/datum/gas_mixture/GM = new
	GM.nitrogen = MOLES_O2STANDARD + MOLES_N2STANDARD
	GM.temperature = T20C
	return GM

/obj/machinery/clonepod/proc/get_completion()
	. = (100 * ((occupant.health + 100) / (heal_level + 100)))

/obj/machinery/clonepod/attack_ai(mob/user)
	return examine(user)

//Radio Announcement

/obj/machinery/clonepod/proc/announce_radio_message(message)
	if(radio_announce)
		Radio.autosay(message, name, "Medical", list(z))

/obj/machinery/clonepod/proc/spooky_devil_flavor()
	playsound(loc, pick('sound/goonstation/voice/male_scream.ogg', 'sound/goonstation/voice/female_scream.ogg'), 100, 1)
	mess = 1
	update_icon()
	connected_message("<font face=\"REBUFFED\" color=#600A0A>If you keep trying to steal from me, you'll end up with me.</font>")

//Start growing a human clone in the pod!
/obj/machinery/clonepod/proc/growclone(datum/dna2/record/R)
	if(mess || attempting || panel_open || stat & (NOPOWER|BROKEN))
		return 0
	clonemind = locate(R.mind)
	if(!istype(clonemind))	//not a mind
		return 0
	if(clonemind.current && clonemind.current.stat != DEAD)	//mind is associated with a non-dead body
		return 0
	if(clonemind.damnation_type)
		spooky_devil_flavor()
		return 0
	if(!clonemind.is_revivable()) //Other reasons for being unrevivable
		return 0
	if(clonemind.active)	//somebody is using that mind
		if(ckey(clonemind.key) != R.ckey )
			return 0
		if(clonemind.suicided) // and stay out!
			malfunction(go_easy = 0)
			return -1 // Flush the record
	else
		// get_ghost() will fail if they're unable to reenter their body
		var/mob/dead/observer/G = clonemind.get_ghost()
		if(!G)
			return 0

/*
	if(clonemind.damnation_type) //Can't clone the damned.
		playsound('sound/hallucinations/veryfar_noise.ogg', 50, 0)
		malfunction()
 		return -1 // so that the record gets flushed out
	*/

	if(biomass >= CLONE_BIOMASS)
		biomass -= CLONE_BIOMASS
	else
		return 0

	attempting = 1 //One at a time!!
	countdown.start()

	if(!R.dna)
		R.dna = new /datum/dna()

	var/mob/living/carbon/human/H = new /mob/living/carbon/human(src)
	H.set_species(R.dna.species.type)
	occupant = H

	if(!R.dna.real_name)	//to prevent null names
		R.dna.real_name = H.real_name
	else
		H.real_name = R.dna.real_name

	H.dna = R.dna.Clone()

	for(var/datum/language/L in R.languages)
		H.add_language(L.name)

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

	check_brine()
	//Get the clone body ready
	maim_clone(H)
	H.Paralyse(4)

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
		// Set up a soul link with the dead body to catch a revival
		soullink(/datum/soullink/soulhook, clonemind.current, src)

	update_icon()

	H.suiciding = 0
	attempting = 0
	return 1

//Grow clones to maturity then kick them out.  FREELOADERS
/obj/machinery/clonepod/process()
	var/show_message = 0
	for(var/obj/item/reagent_containers/food/snacks/meat/meat in range(1, src))
		qdel(meat)
		biomass += BIOMASS_MEAT_AMOUNT
		show_message = 1
	if(show_message)
		visible_message("[src] sucks in and processes the nearby biomass.")

	if(stat & NOPOWER) //Autoeject if power is lost
		if(occupant)
			go_out()
			connected_message("Clone Ejected: Loss of power.")

	else if((occupant) && (occupant.loc == src))
		if((occupant.stat == DEAD) || (occupant.suiciding) || (occupant.mind && !occupant.mind.is_revivable()))  //Autoeject corpses and suiciding dudes.
			announce_radio_message("The cloning of <b>[occupant]</b> has been aborted due to unrecoverable tissue failure.")
			go_out()
			connected_message("Clone Rejected: Deceased.")

		else if(occupant.cloneloss > (100 - heal_level))
			occupant.Paralyse(4)

			 //Slowly get that clone healed and finished.
			occupant.adjustCloneLoss(-((speed_coeff/2)))

			// For human species that lack non-vital parts for some weird reason
			if(organs_number)
				var/progress = CLONE_INITIAL_DAMAGE - occupant.getCloneLoss()
				progress += (100 - MINIMUM_HEAL_LEVEL)
				var/milestone = CLONE_INITIAL_DAMAGE / organs_number
// Doing this as a #define so that the value can change when evaluated multiple times
#define INSTALLED (organs_number - LAZYLEN(missing_organs))

				while((progress / milestone) > INSTALLED && LAZYLEN(missing_organs))
					var/obj/item/organ/I = pick_n_take(missing_organs)
					I.safe_replace(occupant)

#undef INSTALLED

			//Premature clones may have brain damage.
			occupant.adjustBrainLoss(-((speed_coeff/20)*efficiency))

			check_brine()

			//Also heal some oxyloss ourselves just in case!!
			occupant.adjustOxyLoss(-10)

			use_power(7500) //This might need tweaking.

		else if((occupant.cloneloss <= (100 - heal_level)))
			connected_message("Cloning Process Complete.")
			announce_radio_message("The cloning cycle of <b>[occupant]</b> is complete.")
			go_out()

	else if((!occupant) || (occupant.loc != src))
		occupant = null
		update_icon()
		use_power(200)

//Let's unlock this early I guess.  Might be too early, needs tweaking.
/obj/machinery/clonepod/attackby(obj/item/I, mob/user, params)
	if(exchange_parts(user, I))
		return

	if(I.GetID())
		if(!check_access(I))
			to_chat(user, "<span class='danger'>Access Denied.</span>")
			return
		if(!(occupant || mess))
			to_chat(user, "<span class='danger'>Error: Pod has no occupant.</span>")
			return
		else
			connected_message("Authorized Ejection")
			announce_radio_message("An authorized ejection of [(occupant) ? occupant.real_name : "the malfunctioning pod"] has occured")
			to_chat(user, "<span class='notice'>You force an emergency ejection.</span>")
			go_out()

//Removing cloning pod biomass
	else if(istype(I, /obj/item/reagent_containers/food/snacks/meat))
		if(user.drop_item())
			to_chat(user, "<span class='notice'>[src] processes [I].</span>")
			biomass += BIOMASS_MEAT_AMOUNT
			qdel(I)
	else
		return ..()

/obj/machinery/clonepod/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	default_deconstruction_crowbar(user, I)

/obj/machinery/clonepod/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!I.multitool_check_buffer(user))
		return
	var/obj/item/multitool/M = I
	M.set_multitool_buffer(user, src)

/obj/machinery/clonepod/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	default_deconstruction_screwdriver(user, "[icon_state]_maintenance", "[initial(icon_state)]", I)

/obj/machinery/clonepod/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(occupant)
		to_chat(user, "<span class='warning'>Can not do that while [src] is in use.</span>")
		return
	if(anchored)
		WRENCH_UNANCHOR_MESSAGE
		anchored = FALSE
		connected.pods -= src
		connected = null
	else
		WRENCH_ANCHOR_MESSAGE
		anchored = TRUE

/obj/machinery/clonepod/emag_act(user)
	if(isnull(occupant))
		return
	go_out()

/obj/machinery/clonepod/proc/update_clone_antag(var/mob/living/carbon/human/H)
	// Check to see if the clone's mind is an antagonist of any kind and handle them accordingly to make sure they get their spells, HUD/whatever else back.
	if((H.mind in SSticker.mode:revolutionaries) || (H.mind in SSticker.mode:head_revolutionaries))
		SSticker.mode.update_rev_icons_added() //So the icon actually appears
	if(H.mind in SSticker.mode.syndicates)
		SSticker.mode.update_synd_icons_added()
	if(H.mind in SSticker.mode.cult)
		SSticker.mode.add_cultist(occupant.mind)
		SSticker.mode.update_cult_icons_added() //So the icon actually appears
		SSticker.mode.update_cult_comms_added(H.mind) //So the comms actually appears
	if(H.mind.vampire)
		H.mind.vampire.update_owner(H)
	if((H.mind in SSticker.mode.vampire_thralls) || (H.mind in SSticker.mode.vampire_enthralled))
		SSticker.mode.update_vampire_icons_added(H.mind)
	if(H.mind in SSticker.mode.changelings)
		SSticker.mode.update_change_icons_added(H.mind)
 	if((H.mind in SSticker.mode.shadowling_thralls) || (H.mind in SSticker.mode.shadows))
 		SSticker.mode.update_shadow_icons_added(H.mind)

//Put messages in the connected computer's temp var for display.
/obj/machinery/clonepod/proc/connected_message(message)
	if((isnull(connected)) || (!istype(connected, /obj/machinery/computer/cloning)))
		return 0
	if(!message)
		return 0

	connected.temp = "[name] : [message]"
	connected.updateUsrDialog()
	return 1

/obj/machinery/clonepod/proc/go_out()
	countdown.stop()
	var/turf/T = get_turf(src)
	if(mess) //Clean that mess and dump those gibs!
		for(var/i in missing_organs)
			var/obj/I = i
			I.forceMove(T)
		missing_organs.Cut()
		mess = FALSE
		new /obj/effect/gibspawner/generic(get_turf(src), occupant)
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
		for(var/s in sharedSoulhooks)
			var/datum/soullink/S = s
			S.removeSoulsharer(src) //If a sharer is destroy()'d, they are simply removed
		sharedSoulhooks = null


	for(var/i in missing_organs)
		qdel(i)
	missing_organs.Cut()
	occupant.SetLoseBreath(0) // Stop friggin' dying, gosh damn
	occupant.setOxyLoss(0)
	for(var/datum/disease/critical/crit in occupant.viruses)
		crit.cure()
	occupant.forceMove(T)
	occupant.update_body()
	domutcheck(occupant) //Waiting until they're out before possible notransform.
	occupant.special_post_clone_handling()
	occupant = null
	update_icon()

/obj/machinery/clonepod/proc/malfunction(go_easy = FALSE)
	if(occupant)
		connected_message("Critical Error!")
		announce_radio_message("Critical error! Please contact a Thinktronic Systems technician, as your warranty may be affected.")
		for(var/s in sharedSoulhooks)
			var/datum/soullink/S = s
			S.removeSoulsharer(src) //If a sharer is destroy()'d, they are simply removed
		sharedSoulhooks = null
		if(!go_easy)
			if(occupant.mind != clonemind)
				clonemind.transfer_to(occupant)
			occupant.grab_ghost() // We really just want to make you suffer.
			to_chat(occupant, {"<span class='warning'><b>Agony blazes across your
				consciousness as your body is torn apart.</b><br>
				<i>Is this what dying is like? Yes it is.</i></span>"})
			occupant << sound('sound/hallucinations/veryfar_noise.ogg',0,1,50)
		for(var/i in missing_organs)
			qdel(i)
		missing_organs.Cut()
		spawn(40)
			qdel(occupant)


	playsound(loc, 'sound/machines/warning-buzzer.ogg', 50, 0)
	mess = TRUE
	update_icon()

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
	..()
	if(!QDELETED(src) && occupant)
		go_out()

/obj/machinery/clonepod/handle_atom_del(atom/A)
	if(A == occupant)
		occupant = null
		countdown.stop()

/obj/machinery/clonepod/deconstruct(disassembled = TRUE)
	if(occupant)
		go_out()
	..()

/obj/machinery/clonepod/onSoullinkRevive(mob/living/L)
	if(occupant && L == clonemind.current)
		// The old body's back in shape, time to ditch the cloning one
		malfunction(go_easy = TRUE)

/obj/machinery/clonepod/proc/maim_clone(mob/living/carbon/human/H)
	LAZYINITLIST(missing_organs)
	for(var/i in missing_organs)
		qdel(i)
	missing_organs.Cut()

	H.setCloneLoss(CLONE_INITIAL_DAMAGE, FALSE)
	H.setBrainLoss(BRAIN_INITIAL_DAMAGE)

	for(var/o in H.internal_organs)
		var/obj/item/organ/O = o
		if(!istype(O) || O.vital)
			continue

		// Let's non-specially remove all non-vital organs
		// What could possibly go wrong
		var/obj/item/I = O.remove(H)
		// Make this support stuff that turns into items when removed
		I.forceMove(src)
		missing_organs += I

	var/static/list/zones = list("r_arm", "l_arm", "r_leg", "l_leg")
	for(var/zone in zones)
		var/obj/item/organ/external/E = H.get_organ(zone)
		var/obj/item/I = E.remove(H)
		I.forceMove(src)
		missing_organs += I

	organs_number = LAZYLEN(missing_organs)
	H.updatehealth()

/obj/machinery/clonepod/proc/check_brine()
	// Clones are in a pickled bath of mild chemicals, keeping
	// them alive, despite their lack of internal organs
	for(var/bt in brine_types)
		if(occupant.reagents.get_reagent_amount(bt) < 1)
			occupant.reagents.add_reagent(bt, 1)

/*
 *	Diskette Box
 */

/obj/item/storage/box/disks
	name = "Diskette Box"
	icon_state = "disk_kit"

/obj/item/storage/box/disks/New()
	..()
	new /obj/item/disk/data(src)
	new /obj/item/disk/data(src)
	new /obj/item/disk/data(src)
	new /obj/item/disk/data(src)
	new /obj/item/disk/data(src)
	new /obj/item/disk/data(src)
	new /obj/item/disk/data(src)

/*
 *	Manual -- A big ol' manual.
 */

/obj/item/paper/Cloning
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

#undef MINIMUM_HEAL_LEVEL

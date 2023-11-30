/obj/machinery/grey_autocloner
	name = "technocracy cloning pod"
	desc = "An advanced Technocracy cloning pod, used for rapid cloning. Very delicate, very power hungry, and very much should not be tampered with."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "experiment-open"
	anchored = TRUE
	density = TRUE
	var/mob/living/carbon/human/occupant
	var/datum/gas_mixture/air_contents = new()
	var/list/brine_types = list("corazone", "perfluorodecalin", "epinephrine", "salglu_solution") //Taken from cloner, a bit of extra healing though they should be fully good.
	var/datum/mind/clonemind
	var/attempting = FALSE

/obj/machinery/grey_autocloner/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/implanter))
		var/obj/item/implanter/I = O
		if(istype(I.imp, /obj/item/implant/grey_autocloner))
			var/obj/item/implant/grey_autocloner/G = I.imp
			G.linked = src
			atom_say("Link confirmed!")
	return ..()

/obj/machinery/grey_autocloner/Initialize(mapload)
	. = ..()

	air_contents.oxygen = MOLES_O2STANDARD * 2
	air_contents.nitrogen = MOLES_N2STANDARD
	air_contents.temperature = T20C

/obj/machinery/grey_autocloner/Destroy() //These will only be not null if deleted with someone in it
	occupant = null
	clonemind = null
	return ..()

/obj/machinery/grey_autocloner/proc/growclone(datum/dna2/record/R)
	if(attempting || stat & (NOPOWER|BROKEN))
		return 0
	clonemind = locate(R.mind)
	if(!istype(clonemind))	//not a mind
		return 0
	if(clonemind.current && clonemind.current.stat != DEAD)	//mind is associated with a non-dead body
		return 0
	if(clonemind.active)	//somebody is using that mind
		if(ckey(clonemind.key) != R.ckey)
			return 0
		if(clonemind.suicided) // Nah, if you are being dragged to the borg factory, that's on you
			return 0
	else
		// get_ghost() will fail if they're unable to reenter their body
		var/mob/dead/observer/G = clonemind.get_ghost()
		if(!G)
			return 0

	attempting = TRUE //One at a time!!

	if(!R.dna)
		R.dna = new /datum/dna()

	var/mob/living/carbon/human/H = new /mob/living/carbon/human(src)
	H.set_species(/datum/species/grey) //This is a grey cloner after all. Funnier this way tbh
	occupant = H

	if(!R.dna.real_name)	//to prevent null names
		R.dna.real_name = H.real_name
	else
		H.real_name = R.dna.real_name

	H.dna = R.dna.Clone()

	for(var/datum/language/L in R.languages)
		H.add_language(L.name)

	domutcheck(H, MUTCHK_FORCED) //Ensures species that get powers by the species proc handle_dna keep them

	H.dna.UpdateSE()
	H.dna.UpdateUI()

	H.sync_organ_dna(1) // It's literally a fresh body as you can get, so all organs properly belong to it
	H.UpdateAppearance()

	H.Paralyse(8 SECONDS)

	clonemind.transfer_to(H) //INSTANTLY INTO THE CLONE
	H.ckey = R.ckey
	update_clone_antag(H) //Since the body's got the mind, update their antag stuff right now. Otherwise, wait until they get kicked out (as per the CLONER_MATURE_CLONE business) to do it.
	var/message
	message += "<b>Consciousness slowly creeps over you as your body regenerates.</b><br>"
	message += "<i>So this is what cloning feels like?</i>"
	to_chat(H, "<span class='notice'>[message]</span>")

	update_icon()

	H.suiciding = FALSE
	attempting = FALSE
	addtimer(CALLBACK(src, PROC_REF(finish_clone)), 1 MINUTES)
	return 1

/obj/machinery/grey_autocloner/process()
	if(stat & NOPOWER) //explode if power is lost and cloning
		if(occupant)
			messy_explode()
			return

	else if((occupant) && (occupant.loc == src))
		occupant.Paralyse(8 SECONDS)
		use_power(15000) //Hope the room has power!
		for(var/bt in brine_types)
			if(occupant.reagents.get_reagent_amount(bt) < 1)
				occupant.reagents.add_reagent(bt, 1)

/obj/machinery/grey_autocloner/proc/update_clone_antag(mob/living/carbon/human/H)
	// Check to see if the clone's mind is an antagonist of any kind and handle them accordingly to make sure they get their spells, HUD/whatever else back.
	if(H.mind in SSticker.mode.syndicates)
		SSticker.mode.update_synd_icons_added()
	if(H.mind in SSticker.mode.cult)
		SSticker.mode.update_cult_icons_added(H.mind) // Adds the cult antag hud
		SSticker.mode.add_cult_actions(H.mind) // And all the actions
		if(SSticker.mode.cult_risen)
			SSticker.mode.rise(H)
			if(SSticker.mode.cult_ascendant)
				SSticker.mode.ascend(H)

/obj/machinery/grey_autocloner/proc/finish_clone()
	playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
	var/obj/item/organ/internal/storedorgan = new /obj/item/organ/internal/cyberimp/brain/speech_translator
	storedorgan.insert(occupant) //insert stored organ into the user
	occupant.forceMove(get_turf(src))
	occupant.update_body()
	domutcheck(occupant) //Waiting until they're out before possible notransform.
	occupant.special_post_clone_handling()
	occupant = null
	update_icon()

/obj/machinery/grey_autocloner/emp_act(severity)
	messy_explode()

/obj/machinery/grey_autocloner/proc/messy_explode()
	if(occupant)
		occupant.forceMove(get_turf(src))
	explosion(loc, 1, 2, 4, flame_range = 2)
	qdel(src)

/obj/machinery/grey_autocloner/deconstruct(disassembled)
	messy_explode()

/obj/machinery/grey_autocloner/update_icon_state()
	if(occupant)
		icon_state = "experiment"
	else
		icon_state = "experiment-open"

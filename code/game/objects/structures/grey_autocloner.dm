/obj/machinery/grey_autocloner
	name = "technocracy cloning pod"
	desc = "An advanced Technocracy cloning pod, used for rapid cloning. Very delicate, very power hungry, and very much should not be tampered with."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "experiment-open"
	anchored = TRUE
	density = TRUE
	var/mob/living/carbon/human/occupant
	var/datum/gas_mixture/air_contents
	var/list/brine_types = list("corazone", "perfluorodecalin", "epinephrine", "salglu_solution") //Taken from cloner, a bit of extra healing though they should be fully good.
	var/datum/mind/clonemind
	/// If the clone pod is cloning someone, attempting becomes true, so only one person can clone at a time. False otherwise.
	var/attempting = FALSE

/obj/machinery/grey_autocloner/Initialize(mapload)
	. = ..()
	air_contents = new()
	air_contents.set_oxygen(MOLES_O2STANDARD * 2)
	air_contents.set_nitrogen(MOLES_N2STANDARD)
	air_contents.set_temperature(T20C)

/obj/machinery/grey_autocloner/Destroy() //These will only be not null if deleted with someone in it
	occupant = null
	clonemind = null
	return ..()

/obj/machinery/grey_autocloner/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	var/obj/item/bio_chip_implanter/implant = used
	if(!istype(implant) || !(istype(implant.imp, /obj/item/bio_chip/grey_autocloner)))
		return ..()
	var/obj/item/bio_chip/grey_autocloner/autoclone = implant.imp
	autoclone.linked = src
	atom_say("Link confirmed!")
	return ITEM_INTERACT_COMPLETE

/obj/machinery/grey_autocloner/proc/growclone(datum/dna2_record/R)
	if(attempting || stat & (NOPOWER|BROKEN))
		return FALSE
	clonemind = locateUID(R.mind)
	if(!istype(clonemind))	//not a mind
		return FALSE
	if(clonemind.current && clonemind.current.stat != DEAD)	//mind is associated with a non-dead body
		return FALSE
	if(clonemind.active)	//somebody is using that mind
		if(ckey(clonemind.key) != R.ckey)
			return FALSE
		if(clonemind.suicided) // Nah, if you are being dragged to the borg factory, that's on you
			return FALSE
	else
		// get_ghost() will fail if they're unable to reenter their body
		var/mob/dead/observer/G = clonemind.get_ghost()
		if(!G)
			return FALSE

	attempting = TRUE //One at a time!!

	if(!R.dna)
		R.dna = new /datum/dna()

	var/mob/living/carbon/human/H = new /mob/living/carbon/human(src)
	occupant = H

	if(!R.dna.real_name)	//to prevent null names
		R.dna.real_name = H.real_name
	else
		H.real_name = R.dna.real_name

	H.dna = R.dna.Clone()

	H.set_species(/datum/species/grey, skip_same_check = TRUE) //This is a grey cloner after all. Funnier this way tbh

	for(var/datum/language/L in R.languages)
		H.add_language(L.name)

	domutcheck(H, MUTCHK_FORCED) //Ensures species that get powers by the species proc handle_dna keep them

	H.dna.UpdateSE()
	H.dna.UpdateUI()

	H.sync_organ_dna(TRUE) // It's literally a fresh body as you can get, so all organs properly belong to it
	H.UpdateAppearance()

	H.Paralyse(8 SECONDS)

	clonemind.transfer_to(H) //INSTANTLY INTO THE CLONE
	H.ckey = R.ckey
	to_chat(H, "<span class='notice'><b>Consciousness slowly creeps over you as your body regenerates.</b><br><i>So this is what cloning feels like?</i></span>")

	update_icon()

	H.suiciding = FALSE
	attempting = FALSE
	addtimer(CALLBACK(src, PROC_REF(finish_clone)), 1 MINUTES)
	return TRUE

/obj/machinery/grey_autocloner/process()
	if(stat & NOPOWER) //explode if power is lost and cloning
		if(occupant)
			messy_explode()
			return

	else if(occupant?.loc == src)
		occupant.Paralyse(8 SECONDS)
		if(!use_power(15000)) //Hope the room has power!
			return
		for(var/bt in brine_types)
			if(occupant.reagents.get_reagent_amount(bt) < 1)
				occupant.reagents.add_reagent(bt, 1)

/obj/machinery/grey_autocloner/proc/finish_clone()
	playsound(get_turf(src), 'sound/machines/ding.ogg', 50, TRUE)
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
	explosion(get_turf(src), 1, 2, 4, flame_range = 2, cause = "Grey Autocloner Self-destruct")
	qdel(src)

/obj/machinery/grey_autocloner/deconstruct(disassembled)
	messy_explode()

/obj/machinery/grey_autocloner/update_icon_state()
	icon_state = occupant ? "experiment" : "experiment-open"

/datum/species/grey
	name = "Grey"
	name_plural = "Greys"
	icobase = 'icons/mob/human_races/r_grey.dmi'
	deform = 'icons/mob/human_races/r_def_grey.dmi'
	language = "Psionic Communication"
	eyes = "grey_eyes_s"
	butt_sprite = "grey"

	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart/grey,
		"lungs" =    /obj/item/organ/internal/lungs/grey,
		"liver" =    /obj/item/organ/internal/liver/grey,
		"kidneys" =  /obj/item/organ/internal/kidneys/grey,
		"brain" =    /obj/item/organ/internal/brain/grey,
		"appendix" = /obj/item/organ/internal/appendix,
		"eyes" =     /obj/item/organ/internal/eyes/grey //5 darksight.
		)

	brute_mod = 1.25 //greys are fragile

	default_genes = list(REMOTE_TALK)

	species_traits = list(LIPS, IS_WHITELISTED, CAN_BE_FAT, CAN_WINGDINGS)
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags =  HAS_BODY_MARKINGS
	dietflags = DIET_HERB
	has_gender = FALSE
	reagent_tag = PROCESS_ORG
	flesh_color = "#a598ad"
	blood_color = "#A200FF"

/datum/species/grey/handle_dna(mob/living/carbon/human/H, remove)
	..()
	H.dna.SetSEState(REMOTETALKBLOCK, !remove, 1)
	genemutcheck(H, REMOTETALKBLOCK, null, MUTCHK_FORCED)
	H.dna.default_blocks.Add(REMOTETALKBLOCK)

/datum/species/grey/water_act(mob/living/carbon/human/H, volume, temperature, source, method = TOUCH)
	. = ..()

	if(method == TOUCH)
		if(H.wear_mask)
			to_chat(H, "<span class='danger'>Your [H.wear_mask] protects you from the acid!</span>")
			return

		if(H.head)
			to_chat(H, "<span class='danger'>Your [H.wear_mask] protects you from the acid!</span>")
			return

		if(volume > 25)
			if(prob(75))
				H.take_organ_damage(5, 10)
				H.emote("scream")
				var/obj/item/organ/external/affecting = H.get_organ("head")
				if(affecting)
					affecting.disfigure()
			else
				H.take_organ_damage(5, 10)
		else
			H.take_organ_damage(5, 10)
	else
		to_chat(H, "<span class='warning'>The water stings[volume < 10 ? " you, but isn't concentrated enough to harm you" : null]!</span>")
		if(volume >= 10)
			H.adjustFireLoss(min(max(4, (volume - 10) * 2), 20))
			H.emote("scream")
			to_chat(H, "<span class='warning'>The water stings[volume < 10 ? " you, but isn't concentrated enough to harm you" : null]!</span>")

/datum/species/grey/after_equip_job(datum/job/J, mob/living/carbon/human/H)
	var/translator_pref = H.client.prefs.speciesprefs
	if(translator_pref || ((ismindshielded(H) || J.is_command || J.supervisors == "the captain") && (WINGDINGS in H.mutations)))
		if(J.title == "Mime")
			return
		if(J.title == "Clown")
			var/obj/item/organ/internal/cyberimp/brain/speech_translator/clown/implant = new
			implant.insert(H)
		else
			var/obj/item/organ/internal/cyberimp/brain/speech_translator/implant = new
			implant.insert(H)
			if(!translator_pref)
				to_chat(H, "<span class='notice'>A speech translator implant has been installed due to your role on the station.</span>")

/datum/species/grey/handle_reagents(mob/living/carbon/human/H, datum/reagent/R)
	if(R.id == "sacid")
		H.reagents.remove_reagent(R.id, REAGENTS_METABOLISM)
		return FALSE
	if(R.id == "water")
		H.adjustFireLoss(1)
		return TRUE
	return ..()

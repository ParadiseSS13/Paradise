//Procedures in this file: Inernal wound patching, Implant removal.
//////////////////////////////////////////////////////////////////
//					INTERNAL WOUND PATCHING						//
//////////////////////////////////////////////////////////////////

/datum/surgery/infection
	name = "Tratamiento de Infeccion Externa"
	steps = list(/datum/surgery_step/generic/cut_open, /datum/surgery_step/generic/cauterize)
	possible_locs = list("chest","head","groin", "l_arm", "r_arm", "l_leg", "r_leg", "r_hand", "l_hand", "r_foot", "l_foot")

/datum/surgery/bleeding
	name = "Sangrado Interno"
	steps = list(/datum/surgery_step/generic/cut_open,/datum/surgery_step/generic/clamp_bleeders,/datum/surgery_step/generic/retract_skin,/datum/surgery_step/fix_vein,/datum/surgery_step/generic/cauterize)
	possible_locs = list("chest","head","groin", "l_arm", "r_arm", "l_leg", "r_leg", "r_hand", "l_hand", "r_foot", "l_foot")

/datum/surgery/debridement
	name = "Desbridamiento"
	steps = list(/datum/surgery_step/generic/cut_open,/datum/surgery_step/generic/clamp_bleeders,/datum/surgery_step/generic/retract_skin,/datum/surgery_step/fix_dead_tissue,/datum/surgery_step/treat_necrosis,/datum/surgery_step/generic/cauterize)
	possible_locs = list("chest","head","groin", "l_arm", "r_arm", "l_leg", "r_leg", "r_hand", "l_hand", "r_foot", "l_foot")

/datum/surgery/infection/can_start(mob/user, mob/living/carbon/target)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/affected = H.get_organ(user.zone_selected)
		if(!affected)
			return 0
		if(affected.is_robotic())
			return 0
		return 1
	return 0

/datum/surgery/bleeding/can_start(mob/user, mob/living/carbon/target)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/affected = H.get_organ(user.zone_selected)
		if(!affected)
			return 0

		if(affected.internal_bleeding)
			return 1
		return 0

/datum/surgery/debridement/can_start(mob/user, mob/living/carbon/target)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/affected = H.get_organ(user.zone_selected)

		if(!hasorgans(target))
			return 0

		if(!affected)
			return 0

		if(!(affected.status & ORGAN_DEAD))
			return 0

		return 1

	return 0

/datum/surgery_step/fix_vein
	name = "curar sangrando interno"
	allowed_tools = list(
	/obj/item/FixOVein = 100, \
	/obj/item/stack/cable_coil = 90
	)
	can_infect = 1
	blood_level = 1

	time = 32

/datum/surgery_step/fix_vein/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!affected)
		return 0

	return affected.internal_bleeding

/datum/surgery_step/fix_vein/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] comienza a remendar la vena danada en [target] de [affected.name] con \the [tool]." , \
	"Comienzas a remendar la vena danada de [target]' de [affected.name] con \the [tool].")
	target.custom_pain("El dolor en [affected.name] es insorportable!")
	..()

/datum/surgery_step/fix_vein/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] Ha remendado la vena danada en [target] en [affected.name] con \the [tool].</span>", \
		"<span class='notice'>Has remendado la vena danada en [target] de [affected.name] con \the [tool].</span>")

	affected.internal_bleeding = FALSE
	if(ishuman(user) && prob(40))
		var/mob/living/carbon/human/U = user
		U.bloody_hands(target, 0)

	return 1

/datum/surgery_step/fix_vein/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> Las manos de [user] resbalan, manchando [tool] en la incision de [target] en [affected.name]!</span>" , \
	"<span class='warning'> tus manos resbalan, manchando [tool] en la incision de [target] en [affected.name]!</span>")
	affected.receive_damage(5, 0)

	return 0

/datum/surgery_step/fix_dead_tissue		//Debridement
	name = "quitar miembro muerto"
	allowed_tools = list(
		/obj/item/scalpel = 100,		\
		/obj/item/kitchen/knife = 90,	\
		/obj/item/shard = 60, 		\
	)

	can_infect = 1
	blood_level = 1

	time = 16

/datum/surgery_step/fix_dead_tissue/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	if(!hasorgans(target))
		return 0

	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	if(!affected)
		return 0

	if(!(affected.status & ORGAN_DEAD))
		return 0
	return 1

/datum/surgery_step/fix_dead_tissue/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] comienza a cortar el miembro necrotico de [target] en [affected.name] con \the [tool]." , \
	"Comienzas a cortar el miembro necrotico de [target] en [affected.name] con \the [tool].")
	target.custom_pain("El dolor en [affected.name] es insoportable!")
	..()

/datum/surgery_step/fix_dead_tissue/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] ha cortado el miembro necrotico de [target] en [affected.name] con \the [tool].</span>", \
		"<span class='notice'> has cortado el miembro necrotico de [target] en [affected.name] con \the [tool].</span>")
	affected.open = 3

	return 1

/datum/surgery_step/fix_dead_tissue/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> Las manos de [user] resbalan, perforando una arteria dentro de [affected.name] en su [target] con \the [tool]!</span>", \
	"<span class='warning'> tus manos resbalan, slicing an artery inside [target] [affected.name] con \the [tool]!</span>")
	affected.receive_damage(20)

	return 0

/datum/surgery_step/treat_necrosis
	name = "treat necrosis"
	allowed_tools = list(
		/obj/item/reagent_containers/dropper = 100,
		/obj/item/reagent_containers/glass/bottle = 90,
		/obj/item/reagent_containers/food/drinks/drinkingglass = 85,
		/obj/item/reagent_containers/food/drinks/bottle = 80,
		/obj/item/reagent_containers/glass/beaker = 75,
		/obj/item/reagent_containers/spray = 60,
		/obj/item/reagent_containers/glass/bucket = 50
	)

	can_infect = 0
	blood_level = 0

	time = 24

/datum/surgery_step/treat_necrosis/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	if(!istype(tool, /obj/item/reagent_containers))
		return 0

	var/obj/item/reagent_containers/container = tool
	if(!container.reagents.has_reagent("mitocholide"))
		user.visible_message("[user] mira el \the [tool] y reflexiona." , \
		"No estas muy seguro de si \the [tool] contiene mitocholide para trata la necrosis.")
		return 0

	if(!hasorgans(target))
		return 0

	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!(affected.status & ORGAN_DEAD))
		return 0
	return 1

/datum/surgery_step/treat_necrosis/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] comienza a aplicar la medicacion al miembro afectado de [target] en [affected.name] con \the [tool]." , \
	"Comienzas a aplicar la medicacion al miembro afectado de [target] en [affected.name] con \the [tool].")
	target.custom_pain("Algo en tu [affected.name] te causa mucho dolor!")
	..()

/datum/surgery_step/treat_necrosis/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	if(!istype(tool, /obj/item/reagent_containers))
		return 0

	var/obj/item/reagent_containers/container = tool
	var/mitocholide = 0

	if(container.reagents.has_reagent("mitocholide"))
		mitocholide = 1

	var/trans = container.reagents.trans_to(target, container.amount_per_transfer_from_this)
	if(trans > 0)
		container.reagents.reaction(target, REAGENT_INGEST)	//technically it's contact, but the reagents are being applied to internal tissue

		if(mitocholide)
			affected.status &= ~ORGAN_DEAD
			target.update_body()

		user.visible_message("<span class='notice'> [user] Aplica [trans] unidades de la solucion al miembro afectado de [target] en [affected.name]</span>", \
			"<span class='notice'> Aplicas [trans] unidades de la solucion al miembro afectado de [target] en [affected.name] con \the [tool].</span>")

	return 1

/datum/surgery_step/treat_necrosis/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	if(!istype(tool, /obj/item/reagent_containers))
		return

	var/obj/item/reagent_containers/container = tool

	var/trans = container.reagents.trans_to(target, container.amount_per_transfer_from_this)
	container.reagents.reaction(target, REAGENT_INGEST)	//technically it's contact, but the reagents are being applied to internal tissue

	user.visible_message("<span class='warning'> Las manos de [user] resbalan, aplicando [trans] unidades de la solucion en el lugar equivocado en [target] de [affected.name] con el [tool]!</span>" , \
	"<span class='warning'> Tus manos resbalan, colocando [trans] unidades de la solucion en el lugar equivocado en [target] de [affected.name] con el [tool]!</span>")

	//no damage or anything, just wastes medicine


//////////////////////////////////////////////////////////////////
//					Dethrall Shadowling 						//
//////////////////////////////////////////////////////////////////
/datum/surgery/remove_thrall
	name = "Quitar tumor oscuro"
	steps = list(/datum/surgery_step/generic/cut_open, /datum/surgery_step/generic/clamp_bleeders, /datum/surgery_step/generic/retract_skin,  /datum/surgery_step/internal/dethrall, /datum/surgery_step/generic/cauterize)
	possible_locs = list("head", "chest", "groin")

/datum/surgery/remove_thrall/synth
	name = "Depurar tumor oscuro"
	steps = list(/datum/surgery_step/robotics/external/unscrew_hatch,/datum/surgery_step/robotics/external/open_hatch,/datum/surgery_step/internal/dethrall,/datum/surgery_step/robotics/external/close_hatch)
	possible_locs = list("head", "chest", "groin")
	requires_organic_bodypart = 0

/datum/surgery/remove_thrall/can_start(mob/user, mob/living/carbon/human/target)
	if(!istype(target))
		return 0
	if(!is_thrall(target))
		return 0
	var/obj/item/organ/internal/brain/B = target.get_int_organ(/obj/item/organ/internal/brain)
	var/obj/item/organ/external/affected = target.get_organ(user.zone_selected)
	if(!B)
		// No brain to remove the tumor from
		return 0
	if(affected.is_robotic())
		return 0
	if(!(B in affected.internal_organs))
		return 0
	return 1

/datum/surgery/remove_thrall/synth/can_start(mob/user, mob/living/carbon/human/target)
	if(!istype(target))
		return 0
	if(!is_thrall(target))
		return 0
	var/obj/item/organ/internal/brain/B = target.get_int_organ(/obj/item/organ/internal/brain)
	var/obj/item/organ/external/affected = target.get_organ(user.zone_selected)
	if(!B)
		// No brain to remove the tumor from
		return 0
	if(!affected.is_robotic())
		return 0
	if(!(B in affected.internal_organs))
		return 0
	return 1


/datum/surgery_step/internal/dethrall
	name = "limpiar contaminacion"
	allowed_tools = list(/obj/item/flash = 100, /obj/item/flashlight/pen = 80, /obj/item/flashlight = 40)
	blood_level = 0
	time = 30

/datum/surgery_step/internal/dethrall/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	if(!..())
		return 0
	if(!is_thrall(target))
		return 0
	return 1

/datum/surgery_step/internal/dethrall/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/braincase = target.named_organ_parent("brain")
	user.visible_message("[user] rebusca en la cabeza de [target] con [tool].", "<span class='notice'>Comienzas a alinear la luz de [tool] al tumor del cerebro de [target]...</span>")
	to_chat(target, "<span class='boldannounce'>Una pequena parte de tu [braincase] palpita con agonia cuando la luz le impacta.</span>")
	..()

/datum/surgery_step/internal/dethrall/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	if(isshadowlinglesser(target)) //Empowered thralls cannot be deconverted
		to_chat(target, "<span class='shadowling'><b><i>ASI NO!</i></b></span>")
		user.visible_message("<span class='warning'>[target] de repente lo golpea hacia arriba y tumba a [user]!</span>", \
							 "<span class='userdanger'>[target] de repente se atornilla y te golpea con gran fuerza!</span>")
		user.StopResting() //Remove all stuns
		user.SetSleeping(0)
		user.SetStunned(0)
		user.SetWeakened(0)
		user.SetParalysis(0)
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			C.Weaken(6)
			C.apply_damage(20, BRUTE, "chest")
		else if(issilicon(user))
			var/mob/living/silicon/S = user
			S.Weaken(8)
			S.apply_damage(20, BRUTE)
			playsound(S, 'sound/effects/bang.ogg', 50, 1)
		return 0
	var/obj/item/organ/internal/brain/B = target.get_int_organ(/obj/item/organ/internal/brain)
	var/obj/item/organ/external/E = target.get_organ(check_zone(B.parent_organ))
	user.visible_message("[user] alumbra en el tumor de [target] [E]!", "<span class='notice'>Limpias la contaminacion del cerebro de [target]!</span>")
	if(target.vision_type) //Turns off their darksight if it's still active.
		to_chat(target, "<span class='boldannounce'>De repente tus ojos estan forzados en un inmenso dolor tras la forzosa desaparicion de la oscuridad!</span>")
		target.vision_type = null
	SSticker.mode.remove_thrall(target.mind, 0)
	target.visible_message("<span class='warning'>Una extrana masa negra cae de [target] [E]!</span>")
	var/obj/item/organ/thing = new /obj/item/organ/internal/shadowtumor(get_turf(target))
	thing.set_dna(target.dna)
	user.put_in_hands(thing)
	return 1

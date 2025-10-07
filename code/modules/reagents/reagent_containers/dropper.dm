////////////////////////////////////////////////////////////////////////////////
/// 								Droppers.								 ///
////////////////////////////////////////////////////////////////////////////////

/obj/item/reagent_containers/dropper
	name = "dropper"
	desc = "A dropper. Transfers up to 5 units."
	icon_state = "dropper"
	inhand_icon_state = "dropper"
	belt_icon = "dropper"
	amount_per_transfer_from_this = 1
	possible_transfer_amounts = list(1, 2, 3, 4, 5)
	volume = 5
	/// How long it takes to drip the contents into someone's eyes.
	var/mob_drip_delay = 3 SECONDS

/obj/item/reagent_containers/dropper/on_reagent_change()
	if(!reagents.total_volume)
		icon_state = "[initial(icon_state)]"
	else
		icon_state = "[initial(icon_state)]1"

/obj/item/reagent_containers/dropper/mob_act(mob/target, mob/living/user)
	. = TRUE
	var/to_transfer = 0
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(!reagents.total_volume)
			return
		if(user != C)
			visible_message("<span class='danger'>[user] begins to drip something into [C]'s eyes!</span>")
			if(!do_mob(user, C, mob_drip_delay))
				return
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			var/obj/item/safe_thing = null

			if(!H.get_organ(BODY_ZONE_HEAD))
				user.visible_message("<span class='warning'>With a blank stare, [user] drips something where [H]'s eyes should be, but the body has no head to be found. Perhaps [user] is as dead inside as [user.p_their()] patient.</span>", \
				"<span class='warning'>You mindlessly drip something into [H]'s eyes, not realizing that [H.p_their()] head is missing. It's hard to tell which of you is more dead inside.</span>")
				reagents.remove_any(amount_per_transfer_from_this)
				return

			if(H.glasses)
				safe_thing = H.glasses
			if(H.wear_mask)
				if(H.wear_mask.flags_cover & MASKCOVERSEYES)
					safe_thing = H.wear_mask
			if(H.head)
				if(H.head.flags_cover & MASKCOVERSEYES)
					safe_thing = H.head

			if(safe_thing)
				visible_message("<span class='danger'>[user] tries to drip something into [H]'s eyes, but fails!</span>")

				reagents.reaction(safe_thing, REAGENT_TOUCH)
				to_transfer = reagents.remove_any(amount_per_transfer_from_this)

				to_chat(user, "<span class='notice'>You transfer [to_transfer] units of the solution.</span>")
				return

		visible_message("<span class='danger'>[user] drips something into [C]'s eyes!</span>")
		reagents.reaction(C, REAGENT_TOUCH)

		var/list/injected = list()
		for(var/datum/reagent/R in reagents.reagent_list)
			injected += R.name
		var/contained = english_list(injected)
		add_attack_logs(user, C, "Dripped with [src] containing ([contained]), transfering [to_transfer]")

		to_transfer = reagents.trans_to(C, amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You transfer [to_transfer] units of the solution.</span>")

/obj/item/reagent_containers/dropper/normal_act(atom/target, mob/living/user)
	var/to_transfer = 0
	if(!target.reagents)
		return

	if(reagents.total_volume)
		if(!target.is_open_container() && !(isfood(target) && !ispill(target)) && !istype(target, /obj/item/clothing/mask/cigarette))
			to_chat(user, "<span class='warning'>You cannot directly fill this object.</span>")
			return

		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			to_chat(user, "<span class='warning'>[target] is full.</span>")
			return

		to_transfer = reagents.trans_to(target, amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You transfer [to_transfer] units of the solution.</span>")

	else
		if(!target.is_open_container() && !istype(target, /obj/structure/reagent_dispensers))
			to_chat(user, "<span class='warning'>You cannot directly remove reagents from [target].</span>")
			return

		if(!target.reagents.total_volume)
			to_chat(user, "<span class='warning'>[target] is empty.</span>")
			return

		to_transfer = target.reagents.trans_to(src, amount_per_transfer_from_this)

		to_chat(user, "<span class='notice'>You fill [src] with [to_transfer] units of the solution.</span>")
	return TRUE

/obj/item/reagent_containers/dropper/cyborg
	name = "Industrial Dropper"
	desc = "A larger dropper. Transfers up to 10 units."
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
	volume = 10

/obj/item/reagent_containers/dropper/precision
	name = "pipette"
	desc = "A high precision pipette. Transfers up to 1 unit."
	icon_state = "pipette"
	possible_transfer_amounts = list(0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1)
	volume = 1

//Syndicate item. Virus transmitting mini hypospray
/obj/item/reagent_containers/dropper/precision/viral_injector

/obj/item/reagent_containers/dropper/precision/viral_injector/mob_act(mob/living/target, mob/living/user)
	if(target.can_inject(user, TRUE))
		to_chat(user, "<span class='warning'>You stealthily stab [target] with [src].</span>")
		if(reagents.total_volume && target.reagents)
			var/list/injected = list()
			for(var/datum/reagent/R in reagents.reagent_list)
				injected += R.name
				var/datum/reagent/blood/B = R

				if(istype(B) && B.data["viruses"])
					var/virList = list()
					for(var/dis in B.data["viruses"])
						var/datum/disease/D = dis
						var/virusData = D.name
						var/english_symptoms = list()
						var/datum/disease/advance/A = D
						if(A)
							for(var/datum/symptom/S in A.symptoms)
								english_symptoms += S.name
							virusData += " ([english_list(english_symptoms)])"
						virList += virusData
					var/str = english_list(virList)
					add_attack_logs(user, target, "Infected with [str].")

				reagents.reaction(target, REAGENT_INGEST, reagents.total_volume)
				reagents.trans_to(target, 1)

			var/contained = english_list(injected)
			add_attack_logs(user, target, "Injected with [src] containing ([contained])")

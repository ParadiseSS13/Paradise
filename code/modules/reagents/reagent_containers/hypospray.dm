//////////////////////////////
/// MARK: HYPOSPRAY
//////////////////////////////
/obj/item/reagent_containers/hypospray
	name = "hypospray"
	desc = "The DeForest Medical Corporation hypospray is a sterile, air-needle autoinjector for rapid administration of drugs to patients."
	icon = 'icons/obj/hypo.dmi'
	icon_state = "hypo"
	inhand_icon_state = "hypo"
	belt_icon = "hypospray"
	possible_transfer_amounts = list(1,2,3,4,5,10,15,20,25,30)
	resistance_flags = ACID_PROOF
	container_type = OPENCONTAINER
	slot_flags = ITEM_SLOT_BELT
	/// If TRUE, the hypospray can inject any clothing without TRAIT_HYPOSPRAY_IMMUNE.
	var/penetrate_thick = FALSE
	/// If TRUE, the hypospray isn't blocked by suits with TRAIT_HYPOSPRAY_IMMUNE.
	var/ignore_hypospray_immunity = FALSE
	/// if TRUE, the hypospray will always succeed at injecting an organic limb regardless of protective clothing or traits such as the thick skin gene (except for TRAIT_HYPOSPRAY_IMMUNE).
	var/penetrate_everything = FALSE
	/// If TRUE, the hypospray will reject any chemicals not on the safe_chem_list.
	var/safety_hypo = FALSE
	// List of SOSHA-approved medicines.
	/// List of reagents that are allowed to go into a hypospray with active safeties.
	var/static/list/safe_chem_list = list("antihol", "charcoal", "epinephrine", "insulin", "teporone", "salbutamol", "omnizine",
									"weak_omnizine", "godblood", "potass_iodide", "oculine", "mannitol", "spaceacillin", "salglu_solution",
									"sal_acid", "cryoxadone", "sugar", "hydrocodone", "mitocholide", "rezadone", "menthol",
									"mutadone", "sanguine_reagent", "iron", "ephedrine", "heparin", "corazone", "sodiumchloride",
									"lavaland_extract", "synaptizine", "bicaridine", "kelotane")

/obj/item/reagent_containers/hypospray/proc/apply(mob/living/M, mob/user)
	if(!reagents.total_volume)
		to_chat(user, "<span class='warning'>[src] is empty!</span>")
		return

	if(!iscarbon(M))
		return

	var/mob/living/carbon/human/H = M
	if(H.wear_suit)
		// This check is here entirely to stop goobers injecting Nukies, the SST, and the Deathsquad with meme chems.
		if(HAS_TRAIT(H.wear_suit, TRAIT_HYPOSPRAY_IMMUNE) && !ignore_hypospray_immunity)
			to_chat(user, "<span class='warning'>[src] is unable to penetrate the armour of [M] or interface with any injection ports.</span>")
			return

	if(reagents.total_volume && M.can_inject(user, TRUE, user.zone_selected, penetrate_thick, penetrate_everything))
		to_chat(M, "<span class='warning'>You feel a tiny prick!</span>")
		to_chat(user, "<span class='notice'>You inject [M] with [src].</span>")

		if(M.reagents)
			var/list/injected = list()
			for(var/datum/reagent/R in reagents.reagent_list)
				injected += R.name

			var/primary_reagent_name = reagents.get_master_reagent_name()
			var/trans = reagents.trans_to(M, amount_per_transfer_from_this)

			if(safety_hypo)
				visible_message("<span class='warning'>[user] injects [M] with [trans] units of [primary_reagent_name].</span>")
				playsound(loc, 'sound/goonstation/items/hypo.ogg', 80, 0)

			to_chat(user, "<span class='notice'>[trans] unit\s injected.  [reagents.total_volume] unit\s remaining in [src].</span>")

			var/contained = english_list(injected)

			add_attack_logs(user, M, "Injected with [src] containing ([contained])", reagents.harmless_helper() ? ATKLOG_ALMOSTALL : null)
			reagents.reaction(M, REAGENT_INGEST, 0.1)
		return TRUE

/obj/item/reagent_containers/hypospray/mob_act(mob/target, mob/living/user)
	apply(target, user)
	return TRUE

/obj/item/reagent_containers/hypospray/activate_self(mob/user)
	if(..())
		return FINISH_ATTACK

	apply(user, user)

/obj/item/reagent_containers/hypospray/item_interaction(mob/living/user, obj/item/I, list/modifiers)
	if(is_pen(I))
		rename_interactive(user, I, use_prefix = TRUE, prompt = "Give [src] a title.")
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/item/reagent_containers/hypospray/examine(mob/user)
	. = ..()
	if(Adjacent(user))
		. += "<span class='notice'>You can use a pen to add a label to [src].</span>"

/obj/item/reagent_containers/hypospray/on_reagent_change()
	if(safety_hypo && !emagged)
		var/found_forbidden_reagent = FALSE
		for(var/datum/reagent/R in reagents.reagent_list)
			if(!safe_chem_list.Find(R.id))
				reagents.del_reagent(R.id)
				found_forbidden_reagent = TRUE
		if(found_forbidden_reagent)
			if(ismob(loc))
				to_chat(loc, "<span class='warning'>[src] identifies and removes a harmful substance.</span>")
			else
				visible_message("<span class='warning'>[src] identifies and removes a harmful substance.</span>")

/obj/item/reagent_containers/hypospray/emag_act(mob/user)
	if(safety_hypo && !emagged)
		emagged = TRUE
		penetrate_thick = TRUE
		penetrate_everything = TRUE
		to_chat(user, "<span class='warning'>You short out the safeties on [src].</span>")
		return TRUE

//////////////////////////////
// MARK: HYPO VARIANTS
//////////////////////////////
/obj/item/reagent_containers/hypospray/safety
	name = "medical hypospray"
	desc = "A general use medical hypospray for quick injection of chemicals. There is a safety button by the trigger."
	icon_state = "medivend_hypo"
	safety_hypo = TRUE

/obj/item/reagent_containers/hypospray/safety/ert
	name = "medical hypospray (Omnizine)"
	icon_state = "ert_hypo"
	list_reagents = list("omnizine" = 30)

/obj/item/reagent_containers/hypospray/combat
	name = "combat stimulant injector"
	desc = "A modified air-needle autoinjector, used by support operatives to quickly heal injuries in combat. It has a proprietary adapter allowing it to inject through the ports of Syndicate-made hardsuits."
	amount_per_transfer_from_this = 15
	possible_transfer_amounts = list(5, 10, 15, 20, 25, 30)
	icon_state = "combat_hypo"
	volume = 90
	penetrate_thick = TRUE // So they can heal their comrades.
	ignore_hypospray_immunity = TRUE
	penetrate_everything = TRUE
	list_reagents = list("epinephrine" = 30, "weak_omnizine" = 30, "salglu_solution" = 30)

/obj/item/reagent_containers/hypospray/combat/nanites
	desc = "A modified air-needle autoinjector for use in combat situations. Prefilled with a cocktail of experimental combat drugs and <b>extremely</b> expensive medical nanomachines. Capable of healing almost any injury in just a few seconds. It can interface with the injection ports on any type of hardsuit."
	icon_state = "nanites_hypo"
	volume = 100
	list_reagents = list("nanites" = 100)

/obj/item/reagent_containers/hypospray/combat/syndicate_nanites
	name = "medical nanite injector"
	desc = "A modified air-needle autoinjector for use in combat situations. Prefilled with expensive medical nanomachines for rapid field stabilization."
	volume = 100
	list_reagents = list("syndicate_nanites" = 100)

//////////////////////////////
// MARK: CMO HYPO
//////////////////////////////
/obj/item/reagent_containers/hypospray/cmo
	name = "advanced hypospray"
	desc = "Nanotrasen's own, reverse-engineered and improved version of DeForest's hypospray."
	list_reagents = list("omnizine" = 30)
	volume = 100
	penetrate_thick = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/reagent_containers/hypospray/cmo/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/high_value_item)

/obj/item/reagent_containers/hypospray/cmo/examine_more(mob/user)
	. = ..()
	. += "The DeForest Medical Corporation's hypospray is a highly successful medical device currently under patent protection. Naturally, this has not stopped Nanotrasen from taking the design and tinkering with it."
	. += ""
	. += "Nanotrasen's version sports a chemical reserviour over 3 times the size. The injector head is able to produce such a fine high-pressure stream that it can pierce through most armour, this \
	pressurised jet is automatically adjusted to ensure no harm comes to patients with thinner or absent clothing. \
	It is also able to interface with the autoinjector ports found on mordern hardsuits. As this is a prototype, it currently lacks safety features to prevent harmful chemicals being added."
	. += ""
	. += "These hyposprays are mostly kept under lock and key (with some being distributed to NT's CMOs on some stations), waiting for the exact moment that the patent protection on DeForest's design expires."

//////////////////////////////
// MARK: AUTOINJECTOR
//////////////////////////////
/obj/item/reagent_containers/hypospray/autoinjector
	name = "empty autoinjector"
	desc = "A rapid and safe way to inject chemicals into humanoids. This one is empty."
	icon_state = "autoinjector"
	inhand_icon_state = "autoinjector"
	belt_icon = "autoinjector"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = null
	volume = 10
	penetrate_thick = TRUE
	ignore_hypospray_immunity = TRUE
	penetrate_everything = TRUE // Autoinjectors bypass everything.
	container_type = DRAWABLE

/obj/item/reagent_containers/hypospray/autoinjector/on_reagent_change()
	update_icon(UPDATE_ICON_STATE)

/obj/item/reagent_containers/hypospray/autoinjector/update_icon_state()
	if(reagents.total_volume > 0)
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]0"

/obj/item/reagent_containers/hypospray/autoinjector/examine()
	. = ..()
	if(length(reagents?.reagent_list))
		. += "<span class='notice'>It is currently loaded.</span>"
	else
		. += "<span class='notice'>It is spent.</span>"

/obj/item/reagent_containers/hypospray/autoinjector/epinephrine
	name = "emergency autoinjector"
	desc = "A rapid and safe way to stabilize patients in critical condition for personnel without advanced medical knowledge."
	list_reagents = list("epinephrine" = 10)

/// basilisks
/obj/item/reagent_containers/hypospray/autoinjector/teporone
	name = "teporone autoinjector"
	desc = "A rapid way to regulate your body's temperature in the event of a hardsuit malfunction."
	icon_state = "lepopen"
	list_reagents = list("teporone" = 10)

/// goliath kiting
/obj/item/reagent_containers/hypospray/autoinjector/stimpack
	name = "stimpack autoinjector"
	desc = "A rapid way to stimulate your body's adrenaline, allowing for freer movement in restrictive armor."
	icon_state = "stimpen"
	volume = 20
	amount_per_transfer_from_this = 20
	list_reagents = list("methamphetamine" = 10, "coffee" = 10)

/obj/item/reagent_containers/hypospray/autoinjector/stimulants
	name = "Stimulants autoinjector"
	desc = "Rapidly stimulates and regenerates the body's organ system."
	icon_state = "stimulantspen"
	amount_per_transfer_from_this = 50
	volume = 50
	list_reagents = list("stimulants" = 50)

/obj/item/reagent_containers/hypospray/autoinjector/survival
	name = "survival medipen"
	desc = "A medipen for surviving in the harshest of environments, heals and protects from environmental hazards. <br><span class='boldwarning'>WARNING: Do not inject more than one pen in quick succession.</span>"
	icon_state = "survpen"
	volume = 42
	amount_per_transfer_from_this = 42
	list_reagents = list("salbutamol" = 10, "teporone" = 15, "epinephrine" = 10, "lavaland_extract" = 2, "weak_omnizine" = 5)

/obj/item/reagent_containers/hypospray/autoinjector/emergency_nuclear
	name = "emergency stabilization medipen"
	desc = "A fast acting life-saving emergency autoinjector. Effective in combat situations, made by the syndicate for the syndicate."
	icon_state = "stimpen"
	volume = 12
	amount_per_transfer_from_this = 12
	list_reagents = list("perfluorodecalin" = 3, "teporone" = 3, "atropine" = 3, "mannitol" = 3)

/obj/item/reagent_containers/hypospray/autoinjector/nanocalcium
	name = "protoype nanite autoinjector"
	desc = "A highly experimental prototype chemical designed to fully mend limbs and organs of soldiers in the field, shuts down body systems whilst aiding in repair.<br><span class='boldwarning'>WARNING: Side effects can cause temporary paralysis, loss of co-ordination and sickness. Do not use with any kind of stimulant or drugs. Serious damage can occur!</span>"
	icon_state = "bonepen"
	amount_per_transfer_from_this = 40
	volume = 40
	list_reagents = list("nanocalcium" = 30, "epinephrine" = 10)

/obj/item/reagent_containers/hypospray/autoinjector/nanocalcium/apply(mob/living/M, mob/user)
	if(..())
		playsound(loc, 'sound/weapons/smg_empty_alarm.ogg', 20, TRUE)

/obj/item/reagent_containers/hypospray/autoinjector/zombiecure
	name = "\improper Anti-Plague Sequence Alpha autoinjector"
	desc = "A small autoinjector containing 15 units of Anti-Plague Sequence Alpha. Prevents infection, cures level 1 infection."
	icon_state = "zombiepen"
	amount_per_transfer_from_this = 15
	volume = 15
	container_type = NONE // No sucking out the reagent
	list_reagents = list("zombiecure1" = 15)

/obj/item/reagent_containers/hypospray/autoinjector/zombiecure/apply(mob/living/M, mob/user)
	if(..())
		playsound(loc, 'sound/weapons/smg_empty_alarm.ogg', 20, TRUE) //Sucker for sounds, also gets zombies attention.

/obj/item/reagent_containers/hypospray/autoinjector/zombiecure/zombiecure2
	name = "\improper Anti-Plague Sequence Beta autoinjector"
	desc = "A small autoinjector containing 15 units of Anti-Plague Sequence Beta. Weakens zombies, heals low infections."
	list_reagents = list("zombiecure2" = 15)

/obj/item/reagent_containers/hypospray/autoinjector/zombiecure/zombiecure3
	name = "\improper Anti-Plague Sequence Gamma autoinjector"
	desc = "A small autoinjector containing 15 units of Anti-Plague Sequence Gamma. Lowers zombies healing. Heals stage 5 and slows stage 6 infections."
	list_reagents = list("zombiecure3" = 15)

/obj/item/reagent_containers/hypospray/autoinjector/zombiecure/zombiecure4
	name = "\improper Anti-Plague Sequence Omega autoinjector"
	desc = "A small autoinjector containing 15 units of Anti-Plague Sequence Omega. Cures all cases of the Necrotizing Plague. Also heals dead limbs."
	list_reagents = list("zombiecure4" = 15)

/obj/item/reagent_containers/hypospray/autoinjector/hyper_medipen
	name = "suspicious medipen"
	desc = "A cheap-looking medipen containing what seems to be a mix of nearly every medicine stored in the recently raided Nanotrasen warehouse."
	icon_state = "hyperpen"
	amount_per_transfer_from_this = 37
	volume = 37
	list_reagents = list("salglu_solution" = 3, "synthflesh" = 4, "omnizine" = 3, "weak_omnizine" = 3, "perfluorodecalin" = 2, "sal_acid" = 1, "bicaridine" = 4, "kelotane" = 4, "epinephrine" = 5, "lavaland_extract" = 2, "rezadone" = 1, "teporone" =  2, "menthol" = 1, "vitamin" = 2)

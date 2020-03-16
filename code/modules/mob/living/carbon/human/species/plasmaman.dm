/datum/species/plasmaman
	name = "Plasmaman"
	name_plural = "Plasmamen"
	icobase = 'icons/mob/human_races/r_plasmaman_sb.dmi'
	deform = 'icons/mob/human_races/r_plasmaman_pb.dmi'  // TODO: Need deform.
	dangerous_existence = TRUE //So so much
	//language = "Clatter"

	species_traits = list(IS_WHITELISTED, RADIMMUNE, NO_BLOOD, NO_HUNGER, NOTRANSSTING)
	forced_heartattack = TRUE // Plasmamen have no blood, but they should still get heart-attacks
	skinned_type = /obj/item/stack/sheet/mineral/plasma // We're low on plasma, R&D! *eyes plasmaman co-worker intently*
	dietflags = DIET_OMNI
	reagent_tag = PROCESS_ORG

	taste_sensitivity = TASTE_SENSITIVITY_NO_TASTE //skeletons can't taste anything

	butt_sprite = "plasma"

	breathid = "tox"

	burn_mod = 1.5
	heatmod = 1.5
	brute_mod = 1.5

	//Has default darksight of 2.

	suicide_messages = list(
		"is twisting their own neck!",
		"is letting some O2 in!",
		"realizes the existential problem of being made out of plasma!",
		"shows their true colors, which happens to be the color of plasma!")

	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart/plasmaman,
		"lungs" =    /obj/item/organ/internal/lungs/plasmaman,
		"liver" =    /obj/item/organ/internal/liver/plasmaman,
		"kidneys" =  /obj/item/organ/internal/kidneys/plasmaman,
		"brain" =    /obj/item/organ/internal/brain/plasmaman,
		"eyes" =     /obj/item/organ/internal/eyes/plasmaman
		)

	speciesbox = /obj/item/storage/box/survival_plasmaman
	flesh_color = "#8b3fba"

/datum/species/plasmaman/say_filter(mob/M, message, datum/language/speaking)
	if(copytext(message, 1, 2) != "*")
		message = replacetext(message, "s", stutter("ss"))
	return message

/datum/species/plasmaman/before_equip_job(datum/job/J, mob/living/carbon/human/H, visualsOnly = FALSE)
	var/current_job = J.title
	var/datum/outfit/plasmaman/O = new /datum/outfit/plasmaman
	switch(current_job)
		if("Chaplain")
			O = new /datum/outfit/plasmaman/chaplain

		if("Librarian")
			O = new /datum/outfit/plasmaman/librarian

		if("Janitor")
			O = new /datum/outfit/plasmaman/janitor

		if("Botanist")
			O = new /datum/outfit/plasmaman/botany

		if("Bartender", "Internal Affairs Agent", "Magistrate", "Nanotrasen Representative", "Nanotrasen Navy Officer")
			O = new /datum/outfit/plasmaman/bar

		if("Chef")
			O = new /datum/outfit/plasmaman/chef

		if("Security Officer", "Security Pod Pilot", "Special Operations Officer")
			O = new /datum/outfit/plasmaman/security

		if("Detective")
			O = new /datum/outfit/plasmaman/detective

		if("Warden")
			O = new /datum/outfit/plasmaman/warden

		if("Head of Security")
			O = new /datum/outfit/plasmaman/hos

		if("Cargo Technician", "Quartermaster")
			O = new /datum/outfit/plasmaman/cargo

		if("Shaft Miner")
			O = new /datum/outfit/plasmaman/mining

		if("Medical Doctor", "Brig Physician", "Paramedic", "Coroner")
			O = new /datum/outfit/plasmaman/medical

		if("Chief Medical Officer")
			O = new /datum/outfit/plasmaman/cmo

		if("Chemist")
			O = new /datum/outfit/plasmaman/chemist

		if("Geneticist")
			O = new /datum/outfit/plasmaman/genetics

		if("Roboticist")
			O = new /datum/outfit/plasmaman/robotics

		if("Virologist")
			O = new /datum/outfit/plasmaman/viro

		if("Scientist")
			O = new /datum/outfit/plasmaman/science

		if("Research Director")
			O = new /datum/outfit/plasmaman/rd

		if("Station Engineer", "Mechanic")
			O = new /datum/outfit/plasmaman/engineering

		if("Chief Engineer")
			O = new /datum/outfit/plasmaman/ce

		if("Life Support Specialist")
			O = new /datum/outfit/plasmaman/atmospherics

		if("Mime")
			O = new /datum/outfit/plasmaman/mime

		if("Clown")
			O = new /datum/outfit/plasmaman/clown

		if("Head of Personnel")
			O = new /datum/outfit/plasmaman/hop

		if("Captain")
			O = new /datum/outfit/plasmaman/captain

		if("Blueshield")
			O = new /datum/outfit/plasmaman/blueshield

	H.equipOutfit(O, visualsOnly)
	H.internal = H.r_hand
	H.update_action_buttons_icon()
	return FALSE

/datum/species/plasmaman/handle_life(mob/living/carbon/human/H)
	var/datum/gas_mixture/environment = H.loc.return_air()
	var/atmos_sealed = FALSE
	if (H.wear_suit && H.head && istype(H.wear_suit, /obj/item/clothing) && istype(H.head, /obj/item/clothing))
		var/obj/item/clothing/CS = H.wear_suit
		var/obj/item/clothing/CH = H.head
		if (CS.flags & CH.flags & STOPSPRESSUREDMAGE)
			atmos_sealed = TRUE
	if((!istype(H.w_uniform, /obj/item/clothing/under/plasmaman) || !istype(H.head, /obj/item/clothing/head/helmet/space/plasmaman)) && !atmos_sealed)
		if(environment)
			if(environment.total_moles())
				if(environment.oxygen && environment.oxygen >= OXYCONCEN_PLASMEN_IGNITION) //Same threshhold that extinguishes fire
					H.adjust_fire_stacks(0.5)
					if(!H.on_fire && H.fire_stacks > 0)
						H.visible_message("<span class='danger'>[H]'s body reacts with the atmosphere and bursts into flames!</span>","<span class='userdanger'>Your body reacts with the atmosphere and bursts into flame!</span>")
					H.IgniteMob()
	else
		if(H.fire_stacks)
			var/obj/item/clothing/under/plasmaman/P = H.w_uniform
			if(istype(P))
				P.Extinguish(H)
	H.update_fire()
	..()

/datum/species/plasmaman/handle_reagents(mob/living/carbon/human/H, datum/reagent/R)
	if(R.id == "plasma" || R.id == "plasma_dust")
		H.adjustBruteLoss(-0.5*REAGENTS_EFFECT_MULTIPLIER)
		H.adjustFireLoss(-0.5*REAGENTS_EFFECT_MULTIPLIER)
		H.adjustPlasma(20)
		H.reagents.remove_reagent(R.id, REAGENTS_METABOLISM)
		return FALSE //Handling reagent removal on our own. Prevents plasma from dealing toxin damage to Plasmamen.

	return ..()

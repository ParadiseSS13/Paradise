/datum/species/plasmaman
	name = "Plasmaman"
	name_plural = "Plasmamen"
	max_age = 150
	icobase = 'icons/mob/human_races/r_plasmaman_sb.dmi'
	dangerous_existence = TRUE //So so much
	//language = "Clatter"

	blurb = "Plasmamen are the remnants of a species that was either exiled to, or crashed upon, the plasma-rich world of Boron. \
	Believed to have initially served as indentured labourers, Plasmamen are the result of chronic plasma exposure throughout several hundred generations.<br/><br/> \
	Their leaders must ritually self-immolate and are only allowed to hold office for as long as they remain on fire."

	species_traits = list(NO_BLOOD, NO_HAIR)
	inherent_traits = list(TRAIT_RADIMMUNE, TRAIT_NOHUNGER, TRAIT_BURN_WOUND_IMMUNE)
	inherent_biotypes = MOB_HUMANOID | MOB_MINERAL
	forced_heartattack = TRUE // Plasmamen have no blood, but they should still get heart-attacks
	dietflags = DIET_OMNI
	bodyflags = BALD | SHAVED
	reagent_tag = PROCESS_ORG

	taste_sensitivity = TASTE_SENSITIVITY_NO_TASTE //skeletons can't taste anything

	butt_sprite = "plasma"

	breathid = "tox"

	burn_mod = 1.5
	heatmod = 1.5

	//Has default darksight of 2.

	suicide_messages = list(
		"is twisting their own neck!",
		"is letting some O2 in!",
		"realizes the existential problem of being made out of plasma!",
		"shows their true colors, which happens to be the color of plasma!")

	skinned_type = /obj/item/stack/sheet/mineral/plasma // We're low on plasma, R&D! *eyes plasmaman co-worker intently*
	meat_type = /obj/item/food/meat/human
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
	autohiss_basic_map = list(
			"s" = list("ss", "sss", "ssss")
		)

	plushie_type = /obj/item/toy/plushie/plasmamanplushie

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

		if("Bartender", "Internal Affairs Agent", "Magistrate", "Nanotrasen Representative")
			O = new /datum/outfit/plasmaman/bar

		if("Chef")
			O = new /datum/outfit/plasmaman/chef

		if("Security Officer")
			O = new /datum/outfit/plasmaman/security

		if("Detective")
			O = new /datum/outfit/plasmaman/detective

		if("Warden")
			O = new /datum/outfit/plasmaman/warden

		if("Head of Security")
			O = new /datum/outfit/plasmaman/hos

		if("Cargo Technician", "Quartermaster")
			O = new /datum/outfit/plasmaman/cargo

		if("Explorer")
			O = new /datum/outfit/plasmaman/expedition

		if("Shaft Miner")
			O = new /datum/outfit/plasmaman/mining

		if("Smith")
			O = new /datum/outfit/plasmaman/smith

		if("Medical Doctor", "Paramedic", "Coroner")
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

		if("Station Engineer")
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

		if("Assistant")
			O = new /datum/outfit/plasmaman/assistant

		if("Nanotrasen Career Trainer")
			O = new /datum/outfit/plasmaman/trainer

		if("Nanotrasen Navy Officer")
			O = new /datum/outfit/plasmaman/navyofficer

		if("Special Operations Officer", "Trans-Solar Federation General")
			O = new /datum/outfit/plasmaman/soo

	H.equipOutfit(O, visualsOnly)
	H.update_action_buttons_icon()

/datum/species/plasmaman/handle_life(mob/living/carbon/human/H)
	var/atmos_sealed = !HAS_TRAIT(H, TRAIT_NOFIRE) && (isclothing(H.wear_suit) && H.wear_suit.flags & STOPSPRESSUREDMAGE) && (isclothing(H.head) && H.head.flags & STOPSPRESSUREDMAGE)
	if(!atmos_sealed && (!istype(H.w_uniform, /obj/item/clothing/under/plasmaman) || !istype(H.head, /obj/item/clothing/head/helmet/space/plasmaman) && !HAS_TRAIT(H, TRAIT_NOSELFIGNITION_HEAD_ONLY)))
		var/datum/gas_mixture/environment = null
		if(isobj(H.loc))
			var/obj/O = H.loc
			environment = O.return_obj_air()
		if(isnull(environment))
			var/turf/T = get_turf(H)
			environment = T.get_readonly_air()
		if(environment)
			if(environment.total_moles())
				if(!HAS_TRAIT(H, TRAIT_NOFIRE))
					if(environment.oxygen() && environment.oxygen() >= OXYCONCEN_PLASMEN_IGNITION) //Same threshhold that extinguishes fire
						H.adjust_fire_stacks(0.5)
						if(!H.on_fire && H.fire_stacks > 0)
							H.visible_message("<span class='danger'>[H]'s body reacts with the atmosphere and bursts into flames!</span>","<span class='userdanger'>Your body reacts with the atmosphere and bursts into flame!</span>")
						H.IgniteMob()
	else if(H.fire_stacks)
		var/obj/item/clothing/under/plasmaman/P = H.w_uniform
		if(istype(P))
			P.Extinguish(H)
	H.update_fire()
	..()

/datum/species/plasmaman/handle_reagents(mob/living/carbon/human/H, datum/reagent/R)
	if(R.id == "plasma" || R.id == "plasma_dust")
		H.adjustBruteLoss(-0.5*REAGENTS_EFFECT_MULTIPLIER)
		H.adjustFireLoss(-0.5*REAGENTS_EFFECT_MULTIPLIER)
		H.add_plasma(20)
		H.reagents.remove_reagent(R.id, REAGENTS_METABOLISM)
		return FALSE //Handling reagent removal on our own. Prevents plasma from dealing toxin damage to Plasmamen.

	return ..()

/datum/species/plasmaman/after_equip_job(datum/job/J, mob/living/carbon/human/H)
	if(!H.mind || !H.mind.assigned_role || H.mind.assigned_role != "Clown" && H.mind.assigned_role != "Mime")
		H.drop_item_to_ground(H.wear_mask)

	H.equip_or_collect(new /obj/item/clothing/mask/breath(H), ITEM_SLOT_MASK)
	var/tank_pref = H.client && H.client.prefs ? H.client.prefs.active_character.speciesprefs : null
	var/obj/item/tank/internal_tank
	if(tank_pref) //Diseasel, here you go
		internal_tank = new /obj/item/tank/internals/plasmaman/full(H)
	else
		internal_tank = new /obj/item/tank/internals/plasmaman/belt/full(H)
	if(!H.equip_to_appropriate_slot(internal_tank) && !H.put_in_any_hand_if_possible(internal_tank))
		H.drop_item_to_ground(H.l_hand)
		H.equip_or_collect(internal_tank, ITEM_SLOT_LEFT_HAND)
		to_chat(H, "<span class='boldannounceooc'>Could not find an empty slot for internals! Please report this as a bug.</span>")
		stack_trace("Failed to equip plasmaman with a tank, with the job [J.type]")
	H.internal = internal_tank
	to_chat(H, "<span class='notice'>You are now running on plasma internals from [internal_tank]. Oxygen is toxic to your species, so you must breathe plasma only.</span>")
	H.update_action_buttons_icon()

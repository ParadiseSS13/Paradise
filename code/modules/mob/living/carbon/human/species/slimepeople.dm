#define SLIMEPERSON_COLOR_SHIFT_TRIGGER 0.1
#define SLIMEPERSON_ICON_UPDATE_PERIOD 200 // 20 seconds
#define SLIMEPERSON_BLOOD_SCALING_FACTOR 5 // Used to adjust how much of an effect the blood has on the rate of color change. Higher is slower.

#define SLIMEPERSON_HUNGERCOST 50
#define SLIMEPERSON_MINHUNGER 250
#define SLIMEPERSON_REGROWTHDELAY 450 // 45 seconds

#define SLIMEPERSON_MORPH_FORM	10 SECONDS

/datum/species/slime
	name = "Slime People"
	name_plural = "Slime People"
	max_age = 130
	language = "Bubblish"

	blurb = "Slime People are gelatinous and translucent beings hailing from the tropical world of Xarxis 5 and surrounding Xarxis Republic. \
	Relatively recent entrants to the galactic scene, the Xarxis Republic, and slime people by extension, were discovered in the mid-2400s by a TSF survery fleet..<br/><br/> \
	Today, the Xarxis Republic is a member state of the Trans-Solar Federation, having become an Associate State following first contact, and later moving through several stages of integration.  \
	While a great deal of Slime People prefer the comforts and traditions of their home system and the Federation, a number have decided to take their chances in the wider sector, in \
	search of adventure, profit, and freedom among the stars."

	icobase = 'icons/mob/human_races/r_slime.dmi'
	remains_type = /obj/effect/decal/remains/slime
	inherent_factions = list("slime")

	// More sensitive to the cold
	cold_level_1 = 280
	cold_level_2 = 240
	cold_level_3 = 200
	coldmod = 3

	brain_mod = 1.5

	male_cough_sounds = list('sound/effects/slime_squish.ogg')
	female_cough_sounds = list('sound/effects/slime_squish.ogg')

	species_traits = list(LIPS, NO_CLONESCAN, EXOTIC_COLOR)
	inherent_traits = list(TRAIT_WATERBREATH, TRAIT_NO_BONES)
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_SKIN_COLOR | NO_EYES | HAS_SPECIES_SUBTYPE
	dietflags = DIET_CARN
	reagent_tag = PROCESS_ORG

	flesh_color = "#5fe8b1"
	blood_color = "#0064C8"
	exotic_blood = "slimejelly"

	butt_sprite = "slime"
	//Has default darksight of 2.

	vision_organ = null
	has_organ = list(
		"brain" = /obj/item/organ/internal/brain/slime
		)
	mutantears = null
	suicide_messages = list(
		"is melting into a puddle!",
		"is ripping out their own core!",
		"is turning a dull, brown color and melting into a puddle!")

	allowed_species_subtypes = list(
		1 = "None",
		2 = "Vox",
		3 = "Unathi",
		4 = "Tajaran",
		5 = "Nian",
		6 = "Vulpkanin",
		7 = "Kidan",
		8 = "Grey",
		9 = "Drask"
	)

	var/reagent_skin_coloring = FALSE
	var/static_bodyflags = HAS_SKIN_COLOR | NO_EYES | HAS_SPECIES_SUBTYPE

	plushie_type = /obj/item/toy/plushie/slimeplushie

/datum/species/slime/on_species_gain(mob/living/carbon/human/H)
	..()
	var/datum/action/innate/regrow/grow = new()
	grow.Grant(H)
	var/datum/action/innate/slimecolor/recolor = new()
	recolor.Grant(H)
	var/datum/action/innate/morphform/reform = new()
	reform.Grant(H)
	RegisterSignal(H, COMSIG_HUMAN_UPDATE_DNA, PROC_REF(blend))
	blend(H)


/datum/species/slime/on_species_loss(mob/living/carbon/human/H)
	..()
	for(var/datum/action/innate/i in H.actions)
		if(istype(i, /datum/action/innate/slimecolor))
			i.Remove(H)
		if(istype(i, /datum/action/innate/regrow))
			i.Remove(H)
		if(istype(i, /datum/action/innate/morphform))
			i.Remove(H)
	UnregisterSignal(H, COMSIG_HUMAN_UPDATE_DNA)

/datum/species/slime/updatespeciessubtype(mob/living/carbon/human/H, datum/species/new_subtype, owner_sensitive = TRUE, reset_styles = TRUE) //Handling species-subtype and imitation
	if(H.dna.species.bodyflags & HAS_SPECIES_SUBTYPE)
		var/datum/species/temp_species = new type()
		if(isnull(new_subtype) || temp_species.name == new_subtype.name) // Back to our original species.
			H.species_subtype = "None"
			temp_species.species_subtype = "None" // Update our species subtype to match the Mob's subtype.
			var/datum/species/S = GLOB.all_species[temp_species.name]
			new_subtype = new S.type() // Resets back to original. We use initial in the case the datum is var edited.
		else
			H.species_subtype = new_subtype.name
			temp_species.species_subtype = H.species_subtype // Update our species subtype to match the Mob's subtype.

		// Copy over new species variables to our current species.
		temp_species.icobase = new_subtype.icobase
		temp_species.tail = new_subtype.tail
		temp_species.wing = new_subtype.wing
		temp_species.eyes = new_subtype.eyes
		temp_species.scream_verb = new_subtype.scream_verb
		temp_species.male_scream_sound = new_subtype.male_scream_sound
		temp_species.female_scream_sound = new_subtype.female_scream_sound
		temp_species.default_headacc = new_subtype.default_headacc
		temp_species.default_bodyacc = new_subtype.default_bodyacc
		temp_species.male_cough_sounds = new_subtype.male_cough_sounds
		temp_species.female_cough_sounds = new_subtype.female_cough_sounds
		temp_species.male_sneeze_sound = new_subtype.male_sneeze_sound
		temp_species.female_sneeze_sound = new_subtype.female_sneeze_sound
		temp_species.bodyflags = new_subtype.bodyflags
		temp_species.bodyflags |= static_bodyflags // Add our static bodyflags that slime must always have.
		temp_species.sprite_sheet_name = new_subtype.sprite_sheet_name
		temp_species.icon_template = new_subtype.icon_template
		H.dna.species = temp_species

		for(var/obj/item/organ/external/limb in H.bodyparts)
			limb.icobase = temp_species.icobase // update their icobase for when we apply the slimfy effect
			limb.dna.species = temp_species // Update limb to match our newly modified species
			limb.set_company(limb.model, temp_species.sprite_sheet_name) // Robotic limbs always update to our new subtype.

		// Update misc parts that are stored as reference in species and used on the mob. Also resets stylings to none to prevent anything wacky...

		if(reset_styles)
			H.body_accessory = GLOB.body_accessory_by_name[default_bodyacc]
			H.tail = temp_species.tail
			H.wing = temp_species.wing
			var/obj/item/organ/external/head/head = H.get_organ("head")
			head.h_style = "Bald"
			head.f_style = "Shaved"
			head.ha_style = "None"
			H.s_tone = 0
			H.m_styles = DEFAULT_MARKING_STYLES //Wipes out markings, setting them all to "None".
			H.m_colours = DEFAULT_MARKING_COLOURS //Defaults colour to #00000 for all markings.
			H.change_head_accessory(GLOB.head_accessory_styles_list[default_headacc])
		H.change_icobase(temp_species.icobase, owner_sensitive) //Update the icobase of all our organs, but make sure we don't mess with frankenstein limbs in doing so.

/datum/species/slime/proc/blend(mob/living/carbon/human/H)
	var/new_color = BlendRGB(H.skin_colour, "#acacac", 0.5) // Blends this to make it work better
	if(H.dna.species.blood_color != new_color) // Put here, so if it's a roundstart, dyed, or CMA'd slime, their blood changes to match skin
		H.dna.species.blood_color = new_color

/datum/species/slime/handle_life(mob/living/carbon/human/H)
	// Slowly shifting to the color of the reagents
	if(reagent_skin_coloring && H.reagents.total_volume > SLIMEPERSON_COLOR_SHIFT_TRIGGER)
		var/blood_amount = H.blood_volume
		var/r_color = mix_color_from_reagents(H.reagents.reagent_list)
		var/new_body_color = BlendRGB(r_color, H.skin_colour, (blood_amount*SLIMEPERSON_BLOOD_SCALING_FACTOR)/((blood_amount*SLIMEPERSON_BLOOD_SCALING_FACTOR)+(H.reagents.total_volume)))
		H.skin_colour = new_body_color
		if(world.time % SLIMEPERSON_ICON_UPDATE_PERIOD > SLIMEPERSON_ICON_UPDATE_PERIOD - 20) // The 20 is because this gets called every 2 seconds, from the mob controller
			for(var/organname in H.bodyparts_by_name)
				var/obj/item/organ/external/E = H.bodyparts_by_name[organname]
				if(istype(E) && E.dna && istype(E.dna.species, /datum/species/slime))
					E.sync_colour_to_human(H)
			H.update_hair()
			H.update_body()
			blend(H)
	..()

/datum/species/slime/can_hear(mob/living/carbon/human/H) // fucking snowflakes
	. = FALSE
	if(!HAS_TRAIT(H, TRAIT_DEAF))
		. = TRUE

/datum/action/innate/slimecolor
	name = "Toggle Recolor"
	check_flags = AB_CHECK_CONSCIOUS
	button_overlay_icon = 'icons/effects/effects.dmi'
	button_overlay_icon_state = "greenglow"

/datum/action/innate/slimecolor/Activate()
	var/mob/living/carbon/human/H = owner
	var/datum/species/slime/S = H.dna.species
	if(S.reagent_skin_coloring)
		S.reagent_skin_coloring = FALSE
		to_chat(H, "You adjust your internal chemistry to filter out pigments from things you consume.")
	else
		S.reagent_skin_coloring = TRUE
		to_chat(H, "You adjust your internal chemistry to permit pigments in chemicals you consume to tint you.")

/datum/action/innate/regrow
	name = "Regrow limbs"
	check_flags = AB_CHECK_CONSCIOUS
	button_overlay_icon = 'icons/effects/effects.dmi'
	button_overlay_icon_state = "greenglow"

/datum/action/innate/regrow/Activate()
	var/mob/living/carbon/human/H = owner
	if(H.nutrition < SLIMEPERSON_MINHUNGER)
		to_chat(H, "<span class='warning'>You're too hungry to regenerate a limb!</span>")
		return

	var/list/missing_limbs = list()
	for(var/l in H.bodyparts_by_name)
		var/obj/item/organ/external/E = H.bodyparts_by_name[l]
		if(!istype(E))
			var/list/limb_list = H.dna.species.has_limbs[l]
			var/obj/item/organ/external/limb = limb_list["path"]
			var/parent_organ = initial(limb.parent_organ)
			var/obj/item/organ/external/parentLimb = H.bodyparts_by_name[parent_organ]
			if(!istype(parentLimb))
				continue
			missing_limbs[initial(limb.name)] = l

	if(!length(missing_limbs))
		to_chat(H, "<span class='warning'>You're not missing any limbs!</span>")
		return

	var/limb_select = tgui_input_list(H, "Choose a limb to regrow", "Limb Regrowth", missing_limbs)
	if(!limb_select) // If the user hit cancel on the popup, return
		return
	var/chosen_limb = missing_limbs[limb_select]

	H.visible_message("<span class='notice'>[H] begins to hold still and concentrate on [H.p_their()] missing [limb_select]...</span>", "<span class='notice'>You begin to focus on regrowing your missing [limb_select]... (This will take [round(SLIMEPERSON_REGROWTHDELAY/10)] seconds, and you must hold still.)</span>")
	if(do_after(H, SLIMEPERSON_REGROWTHDELAY, FALSE, H, extra_checks = list(CALLBACK(H, TYPE_PROC_REF(/mob/living, IsStunned))), use_default_checks = FALSE)) // Override the check for weakness, only check for stunned
		if(H.incapacitated(extra_checks = list(CALLBACK(H, TYPE_PROC_REF(/mob/living, IsStunned))), use_default_checks = FALSE)) // Override the check for weakness, only check for stunned
			to_chat(H, "<span class='warning'>You cannot regenerate missing limbs in your current state.</span>")
			return

		if(H.nutrition < SLIMEPERSON_MINHUNGER)
			to_chat(H, "<span class='warning'>You're too hungry to regenerate a limb!</span>")
			return

		var/obj/item/organ/external/O = H.bodyparts_by_name[chosen_limb]

		var/stored_brute = 0
		var/stored_burn = 0
		if(istype(O))
			to_chat(H, "<span class='warning'>You distribute the damaged tissue around your body, out of the way of your new pseudopod!</span>")
			var/obj/item/organ/external/doomedStump = O
			stored_brute = doomedStump.brute_dam
			stored_burn = doomedStump.burn_dam
			qdel(O)

		var/limb_list = H.dna.species.has_limbs[chosen_limb]
		var/obj/item/organ/external/limb_path = limb_list["path"]
		// Parent check
		var/obj/item/organ/external/potential_parent = H.bodyparts_by_name[initial(limb_path.parent_organ)]
		if(!istype(potential_parent))
			to_chat(H, "<span class='danger'>You've lost the organ that you've been growing your new part on!</span>")
			return // No rayman for you
		// Grah this line will leave a "not used" warning, in spite of the fact that the new() proc WILL do the thing.
		// Bothersome.
		var/obj/item/organ/external/new_limb = new limb_path(H)
		new_limb.open = ORGAN_CLOSED // This is just so that the compiler won't think that new_limb is unused, because the compiler is horribly stupid.
		H.adjustBruteLoss(stored_brute)
		H.adjustFireLoss(stored_burn)
		H.update_body()
		H.updatehealth()
		H.UpdateDamageIcon()
		H.adjust_nutrition(-SLIMEPERSON_HUNGERCOST)
		H.visible_message("<span class='notice'>[H] finishes regrowing [H.p_their()] missing [new_limb]!</span>", "<span class='notice'>You finish regrowing your [limb_select]</span>")
		new_limb.add_limb_flags()
	else
		to_chat(H, "<span class='warning'>You need to hold still in order to regrow a limb!</span>")

/datum/action/innate/morphform
	name = "Morph Form"
	check_flags = AB_CHECK_CONSCIOUS
	button_overlay_icon = 'icons/effects/effects.dmi'
	button_overlay_icon_state = "acid"

/datum/action/innate/morphform/Activate()

	var/mob/living/carbon/human/H = owner
	if(H.nutrition < SLIMEPERSON_MINHUNGER)
		to_chat(H, "<span class='warning'>You're too hungry to morph your form!</span>")
		return
	var/new_subtype = tgui_input_list(H, "Choose a species to imitate", "Select Subtype", H.dna.species.allowed_species_subtypes)
	if(H.species_subtype == new_subtype)
		return to_chat(H, "<span class='warning'>You stand there as your body shifts and then returns to its original form.</span>")
	H.visible_message("<span class='notice'>[H] begins to hold still and concentrate on [H.p_their()] form as it begins to shift and contort...</span>", "<span class='notice'>You begin to focus on changing your form... (This will take [round(SLIMEPERSON_MORPH_FORM/10)] seconds, and you must hold still.)</span>")
	if(do_after(H, SLIMEPERSON_MORPH_FORM, FALSE, H, extra_checks = list(CALLBACK(H, TYPE_PROC_REF(/mob/living, IsStunned))), use_default_checks = FALSE)) // Override the check for weakness, only check for stunned
		if(H.nutrition < SLIMEPERSON_MINHUNGER)
			to_chat(H, "<span class='warning'>You're too hungry to morph your form!</span>")
			return
		var/datum/species/species_subtype = GLOB.all_species[new_subtype]
		if(isnull(species_subtype))
			species_subtype = GLOB.all_species[H.dna.species.name]
		H.dna.species.updatespeciessubtype(H, new species_subtype.type())
		H.regenerate_icons()
		H.adjust_nutrition(-SLIMEPERSON_HUNGERCOST)
	else
		to_chat(H, "<span class='warning'>You need to hold still in order to shift your form!</span>")

#undef SLIMEPERSON_COLOR_SHIFT_TRIGGER
#undef SLIMEPERSON_ICON_UPDATE_PERIOD
#undef SLIMEPERSON_BLOOD_SCALING_FACTOR

#undef SLIMEPERSON_HUNGERCOST
#undef SLIMEPERSON_MINHUNGER
#undef SLIMEPERSON_REGROWTHDELAY

#undef SLIMEPERSON_MORPH_FORM

/datum/species/slime
	name = "Slime People"
	name_plural = "Slime People"
	language = "Bubblish"
	icobase = 'icons/mob/human_races/r_slime.dmi'
	deform = 'icons/mob/human_races/r_slime.dmi'
	remains_type = /obj/effect/decal/remains/slime

	// More sensitive to the cold
	cold_level_1 = 280
	cold_level_2 = 240
	cold_level_3 = 200
	coldmod = 3

	oxy_mod = 0
	brain_mod = 2.5

	male_cough_sounds = list('sound/effects/slime_squish.ogg')
	female_cough_sounds = list('sound/effects/slime_squish.ogg')

	species_traits = list(LIPS, IS_WHITELISTED, NO_BREATHE, NO_INTORGANS, NO_SCAN)
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_SKIN_COLOR | NO_EYES
	dietflags = DIET_CARN
	reagent_tag = PROCESS_ORG

	blood_color = "#0064C8"
	exotic_blood = "water"
	blood_damage_type = TOX

	butt_sprite = "slime"
	//Has default darksight of 2.

	has_organ = list(
		"brain" = /obj/item/organ/internal/brain/slime
		)

	suicide_messages = list(
		"is melting into a puddle!",
		"is ripping out their own core!",
		"is turning a dull, brown color and melting into a puddle!")

	var/reagent_skin_coloring = FALSE

	var/datum/action/innate/regrow/grow = new()

	species_abilities = list(
		/mob/living/carbon/human/verb/toggle_recolor_verb,
		/mob/living/carbon/human/proc/regrow_limbs
		)

/datum/species/slime/handle_post_spawn(var/mob/living/carbon/human/H)
	grow.Grant(H)
	..()

/datum/action/innate/regrow
	name = "Regrow limbs"
	icon_icon = 'icons/effects/effects.dmi'
	button_icon_state = "greenglow"

/datum/action/innate/regrow/Activate()
	var/mob/living/carbon/human/user = owner
	user.regrow_limbs()


/datum/species/slime/handle_life(var/mob/living/carbon/human/H)
//This is allegedly for code "style". Like a plaid sweater?
#define SLIMEPERSON_COLOR_SHIFT_TRIGGER 0.1
#define SLIMEPERSON_ICON_UPDATE_PERIOD 200 // 20 seconds
#define SLIMEPERSON_BLOOD_SCALING_FACTOR 5 // Used to adjust how much of an effect the blood has on the rate of color change. Higher is slower.
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
			H.update_hair(0)
			H.update_body()
	..()

#undef SLIMEPERSON_COLOR_SHIFT_TRIGGER
#undef SLIMEPERSON_ICON_UPDATE_PERIOD
#undef SLIMEPERSON_BLOOD_SCALING_FACTOR

/mob/living/carbon/human/proc/toggle_recolor(silent = FALSE)
	if(!isslimeperson(src))
		if(!silent)
			to_chat(src, "You're not a slime person!")
		return

	var/datum/species/slime/S = dna.species
	if(S.reagent_skin_coloring)
		S.reagent_skin_coloring = TRUE
		if(!silent)
			to_chat(src, "You adjust your internal chemistry to filter out pigments from things you consume.")
	else
		S.reagent_skin_coloring = TRUE
		if(!silent)
			to_chat(src, "You adjust your internal chemistry to permit pigments in chemicals you consume to tint you.")

/mob/living/carbon/human/verb/toggle_recolor_verb()
	set category = "IC"
	set name = "Toggle Reagent Recoloring"
	set desc = "While active, you'll slowly adjust your body's color to that of the reagents inside of you, moderated by how much blood you have."

	toggle_recolor()


/mob/living/carbon/human/proc/regrow_limbs()
	set category = "IC"
	set name = "Regrow Limbs"
	set desc = "Regrow one of your missing limbs at the cost of a large amount of hunger"

#define SLIMEPERSON_HUNGERCOST 50
#define SLIMEPERSON_MINHUNGER 250
#define SLIMEPERSON_REGROWTHDELAY 450 // 45 seconds

	if(stat || paralysis || stunned)
		to_chat(src, "<span class='warning'>You cannot regenerate missing limbs in your current state.</span>")
		return

	if(nutrition < SLIMEPERSON_MINHUNGER)
		to_chat(src, "<span class='warning'>You're too hungry to regenerate a limb!</span>")
		return

	var/list/missing_limbs = list()
	for(var/l in bodyparts_by_name)
		var/obj/item/organ/external/E = bodyparts_by_name[l]
		if(!istype(E))
			var/list/limblist = dna.species.has_limbs[l]
			var/obj/item/organ/external/limb = limblist["path"]
			var/parent_organ = initial(limb.parent_organ)
			var/obj/item/organ/external/parentLimb = bodyparts_by_name[parent_organ]
			if(!istype(parentLimb))
				continue
			missing_limbs[initial(limb.name)] = l

	if(!missing_limbs.len)
		to_chat(src, "<span class='warning'>You're not missing any limbs!</span>")
		return

	var/limb_select = input(src, "Choose a limb to regrow", "Limb Regrowth") as null|anything in missing_limbs
	var/chosen_limb = missing_limbs[limb_select]

	visible_message("<span class='notice'>[src] begins to hold still and concentrate on [p_their()] missing [limb_select]...</span>", "<span class='notice'>You begin to focus on regrowing your missing [limb_select]... (This will take [round(SLIMEPERSON_REGROWTHDELAY/10)] seconds, and you must hold still.)</span>")
	if(do_after(src, SLIMEPERSON_REGROWTHDELAY, needhand=0, target = src))
		if(stat || paralysis || stunned)
			to_chat(src, "<span class='warning'>You cannot regenerate missing limbs in your current state.</span>")
			return

		if(nutrition < SLIMEPERSON_MINHUNGER)
			to_chat(src, "<span class='warning'>You're too hungry to regenerate a limb!</span>")
			return

		var/obj/item/organ/external/O = bodyparts_by_name[chosen_limb]

		var/stored_brute = 0
		var/stored_burn = 0
		if(istype(O))
			to_chat(src, "<span class='warning'>You distribute the damaged tissue around your body, out of the way of your new pseudopod!</span>")
			var/obj/item/organ/external/doomedStump = O
			stored_brute = doomedStump.brute_dam
			stored_burn = doomedStump.burn_dam
			qdel(O)

		var/limb_list = dna.species.has_limbs[chosen_limb]
		var/obj/item/organ/external/limb_path = limb_list["path"]
		// Parent check
		var/obj/item/organ/external/potential_parent = bodyparts_by_name[initial(limb_path.parent_organ)]
		if(!istype(potential_parent))
			to_chat(src, "<span class='danger'>You've lost the organ that you've been growing your new part on!</span>")
			return // No rayman for you
		// Grah this line will leave a "not used" warning, in spite of the fact that the new() proc WILL do the thing.
		// Bothersome.
		var/obj/item/organ/external/new_limb = new limb_path(src)
		new_limb.open = 0 // This is just so that the compiler won't think that new_limb is unused, because the compiler is horribly stupid.
		adjustBruteLoss(stored_brute)
		adjustFireLoss(stored_burn)
		update_body()
		updatehealth()
		UpdateDamageIcon()
		nutrition -= SLIMEPERSON_HUNGERCOST
		visible_message("<span class='notice'>[src] finishes regrowing [p_their()] missing [new_limb]!</span>", "<span class='notice'>You finish regrowing your [limb_select]</span>")
	else
		to_chat(src, "<span class='warning'>You need to hold still in order to regrow a limb!</span>")
	return

#undef SLIMEPERSON_HUNGERCOST
#undef SLIMEPERSON_MINHUNGER
#undef SLIMEPERSON_REGROWTHDELAY

/datum/species/slime/handle_pre_change(mob/living/carbon/human/H)
	..()
	if(reagent_skin_coloring)
		H.toggle_recolor(silent = 1)
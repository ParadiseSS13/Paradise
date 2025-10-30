/datum/species
	/// Species name
	var/name
	/// Pluralized name (since "[name]s" is not always valid)
	var/name_plural
	var/sprite_sheet_name
	/// Article to use when referring to an individual of the species, if pronunciation is different from expected.
	/// Because it's unathi's turn to be special snowflakes.
	var/article_override
	var/icobase = 'icons/mob/human_races/r_human.dmi'    // Normal icon set.

	/// Minimum age this species can have
	var/min_age = AGE_MIN
	/// Maximum age this species can have
	var/max_age = 85

	// Damage overlay and masks.
	var/damage_overlays = 'icons/mob/human_races/masks/dam_human.dmi'
	var/damage_mask = 'icons/mob/human_races/masks/dam_mask_human.dmi'
	var/blood_mask = 'icons/mob/human_races/masks/blood_human.dmi'

	var/eyes = "eyes_s"                                  // Icon for eyes.
	var/blurb = "A completely nondescript species."      // A brief lore summary for use in the chargen screen.
	var/butt_sprite = "human"

	var/datum/species/primitive_form = null          // Lesser form, if any (ie. monkey for humans)
	var/datum/species/greater_form = null             // Greater form, if any, ie. human for monkeys.
	/// Name of tail image in species effects icon file.
	var/tail
	/// like tail but wings
	var/wing
	var/datum/unarmed_attack/unarmed                  //For empty hand harm-intent attack
	var/unarmed_type = /datum/unarmed_attack

	var/cold_level_1 = 260  // Cold damage level 1 below this point.
	var/cold_level_2 = 200  // Cold damage level 2 below this point.
	var/cold_level_3 = 120  // Cold damage level 3 below this point.
	var/coldmod = 1 // Damage multiplier for being in a cold environment

	var/heat_level_1 = 360  // Heat damage level 1 above this point.
	var/heat_level_2 = 400  // Heat damage level 2 above this point.
	var/heat_level_3 = 460 // Heat damage level 3 above this point; used for body temperature
	var/heatmod = 1 // Damage multiplier for being in a hot environment

	var/body_temperature = 310.15	//non-IS_SYNTHETIC species will try to stabilize at this temperature. (also affects temperature processing)
	var/reagent_tag                 //Used for metabolizing reagents.
	var/hunger_drain = HUNGER_FACTOR
	var/taste_sensitivity = TASTE_SENSITIVITY_NORMAL //the most widely used factor; humans use a different one
	var/hunger_icon = 'icons/mob/screen_hunger.dmi'

	var/siemens_coeff = 1 //base electrocution coefficient

	var/hazard_high_pressure = HAZARD_HIGH_PRESSURE   // Dangerously high pressure.
	var/warning_high_pressure = WARNING_HIGH_PRESSURE // High pressure warning.
	var/warning_low_pressure = WARNING_LOW_PRESSURE   // Low pressure warning.
	var/hazard_low_pressure = HAZARD_LOW_PRESSURE     // Dangerously low pressure.

	var/brute_mod = 1    // Physical damage reduction/amplification
	var/burn_mod = 1     // Burn damage reduction/amplification
	var/tox_mod = 1      // Toxin damage reduction/amplification
	var/oxy_mod = 1		 // Oxy damage reduction/amplification
	var/clone_mod = 1	 // Clone damage reduction/amplification
	var/brain_mod = 1    // Brain damage damage reduction/amplification
	var/stamina_mod = 1
	var/stun_mod = 1	 // If a species is more/less impacated by stuns/weakens/paralysis
	var/speed_mod = 0	// this affects the race's speed. positive numbers make it move slower, negative numbers make it move faster
	///Additional armour value for the species.
	var/armor = 0
	var/blood_damage_type = OXY //What type of damage does this species take if it's low on blood?
	var/total_health = 100
	var/punchdamagelow = 0       //lowest possible punch damage
	var/punchdamagehigh = 9      //highest possible punch damage
	var/punchstunthreshold = 9	 //damage at which punches from this race will stun //yes it should be to the attacked race but it's not useful that way even if it's logical

	var/ventcrawler = VENTCRAWLER_NONE //Determines if the mob can go through the vents.
	var/has_fine_manipulation = 1 // Can use small items.

	///Sounds to override barefeet walking
	var/list/special_step_sounds

	var/list/allowed_consumed_mobs = list() //If a species can consume mobs, put the type of mobs it can consume here.

	var/list/species_traits = list()
	///Generic traits tied to having the species.
	var/list/inherent_traits = list()

	var/breathid = "o2"

	var/clothing_flags = 0 // Underwear and socks.
	var/exotic_blood
	var/own_species_blood = FALSE // Can it only use blood from it's species?
	/// Type of skin produced when butchered.
	var/skinned_type
	/// Type of meat produced in the gibber/meating. Distinct from `butcher_results`.
	var/meat_type = /obj/item/food/meat
	var/no_equip	// bitflags of slots the race can't equip stuff to
	var/nojumpsuit = 0	// this is sorta... weird. it basically lets you equip stuff that usually needs jumpsuits without one, like belts and pockets and ids
	var/can_craft = TRUE // Can this mob using crafting or not?

	var/bodyflags = 0
	var/dietflags  = 0	// Make sure you set this, otherwise it won't be able to digest a lot of foods

	var/blood_color = COLOR_BLOOD_BASE //Red.
	var/flesh_color = "#d1aa2e" //Gold.
	var/single_gib_type = /obj/effect/decal/cleanable/blood/gibs
	var/remains_type = /obj/effect/decal/remains/human //What sort of remains is left behind when the species dusts
	var/base_color      //Used when setting species.
	/// bitfield of biotypes the mob belongs to.
	var/inherent_biotypes = MOB_ORGANIC | MOB_HUMANOID
	var/list/inherent_factions

	//Used in icon caching.
	var/race_key = 0
	var/icon/icon_template

	var/is_small
	var/show_ssd = 1
	var/forced_heartattack = FALSE //Some species have blood, but we still want them to have heart attacks
	var/dies_at_threshold = FALSE // Do they die or get knocked out at specific thresholds, or do they go through complex crit?
	var/can_revive_by_healing				// Determines whether or not this species can be revived by simply healing them
	var/blacklisted = FALSE
	var/dangerous_existence = FALSE

	//Death vars.
	var/death_message = "seizes up and falls limp, their eyes dead and lifeless..."
	var/list/suicide_messages = list(
		"is attempting to bite their tongue off!",
		"is jamming their thumbs into their eye sockets!",
		"is twisting their own neck!",
		"is holding their breath!")

	// Language/culture vars.
	var/default_language = "Galactic Common" // Default language is used when 'say' is used without modifiers.
	var/language = "Galactic Common"         // Default racial language, if any.
	var/secondary_langs = list()             // The names of secondary languages that are available to this species.
	var/list/speech_sounds                   // A list of sounds to potentially play when speaking.
	var/list/speech_chance                   // The likelihood of a speech sound playing.
	var/scream_verb = "screams"
	var/male_scream_sound = 'sound/goonstation/voice/male_scream.ogg'
	var/female_scream_sound = 'sound/goonstation/voice/female_scream.ogg'
	var/list/death_sounds = list('sound/goonstation/voice/deathgasp_1.ogg', 'sound/goonstation/voice/deathgasp_2.ogg')
	var/list/male_dying_gasp_sounds = list('sound/goonstation/voice/male_dying_gasp_1.ogg', 'sound/goonstation/voice/male_dying_gasp_2.ogg', 'sound/goonstation/voice/male_dying_gasp_3.ogg', 'sound/goonstation/voice/male_dying_gasp_4.ogg', 'sound/goonstation/voice/male_dying_gasp_5.ogg')
	var/list/female_dying_gasp_sounds = list('sound/goonstation/voice/female_dying_gasp_1.ogg', 'sound/goonstation/voice/female_dying_gasp_2.ogg', 'sound/goonstation/voice/female_dying_gasp_3.ogg', 'sound/goonstation/voice/female_dying_gasp_4.ogg', 'sound/goonstation/voice/female_dying_gasp_5.ogg')
	var/gasp_sound = 'sound/goonstation/voice/gasp.ogg'
	var/male_cough_sounds = list('sound/effects/mob_effects/m_cougha.ogg','sound/effects/mob_effects/m_coughb.ogg', 'sound/effects/mob_effects/m_coughc.ogg')
	var/female_cough_sounds = list('sound/effects/mob_effects/f_cougha.ogg','sound/effects/mob_effects/f_coughb.ogg')
	var/male_sneeze_sound = 'sound/effects/mob_effects/sneeze.ogg'
	var/female_sneeze_sound = 'sound/effects/mob_effects/f_sneeze.ogg'

	//Default hair/headacc style vars.
	var/default_hair				//Default hair style for newly created humans unless otherwise set.
	var/default_hair_colour
	var/default_fhair				//Default facial hair style for newly created humans unless otherwise set.
	var/default_fhair_colour
	var/default_headacc				//Default head accessory style for newly created humans unless otherwise set.
	var/default_headacc_colour

	/// Name of default body accessory if any.
	var/default_bodyacc

	//Defining lists of icon skin tones for species that have them.
	var/list/icon_skin_tones = list()

	/// Determines the organs that the species spawns with and which required-organ checks are conducted.
	var/list/has_organ = list(
		"heart"		= /obj/item/organ/internal/heart,
		"lungs"		= /obj/item/organ/internal/lungs,
		"liver"		= /obj/item/organ/internal/liver,
		"kidneys"	= /obj/item/organ/internal/kidneys,
		"brain"		= /obj/item/organ/internal/brain,
		"appendix"	= /obj/item/organ/internal/appendix,
		"eyes"		= /obj/item/organ/internal/eyes
	)
	var/vision_organ = /obj/item/organ/internal/eyes // If set, this organ is required for vision.
	var/list/has_limbs = list(
		"chest" =  list("path" = /obj/item/organ/external/chest, "descriptor" = "chest"),
		"groin" =  list("path" = /obj/item/organ/external/groin, "descriptor" = "groin"),
		"head" =   list("path" = /obj/item/organ/external/head, "descriptor" = "head"),
		"l_arm" =  list("path" = /obj/item/organ/external/arm, "descriptor" = "left arm"),
		"r_arm" =  list("path" = /obj/item/organ/external/arm/right, "descriptor" = "right arm"),
		"l_leg" =  list("path" = /obj/item/organ/external/leg, "descriptor" = "left leg"),
		"r_leg" =  list("path" = /obj/item/organ/external/leg/right, "descriptor" = "right leg"),
		"l_hand" = list("path" = /obj/item/organ/external/hand, "descriptor" = "left hand"),
		"r_hand" = list("path" = /obj/item/organ/external/hand/right, "descriptor" = "right hand"),
		"l_foot" = list("path" = /obj/item/organ/external/foot, "descriptor" = "left foot"),
		"r_foot" = list("path" = /obj/item/organ/external/foot/right, "descriptor" = "right foot"))

	// Mutant pieces
	var/obj/item/organ/internal/ears/mutantears = /obj/item/organ/internal/ears

	// Species specific boxes
	var/speciesbox

	/// Whether the presence of a body accessory on this species is optional or not.
	var/optional_body_accessory = TRUE

	var/list/autohiss_basic_map = null
	var/list/autohiss_extra_map = null
	var/list/autohiss_exempt = null

	/// What plushie the species will turn into if turned into a plushie.
	var/plushie_type = /obj/item/toy/plushie/humanplushie

/datum/species/New()
	unarmed = new unarmed_type()
	if(!sprite_sheet_name)
		sprite_sheet_name = name

/datum/species/proc/get_random_name(gender)
	var/datum/language/species_language = GLOB.all_languages[language]
	return species_language.get_random_name(gender)


/**
 * Handles creation of mob organs.
 *
 * Arguments:
 * * H: The human to create organs inside of
 * * bodyparts_to_omit: Any bodyparts in this list (and organs within them) should not be added.
 * * transfer_contents: Whether or not to transfer the contents of the old organs to the new ones
 */
/datum/species/proc/create_organs(mob/living/carbon/human/H, list/bodyparts_to_omit, transfer_contents = TRUE) //Handles creation of mob organs.
	var/list/transfer_list = list()
	for(var/limb_name in has_limbs)
		var/obj/item/organ/external/body_part = H.bodyparts_by_name[limb_name]
		if(!body_part)
			continue
		// Always expel all cyber implants
		for(var/obj/item/organ/internal/cyberimp/internal_organ in body_part.internal_organs)
			internal_organ.remove(H)
			internal_organ.forceMove(get_turf(H))

		// If we don't transfer the content or make a new organ in place of the old one, drop the contents on the ground
		if(!transfer_contents || (bodyparts_to_omit && (limb_name in bodyparts_to_omit)))
			// Drop cavity implant
			if(body_part.hidden)
				body_part.hidden.forceMove(get_turf(H))
				body_part.hidden = null // null ref so it doesn't get deleted with the bodypart
			// Drop general contents of bodypart
			for(var/atom/movable/thing in body_part.contents)
				thing.forceMove(get_turf(H))
			body_part.contents = list() // empty ref list so the contents don't get deleted with the bodypart

		else
			// Transfer cavity implant
			transfer_list += list("[limb_name]" = list("hidden" = null, "contents" = list()))
			if(body_part.hidden)
				transfer_list[limb_name]["hidden"] = body_part.hidden
				body_part.hidden = null // null ref so it doesn't get deleted with the bodypart
			// Transfer contents
			if(length(body_part.contents))
				transfer_list[limb_name]["contents"] = body_part.contents
				body_part.contents = list() // empty ref list so the contents don't get deleted with the bodypart

	QDEL_LIST_CONTENTS(H.internal_organs)
	QDEL_LIST_CONTENTS(H.bodyparts)

	LAZYREINITLIST(H.bodyparts)
	LAZYREINITLIST(H.bodyparts_by_name)
	LAZYREINITLIST(H.internal_organs)

	for(var/limb_name in has_limbs)
		if(bodyparts_to_omit && (limb_name in bodyparts_to_omit))
			H.bodyparts_by_name[limb_name] = null  // Null it out, but leave the name here so it's still "there"
			continue
		var/list/organ_data = has_limbs[limb_name]
		var/limb_path = organ_data["path"]
		var/obj/item/organ/O = new limb_path(H)
		organ_data["descriptor"] = O.name
		// Transfer things from the old organ to the new
		if(istype(O, /obj/item/organ/external) && transfer_list[limb_name])
			var/obj/item/organ/external/external_organ = O
			external_organ.hidden = transfer_list[limb_name]["hidden"]
			external_organ.contents = transfer_list[limb_name]["contents"]

			transfer_list -= transfer_list[limb_name]

	// Anything we still didn't transfer for whatever reason we drop on the ground
	for(var/list/remaining in transfer_list)
		if(remaining["hidden"])
			var/atom/movable/thing = remaining["hidden"]
			thing.forceMove(get_turf(H))
		if(length(remaining["contents"]))
			for(var/atom/movable/thing in remaining["contents"])
				thing.forceMove(get_turf(H))


	for(var/index in has_organ)
		var/obj/item/organ/internal/organ_path = has_organ[index]
		if(initial(organ_path.parent_organ) in bodyparts_to_omit)
			continue

		// heads up for any brave future coders:
		// it's essential that a species' internal organs are intialized with the mob, instead of just creating them and calling insert() separately.
		// not doing so (as of now) causes weird issues for some organs like posibrains, which need a mob on init or they'll qdel themselves.
		// for the record: this caused every single IPC's brain to be deleted randomly throughout a round, killing them instantly.

		new organ_path(H)

	create_mutant_organs(H)

	for(var/name in H.bodyparts_by_name)
		var/part_type = H.bodyparts_by_name[name]
		if(!isnull(part_type))
			H.bodyparts |= part_type  // we do not want nulls here, even though it's alright to have them in bodyparts_by_name

	for(var/obj/item/organ/external/E as anything in H.bodyparts)
		E.owner = H
		E.add_limb_flags()

/datum/species/proc/create_mutant_organs(mob/living/carbon/human/H)
	var/obj/item/organ/internal/ears/ears = H.get_int_organ(/obj/item/organ/internal/ears)
	if(ears)
		if(istype(ears, mutantears))
			// if they're the same, just heal them and don't bother replacing them
			ears.rejuvenate()
			return
		qdel(ears)

	if(mutantears && !isnull(H.bodyparts_by_name[initial(mutantears.parent_organ)]))
		new mutantears(H)

/datum/species/proc/breathe(mob/living/carbon/human/H)
	var/datum/organ/lungs/lung = H.get_int_organ_datum(ORGAN_DATUM_LUNGS)
	if(HAS_TRAIT(H, TRAIT_NOBREATH))
		lung?.clear_alerts(H)
		return TRUE

////////////////
// MOVE SPEED //
////////////////
#define ADD_SLOWDOWN(__value) if(!ignoreslow || __value < 0) . += __value
#define SLOWDOWN_INCREMENT 0.5
#define SLOWDOWN_MULTIPLIER (1 / SLOWDOWN_INCREMENT)

/datum/species/proc/movement_delay(mob/living/carbon/human/H)
	. = 0	//We start at 0.

	if(!has_gravity(H))
		return
	if(!IS_HORIZONTAL(H) || (HAS_TRAIT(H, TRAIT_NOKNOCKDOWNSLOWDOWN) && !H.resting)) //You are slowed if crawling without noknockdownslowdown. However, if you are self crawling, you don't ignore it, so no self crawling to not drop items
		if(HAS_TRAIT(H, TRAIT_GOTTAGOFAST))
			. -= 1
		else if(HAS_TRAIT(H, TRAIT_GOTTAGONOTSOFAST))
			. -= 0.5
	else
		. += GLOB.configuration.movement.crawling_speed_reduction

	var/ignoreslow = FALSE
	if(HAS_TRAIT(H, TRAIT_IGNORESLOWDOWN))
		ignoreslow = TRUE

	var/flight = HAS_TRAIT(H, TRAIT_FLYING)	//Check for flight and flying items

	ADD_SLOWDOWN(speed_mod)

	var/turf/simulated/floor/T = get_turf(H)
	if(istype(T) && !HAS_TRAIT(T, TRAIT_BLUESPACE_SPEED))
		if(H.wear_suit)
			ADD_SLOWDOWN(H.wear_suit.slowdown)
		if(H.head)
			ADD_SLOWDOWN(H.head.slowdown)
		if(H.gloves)
			ADD_SLOWDOWN(H.gloves.slowdown)
		if(!H.buckled && H.shoes)
			ADD_SLOWDOWN(H.shoes.slowdown)
		if(H.back)
			ADD_SLOWDOWN(H.back.slowdown)
		if(H.l_hand && (H.l_hand.flags & HANDSLOW))
			ADD_SLOWDOWN(H.l_hand.slowdown)
		if(H.r_hand && (H.r_hand.flags & HANDSLOW))
			ADD_SLOWDOWN(H.r_hand.slowdown)

	if(ignoreslow)
		return // Only malusses after here

	if(!IS_HORIZONTAL(H) || (HAS_TRAIT(H, TRAIT_NOKNOCKDOWNSLOWDOWN) && !H.resting))
		if(HAS_TRAIT(H, TRAIT_GOTTAGOSLOW))
			. += 1

	if(H.dna.species.spec_movement_delay()) //Species overrides for slowdown due to feet/legs
		. += 2 * H.stance_damage //damaged/missing feet or legs is slow

	var/hungry = (500 - H.nutrition) / 5 // So overeat would be 100 and default level would be 80
	if((hungry >= 70) && !flight)
		. += hungry/50
	if(HAS_TRAIT(H, TRAIT_FAT))
		. += (1.5 - flight)

	if(H.bodytemperature < H.dna.species.cold_level_1 && !HAS_TRAIT(H, TRAIT_RESISTCOLD))
		. += (H.dna.species.cold_level_1 - H.bodytemperature) / COLD_SLOWDOWN_FACTOR

	var/leftover = .
	. = round_down(. * SLOWDOWN_MULTIPLIER) / SLOWDOWN_MULTIPLIER //This allows us to round in values of 0.5 A slowdown of 0.55 becomes 1.10, which is rounded to 1, then reduced to 0.5
	leftover -= .

	var/health_deficiency = max(H.maxHealth - H.health, H.getStaminaLoss())
	health_deficiency -= H.shock_reduction(FALSE)

	if(HAS_TRAIT(H, TRAIT_IGNOREDAMAGESLOWDOWN))
		return
	if(health_deficiency >= 40 - (40 * leftover * SLOWDOWN_MULTIPLIER)) //If we have 0.25 slowdown, or halfway to the threshold of 0.5, we reduce the health threshold by that 50%
		if(flight)
			. += (health_deficiency / 75)
		else
			if(health_deficiency >= 40)
				. += ((health_deficiency / 25) - 1.1) //Once damage is over 40, you get the harsh formula
			else
				. += 0.5 //Otherwise, slowdown (from pain) is capped to 0.5 until you hit 40 damage. This only effects people with fractional slowdowns, and prevents some harshness from the lowered threshold

#undef ADD_SLOWDOWN
#undef SLOWDOWN_INCREMENT
#undef SLOWDOWN_MULTIPLIER

/datum/species/proc/on_species_gain(mob/living/carbon/human/H) //Handles anything not already covered by basic species assignment.
	for(var/slot_id in GLOB.bitflags) // Iterate through all bitflags
		if(slot_id > ITEM_SLOT_AMOUNT_FLAG) // If the slot_id bitflag is larger than the largest ITEM_SLOT flag we're done
			break
		if(!(slot_id & no_equip)) // If the slot_id bitflag isn't in the no_equip flag, check the next bitflag
			continue
		var/obj/item/thing = H.get_item_by_slot(slot_id)
		if(thing && (!thing.species_exception || !is_type_in_list(src, thing.species_exception)))
			H.drop_item_to_ground(thing)
	if(H.hud_used)
		H.hud_used.update_locked_slots()
	H.ventcrawler = ventcrawler

	H.mob_biotypes = inherent_biotypes

	for(var/X in inherent_traits)
		ADD_TRAIT(H, X, SPECIES_TRAIT)

	if(TRAIT_VIRUSIMMUNE in inherent_traits)
		for(var/datum/disease/A in H.viruses)
			if(!A.bypasses_immunity)
				A.cure(FALSE)

	if(inherent_factions)
		for(var/i in inherent_factions)
			H.faction += i //Using +=/-= for this in case you also gain the faction from a different source.

/datum/species/proc/on_species_loss(mob/living/carbon/human/H)
	for(var/X in inherent_traits)
		REMOVE_TRAIT(H, X, SPECIES_TRAIT)

	if(H.butcher_results) //clear it out so we don't butcher a actual human.
		H.butcher_results = null
	H.ventcrawler = initial(H.ventcrawler)

	if(inherent_factions)
		for(var/i in inherent_factions)
			H.faction -= i

/datum/species/proc/updatespeciescolor(mob/living/carbon/human/H) //Handles changing icobase for species that have multiple skin colors.
	return

// Do species-specific reagent handling here
// Return 1 if it should do normal processing too
// Return the parent value if processing does not explicitly stop
// Return 0 if it shouldn't deplete and do its normal effect
// Other return values will cause weird badness
/datum/species/proc/handle_reagents(mob/living/carbon/human/H, datum/reagent/R)
	return TRUE

// For special snowflake species effects
// (Slime People changing color based on the reagents they consume)
/datum/species/proc/handle_life(mob/living/carbon/human/H)
	SHOULD_CALL_PARENT(TRUE)
	if(HAS_TRAIT(H, TRAIT_NOBREATH))
		var/takes_crit_damage = (!HAS_TRAIT(H, TRAIT_NOCRITDAMAGE))
		if((H.health <= HEALTH_THRESHOLD_CRIT) && takes_crit_damage)
			H.adjustBruteLoss(1)
	return

/datum/species/proc/handle_dna(mob/living/carbon/human/H, remove) //Handles DNA mutations, as that doesn't work at init. Make sure you call genemutcheck on any blocks changed here
	return

/datum/species/proc/handle_death(gibbed, mob/living/carbon/human/H) //Handles any species-specific death events (such as dionaea nymph spawns).
	return

/datum/species/proc/apply_damage(damage = 0, damagetype = BRUTE, def_zone, blocked = 0, mob/living/carbon/human/H, sharp = FALSE, obj/used_weapon, spread_damage = FALSE)
	if(H.status_flags & GODMODE)
		return FALSE	//godmode
	SEND_SIGNAL(H, COMSIG_MOB_APPLY_DAMAGE, damage, damagetype, def_zone)
	if(!damage)
		return FALSE

	var/obj/item/organ/external/organ = null
	if(!spread_damage)
		if(is_external_organ(def_zone))
			organ = def_zone
		else
			if(!def_zone)
				def_zone = ran_zone(def_zone)
			organ = H.get_organ(check_zone(def_zone))
			if(!organ)
				organ = H.bodyparts[1]

	var/total_armour = blocked + armor

	switch(damagetype)
		if(BRUTE)
			var/damage_amount = ARMOUR_EQUATION(damage, total_armour, brute_mod * H.physiology.brute_mod)
			if(damage_amount)
				H.damageoverlaytemp = 20

			if(organ)
				if(organ.receive_damage(damage_amount, 0, sharp, used_weapon))
					H.UpdateDamageIcon()
			else //no bodypart, we deal damage with a more general method.
				H.adjustBruteLoss(damage_amount)
		if(BURN)
			var/damage_amount = ARMOUR_EQUATION(damage, total_armour, burn_mod * H.physiology.burn_mod)
			if(damage_amount)
				H.damageoverlaytemp = 20

			if(organ)
				if(organ.receive_damage(0, damage_amount, sharp, used_weapon))
					H.UpdateDamageIcon()
			else
				H.adjustFireLoss(damage_amount)
		if(TOX)
			var/damage_amount = ARMOUR_EQUATION(damage, total_armour, H.physiology.tox_mod)
			H.adjustToxLoss(damage_amount)
		if(OXY)
			var/damage_amount = ARMOUR_EQUATION(damage, total_armour, H.physiology.oxy_mod)
			H.adjustOxyLoss(damage_amount)
		if(CLONE)
			var/damage_amount = ARMOUR_EQUATION(damage, total_armour, H.physiology.clone_mod)
			H.adjustCloneLoss(damage_amount)
		if(STAMINA)
			var/damage_amount = ARMOUR_EQUATION(damage, total_armour, H.physiology.stamina_mod)
			H.adjustStaminaLoss(damage_amount)
		if(BRAIN)
			var/damage_amount = ARMOUR_EQUATION(damage, total_armour, H.physiology.brain_mod)
			H.adjustBrainLoss(damage_amount)

	// Will set our damageoverlay icon to the next level, which will then be set back to the normal level the next mob.Life().
	H.updatehealth("apply damage")
	return TRUE

/datum/species/proc/spec_stun(mob/living/carbon/human/H, amount)
	. = amount
	if(!H.frozen) //admin freeze has no breaks
		. = stun_mod * H.physiology.stun_mod * amount

/datum/species/proc/spec_electrocute_act(mob/living/carbon/human/H, shock_damage, source, siemens_coeff = 1, flags = NONE)
	return

/datum/species/proc/help(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(attacker_style && attacker_style.help_act(user, target) == MARTIAL_ARTS_ACT_SUCCESS)//adminfu only...
		return TRUE
	if(target.on_fire)
		user.pat_out(target)
	else if(target.health >= HEALTH_THRESHOLD_CRIT && !HAS_TRAIT(target, TRAIT_FAKEDEATH) && target.stat != DEAD)
		target.help_shake_act(user)
		return TRUE
	else
		user.do_cpr(target)

/datum/species/proc/grab(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(!attacker_style && target.buckled)
		target.buckled.user_unbuckle_mob(target, user)
		return TRUE
	if(attacker_style && attacker_style.grab_act(user, target) == MARTIAL_ARTS_ACT_SUCCESS)
		return TRUE
	else
		target.grabbedby(user)
		return TRUE

/datum/species/proc/harm(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, "<span class='warning'>You don't want to harm [target]!</span>")
		return FALSE
	if(target != user && handle_harm_antag(user, target))
		return FALSE
	//Mind Flayer code
	var/datum/antagonist/mindflayer/MF = user?.mind?.has_antag_datum(/datum/antagonist/mindflayer)
	var/obj/item/organ/internal/brain/victims_brain = target.get_int_organ(/obj/item/organ/internal/brain) //In case someone's brain isn't in their head
	if(MF && !MF.harvesting && user.zone_selected == victims_brain.parent_organ && target != user)
		MF.handle_harvest(target)
		add_attack_logs(user, target, "flayerdrain")
		return
	//End Mind Flayer Code
	if(SEND_SIGNAL(target, COMSIG_HUMAN_ATTACKED, user) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return FALSE
	if(attacker_style && attacker_style.harm_act(user, target) == MARTIAL_ARTS_ACT_SUCCESS)
		return TRUE

	var/datum/unarmed_attack/attack = user.get_unarmed_attack()

	user.do_attack_animation(target, attack.animation_type)
	if(attack.harmless)
		playsound(target.loc, attack.attack_sound, 25, TRUE, -1)
		target.visible_message("<span class='danger'>[user] [pick(attack.attack_verb)]ed [target]!</span>")
		return FALSE
	add_attack_logs(user, target, "Melee attacked with fists", target.ckey ? null : ATKLOG_ALL)

	target.store_last_attacker(user)

	var/damage = rand(user.dna.species.punchdamagelow, user.dna.species.punchdamagehigh)
	damage += attack.damage
	damage += user.physiology.melee_bonus
	if(!damage)
		playsound(target.loc, attack.miss_sound, 25, TRUE, -1)
		target.visible_message("<span class='danger'>[user] tried to [pick(attack.attack_verb)] [target]!</span>")
		return FALSE


	var/obj/item/organ/external/affecting = target.get_organ(ran_zone(user.zone_selected))
	var/armor_block = target.run_armor_check(affecting, MELEE)

	playsound(target.loc, attack.attack_sound, 25, TRUE, -1)

	target.visible_message("<span class='danger'>[user] [pick(attack.attack_verb)]ed [target]!</span>")
	target.apply_damage(damage, BRUTE, affecting, armor_block, sharp = attack.sharp)
	if((target.stat != DEAD) && damage >= user.dna.species.punchstunthreshold)
		target.visible_message("<span class='danger'>[user] has knocked down [target]!</span>", \
						"<span class='userdanger'>[user] has knocked down [target]!</span>")
		target.KnockDown(4 SECONDS)
	SEND_SIGNAL(target, COMSIG_ATTACK_BY)

/datum/species/proc/disarm(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(user == target)
		return FALSE
	if(SEND_SIGNAL(target, COMSIG_HUMAN_ATTACKED, user) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return FALSE
	if(target.absorb_stun(0))
		target.visible_message("<span class='warning'>[target] is not affected by [user]'s disarm attempt!</span>")
		user.do_attack_animation(target, ATTACK_EFFECT_DISARM)
		playsound(target.loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)
		return FALSE
	if(attacker_style && attacker_style.disarm_act(user, target) == MARTIAL_ARTS_ACT_SUCCESS)
		return TRUE
	user.do_attack_animation(target, ATTACK_EFFECT_DISARM)
	if(target.move_resist > user.pull_force)
		return FALSE
	if(!(target.status_flags & CANPUSH))
		return FALSE
	if(target.anchored)
		return FALSE
	if(target.buckled)
		target.unbuckle()

	var/shove_dir = get_dir(user.loc, target.loc)
	var/turf/shove_to = get_step(target.loc, shove_dir)
	playsound(shove_to, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)

	if(shove_to == user.loc)
		return FALSE

	//Directional checks to make sure that we're not shoving through a windoor or something like that
	var/directional_blocked = FALSE
	var/target_turf = get_turf(target)
	if(shove_dir in list(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)) // if we are moving diagonially, we need to check if there are dense walls either side of us
		var/turf/T = get_step(target.loc, turn(shove_dir, 45)) // check to the left for a dense turf
		if(T.density)
			directional_blocked = TRUE
		else
			T = get_step(target.loc, turn(shove_dir, -45)) // check to the right for a dense turf
			if(T.density)
				directional_blocked = TRUE

	if(!directional_blocked)
		for(var/obj/obj_content in target_turf) // check the tile we are on for border
			if(obj_content.flags & ON_BORDER && obj_content.dir & shove_dir && obj_content.density)
				directional_blocked = TRUE
				break
	if(!directional_blocked)
		for(var/obj/obj_content in shove_to) // check tile we are moving to for borders
			if(obj_content.flags & ON_BORDER && obj_content.dir & turn(shove_dir, 180) && obj_content.density)
				directional_blocked = TRUE
				break

	if(!directional_blocked)
		for(var/atom/movable/AM in shove_to)
			if(AM.shove_impact(target, user)) // check for special interactions EG. tabling someone
				return TRUE

	var/moved = target.Move(shove_to, shove_dir)
	if(!moved) //they got pushed into a dense object
		add_attack_logs(user, target, "Disarmed into a dense object", ATKLOG_ALL)
		target.visible_message("<span class='warning'>[user] slams [target] into an obstacle!</span>", \
								"<span class='userdanger'>You get slammed into the obstacle by [user]!</span>", \
								"You hear a loud thud.")
		if(!HAS_TRAIT(target, TRAIT_FLOORED))
			target.KnockDown(3 SECONDS)
			addtimer(CALLBACK(target, TYPE_PROC_REF(/mob/living, SetKnockDown), 0), 3 SECONDS) // so you cannot chain stun someone
		else if(!user.IsStunned())
			target.Stun(0.5 SECONDS)
	else
		var/obj/item/active_hand = target.get_active_hand()
		if(target.IsSlowed() && active_hand && !IS_HORIZONTAL(user) && !HAS_TRAIT(active_hand, TRAIT_WIELDED) && !istype(active_hand, /obj/item/grab))
			target.drop_item()
			add_attack_logs(user, target, "Disarmed object out of hand", ATKLOG_ALL)
		else
			target.Slowed(2.5 SECONDS, 0.5)
			var/obj/item/I = target.get_active_hand()
			if(I)
				to_chat(target, "<span class='warning'>Your grip on [I] loosens!</span>")
			add_attack_logs(user, target, "Disarmed, shoved back", ATKLOG_ALL)
	target.stop_pulling()

/datum/species/proc/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style) //Handles any species-specific attackhand events.
	if(!istype(M))
		return

	if(istype(M))
		var/obj/item/organ/external/temp = M.bodyparts_by_name["r_hand"]
		if(M.hand)
			temp = M.bodyparts_by_name["l_hand"]
		if(!temp || !temp.is_usable())
			to_chat(M, "<span class='warning'>You can't use your hand.</span>")
			return

	if(M.mind)
		attacker_style = M.mind.martial_art

	if((M != H) && M.a_intent != INTENT_HELP && H.check_shields(M, 0, M.name, attack_type = UNARMED_ATTACK))
		add_attack_logs(M, H, "Melee attacked with fists (miss/block)")
		H.visible_message("<span class='warning'>[M] attempted to touch [H]!</span>")
		return FALSE

	switch(M.a_intent)
		if(INTENT_HELP)
			help(M, H, attacker_style)

		if(INTENT_GRAB)
			grab(M, H, attacker_style)

		if(INTENT_HARM)
			harm(M, H, attacker_style)

		if(INTENT_DISARM)
			disarm(M, H, attacker_style)

/datum/species/proc/before_equip_job(datum/job/J, mob/living/carbon/human/H, visualsOnly = FALSE)
	return

/datum/species/proc/after_equip_job(datum/job/J, mob/living/carbon/human/H, visualsOnly = FALSE)
	return

/datum/species/proc/can_understand(mob/other)
	return

// Called in life() when the mob has no client.
/datum/species/proc/handle_npc(mob/living/carbon/human/H)
	return

//Species unarmed attacks

/datum/unarmed_attack
	var/attack_verb = list("punch")	// Empty hand hurt intent verb.
	var/damage = 0						// How much flat bonus damage an attack will do. This is a *bonus* guaranteed damage amount on top of the random damage attacks do.
	var/attack_sound = "punch"
	var/miss_sound = 'sound/weapons/punchmiss.ogg'
	var/sharp = FALSE
	var/animation_type = ATTACK_EFFECT_PUNCH
	var/harmless = FALSE //if set to true, attacks won't be admin logged and punches will "hit" for no damage

/datum/unarmed_attack/diona
	attack_verb = list("lash", "bludgeon")

/datum/unarmed_attack/claws
	attack_verb = list("scratch", "claw")
	attack_sound = 'sound/weapons/slice.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	sharp = TRUE
	animation_type = ATTACK_EFFECT_CLAW
	var/has_been_sharpened = FALSE

/datum/unarmed_attack/bite
	attack_verb = list("chomp")
	attack_sound = 'sound/weapons/bite.ogg'
	sharp = TRUE
	animation_type = ATTACK_EFFECT_BITE
/*
* Returns a copy of the datum that called this. I know this is pretty dumb
*/
/datum/unarmed_attack/proc/copy_attack()
	var/datum/unarmed_attack/copy = new /datum/unarmed_attack
	copy.attack_verb = attack_verb
	copy.damage = damage
	copy.attack_sound = attack_sound
	copy.miss_sound = miss_sound
	copy.sharp = sharp
	copy.animation_type = animation_type
	return copy

/datum/unarmed_attack/claws/copy_attack()
	var/datum/unarmed_attack/claws/copy = ..()
	copy.has_been_sharpened = has_been_sharpened
	return copy

/datum/species/proc/can_equip(obj/item/I, slot, disable_warning = FALSE, mob/living/carbon/human/H)
	if(slot & no_equip)
		if(!I.species_exception || !is_type_in_list(src, I.species_exception))
			return FALSE

	if(!H.has_organ_for_slot(slot))
		return FALSE

	switch(slot)
		if(ITEM_SLOT_LEFT_HAND)
			return !H.l_hand && !H.incapacitated()
		if(ITEM_SLOT_RIGHT_HAND)
			return !H.r_hand && !H.incapacitated()
		if(ITEM_SLOT_MASK)
			return !H.wear_mask && (I.slot_flags & ITEM_SLOT_MASK)
		if(ITEM_SLOT_BACK)
			return !H.back && (I.slot_flags & ITEM_SLOT_BACK)
		if(ITEM_SLOT_OUTER_SUIT)
			return !H.wear_suit && (I.slot_flags & ITEM_SLOT_OUTER_SUIT)
		if(ITEM_SLOT_GLOVES)
			return !H.gloves && (I.slot_flags & ITEM_SLOT_GLOVES)
		if(ITEM_SLOT_SHOES)
			return !H.shoes && (I.slot_flags & ITEM_SLOT_SHOES)
		if(ITEM_SLOT_NECK)
			return !H.neck && (I.slot_flags & ITEM_SLOT_NECK)
		if(ITEM_SLOT_BELT)
			if(H.belt)
				return FALSE
			var/obj/item/organ/external/O = H.get_organ(BODY_ZONE_CHEST)

			if(!H.w_uniform && !nojumpsuit && !(O?.status & ORGAN_ROBOT) && !(I.flags_2 & ALLOW_BELT_NO_JUMPSUIT_2))
				if(!disable_warning)
					to_chat(H, "<span class='alert'>You need a jumpsuit before you can attach this [I.name].</span>")
				return FALSE
			if(!(I.slot_flags & ITEM_SLOT_BELT))
				return
			return TRUE
		if(ITEM_SLOT_EYES)
			return !H.glasses && (I.slot_flags & ITEM_SLOT_EYES)
		if(ITEM_SLOT_HEAD)
			return !H.head && (I.slot_flags & ITEM_SLOT_HEAD)
		if(ITEM_SLOT_LEFT_EAR)
			return !H.l_ear && (I.slot_flags & ITEM_SLOT_LEFT_EAR)
		if(ITEM_SLOT_RIGHT_EAR)
			return !H.r_ear && (I.slot_flags & ITEM_SLOT_RIGHT_EAR)
		if(ITEM_SLOT_JUMPSUIT)
			return !H.w_uniform && (I.slot_flags & ITEM_SLOT_JUMPSUIT)
		if(ITEM_SLOT_ID)
			if(H.wear_id)
				return FALSE
			var/obj/item/organ/external/O = H.get_organ(BODY_ZONE_CHEST)

			if(!H.w_uniform && !nojumpsuit && !(O?.status & ORGAN_ROBOT))
				if(!disable_warning)
					to_chat(H, "<span class='alert'>You need a jumpsuit before you can attach this [I.name].</span>")
				return FALSE
			if(!(I.slot_flags & ITEM_SLOT_ID))
				return FALSE
			return TRUE
		if(ITEM_SLOT_PDA)
			if(H.wear_pda)
				return FALSE
			var/obj/item/organ/external/O = H.get_organ(BODY_ZONE_CHEST)

			if(!H.w_uniform && !nojumpsuit && !(O?.status & ORGAN_ROBOT))
				if(!disable_warning)
					to_chat(H, "<span class='alert'>You need a jumpsuit before you can attach this [I.name].</span>")
				return FALSE
			if(!(I.slot_flags & ITEM_SLOT_PDA))
				return FALSE
			return TRUE
		if(ITEM_SLOT_LEFT_POCKET)
			if(I.flags & NODROP) //Pockets aren't visible, so you can't move NODROP items into them.
				return FALSE
			if(H.l_store)
				return FALSE
			var/obj/item/organ/external/O = H.get_organ(BODY_ZONE_L_LEG)

			if(!H.w_uniform && !nojumpsuit && !(O?.status & ORGAN_ROBOT))
				if(!disable_warning)
					to_chat(H, "<span class='alert'>You need a jumpsuit before you can attach this [I.name].</span>")
				return FALSE
			if(I.w_class <= WEIGHT_CLASS_SMALL || (I.slot_flags & ITEM_SLOT_BOTH_POCKETS))
				return TRUE
		if(ITEM_SLOT_RIGHT_POCKET)
			if(I.flags & NODROP)
				return FALSE
			if(H.r_store)
				return FALSE
			var/obj/item/organ/external/O = H.get_organ(BODY_ZONE_R_LEG)

			if(!H.w_uniform && !nojumpsuit && !(O?.status & ORGAN_ROBOT))
				if(!disable_warning)
					to_chat(H, "<span class='alert'>You need a jumpsuit before you can attach this [I.name].</span>")
				return FALSE
			if(I.w_class <= WEIGHT_CLASS_SMALL || (I.slot_flags & ITEM_SLOT_BOTH_POCKETS))
				return TRUE
			return FALSE
		if(ITEM_SLOT_SUIT_STORE)
			if(I.flags & NODROP) //Suit storage NODROP items drop if you take a suit off, this is to prevent people exploiting this.
				return FALSE
			if(H.s_store)
				return FALSE
			if(!H.wear_suit)
				if(!disable_warning)
					to_chat(H, "<span class='alert'>You need a suit before you can attach this [I.name].</span>")
				return FALSE
			if(!H.wear_suit.allowed)
				if(!disable_warning)
					to_chat(H, "You somehow have a suit with no defined allowed items for suit storage, stop that.")
				return FALSE
			if(I.w_class > H.wear_suit.max_suit_w)
				if(!disable_warning)
					to_chat(H, "<span class='warning'>[I] is too big to attach.</span>")
				return FALSE
			if(istype(I, /obj/item/pda) || is_pen(I) || is_type_in_list(I, H.wear_suit.allowed))
				return TRUE
			return FALSE
		if(ITEM_SLOT_HANDCUFFED)
			return !H.handcuffed && istype(I, /obj/item/restraints/handcuffs)
		if(ITEM_SLOT_LEGCUFFED)
			return !H.legcuffed && istype(I, /obj/item/restraints/legcuffs)
		if(ITEM_SLOT_IN_BACKPACK)
			if(H.back && istype(H.back, /obj/item/storage/backpack))
				var/obj/item/storage/backpack/B = H.back
				if(length(B.contents) < B.storage_slots && I.w_class <= B.max_w_class)
					return TRUE
			if(H.back && ismodcontrol(H.back))
				var/obj/item/mod/control/C = H.back
				if(C.bag)
					var/obj/item/storage/backpack/B = C.bag
					if(length(B.contents) < B.storage_slots && I.w_class <= B.max_w_class)
						return TRUE
			return FALSE
		if(ITEM_SLOT_ACCESSORY)
			if(!istype(I, /obj/item/clothing/accessory))
				return FALSE
			var/obj/item/clothing/under/uniform = H.w_uniform
			if(!uniform)
				if(!disable_warning)
					to_chat(H, "<span class='warning'>You need a jumpsuit before you can attach this [I.name].</span>")
				return FALSE
			if(length(uniform.accessories) && !uniform.can_attach_accessory(I))
				if(!disable_warning)
					to_chat(H, "<span class='warning'>You already have an accessory of this type attached to your [uniform].</span>")
				return FALSE
			if(!(I.slot_flags & ITEM_SLOT_ACCESSORY))
				return FALSE
			return TRUE

	return FALSE //Unsupported slot

/datum/species/proc/handle_mutations_and_radiation(mob/living/carbon/human/H)
	if(HAS_TRAIT(H, TRAIT_RADIMMUNE))
		H.radiation = 0
		return TRUE

	. = FALSE
	var/radiation = H.radiation

	if(radiation > RAD_MOB_KNOCKDOWN && prob(RAD_MOB_KNOCKDOWN_PROB))
		if(!H.IsWeakened())
			H.emote("collapse")
		H.Weaken(RAD_MOB_KNOCKDOWN_AMOUNT)
		to_chat(H, "<span class='danger'>You feel weak.</span>")

	if(radiation > RAD_MOB_VOMIT && prob(RAD_MOB_VOMIT_PROB))
		H.vomit(10, TRUE)

	if(radiation > RAD_MOB_MUTATE)
		if(prob(1))
			to_chat(H, "<span class='danger'>You mutate!</span>")
			randmutb(H)
			H.emote("gasp")
			domutcheck(H)

	if(radiation > RAD_MOB_HAIRLOSS)
		var/obj/item/organ/external/head/head_organ = H.get_organ("head")
		if(!istype(head_organ) || (NO_HAIR in species_traits))
			return
		if(prob(15) && head_organ.h_style != "Bald")
			to_chat(H, "<span class='danger'>Your hair starts to fall out in clumps...</span>")
			addtimer(CALLBACK(src, PROC_REF(go_bald), H), 5 SECONDS)

/datum/species/proc/go_bald(mob/living/carbon/human/H)
	if(QDELETED(H))	//may be called from a timer
		return
	var/obj/item/organ/external/head/head_organ = H.get_organ("head")
	if(!head_organ)
		return
	head_organ.f_style = "Shaved"
	head_organ.h_style = "Bald"
	H.update_hair()
	H.update_fhair()

/*
Returns the path corresponding to the corresponding organ
It'll return null if the organ doesn't correspond, so include null checks when using this!
*/
//Fethas Todo:Do i need to redo this?
/datum/species/proc/return_organ(organ_slot)
	if(!(organ_slot in has_organ))
		return null
	return has_organ[organ_slot]

/datum/species/proc/update_sight(mob/living/carbon/human/H)
	H.sight = initial(H.sight)

	var/obj/item/organ/internal/eyes/eyes = H.get_int_organ(/obj/item/organ/internal/eyes)
	if(eyes)
		H.sight |= eyes.vision_flags
		H.see_in_dark = eyes.see_in_dark
		H.see_invisible = eyes.see_invisible
		if(!isnull(eyes.lighting_alpha))
			H.lighting_alpha = eyes.lighting_alpha
	else
		H.see_in_dark = initial(H.see_in_dark)
		H.see_invisible = initial(H.see_invisible)
		H.lighting_alpha = initial(H.lighting_alpha)

	if(H.client && H.client.eye != H)
		var/atom/A = H.client.eye
		if(A.update_remote_sight(H)) //returns 1 if we override all other sight updates.
			return

	var/datum/antagonist/vampire/V = H.mind?.has_antag_datum(/datum/antagonist/vampire)
	if(V)
		for(var/datum/vampire_passive/vision/buffs in V.powers)
			H.sight |= buffs.vision_flags
			H.see_in_dark += buffs.see_in_dark
			H.lighting_alpha = buffs.lighting_alpha

	// my glasses, I can't see without my glasses
	if(H.glasses)
		var/obj/item/clothing/glasses/G = H.glasses
		H.sight |= G.vision_flags
		H.see_in_dark = max(G.see_in_dark, H.see_in_dark)

		if(G.invis_override)
			H.see_invisible = G.invis_override
		else
			H.see_invisible = max(G.invis_view, H.see_invisible) //Max, whichever is better

		if(!isnull(G.lighting_alpha))
			H.lighting_alpha = min(G.lighting_alpha, H.lighting_alpha)

	// better living through hat trading
	if(H.head)
		if(istype(H.head, /obj/item/clothing/head))
			var/obj/item/clothing/head/hat = H.head
			H.sight |= hat.vision_flags
			H.see_in_dark = max(hat.see_in_dark, H.see_in_dark)

			if(!isnull(hat.lighting_alpha))
				H.lighting_alpha = min(hat.lighting_alpha, H.lighting_alpha)

	if(HAS_TRAIT(H, TRAIT_MESON_VISION))
		H.sight |= SEE_TURFS
		H.lighting_alpha = min(H.lighting_alpha, LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)

	if(HAS_TRAIT(H, TRAIT_THERMAL_VISION))
		H.sight |= (SEE_MOBS)
		H.lighting_alpha = min(H.lighting_alpha, LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)

	if(HAS_TRAIT(H, TRAIT_XRAY_VISION))
		H.sight |= (SEE_TURFS|SEE_MOBS|SEE_OBJS)

	if(HAS_TRAIT(H, TRAIT_NIGHT_VISION))
		H.see_in_dark = max(H.see_in_dark, 8)
		H.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE

	if(H.has_status_effect(STATUS_EFFECT_SUMMONEDGHOST))
		H.see_invisible = SEE_INVISIBLE_OBSERVER

	H.update_tint()
	H.sync_lighting_plane_alpha()

/datum/species/proc/water_act(mob/living/carbon/human/M, volume, temperature, source, method = REAGENT_TOUCH)
	M.adjust_bodytemperature(clamp((temperature + M.bodytemperature) * 0.5 - M.bodytemperature, BODYTEMP_COOLING_MAX, BODYTEMP_HEATING_MAX)) // Approximation for gradual heating or cooling.

/datum/species/proc/bullet_act(obj/item/projectile/P, mob/living/carbon/human/H) //return TRUE if hit, FALSE if stopped/reflected/etc
	return TRUE

/datum/species/proc/spec_hitby(atom/movable/AM, mob/living/carbon/human/H)
	SEND_SIGNAL(H, COMSIG_SPECIES_HITBY, AM)

/datum/species/proc/spec_attacked_by(obj/item/I, mob/living/user, obj/item/organ/external/affecting, intent, mob/living/carbon/human/H)
	return

/// Returns a list of names of non-blacklisted or hazardous species.
/proc/get_safe_species()
	var/static/list/random_species = list()
	if(!length(random_species))
		for(var/datum/species/S as anything in subtypesof(/datum/species))
			if(!initial(S.dangerous_existence) && !initial(S.blacklisted))
				random_species += initial(S.name)
	return random_species

/datum/species/proc/can_hear(mob/living/carbon/human/H)
	. = FALSE
	var/obj/item/organ/internal/ears/ears = H.get_int_organ(/obj/item/organ/internal/ears)
	if(istype(ears) && !HAS_TRAIT(H, TRAIT_DEAF))
		. = TRUE

/datum/species/proc/spec_Process_Spacemove(mob/living/carbon/human/H)
	return FALSE

/datum/species/proc/spec_thunk(mob/living/carbon/human/H)
	return FALSE

/datum/species/proc/spec_movement_delay()
	return TRUE

/datum/species/proc/spec_WakeUp(mob/living/carbon/human/H)
	return FALSE

/datum/species/proc/handle_brain_death(mob/living/carbon/human/H)
	H.AdjustLoseBreath(20 SECONDS, bound_lower = 0, bound_upper = 50 SECONDS)
	H.Weaken(60 SECONDS)

/datum/species/proc/handle_harm_antag(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(!istype(target))
		return
	if(HAS_TRAIT(user, TRAIT_I_WANT_BRAINS))
		var/obj/item/grab/grabby = user.get_inactive_hand()
		if(istype(grabby))
			if(ismachineperson(target))
				to_chat(user, "<span class='warning zombie'>We can't smell any brains in [target].</span>")
				return FALSE
			if(grabby.state < GRAB_AGGRESSIVE)
				to_chat(user, "<span class='warning zombie'>We need a better grip on [target] to bite them!</span>")
				return TRUE

			if(HAS_TRAIT(target, TRAIT_PIERCEIMMUNE))
				to_chat(user, "<span class='warning zombie'>Our bite fails to pierce [target]!</span>")
				return FALSE

			user.visible_message("<span class='danger'>[user] violently bites [target]!</span>")
			playsound(user.loc, 'sound/weapons/bite.ogg', 20, TRUE)
			playsound(user.loc, 'sound/misc/moist_impact.ogg', 50, TRUE)
			user.do_attack_animation(target, ATTACK_EFFECT_BITE)
			target.apply_damage(20, BRUTE, user.zone_selected)
			if(!HAS_TRAIT(user, TRAIT_NON_INFECTIOUS_ZOMBIE))
				if(!target.HasDisease(/datum/disease/zombie))
					var/datum/disease/zombie/zomb = new /datum/disease/zombie
					if(target.can_contract_disease(zomb)) // biosuit aint going to protect you buddy
						target.ForceContractDisease(zomb)
						target.Dizzy(10 SECONDS)
						target.Confused(10 SECONDS)
					else
						qdel(zomb)

				for(var/datum/disease/zombie/zomb in target.viruses)
					zomb.stage = max(rand(3, 4), zomb.stage)

			qdel(grabby)
			return TRUE

		if(HAS_TRAIT(target, TRAIT_I_WANT_BRAINS))
			to_chat(user, "<span class='warning zombie'>We can't smell any fresh brains in [target].</span>")
			return

		var/obj/item/organ/internal/brain/eat_brain = target.get_organ_slot("brain")
		if(!eat_brain || ismachineperson(target))
			to_chat(user, "<span class='warning zombie'>We can't smell any brains in [target].</span>")
			return FALSE
		var/obj/item/organ/external/brain_house = target.get_limb_by_name(eat_brain.parent_organ)
		if(!brain_house)
			to_chat(user, "<span class='warning zombie'>We can't smell any brains in [target].</span>")
			return FALSE
		if(brain_house.limb_name != user.zone_selected || !brain_house.open)
			return FALSE
		if(target.getarmor(brain_house, MELEE) > 0) // dont count negative armor
			to_chat(user, "<span class='warning zombie'>[target]'s brains are blocked.</span>")
			return FALSE // Armor blocks zombies trying to eat your brains!

		if(target.getBrainLoss() >= 120)
			to_chat(user, "<span class='warning zombie'>No more brains left...</span>")
			return TRUE

		eat_brain.custom_pain("OH GOD!!! THEY'RE EATING MY [uppertext(eat_brain.name)]!!") // gnarly
		user.visible_message("<span class='danger'>[user] digs their claws into [target]'s [brain_house.name], eating their [eat_brain]!</span>", "<span class='danger zombie'>We feast on [target]'s brains.</span>")
		if(!HAS_TRAIT(user, TRAIT_NON_INFECTIOUS_ZOMBIE))
			if(!target.HasDisease(/datum/disease/zombie))
				var/datum/disease/zombie/zomb = new /datum/disease/zombie
				target.ContractDisease(zomb, SPREAD_BLOOD)

			for(var/datum/disease/zombie/zomb in target.viruses)
				zomb.stage = max(5, zomb.stage)

		if(!do_mob(user, target, 1 SECONDS))
			return

		playsound(user.loc, 'sound/items/eatfood.ogg', 20, TRUE)
		playsound(user.loc, 'sound/misc/moist_impact.ogg', 50, TRUE)
		user.do_attack_animation(target, ATTACK_EFFECT_BITE)
		target.adjustBrainLoss(5)
		if(target.stat == CONSCIOUS && prob(33))
			// Ouch, eaten alive.
			target.emote("scream")

		if(user.nutrition < NUTRITION_LEVEL_FULL - 10) // no fat zombies
			user.set_nutrition(user.nutrition + 10)
		user.heal_overall_damage(2, 2)
		return TRUE

	//Vampire code
	var/datum/antagonist/vampire/V = user?.mind?.has_antag_datum(/datum/antagonist/vampire)
	if(V && !V.draining && user.zone_selected == BODY_ZONE_HEAD)
		if((NO_BLOOD in target.dna.species.species_traits) || !target.blood_volume)
			to_chat(user, "<span class='warning'>They have no blood!</span>")
			return TRUE
		if(target.mind && (target.mind.has_antag_datum(/datum/antagonist/vampire) || target.mind.has_antag_datum(/datum/antagonist/mindslave/thrall)))
			to_chat(user, "<span class='warning'>Your fangs fail to pierce [target.name]'s cold flesh!</span>")
			return TRUE
		if(HAS_TRAIT(target, TRAIT_SKELETONIZED))
			to_chat(user, "<span class='warning'>There is no blood in a skeleton!</span>")
			return TRUE
		//we're good to suck the blood, blaah
		V.handle_bloodsucking(target)
		add_attack_logs(user, target, "vampirebit")
		return TRUE
		//end vampire codes

/// Is this species able to be legion infested?
/datum/species/proc/can_be_legion_infested()
	return TRUE

/// Prototype for additional behaviour when a specific species is ground by a compressor.
/datum/species/proc/do_compressor_grind(mob/living/carbon/human)
	return

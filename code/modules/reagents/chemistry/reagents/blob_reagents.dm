// These can only be applied by blobs. They are what blobs are made out of.
// The 4 damage
/datum/reagent/blob
	var/complementary_color = COLOR_BLACK
	var/message = "The blob strikes you" //message sent to any mob hit by the blob
	var/message_living = null //extension to first mob sent to only living mobs i.e. silicons have no skin to be burnt

/datum/reagent/blob/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume, show_message, touch_protection)
	return round(volume * min(1.5 - touch_protection, 1), 0.1) //full touch protection means 50% volume, any prot below 0.5 means 100% volume.

/datum/reagent/blob/proc/damage_reaction(obj/structure/blob/B, damage, damage_type, damage_flag) //when the blob takes damage, do this
	return damage

/// does brute and a little stamina damage
/datum/reagent/blob/ripping_tendrils
	name = "Ripping Tendrils"
	description = "Deals High Brute damage, as well as Stamina damage."
	id = "ripping_tendrils"
	color = COLOR_RIPPING_TENDRILS
	complementary_color = COMPLEMENTARY_COLOR_RIPPING_TENDRILS
	message_living = ", and you feel your skin ripping and tearing off"

/datum/reagent/blob/ripping_tendrils/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_TOUCH)
		volume = ..()
		M.apply_damage(0.6*volume, BRUTE)
		M.apply_damage(volume, STAMINA)
		if(iscarbon(M))
			M.emote("scream")

/// sets you on fire, does burn damage
/datum/reagent/blob/boiling_oil
	name = "Boiling Oil"
	description = "Deals High Burn damage, and sets the victim aflame."
	id = "boiling_oil"
	color = COLOR_BOILING_OIL
	complementary_color = COMPLEMENTARY_COLOR_BOILING_OIL
	message = "The blob splashes you with burning oil"
	message_living = ", and you feel your skin char and melt"

/datum/reagent/blob/boiling_oil/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_TOUCH)
		M.adjust_fire_stacks(round(volume/10))
		volume = ..()
		M.apply_damage(0.6*volume, BURN)
		M.IgniteMob()
		M.emote("scream")

/// toxin, hallucination, and some bonus spore toxin
/datum/reagent/blob/envenomed_filaments
	name = "Envenomed Filaments"
	description = "Deals High Toxin damage, causes Hallucinations, and injects Spores into the bloodstream."
	id = "envenomed_filaments"
	color = COLOR_ENVENOMED_FILAMENTS
	complementary_color = COMPLEMENTARY_COLOR_ENVENOMED_FILAMENTS
	message_living = ", and you feel sick and nauseated"

/datum/reagent/blob/envenomed_filaments/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_TOUCH)
		volume = ..()
		M.apply_damage(0.6 * volume, TOX)
		M.AdjustHallucinate(0.6 SECONDS * volume)
		if(M.reagents)
			M.reagents.add_reagent("spore", 0.4*volume)

/// does tons of oxygen damage and a little brute
/datum/reagent/blob/lexorin_jelly
	name = "Lexorin Jelly"
	description = "Deals Medium Brute damage, but massive amounts of Respiration Damage."
	id = "lexorin_jelly"
	color = COLOR_LEXORIN_JELLY
	complementary_color = COMPLEMENTARY_COLOR_LEXORIN_JELLY
	message_living = ", and your lungs feel heavy and weak"

/datum/reagent/blob/lexorin_jelly/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_TOUCH)
		volume = ..()
		M.apply_damage(0.4*volume, BRUTE)
		M.apply_damage(1*volume, OXY)
		M.AdjustLoseBreath(round(0.6 SECONDS * volume))


/// does semi-random brute damage
/datum/reagent/blob/kinetic
	name = "Kinetic Gelatin"
	description = "Deals Randomized damage, between 0.33 to 2.33 times the standard amount."
	id = "kinetic"
	color = COLOR_KINETIC_GELATIN
	complementary_color = COMPLEMENTARY_COLOR_KINETIC_GELATIN
	message = "The blob pummels you"

/datum/reagent/blob/kinetic/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_TOUCH)
		volume = ..()
		var/damage = rand(5, 35)/25
		M.apply_damage(damage*volume, BRUTE)

/// does low burn damage and stamina damage and cools targets down
/datum/reagent/blob/cryogenic_liquid
	name = "Cryogenic Liquid"
	description = "Deals Medium Brute damage, Stamina Damage, and injects Frost Oil into its victims, freezing them to death."
	id = "cryogenic_liquid"
	color = COLOR_CRYOGENIC_LIQUID
	complementary_color = COMPLEMENTARY_COLOR_CRYOGENIC_LIQUID
	message = "The blob splashes you with an icy liquid"
	message_living = ", and you feel cold and tired"

/datum/reagent/blob/cryogenic_liquid/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_TOUCH)
		volume = ..()
		M.apply_damage(0.4*volume, BURN)
		M.apply_damage(volume, STAMINA)
		if(M.reagents)
			M.reagents.add_reagent("frostoil", 0.4*volume)

/datum/reagent/blob/b_sorium
	name = "Sorium"
	description = "Deals High Brute damage, and sends people flying away."
	id = "b_sorium"
	color = COLOR_SORIUM
	complementary_color = COMPLEMENTARY_COLOR_SORIUM
	message = "The blob slams into you, and sends you flying"

/datum/reagent/blob/b_sorium/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_TOUCH)
		reagent_vortex(M, 1, volume)
		volume = ..()
		M.apply_damage(0.6*volume, BRUTE)

/datum/reagent/blob/proc/reagent_vortex(mob/living/M, setting_type, volume)
	var/turf/pull = get_turf(M)
	var/range_power = clamp(round(volume/5, 1), 1, 5)
	for(var/atom/movable/X in range(range_power,pull))
		if(iseffect(X))
			continue
		if(X.move_resist <= MOVE_FORCE_DEFAULT && !X.anchored)
			var/distance = get_dist(X, pull)
			var/moving_power = max(range_power - distance, 1)
			spawn(0)
			if(!HAS_TRAIT(X, TRAIT_MAGPULSE))
				if(moving_power > 2) //if the vortex is powerful and we're close, we get thrown
					if(setting_type)
						var/atom/throw_target = get_edge_target_turf(X, get_dir(X, get_step_away(X, pull)))
						var/throw_range = 5 - distance
						X.throw_at(throw_target, throw_range, 1)
					else
						X.throw_at(pull, distance, 1)
				else
					if(setting_type)
						for(var/i = 0, i < moving_power, i++)
							sleep(2)
							if(!step_away(X, pull))
								break
					else
						for(var/i = 0, i < moving_power, i++)
							sleep(2)
							if(!step_towards(X, pull))
								break

/datum/reagent/blob/teslium_paste
	name = "Teslium paste"
	description = "Deals medium burn damage, and shocks those struck over time"
	id = "teslium_paste"
	color = COLOR_TESLIUM_PASTE
	complementary_color = COMPLEMENTARY_COLOR_TESLIUM_PASTE
	message_living = ", and you feel a static shock"

/datum/reagent/blob/teslium_paste/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_TOUCH)
		volume = ..()
		M.apply_damage(0.4 * volume, BURN)
		if(M.reagents)
			if(M.reagents.has_reagent("blob_teslium") && prob(0.6 * volume))
				M.electrocute_act((0.5 * volume), "the blob's electrical discharge", 1, SHOCK_NOGLOVES)
				M.reagents.del_reagent("blob_teslium")
				return //don't add more teslium after you shock it out of someone.
			M.reagents.add_reagent("blob_teslium", 0.125 * volume)  // a little goes a long way

/datum/reagent/blob/proc/send_message(mob/living/M)
	var/totalmessage = message
	if(message_living && !issilicon(M))
		totalmessage += message_living
	totalmessage += "!"
	to_chat(M, "<span class='userdanger'>[totalmessage]</span>")

/// Used by cult daggers and the cursed sickly blade. No other melee item can do this, just a universal melee item proc so I don't have to copy paste code
/obj/item/melee/proc/scribe_rune(mob/living/user)
	var/list/shields = list()
	var/list/possible_runes = list()
	var/keyword

	if(!can_scribe(user)) // Check this before anything else
		return

	// Choosing a rune
	for(var/I in (subtypesof(/obj/effect/rune) - /obj/effect/rune/malformed))
		var/obj/effect/rune/R = I
		var/rune_name = initial(R.cultist_name)
		if(rune_name)
			possible_runes[rune_name] = R
	if(!length(possible_runes))
		return

	var/chosen_rune = tgui_input_list(user, "Choose a rite to scribe.", "Sigils of Power", possible_runes)
	if(!chosen_rune)
		return
	var/obj/effect/rune/rune = possible_runes[chosen_rune]
	var/narsie_rune = FALSE
	if(rune == /obj/effect/rune/narsie)
		narsie_rune = TRUE
	if(initial(rune.req_keyword))
		keyword = tgui_input_text(user, "Please enter a keyword for the rune.", "Enter Keyword")
		if(!keyword)
			return

	// Check everything again, in case they moved
	if(!can_scribe(user))
		return

	// Check if the rune is allowed
	var/area/A = get_area(src)
	var/turf/runeturf = get_turf(user)
	var/datum/game_mode/gamemode = SSticker.mode
	if(ispath(rune, /obj/effect/rune/summon))
		if(!is_station_level(runeturf.z) || isspacearea(A))
			to_chat(user, SPAN_CULTITALIC("The veil is not weak enough here to summon a cultist, you must be on station!"))
			return

	if(ispath(rune, /obj/effect/rune/teleport))
		if(!is_level_reachable(user.z))
			to_chat(user, SPAN_CULTITALIC("You are too far away from the station to teleport!"))
			return

	var/old_color = user.color // we'll temporarily redden the user for better feedback to fellow cultists. Store this to revert them back.
	if(narsie_rune)
		if(!narsie_rune_check(user, A))
			return // don't do shit
		var/list/summon_areas = gamemode.cult_team.obj_summon.summon_spots
		if(!(A in summon_areas)) // Check again to make sure they didn't move
			to_chat(user, SPAN_CULTLARGE("The ritual can only begin where the veil is weak - in [english_list(summon_areas)]!"))
			return
		GLOB.major_announcement.Announce("Figments from an eldritch god are being summoned into the [A.map_name] from an unknown dimension. Disrupt the ritual at all costs, before the station is destroyed! Space Law and SOP are suspended. The entire crew must kill cultists on sight.", "Central Command Higher Dimensional Affairs", 'sound/AI/cult_summon.ogg')
		SSticker.cult_tried_summon = TRUE
		for(var/I in spiral_range_turfs(1, user, 1))
			var/turf/T = I
			var/obj/machinery/shield/cult/narsie/N = new(T)
			shields |= N
		user.color = COLOR_RED

	// Draw the rune
	var/mob/living/carbon/human/H = user
	H.cult_self_harm(initial(rune.scribe_damage))
	var/others_message
	if(!narsie_rune)
		others_message = SPAN_WARNING("[user] cuts [user.p_their()] body and begins writing in [user.p_their()] own blood!")
	else
		others_message = SPAN_BIGGERDANGER("[user] cuts [user.p_their()] body and begins writing something particularly ominous in [user.p_their()] own blood!")
	user.visible_message(others_message,
		SPAN_CULTITALIC("You slice open your body and begin drawing a sigil of [GET_CULT_DATA(entity_title3, "your god")]."))

	drawing_rune = TRUE // Only one at a time
	var/scribe_successful = do_after(user, initial(rune.scribe_delay) * toolspeed, target = runeturf)
	for(var/V in shields) // Only used for the 'Tear Veil' rune
		var/obj/machinery/shield/S = V
		if(S && !QDELETED(S))
			qdel(S)
	user.color = old_color
	drawing_rune = FALSE
	if(!scribe_successful)
		return

	user.visible_message(SPAN_WARNING("[user] creates a strange circle in [user.p_their()] own blood."),
						SPAN_CULTITALIC("You finish drawing the arcane markings of [GET_CULT_DATA(entity_title3, "your god")]."))

	var/obj/effect/rune/R = new rune(runeturf, keyword)
	if(narsie_rune)
		for(var/obj/effect/rune/I in orange(1, R))
			qdel(I)
	SSblackbox.record_feedback("tally", "runes_scribed", 1, "[R.cultist_name]")
	R.blood_DNA = list()
	R.blood_DNA[H.dna.unique_enzymes] = H.dna.blood_type
	R.add_hiddenprint(H)
	R.color = H.dna.species.blood_color
	R.rune_blood_color = H.dna.species.blood_color
	to_chat(user, SPAN_CULT("The [lowertext(initial(rune.cultist_name))] rune [initial(rune.cultist_desc)]"))

/obj/item/melee/proc/narsie_rune_check(mob/living/user, area/A)
	var/datum/game_mode/gamemode = SSticker.mode

	if(gamemode.cult_team.cult_status < NARSIE_NEEDS_SUMMONING)
		to_chat(user, SPAN_CULTITALIC("<b>[GET_CULT_DATA(entity_name, "Your god")]</b> is not ready to be summoned yet!"))
		return FALSE
	if(gamemode.cult_team.cult_status == NARSIE_HAS_RISEN)
		to_chat(user, SPAN_CULTLARGE("\"I am already here. There is no need to try to summon me now.\""))
		return FALSE

	var/list/summon_areas = gamemode.cult_team.obj_summon.summon_spots
	if(!(A in summon_areas))
		to_chat(user, SPAN_CULTLARGE("[GET_CULT_DATA(entity_name, "Your god")] can only be summoned where the veil is weak - in [english_list(summon_areas)]!"))
		return FALSE
	var/confirm_final = tgui_alert(user, "This is the FINAL step to summon your deities power, it is a long, painful ritual and the crew will be alerted to your presence AND your location!",
	"Are you prepared for the final battle?", list("My life for [GET_CULT_DATA(entity_name, "the cult")]!", "No"))
	if(user)
		if(confirm_final == "No" || confirm_final == null)
			to_chat(user, SPAN_CULTITALIC("<b>You decide to prepare further before scribing the rune.</b>"))
			return FALSE
		else
			if(locate(/obj/effect/rune) in range(1, user))
				to_chat(user, SPAN_CULTLARGE("You need a space cleared of runes before you can summon [GET_CULT_DATA(entity_title1, "your god")]!"))
				return FALSE
			else
				return TRUE

/obj/item/melee/proc/can_scribe(mob/living/user)
	if(!src || !user || loc != user || user.incapacitated())
		return FALSE
	if(drawing_rune)
		to_chat(user, SPAN_WARNING("You're already drawing a rune!"))
		return FALSE

	var/turf/T = get_turf(user)
	if(isspaceturf(T))
		return FALSE
	if((locate(/obj/effect/rune) in T) || (locate(/obj/effect/rune/narsie) in range(1, T)))
		to_chat(user, SPAN_WARNING("There's already a rune here!"))
		return FALSE
	return TRUE

// MARK: CHAIN OF COMMAND
/obj/item/melee/chainofcommand
	name = "chain of command"
	desc = "A tool used by great men to placate the frothing masses."
	icon_state = "chain"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	force = 10
	throwforce = 7
	origin_tech = "combat=5"
	attack_verb = list("flogged", "whipped", "lashed", "disciplined")
	hitsound = 'sound/weapons/slash.ogg' //pls replace

/obj/item/melee/chainofcommand/suicide_act(mob/user)
	to_chat(viewers(user), SPAN_SUICIDE("[user] is strangling [user.p_themselves()] with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return OXYLOSS

// MARK: ICE PICK
/obj/item/melee/icepick
	name = "ice pick"
	desc = "Used for chopping ice. Also excellent for mafia esque murders."
	icon_state = "icepick"
	force = 15
	throwforce = 10
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("stabbed", "jabbed", "iced,")

// MARK: CANDY SWORD
/obj/item/melee/candy_sword
	name = "candy cane sword"
	desc = "A large candy cane with a sharpened point. Definitely too dangerous for schoolchildren."
	icon_state = "candy_sword"
	force = 10
	throwforce = 7
	attack_verb = list("slashed", "stabbed", "sliced", "caned")

// MARK: FLYSWATTER
/obj/item/melee/flyswatter
	name = "flyswatter"
	desc = "Useful for killing insects of all sizes."
	icon_state = "flyswatter"
	force = 1
	throwforce = 1
	attack_verb = list("swatted", "smacked")
	hitsound = 'sound/effects/snap.ogg'
	w_class = WEIGHT_CLASS_SMALL
	//Things in this list will be instantly splatted.  Flyman weakness is handled in the flyman species weakness proc.
	var/list/strong_against

/obj/item/melee/flyswatter/Initialize(mapload)
	. = ..()
	strong_against = typecacheof(list(
					/mob/living/basic/bee/,
					/mob/living/basic/butterfly,
					/mob/living/basic/cockroach,
					/obj/item/queen_bee))
	strong_against -= /mob/living/basic/bee/syndi // Syndi-bees have special anti-flyswatter tech installed

/obj/item/melee/flyswatter/attack__legacy__attackchain(mob/living/M, mob/living/user, def_zone)
	. = ..()
	if(is_type_in_typecache(M, strong_against))
		new /obj/effect/decal/cleanable/insectguts(M.drop_location())
		user.visible_message(SPAN_WARNING("[user] splats [M] with [src]."),
			SPAN_WARNING("You splat [M] with [src]."),
			SPAN_WARNING("You hear a splat."))
		if(isliving(M))
			var/mob/living/bug = M
			bug.death(TRUE)
		if(!QDELETED(M))
			qdel(M)

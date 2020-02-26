#define CULT_ELDERGOD "eldergod"
#define CULT_SLAUGHTER "slaughter"

/obj/item/melee/cultblade/dagger
	name = "ritual dagger"
	desc = "A strange dagger said to be used by sinister groups for \"preparing\" a corpse before sacrificing it to their dark gods."
	icon = 'icons/obj/cult.dmi'
	icon_state = "cult_dagger"
	w_class = WEIGHT_CLASS_SMALL
	force = 15
	throwforce = 25
	armour_penetration = 35
	var/drawing_rune = FALSE

/obj/item/melee/cultblade/dagger/New()
	if(SSticker.mode)
		icon_state = SSticker.cultdat.dagger_icon
	..()

/obj/item/melee/cultblade/dagger/examine(mob/user)
	. = ..()
	if(iscultist(user) || user.stat == DEAD)
		. += "<span class='cult'>A dagger gifted by [SSticker.cultdat.entity_title3]. Allows the scribing of runes and access to the knowledge archives of the cult of [SSticker.cultdat.entity_name].</span>"
		. += "<span class='cult'>Striking another cultist with it will purge holy water from them.</span>"
		. += "<span class='cult'>Striking a noncultist, however, will tear their flesh.</span>"

/obj/item/melee/cultblade/dagger/attack(mob/living/M, mob/living/user)
	if(iscultist(M))
		if(M.reagents && M.reagents.has_reagent("holywater")) //allows cultists to be rescued from the clutches of ordained religion
			to_chat(user, "<span class='cult'>You remove the taint from [M].</span>")
			var/holy2unholy = M.reagents.get_reagent_amount("holywater")
			M.reagents.del_reagent("holywater")
			M.reagents.add_reagent("unholywater",holy2unholy)
			add_attack_logs(user, M, "Hit with [src], removing the holy water from them")
		return FALSE
	. = ..()

/obj/item/melee/cultblade/dagger/attack_self(mob/user)
	if(!iscultist(user))
		to_chat(user, "<span class='warning'>[src] is covered in unintelligible shapes and markings.</span>")
		return
	scribe_rune(user)

/obj/item/melee/cultblade/dagger/proc/narsie_rune_check(mob/living/user)
	var/datum/game_mode/gamemode = SSticker.mode

	if(gamemode.cult_objs.status < NARSIE_NEEDS_SUMMONING)
		to_chat(user, "<span class='warning'>[SSticker.cultdat.entity_name] is not ready to be summoned yet!</span>")
		return FALSE
	if(gamemode.cult_objs.status == NARSIE_HAS_RISEN)
		to_chat(user, "<span class='cultlarge'>\"I am already here. There is no need to try to summon me now.\"</span>")
		return FALSE
	var/area/A = get_area(src)
	var/list/summon_areas = gamemode.cult_objs.obj_summon.summon_spots
	if(!(A in summon_areas))
		to_chat(user, "<span class='cultlarge'>[SSticker.cultdat.entity_name] can only be summoned where the veil is weak - in [english_list(summon_areas)]!</span>")
		return FALSE
	var/confirm_final = alert(user, "This is the FINAL step to summon your deities power, it is a long, painful ritual and the crew will be alerted to your presence", "Are you prepared for the final battle?", "My life for [SSticker.cultdat.entity_name]!", "No")
	if(confirm_final == "No" || confirm_final == null)
		to_chat(user, "<span class='cult'>You decide to prepare further before scribing the rune.</span>")
		return FALSE
	else
		return TRUE

/obj/item/melee/cultblade/dagger/proc/scribe_rune(mob/living/user)
	var/turf/runeturf = get_turf(user)
	if(isspaceturf(runeturf))
		return
	var/chosen_keyword
	var/obj/effect/rune/rune_to_scribe
	var/entered_rune_name
	var/list/possible_runes = list()
	var/list/shields = list()
	var/area/A = get_area(src)
	if(locate(/obj/effect/rune) in runeturf)
		to_chat(user, "<span class='cult'>There is already a rune here.</span>")
		return
	for(var/T in subtypesof(/obj/effect/rune) - /obj/effect/rune/malformed)
		var/obj/effect/rune/R = T
		if(initial(R.cultist_name))
			possible_runes.Add(initial(R.cultist_name)) //This is to allow the menu to let cultists select runes by name rather than by object path. I don't know a better way to do this
	if(!possible_runes.len)
		return
	entered_rune_name = input(user, "Choose a rite to scribe.", "Sigils of Power") as null|anything in possible_runes
	if(!Adjacent(user) || !src || QDELETED(src) || user.incapacitated())
		return
	for(var/T in typesof(/obj/effect/rune))
		var/obj/effect/rune/R = T
		if(initial(R.cultist_name) == entered_rune_name)
			rune_to_scribe = R
			if(initial(R.req_keyword))
				var/the_keyword = stripped_input(usr, "Please enter a keyword for the rune.", "Enter Keyword", "")
				if(!the_keyword)
					return
				chosen_keyword = the_keyword
			break
	if(!rune_to_scribe)
		return
	runeturf = get_turf(user) //we may have moved. adjust as needed...
	A = get_area(src)
	var/datum/game_mode/gamemode = SSticker.mode
	if(locate(/obj/effect/rune) in runeturf)
		to_chat(user, "<span class='cult'>There is already a rune here.</span>")
		return
	if(!Adjacent(user) || !src || QDELETED(src) || user.incapacitated())
		return
	if(ispath(rune_to_scribe, /obj/effect/rune/summon) && (!is_station_level(runeturf.z) || istype(get_area(src), /area/space)))
		to_chat(user, "<span class='cultitalic'><b>The veil is not weak enough here to summon a cultist, you must be on station!</b></span>")
		return
	if(ispath(rune_to_scribe, /obj/effect/rune/narsie))
		if(narsie_rune_check(user))
			var/list/summon_areas = gamemode.cult_objs.obj_summon.summon_spots
			if(!(A in summon_areas))  // Check again to make sure they didn't move
				to_chat(user, "<span class='cultlarge'>The ritual can only begin where the veil is weak - in [english_list(summon_areas)]!</span>")
				return
			command_announcement.Announce("Figments from an eldritch god are being summoned somewhere on the station from an unknown dimension. Disrupt the ritual at all costs!","Central Command Higher Dimensional Affairs", 'sound/AI/spanomalies.ogg')
			for(var/B in spiral_range_turfs(1, user, 1))
				var/turf/T = B
				var/obj/machinery/shield/N = new(T)
				N.name = "Rune-Scriber's Shield"
				N.desc = "A potent shield summoned by cultists to protect them while they prepare the final ritual"
				N.icon_state = "shield-cult"
				N.health = 60
				shields |= N
		else
			return//don't do shit

	var/mob/living/carbon/human/H = user
	var/dam_zone = pick("l_arm", "l_hand", "r_arm", "r_hand")
	var/obj/item/organ/external/affecting = H.get_organ(dam_zone)
	user.visible_message("<span class='warning'>[user] cuts open [user.p_their()] [affecting.name] and begins writing in [user.p_their()] own blood!</span>", "<span class='cult'>You slice open your [affecting.name] and begin drawing a sigil of [SSticker.cultdat.entity_title3].</span>")
	user.apply_damage(initial(rune_to_scribe.scribe_damage), BRUTE, affecting)
	if(!do_after(user, initial(rune_to_scribe.scribe_delay), target = get_turf(user)))
		for(var/V in shields)
			var/obj/machinery/shield/S = V
			if(S && !QDELETED(S))
				qdel(S)
		return
	if(locate(/obj/effect/rune) in runeturf)
		to_chat(user, "<span class='cult'>There is already a rune here.</span>")
		return
	user.visible_message("<span class='warning'>[user] creates a strange circle in [user.p_their()] own blood.</span>", \
						 "<span class='cult'>You finish drawing the arcane markings of [SSticker.cultdat.entity_title3].</span>")
	for(var/V in shields)
		var/obj/machinery/shield/S = V
		if(S && !QDELETED(S))
			qdel(S)
	var/obj/effect/rune/R = new rune_to_scribe(runeturf, chosen_keyword)
	R.blood_DNA = list()
	R.blood_DNA[H.dna.unique_enzymes] = H.dna.blood_type
	R.add_hiddenprint(H)
	to_chat(user, "<span class='cult'>The [lowertext(initial(rune_to_scribe.cultist_name))] rune [initial(rune_to_scribe.cultist_desc)]</span>")
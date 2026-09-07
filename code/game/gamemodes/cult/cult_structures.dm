/// The amount of time necessary for a structure to be able to produce items after being built
#define CULT_STRUCTURE_COOLDOWN 60 SECONDS

/obj/structure/cult
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	icon = 'icons/obj/cult.dmi'
	light_power = 2

//Noncult As we may have this on maps
/obj/structure/cult/altar
	name = "Altar"
	desc = "A sacrifical altar, stained with long-dried blood. Any power it had is long gone."
	icon_state = "altar"

/obj/structure/cult/forge
	name = "Daemon forge"
	desc = "A forge composed of dark stone and darker metal, covered in incomprehensible inscriptions. The fire within the forge burns low, it is incapable of producing anything."
	icon_state = "forge"
	light_range = 2
	light_color = LIGHT_COLOR_LAVA

/obj/structure/cult/pylon
	name = "Pylon"
	desc = "An otherworldly crystal that hangs in mid-air. Its light is feeble and sputtering, acting as little more than dim illumination."
	icon_state = "pylon"
	light_range = 1.5
	light_color = LIGHT_COLOR_RED

//Cult versions cuase fuck map conflicts
/obj/structure/cult/functional
	max_integrity = 100
	var/cooldowntime = 0
	var/death_message = SPAN_DANGER("The structure falls apart.") //The message shown when the structure is destroyed
	var/death_sound = 'sound/items/bikehorn.ogg'
	var/heathen_message = "You're a huge nerd, go away. Also, a coder forgot to put a message here."
	var/selection_title = "Oops"
	var/selection_prompt = "Choose your weapon, nerdwad"
	var/creation_delay = 2400
	var/list/choosable_items = list("A coder forgot to set this" = /obj/item/grown/bananapeel)
	var/creation_message = "A dank smoke comes out, and you pass out. When you come to, you notice a %ITEM%!"
	/// The dispenser will create this item and then delete itself if it is rust converted.
	var/obj/mansus_conversion_path = /obj/item/bikehorn/rubberducky

/obj/structure/cult/functional/obj_destruction()
	visible_message(death_message)
	playsound(src, death_sound, 50, TRUE)
	..()

/obj/structure/cult/functional/examine(mob/user)
	. = ..()
	if(IS_CULTIST(user) && cooldowntime > world.time)
		. += SPAN_CULTITALIC("The magic in [src] is weak, it will be ready to use again in [get_ETA()].")
	. += SPAN_NOTICE("[src] is [anchored ? "":"not "]secured to the floor.")

/obj/structure/cult/functional/item_interaction(mob/living/user, obj/item/I, list/modifiers)
	if(istype(I, /obj/item/melee/cultblade/dagger) && IS_CULTIST(user))
		if(user.holy_check())
			return ITEM_INTERACT_COMPLETE
		anchored = !anchored
		to_chat(user, SPAN_NOTICE("You [anchored ? "":"un"]secure [src] [anchored ? "to":"from"] the floor."))
		if(!anchored)
			icon_state = GET_CULT_DATA(get_icon("[initial(icon_state)]_off"), "[initial(icon_state)]_off")
		else
			icon_state = GET_CULT_DATA(get_icon(initial(icon_state)), initial(icon_state))
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/structure/cult/functional/attack_hand(mob/living/user)
	if(!IS_CULTIST(user))
		to_chat(user, "[heathen_message]")
		return
	if(invisibility)
		to_chat(user, SPAN_CULTITALIC("The magic in [src] is being suppressed, reveal the structure first!"))
		return
	if(HAS_TRAIT(user, TRAIT_HULK))
		to_chat(user, SPAN_DANGER("You cannot seem to manipulate this structure with your bulky hands!"))
		return
	if(!anchored)
		to_chat(user, SPAN_CULTITALIC("You need to anchor [src] to the floor with a dagger first."))
		return
	if(cooldowntime > world.time)
		to_chat(user, SPAN_CULTITALIC("The magic in [src] is weak, it will be ready to use again in [get_ETA()]."))
		return


	var/list/pickable_items = get_choosable_items()
	var/choice = show_radial_menu(user, src, pickable_items, require_near = TRUE)
	var/picked_type = pickable_items[choice]
	if(!QDELETED(src) && picked_type && Adjacent(user) && !user.incapacitated() && cooldowntime <= world.time)
		cooldowntime = world.time + creation_delay
		var/obj/O = new picked_type
		if(isstructure(O) || !user.put_in_hands(O))
			O.forceMove(get_turf(src))
		to_chat(user, replacetext("[creation_message]", "%ITEM%", "[O.name]"))

/**
  * Returns the items the cult can craft from this forge.
  *
  * Override on children for logic regarding game state.
  */
/obj/structure/cult/functional/proc/get_choosable_items()
	return choosable_items.Copy() // Copied incase its modified on children

/**
  * Returns the cooldown time in minutes and seconds
  */
/obj/structure/cult/functional/proc/get_ETA()
	var/time = cooldowntime - world.time
	var/minutes = round(time / 600)
	var/seconds = round(time * 0.1, 1)
	var/message
	if(minutes)
		message = "[minutes] minute\s"
		seconds = seconds - (60 * minutes)
	if(seconds) // To avoid '2 minutes, 0 seconds.'
		message += "[minutes ? ", " : ""][seconds] second\s"
	return message

/obj/structure/cult/functional/cult_conceal()
	density = FALSE
	visible_message(SPAN_DANGER("[src] fades away."))
	invisibility = INVISIBILITY_HIDDEN_RUNES
	alpha = 100 //To help ghosts distinguish hidden objs
	light_range = 0
	light_power = 0
	update_light()

/obj/structure/cult/functional/cult_reveal()
	density = initial(density)
	invisibility = 0
	visible_message(SPAN_DANGER("[src] suddenly appears!"))
	alpha = initial(alpha)
	light_range = initial(light_range)
	light_power = initial(light_power)
	update_light()

/obj/structure/cult/functional/rust_heretic_act()
	visible_message(SPAN_NOTICE("[src] crumbles to dust. In its midst, you spot \a [initial(mansus_conversion_path.name)]."))
	var/turf/turfy = get_turf(src)
	new mansus_conversion_path(turfy)
	turfy.rust_heretic_act()
	return ..()

/obj/structure/cult/functional/altar
	name = "altar"
	desc = "A sacrifical altar, covered in fresh blood. The runes covering its sides glow with barely-restrained power."
	icon_state = "altar"
	max_integrity = 150 //Sturdy
	death_message = SPAN_DANGER("The altar breaks into splinters, releasing a cascade of spirits into the air!")
	death_sound = 'sound/effects/altar_break.ogg'
	heathen_message = SPAN_WARNING("There is a foreboding aura to the altar and you want nothing to do with it.")
	selection_prompt = "You study the rituals on the altar..."
	selection_title = "Altar"
	creation_message = SPAN_CULTITALIC("You kneel before the altar and your faith is rewarded with a %ITEM%!")
	choosable_items = list("Eldritch Whetstone" = /obj/item/whetstone/cult, "Flask of Unholy Water" = /obj/item/reagent_containers/drinks/bottle/unholywater,
							"Construct Shell" = /obj/structure/constructshell)
	mansus_conversion_path = /obj/effect/heretic_rune/big

/obj/structure/cult/functional/altar/get_choosable_items()
	. = ..()

	if(!SSticker.mode.cult_team?.unlocked_heretic_items[PROTEON_ORB_UNLOCKED])
		return
	. += "Summoning Orb"
	.["Summoning Orb"] = /obj/item/proteon_orb

/obj/structure/cult/functional/altar/Initialize(mapload)
	. = ..()
	icon_state = GET_CULT_DATA(altar_icon_state, "altar")
	cooldowntime = world.time + CULT_STRUCTURE_COOLDOWN

/obj/structure/cult/functional/forge
	name = "daemon forge"
	desc = "A compact forge made of dark stone and darker metal. Molten metal flows through inscribed channels in the construction, ready to be turned into the unholy armaments of a cult."
	icon_state = "forge"
	light_range = 2
	light_color = LIGHT_COLOR_LAVA
	max_integrity = 300 //Made of metal
	death_message = SPAN_DANGER("The forge falls apart, its lava cooling and winking away!")
	death_sound = 'sound/effects/forge_destroy.ogg'
	heathen_message = SPAN_WARNING("Your hand feels like it's melting off as you try to touch the forge.")
	selection_prompt = "You study the schematics etched on the forge..."
	selection_title = "Forge"
	creation_message = SPAN_CULTITALIC("You work the forge as dark knowledge guides your hands, creating a %ITEM%!")
	choosable_items = list("Shielded Robe" = /obj/item/clothing/suit/hooded/cultrobes/cult_shield, "Flagellant's Robe" = /obj/item/clothing/suit/hooded/cultrobes/flagellant_robe)
	mansus_conversion_path = /obj/structure/eldritch_crucible

/obj/structure/cult/functional/forge/get_choosable_items()
	. = ..()
	if(SSticker.mode.cult_team.mirror_shields_active)
		// Both lines here are needed. If you do it without, youll get issues.
		. += "Mirror Shield"
		.["Mirror Shield"] = /obj/item/shield/mirror
	if(!SSticker.mode.cult_team?.unlocked_heretic_items[CURSED_BLADE_UNLOCKED])
		return
	. += "Cursed Blade"
	.["Cursed Blade"] = /obj/item/melee/sickly_blade/cursed


/obj/structure/cult/functional/forge/Initialize(mapload)
	. = ..()
	icon_state = GET_CULT_DATA(forge_icon_state, "forge")

/obj/structure/cult/functional/forge/item_interaction(mob/living/user, obj/item/I, list/modifiers)
	if(istype(I, /obj/item/grab))
		var/obj/item/grab/G = I
		if(!iscarbon(G.affecting))
			return ITEM_INTERACT_COMPLETE
		if(G.affecting == LAVA_PROOF)
			to_chat(user, SPAN_WARNING("[G.affecting] is immune to lava!"))
			return ITEM_INTERACT_COMPLETE
		if(G.affecting.stat == DEAD)
			to_chat(user, SPAN_WARNING("[G.affecting] is dead!"))
			return ITEM_INTERACT_COMPLETE
		var/mob/living/carbon/human/C = G.affecting
		var/obj/item/organ/external/head/head = C.get_organ("head")
		if(!head)
			to_chat(user, SPAN_WARNING("[C] has no head!"))
			return ITEM_INTERACT_COMPLETE

		C.visible_message(SPAN_DANGER("[user] dunks [C]'s face into [src]'s lava!"),
						SPAN_USERDANGER("[user] dunks your face into [src]'s lava!"))
		C.emote("scream")
		C.apply_damage(30, BURN, "head") // 30 fire damage because it's FUCKING LAVA
		head.disfigure() // Your face is unrecognizable because it's FUCKING LAVA
		C.UpdateDamageIcon()
		add_attack_logs(user, C, "Lava-dunked into [src]")
		user.changeNext_move(CLICK_CD_MELEE)
		return ITEM_INTERACT_COMPLETE

	return ..()

GLOBAL_LIST_INIT(blacklisted_pylon_turfs, typecacheof(list(
	/turf/simulated/floor/engine/cult,
	/turf/space,
	/turf/simulated/wall/indestructible,
	/turf/simulated/floor/lava,
	/turf/simulated/floor/chasm,
	/turf/simulated/wall/cult,
	/turf/simulated/wall/cult/artificer
	)))

//why is this a subtype of the dispenser type
/obj/structure/cult/functional/pylon
	name = "pylon"
	desc = "A floating, otherworldly crystal that radiates a baleful red light. Wherever the light touches, matter warps, and the faithful are invigorated."
	icon_state = "pylon"
	light_range = 1.5
	light_color = LIGHT_COLOR_RED
	max_integrity = 50 //Very fragile
	death_message = SPAN_DANGER("The pylon's crystal vibrates and glows fiercely before violently shattering!")
	death_sound = 'sound/effects/pylon_shatter.ogg'
	mansus_conversion_path = /obj/item/clothing/neck/heretic_focus //I guess the crystal turns into a necklace. Look this shouldnt be a subtype, auugh

	var/heal_delay = 30
	var/last_heal = 0
	var/corrupt_delay = 50
	var/last_corrupt = 0

/obj/structure/cult/functional/pylon/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	icon_state = GET_CULT_DATA(pylon_icon_state, "pylon")

/obj/structure/cult/functional/pylon/attack_hand(mob/living/user)//override as it should not create anything
	return

/obj/structure/cult/functional/pylon/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/cult/functional/pylon/cult_conceal()
	STOP_PROCESSING(SSobj, src)
	..()

/obj/structure/cult/functional/pylon/cult_reveal()
	START_PROCESSING(SSobj, src)
	..()

/obj/structure/cult/functional/pylon/process()
	if(!anchored)
		return

	if(last_heal <= world.time)
		last_heal = world.time + heal_delay
		for(var/mob/living/L in range(5, src))
			if(IS_CULTIST(L) || iswizard(L) || isshade(L) || isconstruct(L))
				if(L.health != L.maxHealth)
					new /obj/effect/temp_visual/heal(get_turf(src), COLOR_HEALING_GREEN)

					if(ishuman(L))
						L.heal_overall_damage(1, 1, TRUE, FALSE, TRUE)

					else if(isshade(L) || isconstruct(L))
						var/mob/living/simple_animal/M = L
						if(M.health < M.maxHealth)
							M.adjustHealth(-1)

				if(ishuman(L) && L.blood_volume < BLOOD_VOLUME_NORMAL)
					L.blood_volume += 1

	if(!is_station_level(z) && last_corrupt <= world.time) //Pylons only convert tiles on offstation bases to help hide onstation cults from meson users
		var/list/validturfs = list()
		var/list/cultturfs = list()
		var/list/tableturfs = list()
		for(var/T in circleviewturfs(src, 5))
			for(var/obj/structure/table/table in T)
				if(!istype(table, /obj/structure/table/reinforced/cult))
					tableturfs |= T
			if(istype(T, /turf/simulated/floor/engine/cult))
				cultturfs |= T
				continue
			if(is_type_in_typecache(T, GLOB.blacklisted_pylon_turfs))
				continue
			else
				validturfs |= T

		last_corrupt = world.time + corrupt_delay

		var/turf/tableturf = safepick(tableturfs)
		if(tableturf)
			for(var/obj/structure/table/table in tableturf)
				qdel(table)
				new /obj/structure/table/reinforced/cult/no_metal(tableturf)
		var/turf/T = safepick(validturfs)
		if(T)
			if(isfloorturf(T))
				T.ChangeTurf(/turf/simulated/floor/engine/cult)
			if(iswallturf(T))
				T.ChangeTurf(/turf/simulated/wall/cult/artificer)
		else
			var/turf/simulated/floor/engine/cult/F = safepick(cultturfs)
			if(F)
				new /obj/effect/temp_visual/cult/turf/open/floor(F)
			else
				// Are we in space or something? No cult turfs or
				// convertable turfs?
				last_corrupt = world.time + corrupt_delay * 2

/obj/structure/cult/functional/archives
	name = "archives"
	desc = "A desk covered in arcane manuscripts and tomes in unknown languages. Looking at the text makes your skin crawl."
	icon_state = "archives"
	light_range = 1.5
	light_color = LIGHT_COLOR_FIRE
	max_integrity = 125 //Slightly sturdy
	death_message = SPAN_DANGER("The desk breaks apart, its books falling to the floor.")
	death_sound = 'sound/effects/wood_break.ogg'
	heathen_message = SPAN_CULTLARGE("What do you hope to seek?")
	selection_prompt = "You flip through the black pages of the archives..."
	selection_title = "Archives"
	creation_message = SPAN_CULTITALIC("You invoke the dark magic of the tomes creating a %ITEM%!")
	choosable_items = list("Shuttle Curse" = /obj/item/shuttle_curse, "Zealot's Blindfold" = /obj/item/clothing/glasses/hud/health/night/cultblind,
							"Veil Shifter" = /obj/item/cult_shift, "Reality sunderer" = /obj/item/portal_amulet, "Blank Tarot Card" = /obj/item/blank_tarot_card)
	mansus_conversion_path = /obj/item/codex_cicatrix

/obj/structure/cult/functional/archives/get_choosable_items()
	. = ..()

	if(!SSticker.mode.cult_team?.unlocked_heretic_items[CRIMSON_MEDALLION_UNLOCKED])
		return
	. += "Crimson Medallion"
	.["Crimson Medallion"] = /obj/item/clothing/neck/heretic_focus/crimson_medallion

/obj/structure/cult/functional/archives/Initialize(mapload)
	. = ..()
	icon_state = GET_CULT_DATA(archives_icon_state, "archives")

/obj/effect/gateway
	name = "gateway"
	desc = "There's something inside. It's staring back."
	icon = 'icons/obj/cult.dmi'
	icon_state = "hole"
	density = TRUE

/obj/effect/gateway/singularity_act()
	return

/obj/effect/gateway/singularity_pull()
	return

/obj/effect/gateway/Bumped(atom/movable/AM)
	return

#undef CULT_STRUCTURE_COOLDOWN

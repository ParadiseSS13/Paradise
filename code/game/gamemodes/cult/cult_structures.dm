/obj/structure/cult
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	icon = 'icons/obj/cult.dmi'
	light_power = 2

//Noncult As we may have this on maps
/obj/structure/cult/altar
	name = "Altar"
	desc = "A bloodstained altar."
	icon_state = "altar"

/obj/structure/cult/forge
	name = "Daemon forge"
	desc = "A forge used in crafting unholy armors and weapons."
	icon_state = "forge"
	light_range = 2
	light_color = LIGHT_COLOR_LAVA

/obj/structure/cult/pylon
	name = "Pylon"
	desc = "A floating crystal that hums with an unearthly energy."
	icon_state = "pylon"
	light_range = 1.5
	light_color = LIGHT_COLOR_RED

/obj/structure/cult/archives
	name = "Desk"
	desc = "A desk covered in arcane manuscripts and tomes in unknown languages. Looking at the text makes your skin crawl."
	icon_state = "archives"
	light_range = 1.5
	light_color = LIGHT_COLOR_FIRE

//Cult versions cuase fuck map conflicts
/obj/structure/cult/functional
	max_integrity = 100
	var/cooldowntime = 0
	var/death_message = "<span class='danger'>The structure falls apart.</span>" //The message shown when the structure is destroyed
	var/death_sound = 'sound/items/bikehorn.ogg'
	var/heathen_message = "You're a huge nerd, go away. Also, a coder forgot to put a message here."
	var/selection_title = "Oops"
	var/selection_prompt = "Choose your weapon, nerdwad"
	var/creation_delay = 2400
	var/list/choosable_items = list("A coder forgot to set this" = /obj/item/grown/bananapeel)
	var/creation_message = "A dank smoke comes out, and you pass out. When you come to, you notice a %ITEM%!"

/obj/structure/cult/functional/obj_destruction()
	visible_message(death_message)
	playsound(src, death_sound, 50, TRUE)
	..()

/obj/structure/cult/functional/examine(mob/user)
	. = ..()
	if(iscultist(user) && cooldowntime > world.time)
		. += "<span class='cultitalic'>The magic in [src] is weak, it will be ready to use again in [get_ETA()].</span>"
	. += "<span class='notice'>[src] is [anchored ? "":"not "]secured to the floor.</span>"

/obj/structure/cult/functional/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/melee/cultblade/dagger) && iscultist(user))
		anchored = !anchored
		to_chat(user, "<span class='notice'>You [anchored ? "":"un"]secure [src] [anchored ? "to":"from"] the floor.</span>")
		if(!anchored)
			icon_state = SSticker.cultdat?.get_icon("[initial(icon_state)]_off")
		else
			icon_state = SSticker.cultdat?.get_icon("[initial(icon_state)]")
		return
	return ..()

/obj/structure/cult/functional/attack_hand(mob/living/user)
	if(!iscultist(user))
		to_chat(user, "[heathen_message]")
		return
	if(invisibility)
		to_chat(user, "<span class='cultitalic'>The magic in [src] is being channeled into Redspace, reveal the structure first!</span>")
		return
	if(HULK in user.mutations)
		to_chat(user, "<span class='danger'>You cannot seem to manipulate this structure with your bulky hands!</span>")
		return
	if(!anchored)
		to_chat(user, "<span class='cultitalic'>You need to anchor [src] to the floor with a dagger first.</span>")
		return
	if(cooldowntime > world.time)
		to_chat(user, "<span class='cultitalic'>The magic in [src] is weak, it will be ready to use again in [get_ETA()].</span>")
		return

	var/choice = show_radial_menu(user, src, choosable_items, require_near = TRUE)
	var/picked_type = choosable_items[choice]
	if(!QDELETED(src) && picked_type && Adjacent(user) && !user.incapacitated() && cooldowntime <= world.time)
		cooldowntime = world.time + creation_delay
		var/obj/O = new picked_type
		if(istype(O, /obj/structure) || !user.put_in_hands(O))
			O.forceMove(get_turf(src))
		to_chat(user, replacetext("[creation_message]", "%ITEM%", "[O.name]"))

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
	visible_message("<span class='danger'>[src] fades away.</span>")
	invisibility = INVISIBILITY_HIDDEN_RUNES
	alpha = 100 //To help ghosts distinguish hidden objs
	light_range = 0
	light_power = 0
	update_light()

/obj/structure/cult/functional/cult_reveal()
	density = initial(density)
	invisibility = 0
	visible_message("<span class='danger'>[src] suddenly appears!</span>")
	alpha = initial(alpha)
	light_range = initial(light_range)
	light_power = initial(light_power)
	update_light()

/obj/structure/cult/functional/altar
	name = "altar"
	desc = "A bloodstained altar dedicated to a cult."
	icon_state = "altar"
	max_integrity = 150 //Sturdy
	death_message = "<span class='danger'>The altar breaks into splinters, releasing a cascade of spirits into the air!</span>"
	death_sound = 'sound/effects/altar_break.ogg'
	heathen_message = "<span class='warning'>There is a foreboding aura to the altar and you want nothing to do with it.</span>"
	selection_prompt = "You study the rituals on the altar..."
	selection_title = "Altar"
	creation_message = "<span class='cultitalic'>You kneel before the altar and your faith is rewarded with a %ITEM%!</span>"
	choosable_items = list("Eldritch Whetstone" = /obj/item/whetstone/cult, "Flask of Unholy Water" = /obj/item/reagent_containers/food/drinks/bottle/unholywater,
							"Construct Shell" = /obj/structure/constructshell)

/obj/structure/cult/functional/altar/Initialize(mapload)
	. = ..()
	icon_state = SSticker.cultdat?.altar_icon_state

/obj/structure/cult/functional/forge
	name = "daemon forge"
	desc = "A forge used in crafting the unholy weapons used by the armies of a cult."
	icon_state = "forge"
	light_range = 2
	light_color = LIGHT_COLOR_LAVA
	max_integrity = 300 //Made of metal
	death_message = "<span class='danger'>The forge falls apart, its lava cooling and winking away!</span>"
	death_sound = 'sound/effects/forge_destroy.ogg'
	heathen_message = "<span class='warning'>Your hand feels like it's melting off as you try to touch the forge.</span>"
	selection_prompt = "You study the schematics etched on the forge..."
	selection_title = "Forge"
	creation_message = "<span class='cultitalic'>You work the forge as dark knowledge guides your hands, creating a %ITEM%!</span>"
	choosable_items = list("Shielded Robe" = /obj/item/clothing/suit/hooded/cultrobes/cult_shield, "Flagellant's Robe" = /obj/item/clothing/suit/hooded/cultrobes/flagellant_robe,
							"Mirror Shield" = /obj/item/shield/mirror)

/obj/structure/cult/functional/forge/Initialize(mapload)
	. = ..()
	icon_state = SSticker.cultdat?.forge_icon_state

/obj/structure/cult/functional/forge/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/grab))
		var/obj/item/grab/G = I
		if(!iscarbon(G.affecting))
			return FALSE
		if(G.affecting == LAVA_PROOF)
			to_chat(user, "<span class='warning'>[G.affecting] is immune to lava!</span>")
			return FALSE
		if(G.affecting.stat == DEAD)
			to_chat(user, "<span class='warning'>[G.affecting] is dead!</span>")
			return FALSE
		var/mob/living/carbon/human/C = G.affecting
		var/obj/item/organ/external/head/head = C.get_organ("head")
		if(!head)
			to_chat(user, "<span class='warning'>[C] has no head!</span>")
			return FALSE

		C.visible_message("<span class='danger'>[user] dunks [C]'s face into [src]'s lava!</span>",
						"<span class='userdanger'>[user] dunks your face into [src]'s lava!</span>")
		C.emote("scream")
		C.apply_damage(30, BURN, "head") // 30 fire damage because it's FUCKING LAVA
		head.disfigure() // Your face is unrecognizable because it's FUCKING LAVA
		C.UpdateDamageIcon()
		add_attack_logs(user, C, "Lava-dunked into [src]")
		user.changeNext_move(CLICK_CD_MELEE)
		return TRUE
	return ..()

GLOBAL_LIST_INIT(blacklisted_pylon_turfs, typecacheof(list(
	/turf/simulated/floor/engine/cult,
	/turf/space,
	/turf/simulated/floor/plating/lava,
	/turf/simulated/floor/chasm,
	/turf/simulated/wall/cult,
	/turf/simulated/wall/cult/artificer,
	/turf/unsimulated/wall
	)))

/obj/structure/cult/functional/pylon
	name = "pylon"
	desc = "A floating crystal that slowly heals those faithful to a cult."
	icon_state = "pylon"
	light_range = 1.5
	light_color = LIGHT_COLOR_RED
	max_integrity = 50 //Very fragile
	death_message = "<span class='danger'>The pylon's crystal vibrates and glows fiercely before violently shattering!</span>"
	death_sound = 'sound/effects/pylon_shatter.ogg'

	var/heal_delay = 30
	var/last_heal = 0
	var/corrupt_delay = 50
	var/last_corrupt = 0

/obj/structure/cult/functional/pylon/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	icon_state = SSticker.cultdat?.pylon_icon_state

/obj/structure/cult/functional/pylon/attack_hand(mob/living/user)//override as it should not create anything
	return

/obj/structure/cult/functional/pylon/Destroy()
	STOP_PROCESSING(SSobj, src)
	..()

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
			if(iscultist(L) || iswizard(L) || isshade(L) || isconstruct(L))
				if(L.health != L.maxHealth)
					new /obj/effect/temp_visual/heal(get_turf(src), "#960000")

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
		for(var/T in circleviewturfs(src, 5))
			if(istype(T, /turf/simulated/floor/engine/cult))
				cultturfs |= T
				continue
			if(is_type_in_typecache(T, GLOB.blacklisted_pylon_turfs))
				continue
			else
				validturfs |= T

		last_corrupt = world.time + corrupt_delay

		var/turf/T = safepick(validturfs)
		if(T)
			if(istype(T, /turf/simulated/floor))
				T.ChangeTurf(/turf/simulated/floor/engine/cult)
			if(istype(T, /turf/simulated/wall))
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
	death_message = "<span class='danger'>The desk breaks apart, its books falling to the floor.</span>"
	death_sound = 'sound/effects/wood_break.ogg'
	heathen_message = "<span class='cultlarge'>What do you hope to seek?</span>"
	selection_prompt = "You flip through the black pages of the archives..."
	selection_title = "Archives"
	creation_message = "<span class='cultitalic'>You invoke the dark magic of the tomes creating a %ITEM%!</span>"
	choosable_items = list("Shuttle Curse" = /obj/item/shuttle_curse, "Zealot's Blindfold" = /obj/item/clothing/glasses/hud/health/night/cultblind,
							"Veil Shifter" = /obj/item/cult_shift) //Add void torch to veil shifter spawn

/obj/structure/cult/functional/archives/Initialize(mapload)
	. = ..()
	icon_state = SSticker.cultdat?.archives_icon_state

/obj/effect/gateway
	name = "gateway"
	desc = "You're pretty sure that the abyss is staring back"
	icon = 'icons/obj/cult.dmi'
	icon_state = "hole"
	density = TRUE
	anchored = TRUE

/obj/effect/gateway/singularity_act()
	return

/obj/effect/gateway/singularity_pull()
	return

/obj/effect/gateway/Bumped(atom/movable/AM)
	return

/obj/effect/gateway/Crossed(atom/movable/AM, oldloc)
	return

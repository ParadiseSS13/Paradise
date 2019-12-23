//Noncult
/obj/structure/cult
	density = 1
	anchored = 1
	icon = 'icons/obj/cult.dmi'

//Noncult As we may have this on maps
/obj/structure/cult/altar
	name = "Altar"
	desc = "A bloodstained altar dedicated to Nar-Sie"
	icon_state = "altar"

/obj/structure/cult/forge
	name = "Daemon forge"
	desc = "A forge used in crafting the unholy weapons used by the armies of Nar-Sie"
	icon_state = "forge"

/obj/structure/cult/pylon
	name = "Pylon"
	desc = "A floating crystal that hums with an unearthly energy"
	icon_state = "pylon"
	light_range = 5
	light_color = "#3e0000"

/obj/structure/cult/archives
	name = "Desk"
	desc = "A desk covered in arcane manuscripts and tomes in unknown languages. Looking at the text makes your skin crawl"
	icon_state = "archives"

//Cult versions cuase fuck map conflicts
/obj/structure/cult/functional
	max_integrity = 100
	var/cooldowntime = 0
	var/death_message = "<span class='warning'>The structure falls apart.</span>" //The message shown when the structure is destroyed
	var/death_sound = 'sound/items/bikehorn.ogg'
	var/heathen_message = "You're a huge nerd, go away. Also, a coder forgot to put a message here."
	var/selection_title = "Oops"
	var/selection_prompt = "Choose your weapon, nerdwad"
	var/creation_delay = 2400
	var/list/choosable_items = list("A coder forgot to set this" = /obj/item/grown/bananapeel)
	var/creation_message = "A dank smoke comes out, and you pass out. When you come to, you notice a %ITEM%!"

/obj/structure/cult/functional/obj_destruction()
	visible_message(death_message)
	playsound(src, death_sound, 50, 1)
	..()

/obj/structure/cult/functional/examine(mob/user)
	. = ..()
	if(iscultist(user) && cooldowntime > world.time)
		. += "<span class='cultitalic'>The magic in [src] is weak, it will be ready to use again in [getETA()].</span>"
	. += "<span class='notice'>\The [src] is [anchored ? "":"not "]secured to the floor.</span>"

/obj/structure/cult/functional/attackby(obj/I, mob/user, params)
	if(istype(I, /obj/item/tome) && iscultist(user))
		anchored = !anchored
		to_chat(user, "<span class='notice'>You [anchored ? "":"un"]secure \the [src] [anchored ? "to":"from"] the floor.</span>")
		playsound(loc, 'sound/hallucinations/wail.ogg', 75, 1)
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
	if(HULK in user.mutations)
		to_chat(user, "<span class='danger'>You cannot seem to manipulate this structure with your bulky hands!</span>")
		return
	if(!anchored)
		to_chat(user, "<span class='cultitalic'>You need to anchor [src] to the floor with a tome first.</span>")
		return
	if(cooldowntime > world.time)
		to_chat(user, "<span class='cultitalic'>The magic in [src] is weak, it will be ready to use again in [getETA()].</span>")
		return
	var/choice = input(user, selection_prompt, selection_title) as null|anything in choosable_items
	var/pickedtype = choosable_items[choice]
	if(pickedtype && Adjacent(user) && src && !QDELETED(src) && !user.incapacitated() && cooldowntime <= world.time)
		cooldowntime = world.time + creation_delay
		var/obj/item/N = new pickedtype(get_turf(src))
		to_chat(user, replacetext("[creation_message]", "%ITEM%", "[N]"))

/obj/structure/cult/functional/proc/getETA()
	var/time = (cooldowntime - world.time)/600
	var/eta = "[round(time, 1)] minutes"
	if(time <= 1)
		time = (cooldowntime - world.time)*0.1
		eta = "[round(time, 1)] seconds"
	return eta

/obj/structure/cult/functional/altar
	name = "altar"
	desc = "A bloodstained altar dedicated to a cult."
	icon_state = "altar"
	max_integrity = 150 //Sturdy
	death_message = "<span class='warning'>The altar breaks into splinters, releasing a cascade of spirits into the air!</span>"
	death_sound = 'sound/effects/altar_break.ogg'
	heathen_message = "<span class='warning'>There is a foreboding aura to the altar and you want nothing to do with it.</span>"
	selection_prompt = "You study the rituals on the altar..."
	selection_title = "Altar"
	creation_message = "<span class='cultitalic'>You kneel before the altar and your faith is rewarded with an %ITEM%!</span>"
	choosable_items = list("Eldritch Whetstone"= /obj/item/whetstone/cult, "Zealot's Blindfold" = /obj/item/clothing/glasses/night/cultblind, \
							"Flask of Unholy Water" = /obj/item/reagent_containers/food/drinks/bottle/unholywater, "Cultist Dagger" = /obj/item/melee/cultblade/dagger)

/obj/structure/cult/functional/altar/New()
	. = ..()
	icon_state = SSticker.cultdat?.altar_icon_state

/obj/structure/cult/functional/forge
	name = "daemon forge"
	desc = "A forge used in crafting the unholy weapons used by the armies of a cult."
	icon_state = "forge"
	max_integrity = 300 //Made of metal
	death_message = "<span class='warning'>The forge falls apart, its lava cooling and winking away!</span>"
	death_sound = 'sound/effects/forge_destroy.ogg'
	heathen_message = "<span class='warning'>Your hand feels like it's melting off as you try to touch the forge.</span>"
	selection_prompt = "You study the schematics etched on the forge..."
	selection_title = "Forge"
	creation_message = "<span class='cultitalic'>You work the forge as dark knowledge guides your hands, creating %ITEM%!</span>"
	choosable_items = list("Shielded Robe" = /obj/item/clothing/suit/hooded/cultrobes/cult_shield, "Flagellant's Robe" = /obj/item/clothing/suit/hooded/cultrobes/berserker, \
							"Cultist Hardsuit" = /obj/item/storage/box/cult)

/obj/structure/cult/functional/forge/New()
	. = ..()
	icon_state = SSticker.cultdat?.forge_icon_state

/obj/structure/cult/functional/forge/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/grab))
		var/obj/item/grab/G = I
		if(!iscarbon(G.affecting))
			to_chat(user, "<span class='warning'>You may only dunk carbon-based creatures!</span>")
			return 0
		if(G.affecting == LAVA_PROOF)
			to_chat(user, "<span class='warning'>Is immune to the lava!</span>")
			return 0
		if(G.affecting.stat == DEAD)
			to_chat(user, "<span class='warning'>[G.affecting] is dead!</span>")
			return 0
		var/mob/living/carbon/human/C = G.affecting
		C.visible_message("<span class='danger'>[user] dunks [C]'s face into [src]'s lava!</span>", \
						"<span class='userdanger'>[user] dunks your face into [src]'s lava!</span>")
		if(!C.stat)
			C.emote("scream")
		user.changeNext_move(CLICK_CD_MELEE)
		var/obj/item/organ/external/head/head = C.get_organ("head")
		if(head)
			C.apply_damage(30, BURN, "head") //30 fire damage because it's FUCKING LAVA
			head.disfigure() //Your face is unrecognizable because it's FUCKING LAVA
		return 1
	return ..()

var/list/blacklisted_pylon_turfs = typecacheof(list(
    /turf/simulated/floor/engine/cult,
    /turf/space,
    /turf/simulated/floor/plating/lava,
    /turf/simulated/floor/chasm,
    /turf/simulated/wall/cult,
    /turf/simulated/wall/cult/artificer,
    /turf/unsimulated/wall
	))

/obj/structure/cult/functional/pylon
	name = "pylon"
	desc = "A floating crystal that slowly heals those faithful to a cult."
	icon_state = "pylon"
	light_range = 5
	light_color = "#3e0000"
	max_integrity = 50 //Very fragile
	death_message = "<span class='warning'>The pylon's crystal vibrates and glows fiercely before violently shattering!</span>"
	death_sound = 'sound/effects/pylon_shatter.ogg'

	var/heal_delay = 30
	var/last_heal = 0
	var/corrupt_delay = 50
	var/last_corrupt = 0

/obj/structure/cult/functional/pylon/New()
	. = ..()
	icon_state = SSticker.cultdat?.pylon_icon_state

/obj/structure/cult/functional/pylon/attack_hand(mob/living/user)//override as it should not create anything
	return

/obj/structure/cult/functional/pylon/New()
	START_PROCESSING(SSobj, src)
	..()

/obj/structure/cult/functional/pylon/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/cult/functional/pylon/process()
	if(!anchored)
		return
	if(last_heal <= world.time)
		last_heal = world.time + heal_delay
		for(var/mob/living/L in range(5, src))
			if(iscultist(L) || iswizard(L) || istype(L, /mob/living/simple_animal/shade) || istype(L, /mob/living/simple_animal/hostile/construct))
				if(L.health != L.maxHealth)
					new /obj/effect/temp_visual/heal(get_turf(src), "#960000")
					if(ishuman(L))
						L.heal_overall_damage(1, 1, TRUE, FALSE, TRUE)
					if(istype(L, /mob/living/simple_animal/shade) || istype(L, /mob/living/simple_animal/hostile/construct))
						var/mob/living/simple_animal/M = L
						if(M.health < M.maxHealth)
							M.adjustHealth(-1)
	if(last_corrupt <= world.time)
		var/list/validturfs = list()
		var/list/cultturfs = list()
		for(var/T in circleviewturfs(src, 5))
			if(istype(T, /turf/simulated/floor/engine/cult))
				cultturfs |= T
				continue
			if(is_type_in_typecache(T, blacklisted_pylon_turfs))
				continue
			else
				validturfs |= T

		last_corrupt = world.time + corrupt_delay

		var/turf/T = safepick(validturfs)
		if(T)
			if(istype(T, /turf/simulated/floor))
				T.ChangeTurf(/turf/simulated/floor/engine/cult)
			if(istype(T, /turf/simulated/wall))
				T.ChangeTurf(/turf/simulated/wall/cult)
		else
			var/turf/simulated/floor/engine/cult/F = safepick(cultturfs)
			if(F)
				new /obj/effect/temp_visual/cult/turf/open/floor(F)
			else
				// Are we in space or something? No cult turfs or
				// convertable turfs?
				last_corrupt = world.time + corrupt_delay*2



/obj/structure/cult/functional/archives
	name = "archives"
	desc = "A desk covered in arcane manuscripts and tomes in unknown languages. Looking at the text makes your skin crawl."
	icon_state = "archives"
	max_integrity = 125 //Slightly sturdy
	death_message = "<span class='warning'>The desk breaks apart, its books falling to the floor.</span>"
	death_sound = 'sound/effects/wood_break.ogg'
	heathen_message = "<span class='cultlarge'>What do you hope to seek?</span>"
	selection_prompt = "You flip through the black pages of the archives..."
	selection_title = "Archives"
	creation_message = "<span class='cultitalic'>You invoke the dark magic of the tomes creating %ITEM%!</span>"
	choosable_items = list("Supply Talisman" = /obj/item/paper/talisman/supply/weak, "Shuttle Curse" = /obj/item/shuttle_curse, \
							"Veil Shifter" = /obj/item/cult_shift)

/obj/structure/cult/functional/archives/New()
	. = ..()
	icon_state = SSticker.cultdat?.archives_icon_state

/obj/effect/gateway
	name = "gateway"
	desc = "You're pretty sure that abyss is staring back"
	icon = 'icons/obj/cult.dmi'
	icon_state = "hole"
	density = 1
	anchored = 1.0

/obj/effect/gateway/singularity_act()
	return

/obj/effect/gateway/singularity_pull()
	return

/obj/effect/gateway/Bumped(mob/M as mob|obj)
	spawn(0)
		return
	return

/obj/effect/gateway/Crossed(AM as mob|obj, oldloc)
	spawn(0)
		return
	return


//Armor kit

/obj/item/storage/box/cult
	name = "Dark Forge Cache"
	can_hold = list("/obj/item/clothing/suit/space/cult", "/obj/item/clothing/head/helmet/space/cult")
	max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/cult/New()
	..()
	new /obj/item/clothing/suit/space/cult(src)
	new /obj/item/clothing/head/helmet/space/cult(src)
	return

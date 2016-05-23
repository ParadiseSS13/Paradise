//Noncult
/obj/structure/cult
	density = 1
	anchored = 1
	icon = 'icons/obj/cult.dmi'
	var/cooldowntime = 0
	var/health = 100
	var/death_message = "<span class='warning'>The structure falls apart.</span>" //The message shown when the structure is destroyed
	var/death_sound = 'sound/items/bikehorn.ogg'


/obj/structure/cult/proc/destroy_structure()
	visible_message(death_message)
	playsound(src, death_sound, 50, 1)
	qdel(src)

/obj/structure/cult/attackby(obj/item/I, mob/user, params)
	if(I.force)
		..()
		playsound(src, I.hitsound, 50, 1)
		health = Clamp(health - I.force, 0, initial(health))
		user.changeNext_move(CLICK_CD_MELEE)
		if(health <= 0)
			destroy_structure()
		return
	..()

//Noncult As we may have this on maps
/obj/structure/cult/talisman
	name = "Altar"
	desc = "A bloodstained altar dedicated to Nar-Sie"
	icon_state = "talismanaltar"


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


/obj/structure/cult/tome
	name = "Desk"
	desc = "A desk covered in arcane manuscripts and tomes in unknown languages. Looking at the text makes your skin crawl"
	icon_state = "tomealtar"

//Cult versions cuase fuck map conflicts
/obj/structure/cult/examine(mob/user)
	..()
	if(iscultist(user) && cooldowntime > world.time)
		to_chat(user, "<span class='cultitalic'>The magic in [src] is weak, it will be ready to use again in [getETA()].</span>")

/obj/structure/cult/proc/getETA()
	var/time = (cooldowntime - world.time)/600
	var/eta = "[round(time, 1)] minutes"
	if(time <= 1)
		time = (cooldowntime - world.time)*0.1
		eta = "[round(time, 1)] seconds"
	return eta

/obj/structure/cult/culttalisman
	name = "altar"
	desc = "A bloodstained altar dedicated to Nar-Sie."
	icon_state = "talismanaltar"
	health = 150 //Sturdy
	death_message = "<span class='warning'>The altar breaks into splinters, releasing a cascade of spirits into the air!</span>"
	death_sound = 'sound/effects/altar_break.ogg'

/obj/structure/cult/culttalisman/attack_hand(mob/living/user)
	if(!iscultist(user))
		to_chat(user, "<span class='warning'>You're pretty sure you know exactly what this is used for and you can't seem to touch it.</span>")
		return
	if(cooldowntime > world.time)
		to_chat(user, "<span class='cultitalic'>The magic in [src] is weak, it will be ready to use again in [getETA()].</span>")
		return
	var/choice = alert(user,"You study the schematics etched into the forge...",,"Eldritch Whetstone","Zealot's Blindfold","Flask of Unholy Water")
	var/pickedtype
	switch(choice)
		if("Eldritch Whetstone")
			pickedtype = /obj/item/weapon/whetstone/cult
		if("Zealot's Blindfold")
			pickedtype = /obj/item/clothing/glasses/night/cultblind
		if("Flask of Unholy Water")
			pickedtype = /obj/item/weapon/reagent_containers/food/drinks/bottle/unholywater
	if(pickedtype && Adjacent(user) && src && !qdeleted(src) && !user.incapacitated() && cooldowntime <= world.time)
		cooldowntime = world.time + 2400
		var/obj/item/N = new pickedtype(get_turf(src))
		to_chat(user, "<span class='cultitalic'>You kneel before the altar and your faith is rewarded with an [N]!</span>")


/obj/structure/cult/cultforge
	name = "daemon forge"
	desc = "A forge used in crafting the unholy weapons used by the armies of a cult."
	icon_state = "forge"
	health = 300 //Made of metal
	death_message = "<span class='warning'>The forge falls apart, its lava cooling and winking away!</span>"
	death_sound = 'sound/effects/forge_destroy.ogg'

/obj/structure/cult/cultforge/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = I
		if(!iscarbon(G.affecting))
			to_chat(user, "<span class='warning'>You may only dunk carbon-based creatures!</span>")
			return 0
		if(G.affecting.stat == DEAD)
			to_chat(user, "<span class='warning'>[G.affecting] is dead!</span>")
			return 0
		var/mob/living/carbon/C = G.affecting
		C.visible_message("<span class='danger'>[user] dunks [C]'s face into [src]'s lava!</span>", \
						"<span class='userdanger'>[user] dunks your face into [src]'s lava!</span>")
		if(!C.stat)
			C.emote("scream")
		user.changeNext_move(CLICK_CD_MELEE)
		C.apply_damage(30, BURN, "head") //30 fire damage because it's FUCKING LAVA
		C.status_flags |= DISFIGURED //Your face is unrecognizable because it's FUCKING LAVA
		return 1

/obj/structure/cult/cultforge/attack_hand(mob/living/user)
	if(!iscultist(user))
		to_chat(user, "<span class='warning'>The heat radiating from [src] pushes you back.</span>")
		return
	if(cooldowntime > world.time)
		to_chat(user, "<span class='cultitalic'>The magic in [src] is weak, it will be ready to use again in [getETA()].</span>")
		return
	var/choice = alert(user,"You study the schematics etched into the forge...",, "Flagellant's Robe","Cultist Hardsuit")
	var/pickedtype
	var/otheritem //ie:helmet..
	switch(choice)
		if("Flagellant's Robe")
			pickedtype = /obj/item/clothing/suit/cultrobes/berserker
			otheritem = /obj/item/clothing/head/berserkerhood
		if("Cultist Hardsuit")
			pickedtype = /obj/item/clothing/suit/space/cult
			otheritem = /obj/item/clothing/head/helmet/space/cult
	if(pickedtype && Adjacent(user) && src && !qdeleted(src) && !user.incapacitated() && cooldowntime <= world.time)
		cooldowntime = world.time + 2400
		var/obj/item/N = new pickedtype(get_turf(src))
		if(otheritem)
			new otheritem(get_turf(src))
		to_chat(user, "<span class='cultitalic'>You work the forge as dark knowledge guides your hands, creating [N]!</span>")


/obj/structure/cult/cultpylon
	name = "pylon"
	desc = "A floating crystal that slowly heals those faithful to a cult."
	icon_state = "pylon"
	light_range = 5
	light_color = "#3e0000"
	var/heal_delay = 50
	var/last_shot = 0
	var/list/corruption = list()
	health = 50 //Very fragile
	death_message = "<span class='warning'>The pylon's crystal vibrates and glows fiercely before violently shattering!</span>"
	death_sound = 'sound/effects/pylon_shatter.ogg'

/obj/structure/cult/cultpylon/New()
	processing_objects |= src
	corruption += get_turf(src)
	for(var/i in 1 to 5)
		for(var/t in corruption)
			var/turf/T = t
			corruption |= T.GetAtmosAdjacentTurfs()
	..()

/obj/structure/cult/cultpylon/Destroy()
	processing_objects.Remove(src)
	return ..()

/obj/structure/cult/cultpylon/process()
	if((last_shot + heal_delay) <= world.time)
		last_shot = world.time
		for(var/mob/living/L in range(5, src))
			if(iscultist(L))
				var/mob/living/carbon/human/H = L
				if(istype(H))
					L.adjustBruteLoss(-1, 0)
					L.adjustFireLoss(-1, 0)
					L.updatehealth()
				if(istype(L, /mob/living/simple_animal/shade) || istype(L, /mob/living/simple_animal/hostile/construct))
					var/mob/living/simple_animal/M = L
					if(M.health < M.maxHealth)
						M.adjustBruteLoss(-2)//WAS adjust health...runtimes..
		if(corruption.len)
			var/turf/T = pick_n_take(corruption)
			corruption -= T
			if(istype(T, /turf/simulated/floor/engine/cult) || istype(T, /turf/space))
				return
			T.ChangeTurf(/turf/simulated/floor/engine/cult)


/obj/structure/cult/culttome
	name = "archives"
	desc = "A desk covered in arcane manuscripts and tomes in unknown languages. Looking at the text makes your skin crawl."
	icon_state = "tomealtar"
	health = 125 //Slightly sturdy
	death_message = "<span class='warning'>The desk breaks apart, its books falling to the floor.</span>"
	death_sound = 'sound/effects/wood_break.ogg'

/obj/structure/cult/culttome/attack_hand(mob/living/user)
	if(!iscultist(user))
		to_chat(user, "<span class='warning'>All of these books seem to be gibberish.</span>")
		return
	if(cooldowntime > world.time)
		to_chat(user, "<span class='cultitalic'>The magic in [src] is weak, it will be ready to use again in [getETA()].</span>")
		return
	var/choice = alert(user,"You flip through the black pages of the archives...",,"Supply Talisman","Shuttle Curse","Veil Shifter")
	var/pickedtype
	switch(choice)
		if("Supply Talisman")
			pickedtype = /obj/item/weapon/paper/talisman/supply/weak
		if("Shuttle Curse")
			pickedtype = /obj/item/device/shuttle_curse
		if("Veil Shifter")
			pickedtype = /obj/item/device/cult_shift
	if(pickedtype && Adjacent(user) && src && !qdeleted(src) && !user.incapacitated() && cooldowntime <= world.time)
		cooldowntime = world.time + 2400
		var/obj/item/N = new pickedtype(get_turf(src))
		to_chat(user, "<span class='cultitalic'>You summon [N] from the archives!</span>")


/obj/effect/gateway
	name = "gateway"
	desc = "You're pretty sure that abyss is staring back"
	icon = 'icons/obj/cult.dmi'
	icon_state = "hole"
	density = 1
	unacidable = 1
	anchored = 1.0

/obj/effect/gateway/Bumped(mob/M as mob|obj)
	spawn(0)
		return
	return

/obj/effect/gateway/Crossed(AM as mob|obj)
	spawn(0)
		return
	return
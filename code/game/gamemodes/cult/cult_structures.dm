//Noncult
/obj/structure/cult
	density = 1
	anchored = 1
	icon = 'icons/obj/cult.dmi'
	var/cooldowntime = 0
	var/health = 100
	var/maxhealth = 100

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
	desc = "A forge used in crafting the unholy weapons used by the armies of Nar-Sie."
	icon_state = "forge"
	luminosity = 3

/obj/structure/cult/cultforge/attack_hand(mob/living/user)
	if(!iscultist(user))
		to_chat(user, "<span class='warning'>The heat radiating from [src] pushes you back.</span>")
		return
	if(cooldowntime > world.time)
		to_chat(user, "<span class='cultitalic'>The magic in [src] is weak, it will be ready to use again in [getETA()].</span>")
		return
	var/choice = alert(user,"You study the schematics etched into the forge...", "Flagellant's Robe","Cultist Hardsuit")
	var/pickedtype
	switch(choice)
		if("Flagellant's Robe")
			pickedtype = /obj/item/clothing/suit/cultrobes/berserker
		if("Cultist Hardsuit")
			pickedtype = /obj/item/clothing/suit/space/cult
	if(pickedtype && Adjacent(user) && src && !qdeleted(src) && !user.incapacitated() && cooldowntime <= world.time)
		cooldowntime = world.time + 2400
		var/obj/item/N = new pickedtype(get_turf(src))
		user << "<span class='cultitalic'>You work the forge as dark knowledge guides your hands, creating [N]!</span>"


/obj/structure/cult/cultpylon
	name = "pylon"
	desc = "A floating crystal that slowly heals those faithful to Nar'Sie."
	icon_state = "pylon"
	luminosity = 5
	var/heal_delay = 50
	var/last_shot = 0
	var/list/corruption = list()

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
						M.adjustBruteLoss(-2)
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
	luminosity = 1

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
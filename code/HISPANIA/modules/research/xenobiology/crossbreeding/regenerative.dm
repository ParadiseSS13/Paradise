/*
Regenerative extracts:
	Work like a legion regenerative core.
	Has a unique additional effect.
*/
/obj/item/slimecross/regenerative
	name = "regenerative extract"
	desc = "It's filled with a milky substance, and pulses like a heartbeat."
	effect = "regenerative"
	icon_state = "regenerative"

/obj/item/slimecross/regenerative/proc/core_effect(mob/living/carbon/human/target, mob/user)
	return
/obj/item/slimecross/regenerative/proc/core_effect_before(mob/living/carbon/human/target, mob/user)
	return

/obj/item/slimecross/regenerative/afterattack(atom/target,mob/user,prox)
	. = ..()
	if(!prox || !isliving(target))
		return
	var/mob/living/H = target
	if(H.stat == DEAD)
		to_chat(user, "<span class='warning'>[src] will not work on the dead!</span>")
		return
	if(H != user)
		user.visible_message("<span class='notice'>[user] crushes the [src] over [H], the milky goo quickly regenerating all of [H.p_their()] injuries!</span>",
			"<span class='notice'>You squeeze the [src], and it bursts over [H], the milky goo regenerating [H.p_their()] injuries.</span>")
	else
		user.visible_message("<span class='notice'>[user] crushes the [src] over [user.p_them()]self, the milky goo quickly regenerating all of [user.p_their()] injuries!</span>",
			"<span class='notice'>You squeeze the [src], and it bursts in your hand, splashing you with milky goo which quickly regenerates your injuries!</span>")
	core_effect_before(H, user)
	H.apply_status_effect(STATUS_EFFECT_REGENERATIVE_CORE)
	core_effect(H, user)
	playsound(target, 'sound/effects/splat.ogg', 40, TRUE)
	qdel(src)

/obj/item/slimecross/regenerative/grey
	colour = "grey" //Has no bonus effect.
	effect_desc = "Fully heals the target and does nothing else."

/obj/item/slimecross/regenerative/orange
	colour = "orange"

/obj/item/slimecross/regenerative/orange/core_effect_before(mob/living/target, mob/user)
	target.visible_message("<span class='warning'>The [src] boils over!</span>")
	for(var/turf/turf in range(1,target))
		if(!locate(/obj/effect/hotspot) in turf)
			new /obj/effect/hotspot(turf)

/obj/item/slimecross/regenerative/purple //falta el reagent
	colour = "purple"
	effect_desc = "Fully heals the target and injects them with some regen jelly."

/obj/item/slimecross/regenerative/purple/core_effect(mob/living/target, mob/user)
	target.reagents.add_reagent("regen_jelly",10)

/obj/item/slimecross/regenerative/blue
	colour = "blue"
	effect_desc = "Fully heals the target and makes the floor wet."

/obj/item/slimecross/regenerative/blue/core_effect(mob/living/target, mob/user)
	if(isturf(target.loc))
		var/turf/simulated/T = get_turf(target)
		T.MakeSlippery(TURF_WET_WATER, 10 SECONDS)
		target.visible_message("<span class='warning'>The milky goo in the extract gets all over the floor!</span>")

/obj/item/slimecross/regenerative/metal
	colour = "metal"
	effect_desc = "Fully heals the target and encases the target in a locker."

/obj/item/slimecross/regenerative/metal/core_effect(mob/living/target, mob/user)
	target.visible_message("<span class='warning'>The milky goo hardens and reshapes itself, encasing [target]!</span>")
	var/obj/structure/closet/C = new /obj/structure/closet(target.loc)
	C.name = "slimy closet"
	C.desc = "Looking closer, it seems to be made of a sort of solid, opaque, metal-like goo."
	target.forceMove(C)

/obj/item/slimecross/regenerative/yellow
	colour = "yellow"
	effect_desc = "Fully heals the target and fully recharges a single item on the target."

/obj/item/slimecross/regenerative/yellow/core_effect(mob/living/target, mob/user)
	var/list/batteries = list()
	for(var/obj/item/stock_parts/cell/C in target.GetAllContents())
		if(C.charge < C.maxcharge)
			batteries += C
	if(batteries.len)
		var/obj/item/stock_parts/cell/ToCharge = pick(batteries)
		ToCharge.charge = ToCharge.maxcharge
		to_chat(target, "<span class='notice'>You feel a strange electrical pulse, and one of your electrical items was recharged.</span>")

/obj/item/slimecross/regenerative/silver
	colour = "silver"
	effect_desc = "Fully heals the target and makes their belly feel round and full."

/obj/item/slimecross/regenerative/silver/core_effect(mob/living/target, mob/user)
	target.set_nutrition(NUTRITION_LEVEL_FULL - 1)
	to_chat(target, "<span class='notice'>You feel satiated.</span>")

/obj/item/slimecross/regenerative/cerulean
	colour = "cerulean"
	effect_desc = "Fully heals the target and makes a second regenerative core with no special effects."

/obj/item/slimecross/regenerative/cerulean/core_effect(mob/living/target, mob/user)
	src.forceMove(user.loc)
	var/obj/item/slimecross/X = new /obj/item/slimecross/regenerative(user.loc)
	X.name = name
	X.desc = desc
	user.put_in_active_hand(X)
	to_chat(user, "<span class='notice'>Some of the milky goo congeals in your hand!</span>")

/obj/item/slimecross/regenerative/pyrite
	colour = "pyrite"
	effect_desc = "Fully heals and randomly colors the target."

/obj/item/slimecross/regenerative/pyrite/core_effect(mob/living/target, mob/user)
	target.visible_message("<span class='warning'>The milky goo coating [target] leaves [target.p_them()] a different color!</span>")
	target.add_atom_colour(rgb(rand(0,255),rand(0,255),rand(0,255)),WASHABLE_COLOUR_PRIORITY)

/obj/item/slimecross/regenerative/red
	colour = "red"
	effect_desc = "Fully heals the target and injects them with some ephedrine."

/obj/item/slimecross/regenerative/red/core_effect(mob/living/target, mob/user)
	to_chat(target, "<span class='notice'>You feel... <i>faster.</i></span>")
	target.reagents.add_reagent("ephedrine",3)

/obj/item/slimecross/regenerative/green
	colour = "green"
	effect_desc = "Fully heals the target and changes the spieces or color of a slime or jellyperson."

/obj/item/slimecross/regenerative/green/core_effect(mob/living/target, mob/user)
	if(isslime(target))
		target.visible_message("<span class='warning'>The [target] suddenly changes color!</span>")
		var/mob/living/simple_animal/slime/S = target
		S.random_colour()

/obj/item/slimecross/regenerative/pink
	colour = "pink"
	effect_desc = "Fully heals the target and injects them with some krokodil."

/obj/item/slimecross/regenerative/pink/core_effect(mob/living/target, mob/user)
	to_chat(target, "<span class='notice'>You feel more calm.</span>")
	target.reagents.add_reagent("krokodil",4)

/obj/item/slimecross/regenerative/gold
	colour = "gold"
	effect_desc = "Fully heals the target and produces a random coin."

/obj/item/slimecross/regenerative/gold/core_effect(mob/living/target, mob/user)
	var/newcoin = pick(/obj/item/coin/silver, /obj/item/coin/iron, /obj/item/coin/gold, /obj/item/coin/diamond, /obj/item/coin/plasma, /obj/item/coin/uranium)
	var/obj/item/coin/C = new newcoin(target.loc)
	playsound(C, 'sound/items/coinflip.ogg', 50, TRUE)

/obj/item/slimecross/regenerative/lightpink
	colour = "light pink"
	effect_desc = "Fully heals the target and also heals the user."

/obj/item/slimecross/regenerative/lightpink/core_effect(mob/living/target, mob/user)
	if(!isliving(user))
		return
	if(target == user)
		return
	var/mob/living/U = user
	U.apply_status_effect(STATUS_EFFECT_REGENERATIVE_CORE)
	to_chat(U, "<span class='notice'>Some of the milky goo sprays onto you, as well!</span>")

/obj/item/slimecross/regenerative/darkpurple
	colour = "dark purple"
	effect_desc = "Fully heals the target and gives them purple clothing if they are naked."

/obj/item/slimecross/regenerative/darkpurple/core_effect(mob/living/target, mob/user)
	var/equipped = 0
	equipped += target.equip_to_slot_or_del(new /obj/item/clothing/shoes/purple(null), slot_shoes)
	equipped += target.equip_to_slot_or_del(new /obj/item/clothing/under/color/lightpurple(null), slot_w_uniform)
	equipped += target.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/purple(null), slot_gloves)
	equipped += target.equip_to_slot_or_del(new /obj/item/clothing/head/soft/purple(null), slot_head)
	if(equipped > 0)
		target.visible_message("<span class='notice'>The milky goo congeals into clothing!</span>")

/obj/item/slimecross/regenerative/bluespace
	colour = "bluespace"
	effect_desc = "Fully heals the target and teleports them to where this core was created."
	var/turf/simulated/T

/obj/item/slimecross/regenerative/bluespace/core_effect(mob/living/target, mob/user)
	var/turf/old_location = get_turf(target)
	if(do_teleport(target, T))
		old_location.visible_message("<span class='warning'>[target] disappears in a shower of sparks!</span>")
		to_chat(target, "<span class='danger'>The milky goo teleports you somewhere it remembers!</span>")

/obj/item/slimecross/regenerative/bluespace/Initialize()
	. = ..()
	T = get_turf(src)

/obj/item/slimecross/regenerative/oil
	colour = "oil"
	effect_desc = "Fully heals the target and flashes everyone in sight."

/obj/item/slimecross/regenerative/oil/core_effect(mob/living/target, mob/user)
	playsound(src, 'sound/weapons/flash.ogg', 100, TRUE)
	for(var/mob/living/L in view(user,7))
		L.flash_eyes()

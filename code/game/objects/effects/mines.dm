/obj/effect/mine
	name = "dummy mine"
	desc = "I Better stay away from that thing."
	density = 0
	anchored = 1
	icon = 'icons/obj/items.dmi'
	icon_state = "uglyminearmed"
	var/triggered = 0
	var/faction = "syndicate"

/obj/effect/mine/proc/mineEffect(mob/living/victim)
	to_chat(victim, "<span class='danger'>*click*</span>")

/obj/effect/mine/Crossed(AM as mob|obj, oldloc)
	if(!isliving(AM))
		return
	var/mob/living/M = AM
	if(faction && (faction in M.faction))
		return
	if(M.flying)
		return
	triggermine(M)

/obj/effect/mine/proc/triggermine(mob/living/victim)
	if(triggered)
		return
	visible_message("<span class='danger'>[victim] sets off [bicon(src)] [src]!</span>")
	do_sparks(3, 1, src)
	mineEffect(victim)
	triggered = 1
	qdel(src)

/obj/effect/mine/ex_act(severity)
	// Necessary because, as effects, they have infinite health, and wouldn't be destroyed otherwise.
	// Also, they're pressure-sensitive mines, it makes sense that an explosion (wave of pressure) triggers/destroys them.
	qdel(src)

/obj/effect/mine/explosive
	name = "explosive mine"
	var/range_devastation = 0
	var/range_heavy = 1
	var/range_light = 2
	var/range_flash = 3

/obj/effect/mine/explosive/mineEffect(mob/living/victim)
	explosion(loc, range_devastation, range_heavy, range_light, range_flash)

/obj/effect/mine/stun
	name = "stun mine"
	var/stun_time = 8

/obj/effect/mine/stun/mineEffect(mob/living/victim)
	if(isliving(victim))
		victim.Weaken(stun_time)

/obj/effect/mine/depot
	name = "sentry mine"

/obj/effect/mine/depot/mineEffect(mob/living/victim)
	var/area/syndicate_depot/core/depotarea = areaMaster
	if(istype(depotarea))
		if(depotarea.mine_triggered(victim))
			explosion(loc, 1, 0, 0, 1) // devastate the tile you are on, but leave everything else untouched

/obj/effect/mine/dnascramble
	name = "Radiation Mine"
	var/radiation_amount

/obj/effect/mine/dnascramble/mineEffect(mob/living/victim)
	victim.apply_effect(radiation_amount, IRRADIATE, 0)
	if(ishuman(victim))
		var/mob/living/carbon/human/V = victim
		if(NO_DNA in V.dna.species.species_traits)
			return
	randmutb(victim)
	domutcheck(victim ,null)

/obj/effect/mine/gas
	name = "oxygen mine"
	var/gas_amount = 360
	var/gas_type = SPAWN_OXYGEN

/obj/effect/mine/gas/mineEffect(mob/living/victim)
	atmos_spawn_air(gas_type, gas_amount)

/obj/effect/mine/gas/plasma
	name = "plasma mine"
	gas_type = SPAWN_HEAT | SPAWN_TOXINS

/obj/effect/mine/gas/n2o
	name = "\improper N2O mine"
	gas_type = SPAWN_N2O

/obj/effect/mine/sound
	name = "honkblaster 1000"
	var/sound = 'sound/items/bikehorn.ogg'

/obj/effect/mine/sound/mineEffect(mob/living/victim)
	playsound(loc, sound, 100, 1)

/obj/effect/mine/sound/bwoink
	name = "bwoink mine"
	sound = 'sound/effects/adminhelp.ogg'

/obj/effect/mine/pickup
	name = "pickup"
	desc = "pick me up"
	icon = 'icons/effects/effects.dmi'
	icon_state = "electricity2"
	density = 0
	var/duration = 0

/obj/effect/mine/pickup/New()
	..()
	animate(src, pixel_y = 4, time = 20, loop = -1)

/obj/effect/mine/pickup/triggermine(mob/living/victim)
	if(triggered)
		return
	triggered = 1
	invisibility = 101
	mineEffect(victim)
	qdel(src)

/obj/effect/mine/pickup/bloodbath
	name = "Red Orb"
	desc = "You feel angry just looking at it."
	duration = 1200 //2min
	color = "red"

/obj/effect/mine/pickup/bloodbath/mineEffect(mob/living/carbon/victim)
	if(!istype(victim) || !victim.client)
		return
	to_chat(victim, "<span class='reallybig redtext'>RIP AND TEAR</span>")
	victim << 'sound/misc/e1m1.ogg'
	var/old_color = victim.client.color
	var/red_splash = list(1,0,0,0.8,0.2,0, 0.8,0,0.2,0.1,0,0)
	var/pure_red = list(0,0,0,0,0,0,0,0,0,1,0,0)

	spawn(0)
		new /obj/effect/hallucination/delusion(victim.loc, victim, force_kind = "demon", duration = duration, skip_nearby = 0)

	var/obj/item/twohanded/required/chainsaw/doomslayer/chainsaw = new(victim.loc)
	chainsaw.flags |= NODROP | DROPDEL
	victim.drop_l_hand()
	victim.drop_r_hand()
	victim.put_in_hands(chainsaw)
	chainsaw.attack_self(victim)
	chainsaw.wield(victim)
	victim.reagents.add_reagent("adminordrazine", 25)

	victim.client.color = pure_red
	animate(victim.client,color = red_splash, time = 10, easing = SINE_EASING|EASE_OUT)
	spawn(10)
		animate(victim.client,color = old_color, time = duration)//, easing = SINE_EASING|EASE_OUT)
	spawn(duration)
		to_chat(victim, "<span class='notice'>Your bloodlust seeps back into the bog of your subconscious and you regain self control.</span>")
		qdel(chainsaw)
		qdel(src)

/obj/effect/mine/pickup/healing
	name = "Blue Orb"
	desc = "You feel better just looking at it."
	color = "blue"

/obj/effect/mine/pickup/healing/mineEffect(mob/living/carbon/victim)
	if(!victim.client || !istype(victim))
		return
	to_chat(victim, "<span class='notice'>You feel great!</span>")
	victim.revive()

/obj/effect/mine/pickup/speed
	name = "Yellow Orb"
	desc = "You feel faster just looking at it."
	color = "yellow"
	duration = 300

/obj/effect/mine/pickup/speed/mineEffect(mob/living/carbon/victim)
	if(!victim.client || !istype(victim))
		return
	to_chat(victim, "<span class='notice'>You feel fast!</span>")
	victim.status_flags |= GOTTAGOFAST
	spawn(duration)
		victim.status_flags &= ~GOTTAGOFAST
		to_chat(victim, "<span class='notice'>You slow down.</span>")

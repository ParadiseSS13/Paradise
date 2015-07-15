//////Kitchen Spike

/obj/structure/kitchenspike
	name = "a meat spike"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "spike"
	desc = "A spike for collecting meat from animals."
	density = 1
	anchored = 1
	var/meat = 0
	var/occupied
	var/meat_type
	var/victim_name = "corpse"

/obj/structure/kitchenspike/attackby(obj/item/weapon/grab/G as obj, mob/user as mob)
	if(!istype(G, /obj/item/weapon/grab) || !G.affecting)
		return
	if(occupied)
		user << "<span class = 'danger'>The spike already has something on it, finish collecting its meat first!</span>"
	else
		if(spike(G.affecting))
			visible_message("<span class = 'danger'>[user] has forced [G.affecting] onto the spike, killing them instantly!</span>")
			qdel(G.affecting)
			qdel(G)
		else
			user << "<span class='danger'>They are too big for the spike, try something smaller!</span>"

/obj/structure/kitchenspike/proc/spike(var/mob/living/victim)

	if(!istype(victim))
		return

	if(istype(victim, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = victim
		if(!H.species.is_small)
			return 0
		meat_type = H.species.meat_type
		icon_state = "spikebloody"
	else if(istype(victim, /mob/living/carbon/alien))
		meat_type = /obj/item/weapon/reagent_containers/food/snacks/xenomeat
		icon_state = "spikebloodygreen"
	else
		return 0

	victim_name = victim.name
	occupied = 1
	meat = 5
	return 1

/obj/structure/kitchenspike/attack_hand(mob/user as mob)
	if(..() || !occupied)
		return
	meat--
	new meat_type(get_turf(src))
	if(src.meat > 1)
		user << "You remove some meat from \the [victim_name]."
	else if(src.meat == 1)
		user << "You remove the last piece of meat from \the [victim_name]!"
		icon_state = "spike"
		occupied = 0

/obj/item/grenade/clown_grenade
	name = "Banana Grenade"
	desc = "HONK! brand Bananas. In a special applicator for rapid slipping of wide areas."
	icon_state = "banana"
	force = 2.0
	var/stage = 0
	var/state = 0
	var/path = 0
	var/affected_area = 2

/obj/item/grenade/clown_grenade/prime()
	..()
	playsound(src.loc, 'sound/items/bikehorn.ogg', 25, -3)
	var/i = 0
	var/number = 0
	for(var/direction in GLOB.alldirs)
		for(i = 0; i < 2; i++)
			number++
			var/obj/item/grown/bananapeel/traitorpeel/peel = new /obj/item/grown/bananapeel/traitorpeel(get_turf(src.loc))
			var/a = 1
			if(number & 2)
				for(a = 1; a <= 2; a++)
					step(peel,direction)
			else
				step(peel,direction)
	new /obj/item/grown/bananapeel/traitorpeel(get_turf(src.loc))
	qdel(src)
	return

/obj/item/grown/bananapeel/traitorpeel/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/slippery, src, 14 SECONDS, 100, 4, FALSE)

/obj/item/grown/bananapeel/traitorpeel/after_slip(mob/living/carbon/human/H)
	to_chat(H, "<span class='warning'>Your feet feel like they're on fire!</span>")
	H.take_overall_damage(0, rand(2,8))
	H.take_organ_damage(2)
	return ..()

/obj/item/grown/bananapeel/traitorpeel/throw_impact(atom/hit_atom)
	var/burned = rand(1,3)
	if(isliving(hit_atom))
		var/mob/living/M = hit_atom
		M.take_organ_damage(0, burned)
	return ..()

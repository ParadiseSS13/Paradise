/obj/item/grenade/flashbang
	name = "flashbang"
	icon_state = "flashbang"
	item_state = "flashbang"
	origin_tech = "materials=2;combat=3"
	light_power = 10
	light_color = LIGHT_COLOR_WHITE
	var/light_time = 2

/obj/item/grenade/flashbang/prime()
	update_mob()
	var/flashbang_turf = get_turf(src)
	if(!flashbang_turf)
		return

	set_light(7)

	for(var/mob/living/M in hearers(7, flashbang_turf))
		bang(get_turf(M), M)

	for(var/obj/structure/blob/B in hear(8,flashbang_turf))     		//Blob damage here
		var/damage = round(30/(get_dist(B,get_turf(src))+1))
		B.health -= damage
		B.update_icon()

	spawn(light_time)
		qdel(src)

/obj/item/grenade/flashbang/proc/bang(var/turf/T , var/mob/living/M)
	M.show_message("<span class='warning'>BANG</span>", 2)
	playsound(loc, 'sound/effects/bang.ogg', 25, 1)

//Checking for protections
	var/ear_safety = M.check_ear_prot()
	var/distance = max(1,get_dist(src,T))

//Flash
	if(M.weakeyes)
		M.visible_message("<span class='disarm'><b>[M]</b> screams and collapses!</span>")
		to_chat(M, "<span class='userdanger'><font size=3>AAAAGH!</font></span>")
		M.Weaken(15) //hella stunned
		M.Stun(15)
		if(ishuman(M))
			M.emote("scream")
			var/mob/living/carbon/human/H = M
			var/obj/item/organ/internal/eyes/E = H.get_int_organ(/obj/item/organ/internal/eyes)
			if(E)
				E.receive_damage(8, 1)

	if(M.flash_eyes(affect_silicon = 1))
		M.Stun(max(10/distance, 3))
		M.Weaken(max(10/distance, 3))


//Bang
	if(get_turf(M) == get_turf(src))//Holding on person or being exactly where lies is significantly more dangerous and voids protection
		M.Stun(10)
		M.Weaken(10)
	if(!ear_safety)
		M.Stun(max(10/distance, 3))
		M.Weaken(max(10/distance, 3))
		M.AdjustEarDamage(rand(0, 5), 15)
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			var/obj/item/organ/internal/ears/ears = C.get_int_organ(/obj/item/organ/internal/ears)
			if(istype(ears))
				if(ears.ear_damage >= 15)
					to_chat(M, "<span class='warning'>Your ears start to ring badly!</span>")
					if(prob(ears.ear_damage - 5))
						to_chat(M, "<span class='warning'>You can't hear anything!</span>")
						M.BecomeDeaf()
				else
					if(ears.ear_damage >= 5)
						to_chat(M, "<span class='warning'>Your ears start to ring!</span>")

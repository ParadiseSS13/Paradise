/obj/item/grenade/frag
	name = "frag grenade"
	desc = "Fire in the hole."
	icon_state = "frag"
	item_state = "flashbang"
	origin_tech = "materials=3;magnets=4"
	var/range = 5
	var/max_shrapnel = 4
	var/embed_prob = 100 //reduced by armor
	var/embedded_type = /obj/item/embedded/shrapnel

/obj/item/grenade/frag/prime()
	update_mob()
	var/turf/epicenter = get_turf(src)
	for(var/mob/living/carbon/human/H in epicenter)
		if(H.resting) //grenade is jumped on but get real fucked up
			embed_shrapnel(H, max_shrapnel)
			range = 1
	explosion(loc, 0, 1, range, breach = FALSE)
	for(var/turf/T in view(range, loc))
		for(var/mob/living/carbon/human/H in T)
			var/shrapnel_amount = max_shrapnel - T.Distance(epicenter)
			if(shrapnel_amount > 0)
				embed_shrapnel(H, shrapnel_amount)
	qdel(src)

/obj/item/grenade/frag/proc/embed_shrapnel(mob/living/carbon/human/H, amount)
	for(var/i = 0, i < amount, i++)
		if(prob(embed_prob - H.getarmor(null, "bomb")))
			var/obj/item/embedded/S = new embedded_type(src)
			H.hitby(S, skipcatch = 1)
			S.throwforce = 1
			S.throw_speed = 1
			S.sharp = FALSE
		else
			to_chat(H, "<span class='warning'>Shrapnel bounces off your armor!</span>")

/obj/item/embedded/shrapnel
	name = "shrapnel"
	icon = 'icons/obj/shards.dmi'
	throwforce = 10
	throw_speed =  EMBED_THROWSPEED_THRESHOLD
	embed_chance = 100
	embedded_fall_chance = 0
	w_class = WEIGHT_CLASS_SMALL
	sharp = TRUE
	hitsound = 'sound/weapons/pierce.ogg'

/obj/item/embedded/shrapnel/New()
	..()
	icon_state = pick("shrapnel1", "shrapnel2", "shrapnel3")

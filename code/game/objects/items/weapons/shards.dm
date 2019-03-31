// Glass shards

/obj/item/shard
	name = "glass shard"
	icon = 'icons/obj/shards.dmi'
	icon_state = "large"
	sharp = TRUE
	desc = "Could probably be used as ... a throwing weapon?"
	w_class = WEIGHT_CLASS_TINY
	force = 5
	throwforce = 10
	item_state = "shard-glass"
	materials = list(MAT_GLASS=MINERAL_MATERIAL_AMOUNT)
	attack_verb = list("stabbed", "slashed", "sliced", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	armor = list("melee" = 100, "bullet" = 0, "laser" = 0, "energy" = 100, "bomb" = 0, "bio" = 0, "rad" = 0)

/obj/item/shard/suicide_act(mob/user)
		to_chat(viewers(user), pick("<span class='danger'>[user] is slitting [user.p_their()] wrists with [src]! It looks like [user.p_theyre()] trying to commit suicide.</span>",
									"<span class='danger'>[user] is slitting [user.p_their()] throat with [src]! It looks like [user.p_theyre()] trying to commit suicide.</span>"))
		return BRUTELOSS

/obj/item/shard/New()
	..()
	icon_state = pick("large", "medium", "small")
	switch(icon_state)
		if("small")
			pixel_x = rand(-12, 12)
			pixel_y = rand(-12, 12)
		if("medium")
			pixel_x = rand(-8, 8)
			pixel_y = rand(-8, 8)
		if("large")
			pixel_x = rand(-5, 5)
			pixel_y = rand(-5, 5)

/obj/item/shard/afterattack(atom/movable/AM, mob/user, proximity)
	if(!proximity || !(src in user))
		return
	if(isturf(AM))
		return
	if(istype(AM, /obj/item/storage))
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(!H.gloves)
			var/obj/item/organ/external/affecting = H.get_organ("[user.hand ? "l" : "r" ]_hand")
			if(affecting.is_robotic())
				return
			to_chat(H, "<span class='warning'>[src] cuts into your hand!</span>")
			if(affecting.receive_damage(force*0.5))
				H.UpdateDamageIcon()

/obj/item/shard/attackby(obj/item/I, mob/user, params)
	if(iswelder(I))
		var/obj/item/weldingtool/WT = I
		if(WT.remove_fuel(0, user))
			var/obj/item/stack/sheet/glass/NG = new (user.loc)
			for(var/obj/item/stack/sheet/glass/G in user.loc)
				if(G == NG)
					continue
				if(G.amount >= G.max_amount)
					continue
				G.attackby(NG, user)
			to_chat(user, "<span class='notice'>You add the newly-formed glass to the stack. It now contains [NG.amount] sheet\s.</span>")
			qdel(src)
	else
		return ..()

/obj/item/shard/Crossed(AM as mob|obj)
	if(isliving(AM))
		var/mob/living/M = AM
		if(M.incorporeal_move || M.flying || M.throwing)//you are incorporal or flying or being thrown ..no shard stepping!
			return
		to_chat(M, "<span class='danger'>You step on \the [src]!</span>")
		playsound(loc, 'sound/effects/glass_step.ogg', 50, 1) // not sure how to handle metal shards with sounds
		if(ishuman(M))
			var/mob/living/carbon/human/H = M

			if( !H.shoes && ( !H.wear_suit || !(H.wear_suit.body_parts_covered & FEET) ) )
				var/obj/item/organ/external/affecting = H.get_organ(pick("l_foot", "r_foot"))
				if(!affecting)
					return
				if(affecting.is_robotic())
					return
				H.Weaken(3)
				if(affecting.receive_damage(5, 0))
					H.UpdateDamageIcon()
	..()

/obj/item/shard/plasma
	name = "plasma shard"
	desc = "A shard of plasma glass. Considerably tougher then normal glass shards. Apparently not tough enough to be a window."
	force = 8
	throwforce = 15
	icon_state = "plasmalarge"
	sharp = TRUE

/obj/item/shard/plasma/New()
	..()
	icon_state = pick("plasmalarge", "plasmamedium", "plasmasmall")
	switch(icon_state)
		if("plasmasmall")
			pixel_x = rand(-12, 12)
			pixel_y = rand(-12, 12)
		if("plasmamedium")
			pixel_x = rand(-8, 8)
			pixel_y = rand(-8, 8)
		if("plasmalarge")
			pixel_x = rand(-5, 5)
			pixel_y = rand(-5, 5)

/obj/item/shard/plasma/attackby(obj/item/W, mob/user, params)
	if(iswelder(W))
		var/obj/item/weldingtool/WT = W
		if(WT.remove_fuel(0, user))
			var/obj/item/stack/sheet/plasmaglass/NG = new (user.loc)
			for(var/obj/item/stack/sheet/plasmaglass/G in user.loc)
				if(G == NG)
					continue
				if(G.amount >= G.max_amount)
					continue
				G.attackby(NG, user, params)
				to_chat(usr, "You add the newly-formed plasma glass to the stack. It now contains [NG.amount] sheets.")
			qdel(src)
	else
		return ..()

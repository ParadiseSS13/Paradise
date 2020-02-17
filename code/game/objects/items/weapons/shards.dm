// Glass shards

/obj/item/shard
	name = "shard"
	desc = "A nasty looking shard of glass."
	icon = 'icons/obj/shards.dmi'
	icon_state = "large"
	w_class = WEIGHT_CLASS_TINY
	force = 5
	throwforce = 10
	item_state = "shard-glass"
	materials = list(MAT_GLASS = MINERAL_MATERIAL_AMOUNT)
	attack_verb = list("stabbed", "slashed", "sliced", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	armor = list("melee" = 100, "bullet" = 0, "laser" = 0, "energy" = 100, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 100)
	max_integrity = 40
	resistance_flags = ACID_PROOF
	sharp = TRUE
	var/cooldown = 0
	var/icon_prefix
	var/obj/item/stack/sheet/welded_type = /obj/item/stack/sheet/glass

/obj/item/shard/suicide_act(mob/user)
		to_chat(viewers(user), pick("<span class='danger'>[user] is slitting [user.p_their()] wrists with [src]! It looks like [user.p_theyre()] trying to commit suicide.</span>",
									"<span class='danger'>[user] is slitting [user.p_their()] throat with [src]! It looks like [user.p_theyre()] trying to commit suicide.</span>"))
		return BRUTELOSS

/obj/item/shard/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/caltrop, force)
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
	if(icon_prefix)
		icon_state = "[icon_prefix][icon_state]"

/obj/item/shard/afterattack(atom/movable/AM, mob/user, proximity)
	if(!proximity || !(src in user))
		return
	if(isturf(AM))
		return
	if(istype(AM, /obj/item/storage))
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(!H.gloves && !(PIERCEIMMUNE in H.dna.species.species_traits))
			var/obj/item/organ/external/affecting = H.get_organ("[user.hand ? "l" : "r" ]_hand")
			if(affecting.is_robotic())
				return
			to_chat(H, "<span class='warning'>[src] cuts into your hand!</span>")
			if(affecting.receive_damage(force * 0.5))
				H.UpdateDamageIcon()

/obj/item/shard/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/lightreplacer))
		I.attackby(src, user)
		return
	return ..()

/obj/item/shard/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return
	var/obj/item/stack/sheet/NG = new welded_type(user.loc)
	for(var/obj/item/stack/sheet/G in user.loc)
		if(!istype(G, welded_type))
			continue
		if(G == NG)
			continue
		if(G.amount >= G.max_amount)
			continue
		G.attackby(NG, user)
	to_chat(user, "<span class='notice'>You add the newly-formed glass to the stack. It now contains [NG.amount] sheet\s.</span>")
	qdel(src)

/obj/item/shard/Crossed(mob/living/L, oldloc)
	if(istype(L) && has_gravity(loc))
		if(L.incorporeal_move || L.flying)
			return
		playsound(loc, 'sound/effects/glass_step.ogg', 50, TRUE)
	return ..()

/obj/item/shard/plasma
	name = "plasma shard"
	desc = "A shard of plasma glass. Considerably tougher then normal glass shards. Apparently not tough enough to be a window."
	force = 6
	throwforce = 11
	icon_state = "plasmalarge"
	materials = list(MAT_PLASMA = MINERAL_MATERIAL_AMOUNT * 0.5, MAT_GLASS = MINERAL_MATERIAL_AMOUNT)
	icon_prefix = "plasma"
	welded_type = /obj/item/stack/sheet/plasmaglass

// Glass shards

/obj/item/shard
	name = "shard"
	desc = "A nasty looking shard of glass."
	icon = 'icons/obj/shards.dmi'
	icon_state = "large"
	inhand_icon_state = "shard-glass"
	w_class = WEIGHT_CLASS_TINY
	force = 5
	throwforce = 10
	materials = list(MAT_GLASS = MINERAL_MATERIAL_AMOUNT)
	attack_verb = list("stabbed", "slashed", "sliced", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	armor = list(MELEE = 100, BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 0, RAD = 0, FIRE = 50, ACID = 100)
	max_integrity = 40
	resistance_flags = ACID_PROOF
	sharp = TRUE
	var/cooldown = 0
	var/icon_prefix
	var/obj/item/stack/sheet/welded_type = /obj/item/stack/sheet/glass

/obj/item/shard/suicide_act(mob/user)
		to_chat(viewers(user), pick("<span class='danger'>[user] is slitting [user.p_their()] wrists with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>",
									"<span class='danger'>[user] is slitting [user.p_their()] throat with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>"))
		return BRUTELOSS

/obj/item/shard/proc/set_initial_icon_state()
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

/obj/item/shard/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/caltrop, force)
	set_initial_icon_state()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_atom_entered)
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/item/shard/afterattack__legacy__attackchain(atom/movable/AM, mob/user, proximity)
	if(!proximity || !(src in user))
		return
	if(isturf(AM))
		return
	if(isstorage(AM))
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(!H.gloves && !HAS_TRAIT(H, TRAIT_PIERCEIMMUNE))
			var/obj/item/organ/external/affecting = H.get_organ("[user.hand ? "l" : "r" ]_hand")
			if(affecting.is_robotic())
				return
			to_chat(H, "<span class='warning'>[src] cuts into your hand!</span>")
			if(affecting.receive_damage(force * 0.5))
				H.UpdateDamageIcon()

/obj/item/shard/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return
	new welded_type(user.loc)
	to_chat(user, "<span class='notice'>You add the newly-formed glass to the stack.</span>")
	qdel(src)

/obj/item/shard/proc/on_atom_entered(datum/source, atom/movable/entered)
	var/mob/living/living_entered = entered
	if(istype(living_entered) && has_gravity(loc))
		if(living_entered.incorporeal_move || HAS_TRAIT(living_entered, TRAIT_FLYING) || living_entered.floating)
			return
		playsound(loc, 'sound/effects/glass_step.ogg', 50, TRUE)

/obj/item/shard/decompile_act(obj/item/matter_decompiler/C, mob/user)
	C.stored_comms["glass"] += 3
	qdel(src)
	return TRUE

/obj/item/shard/plasma
	name = "plasma shard"
	desc = "A shard of plasma glass. Considerably tougher then normal glass shards. Apparently not tough enough to be a window."
	force = 6
	throwforce = 11
	icon_state = "plasmalarge"
	materials = list(MAT_PLASMA = MINERAL_MATERIAL_AMOUNT * 0.5, MAT_GLASS = MINERAL_MATERIAL_AMOUNT)
	icon_prefix = "plasma"
	welded_type = /obj/item/stack/sheet/plasmaglass

/obj/item/shard/plastitanium
	name = "plastitanium shard"
	desc = "A shard of plastitanium glass. Considerably tougher then normal glass shards. Apparently not tough enough to be a window."
	force = 6
	throwforce = 11
	icon_state = "plastitaniumlarge"
	materials = list(MAT_TITANIUM = MINERAL_MATERIAL_AMOUNT * 0.5, MAT_PLASMA = MINERAL_MATERIAL_AMOUNT * 0.5, MAT_GLASS = MINERAL_MATERIAL_AMOUNT)
	icon_prefix = "plastitanium"
	welded_type = /obj/item/stack/sheet/plastitaniumglass

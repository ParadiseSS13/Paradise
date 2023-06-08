/obj/item/gun/pneumatic_rifle
	name = "Pneumatic rifle"
	desc = "Oddly looking design purposed to fire syringes at long range. It requires to be holded in two hands for more accurate shooting."
	w_class = WEIGHT_CLASS_BULKY
	force = 8
	attack_verb = list("bludgeoned", "smashed", "beaten")
	icon = 'icons/obj/weapons/pneumaticRifle.dmi'
	icon_state = "pneumaticRifle"
	item_state = "pneumaticRifle"
	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'
	fire_sound = 'sound/weapons/pneumatic_rifle.ogg'
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 50)
	var/obj/item/tank/internals/tank = null
	var/list/syringes = list()
	var/max_syringes = 1
	var/gasPerShot = 0.24
	var/isBelted = FALSE
	var/beltCost = 10 //cable coils needed to make a strap
	slot_flags = 0 //changed by attaching straps, so you can wear it on your back
	weapon_weight = WEAPON_HEAVY
	can_holster = FALSE


/obj/item/gun/pneumatic_rifle/Initialize(mapload)
	. = ..()
	chambered = new /obj/item/ammo_casing/syringegun(src)

/obj/item/gun/pneumatic_rifle/Destroy()
	QDEL_NULL(tank)
	return ..()

/obj/item/gun/pneumatic_rifle/examine(mob/user)
	. = ..()
	if(!in_range(user, src))
		. += span_notice(">You'll need to get closer to see any more.")
	else
		if(chambered.BB)
			. += span_notice("It is loaded.")
		if(tank)
			. += span_notice("[bicon(tank)] It has [tank] mounted onto it. It could be removed with a <b>screwdriver</b>.")
		if(isBelted)
			. += span_notice("It has a strap, now you can hold [src] on your back.")

/obj/item/gun/pneumatic_rifle/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(tank)
		updateTank(tank, 1, user)
	else
		to_chat(user, span_notice("There is no tank inside!"))

/obj/item/gun/pneumatic_rifle/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/analyzer))
		return
	if(istype(I, /obj/item/stack/cable_coil))
		if(!isBelted)
			var/obj/item/stack/cable_coil/coil = I
			if(coil.get_amount() < beltCost)
				to_chat(user, span_warning("Not enough cable coil to strap [src]."))
				return
			else
				coil.use(beltCost)
				to_chat(user, span_notice("You strapped [src], so now you can wear it on your back"))
				isBelted = TRUE
				slot_flags |= SLOT_BACK
				update_icons()
				return
		else
			to_chat(user, span_warning("[src] is already strapped!"))
			return
	if(istype(I, /obj/item/tank/internals) && !tank)
		if(istype(I, /obj/item/tank/internals/emergency_oxygen))
			updateTank(I, 0, user)
			to_chat(user, span_notice("You load [I] into [src]"))
			return
		else
			to_chat(user, span_warning("[I] is too big for [src]."))
			return
	if(istype(I, /obj/item/reagent_containers/syringe))
		var/in_clip = length(syringes) + (chambered.BB ? 1 : 0)
		if(in_clip < max_syringes)
			if(!user.drop_transfer_item_to_loc(I, src))
				return
			to_chat(user, "<span class='notice'>You load [I] into \the [src]!</span>")
			syringes.Add(I)
			process_chamber() // Chamber the syringe if none is already
			return TRUE
		else
			to_chat(user, "<span class='notice'>[src] cannot hold more syringes.</span>")
	else
		return ..()

/obj/item/gun/pneumatic_rifle/afterattack(atom/target, mob/living/carbon/human/user, flag, params)
	. = ..()
	if(target == loc)
		return

/obj/item/gun/pneumatic_rifle/attack_self(mob/living/user)
	if(!length(syringes) && !chambered.BB)
		to_chat(user, "<span class='notice'>[src] is empty.</span>")
		return FALSE

	var/obj/item/reagent_containers/syringe/S
	if(chambered.BB) // Remove the chambered syringe first
		S = new()
		chambered.BB.reagents.trans_to(S, chambered.BB.reagents.total_volume)
		qdel(chambered.BB)
		chambered.BB = null
	else
		S = syringes[length(syringes)]

	user.put_in_hands(S)
	syringes.Remove(S)
	process_chamber()
	to_chat(user, "<span class='notice'>You unload [S] from \the [src]!</span>")
	return TRUE

/obj/item/gun/pneumatic_rifle/process_chamber()
	if(!length(syringes) || chambered.BB)
		return

	var/obj/item/reagent_containers/syringe/S = syringes[1]
	if(!S)
		return

	chambered.BB = new S.projectile_type(src)
	S.reagents.trans_to(chambered.BB, S.reagents.total_volume)
	chambered.BB.name = S.name

	syringes.Remove(S)
	qdel(S)

/obj/item/gun/pneumatic_rifle/afterattack(atom/target, mob/living/user, flag, params)
	if(!tank)
		to_chat(user, span_warning("[src] can't fire without a source of gas."))
		return
	if(!chambered.BB)
		to_chat(user, span_warning("[src] is not loaded."))
		return
	if(tank && tank.air_contents.total_moles() < gasPerShot)
		to_chat(user, span_warning("[src] lets out a weak hiss and doesn't react!"))
		playsound(loc, 'sound/effects/refill.ogg', 50, 1)
		return
	tank.air_contents.remove(gasPerShot)
	..()

/obj/item/gun/pneumatic_rifle/return_analyzable_air()
	if(tank)
		return tank.return_analyzable_air()

/obj/item/gun/pneumatic_rifle/proc/updateTank(obj/item/tank/thetank, removing = 0, mob/living/carbon/human/user)
	if(removing)
		if(!tank)
			return
		to_chat(user, span_notice("You remove [thetank] from [src]."))
		tank.loc = get_turf(src)
		user.put_in_hands(tank)
		tank = null
	if(!removing)
		if(tank)
			to_chat(user, span_warning("[src] already has a tank."))
			return
		if(!user.drop_transfer_item_to_loc(thetank, src))
			return
		to_chat(user, span_notice("You hook [thetank] up to [src]."))
		tank = thetank
	update_icons()

/datum/crafting_recipe/pneumatic_rifle
	name = "Pneumatic Rifle"
	result = /obj/item/gun/pneumatic_rifle
	tools = list(TOOL_SCREWDRIVER)
	reqs = list(/obj/item/c_tube = 3,
				/obj/item/weaponcrafting/receiver = 1,
				/obj/item/weaponcrafting/stock = 1,
				/obj/item/stack/tape_roll = 15,
				/obj/item/stack/sheet/metal = 2)
	time = 300
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/obj/item/gun/pneumatic_rifle/proc/update_icons()
	overlays.Cut()
	if(tank)
		overlays += image('icons/obj/weapons/pneumaticRifle.dmi', "[tank.icon_state]")
	if(isBelted)
		overlays += image('icons/obj/weapons/pneumaticRifle.dmi', "belt")
	update_icon()

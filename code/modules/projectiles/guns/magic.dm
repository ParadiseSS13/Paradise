/obj/item/gun/magic
	name = "staff of nothing"
	desc = "This staff is boring to watch because even though it came first you've seen everything it can do in other staves for years."
	icon = 'icons/obj/guns/magic.dmi'
	icon_state = "staffofnothing"
	inhand_icon_state = "staff"
	lefthand_file = 'icons/mob/inhands/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/staves_righthand.dmi'
	fire_sound = 'sound/weapons/emitter.ogg'
	fire_sound_text = "energy blast"
	w_class = WEIGHT_CLASS_HUGE
	var/max_charges = 6
	var/charges = 0
	var/recharge_rate = 4
	var/charge_tick = 0
	var/can_charge = TRUE
	var/ammo_type
	var/no_den_usage
	var/antimagic_flags = MAGIC_RESISTANCE
	origin_tech = null
	clumsy_check = FALSE
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL // Has no trigger at all, uses magic instead

/obj/item/gun/magic/afterattack__legacy__attackchain(atom/target, mob/living/user, flag)
	if(no_den_usage)
		var/area/A = get_area(user)
		if(istype(A, /area/wizard_station))
			to_chat(user, "<span class='warning'>You know better than to violate the security of The Den, best wait until you leave to use [src].</span>")
			return
		else
			no_den_usage = 0
	if(!user.can_cast_magic(antimagic_flags))
		to_chat(user, "<span class='warning'>[src] whizzles quietly.</span>")
		return FALSE
	..()

/obj/item/gun/magic/can_shoot()
	return charges

/obj/item/gun/magic/newshot(params)
	if(charges && chambered && !chambered.BB)
		chambered.newshot(params)
	return

/obj/item/gun/magic/process_fire(atom/target as mob|obj|turf, mob/living/user as mob|obj, message = 1, params, zone_override, bonus_spread = 0)
	newshot()
	return ..()

/obj/item/gun/magic/process_chamber()
	if(chambered && !chambered.BB) //if BB is null, i.e the shot has been fired...
		charges--//... drain a charge
	return

/obj/item/gun/magic/Initialize(mapload)
	. = ..()
	charges = max_charges
	chambered = new ammo_type(src)
	if(can_charge)
		START_PROCESSING(SSobj, src)


/obj/item/gun/magic/Destroy()
	if(can_charge)
		STOP_PROCESSING(SSobj, src)
	return ..()


/obj/item/gun/magic/process()
	// Don't start recharging until we lose a charge
	if(charges >= max_charges)
		charge_tick = 0
		return FALSE

	charge_tick++
	if(charge_tick >= recharge_rate)
		charge_tick = 0
		charges++
		return TRUE
	else
		return FALSE

/obj/item/gun/magic/update_icon_state()
	return

/obj/item/gun/magic/shoot_with_empty_chamber(mob/living/user as mob|obj)
	to_chat(user, "<span class='warning'>[src] whizzles quietly.</span>")
	return

/obj/item/gun/magic/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is twisting [src] above [user.p_their()] head, releasing a magical blast! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	playsound(loc, fire_sound, 50, TRUE, -1)
	return FIRELOSS

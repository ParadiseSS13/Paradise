#define GET_FUEL reagents.get_reagent_amount("fuel")

/obj/item/gun/projectile/attackby(obj/item/A, mob/user, params)
	. = ..()
	SEND_SIGNAL(src, COMSIG_UPDATE_GUNHUD)

/obj/item/gun/projectile/attack_self(mob/living/user)
	. = ..()
	SEND_SIGNAL(src, COMSIG_UPDATE_GUNHUD)

/obj/item/gun/energy/on_recharge()
	. = ..()
	SEND_SIGNAL(src, COMSIG_UPDATE_GUNHUD)

/obj/item/gun/energy/select_fire(mob/living/user)
	. = ..()
	SEND_SIGNAL(src, COMSIG_UPDATE_GUNHUD)

/obj/item/gun/energy/emp_act(severity)
	. = ..()
	SEND_SIGNAL(src, COMSIG_UPDATE_GUNHUD)

/obj/item/gun/energy/process_chamber()
	. = ..()
	SEND_SIGNAL(src, COMSIG_UPDATE_GUNHUD)

/obj/item/gun/projectile/process_chamber(eject_casing, empty_chamber)
	. = ..()
	SEND_SIGNAL(src, COMSIG_UPDATE_GUNHUD)

/obj/item/gun/projectile/shotgun/pump(mob/M)
	. = ..()
	SEND_SIGNAL(src, COMSIG_UPDATE_GUNHUD)

/obj/item/gun/projectile/revolver/attackby(obj/item/A, mob/user, params)
	. = ..()
	SEND_SIGNAL(src, COMSIG_UPDATE_GUNHUD)

/obj/item/gun/projectile/revolver/attack_self(mob/living/user)
	. = ..()
	SEND_SIGNAL(src, COMSIG_UPDATE_GUNHUD)

/obj/item/weldingtool/toggle_welder(turn_off)
	. = ..()
	SEND_SIGNAL(src, COMSIG_UPDATE_GUNHUD)

/obj/item/weldingtool/remove_fuel(amount)
	. = ..()
	SEND_SIGNAL(src, COMSIG_UPDATE_GUNHUD)

/obj/item/weldingtool/refill(mob/user, atom/A, amount)
	. = ..()
	SEND_SIGNAL(src, COMSIG_UPDATE_GUNHUD)

/obj/item/weldingtool/use(amount)
	. = ..()
	SEND_SIGNAL(src, COMSIG_UPDATE_GUNHUD)

/obj/item/weldingtool/process()
	. = ..()
	if(refills_over_time && GET_FUEL != maximum_fuel)
		SEND_SIGNAL(src, COMSIG_UPDATE_GUNHUD)

#undef GET_FUEL

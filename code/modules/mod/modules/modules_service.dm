//Service modules for MODsuits

///Bike Horn - Plays a bike horn sound.
/obj/item/mod/module/bikehorn
	name = "MOD bike horn module"
	desc = "A shoulder-mounted piece of heavy sonic artillery, this module uses the finest femto-manipulator technology to \
		precisely deliver an almost lethal squeeze to... a bike horn, producing a significantly memorable sound."
	icon_state = "bikehorn"
	module_type = MODULE_USABLE
	complexity = 1
	use_power_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/bikehorn)
	cooldown_time = 1 SECONDS

/obj/item/mod/module/bikehorn/on_use()
	. = ..()
	if(!.)
		return
	playsound(src, 'sound/items/bikehorn.ogg', 100, FALSE)
	drain_power(use_power_cost)

//Waddle - Makes you waddle and squeak.
/obj/item/mod/module/waddle
	name = "MOD waddle module"
	desc = "Some of the most primitive technology in use by Honk Co. This module works off an automatic intention system, \
		utilizing its' sensitivity to the pilot's often-limited brainwaves to directly read their next step, \
		affecting the boots they're installed in. Employing a twin-linked gravitonic drive to create \
		miniaturized etheric blasts of space-time beneath the user's feet, this enables them to... \
		to waddle around, bouncing to and fro with a pep in their step."
	icon_state = "waddle"
	complexity = 1
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.2
	incompatible_modules = list(/obj/item/mod/module/waddle)

/obj/item/mod/module/waddle/on_suit_activation()
	mod.boots.AddComponent(/datum/component/squeak, list('sound/effects/clownstep1.ogg' = 1, 'sound/effects/clownstep2.ogg' = 1), 50, falloff_exponent = 20) //die off quick please
	mod.wearer.AddElement(/datum/element/waddling)

/obj/item/mod/module/waddle/on_suit_deactivation(deleting = FALSE)
	if(!deleting)
		qdel(mod.boots.GetComponent(/datum/component/squeak))
	mod.wearer.RemoveElement(/datum/element/waddling)

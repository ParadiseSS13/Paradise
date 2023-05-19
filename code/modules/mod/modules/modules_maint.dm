//Maint modules for MODsuits

///Springlock Mechanism - allows your modsuit to activate faster, but reagents are very dangerous.
/obj/item/mod/module/springlock
	name = "MOD springlock module"
	desc = "A module that spans the entire size of the MOD unit, sitting under the outer shell. \
		This mechanical exoskeleton pushes out of the way when the user enters and it helps in booting \
		up, but was taken out of modern suits because of the springlock's tendency to \"snap\" back \
		into place when exposed to humidity. You know what it's like to have an entire exoskeleton enter you?"
	icon_state = "springlock"
	complexity = 3 // it is inside every part of your suit, so
	incompatible_modules = list(/obj/item/mod/module/springlock)

/obj/item/mod/module/springlock/on_install()
	mod.activation_step_time *= 0.5

/obj/item/mod/module/springlock/on_uninstall(deleting = FALSE)
	mod.activation_step_time *= 2

/obj/item/mod/module/springlock/on_suit_activation()
	RegisterSignal(mod.wearer, COMSIG_ATOM_EXPOSE_REAGENTS, PROC_REF(on_wearer_exposed))

/obj/item/mod/module/springlock/on_suit_deactivation(deleting = FALSE)
	UnregisterSignal(mod.wearer, COMSIG_ATOM_EXPOSE_REAGENTS)

///Signal fired when wearer is exposed to reagents
/obj/item/mod/module/springlock/proc/on_wearer_exposed(atom/source, list/reagents, datum/reagents/source_reagents, methods, volume_modifier, show_message)
	SIGNAL_HANDLER
	to_chat(mod.wearer, "<span class='danger'>[src] makes an ominous click sound...</span>")
	playsound(src, 'sound/items/modsuit/springlock.ogg', 75, TRUE)
	addtimer(CALLBACK(src, PROC_REF(snap_shut)), rand(3 SECONDS, 5 SECONDS))
	RegisterSignal(mod, COMSIG_MOD_ACTIVATE, PROC_REF(on_activate_spring_block))

///Signal fired when wearer attempts to activate/deactivate suits
/obj/item/mod/module/springlock/proc/on_activate_spring_block(datum/source, user)
	SIGNAL_HANDLER

	to_chat(mod.wearer, "<span class='danger'>The springlocks aren't responding...?</span>")
	return MOD_CANCEL_ACTIVATE

///Delayed death proc of the suit after the wearer is exposed to reagents
/obj/item/mod/module/springlock/proc/snap_shut()
	UnregisterSignal(mod, COMSIG_MOD_ACTIVATE)
	if(!mod.wearer) //while there is a guaranteed user when on_wearer_exposed() fires, that isn't the same case for this proc
		return
	mod.wearer.visible_message("[src] inside [mod.wearer]'s [mod.name] snaps shut, mutilating the user inside!", "<span class='danger'>*SNAP*</span>")
	mod.wearer.emote("scream")
	playsound(mod.wearer, 'sound/effects/snap.ogg', 75, TRUE, frequency = 0.5)
	playsound(mod.wearer, 'sound/effects/splat.ogg', 50, TRUE, frequency = 0.5)
	mod.wearer.apply_damage(500, BRUTE, sharp = TRUE, spread_damage = TRUE) //boggers, bogchamp, etc //why not just poggers

///Balloon Blower - Blows a balloon.
/obj/item/mod/module/balloon
	name = "MOD balloon blower module"
	desc = "A strange module invented years ago by some ingenious mimes. It blows balloons."
	icon_state = "bloon"
	module_type = MODULE_USABLE
	complexity = 1
	use_power_cost = DEFAULT_CHARGE_DRAIN * 0.5
	incompatible_modules = list(/obj/item/mod/module/balloon)
	cooldown_time = 15 SECONDS

/obj/item/mod/module/balloon/on_use()
	. = ..()
	if(!.)
		return
	if(!do_after(mod.wearer, 10 SECONDS, target = mod))
		return FALSE
	mod.wearer.adjustOxyLoss(20)
	playsound(src, 'sound/items/modsuit/inflate_bloon.ogg', 50, TRUE)
	var/obj/item/toy/balloon/balloon = new(get_turf(src))
	mod.wearer.put_in_hands(balloon)
	drain_power(use_power_cost)


///Stamper - Extends a stamp that can switch between accept/deny modes.
/obj/item/mod/module/stamp
	name = "MOD stamper module"
	desc = "A module installed into the wrist of the suit, this functions as a high-power stamp, \
		able to switch between accept and deny modes."
	icon_state = "stamp"
	module_type = MODULE_ACTIVE
	complexity = 1
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	device = /obj/item/stamp/mod
	incompatible_modules = list(/obj/item/mod/module/stamp)
	cooldown_time = 0.5 SECONDS

/obj/item/stamp/mod
	name = "MOD electronic stamp"
	desc = "A high-power stamp, able to switch between accept and deny mode when used."

/obj/item/stamp/mod/attack_self(mob/user, modifiers)
	. = ..()
	if(icon_state == "stamp-ok")
		icon_state = "stamp-deny"
	else
		icon_state = "stamp-ok"

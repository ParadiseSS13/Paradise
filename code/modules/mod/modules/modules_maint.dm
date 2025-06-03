//Maint modules for MODsuits

///Springlock Mechanism - allows your modsuit to activate faster, but reagents are very dangerous.
/obj/item/mod/module/springlock
	name = "MOD springlock module"
	desc = "A module that spans the entire size of the MOD unit, sitting under the outer shell. \
		This mechanical exoskeleton retracts to allow user entry and assists with booting up. \
		It was removed from modern suits due to the springlock's tendency to \"snap\" back \
		into place when exposed to specific chemical reactions, such as smoke from grenades. \
		Despite the mention of humidity in older designs, this module only reacts to smoke. \
		You know what it's like to have an entire exoskeleton snap into place around you?"
	icon_state = "springlock"
	complexity = 3 // it is inside every part of your suit, so
	incompatible_modules = list(/obj/item/mod/module/springlock)
	///How much faster will your suit deploy?
	var/activation_step_time_booster = 2
	///Is this the syndicate version, which can be toggled on multitool?
	var/nineteen_eighty_seven_edition = FALSE
	///If this is true, the suit will prevent you from retracting for 10 seconds, so an antag can smoke bomb you.
	var/dont_let_you_come_back = FALSE
	///If this is true, we are about to spring shut on someone, and should not remove the retraction blocking.
	var/incoming_jumpscare = FALSE

/obj/item/mod/module/springlock/on_install()
	mod.activation_step_time *= (1 / activation_step_time_booster)

/obj/item/mod/module/springlock/on_uninstall(deleting = FALSE)
	mod.activation_step_time *= activation_step_time_booster

/obj/item/mod/module/springlock/on_suit_activation()
	// only works with smoke
	RegisterSignal(mod.wearer, COMSIG_ATOM_EXPOSE_REAGENTS, PROC_REF(on_wearer_exposed))
	if(dont_let_you_come_back)
		RegisterSignal(mod, COMSIG_MOD_ACTIVATE, PROC_REF(on_activate_spring_block))
		addtimer(CALLBACK(src, PROC_REF(remove_retraction_block)), 10 SECONDS)

/obj/item/mod/module/springlock/on_suit_deactivation(deleting = FALSE)
	UnregisterSignal(mod.wearer, COMSIG_ATOM_EXPOSE_REAGENTS)

/obj/item/mod/module/springlock/multitool_act(mob/living/user, obj/item/I)
	if(!nineteen_eighty_seven_edition)
		return
	. = TRUE
	if(dont_let_you_come_back)
		to_chat(user, "<span class='notice'>You disable the retraction blocking systems.</span>")
		dont_let_you_come_back = FALSE
		return
	to_chat(user, "<span class='notice'>You enable the retraction blocking systems, which will block people from retracting the modsuit for 10 seconds.</span>")
	dont_let_you_come_back = TRUE


///Signal fired when wearer is exposed to reagents
/obj/item/mod/module/springlock/proc/on_wearer_exposed(atom/source, list/reagents, datum/reagents/source_reagents, methods, volume_modifier, show_message)
	SIGNAL_HANDLER
	remove_retraction_block() //No double signals
	to_chat(mod.wearer, "<span class='danger'>[src] makes an ominous click sound...</span>")
	incoming_jumpscare = TRUE
	playsound(src, 'sound/items/modsuit/springlock.ogg', 75, TRUE)
	addtimer(CALLBACK(src, PROC_REF(snap_shut)), rand(3 SECONDS, 5 SECONDS))
	RegisterSignal(mod, COMSIG_MOD_ACTIVATE, PROC_REF(on_activate_spring_block))

///Signal fired when wearer attempts to activate/deactivate suits
/obj/item/mod/module/springlock/proc/on_activate_spring_block(datum/source, user)
	SIGNAL_HANDLER

	to_chat(mod.wearer, "<span class='userdanger'>The springlocks aren't responding...?</span>")
	return MOD_CANCEL_ACTIVATE

///Removes the retraction blocker from the springlock so long as they are not about to be killed
/obj/item/mod/module/springlock/proc/remove_retraction_block()
	if(!incoming_jumpscare)
		UnregisterSignal(mod, COMSIG_MOD_ACTIVATE)

///Delayed death proc of the suit after the wearer is exposed to reagents
/obj/item/mod/module/springlock/proc/snap_shut()
	UnregisterSignal(mod, COMSIG_MOD_ACTIVATE)
	if(!mod.wearer) //while there is a guaranteed user when on_wearer_exposed() fires, that isn't the same case for this proc
		return
	mod.wearer.visible_message("<span class='danger'>[src] inside [mod.wearer]'s [mod.name] snaps shut, mutilating the user inside!</span>", "<span class='biggerdanger'><b>*SNAP*</b></span>")
	mod.wearer.emote("scream")
	playsound(mod.wearer, 'sound/effects/snap.ogg', 75, TRUE, frequency = 0.5)
	playsound(mod.wearer, 'sound/effects/splat.ogg', 50, TRUE, frequency = 0.5)
	mod.wearer.adjustBruteLoss(1987) //boggers, bogchamp, etc //why not just poggers, also this caps at 595 damage but comedy
	incoming_jumpscare = FALSE

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
	if(!do_after(mod.wearer, 10 SECONDS, target = mod.wearer))
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
	flags = NODROP

/obj/item/stamp/mod/attack_self__legacy__attackchain(mob/user, modifiers)
	. = ..()
	if(icon_state == "stamp-ok")
		icon_state = "stamp-deny"
	else
		icon_state = "stamp-ok"

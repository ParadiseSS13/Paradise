//Medical modules for MODsuits. Not much here, sorry.

///Injector - Gives the suit an extendable large-capacity piercing syringe.
/obj/item/mod/module/injector
	name = "MOD injector module"
	desc = "A module installed into the wrist of the suit, this functions as a high-capacity syringe, \
		with a tip fine enough to locate the emergency injection ports on any suit of armor, \
		penetrating it with ease. Even yours."
	icon_state = "injector"
	module_type = MODULE_ACTIVE
	complexity = 1
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	device = /obj/item/reagent_containers/syringe/mod
	incompatible_modules = list(/obj/item/mod/module/injector)
	cooldown_time = 0.5 SECONDS

/obj/item/reagent_containers/syringe/mod
	name = "MOD injector syringe"
	desc = "A high-capacity syringe, with a tip fine enough to locate \
		the emergency injection ports on any suit of armor, penetrating it with ease. Even yours."
	flags = NODROP
	amount_per_transfer_from_this = 30
	possible_transfer_amounts = list(5, 10, 15, 20, 30)
	volume = 30
	penetrates_thick = TRUE

///Defibrillator - Gives the suit an extendable pair of shock paddles.
/obj/item/mod/module/defibrillator
	name = "MOD defibrillator module"
	desc = "A module built into the gauntlets of the suit; commonly known as the 'Healing Hands' by medical professionals. \
		The user places their palms above the patient. Onboard computers in the suit calculate the necessary voltage, \
		and a modded targeting computer determines the best position for the user to push. \
		Twenty five pounds of force are applied to the patient's skin. Shocks travel from the suit's gloves \
		and counter-shock the heart, and the wearer returns to Medical a hero. Don't you even think about using it as a weapon; \
		regulations on manufacture and software locks expressly forbid it."
	icon_state = "defibrillator"
	module_type = MODULE_ACTIVE
	complexity = 2
	use_power_cost = DEFAULT_CHARGE_DRAIN * 200 // 1000 charge. Shocking, I know.
	device = /obj/item/mod_defib
	overlay_state_inactive = "module_defibrillator"
	overlay_state_active = "module_defibrillator_active"
	incompatible_modules = list(/obj/item/mod/module/defibrillator)
	cooldown_time = 0.5 SECONDS
	materials = list(MAT_METAL = 10000, MAT_GLASS = 4000, MAT_SILVER = 2000)

/obj/item/mod/module/defibrillator/Initialize(mapload)
	. = ..()
	RegisterSignal(device, COMSIG_DEFIB_SHOCK_APPLIED, PROC_REF(on_defib_success))

/obj/item/mod/module/defibrillator/proc/on_defib_success()
	SIGNAL_HANDLER  // COMSIG_DEFIB_SHOCK_APPLIED
	drain_power(use_power_cost)

/obj/item/mod_defib
	name = "defibrillator gauntlets"
	desc = "A pair of paddles with flat metal surfaces that are used to deliver powerful electric shocks."
	icon = 'icons/obj/defib.dmi'
	icon_state = "defibgauntlets0" //Inhands handled by the module overlays
	flags = NODROP
	w_class = WEIGHT_CLASS_BULKY
	var/defib_cooldown = 5 SECONDS
	var/safety = TRUE
	/// Whether or not the paddles are on cooldown. Used for tracking icon states.
	var/on_cooldown = FALSE


/obj/item/mod_defib/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/defib, cooldown = defib_cooldown, speed_multiplier = toolspeed, combat = !safety, heart_attack_chance = safety ? 0 : 100, robotic = TRUE, safe_by_default = safety, emp_proof = TRUE)

	RegisterSignal(src, COMSIG_DEFIB_READY, PROC_REF(on_cooldown_expire))
	RegisterSignal(src, COMSIG_DEFIB_SHOCK_APPLIED, PROC_REF(after_shock))

/obj/item/mod_defib/proc/after_shock(obj/item/defib, mob/user)
	SIGNAL_HANDLER  // COMSIG_DEFIB_SHOCK_APPLIED
	on_cooldown = TRUE
	update_icon(UPDATE_ICON_STATE)

/obj/item/mod_defib/proc/on_cooldown_expire(obj/item/defib)
	SIGNAL_HANDLER // COMSIG_DEFIB_READY
	on_cooldown = FALSE
	visible_message(SPAN_NOTICE("[src] beeps: Defibrillation unit ready."))
	playsound(get_turf(src), 'sound/machines/defib_ready.ogg', 50, FALSE)
	update_icon(UPDATE_ICON_STATE)

/obj/item/mod_defib/update_icon_state()
	icon_state = "[initial(icon_state)]"
	if(on_cooldown)
		icon_state = "[initial(icon_state)]_cooldown"

/obj/item/mod/module/defibrillator/combat
	name = "MOD combat defibrillator module"
	desc = "A module built into the gauntlets of the suit; commonly known as the 'Healing Hands' by medical professionals. \
		The user places their palms above the patient. Onboard computers in the suit calculate the necessary voltage, \
		and a modded targeting computer determines the best position for the user to push. \
		Twenty five pounds of force are applied to the patient's skin. Shocks travel from the suit's gloves \
		and counter-shock the heart, and the wearer returns to Medical a hero. \
		Interdyne Pharmaceutics marketed the domestic version of the Healing Hands as foolproof and unusable as a weapon. \
		But when it came time to provide their operatives with usable medical equipment, they didn't hesitate to remove \
		those in-built safeties. Operatives in the field can benefit from what they dub as 'Stun Gloves', able to apply shocks \
		straight to a victims heart to disable them, or maybe even outright stop their heart with enough power."
	complexity = 1
	use_power_cost = DEFAULT_CHARGE_DRAIN * 400 // 2000 charge. Since you like causing heart attacks, don't you?
	overlay_state_inactive = "module_defibrillator_combat"
	overlay_state_active = "module_defibrillator_combat_active"
	device = /obj/item/mod_defib/syndicate

/obj/item/mod_defib/syndicate
	name = "combat defibrillator gauntlets"
	icon_state = "syndiegauntlets0"
	safety = FALSE
	toolspeed = 2
	defib_cooldown = 2.5 SECONDS

/obj/item/mod/module/monitor
	name = "MOD crew monitor module"
	desc = "A module installed into the wrist of the suit, this presents a display of crew sensor data."
	icon_state = "monitor"
	module_type = MODULE_USABLE
	complexity = 1
	use_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/monitor)
	cooldown_time = 0.5 SECONDS
	allow_flags = MODULE_ALLOW_INACTIVE
	materials = list(MAT_METAL = 1500, MAT_GLASS = 3000)
	var/datum/ui_module/crew_monitor/mod/crew_monitor


/obj/item/mod/module/monitor/Initialize(mapload)
	. = ..()
	crew_monitor = new(src)

/obj/item/mod/module/monitor/on_use()
	crew_monitor.ui_interact(mod.wearer)

/// Health Analyzer - Gives the suit an extendable health analyzer, able to be upgraded
/obj/item/mod/module/analyzer
	name = "MOD health analyzer"
	desc = "A module installed into the palm of the suit, allows the deployment of a typical upgradable health analyzer."
	icon_state = "health"
	module_type = MODULE_ACTIVE
	complexity = 1
	active_power_cost = DEFAULT_CHARGE_DRAIN
	device = /obj/item/healthanalyzer/mod
	incompatible_modules = list(/obj/item/mod/module/analyzer)
	cooldown_time = 0.5 SECONDS
	materials = list(MAT_METAL = 4000, MAT_GLASS = 4000)

/obj/item/healthanalyzer/mod
	name = "MOD health analyzer"
	desc = "A integrated body scanner that allows the user to scan vital signs of a patient."
	flags = NODROP

/obj/item/mod/module/cbrn
	name = "CBRN Protection System"
	desc = "An active protection system that forms a complete biological shield around the wearer when active, \
		greatly limiting movement and spiking power usage to completely protect against chemical, biological, radiological, and nuclear hazards."
	icon_state = "cbrn"
	module_type = MODULE_TOGGLE
	complexity = 0
	cooldown_time = 0.5 SECONDS
	active_power_cost = DEFAULT_CHARGE_DRAIN * 6 // Eats power for its protection
	incompatible_modules = list(/obj/item/mod/module/cbrn)
	removable = FALSE // Exclusive to the CMO suit
	materials = list(MAT_METAL = 15000, MAT_TITANIUM = 5000, MAT_URANIUM = 5000)
	/// Speed lowered to the control unit.
	var/speed_lowered = 0.15
	/// Original armor of the suit, simpler solution to resolve subtracting infinities
	var/original_armor = null

/obj/item/mod/module/cbrn/on_activation()
	. = ..()
	if(!.)
		return
	playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	to_chat(mod.wearer, SPAN_NOTICE("Environmental protection enabled, biological shield raised, mobility decreased."))
	var/list/parts = mod.mod_parts + mod
	for(var/obj/item/part as anything in parts)
		original_armor = part.armor
		part.armor = part.armor.modifyRating(0, 0, 0, 0, 10, INFINITY, 0, INFINITY, 0) // due to infinities and non-zeros, attach and detach wont work, there is probably a much better solution
		part.slowdown += (speed_lowered)

/obj/item/mod/module/cbrn/on_deactivation(display_message = TRUE, deleting = FALSE)
	. = ..()
	if(!.)
		return
	if(!deleting)
		playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	to_chat(mod.wearer, SPAN_NOTICE("Environmental protection disabled, biological shield lowered, mobility increased."))
	var/list/parts = mod.mod_parts + mod
	for(var/obj/item/part as anything in parts)
		part.armor = original_armor
		part.slowdown -= (speed_lowered)


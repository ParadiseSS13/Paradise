//Antag modules for MODsuits

///Armor Booster - Grants your suit more armor and speed in exchange for EVA protection. Also acts as a welding screen.
/obj/item/mod/module/armor_booster
	name = "MOD armor booster module"
	desc = "A retrofitted series of retractable armor plates, allowing the suit to function as essentially power armor, \
		giving the user incredible protection against conventional firearms, or everyday attacks in close-quarters. \
		However, the additional plating cannot deploy alongside parts of the suit used for vacuum sealing, \
		so this extra armor provides zero ability for extravehicular activity while deployed."
	icon_state = "armor_booster"
	module_type = MODULE_TOGGLE
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	removable = FALSE
	incompatible_modules = list(/obj/item/mod/module/armor_booster, /obj/item/mod/module/welding)
	cooldown_time = 0.5 SECONDS
	overlay_state_inactive = "module_armorbooster_off"
	overlay_state_active = "module_armorbooster_on"
	use_mod_colors = TRUE
	/// Whether or not this module removes pressure protection.
	var/remove_pressure_protection = TRUE
	/// Speed added to the control unit.
	var/speed_added = 0.5
	/// Speed that we actually added.
	var/actual_speed_added = 0
	/// Armor values added to the suit parts.
	var/armor_mod_1 = /obj/item/mod/armor/mod_module_armor_boost
	/// the actual armor object
	var/obj/item/mod/armor/armor_mod_2 = null
	/// List of parts of the suit that are spaceproofed, for giving them back the pressure protection.
	var/list/spaceproofed = list()

/obj/item/mod/module/armor_booster/Initialize(mapload)
	. = ..()
	armor_mod_2 = new armor_mod_1

/obj/item/mod/module/armor_booster/Destroy()
	QDEL_NULL(armor_mod_2)
	return ..()

/obj/item/mod/armor/mod_module_armor_boost
	armor = list(MELEE = 25, BULLET = 30, LASER = 15, ENERGY = 15, BOMB = 0, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/mod/module/armor_booster/on_suit_activation()
	mod.helmet.flash_protect = FLASH_PROTECTION_WELDER

/obj/item/mod/module/armor_booster/on_suit_deactivation(deleting = FALSE)
	if(deleting)
		return
	mod.helmet.flash_protect = initial(mod.helmet.flash_protect)

/obj/item/mod/module/armor_booster/on_activation()
	. = ..()
	if(!.)
		return
	playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	to_chat(mod.wearer, "<span class='notice'>Armor deployed, EVA disabled, speed increased.</span>")
	actual_speed_added = max(0, min(mod.slowdown_active, speed_added / 5))
	var/list/parts = mod.mod_parts + mod
	for(var/obj/item/part as anything in parts)
		part.armor = part.armor.attachArmor(armor_mod_2.armor)
		part.slowdown -= actual_speed_added
		if(!remove_pressure_protection || !isclothing(part))
			continue
		var/obj/item/clothing/clothing_part = part
		if(clothing_part.flags & STOPSPRESSUREDMAGE)
			clothing_part.flags &= ~STOPSPRESSUREDMAGE
			spaceproofed[clothing_part] = TRUE

/obj/item/mod/module/armor_booster/on_deactivation(display_message = TRUE, deleting = FALSE)
	. = ..()
	if(!.)
		return
	if(!deleting)
		playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	to_chat(mod.wearer, "<span class='notice'>Armor retracted, EVA enabled, speed decreased.</span>")
	var/list/parts = mod.mod_parts + mod
	for(var/obj/item/part as anything in parts)
		part.armor = part.armor.detachArmor(armor_mod_2.armor)
		part.slowdown += actual_speed_added
		if(!remove_pressure_protection || !isclothing(part))
			continue
		var/obj/item/clothing/clothing_part = part
		if(spaceproofed[clothing_part])
			clothing_part.flags |= STOPSPRESSUREDMAGE
	spaceproofed = list()

/obj/item/mod/module/armor_booster/generate_worn_overlay(user, mutable_appearance/standing)
	overlay_state_inactive = "[initial(overlay_state_inactive)]-[mod.skin]"
	overlay_state_active = "[initial(overlay_state_active)]-[mod.skin]"
	return ..()

///Insignia - Gives you a skin specific stripe.
/obj/item/mod/module/insignia
	name = "MOD insignia module"
	desc = "Despite the existence of IFF systems, radio communique, and modern methods of deductive reasoning involving \
		the wearer's own eyes, colorful paint jobs remain a popular way for different factions in the galaxy to display who \
		they are. This system utilizes a series of tiny moving paint sprayers to both apply and remove different \
		color patterns to and from the suit."
	icon_state = "insignia"
	removable = FALSE
	incompatible_modules = list(/obj/item/mod/module/insignia)
	overlay_state_inactive = "module_insignia"

/obj/item/mod/module/insignia/generate_worn_overlay(user, mutable_appearance/standing)
	overlay_state_inactive = "[initial(overlay_state_inactive)]-[mod.skin]"
	. = ..()
	for(var/mutable_appearance/appearance as anything in .)
		appearance.color = color

/obj/item/mod/module/insignia/commander
	color = "#4980a5"

/obj/item/mod/module/insignia/security
	color = "#b30d1e"

/obj/item/mod/module/insignia/engineer
	color = "#e9c80e"

/obj/item/mod/module/insignia/medic
	color = "#ebebf5"

/obj/item/mod/module/insignia/janitor
	color = "#7925c7"

/obj/item/mod/module/insignia/clown
	color = "#ff1fc7"

/obj/item/mod/module/insignia/chaplain
	color = "#f0a00c"

///Anti Slip - Prevents you from slipping on water.
/obj/item/mod/module/noslip
	name = "MOD anti slip module"
	desc = "These are a modified variant of standard magnetic boots, utilizing piezoelectric crystals on the soles. \
		The two plates on the bottom of the boots automatically extend and magnetize as the user steps; \
		a pull that's too weak to offer them the ability to affix to a hull, but just strong enough to \
		protect against the fact that you didn't read the wet floor sign. Honk Co. has come out numerous times \
		in protest of these modules being legal."
	icon_state = "noslip"
	complexity = 1
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.1
	incompatible_modules = list(/obj/item/mod/module/noslip)
	origin_tech = "syndicate=1"

/obj/item/mod/module/noslip/on_suit_activation()
	ADD_TRAIT(mod.wearer, TRAIT_NOSLIP, UID())

/obj/item/mod/module/noslip/on_suit_deactivation(deleting = FALSE)
	REMOVE_TRAIT(mod.wearer, TRAIT_NOSLIP, UID())

//Bite of 87 Springlock - Equips faster, disguised as DNA lock, can block retracting for 10 seconds.
/obj/item/mod/module/springlock/bite_of_87
	activation_step_time_booster = 10
	nineteen_eighty_seven_edition = TRUE
	dont_let_you_come_back = TRUE

/obj/item/mod/module/springlock/bite_of_87/Initialize(mapload)
	. = ..()
	var/obj/item/mod/module/dna_lock/the_dna_lock_behind_the_slaughter = /obj/item/mod/module/dna_lock
	name = initial(the_dna_lock_behind_the_slaughter.name)
	desc = initial(the_dna_lock_behind_the_slaughter.desc)
	icon_state = initial(the_dna_lock_behind_the_slaughter.icon_state)
	complexity = initial(the_dna_lock_behind_the_slaughter.complexity)
	use_power_cost = initial(the_dna_lock_behind_the_slaughter.use_power_cost)

/obj/item/mod/module/holster/hidden/Initialize(mapload)
	. = ..()
	var/obj/item/mod/module/tether/fake = /obj/item/mod/module/tether
	name = initial(fake.name)
	desc = initial(fake.desc)
	icon_state = initial(fake.icon_state)
	complexity = initial(fake.complexity) //This is 1 less complex than a holster, but that is fine tbh, paying tc for it.
	use_power_cost = initial(fake.use_power_cost)

///Power kick - Lets the user launch themselves at someone to kick them.
/obj/item/mod/module/power_kick
	name = "MOD power kick module"
	desc = "This module uses high-power myomer to generate an incredible amount of energy, transferred into the power of a kick."
	icon_state = "power_kick"
	module_type = MODULE_ACTIVE
	removable = FALSE
	use_power_cost = DEFAULT_CHARGE_DRAIN * 5
	incompatible_modules = list(/obj/item/mod/module/power_kick)
	cooldown_time = 5 SECONDS
	/// Damage on kick.
	var/damage = 20
	/// How long we knockdown for on the kick.
	var/knockdown_time = 6 SECONDS

/obj/item/mod/module/power_kick/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(mod.wearer.buckled)
		return
	mod.wearer.visible_message("<span class='warning'>[mod.wearer] starts charging a kick!</span>")
	playsound(src, 'sound/items/modsuit/loader_charge.ogg', 75, TRUE)
	animate(mod.wearer, 0.3 SECONDS, pixel_z = 16, flags = ANIMATION_RELATIVE, easing = SINE_EASING|EASE_OUT)
	addtimer(CALLBACK(mod.wearer, TYPE_PROC_REF(/atom, SpinAnimation), 3, 2), 0.3 SECONDS)
	if(!do_after(mod.wearer, 1 SECONDS, target = mod.wearer))
		animate(mod.wearer, 0.2 SECONDS, pixel_z = -16, flags = ANIMATION_RELATIVE, easing = SINE_EASING|EASE_IN)
		return
	animate(mod.wearer)
	drain_power(use_power_cost)
	playsound(src, 'sound/items/modsuit/loader_launch.ogg', 75, TRUE)
	var/angle = get_angle(mod.wearer, target) + 180
	mod.wearer.transform = mod.wearer.transform.Turn(angle)
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_IMPACT, PROC_REF(on_throw_impact))
	mod.wearer.apply_status_effect(STATUS_EFFECT_IMPACT_IMMUNE)
	mod.wearer.throw_at(target, range = 7, speed = 2, thrower = mod.wearer, spin = FALSE, callback = CALLBACK(src, PROC_REF(on_throw_end), mod.wearer, -angle))

/obj/item/mod/module/power_kick/proc/on_throw_end(mob/living/user, angle)
	if(!user)
		return
	user.transform = user.transform.Turn(angle)
	animate(user, 0.2 SECONDS, pixel_z = -16, flags = ANIMATION_RELATIVE, easing = SINE_EASING|EASE_IN)
	user.remove_status_effect((STATUS_EFFECT_IMPACT_IMMUNE))

/obj/item/mod/module/power_kick/proc/on_throw_impact(mob/living/source, atom/target, datum/thrownthing/thrownthing)
	SIGNAL_HANDLER

	UnregisterSignal(source, COMSIG_MOVABLE_IMPACT)
	if(!mod?.wearer)
		return
	if(isliving(target))
		var/mob/living/living_target = target
		living_target.apply_damage(damage, BRUTE, mod.wearer.zone_selected)
		add_attack_logs(mod.wearer, target, "[target] was charged by [mod.wearer]'s [src]", ATKLOG_ALMOSTALL)
		living_target.KnockDown(knockdown_time)
		mod.wearer.visible_message("<span class='danger'>[mod.wearer] crashes into [target], knocking them over!</span>", "<span class='userdanger'>You violently crash into [target]!</span>")
	else
		return
	mod.wearer.do_attack_animation(target, ATTACK_EFFECT_SMASH)

///Plate Compression - Compresses the suit to normal size
/obj/item/mod/module/plate_compression
	name = "MOD plate compression module"
	desc = "A module that keeps the suit in a very tightly fit state, lowering the overall size. \
		Due to the pressure on all the parts, typical storage modules do not fit."
	icon_state = "plate_compression"
	complexity = 2
	incompatible_modules = list(/obj/item/mod/module/plate_compression, /obj/item/mod/module/storage)
	/// The size we set the suit to.
	var/new_size = WEIGHT_CLASS_NORMAL
	/// The suit's size before the module is installed.
	var/old_size
	origin_tech = "materials=6;bluespace=5;syndicate=1" //Printable at illegals 2, so only one level.

/obj/item/mod/module/plate_compression/on_install()
	old_size = mod.w_class
	mod.w_class = new_size

/obj/item/mod/module/plate_compression/on_uninstall(deleting = FALSE)
	mod.w_class = old_size
	old_size = null
	if(!mod.loc)
		return
	mod.forceMove(drop_location())


//Ninja modules for MODsuits

///Cloaking - Lowers the user's visibility, can be interrupted by being touched or attacked.
/obj/item/mod/module/stealth
	name = "MOD prototype cloaking module"
	desc = "A complete retrofitting of the suit, this is a form of visual concealment tech employing esoteric technology \
		to bend light around the user, as well as mimetic materials to make the surface of the suit match the \
		surroundings based off sensor data. For some reason, this tech is rarely seen."
	icon_state = "cloak"
	module_type = MODULE_TOGGLE
	complexity = 4
	active_power_cost = DEFAULT_CHARGE_DRAIN * 2
	use_power_cost = DEFAULT_CHARGE_DRAIN * 10
	incompatible_modules = list(/obj/item/mod/module/stealth)
	cooldown_time = 10 SECONDS
	origin_tech = "combat=6;materials=6;powerstorage=5;bluespace=5;syndicate=2" //Printable at 3
	/// Whether or not the cloak turns off on bumping.
	var/bumpoff = TRUE
	/// The alpha applied when the cloak is on.
	var/stealth_alpha = 50

/obj/item/mod/module/stealth/on_activation()
	. = ..()
	if(!.)
		return
	if(bumpoff)
		RegisterSignal(mod.wearer, COMSIG_LIVING_MOB_BUMP, PROC_REF(unstealth))
	RegisterSignal(mod.wearer, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, PROC_REF(on_unarmed_attack))
	RegisterSignal(mod.wearer, COMSIG_ATOM_BULLET_ACT, PROC_REF(on_bullet_act))
	RegisterSignals(mod.wearer, list(COMSIG_MOB_ITEM_ATTACK, COMSIG_ATTACK_BY, COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_HITBY, COMSIG_ATOM_HULK_ATTACK, COMSIG_ATOM_ATTACK_PAW), PROC_REF(unstealth))
	mod.wearer.set_alpha_tracking(stealth_alpha, src, update_alpha = FALSE)
	animate(mod.wearer, alpha = mod.wearer.get_alpha(), time = 1.5 SECONDS)
	drain_power(use_power_cost)

/obj/item/mod/module/stealth/on_deactivation(display_message = TRUE, deleting = FALSE)
	. = ..()
	if(!.)
		return
	if(bumpoff)
		UnregisterSignal(mod.wearer, COMSIG_LIVING_MOB_BUMP)
	UnregisterSignal(mod.wearer, list(COMSIG_HUMAN_MELEE_UNARMED_ATTACK, COMSIG_MOB_ITEM_ATTACK, COMSIG_ATTACK_BY, COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_BULLET_ACT, COMSIG_ATOM_HITBY, COMSIG_ATOM_HULK_ATTACK, COMSIG_ATOM_ATTACK_PAW))
	mod.wearer.set_alpha_tracking(ALPHA_VISIBLE, src, update_alpha = FALSE)
	animate(mod.wearer, alpha = mod.wearer.get_alpha(), time = 1.5 SECONDS)

/obj/item/mod/module/stealth/proc/unstealth(datum/source)
	SIGNAL_HANDLER

	to_chat(mod.wearer, "<span class='warning'>[src] gets discharged from contact!</span>")
	do_sparks(2, TRUE, src)
	drain_power(use_power_cost)
	COOLDOWN_START(src, cooldown_timer, cooldown_time) //Put it on cooldown.
	on_deactivation(display_message = TRUE, deleting = FALSE)

/obj/item/mod/module/stealth/proc/on_unarmed_attack(datum/source, atom/target)
	SIGNAL_HANDLER

	if(!isliving(target))
		return
	unstealth(source)

/obj/item/mod/module/stealth/proc/on_bullet_act(datum/source, obj/item/projectile)
	SIGNAL_HANDLER
	unstealth(source)

//Advanced Cloaking - Doesn't turf off on bump, less power drain, more stealthy.
/obj/item/mod/module/stealth/ninja
	name = "MOD advanced cloaking module"
	desc = "The latest in stealth technology, this module is a definite upgrade over previous versions. \
		The field has been tuned to be even more responsive and fast-acting, with enough stability to \
		continue operation of the field even if the user bumps into others. \
		The power draw has been reduced drastically, making this perfect for activities like \
		standing near sentry turrets for extended periods of time."
	icon_state = "cloak_ninja"
	bumpoff = FALSE
	stealth_alpha = 10
	active_power_cost = DEFAULT_CHARGE_DRAIN
	use_power_cost = DEFAULT_CHARGE_DRAIN * 5
	cooldown_time = 3 SECONDS
	origin_tech = "combat=6;materials=6;powerstorage=6;bluespace=6;syndicate=4"

///Status Readout - Puts a lot of information including health, nutrition, fingerprints, temperature to the suit TGUI.
/obj/item/mod/module/status_readout
	name = "MOD status readout module"
	desc = "A once-common module, this technology went unfortunately out of fashion; \
		and right into the arachnid grip of the Spider Clan. This hooks into the suit's spine, \
		capable of capturing and displaying all possible biometric data of the wearer; sleep, nutrition, fitness, fingerprints, \
		and even useful information such as their overall health and wellness. \
		The syndicate has been seen using this module of late, with NT as well getting into the technology on their elitest of suits."
	icon_state = "status"
	complexity = 1
	use_power_cost = DEFAULT_CHARGE_DRAIN * 0.1
	incompatible_modules = list(/obj/item/mod/module/status_readout)
	tgui_id = "status_readout"
	origin_tech = "combat=6;biotech=6;syndicate=1"

/obj/item/mod/module/status_readout/add_ui_data()
	. = ..()
	.["statustime"] = station_time_timestamp()
	.["statusid"] = GLOB.round_id
	.["statushealth"] = mod.wearer?.health || 0
	.["statusmaxhealth"] = mod.wearer?.getMaxHealth() || 0
	.["statusbrute"] = mod.wearer?.getBruteLoss() || 0
	.["statusburn"] = mod.wearer?.getFireLoss() || 0
	.["statustoxin"] = mod.wearer?.getToxLoss() || 0
	.["statusoxy"] = mod.wearer?.getOxyLoss() || 0
	.["statustemp"] = mod.wearer?.bodytemperature || 0
	.["statusnutrition"] = mod.wearer?.nutrition || 0
	.["statusfingerprints"] = mod.wearer ? md5(mod.wearer.dna.unique_enzymes) : null
	.["statusdna"] = mod.wearer?.dna.unique_enzymes
	.["statusviruses"] = null
	if(!length(mod.wearer?.viruses))
		return
	var/list/viruses = list()
	for(var/datum/disease/virus as anything in mod.wearer.viruses)
		var/list/virus_data = list()
		virus_data["name"] = virus.name
		virus_data["type"] = virus.spread_text
		virus_data["stage"] = virus.stage
		virus_data["maxstage"] = virus.max_stages
		virus_data["cure"] = virus.cure_text
		viruses += list(virus_data)
	.["statusviruses"] = viruses

///Camera Module - Puts a camera in the modsuit that the ERT commander can see
/obj/item/mod/module/ert_camera
	name = "MOD camera module"
	desc = "This combination camera and broadcasting module grants the modsuit a camera that tracks what the user see, and sends it to the nearest station and \
	CC blackbox. This is used for ERT commander tracking, performance review, Nanotrasen's Funniest Home Videos, \
	and used for reference for their Deathsquad Cartoon Series."
	icon_state = "eradicationlock" //looks like a bluespace transmitter or something, probably could use an actual camera look.
	complexity = 1
	incompatible_modules = list(/obj/item/mod/module/ert_camera)
	removable = FALSE
	var/obj/machinery/camera/portable/camera

/obj/item/mod/module/ert_camera/on_suit_activation()
	if(ishuman(mod.wearer))
		register_camera(mod.wearer)

/obj/item/mod/module/ert_camera/proc/register_camera(mob/wearer)
	if(camera)
		return
	camera = new /obj/machinery/camera/portable(src, FALSE)
	camera.network = list("ERT")
	camera.c_tag = wearer.name
	to_chat(wearer, "<span class='notice'>User scanned as [camera.c_tag]. Camera activated.</span>")

/obj/item/mod/module/ert_camera/Destroy()
	QDEL_NULL(camera)
	return ..()

/obj/item/mod/module/ert_camera/on_suit_deactivation(deleting = FALSE)
	QDEL_NULL(camera)

///Chameleon - lets the suit disguise as any item that would fit on that slot.
/obj/item/mod/module/chameleon
	name = "MOD chameleon module"
	desc = "A module using chameleon technology to disguise the suit as another object."
	icon_state = "chameleon"
	module_type = MODULE_USABLE
	complexity = 2
	incompatible_modules = list(/obj/item/mod/module/chameleon)
	cooldown_time = 0.5 SECONDS
	allow_flags = MODULE_ALLOW_INACTIVE
	origin_tech = "materials=6;bluespace=5;syndicate=1"

/obj/item/mod/module/chameleon/on_install()
	mod.chameleon_action = new(mod)
	mod.chameleon_action.chameleon_type = /obj/item/storage/backpack
	mod.chameleon_action.chameleon_name = "Backpack"
	mod.chameleon_action.initialize_disguises()


/obj/item/mod/module/chameleon/on_uninstall(deleting = FALSE)
	if(mod.current_disguise)
		return_look()
	QDEL_NULL(mod.chameleon_action)

/obj/item/mod/module/chameleon/on_use()
	if(mod.active || mod.activating)
		to_chat(mod.wearer, "<span class='warning'>Your suit is already active!</span>")
		return
	. = ..()
	if(!.)
		return
	if(mod.current_disguise)
		return_look()
		return
	mod.chameleon_action.select_look(mod.wearer)
	mod.current_disguise = TRUE
	RegisterSignal(mod, COMSIG_MOD_ACTIVATE, PROC_REF(return_look))

/obj/item/mod/module/chameleon/proc/return_look()
	mod.current_disguise = FALSE
	mod.name = "[mod.theme.name] [initial(mod.name)]"
	mod.desc = "[initial(mod.desc)] [mod.theme.desc]"
	mod.icon_state = "[mod.skin]-control"
	var/list/mod_skin = mod.theme.skins[mod.skin]
	mod.icon = mod_skin[MOD_ICON_OVERRIDE] || 'icons/obj/clothing/modsuit/mod_clothing.dmi'
	mod.worn_icon = mod_skin[MOD_ICON_OVERRIDE] || 'icons/mob/clothing/modsuit/mod_clothing.dmi'
	mod.lefthand_file = initial(mod.lefthand_file)
	mod.righthand_file = initial(mod.righthand_file)
	mod.wearer.update_inv_back()
	UnregisterSignal(mod, COMSIG_MOD_ACTIVATE)

///Energy Shield - Gives you a rechargeable energy shield that nullifies attacks.
/obj/item/mod/module/energy_shield
	name = "MOD energy shield module"
	desc = "A personal, protective forcefield typically seen in military applications. \
		This advanced deflector shield is essentially a scaled down version of those seen on starships, \
		and the power cost can be an easy indicator of this. However, it is capable of blocking nearly any incoming attack, \
		though with its' low amount of separate charges, the user remains mortal."
	icon_state = "energy_shield"
	complexity = 3
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.5
	use_power_cost = DEFAULT_CHARGE_DRAIN * 2
	incompatible_modules = list(/obj/item/mod/module/energy_shield)
	/// Max charges of the shield.
	var/max_charges = 3
	/// The time it takes for the first charge to recover.
	var/recharge_start_delay = 20 SECONDS
	/// How much time it takes for charges to recover after they started recharging.
	var/charge_increment_delay = 1 SECONDS
	/// How much charge is recovered per recovery.
	var/charge_recovery = 1
	/// Whether or not this shield can lose multiple charges.
	var/lose_multiple_charges = FALSE
	/// The item path to recharge this shield.
	var/recharge_path = null
	/// The icon file of the shield.
	var/shield_icon_file = 'icons/effects/effects.dmi'
	/// The icon_state of the shield.
	var/shield_icon = "shield-red"
	/// Charges the shield should start with.
	var/charges

/obj/item/mod/module/energy_shield/Initialize(mapload)
	. = ..()
	charges = max_charges

/obj/item/mod/module/energy_shield/on_suit_activation()
	mod.AddComponent(/datum/component/shielded, max_charges = max_charges, recharge_start_delay = recharge_start_delay, charge_increment_delay = charge_increment_delay, \
	charge_recovery = charge_recovery, lose_multiple_charges = lose_multiple_charges, recharge_path = recharge_path, starting_charges = charges, shield_icon_file = shield_icon_file, shield_icon = shield_icon)
	RegisterSignal(mod.wearer, COMSIG_HUMAN_CHECK_SHIELDS, PROC_REF(shield_reaction))

/obj/item/mod/module/energy_shield/on_suit_deactivation(deleting = FALSE)
	var/datum/component/shielded/shield = mod.GetComponent(/datum/component/shielded)
	charges = shield.current_charges
	shield.RemoveComponent()
	UnregisterSignal(mod.wearer, COMSIG_HUMAN_CHECK_SHIELDS)

/obj/item/mod/module/energy_shield/proc/shield_reaction(mob/living/carbon/human/owner,
	atom/movable/hitby,
	attack_text = "the attack",
	final_block_chance = 0,
	damage = 0,
	attack_type = MELEE_ATTACK,
	damage_type = BRUTE
)
	SIGNAL_HANDLER

	if(SEND_SIGNAL(mod, COMSIG_ITEM_HIT_REACT, owner, hitby, damage, attack_type) & COMPONENT_BLOCK_SUCCESSFUL)
		drain_power(use_power_cost)
		return SHIELD_BLOCK
	return NONE

/obj/item/mod/module/energy_shield/gamma
	shield_icon = "shield-old"

///Magic Nullifier - Protects you from magic.
/obj/item/mod/module/anti_magic
	name = "MOD magic nullifier module"
	desc = "A series of obsidian rods installed into critical points around the suit, \
		vibrated at a certain low frequency to enable them to resonate. \
		This creates a low-range, yet strong, magic nullification field around the user, \
		aided by a full replacement of the suit's normal coolant with holy water. \
		Spells will spall right off this field, though it'll do nothing to help others believe you about all this."
	icon_state = "magic_nullifier"
	removable = FALSE
	incompatible_modules = list(/obj/item/mod/module/anti_magic)

/obj/item/mod/module/anti_magic/on_suit_activation()
	ADD_TRAIT(mod.wearer, TRAIT_ANTIMAGIC, "[UID()]")

/obj/item/mod/module/anti_magic/on_suit_deactivation(deleting = FALSE)
	REMOVE_TRAIT(mod.wearer, TRAIT_ANTIMAGIC, "[UID()]")

/obj/item/mod/module/anomaly_locked/teslawall
	name = "MOD arc-shield module" // temp
	desc = "A module that uses a flux core to project an unstable protective shield." //change
	icon_state = "tesla"
	complexity = 3
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 3
	use_power_cost = DEFAULT_CHARGE_DRAIN * 75
	accepted_anomalies = list(/obj/item/assembly/signaler/anomaly/flux)
	incompatible_modules = list(/obj/item/mod/module/energy_shield, /obj/item/mod/module/anomaly_locked)
	///Copy paste of shielded code wheeeey
	/// Max charges of the shield.
	var/max_charges = 80 // Less charges because not gamma / this one is real shocking
	/// The time it takes for the first charge to recover.
	var/recharge_start_delay = 10 SECONDS
	/// How much time it takes for charges to recover after they started recharging.
	var/charge_increment_delay = 10 SECONDS
	/// How much charge is recovered per recovery.
	var/charge_recovery = 20
	/// Whether or not this shield can lose multiple charges.
	var/lose_multiple_charges = TRUE
	/// The item path to recharge this shield.
	var/recharge_path = null
	/// The icon file of the shield.
	var/shield_icon_file = 'icons/effects/effects.dmi'
	/// The icon_state of the shield.
	var/shield_icon = "electricity3"
	/// Charges the shield should start with.
	var/charges

	/// Teslawall specific variables.
	var/zap_flags = ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE
	var/zap_range = 5
	var/power = 12500
	var/shock_damage = 30

/obj/item/mod/module/anomaly_locked/teslawall/Initialize(mapload)
	. = ..()
	charges = max_charges

/obj/item/mod/module/anomaly_locked/teslawall/on_suit_activation()
	. = ..()
	if(!core)
		return FALSE
	mod.AddComponent(/datum/component/shielded, max_charges = max_charges, recharge_start_delay = recharge_start_delay, charge_increment_delay = charge_increment_delay, \
	charge_recovery = charge_recovery, lose_multiple_charges = lose_multiple_charges, show_charge_as_alpha = lose_multiple_charges, recharge_path = recharge_path, starting_charges = charges, shield_icon_file = shield_icon_file, shield_icon = shield_icon)
	RegisterSignal(mod.wearer, COMSIG_HUMAN_CHECK_SHIELDS, PROC_REF(shield_reaction))
	ADD_TRAIT(mod.wearer, TRAIT_SHOCKIMMUNE, UNIQUE_TRAIT_SOURCE(src))

/obj/item/mod/module/anomaly_locked/teslawall/on_suit_deactivation(deleting = FALSE)
	. = ..()
	if(!core)
		return FALSE
	var/datum/component/shielded/shield = mod.GetComponent(/datum/component/shielded)
	charges = shield.current_charges
	shield.RemoveComponent()
	UnregisterSignal(mod.wearer, COMSIG_HUMAN_CHECK_SHIELDS)
	REMOVE_TRAIT(mod.wearer, TRAIT_SHOCKIMMUNE, UNIQUE_TRAIT_SOURCE(src))

/obj/item/mod/module/anomaly_locked/teslawall/proc/shield_reaction(mob/living/carbon/human/owner,
	atom/movable/hitby,
	attack_text = "the attack",
	final_block_chance = 0,
	damage = 0,
	attack_type = MELEE_ATTACK,
	damage_type = BRUTE
)
	SIGNAL_HANDLER

	if(SEND_SIGNAL(mod, COMSIG_ITEM_HIT_REACT, owner, hitby, damage, attack_type) & COMPONENT_BLOCK_SUCCESSFUL)
		drain_power(use_power_cost)
		arc_flash(owner, hitby, damage, attack_type)
		return SHIELD_BLOCK
	return NONE

/obj/item/mod/module/anomaly_locked/teslawall/proc/arc_flash(mob/owner, atom/movable/hitby, damage, attack_type)
	if((attack_type == PROJECTILE_ATTACK || attack_type == THROWN_PROJECTILE_ATTACK) && prob(33))
		tesla_zap(owner, zap_range, power, zap_flags)
		return
	if(isitem(hitby))
		if(isliving(hitby.loc))
			var/mob/living/M = hitby.loc
			M.electrocute_act(shock_damage, owner, flags = SHOCK_NOGLOVES)
			M.KnockDown(3 SECONDS)
	else if(isliving(hitby))
		var/mob/living/M = hitby
		M.electrocute_act(shock_damage, owner, flags = SHOCK_NOGLOVES)
		M.KnockDown(3 SECONDS)

/obj/item/mod/module/anomaly_locked/teslawall/prebuilt
	prebuilt = TRUE
	removable = FALSE // No switching it into another suit / no free anomaly core

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
	RegisterSignals(mod.wearer, list(COMSIG_MOB_ITEM_ATTACK, COMSIG_PARENT_ATTACKBY, COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_HITBY, COMSIG_ATOM_HULK_ATTACK, COMSIG_ATOM_ATTACK_PAW), PROC_REF(unstealth))
	animate(mod.wearer, alpha = stealth_alpha, time = 1.5 SECONDS)
	drain_power(use_power_cost)

/obj/item/mod/module/stealth/on_deactivation(display_message = TRUE, deleting = FALSE)
	. = ..()
	if(!.)
		return
	if(bumpoff)
		UnregisterSignal(mod.wearer, COMSIG_LIVING_MOB_BUMP)
	UnregisterSignal(mod.wearer, list(COMSIG_HUMAN_MELEE_UNARMED_ATTACK, COMSIG_MOB_ITEM_ATTACK, COMSIG_PARENT_ATTACKBY, COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_BULLET_ACT, COMSIG_ATOM_HITBY, COMSIG_ATOM_HULK_ATTACK, COMSIG_ATOM_ATTACK_PAW))
	animate(mod.wearer, alpha = 255, time = 1.5 SECONDS)

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
	cooldown_time = 5 SECONDS
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

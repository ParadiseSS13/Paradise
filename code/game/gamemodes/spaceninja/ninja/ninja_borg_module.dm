/*
 * Наследуем от саботажника, чтобы иметь возможность легко интегрировать этому боргу свой хамелион проектор
 */
/mob/living/silicon/robot/syndicate/saboteur/ninja
	base_icon = "ninja"
	icon_state = "ninja"
	lawupdate = 0
	scrambledcodes = 1
	has_camera = FALSE
	pdahide = 1
	faction = list(ROLE_NINJA)
	bubble_icon = "syndibot"
	designation = "Spider Clan"
	modtype = "Spider Clan"
	req_access = list(ACCESS_SYNDICATE)
	ionpulse = 1
	damage_protection = 5
	brute_mod = 0.7 //30% less damage
	burn_mod = 0.7
	can_lock_cover = TRUE
	lawchannel = "State"
	drain_act_protected = TRUE
	playstyle_string = null
	has_transform_animation = FALSE

/mob/living/silicon/robot/syndicate/saboteur/ninja/init(alien = FALSE, mob/living/silicon/ai/ai_to_sync_to = null)
	. = ..()
	laws = new /datum/ai_laws/ninja_override(src)
	QDEL_NULL(module)	//Удаление модуля саботёра который мы наследуем
	module = new /obj/item/robot_module/ninja(src)
	aiCamera = new/obj/item/camera/siliconcam/robot_camera(src)
	radio = new /obj/item/radio/borg/ninja(src)
	radio.recalculateChannels()
	//languages
	module.add_languages(src)
	//subsystems
	module.add_subsystems_and_actions(src)

/obj/item/radio/borg/ninja
	keyslot = new /obj/item/encryptionkey/spider_clan
	freqlock = FALSE
	freerange = TRUE

/obj/item/radio/borg/ninja/Initialize()
	. = ..()
	set_frequency(NINJA_FREQ)

/obj/item/gun/energy/shuriken_emitter/borg
	name = "robotic shuriken emitter"
	desc = "A device sneakily hidden inside your robotic hand. Shoots 3 energy shurikens that slows and temporary blinds their targets"
	ammo_type = list(/obj/item/ammo_casing/energy/shuriken/borg)
	// Эти два значения не нужны боргам - они не носят ниндзя костюм
	cost = null
	my_suit = null

/obj/item/gun/energy/shuriken_emitter/borg/equip_to_best_slot(mob/M)
	return

/obj/item/gun/energy/shuriken_emitter/borg/can_shoot()
	return TRUE

/obj/item/ammo_casing/energy/shuriken/borg
	projectile_type = /obj/item/projectile/beam/shuriken
	muzzle_flash_color = LIGHT_COLOR_GREEN
	select_name  = "shuriken"
	e_cost = 50
	fire_sound = 'sound/weapons/bulletflyby.ogg'
	click_cooldown_override = 2
	harmful = FALSE
	delay = 3

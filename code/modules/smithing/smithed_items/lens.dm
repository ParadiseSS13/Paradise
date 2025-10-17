/obj/item/smithed_item/lens
	name = "Debug lens"
	icon_state = "lens"
	desc = "Debug lens. If you see this, notify the development team."
	/// Base laser speed multiplier
	var/base_laser_speed_mult = 0
	/// Base power draw multiplier
	var/base_power_mult = 0
	/// Base damage multiplier
	var/base_damage_mult = 0
	/// Base fire rate multiplier
	var/base_fire_rate_mult = 0
	/// Laser speed multiplier after construction
	var/laser_speed_mult = 1
	/// Power draw multiplier after construction
	var/power_mult = 1
	/// Damage multiplier after construction
	var/damage_mult = 1
	/// Fire rate multiplier after construction
	var/fire_rate_mult = 1
	/// lens durability
	var/durability = 40
	/// Max durability
	var/max_durability = 40
	/// The weapon the lens is attached to
	var/obj/item/gun/energy/attached_gun

/obj/item/smithed_item/lens/set_stats()
	..()
	durability = initial(durability) * material.durability_mult
	max_durability = durability
	power_mult = 1 + (base_power_mult * quality.stat_mult * material.power_draw_mult)
	damage_mult = 1 + (base_damage_mult * quality.stat_mult * material.projectile_damage_multiplier)
	laser_speed_mult = 1 + (base_laser_speed_mult * quality.stat_mult * material.projectile_speed_mult)
	fire_rate_mult = 1 + (base_fire_rate_mult * quality.stat_mult * material.fire_rate_multiplier)

/obj/item/smithed_item/lens/on_attached(obj/item/gun/energy/target)
	if(!istype(target))
		return
	attached_gun = target
	attached_gun.fire_delay = attached_gun.fire_delay / fire_rate_mult
	if(attached_gun.GetComponent(/datum/component/automatic_fire))
		var/datum/component/automatic_fire/auto_comp = attached_gun.GetComponent(/datum/component/automatic_fire)
		auto_comp.autofire_shot_delay = auto_comp.autofire_shot_delay / fire_rate_mult
	for(var/obj/item/ammo_casing/energy/casing in attached_gun.ammo_type)
		casing.delay = casing.delay / fire_rate_mult
		casing.e_cost = casing.e_cost * power_mult
		casing.lens_damage_multiplier = casing.lens_damage_multiplier * min(attached_gun.lens_damage_cap, damage_mult)
		casing.lens_speed_multiplier = casing.lens_speed_multiplier / laser_speed_mult

/obj/item/smithed_item/lens/on_detached()
	attached_gun.fire_delay = attached_gun.fire_delay * fire_rate_mult
	if(attached_gun.GetComponent(/datum/component/automatic_fire))
		var/datum/component/automatic_fire/auto_comp = attached_gun.GetComponent(/datum/component/automatic_fire)
		auto_comp.autofire_shot_delay = auto_comp.autofire_shot_delay * fire_rate_mult
	for(var/obj/item/ammo_casing/energy/casing in attached_gun.ammo_type)
		casing.delay = casing.delay * fire_rate_mult
		casing.e_cost = casing.e_cost / power_mult
		casing.lens_damage_multiplier = casing.lens_damage_multiplier / min(attached_gun.lens_damage_cap, damage_mult)
		casing.lens_speed_multiplier = casing.lens_speed_multiplier * laser_speed_mult
	attached_gun.current_lens = null
	attached_gun = null

/obj/item/smithed_item/lens/examine(mob/user)
	. = ..()
	var/healthpercent = (durability/max_durability) * 100
	switch(healthpercent)
		if(80 to 100)
			. +=  "It looks pristine."
		if(60 to 79)
			. +=  "It looks slightly used."
		if(40 to 59)
			. +=  "It's seen better days."
		if(20 to 39)
			. +=  "It's been heavily used."
		if(0 to 19)
			. +=  "<span class='warning'>It's falling apart!</span>"

/obj/item/smithed_item/lens/proc/damage_lens()
	durability--
	if(durability <= 0)
		break_lens()

/obj/item/smithed_item/lens/proc/break_lens()
	on_detached()
	qdel(src)

/obj/item/smithed_item/lens/accelerator
	name = "accelerator lens"
	desc = "A lens that accelerates energy beams to a higher velocity, using some of its own energy to propel it."
	base_laser_speed_mult = 0.1
	base_damage_mult = -0.1
	secondary_goal_candidate = TRUE

/obj/item/smithed_item/lens/speed
	name = "speed lens"
	desc = "A lens that cools the capacitors more efficiently, allowing for greater fire rate."
	base_fire_rate_mult = 0.15
	base_damage_mult = -0.1
	durability = 30
	secondary_goal_candidate = TRUE

/obj/item/smithed_item/lens/amplifier
	name = "amplifier lens"
	desc = "A lens that increases the frequency of emitted beams, increasing their potency."
	base_power_mult = 0.2
	base_damage_mult = 0.1
	secondary_goal_candidate = TRUE

/obj/item/smithed_item/lens/efficiency
	name = "efficiency lens"
	desc = "A lens that optimizes the number of shots an energy weapon can take before running dry."
	base_power_mult = -0.2
	base_damage_mult = -0.1
	durability = 80
	secondary_goal_candidate = TRUE

/obj/item/smithed_item/lens/rapid
	name = "rapid lens"
	desc = "An advanced lens that bypasses the heat capacitor entirely, allowing for unprecedented fire rates of low-power emissions."
	base_fire_rate_mult = 0.5
	base_laser_speed_mult = -0.1
	base_damage_mult = -0.2
	durability = 60

/obj/item/smithed_item/lens/densifier
	name = "densifier lens"
	desc = "An advanced lens that keeps energy emissions in the barrel as long as possible, maximising impact at the cost of everything else."
	base_fire_rate_mult = -0.4
	base_laser_speed_mult = -0.4
	base_damage_mult = 0.4
	durability = 30

/obj/item/smithed_item/lens/velocity
	name = "velocity lens"
	desc = "An advanced lens that forces energy emissions from the barrel as fast as possible, accelerating them to ludicrous speed."
	base_laser_speed_mult = 0.5
	base_damage_mult = -0.2
	durability = 30

/obj/item/smithed_item/lens/admin
	name = "adminium lens"
	desc = "A hyper-advanced lens restricted to high-ranking central command officials."
	laser_speed_mult = 5
	damage_mult = 5
	fire_rate_mult = 5
	power_mult = -0.5
	durability = 3000
	quality = /datum/smith_quality/masterwork
	material = /datum/smith_material/platinum

/obj/item/smithed_item/lens/AltClick(mob/user, modifiers)
	if(!HAS_TRAIT(user.mind, TRAIT_SMITH))
		return
	if(do_after_once(user, 3 SECONDS, target = src, allow_moving = TRUE, must_be_held = TRUE))
		var/compiled_message = "<span class='notice'>\
		You determine the following properties on [src]: <br>\
		Base Laser Speed mod: [base_laser_speed_mult] <br>\
		Base Power Draw mod: [base_power_mult] <br>\
		Base Damage mod: [base_damage_mult] <br>\
		Base Fire Rate mod: [base_fire_rate_mult] <br>\
		Laser Speed Multiplier: [laser_speed_mult] <br>\
		Power Draw Multiplier: [power_mult] <br>\
		Damage multiplier: [damage_mult] <br>\
		Fire Rate Multiplier: [fire_rate_mult] <br>\
		Durability: [durability] <br>\
		</span>"
		to_chat(user, compiled_message)

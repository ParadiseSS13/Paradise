/obj/item/weapon/storage/belt
	name = "belt"
	desc = "Can hold various things."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "utilitybelt"
	item_state = "utility"
	slot_flags = SLOT_BELT
	attack_verb = list("whipped", "lashed", "disciplined")


/obj/item/weapon/storage/belt/proc/can_use()
	return is_equipped()


/obj/item/weapon/storage/belt/MouseDrop(obj/over_object as obj, src_location, over_location)
	var/mob/M = usr
	if(!istype(over_object, /obj/screen))
		return ..()
	playsound(src.loc, "rustle", 50, 1, -5)
	if (!M.restrained() && !M.stat && can_use())
		switch(over_object.name)
			if("r_hand")
				M.unEquip(src)
				M.put_in_r_hand(src)
			if("l_hand")
				M.unEquip(src)
				M.put_in_l_hand(src)
		src.add_fingerprint(usr)
		return



/obj/item/weapon/storage/belt/utility
	name = "tool-belt" //Carn: utility belt is nicer, but it bamboozles the text parsing.
	desc = "Can hold various tools."
	icon_state = "utilitybelt"
	item_state = "utility"
	can_hold = list(
		"/obj/item/weapon/crowbar",
		"/obj/item/weapon/screwdriver",
		"/obj/item/weapon/weldingtool",
		"/obj/item/weapon/wirecutters",
		"/obj/item/weapon/wrench",
		"/obj/item/device/multitool",
		"/obj/item/device/flashlight",
		"/obj/item/stack/cable_coil",
		"/obj/item/device/t_scanner",
		"/obj/item/device/analyzer",
		"/obj/item/taperoll/engineering",
		"/obj/item/weapon/extinguisher/mini")


/obj/item/weapon/storage/belt/utility/full/New()
	..()
	new /obj/item/weapon/screwdriver(src)
	new /obj/item/weapon/wrench(src)
	new /obj/item/weapon/weldingtool(src)
	new /obj/item/weapon/crowbar(src)
	new /obj/item/weapon/wirecutters(src)
	new /obj/item/stack/cable_coil(src,30,pick("red","yellow","orange"))

/obj/item/weapon/storage/belt/utility/full/multitool/New()
	..()
	new /obj/item/device/multitool(src)

/obj/item/weapon/storage/belt/utility/atmostech/New()
	..()
	new /obj/item/weapon/screwdriver(src)
	new /obj/item/weapon/wrench(src)
	new /obj/item/weapon/weldingtool(src)
	new /obj/item/weapon/crowbar(src)
	new /obj/item/weapon/wirecutters(src)
	new /obj/item/device/t_scanner(src)
	new /obj/item/weapon/extinguisher/mini(src)



/obj/item/weapon/storage/belt/medical
	use_to_pickup = 1 //Allow medical belt to pick up medicine
	name = "medical belt"
	desc = "Can hold various medical equipment."
	icon_state = "medicalbelt"
	item_state = "medical"
	can_hold = list(
		"/obj/item/device/healthanalyzer",
		"/obj/item/weapon/dnainjector",
		"/obj/item/weapon/reagent_containers/dropper",
		"/obj/item/weapon/reagent_containers/glass/beaker",
		"/obj/item/weapon/reagent_containers/glass/bottle",
		"/obj/item/weapon/reagent_containers/pill",
		"/obj/item/weapon/reagent_containers/syringe",
		"/obj/item/weapon/reagent_containers/glass/dispenser",
		"/obj/item/weapon/lighter/zippo",
		"/obj/item/weapon/storage/fancy/cigarettes",
		"/obj/item/weapon/storage/pill_bottle",
		"/obj/item/stack/medical",
		"/obj/item/device/flashlight/pen",
		"/obj/item/clothing/mask/surgical",
		"/obj/item/clothing/gloves/color/latex",
        "/obj/item/weapon/reagent_containers/hypospray/autoinjector",
        "/obj/item/device/rad_laser",
		"/obj/item/device/sensor_device"
	)

/obj/item/weapon/storage/belt/medical/response_team

/obj/item/weapon/storage/belt/medical/response_team/New()
	new /obj/item/weapon/reagent_containers/pill/salbutamol(src)
	new /obj/item/weapon/reagent_containers/pill/salbutamol(src)
	new /obj/item/weapon/reagent_containers/pill/charcoal(src)
	new /obj/item/weapon/reagent_containers/pill/charcoal(src)
	new /obj/item/weapon/reagent_containers/pill/salicylic(src)
	new /obj/item/weapon/reagent_containers/pill/salicylic(src)
	new /obj/item/weapon/reagent_containers/pill/salicylic(src)


/obj/item/weapon/storage/belt/botany
	name = "botanist belt"
	desc = "Can hold various botanical supplies."
	icon_state = "botanybelt"
	item_state = "botany"
	can_hold = list(
		"/obj/item/device/analyzer/plant_analyzer",
		"/obj/item/weapon/minihoe",
		"/obj/item/weapon/hatchet",
		"/obj/item/weapon/reagent_containers/glass/fertilizer",
		"/obj/item/weapon/reagent_containers/glass/bottle",
		"/obj/item/weapon/plantspray",
		"/obj/item/weapon/reagent_containers/syringe",
		"/obj/item/weapon/reagent_containers/glass/beaker",
		"/obj/item/weapon/lighter/zippo",
		"/obj/item/weapon/storage/fancy/cigarettes",
		"obj/item/weapon/rollingpaperpack",
		"/obj/item/weapon/shovel/spade",
		"/obj/item/device/flashlight/pen",
		"/obj/item/seeds",
		"/obj/item/weapon/wirecutters",
        "/obj/item/weapon/wrench",
		"/obj/item/weapon/disk/botany",
	)


/obj/item/weapon/storage/belt/security
	name = "security belt"
	desc = "Can hold security gear like handcuffs and flashes."
	icon_state = "securitybelt"
	item_state = "security"//Could likely use a better one.
	storage_slots = 5
	max_w_class = 3
	can_hold = list(
		"/obj/item/weapon/grenade/flashbang",
		"/obj/item/weapon/grenade/chem_grenade/teargas",
		"/obj/item/weapon/reagent_containers/spray/pepper",
		"/obj/item/weapon/restraints/handcuffs",
		"/obj/item/device/flash",
		"/obj/item/clothing/glasses",
		"/obj/item/ammo_casing/shotgun",
		"/obj/item/ammo_box",
		"/obj/item/weapon/reagent_containers/food/snacks/donut/normal",
		"/obj/item/weapon/reagent_containers/food/snacks/donut/jelly",
		"/obj/item/weapon/melee/baton",
		"/obj/item/weapon/melee/classic_baton",
		"/obj/item/device/flashlight/seclite",
		"/obj/item/taperoll/police",
		"/obj/item/weapon/melee/classic_baton/telescopic"
		)

/obj/item/weapon/storage/belt/security/sec/New()
	..()
	new /obj/item/device/flashlight/seclite(src)

/obj/item/weapon/storage/belt/security/response_team/New()
	..()
	new /obj/item/weapon/kitchenknife/combat(src)
	new /obj/item/weapon/melee/baton/loaded(src)
	new /obj/item/device/flash(src)
	new /obj/item/weapon/melee/classic_baton/telescopic(src)
	new /obj/item/weapon/grenade/flashbang(src)

/obj/item/weapon/storage/belt/soulstone
	name = "soul stone belt"
	desc = "Designed for ease of access to the shards during a fight, as to not let a single enemy spirit slip away"
	icon_state = "soulstonebelt"
	item_state = "soulstonebelt"
	storage_slots = 6
	can_hold = list(
		"/obj/item/device/soulstone"
		)

/obj/item/weapon/storage/belt/soulstone/full/New()
	..()
	new /obj/item/device/soulstone(src)
	new /obj/item/device/soulstone(src)
	new /obj/item/device/soulstone(src)
	new /obj/item/device/soulstone(src)
	new /obj/item/device/soulstone(src)
	new /obj/item/device/soulstone(src)


/obj/item/weapon/storage/belt/champion
	name = "championship belt"
	desc = "Proves to the world that you are the strongest!"
	icon_state = "championbelt"
	item_state = "champion"
	materials = list(MAT_GOLD=400)
	storage_slots = 1
	can_hold = list(
		"/obj/item/clothing/mask/luchador"
		)

/obj/item/weapon/storage/belt/military
	name = "military belt"
	desc = "A syndicate belt designed to be used by boarding parties.  Its style is modelled after the hardsuits they wear."
	icon_state = "militarybelt"
	item_state = "military"

/obj/item/weapon/storage/belt/janitor
	name = "janibelt"
	desc = "A belt used to hold most janitorial supplies."
	icon_state = "janibelt"
	item_state = "janibelt"
	storage_slots = 6
	max_w_class = 4 // Set to this so the  light replacer can fit.
	can_hold = list(
		"/obj/item/weapon/grenade/chem_grenade/cleaner",
		"/obj/item/device/lightreplacer",
		"/obj/item/device/flashlight",
		"/obj/item/weapon/reagent_containers/spray",
		"/obj/item/weapon/soap",
		"/obj/item/weapon/holosign_creator"
		)

/obj/item/weapon/storage/belt/janitor/full/New()
	..()
	new /obj/item/device/lightreplacer(src)
	new /obj/item/weapon/holosign_creator(src)
	new /obj/item/weapon/reagent_containers/spray(src)
	new /obj/item/weapon/soap(src)
	new /obj/item/weapon/grenade/chem_grenade/cleaner(src)
	new /obj/item/weapon/grenade/chem_grenade/cleaner(src)

/obj/item/weapon/storage/belt/bandolier
	name = "bandolier"
	desc = "A bandolier for holding shotgun ammunition."
	icon_state = "bandolier"
	item_state = "bandolier"
	storage_slots = 6
	can_hold = list(
		"/obj/item/ammo_casing/shotgun"
		)

/obj/item/weapon/storage/belt/bandolier/full/New()
	..()
	new /obj/item/ammo_casing/shotgun/beanbag(src)
	new /obj/item/ammo_casing/shotgun/beanbag(src)
	new /obj/item/ammo_casing/shotgun/beanbag(src)
	new /obj/item/ammo_casing/shotgun/beanbag(src)
	new /obj/item/ammo_casing/shotgun/beanbag(src)
	new /obj/item/ammo_casing/shotgun/beanbag(src)

/obj/item/weapon/storage/belt/holster
	name = "shoulder holster"
	desc = "A holster to conceal a carried handgun. WARNING: Badasses only."
	icon_state = "holster"
	item_state = "holster"
	storage_slots = 1
	max_w_class = 3
	can_hold = list(
		"/obj/item/weapon/gun/projectile/automatic/pistol",
		"/obj/item/weapon/gun/projectile/revolver/detective"
		)

/obj/item/weapon/storage/belt/wands
	name = "wand belt"
	desc = "A belt designed to hold various rods of power. A veritable fanny pack of exotic magic."
	icon_state = "soulstonebelt"
	item_state = "soulstonebelt"
	storage_slots = 6
	can_hold = list(
		"/obj/item/weapon/gun/magic/wand"
		)

/obj/item/weapon/storage/belt/wands/full/New()
	..()
	new /obj/item/weapon/gun/magic/wand/death(src)
	new /obj/item/weapon/gun/magic/wand/resurrection(src)
	new /obj/item/weapon/gun/magic/wand/polymorph(src)
	new /obj/item/weapon/gun/magic/wand/teleport(src)
	new /obj/item/weapon/gun/magic/wand/door(src)
	new /obj/item/weapon/gun/magic/wand/fireball(src)

	for(var/obj/item/weapon/gun/magic/wand/W in contents) //All wands in this pack come in the best possible condition
		W.max_charges = initial(W.max_charges)
		W.charges = W.max_charges

/obj/item/weapon/storage/belt/fannypack
	name = "fannypack"
	desc = "A dorky fannypack for keeping small items in."
	icon_state = "fannypack_leather"
	item_state = "fannypack_leather"
	storage_slots = 3
	max_w_class = 2

/obj/item/weapon/storage/belt/fannypack/black
	name = "black fannypack"
	icon_state = "fannypack_black"
	item_state = "fannypack_black"

/obj/item/weapon/storage/belt/fannypack/red
	name = "red fannypack"
	icon_state = "fannypack_red"
	item_state = "fannypack_red"

/obj/item/weapon/storage/belt/fannypack/purple
	name = "purple fannypack"
	icon_state = "fannypack_purple"
	item_state = "fannypack_purple"

/obj/item/weapon/storage/belt/fannypack/blue
	name = "blue fannypack"
	icon_state = "fannypack_blue"
	item_state = "fannypack_blue"

/obj/item/weapon/storage/belt/fannypack/orange
	name = "orange fannypack"
	icon_state = "fannypack_orange"
	item_state = "fannypack_orange"

/obj/item/weapon/storage/belt/fannypack/white
	name = "white fannypack"
	icon_state = "fannypack_white"
	item_state = "fannypack_white"

/obj/item/weapon/storage/belt/fannypack/green
	name = "green fannypack"
	icon_state = "fannypack_green"
	item_state = "fannypack_green"

/obj/item/weapon/storage/belt/fannypack/pink
	name = "pink fannypack"
	icon_state = "fannypack_pink"
	item_state = "fannypack_pink"

/obj/item/weapon/storage/belt/fannypack/cyan
	name = "cyan fannypack"
	icon_state = "fannypack_cyan"
	item_state = "fannypack_cyan"

/obj/item/weapon/storage/belt/fannypack/yellow
	name = "yellow fannypack"
	icon_state = "fannypack_yellow"
	item_state = "fannypack_yellow"

// -------------------------------------
//     Bluespace Belt
// -------------------------------------


/obj/item/weapon/storage/belt/bluespace
	name = "Belt of Holding"
	desc = "The greatest in pants-supporting technology."
	icon_state = "holdingbelt"
	item_state = "holdingbelt"
	storage_slots = 14
	w_class = 4
	max_w_class = 2
	max_combined_w_class = 21 // = 14 * 1.5, not 14 * 2.  This is deliberate
	origin_tech = "bluespace=4"
	can_hold = list()

	proc/failcheck(mob/user as mob)
		if (prob(src.reliability)) return 1 //No failure
		if (prob(src.reliability))
			user << "\red The Bluespace portal resists your attempt to add another item." //light failure
		else
			user << "\red The Bluespace generator malfunctions!"
			for (var/obj/O in src.contents) //it broke, delete what was in it
				qdel(O)
			crit_fail = 1
			return 0

/obj/item/weapon/storage/belt/bluespace/owlman
	name = "Owlman's utility belt"
	desc = "Sometimes people choose justice.  Sometimes, justice chooses you..."
	icon_state = "securitybelt"
	item_state = "security"
	storage_slots = 6
	max_w_class = 3
	max_combined_w_class = 18
	origin_tech = "bluespace=4;syndicate=2"
	allow_quick_empty = 1
	can_hold = list(
		"/obj/item/weapon/grenade/smokebomb",
		"/obj/item/weapon/legcuffs/bolas"
		)

	flags = NODROP
	var/smokecount = 0
	var/bolacount = 0
	var/cooldown = 0



/obj/item/weapon/storage/belt/bluespace/owlman/New()
	..()
	new /obj/item/weapon/grenade/smokebomb(src)
	new /obj/item/weapon/grenade/smokebomb(src)
	new /obj/item/weapon/grenade/smokebomb(src)
	new /obj/item/weapon/grenade/smokebomb(src)
	new /obj/item/weapon/legcuffs/bolas(src)
	new /obj/item/weapon/legcuffs/bolas(src)
	processing_objects.Add(src)
	cooldown = world.time

/obj/item/weapon/storage/belt/bluespace/owlman/process()
	if(cooldown < world.time - 600)
		smokecount = 0
		var/obj/item/weapon/grenade/smokebomb/S
		for(S in src)
			smokecount++
		bolacount = 0
		var/obj/item/weapon/legcuffs/bolas/B
		for(B in src)
			bolacount++
		if(smokecount < 4)
			while(smokecount < 4)
				new /obj/item/weapon/grenade/smokebomb(src)
				smokecount++
		if(bolacount < 2)
			while(bolacount < 2)
				new /obj/item/weapon/legcuffs/bolas(src)
				bolacount++
		cooldown = world.time
		update_icon()
		orient2hud()
		if(ishuman(loc))
			var/mob/living/carbon/human/H = loc
			if(H.belt && H.belt == src)
				if(H.s_active && H.s_active == src)
					H.s_active.show_to(H)


/* DEPRECATED DUE TO SUPERHERO CODE AND NODROP
 // As a last resort, the belt can be used as a plastic explosive with a fixed timer (15 seconds).  Naturally, you'll lose all your gear...
 // Of course, it could be worse.  It could spawn a singularity!
/obj/item/weapon/storage/belt/bluespace/owlman/afterattack(atom/target as obj|turf, mob/user as mob, flag)
	if (!flag)
		return
	if (istype(target, /turf/unsimulated) || istype(target, /turf/simulated/shuttle) || istype(target, /obj/item/weapon/storage) || istype(target, /obj/structure/table) || istype(target, /obj/structure/closet))
		return
	user << "Planting explosives..."
	user.visible_message("[user.name] is fiddling with their toolbelt.")
	if(ismob(target))
		user.attack_log += "\[[time_stamp()]\] <font color='red'> [user.real_name] tried planting [name] on [target:real_name] ([target:ckey])</font>"
		log_attack("<font color='red'> [user.real_name] ([user.ckey]) tried planting [name] on [target:real_name] ([target:ckey])</font>")
		user.visible_message("\red [user.name] is trying to strap a belt to [target.name]!")


	if(do_after(user, 50, target = target) && in_range(user, target))
		user.drop_item()
		target = target
		loc = null
		var/location
		if (isturf(target)) location = target
		if (ismob(target))
			target:attack_log += "\[[time_stamp()]\]<font color='orange'> Had the [name] planted on them by [user.real_name] ([user.ckey])</font>"
			user.visible_message("\red [user.name] finished planting an explosive on [target.name]!")
		target.overlays += image('icons/obj/assemblies.dmi', "plastic-explosive2")
		user << "You sacrifice your belt for the sake of justice. Timer counting down from 15."
		spawn(150)
			if(target)
				if(ismob(target) || isobj(target))
					location = target.loc // These things can move
				explosion(location, -1, -1, 2, 3)
				if (istype(target, /turf/simulated/wall)) target:dismantle_wall(1)
				else target.ex_act(1)
				if (isobj(target))
					if (target)
						del(target)
				if (src)
					del(src)
*/

/obj/item/weapon/storage/belt/bluespace/attack(mob/M as mob, mob/user as mob, def_zone)
	return

/obj/item/weapon/storage/belt/bluespace/admin
	name = "Admin's Tool-belt"
	desc = "Holds everything for those that run everything."
	icon_state = "soulstonebelt"
	item_state = "soulstonebelt"
	w_class = 10 // permit holding other storage items
	storage_slots = 28
	max_w_class = 10
	max_combined_w_class = 280
	can_hold = list()

	New()
		..()
		new /obj/item/weapon/crowbar(src)
		new /obj/item/weapon/screwdriver(src)
		new /obj/item/weapon/weldingtool/hugetank(src)
		new /obj/item/weapon/wirecutters(src)
		new /obj/item/weapon/wrench(src)
		new /obj/item/device/multitool(src)
		new /obj/item/stack/cable_coil(src)

		new /obj/item/weapon/restraints/handcuffs(src)
		new /obj/item/weapon/dnainjector/xraymut(src)
		new /obj/item/weapon/dnainjector/firemut(src)
		new /obj/item/weapon/dnainjector/telemut(src)
		new /obj/item/weapon/dnainjector/hulkmut(src)
//		new /obj/item/weapon/spellbook(src) // for smoke effects, door openings, etc
//		new /obj/item/weapon/magic/spellbook(src)

//		new/obj/item/weapon/reagent_containers/hypospray/admin(src)

/obj/item/weapon/storage/belt/bluespace/sandbox
	name = "Sandbox Mode Toolbelt"
	desc = "Holds whatever, you can spawn your own damn stuff."
	w_class = 10 // permit holding other storage items
	storage_slots = 28
	max_w_class = 10
	max_combined_w_class = 280
	can_hold = list()

	New()
		..()
		new /obj/item/weapon/crowbar(src)
		new /obj/item/weapon/screwdriver(src)
		new /obj/item/weapon/weldingtool/hugetank(src)
		new /obj/item/weapon/wirecutters(src)
		new /obj/item/weapon/wrench(src)
		new /obj/item/device/multitool(src)
		new /obj/item/stack/cable_coil(src)

		new /obj/item/device/analyzer(src)
		new /obj/item/device/healthanalyzer(src)

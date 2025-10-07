/* CONTENTS:
* 1. SABER SMG
* 2. C-20R SMG
* 3. WT-550 PDW
* 4. TYPE U3 UZI
* 5. M-90GL CARBINE
* 6. THOMPSON SMG
* 7. M26A2 ASSAULT RIFLE
* 8. AK-814 ASSAULT RIFLE
* 9. AS-14 'BULLDOG' SHOTGUN
* 10. IK-M2 LASER CARBINE
* 11. IK-M1 LASER RIFLE
*/

/obj/item/gun/projectile/automatic
	var/alarmed = 0
	var/select = 1
	can_tactical = TRUE
	can_suppress = TRUE
	burst_size = 3
	fire_delay = 2
	actions_types = list(/datum/action/item_action/toggle_firemode)

/obj/item/gun/projectile/automatic/update_icon_state()
	icon_state = "[initial(icon_state)][magazine ? "-[magazine.max_ammo]" : ""][chambered ? "" : "-e"][suppressed ? "-suppressed" : ""]"

/obj/item/gun/projectile/automatic/update_overlays()
	. = ..()
	if(!select)
		. += "[initial(icon_state)]semi"
	if(select == 1)
		. += "[initial(icon_state)]burst"

/obj/item/gun/projectile/automatic/attackby__legacy__attackchain(obj/item/A as obj, mob/user as mob, params)
	. = ..()
	if(.)
		if(alarmed) // Did the empty clip alarm go off already?
			alarmed = 0 // Reset the alarm once a magazine is loaded
		return
	if(istype(A, /obj/item/ammo_box/magazine))
		var/obj/item/ammo_box/magazine/AM = A
		if(istype(AM, mag_type))
			if(magazine)
				to_chat(user, "<span class='notice'>You perform a tactical reload on \the [src], replacing the magazine.</span>")
				magazine.loc = get_turf(loc)
				magazine.update_icon()
				magazine = null
			else
				to_chat(user, "<span class='notice'>You insert the magazine into \the [src].</span>")
			if(alarmed)
				alarmed = 0
			user.unequip(AM)
			magazine = AM
			magazine.loc = src
			chamber_round()
			A.update_icon()
			update_icon()
			return 1

/obj/item/gun/projectile/automatic/ui_action_click()
	burst_select()

/obj/item/gun/projectile/automatic/proc/burst_select()
	var/mob/living/carbon/human/user = usr
	select = !select
	if(!select)
		burst_size = 1
		fire_delay = 0
		to_chat(user, "<span class='notice'>You switch to semi-automatic.</span>")
	else
		burst_size = initial(burst_size)
		fire_delay = initial(fire_delay)
		to_chat(user, "<span class='notice'>You switch to [burst_size] round burst.</span>")

	playsound(user, 'sound/weapons/gun_interactions/selector.ogg', 100, 1)
	update_icon()
	update_action_buttons()

/obj/item/gun/projectile/automatic/can_shoot()
	return get_ammo()

/obj/item/gun/projectile/automatic/proc/empty_alarm()
	if(!chambered && !get_ammo() && !alarmed)
		playsound(loc, 'sound/weapons/smg_empty_alarm.ogg', 40, 1)
		update_icon()
		alarmed = 1

//////////////////////////////
// MARK: SABER SMG
//////////////////////////////
/obj/item/gun/projectile/automatic/proto
	name = "\improper NF10 'Saber' SMG"
	desc = "A rejected prototype three-round burst 9mm submachine gun, designated 'SABR'. Surplus of this model are bouncing around armories of Nanotrasen Space Stations. Has a threaded barrel for suppressors."
	icon_state = "saber"
	inhand_icon_state = "saber"
	mag_type = /obj/item/ammo_box/magazine/smgm9mm
	origin_tech = "combat=4;materials=2"
	fire_sound = 'sound/weapons/gunshots/gunshot_pistol.ogg'

//////////////////////////////
// MARK: C-20R SMG
//////////////////////////////
/obj/item/gun/projectile/automatic/c20r
	name = "\improper C-20R SMG"
	desc = "A two-round burst .45 SMG, designated 'C-20R'. Has a 'Scarborough Arms - Per falcis, per pravitas' buttstamp."
	icon_state = "c20r"
	inhand_icon_state = "c20r"
	origin_tech = "combat=5;materials=2;syndicate=6"
	mag_type = /obj/item/ammo_box/magazine/smgm45
	fire_sound = 'sound/weapons/gunshots/gunshot_smg.ogg'
	burst_size = 2
	can_bayonet = TRUE
	knife_x_offset = 26
	knife_y_offset = 12

/obj/item/gun/projectile/automatic/c20r/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/gun/projectile/automatic/c20r/afterattack__legacy__attackchain(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag)
	..()
	empty_alarm()

/obj/item/gun/projectile/automatic/c20r/update_icon_state()
	icon_state = "c20r[magazine ? "-[CEILING(get_ammo(0)/4, 1)*4]" : ""][chambered ? "" : "-e"][suppressed ? "-suppressed" : ""]"

//////////////////////////////
// MARK: WT-550 PDW
//////////////////////////////
/obj/item/gun/projectile/automatic/wt550
	name = "\improper WT-550 PDW"
	desc = "An outdated personal defense weapon utilized by law enforcement. Chambered in 4.6x30mm."
	icon_state = "wt550"
	w_class = WEIGHT_CLASS_BULKY
	mag_type = /obj/item/ammo_box/magazine/wt550m9
	fire_sound = 'sound/weapons/gunshots/gunshot_rifle.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	can_suppress = FALSE
	burst_size = 1
	actions_types = list()
	can_bayonet = TRUE
	knife_x_offset = 25
	knife_y_offset = 12

/obj/item/gun/projectile/automatic/wt550/update_icon_state()
	icon_state = "wt550[magazine ? "-[CEILING(get_ammo(FALSE) / 4, 1) * 4]" : ""]"
	inhand_icon_state = "wt550-[CEILING(get_ammo(FALSE) / 6.7, 1)]"

//////////////////////////////
// MARK: TYPE U3 UZI
//////////////////////////////
/obj/item/gun/projectile/automatic/mini_uzi
	name = "\improper 'Type U3' Uzi"
	desc = "A lightweight, burst-fire submachine gun, for when you really want someone dead. Uses 9mm rounds."
	icon = 'icons/tgmc/objects/guns.dmi'
	icon_state = "mini-uzi"
	inhand_icon_state = "mini-uzi"
	lefthand_file = 'icons/tgmc/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/tgmc/mob/inhands/guns_righthand.dmi'
	origin_tech = "combat=4;materials=2;syndicate=4"
	mag_type = /obj/item/ammo_box/magazine/uzim9mm
	fire_sound = 'sound/weapons/gunshots/gunshot_pistol.ogg'
	burst_size = 2
	can_holster = TRUE // it's a mini-uzi after all

/obj/item/gun/projectile/automatic/mini_uzi/update_overlays()
	. = ..()
	if(suppressed)
		. += image(icon = 'icons/obj/guns/attachments.dmi', icon_state = "suppressor_attached", pixel_x = 13, pixel_y = 5)

//////////////////////////////
// MARK: M-90GL CARBINE
//////////////////////////////
/obj/item/gun/projectile/automatic/m90
	name = "\improper M-90GL Carbine"
	desc = "A three-round burst 5.56 toploading carbine, designated 'M-90GL'. Has an attached underbarrel grenade launcher which can be toggled on and off."
	icon_state = "m90"
	inhand_icon_state = "m90-4"
	origin_tech = "combat=5;materials=2;syndicate=6"
	mag_type = /obj/item/ammo_box/magazine/m556
	fire_sound = 'sound/weapons/gunshots/gunshot_rifle.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	can_suppress = FALSE
	var/obj/item/gun/projectile/revolver/grenadelauncher/underbarrel

/obj/item/gun/projectile/automatic/m90/Initialize(mapload)
	. = ..()
	underbarrel = new /obj/item/gun/projectile/revolver/grenadelauncher(src)
	update_icon()

/obj/item/gun/projectile/automatic/m90/Destroy()
	qdel(underbarrel)
	return ..()

/obj/item/gun/projectile/automatic/m90/afterattack__legacy__attackchain(atom/target, mob/living/user, flag, params)
	if(select == 2)
		underbarrel.afterattack__legacy__attackchain(target, user, flag, params)
	else
		..()
		return

/obj/item/gun/projectile/automatic/m90/attackby__legacy__attackchain(obj/item/A, mob/user, params)
	if(istype(A, /obj/item/ammo_casing))
		if(istype(A, underbarrel.magazine.ammo_type))
			underbarrel.attack_self__legacy__attackchain(user)
			underbarrel.attackby__legacy__attackchain(A, user, params)
	else
		return ..()

/obj/item/gun/projectile/automatic/m90/update_icon_state()
	icon_state = "[initial(icon_state)][magazine ? "" : "-e"]"
	inhand_icon_state = "m90-[CEILING(get_ammo(FALSE) / 7.5, 1)]"

/obj/item/gun/projectile/automatic/m90/update_overlays()
	. = ..()
	switch(select)
		if(0)
			. += "[initial(icon_state)]semi"
		if(1)
			. += "[initial(icon_state)]burst"
		if(2)
			. += "[initial(icon_state)]gren"
	if(magazine)
		. += image(icon = icon, icon_state = "m90-[CEILING(get_ammo(0)/6, 1)*6]")

/obj/item/gun/projectile/automatic/m90/burst_select()
	var/mob/living/carbon/human/user = usr
	switch(select)
		if(0)
			select = 1
			burst_size = initial(burst_size)
			fire_delay = initial(fire_delay)
			to_chat(user, "<span class='notice'>You switch to [burst_size] round burst.</span>")
		if(1)
			select = 2
			to_chat(user, "<span class='notice'>You switch to grenades.</span>")
		if(2)
			select = 0
			burst_size = 1
			fire_delay = 0
			to_chat(user, "<span class='notice'>You switch to semi-auto.</span>")
	playsound(user, 'sound/weapons/gun_interactions/selector.ogg', 100, 1)
	update_icon()

//////////////////////////////
// MARK: THOMPSON SMG
//////////////////////////////
/obj/item/gun/projectile/automatic/tommygun
	name = "\improper Thompson SMG"
	desc = "A genuine 'Chicago Typewriter'."
	inhand_icon_state = "shotgun"
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = 0
	origin_tech = "combat=5;materials=1;syndicate=3"
	mag_type = /obj/item/ammo_box/magazine/tommygunm45
	fire_sound = 'sound/weapons/gunshots/gunshot_smg.ogg'
	can_suppress = FALSE
	burst_size = 4
	fire_delay = 1

//////////////////////////////
// MARK: M26A2 ASSAULT RIFLE
//////////////////////////////
/obj/item/gun/projectile/automatic/ar
	name = "\improper M26A2 assault rifle"
	desc = "A robust assault rifle used by Trans-Solar Federation forces. Chambered in 5.56mm."
	icon_state = "arg"
	inhand_icon_state = "arg"
	slot_flags = 0
	origin_tech = "combat=6;engineering=4"
	mag_type = /obj/item/ammo_box/magazine/m556/arg
	fire_sound = 'sound/weapons/gunshots/gunshot_mg.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	can_suppress = FALSE
	fire_delay = 1

//////////////////////////////
// MARK: AK-814 ASSAULT RIFLE
//////////////////////////////
/obj/item/gun/projectile/automatic/ak814
	name = "\improper AK-814 assault rifle"
	desc = "A modern AK assault rifle favored by elite Soviet soldiers. Chambered in 7.62x54mm."
	icon_state = "ak814"
	inhand_icon_state = "ak814"
	origin_tech = "combat=5;materials=3"
	mag_type = /obj/item/ammo_box/magazine/ak814
	fire_sound = 'sound/weapons/gunshots/gunshot_mg.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	can_suppress = FALSE
	can_bayonet = TRUE
	knife_x_offset = 26
	knife_y_offset = 10
	burst_size = 2
	fire_delay = 1

//////////////////////////////
// MARK: AS-14 'BULLDOG' SHOTGUN
//////////////////////////////
/obj/item/gun/projectile/automatic/shotgun/bulldog
	name = "\improper AS-14 'Bulldog' Shotgun"
	desc = "A compact semi-automatic shotgun for combat in narrow corridors, nicknamed 'Bulldog' by boarding parties. Compatible only with specialized 8-round drum magazines."
	icon_state = "bulldog"
	inhand_icon_state = "bulldog"
	origin_tech = "combat=6;materials=4;syndicate=6"
	mag_type = /obj/item/ammo_box/magazine/m12g
	fire_sound = 'sound/weapons/gunshots/gunshot_shotgun.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	can_suppress = FALSE
	burst_size = 1
	fire_delay = 0
	actions_types = list()
	execution_speed = 5 SECONDS

/obj/item/gun/projectile/automatic/shotgun/bulldog/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/gun/projectile/automatic/shotgun/bulldog/update_overlays()
	. = ..()
	if(magazine)
		. += "[magazine.icon_state]"
		if(istype(magazine, /obj/item/ammo_box/magazine/m12g/xtr_lrg))
			w_class = WEIGHT_CLASS_BULKY
		else
			w_class = WEIGHT_CLASS_NORMAL
	else
		w_class = WEIGHT_CLASS_NORMAL

/obj/item/gun/projectile/automatic/shotgun/bulldog/update_icon_state()
	icon_state = "bulldog[chambered ? "" : "-e"]"

/obj/item/gun/projectile/automatic/shotgun/bulldog/attackby__legacy__attackchain(obj/item/A as obj, mob/user as mob, params)
	if(istype(A, /obj/item/ammo_box/magazine/m12g/xtr_lrg))
		if(isstorage(loc))	// To prevent inventory exploits
			var/obj/item/storage/Strg = loc
			if(Strg.max_w_class < WEIGHT_CLASS_BULKY)
				to_chat(user, "<span class='warning'>You can't reload [src], with a XL mag, while it's in a normal bag.</span>")
				return
	return ..()

/obj/item/gun/projectile/automatic/shotgun/bulldog/afterattack__legacy__attackchain(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag)
	..()
	empty_alarm()

// Standard traitor uplink variant
/obj/item/gun/projectile/automatic/shotgun/bulldog/traitor
	mag_type = /obj/item/ammo_box/magazine/m12g/rubbershot

//////////////////////////////
// MARK: IK-M2 LASER CARBINE
//////////////////////////////
/obj/item/gun/projectile/automatic/lasercarbine
	name = "\improper IK-M2 laser carbine"
	desc = "A compact Warp-Tac Industries fully automatic laser carbine that uses disposable laser cartridges rather than an internal power cell. Utilized by Nanotrasen's response teams for combat operations."
	icon_state = "lasercarbine"
	inhand_icon_state = "lasercarbine"
	origin_tech = "combat=4;materials=2"
	mag_type = /obj/item/ammo_box/magazine/laser
	fire_sound = 'sound/weapons/gunshots/gunshot_lascarbine.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	actions_types = list()
	can_suppress = FALSE
	burst_size = 1
	execution_speed = 5 SECONDS
	fire_delay = 0

/obj/item/gun/projectile/automatic/lasercarbine/examine_more(mob/user)
	..()
	. = list()
	. += "The IK-M2 is the premium version of the already well-regarded IK-M1. Whilst the two weapons are fairly similar, \
	the IK-M2 is made from more advanced materials to achieve an even lighter and more ruggedized package, whilst also being slightly more compact."
	. += ""
	. += "The receiver is also modified, allowing it to continiously extract cartrages as long as the trigger is held, permitting fully automatic fire. \
	It also comes with hardened magazines to protect the laser cartridges from EMP damage."
	. += ""
	. += "Warp-Tac bundles this weapon with a lifetime warranty. This weapon is favored by private military groups and mercenaries with money to throw around."

/obj/item/gun/projectile/automatic/lasercarbine/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, 0.30 SECONDS, allow_akimbo = FALSE)

/obj/item/gun/projectile/automatic/lasercarbine/update_icon_state()
	if(magazine)
		var/bullets = CEILING(get_ammo(FALSE) / 5, 1) * 5
		icon_state = "lasercarbine-[bullets]"
		inhand_icon_state = "lasercarbine-[bullets]"
	else
		icon_state = "lasercarbine"
		inhand_icon_state = "lasercarbine"

//////////////////////////////
// MARK: IK-M1 LASER RIFLE
//////////////////////////////
/obj/item/gun/projectile/automatic/laserrifle
	name = "\improper IK-M1 laser rifle"
	desc = "A sleek, Warp-Tac Industries laser rifle that uses disposable laser cartridges rather than an internal power cell. Sold to Nanotrasen's private security forces."
	icon_state = "laserrifle"
	inhand_icon_state = "lasercarbine"
	w_class = WEIGHT_CLASS_BULKY
	origin_tech = "combat=3;materials=2"
	mag_type = /obj/item/ammo_box/magazine/laser
	fire_sound = 'sound/weapons/gunshots/gunshot_lascarbine.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	can_suppress = FALSE
	burst_size = 1
	actions_types = list()

/obj/item/gun/projectile/automatic/laserrifle/examine_more(mob/user)
	..()
	. = list()
	. += "A sleek, futuristic laser rifle, developed by the brightest minds of Warp-Tac Industries. The IK-series is unique for utilising a patented system of disposable energy cartridges. \
	This unique system makes IK-pattern rifles handle more like a traditional firearm than a laser."
	. += ""
	. += "The IK-M1 marked Warp-Tec's investment into the realm of laser arms manufacturing, a bold move considering the industry's typical separation of ballistic and energy weapon production. \
	Years of development went into the creation of the ammunition, culminating in a cheap, easy to produce single-use supercapacitor cartridge that discharges its energy into the rifle's laser cavity at the moment of firing. \
	The cartridge is then ejected by an electronically-actuated plastitanum bolt powered by a small internal power cell. As the spent cell is extracted, it also carries with it a significant amount of heat directly \
	from the internals of the rifle. This action is responsible for most of the cooling of the weapon, the remaining heat conducts to the barrel, which also functions as a passive heatsink. \
	The lack of need for any further cooling hardware makes these rifles deceptively light and easy to handle."
	. += ""
	. += "Modern IK-pattern weapons remain expensive due to extremely stringent quality control measures at Warp-Tac's manufacturing plants - \
	each one is individually inspected and tested to ensure proper operation up to Warp-Tac's standards. The end result, however, is an exceptionally reliable weapon."
	. += ""
	. += "Today, the latest generation of the IK-M1 competes with established laser brands like Shellguard Munitions, positioning itself as a premium choice in the laser weaponry market."

/obj/item/gun/projectile/automatic/laserrifle/update_icon_state()
	if(magazine)
		var/bullets = CEILING(get_ammo(FALSE) / 5, 1) * 5
		icon_state = "laserrifle-[bullets]"
		inhand_icon_state = "lasercarbine-[bullets]"
	else
		icon_state = "laserrifle"
		inhand_icon_state = "lasercarbine"

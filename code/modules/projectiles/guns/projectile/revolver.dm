/obj/item/gun/projectile/revolver
	name = "\improper .357 magnum revolver"
	desc = "A powerful revolver commonly used by the Syndicate. Uses .357 magnum ammo."
	materials = list()
	icon = 'icons/tgmc/objects/guns.dmi'
	icon_state = "revolver"
	inhand_icon_state = "revolver"
	lefthand_file = 'icons/tgmc/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/tgmc/mob/inhands/guns_righthand.dmi'
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder
	origin_tech = "combat=3;materials=2"
	fire_sound = 'sound/weapons/gunshots/gunshot_strong.ogg'
	can_holster = TRUE
	execution_speed = 5 SECONDS

/obj/item/gun/projectile/revolver/examine(mob/user)
	. = ..()
	. += "[get_ammo(0, 0)] of those are live rounds."
	. += "<span class='notice'>You can <b>Alt-Click</b> [src] to spin it's barrel.</span>"

/obj/item/gun/projectile/revolver/chamber_round(spin = 1)
	if(spin)
		chambered = magazine.get_round(1)
	else
		chambered = magazine.stored_ammo[1]
	return

/obj/item/gun/projectile/revolver/shoot_with_empty_chamber(mob/living/user as mob|obj)
	..()
	chamber_round(1)

/obj/item/gun/projectile/revolver/process_chamber()
	return ..(0, 1)

/obj/item/gun/projectile/revolver/attackby__legacy__attackchain(obj/item/A, mob/user, params)
	. = ..()
	if(istype(A, /obj/item/ammo_box/b357))
		return
	if(.)
		return
	var/num_loaded = magazine.attackby__legacy__attackchain(A, user, params, 1)
	if(num_loaded)
		to_chat(user, "<span class='notice'>You load [num_loaded] shell\s into \the [src].</span>")
		A.update_icon()
		update_icon()
		chamber_round(0)

/obj/item/gun/projectile/revolver/attack_self__legacy__attackchain(mob/living/user)
	var/num_unloaded = 0
	chambered = null
	while(get_ammo() > 0)
		var/obj/item/ammo_casing/CB
		CB = magazine.get_round(0)
		if(CB)
			CB.loc = get_turf(loc)
			CB.SpinAnimation(10, 1)
			CB.update_icon()
			playsound(get_turf(CB), "casingdrop", 60, 1)
			num_unloaded++
	if(num_unloaded)
		to_chat(user, "<span class='notice'>You unload [num_unloaded] shell\s from [src].</span>")
	else
		to_chat(user, "<span class='warning'>[src] is empty!</span>")

/obj/item/gun/projectile/revolver/AltClick(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return

	if(!istype(magazine, /obj/item/ammo_box/magazine/internal/cylinder))
		return ..()
	var/obj/item/ammo_box/magazine/internal/cylinder/C = magazine
	C.spin()
	chamber_round(0)
	playsound(get_turf(user), 'sound/weapons/revolver_spin.ogg', 50, TRUE)
	user.visible_message("<span class='warning'>[user] spins [src]'s chamber.</span>", "<span class='notice'>You spin [src]'s chamber.</span>")

/obj/item/gun/projectile/revolver/can_shoot()
	return get_ammo(0,0)

/obj/item/gun/projectile/revolver/get_ammo(countchambered = 0, countempties = 1)
	var/boolets = 0 //mature var names for mature people
	if(chambered && countchambered)
		boolets++
	if(magazine)
		boolets += magazine.ammo_count(countempties)
	return boolets

/obj/item/gun/projectile/revolver/fake

/obj/item/gun/projectile/revolver/fake/examine(mob/user)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_CLUMSY))
		. += "<span class='sans'>Its mechanism seems to shoot backwards.</span>"

/obj/item/gun/projectile/revolver/fake/process_fire(atom/target, mob/living/carbon/human/user, message, params, zone_override, bonus_spread)
	var/zone = "chest"
	if(user.has_organ("head"))
		zone = "head"
	add_fingerprint(user)
	if(!chambered)
		shoot_with_empty_chamber(user)
		return
	if(!chambered.fire(target = user, user = user, params = params, distro = null, quiet = suppressed, zone_override = zone, spread = 0, firer_source_atom = src))
		shoot_with_empty_chamber(user)
		return
	process_chamber()
	update_icon()
	playsound(src, 'sound/weapons/gunshots/gunshot_strong.ogg', 50, TRUE)
	user.visible_message("<span class='danger'>[src] goes off!</span>")
	to_chat(user, "<span class='danger'>[src] did look pretty dodgey!</span>")
	SEND_SOUND(user, sound('sound/misc/sadtrombone.ogg')) //HONK
	user.apply_damage(300, BRUTE, zone, sharp = TRUE, used_weapon = "Self-inflicted gunshot wound to the [zone].")
	user.bleed(BLOOD_VOLUME_NORMAL)
	user.death() // Just in case

/// Summoned by the Finger Gun spell, from advanced mimery traitor item
/obj/item/gun/projectile/revolver/fingergun
	name = "finger gun"
	desc = "Bang bang bang!"
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "fingergun"
	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'
	force = 0
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev38/invisible
	origin_tech = ""
	flags = ABSTRACT | NODROP | DROPDEL
	slot_flags = null
	fire_sound = null
	fire_sound_text = null
	lefthand_file = null
	righthand_file = null
	can_holster = FALSE // Get your fingers out of there!
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL
	clumsy_check = FALSE //Stole your uplink! Honk!
	needs_permit = FALSE //go away beepsky
	var/datum/spell/mime/fingergun/parent_spell

/obj/item/gun/projectile/revolver/fingergun/Destroy()
	if(parent_spell)
		parent_spell.current_gun = null
		parent_spell.UnregisterSignal(parent_spell.action.owner, COMSIG_MOB_WILLINGLY_DROP)
		parent_spell = null
	return ..()

/obj/item/gun/projectile/revolver/fingergun/fake
	desc = "Pew pew pew!"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev38/invisible/fake

/obj/item/gun/projectile/revolver/fingergun/Initialize(mapload, new_parent_spell)
	. = ..()
	parent_spell = new_parent_spell

/obj/item/gun/projectile/revolver/fingergun/AltClick(mob/user) // can't spin a barrel that doesn't exist!
	return

/obj/item/gun/projectile/revolver/fingergun/shoot_with_empty_chamber(/*mob/living/user as mob|obj*/)
	to_chat(usr, "<span class='warning'>You are out of ammo! You holster your fingers.</span>")
	qdel(src)
	return

/obj/item/gun/projectile/revolver/fingergun/afterattack__legacy__attackchain(atom/target, mob/living/user, flag, params)
	if(!user.mind.miming)
		to_chat(usr, "<span class='warning'>You must dedicate yourself to silence first. Use your fingers if you wish to holster them.</span>")
		return
	..()

/obj/item/gun/projectile/revolver/fingergun/attackby__legacy__attackchain(obj/item/A, mob/user, params)
	return

/obj/item/gun/projectile/revolver/fingergun/attack_self__legacy__attackchain(mob/living/user)
	to_chat(usr, "<span class='notice'>You holster your fingers. Another time.</span>")
	qdel(src)
	return

/obj/item/gun/projectile/revolver/mateba
	name = "\improper Unica 6 auto-revolver"
	desc = "A retro high-powered autorevolver typically used by officers of several unrelated militaries. Uses .357 ammo."	//>10mm hole >.357
	icon_state = "mateba"
	inhand_icon_state = "mateba"

/obj/item/gun/projectile/revolver/golden
	name = "\improper Golden revolver"
	desc = "This ain't no game, ain't never been no show, And I'll gladly gun down the oldest lady you know. Uses .357 ammo."
	icon = 'icons/tgmc/objects/guns64.dmi'
	icon_state = "goldrevolver"
	inhand_icon_state = "goldrevolver"
	fire_sound = 'sound/weapons/resonator_blast.ogg'
	recoil = 8

/obj/item/gun/projectile/revolver/nagant
	name = "\improper Nagant revolver"
	desc = "An old model of revolver that originated in Russia, now used by the USSP. Able to be suppressed. Uses 7.62x38mmR ammo."
	icon_state = "nagant"
	inhand_icon_state = "nagant"
	origin_tech = "combat=3"
	can_suppress = TRUE
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev762

/obj/item/gun/projectile/revolver/nagant/update_overlays()
	. = list()
	if(suppressed)
		. += image(icon = 'icons/obj/guns/attachments.dmi', icon_state = "suppressor_attached", pixel_x = 15, pixel_y = 6)

/obj/item/gun/projectile/revolver/overgrown
	name = "overgrown revolver"
	desc = "A bulky revolver that seems to be made out of a plant."
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "pea_shooter"
	inhand_icon_state = "peashooter"
	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	origin_tech = "combat=3;biotech=5"
	mag_type = /obj/item/ammo_box/magazine/internal/overgrown

/obj/item/gun/projectile/revolver/capgun
	name = "cap gun"
	desc = "Looks almost like the real thing! Ages 8 and up."
	origin_tech = null
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/cap

/obj/item/gun/projectile/revolver/capgun/chaosprank
	name = "\improper .357 revolver"

/obj/item/gun/projectile/revolver/capgun/chaosprank/shoot_with_empty_chamber(mob/living/user)
	to_chat(user, "<span class='chaosbad'>[src] vanishes in a puff of smoke!</span>")
	playsound(src, 'sound/items/bikehorn.ogg')
	qdel(src)

/////////////////////////////
// DOUBLE BARRELED SHOTGUN //
/////////////////////////////

/obj/item/gun/projectile/revolver/doublebarrel
	name = "\improper CM150 double-barreled shotgun"
	desc = "A true classic, by Starstrike Arms."
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "dbshotgun"
	worn_icon_state = null
	inhand_icon_state = null
	lefthand_file = 'icons/mob/inhands/64x64_guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_guns_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	force = 10
	slot_flags = ITEM_SLOT_BACK
	mag_type = /obj/item/ammo_box/magazine/internal/shot/dual
	fire_sound = 'sound/weapons/gunshots/gunshot_shotgun.ogg'
	sawn_desc = "Omar's coming!"
	can_holster = FALSE
	unique_reskin = TRUE
	var/can_sawoff = TRUE

/obj/item/gun/projectile/revolver/doublebarrel/Initialize(mapload)
	. = ..()
	options["Default"] = "dbshotgun"
	options["Dark Red Finish"] = "dbshotgun_d"
	options["Ash"] = "dbshotgun_f"
	options["Faded Grey"] = "dbshotgun_g"
	options["Maple"] = "dbshotgun_l"
	options["Rosewood"] = "dbshotgun_p"

/obj/item/gun/projectile/revolver/doublebarrel/attackby__legacy__attackchain(obj/item/A, mob/user, params)
	if(istype(A, /obj/item/ammo_box) || istype(A, /obj/item/ammo_casing))
		chamber_round()
	if(!can_sawoff)
		return ..()
	if(istype(A, /obj/item/melee/energy))
		var/obj/item/melee/energy/W = A
		if(HAS_TRAIT(W, TRAIT_ITEM_ACTIVE))
			sawoff(user)
	if(istype(A, /obj/item/circular_saw) || istype(A, /obj/item/gun/energy/plasmacutter))
		sawoff(user)
	else
		return ..()

/obj/item/gun/projectile/revolver/doublebarrel/sawoff(mob/user)
	. = ..()
	weapon_weight = WEAPON_MEDIUM

/obj/item/gun/projectile/revolver/doublebarrel/attack_self__legacy__attackchain(mob/living/user)
	var/num_unloaded = 0

	while(get_ammo() > 0)
		var/obj/item/ammo_casing/CB
		CB = magazine.get_round(0)
		chambered = null
		CB.loc = get_turf(loc)
		CB.SpinAnimation(10, 1)
		CB.update_icon()
		playsound(get_turf(CB), 'sound/weapons/gun_interactions/shotgun_fall.ogg', 70, 1)
		num_unloaded++

	if(sleight_of_handling(user))
		return

	if(num_unloaded)
		to_chat(user, "<span class='notice'>You break open [src] and unload [num_unloaded] shell\s.</span>")
	else
		to_chat(user, "<span class='notice'>[src] is empty.</span>")

/obj/item/gun/projectile/revolver/doublebarrel/proc/sleight_of_handling(mob/living/carbon/human/user)
	if(!istype(get_area(user), /area/station/service/bar))
		return FALSE
	if(!istype(user) || !HAS_MIND_TRAIT(user, TRAIT_SLEIGHT_OF_HAND))
		return FALSE
	if(!istype(user.belt, /obj/item/storage/belt/bandolier))
		return FALSE
	var/obj/item/storage/belt/bandolier/our_bandolier = user.belt

	var/loaded_shells = 0
	for(var/obj/item/ammo_casing/shotgun/shell in our_bandolier)
		if(loaded_shells == magazine.max_ammo)
			break

		our_bandolier.remove_from_storage(shell)
		magazine.give_round(shell)
		chamber_round()

		loaded_shells++

	if(loaded_shells)
		to_chat(user, "<span class='notice'>You quickly load [loaded_shells] shell\s from your bandolier into [src].</span>")
	return TRUE

// IMPROVISED SHOTGUN //

/obj/item/gun/projectile/revolver/doublebarrel/improvised
	name = "improvised shotgun"
	desc = "Essentially a tube that aims shotgun shells."
	icon_state = "ishotgun"
	slot_flags = null
	mag_type = /obj/item/ammo_box/magazine/internal/shot/improvised
	sawn_desc = "I'm just here for the gasoline."
	unique_reskin = FALSE
	var/sling = FALSE

/obj/item/gun/projectile/revolver/doublebarrel/improvised/attackby__legacy__attackchain(obj/item/A, mob/user, params)
	..()
	if(istype(A, /obj/item/stack/cable_coil) && !sawn_state)
		var/obj/item/stack/cable_coil/C = A
		if(sling)
			to_chat(user, "<span class='warning'>The shotgun already has a sling!</span>")
		else if(C.use(10))
			slot_flags = ITEM_SLOT_BACK
			to_chat(user, "<span class='notice'>You tie the lengths of cable to the shotgun, making a sling.</span>")
			sling = TRUE
			update_icon()
		else
			to_chat(user, "<span class='warning'>You need at least ten lengths of cable if you want to make a sling!</span>")

/obj/item/gun/projectile/revolver/doublebarrel/improvised/update_icon_state()
	icon_state = "ishotgun[sling ? "_sling" : sawn_state == SAWN_OFF ? "_sawn" : ""]"

/obj/item/gun/projectile/revolver/doublebarrel/improvised/sawoff(mob/user)
	. = ..()
	if(. && sling) //sawing off the gun removes the sling
		new /obj/item/stack/cable_coil(get_turf(src), 10)
		sling = FALSE
		update_icon(UPDATE_ICON_STATE)

//caneshotgun

/obj/item/gun/projectile/revolver/doublebarrel/improvised/cane
	name = "cane"
	desc = "A cane used by a true gentleman. Or a clown."
	icon = 'icons/obj/items.dmi'
	icon_state = "cane"
	worn_icon_state = null
	inhand_icon_state = "stick"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	sawn_state = SAWN_OFF
	w_class = WEIGHT_CLASS_SMALL
	can_unsuppress = FALSE
	origin_tech = "" // NO GIVAWAYS
	mag_type = /obj/item/ammo_box/magazine/internal/shot/improvised/cane
	sawn_desc = "I'm sorry, but why did you saw your cane in the first place?"
	attack_verb = list("bludgeoned", "whacked", "disciplined", "thrashed")
	fire_sound = 'sound/weapons/gunshots/gunshot_silenced.ogg'
	suppressed = TRUE
	needs_permit = FALSE //its just a cane beepsky.....

/obj/item/gun/projectile/revolver/doublebarrel/improvised/cane/get_crutch_efficiency()
	return 2

/obj/item/gun/projectile/revolver/doublebarrel/improvised/cane/update_icon_state()
	return

/obj/item/gun/projectile/revolver/doublebarrel/improvised/cane/attackby__legacy__attackchain(obj/item/A, mob/user, params)
	if(istype(A, /obj/item/stack/cable_coil))
		return
	else
		return ..()

/obj/item/gun/projectile/revolver/doublebarrel/improvised/cane/examine(mob/user)
	// So that it is stealthy
	return build_base_description()

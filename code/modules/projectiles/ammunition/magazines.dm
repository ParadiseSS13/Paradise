/obj/item/ammo_box/magazine
	icon_state = null

////////////////INTERNAL MAGAZINES//////////////////////
/obj/item/ammo_box/magazine/internal
	desc = "Oh god, this shouldn't be here!"

//internals magazines are accessible, so replace spent ammo if full when trying to put a live one in
/obj/item/ammo_box/magazine/internal/give_round(obj/item/ammo_casing/R)
	return ..(R,1)

// Revolver internal mags
/obj/item/ammo_box/magazine/internal/cylinder
	name = "revolver cylinder"
	ammo_type = /obj/item/ammo_casing/a357
	caliber = "357"


/obj/item/ammo_box/magazine/internal/cylinder/ammo_count(countempties = 1)
	var/boolets = 0
	for(var/obj/item/ammo_casing/bullet in stored_ammo)
		if(bullet && (bullet.BB || countempties))
			boolets++
	return boolets

/obj/item/ammo_box/magazine/internal/cylinder/get_round(keep = 0)
	rotate()

	var/b = stored_ammo[1]
	if(!keep)
		stored_ammo[1] = null

	return b

/obj/item/ammo_box/magazine/internal/cylinder/proc/rotate()
	var/b = stored_ammo[1]
	stored_ammo.Cut(1,2)
	stored_ammo.Insert(0, b)

/obj/item/ammo_box/magazine/internal/cylinder/proc/spin()
	for(var/i in 1 to rand(0, max_ammo*2))
		rotate()

/obj/item/ammo_box/magazine/internal/cylinder/give_round(obj/item/ammo_casing/R, replace_spent = 0)
	if(!R || (caliber && R.caliber != caliber) || (!caliber && R.type != ammo_type))
		return FALSE

	for(var/i in 1 to length(stored_ammo))
		var/obj/item/ammo_casing/bullet = stored_ammo[i]
		if(!bullet || !bullet.BB) // found a spent ammo
			stored_ammo[i] = R
			R.forceMove(src)

			if(bullet)
				bullet.forceMove(get_turf(loc))
			return TRUE

	return FALSE

/obj/item/ammo_box/magazine/internal/cylinder/charons_special
	name = "\improper Charon's Special revolver cylinder"
	ammo_type = /obj/item/ammo_casing/huntsman32
	caliber = "32"

/obj/item/ammo_box/magazine/internal/cylinder/rev38/invisible
	name = "finger gun cylinder"
	desc = "Wait, what?"
	max_ammo = 3
	ammo_type = /obj/item/ammo_casing/c38/invisible

/obj/item/ammo_box/magazine/internal/cylinder/rev38/invisible/fake
	ammo_type = /obj/item/ammo_casing/c38/invisible/fake

/obj/item/ammo_box/magazine/internal/cylinder/rev762
	name = "nagant revolver cylinder"
	ammo_type = /obj/item/ammo_casing/n762
	caliber = "n762"

/obj/item/ammo_box/magazine/internal/cylinder/cap
	name = "cap gun revolver cylinder"
	ammo_type = /obj/item/ammo_casing/cap
	caliber = "cap"

/obj/item/ammo_box/magazine/internal/overgrown
	name = "overgrown revolver cylinder"
	ammo_type = /obj/item/ammo_casing/overgrown
	max_ammo = 8

// Shotgun internal mags
/obj/item/ammo_box/magazine/internal/shot
	name = "shotgun internal magazine"
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag
	caliber = "shotgun"
	max_ammo = 4
	multiload = 0

/obj/item/ammo_box/magazine/internal/shot/ammo_count(countempties = 1)
	if(!countempties)
		var/boolets = 0
		for(var/obj/item/ammo_casing/bullet in stored_ammo)
			if(bullet.BB)
				boolets++
		return boolets
	else
		return ..()

/obj/item/ammo_box/magazine/internal/shot/tube
	name = "dual feed shotgun internal tube"
	ammo_type = /obj/item/ammo_casing/shotgun/rubbershot

/obj/item/ammo_box/magazine/internal/shot/lethal
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot

/obj/item/ammo_box/magazine/internal/shot/com
	name = "combat shotgun internal magazine"
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/shot/com/confetti
	ammo_type = /obj/item/ammo_casing/shotgun/confetti

/obj/item/ammo_box/magazine/internal/shot/malf
	name = "cyborg shotgun internal magazine"
	ammo_type = /obj/item/ammo_casing/shotgun/lasershot
	max_ammo = 8

/obj/item/ammo_box/magazine/internal/shot/dual
	name = "double-barrel shotgun internal magazine"
	max_ammo = 2

/obj/item/ammo_box/magazine/internal/shot/improvised
	name = "improvised shotgun internal magazine"
	ammo_type = /obj/item/ammo_casing/shotgun/rubbershot
	max_ammo = 1

/obj/item/ammo_box/magazine/internal/shot/dueling_pistol
	name = "dueling pistol internal magazine"
	caliber = "50AE"
	ammo_type = /obj/item/ammo_casing/dueling
	max_ammo = 1

/obj/item/ammo_box/magazine/internal/shot/improvised/cane
	ammo_type = /obj/item/ammo_casing/shotgun/assassination

/obj/item/ammo_box/magazine/internal/shot/riot
	name = "riot shotgun internal magazine"
	ammo_type = /obj/item/ammo_casing/shotgun/rubbershot
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/shot/riot/short
	max_ammo = 3

/obj/item/ammo_box/magazine/internal/grenadelauncher
	name = "grenade launcher internal magazine"
	ammo_type = /obj/item/ammo_casing/a40mm
	caliber = "40mm"
	max_ammo = 1

/obj/item/ammo_box/magazine/internal/cylinder/grenadelauncher/multi
	ammo_type = /obj/item/ammo_casing/a40mm
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/cylinder/grenadelauncher/multi/fifteen
	max_ammo = 15

/obj/item/ammo_box/magazine/internal/speargun
	name = "speargun internal magazine"
	ammo_type = /obj/item/ammo_casing/caseless/magspear
	caliber = "speargun"
	max_ammo = 1

/obj/item/ammo_box/magazine/internal/rus357
	name = "russian revolver cylinder"
	ammo_type = /obj/item/ammo_casing/a357
	caliber = "357"
	max_ammo = 6
	multiload = 0

/obj/item/ammo_box/magazine/internal/rus357/Initialize(mapload)
	. = ..()
	stored_ammo.Cut() // We only want 1 bullet in there
	stored_ammo += new ammo_type(src)

/obj/item/ammo_box/magazine/internal/boltaction
	name = "bolt action rifle internal magazine"
	ammo_type = /obj/item/ammo_casing/a762
	caliber = "a762"
	max_ammo = 5

/obj/item/ammo_box/magazine/internal/boltaction/enchanted
	max_ammo = 1
	ammo_type = /obj/item/ammo_casing/a762/enchanted

/obj/item/ammo_box/magazine/internal/shot/toy
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart
	caliber = "foam_force"

/obj/item/ammo_box/magazine/internal/shot/toy/crossbow
	max_ammo = 5

/obj/item/ammo_box/magazine/internal/shot/toy/tommygun
	max_ammo = 10

///////////EXTERNAL MAGAZINES////////////////
/obj/item/ammo_box/magazine/m10mm
	name = "pistol magazine (10mm)"
	desc = "An 8-round pistol magazine that holds 10mm rounds."
	icon = 'icons/tgmc/objects/ammo.dmi'
	icon_state = "9x19p"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c10mm
	caliber = "10mm"
	max_ammo = 8
	multi_sprite_step = AMMO_BOX_MULTI_SPRITE_STEP_ON_OFF

/obj/item/ammo_box/magazine/m10mm/fire
	name = "pistol magazine (10mm incendiary)"
	icon_state = "9x19pI"
	desc = "An 8-round pistol magazine that holds 10mm rounds. Pre-loaded with incendiary rounds which set the target on fire."
	ammo_type = /obj/item/ammo_casing/c10mm/fire

/obj/item/ammo_box/magazine/m10mm/hp
	name = "pistol magazine (10mm HP)"
	icon_state = "9x19pH"
	desc= "An 8-round pistol magazine that holds 10mm rounds. Pre-loaded with hollow-point rounds, extremely effective against unarmored targets, but nearly useless against protective clothing."
	ammo_type = /obj/item/ammo_casing/c10mm/hp

/obj/item/ammo_box/magazine/m10mm/ap
	name = "pistol magazine (10mm AP)"
	icon_state = "9x19pA"
	desc = "An 8-round pistol magazine that holds 10mm rounds. Pre-loaded with rounds which are better against armoured targets, but are less effective against unarmoured targets."
	ammo_type = /obj/item/ammo_casing/c10mm/ap

/obj/item/ammo_box/magazine/m45
	name = "pistol magazine (.45 Auto)"
	icon = 'icons/tgmc/objects/ammo.dmi'
	icon_state = "45"
	desc = "An 8-round magazine for the M1911 pistol that holds .45 Auto rounds."
	ammo_type = /obj/item/ammo_casing/c45
	caliber = ".45"
	max_ammo = 8
	multi_sprite_step = AMMO_BOX_MULTI_SPRITE_STEP_ON_OFF

/obj/item/ammo_box/magazine/enforcer
	name = "\improper Enforcer pistol magazine (9mm rubber)"
	icon = 'icons/tgmc/objects/ammo.dmi'
	icon_state = "enforcer"
	desc = "An 8-round magazine for the Enforcer pistol that holds 9mm rounds. Pre-loaded with less-lethal rubber bullets."
	ammo_type = /obj/item/ammo_casing/rubber9mm
	max_ammo = 8
	caliber = "9mm"
	multi_sprite_step = AMMO_BOX_MULTI_SPRITE_STEP_ON_OFF

/obj/item/ammo_box/magazine/enforcer/update_overlays()
	. = ..()
	var/ammo = ammo_count()
	if(ammo && is_rubber())
		. += image('icons/tgmc/objects/ammo.dmi', icon_state = "enforcer-r")

/obj/item/ammo_box/magazine/enforcer/examine(mob/user)
	. = ..()
	if(get_dist(user, src) <= 2)
		. += "It seems to be loaded with [is_rubber() ? "rubber" : "lethal"] bullets."//only can see the topmost one.

/obj/item/ammo_box/magazine/enforcer/proc/is_rubber()//if the topmost bullet is a rubber one
	var/ammo = ammo_count()
	if(!ammo)
		return FALSE
	if(istype(contents[length(contents)], /obj/item/ammo_casing/rubber9mm))
		return TRUE
	return FALSE

/obj/item/ammo_box/magazine/enforcer/lethal
	name = "\improper Enforcer pistol magazine (9mm)"
	desc = "An 8-round magazine for the Enforcer pistol that holds 9mm rounds."
	ammo_type = /obj/item/ammo_casing/c9mm

/obj/item/ammo_box/magazine/wt550m9
	name = "\improper WT-550 magazine (4.6x30mm)"
	icon_state = "46x30mmt"
	desc = "A 20-round top-loading magazine for the WT-550 PDW that holds 4.5x30mm rounds."
	ammo_type = /obj/item/ammo_casing/c46x30mm
	caliber = "4.6x30mm"
	max_ammo = 20
	multi_sprite_step = 4
	multiload = 0
	slow_loading = TRUE
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(MAT_METAL = 10000)
	///A var to check if the mag is being loaded
	var/being_loaded = FALSE
	/// There are two reloading processes ongoing so cancel them
	var/double_loaded = FALSE

/obj/item/ammo_box/magazine/wt550m9/load_box(obj/item/used, mob/living/user, silent = FALSE)
	if(istype(used, /obj/item/ammo_casing))
		var/obj/item/ammo_casing/used_casing = used
		if(give_round(used_casing))
			user.transfer_item_to(used_casing, src)
		return

	if(!(istype(used, /obj/item/ammo_box/wt550) || istype(used, /obj/item/ammo_box/magazine/wt550m9)))
		return

	to_chat(user, SPAN_NOTICE("You begin to load the magazine with [used]."))
	var/obj/item/ammo_box/used_box = used

	for(var/obj/item/ammo_casing/used_casing in used_box.stored_ammo)
		if(length(stored_ammo) >= max_ammo)
			to_chat(user, SPAN_NOTICE("You stop loading the magazine with [used]."))
			break

		if(!do_after_once(user, 0.5 SECONDS, target = src, allow_moving = TRUE, must_be_held = TRUE, attempt_cancel_message = SPAN_NOTICE("You stop loading the magazine with [used].")))
			break

		src.give_round(used_casing)
		used_box.stored_ammo -= used_casing
		update_mat_value()
		update_appearance(UPDATE_DESC|UPDATE_ICON_STATE)
		used_box.update_appearance(UPDATE_DESC|UPDATE_ICON_STATE)
		playsound(src, 'sound/weapons/gun_interactions/bulletinsert.ogg', 50, 1)

/obj/item/ammo_box/magazine/wt550m9/wtap
	name = "\improper WT-550 magazine (4.6x30mm AP)"
	icon_state = "46x30mmtA"
	desc = "A 20-round top-loading magazine for the WT-550 PDW that holds 4.5x30mm rounds. Pre-loaded with rounds which are better against armoured targets, but are less effective against unarmoured targets."
	ammo_type = /obj/item/ammo_casing/c46x30mm/ap

/obj/item/ammo_box/magazine/wt550m9/wttx
	name = "\improper WT-550 magazine (4.6x30mm Toxin-Tipped)"
	icon_state = "46x30mmtT"
	desc = "A 20-round top-loading magazine for the WT-550 PDW that holds 4.5x30mm rounds. Pre-loaded with rounds tipped with a toxic payload. \
	Less damaging than standard rounds, but standard trauma treatments will not heal the damage they cause."
	ammo_type = /obj/item/ammo_casing/c46x30mm/tox

/obj/item/ammo_box/magazine/wt550m9/wtic
	name = "\improper WT-550 magazine (4.6x30mm Incendiary)"
	icon_state = "46x30mmtI"
	desc = "A 20-round top-loading magazine for the WT-550 PDW that holds 4.5x30mm rounds. Pre-loaded with incendiary rounds which set the target on fire."
	ammo_type = /obj/item/ammo_casing/c46x30mm/inc

/obj/item/ammo_box/magazine/wt550m9/empty

/obj/item/ammo_box/magazine/wt550m9/empty/Initialize(mapload)
	. = ..()
	stored_ammo.Cut()
	update_appearance(UPDATE_DESC|UPDATE_ICON)

/obj/item/ammo_box/magazine/uzim9mm
	name = "\improper Uzi SMG magazine (9mm)"
	icon = 'icons/tgmc/objects/ammo.dmi'
	icon_state = "uzi9mm"
	desc = "A 32-round magazine for the Uzi submachine gun that holds 9mm rounds."
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "9mm"
	max_ammo = 32
	multi_sprite_step = AMMO_BOX_MULTI_SPRITE_STEP_ON_OFF

/obj/item/ammo_box/magazine/smgm9mm
	name = "\improper Uzi SMG magazine (9mm)"
	icon_state = "smg9mm"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "9mm"
	max_ammo = 21
	materials = list(MAT_METAL = 2000)
	multi_sprite_step = 4

/obj/item/ammo_box/magazine/smgm9mm/ap
	name = "\improper Uzi SMG magazine (9mm AP)"
	desc = "A 32-round magazine for the Uzi submachine gun that holds 9mm rounds. Pre-loaded with rounds which are better against armoured targets, but are less effective against unarmoured targets."
	ammo_type = /obj/item/ammo_casing/c9mm/ap
	materials = list(MAT_METAL = 3000)

/obj/item/ammo_box/magazine/smgm9mm/toxin
	name = "\improper Uzi SMG magazine (9mm Toxin-Tipped)"
	desc = "A 32-round magazine for the Uzi submachine gun that holds 9mm rounds. Pre-loaded with rounds tipped with a toxic payload. \
	Less damaging than standard rounds, but standard trauma treatments will not heal the damage they cause."
	ammo_type = /obj/item/ammo_casing/c9mm/tox
	materials = list(MAT_METAL = 3000)

/obj/item/ammo_box/magazine/smgm9mm/fire
	name = "\improper Uzi SMG Magazine (9mm Incendiary)"
	desc = "A 32-round magazine for the Uzi submachine gun that holds 9mm rounds. Pre-loaded with incendiary rounds which set the target on fire."
	ammo_type = /obj/item/ammo_casing/c9mm/inc
	materials = list(MAT_METAL = 3000)

/obj/item/ammo_box/magazine/apsm10mm
	name = "\improper Type 230 magazine (10mm)"
	icon = 'icons/tgmc/objects/ammo.dmi'
	icon_state = "10mmaps"
	desc = "A 20-round magazine for the Type 230 machine pistol that holds 10mm rounds."
	ammo_type = /obj/item/ammo_casing/c10mm
	caliber = "10mm"
	max_ammo = 20
	multi_sprite_step = AMMO_BOX_MULTI_SPRITE_STEP_ON_OFF

/obj/item/ammo_box/magazine/apsm10mm/fire
	name = "\improper Type 230 magazine (10mm incendiary)"
	icon_state = "10mmapsI"
	desc = "A 20-round magazine for the Type 230 machine pistol that holds 10mm rounds. Pre-loaded with incendiary rounds which set the target on fire."
	ammo_type = /obj/item/ammo_casing/c10mm/fire

/obj/item/ammo_box/magazine/apsm10mm/hp
	name = "\improper Type 230 magazine (10mm HP)"
	icon_state = "10mmapsH"
	desc = "A 20-round magazine for the Type 230 machine pistol that holds 10mm rounds. Pre-loaded with hollow-point rounds, extremely effective against unarmored targets, but nearly useless against protective clothing."
	ammo_type = /obj/item/ammo_casing/c10mm/hp

/obj/item/ammo_box/magazine/apsm10mm/ap
	name = "\improper Type 230 magazine (10mm AP)"
	icon_state = "10mmapsA"
	desc = "A 20-round magazine for the Type 230 machine pistol that holds 10mm rounds. Pre-loaded with rounds which are better against armoured targets, but are less effective against unarmoured targets."
	ammo_type = /obj/item/ammo_casing/c10mm/ap

/obj/item/ammo_box/magazine/smgm45
	name = "\improper C-20R magazine (.45 Auto)"
	icon_state = "c20r45"
	desc = "A 20-round magazine for the C-20R submachine gun that holds .45 auto rounds."
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = ".45"
	max_ammo = 20
	multi_sprite_step = 2

/obj/item/ammo_box/magazine/tommygunm45
	name = "\improper Thompson drum magazine (.45 Auto)"
	icon_state = "drum45"
	desc = "A 50-round magazine for the Thompson submachine gun that holds .45 auto rounds."
	ammo_type = /obj/item/ammo_casing/c45/nostamina
	caliber = ".45"
	max_ammo = 50

/obj/item/ammo_box/magazine/m50
	name = "pistol magazine (.50 AE)"
	icon_state = "50ae"
	desc = "An 8-round magazine for the Deasert Eagle pistol that holds .50 Action Express rounds."
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/a50
	caliber = ".50"
	multi_sprite_step = 1

/obj/item/ammo_box/magazine/m75
	name = "specialized magazine (.75 gyrojet)"
	desc = "An 8-round magazine for the MX-2000 gyrojet pistol that holds .75 gyrojet rounds."
	ammo_type = /obj/item/ammo_casing/caseless/a75
	caliber = "75"
	multi_sprite_step = AMMO_BOX_MULTI_SPRITE_STEP_ON_OFF
	max_ammo = 8

/obj/item/ammo_box/magazine/m556
	name = "\improper M-90 toploader magazine (5.56mm)"
	icon_state = "5.56m"
	desc = "A 30-round top-loading magazine for the M-90 PDW that holds 5.56mm rounds."
	origin_tech = "combat=5;syndicate=1"
	ammo_type = /obj/item/ammo_casing/a556
	caliber = "a556"
	max_ammo = 30
	multi_sprite_step = AMMO_BOX_MULTI_SPRITE_STEP_ON_OFF

/obj/item/ammo_box/magazine/m556/arg
	name = "\improper M26 assault rifle magazine (5.56mm)"
	desc = "A 30-round Standardized Equipment model magazine for the M26 assault rifle that holds 5.56mm rounds."
	icon_state = "arg"

/obj/item/ammo_box/magazine/ak814
	name = "\improper AK magazine (5.45x39mm)"
	desc = "A 30-round magazine for AK platform rifles that holds 5.45x39mm rounds."
	icon_state = "ak814"
	origin_tech = "combat=5;syndicate=1"
	ammo_type = /obj/item/ammo_casing/a545
	caliber = "a545"
	max_ammo = 30
	multi_sprite_step = AMMO_BOX_MULTI_SPRITE_STEP_ON_OFF

/obj/item/ammo_box/magazine/m12g
	name = "shotgun magazine (12G slugs)"
	desc = "A drum magazine."
	icon_state = "m12gsl"
	desc = "An 8-round drum magazine for the M-12 'Bulldog' shotgun that holds 12G shotgun shells. Pre-loaded with slugs."
	ammo_type = /obj/item/ammo_casing/shotgun
	origin_tech = "combat=3;syndicate=1"
	caliber = "shotgun"
	max_ammo = 8
	multi_sprite_step = AMMO_BOX_MULTI_SPRITE_STEP_ON_OFF

/obj/item/ammo_box/magazine/m12g/buckshot
	name = "shotgun magazine (12G buckshot slugs)"
	icon_state = "m12gb"
	desc = "An 8-round drum magazine for the M-12 'Bulldog' shotgun that holds 12G shotgun shells. Pre-loaded with buckshot."
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot

/obj/item/ammo_box/magazine/m12g/rubbershot
	name = "shotgun magazine (12G rubbershot)"
	icon_state = "m12gb"
	desc = "An 8-round drum magazine for the M-12 'Bulldog' shotgun that holds 12G shotgun shells. Pre-loaded with less-lethal rubbershot."
	ammo_type = /obj/item/ammo_casing/shotgun/rubbershot

/obj/item/ammo_box/magazine/m12g/rubbershot/give_round(obj/item/ammo_casing/R, replace_spent)
	if(istype(R, /obj/item/ammo_casing/shotgun/frag12) || istype(R, /obj/item/ammo_casing/shotgun/buckshot))
		return FALSE
	return ..()

/obj/item/ammo_box/magazine/m12g/stun
	name = "shotgun magazine (12G taser slugs)"
	icon_state = "m12gs"
	desc = "An 8-round drum magazine for the M-12 'Bulldog' shotgun that holds 12G shotgun shells. Pre-loaded with less-lethal taser slugs that will stun targets."
	ammo_type = /obj/item/ammo_casing/shotgun/stunslug

/obj/item/ammo_box/magazine/m12g/dragon
	name = "shotgun magazine (12G dragon's breath)"
	icon_state = "m12gf"
	desc = "An 8-round drum magazine for the M-12 'Bulldog' shotgun that holds 12G shotgun shells. Pre-loaded with dragon's breath shells that will set targets on fire."
	ammo_type = /obj/item/ammo_casing/shotgun/incendiary/dragonsbreath

/obj/item/ammo_box/magazine/m12g/bioterror
	name = "shotgun magazine (12G bioterror)"
	icon_state = "m12gt"
	desc = "An 8-round drum magazine for the M-12 'Bulldog' shotgun that holds 12G shotgun shells. Pre-loaded with darts filed with bioterror toxin which will mute, disorent, paralyze, and poison targets."
	ammo_type = /obj/item/ammo_casing/shotgun/dart/bioterror

/obj/item/ammo_box/magazine/m12g/meteor
	name = "shotgun magazine (12G meteor slugs)"
	icon_state = "m12gbc"
	desc = "An 8-round drum magazine for the M-12 'Bulldog' shotgun that holds 12G shotgun shells. Pre-loaded with experimental bluespace shells that contain an oversized slug."
	ammo_type = /obj/item/ammo_casing/shotgun/meteorslug

/obj/item/ammo_box/magazine/m12g/xtr_lrg
	name = "\improper XL shotgun magazine (12G slugs)"
	desc = "A 16-round drum magazine for the M-12 'Bulldog' shotgun that holds 12G shotgun shells. Pre-loaded with experimental bluespace shells that contain an oversized slug."
	icon_state = "m12gXlSl"
	w_class = WEIGHT_CLASS_NORMAL
	max_ammo = 16

/obj/item/ammo_box/magazine/m12g/xtr_lrg/buckshot
	name = "\improper XL shotgun magazine (12g buckshot)"
	icon_state = "m12gXlBs"
	desc = "A 16-round drum magazine for the M-12 'Bulldog' shotgun that holds 12G shotgun shells. Pre-loaded with buckshot."
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot

/obj/item/ammo_box/magazine/m12g/xtr_lrg/dragon
	name = "\improper XL shotgun magazine (12g dragon's breath)"
	icon_state = "m12gXlDb"
	desc = "A 16-round drum magazine for the M-12 'Bulldog' shotgun that holds 12G shotgun shells. Pre-loaded with dragon's breath shells that will set targets on fire."
	ammo_type = /obj/item/ammo_casing/shotgun/incendiary/dragonsbreath

/obj/item/ammo_box/magazine/m12g/confetti
	name = "\improper XL shotgun magazine (12g confetti)"
	icon_state = "party_drum"
	desc = "A 16-round drum magazine for the M-12 'Bulldog' shotgun that holds 12G shotgun shells. Pre-loaded with harmless confetti shot for celebrations and pranks in equal measure."
	ammo_type = /obj/item/ammo_casing/shotgun/confetti

/obj/item/ammo_box/magazine/paintball
	name = "paintball magazine"
	desc = "A magazine that holds a large amount of paintballs."
	icon = 'icons/obj/guns/toy.dmi'
	icon_state = "paintballmag"
	ammo_type = /obj/item/ammo_casing/caseless/paintball
	caliber = "paintball"
	max_ammo = 25
	multi_sprite_step = AMMO_BOX_MULTI_SPRITE_STEP_ON_OFF

/obj/item/ammo_box/magazine/paintball/pepperball
	name = "pepperball magazine"
	desc = "A magazine that holds a large amount of pepperballs."
	icon_state = "pepperballmag"
	ammo_type = /obj/item/ammo_casing/caseless/pepperball
	caliber = "pepperball"
	max_ammo = 10

/obj/item/ammo_box/magazine/toy
	name = "generic toy gun magazine"
	desc = ABSTRACT_TYPE_DESC
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart
	caliber = "foam_force"

/obj/item/ammo_box/magazine/toy/smg
	name = "\improper Foam Force SMG magazine"
	icon_state = "smg9mm"
	desc = "A 20-round magazine for a Foam Force SMG. While the design is based off Nanotrasen's Saber SMG magazine, it can neither accept real 9mm rounds, nor will it fit inside a real Saber SMG."
	max_ammo = 20
	multi_sprite_step = 4

/obj/item/ammo_box/magazine/toy/smg/riot
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot

/obj/item/ammo_box/magazine/toy/pistol
	name = "\improper Foam Force pistol magazine"
	icon = 'icons/tgmc/objects/ammo.dmi'
	desc = "An 8-round magazine for a Foam Force pistol. While the desgin is based off real pistol magazines, it can neither accept real rounds, nor will it fit inside a real pistol."
	icon_state = "9x19p"
	max_ammo = 8
	multi_sprite_step = AMMO_BOX_MULTI_SPRITE_STEP_ON_OFF

/obj/item/ammo_box/magazine/toy/pistol/riot
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot

/obj/item/ammo_box/magazine/toy/enforcer
	name = "\improper Foam Force Enforcer magazine"
	icon = 'icons/tgmc/objects/ammo.dmi'
	icon_state = "enforcer"
	desc = "An 8-round magazine for a Foam Force Enforcer pistol. While the desgin is based off the Enforcer, it can neither accept real 9mm rounds, nor will it fit inside a real Enforcer pistol."
	max_ammo = 8
	multi_sprite_step = AMMO_BOX_MULTI_SPRITE_STEP_ON_OFF
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot

/obj/item/ammo_box/magazine/toy/enforcer/update_overlays()
	. = ..()
	var/ammo = ammo_count()
	if(ammo && is_riot())
		. += image('icons/tgmc/objects/ammo.dmi', icon_state = "enforcer-rd")
	else if(ammo)
		. += image('icons/tgmc/objects/ammo.dmi', icon_state = "enforcer-bd")

/obj/item/ammo_box/magazine/toy/enforcer/proc/is_riot()//if the topmost bullet is a riot dart
	var/ammo = ammo_count()
	if(!ammo)
		return FALSE
	if(istype(contents[length(contents)], /obj/item/ammo_casing/caseless/foam_dart/riot))
		return TRUE
	return FALSE

/obj/item/ammo_box/magazine/toy/m762
	name = "\improper Donksoft machine gun magazine"
	icon_state = "a762"
	desc = "A 50-round belt box magazine for a Donksoft machine gun. While the design is based on the L6 SAW, it can neither accept 7.62x51mm rounds, nor will fit in a real L6 SAW."
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot
	max_ammo = 50
	multi_sprite_step = 10

/obj/item/ammo_box/magazine/toy/m762/riot

/obj/item/ammo_box/magazine/laser
	name = "\improper IK-series laser magazine"
	desc = "A 20-round box magazine for IK-series laserarms that holds experimental laser ammo casings."
	icon_state = "laser"
	ammo_type = /obj/item/ammo_casing/caseless/laser
	origin_tech = "combat=3"
	caliber = "laser"
	max_ammo = 20
	multi_sprite_step = 5
	w_class = WEIGHT_CLASS_NORMAL

/// Used by red ERT. Keeps the size for them
/obj/item/ammo_box/magazine/laser/ert
	name = "\improper IK-series laser magazine (EMP-shielded, Miniturized)"
	desc = "A 20-round box magazine for IK-series laserarms that holds experimental laser ammo casings. Features EMP shielding to protect the ammunition inside, \
	and uses experimental bluespace technology to reduce its size to that of a cigarette lighter. Each magazine costs as much as 5 of the carbines that use it, \
	but nobody's accused Nanotrasen's budget allocation of being practical before."
	w_class = WEIGHT_CLASS_TINY

/obj/item/ammo_box/magazine/laser/ert/emp_act(severity)
	return

/obj/item/ammo_box/magazine/toy/smgm45
	name = "\improper Donksoft SMG magazine"
	icon_state = "c20r45"
	desc = "A 20-round magazine for a Donksoft SMG. While the design is based off the C-20R, it can neither accept real .45 auto rounds, nor will it fit inside a real C-20R."
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot
	max_ammo = 20
	multi_sprite_step = 2

/obj/item/ammo_box/magazine/toy/smgm45/riot

// Yes this doesn't really belong here but nowhere else works.
/obj/item/ammo_box/magazine/detective/speedcharger
	name = "\improper DL-88 charge pack"
	desc = "A single-use charge pack for the DL-88 energy revolver."
	icon_state = "handgun_ammo_battery"
	materials = list(MAT_METAL = 20000, MAT_GLASS = 6000)
	var/charge = 1000

// Overwrite description so shells aren't displayed
/obj/item/ammo_box/magazine/detective/speedcharger/update_desc()
	. = ..()
	desc = "[initial(desc)]"

/obj/item/ammo_box/magazine/detective/speedcharger/update_icon_state()
	return

/obj/item/ammo_box/magazine/detective/speedcharger/update_overlays()
	. = ..()
	var/charge_percent_rounded = round(charge_percent(), 20) // to the nearest 20%
	if(charge_percent_rounded)
		. += "hab_charge_[charge_percent_rounded]"

/obj/item/ammo_box/magazine/detective/speedcharger/proc/charge_percent()
	return (charge / initial(charge) * 100)

/obj/item/ammo_box/magazine/detective/speedcharger/examine()
	. = ..()
	. += SPAN_NOTICE("There is [charge_percent()]% charge left!")

/obj/item/ammo_box/magazine/detective/speedcharger/activate_self(mob/user)
	if(!user)
		return ..()
	return ITEM_INTERACT_COMPLETE

/obj/item/ammo_box/magazine/detective/speedcharger/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	return NONE

/obj/item/ammo_box/magazine/c_foam
	name = "\improper C-Foam canister"
	desc = "A canister containing inert foam for the C-Foam launcher. Big enough to hold 12 shots worth of foam."
	icon_state = "foam_canister"
	ammo_type = /obj/item/ammo_casing/caseless/c_foam
	max_ammo = 12

/obj/item/ammo_box/magazine/c_foam/activate_self(mob/user)
	if(!user)
		return ..()
	return ITEM_INTERACT_COMPLETE

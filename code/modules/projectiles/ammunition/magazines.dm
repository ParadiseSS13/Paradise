/obj/item/ammo_box/magazine
	icon_state = "enforcer" // placeholder icon

////////////////INTERNAL MAGAZINES//////////////////////
/obj/item/ammo_box/magazine/internal
	desc = "Oh god, this shouldn't be here"

//internals magazines are accessible, so replace spent ammo if full when trying to put a live one in
/obj/item/ammo_box/magazine/internal/give_round(obj/item/ammo_casing/R)
	return ..(R,1)

// Revolver internal mags
/obj/item/ammo_box/magazine/internal/cylinder
	name = "revolver cylinder"
	ammo_type = /obj/item/ammo_casing/a357
	caliber = "357"
	max_ammo = 7


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
		return 0

	for(var/i in 1 to length(stored_ammo))
		var/obj/item/ammo_casing/bullet = stored_ammo[i]
		if(!bullet || !bullet.BB) // found a spent ammo
			stored_ammo[i] = R
			R.loc = src

			if(bullet)
				bullet.loc = get_turf(loc)
			return 1

	return 0

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
	max_ammo = 7

/obj/item/ammo_box/magazine/internal/cylinder/cap
	name = "cap gun revolver cylinder"
	desc = "Oh god, this shouldn't be here"
	ammo_type = /obj/item/ammo_casing/cap
	caliber = "cap"
	max_ammo = 7

/obj/item/ammo_box/magazine/internal/overgrown
	name = "overgrown pistol magazine"
	desc = "Oh god, this shouldn't be here"
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
	max_ammo = 4

/obj/item/ammo_box/magazine/internal/shot/lethal
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot

/obj/item/ammo_box/magazine/internal/shot/com
	name = "combat shotgun internal magazine"
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/shot/dual
	name = "double-barrel shotgun internal magazine"
	max_ammo = 2

/obj/item/ammo_box/magazine/internal/shot/improvised
	name = "improvised shotgun internal magazine"
	ammo_type = /obj/item/ammo_casing/shotgun/improvised
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
	desc = "Oh god, this shouldn't be here"
	ammo_type = /obj/item/ammo_casing/a762
	caliber = "a762"
	max_ammo = 5
	multiload = 1

/obj/item/ammo_box/magazine/internal/boltaction/enchanted
	max_ammo =1
	ammo_type = /obj/item/ammo_casing/a762/enchanted

/obj/item/ammo_box/magazine/internal/shot/toy
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart
	caliber = "foam_force"
	max_ammo = 4

/obj/item/ammo_box/magazine/internal/shot/toy/crossbow
	max_ammo = 5

/obj/item/ammo_box/magazine/internal/shot/toy/tommygun
	max_ammo = 10

///////////EXTERNAL MAGAZINES////////////////

/obj/item/ammo_box/magazine/m10mm
	name = "pistol magazine (10mm)"
	desc = "A gun magazine."
	icon_state = "9x19p"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c10mm
	caliber = "10mm"
	max_ammo = 8
	multi_sprite_step = AMMO_MULTI_SPRITE_STEP_ON_OFF

/obj/item/ammo_box/magazine/m10mm/fire
	name = "pistol magazine (10mm incendiary)"
	icon_state = "9x19pI"
	desc = "A gun magazine. Loaded with rounds which ignite the target."
	ammo_type = /obj/item/ammo_casing/c10mm/fire

/obj/item/ammo_box/magazine/m10mm/hp
	name = "pistol magazine (10mm HP)"
	icon_state = "9x19pH"
	desc= "A gun magazine. Loaded with hollow-point rounds, extremely effective against unarmored targets, but nearly useless against protective clothing."
	ammo_type = /obj/item/ammo_casing/c10mm/hp

/obj/item/ammo_box/magazine/m10mm/ap
	name = "pistol magazine (10mm AP)"
	icon_state = "9x19pA"
	desc= "A gun magazine. Loaded with rounds which penetrate armour, but are less effective against normal targets"
	ammo_type = /obj/item/ammo_casing/c10mm/ap

/obj/item/ammo_box/magazine/m45
	name = "handgun magazine (.45)"
	icon_state = "45"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = ".45"
	max_ammo = 8
	multi_sprite_step = 1

/obj/item/ammo_box/magazine/enforcer
	name = "handgun magazine (9mm rubber)"
	icon_state = "enforcer"
	ammo_type = /obj/item/ammo_casing/rubber9mm
	max_ammo = 8
	multi_sprite_step = 1
	caliber = "9mm"

/obj/item/ammo_box/magazine/enforcer/update_overlays()
	. = ..()
	var/ammo = ammo_count()
	if(ammo && is_rubber())
		. += image('icons/obj/ammo.dmi', icon_state = "enforcer-r")

/obj/item/ammo_box/magazine/enforcer/examine(mob/user)
	. = ..()
	if(get_dist(user, src) <= 2)
		. += "It seems to be loaded with [is_rubber() ? "rubber" : "lethal"] bullets."//only can see the topmost one.

/obj/item/ammo_box/magazine/enforcer/proc/is_rubber()//if the topmost bullet is a rubber one
	var/ammo = ammo_count()
	if(!ammo)
		return 0
	if(istype(contents[length(contents)], /obj/item/ammo_casing/rubber9mm))
		return 1
	return 0

/obj/item/ammo_box/magazine/enforcer/lethal
	name = "handgun magazine (9mm)"
	ammo_type = /obj/item/ammo_casing/c9mm

/obj/item/ammo_box/magazine/wt550m9
	name = "wt550 magazine (4.6x30mm)"
	icon_state = "46x30mmt"
	ammo_type = /obj/item/ammo_casing/c46x30mm
	caliber = "4.6x30mm"
	max_ammo = 20
	multi_sprite_step = 4
	multiload = 0
	slow_loading = TRUE
	w_class = WEIGHT_CLASS_NORMAL
	///A var to check if the mag is being loaded
	var/being_loaded = FALSE
	/// There are two reloading processes ongoing so cancel them
	var/double_loaded = FALSE

/obj/item/ammo_box/magazine/wt550m9/attackby(obj/item/A, mob/user, params)
	if(istype(A, /obj/item/ammo_casing))
		var/obj/item/ammo_casing/AC = A
		if(give_round(AC))
			user.drop_item()
			AC.loc = src
			return
	if(istype(A, /obj/item/ammo_box/wt550) || istype(A, /obj/item/ammo_box/magazine/wt550m9))
		to_chat(user, "<span class='notice'>You begin to load the magazine with [A].</span>")
		var/obj/item/ammo_box/AB = A
		for(var/obj/item/ammo_casing/AC in AB.stored_ammo)
			if(length(stored_ammo) >= max_ammo)
				to_chat(user, "<span class='notice'>You stop loading the magazine with [A].</span>")
				break
			if(do_after_once(user, 0.5 SECONDS, target = src, allow_moving = TRUE, must_be_held = TRUE, attempt_cancel_message = "<span class='notice'>You stop loading the magazine with [A].</span>"))
				src.give_round(AC)
				AB.stored_ammo -= AC
				update_mat_value()
				update_appearance(UPDATE_DESC|UPDATE_ICON_STATE)
				AB.update_appearance(UPDATE_DESC|UPDATE_ICON_STATE)
				playsound(src, 'sound/weapons/gun_interactions/bulletinsert.ogg', 50, 1)
			else
				break

/obj/item/ammo_box/magazine/wt550m9/wtap
	name = "wt550 magazine (Armour Piercing 4.6x30mm)"
	icon_state = "46x30mmtA"
	ammo_type = /obj/item/ammo_casing/c46x30mm/ap

/obj/item/ammo_box/magazine/wt550m9/wttx
	name = "wt550 magazine (Toxin Tipped 4.6x30mm)"
	icon_state = "46x30mmtT"
	ammo_type = /obj/item/ammo_casing/c46x30mm/tox

/obj/item/ammo_box/magazine/wt550m9/wtic
	name = "wt550 magazine (Incendiary 4.6x30mm)"
	icon_state = "46x30mmtI"
	ammo_type = /obj/item/ammo_casing/c46x30mm/inc

/obj/item/ammo_box/magazine/wt550m9/empty
	name = "wt550 magazine (4.6x30mm)"
	icon_state = "46x30mmt"
	ammo_type = /obj/item/ammo_casing/c46x30mm

/obj/item/ammo_box/magazine/wt550m9/empty/Initialize(mapload)
	. = ..()
	stored_ammo.Cut()
	update_appearance(UPDATE_DESC|UPDATE_ICON)

/obj/item/ammo_box/magazine/uzim9mm
	name = "uzi magazine (9mm)"
	icon_state = "uzi9mm"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "9mm"
	max_ammo = 32
	multi_sprite_step = 4

/obj/item/ammo_box/magazine/smgm9mm
	name = "\improper SMG magazine (9mm)"
	icon_state = "smg9mm"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "9mm"
	max_ammo = 21
	materials = list(MAT_METAL = 2000)
	multi_sprite_step = 4

/obj/item/ammo_box/magazine/smgm9mm/ap
	name = "\improper SMG magazine (Armour Piercing 9mm)"
	ammo_type = /obj/item/ammo_casing/c9mm/ap
	materials = list(MAT_METAL = 3000)

/obj/item/ammo_box/magazine/smgm9mm/toxin
	name = "\improper SMG magazine (Toxin Tipped 9mm)"
	ammo_type = /obj/item/ammo_casing/c9mm/tox
	materials = list(MAT_METAL = 3000)

/obj/item/ammo_box/magazine/smgm9mm/fire
	name = "\improper SMG Magazine (Incendiary 9mm)"
	ammo_type = /obj/item/ammo_casing/c9mm/inc
	materials = list(MAT_METAL = 3000)

/obj/item/ammo_box/magazine/apsm10mm
	name = "stechkin aps magazine (10mm)"
	icon_state = "10mmaps"
	ammo_type = /obj/item/ammo_casing/c10mm
	caliber = "10mm"
	max_ammo = 20
	multi_sprite_step = 5

/obj/item/ammo_box/magazine/apsm10mm/fire
	name = "stechkin aps magazine (10mm incendiary)"
	icon_state = "10mmapsI"
	ammo_type = /obj/item/ammo_casing/c10mm/fire
	caliber = "10mm"
	max_ammo = 20
	multi_sprite_step = 5

/obj/item/ammo_box/magazine/apsm10mm/hp
	name = "stechkin aps magazine (10mm HP)"
	icon_state = "10mmapsH"
	ammo_type = /obj/item/ammo_casing/c10mm/hp
	caliber = "10mm"
	max_ammo = 20
	multi_sprite_step = 5

/obj/item/ammo_box/magazine/apsm10mm/ap
	name = "stechkin aps magazine (10mm AP)"
	icon_state = "10mmapsA"
	ammo_type = /obj/item/ammo_casing/c10mm/ap
	caliber = "10mm"
	max_ammo = 20
	multi_sprite_step = 5

/obj/item/ammo_box/magazine/smgm45
	name = "\improper SMG magazine (.45)"
	icon_state = "c20r45"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = ".45"
	max_ammo = 20
	multi_sprite_step = 2

/obj/item/ammo_box/magazine/tommygunm45
	name = "drum magazine (.45)"
	icon_state = "drum45"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = ".45"
	max_ammo = 50

/obj/item/ammo_box/magazine/m50
	name = "handgun magazine (.50ae)"
	icon_state = "50ae"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/a50
	caliber = ".50"
	max_ammo = 7
	multi_sprite_step = 1

/obj/item/ammo_box/magazine/m75
	name = "specialized magazine (.75)"
	icon_state = "75"
	ammo_type = /obj/item/ammo_casing/caseless/a75
	caliber = "75"
	multi_sprite_step = AMMO_MULTI_SPRITE_STEP_ON_OFF
	max_ammo = 8

/obj/item/ammo_box/magazine/m556
	name = "toploader magazine (5.56mm)"
	icon_state = "5.56m"
	origin_tech = "combat=5;syndicate=1"
	ammo_type = /obj/item/ammo_casing/a556
	caliber = "a556"
	max_ammo = 30
	multi_sprite_step = AMMO_MULTI_SPRITE_STEP_ON_OFF

/obj/item/ammo_box/magazine/m556/arg
	name = "\improper ARG magazine (5.56mm)"
	icon_state = "arg"

/obj/item/ammo_box/magazine/ak814
	name = "AK magazine (5.45x39mm)"
	desc = "A universal magazine for an AK style rifle."
	icon_state = "ak814"
	origin_tech = "combat=5;syndicate=1"
	ammo_type = /obj/item/ammo_casing/a545
	caliber = "a545"
	max_ammo = 30
	multi_sprite_step = AMMO_MULTI_SPRITE_STEP_ON_OFF

/obj/item/ammo_box/magazine/m12g
	name = "shotgun magazine (12g slugs)"
	desc = "A drum magazine."
	icon_state = "m12gsl"
	ammo_type = /obj/item/ammo_casing/shotgun
	origin_tech = "combat=3;syndicate=1"
	caliber = "shotgun"
	max_ammo = 8
	multi_sprite_step = AMMO_MULTI_SPRITE_STEP_ON_OFF

/obj/item/ammo_box/magazine/m12g/buckshot
	name = "shotgun magazine (12g buckshot slugs)"
	icon_state = "m12gb"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot

/obj/item/ammo_box/magazine/m12g/stun
	name = "shotgun magazine (12g taser slugs)"
	icon_state = "m12gs"
	ammo_type = /obj/item/ammo_casing/shotgun/stunslug

/obj/item/ammo_box/magazine/m12g/dragon
	name = "shotgun magazine (12g dragon's breath)"
	icon_state = "m12gf"
	ammo_type = /obj/item/ammo_casing/shotgun/incendiary/dragonsbreath

/obj/item/ammo_box/magazine/m12g/bioterror
	name = "shotgun magazine (12g bioterror)"
	icon_state = "m12gt"
	ammo_type = /obj/item/ammo_casing/shotgun/dart/bioterror

/obj/item/ammo_box/magazine/m12g/meteor
	name = "shotgun magazine (12g meteor slugs)"
	icon_state = "m12gbc"
	ammo_type = /obj/item/ammo_casing/shotgun/meteorslug


/obj/item/ammo_box/magazine/m12g/XtrLrg
	name = "\improper XL shotgun magazine (12g slugs)"
	desc = "An extra large drum magazine."
	icon_state = "m12gXlSl"
	w_class = WEIGHT_CLASS_NORMAL
	ammo_type = /obj/item/ammo_casing/shotgun
	max_ammo = 16

/obj/item/ammo_box/magazine/m12g/XtrLrg/buckshot
	name = "\improper XL shotgun magazine (12g buckshot)"
	icon_state = "m12gXlBs"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot

/obj/item/ammo_box/magazine/m12g/XtrLrg/dragon
	name = "\improper XL shotgun magazine (12g dragon's breath)"
	icon_state = "m12gXlDb"
	ammo_type = /obj/item/ammo_casing/shotgun/incendiary/dragonsbreath

/obj/item/ammo_box/magazine/m12g/confetti
	name = "\improper XL shotgun magazine (12g confetti)"
	icon_state = "party_drum"
	ammo_type = /obj/item/ammo_casing/shotgun/confetti

/obj/item/ammo_box/magazine/toy
	name = "foam force META magazine"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart
	caliber = "foam_force"

/obj/item/ammo_box/magazine/toy/smg
	name = "foam force SMG magazine"
	icon_state = "smg9mm"
	max_ammo = 20
	multi_sprite_step = 4

/obj/item/ammo_box/magazine/toy/smg/riot
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot

/obj/item/ammo_box/magazine/toy/pistol
	name = "foam force pistol magazine"
	icon_state = "9x19p"
	max_ammo = 8
	multi_sprite_step = AMMO_MULTI_SPRITE_STEP_ON_OFF

/obj/item/ammo_box/magazine/toy/pistol/riot
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot

/obj/item/ammo_box/magazine/toy/enforcer
	name = "\improper Enforcer foam magazine"
	icon_state = "enforcer"
	max_ammo = 8
	multi_sprite_step = 1
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot

/obj/item/ammo_box/magazine/toy/enforcer/update_overlays()
	. = ..()
	var/ammo = ammo_count()
	if(ammo && is_riot())
		. += image('icons/obj/ammo.dmi', icon_state = "enforcer-rd")
	else if(ammo)
		. += image('icons/obj/ammo.dmi', icon_state = "enforcer-bd")

/obj/item/ammo_box/magazine/toy/enforcer/proc/is_riot()//if the topmost bullet is a riot dart
	var/ammo = ammo_count()
	if(!ammo)
		return 0
	if(istype(contents[length(contents)], /obj/item/ammo_casing/caseless/foam_dart/riot))
		return 1
	return 0

/obj/item/ammo_box/magazine/toy/m762
	name = "donksoft box magazine"
	icon_state = "a762"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot
	max_ammo = 50
	multi_sprite_step = 10

/obj/item/ammo_box/magazine/toy/m762/riot
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot

/obj/item/ammo_box/magazine/laser
	name = "laser carbine projector magazine"
	desc = "Fits experimental laser ammo casings. Compatible with laser rifles and carbines."
	icon_state = "laser"
	ammo_type = /obj/item/ammo_casing/caseless/laser
	origin_tech = "combat=3"
	caliber = "laser"
	max_ammo = 20
	multi_sprite_step = 5
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/ammo_box/magazine/laser/ert //Used by red ERT. Keeps the size for them
	name = "compact laser carbine projector magazine"
	desc = "By use of bluespace technology, the ammo casings are stored in a pocket dimension, saving on space and making them EMP proof."
	w_class = WEIGHT_CLASS_TINY

/obj/item/ammo_box/magazine/laser/ert/emp_act(severity)
	return

/obj/item/ammo_box/magazine/toy/smgm45
	name = "donksoft SMG magazine"
	icon_state = "c20r45"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot
	max_ammo = 20
	multi_sprite_step = 2

/obj/item/ammo_box/magazine/toy/smgm45/riot
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot

/obj/item/ammo_box/magazine/detective/speedcharger //yes this doesn't really belong here but nowhere else works
	name = "DL-88 charge pack"
	desc = "One-use charge pack for the DL-88 energy revolver."
	icon_state = "handgun_ammo_battery"
	var/charge = 1000

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
	. += "<span class='notice'>There is [charge_percent()]% charge left!</span>"

/obj/item/ammo_box/magazine/detective/speedcharger/attack_self()
	return

/obj/item/ammo_box/magazine/detective/speedcharger/attackby()
	return

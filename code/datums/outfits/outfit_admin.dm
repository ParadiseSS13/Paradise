// Used for 'select equipment'
// code/modules/admin/verbs/debug.dm 566

/proc/apply_to_card(obj/item/weapon/card/id/I, mob/living/carbon/human/H, list/access = list(), rank, special_icon)
	if(!istype(I) || !istype(H))
		return 0

	I.access = access
	I.registered_name = H.real_name
	I.rank = rank
	I.assignment = rank
	I.sex = capitalize(H.gender)
	I.age = H.age
	I.name = "[I.registered_name]'s ID Card ([I.assignment])"
	I.photo = get_id_photo(H)

	if(special_icon)
		I.icon_state = special_icon

/datum/outfit/admin/syndicate
	name = "Syndicate Agent"

	uniform = /obj/item/clothing/under/syndicate
	back = /obj/item/weapon/storage/backpack
	belt = /obj/item/weapon/storage/belt/utility/full/multitool
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/combat
	l_ear = /obj/item/device/radio/headset/syndicate
	id = /obj/item/weapon/card/id/syndicate
	r_pocket = /obj/item/device/radio/uplink
	backpack_contents = list(
		/obj/item/weapon/storage/box/engineer = 1,
		/obj/item/device/flashlight = 1,
		/obj/item/weapon/card/emag = 1,
		/obj/item/weapon/reagent_containers/food/snacks/syndidonkpocket = 1
	)

	var/id_icon = "syndie"
	var/id_access = "Syndicate Operative"
	var/uplink_uses = 20

/datum/outfit/admin/syndicate/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/weapon/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_syndicate_access(id_access), name, id_icon)

	var/obj/item/device/radio/uplink/U = H.r_store
	if(istype(U))
		U.hidden_uplink.uplink_owner = "[H.key]"
		U.hidden_uplink.uses = uplink_uses

	var/obj/item/device/radio/R = H.l_ear
	if(istype(R))
		R.set_frequency(SYND_FREQ)

/datum/outfit/admin/syndicate/infiltrator
	name = "Syndicate Infiltrator"

	uniform = /obj/item/clothing/under/chameleon
	glasses = /obj/item/clothing/glasses/hud/security/chameleon
	shoes = /obj/item/clothing/shoes/syndigaloshes
	r_pocket = null
	pda = /obj/item/device/pda

	backpack_contents = list(
		/obj/item/weapon/storage/box/engineer = 1,
		/obj/item/device/flashlight = 1,
		/obj/item/weapon/reagent_containers/food/snacks/syndidonkpocket = 1
	)

/datum/outfit/admin/syndicate/infiltrator/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return
	if(H.gloves)
		H.gloves.name = "black gloves"

	var/obj/item/weapon/implant/uplink/U = new /obj/item/weapon/implant/uplink(H)
	U.implant(H)
	U.hidden_uplink.uses = uplink_uses

	var/obj/item/weapon/implant/dust/D = new /obj/item/weapon/implant/dust(H)
	D.implant(H)

/datum/outfit/admin/syndicate/operative
	name = "Syndicate Nuclear Operative"

	suit = /obj/item/clothing/suit/space/hardsuit/syndi
	belt = /obj/item/weapon/storage/belt/military
	head = /obj/item/clothing/head/helmet/space/hardsuit/syndi
	mask = /obj/item/clothing/mask/gas/syndicate
	l_ear = /obj/item/device/radio/headset/syndicate/alt
	glasses = /obj/item/clothing/glasses/night
	l_pocket = /obj/item/weapon/pinpointer/advpinpointer
	l_hand = /obj/item/weapon/tank/jetpack/oxygen/harness

	backpack_contents = list(
		/obj/item/weapon/storage/box/engineer = 1,
		/obj/item/weapon/reagent_containers/food/pill/initropidril = 1,
		/obj/item/weapon/gun/projectile/automatic/pistol = 1,
		/obj/item/ammo_box/magazine/m10mm = 1,
		/obj/item/weapon/crowbar/red = 1,
		/obj/item/weapon/grenade/plastic/c4 = 1,
		/obj/item/weapon/reagent_containers/food/snacks/syndidonkpocket = 1,
		/obj/item/device/flashlight = 1,
	)

/datum/outfit/admin/syndicate/operative/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/weapon/implant/explosive/E = new(H)
	E.implant(H)

/datum/outfit/admin/syndicate/operative/freedom
	name = "Syndicate Freedom Operative"
	suit = /obj/item/clothing/suit/space/hardsuit/syndi/freedom
	head = /obj/item/clothing/head/helmet/space/hardsuit/syndi/freedom

/datum/outfit/admin/syndicate_strike_team
	name = "Syndicate Strike Team"

/datum/outfit/admin/syndicate_strike_team/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	return H.equip_syndicate_commando()

/datum/outfit/admin/syndicate/officer
	name = "Syndicate Officer"

	belt = /obj/item/weapon/gun/projectile/automatic/pistol/deagle/camo
	l_ear = /obj/item/device/radio/headset/syndicate/alt
	l_pocket = /obj/item/weapon/pinpointer/advpinpointer

	backpack_contents = list(
		/obj/item/weapon/storage/box/engineer = 1,
		/obj/item/weapon/reagent_containers/food/pill/initropidril = 1,
		/obj/item/weapon/reagent_containers/food/snacks/syndidonkpocket = 1,
		/obj/item/ammo_box/magazine/m50 = 2)

	id_icon = "commander"
	id_access = "Syndicate Operative Leader"
	uplink_uses = 500

/datum/outfit/admin/syndicate/officer/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/weapon/implant/uplink/U = new /obj/item/weapon/implant/uplink(H)
	U.implant(H)
	U.hidden_uplink.uses = 500//a measly 1000 TC along with the uplink in the pocket

	var/obj/item/weapon/implant/dust/D = new(H)
	D.implant(H)

/datum/outfit/admin/syndicate/bomber
	name = "Syndicate Bomber"

	backpack_contents = list(
		/obj/item/weapon/storage/box/engineer = 1,
		/obj/item/device/flashlight = 1,
		/obj/item/weapon/card/emag = 1,
		/obj/item/device/radio/beacon/syndicate/bomb = 2,
		/obj/item/device/syndicatedetonator = 1,
		/obj/item/weapon/reagent_containers/food/snacks/syndidonkpocket = 1
	)

/datum/outfit/admin/nt_vip
	name = "VIP Guest"

	uniform = /obj/item/clothing/under/suit_jacket/really_black
	back = /obj/item/weapon/storage/backpack/satchel
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/black
	head = /obj/item/clothing/head/that
	l_ear = /obj/item/device/radio/headset/ert
	id = /obj/item/weapon/card/id/centcom
	pda = /obj/item/device/pda
	backpack_contents = list(
		/obj/item/weapon/storage/box/engineer = 1
	)

/datum/outfit/admin/nt_vip/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/weapon/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_centcom_access("VIP Guest"), "VIP Guest")

/datum/outfit/admin/nt_navy_officer
	name = "NT Navy Officer"

	uniform = /obj/item/clothing/under/rank/centcom/officer
	back = /obj/item/weapon/storage/backpack/satchel
	belt = /obj/item/weapon/gun/energy/pulse/pistol
	gloves = /obj/item/clothing/gloves/color/white
	shoes = /obj/item/clothing/shoes/centcom
	head = /obj/item/clothing/head/beret/centcom/officer
	l_ear = /obj/item/device/radio/headset/centcom
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	id = /obj/item/weapon/card/id/centcom
	pda = /obj/item/device/pda/centcom
	backpack_contents = list(
		/obj/item/weapon/storage/box/engineer = 1,
		/obj/item/weapon/implanter/dust = 1,
		/obj/item/weapon/implanter/death_alarm = 1
	)

/datum/outfit/admin/nt_navy_officer/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/weapon/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_centcom_access("Nanotrasen Navy Officer"), "Nanotrasen Navy Officer")

	var/obj/item/weapon/implant/L = new /obj/item/weapon/implant/mindshield(H)
	L.implant(H)


/datum/outfit/admin/nt_special_ops_officer
	name = "NT Special Ops Officer"

	uniform = /obj/item/clothing/under/syndicate/combat
	suit = /obj/item/clothing/suit/space/deathsquad/officer
	back = /obj/item/weapon/storage/backpack/security
	belt = /obj/item/weapon/gun/energy/pulse/pistol/m1911
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/combat
	head = /obj/item/clothing/head/helmet/space/deathsquad/beret
	mask = /obj/item/clothing/mask/cigarette/cigar/cohiba
	l_ear = /obj/item/device/radio/headset/centcom
	glasses = /obj/item/clothing/glasses/thermal/cyber
	id = /obj/item/weapon/card/id/centcom
	r_pocket = /obj/item/weapon/storage/box/matches
	pda = /obj/item/device/pda/centcom
	backpack_contents = list(
		/obj/item/weapon/storage/box/engineer = 1,
		/obj/item/weapon/tank/emergency_oxygen/double/full = 1,
		/obj/item/weapon/implanter/dust = 1,
		/obj/item/weapon/implanter/death_alarm = 1,
		/obj/item/weapon/twohanded/dualsaber/red = 1,
		/obj/item/weapon/pinpointer/advpinpointer = 1,
		/obj/item/weapon/reagent_containers/hypospray/combat/nanites = 1,
		/obj/item/weapon/storage/box/zipties = 1,
		/obj/item/clothing/shoes/magboots/advance = 1,
		/obj/item/weapon/implanter/mindshield = 1,
	)

/datum/outfit/admin/nt_special_ops_officer/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/weapon/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_centcom_access("Special Operations Officer"), "Special Operations Officer")

/datum/outfit/admin/nt_special_ops_formal
	name = "NT Special Ops Formal"

	uniform = /obj/item/clothing/under/rank/centcom/captain
	back = /obj/item/weapon/storage/backpack/satchel
	belt = /obj/item/weapon/gun/energy/pulse/pistol/m1911
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/combat
	head = /obj/item/clothing/head/helmet/space/deathsquad/beret
	mask = /obj/item/clothing/mask/cigarette/cigar/cohiba
	l_ear = /obj/item/device/radio/headset/centcom
	glasses = /obj/item/clothing/glasses/thermal/cyber
	id = /obj/item/weapon/card/id/centcom
	r_pocket = /obj/item/weapon/storage/box/matches
	pda = /obj/item/device/pda/centcom
	backpack_contents = list(
		/obj/item/weapon/storage/box/engineer = 1,
		/obj/item/weapon/melee/classic_baton/telescopic = 1,
		/obj/item/weapon/implanter/dust = 1,
		/obj/item/weapon/implanter/death_alarm = 1
	)

/datum/outfit/admin/nt_special_ops_formal/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/device/pda/PDA = H.wear_pda
	if(istype(PDA))
		PDA.owner = H.real_name
		PDA.ownjob = "Special Operations Officer"
		PDA.icon_state = "pda-syndi"
		PDA.name = "PDA-[H.real_name] ([PDA.ownjob])"
		PDA.desc = "A portable microcomputer by Thinktronic Systems, LTD. This is model is a special edition designed for military field work."

	var/obj/item/weapon/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_centcom_access("Special Operations Officer"), "Special Operations Officer")

/datum/outfit/admin/nt_navy_captain
	name = "NT Navy Captain"

	uniform = /obj/item/clothing/under/rank/centcom/captain
	back = /obj/item/weapon/storage/backpack/satchel
	belt = /obj/item/weapon/gun/energy/pulse/pistol
	gloves = /obj/item/clothing/gloves/color/white
	shoes = /obj/item/clothing/shoes/centcom
	head = /obj/item/clothing/head/beret/centcom/captain
	l_ear = /obj/item/device/radio/headset/centcom
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	id = /obj/item/weapon/card/id/centcom
	pda = /obj/item/device/pda/centcom
	backpack_contents = list(
		/obj/item/weapon/storage/box/engineer = 1,
		/obj/item/weapon/implanter/dust = 1,
		/obj/item/weapon/implanter/death_alarm = 1
	)

/datum/outfit/admin/nt_navy_captain/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/weapon/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_centcom_access("Nanotrasen Navy Captain"), "Nanotrasen Navy Captain")

	var/obj/item/weapon/implant/L = new /obj/item/weapon/implant/mindshield(H)
	L.implant(H)

/datum/outfit/admin/nt_diplomat
	name = "NT Diplomat"

	uniform = /obj/item/clothing/under/rank/centcom/diplomatic
	back = /obj/item/weapon/storage/backpack/satchel
	gloves = /obj/item/clothing/gloves/color/white
	shoes = /obj/item/clothing/shoes/centcom
	l_ear = /obj/item/device/radio/headset/centcom
	id = /obj/item/weapon/card/id/centcom
	r_pocket = /obj/item/weapon/lighter/zippo/nt_rep
	l_pocket = /obj/item/weapon/storage/fancy/cigarettes/dromedaryco
	pda = /obj/item/device/pda/centcom
	backpack_contents = list(
		/obj/item/weapon/storage/box/survival = 1,
		/obj/item/weapon/implanter/dust = 1,
		/obj/item/weapon/implanter/death_alarm = 1,
	)

/datum/outfit/admin/nt_diplomat/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/weapon/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_centcom_access("Nanotrasen Navy Representative"), "Nanotrasen Diplomat")

/datum/outfit/admin/death_commando
	name = "NT Death Commando"

/datum/outfit/admin/death_commando/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	return H.equip_death_commando()

/datum/outfit/admin/pirate
	name = "Space Pirate"

	uniform = /obj/item/clothing/under/pirate
	back = /obj/item/weapon/storage/backpack/satchel
	shoes = /obj/item/clothing/shoes/brown
	id = /obj/item/weapon/card/id
	r_hand = /obj/item/weapon/melee/energy/sword/pirate
	backpack_contents = list(
		/obj/item/weapon/storage/box/survival = 1
	)

/datum/outfit/admin/pirate/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/weapon/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, list(access_maint_tunnels), name)

/datum/outfit/admin/pirate/first_mate
	name = "Space Pirate First Mate"

	glasses = /obj/item/clothing/glasses/eyepatch
	head = /obj/item/clothing/head/bandana

/datum/outfit/admin/pirate/captain
	name = "Space Pirate Captain"

	suit = /obj/item/clothing/suit/pirate_black
	head = /obj/item/clothing/head/pirate

/datum/outfit/admin/vox
	name = "Vox Raider"
	uniform = /obj/item/clothing/under/vox/vox_robes
	suit = /obj/item/clothing/suit/space/vox/carapace
	back = /obj/item/weapon/storage/backpack
	gloves = /obj/item/clothing/gloves/color/yellow/vox
	shoes = /obj/item/clothing/shoes/magboots/vox
	head = /obj/item/clothing/head/helmet/space/vox/carapace
	mask = /obj/item/clothing/mask/gas/syndicate
	l_ear = /obj/item/device/radio/headset/syndicate
	glasses = /obj/item/clothing/glasses/thermal/monocle
	id = /obj/item/weapon/card/id/syndicate/vox
	l_pocket = /obj/item/weapon/melee/classic_baton/telescopic
	r_pocket = /obj/item/weapon/tank/emergency_oxygen/vox
	backpack_contents = list(
		/obj/item/device/flashlight = 1,
		/obj/item/weapon/restraints/handcuffs/cable/zipties = 1,
		/obj/item/device/flash = 1,
		/obj/item/weapon/gun/energy/noisecannon = 1
	)

/datum/outfit/admin/vox/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(H.get_species() == "Vox Armalis")
		. = ..()
	else
		H.equip_vox_raider()
		H.regenerate_icons()

/datum/outfit/admin/vox/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/weapon/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_all_accesses(), "Vox Armalis", "syndie")

/datum/outfit/admin/tunnel_clown
	name = "Tunnel Clown"

	uniform = /obj/item/clothing/under/rank/clown
	suit = /obj/item/clothing/suit/hooded/chaplain_hoodie
	back = /obj/item/weapon/storage/backpack
	belt = /obj/item/weapon/storage/belt/utility/full/multitool
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/clown_shoes
	mask = /obj/item/clothing/mask/gas/clown_hat
	l_ear = /obj/item/device/radio/headset
	glasses = /obj/item/clothing/glasses/thermal/monocle
	id = /obj/item/weapon/card/id
	l_pocket = /obj/item/weapon/reagent_containers/food/snacks/grown/banana
	r_pocket = /obj/item/weapon/bikehorn
	r_hand = /obj/item/weapon/twohanded/fireaxe
	backpack_contents = list(
		/obj/item/weapon/storage/box/survival = 1,
		/obj/item/device/flashlight = 1,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofbanana = 1
	)

/datum/outfit/admin/tunnel_clown/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/weapon/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, list(access_clown, access_theatre, access_maint_tunnels), "Tunnel Clown")

/datum/outfit/admin/mime_assassin
	name = "Mime Assassin"

	uniform = /obj/item/clothing/under/mime
	suit = /obj/item/clothing/suit/suspenders
	back = /obj/item/weapon/storage/backpack/mime
	belt = /obj/item/weapon/storage/belt/utility/full/multitool
	gloves = /obj/item/clothing/gloves/color/white
	shoes = /obj/item/clothing/shoes/black
	head = /obj/item/clothing/head/beret
	mask = /obj/item/clothing/mask/gas/mime
	l_ear = /obj/item/device/radio/headset
	glasses = /obj/item/clothing/glasses/thermal/monocle
	id = /obj/item/weapon/card/id/syndicate
	pda = /obj/item/device/pda/mime
	backpack_contents = list(
		/obj/item/weapon/storage/box/survival = 1,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing = 1,
		/obj/item/weapon/storage/box/syndie_kit/caneshotgun = 1,
		/obj/item/toy/crayon/mime = 1,
		/obj/item/weapon/gun/projectile/automatic/pistol = 1,
		/obj/item/weapon/suppressor = 1,
		/obj/item/ammo_casing/shotgun/incendiary/dragonsbreath = 2,
		/obj/item/weapon/pen/sleepy = 1,
		/obj/item/weapon/reagent_containers/food/snacks/syndidonkpocket = 1,
		/obj/item/device/flashlight = 1
	)

/datum/outfit/admin/mime_assassin/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(H.gender == FEMALE)
		uniform = /obj/item/clothing/under/sexymime
		suit = /obj/item/clothing/mask/gas/sexymime

/datum/outfit/admin/mime_assassin/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/device/pda/PDA = H.wear_pda
	if(istype(PDA))
		PDA.owner = H.real_name
		PDA.ownjob = "Mime"
		PDA.name = "PDA-[H.real_name] ([PDA.ownjob])"

	var/obj/item/weapon/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, list(access_mime, access_theatre, access_maint_tunnels), "Mime")

/datum/outfit/admin/greytide
	name = "Greytide"

	uniform = /obj/item/clothing/under/color/grey
	back = /obj/item/weapon/storage/backpack
	shoes = /obj/item/clothing/shoes/brown
	mask = /obj/item/clothing/mask/gas
	l_ear = /obj/item/device/radio/headset
	id = /obj/item/weapon/card/id
	l_hand = /obj/item/weapon/storage/toolbox/mechanical
	r_hand = /obj/item/flag/grey
	backpack_contents = list(
		/obj/item/weapon/storage/box/survival = 1,
		/obj/item/device/flashlight = 1
	)

/datum/outfit/admin/greytide/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/weapon/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, list(access_maint_tunnels), "Greytide")

/datum/outfit/admin/greytide/leader
	name = "Greytide Leader"

	belt = /obj/item/weapon/storage/belt/utility/full/multitool
	gloves = /obj/item/clothing/gloves/color/yellow

	backpack_contents = list(
		/obj/item/weapon/storage/box/survival = 1,
		/obj/item/clothing/head/welding = 1,
		/obj/item/device/flashlight = 1
	)

/datum/outfit/admin/greytide/leader/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..(H, TRUE)
	if(visualsOnly)
		return

	var/obj/item/weapon/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, list(access_maint_tunnels), "Greytide Leader")

/datum/outfit/admin/greytide/xeno
	name = "Greytide Xeno"

	uniform = /obj/item/clothing/under/color/black
	suit = /obj/item/clothing/suit/xenos
	back = /obj/item/weapon/storage/backpack/satchel
	belt = /obj/item/weapon/storage/belt/utility/full/multitool
	gloves = /obj/item/clothing/gloves/color/yellow
	shoes = /obj/item/clothing/shoes/black
	head = /obj/item/clothing/head/xenos
	glasses = /obj/item/clothing/glasses/thermal
	l_pocket = /obj/item/weapon/tank/emergency_oxygen/double/full
	r_pocket = /obj/item/toy/toy_xeno
	backpack_contents = list(
		/obj/item/weapon/storage/box/survival = 1,
		/obj/item/clothing/head/welding = 1,
		/obj/item/device/flashlight = 1
	)

/datum/outfit/admin/greytide/xeno/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..(H, TRUE)
	if(visualsOnly)
		return

	var/obj/item/weapon/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, list(access_maint_tunnels), "Legit Xenomorph")

/datum/outfit/admin/soviet

	gloves = /obj/item/clothing/gloves/combat
	uniform = /obj/item/clothing/under/soviet
	back = /obj/item/weapon/storage/backpack/satchel
	head = /obj/item/clothing/head/ushanka
	id = /obj/item/weapon/card/id

/datum/outfit/admin/soviet/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/weapon/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, list(access_maint_tunnels), name)

/datum/outfit/admin/soviet/tourist
	name = "Soviet Tourist"

	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/black
	l_ear = /obj/item/device/radio/headset
	backpack_contents = list(
		/obj/item/weapon/storage/box/survival = 1
	)

/datum/outfit/admin/soviet/soldier
	name = "Soviet Soldier"

	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/combat
	l_ear = /obj/item/device/radio/headset/syndicate
	glasses = /obj/item/clothing/glasses/sunglasses

	backpack_contents = list(
		/obj/item/weapon/storage/box/engineer = 1,
		/obj/item/weapon/card/emag = 1,
		/obj/item/device/flashlight = 1,
		/obj/item/weapon/grenade/plastic/c4 = 2,
		/obj/item/weapon/gun/projectile/revolver/mateba = 1,
		/obj/item/ammo_box/a357 = 3
	)

/datum/outfit/admin/soviet/admiral
	name = "Soviet Admiral"

	suit = /obj/item/clothing/suit/hgpirate
	belt = null
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/combat
	head = /obj/item/clothing/head/hgpiratecap
	mask = null
	l_ear = /obj/item/device/radio/headset/syndicate
	r_ear = null
	glasses = /obj/item/clothing/glasses/thermal/eyepatch
	id = null
	l_pocket = null
	r_pocket = null
	suit_store = null
	l_hand = null
	r_hand = null
	pda = null

	backpack_contents = list(
		/obj/item/weapon/storage/box/engineer = 1,
		/obj/item/weapon/gun/projectile/revolver/mateba = 1,
		/obj/item/ammo_box/a357 = 3
	)

/datum/outfit/admin/solgov_rep
	name = "Solar Federation Representative"

	uniform = /obj/item/clothing/under/solgov/rep
	back = /obj/item/weapon/storage/backpack/satchel
	gloves = /obj/item/clothing/gloves/color/white
	shoes = /obj/item/clothing/shoes/centcom
	l_ear = /obj/item/device/radio/headset
	id = /obj/item/weapon/card/id/silver
	r_pocket = /obj/item/weapon/lighter/zippo/blue
	l_pocket = /obj/item/weapon/storage/fancy/cigarettes/cigpack_robustgold
	pda = /obj/item/device/pda
	backpack_contents = list(
		/obj/item/weapon/storage/box/survival = 1,
		/obj/item/weapon/implanter/dust = 1,
		/obj/item/weapon/implanter/death_alarm = 1,
	)

/datum/outfit/admin/solgov_rep/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/weapon/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_centcom_access("VIP Guest"), "Solar Federation Representative")


/datum/outfit/admin/solgov
	name = "Solar Federation Marine"

	uniform = /obj/item/clothing/under/solgov
	back = /obj/item/weapon/storage/backpack/security
	head = /obj/item/clothing/head/soft/solgov
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/combat
	id = /obj/item/weapon/card/id
	l_hand = /obj/item/weapon/gun/projectile/automatic/ar
	backpack_contents = list(
		/obj/item/weapon/storage/box/survival = 1,
		/obj/item/weapon/kitchen/knife/combat = 1,
		/obj/item/ammo_box/magazine/m556 = 3)


/datum/outfit/admin/solgov/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/weapon/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_centcom_access("VIP Guest"), name)

/datum/outfit/admin/solgov/lieutenant
	name = "Solar Federation Lieutenant"

	uniform = /obj/item/clothing/under/solgov/command
	head = /obj/item/clothing/head/soft/solgov/command
	back = /obj/item/weapon/storage/backpack/satchel
	l_hand = null
	belt = /obj/item/weapon/gun/projectile/automatic/pistol/deagle
	backpack_contents = list(
		/obj/item/weapon/storage/box/survival = 1,
		/obj/item/weapon/kitchen/knife/combat = 1,
		/obj/item/weapon/melee/classic_baton/telescopic = 1,
		/obj/item/ammo_box/magazine/m50 = 2)

/datum/outfit/admin/paranormal_ert
	name = "Paranormal ERT member"

	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/space/hardsuit/ert/paranormal
	back = /obj/item/weapon/storage/backpack/ert/security
	belt = /obj/item/weapon/gun/energy/gun/nuclear
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/combat
	head = /obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal
	l_ear = /obj/item/device/radio/headset/ert/alt
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	id = /obj/item/weapon/card/id/centcom
	pda = /obj/item/device/pda/centcom
	backpack_contents = list(
		/obj/item/weapon/storage/box/survival = 1,
		/obj/item/clothing/mask/gas/sechailer/swat = 1,
		/obj/item/weapon/storage/box/zipties = 1,
		/obj/item/device/flashlight = 1)

/datum/outfit/admin/paranormal_ert/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/weapon/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_centcom_access("Emergency Response Team Member"), "Emergency Response Team Member")

	var/obj/item/weapon/implant/L = new /obj/item/weapon/implant/mindshield(H)
	L.implant(H)

/datum/outfit/admin/janitorial_ert
	name = "Janitorial ERT member"

	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/space/hardsuit/ert/janitor
	back = /obj/item/weapon/storage/backpack/ert/janitor
	belt = /obj/item/weapon/storage/belt/janitor/full
	gloves = /obj/item/clothing/gloves/color/yellow
	shoes = /obj/item/clothing/shoes/galoshes
	head = /obj/item/clothing/head/helmet/space/hardsuit/ert/janitor
	l_ear = /obj/item/device/radio/headset/ert/alt
	glasses = /obj/item/clothing/glasses/sunglasses
	id = /obj/item/weapon/card/id/centcom
	pda = /obj/item/device/pda/centcom
	backpack_contents = list(
		/obj/item/weapon/caution = 2,
		/obj/item/weapon/storage/box/survival = 1,
		/obj/item/weapon/reagent_containers/spray/cleaner = 1,
		/obj/item/weapon/storage/bag/trash = 1,
		/obj/item/weapon/storage/box/lights/mixed = 1,
		/obj/item/weapon/holosign_creator = 1,
		/obj/item/device/flashlight = 1)

/datum/outfit/admin/janitorial_ert/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/weapon/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_centcom_access("Emergency Response Team Member"), "Emergency Response Team Member")

	var/obj/item/weapon/implant/L = new /obj/item/weapon/implant/mindshield(H)
	L.implant(H)

/datum/outfit/admin/chrono
	name = "Chrono Legionnaire"

	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/space/chronos
	back = /obj/item/weapon/chrono_eraser
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/combat
	head = /obj/item/clothing/head/helmet/space/chronos
	mask = /obj/item/clothing/mask/gas/syndicate
	glasses = /obj/item/clothing/glasses/night
	id = /obj/item/weapon/card/id/syndicate
	suit_store = /obj/item/weapon/tank/emergency_oxygen/double/full

/datum/outfit/admin/chrono/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/weapon/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_all_accesses() + get_all_centcom_access(), name, "syndie")

/datum/outfit/admin/spacegear
	name = "Standard Space Gear"

	uniform = /obj/item/clothing/under/color/grey
	suit = /obj/item/clothing/suit/space
	back = /obj/item/weapon/tank/jetpack/oxygen
	shoes = /obj/item/clothing/shoes/black
	head = /obj/item/clothing/head/helmet/space
	mask = /obj/item/clothing/mask/breath
	l_ear = /obj/item/device/radio/headset
	id = /obj/item/weapon/card/id

/datum/outfit/admin/spacegear/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	if(istype(H.back, /obj/item/weapon/tank/jetpack))
		var/obj/item/weapon/tank/jetpack/J = H.back
		J.turn_on()
		J.toggle_internals(H)

	var/obj/item/weapon/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_all_accesses(), "Space Explorer")

/datum/outfit/admin/hardsuit
	back = /obj/item/weapon/tank/jetpack/oxygen
	mask = /obj/item/clothing/mask/breath
	id = /obj/item/weapon/card/id

/datum/outfit/admin/hardsuit/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	if(istype(H.back, /obj/item/weapon/tank/jetpack))
		var/obj/item/weapon/tank/jetpack/J = H.back
		J.turn_on()
		J.toggle_internals(H)

	var/obj/item/weapon/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_all_accesses(), "Hardsuit Tester")

/datum/outfit/admin/hardsuit/engineer
	name = "Engineer Hardsuit"
	suit = /obj/item/clothing/suit/space/hardsuit
	head = /obj/item/clothing/head/helmet/space/hardsuit

/datum/outfit/admin/hardsuit/ce
	name = "CE Hardsuit"
	suit = /obj/item/clothing/suit/space/hardsuit/elite
	head = /obj/item/clothing/head/helmet/space/hardsuit/elite

/datum/outfit/admin/hardsuit/mining
	name = "Mining Hardsuit"
	suit = /obj/item/clothing/suit/space/hardsuit/mining
	head = /obj/item/clothing/head/helmet/space/hardsuit/mining

/datum/outfit/admin/hardsuit/syndi
	name = "Syndi Hardsuit"
	suit = /obj/item/clothing/suit/space/hardsuit/syndi
	head = /obj/item/clothing/head/helmet/space/hardsuit/syndi

/datum/outfit/admin/hardsuit/wizard
	name = "Wizard Hardsuit"
	suit = /obj/item/clothing/suit/space/hardsuit/wizard
	head = /obj/item/clothing/head/helmet/space/hardsuit/wizard

/datum/outfit/admin/hardsuit/medical
	name = "Medical Hardsuit"
	suit = /obj/item/clothing/suit/space/hardsuit/medical
	head = /obj/item/clothing/head/helmet/space/hardsuit/medical

/datum/outfit/admin/hardsuit/atmos
	name = "Atmos Hardsuit"
	suit = /obj/item/clothing/suit/space/hardsuit/atmos
	head = /obj/item/clothing/head/helmet/space/hardsuit/atmos


/datum/outfit/admin/tournament
	suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/black
	head = /obj/item/clothing/head/helmet/thunderdome
	r_pocket = /obj/item/weapon/grenade/smokebomb
	l_hand = /obj/item/weapon/kitchen/knife
	r_hand = /obj/item/weapon/gun/energy/pulse/destroyer

/datum/outfit/admin/tournament/red
	name = "Tournament Standard Red"
	uniform = /obj/item/clothing/under/color/red

/datum/outfit/admin/tournament/green
	name = "Tournament Standard Green"
	uniform = /obj/item/clothing/under/color/green

/datum/outfit/admin/tournament_gangster //gangster are supposed to fight each other. --rastaf0
	name = "Tournament Gangster"

	uniform = /obj/item/clothing/under/det
	suit = /obj/item/clothing/suit/storage/det_suit
	shoes = /obj/item/clothing/shoes/black
	head = /obj/item/clothing/head/det_hat
	glasses = /obj/item/clothing/glasses/thermal/monocle
	l_pocket = /obj/item/ammo_box/a357
	r_hand = /obj/item/weapon/gun/projectile/automatic/proto

/datum/outfit/admin/tournament_chef //Steven Seagal FTW
	name = "Tournament Chef"

	uniform = /obj/item/clothing/under/rank/chef
	suit = /obj/item/clothing/suit/chef
	shoes = /obj/item/clothing/shoes/black
	head = /obj/item/clothing/head/chefhat
	l_pocket = /obj/item/weapon/kitchen/knife
	r_pocket = /obj/item/weapon/kitchen/knife
	l_hand = /obj/item/weapon/kitchen/knife
	r_hand = /obj/item/weapon/kitchen/rollingpin

/datum/outfit/admin/tournament_janitor
	name = "Tournament Janitor"

	uniform = /obj/item/clothing/under/rank/janitor
	back = /obj/item/weapon/storage/backpack
	shoes = /obj/item/clothing/shoes/black
	l_hand = /obj/item/weapon/reagent_containers/glass/bucket
	backpack_contents = list(
		/obj/item/weapon/grenade/chem_grenade/cleaner = 2,
		/obj/item/stack/tile/plasteel = 7
	)

/datum/outfit/admin/tournament_janitor/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/weapon/reagent_containers/R = H.l_hand
	if(istype(R))
		R.reagents.add_reagent("water", 70)

/datum/outfit/admin/survivor
	name = "Survivor"

	uniform = /obj/item/clothing/under/overalls
	back = /obj/item/weapon/storage/backpack
	gloves = /obj/item/clothing/gloves/color/latex
	shoes = /obj/item/clothing/shoes/white
	l_ear = /obj/item/device/radio/headset
	id = /obj/item/weapon/card/id
	backpack_contents = list(
		/obj/item/weapon/storage/box/survival = 1
	)

/datum/outfit/admin/survivor/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	for(var/obj/item/I in H.contents)
		if(!istype(I, /obj/item/weapon/implant))
			I.add_mob_blood(H)

	if(visualsOnly)
		return

	var/obj/item/weapon/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, list(access_maint_tunnels), "Survivor")

/datum/outfit/admin/masked_killer
	name = "Masked Killer"

	uniform = /obj/item/clothing/under/overalls
	suit = /obj/item/clothing/suit/apron
	back = /obj/item/weapon/storage/backpack
	gloves = /obj/item/clothing/gloves/color/latex
	shoes = /obj/item/clothing/shoes/white
	head = /obj/item/clothing/head/welding
	mask = /obj/item/clothing/mask/surgical
	l_ear = /obj/item/device/radio/headset
	glasses = /obj/item/clothing/glasses/thermal/monocle
	id = /obj/item/weapon/card/id/syndicate
	l_pocket = /obj/item/weapon/kitchen/knife
	r_pocket = /obj/item/weapon/scalpel
	r_hand = /obj/item/weapon/twohanded/fireaxe
	backpack_contents = list(
		/obj/item/weapon/storage/box/survival = 1,
		/obj/item/device/flashlight = 1
	)

/datum/outfit/admin/masked_killer/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	for(var/obj/item/I in H.contents)
		if(!istype(I, /obj/item/weapon/implant))
			I.add_mob_blood(H)

	if(visualsOnly)
		return

	var/obj/item/weapon/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, list(access_maint_tunnels), "Masked Killer", "syndie")

/datum/outfit/admin/singuloth_knight
	name = "Singuloth Knight"

	uniform = /obj/item/clothing/under/syndicate/combat
	suit = /obj/item/clothing/suit/space/hardsuit/singuloth
	back = /obj/item/weapon/twohanded/knighthammer
	belt = /obj/item/weapon/claymore/ceremonial
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/magboots
	head = /obj/item/clothing/head/helmet/space/hardsuit/singuloth
	mask = /obj/item/clothing/mask/breath
	l_ear = /obj/item/device/radio/headset/ert
	glasses = /obj/item/clothing/glasses/meson/cyber
	id = /obj/item/weapon/card/id
	suit_store = /obj/item/weapon/tank/oxygen

/datum/outfit/admin/singuloth_knight/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/weapon/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_all_accesses(), "Singuloth Knight")

/datum/outfit/admin/assassin
	name = "Syndicate Assassin"

	uniform = /obj/item/clothing/under/suit_jacket
	suit = /obj/item/clothing/suit/wcoat
	back = /obj/item/weapon/storage/backpack
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/black
	l_ear = /obj/item/device/radio/headset/syndicate
	glasses = /obj/item/clothing/glasses/sunglasses
	id = /obj/item/weapon/card/id/syndicate
	l_pocket = /obj/item/weapon/melee/energy/sword/saber
	l_hand = /obj/item/weapon/storage/secure/briefcase/reaper
	pda = /obj/item/device/pda/heads
	backpack_contents = list(
		/obj/item/weapon/storage/box/survival = 1,
		/obj/item/device/flashlight = 1
	)

/datum/outfit/admin/assassin/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/weapon/implant/dust/D = new /obj/item/weapon/implant/dust(H)
	D.implant(H)

	var/obj/item/device/pda/PDA = H.wear_pda
	if(istype(PDA))
		PDA.owner = H.real_name
		PDA.ownjob = "Reaper"
		PDA.name = "PDA-[H.real_name] ([PDA.ownjob])"

	var/obj/item/weapon/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_all_accesses(), "Reaper", "syndie")

/datum/outfit/admin/spy
	name = "Spy"

	uniform = /obj/item/clothing/under/suit_jacket/really_black
	back = /obj/item/weapon/storage/backpack
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/black
	l_ear = /obj/item/device/radio/headset/syndicate
	glasses = /obj/item/clothing/glasses/hud/security/chameleon
	id = /obj/item/weapon/card/id/syndicate
	l_pocket = /obj/item/weapon/melee/energy/sword/saber
	r_pocket = /obj/item/weapon/pen/sleepy
	pda = /obj/item/device/pda/heads
	backpack_contents = list(
		/obj/item/weapon/storage/box/survival = 1,
		/obj/item/weapon/gun/projectile/automatic/pistol = 1,
		/obj/item/weapon/suppressor = 1,
		/obj/item/weapon/card/emag = 1,
		/obj/item/device/flashlight = 1,
		/obj/item/weapon/implanter/storage = 1
	)

/datum/outfit/admin/spy/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/clothing/gloves/combat/G = H.gloves
	if(istype(G))
		G.name = "black gloves"

	var/obj/item/weapon/implant/dust/D = new /obj/item/weapon/implant/dust(H)
	D.implant(H)

	var/obj/item/device/pda/PDA = H.wear_pda
	if(istype(PDA))
		PDA.owner = H.real_name
		PDA.ownjob = "Spy"
		PDA.name = "PDA-[H.real_name] ([PDA.ownjob])"

	var/obj/item/weapon/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, list(access_maint_tunnels), "Spy", "syndie")

/datum/outfit/admin/dark_lord
	name = "Dark Lord"

	uniform = /obj/item/clothing/under/color/black
	suit = /obj/item/clothing/suit/hooded/chaplain_hoodie
	back = /obj/item/weapon/storage/backpack
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/black
	l_ear = /obj/item/device/radio/headset/syndicate
	id = /obj/item/weapon/card/id/syndicate
	l_hand = /obj/item/weapon/twohanded/dualsaber/red
	backpack_contents = list(
		/obj/item/weapon/storage/box/survival = 1,
		/obj/item/device/flashlight = 1,
	)

/datum/outfit/admin/dark_lord/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/clothing/suit/hooded/chaplain_hoodie/C = H.wear_suit
	if(istype(C))
		C.name = "dark lord robes"
		C.hood.name = "dark lord hood"

	var/obj/item/weapon/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_all_accesses(), "Dark Lord", "syndie")

/datum/outfit/admin/wizard
	uniform = /obj/item/clothing/under/color/lightpurple
	suit = /obj/item/clothing/suit/wizrobe
	back = /obj/item/weapon/storage/backpack
	shoes = /obj/item/clothing/shoes/sandal
	head = /obj/item/clothing/head/wizard
	l_ear = /obj/item/device/radio/headset
	id = /obj/item/weapon/card/id
	r_pocket = /obj/item/weapon/teleportation_scroll
	l_hand = /obj/item/weapon/twohanded/staff
	r_hand = /obj/item/weapon/spellbook
	backpack_contents = list(
		/obj/item/weapon/storage/box/engineer = 1
	)

/datum/outfit/admin/wizard/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/weapon/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_all_accesses(), "Wizard")

/datum/outfit/admin/wizard/blue
	name = "Blue Wizard"
	// the default wizard clothes are blue

/datum/outfit/admin/wizard/red
	name = "Red Wizard"

	suit = /obj/item/clothing/suit/wizrobe/red
	head = /obj/item/clothing/head/wizard/red

/datum/outfit/admin/wizard/marisa
	name = "Marisa Wizard"

	suit = /obj/item/clothing/suit/wizrobe/marisa
	shoes = /obj/item/clothing/shoes/sandal/marisa
	head = /obj/item/clothing/head/wizard/marisa


/datum/outfit/admin/dark_priest
	name = "Dark Priest"

	uniform = /obj/item/clothing/under/color/black
	suit = /obj/item/clothing/suit/hooded/chaplain_hoodie
	back = /obj/item/weapon/storage/backpack
	head = /obj/item/clothing/head/chaplain_hood
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/black
	l_ear = /obj/item/device/radio/headset/syndicate
	id = /obj/item/weapon/card/id/syndicate
	r_hand = /obj/item/weapon/nullrod/armblade
	backpack_contents = list(
		/obj/item/weapon/storage/box/survival = 1,
		/obj/item/device/flashlight = 1,
	)

/datum/outfit/admin/dark_priest/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return
	var/obj/item/weapon/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_all_accesses(), "Dark Priest", "syndie")
	var/obj/item/weapon/nullrod/armblade/B = H.r_hand
	if(istype(B))
		B.force = 20
		B.name = "blessing of the reaper"
		B.desc = "Sometimes, someone's just gotta die."
	var/obj/item/device/radio/headset/R = H.l_ear
	if(istype(R))
		R.flags |= NODROP
	var/obj/item/weapon/implant/dust/D = new /obj/item/weapon/implant/dust(H)
	D.implant(H)
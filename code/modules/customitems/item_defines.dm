// Add custom items you give to people here, and put their icons in custom_items.dmi
// Remember to change 'icon = 'custom_items.dmi'' for items not using /obj/item/fluff as a base
// Clothing item_state doesn't use custom_items.dmi. Just add them to the normal clothing files.

///////////////////////////////////////////////////////////////////////
/////////////////////PARADISE STATION CUSTOM ITEMS/////////////////////
///////////////////////////////////////////////////////////////////////

//////////////////////////////////
////////// Usable Items //////////
//////////////////////////////////

#define USED_MOD_HELM 1
#define USED_MOD_SUIT 2

/obj/item/fluff
	var/used = 0

/obj/item/fluff/tattoo_gun // Generic tattoo gun, make subtypes for different folks
	name = "disposable tattoo pen"
	desc = "A cheap plastic tattoo application pen."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "tatgun"
	force = 0
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	var/tattoo_name = "tiger stripe tattoo" // Tat name for visible messages
	var/tattoo_icon = "Tiger-stripe Tattoo" // body_accessory.dmi, new icons defined in sprite_accessories.dm
	var/tattoo_r = 1 // RGB values for the body markings
	var/tattoo_g = 1
	var/tattoo_b = 1
	toolspeed = 1
	usesound = 'sound/items/welder2.ogg'

/obj/item/fluff/tattoo_gun/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(user.a_intent == INTENT_HARM)
		user.visible_message("<span class='warning'>[user] stabs [M] with the [src]!</span>", "<span class='warning'>You stab [M] with the [src]!</span>")
		to_chat(M, "<span class='userdanger'>[user] stabs you with the [src]!<br></span><span class = 'warning'>You feel a tiny prick!</span>")
		return

	if(used)
		to_chat(user, "<span class= 'notice'>The [src] is out of ink.</span>")
		return

	if(!istype(M, /mob/living/carbon/human))
		to_chat(user, "<span class= 'notice'>You don't think tattooing [M] is the best idea.</span>")
		return

	var/mob/living/carbon/human/target = M

	if(ismachine(target))
		to_chat(user, "<span class= 'notice'>[target] has no skin, how do you expect to tattoo [target.p_them()]?</span>")
		return

	if(target.m_styles["body"] != "None")
		to_chat(user, "<span class= 'notice'>[target] already has body markings, any more would look silly!</span>")
		return

	var/datum/sprite_accessory/body_markings/tattoo/temp_tatt = GLOB.marking_styles_list[tattoo_icon]
	if(!(target.dna.species.name in temp_tatt.species_allowed))
		to_chat(user, "<span class= 'notice'>You can't think of a way to make the [tattoo_name] design work on [target == user ? "your" : "[target]'s"] body type.</span>")
		return

	if(target == user)
		to_chat(user, "<span class= 'notice'>You use the [src] to apply a [tattoo_name] to yourself!</span>")

	else
		user.visible_message("<span class='notice'>[user] begins to apply a [tattoo_name] [target] with the [src].</span>", "<span class='notice'>You begin to tattoo [target] with the [src]!</span>")
		if(!do_after(user, 30 * toolspeed, target = M))
			return
		user.visible_message("<span class='notice'>[user] finishes the [tattoo_name] on [target].</span>", "<span class='notice'>You finish the [tattoo_name].</span>")

	if(!used) // No exploiting do_after to tattoo multiple folks.
		target.change_markings(tattoo_icon, "body")
		target.change_marking_color(rgb(tattoo_r, tattoo_g, tattoo_b), "body")

		playsound(src.loc, usesound, 20, 1)
		used = 1
		update_icon()

/obj/item/fluff/tattoo_gun/update_icon()
	..()

	overlays.Cut()

	if(!used)
		var/image/ink = image(src.icon, src, "ink_overlay")
		ink.icon += rgb(tattoo_r, tattoo_g, tattoo_b, 190)
		overlays += ink

/obj/item/fluff/tattoo_gun/New()
	..()
	update_icon()

/obj/item/fluff/tattoo_gun/elliot_cybernetic_tat
	desc = "A cheap plastic tattoo application pen.<br>This one seems heavily used."
	tattoo_name = "circuitry tattoo"
	tattoo_icon = "Elliot Circuit Tattoo"
	tattoo_r = 48
	tattoo_g = 138
	tattoo_b = 176

/obj/item/fluff/tattoo_gun/elliot_cybernetic_tat/attack_self(mob/user as mob)
	if(!used)
		var/ink_color = input("Please select an ink color.", "Tattoo Ink Color", rgb(tattoo_r, tattoo_g, tattoo_b)) as color|null
		if(ink_color && !(user.incapacitated() || used) )
			tattoo_r = color2R(ink_color)
			tattoo_g = color2G(ink_color)
			tattoo_b = color2B(ink_color)

			to_chat(user, "<span class='notice'>You change the color setting on the [src].</span>")

			update_icon()

	else
		to_chat(user, "<span class='notice'>The [src] is out of ink!</span>")

/obj/item/fluff/bird_painter // BirdtTalon: Kahkiri
	name = "Orb of Onyx"
	desc = "It is imbued with such dark power as to corrupt the very appearance of those who gaze into its depths."
	icon_state = "bird_orb"
	icon = 'icons/obj/custom_items.dmi'

/obj/item/fluff/bird_painter/attack_self(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.s_tone = -115
		H.regenerate_icons()
		to_chat(user, "You use [src] on yourself.")
		qdel(src)

/obj/item/claymore/fluff // MrBarrelrolll: Maximus Greenwood
	name = "Greenwood's Blade"
	desc = "A replica claymore with strange markings scratched into the blade."
	force = 5
	sharp = 0

/obj/item/claymore/fluff/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	return 0

/obj/item/fluff/rsik_katana //Xydonus: Rsik Ugsharki Atan
	name = "ceremonial katana"
	desc = "A shimmering ceremonial golden katana, for the most discerning class of ninja. Looks expensive, and fragile."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "rsik_katana"
	item_state = "rsik_katana"
	lefthand_file = 'icons/mob/inhands/fluff_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/fluff_righthand.dmi'
	force = 5
	sharp = 0
	flags = CONDUCT
	slot_flags = SLOT_BELT
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("attacked", "slashed", "stabbed", "sliced")
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/fluff/rsik_katana/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] tries to stab [src] into [user.p_their()] stomach! Except [src] shatters! [user.p_they(TRUE)] look[user.p_s()] as if [user.p_they()] might die from the shame.</span>")
	return BRUTELOSS

/obj/item/crowbar/fluff/zelda_creedy_1 // Zomgponies: Griffin Rowley
	name = "Zelda's Crowbar"
	desc = "A pink crow bar that has an engraving that reads, 'To Zelda. Love always, Dawn'"
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "zeldacrowbar"
	item_state = "crowbar"

/obj/item/clothing/glasses/monocle/fluff/trubus //Trubus: Wolf O'Shaw
	name = "Gold Thermal Eyepatch"
	desc = "Wolf's non-functional thermal eyepatch."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "wolf_eyepatch"

/obj/item/clothing/glasses/meson/fluff/book_berner_1 // Adrkiller59: Adam Cooper
	name = "bespectacled mesonic surveyors"
	desc = "One of the older meson scanner models retrofitted to perform like its modern counterparts."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "book_berner_1"

/obj/item/clothing/glasses/sunglasses_fake/fluff/kaki //Rapidvalj: Kakicharakiti
	name = "broken thermonocle"
	desc = "A weathered Vox thermonocle, doesn't seem to work anymore."
	icon_state = "thermoncle"

/obj/item/fluff/rapid_wheelchair_kit //Rapidvalj: Hakikarahiti
	name = "wheelchair conversion kit"
	desc = "An assorted set of exchangable parts for a wheelchair."
	icon_state = "modkit"

/obj/item/fluff/rapid_wheelchair_kit/afterattack(atom/target, mob/user, proximity)
	if(!proximity || !ishuman(user) || user.incapacitated())
		return

	if(istype(target, /obj/structure/chair/wheelchair) && !istype(target, /obj/structure/chair/wheelchair/bike))
		to_chat(user, "<span class='notice'>You modify the appearance of [target].</span>")
		var/obj/structure/chair/wheelchair/chair = target
		chair.icon = 'icons/obj/custom_items.dmi'
		chair.icon_state = "vox_wheelchair"
		chair.name = "vox wheelchair"
		chair.desc = "A luxurious Vox Wheelchair, weathered from use."
		chair.handle_rotation()
		qdel(src)
		return

	to_chat(user, "<span class='warning'>You can't modify [target]!</span>")

/obj/item/lighter/zippo/fluff/purple // GodOfOreos: Jason Conrad
	name = "purple engraved zippo"
	desc = "All craftsspacemanship is of the highest quality. It is encrusted with refined plasma sheets. On the item is an image of a dwarf and the words 'Strike the Earth!' etched onto the side."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "purple_zippo_off"
	icon_on = "purple_zippo_on"
	icon_off = "purple_zippo_off"

/obj/item/lighter/zippo/fluff/michael_guess_1 // mrbits: Callista Gold
	name = "engraved lighter"
	desc = "A golden lighter, engraved with some ornaments and a G."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "guessip"
	icon_on = "guessipon"
	icon_off = "guessip"

/obj/item/lighter/zippo/fluff/duckchan // Duckchan: Rybys Romney
	name = "Monogrammed Zippo"
	desc = " A shiny purple zippo lighter, engraved with Rybys Romney and BuzzPing's name, with a festive green flame."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "rybysfluff"
	icon_on = "rybysfluffopen"
	icon_off = "rybysfluff"

/obj/item/fluff/dogwhistle //phantasmicdream: Zeke Varloss
	name = "Sax's whistle"
	desc = "This whistle seems to have a strange aura about it. Maybe you should blow on it?"
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "dogwhistle"
	item_state = "dogwhistle"
	force = 2

/obj/item/fluff/dogwhistle/attack_self(mob/user)
	user.visible_message("<span class='notice'>[user] blows on the whistle, but no sound comes out.</span>",  "<span class='notice'>You blow on the whistle, but don't hear anything.</span>")
	addtimer(CALLBACK(src, .proc/summon_sax, user), 20)

/obj/item/fluff/dogwhistle/proc/summon_sax(mob/user)
	var/mob/living/simple_animal/pet/dog/corgi/C = new /mob/living/simple_animal/pet/dog/corgi(get_turf(user))
	C.name = "Sax"
	C.real_name = "Sax"
	var/obj/item/clothing/head/det_hat/D = new
	D.flags |= NODROP
	C.place_on_head(D)
	C.visible_message("<span class='notice'>[C] suddenly winks into existence at [user]'s feet!</span>")
	to_chat(user, "<span class='danger'>[src] crumbles to dust in your hands!</span>")
	user.drop_item()
	qdel(src)

/obj/item/storage/toolbox/fluff/lunchbox //godoforeos: Jason Conrad
	name = "lunchpail"
	desc = "A simple black lunchpail."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "lunch_box"
	item_state = "lunch_box"
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 9
	storage_slots = 3

/obj/item/storage/toolbox/fluff/lunchbox/New()
	..()
	new /obj/item/reagent_containers/food/snacks/sandwich(src)
	new /obj/item/reagent_containers/food/snacks/chips(src)
	new /obj/item/reagent_containers/food/drinks/cans/cola(src)


/obj/item/instrument/guitar/jello_guitar //Pineapple Salad: Dan Jello
	name = "Dan Jello's Pink Guitar"
	desc = "Dan Jello's special pink guitar."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "jello_guitar"
	item_state = "jello_guitar"
	righthand_file = 'icons/mob/inhands/fluff_righthand.dmi'
	lefthand_file = 'icons/mob/inhands/fluff_lefthand.dmi'

/obj/item/fluff/wingler_comb
	name = "blue comb"
	desc = "A blue comb, it looks like it was made to groom a Tajaran's fur."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "wingler_comb"
	attack_verb = list("combed")
	hitsound = 'sound/weapons/tap.ogg'
	force = 0
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL

/obj/item/fluff/wingler_comb/attack_self(mob/user)
	if(used)
		return

	var/mob/living/carbon/human/target = user
	if(!istype(target) || !istajaran(target)) // Only catbeasts, kthnx.
		return

	if(target.change_body_accessory("Jay Wingler Tail"))
		to_chat(target, "<span class='notice'>You comb your tail with the [src].</span>")
		used = 1

/obj/item/fluff/desolate_coat_kit //DesolateG: Micheal Smith
	name = "armored jacket conversion kit"
	desc = "Flaps of dark fabric, probably used to somehow modify some sort of an armored garment. Won't help with protection, though."
	icon_state = "modkit"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/fluff/desolate_coat_kit/afterattack(atom/target, mob/user, proximity)
	if(!proximity || !ishuman(user) || user.incapacitated())
		return

	if(!istype(target, /obj/item/clothing/suit/armor/hos))
		to_chat(user, "<span class='warning'>You can't modify [target]!</span>")
		return

	to_chat(user, "<span class='notice'>You modify the appearance of [target].</span>")
	var/obj/item/clothing/suit/armor/jacket = target
	jacket.icon_state = "desolate_coat_open"
	jacket.icon = 'icons/obj/custom_items.dmi'
	jacket.ignore_suitadjust = 0
	jacket.suit_adjusted = 1
	var/has_action = FALSE
	for(var/datum/action/A in jacket.actions)
		if(istype(A, /datum/action/item_action/openclose))
			has_action = TRUE
	if(!has_action)
		new /datum/action/item_action/openclose(jacket)//this actually works
	jacket.adjust_flavour = "unbutton"
	jacket.sprite_sheets = null
	user.update_inv_wear_suit()
	qdel(src)

/obj/item/fluff/fei_gasmask_kit //Fei Hazelwood: Tariq Yon-Dale
	name = "gas mask conversion kit"
	desc = "A gas mask conversion kit."
	icon_state = "modkit"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/fluff/fei_gasmask_kit/afterattack(atom/target, mob/user, proximity)
	if(!proximity || !ishuman(user) || user.incapacitated())
		return

	if(istype(target, /obj/item/clothing/mask/gas) && !istype(target, /obj/item/clothing/mask/gas/welding))
		to_chat(user, "<span class='notice'>You modify the appearance of [target].</span>")
		var/obj/item/clothing/mask/gas/M = target
		M.name = "Prescription Gas Mask"
		M.desc = "It looks heavily modified, but otherwise functions as a gas mask. The words “Property of Yon-Dale” can be seen on the inner band."
		M.icon = 'icons/obj/custom_items.dmi'
		M.icon_state = "gas_tariq"
		M.sprite_sheets = list(
			"Vulpkanin" = 'icons/mob/species/vulpkanin/mask.dmi'
			)
		user.update_icons()
		qdel(src)
		return

	to_chat(user, "<span class='warning'>You can't modify [target]!</span>")

/obj/item/fluff/desolate_baton_kit //DesolateG: Micheal Smith
	name = "stun baton conversion kit"
	desc = "Some sci-fi looking parts for a stun baton."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "scifikit"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/fluff/desolate_baton_kit/afterattack(atom/target, mob/user, proximity)
	if(!proximity || !ishuman(user) || user.incapacitated())
		return

	if(istype(target, /obj/item/melee/baton) && !istype(target, /obj/item/melee/baton/cattleprod))
		to_chat(user, "<span class='notice'>You modify the appearance of [target].</span>")
		var/obj/item/melee/baton/the_baton = target
		the_baton.base_icon = "desolate_baton"
		the_baton.item_state = "desolate_baton"
		the_baton.icon = 'icons/obj/custom_items.dmi'
		the_baton.lefthand_file = 'icons/mob/inhands/fluff_lefthand.dmi'
		the_baton.righthand_file = 'icons/mob/inhands/fluff_righthand.dmi'
		the_baton.update_icon()
		user.update_icons()
		qdel(src)
		return

	to_chat(user, "<span class='warning'>You can't modify [target]!</span>")

/obj/item/fluff/cardgage_helmet_kit //captain cardgage: Richard Ulery
	name = "welding helmet modkit"
	desc = "Some spraypaint and a stencil, perfect for painting flames onto a welding helmet!"
	icon_state = "modkit"
	w_class = WEIGHT_CLASS_SMALL
	force = 0
	throwforce = 0

/obj/item/fluff/cardgage_helmet_kit/afterattack(atom/target, mob/user, proximity)
	if(!proximity || !ishuman(user) || user.incapacitated())
		return

	if(istype(target, /obj/item/clothing/head/welding))
		to_chat(user, "<span class='notice'>You modify the appearance of [target].</span>")

		var/obj/item/clothing/head/welding/flamedecal/P = new(get_turf(target))
		target.transfer_fingerprints_to(P)
		qdel(target)
		qdel(src)
		return
	to_chat(user, "<span class='warning'>You can't modify [target]!</span>")

/obj/item/fluff/merchant_sallet_modkit //Travelling Merchant: Trav Noble. This is what they spawn in with
	name = "SG Helmet modkit"
	desc = "A modkit that can make most helmets look like a Shellguard Helmet."
	icon_state = "modkit"
	w_class = WEIGHT_CLASS_SMALL
	force = 0
	throwforce = 0

/obj/item/fluff/merchant_sallet_modkit/afterattack(atom/target, mob/user, proximity)
	if(!proximity || !ishuman(user) || user.incapacitated())
		return

	var/mob/living/carbon/human/H = user
	if(istype(target, /obj/item/clothing/head/helmet) && !istype(target, /obj/item/clothing/head/helmet/space))
		var/obj/item/clothing/head/helmet/helm = target
		var/obj/item/clothing/head/helmet/fluff/merchant_sallet/sallet = new(get_turf(target))
		sallet.flags = helm.flags
		sallet.flags_cover = helm.flags_cover
		sallet.armor = helm.armor
		sallet.flags_inv = helm.flags_inv
		sallet.cold_protection = helm.cold_protection
		sallet.min_cold_protection_temperature = helm.min_cold_protection_temperature
		sallet.heat_protection = helm.heat_protection
		sallet.max_heat_protection_temperature = helm.max_heat_protection_temperature
		sallet.strip_delay = helm.strip_delay
		sallet.put_on_delay = helm.put_on_delay
		sallet.resistance_flags = helm.resistance_flags
		sallet.flags_cover = helm.flags_cover
		sallet.visor_flags = helm.visor_flags
		sallet.visor_flags_inv = helm.visor_flags_inv
		if(!(BLOCKHAIR in sallet.flags))
			sallet.flags |= BLOCKHAIR

		sallet.add_fingerprint(H)
		target.transfer_fingerprints_to(sallet)
		playsound(src.loc, 'sound/items/screwdriver.ogg', 50, 1)
		to_chat(user, "<span class='notice'>You modify [target] with [src].</span>")
		H.update_inv_head()
		qdel(target)
		qdel(src)
	else
		to_chat(user, "<span class='warning'>You can't modify [target]!</span>")

/obj/item/fluff/k3_webbing_modkit //IK3I: Yakikatachi
	name = "webbing modkit"
	desc = "A modkit that can be used to turn certain vests and labcoats into lightweight webbing"
	icon_state = "modkit"
	w_class = 2
	force = 0
	throwforce = 0

/obj/item/fluff/k3_webbing_modkit/afterattack(atom/target, mob/user, proximity)
	if(!proximity || !ishuman(user) || user.incapacitated())
		return

	if(istype(target, /obj/item/clothing/suit/storage/labcoat) || istype(target, /obj/item/clothing/suit/storage/hazardvest))
		var/mob/living/carbon/human/H = user
		var/obj/item/clothing/suit/storage/S = target
		var/obj/item/clothing/suit/storage/fluff/k3_webbing/webbing = new(get_turf(target))
		webbing.allowed = S.allowed
		to_chat(user, "<span class='notice'>You modify the [S] with [src].</span>")
		H.update_inv_wear_suit()
		qdel(S)
		qdel(src)
	else
		to_chat(user, "<span class='warning'>You can't modify [target]!</span>")


/obj/item/fluff/pyro_wintersec_kit //DarkLordpyro: Valthorne Haliber
	name = "winter sec conversion kit"
	desc = "A securirty hardsuit conversion kit."
	icon_state = "modkit"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/fluff/pyro_wintersec_kit/afterattack(atom/target, mob/user, proximity)
	if(!proximity || !ishuman(user) || user.incapacitated())
		return
	var/mob/living/carbon/human/H = user

	if(istype(target, /obj/item/clothing/head/helmet/space/hardsuit/security))
		if(used & USED_MOD_HELM)
			to_chat(H, "<span class='notice'>The kit's helmet modifier has already been used.</span>")
			return
		to_chat(H, "<span class='notice'>You modify the appearance of [target].</span>")
		used |= USED_MOD_HELM

		var/obj/item/clothing/head/helmet/space/hardsuit/security/P = target
		P.name = "winterised security hardsuit helmet"
		P.desc = "A rare winterised variant of the security hardsuit helmet, used on colder mining worlds for security patrols."
		P.icon = 'icons/obj/custom_items.dmi'
		P.icon_state = "hardsuit0-secf"
		P.item_state = "hardsuit0-secf"
		P.sprite_sheets = null
		P.item_color = "secf"
		user.update_icons()

		if(P == H.head)
			H.update_inv_head()
		return
	if(istype(target, /obj/item/clothing/suit/space/hardsuit/security))
		if(used & USED_MOD_SUIT)
			to_chat(user, "<span class='notice'>The kit's suit modifier has already been used.</span>")
			return
		to_chat(H, "<span class='notice'>You modify the appearance of [target].</span>")
		used |= USED_MOD_SUIT

		var/obj/item/clothing/suit/space/hardsuit/security/P = target
		P.name = "winterised security hardsuit"
		P.desc = "A rare winterised variant of the security hardsuit, used on colder mining worlds for securiry patrols, this one has 'Haliber' written on an ID patch located on the right side of the chest."
		P.icon = 'icons/obj/custom_items.dmi'
		P.icon_state = "hardsuit-secf"
		P.item_state = "hardsuit-secf"
		P.sprite_sheets = null
		user.update_icons()

		if(P == H.wear_suit)
			H.update_inv_wear_suit()
		return
	to_chat(user, "<span class='warning'>You can't modify [target]!</span>")


/obj/item/fluff/sylus_conversion_kit //Decemviri: Sylus Cain
	name = "cerberus pattern conversion kit"
	desc = "A securirty hardsuit conversion kit."
	icon_state = "modkit"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/fluff/sylus_conversion_kit/afterattack(atom/target, mob/user, proximity)
	if(!proximity || !ishuman(user) || user.incapacitated())
		return
	var/mob/living/carbon/human/H = user

	if(istype(target, /obj/item/clothing/head/helmet/space/hardsuit/security))
		if(used & USED_MOD_HELM)
			to_chat(H, "<span class='notice'>The kit's helmet modifier has already been used.</span>")
			return
		to_chat(H, "<span class='notice'>You modify the appearance of [target].</span>")
		used |= USED_MOD_HELM

		var/obj/item/clothing/head/helmet/space/hardsuit/security/P = target
		P.name = "cerberus pattern security hardsuit helmet"
		P.desc = "A special helmet that protects against hazardous, low pressure environments. Has an additional layer of armor and rigging for combat duty."
		P.icon = 'icons/obj/custom_items.dmi'
		P.icon_state = "hardsuit0-secc"
		P.item_state = "hardsuit0-secc"
		P.sprite_sheets = null
		P.item_color = "secc"
		user.update_icons()

		if(P == H.head)
			H.update_inv_head()
		if(used & USED_MOD_HELM && used & USED_MOD_SUIT)
			qdel(src)
		return

	if(istype(target, /obj/item/clothing/suit/space/hardsuit/security))
		if(used & USED_MOD_SUIT)
			to_chat(user, "<span class='notice'>The kit's suit modifier has already been used.</span>")
			return
		to_chat(H, "<span class='notice'>You modify the appearance of [target].</span>")
		used |= USED_MOD_SUIT

		var/obj/item/clothing/suit/space/hardsuit/security/P = target
		P.name = "cerberus pattern security hardsuit"
		P.desc = "A special suit that protects against hazardous, low pressure environments. Has an additional layer of armor and rigging for combat duty"
		P.icon = 'icons/obj/custom_items.dmi'
		P.icon_state = "hardsuit-secc"
		P.item_state = "hardsuit-secc"
		P.sprite_sheets = null
		user.update_icons()

		if(P == H.wear_suit)
			H.update_inv_wear_suit()
		if(used & USED_MOD_HELM && used & USED_MOD_SUIT)
			qdel(src)
		return

	to_chat(user, "<span class='warning'>You can't modify [target]!</span>")


#undef USED_MOD_HELM
#undef USED_MOD_SUIT


//////////////////////////////////
//////////// Clothing ////////////
//////////////////////////////////

//////////// Gloves //////////////

//////////// Eye Wear ////////////
/obj/item/clothing/glasses/hud/security/sunglasses/fluff/eyepro //T0EPIC4U: Ty Omaha
	name = "Tacticool EyePro"
	desc = "Tacticool ballistic glasses, for making all operators look badass."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "eyepro"
	item_state = "eyepro"

/obj/item/clothing/glasses/hud/security/sunglasses/fluff/voxxyhud //LP Spartan: Kaskreyarawkta
	name = "VoxxyHUD"
	desc = "A worn down visor from a vox raider's gear, crudely ripped from its helmet and linked into the security systems of the station. The word 'Kask' is scratched into the side."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "hud-spartan"

//////////// Hats ////////////
/obj/item/clothing/head/fluff/heather_winceworth // Regens: Heather Winceworth
	name= "Heather's rose"
	desc= "A beautiful purple rose for your hair."
	icon= 'icons/obj/custom_items.dmi'
	icon_state = "hairflowerp"
	item_state = "hairflowerp"

/obj/item/clothing/head/valkyriehelmet //R3Valkyrie: Rikki
	name = "charred visor"
	desc = "A visor of alien origin, charred by fire and completely non-functioning. It's been impeccably polished, shiny!"
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "charred_visor"
	species_restricted = list("Vox")

/obj/item/clothing/head/bearpelt/fluff/polar //Gibson1027: Sploosh
	name = "polar bear pelt hat"
	desc = "Fuzzy, and also stained with blood."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "polarbearpelt"

/obj/item/clothing/head/fluff/sparkyninja_beret // Sparkyninja: Neil Wilkinson
	name = "royal marines commando beret"
	desc = "Dark Green beret with an old insignia on it."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "sparkyninja_beret"

/obj/item/clothing/head/beret/fluff/sigholt //sigholtstarsong: Sigholt Starsong
	name = "Lieutenant Starsong's beret"
	desc = "This beret bears insignia of the SOLGOV Marine Corps 417th Regiment, 2nd Battalion, Bravo Company. It looks meticulously maintained."
	icon_state = "beret_hos"
	item_state = "beret_hos"

/obj/item/clothing/head/pirate/fluff/stumpy //MrFroztee: Stumpy
	name = "The Sobriety Skullcap"
	desc = "A hat suited for the king of the pirates"
	icon_state = "pirate"
	item_state = "pirate"

/obj/item/clothing/head/pirate/fluff/stumpy/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/item/clothing/head/pirate/fluff/stumpy/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/head/pirate/fluff/stumpy/process()
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(H.head == src)
			H.Slur(3) //always slur

/obj/item/clothing/head/beret/fluff/linda //Epic_Charger: Linda Clark
	name = "Green beret"
	desc = "A beret, an artist's favorite headwear. This one has two holes cut on the edges."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "linda_beret"

/obj/item/clothing/head/fluff/kaki //Rapidvalj: Kakicharakiti
	name = "sleek fancy leader hat"
	desc = "A uniquely colored vox leader hat. Has some signs of wear."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "kakicharakiti"

/obj/item/clothing/head/helmet/fluff/merchant_sallet //Travelling Merchant: Trav Noble. This >>IS NOT<< what they spawn in with
	name = "Shellguard Helmet"
	desc = "A Shellguard Helmet with the name Noble written on the inside."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "merchant_sallet_visor_bevor"
	item_state = "merchant_sallet_visor_bevor"
	actions_types = list(/datum/action/item_action/toggle_helmet_mode)
	toggle_cooldown = 20
	toggle_sound = 'sound/items/change_jaws.ogg'
	flags = BLOCKHAIR
	flags_inv = HIDEEYES|HIDEMASK|HIDEFACE|HIDEEARS
	var/state = "Soldier Up"

/obj/item/clothing/head/helmet/fluff/merchant_sallet/attack_self(mob/user)
	if(!user.incapacitated() && (world.time > cooldown + toggle_cooldown) && Adjacent(user))
		var/list/options = list()
		options["Soldier Up"] = list(
			"icon_state"	= "merchant_sallet_visor_bevor",
			"visor_flags"	= null,
			"mask_flags"	= null
			)
		options["Soldier Down"] = list(
			"icon_state"	= "merchant_sallet_visor",
			"visor_flags"	= HIDEEYES,
			"mask_flags"	= HIDEMASK|HIDEFACE
			)
		options["Technician Up"] = list(
			"icon_state"	= "merchant_sallet_bevor",
			"visor_flags"	= null,
			"mask_flags"	= null
			)
		options["Technician Down"] = list(
			"icon_state"	= "merchant_sallet",
			"visor_flags"	= HIDEEYES,
			"mask_flags"	= HIDEMASK|HIDEFACE
			)

		var/choice = input(user, "How would you like to adjust the helmet?", "Adjust Helmet") as null|anything in options

		if(choice && choice != state && !user.incapacitated() && Adjacent(user))
			var/list/new_state = options[choice]
			icon_state = new_state["icon_state"]
			state = choice
			to_chat(user, "You adjust the helmet.")
			playsound(src.loc, "[toggle_sound]", 100, 0, 4)
			user.update_inv_head()
			return 1

/obj/item/clothing/head/beret/fluff/elo	//V-Force_Bomber: E.L.O.
	name = "E.L.O.'s medical beret"
	desc = "E.L.O.s personal medical beret, issued by Nanotrassen and awarded along with her medal."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "elo-beret"

//////////// Suits ////////////
/obj/item/clothing/suit/fluff
	icon = 'icons/obj/custom_items.dmi'
	actions_types = list()
	ignore_suitadjust = 1
	adjust_flavour = null
	sprite_sheets = null

/obj/item/clothing/suit/storage/labcoat/fluff/pulsecoat //ozewse : Daniel Harper : Donated to them by Runemeds, who is the original donor.
	name = "EMT pulse coat"
	desc = "An EMT labcoat modified to track the wearer's heartbeat. It's so worn out that it doesn't seem to accurately track heartbeat anymore. Also, the zipper is stuck."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "pulsecoat"
	item_state = "pulsecoat"
	ignore_suitadjust = 1
	actions_types = list()

/obj/item/clothing/suit/jacket/miljacket/patch // sniper_fairy : P.A.T.C.H.
	name = "custom purple military jacket"
	desc = "A canvas jacket styled after classical American military garb. Feels sturdy, yet comfortable. This one has a medical patch on it."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "shazjacket_purple_open"
	ignore_suitadjust = 0
	suit_adjusted = 1
	actions_types = list(/datum/action/item_action/openclose)
	adjust_flavour = "unbutton"

/obj/item/clothing/suit/jacket/miljacket/patch/attack_self(mob/user)
	var/list/options = list()
	options["purple"] = "shazjacket_purple"
	options["purple light"] = "shazjacket_purple_light"
	options["yellow"] = "shazjacket_yellow"
	options["blue"] = "shazjacket_blue"
	options["cyan"] = "shazjacket_cyan"
	options["command blue"] = "shazjacket_command"
	options["brown"] = "shazjacket_brown"
	options["orange"] = "shazjacket_orange"
	options["engi orange"] = "shazjacket_engi"
	options["grey"] = "shazjacket_grey"
	options["black"] ="shazjacket_black"
	options["red"] ="shazjacket_red"
	options["red light"] ="shazjacket_red_light"
	options["pink"] ="shazjacket_pink"
	options["magenta"] ="shazjacket_magenta"
	options["navy"] ="shazjacket_navy"
	options["white"] ="shazjacket_white"
	options["green"] ="shazjacket_green"
	options["lime"] ="shazjacket_lime"
	options["army green"] ="shazjacket_army"

	var/choice = input(user, "What color do you wish your jacket to be?", "Change color") as null|anything in options

	if(choice && !user.stat && in_range(user, src))
		if(suit_adjusted)
			icon_state = "[options[choice]]_open"
		else
			icon_state = options[choice]
		to_chat(user, "You turn your coat inside out and now it's [choice]!")
		name = "custom [choice] military jacket"
		user.update_inv_wear_suit()
		return 1

	. = ..()

/obj/item/clothing/suit/fluff/dusty_jacket //ComputerlessCitizen: Screech
	name = "Dusty Jacket"
	desc = "A worn leather jacket. Some burn holes have been patched."
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	icon_state = "dusty_jacket"

/obj/item/clothing/suit/fluff/cheeky_sov_coat //CheekyCrenando: Srusu Rskuzu
	name = "Srusu's Greatcoat"
	desc = "A heavy wool Soviet-style greatcoat. A name is written in fancy handwriting on the inside tag: Srusu Rskuzu"
	icon = 'icons/obj/custom_items.dmi'
	item_state = "cheeky_sov_coat"
	icon_state = "cheeky_sov_coat"

/obj/item/clothing/suit/fluff/supplymaster_jacket //Denthamos: Henry Grandpa Gadow
	name = "faded NT Supply Master's Coat"
	desc = "A faded leather overcoat bearing a worn out badge from the NAS Crescent on the shoulder, and a designation tag of Supply Master on the front.  A tarnished gold nameplate says H.Gadow on it."
	icon_state = "supplymaster_jacket_open"
	item_state = "supplymaster_jacket_open"
	ignore_suitadjust = 0
	suit_adjusted = 1
	allowed = list(/obj/item/flashlight,/obj/item/tank/emergency_oxygen,/obj/item/toy,/obj/item/storage/fancy/cigarettes,/obj/item/lighter)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS
	actions_types = list(/datum/action/item_action/button)
	adjust_flavour = "unbutton"

/obj/item/clothing/suit/storage/labcoat/fluff/aeneas_rinil //Socialsystem: Lynn Fea
	name = "Robotics labcoat"
	desc = "A labcoat with a few markings denoting it as the labcoat of roboticist."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "aeneasrinil_open"
	sprite_sheets = null

/obj/item/clothing/suit/jacket/fluff/kidosvest // Anxipal: Kido Qasteth
	name = "Kido's Vest"
	desc = "A rugged leather vest with a tag labelled \"Men of Mayhem.\""
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "kidosvest"
	item_state = "kidosvest"
	ignore_suitadjust = 1
	actions_types = list()
	adjust_flavour = null
	sprite_sheets = null

/obj/item/clothing/suit/jacket/fluff/jacksvest // Anxipal: Jack Harper
	name = "Jack's vest"
	desc = "A rugged leather vest with a tag labelled \"President\"."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "jacksvest"
	ignore_suitadjust = TRUE
	actions_types = list()
	adjust_flavour = null
	sprite_sheets = null

/obj/item/clothing/suit/fluff/kluys // Kluys: Cripty Pandaen
	name = "Nano Fibre Jacket"
	desc = "A Black Suit made out of nanofibre. The newest of cyberpunk fashion using hightech liquid to solid materials."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "Kluysfluff1"
	item_state = "Kluysfluff1"
	blood_overlay_type = "coat"
	body_parts_covered = UPPER_TORSO|ARMS

/obj/item/clothing/suit/fluff/kluys/verb/toggle()
	set name = "Toggle Nanofibre Mode"
	set category = "Object"
	set src in usr

	if(usr.stat || usr.restrained())
		return 0

	switch(icon_state)
		if("Kluysfluff1")
			src.icon_state = "Kluysfluff2"
			to_chat(usr, "The fibre unfolds into a jacket.")
		if("Kluysfluff2")
			src.icon_state = "Kluysfluff3"
			to_chat(usr, "The fibre unfolds into a coat.")
		if("Kluysfluff3")
			src.icon_state = "Kluysfluff1"
			to_chat(usr, "The fibre gets sucked back into its holder.")
		else
			to_chat(usr, "You attempt to hit the button but can't.")
			return
	usr.update_inv_wear_suit()

/obj/item/clothing/suit/storage/labcoat/fluff/red // Sweetjealousy: Sophie Faust-Noms
	name = "red labcoat"
	desc = "A suit that protects against minor chemical spills. Has a red stripe on the shoulders and rolled up sleeves."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "labcoat_red_open"
	sprite_sheets = null

/obj/item/clothing/suit/storage/labcoat/fluff/ionward_labcoat // Ionward: Gemini
	name = "Technocracy labcoat"
	desc = "A thin, faded, carbon fiber labcoat. On the back, a Technocracy vessel's logo. Inside, the name 'Gemini' is printed on the collar."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "ionward_labcoat_open"
	sprite_sheets = null

/obj/item/clothing/suit/fluff/stobarico_greatcoat // Stobarico: F.U.R.R.Y
	name = "\improper F.U.R.R.Y's Nanotrasen Greatcoat"
	desc = "A greatcoat with Nanotrasen colors."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "stobarico_jacket"


/obj/item/clothing/suit/hooded/hoodie/fluff/linda // Epic_Charger: Linda Clark
	name = "Green Nanotrasen Hoodie"
	desc = "A green hoodie with the Nanotrasen logo on the back. It looks weathered."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "linda_hoodie"
	hoodtype = /obj/item/clothing/head/hooded/hood/fluff/linda

/obj/item/clothing/head/hooded/hood/fluff/linda //Epic_Charger: Linda Clark
	icon_state = "greenhood"

/obj/item/clothing/suit/hooded/hoodie/hylo //Hylocereus: Sam Aria
	name = "worn assymetrical hoodie"
	desc = "A soft, cozy longline hoodie. It looks old and worn, but well cared for. There's no label, but a series of dates and names is penned on a scrap of fabric sewn on the inside of the left side of the chest - 'Sam Aria' is scrawled atop them all, next to the words 'Please Remember'."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "sam_hoodie"
	hoodtype = /obj/item/clothing/head/hooded/hood/hylo

/obj/item/clothing/head/hooded/hood/hylo
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "sam_hood"

/obj/item/clothing/suit/hooded/fluff/bone //Doru7: Jack Bone
	name = "skeleton suit"
	desc = "A spooky full-body suit! This one doesn't glow in the dark."
	body_parts_covered = HEAD|UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "skeleton_suit"
	hoodtype = /obj/item/clothing/head/hooded/hood/fluff/skeleton

/obj/item/clothing/head/hooded/hood/fluff/skeleton
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "skeleton_hood"

/obj/item/clothing/suit/armor/shodanscoat // RazekPraxis: SHODAN
	name = "SHODAN's Captain's Coat"
	desc = "A black coat with gold trim and an old US Chevron printed on the back. Edgy."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "shodancoat"

/obj/item/clothing/suit/storage/fluff/k3_webbing
	name = "vox tactical webbing"
	desc = "A somewhat worn but well kept set of vox tactical webbing. It has a couple of pouches attached."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "k3_webbing"

	sprite_sheets = list("Vox" = 'icons/mob/species/vox/suit.dmi')
	ignore_suitadjust = 0
	actions_types = list(/datum/action/item_action/toggle)
	suit_adjusted = 0

/obj/item/clothing/suit/storage/fluff/k3_webbing/adjustsuit(var/mob/user)
	if(!user.incapacitated())
		var/flavour
		if(suit_adjusted)
			flavour = "off"
			icon_state = copytext(icon_state, 1, findtext(icon_state, "_on"))
			item_state = copytext(item_state, 1, findtext(item_state, "_on"))
			suit_adjusted = 0 //Lights Off
		else
			flavour = "on"
			icon_state += "_on"
			item_state += "_on"
			suit_adjusted = 1 //Lights On

		for(var/X in actions)
			var/datum/action/A = X
			A.UpdateButtonIcon()
		to_chat(user, "You turn the [src]'s lighting system [flavour].")
		user.update_inv_wear_suit()

/obj/item/clothing/suit/hooded/hoodie/fluff/xantholne // Xantholne: Meex Zwichsnicrur
	name = "stripped winter coat"
	desc = "A velvety smooth black winter coat with white and red stripes on the side."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "xantholne_wintercoat"
	hoodtype = /obj/item/clothing/head/hooded/hood/fluff/xantholne
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	allowed = list(/obj/item/flashlight, /obj/item/tank/emergency_oxygen, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter)


/obj/item/clothing/head/hooded/hood/fluff/xantholne // Xantholne: Meex Zwichsnicrur
	name = "black winter hood"
	desc = "A black hood attached to a stripped winter coat."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "xantholne_winterhood"
	body_parts_covered = HEAD
	flags = BLOCKHAIR
	flags_inv = HIDEEARS

/obj/item/clothing/suit/hooded/hoodie/fluff/xydonus //Xydonus: Rsik Ugsharki Atan | Based off of the bomber jacket, but with a hood slapped on (for allowed suit storage)
	name = "custom fit bomber jacket"
	desc = "Made for Unathi who likes to show off their big horns."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "xydonus_jacket"
	ignore_suitadjust = 0
	hoodtype = /obj/item/clothing/head/hooded/hood/fluff/xydonus
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS
	allowed = list(/obj/item/flashlight,/obj/item/tank/emergency_oxygen,/obj/item/toy,/obj/item/storage/fancy/cigarettes,/obj/item/lighter)

/obj/item/clothing/head/hooded/hood/fluff/xydonus
	name = "custom fit hood"
	desc = "A hood with some horns <i>glued</i> to them, or something like that. Custom fit for a Unathi's head shape."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "xydonus_bomberhood"
	body_parts_covered = HEAD
	flags = BLOCKHAIR
	flags_inv = HIDEEARS

/obj/item/clothing/suit/fluff/pineapple //Pineapple Salad: Dan Jello
	name = "red trench coat"
	desc = "A red coat with cheaply made plastic accessories."
	icon_state = "pineapple_trench"

/obj/item/fluff/pinapplehairgel ////Pineapple Salad: Dan Jello
	name = "slime hair gel"
	desc = "A bottle containing extra..material..for custom 'hair' styling."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "ps_hairgel"
	attack_verb = list("smacked")
	hitsound = 'sound/weapons/tap.ogg'
	force = 0
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL

/obj/item/fluff/pinapplehairgel/attack_self(mob/user)
	var/mob/living/carbon/human/target = user
	if(!istype(target) || !isslimeperson(target))
		return

	if(target.change_hair("Sasook Hair", 1))
		to_chat(target, "<span class='notice'>You dump some of [src] on your head and style it around.</span>")



/obj/item/clothing/suit/hooded/wintercoat/fluff/shesi //MrSynnester : Shesi Skaklas
	name = "custom made winter coat"
	desc = "A custom made winter coat with the arms removed. Looks comfy."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "shesicoat"
	item_state = "shesicoat"
	hoodtype = /obj/item/clothing/head/hooded/hood/fluff/shesi
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	cold_protection = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/head/hooded/hood/fluff/shesi //MrSynnester : Shesi Skaklas
	name = "custom made winter hood"
	desc = "A custom made winter coat hood. Looks comfy."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "shesicoat_hood2"
	body_parts_covered = HEAD
	flags = BLOCKHAIR
	flags_inv = HIDEEARS

/obj/item/clothing/suit/jacket/dtx //AffectedArc07: DTX
	name = "telecommunications bomber jacket"
	desc = "Looks like something only a nerd would buy. Has a tag inside reading <i>Property of DTX</i>."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "dtxbomber"
	item_state = "dtxbomber"
	ignore_suitadjust = 0
	allowed = list(/obj/item/flashlight,/obj/item/tank/emergency_oxygen,/obj/item/toy,/obj/item/storage/fancy/cigarettes,/obj/item/lighter)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS
	actions_types = list(/datum/action/item_action/zipper)
	adjust_flavour = "unzip"

//////////// Uniforms ////////////
/obj/item/clothing/under/fluff/counterfeitguise_uniform 	// thatdanguy23 : Rissa Williams
	icon = 'icons/obj/custom_items.dmi'
	name = "Rissa's hand-me-downs"
	desc = "An old, hand-me-down baggy sweater and sweatpants combo. A label on the neck reads 'RISSA' in scruffy handwriting."
	lefthand_file = 'icons/mob/inhands/fluff_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/fluff_righthand.dmi'
	icon_state = "counterfeitguise"
	item_state = "counterfeitguise"
	item_color = "counterfeitguise"
	flags_size = ONESIZEFITSALL

/obj/item/clothing/under/fluff/benjaminfallout // Benjaminfallout: Pretzel Brassheart
	icon = 'icons/obj/custom_items.dmi'
	name = "Pretzel's dress"
	desc = "A nice looking dress"
	icon_state = "fallout_dress"
	item_state = "fallout_dress"
	item_color = "fallout_dress"

/obj/item/clothing/under/fluff/soviet_casual_uniform // Norstead : Natalya Sokolova
    icon = 'icons/obj/custom_items.dmi'
    name = "Soviet Casual Uniform"
    desc = "Female U.S.S.P. casual wear. Dlya Rodiny!"
    icon_state = "soviet_casual_uniform"
    item_state = "soviet_casual_uniform"
    item_color = "soviet_casual_uniform"

/obj/item/clothing/under/fluff/kharshai // Kharshai: Athena Castile
	name = "Castile formal outfit"
	desc = "A white and gold formal uniform, accompanied by a small pin with the numbers '004' etched upon it."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "castile_dress"
	item_state = "castile_dress"
	item_color = "castile_dress"

/obj/item/clothing/under/fluff/xantholne //Xantholne: Meex Zwichsnicrur
	name = "Stripped Shorts and Shirt"
	desc = "A silky pair of dark shorts with a matching shirt. The shirt's collar has a tag on the inside that reads 'Meexy' on it."
	icon = 'icons/obj/custom_items.dmi'
	lefthand_file = 'icons/mob/inhands/fluff_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/fluff_righthand.dmi'
	icon_state = "xantholne"
	item_state = "xantholne"
	item_color = "xantholne"

/obj/item/clothing/under/fluff/elishirt // FlattestGuitar9: Eli Randolph
	name = "casual dress shirt"
	desc = "A soft, white dress shirt paired up with black suit pants. The set looks comfortable."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "elishirt"
	item_state = "elishirt"
	item_color = "elishirt"
	displays_id = 0

/obj/item/clothing/under/fluff/jay_turtleneck // Jayfeather: Jay Wingler
	name = "Mar's Pattern Custom Turtleneck"
	desc = "It seems to be lightly dusted in orange fuzz, and damp with the smell of anti-freeze. It has a strange symbol in the middle."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "jaywingler"
	item_state = "jaywingler"
	item_color = "jaywingler"
	displays_id = 0

/obj/item/clothing/under/psysuit/fluff/isaca_sirius_1 // Xilia: Isaca Sirius
	name = "Isaca's suit"
	desc = "Black, comfortable and nicely fitting suit. Made not to hinder the wearer in any way. Made of some exotic fabric. And some strange glowing jewel at the waist. Name labels says; Property of Isaca Sirius; The Seeder."

/obj/item/clothing/under/fluff/jane_sidsuit // SyndiGirl: Zoey Scyth
	name = "NT-SID jumpsuit"
	desc = "A Nanotrasen Synthetic Intelligence Division jumpsuit, issued to 'volunteers'. On other people it looks fine, but right here a scientist has noted: on you it looks stupid."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "jane_sid_suit"
	item_state = "jane_sid_suit"
	item_color = "jane_sid_suit"
	has_sensor = 2
	sensor_mode = 3

/obj/item/clothing/under/fluff/jane_sidsuit/verb/toggle_zipper()
	set name = "Toggle Jumpsuit Zipper"
	set category = "Object"
	set src in usr

	if(usr.stat || usr.restrained())
		return 0

	if(src.icon_state == "jane_sid_suit_down")
		src.item_color = "jane_sid_suit"
		to_chat(usr, "You zip up \the [src].")
	else
		src.item_color = "jane_sid_suit_down"
		to_chat(usr, "You unzip and roll down \the [src].")

	src.icon_state = "[item_color]"
	src.item_state = "[item_color]"
	usr.update_inv_w_uniform()

/obj/item/clothing/under/fluff/honourable // MrBarrelrolll: Maximus Greenwood
	name = "Viridi Protegat"
	desc = "A set of chainmail adorned with a hide mantle. \"Greenwood\" is engraved into the right breast."
	icon = 'icons/obj/clothing/uniforms.dmi'
	icon_state = "roman"
	item_state = "maximus_armor"
	item_color = "maximus_armor"
	displays_id = 0
	strip_delay = 100

/obj/item/clothing/under/fluff/aegis //PlagueWalker: A.E.G.I.S.
	name = "gilded waistcoat"
	desc = "This black, gold-trimmed, rather expensive-looking uniform laced with fine materials appears comfortable despite its stiffness."
	icon = 'icons/obj/custom_items.dmi'
	lefthand_file = 'icons/mob/inhands/fluff_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/fluff_righthand.dmi'
	icon_state = "aegisuniform"
	item_state = "aegisuniform"
	item_color = "aegisuniform"
	displays_id = 0

/obj/item/clothing/under/fluff/elo_turtleneck // vforcebomber: E.L.O.
	name = "E.L.O's Turtleneck"
	desc = "This TurtleNeck belongs to the IPC E.L.O. And has her name sown into the upper left breast, a very wooly jumper."
	icon = 'icons/obj/custom_items.dmi' // for the floor sprite
	icon_override = 'icons/obj/custom_items.dmi' // for the mob sprite
	icon_state = "eloturtleneckfloor"
	item_color = "eloturtleneck"
	displays_id = FALSE

//////////// Masks ////////////

/obj/item/clothing/mask/bandana/fluff/dar //sasanek12: Dar'Konr
	name = "camo bandana"
	desc = "It's a worn-out bandana in camo paint"
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "bandcamo"

/obj/item/clothing/mask/gas/sechailer/fluff/spartan //LP Spartan: Kaskreyarawkta
	name = "minimal gasmask"
	desc = "Designed to cover as little of face as possible while still being a functional gasmask."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "spartan_mask"
	item_state = "spartan_mask"
	species_restricted = list("Vox")

//////////// Shoes ////////////

//////////// Sets ////////////
// Fox P McCloud: Fox McCloud
/obj/item/clothing/suit/storage/fox
	name = "Aeronautics Jacket"
	desc = "An aviator styled jacket made from a peculiar material; this one seems very old."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "fox_jacket"
	item_state = "fox_jacket"
	allowed = list(/obj/item/flashlight, /obj/item/tank/emergency_oxygen, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter, /obj/item/gun/projectile/automatic/pistol, /obj/item/gun/projectile/revolver, /obj/item/gun/projectile/revolver/detective)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/clothing/under/fluff/fox
	name = "Aeronautics Jumpsuit"
	desc = "A jumpsuit tailor made for spacefaring fighter pilots; this one seems very old."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "fox_suit"
	item_state = "g_suit"
	item_color = "fox_suit"
	displays_id = FALSE //still appears on examine; this is pure fluff.

/obj/item/clothing/suit/storage/fox/miljacket_desert
	name = "rugged military jacket"
	desc = "A rugged brown military jacket with a stylized 'A' embroidered on the back. It seems very old, yet is in near mint condition. Has a tag on the inside collar signed 'Fox McCloud'."
	icon_state = "fox_coat"
	item_color = "fox_coat"

/obj/item/toy/plushie/fluff/fox
	name = "orange fox plushie"
	desc = "A cute, soft, fuzzy, fluffy, and cuddly plushie. This has a small tag on it that is signed 'Fox McCloud'."
	icon_state = "orangefox"
	attack_verb = list("poofed", "cuddled","fluffed")
	actions_types = list(/datum/action/item_action/adjust)
	var/prompting_change = FALSE
	var/list/plush_colors = list("red fox plushie" = "redfox", "black fox plushie" = "blackfox", "marble fox plushie" = "marblefox", "blue fox plushie" = "bluefox", "orange fox plushie" = "orangefox",
								 "coffee fox plushie" = "coffeefox", "pink fox plushie" = "pinkfox", "purple fox plushie" = "purplefox", "crimson fox plushie" = "crimsonfox")

/obj/item/toy/plushie/fluff/fox/proc/change_color()
	if(prompting_change)
		return
	prompting_change = TRUE
	var/plushie_color = input("Select a color", "[src]") as null|anything in plush_colors
	prompting_change = FALSE
	if(!plushie_color)
		return
	if(!Adjacent(usr))
		return
	name = plushie_color
	icon_state = plush_colors[plushie_color]

	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/toy/plushie/fluff/fox/ui_action_click()
	change_color()


// TheFlagbearer: Willow Walker
/obj/item/clothing/under/fluff/arachno_suit
	name = "Arachno-Man costume"
	desc = "It's what an evil genius would design if he switched brains with the Amazing Arachno-Man. Actually, he'd probably add weird tentacles that come out the back, too."
	icon = 'icons/obj/clothing/uniforms.dmi'
	icon_state = "superior_suit"
	item_state = "superior_suit"
	item_color = "superior_suit"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	flags_inv = HIDEGLOVES|HIDESHOES

/obj/item/clothing/head/fluff/arachno_mask
	name = "Arachno-Man mask"
	desc = "Put it on. The mask, it's gonna make you stronger!"
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "superior_mask"
	item_state = "superior_mask"
	body_parts_covered = HEAD
	flags = BLOCKHAIR
	flags_inv = HIDEFACE


/obj/item/clothing/shoes/fluff/arachno_boots
	name = "Arachno-Man boots"
	desc = "These boots were made for crawlin'"
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "superior_boots"
	item_state = "superior_boots"


/obj/item/nullrod/fluff/chronx //chronx100: Hughe O'Splash
	fluff_transformations = list(/obj/item/nullrod/fluff/chronx/scythe)

/obj/item/nullrod/fluff/chronx/scythe
	name = "Soul Collector"
	desc = "An ancient scythe used by the worshipers of Cthulhu. Tales say it is used to prepare souls for Cthulhu's great devouring. Someone carved their name into the handle: Hughe O'Splash"
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "chronx_scythe"
	item_state = "chronx_scythe"

/obj/item/clothing/head/fluff/chronx //chronx100: Hughe O'Splash
	name = "Cthulhu's Hood"
	desc = "Hood worn by the worshipers of Cthulhu. You see a name inscribed in blood on the inside: Hughe O'Splash"
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "chronx_hood"
	item_state = "chronx_hood"
	flags = BLOCKHAIR
	flags_cover = HEADCOVERSEYES
	actions_types = list(/datum/action/item_action/toggle)
	var/adjusted = 0

/obj/item/clothing/head/fluff/chronx/ui_action_click()
	adjust()

/obj/item/clothing/head/fluff/chronx/proc/adjust()
	if(adjusted)
		icon_state = initial(icon_state)
		item_state = initial(item_state)
		to_chat(usr, "You untransform \the [src].")
		adjusted = 0
	else
		icon_state += "_open"
		item_state += "_open"
		to_chat(usr, "You transform \the [src].")
		adjusted = 1
	usr.update_inv_head()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/suit/chaplain_hoodie/fluff/chronx //chronx100: Hughe O'Splash
	name = "Cthulhu's Robes"
	desc = "Robes worn by  the worshipers of Cthulhu. You see a name inscribed in blood on the inside: Hughe O'Splash"
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "chronx_robe"
	item_state = "chronx_robe"
	flags_size = ONESIZEFITSALL
	actions_types = list(/datum/action/item_action/toggle)
	adjust_flavour = "untransform"
	ignore_suitadjust = 0

/obj/item/clothing/shoes/black/fluff/chronx //chronx100: Hughe O'Splash
	name = "Cthulhu's Boots"
	desc = "Boots worn by the worshipers of Cthulhu. You see a name inscribed in blood on the inside: Hughe O'Splash"
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "chronx_shoes"
	item_state = "chronx_shoes"

/obj/item/clothing/suit/armor/vest/fluff/tactical //m3hillus: Medusa Schlofield
	name = "tactical armor vest"
	desc = "A tactical vest with armored plate inserts."
	icon = 'icons/obj/clothing/ties.dmi'
	icon_state = "vest_black"
	item_state = "vest_black"
	sprite_sheets = null

/obj/item/clothing/under/pants/fluff/combat
	name = "combat pants"
	desc = "Medium style tactical pants, for the fashion aware combat units out there."
	icon_state = "chaps"
	item_color = "combat_pants"

/obj/item/clothing/suit/jacket/fluff/elliot_windbreaker // DaveTheHeadcrab: Elliot Campbell
	name = "nylon windbreaker"
	desc = "A cheap nylon windbreaker, according to the tag it was manufactured in New Chiba, Earth.<br>The color reminds you of a television tuned to a dead channel."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "elliot_windbreaker_open"
	item_state = "elliot_windbreaker_open"
	adjust_flavour = "unzip"
	suit_adjusted = 1
	sprite_sheets = null

/obj/item/storage/backpack/fluff/syndiesatchel //SkeletalElite: Rawkkihiki
	name= "Military Satchel"
	desc = "A well made satchel for military operations. Totally not made by an enemy corporation"
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "rawk_satchel"
	sprite_sheets = null

/obj/item/storage/backpack/fluff/krich_back //lizardzsi: Krichahka
	name = "Voxcaster"
	desc = "Battered, Sol-made military radio backpack that had its speakers fried from playing Vox opera. The words 'Swift-Talon' are crudely scratched onto its side."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "voxcaster_fluff"

/obj/item/storage/backpack/fluff/ssscratches_back //Ssscratches: Lasshy-Bot
	name = "CatPack"
	desc = "It's a backpack, but it's also a cat."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "ssscratches_backpack"

/obj/item/storage/backpack/fluff/thebrew //Greey: Korala Ice
	name = "The Brew"
	desc = "Amber colored backpack resembling a long lost friend, a spirit long forgotten."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "greeyfluff"
	item_state = "greeyfluff"

/obj/item/clothing/head/wizard/fake/fluff/dreamy //phantasmicdream : Dreamy Rockwall
	name = "strange witch hat"
	desc = "A shapeshifting witch hat. A strange aura comes from it..."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "classic_witch"
	item_state = "classic_witch"

/obj/item/clothing/head/wizard/fake/fluff/dreamy/attack_self(mob/user)
	var/list/options = list()
	options["Classic"] = "classic_witch"
	options["Good"] = "good_witch"
	options["Dark"] = "dark_witch"
	options["Steampunk"] ="steampunk_witch"
	options["Healer"] = "healer_witch"
	options["Cute"] = "cutie_witch"
	options["Shy"] = "shy_witch"
	options["Sexy"] ="sexy_witch"
	options["Bunny"] = "bunny_witch"
	options["Potions"] = "potions_witch"
	options["Syndicate"] = "syndie_witch"
	options["Nanotrasen"] ="nt_witch"

	var/choice = input(user, "To what form do you wish to Shapeshift this hat?", "Shapeshift Hat") as null|anything in options

	if(choice && !user.stat && in_range(user, src))
		icon_state = options[choice]
		to_chat(user, "Your strange witch hat has now shapeshifted into it's [choice] form!")
		return 1
	..()

/obj/item/fluff/zekemirror //phantasmicdream : Zeke Varloss
	name = "engraved hand mirror"
	desc = "A very classy hand mirror, with fancy detailing."
	icon = 'icons/obj/custom_items.dmi'
	lefthand_file = 'icons/mob/inhands/fluff_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/fluff_righthand.dmi'
	icon_state = "hand_mirror"
	attack_verb = list("smacked")
	hitsound = 'sound/weapons/tap.ogg'
	force = 0
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL

/obj/item/fluff/zekemirror/attack_self(mob/user)
	var/mob/living/carbon/human/target = user
	if(!istype(target) || !isskrell(target)) // It'd be strange to see other races with head tendrils.
		return

	if(target.change_hair("Zekes Tentacles", 1))
		to_chat(target, "<span class='notice'>You take time to admire yourself in [src], brushing your tendrils down and revealing their true length.</span>")


/obj/item/clothing/accessory/necklace/locket/fluff/fethasnecklace //Fethas: Sefra'neem
	name = "Orange gemmed locket"
	desc = "A locket with a orange gem set on the front, the picture inside seems to be of a Tajaran."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "fethasnecklace"
	item_state = "fethasnecklace"
	item_color = "fethasnecklace"
	slot_flags = SLOT_MASK | SLOT_TIE

/obj/item/bedsheet/fluff/hugosheet //HugoLuman: Dan Martinez
	name = "Cosmic space blankie"
	desc = "Made from the dreams of space children everywhere."
	icon = 'icons/obj/custom_items.dmi'
	lefthand_file = 'icons/mob/inhands/fluff_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/fluff_righthand.dmi'
	icon_state = "sheetcosmos"
	item_state = "sheetcosmos"
	item_color = "sheetcosmos"


/obj/item/clothing/head/fluff/lfbowler //Lightfire: Hyperion
	name = "Classy bowler hat"
	desc = "a very classy looking bowler hat"
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "bowler_lightfire"

/obj/item/clothing/under/fluff/lfvicsuit //Lightfire: Hyperion
	name = "Classy victorian suit"
	desc = "A blue and black victorian suit with silver buttons, very fancy!"
	icon = 'icons/obj/custom_items.dmi'
	lefthand_file = 'icons/mob/inhands/fluff_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/fluff_righthand.dmi'
	icon_state = "victorianlightfire"
	item_state = "victorianvest"
	item_color = "victorianlightfire"
	displays_id = FALSE


/obj/item/fluff/decemviri_spacepod_kit //Decemviri: Sylus Cain
	name = "Spacepod mod kit"
	desc = "a kit on tools and a blueprint detailing how to reconfigure a spacepod"
	icon_state = "modkit"

/obj/item/fluff/decemviri_spacepod_kit/afterattack(atom/target, mob/user, proximity)
	if(!proximity || !ishuman(user) || user.incapacitated())
		return

	if(!istype(target, /obj/spacepod))
		to_chat(user, "<span class='warning'>You can't modify [target]!</span>")
		return

	to_chat(user, "<span class='notice'>You modify the appearance of [target] based on the kit blueprints.</span>")
	var/obj/spacepod/pod = target
	pod.icon = 'icons/48x48/custom_pod.dmi'
	pod.icon_state = "pod_dece"
	pod.name = "sleek spacepod"
	pod.desc = "A modified varient of a space pod."
	pod.can_paint = FALSE
	used = 1
	qdel(src)

/obj/item/bikehorn/fluff/pinkbikehorn //Xerdies: Squiddle Toodle
	name = "Honkinator5000"
	desc = "This horn may look ridiculous but is the new hot item for clowns in the Clown Empire. It has a fine print on its side reading: Property of Prince Honktertong the IV"
	icon = 'icons/obj/custom_items.dmi'
	lefthand_file = 'icons/mob/inhands/fluff_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/fluff_righthand.dmi'
	honk_sounds = list('sound/items/teri_horn.ogg' = 1)
	icon_state = "teri_horn"
	item_state = "teri_horn"

/obj/item/clothing/accessory/medal/fluff/elo	//V-Force_Bomber: E.L.O.
	name = "distinguished medal of loyalty and excellence"
	desc = "This medal is cut into the shape of a Victoria Cross, and is awarded to those who have proven themselves to Nanotrasen with a long and successful career."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "elo-medal"
	item_color = "elo-medal"

/obj/item/clothing/suit/fluff/vetcoat //Furasian: Fillmoore Grayson
	name = "Veteran Coat"
	desc = "An old, yet well-kept Nanotrasen uniform. Very few of its kind are still produced."
	icon = 'icons/obj/custom_items.dmi'
	lefthand_file = 'icons/mob/inhands/fluff_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/fluff_righthand.dmi'
	icon_state = "alchemistcoatblack"
	item_state = "alchemistcoatblack"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS

/obj/item/clothing/suit/fluff/vetcoat/red //Furasian: Fillmoore Grayson
	icon_state = "alchemistcoatred"
	item_state = "alchemistcoatred"

/obj/item/clothing/suit/fluff/vetcoat/navy //Furasian: Fillmoore Grayson
	icon_state = "alchemistcoatnavy"
	item_state = "alchemistcoatnavy"

/obj/item/clothing/accessory/medal/fluff/panzermedal //PanzerSkull: GRN-DER
	name = "Cross of Valor"
	desc = "A medal from the bygone Asteroid Wars. Its Ruby shines with a strange intensity."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "panzermedal"
	item_state = "panzermedal"
	item_color = "panzermedal"
	slot_flags = SLOT_TIE

/obj/item/clothing/accessory/medal/fluff/XannZxiax //Sagrotter: Xann Zxiax
	name = "Zxiax Garnet"
	desc = "Green Garnet on fancy blue cord, when you look at the Garnet, you feel strangely appeased."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "Xann_necklace"
	item_state = "Xann_necklace"
	item_color = "Xann_necklace"
	slot_flags = SLOT_TIE

/obj/item/clothing/accessory/rbscarf //Rb303: Isthel Eisenwald
    name = "Old purple scarf"
    desc = "An old, striped purple scarf. It appears to be hand-knitted and has the name 'Isthel' written on it in bad handwriting."
    icon = 'icons/obj/custom_items.dmi'
    icon_state = "rbscarf"
    item_state = "rbscarf"
    item_color = "rbscarf"

/obj/item/instrument/accordion/fluff/asmer_accordion //Asmerath: Coloratura
	name = "Rara's Somber Accordion"
	desc = "A blue colored accordion with claw indentations on the keys made special for vulpkanins."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "asmer_accordion"
	item_state = "asmer_accordion"


/obj/item/clothing/head/rabbitears/fluff/pinesalad_bunny // Pineapple Salad : Dan Jello
	name = "Bluespace rabbit ears"
	desc = "A pair of sparkly bluespace rabbit ears, with a small tag on them that reads, 'Dan Jello~'. Yuck, \
	 there's some pink slime on the part that goes on your head!"
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "ps_bunny"


/obj/item/clothing/under/fluff/kiaoutfit //FullOfSkittles: Kiachi
	name = "Suspicious Outfit"
	desc = "A very expensive top with intricate details tailored to fit a vox and paired with a glittery blue skirt, probably illegal."
	icon = 'icons/obj/custom_items.dmi'
	lefthand_file = 'icons/mob/inhands/fluff_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/fluff_righthand.dmi'
	sprite_sheets = list("Vox" = 'icons/mob/species/vox/uniform.dmi')
	icon_state = "kiaoutfit"
	item_state = "kiaoutfit"
	item_color = "kiaoutfit"
	displays_id = FALSE
	species_restricted = list("Vox")

/obj/item/clothing/head/fluff/kiahat //FullOfSkittles: Kiachi
	name = "Suspicious Witch Hat"
	desc = "A black witch hat with a blue sash decorated with tiny glimmering stars and a gold squid-like medallion, probably possessed."
	icon = 'icons/obj/custom_items.dmi'
	lefthand_file = 'icons/mob/inhands/fluff_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/fluff_righthand.dmi'
	icon_state = "kiahat"
	item_state = "kiahat"
	item_color = "kiahat"

/obj/item/clothing/mask/gas/fluff/kiamask //FullOfSkittles: Kiachi
	name = "Suspicious Mask"
	desc = "A sleek mask that blends in with the owner's existing quills using strange technology. It might even be magic..."
	icon = 'icons/obj/custom_items.dmi'
	lefthand_file = 'icons/mob/inhands/fluff_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/fluff_righthand.dmi'
	sprite_sheets = list("Vox" = 'icons/mob/species/vox/mask.dmi')
	icon_state = "kiamask"
	item_state = "kiamask"
	item_color = "kiamask"
	species_restricted = list("Vox")



/obj/item/clothing/gloves/ring/fluff
	name = "fluff ring"
	desc = "Someone forgot to set this fluff item's description, notify a coder!"
	icon = 'icons/obj/custom_items.dmi'
	fluff_material = TRUE

/obj/item/clothing/gloves/ring/fluff/update_icon()
	return

/obj/item/clothing/gloves/ring/fluff/attackby(obj/item/I as obj, mob/user as mob, params)
	return



/obj/item/clothing/gloves/ring/fluff/benjaminfallout	//Benjaminfallout: Pretzel Brassheart
	name = "Pretzel's Ring"
	desc = "A small platinum ring with a large light blue diamond. Engraved inside the band are the words: 'To my lovely Pristine Princess. Forever yours, Savinien.'"
	icon_state = "benjaminfallout_ring"

/obj/item/clothing/under/fluff/voxbodysuit //Gangelwaefre: Kikeri
	name = "Vox Bodysuit"
	desc = "A shimmering bodysuit custom-fit to a vox. Has shorts sewn in."
	lefthand_file = 'icons/mob/inhands/fluff_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/fluff_righthand.dmi'
	icon = 'icons/mob/inhands/fluff_righthand.dmi'
	icon_state = "voxbodysuit"
	item_state = "voxbodysuit"
	item_color = "voxbodysuit"
	body_parts_covered = HEAD|UPPER_TORSO|LOWER_TORSO|LEGS|ARMS

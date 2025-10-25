/datum/outfit/admin/debug
	name = "Debug outfit"

	uniform = /obj/item/clothing/under/costume/patriotsuit
	back = /obj/item/mod/control/pre_equipped/debug
	backpack_contents = list(
		/obj/item/melee/energy/axe = 1,
		/obj/item/storage/part_replacer/bluespace/tier4 = 1,
		/obj/item/gun/magic/wand/resurrection/debug = 1,
		/obj/item/gun/magic/wand/death/debug = 1,
		/obj/item/debug/human_spawner = 1
	)
	belt = /obj/item/storage/belt/military/abductor/full
	l_ear = /obj/item/radio/headset/centcom/debug
	glasses = /obj/item/clothing/glasses/hud/debug
	mask = /obj/item/clothing/mask/gas/welding/advanced
	shoes = /obj/item/clothing/shoes/combat/swat

	box = /obj/item/storage/box/debug/debugtools
	suit_store = /obj/item/tank/internals/oxygen
	gloves = /obj/item/clothing/gloves/combat
	id = /obj/item/card/id/admin
	pda = /obj/item/pda/centcom

	internals_slot = ITEM_SLOT_SUIT_STORE

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/arm/surgery/debug,
		/obj/item/organ/internal/cyberimp/chest/nutriment/hardened,
		/obj/item/organ/internal/cyberimp/arm/janitorial/debug
	)


/datum/outfit/admin/debug/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return
	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_all_accesses(), "Debugger", "admin")

	H.dna.SetSEState(GLOB.breathlessblock, 1)
	singlemutcheck(H, GLOB.breathlessblock, MUTCHK_FORCED)
	H.dna.default_blocks.Add(GLOB.breathlessblock)
	H.check_mutations = 1

/obj/item/radio/headset/centcom/debug
	name = "AVD-CNED bowman headset"
	ks2type = /obj/item/encryptionkey/syndicate/all_channels

/// has to be a subtype and stuff
/obj/item/encryptionkey/syndicate/all_channels
	name = "AVD-CNED Encryption Key"
	desc = "Lets you listen to <b>everything</b>. Use in hand to toggle voice changing. Alt-click to change your fake name."
	icon_state = "com_cypherkey"
	channels = list("Response Team" = 1, "Special Ops" = 1, "Science" = 1, "Command" = 1, "Medical" = 1, "Engineering" = 1, "Security" = 1, "Supply" = 1, "Service" = 1, "Procedure" = 1) // just in case
	change_voice = FALSE

/obj/item/encryptionkey/syndicate/all_channels/Initialize(mapload)
	. = ..()
	for(var/channel in SSradio.radiochannels)
		channels[channel] = 1 // yeah, all channels, sure, probably fine

/obj/item/encryptionkey/syndicate/all_channels/attack_self__legacy__attackchain(mob/user, pickupfireoverride)
	change_voice = !change_voice
	to_chat(user, "You switch [src] to [change_voice ? "" : "not "]change your voice on syndicate communications.")

/obj/item/encryptionkey/syndicate/all_channels/AltClick(mob/user)
	var/new_name = tgui_input_text(user, "Enter new fake agent name...", "New name", max_length = MAX_NAME_LEN)
	if(!new_name)
		return
	fake_name = new_name

/obj/item/clothing/mask/gas/welding/advanced
	name = "AVD-CNED welding mask"
	desc = "Retinal damage is no joke."
	tint = FLASH_PROTECTION_NONE
	flags_cover = MASKCOVERSEYES|MASKCOVERSMOUTH // vomit prevention when being surrounded by tons of dead bodies

/obj/item/gun/magic/wand/resurrection/debug
	desc = "Is it possible for something to be even more powerful than regular magic? This wand is."
	max_charges = 500
	variable_charges = FALSE
	can_charge = TRUE
	recharge_rate = 1

/obj/item/gun/magic/wand/death/debug
	desc = "In some obscure circles, this is known as the 'cloning tester's friend'."
	max_charges = 500
	variable_charges = FALSE
	can_charge = TRUE
	recharge_rate = 1

/obj/item/clothing/glasses/hud/debug
	name = "AVD-CNED glasses"
	desc = "Diagnostic, Hydroponic, Medical, and Security HUD. Built-in advanced reagent scanner. Protects the wearer from supermatter hallucinations and welding flashes."
	icon_state = "nvgmeson"
	hud_debug = TRUE
	flash_protect = FLASH_PROTECTION_WELDER
	scan_reagents_advanced = TRUE
	prescription_upgradable = FALSE
	hud_types = list(DATA_HUD_MEDICAL_ADVANCED, DATA_HUD_DIAGNOSTIC_ADVANCED, DATA_HUD_SECURITY_ADVANCED, DATA_HUD_HYDROPONIC)
	var/xray = FALSE

/obj/item/clothing/glasses/hud/debug/examine(mob/user)
	. = ..()
	. += "<span class = 'notice'><b>Alt-Click</b> to toggle X-ray vision.</span>"

/obj/item/clothing/glasses/hud/debug/equipped(mob/user, slot)
	..()
	if(slot == ITEM_SLOT_EYES)
		handle_traits(user, TRUE)
	else
		handle_traits(user)

/obj/item/clothing/glasses/hud/debug/dropped(mob/user)
	..()
	handle_traits(user)

/obj/item/clothing/glasses/hud/debug/AltClick(mob/living/carbon/human/user)
	to_chat(user, "<span class='notice'>You [xray ? "de" : ""]activate the x-ray setting on [src].</span>")
	xray = !xray
	if(istype(user) && user.glasses == src)
		handle_traits(user, TRUE)

/obj/item/clothing/glasses/hud/debug/proc/handle_traits(mob/user, worn = FALSE)
	if(!ishuman(user))
		return

	if(worn)
		if(!HAS_TRAIT_FROM(user, SM_HALLUCINATION_IMMUNE, "debug_glasses[UID()]"))
			ADD_TRAIT(user, SM_HALLUCINATION_IMMUNE, "debug_glasses[UID()]")
	else
		REMOVE_TRAIT(user, SM_HALLUCINATION_IMMUNE, "debug_glasses[UID()]")

	if(xray && worn)
		see_in_dark = 8
		lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
		if(!HAS_TRAIT_FROM(user, TRAIT_XRAY_VISION, "debug_glasses[UID()]"))
			ADD_TRAIT(user, TRAIT_XRAY_VISION, "debug_glasses[UID()]")
	else
		see_in_dark = initial(see_in_dark)
		lighting_alpha = initial(lighting_alpha)
		REMOVE_TRAIT(user, TRAIT_XRAY_VISION, "debug_glasses[UID()]")
	user.update_sight()

/obj/item/debug/human_spawner
	name = "human spawner"
	desc = "Spawn a human by aiming at a turf and clicking. Use in hand to change type."
	icon = 'icons/obj/guns/magic.dmi'
	icon_state = "nothingwand"
	w_class = WEIGHT_CLASS_SMALL
	var/datum/species/selected_species
	var/activate_mind = FALSE

/obj/item/debug/human_spawner/examine(mob/user)
	. = ..()
	. += "<span class='notice'><b>Alt-Click</b> to toggle mind-activation on spawning.</span>"

/obj/item/debug/human_spawner/afterattack__legacy__attackchain(atom/target, mob/user, proximity)
	..()
	if(!isturf(target))
		return
	var/mob/living/carbon/human/H = new /mob/living/carbon/human(target)
	if(selected_species)
		H.setup_dna(selected_species.type)
	if(activate_mind)
		H.mind_initialize()

/obj/item/debug/human_spawner/attack_self__legacy__attackchain(mob/user)
	..()
	var/choice = input("Select a species", "Human Spawner", null) in GLOB.all_species
	selected_species = GLOB.all_species[choice]

/obj/item/debug/human_spawner/AltClick(mob/user)
	if(!Adjacent(user))
		return
	activate_mind = !activate_mind
	to_chat(user, "<span class='notice'>Any humans spawned will [activate_mind ? "" : "not "]spawn with an initialized mind.</span>")

/obj/item/rcd/combat/admin
	name = "AVD-CNED RCD"
	max_matter = INFINITY
	matter = INFINITY
	locked = FALSE

/obj/item/stack/spacecash/debug
	amount = 50000
	max_amount = 50000

/obj/item/bodyanalyzer/debug
	name = "AVD-CNED handheld body analyzer"
	cell_type = /obj/item/stock_parts/cell/infinite
	scan_time = 1 SECONDS
	scan_cd = 0 SECONDS

/obj/item/scalpel/laser/manager/debug
	name = "AVD-CNED IMS"
	desc = "A wonder of modern medicine. This tool functions as any other sort of surgery tool, and finishes in only a fraction of the time. Hey, how'd you get your hands on this, anyway?"
	toolspeed = 0.01

/obj/item/scalpel/laser/manager/debug/activate_self(mob/user)
	if(..())
		return

	toolspeed = toolspeed == 0.5 ? 0.01 : 0.5
	to_chat(user, "[src] is now set to toolspeed [toolspeed]")
	playsound(src, 'sound/effects/pop.ogg', 50, 0)		//Change the mode

/obj/item/organ/internal/cyberimp/arm/surgery/debug
	name = "AVD-CNED surgical toolset implant"
	contents = newlist(
		/obj/item/scalpel/laser/manager/debug,
		/obj/item/hemostat/alien, // its needed specifically for some surgeries
		/obj/item/circular_saw/alien,
		/obj/item/healthanalyzer/advanced,
		/obj/item/gun/medbeam,
		/obj/item/handheld_defibrillator,
		/obj/item/bodyanalyzer/debug
	)

/obj/item/organ/internal/cyberimp/arm/janitorial/debug
	name = "AVD-CNED janitorial toolset implant... is that a... tazer?"
	desc = "A set of advanced janitorial tools hidden behind a concealed panel on the user's arm with a tazer? What the fuck."
	parent_organ = "l_arm" // left arm by default cuz im lazy
	slot = "l_arm_device"

	contents = newlist(
		/obj/item/mop/advanced/debug,
		/obj/item/soap/syndie/debug,
		/obj/item/lightreplacer/bluespace/debug,
		/obj/item/reagent_containers/spray/cleaner/advanced/debug,
		/obj/item/gun/energy/gun/advtaser/mounted // yeah why not
	)

/obj/item/mop/advanced/debug
	name = "AVD-CNED mop"
	desc = "I know you want to do it. Make shit slippery."
	mopcap = 100
	mopspeed = 1
	refill_rate = 50

/obj/item/soap/syndie/debug
	name = "super soap"
	desc = "The fastest soap in the space-west."
	cleanspeed = 1

/obj/item/lightreplacer/bluespace/debug
	name = "AVD-CNED light... thingy. You know what it is."
	max_uses = 20000
	uses = 20000

/obj/item/reagent_containers/spray/cleaner/advanced/debug
	name = "AVD-CNED advanced space cleaner"
	desc = "AVD-CNED!-brand non-foaming space cleaner! How fancy."
	volume = 50000
	spray_maxrange = 10
	spray_currentrange = 10
	spray_minrange = 5
	list_reagents = list("cleaner" = 50000)
	delay = 0.1 SECONDS // it costs 1000 reagents to fire this cleaner... for 12 seconds.


//
// Funny matryoshka doll boxes
//

/obj/item/storage/box/debug
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 1000
	storage_slots = 99
	allow_same_size = TRUE

/obj/item/storage/box/debug/debugtools
	name = "debug tools"

/obj/item/paper/debug_research
	name = "debug reseach notes"
	desc = "Your brain is melting just from looking at this endless knowledge."
	info = "<b>Information written here is beyond your understanding</b>"
	origin_tech = "materials=10;engineering=10;plasmatech=10;powerstorage=10;bluespace=10;biotech=10;combat=10;magnets=10;programming=10;toxins=10;syndicate=10;abductor=10"

/obj/item/storage/box/debug/debugtools/populate_contents()
	new /obj/item/card/emag(src)
	new /obj/item/rcd/combat/admin(src)
	new /obj/item/geiger_counter(src)
	new /obj/item/healthanalyzer/advanced(src)
	new /obj/item/rpd/bluespace(src)
	new /obj/item/stack/spacecash/debug(src)
	new /obj/item/storage/box/beakers/bluespace(src)
	new /obj/item/storage/box/debug/material(src)
	new /obj/item/storage/box/debug/misc_debug(src)
	new /obj/item/storage/box/centcomofficer(src)
	new /obj/item/radio/uplink/admin(src)
	new /obj/item/paper/debug_research(src)

/obj/item/storage/box/debug/material
	name = "box of materials"

/obj/item/storage/box/debug/material/populate_contents()
	new /obj/item/stack/sheet/metal/fifty(src)
	new /obj/item/stack/sheet/plasteel/fifty(src)
	new /obj/item/stack/sheet/plastic/fifty(src)
	new /obj/item/stack/tile/brass/fifty(src)
	new /obj/item/stack/sheet/runed_metal/fifty(src)
	new /obj/item/stack/sheet/glass/fifty(src)
	new /obj/item/stack/sheet/rglass/fifty(src)
	new /obj/item/stack/sheet/plasmaglass/fifty(src)
	new /obj/item/stack/sheet/plasmarglass/fifty(src)
	new /obj/item/stack/sheet/titaniumglass/fifty(src)
	new /obj/item/stack/sheet/plastitaniumglass/fifty(src)
	new /obj/item/stack/sheet/wood/fifty(src)
	new /obj/item/stack/sheet/bamboo/fifty(src)
	new /obj/item/stack/sheet/cloth/fifty(src)
	new /obj/item/stack/sheet/durathread/fifty(src)
	new /obj/item/stack/sheet/cardboard/fifty(src)
	new /obj/item/stack/sheet/mineral/sandstone/fifty(src)
	new /obj/item/stack/sheet/mineral/diamond/fifty(src)
	new /obj/item/stack/sheet/mineral/uranium/fifty(src)
	new /obj/item/stack/sheet/mineral/plasma/fifty(src)
	new /obj/item/stack/sheet/mineral/gold/fifty(src)
	new /obj/item/stack/sheet/mineral/silver/fifty(src)
	new /obj/item/stack/sheet/mineral/bananium/fifty(src)
	new /obj/item/stack/sheet/mineral/tranquillite/fifty(src)
	new /obj/item/stack/sheet/mineral/titanium/fifty(src)
	new /obj/item/stack/sheet/mineral/plastitanium/fifty(src)
	new /obj/item/stack/sheet/mineral/abductor/fifty(src)
	new /obj/item/stack/sheet/mineral/adamantine/fifty(src)

/obj/item/storage/box/debug/misc_debug
	name = "misc admin items"

// put cool admin-only shit here :)
/obj/item/storage/box/debug/misc_debug/populate_contents()
	new /obj/item/badmin_book(src)
	new /obj/item/reagent_containers/drinks/bottle/vodka/badminka(src)
	new /obj/item/crowbar/power(src) // >admin only lol
	new /obj/item/clothing/gloves/fingerless/rapid/admin(src)
	new /obj/item/clothing/under/misc/acj(src)
	new /obj/item/clothing/suit/advanced_protective_suit(src)
	new /obj/item/adminfu_scroll(src)
	new /obj/item/teleporter/admin(src)
	new /obj/item/storage/belt/bluespace/admin(src) // god i love storage nesting
	new /obj/item/mining_scanner/admin(src)
	new /obj/item/gun/energy/meteorgun/pen(src)


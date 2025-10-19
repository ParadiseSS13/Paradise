GLOBAL_LIST_INIT(uplink_items, subtypesof(/datum/uplink_item))
// This define is used when we have to spawn in an uplink item in a weird way, like a Surplus crate spawning an actual crate.
// Use this define by setting `uses_special_spawn` to TRUE on the item, and then checking if the parent proc of `spawn_item` returns this define. If it does, implement your special spawn after that.

/proc/get_uplink_items(obj/item/uplink/U, mob/user)
	var/list/uplink_items = list()
	var/list/sales_items = list()
	var/newreference = 1
	if(!length(uplink_items))
		for(var/path in GLOB.uplink_items)
			var/datum/uplink_item/I = new path
			if(!I.item)
				continue
			if(length(I.uplinktypes) && !(U.uplink_type in I.uplinktypes) && U.uplink_type != UPLINK_TYPE_ADMIN)
				continue
			if(length(I.excludefrom) && (U.uplink_type in I.excludefrom))
				continue
			//Add items to discount pool, checking job, species, and hijacker status
			if(I.job && !(user.mind.assigned_role in I.job)) //If your job does not match, no discount
				continue
			if(I.species && !(user.dna?.species.name in I.species)) //If your species does not match, no discount
				continue

			if(!uplink_items[I.category])
				uplink_items[I.category] = list()

			uplink_items[I.category] += I

			if(I.limited_stock < 0 && I.can_discount && I.item && I.cost > 5 && !I.hijack_only)
				sales_items += I

	if(isnull(user)) //Handles surplus
		return uplink_items

	for(var/i in 1 to 3)
		var/datum/uplink_item/sale_item = pick_n_take(sales_items)
		var/datum/uplink_item/A = new sale_item.type
		var/discount = 0.5
		A.limited_stock = 1
		sale_item.refundable = FALSE
		A.refundable = FALSE
		if(A.cost >= 100)
			discount *= 0.5 // If the item costs 100TC or more, it's only 25% off.
		A.cost = max(round(A.cost * (1 - discount)), 1)
		A.category = "Discounted Gear"
		A.name += " ([round(((initial(A.cost) - A.cost) / initial(A.cost)) * 100)]% off!)"
		A.reference = "DIS[newreference]"
		A.desc += " Limit of [A.limited_stock] per uplink. Normally costs [initial(A.cost)] TC."
		A.surplus = 0 //No freebies
		A.item = sale_item.item
		newreference++
		if(!uplink_items[A.category])
			uplink_items[A.category] = list()

		uplink_items[A.category] += A

	return uplink_items

// You can change the order of the list by putting datums before/after one another

/datum/uplink_item
	/// Name of the item in the uplink
	var/name = "item name"
	/// What category is the item listed under
	var/category = "item category"
	/// Description of the item in the uplink
	var/desc = "Item Description."
	/// Used for discounts. Any unique string will do.
	var/reference
	/// What is spawned when we purchase this?
	var/item
	/// How many TC does this cost?
	var/cost = 0
	/// Is what we're spawning abstract?
	var/abstract = 0
	/// Empty list means it is in all the uplink types. Otherwise place the uplink type here.
	var/list/uplinktypes = list()
	/// Empty list does nothing. Place the name of uplink type you don't want this item to be available in here.
	var/list/excludefrom = list()
	/// Is this job locked?
	var/list/job = null
	/// This makes an item on the uplink only show up to the specified species
	var/list/species = null
	/// Chance of being included in the surplus crate (when pick() selects it)
	var/surplus = 100
	/// Can this be sold at a discount?
	var/can_discount = TRUE
	/// Can you only buy so many? -1 allows for infinite purchases
	var/limited_stock = -1
	/// Can this item be purchased only during hijackings? Hijack-only items are by default unable to be on sale.
	var/hijack_only = FALSE
	/// Can you refund this in the uplink?
	var/refundable = FALSE
	/// Alternative path for refunds, in case the item purchased isn't what is actually refunded (ie: holoparasites).
	var/refund_path = null
	/// specified refund amount in case there needs to be a TC penalty for refunds.
	var/refund_amount
	/// Our special little snowflakes that have to be spawned in a different way than normal, like a surplus crate spawning a crate or contractor kits
	var/uses_special_spawn = FALSE

/datum/uplink_item/proc/spawn_item(turf/loc, obj/item/uplink/U)

	if(hijack_only && !(usr.mind.special_role == SPECIAL_ROLE_NUKEOPS))//nukies get items that regular traitors only get with hijack. If a hijack-only item is not for nukies, then exclude it via the gamemode list.
		if(!(locate(/datum/objective/hijack) in usr.mind.get_all_objectives()) && U.uplink_type != UPLINK_TYPE_ADMIN)
			to_chat(usr, "<span class='warning'>The Syndicate will only issue this extremely dangerous item to agents assigned the Hijack objective.</span>")
			return

	U.uses -= max(cost, 0)
	U.used_TC += cost
	SSblackbox.record_feedback("nested tally", "traitor_uplink_items_bought", 1, list("[initial(name)]", "[cost]"))
	if(item && !uses_special_spawn)
		return new item(loc)

	if(limited_stock)
		limited_stock -= 1 // In case we are handling discount items differently
	return UPLINK_SPECIAL_SPAWNING

/datum/uplink_item/proc/description()
	if(!desc)
		// Fallback description
		var/obj/temp = src.item
		desc = replacetext(initial(temp.desc), "\n", "<br>")
	return desc

/datum/uplink_item/proc/buy_uplink_item(obj/item/uplink/hidden/U, mob/user, put_in_hands = TRUE)
	if(!istype(U))
		return

	if(user.stat || user.restrained())
		return

	if(!ishuman(user))
		return

	// If the uplink's holder is in the user's contents
	if(((U.loc in user.contents) || (in_range(U.loc, user) && isturf(U.loc.loc))))
		if(cost > U.uses)
			return


		var/obj/I = spawn_item(get_turf(user), U, user)

		if(!I || I == UPLINK_SPECIAL_SPAWNING)
			return // Failed to spawn, or we handled it with special spawning
		if(limited_stock > 0)
			limited_stock--
			log_game("[key_name(user)] purchased [name]. [name] was discounted to [cost].")
			user.create_log(MISC_LOG, "Uplink purchase: [name] was discounted to [cost]tc")
			if(!user.mind.special_role)
				message_admins("[key_name_admin(user)] purchased [name] (discounted to [cost]), as a non antagonist.")

		else
			log_game("[key_name(user)] purchased [name].")
			user.create_log(MISC_LOG, "Uplink purchase: [name] for [cost]tc")
			if(!user.mind.special_role)
				message_admins("[key_name_admin(user)] purchased [name], as a non antagonist.")

		if(istype(I, /obj/item/storage/box) && length(I.contents))
			for(var/atom/o in I)
				U.purchase_log += "<big>[bicon(o)]</big>"

		else
			U.purchase_log += "<big>[bicon(I)]</big>"

		if(put_in_hands)
			user.put_in_any_hand_if_possible(I)
		return I

/*
//
//	UPLINK ITEMS
//
*/

//Discounts (dynamically filled above)
/datum/uplink_item/discounts
	category = "Discounted Gear"

////////////////////////////////////////
// MARK: DANGEROUS WEAPONS
////////////////////////////////////////

/datum/uplink_item/dangerous
	category = "Highly Visible and Dangerous Weapons"

/datum/uplink_item/dangerous/pistol
	name = "FK-69 Stechkin Pistol"
	reference = "SPI"
	desc = "A small, easily concealable handgun that uses 10mm auto rounds in 8-round magazines and is compatible with suppressors."
	item = /obj/item/gun/projectile/automatic/pistol
	cost = 20

/datum/uplink_item/dangerous/revolver
	name = "Syndicate .357 Revolver"
	reference = "SR"
	desc = "A brutally simple syndicate revolver that fires .357 Magnum cartridges and has 7 chambers. Comes with a spare speed loader."
	item = /obj/item/storage/box/syndie_kit/revolver
	cost = 65
	surplus = 50

/datum/uplink_item/dangerous/rapid
	name = "Gloves of the North Star"
	desc = "These gloves let the user help, shove, grab, and punch people very fast. Does not improve weapon attack speed. Can be combined with martial arts for a deadly weapon."
	reference = "RPGD"
	item = /obj/item/clothing/gloves/fingerless/rapid
	cost = 40

/datum/uplink_item/dangerous/sword
	name = "Energy Sword"
	desc = "The energy sword is an edged weapon with a blade of pure energy. The sword is small enough to be pocketed when inactive. Activating it produces a loud, distinctive noise."
	reference = "ES"
	item = /obj/item/melee/energy/sword/saber
	cost = 40

/datum/uplink_item/dangerous/dsword
	name = "Double Energy Sword"
	desc = "A double-bladed energy sword. More damaging than a standard energy sword, and automatically parries incoming energy weapons fire. Bulk discount applied."
	reference = "DSRD"
	item = /obj/item/dualsaber
	cost = 60

/datum/uplink_item/dangerous/snakefang
	name = "Snakesfang"
	desc = "The Snakesfang is a fork-tipped scimitar with a sharp edge and sharper bite. This sword cannot fit in your bag, but it does come with a scabbard you can attach to your belt."
	reference = "SF"
	item = /obj/item/storage/belt/sheath/snakesfang
	cost = 25

/datum/uplink_item/dangerous/powerfist
	name = "Power Fist"
	desc = "The Power Fist is a metal gauntlet with a built-in piston-ram powered by an external gas supply. \
		Upon hitting a target, the piston-ram will extend forward to make contact for some serious damage. \
		Using a wrench on the piston valve will allow you to tweak the amount of gas used per punch to \
		deal extra damage and hit targets further. Use a screwdriver to take out any attached tanks."
	reference = "PF"
	item = /obj/item/melee/powerfist
	cost = 50

/datum/uplink_item/dangerous/chainsaw
	name = "Chainsaw"
	desc = "A high powered chainsaw for cutting up ...you know...."
	reference = "CH"
	item = /obj/item/chainsaw/syndie
	cost = 65
	surplus = 0 // This has caused major problems with un-needed chainsaw massacres. Bwoink bait.
	excludefrom = list(UPLINK_TYPE_NUCLEAR)
	can_discount = FALSE // Too gamer.

/datum/uplink_item/dangerous/universal_gun_kit
	name = "Universal Self Assembling Gun Kit"
	desc = "A universal gun kit, that can be combined with any weapon kit to make a functioning RND gun of your own. Uses built-in hex keys to self assemble, just combine the kits by hitting them together."
	reference = "IKEA"
	item = /obj/item/weaponcrafting/gunkit/universal_gun_kit
	cost = 20

/datum/uplink_item/dangerous/batterer
	name = "Mind Batterer"
	desc = "A dangerous Syndicate device focused on crowd control and escapes. Causes brain damage, confusion, and other nasty effects to those surrounding the user. Has 5 charges."
	reference = "BTR"
	item = /obj/item/batterer
	cost = 25

/datum/uplink_item/dangerous/porta_turret
	name = "Portable Turret"
	desc = "A pop-up Syndicate turret that will shoot anyone who didn't prime the grenade. The turret cannot be moved after it's deployed."
	reference = "MIS"
	item = /obj/item/grenade/turret
	cost = 20

////////////////////////////////////////
// MARK: AMMUNITION
////////////////////////////////////////

/datum/uplink_item/ammo
	category = "Ammunition"
	surplus = 0 // Getting these in a discount or surplus is not a good time.
	can_discount = FALSE

/datum/uplink_item/ammo/pistol
	name = "Stechkin - 10mm Magazine"
	desc = "An additional 8-round 10mm magazine for use in the syndicate pistol, loaded with rounds that are cheap but around half as effective as .357"
	reference = "10MM"
	item = /obj/item/ammo_box/magazine/m10mm
	cost = 3

/datum/uplink_item/ammo/pistolap
	name = "Stechkin - 10mm Armour Piercing Magazine"
	desc = "An additional 8-round 10mm magazine for use in the syndicate pistol, loaded with rounds that are less effective at injuring the target but penetrate protective gear."
	reference = "10MMAP"
	item = /obj/item/ammo_box/magazine/m10mm/ap
	cost = 6

/datum/uplink_item/ammo/pistolfire
	name = "Stechkin - 10mm Incendiary Magazine"
	desc = "An additional 8-round 10mm magazine for use in the syndicate pistol, loaded with incendiary rounds which ignite the target."
	reference = "10MMFIRE"
	item = /obj/item/ammo_box/magazine/m10mm/fire
	cost = 9

/datum/uplink_item/ammo/pistolhp
	name = "Stechkin - 10mm Hollow Point Magazine"
	desc = "An additional 8-round 10mm magazine for use in the syndicate pistol, loaded with rounds which are more damaging but ineffective against armor."
	reference = "10MMHP"
	item = /obj/item/ammo_box/magazine/m10mm/hp
	cost = 7

/datum/uplink_item/ammo/revolver
	name = ".357 Revolver - Speedloader"
	desc = "A speed loader that contains seven additional .357 Magnum rounds for the syndicate revolver. For when you really need a lot of things dead."
	reference = "357"
	item = /obj/item/ammo_box/a357
	cost = 15

////////////////////////////////////////
// MARK: STEALTHY WEAPONS
////////////////////////////////////////

/datum/uplink_item/stealthy_weapons
	category = "Stealthy and Inconspicuous Weapons"

/datum/uplink_item/stealthy_weapons/garrote
	name = "Fiber Wire Garrote"
	desc = "A length of fiber wire between two wooden handles, perfect for the discrete assassin. This weapon, when used on a target from behind \
			will instantly put them in your grasp and silence them, as well as causing rapid suffocation. Does not work on those who do not need to breathe."
	item = /obj/item/garrote
	reference = "GAR"
	cost = 30

/datum/uplink_item/stealthy_weapons/cameraflash
	name = "Camera Flash"
	desc = "A flash disguised as a camera with a self-charging safety system preventing the flash from burning out. \
			Due to its design, this flash cannot be overcharged like regular flashes can. \
			Useful for stunning borgs and individuals without eye protection or blinding a crowd for a get away."
	reference = "CF"
	item = /obj/item/flash/cameraflash
	cost = 5

/datum/uplink_item/stealthy_weapons/throwingweapons
	name = "Box of Throwing Weapons"
	desc = "A box of shurikens and reinforced bolas from ancient Earth martial arts. They are highly effective \
			throwing weapons. The bolas can knock a target down and the shurikens will embed into limbs."
	reference = "STK"
	item = /obj/item/storage/box/syndie_kit/throwing_weapons
	cost = 15

/datum/uplink_item/stealthy_weapons/edagger
	name = "Energy Dagger"
	desc = "A dagger made of energy that looks and functions as a pen when off."
	reference = "EDP"
	item = /obj/item/pen/edagger
	cost = 10

/datum/uplink_item/stealthy_weapons/foampistol
	name = "Toy Gun (with Stun Darts)"
	desc = "An innocent looking toy pistol designed to fire foam darts. Comes loaded with riot grade darts, to incapacitate a target."
	reference = "FSPI"
	item = /obj/item/gun/projectile/automatic/toy/pistol/riot
	cost = 15
	surplus = 10

/datum/uplink_item/stealthy_weapons/false_briefcase
	name = "False Bottomed Briefcase"
	desc = "A modified briefcase capable of storing and firing a gun under a false bottom. Use a screwdriver to pry away the false bottom and make modifications. Distinguishable upon close examination due to the added weight."
	reference = "FBBC"
	item = /obj/item/storage/briefcase/false_bottomed
	cost = 10

/datum/uplink_item/stealthy_weapons/soap
	name = "Syndicate Soap"
	desc = "A sinister-looking surfactant used to clean blood stains to hide murders and prevent DNA analysis. You can also drop it underfoot to slip people."
	reference = "SOAP"
	item = /obj/item/soap/syndie
	cost = 5
	surplus = 50

/datum/uplink_item/stealthy_weapons/rsg
	name = "Rapid Syringe Gun"
	desc = "A Syndicate rapid syringe gun able to fill and fire syringes automatically from an internal reagent reservoir. Comes pre-loaded with 7 empty syringes, and has a maximum capacity of 14 syringes and 300u of reagents."
	reference = "RSG"
	item = /obj/item/gun/syringe/rapidsyringe/preloaded/half
	cost = 60

/datum/uplink_item/stealthy_weapons/poisonbottle
	name = "Poison Bottle"
	desc = "The Syndicate will ship a bottle containing 40 units of a randomly selected poison. The poison can range from highly irritating to incredibly lethal."
	reference = "TPB"
	item = /obj/item/reagent_containers/glass/bottle/traitor
	cost = 10
	surplus = 0 // Requires another item to function.

/datum/uplink_item/stealthy_weapons/silencer
	name = "Universal Suppressor"
	desc = "Fitted for use on any small caliber weapon with a threaded barrel, this suppressor will silence the shots of the weapon for increased stealth and superior ambushing capability."
	reference = "US"
	item = /obj/item/suppressor
	cost = 5
	surplus = 10

/datum/uplink_item/stealthy_weapons/dehy_carp
	name = "Dehydrated Space Carp"
	desc = "Just add water to make your very own hostile to everything space carp. It looks just like a plushie. The first person to squeeze it will be registered as its owner, who it will not attack. If no owner is registered, it'll just attack everyone."
	reference = "DSC"
	item = /obj/item/toy/plushie/carpplushie/dehy_carp
	cost = 4

/datum/uplink_item/stealthy_weapons/knuckleduster
	name = "Syndicate Knuckleduster"
	desc = "A straightforward and fairly concealable melee weapon for bludgeoning someone to death in brutal fashion. This one is designed specifically to cause severe organ damage to the victim."
	reference = "SKD"
	item = /obj/item/melee/knuckleduster/syndie
	cost = 10

////////////////////////////////////////
// MARK: GRENADES AND EXPLOSIVES
////////////////////////////////////////

/datum/uplink_item/explosives
	category = "Grenades and Explosives"

/datum/uplink_item/explosives/plastic_explosives
	name = "Composition C-4"
	desc = "C-4 is plastic explosive of the common variety Composition C. Reliably destroys the object it's placed on, assuming it isn't bomb resistant. Remarkably good for disposing bodies, or tired crewmates. Will only destroy station floors if placed directly on it. It has a modifiable timer with a minimum setting of 10 seconds."
	reference = "C4"
	item = /obj/item/grenade/plastic/c4
	cost = 5

/datum/uplink_item/explosives/plastic_explosives_pack
	name = "Pack of 5 C-4 Explosives"
	desc = "A package containing 5 C-4 Explosives at a discounted price. For when you need that little bit extra for your sabotaging needs."
	reference = "C4P"
	item = /obj/item/storage/box/syndie_kit/c4
	cost = 20

/datum/uplink_item/explosives/syndicate_minibomb
	name = "Syndicate Minibomb"
	desc = "The minibomb is a grenade with a five-second fuse."
	reference = "SMB"
	item = /obj/item/grenade/syndieminibomb
	cost = 30

/datum/uplink_item/explosives/frag_grenade
	name = "Fragmentation Grenade"
	desc = "A frag grenade. Upon detonation, releases shrapnel that can embed in nearby victims."
	reference = "FG"
	item = /obj/item/grenade/frag
	cost = 10

/datum/uplink_item/explosives/frag_grenade_pack
	name = "Pack of 5 Fragmentation Grenades"
	desc = "A box of 5 frag grenades. Upon detonation, releases shrapnel that can embed in nearby victims. And it seems you'll have a LOT of victims."
	reference = "FGP"
	item = /obj/item/storage/box/syndie_kit/frag_grenades
	cost = 40

/datum/uplink_item/explosives/pizza_bomb
	name = "Pizza Bomb"
	desc = "A pizza box with a bomb taped inside of it. The timer needs to be set by opening the box; afterwards, opening the box again will trigger the detonation."
	reference = "PB"
	item = /obj/item/pizzabox/pizza_bomb
	cost = 30
	surplus = 80

/datum/uplink_item/explosives/atmosn2ogrenades
	name = "Knockout Gas Grenades"
	desc = "A box of two (2) grenades that spread knockout gas over a large area. Equip internals before using one of these."
	reference = "ANG"
	item = /obj/item/storage/box/syndie_kit/atmosn2ogrenades
	cost = 40

/datum/uplink_item/explosives/emp
	name = "EMP Grenades and bio-chip implanter Kit"
	desc = "A box that contains two EMP grenades and an EMP implant with 2 uses. Useful to disrupt communication, \
			security's energy weapons, and silicon lifeforms when you're in a tight spot."
	reference = "EMPK"
	item = /obj/item/storage/box/syndie_kit/emp
	cost = 10

/datum/uplink_item/explosives/emp/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		cost *= 3

/datum/uplink_item/explosives/targrenade
	name = "Sticky Tar Grenade"
	desc = "A grenade filled with aerosols and sticky tar. \
			Will release a plume of smoke that applies tar to a wide area, severely slowing down movement. Makes for the ultimate getaway!"
	reference = "TARG"
	item = /obj/item/grenade/chem_grenade/tar
	cost = 7

////////////////////////////////////////
// MARK: STEALTHY TOOLS
////////////////////////////////////////

/datum/uplink_item/stealthy_tools
	category = "Stealth and Camouflage Items"

/datum/uplink_item/stealthy_tools/forgers_kit
	name = "Forger's Kit"
	desc = "A set consisting of a stamp and a special pen. The stamp can be activated to imitate an official Nanotrasen Stamp, \
		allowing you to forge false documents for access or equipment, and can also be used in a washing machine to create counterfeit clothing. \
			The included pen lets you create fake signatures, further enhancing your forgery capabilities."
	reference = "FGK"
	item = /obj/item/storage/box/syndie_kit/forgers_kit
	cost = 10
	surplus = 35

/datum/uplink_item/stealthy_tools/chameleonflag
	name = "Chameleon Flag"
	desc = "A flag that can be disguised as any other known flag. There is a hidden spot in the pole to booby trap the flag with a grenade or minibomb, which will detonate some time after the flag is set on fire."
	reference = "CHFLAG"
	item = /obj/item/flag/chameleon
	cost = 1
	surplus = 35

/datum/uplink_item/stealthy_tools/chamsechud
	name = "Chameleon Security HUD"
	desc = "A stolen Nanotrasen Security HUD with Syndicate chameleon technology implemented into it. Similarly to a chameleon jumpsuit, the HUD can be morphed into various other eyewear, while retaining the HUD qualities when worn."
	reference = "CHHUD"
	item = /obj/item/clothing/glasses/hud/security/chameleon
	cost = 10

/datum/uplink_item/stealthy_tools/thermal
	name = "Thermal Chameleon Glasses"
	desc = "These glasses are thermals with Syndicate chameleon technology built into them. They allow you to see organisms through walls by capturing the upper portion of the infra-red light spectrum, emitted as heat and light by objects. Hotter objects, such as warm bodies, cybernetic organisms and artificial intelligence cores emit more of this light than cooler objects like walls and airlocks."
	reference = "THIG"
	item = /obj/item/clothing/glasses/chameleon/thermal
	cost = 15

/datum/uplink_item/stealthy_tools/night
	name = "Nightvision Chameleon Glasses"
	desc = "These glasses are nightvision with Syndicate chameleon technology built into them. Lets you see clearer in the dark."
	reference = "TNIG"
	item = /obj/item/clothing/glasses/chameleon/night
	cost = 5

/datum/uplink_item/stealthy_tools/agent_card
	name = "Agent ID Card"
	desc = "Agent cards prevent artificial intelligences from tracking the wearer, and can copy access from other identification cards. The access is cumulative, so scanning one card does not erase the access gained from another."
	reference = "AIDC"
	item = /obj/item/card/id/syndicate
	cost = 10

/datum/uplink_item/stealthy_tools/chameleon_proj
	name = "Chameleon-Projector"
	desc = "Projects an image across a user, disguising them as an object scanned with it, as long as they don't move the projector from their hand. The disguised user cannot run and projectiles pass over them."
	reference = "CP"
	item = /obj/item/chameleon
	cost = 25

/datum/uplink_item/stealthy_tools/chameleon_counter
	name = "Chameleon Counterfeiter"
	desc = "This device disguises itself as any object scanned by it. The disguise is not a perfect replica and can be noticed when examined by an observer."
	reference = "CC"
	item = /obj/item/chameleon_counterfeiter
	cost = 10

/datum/uplink_item/stealthy_tools/camera_bug
	name = "Camera Bug"
	desc = "Enables you to view all cameras on the network to track a target. Also has 5 sticky hidden cameras, allowing you remote view of any object you can stick a camera on."
	reference = "CB"
	item = /obj/item/storage/box/syndie_kit/camera_bug
	cost = 5
	surplus = 90

/datum/uplink_item/stealthy_tools/dnascrambler
	name = "DNA Scrambler"
	desc = "A syringe with one injection that randomizes appearance and name upon use. A cheaper but less versatile alternative to an agent card and voice changer."
	reference = "DNAS"
	item = /obj/item/dnascrambler
	cost = 7

/datum/uplink_item/stealthy_tools/smugglersatchel
	name = "Smuggler's Satchel"
	desc = "This satchel is thin enough to be hidden in the gap between plating and tiling, great for stashing your stolen goods. Comes with a crowbar and a floor tile inside."
	reference = "SMSA"
	item = /obj/item/storage/backpack/satchel_flat
	cost = 10
	surplus = 30

/datum/uplink_item/stealthy_tools/emplight
	name = "EMP Flashlight"
	desc = "A small, self-charging, short-ranged EMP device disguised as a flashlight. \
		Useful for disrupting headsets, cameras, and borgs during stealth operations."
	reference = "EMPL"
	item = /obj/item/flashlight/emp
	cost = 20
	surplus = 30

/datum/uplink_item/stealthy_tools/emplight/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		cost *= 2.5

/datum/uplink_item/stealthy_tools/cutouts
	name = "Adaptive Cardboard Cutouts"
	desc = "These cardboard cutouts are coated with a thin material that prevents discoloration and makes the images on them appear more lifelike. This pack contains three as well as a \
	spraycan for changing their appearances."
	reference = "ADCC"
	item = /obj/item/storage/box/syndie_kit/cutouts
	cost = 1
	surplus = 20

/datum/uplink_item/stealthy_tools/safecracking
	name = "Safe-cracking Kit"
	desc = "Everything you need to quietly open a mechanical combination safe."
	reference = "SCK"
	item = /obj/item/storage/box/syndie_kit/safecracking
	cost = 5
	surplus = 0 // Far too objective specific.

/datum/uplink_item/stealthy_tools/handheld_mirror
	name = "Hand Held Mirror"
	desc = "A pocket sized mirror. Allows you to change all your hair and facial features, from color to style, instantly while in your hand."
	reference = "HM"
	item = /obj/item/handheld_mirror
	cost = 5

////////////////////////////////////////
// MARK: DEVICES AND TOOLS
////////////////////////////////////////

/datum/uplink_item/device_tools
	category = "Devices and Tools"
	abstract = 1

/datum/uplink_item/device_tools/emag
	name = "Cryptographic Sequencer"
	desc = "The cryptographic sequencer, also known as an emag, is a small card that unlocks hidden functions in electronic devices, subverts intended functions and characteristically breaks security mechanisms."
	reference = "EMAG"
	item = /obj/item/card/emag
	cost = 30

/datum/uplink_item/device_tools/access_tuner
	name = "Access Tuner"
	desc = "The access tuner is a small device that can interface with airlocks from range. It takes a few seconds to connect and can change the bolt state, open the door, or toggle emergency access."
	reference = "HACK"
	item = /obj/item/door_remote/omni/access_tuner
	cost = 30

/datum/uplink_item/device_tools/toolbox
	name = "Fully Loaded Toolbox"
	desc = "The syndicate toolbox is a suspicious black and red. Aside from tools, it comes with insulated gloves and a multitool."
	reference = "FLTB"
	item = /obj/item/storage/toolbox/syndicate
	cost = 5

/datum/uplink_item/device_tools/surgerybag
	name = "Syndicate Surgery Duffel Bag"
	desc = "The Syndicate surgery duffel bag comes with a full set of surgery tools, a straightjacket and a muzzle. The bag itself is also made of very light materials and won't slow you down while it is equipped."
	reference = "SSDB"
	item = /obj/item/storage/backpack/duffel/syndie/med/surgery
	cost = 10

/datum/uplink_item/device_tools/bonerepair
	name = "Prototype Nanite Autoinjector"
	desc = "Stolen prototype full body repair nanites. On injection it will shut down body systems as it revitilizes limbs and organs. Heals organics organs, cybernetic organs, and limbs to fully operational conditions."
	reference = "NCAI"
	item = /obj/item/reagent_containers/hypospray/autoinjector/nanocalcium
	cost = 10

/datum/uplink_item/device_tools/syndicate_teleporter
	name = "Experimental Syndicate Teleporter"
	desc = "The Syndicate teleporter is a handheld device that teleports the user 4-8 meters forward. \
			Beware, teleporting into a wall will make the teleporter do a parallel emergency teleport, \
			but if that emergency teleport fails, it will kill you. \
			Has 4 charges, recharges, warranty voided if exposed to EMP. \
			Comes with free chameleon mesons, to help you stay stylish while seeing through walls."
	reference = "TELE"
	item = /obj/item/storage/box/syndie_kit/teleporter
	cost = 40

/datum/uplink_item/device_tools/organ_extractor
	name = "Organ Extractor"
	desc = "A device that can remove organs or cybernetic implants from a target, and stores them inside. \
	Stored organs can be implanted into the user, or into other targets. Synthesizes chemicals to keep the organs fresh."
	reference = "OREX"
	item = /obj/item/organ_extractor
	cost = 20

/datum/uplink_item/device_tools/c_foam_launcher
	name = "C-Foam Launcher"
	desc = "A gun that shoots blobs of foam. Will block airlocks, and slow down humanoids. Not rated for xenomorph usage."
	reference = "CFOAM"
	item = /obj/item/gun/projectile/c_foam_launcher
	cost = 25

/datum/uplink_item/device_tools/tar_spray
	name = "Sticky Tar Applicator"
	desc = "A spray bottle containing an extremely viscous fluid that will leave behind tar whenever it is sprayed, greatly slowing down anyone who tries to walk over it. \
	Comes with 10 uses worth of fluid and cannot be refilled."
	reference = "TAR"
	item = /obj/item/reagent_containers/spray/sticky_tar
	cost = 10

/datum/uplink_item/device_tools/binary
	name = "Binary Translator Key"
	desc = "A key, that when inserted into a radio headset, allows you to listen to and talk with artificial intelligences and cybernetic organisms in binary. To talk on the binary channel, type :+ before your radio message."
	reference = "BITK"
	item = /obj/item/encryptionkey/binary
	cost = 25
	surplus = 75

/datum/uplink_item/device_tools/cipherkey
	name = "Syndicate Encryption Key"
	desc = "A key, that when inserted into a radio headset, allows you to listen to all station department channels as well as talk on an encrypted Syndicate channel."
	reference = "SEK"
	item = /obj/item/encryptionkey/syndicate
	cost = 10 //Nowhere near as useful as the Binary Key!
	surplus = 75

/datum/uplink_item/device_tools/hacked_module
	name = "Hacked AI Upload Module"
	desc = "When used with an upload console, this module allows you to upload priority laws to an artificial intelligence. Be careful with their wording, as artificial intelligences may look for loopholes to exploit."
	reference = "HAI"
	item = /obj/item/ai_module/syndicate
	cost = 15

/datum/uplink_item/device_tools/powersink
	name = "Power Sink"
	desc = "When screwed to wiring attached to an electric grid, then activated, this large device places excessive load on the grid, causing a stationwide blackout. The sink cannot be carried because of its excessive size. Ordering this sends you a small beacon that will teleport the power sink to your location on activation."
	reference = "PS"
	item = /obj/item/beacon/syndicate/power_sink
	cost = 50

/datum/uplink_item/device_tools/singularity_beacon
	name = "Power Beacon"
	desc = "When screwed to wiring attached to an electric grid and activated, this large device pulls any \
			active gravitational singularities. This will not work when the engine is still \
			in containment. Because of its size, it cannot be carried. Ordering this \
			sends you a small beacon that will teleport the larger beacon to your location upon activation."
	reference = "SNGB"
	item = /obj/item/beacon/syndicate
	cost = 10
	surplus = 0
	hijack_only = TRUE //This is an item only useful for a hijack traitor, as such, it should only be available in those scenarios.

/datum/uplink_item/device_tools/advpinpointer
	name = "Advanced Pinpointer"
	desc = "A pinpointer that tracks any specified coordinates, DNA string, high value item or the nuclear authentication disk."
	reference = "ADVP"
	item = /obj/item/pinpointer/advpinpointer
	cost = 10
	can_discount = FALSE

/datum/uplink_item/device_tools/ai_detector
	name = "Artificial Intelligence Detector" // changed name in case newfriends thought it detected disguised ai's
	desc = "A functional multitool that turns red when it detects an artificial intelligence watching it or its holder. Knowing when an artificial intelligence is watching you is useful for knowing when to maintain cover."
	reference = "AID"
	item = /obj/item/multitool/ai_detect
	cost = 5

/datum/uplink_item/device_tools/jammer
	name = "Radio Jammer"
	desc = "When turned on this device will scramble any outgoing radio communications near you, making them hard to understand."
	reference = "RJ"
	item = /obj/item/jammer
	cost = 20

/datum/uplink_item/device_tools/decoy_nade
	name = "Decoy Grenade Kit"
	desc = "A box of five grenades that can be configured to reproduce many suspicious sounds at varying rates."
	reference = "DCY"
	item = /obj/item/storage/box/syndie_kit/decoy
	cost = 20

////////////////////////////////////////
// MARK: SPACE SUITS AND HARDSUITS
////////////////////////////////////////

/datum/uplink_item/suits
	category = "Space Suits and MODsuits"
	surplus = 10 //I am setting this to 10 as there are a bunch of modsuit parts in here that should be weighted to 10. Suits and modsuits adjusted below.

/datum/uplink_item/suits/space_suit
	name = "Syndicate Space Suit"
	desc = "This armoured red and black Syndicate space suit is less encumbering than Nanotrasen variants, \
			fits inside bags, and has a weapon slot. Comes packaged with internals. Nanotrasen crewmembers are trained to report red space suit \
			sightings, however. "
	reference = "SS"
	item = /obj/item/storage/box/syndie_kit/space
	cost = 20

/datum/uplink_item/suits/thermal
	name = "MODsuit Thermal Visor Module"
	desc = "A visor for a MODsuit. Lets you see living beings through walls. Also provides night vision."
	reference = "MSTV"
	item = /obj/item/mod/module/visor/thermal
	cost = 15 // Don't forget, you need to get a modsuit to go with this

/datum/uplink_item/suits/night
	name = "MODsuit Night Visor Module"
	desc = "A visor for a MODsuit. Lets you see clearer in the dark."
	reference = "MSNV"
	item = /obj/item/mod/module/visor/night
	cost = 5 // It's night vision, rnd pumps out those goggles for anyone man.

/datum/uplink_item/suits/plate_compression
	name = "MODsuit Plate Compression Module"
	desc = "A MODsuit module that lets the suit compress into a smaller size. Not compatible with storage modules, \
	you will have to take that module out first."
	reference = "MSPC"
	item = /obj/item/mod/module/plate_compression
	cost = 10

/datum/uplink_item/suits/chameleon_module
	name = "MODsuit Chameleon Module"
	desc = "A module using chameleon technology to disguise an undeployed MODsuit as another object. Note: the disguise will not work once the MODsuit is deployed, but can be toggled again when retracted."
	reference = "MSCM"
	item = /obj/item/mod/module/chameleon
	cost = 10

/datum/uplink_item/suits/noslip
	name = "MODsuit Anti-Slip Module"
	desc = "A MODsuit module preventing the user from slipping on water. Already installed in the uplink MODsuits."
	reference = "MSNS"
	item = /obj/item/mod/module/noslip
	cost = 5

/datum/uplink_item/suits/springlock_module
	name = "Heavily Modified Springlock MODsuit Module"
	desc = "A module that spans the entire size of the MOD unit, sitting under the outer shell. \
		This mechanical exoskeleton pushes out of the way when the user enters and it helps in booting \
		up. While springlocks in older models were prone to \"snapping\" due to environmental humidity, \
		this version reacts solely to specific chemical triggers, such as smoke from grenades. \
		You know what it's like to have an entire exoskeleton enter you? \
		This version of the module has been modified to allow for near instant activation of the MODsuit. \
		Useful for quickly getting your MODsuit on/off, or for taking care of a target via a tragic accident. \
		It is hidden as a DNA lock module. It will block retraction for 10 seconds by default to allow you to follow \
		up with smoke, but you can multitool the module to disable that."
	reference = "FNAF"
	item = /obj/item/mod/module/springlock/bite_of_87
	cost = 5

/datum/uplink_item/suits/hidden_holster
	name = "Hidden Holster Module"
	desc = "A holster module disguised to look like a tether module. Requires a MODsuit to put it in of course. Gun not included."
	reference = "HHM"
	item = /obj/item/mod/module/holster/hidden
	cost = 5

/datum/uplink_item/suits/smoke_grenade
	name = "Smoke Grenade Module"
	desc = "A module that dispenses primed smoke grenades to disperse crowds."
	reference = "SGM"
	item = /obj/item/mod/module/dispenser/smoke
	cost = 10

////////////////////////////////////////
// MARK: IMPLANTS
////////////////////////////////////////

/datum/uplink_item/bio_chips
	category = "Bio-chips"

/datum/uplink_item/bio_chips/freedom
	name = "Freedom Bio-chip"
	desc = "A bio-chip injected into the body and later activated manually to break out of any restraints or grabs. Can be activated up to 4 times."
	reference = "FI"
	item = /obj/item/bio_chip_implanter/freedom
	cost = 25

/datum/uplink_item/bio_chips/protofreedom
	name = "Prototype Freedom Bio-chip"
	desc = "A prototype bio-chip injected into the body and later activated manually to break out of any restraints or grabs. Can only be activated a singular time."
	reference = "PFI"
	item = /obj/item/bio_chip_implanter/freedom/prototype
	cost = 10

/datum/uplink_item/bio_chips/storage
	name = "Storage Bio-chip"
	desc = "A bio-chip injected into the body, and later activated at the user's will. It will open a small subspace pocket capable of storing two items."
	reference = "ESI"
	item = /obj/item/bio_chip_implanter/storage
	cost = 40

/datum/uplink_item/bio_chips/mindslave
	name = "Mindslave Bio-chip"
	desc = "A box containing a bio-chip implanter filled with a mindslave bio-chip that when injected into another person makes them loyal to you and your cause, unless of course they're already implanted by someone else. Loyalty ends if the implant is no longer in their system."
	reference = "MI"
	item = /obj/item/bio_chip_implanter/traitor
	cost = 50

/datum/uplink_item/bio_chips/adrenal
	name = "Adrenal Bio-chip"
	desc = "A bio-chip injected into the body, and later activated manually to inject a chemical cocktail, which has a mild healing effect along with removing and reducing the time of all stuns and increasing movement speed. Can be activated up to 3 times."
	reference = "AI"
	item = /obj/item/bio_chip_implanter/adrenalin
	cost = 40

/datum/uplink_item/bio_chips/basic_adrenal
	name = "Basic-Adrenal Bio-chip"
	desc = "A single-use bio-chip injected into the body and later activated manually to inject a chemical cocktail. This one has a worse healing effect than regular adrenaline. It can be activated once for 3/4 of the effect of the original."
	reference = "BAI"
	item = /obj/item/bio_chip_implanter/basic_adrenalin
	cost = 20
	can_discount = FALSE

/datum/uplink_item/bio_chips/proto_adrenal
	name = "Proto-Adrenal Bio-chip"
	desc = "A old prototype of the Adrenalin implant, that grants the user 4 seconds of antistun, getting them back on their feet instantly once, but nothing more. Speed and healing sold separately."
	reference = "PAI"
	item = /obj/item/bio_chip_implanter/proto_adrenalin
	cost = 10

/datum/uplink_item/bio_chips/stealthimplant
	name = "Stealth Bio-chip"
	desc = "This one-of-a-kind implant will make you almost invisible if you play your cards right. \
			On activation, it will conceal you inside a chameleon cardboard box that is only revealed once someone bumps into it."
	reference = "SI"
	item = /obj/item/bio_chip_implanter/stealth
	cost = 45

////////////////////////////////////////
// MARK: CYBERNETICS
////////////////////////////////////////

/datum/uplink_item/cyber_implants
	category = "Cybernetic Implants"

/datum/uplink_item/cyber_implants/hackerman_deck
	name = "Binyat Wireless Hacking System Autoimplanter"
	desc = "This implant will allow you to wirelessly emag from a distance. However, it will slightly burn you \
	on use, and will be quite visual as you are emaging the object. \
	Will not show on unupgraded body scanners. Incompatible with the Qani-Laaca Sensory Computer."
	reference = "HKR"
	item = /obj/item/autosurgeon/organ/syndicate/oneuse/hackerman_deck
	cost = 30 // Probably slightly less useful than an emag with heat / cooldown, but I am not going to make it cheaper or everyone picks it over emag

/datum/uplink_item/cyber_implants/razorwire
	name = "Razorwire Spool Arm Implant Autoimplanter"
	desc = "A long length of monomolecular filament, built into the back of your hand. \
		Impossibly thin and flawlessly sharp, it should slice through organic materials with no trouble; \
		even from a few steps away. However, results against anything more durable will heavily vary."
	reference = "RZR"
	item = /obj/item/autosurgeon/organ/syndicate/oneuse/razorwire
	cost = 20

/datum/uplink_item/cyber_implants/scope_eyes
	name = "Hardened Kaleido Optics Eyes Autoimplanter"
	desc = "These cybernetic eye implants will let you zoom in on far away objects. \
	Many users find it disorienting, and find it hard to interact with things near them when active. \
	This pair has been hardened for special operations personnel."
	reference = "KOE"
	item = /obj/item/autosurgeon/organ/syndicate/oneuse/scope_eyes
	cost = 10

/datum/uplink_item/cyber_implants/mantis_kit
	name = "'Naginata' Mantis Blades Kit"
	desc = "A pair of devastating 'Naginata' concealable mantis blades, which retract into the arms of the user. \
	Their monomolecular edges will easily tear through flesh and armor alike, and can even pry open airlocks when used together. \
	When both blades are equipped, they enable the user to perform double attacks. \
	Can be used to parry incoming melee attacks."
	reference = "MBK"
	item = /obj/item/storage/box/syndie_kit/syndie_mantis
	cost = 50
	surplus = 0
	can_discount = FALSE
	excludefrom = list(UPLINK_TYPE_NUCLEAR)

////////////////////////////////////////
// MARK: POINTLESS BADASSERY
////////////////////////////////////////

/datum/uplink_item/badass
	category = "(Pointless) Badassery"
	surplus = 0

/datum/uplink_item/badass/pen
	name = "Syndicate Fountain Pen"
	desc = "A slick Syndicate-branded pen, to show everyone at the meeting that you mean business."
	reference = "PEN"
	item = /obj/item/pen/multi/syndicate
	cost = 1

/datum/uplink_item/badass/syndiecigs
	name = "Syndicate Smokes"
	desc = "Strong flavor, dense smoke, infused with omnizine."
	reference = "SYSM"
	item = /obj/item/storage/fancy/cigarettes/cigpack_syndicate
	cost = 7

/datum/uplink_item/badass/syndiecash
	name = "Syndicate Briefcase Full of Cash"
	desc = "A secure briefcase containing 600 space credits. Useful for bribing personnel, or purchasing goods and services at lucrative prices. \
	The briefcase also feels a little heavier to hold; it has been manufactured to pack a little bit more of a punch if your client needs some convincing."
	reference = "CASH"
	item = /obj/item/storage/secure/briefcase/syndie
	cost = 5

/datum/uplink_item/badass/balloon
	name = "For showing that you are The Boss"
	desc = "A useless red balloon with the syndicate logo on it, which can blow the deepest of covers."
	reference = "BABA"
	item = /obj/item/toy/syndicateballoon
	cost = 100
	can_discount = FALSE

/datum/uplink_item/badass/bomber
	name = "Syndicate Bomber Jacket"
	desc = "An awesome jacket to help you style on Nanotrasen with. The lining is made of a thin polymer to provide a small amount of armor. Does not provide any extra storage space."
	reference = "JCKT"
	item = /obj/item/clothing/suit/jacket/bomber/syndicate
	cost = 3

/datum/uplink_item/badass/tpsuit
	name = "Syndicate Two-Piece Suit"
	desc = "A snappy two-piece suit that any self-respecting Syndicate agent should wear. Perfect for professionals trying to go undetected, but moderately armored with experimental nanoweave in case things do get loud. Comes with two cashmere-lined pockets for maximum style and comfort."
	reference = "SUIT"
	item = /obj/item/clothing/suit/storage/iaa/blackjacket/armored
	cost = 3

/datum/uplink_item/badass/syndie_garments
	name = "Syndicate Garment Bag"
	desc = "A customised garment bag filled with all kinds of Syndicate attire, for the fashionable agent's needs. Proclaim your allegiance with style!"
	reference = "GRMT"
	item = /obj/item/storage/bag/garment/syndie
	cost = 5

////////////////////////////////////////
// MARK: BUNDLES AND TELECRYSTALS
////////////////////////////////////////

/datum/uplink_item/bundles_tc
	category = "Bundles and Telecrystals"
	surplus = 0
	can_discount = FALSE

/datum/uplink_item/bundles_tc/telecrystal
	name = "Raw Telecrystal"
	desc = "Telecrystal in its rawest and purest form; can be utilized on active uplinks to increase their telecrystal count."
	reference = "RTC"
	item = /obj/item/stack/telecrystal
	cost = 1

/datum/uplink_item/bundles_tc/telecrystal/five
	name = "5 Raw Telecrystals"
	desc = "Five telecrystals in their rawest and purest form; can be utilized on active uplinks to increase their telecrystal count."
	reference = "RTCF"
	item = /obj/item/stack/telecrystal/five
	cost = 5

/datum/uplink_item/bundles_tc/telecrystal/twenty
	name = "20 Raw Telecrystals"
	desc = "Twenty telecrystals in their rawest and purest form; can be utilized on active uplinks to increase their telecrystal count."
	reference = "RTCT"
	item = /obj/item/stack/telecrystal/twenty
	cost = 20

/datum/uplink_item/bundles_tc/telecrystal/fifty
	name = "50 Raw Telecrystals"
	desc = "Fifty telecrystals in their rawest and purest form; can be utilized on active uplinks to increase their telecrystal count."
	reference = "RTCB"
	item = /obj/item/stack/telecrystal/fifty
	cost = 50

/datum/uplink_item/bundles_tc/telecrystal/hundred
	name = "100 Raw Telecrystals"
	desc = "One-hundred telecrystals in their rawest and purest form; can be utilized on active uplinks to increase their telecrystal count."
	reference = "RTCH"
	item = /obj/item/stack/telecrystal/hundred
	cost = 100

var/list/uplink_items = list()

/proc/get_uplink_items(var/job = null)
	// If not already initialized..
	if(!uplink_items.len)

		// Fill in the list	and order it like this:
		// A keyed list, acting as categories, which are lists to the datum.

		var/list/last = list()
		for(var/item in typesof(/datum/uplink_item))

			var/datum/uplink_item/I = new item()
			if(!I.item)
				continue
			if(I.gamemodes.len && ticker && !(ticker.mode.type in I.gamemodes))
				continue
			if(I.excludefrom.len && ticker && (ticker.mode.type in I.excludefrom))
				continue
			if(I.last)
				last += I
				continue

			if(!uplink_items[I.category])
				uplink_items[I.category] = list()

			uplink_items[I.category] += I

		for(var/datum/uplink_item/I in last)
			if(!uplink_items[I.category])
				uplink_items[I.category] = list()

			uplink_items[I.category] += I

	return uplink_items

/datum/nano_item_lists
	var/list/items_nano
	var/list/items_reference

// You can change the order of the list by putting datums before/after one another OR
// you can use the last variable to make sure it appears last, well have the category appear last.

/datum/uplink_item
	var/name = "item name"
	var/category = "item category"
	var/desc = "Item Description"
	var/reference = "Item Reference"
	var/item = null
	var/cost = 0
	var/last = 0 // Appear last
	var/abstract = 0
	var/list/gamemodes = list() // Empty list means it is in all the gamemodes. Otherwise place the gamemode name here.
	var/list/excludefrom = list() //Empty list does nothing. Place the name of gamemode you don't want this item to be available in here. This is so you dont have to list EVERY mode to exclude something.
	var/list/job = null
	var/surplus = 100 //Chance of being included in the surplus crate (when pick() selects it)
	var/hijack_only = 0 //can this item be purchased only during hijackings?

/datum/uplink_item/proc/spawn_item(var/turf/loc, var/obj/item/device/uplink/U)
	if(hijack_only)
		if(!(locate(/datum/objective/hijack) in usr.mind.objectives))
			to_chat(usr, "<span class='warning'>The Syndicate lacks resources to provide you with this item.</span>")
			return
	if(item)
		U.uses -= max(cost, 0)
		U.used_TC += cost
		feedback_add_details("traitor_uplink_items_bought", name)
		return new item(loc)

/datum/uplink_item/proc/description()
	if(!desc)
		// Fallback description
		var/obj/temp = src.item
		desc = replacetext(initial(temp.desc), "\n", "<br>")
	return desc

/datum/uplink_item/proc/buy(var/obj/item/device/uplink/hidden/U, var/mob/user)
	..()

	if(!istype(U))
		return 0

	if(user.stat || user.restrained())
		return 0

	if(!(istype(user, /mob/living/carbon/human)))
		return 0

	// If the uplink's holder is in the user's contents
	if((U.loc in user.contents || (in_range(U.loc, user) && istype(U.loc.loc, /turf))))
		user.set_machine(U)
		if(cost > U.uses)
			return 0

		var/obj/I = spawn_item(get_turf(user), U)

		if(I)
			if(ishuman(user))
				var/mob/living/carbon/human/A = user
				A.put_in_any_hand_if_possible(I)

				if(istype(I,/obj/item/weapon/storage/box/) && I.contents.len>0)
					for(var/atom/o in I)
						U.purchase_log += "<BIG>[bicon(o)]</BIG>"
				else
					U.purchase_log += "<BIG>[bicon(I)]</BIG>"

		//U.interact(user)
		return 1
	return 0

/*
//
//	UPLINK ITEMS
//
*/
//Work in Progress, job specific antag tools

/datum/uplink_item/jobspecific
	category = "Job Specific Tools"

//Clown
/datum/uplink_item/jobspecific/clowngrenade
	name = "Banana Grenade"
	desc = "A grenade that explodes into HONK! brand banana peels that are genetically modified to be extra slippery and extrude caustic acid when stepped on"
	reference = "BG"
	item = /obj/item/weapon/grenade/clown_grenade
	cost = 5
	job = list("Clown")

//mime
/datum/uplink_item/job_specific/caneshotgun
	name = "Cane Shotgun + Assassination Darts"
	desc = "A specialized, one shell shotgun with a built-in cloaking device to mimic a cane. The shotgun is capable of hiding it's contents and the pin alongside being supressed. Comes with 6 special darts and a preloaded shrapnel round."
	reference = "MCS"
	item = /obj/item/weapon/storage/box/syndie_kit/caneshotgun
	cost = 15
	job = list("Mime")

/datum/uplink_item/dangerous/cat_grenade
	name = "Feral Cat Delivery Grenade"
	desc = "The feral cat delivery grenade contains 8 dehydrated feral cats in a similar manner to dehydrated monkeys, which, upon detonation, will be rehydrated by a small reservoir of water contained within the grenade. These cats will then attack anything in sight."
	item = /obj/item/weapon/grenade/spawnergrenade/feral_cats
	reference = "CCLG"
	cost = 5
	job = list("Psychiatrist")//why? Becuase its funny that a person in charge of your mental wellbeing has a cat granade..

//Chef
/datum/uplink_item/jobspecific/specialsauce
	name = "Chef Excellence's Special Sauce"
	desc = "A custom made sauce made from the toxin glands of 1000 space carp, if somebody ingests enough they'll be dead in 3 minutes or less guaranteed."
	reference = "CESS"
	item = /obj/item/weapon/reagent_containers/food/condiment/syndisauce
	cost = 2
	job = list("Chef")

/datum/uplink_item/jobspecific/meatcleaver
	name = "Meat Cleaver"
	desc = "A mean looking meat cleaver that does damage comparable to an Energy Sword but with the added benefit of chopping your victim into hunks of meat after they've died and the chance to stun when thrown."
	reference = "MC"
	item = /obj/item/weapon/kitchen/knife/butcher/meatcleaver
	cost = 10
	job = list("Chef")

/datum/uplink_item/jobspecific/syndidonk
	name = "Syndicate Donk Pockets"
	desc = "A box of highly specialized Donk pockets with a number of regenerative and stimulating chemicals inside of them; the box comes equipped with a self-heating mechanism."
	reference = "SDP"
	item = /obj/item/weapon/storage/box/syndidonkpockets
	cost = 2
	job = list("Chef")

//Chaplain

/datum/uplink_item/jobspecific/voodoo
	name = "Voodoo Doll"
	desc = "A doll created by Syndicate Witch Doctors. Ingredients: Something of the Thread, Something of the Head, Something of the Body, Something of the Dead, Secret Voodoo herbs, and Monosodium glutamate."
	reference = "VD"
	item = /obj/item/voodoo
	cost = 13
	job = list("Chaplain")

/datum/uplink_item/jobspecific/missionary_kit
	name = "Missionary Starter Kit"
	desc = "A box containing a missionary staff, missionary robes, and bible. The robes and staff can be linked to allow you to convert victims at range for a short time to do your bidding. The bible is for bible stuff."
	reference = "MK"
	item = /obj/item/weapon/storage/box/syndie_kit/missionary_set
	cost = 15
	job = list("Chaplain")

/datum/uplink_item/jobspecific/artistic_toolbox
	name = "Artistic Toolbox"
	desc = "An accursed toolbox that grants its followers extreme power at the cost of requiring repeated sacrifices to it. If sacrifices are not provided, it will turn on its follower."
	reference = "HGAT"
	item = /obj/item/weapon/storage/toolbox/green/memetic
	cost = 20
	job = list("Chaplain")
	surplus = 0     //No lucky chances from the crate; if you get this, this is ALL you're getting
	hijack_only = 1 //This is a murderbone weapon, as such, it should only be available in those scenarios.

//Janitor

/datum/uplink_item/jobspecific/cautionsign
	name = "Proximity Mine"
	desc = "An Anti-Personnel proximity mine cleverly disguised as a wet floor caution sign that is triggered by running past it, activate it to start the 15 second timer and activate again to disarm."
	reference = "PM"
	item = /obj/item/weapon/caution/proximity_sign
	cost = 4
	job = list("Janitor")

//Medical


/datum/uplink_item/jobspecific/rad_laser
	name = "Radiation Laser"
	desc = "A radiation laser concealed inside of a Health Analyser. After a moderate delay, causes temporary collapse and radiation.  Has adjustable controls, but will not function as a regular health analyser, only appears like one. May not function correctly on radiation resistant humanoids!"
	reference = "RL"
	item = /obj/item/device/rad_laser
	cost = 5
	job = list(
		"Chief Medical Officer",
		"Medical Doctor",
		"Geneticist",
		"Psychiatrist",
		"Chemist",
		"Paramedic",
		"Virologist",
		"Brig Physician"
	)

//Assistant

/datum/uplink_item/jobspecific/pickpocketgloves
	name = "Pickpocket's Gloves"
	desc = "A pair of sleek gloves to aid in pickpocketing. While wearing these, you can loot your target without them knowing. Pickpocketing puts the item directly into your hand."
	reference = "PG"
	item = /obj/item/clothing/gloves/color/black/thief
	cost = 6
	job = list("Civilian")

//Bartender

/datum/uplink_item/jobspecific/drunkbullets
	name = "Boozey Shotgun Shells"
	desc = "A box containing 6 shotgun shells that simulate the effects of extreme drunkenness on the target, more effective for each type of alcohol in the target's system."
	reference = "BSS"
	item = /obj/item/weapon/storage/box/syndie_kit/boolets
	cost = 6
	job = list("Bartender")


//Barber

/datum/uplink_item/jobspecific/safety_scissors  //Hue
	name = "Safety Scissors"
	desc = "A pair of scissors that are anything but what their name implies; can easily cut right into someone's throat."
	reference = "CTS"
	item = /obj/item/weapon/scissors/safety
	cost = 5
	job = list("Barber")

//Botanist

/datum/uplink_item/jobspecific/bee_briefcase
	name = "Briefcase Full of Bees"
	desc = "A seemingly innocent briefcase full of not-so-innocent Syndicate-bred bees. Inject the case with blood to train the bees to ignore the donor(s). It also wirelessly taps into station intercomms to broadcast a message of TERROR."
	reference = "BEE"
	item = /obj/item/weapon/bee_briefcase
	cost = 10
	job = list("Botanist")

//Engineer

/datum/uplink_item/jobspecific/powergloves
	name = "Power Gloves"
	desc = "Insulated gloves that can utilize the power of the station to deliver a short arc of electricity at a target. Must be standing on a powered cable to use."
	reference = "PG"
	item = /obj/item/clothing/gloves/color/yellow/power
	cost = 10
	job = list("Station Engineer","Chief Engineer")

//RD

/datum/uplink_item/jobspecific/telegun
	name = "Telegun"
	desc = "An extremely high-tech energy gun that utilizes bluespace technology to teleport away living targets. Select the target beacon on the telegun itself; projectiles will send targets to the beacon locked onto."
	reference = "TG"
	item = /obj/item/weapon/gun/energy/telegun
	cost = 12
	job = list("Research Director")

//Librarian
/datum/uplink_item/jobspecific/etwenty
	name = "The E20"
	desc = "A seemingly innocent die, those who are not afraid to roll for attack will find it's effects quite explosive. Has a four second timer."
	reference = "ETW"
	item = /obj/item/weapon/dice/d20/e20
	cost = 3
	job = list("Librarian")


//Botanist
/datum/uplink_item/jobspecific/ambrosiacruciatus
	name = "Ambrosia Cruciatus Seeds"
	desc = "Part of the notorious Ambrosia family, this species is nearly indistinguishable from Ambrosia Vulgaris- but its' branches contain a revolting toxin. Eight units are enough to drive victims insane."
	reference = "BRO"
	item = /obj/item/seeds/ambrosiavulgarisseed/cruciatus
	cost = 2
	job = list("Botanist")


//Atmos Tech
/datum/uplink_item/jobspecific/contortionist
	name = "Contortionist's Jumpsuit"
	desc = "A highly flexible jumpsuit that will help you navigate the ventilation loops of the station internally. Comes with pockets and ID slot, but can't be used without stripping off most gear, including backpack, belt, helmet, and exosuit. Free hands are also necessary to crawl around inside."
	reference = "AIRJ"
	item = /obj/item/clothing/under/contortionist
	cost = 6
	job = list("Life Support Specialist")

/datum/uplink_item/dangerous/energizedfireaxe
	name = "Energized Fire Axe"
	desc = "A fire axe with a massive electrical charge built into it. It can release this charge on its first victim and will be rather plain after that."
	reference = "EFA"
	item = /obj/item/weapon/twohanded/energizedfireaxe
	cost = 10
	job = list("Life Support Specialist")

//Stimulants

/datum/uplink_item/jobspecific/stims
	name = "Stimulants"
	desc = "A highly illegal compound contained within a compact auto-injector; when injected it makes the user extremely resistant to incapacitation and greatly enhances the body's ability to repair itself."
	reference = "ST"
	item = /obj/item/weapon/reagent_containers/hypospray/autoinjector/stimulants
	cost = 7
	job = list("Scientist","Research Director","Geneticist","Chief Medical Officer","Medical Doctor","Psychiatrist","Chemist","Paramedic","Virologist","Brig Physician")

//Tator Poison Bottles

/datum/uplink_item/jobspecific/poisonbottle
	name = "Poison Bottle"
	desc = "The Syndicate will ship a bottle containing 40 units of a randomly selected poison. The poison can range from highly irritating to incredibly lethal."
	reference = "TPB"
	item = /obj/item/weapon/reagent_containers/glass/bottle/traitor
	cost = 2
	job = list("Research Director","Chief Medical Officer","Medical Doctor","Psychiatrist","Paramedic","Virologist","Bartender")

// DANGEROUS WEAPONS

/datum/uplink_item/dangerous
	category = "Highly Visible and Dangerous Weapons"


/datum/uplink_item/dangerous/pistol
	name = "FK-69 Pistol"
	reference = "SPI"
	desc = "A small, easily concealable handgun that uses 10mm auto rounds in 8-round magazines and is compatible with suppressors."
	item = /obj/item/weapon/gun/projectile/automatic/pistol
	cost = 4

/datum/uplink_item/dangerous/revolver
	name = "Syndicate .357 Revolver"
	reference = "SR"
	desc = "A brutally simple syndicate revolver that fires .357 Magnum cartridges and has 7 chambers."
	item = /obj/item/weapon/gun/projectile/revolver
	cost = 13
	surplus = 50

/datum/uplink_item/dangerous/smg
	name = "C-20r Submachine Gun"
	reference = "SMG"
	desc = "A fully-loaded Scarborough Arms bullpup submachine gun that fires .45 rounds with a 20-round magazine and is compatible with suppressors."
	item = /obj/item/weapon/gun/projectile/automatic/c20r
	cost = 14
	gamemodes = list(/datum/game_mode/nuclear)
	surplus = 40

/datum/uplink_item/dangerous/carbine
	name = "M-90gl Carbine"
	desc = "A fully-loaded three-round burst carbine that uses 30-round 5.56mm magazines with a togglable underslung 40mm grenade launcher."
	reference = "AR"
	item = /obj/item/weapon/gun/projectile/automatic/m90
	cost = 18
	gamemodes = list(/datum/game_mode/nuclear)
	surplus = 50

/datum/uplink_item/dangerous/machinegun
	name = "L6 Squad Automatic Weapon"
	desc = "A fully-loaded Aussec Armoury belt-fed machine gun. This deadly weapon has a massive 50-round magazine of devastating 7.62x51mm ammunition."
	reference = "LMG"
	item = /obj/item/weapon/gun/projectile/automatic/l6_saw
	cost = 40
	gamemodes = list(/datum/game_mode/nuclear)
	surplus = 0

/datum/uplink_item/dangerous/sniper
	name = "Sniper Rifle"
	desc = "Ranged fury, Syndicate style. guaranteed to cause shock and awe or your TC back!"
	reference = "SSR"
	item = /obj/item/weapon/gun/projectile/automatic/sniper_rifle/syndicate
	cost = 16
	surplus = 25
	gamemodes = list(/datum/game_mode/nuclear)

/datum/uplink_item/dangerous/crossbow
	name = "Energy Crossbow"
	desc = "A miniature energy crossbow that is small enough both to fit into a pocket and to slip into a backpack unnoticed by observers. Fires bolts tipped with toxin, a poisonous substance that is the product of a living organism. Stuns enemies for a short period of time. Recharges automatically."
	reference = "EC"
	item = /obj/item/weapon/gun/energy/kinetic_accelerator/crossbow
	cost = 12
	excludefrom = list(/datum/game_mode/nuclear)
	surplus = 50

/datum/uplink_item/dangerous/flamethrower
	name = "Flamethrower"
	desc = "A flamethrower, fuelled by a portion of highly flammable bio-toxins stolen previously from Nanotrasen stations. Make a statement by roasting the filth in their own greed. Use with caution."
	reference = "FT"
	item = /obj/item/weapon/flamethrower/full/tank
	cost = 11
	gamemodes = list(/datum/game_mode/nuclear)
	surplus = 40

/datum/uplink_item/dangerous/sword
	name = "Energy Sword"
	desc = "The energy sword is an edged weapon with a blade of pure energy. The sword is small enough to be pocketed when inactive. Activating it produces a loud, distinctive noise."
	reference = "ES"
	item = /obj/item/weapon/melee/energy/sword/saber
	cost = 8

/datum/uplink_item/dangerous/powerfist
	name = "Power Fist"
	desc = "The power-fist is a metal gauntlet with a built-in piston-ram powered by an external gas supply.\
		 Upon hitting a target, the piston-ram will extend foward to make contact for some serious damage. \
		 Using a wrench on the piston valve will allow you to tweak the amount of gas used per punch to \
		 deal extra damage and hit targets further. Use a screwdriver to take out any attached tanks."
	reference = "PF"
	item = /obj/item/weapon/melee/powerfist
	cost = 8

/datum/uplink_item/dangerous/chainsaw
	name = "Chainsaw"
	desc = "A high powered chainsaw for cutting up ...you know...."
	reference = "CH"
	item = /obj/item/weapon/twohanded/chainsaw
	cost = 13

/datum/uplink_item/dangerous/batterer
	name = "Mind Batterer"
	desc = "A device that has a chance of knocking down people around you for a long amount of time. 50% chance per person. The user is unaffected. Has 5 charges."
	reference = "BTR"
	item = /obj/item/device/batterer
	cost = 5

/datum/uplink_item/dangerous/manhacks
	name = "Viscerator Delivery Grenade"
	desc = "A unique grenade that deploys a swarm of viscerators upon activation, which will chase down and shred any non-operatives in the area."
	reference = "VDG"
	item = /obj/item/weapon/grenade/spawnergrenade/manhacks
	cost = 8
	gamemodes = list(/datum/game_mode/nuclear)
	surplus = 35

/datum/uplink_item/ammo/bioterror
	name = "Box of Bioterror Syringes"
	desc = "A box full of preloaded syringes, containing various chemicals that seize up the victim's motor and broca system , making it impossible for them to move or speak while in their system."
	reference = "BTS"
	item = /obj/item/weapon/storage/box/syndie_kit/bioterror
	cost = 6
	gamemodes = list(/datum/game_mode/nuclear)

/datum/uplink_item/dangerous/saringrenades
	name = "Sarin Gas Grenades"
	desc = "A box of four (4) grenades filled with Sarin, a deadly neurotoxin. Use extreme caution when handling and be sure to vacate the premise after using; ensure communication is maintained with team to avoid accidental gassings."
	reference = "TGG"
	item = /obj/item/weapon/storage/box/syndie_kit/sarin
	cost = 15
	gamemodes = list(/datum/game_mode/nuclear)
	surplus = 0

/datum/uplink_item/dangerous/atmosgrenades
	name = "Atmos Grenades"
	desc = "A box of two (2) grenades that wreak havoc with the atmosphere of the target area. Capable of engulfing a large area in lit plasma, or N2O. Deploy with extreme caution!"
	reference = "AGG"
	item = /obj/item/weapon/storage/box/syndie_kit/atmosgasgrenades
	cost = 6

/datum/uplink_item/dangerous/emp
	name = "EMP Grenades and Implanter Kit"
	desc = "A box that contains two EMP grenades and an EMP implant. Useful to disrupt communication, \
			security's energy weapons, and silicon lifeforms when you're in a tight spot."
	reference = "EMPK"
	item = /obj/item/weapon/storage/box/syndie_kit/emp
	cost = 2

/datum/uplink_item/dangerous/syndicate_minibomb
	name = "Syndicate Minibomb"
	desc = "The minibomb is a grenade with a five-second fuse."
	reference = "SMB"
	item = /obj/item/weapon/grenade/syndieminibomb
	cost = 6

/datum/uplink_item/dangerous/gygax
	name = "Gygax Exosuit"
	desc = "A lightweight exosuit, painted in a dark scheme. Its speed and equipment selection make it excellent for hit-and-run style attacks. \
	This model lacks a method of space propulsion, and therefore it is advised to repair the mothership's teleporter if you wish to make use of it."
	reference = "GE"
	item = /obj/mecha/combat/gygax/dark/loaded
	cost = 90
	gamemodes = list(/datum/game_mode/nuclear)
	surplus = 0

/datum/uplink_item/dangerous/mauler
	name = "Mauler Exosuit"
	desc = "A massive and incredibly deadly Syndicate exosuit. Features long-range targeting, thrust vectoring, and deployable smoke."
	reference = "ME"
	item = /obj/mecha/combat/marauder/mauler/loaded
	cost = 140
	gamemodes = list(/datum/game_mode/nuclear)
	surplus = 0

/datum/uplink_item/dangerous/syndieborg
	name = "Syndicate Cyborg"
	desc = "A cyborg designed and programmed for systematic extermination of non-Syndicate personnel."
	reference = "SC"
	item = /obj/item/weapon/antag_spawner/borg_tele
	cost = 50
	gamemodes = list(/datum/game_mode/nuclear)
	surplus = 0

/datum/uplink_item/dangerous/foamsmg
	name = "Toy Submachine Gun"
	desc = "A fully-loaded Donksoft bullpup submachine gun that fires riot grade rounds with a 20-round magazine."
	reference = "FSMG"
	item = /obj/item/weapon/gun/projectile/automatic/c20r/toy
	cost = 5
	gamemodes = list(/datum/game_mode/nuclear)
	surplus = 0

/datum/uplink_item/dangerous/foammachinegun
	name = "Toy Machine Gun"
	desc = "A fully-loaded Donksoft belt-fed machine gun. This weapon has a massive 50-round magazine of devastating riot grade darts, that can briefly incapacitate someone in just one volley."
	reference = "FLMG"
	item = /obj/item/weapon/gun/projectile/automatic/l6_saw/toy
	cost = 10
	gamemodes = list(/datum/game_mode/nuclear)
	surplus = 0

/datum/uplink_item/ammo/toydarts
	name = "Box of Riot Darts"
	desc = "A box of 40 Donksoft foam riot darts, for reloading any compatible foam dart gun. Don't forget to share!"
	reference = "FOAM"
	item = /obj/item/ammo_box/foambox/riot
	cost = 2
	gamemodes = list(/datum/game_mode/nuclear)
	surplus = 0


//for refunding the syndieborg teleporter
/datum/uplink_item/dangerous/syndieborg/spawn_item()
	var/obj/item/weapon/antag_spawner/borg_tele/T = ..()
	if(istype(T))
		T.TC_cost = cost

/datum/uplink_item/dangerous/guardian
	name = "Holoparasites"
	desc = "Though capable of near sorcerous feats via use of hardlight holograms and nanomachines, they require an organic host as a home base and source of fuel."
	item = /obj/item/weapon/storage/box/syndie_kit/guardian
	excludefrom = list(/datum/game_mode/nuclear)
	cost = 12

// Ammunition

/datum/uplink_item/ammo
	category = "Ammunition"
	surplus = 40

/datum/uplink_item/ammo/pistol
	name = "Magazine - 10mm"
	desc = "An additional 8-round 10mm magazine for use in the syndicate pistol. These subsonic rounds are dirt cheap but are half as effective as .357 rounds."
	reference = "10MM"
	item = /obj/item/ammo_box/magazine/m10mm
	cost = 1

/datum/uplink_item/ammo/revolver
	name = "Speed Loader - .357"
	desc = "A speed loader that contains seven additional .357 Magnum rounds for the syndicate revolver. For when you really need a lot of things dead."
	reference = "357"
	item = /obj/item/ammo_box/a357
	cost = 4

/datum/uplink_item/ammo/smg
	name = "Magazine - .45"
	desc = "An additional 20-round .45 magazine for use in the C-20r submachine gun. These bullets pack a lot of punch that can knock most targets down, but do limited overall damage."
	reference = "45"
	item = /obj/item/ammo_box/magazine/smgm45
	cost = 2
	gamemodes = list(/datum/game_mode/nuclear)

/datum/uplink_item/ammo/ammobag
	name = "Ammo Duffelbag - Shotgun Ammo Grab Bag"
	desc = "A duffelbag filled with Bulldog ammo to kit out an entire team, at a discounted price."
	reference = "SAGL"
	item = /obj/item/weapon/storage/backpack/duffel/syndie/ammo/loaded
	cost = 10 //bulk buyer's discount. Very useful if you're buying a mech and dont have TC left to buy people non-shotgun guns
	gamemodes = list(/datum/game_mode/nuclear)

/datum/uplink_item/ammo/bullslug
	name = "Drum Magazine - 12g Slugs"
	desc = "An additional 8-round slug magazine for use in the Bulldog shotgun. Now 8 times less likely to shoot your pals."
	reference = "12BSG"
	item = /obj/item/ammo_box/magazine/m12g
	cost = 2
	gamemodes = list(/datum/game_mode/nuclear)

/datum/uplink_item/ammo/bullbuck
	name = "Drum Magazine - 12g buckshot"
	desc = "An additional 8-round buckshot magazine for use in the Bulldog shotgun. Front towards enemy."
	reference = "12BS"
	item = /obj/item/ammo_box/magazine/m12g/buckshot
	cost = 2
	gamemodes = list(/datum/game_mode/nuclear)

/datum/uplink_item/ammo/bullstun
	name = "Drum Magazine - 12g Stun Slug"
	desc = "An alternative 8-round stun slug magazine for use in the Bulldog shotgun. Saying that they're completely non-lethal would be lying."
	reference = "12SS"
	item = /obj/item/ammo_box/magazine/m12g/stun
	cost = 3
	gamemodes = list(/datum/game_mode/nuclear)

/datum/uplink_item/ammo/bulldragon
	name = "Drum Magazine - 12g Dragon's Breath"
	desc = "An alternative 8-round dragon's breath magazine for use in the Bulldog shotgun. I'm a fire starter, twisted fire starter!"
	reference = "12DB"
	item = /obj/item/ammo_box/magazine/m12g/dragon
	cost = 2
	gamemodes = list(/datum/game_mode/nuclear)

/datum/uplink_item/ammo/carbine
	name = "Toploader Magazine - 5.56"
	desc = "An additional 30-round 5.56 magazine for use in the M-90gl carbine. These bullets don't have the punch to knock most targets down, but dish out higher overall damage."
	reference = "556"
	item = /obj/item/ammo_box/magazine/m556
	cost = 2
	gamemodes = list(/datum/game_mode/nuclear)

/datum/uplink_item/ammo/a40mm
	name = "Ammo Box - 40mm grenades"
	desc = "A box of 4 additional 40mm HE grenades for use the C-90gl's underbarrel grenade launcher. Your teammates will thank you to not shoot these down small hallways."
	reference = "40MM"
	item = /obj/item/ammo_box/a40mm
	cost = 4
	gamemodes = list(/datum/game_mode/nuclear)

/datum/uplink_item/ammo/machinegun
	name = "Box Magazine - 5.56x45mm"
	desc = "A 50-round magazine of 5.56x45mm ammunition for use in the L6 SAW machine gun. By the time you need to use this, you'll already be on a pile of corpses."
	reference = "762"
	item = /obj/item/ammo_box/magazine/mm556x45
	cost = 12
	gamemodes = list(/datum/game_mode/nuclear)
	surplus = 0

/datum/uplink_item/ammo/sniper
	cost = 4
	gamemodes = list(/datum/game_mode/nuclear)

/datum/uplink_item/ammo/sniper/basic
	name = ".50 Magazine"
	desc = "An additional standard 6-round magazine for use with .50 sniper rifles."
	reference = "50M"
	item = /obj/item/ammo_box/magazine/sniper_rounds

/datum/uplink_item/ammo/sniper/soporific
	name = ".50 Soporific Magazine"
	desc = "A 3-round magazine of soporific ammo designed for use with .50 sniper rifles. Put your enemies to sleep today!"
	reference = "50S"
	item = /obj/item/ammo_box/magazine/sniper_rounds/soporific
	cost = 6

/datum/uplink_item/ammo/sniper/haemorrhage
	name = ".50 Haemorrhage Magazine"
	desc = "A 5-round magazine of haemorrhage ammo designed for use with .50 sniper rifles; causes heavy bleeding \
			in the target."
	reference = "50B"
	item = /obj/item/ammo_box/magazine/sniper_rounds/haemorrhage

/datum/uplink_item/ammo/sniper/penetrator
	name = ".50 Penetrator Magazine"
	desc = "A 5-round magazine of penetrator ammo designed for use with .50 sniper rifles. \
			Can pierce walls and multiple enemies."
	reference = "50P"
	item = /obj/item/ammo_box/magazine/sniper_rounds/penetrator
	cost = 5

// STEALTHY WEAPONS

/datum/uplink_item/stealthy_weapons
	category = "Stealthy and Inconspicuous Weapons"

/datum/uplink_item/stealthy_weapons/garrote
	name = "Fiber Wire Garrote"
	desc = "A length of fiber wire between two wooden handles, perfect for the discrete assassin. This weapon, when used on a target from behind \
			will instantly put them in your grasp and silence them, as well as causing rapid suffocation. Does not work on those who do not need to breathe."
	reference = "GAR"
	item = /obj/item/weapon/twohanded/garrote
	cost = 12

/datum/uplink_item/stealthy_weapons/martialarts
	name = "Martial Arts Scroll"
	desc = "This scroll contains the secrets of an ancient martial arts technique. You will master unarmed combat, \
			deflecting all ranged weapon fire, but you also refuse to use dishonorable ranged weaponry."
	reference = "SCS"
	item = /obj/item/weapon/sleeping_carp_scroll
	cost = 17
	excludefrom = list(/datum/game_mode/nuclear)

/datum/uplink_item/stealthy_weapons/edagger
	name = "Energy Dagger"
	desc = "A dagger made of energy that looks and functions as a pen when off."
	reference = "EDP"
	item = /obj/item/weapon/pen/edagger
	cost = 2

/datum/uplink_item/stealthy_weapons/sleepy_pen
	name = "Sleepy Pen"
	desc = "A syringe disguised as a functional pen. It's filled with a potent anaesthetic. \ The pen holds two doses of the mixture. The pen can be refilled."
	reference = "SP"
	item = /obj/item/weapon/pen/sleepy
	cost = 8
	excludefrom = list(/datum/game_mode/nuclear)

/datum/uplink_item/stealthy_weapons/foampistol
	name = "Toy Gun (with Stun Darts)"
	desc = "An innocent looking toy pistol designed to fire foam darts. Comes loaded with riot grade darts, to incapacitate a target."
	reference = "FSPI"
	item = /obj/item/weapon/gun/projectile/automatic/toy/pistol/riot
	cost = 3
	surplus = 10

/datum/uplink_item/stealthy_weapons/soap
	name = "Syndicate Soap"
	desc = "A sinister-looking surfactant used to clean blood stains to hide murders and prevent DNA analysis. You can also drop it underfoot to slip people."
	reference = "SOAP"
	item = /obj/item/weapon/soap/syndie
	cost = 1
	surplus = 50

/datum/uplink_item/stealthy_weapons/dart_pistol
	name = "Dart Pistol"
	desc = "A miniaturized version of a normal syringe gun. It is very quiet when fired and can fit into any space a small item can."
	reference = "DART"
	item = /obj/item/weapon/gun/syringe/syndicate
	cost = 4
	surplus = 50

/datum/uplink_item/stealthy_weapons/detomatix
	name = "Detomatix PDA Cartridge"
	desc = "When inserted into a personal digital assistant, this cartridge gives you five opportunities to detonate PDAs of crewmembers who have their message feature enabled. The concussive effect from the explosion will knock the recipient out for a short period, and deafen them for longer. It has a chance to detonate your PDA."
	reference = "DEPC"
	item = /obj/item/weapon/cartridge/syndicate
	cost = 6

/datum/uplink_item/stealthy_weapons/silencer
	name = "Universal Suppressor"
	desc = "Fitted for use on any small caliber weapon with a threaded barrel, this suppressor will silence the shots of the weapon for increased stealth and superior ambushing capability."
	reference = "US"
	item = /obj/item/weapon/suppressor
	cost = 1
	surplus = 10

/datum/uplink_item/stealthy_weapons/pizza_bomb
	name = "Pizza Bomb"
	desc = "A pizza box with a bomb taped inside of it. The timer needs to be set by opening the box; afterwards, opening the box again will trigger the detonation."
	reference = "PB"
	item = /obj/item/device/pizza_bomb
	cost = 5
	surplus = 8

/datum/uplink_item/stealthy_weapons/dehy_carp
	name = "Dehydrated Space Carp"
	desc = "Just add water to make your very own hostile to everything space carp. It looks just like a plushie. The first person to squeeze it will be registered as its owner, who it will not attack. If no owner is registered, it'll just attack everyone."
	reference = "DSC"
	item = /obj/item/toy/carpplushie/dehy_carp
	cost = 3

/datum/uplink_item/stealthy_weapons/chamsechud
	name = "Chameleon Security HUD"
	desc = "A stolen Nanotrasen Security HUD with Syndicate chameleon technology implemented into it. Similarly to a chameleon jumpsuit, the HUD can be morphed into various other eyewear, while retaining the HUD qualities when worn."
	reference = "CHHUD"
	item = /obj/item/clothing/glasses/hud/security/chameleon
	cost = 2
	
/datum/uplink_item/stealthy_weapons/chameleonflag
	name = "Chameleon Flag"
	desc = "A flag that can be disguised as any other known flag. There is a heat sensitive bomb loaded into the pole that will be detonated if the flag is lit on fire."
	reference = "CHFLAG"
	item = /obj/item/flag/chameleon
	cost = 7

// STEALTHY TOOLS

/datum/uplink_item/stealthy_tools
	category = "Stealth and Camouflage Items"

/datum/uplink_item/stealthy_tools/chameleon_jumpsuit
	name = "Chameleon Jumpsuit"
	desc = "A jumpsuit used to imitate the uniforms of Nanotrasen crewmembers."
	reference = "CJ"
	item = /obj/item/clothing/under/chameleon
	cost = 2

/datum/uplink_item/stealthy_tools/chameleon_stamp
	name = "Chameleon Stamp"
	desc = "A stamp that can be activated to imitate an official Nanotrasen Stamp. The disguised stamp will work exactly like the real stamp and will allow you to forge false documents to gain access or equipment; \
	it can also be used in a washing machine to forge clothing."
	reference = "CHST"
	item = /obj/item/weapon/stamp/chameleon
	cost = 1
	surplus = 35

/datum/uplink_item/stealthy_tools/syndigaloshes
	name = "No-Slip Syndicate Shoes"
	desc = "These allow you to run on wet floors. They do not work on lubricated surfaces."
	reference = "NSSS"
	item = /obj/item/clothing/shoes/syndigaloshes
	cost = 2
	excludefrom = list(/datum/game_mode/nuclear)

/datum/uplink_item/stealthy_tools/syndigaloshes/nuke
	name = "Tactical No-Slip Brown Shoes"
	desc = "These allow you to run on wet floors. They do not work on lubricated surfaces, and the maker swears they're better than normal ones, somehow."
	reference = "NNSSS"
	cost = 4 //but they aren't
	gamemodes = list(/datum/game_mode/nuclear)

/datum/uplink_item/stealthy_tools/agent_card
	name = "Agent ID Card"
	desc = "Agent cards prevent artificial intelligences from tracking the wearer, and can copy access from other identification cards. The access is cumulative, so scanning one card does not erase the access gained from another."
	reference = "AIDC"
	item = /obj/item/weapon/card/id/syndicate
	cost = 2

/datum/uplink_item/stealthy_tools/voice_changer
	name = "Voice Changer"
	desc = "A conspicuous gas mask that mimics the voice named on your identification card. When no identification is worn, the mask will render your voice unrecognisable."
	reference = "VC"
	item = /obj/item/clothing/mask/gas/voice
	cost = 3

/datum/uplink_item/stealthy_tools/chameleon_proj
	name = "Chameleon-Projector"
	desc = "Projects an image across a user, disguising them as an object scanned with it, as long as they don't move the projector from their hand. The disguised user cannot run and projectiles pass over them."
	reference = "CP"
	item = /obj/item/device/chameleon
	cost = 7

/datum/uplink_item/stealthy_tools/camera_bug
	name = "Camera Bug"
	desc = "Enables you to view all cameras on the network and track a target. Bugging cameras allows you to disable them remotely."
	reference = "CB"
	item = /obj/item/device/camera_bug
	cost = 1
	surplus = 90

/datum/uplink_item/stealthy_tools/dnascrambler
	name = "DNA Scrambler"
	desc = "A syringe with one injection that randomizes appearance and name upon use. A cheaper but less versatile alternative to an agent card and voice changer."
	reference = "DNAS"
	item = /obj/item/weapon/dnascrambler
	cost = 4

/datum/uplink_item/stealthy_tools/smugglersatchel
	name = "Smuggler's Satchel"
	desc = "This satchel is thin enough to be hidden in the gap between plating and tiling, great for stashing your stolen goods. Comes with a crowbar and a floor tile inside."
	reference = "SMSA"
	item = /obj/item/weapon/storage/backpack/satchel_flat
	cost = 2
	surplus = 30

/datum/uplink_item/stealthy_tools/emplight
	name = "EMP Flashlight"
	desc = "A small, self-charging, short-ranged EMP device disguised as a flashlight. \
		Useful for disrupting headsets, cameras, and borgs during stealth operations."
	reference = "EMPL"
	item = /obj/item/device/flashlight/emp
	cost = 2
	surplus = 30

// DEVICE AND TOOLS

/datum/uplink_item/device_tools
	category = "Devices and Tools"
	abstract = 1

/datum/uplink_item/device_tools/emag
	name = "Cryptographic Sequencer"
	desc = "The cryptographic sequencer, also known as an emag, is a small card that unlocks hidden functions in electronic devices, subverts intended functions and characteristically breaks security mechanisms."
	reference = "EMAG"
	item = /obj/item/weapon/card/emag
	cost = 6

/datum/uplink_item/device_tools/toolbox
	name = "Fully Loaded Toolbox"
	desc = "The syndicate toolbox is a suspicious black and red. Aside from tools, it comes with insulated gloves and a multitool."
	reference = "FLTB"
	item = /obj/item/weapon/storage/toolbox/syndicate
	cost = 1

/datum/uplink_item/device_tools/surgerybag
	name = "Syndicate Surgery Duffelbag"
	desc = "The Syndicate surgery duffelbag is a toolkit containing all surgery tools, a straitjacket, and a muzzle."
	reference = "SSDB"
	item = /obj/item/weapon/storage/backpack/duffel/syndie/surgery
	cost = 4

/datum/uplink_item/device_tools/military_belt
	name = "Military Belt"
	desc = "A robust seven-slot red belt made for carrying a broad variety of weapons, ammunition and explosives"
	reference = "SBM"
	item = /obj/item/weapon/storage/belt/military
	cost = 3
	excludefrom = list(/datum/game_mode/nuclear)

/datum/uplink_item/device_tools/medkit
	name = "Syndicate Combat Medic Kit"
	desc = "The syndicate medkit is a suspicious black and red. Included is a combat stimulant injector for rapid healing, a medical HUD for quick identification of injured comrades, \
	and other medical supplies helpful for a medical field operative."
	reference = "SCMK"
	item = /obj/item/weapon/storage/firstaid/tactical
	cost = 9
	gamemodes = list(/datum/game_mode/nuclear)

//Space Suits and Hardsuits
/datum/uplink_item/suits
	category = "Space Suits and Hardsuits"
	surplus = 40

/datum/uplink_item/suits/space_suit
	name = "Syndicate Space Suit"
	desc = "This red and black syndicate space suit is less encumbering than Nanotrasen variants, \
			fits inside bags, and has a weapon slot. Nanotrasen crewmembers are trained to report red space suit \
			sightings, however."
	reference = "SS"
	item = /obj/item/weapon/storage/box/syndie_kit/space
	cost = 4

/datum/uplink_item/suits/hardsuit
	name = "Syndicate Hardsuit"
	desc = "The feared suit of a syndicate nuclear agent. Features slightly better armoring and a built in jetpack \
			that runs off standard atmospheric tanks. When the built in helmet is deployed your identity will be \
			protected, even in death, as the suit cannot be removed by outside forces. Toggling the suit in and out of \
			combat mode will allow you all the mobility of a loose fitting uniform without sacrificing armoring. \
			Additionally the suit is collapsible, making it small enough to fit within a backpack. \
			Nanotrasen crew who spot these suits are known to panic."
	reference = "BRHS"
	item = /obj/item/weapon/storage/box/syndie_kit/hardsuit
	cost = 8

/datum/uplink_item/suits/hardsuit/elite
	name = "Elite Syndicate Hardsuit"
	desc = "An advanced hardsuit with superior armor and mobility to the standard Syndicate Hardsuit."
	item = /obj/item/weapon/storage/box/syndie_kit/elite_hardsuit
	cost = 8
	reference = "ESHS"
	gamemodes = list(/datum/game_mode/nuclear)

/datum/uplink_item/suits/hardsuit/shielded
	name = "Shielded Hardsuit"
	desc = "An advanced hardsuit with built in energy shielding. The shields will rapidly recharge when not under fire."
	item = /obj/item/weapon/storage/box/syndie_kit/shielded_hardsuit
	cost = 30
	reference = "SHS"
	gamemodes = list(/datum/game_mode/nuclear)


/datum/uplink_item/device_tools/thermal
	name = "Thermal Imaging Glasses"
	desc = "These glasses are thermals disguised as engineers' optical meson scanners. They allow you to see organisms through walls by capturing the upper portion of the infra-red light spectrum, emitted as heat and light by objects. Hotter objects, such as warm bodies, cybernetic organisms and artificial intelligence cores emit more of this light than cooler objects like walls and airlocks."
	reference = "THIG"
	item = /obj/item/clothing/glasses/thermal/syndi
	cost = 6

/datum/uplink_item/device_tools/binary
	name = "Binary Translator Key"
	desc = "A key, that when inserted into a radio headset, allows you to listen to and talk with artificial intelligences and cybernetic organisms in binary."
	reference = "BITK"
	item = /obj/item/device/encryptionkey/binary
	cost = 5
	surplus = 75

/datum/uplink_item/device_tools/cipherkey
	name = "Syndicate Encryption Key"
	desc = "A key, that when inserted into a radio headset, allows you to listen to all station department channels as well as talk on an encrypted Syndicate channel."
	reference = "SEK"
	item = /obj/item/device/encryptionkey/syndicate
	cost = 2 //Nowhere near as useful as the Binary Key!
	surplus = 75

/datum/uplink_item/device_tools/hacked_module
	name = "Hacked AI Upload Module"
	desc = "When used with an upload console, this module allows you to upload priority laws to an artificial intelligence. Be careful with their wording, as artificial intelligences may look for loopholes to exploit."
	reference = "HAI"
	item = /obj/item/weapon/aiModule/syndicate
	cost = 14

/datum/uplink_item/device_tools/magboots
	name = "Blood-Red Magboots"
	desc = "A pair of magnetic boots with a Syndicate paintjob that assist with freer movement in space or on-station during gravitational generator failures. \
	These reverse-engineered knockoffs of Nanotrasen's 'Advanced Magboots' slow you down in simulated-gravity environments much like the standard issue variety."
	reference = "BRMB"
	item = /obj/item/clothing/shoes/magboots/syndie
	cost = 3
	gamemodes = list(/datum/game_mode/nuclear)

/datum/uplink_item/device_tools/plastic_explosives
	name = "Composition C-4"
	desc = "C-4 is plastic explosive of the common variety Composition C. You can use it to breach walls or connect an assembly to its wiring to make it remotely detonable. It has a modifiable timer with a minimum setting of 10 seconds."
	reference = "C4"
	item = /obj/item/weapon/grenade/plastic/c4
	cost = 1

/datum/uplink_item/device_tools/breaching_charge
	name = "Composition X-4"
	desc = "X-4 is a shaped charge designed to be safe to the user while causing maximum damage to the occupants of the room beach breached. It has a modifiable timer with a minimum setting of 10 seconds."
	reference = "X4"
	item = /obj/item/weapon/grenade/plastic/x4
	cost = 2
	gamemodes = list(/datum/game_mode/nuclear)

/datum/uplink_item/device_tools/powersink
	name = "Power Sink"
	desc = "When screwed to wiring attached to an electric grid, then activated, this large device places excessive load on the grid, causing a stationwide blackout. The sink cannot be carried because of its excessive size. Ordering this sends you a small beacon that will teleport the power sink to your location on activation."
	reference = "PS"
	item = /obj/item/device/powersink
	cost = 10

/datum/uplink_item/device_tools/singularity_beacon
	name = "Power Beacon"
	desc = "When screwed to wiring attached to an electric grid and activated, this large device pulls any \
			active gravitational singularities or tesla balls towards it. This will not work when the engine is still \
			in containment. Because of its size, it cannot be carried. Ordering this \
			sends you a small beacon that will teleport the larger beacon to your location upon activation."
	reference = "SNGB"
	item = /obj/item/device/radio/beacon/syndicate
	cost = 14

/datum/uplink_item/device_tools/syndicate_bomb
	name = "Syndicate Bomb"
	desc = "The Syndicate Bomb has an adjustable timer with a minimum setting of 60 seconds. Ordering the bomb sends you a small beacon, which will teleport the explosive to your location when you activate it. \
	You can wrench the bomb down to prevent removal. The crew may attempt to defuse the bomb."
	reference = "SB"
	item = /obj/item/device/radio/beacon/syndicate/bomb
	cost = 11

/datum/uplink_item/device_tools/syndicate_detonator
	name = "Syndicate Detonator"
	desc = "The Syndicate Detonator is a companion device to the Syndicate Bomb. Simply press the included button and an encrypted radio frequency will instruct all live syndicate bombs to detonate. \
	Useful for when speed matters or you wish to synchronize multiple bomb blasts. Be sure to stand clear of the blast radius before using the detonator."
	reference = "SD"
	item = /obj/item/device/syndicatedetonator
	cost = 3
	gamemodes = list(/datum/game_mode/nuclear)

/datum/uplink_item/device_tools/advpinpointer
	name = "Advanced Pinpointer"
	desc = "A pinpointer that tracks any specified coordinates, DNA string, high value item or the nuclear authentication disk."
	reference = "ADVP"
	item = /obj/item/weapon/pinpointer/advpinpointer
	cost = 4

/datum/uplink_item/device_tools/ai_detector
	name = "Artificial Intelligence Detector" // changed name in case newfriends thought it detected disguised ai's
	desc = "A functional multitool that turns red when it detects an artificial intelligence watching it or its holder. Knowing when an artificial intelligence is watching you is useful for knowing when to maintain cover."
	reference = "AID"
	item = /obj/item/device/multitool/ai_detect
	cost = 1

/datum/uplink_item/device_tools/telecrystal
	name = "Raw Telecrystal"
	desc = "Telecrystal in its rawest and purest form; can be utilized on active uplinks to increase their telecrystal count."
	reference = "RTC"
	item = /obj/item/stack/telecrystal
	cost = 1
	surplus = 0

/datum/uplink_item/device_tools/teleporter
	name = "Teleporter Circuit Board"
	desc = "A printed circuit board that completes the teleporter onboard the mothership. Advise you test fire the teleporter before entering it, as malfunctions can occur."
	item = /obj/item/weapon/circuitboard/teleporter
	reference = "TP"
	cost = 40
	gamemodes = list(/datum/game_mode/nuclear)
	surplus = 0

/datum/uplink_item/device_tools/assault_pod
	name = "Assault Pod Targetting Device"
	desc = "Use to select the landing zone of your assault pod."
	item = /obj/item/device/assault_pod
	reference = "APT"
	cost = 30
	gamemodes = list(/datum/game_mode/nuclear)
	surplus = 0

/datum/uplink_item/device_tools/shield
	name = "Energy Shield"
	desc = "An incredibly useful personal shield projector, capable of reflecting energy projectiles and defending against other attacks."
	item = /obj/item/weapon/shield/energy
	reference = "ESD"
	cost = 16
	gamemodes = list(/datum/game_mode/nuclear)
	surplus = 20

/datum/uplink_item/device_tools/medgun
	name = "Medbeam Gun"
	desc = "Medical Beam Gun, useful in prolonged firefights."
	item = /obj/item/weapon/gun/medbeam
	reference = "MBG"
	cost = 15
	gamemodes = list(/datum/game_mode/nuclear)


// IMPLANTS

/datum/uplink_item/implants
	category = "Implants"

/datum/uplink_item/implants/freedom
	name = "Freedom Implant"
	desc = "An implant injected into the body and later activated using a bodily gesture to attempt to slip restraints."
	reference = "FI"
	item = /obj/item/weapon/implanter/freedom
	cost = 5

/datum/uplink_item/implants/uplink
	name = "Uplink Implant"
	desc = "An implant injected into the body, and later activated using a bodily gesture to open an uplink with 10 telecrystals. The ability for an agent to open an uplink after their possessions have been stripped from them makes this implant excellent for escaping confinement."
	reference = "UI"
	item = /obj/item/weapon/implanter/uplink
	cost = 14
	surplus = 0

/datum/uplink_item/implants/storage
	name = "Storage Implant"
	desc = "An implant injected into the body, and later activated at the user's will. It will open a small subspace pocket capable of storing two items."
	reference = "ESI"
	item = /obj/item/weapon/implanter/storage
	cost = 8

/datum/uplink_item/implants/mindslave
	name = "Mindslave Implant"
	desc = "A box containing an implanter filled with a mindslave implant that when injected into another person makes them loyal to you and your cause, unless of course they're already implanted by someone else. Loyalty ends if the implant is no longer in their system."
	reference = "MI"
	item = /obj/item/weapon/implanter/traitor
	cost = 10

/datum/uplink_item/implants/adrenal
	name = "Adrenal Implant"
	desc = "An implant injected into the body, and later activated using a bodily gesture to inject a chemical cocktail, which has a mild healing effect along with removing all stuns and increasing his speed."
	reference = "AI"
	item = /obj/item/weapon/implanter/adrenalin
	cost = 8

/datum/uplink_item/implants/microbomb
	name = "Microbomb Implant"
	desc = "An implant injected into the body, and later activated either manually or automatically upon death. The more implants inside of you, the higher the explosive power. \
	This will permanently destroy your body, however."
	reference = "MBI"
	item = /obj/item/weapon/implanter/explosive
	cost = 2
	gamemodes = list(/datum/game_mode/nuclear)

// Cybernetics
/datum/uplink_item/cyber_implants
	category = "Cybernetic Implants"
	surplus = 0
	gamemodes = list(/datum/game_mode/nuclear)

/datum/uplink_item/cyber_implants/spawn_item(turf/loc, obj/item/device/uplink/U)
	if(item)
		if(findtext(item, /obj/item/organ/internal/cyberimp))
			return new /obj/item/weapon/storage/box/cyber_implants(loc, item)
		else
			return ..()

/datum/uplink_item/cyber_implants/thermals
	name = "Thermal Vision Implant"
	desc = "These cybernetic eyes will give you thermal vision. Comes with an automated implanting tool."
	reference = "CIT"
	item = /obj/item/organ/internal/cyberimp/eyes/thermals
	cost = 8

/datum/uplink_item/cyber_implants/xray
	name = "X-Ray Vision Implant"
	desc = "These cybernetic eyes will give you X-ray vision. Comes with an automated implanting tool."
	reference = "CIX"
	item = /obj/item/organ/internal/cyberimp/eyes/xray
	cost = 10

/datum/uplink_item/cyber_implants/antistun
	name = "CNS Rebooter Implant"
	desc = "This implant will help you get back up on your feet faster after being stunned. \
			Comes with an automated implanting tool."
	reference = "CIAS"
	item = /obj/item/organ/internal/cyberimp/brain/anti_stun
	cost = 12

/datum/uplink_item/cyber_implants/reviver
	name = "Reviver Implant"
	desc = "This implant will attempt to revive you if you lose consciousness. Comes with an automated implanting tool."
	reference = "CIR"
	item = /obj/item/organ/internal/cyberimp/chest/reviver
	cost = 8

/datum/uplink_item/cyber_implants/bundle
	name = "Cybernetic Implants Bundle"
	desc = "A random selection of cybernetic implants. Guaranteed 5 high quality implants. \
			Comes with an automated implanting tool."
	reference = "CIB"
	item = /obj/item/weapon/storage/box/cyber_implants/bundle
	cost = 40

// POINTLESS BADASSERY

/datum/uplink_item/badass
	category = "(Pointless) Badassery"
	surplus = 0

/datum/uplink_item/badass/syndiecigs
	name = "Syndicate Smokes"
	desc = "Strong flavor, dense smoke, infused with omnizine."
	reference = "SYSM"
	item = /obj/item/weapon/storage/fancy/cigarettes/cigpack_syndicate
	cost = 2

/datum/uplink_item/badass/bundle
	name = "Syndicate Bundle"
	desc = "Syndicate Bundles are specialised groups of items that arrive in a plain box. These items are collectively worth more than 20 telecrystals, but you do not know which specialisation you will receive."
	reference = "SYB"
	item = /obj/item/weapon/storage/box/syndicate
	cost = 20
	excludefrom = list(/datum/game_mode/nuclear)

/datum/uplink_item/badass/syndiecards
	name = "Syndicate Playing Cards"
	desc = "A special deck of space-grade playing cards with a mono-molecular edge and metal reinforcement, making them lethal weapons both when wielded as a blade and when thrown. \
	You can also play card games with them."
	reference = "SPC"
	item = /obj/item/toy/cards/deck/syndicate
	cost = 1
	excludefrom = list(/datum/game_mode/nuclear)
	surplus = 40

/datum/uplink_item/badass/syndiecash
	name = "Syndicate Briefcase Full of Cash"
	desc = "A secure briefcase containing 5000 space credits. Useful for bribing personnel, or purchasing goods and services at lucrative prices. \
	The briefcase also feels a little heavier to hold; it has been manufactured to pack a little bit more of a punch if your client needs some convincing."
	reference = "CASH"
	item = /obj/item/weapon/storage/secure/briefcase/syndie
	cost = 1

/datum/uplink_item/badass/balloon
	name = "For showing that you are The Boss"
	desc = "A useless red balloon with the syndicate logo on it, which can blow the deepest of covers."
	reference = "BABA"
	item = /obj/item/toy/syndicateballoon
	cost = 20

/datum/uplink_item/implants/macrobomb
	name = "Macrobomb Implant"
	desc = "An implant injected into the body, and later activated either manually or automatically upon death. Upon death, releases a massive explosion that will wipe out everything nearby."
	reference = "HAB"
	item = /obj/item/weapon/implanter/explosive_macro
	cost = 20
	gamemodes = list(/datum/game_mode/nuclear)

/*/datum/uplink_item/badass/random
	name = "Random Item"
	desc = "Picking this choice will send you a random item from the list. Useful for when you cannot think of a strategy to finish your objectives with."
	reference = "RAIT"
	item = /obj/item/weapon/storage/box/syndicate
	cost = 0

/datum/uplink_item/badass/random/spawn_item(var/turf/loc, var/obj/item/device/uplink/U)

	var/list/buyable_items = get_uplink_items()
	var/list/possible_items = list()

	for(var/category in buyable_items)
		for(var/datum/uplink_item/I in buyable_items[category])
			if(I == src)
				continue
			if(I.cost > U.uses)
				continue
			possible_items += I

	if(possible_items.len)
		var/datum/uplink_item/I = pick(possible_items)
		U.uses -= max(0, I.cost)
		feedback_add_details("traitor_uplink_items_bought","RN")
		return new I.item(loc) */

/datum/uplink_item/badass/surplus_crate
	name = "Syndicate Surplus Crate"
	desc = "A crate containing 50 telecrystals worth of random syndicate leftovers."
	reference = "SYSC"
	cost = 20
	item = /obj/item/weapon/storage/box/syndicate
	excludefrom = list(/datum/game_mode/nuclear)

/datum/uplink_item/badass/surplus_crate/spawn_item(turf/loc, obj/item/device/uplink/U)
	var/obj/structure/closet/crate/C = new(loc)
	var/list/temp_uplink_list = get_uplink_items()
	var/list/buyable_items = list()
	for(var/category in temp_uplink_list)
		buyable_items += temp_uplink_list[category]
	var/list/bought_items = list()
	U.uses -= cost
	U.used_TC = 20
	var/remaining_TC = 50

	var/datum/uplink_item/I
	while(remaining_TC)
		I = pick(buyable_items)
		if(!I.surplus)
			continue
		if(I.cost > remaining_TC)
			continue
		if((I.item in bought_items) && prob(33)) //To prevent people from being flooded with the same thing over and over again.
			continue
		bought_items += I.item
		remaining_TC -= I.cost

	U.purchase_log += "<BIG>[bicon(C)]</BIG>"
	for(var/item in bought_items)
		new item(C)
		U.purchase_log += "<BIG>[bicon(item)]</BIG>"

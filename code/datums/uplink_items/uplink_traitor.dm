// TRAITOR ONLY GEAR

// JOB SPECIFIC GEAR

/datum/uplink_item/jobspecific
	category = "Job Specific Tools"
	cant_discount = TRUE
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST) // Stops the job specific category appearing for nukies

//Clown
/datum/uplink_item/jobspecific/clowngrenade
	name = "Banana Grenade"
	desc = "A grenade that explodes into HONK! brand banana peels that are genetically modified to be extra slippery and extrude caustic acid when stepped on."
	reference = "BG"
	item = /obj/item/grenade/clown_grenade
	cost = 15
	job = list("Clown")

/datum/uplink_item/jobspecific/clownslippers
	name = "Clown Acrobatic Shoes"
	desc = "A pair of modified clown shoes fitted with a built-in propulsion system that allows the user to perform a short slip below anyone. Turning on the waddle dampeners removes the slowdown on the shoes."
	reference = "CAS"
	item = /obj/item/clothing/shoes/clown_shoes/slippers
	cost = 15
	surplus = 75
	job = list("Clown")

/datum/uplink_item/jobspecific/cmag
	name = "Jestographic Sequencer"
	desc = "The jestographic sequencer, also known as a cmag, is a small card that inverts the access on any door it's used on. Perfect for locking command out of their own departments. Honk!"
	reference = "CMG"
	item = /obj/item/card/cmag
	cost = 20
	surplus = 75
	job = list("Clown")

/datum/uplink_item/jobspecific/trick_revolver
	name = "Trick Revolver"
	desc = "A revolver that will fire backwards and kill whoever attempts to use it. Perfect for those pesky vigilante or just a good laugh."
	reference = "CTR"
	item = /obj/item/storage/box/syndie_kit/fake_revolver
	cost = 5
	job = list("Clown")

/datum/uplink_item/jobspecific/trick_grenade
	name = "Trick Grenade"
	desc = "Syndicate Minibomb with glue ejectors that will stick it to the user's hands on activation."
	reference = "CGN"
	item = /obj/item/storage/box/syndie_kit/fake_minibomb
	cost = 5
	job = list("Clown")

//mime
/datum/uplink_item/jobspecific/caneshotgun
	name = "Cane Shotgun and Assassination Shells"
	desc = "A specialised, one shell shotgun with a built-in cloaking device to mimic a cane. The shotgun is capable of hiding it's contents and the pin alongside being suppressed. Comes boxed with 6 specialised shrapnel rounds laced with a silencing toxin and 1 preloaded in the shotgun's chamber."
	reference = "MCS"
	item = /obj/item/storage/box/syndie_kit/caneshotgun
	cost = 40
	job = list("Mime")

/datum/uplink_item/jobspecific/mimery
	name = "Guide to Advanced Mimery Series"
	desc = "Contains two manuals to teach you advanced Mime skills. You will be able to shoot lethal bullets that silence out of your fingers, and create large walls that can block an entire hallway!"
	reference = "AM"
	item = /obj/item/storage/box/syndie_kit/mimery
	cost = 50
	job = list("Mime")
	surplus = 0 // I feel this just isn't healthy to be in these crates.

/datum/uplink_item/jobspecific/combat_baking
	name = "Combat Bakery Kit"
	desc = "A kit of clandestine baked weapons. Contains a baguette which a skilled mime could use as a sword, \
		a pair of throwing croissants, and the recipe to make more on demand. Once the job is done, eat the evidence."
	reference = "CBK"
	item = /obj/item/storage/box/syndie_kit/combat_baking
	cost = 25 //A chef can get a knife that sharp easily, though it won't block. While you can get endless boomerang, they are less deadly than a stech, and slower / more predictable.
	job = list("Mime", "Chef")

/datum/uplink_item/jobspecific/pressure_mod
	name = "Kinetic Accelerator Pressure Mod"
	desc = "A modification kit which allows Kinetic Accelerators to do greatly increased damage while indoors. Occupies 35% mod capacity."
	reference = "KPM"
	item = /obj/item/borg/upgrade/modkit/indoors
	cost = 25 //you need two for full damage, so total of 50 for maximum damage
	job = list("Shaft Miner")
	surplus = 0 // Requires a KA to even be used.

//Chef
/datum/uplink_item/jobspecific/specialsauce
	name = "Chef Excellence's Special Sauce"
	desc = "A custom sauce made from the highly poisonous fly amanita mushrooms. Anyone who ingests it will take variable toxin damage depending on how long it has been in their system, with a higher dosage taking longer to metabolize."
	reference = "CESS"
	item = /obj/item/reagent_containers/food/condiment/syndisauce
	cost = 10
	job = list("Chef")
	surplus = 0 // Far too specific in its use.

/datum/uplink_item/jobspecific/meatcleaver
	name = "Meat Cleaver"
	desc = "A mean looking meat cleaver that does damage comparable to an Energy Sword but with the added benefit of chopping your victim into hunks of meat after they've died."
	reference = "MC"
	item = /obj/item/kitchen/knife/butcher/meatcleaver
	cost = 40
	job = list("Chef")

/datum/uplink_item/jobspecific/syndidonk
	name = "Syndicate Donk Pockets"
	desc = "A box of highly specialized Donk pockets with a number of regenerative and stimulating chemicals inside of them; the box comes equipped with a self-heating mechanism."
	reference = "SDP"
	item = /obj/item/storage/box/syndidonkpockets
	cost = 10
	job = list("Chef")

//Chaplain

/datum/uplink_item/jobspecific/missionary_kit
	name = "Missionary Starter Kit"
	desc = "A box containing a missionary staff, missionary robes, and bible. The robes and staff can be linked to allow you to convert victims at range for a short time to do your bidding. The bible is for bible stuff."
	reference = "MK"
	item = /obj/item/storage/box/syndie_kit/missionary_set
	cost = 75
	job = list("Chaplain")
	surplus = 0 // Controversial maybe, but with the ease of mindslaving with this item I'd prefer it stay chaplain specific.

/datum/uplink_item/jobspecific/artistic_toolbox
	name = "His Grace"
	desc = "An incredibly dangerous weapon recovered from a station overcome by the grey tide. Once activated, He will thirst for blood and must be used to kill to sate that thirst. \
	His Grace grants gradual regeneration and complete stun immunity to His wielder, but be wary: if He gets too hungry, He will become impossible to drop and eventually kill you if not fed. \
	However, if left alone for long enough, He will fall back to slumber. \
	To activate His Grace, simply unlatch Him."
	reference = "HG"
	item = /obj/item/his_grace
	cost = 100
	job = list("Chaplain")
	surplus = 0 //No lucky chances from the crate; if you get this, this is ALL you're getting
	hijack_only = TRUE //This is a murderbone weapon, as such, it should only be available in those scenarios.

//Janitor

/datum/uplink_item/jobspecific/cautionsign
	name = "Proximity Mine"
	desc = "An Anti-Personnel proximity mine cleverly disguised as a wet floor caution sign that is triggered by running past it, activate it to start the 15 second timer and activate again to disarm."
	reference = "PM"
	item = /obj/item/caution/proximity_sign
	cost = 10
	job = list("Janitor")

/datum/uplink_item/jobspecific/titaniumbroom
	name = "Titanium Push Broom"
	desc = "A push broom with a reinforced handle and a metal wire brush, perfect for giving yourself more work by beating up assistants. \
	When wielded, you will reflect projectiles, and hitting people will have different effects based on your intent."
	reference = "TPBR"
	item = /obj/item/push_broom/traitor
	cost = 60
	job = list("Janitor")
	surplus = 0 //no reflect memes

//Virology

/datum/uplink_item/jobspecific/viral_injector
	name = "Viral Injector"
	desc = "A modified hypospray disguised as a functional pipette. The pipette can infect victims with viruses upon injection."
	reference = "VI"
	item = /obj/item/reagent_containers/dropper/precision/viral_injector
	cost = 15
	job = list("Virologist")

/datum/uplink_item/jobspecific/cat_grenade
	name = "Feral Cat Delivery Grenade"
	desc = "The feral cat delivery grenade contains 5 dehydrated feral cats in a similar manner to dehydrated monkeys, which, upon detonation, will be rehydrated by a small reservoir of water contained within the grenade. These cats will then attack anything in sight."
	item = /obj/item/grenade/spawnergrenade/feral_cats
	reference = "CCLG"
	cost = 15
	job = list("Psychiatrist")//why? Becuase its funny that a person in charge of your mental wellbeing has a cat granade..

//Assistant

/datum/uplink_item/jobspecific/pickpocketgloves
	name = "Pickpocket's Gloves"
	desc = "A pair of sleek gloves to aid in pickpocketing. While wearing these, you can loot your target without them knowing. Pickpocketing puts the item directly into your hand."
	reference = "PPG"
	item = /obj/item/clothing/gloves/color/black/thief
	cost = 30
	job = list("Assistant")

//Bartender

/datum/uplink_item/jobspecific/drunkbullets
	name = "Boozey Shotgun Shells"
	desc = "A box containing 6 shotgun shells that simulate the effects of extreme drunkenness on the target, more effective for each type of alcohol in the target's system."
	reference = "BSS"
	item = /obj/item/storage/box/syndie_kit/boolets
	cost = 10
	job = list("Bartender")

//Barber

/datum/uplink_item/jobspecific/safety_scissors //Hue
	name = "Safety Scissors"
	desc = "A pair of scissors that are anything but what their name implies; can easily cut right into someone's throat."
	reference = "CTS"
	item = /obj/item/scissors/safety
	cost = 15
	job = list("Barber")

//Botanist

/datum/uplink_item/jobspecific/bee_briefcase
	name = "Briefcase Full of Bees"
	desc = "A seemingly innocent briefcase full of not-so-innocent Syndicate-bred bees. Inject the case with blood to train the bees to ignore the donor(s), WARNING: exotic blood types such as slime jelly do not work. It also wirelessly taps into station intercomms to broadcast a message of TERROR."
	reference = "BEE"
	item = /obj/item/bee_briefcase
	cost = 50
	job = list("Botanist")

//Engineer

/datum/uplink_item/jobspecific/powergloves
	name = "Power Gloves"
	desc = "Insulated gloves that can utilize the power of the station to deliver a short arc of electricity at a target. \
			Must be standing on a powered cable to use. \
			Activated by alt-clicking, or pressing the middle mouse button. Disarm intent will deal stamina damage and cause jittering, while harm intent will deal damage based on the power of the cable you're standing on."
	reference = "PG"
	item = /obj/item/clothing/gloves/color/yellow/power
	cost = 50
	job = list("Station Engineer", "Chief Engineer")

//RD

/datum/uplink_item/jobspecific/telegun
	name = "Telegun"
	desc = "An extremely high-tech energy gun that utilizes bluespace technology to teleport away living targets. Select the target beacon on the telegun itself; projectiles will send targets to the beacon locked onto. Can only send targets to beacons in-sector unless they are emagged!"
	reference = "TG"
	item = /obj/item/gun/energy/telegun
	cost = 50
	job = list("Research Director")

//Roboticist
/datum/uplink_item/jobspecific/syndiemmi
	name = "Syndicate MMI"
	desc = "A syndicate developed man-machine-interface which will mindslave any brain inserted into it, for as long as it's in. Cyborgs made with this MMI will be permanently slaved to you but otherwise function normally."
	reference = "SMMI"
	item = /obj/item/mmi/syndie
	cost = 10
	job = list("Roboticist")
	surplus = 0


//Librarian
/datum/uplink_item/jobspecific/etwenty
	name = "The E20"
	desc = "A seemingly innocent die, those who are not afraid to roll for attack will find it's effects quite explosive. Has a four second timer."
	reference = "ETW"
	item = /obj/item/dice/d20/e20
	cost = 15
	job = list("Librarian")

//Botanist
/datum/uplink_item/jobspecific/ambrosiacruciatus
	name = "Ambrosia Cruciatus Seeds"
	desc = "Part of the notorious Ambrosia family, this species is nearly indistinguishable from Ambrosia Vulgaris- but its' branches contain a revolting toxin. Eight units are enough to drive victims insane."
	reference = "BRO"
	item = /obj/item/seeds/ambrosia/cruciatus
	cost = 5
	job = list("Botanist")
	surplus = 0 // Even botanists would struggle to use this effectively, nevermind a coroner.

//Atmos Tech
/datum/uplink_item/jobspecific/contortionist
	name = "Contortionist's Jumpsuit"
	desc = "A highly flexible jumpsuit that will help you navigate the ventilation loops of the station internally. Comes with pockets and ID slot, but can't be used without stripping off most gear, including backpack, belt, helmet, and exosuit. Free hands are also necessary to crawl around inside."
	reference = "AIRJ"
	item = /obj/item/clothing/under/rank/engineering/atmospheric_technician/contortionist
	cost = 30
	job = list("Life Support Specialist")

/datum/uplink_item/jobspecific/energizedfireaxe
	name = "Energized Fire Axe"
	desc = "A fire axe with a massive energy charge built into it. Upon striking someone while charged it will throw them backwards while stunning them briefly, but will take some time to charge up again. It is also much sharper than a regular axe and can pierce light armor."
	reference = "EFA"
	item = /obj/item/fireaxe/energized
	cost = 40
	job = list("Life Support Specialist")

//Stimulants

/datum/uplink_item/jobspecific/stims
	name = "Stimulants"
	desc = "A highly illegal compound contained within a compact auto-injector; when injected it makes the user extremely resistant to incapacitation and greatly enhances the body's ability to repair itself."
	reference = "ST"
	item = /obj/item/reagent_containers/hypospray/autoinjector/stimulants
	cost = 40
	job = list("Scientist", "Research Director", "Geneticist", "Chief Medical Officer", "Medical Doctor", "Psychiatrist", "Chemist", "Paramedic", "Coroner", "Virologist")

// Genetics

/datum/uplink_item/jobspecific/magillitis_serum
	name = "Magillitis Serum Bio-chip"
	desc = "A single-use bio-chip which contains an experimental serum that causes rapid muscular growth in Hominidae. \
			Side-affects may include hypertrichosis, violent outbursts, and an unending affinity for bananas."
	reference = "MAG"
	item = /obj/item/implanter/gorilla_rampage
	cost = 25
	job = list("Research Director", "Geneticist")

// Paper contact poison pen

/datum/uplink_item/jobspecific/poison_pen
	name = "Poison Pen"
	desc = "Cutting edge of deadly writing implements technology, this gadget will infuse any piece of paper with various delayed poisons based on the selected color. Black ink is normal ink, red ink is a highly lethal poison, green ink causes radiation, blue ink will periodically shock the victim, and yellow ink will paralyze. The included gloves will protect you from your own poisons."
	reference = "PP"
	item = /obj/item/storage/box/syndie_kit/poisoner
	cost = 10
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	job = list("Head of Personnel", "Quartermaster", "Cargo Technician", "Librarian", "Coroner", "Psychiatrist", "Virologist")


//--------------------------//
// Species Restricted Gear //
//-------------------------//

/datum/uplink_item/species_restricted
	category = "Species Specific Gear"
	cant_discount = TRUE
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST) // Stops the job specific category appearing for nukies

//skrell
/datum/uplink_item/species_restricted/lovepen
	name = "Aggression Suppression Pen"
	desc = "A syringe disguised as a functional pen which is filled with a potent aggression supressing chemical. The pen holds four doses of the mixture and it cannot be refilled."
	reference = "LP"
	item = /obj/item/pen/sleepy/love
	cost = 20
	species = list("Skrell")

//Vox
/datum/uplink_item/species_restricted/spikethrower
	name = "Skipjack Spikethrower"
	desc = "An energy based weapon that launches high velocity plasma spikes. These spikes hit with enough force to knock the target down and leave a nasty wound."
	reference = "STG"
	item = /obj/item/gun/energy/spikethrower
	cost = 60
	species = list("Vox")
	surplus = 0

//IPC:
//Positonic supercharge implant: stims, 3 uses, IPC adrenals
/datum/uplink_item/species_restricted/supercharge_implant
	name = "Synthetic Supercharge Bio-chip"
	desc = "A bio-chip injected into the body, and later activated manually to inject a chemical cocktail, which has the effect of removing and reducing the time of all stuns and increasing movement speed. Can be activated up to 3 times."
	reference = "SSI"
	item = /obj/item/implanter/supercharge
	cost = 40
	species = list("Machine")
	surplus = 0


//plasmeme
/datum/uplink_item/species_restricted/fireproofing_nanites
	name = "Fireproofing Nanite Injector"
	desc = "A swarm of nanomachines that absorb excess amounts of heat, allowing the user to become practically fireproof."
	reference = "FPN"
	item = /obj/item/fireproofing_injector
	cost = 25
	species = list("Plasmaman")
	surplus = 0

//Human
/datum/uplink_item/species_restricted/holo_cigar
	name = "Holo-Cigar"
	desc = "A holo-cigar imported from the Sol system. The full effects of looking so badass aren't understood yet, but users show an increase in precision while dual-wielding firearms."
	reference = "SHC"
	item = /obj/item/clothing/mask/holo_cigar
	cost = 10
	species = list("Human")

// -------------------------------------
// ITEMS BLACKLISTED FROM NUCLEAR AGENTS
// -------------------------------------

/datum/uplink_item/dangerous/crossbow
	name = "Energy Crossbow"
	desc = "A miniature energy crossbow that is small enough both to fit into a pocket and to slip into a backpack unnoticed by observers. Fires bolts tipped with toxin, a poisonous substance that is the product of a living organism. Knocks enemies down for a short period of time. Recharges automatically."
	reference = "EC"
	item = /obj/item/gun/energy/kinetic_accelerator/crossbow
	cost = 60
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 50

/datum/uplink_item/dangerous/guardian
	name = "Holoparasites"
	reference = "HPA"
	desc = "Though capable of near sorcerous feats via use of hardlight holograms and nanomachines, they require an organic host as a home base and source of fuel. \
			The holoparasites are unable to incoporate themselves to changeling and vampire agents."
	item = /obj/item/storage/box/syndie_kit/guardian
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	cost = 60
	refund_path = /obj/item/guardiancreator/tech/choose
	refundable = TRUE
	surplus = 0 // This being refundable makes this a big no no in my mind.
	cant_discount = TRUE

/datum/uplink_item/stealthy_weapons/martialarts
	name = "Martial Arts Scroll"
	desc = "This scroll contains the secrets of an ancient martial arts technique. You will master unarmed combat, \
			deflecting ranged weapon fire when you are in a defensive stance (throw mode). Learning this art means you will also refuse to use dishonorable ranged weaponry. \
			Unable to be understood by vampire and changeling agents."
	reference = "SCS"
	item = /obj/item/sleeping_carp_scroll
	cost = 65
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	cant_discount = TRUE

/datum/uplink_item/stealthy_tools/traitor_belt
	name = "Traitor's Toolbelt"
	desc = "A robust seven-slot belt made for carrying a broad variety of weapons, ammunition and explosives. It's modelled after the standard NT toolbelt so as to avoid suspicion while wearing it."
	reference = "SBM"
	item = /obj/item/storage/belt/military/traitor
	cost = 10
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/stealthy_tools/frame
	name = "F.R.A.M.E. PDA Cartridge"
	desc = "When inserted into a personal digital assistant, this cartridge gives you five PDA viruses which \
			when used cause the targeted PDA to become a new uplink with zero TCs, and immediately become unlocked.  \
			You will receive the unlock code upon activating the virus, and the new uplink may be charged with \
			telecrystals normally."
	reference = "FRAME"
	item = /obj/item/cartridge/frame
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	cost = 20

/datum/uplink_item/stealthy_tools/voice_modulator
	name = "Chameleon Voice Modulator Mask"
	desc = "A syndicate tactical mask equipped with chameleon technology and a sound modulator for disguising your voice. \
			While the mask is active, your voice will sound unrecognizable to others."
	reference = "CVMM"
	item = /obj/item/clothing/mask/gas/voice_modulator/chameleon
	cost = 5
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/stealthy_tools/silicon_cham_suit
	name = "\"Big Brother\" Obfuscation Suit"
	desc = "A syndicate tactical suit equipped with the latest in anti-silicon technology and, allegedly, biological technology learned from the Changeling Hivemind. \
			While this suit is worn, you will be unable to be tracked or seen by on-Station AI."
	reference = "BBOS"
	item = /obj/item/clothing/under/syndicate/silicon_cham
	cost = 20
	excludefrom = list(UPLINK_TYPE_NUCLEAR)

/datum/uplink_item/stealthy_weapons/sleepy_pen
	name = "Sleepy Pen"
	desc = "A syringe disguised as a functional pen. It's filled with a potent anaesthetic. \ The pen holds two doses of the mixture. The pen can be refilled."
	reference = "SP"
	item = /obj/item/pen/sleepy
	cost = 40
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/stealthy_weapons/dart_pistol
	name = "Dart Pistol Kit"
	desc = "A miniaturized version of a normal syringe gun. It is very quiet when fired and can fit into any space a small item can. Comes with 3 syringes: a knockout poison, a silencing agent and a deadly neurotoxin."
	reference = "DART"
	item = /obj/item/storage/box/syndie_kit/dart_gun
	cost = 20
	surplus = 50
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/stealthy_weapons/combat_minus // Nukies get combat gloves plus instead
	name = "Experimental Krav Gloves"
	desc = "Experimental gloves with installed nanochips that teach you Krav Maga when worn, great as a cheap backup weapon. Warning, the nanochips will override any other fighting styles such as CQC. Do not look as fly as the Warden's"
	reference = "CGM"
	item = /obj/item/clothing/gloves/color/black/krav_maga
	cost = 50
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/device_tools/thermal_drill // Nukies get Diamond Tipped Thermal Safe Drill instead
	name = "Amplifying Thermal Safe Drill"
	desc = "A tungsten carbide thermal drill with magnetic clamps for the purpose of drilling hardened objects. Comes with built in security detection and nanite system, to keep you up if security comes a-knocking."
	reference = "DRL"
	item = /obj/item/thermal_drill/syndicate
	cost = 5
	surplus = 0 // I feel like its amazing for one objective and one objective only. Far too specific.
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/suits/modsuit
	name = "Syndicate MODsuit"
	desc = "The feared MODsuit of a syndicate nuclear agent. Features armor and a eva mode \
			for faster movement on station. Toggling the suit in and out of \
			combat mode will allow you all the mobility of a loose fitting uniform without sacrificing armoring. \
			Comes packaged with internals. \
			Nanotrasen crew who spot these suits are known to panic."
	reference = "BRHS"
	item = /obj/item/storage/box/syndie_kit/modsuit
	cost = 30
	surplus = 60 //I have upped the chance of modsuits from 40, as I do feel they are much more worthwhile with the base modsuit no longer being 8 tc, and the high armor values of the elite.
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/suits/modsuit_elite
	name = "Syndicate Elite MODsuit"
	desc = "An advanced MODsuit with superior armor to the standard Syndicate MODsuit. \
	Nanotrasen crew who spot these suits are known to *really* panic."
	reference = "MSE"
	item = /obj/item/storage/box/syndie_kit/modsuit/elite
	cost = 45 //45 to start, no holopara / ebow.
	surplus = 60
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/implants/uplink // Nukies get Nuclear Uplink Bio-chip instead
	name = "Uplink Bio-chip"
	desc = "A bio-chip injected into the body, and later activated manually to open an uplink with 50 telecrystals. The ability for an agent to open an uplink after their possessions have been stripped from them makes this implant excellent for escaping confinement."
	reference = "UI"
	item = /obj/item/implanter/uplink
	cost = 70
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 0
	cant_discount = TRUE

/datum/uplink_item/badass/syndiecards
	name = "Syndicate Playing Cards"
	desc = "A special deck of space-grade playing cards with a mono-molecular edge and metal reinforcement, making them lethal weapons both when wielded as a blade and when thrown. \
	You can also play card games with them."
	reference = "SPC"
	item = /obj/item/deck/cards/syndicate
	cost = 2
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 40

/datum/uplink_item/badass/plasticbag
	name = "Plastic Bag"
	desc = "A simple, plastic bag. Keep out of reach of small children, do not apply to head."
	reference = "PBAG"
	item = /obj/item/storage/bag/plasticbag
	cost = 1
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/bundles_TC/contractor
	name = "Syndicate Contractor Kit"
	desc = "A bundle granting you the privilege of taking on kidnapping contracts for credit and TC payouts that can add up to more than its initial cost."
	reference = "SCOK"
	cost = 100
	item = /obj/item/storage/box/syndie_kit/contractor
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/bundles_TC/contractor/spawn_item(turf/loc, obj/item/uplink/U)
	var/datum/mind/mind = usr.mind
	var/datum/antagonist/traitor/AT = mind.has_antag_datum(/datum/antagonist/traitor)
	if(LAZYACCESS(GLOB.contractors, mind))
		to_chat(usr, "<span class='warning'>Error: Contractor credentials detected for the current user. Unable to provide another Contractor kit.</span>")
		return
	else if(!AT)
		to_chat(usr, "<span class='warning'>Error: Embedded Syndicate credentials not found.</span>")
		return
	else if(ischangeling(usr) || mind.has_antag_datum(/datum/antagonist/vampire))
		to_chat(usr, "<span class='warning'>Error: Embedded Syndicate credentials contain an abnormal signature. Aborting.</span>")
		return

	var/obj/item/I = ..()
	// Init the hub
	var/obj/item/contractor_uplink/CU = locate(/obj/item/contractor_uplink) in I
	CU.hub = new(mind, CU)
	// Update their mind stuff
	LAZYSET(GLOB.contractors, mind, CU.hub)
	AT.add_antag_hud(mind.current)

	log_game("[key_name(usr)] became a Contractor")
	return I

/datum/uplink_item/bundles_TC/badass
	name = "Syndicate Bundle"
	desc = "Syndicate Bundles are specialised groups of items that arrive in a plain box. These items are collectively worth more than 100 telecrystals, but you do not know which specialisation you will receive."
	reference = "SYB"
	item = /obj/item/storage/box/syndie_kit/bundle
	cost = 100
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/bundles_TC/surplus_crate
	name = "Syndicate Surplus Crate"
	desc = "A crate containing 250 telecrystals worth of random syndicate leftovers."
	reference = "SYSC"
	cost = 100
	item = /obj/item/storage/box/syndie_kit/bundle
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	var/crate_value = 250
	uses_special_spawn = TRUE

/datum/uplink_item/bundles_TC/surplus_crate/super
	name = "Syndicate Super Surplus Crate"
	desc = "A crate containing 625 telecrystals worth of random syndicate leftovers."
	reference = "SYSS"
	cost = 200
	crate_value = 625

/datum/uplink_item/bundles_TC/surplus_crate/spawn_item(turf/loc, obj/item/uplink/U)
	if(..() != UPLINK_SPECIAL_SPAWNING)
		return FALSE

	new /obj/structure/closet/crate/surplus(loc, U, crate_value, cost)

// -----------------------------------
// PRICES OVERRIDEN FOR NUCLEAR AGENTS
// -----------------------------------

/datum/uplink_item/stealthy_weapons/cqc
	name = "CQC Manual"
	desc = "A manual that teaches a single user tactical Close-Quarters Combat before self-destructing. \
			Changes your unarmed damage to deal non-lethal stamina damage. \
			Does not restrict weapon usage, and can be used alongside Gloves of the North Star."
	reference = "CQC"
	item = /obj/item/CQC_manual
	cost = 50
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/explosives/syndicate_bomb
	name = "Syndicate Bomb"
	desc = "The Syndicate Bomb has an adjustable timer with a minimum setting of 90 seconds. Ordering the bomb sends you a small beacon, which will teleport the explosive to your location when you activate it. \
	You can wrench the bomb down to prevent removal. The crew may attempt to defuse the bomb."
	reference = "SB"
	item = /obj/item/radio/beacon/syndicate/bomb
	cost = 40
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 0
	cant_discount = TRUE
	hijack_only = TRUE

/datum/uplink_item/explosives/emp_bomb
	name = "EMP bomb"
	desc = "The EMP has an adjustable timer with a minimum setting of 90 seconds. Ordering the bomb sends you a small beacon, which will teleport the explosive to your location when you activate it. \
	You can wrench the bomb down to prevent removal. The crew may attempt to defuse the bomb. Will pulse 3 times."
	reference = "SBEMP"
	item = /obj/item/radio/beacon/syndicate/bomb/emp
	cost = 40
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 0
	cant_discount = TRUE

/datum/uplink_item/explosives/atmosfiregrenades
	name = "Plasma Fire Grenades"
	desc = "A box of two (2) grenades that cause large plasma fires. Can be used to deny access to a large area. Most useful if you have an atmospherics hardsuit."
	reference = "APG"
	item = /obj/item/storage/box/syndie_kit/atmosfiregrenades
	hijack_only = TRUE
	cost = 50
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 0
	cant_discount = TRUE

/datum/uplink_item/stealthy_tools/chameleon
	name = "Chameleon Kit"
	desc = "A set of items that contain chameleon technology allowing you to disguise as pretty much anything on the station, and more! \
			Due to budget cuts, the shoes don't provide protection against slipping. The set comes with a complementary chameleon stamp."
	reference = "CHAM"
	item = /obj/item/storage/box/syndie_kit/chameleon
	cost = 20
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/stealthy_tools/syndigaloshes
	name = "No-Slip Chameleon Shoes"
	desc = "These shoes will allow the wearer to run on wet floors and slippery objects without falling down. \
			They do not work on heavily lubricated surfaces."
	reference = "NSSS"
	item = /obj/item/clothing/shoes/chameleon/noslip
	cost = 10
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/explosives/detomatix
	name = "Detomatix PDA Cartridge"
	desc = "When inserted into a personal digital assistant, this cartridge gives you five opportunities to detonate PDAs of crewmembers who have their message feature enabled. The concussive effect from the explosion will knock the recipient out for a short period, and deafen them for longer. It has a chance to detonate your PDA."
	reference = "DEPC"
	item = /obj/item/cartridge/syndicate
	cost = 30
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

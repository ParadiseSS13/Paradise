/obj/structure/sign
	icon = 'icons/obj/decals.dmi'
	anchored = TRUE
	layer = NOT_HIGH_OBJ_LAYER
	max_integrity = 100
	armor = list(MELEE = 50, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 50, ACID = 50)
	flags_2 = RAD_PROTECT_CONTENTS_2 | RAD_NO_CONTAMINATE_2
	blocks_emissive = EMISSIVE_BLOCK_GENERIC
	var/does_emissive = FALSE
	var/removable = TRUE

/obj/structure/sign/Initialize(mapload)
	. = ..()
	if(does_emissive)
		update_icon()
		set_light(1, LIGHTING_MINIMUM_POWER)

/obj/structure/sign/update_overlays()
	. = ..()

	underlays.Cut()
	if(!does_emissive)
		return

	underlays += emissive_appearance(icon,"[icon_state]_lightmask")

/obj/structure/sign/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src.loc, 'sound/weapons/slash.ogg', 80, TRUE)
			else
				playsound(loc, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', 80, TRUE)

/obj/structure/sign/screwdriver_act(mob/user, obj/item/I)
	if(!removable)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	to_chat(user, "You unfasten the sign with [I].")
	var/obj/item/sign/S = new(src.loc)
	S.name = name
	S.desc = desc
	S.icon_state = icon_state
	//var/icon/I = icon('icons/obj/decals.dmi', icon_state)
	//S.icon = I.Scale(24, 24)
	S.sign_state = icon_state
	qdel(src)

/obj/item/sign
	name = "sign"
	desc = ""
	icon = 'icons/obj/decals.dmi'
	resistance_flags = FLAMMABLE
	var/sign_state = ""

/obj/item/sign/screwdriver_act(mob/living/user, obj/item/I)
	if(!isturf(user.loc)) // Why does this use user? This should just be loc.
		return
	. = TRUE // These return values gotta be true or we stab the sign
	var/direction = tgui_input_list(user, "Which direction will this sign be moved?", "Select direction,", list("North", "East", "South", "West", "Cancel"))
	if(direction == "Cancel" || QDELETED(src))
		return

	var/obj/structure/sign/S = new(get_turf(user))
	switch(direction)
		if("North")
			S.pixel_y = 32
		if("East")
			S.pixel_x = 32
		if("South")
			S.pixel_y = -32
		if("West")
			S.pixel_x = -32
		else
			return
	S.name = name
	S.desc = desc
	S.icon_state = sign_state
	to_chat(user, SPAN_NOTICE("You fasten [S] with your [I]."))
	qdel(src)

/obj/structure/sign/double
	removable = FALSE

/obj/structure/sign/double/map
	name = "station map"
	desc = "A framed picture of the station."
	max_integrity = 500

/obj/structure/sign/double/map/left
	icon_state = "map-left"

/obj/structure/sign/double/map/right
	icon_state = "map-right"

/obj/structure/sign/double/map/attack_hand(mob/user)
	if(user.client)
		user.client.webmap()

/obj/structure/sign/nanotrasen
	name = "\improper NANOTRASEN"
	desc = "A sign that indicates an NT turf."
	icon_state = "nanotrasen"

/obj/structure/sign/monkey_paint
	name = "Mr. Deempisi portrait"
	desc = "Under the painting a plaque reads: 'While the meat grinder may not have spared you, fear not. Not one part of you has gone to waste...You were delicious."
	icon_state = "monkey_painting"

/obj/structure/sign/lifestar
	name = "medbay"
	desc = "The Star of Life, a symbol of Medical Aid."
	icon_state = "lifestar"

/obj/structure/sign/greencross
	name = "medbay"
	desc = "The universal symbol of medical institutions across the Sector. You'll probably find help here."
	icon_state = "greencross"

/obj/structure/sign/goldenplaque
	name = "The Most Robust Men Award for Robustness"
	desc = "To be Robust is not an action or a way of life, but a mental state. Only those with the force of Will strong enough to act during a crisis, saving friend from foe, are truly Robust. Stay Robust my friends."
	icon_state = "goldenplaque"

/obj/structure/sign/goldenplaque/medical
	name = "The Hippocratic Award for Excellence in Medicine"
	desc = "A golden plaque commemorating excellence in medical care. God only knows how this ended up in this medbay."

/obj/structure/sign/kiddieplaque
	name = "AI developers plaque"
	desc = "Next to the extremely long list of names and job titles, there is a drawing of a little child. The child's eyes are crossed, and is drooling. Beneath the image, someone has scratched the word \"PACKETS\"."
	icon_state = "kiddieplaque"

/obj/structure/sign/kiddieplaque/remembrance
	name = "Remembrance Plaque"
	desc = "A plaque commemorating the fallen, may they rest in peace, forever asleep amongst the stars. Someone has drawn a picture of a crying badger at the bottom."

/obj/structure/sign/kiddieplaque/remembrance/mining
	desc = "A plaque commemorating the fallen, may they rest in peace, forever asleep amongst the ashes. Someone has drawn a picture of a crying badger at the bottom."

/obj/structure/sign/kiddieplaque/perfect_man
	name = "\improper 'Perfect Man' sign"
	desc = "A guide to the exhibit, explaining how recent developments in mindshield implant and cloning technologies by Nanotrasen Corporation have led to the development and the effective immortality of the 'perfect man', the loyal Nanotrasen Employee."

/obj/structure/sign/kiddieplaque/perfect_drone
	name = "\improper 'Perfect Drone' sign"
	desc = "A guide to the drone shell dispenser, detailing the constructive and destructive applications of modern repair drones, as well as the development of the incorruptible cyborg servants of tomorrow, available today."

/obj/structure/sign/atmosplaque
	name = "\improper ZAS Atmospherics Division plaque"
	desc = "This plaque commemorates the fall of the Atmos ZAS division. For all the charred, dizzy, and brittle men who have died in its horrible hands."
	icon_state = "atmosplaque"

/obj/structure/sign/kidanplaque
	name = "Kidan wall trophy"
	desc = "A dead and stuffed Diona nymph, mounted on a board."
	icon_state = "kidanplaque"

/obj/structure/sign/mech
	name = "mech painting"
	desc = "A painting of a mech."
	icon_state = "mech"

/obj/structure/sign/nuke
	name = "nuke painting"
	desc = "A painting of a nuke."
	icon_state = "nuke"

/obj/structure/sign/clown
	name = "clown painting"
	desc = "A painting of the clown and mime. Awwww."
	icon_state = "clown"

/obj/structure/sign/bobross
	name = "calming painting"
	desc = "We don't make mistakes, just happy little accidents."
	icon_state = "bob"

/obj/structure/sign/singulo
	name = "singulo painting"
	desc = "A mesmerizing painting of a singularity. It seems to suck you in..."
	icon_state = "singulo"

/obj/structure/sign/barber
	name = "barber shop sign"
	desc = "A spinning sign indicating a barbershop is near."
	icon_state = "barber"
	does_emissive = TRUE
	blocks_emissive = FALSE

/obj/structure/sign/chinese
	name = "chinese restaurant sign"
	desc = "A glowing dragon invites you in."
	icon_state = "chinese"
	does_emissive = TRUE
	blocks_emissive = FALSE

// MARK: Warning signs
/obj/structure/sign/biohazard
	name = "\improper BIOHAZARD"
	desc = "DANGER: BIOLOGICAL HAZARD. Biological PPE is REQUIRED past this point!"
	icon_state = "biohazard"

/obj/structure/sign/electricshock
	name = "\improper HIGH VOLTAGE"
	desc = "DANGER OF DEATH: HIGH VOLTAGE. Electrical PPE is REQUIRED before coming into contact with energized equipment!"
	icon_state = "shock"

/obj/structure/sign/fire
	name = "\improper DANGER: FIRE"
	desc = "A warning sign which reads 'DANGER: FIRE'."
	icon_state = "fire"
	resistance_flags = FIRE_PROOF

/obj/structure/sign/nosmoking
	name = "\improper NO SMOKING"
	desc = "Smoking is strictly prohibited in this area."
	icon_state = "nosmoking"
	resistance_flags = FLAMMABLE

/obj/structure/sign/nosmoking/alt
	icon_state = "nosmoking2"

/obj/structure/sign/radiation
	name = "\improper RADIOLOGICALLY SUPERVISED AREA"
	desc = "WARNING: Low level radiation may be present. Ensure your dose level remains below exposure limits."
	icon_state = "radiation"

/obj/structure/sign/radiation/rad_area
	name = "\improper RADIOLOGICALLY CONTROLLED AREA"
	desc = "DANGER: High levels of radiation may be present. Radiological PPE is REQUIRED beyond this point."

/obj/structure/sign/explosives
	name = "\improper HIGH EXPLOSIVES"
	desc = "DANGER: High explosives in this area!"
	icon_state = "explosives"

/obj/structure/sign/explosives/alt
	icon_state = "explosives2"

/obj/structure/sign/warning
	name = "\improper WARNING!"
	desc = "A generic warning sign, warning about some danger."
	icon_state = "warning"

/obj/structure/sign/securearea
	name = "\improper SECURE AREA"
	desc = "WARNING: High-Security area! Identification MUST be worn at all times."
	icon_state = "warning"

/obj/structure/sign/magboots
	name = "\improper MAG BOOTS"
	desc = "WARNING: Magboots are REQUIRED in this area!"
	icon_state = "magboots"

/obj/structure/sign/turbine
	name = "\improper TURBINE"
	desc = "DANGER OF DEATH: NO GUARD ON TURBINE INTAKE!"
	icon_state = "turbine"

/obj/structure/sign/vacuum
	name = "\improper HARD VACUUM AHEAD"
	desc = "DANGER OF DEATH: Breathing apparatus and pressure suit required beyond this point."
	icon_state = "space"

/obj/structure/sign/vacuum/external
	name = "\improper EXTERNAL AIRLOCK"
	layer = MOB_LAYER

/obj/structure/sign/wait
	name = "\improper WAIT FOR DECONTAMINATION!"
	desc = "A warning sign which reads: WAIT! <BR>\
	Before returning from the asteroid internal zone, please wait for the in-built scrubber system to remove all traces of the toxic atmosphere. This will take approximately 20 seconds.<BR> \
	Failure to adhere to this safety regulation will result in large plasmafires that will destroy the locking mechanisms."
	icon_state = "waitsign"
	resistance_flags = FIRE_PROOF

// MARK: Direction signs
/obj/structure/sign/directions
	name = "direction sign"

/obj/structure/sign/directions/bridge
	desc = "A direction sign, pointing out which way the Bridge is."
	icon_state = "direction_bridge"

/obj/structure/sign/directions/science
	desc = "A direction sign, pointing out which way the Research Division is."
	icon_state = "direction_sci"

/obj/structure/sign/directions/engineering
	desc = "A direction sign, pointing out which way the Engineering Department is."
	icon_state = "direction_eng"

/obj/structure/sign/directions/security
	desc = "A direction sign, pointing out which way the Security Department is."
	icon_state = "direction_sec"

/obj/structure/sign/directions/medical
	desc = "A direction sign, pointing out which way the Medical Bay is."
	icon_state = "direction_med"

/obj/structure/sign/directions/evac
	desc = "A direction sign, pointing out which way the Escape Shuttle Dock is."
	icon_state = "direction_evac"
	does_emissive = TRUE
	blocks_emissive = FALSE

/obj/structure/sign/directions/cargo
	desc = "A direction sign, pointing out which way the Supply Department is."
	icon_state = "direction_supply"

/obj/structure/sign/directions/service
	desc = "A direction sign, pointing out which way the Service Department is."
	icon_state = "direction_service"

// MARK: Public signs
/obj/structure/sign/public/arcade
	name = "\improper ARCADE"
	desc = "A place for fun and games! If you stay long enough, you might even get a bike!"
	icon_state = "arcade"

/obj/structure/sign/public/arrivals
	name = "\improper ARRIVALS"
	desc = "The arrivals shuttle will drop new arrivals off here, and other ships can dock in the nearby bays."
	icon_state = "arrivals"

/obj/structure/sign/public/arrivals/examine(mob/user)
	. = ..()
	. += SPAN_USERDANGER("During a crew transfer or emergency evacuation, you cannot leave via the arrivals shuttle. You must head to the departing shuttle or an escape pod.")

/obj/structure/sign/public/bath
	name = "\improper BATH OR SHOWER"
	desc = "Cleans the filth from your body."
	icon_state = "bath"

/obj/structure/sign/public/cryo
	name = "\improper CRYOGENIC DORMITORIES"
	desc = "You can safely enter cryosleep here and leave the current work shift."
	icon_state = "cryo"

/obj/structure/sign/public/deathsposal
	name = "\improper DISPOSAL LEADS TO SPACE"
	desc = "DANGER OF DEATH: This disposal unit will eject anything inside it into space."
	icon_state = "deathsposal"

/obj/structure/sign/public/doors
	name = "\improper BLAST DOORS"
	desc = "There's a set of remote-controlled blast doors here. Don't get crushed between them!"
	icon_state = "doors"

/obj/structure/sign/public/drop
	name = "\improper DROP PODS"
	desc = "Drop pods will be loaded and launched from this location. Give 'em hell!"
	icon_state = "drop"

/obj/structure/sign/public/evac	
	name = "\improper EVACUATION"
	desc = "The shuttle will dock here at the end of the shift or during an emergency evacuation."
	icon_state = "evac"
	does_emissive = TRUE
	blocks_emissive = FALSE

/obj/structure/sign/public/holy
	name = "\improper HOLY"
	desc = "A sign labelling a sanctified area."
	icon_state = "holy"

/obj/structure/sign/public/laundry
	name = "\improper LAUNDRY"
	desc = "A place for you to wash all the blood out of your clothes."
	icon_state = "laundry"

/obj/structure/sign/public/pods
	name = "\improper ESCAPE PODS"
	desc = "The station's escape pods can be used to evacuate in the event that the main shuttle cannot be reached."
	icon_state = "pods"
	does_emissive = TRUE
	blocks_emissive = FALSE

/obj/structure/sign/public/salon
	name = "\improper SALON"
	desc = "If the station theoretically had a barber or stylist, they'd be found here, for sure."
	icon_state = "salon"

/obj/structure/sign/public/reception
	name = "\improper RECEPTION"
	desc = "Ring the bell on the desk and then wait for assistance to arrive."
	icon_state = "reception"

/obj/structure/sign/public/restroom
	name = "\improper RESTROOM"
	desc = "Toilets, showers, and even a robot charger!"
	icon_state = "restroom"

/obj/structure/sign/public/tools
	name = "\improper TOOL STORAGE"
	desc = "A place Nanotrasen stores excess tools before they're removed by roving gangs of assistants."
	icon_state = "tools"

/obj/structure/sign/public/vox_box
	name = "\improper VOX BOX"
	desc = "DANGER OF DEATH: PURE NITROGEN ATMOSPHERE. Breathing apparatus required for non-vox beyond this point."
	icon_state = "vox_box"

// MARK: Security
/obj/structure/sign/security
	name = "\improper SECURITY"
	desc = "This is Security's turf. Better behave yourself around here."
	icon_state = "security"

/obj/structure/sign/security/armory
	name = "\improper ARMORY"
	desc = "All the guns are kept here. Often opened at the slightest sign of resistance against the Security department's iron rule."
	icon_state = "armory"

/obj/structure/sign/security/brig
	name = "\improper BRIG"
	desc = "This is where criminals are locked up."
	icon_state = "brig"

/obj/structure/sign/security/detective
	name = "\improper DETECTIVE"
	desc = "The office of the Detective, who will solve any case that ends up on their desk. Provided they don't need to go out for another carton of cigarettes."
	icon_state = "detective"

/obj/structure/sign/security/evidence
	name = "\improper EVIDENCE"
	desc = "A secure room to store evidence of crimes as well as confiscated equipment, until a Syndicate agent breaks in to retrieve it."
	icon_state = "evidence"

/obj/structure/sign/security/interrogation
	name = "\improper INTERROGATION"
	desc = "Despite the number of tooth extractions that happen here, no one in the Security department is actually a qualified dentist."
	icon_state = "interrogation"

/obj/structure/sign/security/labor_camp
	name = "\improper LABOR CAMP"
	desc = "Why have prisoners sitting around doing nothing, when they can actually be productive?"
	icon_state = "labor_camp"

/obj/structure/sign/security/law
	name = "\improper LAW OFFICES"
	desc = "The home of THE LAW. Houses the Internal Affairs Agent, and the Magistrate that people actually have a reason to speak to."
	icon_state = "law"

/obj/structure/sign/security/perma
	name = "\improper PERMANENT CONFINEMENT"
	desc = "This is where the worst of the worst criminals are locked up. Foooorrrreeeeeveeeerrrr!"
	icon_state = "perma"

// MARK: Cargo
/obj/structure/sign/cargo
	name = "\improper CARGO"
	desc = "The logistical heart of the station, handling incoming supply shipments, salvage, and minerals. Oh, and mail too."
	icon_state = "cargo"

/obj/structure/sign/cargo/dock
	name = "\improper CARGO DOCK"
	desc = "The cargo dock and attached warehouse is the place that old crates, Forklift, and freshly arrived shipments can be found."
	icon_state = "cargo_dock"

/obj/structure/sign/cargo/mail
	name = "\improper MAIL"
	desc = "The station's mail room, where boxes are delivered by cargo telepad or the station's disposal system. \
	Try not to think too hard about your package going through the same pipe as all the station's rubbish."
	icon_state = "mail"

/obj/structure/sign/cargo/materials
	name = "\improper MATERIALS"
	desc = "Hopefully cargo's mining department deposited something here before running off and dying."
	icon_state = "materials_cargo"

/obj/structure/sign/cargo/mining
	name = "\improper MINING"
	desc = "Miners are responsable for getting the materials that all other industry needs to function. And also monster hunting, alledgedly."
	icon_state = "mining"

/obj/structure/sign/cargo/salvage
	name = "\improper SALVAGE"
	desc = "The base of operation used by the station's explorers preparing for their quest to get as many guns as possible."
	icon_state = "salvage"

/obj/structure/sign/cargo/smith
	name = "\improper SMITH"
	desc = "Despite the rise automated fabrication systems such as the autolathe, some of the best craftsmanship is still only possible by letting a trained person hit the workpiece with a big hammer."
	icon_state = "smith"

/obj/structure/sign/cargo/xenos
	name = "DANGEROUS ALIEN LIFE"
	desc = "A warning sign reminding you that this is not a safe place. Keep a weapon with you at all times."
	icon_state = "mining_xenos"

// MARK: Engineering
/obj/structure/sign/engineering
	name = "\improper ENGINEERING"
	desc = "Home to the vital systems that keep the station running. Sometimes you'll even find some engineers in here too!"
	icon_state = "engineering"

/obj/structure/sign/engineering/atmos
	name = "\improper ATMOSPHERICS"
	desc = "The endless pipes of Atmosia supply the air you breathe. And occasionally some other less-safe gasses too."
	icon_state = "atmos"

/obj/structure/sign/engineering/cans
	name = "\improper GAS CANISTERS"
	desc = "A storage area for gas canisters."
	icon_state = "cans"

/obj/structure/sign/engineering/comms
	name = "\improper TELECOMMUNICATIONS"
	desc = "The equipment that lets your headset work, breaks the moment an ion cloud exists near the station. If you want to live without it, grab a station-bounced radio or use an intercom."
	icon_state = "comms"

/obj/structure/sign/engineering/gravity
	name = "\improper GRAVITY GENERATOR"
	desc = "The machine that generates the station's artifical gravity field. Ideally this should be left alone until it breaks. Then it shouldn't be left alone."
	icon_state = "gravity"

/obj/structure/sign/engineering/materials
	name = "\improper MATERIALS"
	desc = "A cache of materials for use in construction and maintenance. It won't last for long enough."
	icon_state = "materials"

/obj/structure/sign/engineering/power
	name = "\improper POWER GENERATION EQUIPMENT"
	desc = "The equipment needed to keep the heart of the station beating. If all of this breaks, the rest of the station won't be far behind."
	icon_state = "power"

// MARK: Service
/obj/structure/sign/service/bar
	name = "\improper BAR"
	desc = "A place to go and have fun, get to know new and interesting people, and destroy your liver."
	icon_state = "bar"

/obj/structure/sign/service/bar/examine(mob/user)
	. = ..()
	. += SPAN_INFO("Remember: The bartender is allowed under SOP to charge you for drinks. Nanotrasen is not a charity.")
	. += SPAN_INFO("Also remember: If you start shit in the bar, the bartender is legally entitled to blast you with his shotgun and then throw you out of the bar.")

/obj/structure/sign/service/chapel
	name = "\improper CHAPEL"
	desc = "An oasis of holy ground and spiritual peace. Obviously this is the first place you should run if you're being chased by ghosts, cultists, or vampires."
	icon_state = "chapel"

/obj/structure/sign/service/chapel/examine(mob/user)
	. = ..()
	. += SPAN_INFO("The chapel does in fact provide protection from all the aforementioned entities!")

/obj/structure/sign/service/custodian
	name = "\improper CUSTODIAN"
	desc = "The kingdom of Janitalia, the first and often last line of defence standing between the station and an endless tide of blood, vomit, and fuck knows what else smeared across the halls."
	icon_state = "custodian"

/obj/structure/sign/service/drama
	name = "\improper THEATRE"
	desc = "Becuase of various obscure contractual oblications and treaties, Nanotrasen has agreed to give this space over to the station's Clown and Mime so they'll stop bothering everyone everywhere else."
	base_icon_state = "drama"
	icon_state = "drama1"

/obj/structure/sign/service/drama/Initialize(mapload)
	. = ..()
	icon_state = "[base_icon_state][rand(1-3)]"
	update_appearance(UPDATE_ICON_STATE)

/obj/structure/sign/service/library
	name = "\improper LIBRARY"
	desc = "A sanctuary of NERDS! Books can alledgedly be found here. The space is also used for the station's D&D game night."
	icon_state = "library"

/obj/structure/sign/service/kitchen
	name = "\improper KITCHEN"
	desc = "The place to go when you need a delicious meal. Or a deep fried strip of raw bacon."
	icon_state = "kitchen"

/obj/structure/sign/service/kitchen/examine(mob/user)
	. = ..()
	. += SPAN_INFO("Remember: The chef is allowed under SOP to charge you for meals. Nanotrasen is not a charity.")
	. += SPAN_INFO("Also remember: If you break into the kichen because you don't want to pay, the chef is legally entitled to beat the crap out of you.")

/obj/structure/sign/service/botany
	name = "\improper HYDROPONICS"
	desc = "A hydroponics lab where food and other plants can be grown. There are a statistically significant number of war criminals employed here above the station's baseline."
	icon_state = "hydro"

// MARK: Medical
/obj/structure/sign/medical
	name = "\improper MEDICAL"
	desc = "The station's medical bay. The doctors inside can be your salvation, but beware their wrath if provoked."
	icon_state = "medical"

/obj/structure/sign/medical/chemistry
	name = "\improper CHEMISTRY"
	desc = "The source of the medical department's medicines, and the clown's lube."
	icon_state = "chemistry"

/obj/structure/sign/medical/cloning
	name = "\improper CLONING"
	desc = "The first port-of-call for many doctors treating cardiac arrest."
	icon_state = "clone"

/obj/structure/sign/medical/morgue
	name = "\improper MORGUE"
	desc = "The place where autopsies are performed and cadavers are stored while awaiting funeral rites in the chapel... Or until the chef steals them."
	icon_state = "morgue"

/obj/structure/sign/medical/examroom
	name = "\improper EXAM ROOM"
	desc = "The place where doctors try and figure out what's wrong with you."
	icon_state = "examroom"

/obj/structure/sign/medical/psych
	name = "\improper PSYCHOLOGIST"
	desc = "The psychologist is alledgedly the most sane individual on the station, who can alledgedly help you with your own psychological traumas."
	icon_state = "psych"

/obj/structure/sign/medical/surgery
	name = "\improper SURGERY"
	desc = "This is where the station's surgical teams will perform invasive medical procedures deep inside your body. Hopefully under the effects of anesthetic."
	icon_state = "surgery"

/obj/structure/sign/medical/virology
	name = "\improper VIROLOGY"
	desc = "If you're nice to the virologist, they'll inject you a vaccine instead of their experimental projectile vomiting disease."
	icon_state = "virology"

// MARK: Command
/obj/structure/sign/command
	name = "\improper BRIDGE"
	desc = "The throbbing brain of the station. The bridge's viewing window is a common gathering place for the station's seething masses, \
	who all enjoy staring into what is sometimes referred to as the station's \"fish tank\"."
	icon_state = "bridge"

/obj/structure/sign/command/ai
	name = "\improper ARTIFICIAL INTELLIGENCE"
	desc = "The station's AI core, where the AI and a large number of automated gun turrets can be found."
	icon_state = "ai"

/obj/structure/sign/command/ai_upload
	name = "\improper AI UPLOAD"
	desc = "A pair of computers that can remotely upload your stupid custom lawset to any AI or any unsyncronized robots on the station. Provided they're registered to Nanotrasen, at least."
	icon_state = "ai_upload"

/obj/structure/sign/command/conference
	name = "\improper CONFERENCE ROOM"
	desc = "A room that is supposedly about holding orderly meetings between station command, plus the occasional diplomatic delegation. \
	It's been host to more internal and international incidents than anywhere else on the station."
	icon_state = "conference"

/obj/structure/sign/command/eva
	name = "\improper EVA"
	desc = "Stocked with space suits and other equipment for performing Extra-Vehicular Activity. It's an ideal pick for the first place you should run to when you see the self-destruct mechanism being activated."
	icon_state = "eva"

/obj/structure/sign/command/head
	name = "\improper DEPARTMENT HEAD"
	desc = "The office of this department's commanding officer. The first place that any revolutionary will look, so don't hide in here if people start unionizing!"
	icon_state = "head"

/obj/structure/sign/command/vault
	name = "\improper VAULT"
	desc = "The station's high-security vault, for storing valuable items, currency, and the station's Nuclear Fission Explosive. Oh and Tom, Tom also lives in there."
	icon_state = "vault"

// MARK: Science
/obj/structure/sign/science
	name = "\improper SCIENCE!"
	desc = "The science department, supposedly the entire reason that this station exists is because of the research done here."
	icon_state = "science"

/obj/structure/sign/science/chemistry_sci
	name = "\improper SCIENCE CHEMISTRY"
	desc = "The dedicated chemistry unit of Science. Because medical can't have all the chemicals to itself!"
	icon_state = "chemistry_sci"

/obj/structure/sign/science/cans_sci
	name = "\improper GAS CANISTERS"
	desc = "The various gas canisters used by Toxins to blow stuff up. Most of the gasses in here will never be used for legitimate purposes."
	icon_state = "cans_sci"

/obj/structure/sign/science/data
	name = "\improper DATA"
	desc = "The station's research data has to go somewhere, and that somewhere is here. Make sure you back it up, or you'll eventually be in a bad situation."
	icon_state = "data"

/obj/structure/sign/science/genetics
	name = "\improper GENETICS"
	desc = "Geneticists and botanists eternally race each other to create as many crimes against God as possible."
	icon_state = "genetics"

/obj/structure/sign/science/research
	name = "\improper RESEARCH & DEVELOPMENT"
	desc = "Where new technologies are discovered to benefit the crew. Make sure to give 'em at least 15 minutes before banging on the windows. Maybe help by bringing some materials or funny science gizmos over too."
	icon_state = "research"

/obj/structure/sign/science/robotics
	name = "\improper ROBOTICS"
	desc = "Builders and maintainers of robots, cyborgs, and mecha. They can also deck you out with some sick implants too, mostly no questions asked!"
	icon_state = "robotics"

/obj/structure/sign/science/toxins
	name = "\improper TOXINS"
	desc = "Where people reserch the scince of blowing stuff up. There's really not much more to say."
	icon_state = "toxins"

/obj/structure/sign/science/xenobio
	name = "\improper XENOBIOLOGY"
	desc = "A room that, if functioning properly, should be full of gasping monkeys, pens filled with slimes, and 500 other random creatures just roaming around."
	icon_state = "xenobio"

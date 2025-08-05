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
	to_chat(user, "<span class='notice'>You fasten [S] with your [I].</span>")
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

/obj/structure/sign/securearea
	name = "\improper SECURE AREA"
	desc = "A warning sign which reads 'SECURE AREA'."
	icon_state = "securearea"

/obj/structure/sign/wait
	name = "\improper WAIT FOR DECONTAMINATION!"
	desc = "A warning sign which reads: WAIT! <BR>\
	Before returning from the asteroid internal zone, please wait for the in-built scrubber system to remove all traces of the toxic atmosphere. This will take approximately 20 seconds.<BR> \
	Failure to adhere to this safety regulation will result in large plasmafires that will destroy the locking mechanisms."
	icon_state = "waitsign"
	resistance_flags = FIRE_PROOF

/obj/structure/sign/monkey_paint
	name = "Mr. Deempisi portrait"
	desc = "Under the painting a plaque reads: 'While the meat grinder may not have spared you, fear not. Not one part of you has gone to waste...You were delicious."
	icon_state = "monkey_painting"

/obj/structure/sign/biohazard
	name = "\improper BIOHAZARD"
	desc = "A warning sign which reads 'BIOHAZARD'."
	icon_state = "bio"

/obj/structure/sign/electricshock
	name = "\improper HIGH VOLTAGE"
	desc = "A warning sign which reads 'HIGH VOLTAGE'."
	icon_state = "shock"

/obj/structure/sign/examroom
	name = "\improper EXAM"
	desc = "A guidance sign which reads 'EXAM ROOM'."
	icon_state = "examroom"

/obj/structure/sign/vacuum
	name = "\improper HARD VACUUM AHEAD"
	desc = "A warning sign which reads 'HARD VACUUM AHEAD'."
	icon_state = "space"

/obj/structure/sign/vacuum/external
	name = "\improper EXTERNAL AIRLOCK"
	desc = "A warning sign which reads 'EXTERNAL AIRLOCK'."
	layer = MOB_LAYER

/obj/structure/sign/deathsposal
	name = "\improper DISPOSAL LEADS TO SPACE"
	desc = "A warning sign which reads 'DISPOSAL LEADS TO SPACE'."
	icon_state = "deathsposal"

/obj/structure/sign/pods
	name = "\improper ESCAPE PODS"
	desc = "A warning sign which reads 'ESCAPE PODS'."
	icon_state = "pods"

/obj/structure/sign/fire
	name = "\improper DANGER: FIRE"
	desc = "A warning sign which reads 'DANGER: FIRE'."
	icon_state = "fire"
	resistance_flags = FIRE_PROOF

/obj/structure/sign/nosmoking_1
	name = "\improper NO SMOKING"
	desc = "A warning sign which reads 'NO SMOKING'."
	icon_state = "nosmoking"
	resistance_flags = FLAMMABLE

/obj/structure/sign/nosmoking_2
	name = "\improper NO SMOKING"
	desc = "A warning sign which reads 'NO SMOKING'."
	icon_state = "nosmoking2"

/obj/structure/sign/radiation
	name = "\improper HAZARDOUS RADIATION"
	desc = "A warning sign alerting the user of potential radiation hazards."
	icon_state = "radiation"

/obj/structure/sign/radiation/rad_area
	name = "\improper RADIOACTIVE AREA"
	desc = "A warning sign which reads 'RADIOACTIVE AREA'."

/obj/structure/sign/xeno_warning_mining
	name = "DANGEROUS ALIEN LIFE"
	desc = "A sign that warns would be travellers of hostile alien life in the vicinity."
	icon = 'icons/obj/mining.dmi'
	icon_state = "xeno_warning"

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

/obj/structure/sign/science
	name = "\improper SCIENCE!"
	desc = "A warning sign which reads 'SCIENCE!'"
	icon_state = "science1"

/obj/structure/sign/chemistry
	name = "\improper CHEMISTRY"
	desc = "A warning sign which reads 'CHEMISTRY'."
	icon_state = "chemistry1"

/obj/structure/sign/botany
	name = "\improper HYDROPONICS"
	desc = "A warning sign which reads 'HYDROPONICS'."
	icon_state = "hydro1"

/obj/structure/sign/xenobio
	name = "\improper XENOBIOLOGY"
	desc = "A sign labelling an area as a place where xenobiological entities are researched."
	icon_state = "xenobio"

/obj/structure/sign/evac
	name = "\improper EVACUATION"
	desc = "A sign labelling an area where evacuation procedures take place."
	icon_state = "evac"

/obj/structure/sign/drop
	name = "\improper DROP PODS"
	desc = "A sign labelling an area where drop pod loading procedures take place."
	icon_state = "drop"

/obj/structure/sign/custodian
	name = "\improper CUSTODIAN"
	desc = "A sign labelling an area where the custodian works."
	icon_state = "custodian"

/obj/structure/sign/engineering
	name = "\improper ENGINEERING"
	desc = "A sign labelling an area where engineers work."
	icon_state = "engine"

/obj/structure/sign/cargo
	name = "\improper CARGO"
	desc = "A sign labelling an area where cargo ships dock."
	icon_state = "cargo"

/obj/structure/sign/security
	name = "\improper SECURITY"
	desc = "A sign labelling an area where the law is law."
	icon_state = "security"

/obj/structure/sign/holy
	name = "\improper HOLY"
	desc = "A sign labelling a religious area."
	icon_state = "holy"

/obj/structure/sign/restroom
	name = "\improper RESTROOM"
	desc = "A sign labelling a restroom."
	icon_state = "restroom"

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

/obj/structure/sign/directions/cargo
	desc = "A direction sign, pointing out which way the Supply Department is."
	icon_state = "direction_supply"

/obj/structure/sign/directions/service
	desc = "A direction sign, pointing out which way the Service Department is."
	icon_state = "direction_service"

/obj/structure/sign/explosives
	name = "\improper HIGH EXPLOSIVES"
	desc = "A warning sign which reads 'HIGH EXPLOSIVES'."
	icon_state = "explosives"

/obj/structure/sign/explosives/alt
	icon_state = "explosives2"

/obj/structure/sign/magboots
	name = "\improper MAG BOOTS"
	desc = "A warning sign which reads MAGBOOTS"
	icon_state = "magboots"

/obj/structure/sign/turbine
	name = "\improper TURBINE"
	desc = "A warning which reads TURBINE"
	icon_state = "turbine"

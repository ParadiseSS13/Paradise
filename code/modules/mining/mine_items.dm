/**********************Light************************/

//this item is intended to give the effect of entering the mine, so that light gradually fades
/obj/effect/light_emitter
	name = "Light-emtter"
	anchored = 1
	unacidable = 1
	light_range = 8

/**********************Miner Lockers**************************/

/obj/structure/closet/wardrobe/miner
	name = "mining wardrobe"
	icon_state = "mixed"
	icon_closed = "mixed"

/obj/structure/closet/wardrobe/miner/New()
	..()
	contents = list()
	new /obj/item/weapon/storage/backpack/duffel(src)
	new /obj/item/weapon/storage/backpack/industrial(src)
	new /obj/item/weapon/storage/backpack/satchel_eng(src)
	new /obj/item/clothing/under/rank/miner(src)
	new /obj/item/clothing/under/rank/miner(src)
	new /obj/item/clothing/under/rank/miner(src)
	new /obj/item/clothing/shoes/workboots(src)
	new /obj/item/clothing/shoes/workboots(src)
	new /obj/item/clothing/shoes/workboots(src)
	new /obj/item/clothing/gloves/fingerless(src)
	new /obj/item/clothing/gloves/fingerless(src)
	new /obj/item/clothing/gloves/fingerless(src)

/obj/structure/closet/secure_closet/miner
	name = "miner's equipment"
	icon_state = "miningsec1"
	icon_closed = "miningsec"
	icon_locked = "miningsec1"
	icon_opened = "miningsecopen"
	icon_broken = "miningsecbroken"
	icon_off = "miningsecoff"
	req_access = list(access_mining)

/obj/structure/closet/secure_closet/miner/New()
	..()
	new /obj/item/weapon/shovel(src)
	new /obj/item/weapon/pickaxe(src)
	new /obj/item/device/radio/headset/headset_cargo/mining(src)
	new /obj/item/device/t_scanner/adv_mining_scanner/lesser(src)
	new /obj/item/weapon/storage/bag/ore(src)
	new /obj/item/clothing/glasses/meson(src)

/**********************Shuttle Computer**************************/

/obj/machinery/computer/shuttle/mining
	name = "Mining Shuttle Console"
	desc = "Used to call and send the mining shuttle."
	circuit = /obj/item/weapon/circuitboard/mining_shuttle
	shuttleId = "mining"
	possible_destinations = "mining_home;mining_away"

/******************************Lantern*******************************/

/obj/item/device/flashlight/lantern
	name = "lantern"
	icon_state = "lantern"
	desc = "A mining lantern."
	brightness_on = 6			// luminosity when on

/*****************************Pickaxe********************************/

/obj/item/weapon/pickaxe
	name = "pickaxe"
	icon = 'icons/obj/items.dmi'
	icon_state = "pickaxe"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 15.0
	throwforce = 10.0
	item_state = "pickaxe"
	w_class = 4
	materials = list(MAT_METAL=2000) //one sheet, but where can you make them?
	var/digspeed = 40 //moving the delay to an item var so R&D can make improved picks. --NEO
	origin_tech = "materials=1;engineering=1"
	attack_verb = list("hit", "pierced", "sliced", "attacked")
	var/list/digsound = list('sound/effects/picaxe1.ogg','sound/effects/picaxe2.ogg','sound/effects/picaxe3.ogg')
	var/drill_verb = "picking"
	sharp = 1
	edge = 1
	var/excavation_amount = 100

/obj/item/weapon/pickaxe/proc/playDigSound()
		playsound(src, pick(digsound),20,1)

/obj/item/weapon/pickaxe/silver
	name = "silver-plated pickaxe"
	icon_state = "spickaxe"
	item_state = "spickaxe"
	digspeed = 30 //mines faster than a normal pickaxe, bought from mining vendor
	origin_tech = "materials=3;engineering=2"
	desc = "A silver-plated pickaxe that mines slightly faster than standard-issue."

/obj/item/weapon/pickaxe/diamond
	name = "diamond-tipped pickaxe"
	icon_state = "dpickaxe"
	item_state = "dpickaxe"
	digspeed = 20 //mines twice as fast as a normal pickaxe, bought from mining vendor
	origin_tech = "materials=4;engineering=3"
	desc = "A pickaxe with a diamond pick head. Extremely robust at cracking rock walls and digging up dirt."

/obj/item/weapon/pickaxe/drill
	name = "mining drill"
	icon_state = "handdrill"
	item_state = "jackhammer"
	digspeed = 25 //available from roundstart, faster than a pickaxe.
	digsound = list('sound/weapons/drill.ogg')
	hitsound = 'sound/weapons/drill.ogg'
	origin_tech = "materials=2;powerstorage=3;engineering=2"
	desc = "An electric mining drill for the especially scrawny."

/obj/item/weapon/pickaxe/drill/cyborg
	name = "cyborg mining drill"
	desc = "An integrated electric mining drill."
	flags = NODROP

/obj/item/weapon/pickaxe/drill/diamonddrill
	name = "diamond-tipped mining drill"
	icon_state = "diamonddrill"
	digspeed = 10
	origin_tech = "materials=6;powerstorage=4;engineering=5"
	desc = "Yours is the drill that will pierce the heavens!"

/obj/item/weapon/pickaxe/diamonddrill/traitor //Pocket-sized traitor diamond drill.
	name = "supermatter drill"
	icon_state = "smdrill"
	origin_tech = "materials=6;powerstorage=4;engineering=5;syndicate=3"
	desc = "Microscopic supermatter crystals cover the head of this tiny drill."
	w_class = 2

/obj/item/weapon/pickaxe/drill/cyborg/diamond //This is the BORG version!
	name = "diamond-tipped cyborg mining drill" //To inherit the NODROP flag, and easier to change borg specific drill mechanics.
	icon_state = "diamonddrill"
	digspeed = 10

/obj/item/weapon/pickaxe/drill/jackhammer
	name = "sonic jackhammer"
	icon_state = "jackhammer"
	item_state = "jackhammer"
	digspeed = 5 //the epitome of powertools. extremely fast mining, laughs at puny walls
	origin_tech = "materials=3;powerstorage=2;engineering=2"
	digsound = list('sound/weapons/sonic_jackhammer.ogg')
	hitsound = 'sound/weapons/sonic_jackhammer.ogg'
	desc = "Cracks rocks with sonic blasts, and doubles as a demolition power tool for smashing walls."

/obj/item/weapon/pickaxe/silver
	name = "silver pickaxe"
	icon_state = "spickaxe"
	item_state = "spickaxe"
	digspeed = 30
	origin_tech = "materials=3"
	desc = "This makes no metallurgic sense."

/obj/item/weapon/pickaxe/gold
	name = "golden pickaxe"
	icon_state = "gpickaxe"
	item_state = "gpickaxe"
	digspeed = 20
	origin_tech = "materials=4"
	desc = "This makes no metallurgic sense."
/*****************************Shovel********************************/

/obj/item/weapon/shovel
	name = "shovel"
	desc = "A large tool for digging and moving dirt."
	icon = 'icons/obj/items.dmi'
	icon_state = "shovel"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 8.0
	throwforce = 4.0
	item_state = "shovel"
	w_class = 3
	materials = list(MAT_METAL=50)
	origin_tech = "materials=1;engineering=1"
	attack_verb = list("bashed", "bludgeoned", "thrashed", "whacked")

/obj/item/weapon/shovel/spade
	name = "spade"
	desc = "A small tool for digging and moving dirt."
	icon_state = "spade"
	item_state = "spade"
	force = 5.0
	throwforce = 7.0
	w_class = 2


/**********************Mining car (Crate like thing, not the rail car)**************************/

/obj/structure/closet/crate/miningcar
	desc = "A mining car. This one doesn't work on rails, but has to be dragged."
	name = "mining car (not for rails)"
	icon = 'icons/obj/storage.dmi'
	icon_state = "miningcar"
	density = 1
	icon_opened = "miningcaropen"
	icon_closed = "miningcar"

/*********************Mob Capsule*************************/

/obj/item/device/mobcapsule
	name = "lazarus capsule"
	desc = "It allows you to store and deploy lazarus-injected creatures easier."
	icon = 'icons/obj/mobcap.dmi'
	icon_state = "mobcap0"
	w_class = 1
	throw_range = 20
	var/mob/living/simple_animal/captured = null
	var/colorindex = 0

/obj/item/device/mobcapsule/Destroy()
	if(captured)
		qdel(captured)
		captured = null
	return ..()

/obj/item/device/mobcapsule/attack(var/atom/A, mob/user, prox_flag)
	if(!istype(A, /mob/living/simple_animal) || isbot(A))
		return ..()
	capture(A, user)
	return 1

/obj/item/device/mobcapsule/proc/capture(var/mob/target, var/mob/U as mob)
	var/mob/living/simple_animal/T = target
	if(captured)
		to_chat(U, "<span class='notice'>Capture failed!</span>: The capsule already has a mob registered to it!")
	else
		if(istype(T) && "neutral" in T.faction)
			T.forceMove(src)
			T.name = "[U.name]'s [initial(T.name)]"
			T.cancel_camera()
			name = "Lazarus Capsule: [initial(T.name)]"
			to_chat(U, "<span class='notice'>You placed a [T.name] inside the Lazarus Capsule!</span>")
			captured = T
		else
			to_chat(U, "You can't capture that mob!")

/obj/item/device/mobcapsule/throw_impact(atom/A, mob/user)
	..()
	if(captured)
		dump_contents(user)

/obj/item/device/mobcapsule/proc/dump_contents(mob/user)
	if(captured)
		captured.forceMove(get_turf(src))
		if(captured.client)
			captured.client.eye = captured.client.mob
			captured.client.perspective = MOB_PERSPECTIVE
		captured = null

/obj/item/device/mobcapsule/attack_self(mob/user)
	colorindex += 1
	if(colorindex >= 6)
		colorindex = 0
	icon_state = "mobcap[colorindex]"
	update_icon()

/*****************************Survival Pod********************************/


/area/survivalpod
	name = "\improper Emergency Shelter"
	icon_state = "away"
	requires_power = 0
	has_gravity = 1

/obj/item/weapon/survivalcapsule
	name = "bluespace shelter capsule"
	desc = "An emergency shelter stored within a pocket of bluespace."
	icon_state = "capsule"
	icon = 'icons/obj/mining.dmi'
	w_class = 1
	origin_tech = "engineering=3;bluespace=3"
	var/template_id = "shelter_alpha"
	var/datum/map_template/shelter/template
	var/used = FALSE

/obj/item/weapon/survivalcapsule/proc/get_template()
	if(template)
		return
	template = shelter_templates[template_id]
	if(!template)
		log_runtime("Shelter template ([template_id]) not found!", src)
		qdel(src)

/obj/item/weapon/survivalcapsule/examine(mob/user)
	. = ..()
	get_template()
	to_chat(user, "This capsule has the [template.name] stored.")
	to_chat(user, template.description)

/obj/item/weapon/survivalcapsule/attack_self()
	// Can't grab when capsule is New() because templates aren't loaded then
	get_template()
	if(used == FALSE)
		loc.visible_message("<span class='warning'>[src] begins to shake. Stand back!</span>")
		used = TRUE
		sleep(50)
		var/turf/deploy_location = get_turf(src)
		var/status = template.check_deploy(deploy_location)
		switch(status)
			if(SHELTER_DEPLOY_BAD_AREA)
				loc.visible_message("<span class='warning'>[src] will not function in this area.</span>")
			if(SHELTER_DEPLOY_BAD_TURFS, SHELTER_DEPLOY_ANCHORED_OBJECTS)
				var/width = template.width
				var/height = template.height
				loc.visible_message("<span class='warning'>[src] doesn't have room to deploy! You need to clear a [width]x[height] area!</span>")

		if(status != SHELTER_DEPLOY_ALLOWED)
			used = FALSE
			return

		playsound(get_turf(src), 'sound/effects/phasein.ogg', 100, 1)

		var/turf/T = deploy_location
		if(!is_mining_level(T.z))//only report capsules away from the mining/lavaland level
			message_admins("[key_name_admin(usr)] (<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[usr]'>FLW</A>) activated a bluespace capsule away from the mining level! (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</a>)")
			log_admin("[key_name(usr)] activated a bluespace capsule away from the mining level at [T.x], [T.y], [T.z]")
		template.load(deploy_location, centered = TRUE)
		new /obj/effect/effect/harmless_smoke(get_turf(src))
		qdel(src)

//Pod turfs and objects


//Floors
/turf/simulated/floor/pod
	name = "pod floor"
	icon_state = "podfloor"
	icon_regular_floor = "podfloor"
	floor_tile = /obj/item/stack/tile/pod

//Walls
/turf/simulated/wall/survival
	name = "pod wall"
	desc = "An easily-compressable wall used for temporary shelter."
	icon = 'icons/turf/walls/survival_pod_walls.dmi'
	icon_state = "smooth"
	walltype = "shuttle"
	smooth = SMOOTH_MORE // To Do: Add in Diagnaol Smooth Support
	canSmoothWith = list(/turf/simulated/wall/survival, /obj/machinery/door/airlock/survival_pod)

//Door
/obj/machinery/door/airlock/survival_pod
	name = "Airlock"
	icon = 'icons/obj/doors/survival.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_pod
	opacity = 0
	glass = 1

/obj/structure/door_assembly/door_assembly_pod
	base_icon_state = "survival_pod"
	glass_type = "/survival_pod"

//Table
/obj/structure/table/survival_pod
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	icon_state = "table"
	smooth = SMOOTH_FALSE

//Sleeper
/obj/machinery/sleeper/survival_pod
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	icon_state = "sleeper-open"
	density = 0

/obj/machinery/sleeper/survival_pod/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/sleeper/survival(null)
	var/obj/item/weapon/stock_parts/matter_bin/B = new(null)
	B.rating = initial_bin_rating
	component_parts += B
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()

//Computer
/obj/item/device/gps/computer
	name = "pod computer"
	icon_state = "pod_computer"
	icon = 'icons/obj/lavaland/pod_computer.dmi'
	anchored = 1
	density = 1
	pixel_y = -32

/obj/item/device/gps/computer/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/wrench))
		playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
		user.visible_message("<span class='warning'>[user] disassembles the gps.</span>", \
						"<span class='notice'>You start to disassemble the gps...</span>", "You hear clanking and banging noises.")
		if(do_after(user, 20, target = src))
			new /obj/item/device/gps(loc)
			qdel(src)
			return ..()

/obj/item/device/gps/computer/attack_hand(mob/user)
	attack_self(user)

//Bed
/obj/structure/stool/bed/pod
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	icon_state = "bed"

//Survival Storage Unit
/obj/machinery/smartfridge/survival_pod
	name = "survival pod storage"
	desc = "A heated storage unit."
	icon_state = "donkvendor"
	icon = 'icons/obj/lavaland/donkvendor.dmi'
	icon_on = "donkvendor"
	icon_off = "donkvendor"
	light_range = 8
	max_n_of_items = 10
	pixel_y = -4

/obj/item/weapon/circuitboard/smartfridge/survival
	name = "circuit board (Smartfridge Survival)"
	build_path = /obj/machinery/smartfridge/survival_pod

/obj/item/weapon/circuitboard/smartfridge/attackby(obj/item/I, mob/user, params)
	return

/obj/machinery/smartfridge/survival_pod/accept_check(obj/item/O)
	if(istype(O, /obj/item))
		return 1
	return 0

/obj/machinery/smartfridge/survival_pod/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/smartfridge/survival(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	RefreshParts()

/obj/machinery/smartfridge/survival_pod/loaded/New()
	..()
	for(var/i in 1 to 5)
		var/obj/item/weapon/reagent_containers/food/snacks/warmdonkpocket_weak/W = new(src)
		load(W)
	if(prob(50))
		var/obj/item/weapon/storage/pill_bottle/dice/D = new(src)
		load(D)
	else
		var/obj/item/device/guitar/G = new(src)
		load(G)

//Fans
/obj/structure/fans
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	icon_state = "fans"
	name = "environmental regulation system"
	desc = "A large machine releasing a constant gust of air."
	anchored = 1
	density = 1
	var/arbitraryatmosblockingvar = 1
	var/buildstacktype = /obj/item/stack/sheet/metal
	var/buildstackamount = 5

/obj/structure/fans/proc/deconstruct()
	if(buildstacktype)
		new buildstacktype(loc, buildstackamount)
	qdel(src)

/obj/structure/fans/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/wrench))
		playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
		user.visible_message("<span class='warning'>[user] disassembles the fan.</span>", \
							 "<span class='notice'>You start to disassemble the fan...</span>", "You hear clanking and banging noises.")
		if(do_after(user, 20, target = src))
			deconstruct()
			return ..()

/obj/structure/fans/tiny
	name = "tiny fan"
	desc = "A tiny fan, releasing a thin gust of air."
	layer = TURF_LAYER+0.1
	density = 0
	icon_state = "fan_tiny"
	buildstackamount = 2

/obj/structure/fans/New(loc)
	..()
	air_update_turf(1)

/obj/structure/fans/Destroy()
	arbitraryatmosblockingvar = 0
	air_update_turf(1)
	return ..()

/obj/structure/fans/CanAtmosPass(turf/T)
	return !arbitraryatmosblockingvar

//Signs
/obj/structure/sign/mining
	name = "nanotrasen mining corps sign"
	desc = "A sign of relief for weary miners, and a warning for would-be competitors to Nanotrasen's mining claims."
	icon = 'icons/turf/walls/survival_pod_walls.dmi'
	icon_state = "ntpod"

/obj/structure/sign/mining/survival
	name = "shelter sign"
	desc = "A high visibility sign designating a safe shelter."
	icon = 'icons/turf/walls/survival_pod_walls.dmi'
	icon_state = "survival"

//Fluff
/obj/structure/tubes
	icon_state = "tubes"
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	name = "tubes"
	anchored = 1
	layer = MOB_LAYER - 0.2
	density = 0

/obj/structure/tubes/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/wrench))
		playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
		user.visible_message("<span class='warning'>[user] disassembles [src].</span>", \
							 "<span class='notice'>You start to disassemble [src]...</span>", "You hear clanking and banging noises.")
		if(do_after(user, 20, target = src))
			new /obj/item/stack/rods(loc)
			qdel(src)
			return ..()
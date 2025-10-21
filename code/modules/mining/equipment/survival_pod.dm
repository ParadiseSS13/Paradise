/area/survivalpod
	name = "\improper Emergency Shelter"
	icon_state = "away"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	ambientsounds = MINING_SOUNDS

/obj/item/survivalcapsule
	name = "bluespace shelter capsule"
	desc = "An emergency shelter stored within a pocket of bluespace."
	icon_state = "capsule"
	icon = 'icons/obj/mining.dmi'
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "engineering=3;bluespace=3"
	var/template_id = "shelter_alpha"
	var/datum/map_template/shelter/template
	var/used = FALSE

/obj/item/survivalcapsule/emag_act()
	if(!emagged)
		to_chat(usr, "<span class='warning'>You short out the safeties, allowing it to be placed in the station sector.</span>")
		emagged = TRUE
		return TRUE
	to_chat(usr, "<span class='warning'>The safeties are already shorted out!</span>")

/obj/item/survivalcapsule/proc/get_template()
	if(template)
		return
	template = GLOB.shelter_templates[template_id]
	if(!template)
		stack_trace("Shelter template ([template_id]) not found!")
		qdel(src)

/obj/item/survivalcapsule/examine(mob/user)
	. = ..()
	get_template()
	. += "This capsule has the [template.name] stored."
	. += template.description

/obj/item/survivalcapsule/attack_self__legacy__attackchain()
	// Can't grab when capsule is New() because templates aren't loaded then
	get_template()
	if(!used)
		loc.visible_message("<span class='warning'>[src] begins to shake. Stand back!</span>")
		used = TRUE
		sleep(50)
		var/turf/deploy_location = get_turf(src)
		var/status = template.check_deploy(deploy_location)
		var/turf/UT = get_turf(usr)
		if((UT.z == level_name_to_num(MAIN_STATION)) && !emagged)
			to_chat(usr, "<span class='notice'>Error. Deployment was attempted on the station sector. Deployment aborted.</span>")
			playsound(usr, 'sound/machines/terminal_error.ogg', 15, TRUE)
			used = FALSE
			return
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
			message_admins("[key_name_admin(usr)] ([ADMIN_QUE(usr,"?")]) ([ADMIN_FLW(usr,"FLW")]) activated a bluespace capsule away from the mining level! (<A href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</a>)")
			log_admin("[key_name(usr)] activated a bluespace capsule away from the mining level at [T.x], [T.y], [T.z]")
		template.load(deploy_location, centered = TRUE)
		new /obj/effect/particle_effect/smoke(get_turf(src))
		SEND_GLOBAL_SIGNAL(COMSIG_GLOB_SHELTER_PLACED, T)
		qdel(src)

/obj/item/survivalcapsule/luxury
	name = "luxury bluespace shelter capsule"
	desc = "An exorbitantly expensive luxury suite stored within a pocket of bluespace. It is made of durable materials more capable of withstanding harsh weather over standard capsules."
	origin_tech = "engineering=3;bluespace=4"
	template_id = "shelter_beta"

// for things that shouldnt affect specifically the luxury pods
/area/survivalpod/luxurypod
	name = "\improper Luxury Shelter"

//Pod turfs and objects

//Window
/obj/structure/window/full/shuttle/survival_pod
	name = "pod window"
	icon = 'icons/obj/smooth_structures/windows/pod_window.dmi'
	icon_state = "pod_window-0"
	base_icon_state = "pod_window"
	smoothing_groups = list(SMOOTH_GROUP_SHUTTLE_PARTS, SMOOTH_GROUP_SURVIVAL_TIANIUM_POD)
	canSmoothWith = list(SMOOTH_GROUP_SURVIVAL_TIANIUM_POD)

/obj/structure/window/reinforced/survival_pod
	name = "pod window"
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	icon_state = "pwindow"

/obj/structure/window/full/shuttle/survival_pod/tinted
	name = "tinted pod window"
	opacity = TRUE

//Floors
/turf/simulated/floor/pod
	name = "pod floor"
	icon_state = "podfloor"
	icon_regular_floor = "podfloor"
	floor_tile = /obj/item/stack/tile/pod

/turf/simulated/floor/pod/light
	icon_state = "podfloor_light"
	icon_regular_floor = "podfloor_light"
	floor_tile = /obj/item/stack/tile/pod/light

/turf/simulated/floor/pod/light/lavaland_air
	oxygen = LAVALAND_OXYGEN
	nitrogen = LAVALAND_NITROGEN
	temperature = LAVALAND_TEMPERATURE
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_LAVALAND

/turf/simulated/floor/pod/dark
	icon_state = "podfloor_dark"
	icon_regular_floor = "podfloor_dark"
	floor_tile = /obj/item/stack/tile/pod/dark

/turf/simulated/floor/pod/dark/lavaland_air
	oxygen = LAVALAND_OXYGEN
	nitrogen = LAVALAND_NITROGEN
	temperature = LAVALAND_TEMPERATURE
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_LAVALAND

//Door
/obj/machinery/door/airlock/survival_pod
	icon = 'icons/obj/doors/airlocks/survival/survival.dmi'
	overlays_file = 'icons/obj/doors/airlocks/survival/survival_overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_pod

/obj/machinery/door/airlock/survival_pod/glass
	opacity = FALSE
	glass = TRUE

/obj/structure/door_assembly/door_assembly_pod
	name = "pod airlock assembly"
	icon = 'icons/obj/doors/airlocks/survival/survival.dmi'
	base_name = "pod airlock"
	overlays_file = 'icons/obj/doors/airlocks/survival/survival_overlays.dmi'
	airlock_type = /obj/machinery/door/airlock/survival_pod
	glass_type = /obj/machinery/door/airlock/survival_pod/glass

//Windoor
/obj/machinery/door/window/survival_pod
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	icon_state = "windoor"
	base_state = "windoor"

//Table
/obj/structure/table/survival_pod
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	icon_state = "table"
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null

//Sleeper
/obj/machinery/sleeper/survival_pod
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	density = FALSE

/obj/machinery/sleeper/survival_pod/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/sleeper/survival(null)
	var/obj/item/stock_parts/matter_bin/B = new(null)
	B.rating = initial_bin_rating
	component_parts += B
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()
	update_icon()

/obj/machinery/sleeper/survival_pod/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[icon_state]_lightmask")

//NanoMed
/obj/machinery/economy/vending/wallmed/survival_pod
	name = "survival pod emergency medical supply"
	desc = "Wall-mounted Medical Equipment dispenser. This one seems just a tiny bit smaller."

	products = list(/obj/item/stack/medical/bruise_pack = 1,
				/obj/item/stack/medical/ointment = 1,
				/obj/item/reagent_containers/syringe/charcoal = 1,
				/obj/item/reagent_containers/hypospray/autoinjector/epinephrine = 2,
				/obj/item/stack/medical/splint = 1,
	)
	contraband = list()

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/economy/vending/wallmed/survival_pod, 32, 32)

//Computer
/obj/item/gps/computer
	name = "pod computer"
	icon_state = "pod_computer"
	icon = 'icons/obj/lavaland/pod_computer.dmi'
	anchored = TRUE
	density = TRUE
	tracking = TRUE
	pixel_y = -32
	light_power = 1.4
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	light_color = "#79dcc4"

/obj/item/gps/computer/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/gps/computer/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[icon_state]_lightmask")

/obj/item/gps/computer/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	user.visible_message("<span class='warning'>[user] starts to disassemble [src].</span>", \
						"<span class='notice'>You start to disassemble [src]...</span>", "You hear clanking and banging noises.")
	if(!I.use_tool(src, user, 2 SECONDS, 0, 50))
		return
	user.visible_message("<span class='warning'>[user] disassembles [src].</span>", \
				"<span class='notice'>You disassemble [src].</span>", "You hear clanking and banging noises.")
	new /obj/item/gps(loc)
	qdel(src)

/obj/item/gps/computer/attack_hand(mob/user)
	attack_self__legacy__attackchain(user)

//Bed
/obj/structure/bed/pod
	icon = 'icons/obj/lavaland/survival_pod.dmi'

//Survival Storage Unit
/obj/machinery/smartfridge/survival_pod
	name = "survival pod storage"
	desc = "A heated storage unit."
	icon_state = "donkvendor"
	icon = 'icons/obj/lavaland/donkvendor.dmi'
	light_range_on = 3
	light_power_on = 1
	light_color = "#79dcc4"
	max_n_of_items = 10
	pixel_y = -4
	flags = NODECONSTRUCT
	var/empty = FALSE

/obj/machinery/smartfridge/survival_pod/Initialize(mapload)
	. = ..()

	if(empty)
		return

	for(var/i in 1 to 5)
		var/obj/item/food/warmdonkpocket_weak/W = new(src)
		load(W)
	if(prob(50))
		var/obj/item/storage/bag/dice/D = new(src)
		load(D)
	else
		var/obj/item/instrument/guitar/G = new(src)
		load(G)

/obj/machinery/smartfridge/survival_pod/update_icon_state()
	return

/obj/machinery/smartfridge/survival_pod/update_overlays()
	underlays.Cut()
	underlays += emissive_appearance(icon, "[icon_state]_lightmask")

/obj/machinery/smartfridge/survival_pod/accept_check(obj/item/O)
	return isitem(O)

/obj/machinery/smartfridge/survival_pod/default_unfasten_wrench(mob/user, obj/item/I, time)
	return FALSE

/obj/machinery/smartfridge/survival_pod/empty
	name = "dusty survival pod storage"
	desc = "A heated storage unit. This one's seen better days."
	empty = TRUE

//Fans
/obj/structure/fans
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	icon_state = "fans"
	name = "environmental regulation system"
	desc = "A large machine releasing a constant gust of air."
	anchored = TRUE
	density = TRUE
	var/arbitraryatmosblockingvar = 1
	var/buildstacktype = /obj/item/stack/sheet/metal
	var/buildstackamount = 5

/obj/structure/fans/Initialize(mapload, loc)
	. = ..()
	recalculate_atmos_connectivity()

/obj/structure/fans/Destroy()
	arbitraryatmosblockingvar = 0
	recalculate_atmos_connectivity()
	return ..()

/obj/structure/fans/CanAtmosPass(direction)
	return !arbitraryatmosblockingvar

/obj/structure/fans/deconstruct()
	if(!(flags & NODECONSTRUCT))
		if(buildstacktype)
			new buildstacktype(loc, buildstackamount)
	qdel(src)

/obj/structure/fans/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	user.visible_message("<span class='warning'>[user] starts to disassemble [src].</span>", \
						"<span class='notice'>You start to disassemble [src]...</span>", "You hear clanking and banging noises.")
	if(!I.use_tool(src, user, 2 SECONDS, volume = 50))
		return
	user.visible_message("<span class='warning'>[user] disassembles [src].</span>", \
						"<span class='notice'>You disassemble [src].</span>", "You hear something fall on the floor.")
	deconstruct()

/obj/structure/fans/tiny
	name = "tiny fan"
	desc = "A tiny fan, releasing a thin gust of air."
	layer = TURF_LAYER+0.1
	density = FALSE
	icon_state = "fan_tiny"
	buildstackamount = 2

/obj/structure/fans/tiny/get_superconductivity(direction)
	// Mostly for stuff on Lavaland.
	return ZERO_HEAT_TRANSFER_COEFFICIENT

/obj/structure/fans/tiny/invisible
	name = "air flow blocker"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	invisibility = INVISIBILITY_ABSTRACT
//Signs
/obj/structure/sign/mining
	name = "nanotrasen mining corps sign"
	desc = "A sign of relief for weary miners, and a warning for would-be competitors to Nanotrasen's mining claims."
	icon_state = "ntpod"
	layer = TABLE_LAYER // scuffed but it works

/obj/structure/sign/mining/survival
	name = "shelter sign"
	desc = "A high visibility sign designating a safe shelter."
	icon_state = "survival"

//Fluff
/obj/structure/tubes
	icon_state = "tubes"
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	name = "tubes"
	anchored = TRUE
	layer = MOB_LAYER - 0.2

/obj/structure/tubes/wrench_act(mob/living/user, obj/item/W)
	. = TRUE
	user.visible_message("<span class='warning'>[user] disassembles [src].</span>", \
						"<span class='notice'>You start to disassemble [src]...</span>", "You hear clanking and banging noises.")
	if(!W.use_tool(src, user, 2 SECONDS, volume = 50))
		return
	new /obj/item/stack/rods(loc)
	qdel(src)

/obj/item/fakeartefact
	name = "expensive forgery"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x2"
	var/possible = list(/obj/item/ship_in_a_bottle,
						/obj/item/gun/energy/pulse,
						/obj/item/sleeping_carp_scroll,
						/obj/item/shield/changeling,
						/obj/item/lava_staff,
						/obj/item/katana/energy,
						/obj/item/hierophant_club,
						/obj/item/his_grace,
						/obj/item/gun/projectile/automatic/l6_saw,
						/obj/item/gun/magic/staff/chaos,
						/obj/item/melee/spellblade,
						/obj/item/gun/magic/wand/death,
						/obj/item/gun/magic/wand/fireball,
						/obj/item/stack/telecrystal/twenty,
						/obj/item/banhammer)

/obj/item/fakeartefact/Initialize(mapload)
	. = ..()
	var/obj/item/I = pick(possible)
	name = initial(I.name)
	icon = initial(I.icon)
	desc = initial(I.desc)
	icon_state = initial(I.icon_state)
	inhand_icon_state = initial(I.inhand_icon_state)
	lefthand_file = initial(I.lefthand_file)
	righthand_file = initial(I.righthand_file)
	slot_flags = initial(I.slot_flags)
	w_class = initial(I.w_class)

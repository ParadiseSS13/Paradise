//general-use clothing vendors, wardrobe vendors are in another file
/obj/machinery/economy/vending/assist
	ads_list = list(
		"Only the finest!",
		"Have some tools.",
		"The most robust equipment.",
		"The finest gear in space!",
	)

	products = list(
		/obj/item/assembly/prox_sensor = 4,
		/obj/item/assembly/igniter = 4,
		/obj/item/assembly/signaler = 4,
		/obj/item/wirecutters = 2,
		/obj/item/cartridge/signal = 4,
	)

	contraband = list(
		/obj/item/flashlight = 4,
		/obj/item/assembly/timer = 2,
		/obj/item/assembly/voice = 2,
		/obj/item/assembly/health = 2,
	)

	prices = list(
		/obj/item/assembly/prox_sensor = 20,
		/obj/item/assembly/igniter = 20,
		/obj/item/assembly/signaler = 30,
		/obj/item/wirecutters = 50,
		/obj/item/cartridge/signal = 75,
		/obj/item/flashlight = 40,
		/obj/item/assembly/timer = 20,
		/obj/item/assembly/voice = 20,
		/obj/item/assembly/health = 20,
	)

	refill_canister = /obj/item/vending_refill/assist
	category = VENDOR_TYPE_SUPPLIES

/obj/machinery/economy/vending/assist/free
	prices = list()

/obj/machinery/economy/vending/artvend
	name = "\improper ArtVend"
	desc = "A vending machine for art supplies."
	slogan_list = list(
		"Stop by for all your artistic needs!",
		"Color the floors with crayons, not blood!",
		"Don't be a starving artist, use ArtVend. ",
		"Don't fart, do art!",
	)

	ads_list = list(
		"Just like Kindergarten!",
		"Now with 1000% more vibrant colors!",
		"Screwing with the janitor was never so easy!",
		"Creativity is at the heart of every spessman.",
	)

	vend_delay = 15
	icon_state = "artvend"
	icon_lightmask = "artvend"
	icon_panel = "screen_vendor"
	category = VENDOR_TYPE_SUPPLIES
	products = list(
		/obj/item/stack/cable_coil/random = 10,
		/obj/item/toner = 4,
		/obj/item/camera = 4,
		/obj/item/camera_film = 6,
		/obj/item/storage/photo_album = 2,
		/obj/item/stack/wrapping_paper = 4,
		/obj/item/stack/package_wrap = 4,
		/obj/item/c_tube = 10,
		/obj/item/hand_labeler = 4,
		/obj/item/stack/tape_roll = 5,
		/obj/item/paper = 10,
		/obj/item/storage/fancy/crayons = 4,
		/obj/item/pen = 5,
		/obj/item/pen/blue = 5,
		/obj/item/pen/red = 5,
		/obj/item/pen/fancy = 2,
	)

	contraband = list(
		/obj/item/storage/toolbox/artistic = 1,
		/obj/item/toy/crayon/mime = 1,
		/obj/item/toy/crayon/rainbow = 1,
		/obj/item/poster/random_contraband = 5,
	)

	prices = list(
		/obj/item/stack/cable_coil/random = 20,
		/obj/item/toner = 40,
		/obj/item/pen/fancy = 40,
	)

/obj/machinery/economy/vending/artvend/free
	prices = list()

/obj/machinery/economy/vending/tool
	name = "\improper YouTool"
	desc = "Tools for tools."
	icon_state = "tool"
	icon_deny = "tool_deny"
	icon_lightmask = "tool"
	icon_panel = "generic"
	category = VENDOR_TYPE_SUPPLIES
	armor = list(MELEE = 50, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 0, RAD = 0, FIRE = 100, ACID = 70)
	resistance_flags = FIRE_PROOF
	products = list(
		/obj/item/crowbar = 5,
		/obj/item/screwdriver = 5,
		/obj/item/weldingtool = 3,
		/obj/item/wirecutters = 5,
		/obj/item/wrench = 5,
		/obj/item/analyzer = 5,
		/obj/item/t_scanner = 5,
		/obj/item/stack/cable_coil/random = 10,
		/obj/item/stack/cable_coil/extra_insulated = 10,
		/obj/item/clothing/gloves/color/yellow = 1,
		/obj/item/crowbar/large = 1,
	)

	contraband = list(
		/obj/item/clothing/gloves/color/fyellow = 2,
		/obj/item/weldingtool/hugetank = 2,
	)

	prices = list(
		/obj/item/crowbar = 75,
		/obj/item/screwdriver = 50,
		/obj/item/weldingtool = 100,
		/obj/item/wirecutters = 50,
		/obj/item/wrench = 75,
		/obj/item/analyzer = 25,
		/obj/item/t_scanner = 25,
		/obj/item/stack/cable_coil/random = 20,
		/obj/item/clothing/gloves/color/yellow = 250,
		/obj/item/weldingtool/hugetank = 120,
		/obj/item/crowbar/large = 150,
	)

	refill_canister = /obj/item/vending_refill/youtool

/// we want a free version for engineering to use
/obj/machinery/economy/vending/tool/free
	prices = list()
	desc = "Free Tools for tools."

/obj/machinery/economy/vending/crittercare
	name = "\improper CritterCare"
	desc = "A vending machine for pet supplies."
	slogan_list = list(
		"Stop by for all your animal's needs!",
		"Cuddly pets deserve a stylish collar!",
		"Pets in space, what could be more adorable?",
		"Freshest fish eggs in the system!",
		"Rocks are the perfect pet, buy one today!",
	)

	ads_list = list(
		"House-training costs extra!",
		"Now with 1000% more cat hair!",
		"Allergies are a sign of weakness!",
		"Dogs are man's best friend. Remember that Vulpkanin!",
		"Heat lamps for Unathi!",
		"Vox-y want a cracker?",
	)

	vend_delay = 15
	icon_state = "crittercare"
	icon_lightmask = "crittercare"
	icon_panel = "drobe"
	category = VENDOR_TYPE_SUPPLIES
	products = list(
		/obj/item/petcollar = 5,
		/obj/item/storage/firstaid/aquatic_kit/full = 5,
		/obj/item/fish_eggs/goldfish = 5,
		/obj/item/fish_eggs/clownfish = 5,
		/obj/item/fish_eggs/shark = 5,
		/obj/item/fish_eggs/feederfish = 10,
		/obj/item/fish_eggs/salmon = 5,
		/obj/item/fish_eggs/catfish = 5,
		/obj/item/fish_eggs/glofish = 5,
		/obj/item/fish_eggs/electric_eel = 5,
		/obj/item/fish_eggs/shrimp = 10,
		/obj/item/toy/pet_rock = 5,
		/obj/item/toy/pet_rock/fred = 1,
		/obj/item/toy/pet_rock/roxie = 1,
	)

	prices = list(
		/obj/item/petcollar = 75,
		/obj/item/storage/firstaid/aquatic_kit/full = 50,
		/obj/item/fish_eggs/goldfish = 10,
		/obj/item/fish_eggs/clownfish = 30,
		/obj/item/fish_eggs/shark = 30,
		/obj/item/fish_eggs/feederfish = 20,
		/obj/item/fish_eggs/salmon = 30,
		/obj/item/fish_eggs/catfish = 30,
		/obj/item/fish_eggs/glofish = 10,
		/obj/item/fish_eggs/electric_eel = 30,
		/obj/item/fish_eggs/shrimp = 10,
		/obj/item/toy/pet_rock = 50,
		/obj/item/toy/pet_rock/fred = 75,
		/obj/item/toy/pet_rock/roxie = 75,
	)

	contraband = list(/obj/item/fish_eggs/babycarp = 5)

	refill_canister = /obj/item/vending_refill/crittercare

/obj/machinery/economy/vending/crittercare/free
	prices = list()

/obj/machinery/economy/vending/cart
	name = "\improper PTech"
	desc = "Cartridges for PDA's."
	slogan_list = list("Carts to go!")

	icon_state = "cart"
	icon_lightmask = "med"
	icon_deny = "cart_deny"
	icon_panel = "wide_vendor"
	category = VENDOR_TYPE_SUPPLIES
	products = list(
		/obj/item/pda = 10,
		/obj/item/cartridge/medical = 10,
		/obj/item/cartridge/chemistry = 10,
		/obj/item/cartridge/engineering = 10,
		/obj/item/cartridge/atmos = 10,
		/obj/item/cartridge/janitor = 10,
		/obj/item/cartridge/signal/toxins = 10,
		/obj/item/cartridge/signal = 10,
		/obj/item/cartridge/chef = 10,
	)

	contraband = list(
		/obj/item/cartridge/clown = 1,
		/obj/item/cartridge/mime = 1,
	)

	prices = list(
		/obj/item/pda = 300,
		/obj/item/cartridge/medical = 200,
		/obj/item/cartridge/chemistry = 150,
		/obj/item/cartridge/engineering = 100,
		/obj/item/cartridge/atmos = 75,
		/obj/item/cartridge/janitor = 100,
		/obj/item/cartridge/signal/toxins = 150,
		/obj/item/cartridge/signal = 75,
		/obj/item/cartridge/chef = 100,
	)

	refill_canister = /obj/item/vending_refill/cart

/obj/machinery/economy/vending/cart/free
	prices = list()

/obj/machinery/economy/vending/dye_generator
	name = "Dye Generator"
	desc = "A machine that synthesizes dye and dispenses hairstyling tools. Simply insert a dye bottle and pick the color of your dreams to dispense dye."
	icon_state = "barbervend"
	icon_lightmask = "barbervend"
	category = VENDOR_TYPE_SUPPLIES
	vend_delay = 15
	products = list(
		/obj/item/scissors/barber = 3,
		/obj/item/scissors = 5,
		/obj/item/razor = 3,
		/obj/item/hair_dye_bottle = 3,
		/obj/item/reagent_containers/glass/bottle/reagent/hairgrownium = 1,
		/obj/item/reagent_containers/glass/bottle/reagent/hair_dye = 1,
		/obj/item/reagent_containers/dropper = 3,
		/obj/item/storage/box/lip_stick = 2,
	)
	contraband = list(
		/obj/item/clothing/mask/fakemoustache = 3,
		/obj/item/clothing/mask/fake_beard = 3
	)
	prices = list(
		/obj/item/scissors/barber = 50,
		/obj/item/scissors = 20,
		/obj/item/razor = 20,
		/obj/item/hair_dye_bottle = 30,
		/obj/item/reagent_containers/glass/bottle/reagent/hairgrownium = 30,
		/obj/item/reagent_containers/glass/bottle/reagent/hair_dye = 30,
		/obj/item/reagent_containers/dropper = 10,
		/obj/item/storage/box/lip_stick = 20,
		/obj/item/clothing/mask/fakemoustache = 20,
		/obj/item/clothing/mask/fake_beard = 20,
	)
	refill_canister = /obj/item/vending_refill/dye
	var/dye_color = "#FFFFFF"

/obj/machinery/economy/vending/dye_generator/update_overlays()
	. = ..()
	if(light)
		set_light(light_range_on, light_power_on, dye_color)

/obj/machinery/economy/vending/dye_generator/power_change()
	. = ..()
	if(light)
		set_light(light_range_on, light_power_on, dye_color)

/obj/machinery/economy/vending/dye_generator/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!istype(used, /obj/item/hair_dye_bottle))
		return ..()

	if(stat & (BROKEN|NOPOWER))
		to_chat(user, SPAN_WARNING("[src] can't dispense hair dye in this state!"))
		return ..()

	var/obj/item/hair_dye_bottle/dye_bottle = used
	var/temp = tgui_input_color(user, "Please select a dye color", "Dye Color", dye_color)
	if(isnull(temp)) // Decided not to.
		return ITEM_INTERACT_COMPLETE
	if(!Adjacent(user)) // No remote dye dispensing.
		return ITEM_INTERACT_COMPLETE
	if(user.l_hand != used && user.r_hand != used) // No magic tricks.
		return ITEM_INTERACT_COMPLETE
	if((stat & (BROKEN|NOPOWER)) || QDELETED(src)) // Missed your chance.
		return ITEM_INTERACT_COMPLETE
	dye_color = temp
	set_light(light_range_on, light_power_on, dye_color)
	user.visible_message(
		SPAN_NOTICE("[src] fills up [used] with the chosen color of hair dye."),
		SPAN_NOTICE("[src] fills up [used] with your chosen color of hair dye."),
		SPAN_HEAR("[src] whirrs quietly as it dispenses some foam.")
	)
	dye_bottle.dye_color = dye_color
	dye_bottle.update_icon()
	dye_bottle.add_fingerprint(user)
	return ITEM_INTERACT_COMPLETE

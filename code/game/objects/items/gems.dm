//rare and valulable gems- designed to eventually be used for archeology, or to be given as opposed to money as loot. Auctioned off at export, or kept as a trophy. -MemedHams

/obj/item/gem
	name = "\improper gem"
	desc = "Oooh! Shiny!"
	icon = 'icons/obj/lavaland/gems.dmi'
	icon_state = "rupee"
	w_class = WEIGHT_CLASS_SMALL

	///have we been analysed with a mining scanner?
	var/analysed = FALSE
	///how many points we grant to whoever discovers us
	var/point_value = 100
	///what's our real name that will show upon discovery? null to do nothing
	var/true_name
	///the message given when you discover this gem.
	var/analysed_message = null
	///the thing that spawns in the item.
	var/sheet_type = null
	///how many cargo point we will get from sending this to station
	var/sell_value = 100

	var/image/shine_overlay //shows this overlay when not scanned

/obj/item/gem/Initialize()
	. = ..()
	shine_overlay = image(icon = 'icons/obj/lavaland/gems.dmi',icon_state = "shine")
	add_overlay(shine_overlay)
	pixel_x = rand(-8,8)
	pixel_y = rand(-8,8)

/obj/item/gem/attackby(obj/item/item, mob/living/user, params) //Stolen directly from geysers, removed the internal gps
	if(!istype(item, /obj/item/mining_scanner) && !istype(item, /obj/item/t_scanner/adv_mining_scanner))
		return ..()

	if(analysed)
		to_chat(user, span_warning("This gem has already been analysed!"))
		return

	to_chat(user, span_notice("You analyse the precious gemstone!"))
	if(analysed_message)
		to_chat(user, analysed_message)

	analysed = TRUE
	if(true_name)
		name = true_name

	if(shine_overlay)
		cut_overlay(shine_overlay)
		qdel(shine_overlay)

	if(isliving(user))
		var/mob/living/living = user

		var/obj/item/card/id/card = living.get_id_card()
		if(card)
			to_chat(user, span_notice("[point_value] mining points have been paid out!"))
			card.mining_points += point_value
			playsound(src, 'sound/machines/ping.ogg', 15, TRUE)

/obj/item/gem/welder_act(mob/living/user, obj/item/I) //Jank code that detects if the gem in question has a sheet_type and spawns the items specifed in it
	if(I.use_tool(src, user, 0, volume=50))
		if(src.sheet_type)
			new src.sheet_type(user.loc)
			to_chat(user, span_notice("You carefully cut [src]."))
			qdel(src)
		else
			to_chat(user, span_notice("You can't seem to cut [src]."))
	return TRUE

/obj/item/gem/rupee
	name = "\improper ruperium crystal"
	desc = "A radioactive, crystalline compound rarely found in the goldgrubs. While able to be cut into sheets of uranium, the mineral's true value is in its resonating, humming properties, often sought out by musicians to work into their gem-encrusted instruments."
	icon_state = "rupee"
	materials = list(MAT_URANIUM = 20000)
	sheet_type = /obj/item/stack/sheet/mineral/uranium{amount = 10}
	point_value = 800
	sell_value = 300

/obj/item/gem/magma
	name = "\improper calcified auric"
	desc = "A hot, lightly glowing mineral born from the inner workings of magmawing watchers. It is most commonly smelted down into deposits of pure gold."
	icon_state = "magma"
	materials = list(MAT_GOLD = 50000)
	sheet_type = /obj/item/stack/sheet/mineral/gold{amount = 25}
	point_value = 250 //prevent farming from tendrills
	sell_value = 150
	light_range = 2
	light_power = 1
	light_color = "#ff7b00"

/obj/item/gem/fdiamond
	name = "\improper frost diamond"
	desc = "A unique diamond that is produced within icewing watchers. It looks like it can be cut into smaller sheets of diamond ore."
	icon_state = "diamond"
	materials = list(MAT_DIAMOND = 30000)
	sheet_type = /obj/item/stack/sheet/mineral/diamond{amount = 15}
	point_value = 1200
	sell_value = 600

/obj/item/gem/phoron
	name = "\improper stabilized baroxuldium"
	desc = "A soft, glowing crystal only found in the deepest veins of plasma. It looks like it could be destructively analyzed to extract the condensed materials within."
	icon_state = "phoron"
	materials = list(MAT_PLASMA = 80000)
	sheet_type = /obj/item/stack/sheet/mineral/plasma{amount = 40}
	point_value = 2400
	sell_value = 800
	light_range = 2
	light_power = 2
	light_color = "#62326a"

/obj/item/gem/purple
	name = "\improper densified dilithium"
	desc = "A strange mass of dilithium which pulses to a steady rhythm. Its strange surface exudes a unique radio signal detectable by GPS."
	icon_state = "purple"
	point_value = 2600
	sell_value = 900
	light_range = 2
	light_power = 1
	light_color = "#b714cc"

	var/obj/item/gps/internal

/obj/item/gem/purple/Initialize()
	. = ..()
	internal = new /obj/item/gps/internal/purple(src)

/obj/item/gps/internal/purple
	icon_state = null
	gpstag = "Harmonic Signal"
	desc = "It's ringing."
	invisibility = 100

/obj/item/gem/amber
	name = "\improper draconic amber"
	desc = "A brittle, strange mineral that forms when an ash drake's blood hardens after death. Cherished by gemcutters for its faint glow and unique, soft warmth. Poacher tales whisper of the dragon's strength being bestowed to one that wears a necklace of this amber, though such rumors are fictitious."
	icon_state = "amber"
	point_value = 2600
	sell_value = 1200
	light_range = 2
	light_power = 2
	light_color = "#FFBF00"

/obj/item/gem/void
	name = "\improper null crystal"
	desc = "A shard of stellar, crystallized energy. These strange objects occasionally appear spontaneously in areas where the bluespace fabric is largely unstable. Its surface gives a light jolt to those who touch it."
	icon_state ="void"
	point_value = 2400
	sell_value = 1100
	light_range = 2
	light_power = 1
	light_color = "#4785a4"

/obj/item/gem/bloodstone
	name = "\improper ichorium"
	desc = "A weird, sticky substance, known to coalesce in the presence of otherwordly phenomena. While shunned by most spiritual groups, this gemstone has unique ties to the occult which find it handsomely valued by mysterious patrons."
	icon_state = "red"
	point_value = 3000
	sell_value = 1500
	light_range = 2
	light_power = 3
	light_color = "#800000"

/obj/item/gem/data
	name = "\improper bluespace data crystal"
	desc = "A large bluespace crystal, etched internally with nano-circuits, it seemingly draws power from nowhere."
	icon_state = "data"
	materials = list(MAT_BLUESPACE = 24000)
	sheet_type = /obj/item/stack/sheet/bluespace_crystal{amount = 12}
	origin_tech = "materials=6;bluespace=7" //uh-oh
	light_range = 2
	light_power = 6
	light_color = "#0004ff"
	point_value = 2500
	sell_value = 1800

/obj/item/gem/random
	name = "random gem"
	icon_state = "ruby"
	var/gem_list = list(/obj/item/gem/ruby, /obj/item/gem/sapphire, /obj/item/gem/emerald, /obj/item/gem/topaz)

/obj/item/gem/random/Initialize(quantity)
	. = ..()
	var/q = quantity ? quantity : 1
	for(var/i = 0, i < q, i++)
		var/obj/item/gem/G = pick(gem_list)
		new G(loc)
	qdel(src)

/obj/item/gem/ruby
	name = "\improper ruby"
	icon_state = "ruby"
	point_value = 150
	sell_value = 75

/obj/item/gem/sapphire
	name = "\improper sapphire"
	icon_state = "sapphire"
	point_value = 150
	sell_value = 75

/obj/item/gem/emerald
	name = "\improper emerald"
	icon_state = "emerald"
	point_value = 150
	sell_value = 75

/obj/item/gem/topaz
	name = "\improper topaz"
	icon_state = "topaz"
	point_value = 150
	sell_value = 75

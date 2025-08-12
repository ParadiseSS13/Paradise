
/// A "supply pack" that allows for purchasing a custom shuttle.
/datum/supply_packs/abstract/shuttle
	name = "Custom Shuttle"
	cost = 1
	containertype = null
	group = SUPPLY_SHUTTLE
	singleton = TRUE
	singleton_group_id = "shuttle"
	department_restrictions = list(DEPARTMENT_COMMAND)
	// these are special, but start enabled. As soon as one is ordered, all variants of this should be disabled.
	special = TRUE
	special_enabled = TRUE
	/// The shuttle that this pack corresponds to ordering.
	/// If given on init, will fill out the pack automagically.
	var/datum/map_template/shuttle/template
	/// The base speed multiplier to apply to the shuttle. 2 means it arrives twice as fast.
	var/speed_factor = 1

/datum/supply_packs/abstract/shuttle/New(datum/map_template/shuttle/_template)
	. = ..()
	if(_template)
		template = _template
	if(template)
		if(ispath(template))
			template = new template()
		name = template.name
		manifest = template.description
		ui_manifest = list(manifest)

/datum/supply_packs/abstract/shuttle/Destroy(force, ...)
	. = ..()
	qdel(template)

/datum/supply_packs/abstract/shuttle/can_order()
	// check here so people don't spend their money on it
	return (SSshuttle.emergency?.mode == SHUTTLE_IDLE)

/datum/supply_packs/abstract/shuttle/on_order_confirm(datum/supply_order/order)
	. = ..()
	if(SSshuttle.custom_shuttle_ordered)
		return
	if(SSshuttle.emergency_locked_in)
		return
	if(isnull(template))
		CRASH("Shuttle pack [src] has no map template to load!")
	GLOB.major_announcement.Announce("[order.orderedby] has purchased [name] for [cost] credit\s as the emergency shuttle for the shift.", "Shuttle Purchase Receipt")
	var/orderer = order.orderedby
	log_and_message_admins("Shuttle pack [src] costing [cost] has been ordered and paid for by [orderer] ([order.orderedbyRank])")
	for(var/pack_key in SSeconomy.supply_packs)
		var/datum/supply_packs/abstract/shuttle/SP = SSeconomy.supply_packs[pack_key]
		if(!istype(SP))
			continue
		SP.special_enabled = FALSE
	SSshuttle.custom_shuttle_ordered = TRUE
	var/obj/docking_port/mobile/shuttle = SSshuttle.load_template(template)
	shuttle.shuttle_speed_factor = speed_factor
	SSshuttle.replace_shuttle(shuttle)
	SSshuttle.emergency_locked_in = TRUE
	return TRUE

/// Simple supply pack for easy admin modification
/datum/supply_packs/abstract/admin_notify/donations
	name = "Donation to Lonely Corgi Foundation"
	special = TRUE
	manifest = "1% of every donation goes towards supporting corgis in need."
	cost = 500

// these ones are pretty reasonable

/datum/supply_packs/abstract/shuttle/bar
	cost = 3250
	template = /datum/map_template/shuttle/emergency/bar

/datum/supply_packs/abstract/shuttle/dept
	cost = 3000
	template = /datum/map_template/shuttle/emergency/dept

/datum/supply_packs/abstract/shuttle/old
	cost = 2500
	template = /datum/map_template/shuttle/emergency/old

/datum/supply_packs/abstract/shuttle/military
	cost = 3500
	template = /datum/map_template/shuttle/emergency/military

// if you can pool enough money together for this one, maybe you deserve it

/datum/supply_packs/abstract/shuttle/raven
	cost = 4500 //I do wonder about shuttle prices, especially considering how many guns you could get for this price. Perhaps a lowering in the future.
	template = /datum/map_template/shuttle/emergency/raven

/datum/supply_packs/abstract/shuttle/shadow
	cost = 3250
	template = /datum/map_template/shuttle/emergency/shadow
	speed_factor = 2 //Fast enough that it probably won't burn down entirely after the crew looses the plasma

/datum/supply_packs/abstract/shuttle/cherenkov
	cost = 3250
	template = /datum/map_template/shuttle/emergency/cherenkov
	speed_factor = 2 // Speedy enough to not explode during the round trip.

/datum/supply_packs/abstract/shuttle/lance
	cost = 5000 //please don't order this for funny please sir
	template = /datum/map_template/shuttle/emergency/lance
	speed_factor = 1.5 //Don't need to slow down before docking
	are_you_sure_you_want_to_be_banned = "If you are not an antagonist, and you are ordering this shuttle for no valid reason, you will be banned, or job banned. If you are an antagonist, ahelp for permision, unless you are a hijacker, or you will be antagonist banned. If you are unsure, ahelp now."

/datum/supply_packs/abstract/shuttle/lance/on_order_confirm(datum/supply_order/order)
	. = ..()
	if(!.)
		return
	if(order.orderedby)
		for(var/mob/living/carbon/human/H in GLOB.human_list)
			if(H.name == order.orderedby)
				new /obj/item/lance_docking_generator(get_turf(H))
				GLOB.major_announcement.Announce("[order.orderedby] has had a beacon placer teleported to them!", "Shuttle Purchase Receipt")
				return TRUE
	GLOB.major_announcement.Announce("We were unable to find an orderer. We have sent the beacon placer to the Cargo Office.", "Shuttle Purchase Receipt")
	var/list/L = list()
	for(var/turf/T in get_area_turfs(/area/station/supply/office))
		if(T.is_blocked_turf())
			continue
		L.Add(T)

	if(!length(L))
		GLOB.major_announcement.Announce("We... couldn't find cargo? Well. We'll crash somewhere into your station.", "WELP")
		return TRUE

	new /obj/item/lance_docking_generator(pick(L))
	return TRUE

// these, otoh, have some pretty silly features, and are hidden behind emag
/datum/supply_packs/abstract/shuttle/clockwork
	cost = 3000
	hidden = TRUE
	template = /datum/map_template/shuttle/emergency/clockwork

/datum/supply_packs/abstract/shuttle/narnar
	cost = 3000
	hidden = TRUE
	template = /datum/map_template/shuttle/emergency/narnar

/datum/supply_packs/abstract/shuttle/jungle
	hidden = TRUE
	cost = 4000
	template = /datum/map_template/shuttle/emergency/jungle

// these are hidden behind cmag

/datum/supply_packs/abstract/shuttle/clown
	speed_factor = 0.75  // this one's a little slower, enjoy your ride!
	cmag_hidden = TRUE
	cost = 500  // let the clown have it
	template = /datum/map_template/shuttle/emergency/clown

/datum/supply_packs/abstract/shuttle/cramped
	cost = 3750
	cmag_hidden = TRUE
	template = /datum/map_template/shuttle/emergency/cramped

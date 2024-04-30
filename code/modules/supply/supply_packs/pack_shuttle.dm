
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

/// Simple supply pack for easy admin modification
/datum/supply_packs/abstract/admin_notify/donations
	name = "Donation to Lonely Corgi Foundation"
	special = TRUE
	special_enabled = FALSE
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

// this one isn't great but it isn't horrible either

/datum/supply_packs/abstract/shuttle/cramped
	cost = 3750
	template = /datum/map_template/shuttle/emergency/cramped

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

// these, otoh, have some pretty silly features, and are hidden behind emag

/datum/supply_packs/abstract/shuttle/clown
	speed_factor = 0.75  // this one's a little slower, enjoy your ride!
	cmag_hidden = TRUE
	cost = 500  // let the clown have it
	template = /datum/map_template/shuttle/emergency/clown

/datum/supply_packs/abstract/shuttle/narnar
	cost = 3000
	hidden = TRUE
	template = /datum/map_template/shuttle/emergency/narnar

/datum/supply_packs/abstract/shuttle/jungle
	hidden = TRUE
	cost = 4000
	template = /datum/map_template/shuttle/emergency/jungle

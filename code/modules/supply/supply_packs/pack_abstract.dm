/// Abstract supply packs that don't contain any goods, but instead represent purchases that cargo can make.


/// A "supply pack" that allows for purchasing a custom shuttle.
/datum/supply_packs/abstract/shuttle
	name = "HEADER"
	cost = 1
	containertype = null
	group = SUPPLY_SHUTTLE
	department_restrictions = list(DEPARTMENT_COMMAND)
	// these are special, but start enabled. As soon as one is ordered, all variants of this should be disabled.
	special = TRUE
	special_enabled = TRUE  // TODO come up with a better way of blacklisting intermediate types
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
	if(isnull(template))
		CRASH("Shuttle pack [src] has no map template to load!")
	GLOB.major_announcement.Announce("[order.orderedby] has purchased [name] for [cost] credit\s as the emergency shuttle for the shift.", "Shuttle Purchase Receipt")
	var/orderer = order.orderedby
	log_and_message_admins("Shuttle pack [src] costing [cost] has been ordered and paid for by [orderer] ([order.orderedbyRank])")
	for(var/datum/supply_packs/abstract/shuttle/emergency/shuttle_pack in SSeconomy.supply_packs)
		shuttle_pack.special_enabled = FALSE
	SSshuttle.custom_shuttle_ordered = TRUE
	// var/datum/map_template
	// TODO prevent this from happening while someone else is modifying it, or while it's not at centcomm
	// probably should do this in a way that prevents people from buying it
	var/obj/docking_port/mobile/emergency/shuttle = SSshuttle.load_template(template)
	shuttle.shuttle_speed_factor = speed_factor
	SSshuttle.replace_shuttle(shuttle)

/datum/supply_packs/abstract/admin_notify/donations
	name = "Donation to Lonely Corgi Foundation"
	manifest = "1% of every donation goes towards supporting corgis in need."
	cost = 500

/datum/supply_packs/abstract/shuttle/emergency
	// This one is here so the remaining ones don't get filtered out on init due to having no name.
	// This would also be a good place to slot any custom admin shuttles.
	name = "Custom Emergency Shuttle"
	special_enabled = TRUE

/datum/supply_packs/abstract/shuttle/emergency/bar
	template = /datum/map_template/shuttle/emergency/bar

/datum/supply_packs/abstract/shuttle/emergency/dept
	template = /datum/map_template/shuttle/emergency/dept

/datum/supply_packs/abstract/shuttle/emergency/dept
	template = /datum/map_template/shuttle/emergency/military

/datum/supply_packs/abstract/shuttle/emergency/clown
	speed_factor = 5
	template = /datum/map_template/shuttle/emergency/clown

/datum/supply_packs/abstract/shuttle/emergency/cramped
	template = /datum/map_template/shuttle/emergency/cramped

/datum/supply_packs/abstract/shuttle/emergency/narnar
	template = /datum/map_template/shuttle/emergency/narnar

/datum/supply_packs/abstract/shuttle/emergency/old
	template = /datum/map_template/shuttle/emergency/old

/datum/supply_packs/abstract/shuttle/emergency/jungle
	template = /datum/map_template/shuttle/emergency/jungle

/datum/supply_packs/abstract/shuttle/emergency/yaya
	template = /datum/map_template/shuttle/admin/skipjack

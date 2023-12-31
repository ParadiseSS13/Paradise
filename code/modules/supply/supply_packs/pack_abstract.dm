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
	special_enabled = TRUE
	/// The shuttle that this pack corresponds to ordering.
	/// If given on init, will fill out the pack automagically.
	var/datum/map_template/shuttle/template

/datum/supply_packs/abstract/shuttle/New(datum/map_template/shuttle/_template)
	. = ..()
	if(_template)
		template = _template
	if(template)
		name = template.name
		manifest = template.description
		ui_manifest = list(manifest)

/datum/supply_packs/abstract/shuttle/on_order_confirm(datum/supply_order/order)
	. = ..()
	GLOB.major_announcement.Announce("[order.orderedby] has purchased [name] for [cost] credit\s as the emergency shuttle for the shift.", "Shuttle Purchase Receipt")
	for(var/datum/supply_packs/abstract/shuttle/emergency/shuttle_pack in SSeconomy.supply_packs)
		shuttle_pack.special_enabled = FALSE
	SSshuttle.custom_shuttle_ordered = TRUE



/datum/supply_packs/abstract/admin_notify/donations
	name = "Donation"
	cost = 500

/datum/supply_packs/abstract/shuttle/emergency
	/// This one is here so the remaining ones don't get filtered out on init due to having no name.
	name = "Custom Emergency Shuttle"

/datum/supply_packs/abstract/shuttle/emergency/bar
	template = /datum/map_template/shuttle/emergency/bar

/datum/supply_packs/abstract/shuttle/emergency/dept
	template = /datum/map_template/shuttle/emergency/dept

/datum/supply_packs/abstract/shuttle/emergency/dept
	template = /datum/map_template/shuttle/emergency/military

/datum/supply_packs/abstract/shuttle/emergency/clown
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

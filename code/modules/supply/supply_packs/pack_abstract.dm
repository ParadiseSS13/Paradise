/// Abstract supply packs that don't contain any goods, but instead represent purchases that cargo can make.


/// A supply pack that does not contain physical objects, but instead fires some sort of callback when ordered.
/datum/supply_packs/abstract

/datum/supply_packs/abstract/New()
	. = ..()
	ui_manifest = list(manifest)

/datum/supply_packs/abstract/create_package(turf/spawn_location)
	return

/// A sample supply pack that notifies admins when it is purchased, but provides no items.
/datum/supply_packs/abstract/admin_notify

/datum/supply_packs/abstract/admin_notify/on_order_confirm(datum/supply_order/order)
	var/mob/orderer = order.orderedby
	var/order_rank = order.orderedbyRank
	message_admins("Admin-notify pack [src] costing [cost] has been ordered and paid for by [orderer] ([order_rank])")


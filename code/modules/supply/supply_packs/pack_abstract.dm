/// Abstract supply packs that don't contain any goods, but instead represent purchases that cargo can make.


/// A "supply pack" that allows for purchasing a custom shuttle.
/datum/supply_packs/abstract/shuttle
	name = "HEADER"
	containertype = null
	group = SUPPLY_SHUTTLE
	department_restrictions = list(DEPARTMENT_COMMAND)
	// these are special, but start enabled. As soon as one is ordered, all variants of this should be disabled.
	special = TRUE
	special_enabled = TRUE
	/// The shuttle that this pack corresponds to ordering.
	var/shuttle_name

/datum/supply_packs/abstract/shuttle/on_order_confirm()
	. = ..()
	GLOB.major_announcement.Announce()
	for(var/datum/supply_packs/abstract/shuttle/shuttle_pack in SSeconomy.supply_packs)
		shuttle_pack.special_enabled = FALSE



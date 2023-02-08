/datum/supply_order
	///The orders ID number
	var/ordernum
	///The supply pack this order is for
	var/datum/supply_packs/object
	///The person who ordered the supply order
	var/orderedby
	///The occupation/assignment of the person who ordered the supply order
	var/orderedbyRank
	///The account tied to this order, important for personal orders
	var/orderedbyaccount
	///The station department datum of the person's department who ordered the supply order
	var/datum/station_department/ordered_by_department
	///Reason/purpose for order given by orderer
	var/comment
	///does this order need to be approve by the department head?
	var/requires_head_approval = FALSE
	///does this order need to be approve by carg?
	var/requires_cargo_approval = FALSE

/obj/item/paper/request_form
	name = "request form"
	var/order_number

/datum/supply_order/proc/createObject(atom/_loc, errors = 0)
	if(!object)
		return

	//create the crate
	var/obj/structure/closet/crate/crate = new object.containertype(_loc)
	crate.name = "[object.containername] [comment ? "([comment])":"" ]"
	if(object.access)
		crate.req_access = list(text2num(object.access))

	//create the manifest slip
	var/obj/item/paper/manifest/slip = new
	slip.points = object.cost
	slip.ordernumber = ordernum

	var/stationName = station_name()
	var/packagesAmt = length(SSeconomy.shopping_list)

	slip.name = "Shipping Manifest - '[object.name]' for [orderedby]"
	slip.info = "<h3>NAS Trurl Shipping Manifest</h3><hr><br>"
	slip.info += "Order: #[ordernum]<br>"
	slip.info += "Destination: [stationName]<br>"
	slip.info += "Requested By: [orderedby]<br>"
	slip.info += "Rank: [orderedbyRank]<br>"
	slip.info += "Reason: [comment]<br>"
	slip.info += "Supply Crate Type: [object.name]<br>"
	slip.info += "Access Restriction: [object.access ? get_access_desc(object.access) : "None"]<br>"
	slip.info += "[packagesAmt] PACKAGES IN THIS SHIPMENT<br>"
	slip.info += "CONTENTS:<br><ul>"

	//we now create the actual contents
	var/list/contains = list()
	if(istype(object, /datum/supply_packs/misc/randomised))
		var/datum/supply_packs/misc/randomised/SO = object
		contains = list()
		if(length(object.contains))
			for(var/j in 1 to SO.num_contained)
				contains += pick(object.contains)
	else
		contains = object.contains

	for(var/typepath in contains)
		if(!typepath)
			continue
		var/atom/A = new typepath(crate)
		if(object.amount && A.vars.Find("amount") && A:amount)
			A:amount = object.amount
		slip.info += "<li>[A.name]</li>"	//add the item to the manifest (even if it was misplaced)

	if(istype(crate, /obj/structure/closet/critter)) // critter crates do not actually spawn mobs yet and have no contains var, but the manifest still needs to list them
		var/obj/structure/closet/critter/CritCrate = crate
		if(CritCrate.content_mob)
			var/mob/crittername = CritCrate.content_mob
			slip.info += "<li>[initial(crittername.name)]</li>"

	//manifest finalisation
	slip.info += "</ul><br>"
	slip.info += "CHECK CONTENTS AND STAMP BELOW THE LINE TO CONFIRM RECEIPT OF GOODS<hr>" // And now this is actually meaningful.
	slip.loc = crate
	if(istype(crate, /obj/structure/closet/crate))
		var/obj/structure/closet/crate/CR = crate
		CR.manifest = slip
		CR.update_icon()
		CR.announce_beacons = object.announce_beacons.Copy()
	if(istype(crate, /obj/structure/largecrate))
		var/obj/structure/largecrate/LC = crate
		LC.manifest = slip
		LC.update_icon()

	return crate

/obj/item/paper/manifest
	name = "supply manifest"
	var/points = 0
	var/ordernumber = 0

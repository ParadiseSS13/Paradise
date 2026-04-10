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

/// Set the account that made the request and make sure the request is deleted when the account is deleted
/datum/supply_order/proc/set_account(datum/money_account/account)
	orderedbyaccount = account
	RegisterSignal(orderedbyaccount, COMSIG_PARENT_QDELETING, PROC_REF(clear_request))

/// Clear the request from the request list so it's not permanently stuck in the console
/datum/supply_order/proc/clear_request()
	SSeconomy.request_list -= src

/datum/supply_order/proc/createObject(atom/_loc, errors = 0)
	if(!object)
		return

	//create the crate
	var/obj/structure/closet/crate/crate = object.create_package(_loc)

	if(comment)
		crate.name = "[crate.name] ([comment])"

	//create the manifest slip
	var/obj/item/paper/manifest/slip = new
	slip.points = object.get_cost()
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

	for(var/atom/A in crate.contents)
		slip.info += "<li>[A.name]</li>"

	var/special_content = object.get_special_manifest()
	if(special_content)
		slip.info += "<li>[special_content]</li>"

	if(istype(crate, /obj/structure/closet/critter)) // critter crates do not actually spawn mobs yet and have no contains var, but the manifest still needs to list them
		var/obj/structure/closet/critter/CritCrate = crate
		if(CritCrate.content_mob)
			var/mob/crittername = CritCrate.content_mob
			slip.info += "<li>[initial(crittername.name)]</li>"

	//manifest finalisation
	slip.info += "</ul><br>"
	slip.info += "CHECK CONTENTS AND STAMP BELOW THE LINE TO CONFIRM RECEIPT OF GOODS<hr>" // And now this is actually meaningful.
	slip.update_icon()
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

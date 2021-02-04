/***************************************************************
**						Design Datums						  **
**	All the data for building stuff. **
***************************************************************/
/*
For the materials datum, it assumes you need reagents unless specified otherwise. To designate a material that isn't a reagent,
you use one of the material IDs below. These are NOT ids in the usual sense (they aren't defined in the object or part of a datum),
they are simply references used as part of a "has materials?" type proc. They all start with a $ to denote that they aren't reagents.
The currently supporting non-reagent materials:
- MAT_METAL (/obj/item/stack/metal).
- MAT_GLASS (/obj/item/stack/glass).
- MAT_PLASMA (/obj/item/stack/plasma).
- MAT_SILVER (/obj/item/stack/silver).
- MAT_GOLD (/obj/item/stack/gold).
- MAT_URANIUM (/obj/item/stack/uranium).
- MAT_DIAMOND (/obj/item/stack/diamond).
- MAT_BANANIUM (/obj/item/stack/bananium).
- MAT_TRANQUILLITE (/obj/item/stack/tranquillite).
(Insert new ones here)

Don't add new keyword/IDs if they are made from an existing one (such as rods which are made from metal). Only add raw materials.

Design Guidlines
- When adding new designs, check rdreadme.dm to see what kind of things have already been made and where new stuff is needed.
- A single sheet of anything is 2000 units of material. Materials besides metal/glass require help from other jobs (mining for
other types of metals and chemistry for reagents).
- Add the AUTOLATHE tag to


*/

//DESIGNS ARE GLOBAL. DO NOT CREATE OR DESTROY THEM AT RUNTIME OUTSIDE OF INIT, JUST REFERENCE THEM TO WHATEVER YOU'RE DOING!
//DO NOT REFERENCE OUTSIDE OF SSRESEARCH. USE THE PROCS IN SSRESEARCH TO OBTAIN A REFERENCE.

/datum/design
	/// Name of the created object.
	var/name = "Name"
	/// Description of the created object.
	var/desc = "Desc"
	/// ID of the created object for easy refernece. Alphanumeric, lower-case, no symbols
	var/id = DESIGN_ID_IGNORE
	/// Flag as to what kind machine the design is built in. See defines.
	var/build_type = null
	/// List of materials. Format: "id" = amount.
	var/list/materials = list()
	/// Amount of time required for building the object. Used on mechfabs
	var/construction_time
	/// The typepath of the object that gets created
	var/build_path = null
	/// Reagents produced. Format: "id" = amount. Currently only supported by the biogenerator.
	var/list/make_reagents = list()
	/// If locked is TRUE, it will spawn the built item inside a lockbox with currently sec access
	var/locked = FALSE
	/// If a lockbox is needed, what special access requirements will the lockbox have? Defaults to armory.
	var/access_requirement = list(ACCESS_ARMORY)
	/// Item category in the UI
	var/category = null
	/// List of reagents. Format: "id" = amount.
	var/list/reagents_list = list()
	/// Max stack somehting can be printed in (Mainly used in autolathes)
	var/maxstack = 1
	/// How many times faster than normal is this to build on the protolathe
	var/lathe_time_factor = 1
	/// Should this design warn admins on construction
	var/warn_on_construct = FALSE

/datum/design/error_design
	name = "ERROR"
	desc = "This usually means something in the database has corrupted. If this doesn't go away automatically, inform Central Comamnd so their techs can fix this ASAP(tm)"

/datum/design/Destroy()
	SSresearch.techweb_designs -= id
	return ..()

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

/datum/design						//Datum for object designs, used in construction
	var/name = "Name"					//Name of the created object.
	var/desc = "Desc"					//Description of the created object.
	var/id = "id"						//ID of the created object for easy refernece. Alphanumeric, lower-case, no symbols
	var/list/req_tech = list()			//IDs of that techs the object originated from and the minimum level requirements.
	var/build_type = null				//Flag as to what kind machine the design is built in. See defines.
	var/list/materials = list()			//List of materials. Format: "id" = amount.
	var/construction_time				//Amount of time required for building the object
	var/build_path = null				//The file path of the object that gets created
	var/list/make_reagents = list()			//Reagents produced. Format: "id" = amount. Currently only supported by the biogenerator.
	var/locked = 0						//If true it will spawn inside a lockbox with currently sec access
	var/access_requirement = list(access_armory) //What special access requirements will the lockbox have? Defaults to armory.
	var/category = null //Primarily used for Mech Fabricators, but can be used for anything
	var/list/reagents_list = list()			//List of reagents. Format: "id" = amount.
	var/maxstack = 1
	var/lathe_time_factor = 1			//How many times faster than normal is this to build on the protolathe

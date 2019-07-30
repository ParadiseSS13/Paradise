/////////////////////////////////////LOOT DEFINER/////////////////////////////////////
// Holds all the messy stuff to do with name and type picking, loot lists etc.
// define() returns a named unboxed item based on stats and loot lists.
// The actual items and their purposes should be defined elsewhere,
// though they can be initialized here as part of the loot picking.
//
// Expansion sections (Searchable):
// O.   LEAVE THIS PART ALONE
// I.   LOOT LIST
// II.  LOOT DEFINITIONS
// III. SECOND NAME
// IV.  THIRD NAME
// V.   DESCRIPTION


#define RARITY_COMMON 0
#define RARITY_UNCOMMON 1
#define RARITY_RARE 2
#define RARITY_VERYRARE 3

//////////////////////// O. LEAVE THIS PART ALONE //////////////////////////
// Unless you have a good idea of how this works.
// If you're just adding new loot you shouldn't have to touch this.

/obj/experimentor/loot_definer
    name = "loot definer"
    desc = "If you can see this, something is very, very wrong."
    var/stability = 0
    var/potency = 0
    var/raritylevel = 0
    var/box_type
    var/item_category
    var/item_type
    var/obj/loot_item

    // Set to FALSE during item definition to use the default name or description for the new object.
    var/loot_named
    var/loot_described
    // Keywords used to choose names for the second and third parts of the generated name.
    // When defining new keywords, try to use ones that fit in the auto-generated descriptions.
    var/list/loot_keywords
    // Unique Names - If instantiated in the definition, will use one of the contained names instead of generating the third name.
    var/list/unique_names

// Returns a finished item from the stats supplied to the experimentor.
/obj/experimentor/loot_definer/proc/define(var/stability_in, var/potency_in, var/base_name, var/rare_level, var/itemcategory)
	stability = stability_in
	potency = potency_in
	raritylevel = rare_level
	box_type = base_name
	item_category = itemcategory
	loot_named = TRUE
	loot_described = TRUE
	loot_keywords = new/list
	unique_names = null

    // determine what specific type (itemtype) the item is based on.
	item_type = findItemType()
    // define the item to be granted as loot.
	loot_item = definitionByType()
	// name and describe the item unless the definition says not to.
	if(loot_named && loot_item != null)
		loot_item.name = box_type + " [generateSecondName()][generateThirdName()]"
	if(loot_described && loot_item != null)
		loot_item.desc = generateDescription()
	return loot_item


///////////////////I. LOOT LIST////////////////////
// Defines the loot lists for the experimentor
// by category then by rarity.

/obj/experimentor/loot_definer/proc/findItemType()
    switch (item_category)
        // Broad category list
        if("Device")
            // Lists by rarity.
            if(raritylevel == RARITY_COMMON)
                return pick("rapiddupe", "throwSmoke", "floofcannon", "teleport", "nothing")
            if(raritylevel == RARITY_UNCOMMON)
                return pick("teleport", "rapiddupe", "explode", "petSpray", "flash", "clean")
            if(raritylevel == RARITY_RARE)
                return pick("explode", "petSpray", "rapiddupe", "flash", "teleport")
            if(raritylevel == RARITY_VERYRARE)
                return pick("teleport", "explode", "rapiddupe")
    return


///////////////////// II. LOOT DEFINITIONS /////////////////////
// This is what defines the object that actually gets returned.
// Responsible for creating the object, populating its keywords
// for naming and so on. set loot_named to FALSE if the item has
// a unique name that you don't want to use the generator for.

/obj/experimentor/loot_definer/proc/definitionByType()
    // Switch here mostly for our benefit to break up categories.
    // Try to keep your loot and device types in alphabetical order.
    switch(item_category)
        if("Device")
            switch(item_type)
                if("clean")
                    loot_keywords.Add("destruction")
                    return new/obj/item/discovered_tech(stability, potency, raritylevel, item_type)
                if("explode")
                    loot_keywords.Add("destruction", "sound")
                    return new/obj/item/discovered_tech(stability, potency, raritylevel, item_type)
                if("flash")
                    loot_keywords.Add("stun", "light", "sound")
                    return new/obj/item/discovered_tech(stability, potency, raritylevel, item_type)
                if("floofcannon")
                    loot_keywords.Add("animals", "replication")
                    return new/obj/item/discovered_tech(stability, potency, raritylevel, item_type)
                if("nothing")
                    loot_keywords.Add("clowns")
                    return new/obj/item/discovered_tech(stability, potency, raritylevel, item_type)
                if("petSpray")
                    loot_keywords.Add("animals", "replication")
                    return new/obj/item/discovered_tech(stability, potency, raritylevel, item_type)
                if("rapiddupe")
                    loot_keywords.Add("replication")
                    unique_names = list("Fabritron", "Mitosinator")
                    return new/obj/item/discovered_tech(stability, potency, raritylevel, item_type)
                if("teleport")
                    loot_keywords.Add("teleportation", "bluespace")
                    return new/obj/item/discovered_tech(stability, potency, raritylevel, item_type)
                if("throwSmoke")
                    loot_keywords.Add("destruction", "light")
                    return new/obj/item/discovered_tech(stability, potency, raritylevel, item_type)


//////////////////III. SECOND NAME////////////////////
// Each revealed object has 3 parts to its name.
// This defines the second section based on keywords
// and also the general rarity of the item.
//
// NOTE: Don't forget to add proper spacing to added names!

/obj/experimentor/loot_definer/proc/generateSecondName()
    var/list/possiblenames = new/list
    // Adds generic rarity names to the list.
    switch(raritylevel)
        if(RARITY_COMMON)
            possiblenames.Add("Alpha ", "Alpha-")
        if(RARITY_UNCOMMON)
            possiblenames.Add("Beta ", "Beta-")
        if(RARITY_RARE)
            possiblenames.Add("Gamma ", "Gamma-")
        if(RARITY_VERYRARE)
            possiblenames.Add("Omega ", "Omega-")
    // Adds names based on keywords as defined in II.
    for(var/keyword in loot_keywords)
        switch(keyword)
            if("destruction")
                possiblenames.Add("Molecular ", "Destabilized ", "Destructive ", "Cleansing ")
            if("replication")
                possiblenames.Add("Induced ", "Replicant ")
            if("teleportation")
                possiblenames.Add("Distorting ", "Gravitic ")
            if("bluespace")
                possiblenames.Add("Phased ", "Quasi-Real ")
            if("stun")
                possiblenames.Add("Enervating ")
            if("sound")
                possiblenames.Add("Sonic ", "High-Frequency ", "Modulated ")
            if("light")
                possiblenames.Add("Photonic ", "Modulated ", "Luminescent ", "Strobing ")
            if("clowns")
                possiblenames.Add("Honk ", "Banana-", "Squeak-", "Murder-")
    return pick(possiblenames)


///////////////////IV. THIRD NAME////////////////////
// Each revealed object has 3 parts to its name.
// This defines the second section based on keywords
// or on the defined unique name if any.

/obj/experimentor/loot_definer/proc/generateThirdName()
    if(unique_names != null)
        return pick(unique_names)

    var/list/possiblenames = new/list
    for(var/keyword in loot_keywords)
        switch(keyword)
            if("destruction")
                possiblenames.Add("Disintegrator", "Obliterator", "Annihilator", "Destructo-tron")
            if("replication")
                possiblenames.Add("Growth Catalyst", "Seeder")
            if("teleportation")
                possiblenames.Add("Translocator", "Space-Folder", "Dimensional Porta-Potty")
            if("stun")
                possiblenames.Add("Pacifier", "Nullifier", "Mesmertron")
            if("sound")
                possiblenames.Add("Blaster")
            if("light")
                possiblenames.Add("Photon Manipulator", "Modulator", "Strobe")
            if("animals")
                possiblenames.Add("Bio-Invigorator", "Cloner")
    //If there are no names available for the chosen keyword, pick a generic name instead.
    if(possiblenames.len<1)
        return pick("Doohickey", "Thingummywhatsit", "Machine", "Tech")
    return pick(possiblenames)

//////////////////////// IV. DESCRIPTION //////////////////////////
// Generates a vaguely relevant description for the item, revealing
// one of the item's keywords. If the item has a specific use that
// is not readily apparent, using the item's own description
// definition (loot_described = FALSE) is recommended.

/obj/experimentor/loot_definer/proc/generateDescription()
	var/item_description = ""
	if(raritylevel == RARITY_COMMON)
		item_description += pick("This is a fairly simple piece of [box_type] Technology. ", "This is a basic but possibly useful piece of [box_type] Technology. ")
	if(raritylevel == RARITY_UNCOMMON)
		item_description += pick("This is a well-made piece of [box_type] Technology. ", "This is a piece of [box_type] Technology. It has a solid build. ")
	if(raritylevel == RARITY_RARE)
		item_description += pick("This is an elaborate piece of [box_type] Technology. ", "This is a piece of [box_type] Technology. Its build quality is surprisingly high. ")
	if(raritylevel == RARITY_VERYRARE)
		item_description += pick("This is an incredible example of [box_type] Technology. ", "This is a piece of [box_type] Technology. It's so complex you have no idea how it works. ")

	if (loot_keywords.len>=1)
		item_description += pick("There's a marking on the side which reminds you of [pick(loot_keywords)].", "When you look at it, you can't help but think of [pick(loot_keywords)].", "It's hard to tell for sure, but it seems to have something to do with [pick(loot_keywords)].")
	return item_description
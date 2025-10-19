/obj/machinery/plantgenes
	name = "plant DNA manipulator"
	desc = "An advanced device designed to manipulate plant genetic makeup."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	pass_flags = PASSTABLE
	icon_state = "dnamod"
	density = TRUE
	anchored = TRUE
	/// the seed stored in the machine
	var/obj/item/seeds/seed
	/// the disk in use
	var/obj/item/disk/plantgene/disk
	/// list of the seed's trait genes
	var/list/core_genes = list()
	/// list of the seed's trait genes
	var/list/reagent_genes = list()
	/// list of the seed's trait genes
	var/list/trait_genes = list()
	/// disk capacity
	var/disk_capacity = 100
	/// gene targeted for operation
	var/datum/plant_gene/target
	/// maximum potency that can be put on a disk
	var/max_potency = 50 // See RefreshParts() for how these work
	/// maximum yield that can be put on a disk
	var/max_yield = 2
	/// minimum production that can be put on a disk
	var/min_production = 12
	/// maximum endurance that can be put on a disk
	var/max_endurance = 10 // IMPT: ALSO AFFECTS LIFESPAN
	/// minimum weed growth chance that can be put on a disk
	var/min_weed_chance = 67
	/// minimum weed growth rate that can be put on a disk
	var/min_weed_rate = 10
	/// amount of seeds needed to make a core stat disk
	var/seeds_for_bulk_core = 5
	/// index of disk in use in the content list
	var/disk_index = 0

/obj/machinery/plantgenes/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/plantgenes(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	RefreshParts()

/obj/machinery/plantgenes/seedvault/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/plantgenes/vault(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	RefreshParts()

/obj/machinery/plantgenes/Destroy()
	for(var/atom/movable/A in contents)
		A.forceMove(loc)
	seed = null
	disk = null
	core_genes.Cut()
	reagent_genes.Cut()
	trait_genes.Cut()
	target = null
	return ..()

/obj/machinery/plantgenes/RefreshParts() // Comments represent the max you can set per tier, respectively. seeds.dm [219] clamps these for us but we don't want to mislead the viewer.
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		if(M.rating > 3)
			max_potency = 95
		else
			max_potency = initial(max_potency) + (M.rating**3) // 51,58,77,95 	 Clamps at 100

		max_yield = initial(max_yield) + (M.rating*2) // 4,6,8,10 	Clamps at 10

	for(var/obj/item/stock_parts/scanning_module/SM in component_parts)
		if(SM.rating > 3) //If you create t5 parts I'm a step ahead mwahahaha!
			min_production = 1
		else
			min_production = 12 - (SM.rating * 3) //9,6,3,1. Requires if to avoid going below clamp [1]

		max_endurance = initial(max_endurance) + (SM.rating * 25) // 35,60,85,100	Clamps at 10min 100max

	for(var/obj/item/stock_parts/micro_laser/ML in component_parts)
		var/weed_rate_mod = ML.rating * 2.5
		min_weed_rate = FLOOR(10-weed_rate_mod, 1) // 7,5,2,0	Clamps at 0 and 10	You want this low
		min_weed_chance = 67-(ML.rating*16) // 48,35,19,3 	Clamps at 0 and 67	You want this low

	var/total_rating = 0
	for(var/obj/item/stock_parts/S in component_parts)
		total_rating += S.rating

	switch(clamp(total_rating, 1, 12))
		if(1 to 3)
			seeds_for_bulk_core = 5
		if(4 to 6)
			seeds_for_bulk_core = 4
		if(7 to 9)
			seeds_for_bulk_core = 3
		if(10 to 11)
			seeds_for_bulk_core = 2
		else
			seeds_for_bulk_core = 1

	for(var/obj/item/circuitboard/plantgenes/vaultcheck in component_parts)
		if(istype(vaultcheck, /obj/item/circuitboard/plantgenes/vault)) // TRAIT_DUMB BOTANY TUTS
			total_rating = 12
			max_potency = 100
			max_yield = 10
			min_production = 1
			max_endurance = 100
			min_weed_chance = 0
			min_weed_rate = 0
			seeds_for_bulk_core = 1

/obj/machinery/plantgenes/update_icon_state()
	if((stat & (BROKEN|NOPOWER)))
		icon_state = "dnamod-off"
	else
		icon_state = "dnamod"

/obj/machinery/plantgenes/update_overlays()
	. = ..()
	if(seed)
		. += "dnamod-dna"
	if(panel_open)
		. += "dnamod-open"

/obj/machinery/plantgenes/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(default_deconstruction_screwdriver(user, "dnamod", "dnamod", used))
		update_icon(UPDATE_OVERLAYS)
		return ITEM_INTERACT_COMPLETE

	if(default_deconstruction_crowbar(user, used))
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/unsorted_seeds))
		to_chat(user, "<span class='warning'>You need to sort [used] first!</span>")
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/seeds))
		add_seed(used, user)
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/disk/plantgene) || istype(used, /obj/item/storage/box))
		add_disk(used, user)
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/plantgenes/proc/add_seed(obj/item/seeds/new_seed, mob/user)
	if(seed)
		to_chat(user, "<span class='warning'>A sample is already loaded into the machine!</span>")
		return
	if(!user.drop_item())
		return
	insert_seed(new_seed)
	to_chat(user, "<span class='notice'>You add [new_seed] to the machine.</span>")
	ui_interact(user)

/obj/machinery/plantgenes/proc/add_disk(obj/item/disk/plantgene/new_disk, mob/user)
	if(length(contents) - (seed ? 1 : 0) >= disk_capacity)
		to_chat(user, "<span class='warning'>[src] cannot hold any more disks!</span>")
		return
	if(istype(new_disk, /obj/item/storage/box))
		var/has_disks = FALSE
		for(var/obj/item/disk/plantgene/D in new_disk.contents)
			if(length(contents)- (seed ? 1 : 0) >= disk_capacity)
				to_chat(user, "<span class='notice'>You fill [src] with disks.</span>")
				break
			has_disks = TRUE
			D.forceMove(src)
			if(!disk)
				disk = D
		if(has_disks)
			playsound(loc, 'sound/items/handling/cardboardbox_drop.ogg', 50)
			to_chat(user, "<span class='notice'>You load [src] from [new_disk].</span>")
		else
			to_chat(user, "<span class='notice'>[new_disk] contains no disks.</span>")
		SStgui.update_uis(src)
		return
	if(!user.drop_item())
		return
	if(!disk)
		disk = new_disk
	new_disk.forceMove(src)
	to_chat(user, "<span class='notice'>You add [new_disk] to the machine.</span>")
	ui_interact(user)

/obj/machinery/plantgenes/attack_hand(mob/user)
	if(..())
		return
	ui_interact(user)

/obj/machinery/plantgenes/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/plantgenes/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/plantgenes/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GeneModder", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/plantgenes/ui_data(mob/user)
	var/list/data = list()

	data["has_seed"] = seed ? TRUE : FALSE
	data["has_disk"] = disk ? TRUE : FALSE

	data["core_genes"] = list()
	data["reagent_genes"] = list()
	data["trait_genes"] = list()

	data["has_reagent"] = FALSE
	data["has_trait"] = FALSE

	data["seed"] = list()

	if(seed)
		var/icon/base64icon = GLOB.seeds_cached_base64_icons["[initial(seed.icon)][initial(seed.icon_state)]"]
		if(!base64icon)
			base64icon = icon2base64(icon(initial(seed.icon), initial(seed.icon_state), SOUTH, 1))
			GLOB.seeds_cached_base64_icons["[initial(seed.icon)][initial(seed.icon_state)]"] = base64icon
		data["seed"] = list(
			"image" = "[base64icon]",
			"name" = seed.name,
			"variant" = seed.variant
		)

		for(var/datum/plant_gene/core/c_gene in core_genes)
			var/list/seed_info = list(
				"name" = c_gene.get_name(),
				"id" = c_gene.UID(),
				"is_type" = disk && istype(disk.gene, c_gene)
			)
			data["core_genes"] += list(seed_info)
			// there will always be core genes, if there isnt, something has gone very wrong

		for(var/datum/plant_gene/reagent/r_gene in reagent_genes)
			var/list/seed_info = list(
				"name" = r_gene.get_name(),
				"id" = r_gene.UID()
			)
			data["reagent_genes"] += list(seed_info)
			data["has_reagent"] = TRUE

		for(var/datum/plant_gene/trait/t_gene in trait_genes)
			var/list/seed_info = list(
				"name" = t_gene.get_name(),
				"id" = t_gene.UID()
			)
			data["trait_genes"] += list(seed_info)
			data["has_trait"] = TRUE

	data["disk"] = list()

	if(disk)
		var/disk_name = disk.ui_name
		if(disk.read_only)
			disk_name = "[disk_name] (Read Only)"
		var/can_insert = FALSE
		if(seed)
			can_insert = disk.gene?.can_add(seed)
		data["disk"] = list(
			"name" = disk_name,
			"can_insert" = can_insert,
			"can_extract" = !disk.read_only,
			"is_core" = istype(disk?.gene, /datum/plant_gene/core),
			"is_bulk_core" = disk?.is_bulk_core && (disk.seeds_needed <= disk.seeds_scanned)
		)

	data["modal"] = ui_modal_data(src)

	var/list/stats = list()
	var/list/traits = list()
	var/list/reagents = list()
	var/empty_disks = 0

	data["stat_disks"] = list()
	data["trait_disks"] = list()
	data["reagent_disks"] = list()

	for(var/i in 1 to length(contents))
		if(istype(contents[i], /obj/item/disk/plantgene))
			var/obj/item/disk/plantgene/D = contents[i]
			if(!D.gene && !D.is_bulk_core)
				empty_disks++
			else if(D.is_bulk_core)
				stats.Add(list(list("display_name" = D.ui_name, "index" = i, "stat" = "All", "ready" = D.seeds_needed <= D.seeds_scanned, "read_only" = D.read_only)))
			else if(istype(D.gene, /datum/plant_gene/core))
				var/datum/plant_gene/core/C = D.gene
				stats.Add(list(list("display_name" = C.name +" "+ num2text(C.value), "index" = i, "stat" = C.name, "read_only" = D.read_only)))
			else if(istype(D.gene, /datum/plant_gene/trait))
				var/insertable = D.gene?.can_add(seed)
				traits.Add(list(list("display_name" = D.gene.name, "index" = i, "can_insert" = insertable, "read_only" = D.read_only)))
			else if(istype(D.gene, /datum/plant_gene/reagent))
				var/datum/plant_gene/reagent/R = D.gene
				var/insertable = R?.can_add(seed)
				reagents.Add(list(list("display_name" = "[R.name] [num2text(R.rate*200)]%", "index" = i,  "can_insert" = insertable, "read_only" = D.read_only)))
	if(length(stats))
		data["stat_disks"] = stats
	if(length(traits))
		data["trait_disks"] = traits
	if(length(reagents))
		data["reagent_disks"] = reagents
	data["empty_disks"] = empty_disks

	return data

/obj/machinery/plantgenes/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	. = TRUE

	// we dont care what we get from modal act, as long as its not null because we only have boolean modals
	if(ui_modal_act(src, action, params))
		return

	var/mob/user = ui.user

	if(params["id"])
		target = seed?.get_gene(params["id"])
	else if(params["stat"] && params["stat"] != "All")
		for(var/datum/plant_gene/core/c_gene in core_genes)
			if(c_gene.name == params["stat"])
				target = c_gene

	switch(action)
		if("eject_seed")
			if(seed)
				seed.forceMove(loc)
				if(Adjacent(user) && !issilicon(user))
					user.put_in_hands(seed)
				seed = null
				update_genes()
				update_icon(UPDATE_OVERLAYS)
			else
				var/obj/item/I = user.get_active_hand()
				if(istype(I, /obj/item/seeds))
					add_seed(I, user)

		if("eject_disk")
			var/obj/item/disk/plantgene/D = contents[text2num(params["index"])]
			if(D)
				D.forceMove(loc)
				if(Adjacent(user) && !issilicon(user))
					user.put_in_hands(D)
				disk = null
				update_genes()
			else
				var/obj/item/I = user.get_active_hand()
				if(istype(I, /obj/item/disk/plantgene))
					add_disk(I, user)

		if("variant_name")
			seed.variant_prompt(user, src)
			// uses the default byond prompt, but it works

		if("bulk_extract_core")
			var/dat = "Are you sure you want to extract all core genes from the [seed]? The sample will be destroyed in the process!"
			var/prev_seeds = 0
			if(disk.is_bulk_core && disk.core_matches(seed))
				prev_seeds = disk.seeds_scanned
			if(seeds_for_bulk_core > prev_seeds + 1)
				var/remaining = seeds_for_bulk_core - prev_seeds - 1
				dat += " This device needs [seeds_for_bulk_core] samples to produce a usable core gene disk. You will need [remaining] more sample[ remaining > 1 ? "s" : ""] with identical core genes."

			ui_modal_boolean(src, action, dat, yes_text = "Extract", no_text = "Cancel", delegate = PROC_REF(bulk_extract_core))

		if("extract")
			var/dat = "Are you sure you want to extract [target.get_name()] gene from the [seed]? The sample will be destroyed in process!"
			if(istype(target, /datum/plant_gene/core))
				var/datum/plant_gene/core/core_gene = target
				var/genemod_var = core_gene.get_genemod_variable(src) // polymorphism my beloved
				if((core_gene.use_max && core_gene.value < genemod_var) || (!core_gene.use_max && core_gene.value > genemod_var))
					var/gene_name = lowertext(core_gene.name)
					dat += " This device's extraction capabilities are currently limited to [genemod_var] [gene_name]. \
							Target gene will be degraded to [genemod_var] [gene_name] on extraction."

			ui_modal_boolean(src, action, dat, yes_text = "Extract", no_text = "Cancel", delegate = PROC_REF(gene_extract))

		if("bulk_replace_core")
			disk_index = text2num(params["index"])
			ui_modal_boolean(src, action, "Are you sure you want to replace ALL core genes of the [seed]?" , yes_text = "Replace", no_text = "Cancel", delegate = PROC_REF(bulk_replace_core))

		if("replace")
			disk_index = text2num(params["index"])
			var/obj/item/disk/plantgene/D = contents[text2num(params["index"])]
			ui_modal_boolean(src, action, "Are you sure you want to replace [target.get_name()] gene with [D.gene.get_name()]?", yes_text = "Replace", no_text = "Cancel", delegate = PROC_REF(gene_replace))

		if("remove")
			ui_modal_boolean(src, action, "Are you sure you want to remove [target.get_name()] gene from the [seed]" , yes_text = "Remove", no_text = "Cancel", delegate = PROC_REF(gene_remove))

		if("insert")
			var/obj/item/disk/plantgene/D = contents[text2num(params["index"])]
			if(D.gene && (istype(D.gene, /datum/plant_gene/trait) || istype(D.gene, /datum/plant_gene/reagent)) && D.gene.can_add(seed))
				seed.genes += D.gene.Copy()
				if(istype(D.gene, /datum/plant_gene/reagent))
					seed.reagents_from_genes()
				update_genes()
				repaint_seed()

		if("select")
			disk = contents[text2num(params["index"])]

		if("select_empty_disk")
			for(var/obj/item/disk/plantgene/D in contents)
				if(!D.gene && !D.is_bulk_core)
					disk =	D
					return

		if("eject_empty_disk")
			for(var/obj/item/disk/plantgene/D in contents)
				if(!D.gene && !D.is_bulk_core)
					D.forceMove(loc)
					if(Adjacent(user) && !issilicon(user))
						user.put_in_hands(D)
					update_genes()
					return
			to_chat(user, "<span class='warning'>No Empty Disks to Eject!</span>")
		if("set_read_only")
			var/obj/item/disk/plantgene/D = contents[text2num(params["index"])]
			D.read_only = !D.read_only

/obj/machinery/plantgenes/proc/gene_remove()
	if(istype(target, /datum/plant_gene/core))
		return
	seed.genes -= target
	if(istype(target, /datum/plant_gene/reagent))
		seed.reagents_from_genes()
	repaint_seed()
	update_genes()
	target = null

/obj/machinery/plantgenes/proc/gene_extract()
	if(!disk || disk.read_only)
		return
	disk.is_bulk_core = FALSE
	disk.gene = target.Copy()
	if(istype(disk.gene, /datum/plant_gene/core))
		var/datum/plant_gene/core/core_gene = disk.gene
		var/genemod_var = core_gene.get_genemod_variable(src)
		if(core_gene.use_max)
			core_gene.value = max(core_gene.value, genemod_var)
		else
			core_gene.value = min(core_gene.value, genemod_var)

	disk.update_appearance(UPDATE_NAME)
	QDEL_NULL(seed)
	update_icon(UPDATE_OVERLAYS)
	update_genes()
	target = null
	//replace with empty disk if possible
	for(var/obj/item/disk/plantgene/D in contents)
		if(!D.gene && !D.is_bulk_core)
			disk = D
			return

/obj/machinery/plantgenes/proc/gene_replace()
	var/obj/item/disk/plantgene/D = contents[disk_index]
	if(!D?.gene || D.is_bulk_core)
		return
	if(!istype(target, /datum/plant_gene/core))
		return
	if(!istype(D.gene, target.type))
		return // you can't replace a endurance gene with a weed chance gene, etc
	seed.genes -= target
	var/datum/plant_gene/core/C = D.gene.Copy()
	seed.genes += C
	C.apply_stat(seed)
	repaint_seed()
	update_genes()
	target = null

/obj/machinery/plantgenes/proc/bulk_extract_core()
	if(!disk || disk.read_only)
		return
	disk.seeds_needed = seeds_for_bulk_core
	if(disk.core_matches(seed))
		disk.seeds_scanned += 1
	else
		disk.seeds_scanned = 1
		disk.is_bulk_core = TRUE
		disk.gene = null
		disk.core_genes = list()
		for(var/datum/plant_gene/core/gene in core_genes)
			var/datum/plant_gene/core/C = gene.Copy()
			disk.core_genes += C

	disk.update_appearance(UPDATE_NAME)
	QDEL_NULL(seed)
	update_icon(UPDATE_OVERLAYS)
	update_genes()
	target = null

	if(disk.seeds_scanned >= disk.seeds_needed)
		for(var/obj/item/disk/plantgene/D in contents)
			if(!D.gene && (!D.is_bulk_core))
				disk = D
				return

/obj/machinery/plantgenes/proc/bulk_replace_core()
	var/obj/item/disk/plantgene/D = contents[disk_index]
	if(!D?.is_bulk_core)
		return
	if(D.seeds_scanned < D.seeds_needed)
		return
	for(var/datum/plant_gene/gene in seed.genes)
		if(istype(gene, /datum/plant_gene/core))
			seed.genes -= gene
	for(var/datum/plant_gene/core/gene in D.core_genes)
		var/datum/plant_gene/core/C = gene.Copy()
		seed.genes += C
		C.apply_stat(seed)
	repaint_seed()
	update_genes()
	target = null

/obj/machinery/plantgenes/proc/insert_seed(obj/item/seeds/S)
	if(!istype(S) || seed)
		return
	S.forceMove(src)
	seed = S
	update_genes()
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/plantgenes/proc/update_genes()
	core_genes = list()
	reagent_genes = list()
	trait_genes = list()

	if(seed)
		var/gene_paths = list(
			/datum/plant_gene/core/potency,
			/datum/plant_gene/core/yield,
			/datum/plant_gene/core/production,
			/datum/plant_gene/core/endurance,
			/datum/plant_gene/core/lifespan,
			/datum/plant_gene/core/weed_rate,
			/datum/plant_gene/core/weed_chance
			)
		for(var/a in gene_paths)
			core_genes += seed.get_gene(a)

		for(var/datum/plant_gene/reagent/G in seed.genes)
			reagent_genes += G
		for(var/datum/plant_gene/trait/G in seed.genes)
			trait_genes += G

/obj/machinery/plantgenes/proc/repaint_seed()
	if(!seed)
		return
	if(copytext(seed.name, 1, 13) == "experimental")
		return // Already modded name and icon
	seed.name = "experimental " + seed.name
	seed.icon_state = "seed-x"

// MARK: Plant Disk


/obj/item/disk/plantgene
	name = "plant data disk"
	desc = "A disk for storing plant genetic data."
	icon_state = "datadisk_hydro"
	materials = list(MAT_METAL=30, MAT_GLASS=10)
	var/ui_name = "Empty Disk"
	var/is_bulk_core = FALSE
	var/read_only = 0 //Well, it's still a floppy disk

	// For single genes
	var/datum/plant_gene/gene

	// For bulk core genes
	var/list/core_genes = list()
	var/seeds_scanned = 0
	var/seeds_needed = 5

/obj/item/disk/plantgene/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_ICON_STATE)

/obj/item/disk/plantgene/Destroy()
	QDEL_NULL(gene)
	return ..()

/obj/item/disk/plantgene/attackby__legacy__attackchain(obj/item/W, mob/user, params)
	..()
	if(is_pen(W))
		rename_interactive(user, W)

/obj/item/disk/plantgene/update_name()
	. = ..()
	if(HAS_TRAIT(src, TRAIT_CMAGGED))
		name = "nuclear authentication disk"
		ui_name = "nuclear authentication disk?"
		return
	if(!is_bulk_core && gene)
		name = "[gene.get_name()] (plant data disk)"
		ui_name = "[gene.get_name()]"
	else if(is_bulk_core)
		name = ""
		if(seeds_scanned < seeds_needed)
			name +=  "[round(seeds_scanned/seeds_needed*100,1)]% of "
		name += "Core gene set "
		ui_name = "Core "
		for(var/i in 1 to length(core_genes))
			if(i > 1)
				name += "/"
				ui_name += "/"
			var/datum/plant_gene/core/core_gene = core_genes[i]
			name += "[core_gene.value]"
			ui_name += "[core_gene.value]"

		name += " (plant data disk)"

		if(seeds_scanned < seeds_needed)
			ui_name +=  " ([round(seeds_scanned / seeds_needed * 100, 1)]%)"
	else
		name = "plant data disk"
		ui_name = "Empty Disk"

/obj/item/disk/plantgene/proc/core_matches(obj/item/seeds/seed)
	if(!is_bulk_core)
		return FALSE
	for(var/datum/plant_gene/core/gene in core_genes)
		var/datum/plant_gene/core/seed_gene = seed.get_gene(gene.type)
		if(gene.value != seed_gene.value)
			return FALSE
	return TRUE

/obj/item/disk/plantgene/update_desc()
	. = ..()
	if(HAS_TRAIT(src, TRAIT_CMAGGED))
		desc = "A floppy disk containing unique cryptographic identification data. Used along with a valid code to detonate the on-site nuclear fission explosive."
		return

	desc = "A disk for storing plant genetic data."

/obj/item/disk/plantgene/update_icon_state()
	. = ..()
	if(HAS_TRAIT(src, TRAIT_CMAGGED))
		icon_state = "nucleardisk"
		return

	icon_state = "datadisk_hydro"

/obj/item/disk/plantgene/attack_self__legacy__attackchain(mob/user)
	if(HAS_TRAIT(src, TRAIT_CMAGGED))
		return
	read_only = !read_only
	to_chat(user, "<span class='notice'>You flip the write-protect tab to [read_only ? "protected" : "unprotected"].</span>")

/obj/item/disk/plantgene/cmag_act(mob/user)
	if(!HAS_TRAIT(src, TRAIT_CMAGGED))
		to_chat(user, "<span class='warning'>The bananium ooze flips a couple bits on the plant disk's display, making it look just like the..!</span>")
		ADD_TRAIT(src, TRAIT_CMAGGED, CLOWN_EMAG)
		update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_ICON)
		playsound(src, "sparks", 75, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		return TRUE
	return FALSE

/obj/item/disk/plantgene/uncmag()
	update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_ICON)

/obj/item/disk/plantgene/examine(mob/user)
	. = ..()
	if(!HAS_TRAIT(src, TRAIT_CMAGGED))
		. += "The write-protect tab is set to [read_only ? "protected" : "unprotected"]."
		return
	if((user.mind.assigned_role == "Captain" || user.mind.special_role == SPECIAL_ROLE_NUKEOPS) && (user.Adjacent(src)))
		. += "<span class='warning'>... Wait. This isn't the nuclear authentication disk! It's a clever forgery!</span>"
	else
		. += "<span class='warning'>You should keep this safe...</span>"

/obj/item/disk/plantgene/examine_more(mob/user)
	. = ..()
	if(!HAS_TRAIT(src, TRAIT_CMAGGED))
		return

	if((user.mind.assigned_role == "Captain" || user.mind.special_role == SPECIAL_ROLE_NUKEOPS) && user.Adjacent(src))
		. += "<span class='danger'>Yes, even closer examination confirms it's not a trick of the light, it really is just a regular plant disk.</span>"
		. += "<span class='userdanger'>Now stop staring at this worthless fake and FIND THE REAL ONE!</span>"
		return

	. += "Nuclear fission explosives are stored on all Nanotrasen stations in the system so that they may be rapidly destroyed should the need arise."
	. += ""
	. += "Naturally, such a destructive capability requires robust safeguards to prevent accidental or mallicious misuse. NT employs two mechanisms: an authorisation code from Central Command, \
	and the nuclear authentication disk. Whilst the code is normally sufficient, enemies of Nanotrasen with sufficient resources may be able to spoof, steal, or otherwise crack the authorisation code. \
	The NAD serves to protect against this. It is essentially a one-time pad that functions in tandem with the authorisation code to unlock the detonator of the fission explosive."

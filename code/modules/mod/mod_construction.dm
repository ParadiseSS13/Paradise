/obj/item/mod/construction
	desc = "A part used in MOD construction. You could insert it into a MOD shell."
	icon = 'icons/obj/clothing/modsuit/mod_construction.dmi'

/obj/item/mod/construction/helmet
	name = "MOD helmet"
	desc = "A standardized helmet frame for use in constructing MOD suits. Useless without a MOD shell."
	icon_state = "helmet"

/obj/item/mod/construction/chestplate
	name = "MOD chestplate"
	desc = "A heavy metal chestpiece for use in constructing MOD suits. Useless without a MOD shell."
	icon_state = "chestplate"

/obj/item/mod/construction/gauntlets
	name = "MOD gauntlets"
	desc = "Bare powered gauntlets for use in constructing MOD suits. Useless without a MOD shell."
	icon_state = "gauntlets"

/obj/item/mod/construction/boots
	name = "MOD boots"
	desc = "Powered boots for use in MOD suit construction. Useless without a MOD shell."
	icon_state = "boots"

/obj/item/mod/construction/broken_core
	name = "broken MOD core"
	icon_state = "mod-core"
	desc = "An internal power source for a Modular Outerwear Device. You don't seem to be able to source any power from this one, though."

/obj/item/mod/construction/broken_core/examine(mob/user)
	. = ..()
	. += "<span class='notice'>You could repair it with a <b>screwdriver</b>...</span>"

/obj/item/mod/construction/broken_core/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	if(!tool.use_tool(src, user, 5 SECONDS, volume = 30))
		return
	new /obj/item/mod/core/standard(drop_location())
	qdel(src)

/obj/item/mod/construction/plating
	name = "MOD external plating"
	desc = "External plating used to finish a MOD control unit."
	icon_state = "standard-plating"
	var/datum/mod_theme/theme = /datum/mod_theme/standard

/obj/item/mod/construction/plating/Initialize(mapload)
	. = ..()
	var/datum/mod_theme/used_theme = GLOB.mod_themes[theme]
	name = "MOD [used_theme.name] external plating"
	desc = "[desc] [used_theme.desc]"
	icon_state = "[used_theme.default_skin]-plating"

/obj/item/mod/construction/plating/engineering
	theme = /datum/mod_theme/engineering

/obj/item/mod/construction/plating/atmospheric
	theme = /datum/mod_theme/atmospheric

/obj/item/mod/construction/plating/medical
	theme = /datum/mod_theme/medical

/obj/item/mod/construction/plating/security
	theme = /datum/mod_theme/security
/obj/item/mod/construction/plating/cosmohonk
	theme = /datum/mod_theme/cosmohonk

/// I want to add a way to get the rarer modsuit types, that is limited. A low chance for traders to have plating for it seems interesting
/obj/item/mod/construction/plating/rescue
	theme = /datum/mod_theme/rescue

/// Continued from above, none of these are steal objectives, and only the CE or RD one comes pre-installed with modules. You are getting the protection / speed / looks of these hardsuits, but no special modules.
/obj/item/mod/construction/plating/safeguard
	theme = /datum/mod_theme/safeguard

/// This may be a bad idea. I think this is an interesting idea. And you still need robotics to build it, and traders can charge as much for it as they want. Also with ones like the CE modsuit, it is the flagship mod. That means it is sold a lot.
/obj/item/mod/construction/plating/advanced
	theme = /datum/mod_theme/advanced

/// Don't think people will want the RD one though, it is as slow as shit. Anyway, here it is. Surely this will not end poorly.
/obj/item/mod/construction/plating/research
	theme = /datum/mod_theme/research

#define START_STEP "start"
#define CORE_STEP "core"
#define SCREWED_CORE_STEP "screwed_core"
#define HELMET_STEP "helmet"
#define CHESTPLATE_STEP "chestplate"
#define GAUNTLETS_STEP "gauntlets"
#define BOOTS_STEP "boots"
#define WRENCHED_ASSEMBLY_STEP "wrenched_assembly"
#define SCREWED_ASSEMBLY_STEP "screwed_assembly"

/obj/item/mod/construction/shell
	name = "MOD shell"
	desc = "The core housing and support structure for a MOD suit, with numerous plugs and connectors for attaching additional components."
	icon_state = "mod-construction_start"
	var/obj/item/core
	var/obj/item/helmet
	var/obj/item/chestplate
	var/obj/item/gauntlets
	var/obj/item/boots
	var/construction_step = START_STEP

/obj/item/mod/construction/shell/examine(mob/user)
	. = ..()
	var/display_text
	switch(construction_step)
		if(START_STEP)
			display_text = "It looks like it's missing a <b>MOD core</b>..."
		if(CORE_STEP)
			display_text = "The core seems <b>loose</b>..."
		if(SCREWED_CORE_STEP)
			display_text = "It looks like it's missing a <b>helmet</b>..."
		if(HELMET_STEP)
			display_text = "It looks like it's missing a <b>chestplate</b>..."
		if(CHESTPLATE_STEP)
			display_text = "It looks like it's missing <b>gauntlets</b>..."
		if(GAUNTLETS_STEP)
			display_text = "It looks like it's missing <b>boots</b>..."
		if(BOOTS_STEP)
			display_text = "The assembly seems <b>unsecured</b>..."
		if(WRENCHED_ASSEMBLY_STEP)
			display_text = "The assembly seems <b>loose</b>..."
		if(SCREWED_ASSEMBLY_STEP)
			display_text = "All it's missing is <b>external plating</b>..."
	. += "<span class='notice'>[display_text]</span>"

/obj/item/mod/construction/shell/attackby__legacy__attackchain(obj/item/part, mob/user, params)
	. = ..()
	switch(construction_step)
		if(START_STEP)
			if(!istype(part, /obj/item/mod/core))
				return
			if(!user.drop_item())
				to_chat(user, "<span class='warning'>[part] is stuck to you and cannot be placed into [src].</span>")
				return
			playsound(src, 'sound/machines/click.ogg', 30, TRUE)
			to_chat(user, "<span class='notice'>Core inserted.</span>")
			core = part
			core.forceMove(src)
			construction_step = CORE_STEP
		if(CORE_STEP)
			if(part.tool_behaviour == TOOL_SCREWDRIVER) //Construct
				if(part.use_tool(src, user, 0, volume = 30))
					to_chat(user, "<span class='notice'>Core screwed.</span>")
				construction_step = SCREWED_CORE_STEP
			else if(part.tool_behaviour == TOOL_CROWBAR) //Deconstruct
				if(part.use_tool(src, user, 0, volume = 30))
					core.forceMove(drop_location())
					to_chat(user, "<span class='notice'>Core removed.</span>")
				construction_step = START_STEP
		if(SCREWED_CORE_STEP)
			if(istype(part, /obj/item/mod/construction/helmet)) //Construct
				if(!user.drop_item())
					to_chat(user, "<span class='warning'>[part] is stuck to you and cannot be placed into [src].</span>")
					return
				playsound(src, 'sound/machines/click.ogg', 30, TRUE)
				to_chat(user, "<span class='notice'>Helmet added.</span>")
				helmet = part
				helmet.forceMove(src)
				construction_step = HELMET_STEP
			else if(part.tool_behaviour == TOOL_SCREWDRIVER) //Deconstruct
				if(part.use_tool(src, user, 0, volume = 30))
					to_chat(user, "<span class='notice'>Core unscrewed.</span>")
					construction_step = CORE_STEP
		if(HELMET_STEP)
			if(istype(part, /obj/item/mod/construction/chestplate)) //Construct
				if(!user.drop_item())
					to_chat(user, "<span class='warning'>[part] is stuck to you and cannot be placed into [src].</span>")
					return
				playsound(src, 'sound/machines/click.ogg', 30, TRUE)
				to_chat(user, "<span class='notice'>Chestplate added.</span>")
				forceMove(src)
				chestplate = part
				chestplate.forceMove(src)
				construction_step = CHESTPLATE_STEP
			else if(part.tool_behaviour == TOOL_CROWBAR) //Deconstruct
				if(part.use_tool(src, user, 0, volume = 30))
					helmet.forceMove(drop_location())
					to_chat(user, "<span class='notice'>Helmet removed.</span>")
					helmet = null
					construction_step = SCREWED_CORE_STEP
		if(CHESTPLATE_STEP)
			if(istype(part, /obj/item/mod/construction/gauntlets)) //Construct
				if(!user.drop_item())
					to_chat(user, "<span class='warning'>[part] is stuck to you and cannot be placed into [src].</span>")
					return
				playsound(src, 'sound/machines/click.ogg', 30, TRUE)
				to_chat(user, "<span class='notice'>Gauntlets added.</span>")
				gauntlets = part
				gauntlets.forceMove(src)
				construction_step = GAUNTLETS_STEP
			else if(part.tool_behaviour == TOOL_CROWBAR) //Deconstruct
				if(part.use_tool(src, user, 0, volume = 30))
					chestplate.forceMove(drop_location())
					to_chat(user, "<span class='notice'>Chestplate removed.</span>")
					chestplate = null
					construction_step = HELMET_STEP
		if(GAUNTLETS_STEP)
			if(istype(part, /obj/item/mod/construction/boots)) //Construct
				if(!user.drop_item())
					to_chat(user, "<span class='warning'>[part] is stuck to you and cannot be placed into [src].</span>")
					return
				playsound(src, 'sound/machines/click.ogg', 30, TRUE)
				to_chat(user, "<span class='notice'>Boots added.</span>")
				boots = part
				boots.forceMove(src)
				construction_step = BOOTS_STEP
			else if(part.tool_behaviour == TOOL_CROWBAR) //Deconstruct
				if(part.use_tool(src, user, 0, volume = 30))
					gauntlets.forceMove(drop_location())
					to_chat(user, "<span class='notice'>Gauntlets removed.</span>")
					gauntlets = null
					construction_step = CHESTPLATE_STEP
		if(BOOTS_STEP)
			if(part.tool_behaviour == TOOL_WRENCH) //Construct
				if(part.use_tool(src, user, 0, volume = 30))
					to_chat(user, "<span class='notice'>Assembly secured.</span>")
					construction_step = WRENCHED_ASSEMBLY_STEP
			else if(part.tool_behaviour == TOOL_CROWBAR) //Deconstruct
				if(part.use_tool(src, user, 0, volume = 30))
					boots.forceMove(drop_location())
					to_chat(user, "<span class='notice'>Boots removed.</span>")
					boots = null
					construction_step = GAUNTLETS_STEP
		if(WRENCHED_ASSEMBLY_STEP)
			if(part.tool_behaviour == TOOL_SCREWDRIVER) //Construct
				if(part.use_tool(src, user, 0, volume = 30))
					to_chat(user, "<span class='notice'>Assembly screwed.</span>")
					construction_step = SCREWED_ASSEMBLY_STEP
			else if(part.tool_behaviour == TOOL_WRENCH) //Deconstruct
				if(part.use_tool(src, user, 0, volume = 30))
					to_chat(user, "<span class='notice'>Assembly unsecured.</span>")
					construction_step = BOOTS_STEP
		if(SCREWED_ASSEMBLY_STEP)
			if(istype(part, /obj/item/mod/construction/plating)) //Construct
				var/obj/item/mod/construction/plating/external_plating = part
				if(!user.drop_item())
					return
				playsound(src, 'sound/machines/click.ogg', 30, TRUE)
				var/obj/item/mod = new /obj/item/mod/control(drop_location(), external_plating.theme, null, core)
				core = null
				qdel(external_plating)
				qdel(src)
				user.put_in_hands(mod)
				to_chat(user, "<span class='notice'>Suit finished!</span>")
			else if(part.tool_behaviour == TOOL_SCREWDRIVER) //Construct
				if(part.use_tool(src, user, 0, volume = 30))
					to_chat(user, "<span class='notice'>Assembly unscrewed.</span>")
					construction_step = SCREWED_ASSEMBLY_STEP
	update_icon(UPDATE_ICON_STATE)

/obj/item/mod/construction/shell/update_icon_state()
	. = ..()
	icon_state = "mod-construction_[construction_step]"

/obj/item/mod/construction/shell/Destroy()
	QDEL_NULL(core)
	QDEL_NULL(helmet)
	QDEL_NULL(chestplate)
	QDEL_NULL(gauntlets)
	QDEL_NULL(boots)
	return ..()

/obj/item/mod/construction/shell/handle_atom_del(atom/deleted_atom)
	if(deleted_atom == core)
		core = null
	if(deleted_atom == helmet)
		helmet = null
	if(deleted_atom == chestplate)
		chestplate = null
	if(deleted_atom == gauntlets)
		gauntlets = null
	if(deleted_atom == boots)
		boots = null
	return ..()

#undef START_STEP
#undef CORE_STEP
#undef SCREWED_CORE_STEP
#undef HELMET_STEP
#undef CHESTPLATE_STEP
#undef GAUNTLETS_STEP
#undef BOOTS_STEP
#undef WRENCHED_ASSEMBLY_STEP
#undef SCREWED_ASSEMBLY_STEP

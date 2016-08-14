/*
	Global associative list for caching humanoid icons.
	Index format m or f, followed by a string of 0 and 1 to represent bodyparts followed by husk fat hulk skeleton 1 or 0.
	TODO: Proper documentation
	icon_key is [species.race_key][g][husk][fat][hulk][skeleton][s_tone]
*/
var/global/list/human_icon_cache = list()

	///////////////////////
	//UPDATE_ICONS SYSTEM//
	///////////////////////
/*
Calling this  a system is perhaps a bit trumped up. It is essentially update_clothing dismantled into its
core parts. The key difference is that when we generate overlays we do not generate either lying or standing
versions. Instead, we generate both and store them in two fixed-length lists, both using the same list-index
(The indexes are in update_icons.dm): Each list for humans is (at the time of writing) of length 19.
This will hopefully be reduced as the system is refined.

	var/overlays_lying[19]			//For the lying down stance
	var/overlays_standing[19]		//For the standing stance

When we call update_icons, the 'lying' variable is checked and then the appropriate list is assigned to our overlays!
That in itself uses a tiny bit more memory (no more than all the ridiculous lists the game has already mind you).

On the other-hand, it should be very CPU cheap in comparison to the old system.
In the old system, we updated all our overlays every life() call, even if we were standing still inside a crate!
or dead!. 25ish overlays, all generated from scratch every second for every xeno/human/monkey and then applied.
More often than not update_clothing was being called a few times in addition to that! CPU was not the only issue,
all those icons had to be sent to every client. So really the cost was extremely cumulative. To the point where
update_clothing would frequently appear in the top 10 most CPU intensive procs during profiling.

Another feature of this new system is that our lists are indexed. This means we can update specific overlays!
So we only regenerate icons when we need them to be updated! This is the main saving for this system.

In practice this means that:
	everytime you fall over, we just switch between precompiled lists. Which is fast and cheap.
	Everytime you do something minor like take a pen out of your pocket, we only update the in-hand overlay
	etc...


There are several things that need to be remembered:

>	Whenever we do something that should cause an overlay to update (which doesn't use standard procs
	( i.e. you do something like l_hand = /obj/item/something new(src) )
	You will need to call the relevant update_inv_* proc:
		update_inv_head()
		update_inv_wear_suit()
		update_inv_gloves()
		update_inv_shoes()
		update_inv_w_uniform()
		update_inv_glasse()
		update_inv_l_hand()
		update_inv_r_hand()
		update_inv_belt()
		update_inv_wear_id()
		update_inv_ears()
		update_inv_s_store()
		update_inv_pockets()
		update_inv_back()
		update_inv_handcuffed()
		update_inv_wear_mask()

	All of these are named after the variable they update from. They are defined at the mob/ level like
	update_clothing was, so you won't cause undefined proc runtimes with usr.update_inv_wear_id() if the usr is a
	slime etc. Instead, it'll just return without doing any work. So no harm in calling it for slimes and such.


>	There are also these special cases:
		update_mutations()	//handles updating your appearance for certain mutations.  e.g TK head-glows
		update_mutantrace()	//handles updating your appearance after setting the mutantrace var
		UpdateDamageIcon()	//handles damage overlays for brute/burn damage //(will rename this when I geta round to it)
		update_body()	//Handles updating your mob's icon to reflect their gender/race/complexion etc
		update_hair()	//Handles updating your hair overlay (used to be update_face, but mouth and
																			...eyes were merged into update_body)

>	All of these procs update our overlays_lying and overlays_standing, and then call update_icons() by default.
	If you wish to update several overlays at once, you can set the argument to 0 to disable the update and call
	it manually:
		e.g.
		update_inv_head(0)
		update_inv_l_hand(0)
		update_inv_r_hand()		//<---calls update_icons()

	or equivillantly:
		update_inv_head(0)
		update_inv_l_hand(0)
		update_inv_r_hand(0)
		update_icons()

>	If you need to update all overlays you can use regenerate_icons(). it works exactly like update_clothing used to.

>	I reimplimented an old unused variable which was in the code called (coincidentally) var/update_icon
	It can be used as another method of triggering regenerate_icons(). It's basically a flag that when set to non-zero
	will call regenerate_icons() at the next life() call and then reset itself to 0.
	The idea behind it is icons are regenerated only once, even if multiple events requested it.

This system is confusing and is still a WIP. It's primary goal is speeding up the controls of the game whilst
reducing processing costs. So please bear with me while I iron out the kinks. It will be worth it, I promise.
If I can eventually free var/lying stuff from the life() process altogether, stuns/death/status stuff
will become less affected by lag-spikes and will be instantaneous! :3

If you have any questions/constructive-comments/bugs-to-report/or have a massivly devestated butt...
Please contact me on #coderbus IRC. ~Carn x
*/

/mob/living/carbon/human
	var/list/overlays_standing[TOTAL_LAYERS]
	var/previous_damage_appearance // store what the body last looked like, so we only have to update it if something changed
	var/icon/skeleton
	var/list/cached_standing_overlays = list() // List of everything currently in a human's actual overlays

//UPDATES OVERLAYS FROM OVERLAYS_LYING/OVERLAYS_STANDING
//this proc is messy as I was forced to include some old laggy cloaking code to it so that I don't break cloakers
//I'll work on removing that stuff by rewriting some of the cloaking stuff at a later date.
/mob/living/carbon/human/update_icons()
	var/stealth = 0
	var/obj/item/clothing/suit/armor/abductor/vest/V // Begin the most snowflakey bullshit code I've ever written. I'm so sorry, but there was no other way.

	for(V in list(wear_suit))
		if(V.stealth_active)
			stealth = 1
			break

	if(stealth)
		icon = V.disguise.icon //if the suit is active, reference the suit's current loaded icon and overlays; this does not include hand overlays
		overlays.Cut()
		cached_standing_overlays.Cut() // Make sure the cache gets rebuilt once the disguise is gone

		for(var/thing in V.disguise.overlays)
			if(thing)
				overlays += thing

		var/image/I  = overlays_standing[L_HAND_LAYER] //manually add both left and right hand, so its independently updated
		if(istype(I))
			overlays += I
		I = overlays_standing[R_HAND_LAYER]
		if(istype(I))
			overlays += I
	else
		icon = stand_icon
		var/list/new_overlays = list()
		var/list/old_overlays = cached_standing_overlays

		// Totally regenerate if something touched our overlays
		if(overlays.len != old_overlays.len)
			overlays.Cut()
			old_overlays.Cut()

		for(var/i in 1 to TOTAL_LAYERS)
			var/image/I = overlays_standing[i]
			if(I)
				if(istype(I))
					// Since we avoid full overlay rebuilds, we have to reorganize the layers manually
					I.layer = (-2 - (TOTAL_LAYERS - i)) // Highest layer gets -2, each prior layer is 1 lower
				new_overlays += I

		if(frozen) // Admin freeze overlay
			new_overlays += frozen

		overlays += (new_overlays - old_overlays)
		overlays -= (old_overlays - new_overlays)
		cached_standing_overlays = new_overlays

	update_transform()

var/global/list/damage_icon_parts = list()

//DAMAGE OVERLAYS
//constructs damage icon for each organ from mask * damage field and saves it in our overlays_ lists
/mob/living/carbon/human/UpdateDamageIcon(var/update_icons=1)
	// first check whether something actually changed about damage appearance
	var/damage_appearance = ""

	for(var/obj/item/organ/external/O in organs)
		if(O.is_stump())
			continue
		if(O.status & ORGAN_DESTROYED) damage_appearance += "d"
		else
			damage_appearance += O.damage_state

	if(damage_appearance == previous_damage_appearance)
		// nothing to do here
		return

	previous_damage_appearance = damage_appearance

	var/icon/standing = new /icon(species.damage_overlays, "00")

	var/image/standing_image = new /image("icon" = standing)

	// blend the individual damage states with our icons
	for(var/obj/item/organ/external/O in organs)
		if(O.is_stump())
			continue
		if(!(O.status & ORGAN_DESTROYED))
			O.update_icon()
			if(O.damage_state == "00") continue
			var/icon/DI
			var/cache_index = "[O.damage_state]/[O.icon_name]/[species.blood_color]/[species.name]"

			if(damage_icon_parts[cache_index] == null)
				DI = new /icon(species.damage_overlays, O.damage_state)			// the damage icon for whole human
				DI.Blend(new /icon(species.damage_mask, O.icon_name), ICON_MULTIPLY)	// mask with this organ's pixels
				DI.Blend(species.blood_color, ICON_MULTIPLY)
				damage_icon_parts[cache_index] = DI
			else
				DI = damage_icon_parts[cache_index]
			standing_image.overlays += DI

	overlays_standing[DAMAGE_LAYER]	= standing_image

	if(update_icons)   update_icons()

//BASE MOB SPRITE
/mob/living/carbon/human/proc/update_body(var/update_icons=1)

	var/husk_color_mod = rgb(96,88,80)
	var/hulk_color_mod = rgb(48,224,40)

	var/husk = (HUSK in src.mutations)
	var/fat = (FAT in src.mutations)
	var/hulk = (HULK in src.mutations)
	var/skeleton = (SKELETON in src.mutations)

	if(species && species.bodyflags & HAS_ICON_SKIN_TONE)
		species.updatespeciescolor(src)

	//CACHING: Generate an index key from visible bodyparts.
	//0 = destroyed, 1 = normal, 2 = robotic, 3 = necrotic.
	//Create a new, blank icon for our mob to use.
	if(stand_icon)
		qdel(stand_icon)
	stand_icon = new(species.icon_template ? species.icon_template : 'icons/mob/human.dmi',"blank")
	var/icon_key = ""
	var/obj/item/organ/internal/eyes/eyes = get_int_organ(/obj/item/organ/internal/eyes)

	if(eyes)
		icon_key += "[rgb(eyes.eye_colour[1], eyes.eye_colour[2], eyes.eye_colour[3])]"
	else
		icon_key += "#000000"

	for(var/organ_tag in species.has_limbs)
		var/obj/item/organ/external/part = organs_by_name[organ_tag]
		if(isnull(part) || part.is_stump() || (part.status & ORGAN_DESTROYED))
			icon_key += "0"
		else if(part.status & ORGAN_ROBOT)
			icon_key += "2[part.model ? "-[part.model]": ""]"
		else if(part.status & ORGAN_DEAD)
			icon_key += "3"
		else
			icon_key += "1"

		if(part)
			icon_key += "[part.species.race_key]"
			icon_key += "[part.dna.GetUIState(DNA_UI_GENDER)]"
			icon_key += "[part.dna.GetUIValue(DNA_UI_SKIN_TONE)]"
			if(part.s_col)
				icon_key += "[rgb(part.s_col[1], part.s_col[2], part.s_col[3])]"
			if(part.s_tone)
				icon_key += "[part.s_tone]"

	icon_key = "[icon_key][husk ? 1 : 0][fat ? 1 : 0][hulk ? 1 : 0][skeleton ? 1 : 0]"

	var/icon/base_icon
	if(human_icon_cache[icon_key])
		base_icon = human_icon_cache[icon_key]
	else
		//BEGIN CACHED ICON GENERATION.
		var/obj/item/organ/external/chest = get_organ("chest")
		base_icon = chest.get_icon(skeleton)

		for(var/obj/item/organ/external/part in organs)
			var/icon/temp = part.get_icon(skeleton)
			//That part makes left and right legs drawn topmost and lowermost when human looks WEST or EAST
			//And no change in rendering for other parts (they icon_position is 0, so goes to 'else' part)
			if(part.icon_position&(LEFT|RIGHT))
				var/icon/temp2 = new('icons/mob/human.dmi',"blank")
				temp2.Insert(new/icon(temp,dir=NORTH),dir=NORTH)
				temp2.Insert(new/icon(temp,dir=SOUTH),dir=SOUTH)
				if(!(part.icon_position & LEFT))
					temp2.Insert(new/icon(temp,dir=EAST),dir=EAST)
				if(!(part.icon_position & RIGHT))
					temp2.Insert(new/icon(temp,dir=WEST),dir=WEST)
				base_icon.Blend(temp2, ICON_OVERLAY)
				if(part.icon_position & LEFT)
					temp2.Insert(new/icon(temp,dir=EAST),dir=EAST)
				if(part.icon_position & RIGHT)
					temp2.Insert(new/icon(temp,dir=WEST),dir=WEST)
				base_icon.Blend(temp2, ICON_UNDERLAY)
			else
				base_icon.Blend(temp, ICON_OVERLAY)

		if(!skeleton)
			if(husk)
				base_icon.ColorTone(husk_color_mod)
			else if(hulk)
				var/list/tone = ReadRGB(hulk_color_mod)
				base_icon.MapColors(rgb(tone[1],0,0),rgb(0,tone[2],0),rgb(0,0,tone[3]))

		//Handle husk overlay.
		if(husk && ("overlay_husk" in icon_states(species.icobase)))
			var/icon/mask = new(base_icon)
			var/icon/husk_over = new(species.icobase,"overlay_husk")
			mask.MapColors(0,0,0,1, 0,0,0,1, 0,0,0,1, 0,0,0,1, 0,0,0,0)
			husk_over.Blend(mask, ICON_ADD)
			base_icon.Blend(husk_over, ICON_OVERLAY)

		human_icon_cache[icon_key] = base_icon

	//END CACHED ICON GENERATION.
	stand_icon.Blend(base_icon,ICON_OVERLAY)
	if(src.species.bodyflags & TAIL_OVERLAPPED) // If the user's species is flagged to have a tail that needs to be overlapped by limbs...
		overlays_standing[LIMBS_LAYER]	= image(stand_icon) // Diverts limbs to their own layer so they can overlay things (i.e. tails).
	else
		overlays_standing[LIMBS_LAYER] = null // So we don't get the old species' sprite splatted on top of the new one's

	//Underwear
	overlays_standing[UNDERWEAR_LAYER]	= null
	var/icon/underwear_standing = new/icon('icons/mob/underwear.dmi',"nude")

	if(underwear && species.clothing_flags & HAS_UNDERWEAR)
		var/datum/sprite_accessory/underwear/U = underwear_list[underwear]
		if(U)
			underwear_standing.Blend(new /icon(U.icon, "uw_[U.icon_state]_s"), ICON_OVERLAY)

	if(undershirt && species.clothing_flags & HAS_UNDERSHIRT)
		var/datum/sprite_accessory/undershirt/U2 = undershirt_list[undershirt]
		if(U2)
			underwear_standing.Blend(new /icon(U2.icon, "us_[U2.icon_state]_s"), ICON_OVERLAY)


	if(socks && species.clothing_flags & HAS_SOCKS)
		var/datum/sprite_accessory/socks/U3 = socks_list[socks]
		if(U3)
			underwear_standing.Blend(new /icon(U3.icon, "sk_[U3.icon_state]_s"), ICON_OVERLAY)

	if(underwear_standing)
		overlays_standing[UNDERWEAR_LAYER]	= image(underwear_standing)


	if(update_icons)
		update_icons()

	if(lip_style  && species && species.flags & HAS_LIPS)
		var/icon/lips = icon("icon"='icons/mob/human_face.dmi', "icon_state"="lips_[lip_style]_s")
		lips.Blend(lip_color, ICON_ADD)

		stand_icon.Blend(lips, ICON_OVERLAY)

	//tail
	update_tail_layer(0)
	//head accessory
	update_head_accessory(0)
	//markings
	update_markings(0)
	//hair
	update_hair(0)
	update_fhair(0)


//MARKINGS OVERLAY
/mob/living/carbon/human/proc/update_markings(var/update_icons=1)
	//Reset our markings
	overlays_standing[MARKINGS_LAYER]	= null

	var/obj/item/organ/external/chest/chest_organ = get_organ("chest")
	if(!chest_organ || chest_organ.is_stump() || (chest_organ.status & ORGAN_DESTROYED) )
		if(update_icons)   update_icons()
		return

	//base icons
	var/icon/markings_standing	= new /icon('icons/mob/body_accessory.dmi',"accessory_none_s")

	if(m_style && m_style != "None")
		var/datum/sprite_accessory/marking_style = marking_styles_list[m_style]
		if(marking_style)
			var/obj/item/organ/external/head/head_organ = get_organ("head")
			if((!head_organ || head_organ.is_stump() || (head_organ.status & ORGAN_DESTROYED)) && marking_style.marking_location == "head")
				return //If the head is destroyed and it is the organ the marking is located on, get us out of here. This prevents floating optical markings on decapitated IPCs, for example.
			var/icon/markings_s = new/icon("icon" = marking_style.icon, "icon_state" = "[marking_style.icon_state]_s")
			if(marking_style.do_colouration)
				markings_s.Blend(rgb(r_markings, g_markings, b_markings), ICON_ADD)
			markings_standing.Blend(markings_s, ICON_OVERLAY)
		else
			//warning("Invalid m_style for [species.name]: [m_style]")

	overlays_standing[MARKINGS_LAYER]	= image(markings_standing)

	if(update_icons)   update_icons()

//HEAD ACCESSORY OVERLAY
/mob/living/carbon/human/proc/update_head_accessory(var/update_icons=1)
	//Reset our head accessory
	overlays_standing[HEAD_ACCESSORY_LAYER]	= null

	var/obj/item/organ/external/head/head_organ = get_organ("head")
	if(!head_organ || head_organ.is_stump() || (head_organ.status & ORGAN_DESTROYED) )
		if(update_icons)   update_icons()
		return

	//masks and helmets can obscure our head accessory
	if( (head && (head.flags & BLOCKHAIR)) || (wear_mask && (wear_mask.flags & BLOCKHAIR)))
		if(update_icons)   update_icons()
		return

	//base icons
	var/icon/head_accessory_standing	= new /icon('icons/mob/body_accessory.dmi',"accessory_none_s")

	if(head_organ.ha_style && (head_organ.species.bodyflags & HAS_HEAD_ACCESSORY))
		var/datum/sprite_accessory/head_accessory_style = head_accessory_styles_list[head_organ.ha_style]
		if(head_accessory_style && head_accessory_style.species_allowed)
			if(head_organ.species.name in head_accessory_style.species_allowed)
				var/icon/head_accessory_s = new/icon("icon" = head_accessory_style.icon, "icon_state" = "[head_accessory_style.icon_state]_s")
				if(head_accessory_style.do_colouration)
					head_accessory_s.Blend(rgb(head_organ.r_headacc, head_organ.g_headacc, head_organ.b_headacc), ICON_ADD)
				head_accessory_standing = head_accessory_s //head_accessory_standing.Blend(head_accessory_s, ICON_OVERLAY)
														   //Having it this way preserves animations. Useful for animated antennae.
		else
			//warning("Invalid ha_style for [species.name]: [ha_style]")

	overlays_standing[HEAD_ACCESSORY_LAYER]	= image(head_accessory_standing)

	if(update_icons)   update_icons()


//HAIR OVERLAY
/mob/living/carbon/human/proc/update_hair(var/update_icons=1)
	//Reset our hair
	overlays_standing[HAIR_LAYER]	= null

	var/obj/item/organ/external/head/head_organ = get_organ("head")
	if(!head_organ || head_organ.is_stump() || (head_organ.status & ORGAN_DESTROYED) )
		if(update_icons)   update_icons()
		return

	//masks and helmets can obscure our hair, unless we're a synthetic
	if( (head && (head.flags & BLOCKHAIR)) || (wear_mask && (wear_mask.flags & BLOCKHAIR)))
		if(update_icons)   update_icons()
		return

	//base icons
	var/icon/hair_standing	= new /icon('icons/mob/human_face.dmi',"bald_s")
	//var/icon/debrained_s = new /icon("icon"='icons/mob/human_face.dmi', "icon_state" = "debrained_s")

	if(head_organ.h_style && !(head && (head.flags & BLOCKHEADHAIR) && !(isSynthetic())))
		var/datum/sprite_accessory/hair_style = hair_styles_list[head_organ.h_style]
		//if(!src.get_int_organ(/obj/item/organ/internal/brain) && src.get_species() != "Machine" )//make it obvious we have NO BRAIN
		//	hair_standing.Blend(debrained_s, ICON_OVERLAY)
		if(hair_style && hair_style.species_allowed)
			if((head_organ.species.name in hair_style.species_allowed) || (head_organ.species.flags & ALL_RPARTS)) //If the head's species is in the list of allowed species for the hairstyle, or the head's species is one flagged to have bodies comprised wholly of cybernetics...
				var/icon/hair_s = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
				if(head_organ.species.name == "Slime People") // I am el worstos
					hair_s.Blend(rgb(r_skin, g_skin, b_skin, 160), ICON_AND)
				else if(hair_style.do_colouration)
					hair_s.Blend(rgb(head_organ.r_hair, head_organ.g_hair, head_organ.b_hair), ICON_ADD)

				hair_standing = hair_s //hair_standing.Blend(hair_s, ICON_OVERLAY)
									   //Having it this way preserves animations. Useful for IPC screens.
		else
			//warning("Invalid h_style for [species.name]: [h_style]")
		//hair_standing.Blend(debrained_s, ICON_OVERLAY)//how does i overlay for fish?

	overlays_standing[HAIR_LAYER]	= image(hair_standing)

	if(update_icons)   update_icons()


//FACIAL HAIR OVERLAY
/mob/living/carbon/human/proc/update_fhair(var/update_icons=1)
	//Reset our facial hair
	overlays_standing[FHAIR_LAYER]	= null

	var/obj/item/organ/external/head/head_organ = get_organ("head")
	if(!head_organ || head_organ.is_stump() || (head_organ.status & ORGAN_DESTROYED) )
		if(update_icons)   update_icons()
		return

	//masks and helmets can obscure our facial hair, unless we're a synthetic
	if( (head && (head.flags & BLOCKHAIR)) || (wear_mask && (wear_mask.flags & BLOCKHAIR)))
		if(update_icons)   update_icons()
		return

	//base icons
	var/icon/face_standing	= new /icon('icons/mob/human_face.dmi',"bald_s")

	if(head_organ.f_style)
		var/datum/sprite_accessory/facial_hair_style = facial_hair_styles_list[head_organ.f_style]
		if(facial_hair_style && facial_hair_style.species_allowed)
			if((head_organ.species.name in facial_hair_style.species_allowed) || (head_organ.species.flags & ALL_RPARTS)) //If the head's species is in the list of allowed species for the hairstyle, or the head's species is one flagged to have bodies comprised wholly of cybernetics...
				var/icon/facial_s = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_s")
				if(head_organ.species.name == "Slime People") // I am el worstos
					facial_s.Blend(rgb(r_skin, g_skin, b_skin, 160), ICON_AND)
				else if(facial_hair_style.do_colouration)
					facial_s.Blend(rgb(head_organ.r_facial, head_organ.g_facial, head_organ.b_facial), ICON_ADD)
				face_standing.Blend(facial_s, ICON_OVERLAY)
		else
			//warning("Invalid f_style for [species.name]: [f_style]")

	overlays_standing[FHAIR_LAYER]	= image(face_standing)

	if(update_icons)   update_icons()

/mob/living/carbon/human/update_mutations(var/update_icons=1)
	var/fat
	if(FAT in mutations)
		fat = "fat"

	var/image/standing	= image("icon" = 'icons/effects/genetics.dmi')
	var/add_image = 0
	var/g = "m"
	if(gender == FEMALE)	g = "f"
	// DNA2 - Drawing underlays.
	for(var/datum/dna/gene/gene in dna_genes)
		if(!gene.block)
			continue
		if(gene.is_active(src))
			var/underlay=gene.OnDrawUnderlays(src,g,fat)
			if(underlay)
				standing.underlays += underlay
				add_image = 1
	for(var/mut in mutations)
		switch(mut)
			if(LASER)
				standing.overlays	+= "lasereyes_s"
				add_image = 1
	if((RESIST_COLD in mutations) && (RESIST_HEAT in mutations))
		standing.underlays	-= "cold[fat]_s"
		standing.underlays	-= "fire[fat]_s"
		standing.underlays	+= "coldfire[fat]_s"
	if(add_image)
		overlays_standing[MUTATIONS_LAYER]	= standing
	else
		overlays_standing[MUTATIONS_LAYER]	= null
	if(update_icons)   update_icons()


/mob/living/carbon/human/proc/update_mutantrace(var/update_icons=1)
//BS12 EDIT
	var/skel = (SKELETON in src.mutations)
	if(skel)
		skeleton = 'icons/mob/human_races/r_skeleton.dmi'
	else
		skeleton = null

	update_hair(0)
	update_fhair(0)
	if(update_icons)   update_icons()


/mob/living/carbon/human/update_fire()
	if(on_fire)
		if(!overlays_standing[FIRE_LAYER])
			overlays_standing[FIRE_LAYER] = image("icon"=fire_dmi, "icon_state"=fire_sprite)
			update_icons()
	else
		overlays_standing[FIRE_LAYER] = null
		update_icons()

/* --------------------------------------- */
//For legacy support.
/mob/living/carbon/human/regenerate_icons()
	..()
	if(notransform)		return
	update_mutations(0)
	update_body(0)
	update_hair(0)
	update_head_accessory(0)
	update_fhair(0)
	update_mutantrace(0)
	update_inv_w_uniform(0,0)
	update_inv_wear_id(0)
	update_inv_gloves(0,0)
	update_inv_glasses(0)
	update_inv_ears(0)
	update_inv_shoes(0,0)
	update_inv_s_store(0)
	update_inv_wear_mask(0)
	update_inv_head(0,0)
	update_inv_belt(0)
	update_inv_back(0)
	update_inv_wear_suit(0)
	update_inv_r_hand(0)
	update_inv_l_hand(0)
	update_inv_handcuffed(0)
	update_inv_legcuffed(0)
	update_inv_pockets(0)
	update_inv_wear_pda(0)
	UpdateDamageIcon(0)
	force_update_limbs()
	update_tail_layer(0)
	overlays.Cut() // Force all overlays to regenerate
	update_fire()
	update_icons()
/* --------------------------------------- */
//vvvvvv UPDATE_INV PROCS vvvvvv

/mob/living/carbon/human/update_inv_w_uniform(var/update_icons=1)

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[slot_w_uniform]
		if(inv)
			inv.update_icon()

	if(w_uniform && istype(w_uniform, /obj/item/clothing/under))
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				w_uniform.screen_loc = ui_iclothing //...draw the item in the inventory screen
			client.screen += w_uniform				//Either way, add the item to the HUD

		var/t_color = w_uniform.item_color
		if(!t_color)		t_color = icon_state
		var/image/standing	= image("icon_state" = "[t_color]_s")

		if(FAT in mutations)
			if(w_uniform.flags_size & ONESIZEFITSALL)
				standing.icon	= 'icons/mob/uniform_fat.dmi'
			else
				to_chat(src, "\red You burst out of \the [w_uniform]!")
				unEquip(w_uniform)
				return
		else
			standing.icon	= 'icons/mob/uniform.dmi'

		if(w_uniform.icon_override)
			standing.icon = w_uniform.icon_override
		else if(w_uniform.sprite_sheets && w_uniform.sprite_sheets[species.name])
			standing.icon = w_uniform.sprite_sheets[species.name]

		if(w_uniform.blood_DNA)
			var/image/bloodsies	= image("icon" = species.blood_mask, "icon_state" = "uniformblood")
			bloodsies.color		= w_uniform.blood_color
			standing.overlays	+= bloodsies

		if(w_uniform:accessories.len)	//WE CHECKED THE TYPE ABOVE. THIS REALLY SHOULD BE FINE.
			for(var/obj/item/clothing/accessory/A in w_uniform:accessories)
				var/tie_color = A.item_color
				if(!tie_color) tie_color = A.icon_state
				if(A.icon_override)
					standing.overlays += image("icon" = A.icon_override, "icon_state" = "[A.icon_state]")
				else if(A.sprite_sheets && A.sprite_sheets[species.name])
					standing.overlays += image("icon" = A.sprite_sheets[species.name], "icon_state" = "[A.icon_state]")
				else
					standing.overlays += image("icon" = 'icons/mob/ties.dmi', "icon_state" = "[tie_color]")

		overlays_standing[UNIFORM_LAYER]	= standing
	else
		overlays_standing[UNIFORM_LAYER]	= null
		// Automatically drop anything in store / id / belt if you're not wearing a uniform.	//CHECK IF NECESARRY
		for( var/obj/item/thing in list(r_store, l_store, wear_id, wear_pda, belt) )						//
			if(thing)																			//
				unEquip(thing)																	//
				if(client)																		//
					client.screen -= thing														//
																								//
				if(thing)																		//
					thing.loc = loc																//
					thing.dropped(src)															//
					thing.layer = initial(thing.layer)
					thing.plane = initial(thing.plane)
	if(update_icons)   update_icons()

/mob/living/carbon/human/update_inv_wear_id(var/update_icons=1)

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[slot_wear_id]
		if(inv)
			inv.update_icon()

	if(wear_id)
		if(client && hud_used && hud_used.hud_shown)
			wear_id.screen_loc = ui_id
			client.screen += wear_id

		if(w_uniform && w_uniform:displays_id)
			overlays_standing[ID_LAYER]	= image("icon" = 'icons/mob/mob.dmi', "icon_state" = "id")
		else
			overlays_standing[ID_LAYER]	= null
	else
		overlays_standing[ID_LAYER]	= null

	if(update_icons)   update_icons()

/mob/living/carbon/human/update_inv_gloves(var/update_icons=1)

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[slot_gloves]
		if(inv)
			inv.update_icon()

	if(gloves)
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				gloves.screen_loc = ui_gloves		//...draw the item in the inventory screen
			client.screen += gloves					//Either way, add the item to the HUD

		var/t_state = gloves.item_state
		if(!t_state)	t_state = gloves.icon_state

		var/image/standing
		if(gloves.icon_override)
			standing = image("icon" = gloves.icon_override, "icon_state" = "[t_state]")
		else if(gloves.sprite_sheets && gloves.sprite_sheets[species.name])
			standing = image("icon" = gloves.sprite_sheets[species.name], "icon_state" = "[t_state]")
		else
			standing = image("icon" = 'icons/mob/hands.dmi', "icon_state" = "[t_state]")

		if(gloves.blood_DNA)
			var/image/bloodsies	= image("icon" = species.blood_mask, "icon_state" = "bloodyhands")
			bloodsies.color = gloves.blood_color
			standing.overlays	+= bloodsies
		overlays_standing[GLOVES_LAYER]	= standing
	else
		if(blood_DNA)
			var/image/bloodsies	= image("icon" = species.blood_mask, "icon_state" = "bloodyhands")
			bloodsies.color = hand_blood_color
			overlays_standing[GLOVES_LAYER]	= bloodsies
		else
			overlays_standing[GLOVES_LAYER]	= null
	if(update_icons)   update_icons()


/mob/living/carbon/human/update_inv_glasses(var/update_icons=1)

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[slot_glasses]
		if(inv)
			inv.update_icon()

	if(glasses)
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				glasses.screen_loc = ui_glasses		//...draw the item in the inventory screen
			client.screen += glasses				//Either way, add the item to the HUD

		if(glasses.icon_override)
			overlays_standing[GLASSES_LAYER] = image("icon" = glasses.icon_override, "icon_state" = "[glasses.icon_state]")
		else if(glasses.sprite_sheets && glasses.sprite_sheets[species.name])
			overlays_standing[GLASSES_LAYER]= image("icon" = glasses.sprite_sheets[species.name], "icon_state" = "[glasses.icon_state]")
		else
			overlays_standing[GLASSES_LAYER]= image("icon" = 'icons/mob/eyes.dmi', "icon_state" = "[glasses.icon_state]")

	else
		overlays_standing[GLASSES_LAYER]	= null
	if(update_icons)   update_icons()

/mob/living/carbon/human/update_inv_ears(var/update_icons=1)

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[slot_l_ear]
		if(inv)
			inv.update_icon()

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[slot_r_ear]
		if(inv)
			inv.update_icon()

	if(l_ear || r_ear)
		if(l_ear)
			if(client && hud_used && hud_used.hud_shown)
				if(hud_used.inventory_shown)			//if the inventory is open ...
					l_ear.screen_loc = ui_l_ear			//...draw the item in the inventory screen
				client.screen += l_ear					//Either way, add the item to the HUD

			var/t_type = l_ear.icon_state
			if(l_ear.icon_override)
				t_type = "[t_type]_l"
				overlays_standing[EARS_LAYER] = image("icon" = l_ear.icon_override, "icon_state" = "[t_type]")
			else if(l_ear.sprite_sheets && l_ear.sprite_sheets[species.name])
				t_type = "[t_type]_l"
				overlays_standing[EARS_LAYER] = image("icon" = l_ear.sprite_sheets[species.name], "icon_state" = "[t_type]")
			else
				overlays_standing[EARS_LAYER] = image("icon" = 'icons/mob/ears.dmi', "icon_state" = "[t_type]")

		if(r_ear)
			if(client && hud_used && hud_used.hud_shown)
				if(hud_used.inventory_shown)			//if the inventory is open ...
					r_ear.screen_loc = ui_r_ear			//...draw the item in the inventory screen
				client.screen += r_ear					//Either way, add the item to the HUD

			var/t_type = r_ear.icon_state
			if(r_ear.icon_override)
				t_type = "[t_type]_r"
				overlays_standing[EARS_LAYER] = image("icon" = r_ear.icon_override, "icon_state" = "[t_type]")
			else if(r_ear.sprite_sheets && r_ear.sprite_sheets[species.name])
				t_type = "[t_type]_r"
				overlays_standing[EARS_LAYER] = image("icon" = r_ear.sprite_sheets[species.name], "icon_state" = "[t_type]")
			else
				overlays_standing[EARS_LAYER] = image("icon" = 'icons/mob/ears.dmi', "icon_state" = "[t_type]")

	else
		overlays_standing[EARS_LAYER]	= null
	if(update_icons)   update_icons()

/mob/living/carbon/human/update_inv_shoes(var/update_icons=1)

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[slot_shoes]
		if(inv)
			inv.update_icon()

	if(shoes)
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				shoes.screen_loc = ui_shoes			//...draw the item in the inventory screen
			client.screen += shoes					//Either way, add the item to the HUD

		var/image/standing
		if(shoes.icon_override)
			standing = image("icon" = shoes.icon_override, "icon_state" = "[shoes.icon_state]")
		else if(shoes.sprite_sheets && shoes.sprite_sheets[species.name])
			standing = image("icon" = shoes.sprite_sheets[species.name], "icon_state" = "[shoes.icon_state]")
		else
			standing = image("icon" = 'icons/mob/feet.dmi', "icon_state" = "[shoes.icon_state]")


		if(shoes.blood_DNA)
			var/image/bloodsies = image("icon" = species.blood_mask, "icon_state" = "shoeblood")
			bloodsies.color = shoes.blood_color
			standing.overlays += bloodsies
		overlays_standing[SHOES_LAYER] = standing
	else
		if(feet_blood_DNA)
			var/image/bloodsies = image("icon" = species.blood_mask, "icon_state" = "shoeblood")
			bloodsies.color = feet_blood_color
			overlays_standing[SHOES_LAYER] = bloodsies
		else
			overlays_standing[SHOES_LAYER] = null
	if(update_icons)   update_icons()

/mob/living/carbon/human/update_inv_s_store(var/update_icons=1)

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[slot_s_store]
		if(inv)
			inv.update_icon()

	if(s_store)
		if(client && hud_used && hud_used.hud_shown)
			s_store.screen_loc = ui_sstore1
			client.screen += s_store

		var/t_state = s_store.item_state
		if(!t_state)
			t_state = s_store.icon_state
		var/dmi='icons/mob/belt_mirror.dmi'
		overlays_standing[SUIT_STORE_LAYER]  = image("icon" = dmi, "icon_state" = "[t_state]")
		s_store.screen_loc = ui_sstore1		//TODO
	else
		overlays_standing[SUIT_STORE_LAYER]	= null
	if(update_icons)   update_icons()


/mob/living/carbon/human/update_inv_head(var/update_icons=1)
	..()
	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[slot_head]
		if(inv)
			inv.update_icon()

	if(head)
		var/image/standing
		if(head.icon_override)
			standing = image("icon" = head.icon_override, "icon_state" = "[head.icon_state]")
		else if(head.sprite_sheets && head.sprite_sheets[species.name])
			standing = image("icon" = head.sprite_sheets[species.name], "icon_state" = "[head.icon_state]")
		else
			standing = image("icon" = 'icons/mob/head.dmi', "icon_state" = "[head.icon_state]")

		if(head.blood_DNA)
			var/image/bloodsies = image("icon" = species.blood_mask, "icon_state" = "helmetblood")
			bloodsies.color = head.blood_color
			standing.overlays	+= bloodsies
		overlays_standing[HEAD_LAYER]	= standing


	else
		overlays_standing[HEAD_LAYER]	= null
	if(update_icons)   update_icons()

/mob/living/carbon/human/update_inv_belt(var/update_icons=1)

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[slot_belt]
		if(inv)
			inv.update_icon()

		if(hud_used.hud_shown && belt)
			client.screen += belt
			belt.screen_loc = ui_belt

	if(belt)
		var/t_state = belt.item_state
		if(!t_state)	t_state = belt.icon_state

		if(belt.icon_override)
			t_state = "[t_state]_be"
			overlays_standing[BELT_LAYER] = image("icon" = belt.icon_override, "icon_state" = "[t_state]")
		else if(belt.sprite_sheets && belt.sprite_sheets[species.name])
			overlays_standing[BELT_LAYER] = image("icon" = belt.sprite_sheets[species.name], "icon_state" = "[t_state]")
		else
			overlays_standing[BELT_LAYER] = image("icon" = 'icons/mob/belt.dmi', "icon_state" = "[t_state]")
	else
		overlays_standing[BELT_LAYER] = null
	if(update_icons)   update_icons()


/mob/living/carbon/human/update_inv_wear_suit(var/update_icons=1)
	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[slot_wear_suit]
		if(inv)
			inv.update_icon()

	if(wear_suit && istype(wear_suit, /obj/item/clothing/suit))
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)					//if the inventory is open ...
				wear_suit.screen_loc = ui_oclothing	//TODO	//...draw the item in the inventory screen
			client.screen += wear_suit						//Either way, add the item to the HUD

		var/image/standing
		if(wear_suit.icon_override)
			standing = image("icon" = wear_suit.icon_override, "icon_state" = "[wear_suit.icon_state]")
		else if(wear_suit.sprite_sheets && wear_suit.sprite_sheets[species.name])
			standing = image("icon" = wear_suit.sprite_sheets[species.name], "icon_state" = "[wear_suit.icon_state]")
		else if(FAT in mutations)
			if(wear_suit.flags_size & ONESIZEFITSALL)
				standing = image("icon" = 'icons/mob/suit_fat.dmi', "icon_state" = "[wear_suit.icon_state]")
			else
				to_chat(src, "\red You burst out of \the [wear_suit]!")
				unEquip(wear_suit)
				return
		else
			standing = image("icon" = 'icons/mob/suit.dmi', "icon_state" = "[wear_suit.icon_state]")


		if( istype(wear_suit, /obj/item/clothing/suit/straight_jacket) )
			unEquip(handcuffed)
			drop_l_hand()
			drop_r_hand()


		if(wear_suit.blood_DNA)
			var/obj/item/clothing/suit/S = wear_suit
			var/image/bloodsies = image("icon" = species.blood_mask, "icon_state" = "[S.blood_overlay_type]blood")
			bloodsies.color = wear_suit.blood_color
			standing.overlays	+= bloodsies


		overlays_standing[SUIT_LAYER]	= standing

		update_tail_layer(0)

	else
		overlays_standing[SUIT_LAYER]	= null

		update_tail_layer(0)

	update_collar(0)

	if(update_icons)   update_icons()

/mob/living/carbon/human/update_inv_pockets()
	if(client && hud_used)
		var/obj/screen/inventory/inv

		inv = hud_used.inv_slots[slot_l_store]
		if(inv)
			inv.update_icon()

		inv = hud_used.inv_slots[slot_r_store]
		if(inv)
			inv.update_icon()

		if(hud_used.hud_shown)
			if(l_store)
				client.screen += l_store
				l_store.screen_loc = ui_storage1

			if(r_store)
				client.screen += r_store
				r_store.screen_loc = ui_storage2

/mob/living/carbon/human/update_inv_wear_pda()
	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[slot_wear_pda]
		if(inv)
			inv.update_icon()

		if(wear_pda)
			client.screen += wear_pda
			wear_pda.screen_loc = ui_pda

/mob/living/carbon/human/update_inv_wear_mask(var/update_icons = 1)
	..()
	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[slot_wear_mask]
		if(inv)
			inv.update_icon()
	if(wear_mask && (istype(wear_mask, /obj/item/clothing/mask) || istype(wear_mask, /obj/item/clothing/accessory)))
		var/image/standing
		if(wear_mask.icon_override)
			standing = image("icon" = wear_mask.icon_override, "icon_state" = "[wear_mask.icon_state]")
		else if(wear_mask.sprite_sheets && wear_mask.sprite_sheets[species.name])
			standing = image("icon" = wear_mask.sprite_sheets[species.name], "icon_state" = "[wear_mask.icon_state]")
		else
			standing = image("icon" = 'icons/mob/mask.dmi', "icon_state" = "[wear_mask.icon_state]")

		if(!istype(wear_mask, /obj/item/clothing/mask/cigarette) && wear_mask.blood_DNA)
			var/image/bloodsies = image("icon" = species.blood_mask, "icon_state" = "maskblood")
			bloodsies.color = wear_mask.blood_color
			standing.overlays += bloodsies
		overlays_standing[FACEMASK_LAYER]	= standing
	else
		overlays_standing[FACEMASK_LAYER]	= null
	if(update_icons)   update_icons()


/mob/living/carbon/human/update_inv_back(var/update_icons=1)
	..()
	if(back)
		//determine the icon to use
		var/icon/standing
		if(back.icon_override)
			standing = image("icon" = back.icon_override, "icon_state" = "[back.icon_state]")
		else if(istype(back, /obj/item/weapon/rig))
			//If this is a rig and a mob_icon is set, it will take species into account in the rig update_icon() proc.
			var/obj/item/weapon/rig/rig = back
			standing = rig.mob_icon
		else if(back.sprite_sheets && back.sprite_sheets[species.name])
			standing = image("icon" = back.sprite_sheets[species.name], "icon_state" = "[back.icon_state]")
		else
			standing = image("icon" = 'icons/mob/back.dmi', "icon_state" = "[back.icon_state]")

		//create the image
		overlays_standing[BACK_LAYER] = standing
	else
		overlays_standing[BACK_LAYER] = null

	if(update_icons)   update_icons()

/mob/living/carbon/human/update_inv_handcuffed(var/update_icons=1)
	overlays_standing[HANDCUFF_LAYER] = null
	if(handcuffed)
		if(istype(handcuffed, /obj/item/weapon/restraints/handcuffs/pinkcuffs))
			overlays_standing[HANDCUFF_LAYER] = image("icon" = 'icons/mob/mob.dmi', "icon_state" = "pinkcuff1")
		else
			overlays_standing[HANDCUFF_LAYER] = image("icon" = 'icons/mob/mob.dmi', "icon_state" = "handcuff1")

	if(update_icons)
		update_icons()

/mob/living/carbon/human/update_inv_legcuffed(var/update_icons=1)
	clear_alert("legcuffed")
	if(legcuffed)
		overlays_standing[LEGCUFF_LAYER]	= image("icon" = 'icons/mob/mob.dmi', "icon_state" = "legcuff1")
		throw_alert("legcuffed", /obj/screen/alert/restrained/legcuffed, new_master = src.legcuffed)
		if(m_intent != "walk")
			m_intent = "walk"
			if(hud_used && hud_used.move_intent)
				hud_used.move_intent.icon_state = "walking"

	else
		overlays_standing[LEGCUFF_LAYER]	= null
	if(update_icons)
		update_icons()


/mob/living/carbon/human/update_inv_r_hand(var/update_icons=1)
	..()
	if(r_hand)
		var/t_state = r_hand.item_state
		if(!t_state)
			t_state = r_hand.icon_state

		var/image/I = image("icon" = r_hand.righthand_file, "icon_state" = "[t_state]")
		I = center_image(I, r_hand.inhand_x_dimension, r_hand.inhand_y_dimension)
		overlays_standing[R_HAND_LAYER] = I
	else
		overlays_standing[R_HAND_LAYER] = null
	if(update_icons)
		update_icons()


/mob/living/carbon/human/update_inv_l_hand(var/update_icons=1)
	..()
	if(l_hand)
		var/t_state = l_hand.item_state
		if(!t_state)
			t_state = l_hand.icon_state

		var/image/I = image("icon" = l_hand.lefthand_file, "icon_state" = "[t_state]")
		I = center_image(I, l_hand.inhand_x_dimension, l_hand.inhand_y_dimension)
		overlays_standing[L_HAND_LAYER] = I
	else
		overlays_standing[L_HAND_LAYER] = null
	if(update_icons)
		update_icons()

//human HUD updates for items in our inventory

//update whether our head item appears on our hud.
/mob/living/carbon/human/update_hud_head(obj/item/I)
	if(client && hud_used && hud_used.hud_shown)
		if(hud_used.inventory_shown)
			I.screen_loc = ui_head
		client.screen += I

//update whether our mask item appears on our hud.
/mob/living/carbon/human/update_hud_wear_mask(obj/item/I)
	if(client && hud_used && hud_used.hud_shown)
		if(hud_used.inventory_shown)
			I.screen_loc = ui_mask
		client.screen += I

//update whether our back item appears on our hud.
/mob/living/carbon/human/update_hud_back(obj/item/I)
	if(client && hud_used && hud_used.hud_shown)
		I.screen_loc = ui_back
		client.screen += I


/mob/living/carbon/human/proc/update_tail_layer(var/update_icons=1)
	overlays_standing[TAIL_UNDERLIMBS_LAYER] = null // SEW direction icons, overlayed by LIMBS_LAYER.
	overlays_standing[TAIL_LAYER] = null // This will be one of two things:
										 // If the species' tail is overlapped by limbs, this will be only the N direction icon so tails can still appear on the outside of uniforms and such.
										 // Otherwise, since the user's tail isn't overlapped by limbs, it will be a full icon with all directions.

	if(body_accessory)
		if(body_accessory.try_restrictions(src))
			var/icon/accessory_s = new/icon("icon" = body_accessory.icon, "icon_state" = body_accessory.icon_state)
			if(species.bodyflags & HAS_SKIN_COLOR)
				accessory_s.Blend(rgb(r_skin, g_skin, b_skin), body_accessory.blend_mode)

			if(species.bodyflags & TAIL_OVERLAPPED) // If the player has a species whose tail is overlapped by limbs...
				// Gives the underlimbs layer SEW direction icons since it's overlayed by limbs and just about everything else anyway.
				var/icon/temp1 = new /icon('icons/mob/body_accessory.dmi',"accessory_none_s")
				if(species.name in body_accessory.allowed_species)
					var/icon/temp = new/icon("icon" = 'icons/mob/body_accessory.dmi', "icon_state" = "[species.tail]_delay")
					temp1 = temp
				else
					var/icon/temp = new/icon("icon" = 'icons/mob/body_accessory.dmi', "icon_state" = "vulptail_delay")
					temp1 = temp

				temp1.Insert(new/icon(accessory_s,dir=SOUTH),dir=SOUTH)
				temp1.Insert(new/icon(accessory_s,dir=EAST),dir=EAST)
				temp1.Insert(new/icon(accessory_s,dir=WEST),dir=WEST)

				overlays_standing[TAIL_UNDERLIMBS_LAYER]	= image(temp1, "pixel_x" = body_accessory.pixel_x_offset, "pixel_y" = body_accessory.pixel_y_offset)

				// Creates a blank icon, and copies accessory_s' north direction sprite into it
				// before passing that to the tail layer that overlays uniforms and such.
				var/icon/temp2 = new /icon('icons/mob/body_accessory.dmi',"accessory_none_s")
				if(species.name in body_accessory.allowed_species)
					var/icon/temp = new/icon("icon" = 'icons/mob/body_accessory.dmi', "icon_state" = "[species.tail]_delay")
					temp2 = temp
				else
					var/icon/temp = new/icon("icon" = 'icons/mob/body_accessory.dmi', "icon_state" = "vulptail_delay")
					temp2 = temp

				temp2.Insert(new/icon(accessory_s,dir=NORTH),dir=NORTH)

				overlays_standing[TAIL_LAYER]	= image(temp2, "pixel_x" = body_accessory.pixel_x_offset, "pixel_y" = body_accessory.pixel_y_offset)
			else // Otherwise, since the user's tail isn't overlapped by limbs, go ahead and use default icon generation.
				overlays_standing[TAIL_LAYER]	= image(accessory_s, "pixel_x" = body_accessory.pixel_x_offset, "pixel_y" = body_accessory.pixel_y_offset)

	else if(species.tail && species.bodyflags & HAS_TAIL) //no tailless tajaran
		if(!wear_suit || !(wear_suit.flags_inv & HIDETAIL) && !istype(wear_suit, /obj/item/clothing/suit/space))
			var/icon/tail_s = new/icon("icon" = 'icons/effects/species.dmi', "icon_state" = "[species.tail]_s")
			if(species.bodyflags & HAS_SKIN_COLOR)
				tail_s.Blend(rgb(r_skin, g_skin, b_skin), ICON_ADD)

			if(species.bodyflags & TAIL_OVERLAPPED) // If the player has a species whose tail is overlapped by limbs...
				// Gives the underlimbs layer SEW direction icons since it's overlayed by limbs and just about everything else anyway.
				var/icon/temp1 = new/icon("icon" = 'icons/effects/species.dmi', "icon_state" = "[species.tail]_delay")
				temp1.Insert(new/icon(tail_s,dir=SOUTH),dir=SOUTH)
				temp1.Insert(new/icon(tail_s,dir=EAST),dir=EAST)
				temp1.Insert(new/icon(tail_s,dir=WEST),dir=WEST)

				overlays_standing[TAIL_UNDERLIMBS_LAYER]	= image(temp1)

				// Creates a blank icon, and copies accessory_s' north direction sprite into it
				// before passing that to the tail layer that overlays uniforms and such.
				var/icon/temp2 = new/icon("icon" = 'icons/effects/species.dmi', "icon_state" = "[species.tail]_delay")
				temp2.Insert(new/icon(tail_s,dir=NORTH),dir=NORTH)

				overlays_standing[TAIL_LAYER]	= image(temp2)
			else // Otherwise, since the user's tail isn't overlapped by limbs, go ahead and use default icon generation.
				overlays_standing[TAIL_LAYER]	= image(tail_s)

	if(update_icons)
		update_icons()


/mob/living/carbon/human/proc/start_tail_wagging(var/update_icons=1)
	overlays_standing[TAIL_UNDERLIMBS_LAYER] = null // SEW direction icons, overlayed by LIMBS_LAYER.
	overlays_standing[TAIL_LAYER] = null // This will be one of two things:
										 // If the species' tail is overlapped by limbs, this will be only the N direction icon so tails can still appear on the outside of uniforms and such.
										 // Otherwise, since the user's tail isn't overlapped by limbs, it will be a full icon with all directions.

	if(body_accessory)
		var/icon/accessory_s = new/icon("icon" = body_accessory.get_animated_icon(), "icon_state" = body_accessory.get_animated_icon_state())
		if(species.bodyflags & HAS_SKIN_COLOR)
			accessory_s.Blend(rgb(r_skin, g_skin, b_skin), body_accessory.blend_mode)

		if(species.bodyflags & TAIL_OVERLAPPED) // If the player has a species whose tail is overlapped by limbs...
			// Gives the underlimbs layer SEW direction icons since it's overlayed by limbs and just about everything else anyway.
			var/icon/temp1 = new /icon('icons/mob/body_accessory.dmi',"accessory_none_s")
			if(body_accessory.allowed_species)
				if(species.name in body_accessory.allowed_species)
					var/icon/temp = new/icon("icon" = 'icons/mob/body_accessory.dmi', "icon_state" = "[species.tail]_delay")
					temp1 = temp
				else
					var/icon/temp = new/icon("icon" = 'icons/mob/body_accessory.dmi', "icon_state" = "vulptail_delay")
					temp1 = temp

			temp1.Insert(accessory_s,dir=SOUTH)
			temp1.Insert(accessory_s,dir=EAST)
			temp1.Insert(accessory_s,dir=WEST)

			overlays_standing[TAIL_UNDERLIMBS_LAYER]	= image(temp1, "pixel_x" = body_accessory.pixel_x_offset, "pixel_y" = body_accessory.pixel_y_offset)

			// Creates a blank icon, and copies accessory_s' north direction sprite into it
			// before passing that to the tail layer that overlays uniforms and such.
			var/icon/temp2 = new /icon('icons/mob/body_accessory.dmi',"accessory_none_s")
			if(species.name in body_accessory.allowed_species) // If the user's species is in the list of allowed species for the currently selected body accessory, use the appropriate animation timing blank
				var/icon/temp = new/icon("icon" = 'icons/mob/body_accessory.dmi', "icon_state" = "[species.tail]_delay")
				temp2 = temp
			else // Else if the user's species is not in the list of allowed species for the currently selected body accessory, this point must have been reached by admin-override. Use vulpkanin timings as default.
				var/icon/temp = new/icon("icon" = 'icons/mob/body_accessory.dmi', "icon_state" = "vulptail_delay")
				temp2 = temp

			temp2.Insert(accessory_s,dir=NORTH)

			overlays_standing[TAIL_LAYER]	= image(temp2, "pixel_x" = body_accessory.pixel_x_offset, "pixel_y" = body_accessory.pixel_y_offset)
		else // Otherwise, since the user's tail isn't overlapped by limbs, go ahead and use default icon generation.
			overlays_standing[TAIL_LAYER]	= image(accessory_s, "pixel_x" = body_accessory.pixel_x_offset, "pixel_y" = body_accessory.pixel_y_offset)

	else if(species.tail && species.bodyflags & HAS_TAIL)
		var/icon/tailw_s = new/icon("icon" = 'icons/effects/species.dmi', "icon_state" = "[species.tail]w_s")
		if(species.bodyflags & HAS_SKIN_COLOR)
			tailw_s.Blend(rgb(r_skin, g_skin, b_skin), ICON_ADD)

		if(species.bodyflags & TAIL_OVERLAPPED) // If the player has a species whose tail is overlapped by limbs...
			// Gives the underlimbs layer SEW direction icons since it's overlayed by limbs and just about everything else anyway.
			var/icon/temp1 = new/icon("icon" = 'icons/effects/species.dmi', "icon_state" = "[species.tail]_delay")
			temp1.Insert(tailw_s,dir=SOUTH)
			temp1.Insert(tailw_s,dir=EAST)
			temp1.Insert(tailw_s,dir=WEST)

			overlays_standing[TAIL_UNDERLIMBS_LAYER]	= image(temp1)

			// Creates a blank icon, and copies accessory_s' north direction sprite into it
			// before passing that to the tail layer that overlays uniforms and such.
			var/icon/temp2 = new/icon("icon" = 'icons/effects/species.dmi', "icon_state" = "[species.tail]_delay")
			temp2.Insert(tailw_s,dir=NORTH)

			overlays_standing[TAIL_LAYER]	= image(temp2)
		else // Otherwise, since the user's tail isn't overlapped by limbs, go ahead and use default icon generation.
			overlays_standing[TAIL_LAYER]	= image(tailw_s)

	if(update_icons)
		update_icons()

/mob/living/carbon/human/proc/stop_tail_wagging(var/update_icons=1)
	overlays_standing[TAIL_UNDERLIMBS_LAYER] = null
	overlays_standing[TAIL_LAYER] = null

	update_tail_layer(update_icons) //just trigger a full update for normal stationary sprites

/mob/living/carbon/human/handle_transform_change()
	..()
	update_tail_layer()

//Adds a collar overlay above the helmet layer if the suit has one
//	Suit needs an identically named sprite in icons/mob/collar.dmi
//  For suits with species_fit and sprite_sheets, an identically named sprite needs to exist in a file like this icons/mob/species/[species_name_here]/collar.dmi.
/mob/living/carbon/human/proc/update_collar(var/update_icons=1)
	var/icon/C = new('icons/mob/collar.dmi')
	var/image/standing = null

	if(wear_suit)
		if(wear_suit.icon_override)
			var/icon_path = "[wear_suit.icon_override]"
			icon_path = "[copytext(icon_path, 1, findtext(icon_path, "/suit.dmi"))]/collar.dmi" //If this file doesn't exist, the end result is that COLLAR_LAYER will be unchanged (empty).
			var/icon/icon_file
			if(fexists(icon_path)) //Just ensuring the nonexistance of a file with the above path won't cause a runtime.
				icon_file = new(icon_path)
			standing = image("icon" = icon_file, "icon_state" = "[wear_suit.icon_state]")
		else if(wear_suit.sprite_sheets && wear_suit.sprite_sheets[species.name])
			var/icon_path = "[wear_suit.sprite_sheets[species.name]]"
			icon_path = "[copytext(icon_path, 1, findtext(icon_path, "/suit.dmi"))]/collar.dmi" //If this file doesn't exist, the end result is that COLLAR_LAYER will be unchanged (empty).
			var/icon/icon_file
			if(fexists(icon_path)) //Just ensuring the nonexistance of a file with the above path won't cause a runtime.
				icon_file = new(icon_path)
			standing = image("icon" = icon_file, "icon_state" = "[wear_suit.icon_state]")
		else
			if(wear_suit.icon_state in C.IconStates())
				standing = image("icon" = C, "icon_state" = "[wear_suit.icon_state]")

	overlays_standing[COLLAR_LAYER]	= standing

	if(update_icons)   update_icons()

/mob/living/carbon/human/proc/force_update_limbs()
	for(var/obj/item/organ/external/O in organs)
		O.sync_colour_to_human(src)
	update_body(0)

/mob/living/carbon/human/proc/get_overlays_copy(list/unwantedLayers)
	var/list/out = new
	for(var/i=1;i<=TOTAL_LAYERS;i++)
		if(overlays_standing[i])
			if(i in unwantedLayers)
				continue
			out += overlays_standing[i]
	return out

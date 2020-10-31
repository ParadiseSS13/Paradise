/obj/item/organ/internal/liver/kidan
	species_type = /datum/species/kidan
	name = "kidan liver"
	icon = 'icons/obj/species_organs/kidan.dmi'
	alcohol_intensity = 0.5


#define KIDAN_LANTERN_HUNGERCOST 0.5
#define KIDAN_LANTERN_MINHUNGER 150
#define KIDAN_LANTERN_LIGHT 5

/obj/item/organ/internal/lantern
	species_type = /datum/species/kidan
	name = "Bioluminescent Lantern"
	desc = "A specialized tissue that reacts with oxygen, nutriment and blood to produce light in Kidan."
	icon = 'icons/obj/species_organs/kidan.dmi'
	icon_state = "kid_lantern"
	origin_tech = "biotech=2"
	w_class = WEIGHT_CLASS_TINY
	parent_organ = "groin"
	slot = "lantern"
	actions_types = list(/datum/action/item_action/organ_action/toggle)
	var/colour
	var/glowing = 0

/obj/item/organ/internal/lantern/ui_action_click()
	if(toggle_biolum())
		if(glowing)
			owner.visible_message("<span class='notice'>[owner] starts to glow!</span>", "<span class='notice'>You enable your bioluminescence.</span>")
		else
			owner.visible_message("<span class='notice'>[owner] fades to dark.</span>", "<span class='notice'>You disable your bioluminescence.</span>")

/obj/item/organ/internal/lantern/on_life()
	..()
	if(glowing)//i hate this but i couldnt figure out a better way
		if(owner.nutrition < KIDAN_LANTERN_MINHUNGER)
			toggle_biolum(1)
			to_chat(owner, "<span class='warning'>You're too hungry to be bioluminescent!</span>")
			return

		if(owner.stat)
			toggle_biolum(1)
			owner.visible_message("<span class='notice'>[owner] fades to dark.</span>")
			return

		owner.set_nutrition(max(owner.nutrition - KIDAN_LANTERN_HUNGERCOST, KIDAN_LANTERN_HUNGERCOST))

		var/new_light = calculate_glow(KIDAN_LANTERN_LIGHT)

		if(!colour)																		//this should never happen in theory
			colour = BlendRGB(owner.m_colours["body"], owner.m_colours["head"], 0.65)	//then again im pretty bad at theoretics

		if(new_light != glowing)
			var/obj/item/organ/external/groin/lbody = owner.get_organ(check_zone(parent_organ))
			lbody.set_light(new_light,l_color = colour)
			glowing = new_light

	return

/obj/item/organ/internal/lantern/on_owner_death()
	if(glowing)
		toggle_biolum(1)

/obj/item/organ/internal/lantern/proc/toggle_biolum(statoverride)
	if(!statoverride && owner.incapacitated())
		to_chat(owner, "<span class='warning'>You cannot alter your bioluminescence in your current state.</span>")
		return 0

	if(!statoverride && owner.nutrition < KIDAN_LANTERN_MINHUNGER)
		to_chat(owner, "<span class='warning'>You're too hungry to be bioluminescent!</span>")
		return 0

	if(!colour)
		colour = BlendRGB(owner.m_colours["head"], owner.m_colours["body"], 0.65)

	if(!glowing)
		var/light = calculate_glow(KIDAN_LANTERN_LIGHT)
		var/obj/item/organ/external/groin/lbody = owner.get_organ(check_zone(parent_organ))
		lbody.set_light(light,l_color = colour)
		glowing = light
		return 1

	else
		var/obj/item/organ/external/groin/lbody = owner.get_organ(check_zone(parent_organ))
		lbody.set_light(0)
		glowing = 0
		return 1

/obj/item/organ/internal/lantern/proc/calculate_glow(light)
	if(!light)
		light = KIDAN_LANTERN_LIGHT //should never happen but just to prevent things from breaking

	var/occlusion = 0 //clothes occluding light

	if(!get_location_accessible(owner, "head"))
		occlusion++
	if(owner.w_uniform && copytext(owner.w_uniform.item_color,-2) != "_d") //jumpsuit not rolled down
		occlusion++
	if(owner.wear_suit)
		occlusion++

	return light - occlusion

/obj/item/organ/internal/lantern/remove(mob/living/carbon/M, special = 0)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M

		if(!colour)								//if its removed before used save the color
			colour = BlendRGB(H.m_colours["body"], H.m_colours["head"], 0.65)

		if(glowing)
			toggle_biolum(1)

	. = ..()

/obj/item/organ/internal/eyes/kidan
	species_type = /datum/species/kidan
	name = "kidan eyeballs"
	icon = 'icons/obj/species_organs/kidan.dmi'

/obj/item/organ/internal/heart/kidan
	species_type = /datum/species/kidan
	name = "kidan heart"
	icon = 'icons/obj/species_organs/kidan.dmi'

/obj/item/organ/internal/brain/kidan
	species_type = /datum/species/kidan
	icon = 'icons/obj/species_organs/kidan.dmi'
	icon_state = "brain2"
	mmi_icon = 'icons/obj/species_organs/kidan.dmi'
	mmi_icon_state = "mmi_full"

/obj/item/organ/internal/lungs/kidan
	species_type = /datum/species/kidan
	name = "kidan lungs"
	icon = 'icons/obj/species_organs/kidan.dmi'

/obj/item/organ/internal/kidneys/kidan
	species_type = /datum/species/kidan
	name = "kidan kidneys"
	icon = 'icons/obj/species_organs/kidan.dmi'

#undef KIDAN_LANTERN_HUNGERCOST
#undef KIDAN_LANTERN_MINHUNGER
#undef KIDAN_LANTERN_LIGHT

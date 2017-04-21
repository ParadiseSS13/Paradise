/obj/item/organ/internal/liver/kidan
	alcohol_intensity = 0.5
	species = "Kidan"

/obj/item/organ/internal/lantern
	name = "bioluminescent lantern"
	desc = "A specialized tissue that reacts with oxygen, nutriment and blood to produce light in Kidan."
	icon_state = "kid_lantern"
	origin_tech = "biotech=2"
	w_class = 1
	parent_organ = "groin"
	slot = "lantern"
	var/colour

/obj/item/organ/internal/lantern/process()
	if(owner.glowing)//i hate this but i couldnt figure out a better way
		if(owner.nutrition < KIDAN_MINHUNGER)
			var/obj/item/organ/external/groin/lbody = owner.get_organ(check_zone(parent_organ))
			lbody.set_light(0)
			owner.glowing = 0
			to_chat(owner, "<span class='warning'>You're too hungry to be bioluminescent!</span>")
			return ..()

		if(owner.stat)
			var/obj/item/organ/external/groin/lbody = owner.get_organ(check_zone(parent_organ))
			lbody.set_light(0)
			owner.glowing = 0
			owner.visible_message("<span class='notice'>[owner] fades to dark.</span>")
			return ..()

		owner.nutrition -= KIDAN_HUNGERCOST

		var/new_light = calculate_glow(KIDAN_LIGHT)

		if(!colour)																		//this should never happen in theory
			colour = BlendRGB(owner.m_colours["body"], owner.m_colours["head"], 0.65)	//then again im pretty bad at theoretics

		if(new_light != owner.glowing)
			var/obj/item/organ/external/groin/lbody = owner.get_organ(check_zone(parent_organ))
			lbody.set_light(new_light,l_color = colour)
			owner.glowing = new_light

	return ..()

/obj/item/organ/internal/lantern/proc/toggle_biolum(var/statoverride)
	if(!statoverride && owner.incapacitated())
		to_chat(owner, "<span class='warning'>You cannot alter your bioluminescence in your current state.</span>")
		return

	if(owner.nutrition < KIDAN_MINHUNGER)
		to_chat(owner, "<span class='warning'>You're too hungry to be bioluminescent!</span>")
		return

	if(!colour)
		colour = BlendRGB(owner.m_colours["head"], owner.m_colours["body"], 0.65)

	if(!owner.glowing)
		var/light = calculate_glow(KIDAN_LIGHT)
		var/obj/item/organ/external/groin/lbody = owner.get_organ(check_zone(parent_organ))
		lbody.set_light(light,l_color = colour)
		owner.glowing = light
		owner.visible_message("<span class='notice'>[owner] starts to glow!</span>", "<span class='notice'>You enable your bioluminescence.</span>")

	else
		var/obj/item/organ/external/groin/lbody = owner.get_organ(check_zone(parent_organ))
		lbody.set_light(0)
		owner.glowing = 0
		owner.visible_message("<span class='notice'>[owner] fades to dark.</span>", "<span class='notice'>You disable your bioluminescence.</span>")

/obj/item/organ/internal/lantern/proc/calculate_glow(var/light)
	if(!light)
		light = KIDAN_LIGHT //should never happen but just to prevent things from breaking

	var/occlusion = 0 //clothes occluding light

	if(!get_location_accessible(owner, "head"))
		occlusion++
	if(owner.w_uniform && copytext(owner.w_uniform.item_color,-2) != "_d") //jumpsuit not rolled down
		occlusion++
	if(owner.wear_suit)
		occlusion++

	return light - occlusion

/obj/item/organ/internal/lantern/insert(mob/living/carbon/M, special = 0)
	..()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.verbs += /mob/living/carbon/human/proc/toggle_biolum

/obj/item/organ/internal/lantern/remove(mob/living/carbon/M, special = 0)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M

		if(!colour)																		//if its removed before used
			colour = BlendRGB(H.m_colours["body"], H.m_colours["head"], 0.65)

		if(H.glowing)
			var/obj/item/organ/external/groin/lbody = owner.get_organ(check_zone(parent_organ))
			lbody.set_light(0)
			owner.glowing = 0

		H.verbs -= /mob/living/carbon/human/proc/toggle_biolum

	. = ..()
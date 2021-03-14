/*
Stabilized extracts:
	Provides a passive buff to the holder.
*/

//To add: Create an effect in crossbreeding/_status_effects.dm with the name "/datum/status_effect/stabilized/[color]"
//Status effect will automatically be applied while held, and lost on drop.

/obj/item/slimecross/stabilized
	name = "stabilized extract"
	desc = "It seems inert, but anything it touches glows softly..."
	effect = "stabilized"
	icon_state = "stabilized"
	var/datum/status_effect/linked_effect
	var/mob/living/owner

/obj/item/slimecross/stabilized/Initialize()
	. = ..()
	START_PROCESSING(SSobj,src)

/obj/item/slimecross/stabilized/Destroy()
	STOP_PROCESSING(SSobj,src)
	qdel(linked_effect)
	return ..()

/obj/item/slimecross/stabilized/process()
	var/humanfound
	if(ishuman(loc))
		humanfound = loc
	if(ishuman(loc.loc)) //Check if in backpack.
		humanfound = (loc.loc)
	if(!humanfound)
		return
	var/mob/living/carbon/human/H = humanfound
	var/effectpath = /datum/status_effect/stabilized
	var/static/list/effects = subtypesof(/datum/status_effect/stabilized)
	for(var/X in effects)
		var/datum/status_effect/stabilized/S = X
		if(initial(S.colour) == colour)
			effectpath = S
			break
	if(!H.has_status_effect(effectpath))
		var/datum/status_effect/stabilized/S = H.apply_status_effect(effectpath)
		owner = H
		S.linked_extract = src
		STOP_PROCESSING(SSobj,src)



//Colors and subtypes:
/obj/item/slimecross/stabilized/grey
	colour = "grey"
	effect_desc = "Makes slimes friendly to the owner"

/obj/item/slimecross/stabilized/orange
	colour = "orange"
	effect_desc = "Passively tries to increase or decrease the owner's body temperature to normal"

/obj/item/slimecross/stabilized/purple
	colour = "purple"
	effect_desc = "Provides a regeneration effect"

/obj/item/slimecross/stabilized/blue
	colour = "blue"
	effect_desc = "Makes the owner immune to slipping on water, soap or foam. Space lube and ice are still too slippery."

/obj/item/slimecross/stabilized/metal
	colour = "metal"
	effect_desc = "Every 30 seconds, adds a sheet of material to a random stack in the owner's backpack."

/obj/item/slimecross/stabilized/yellow
	colour = "yellow"
	effect_desc = "Every ten seconds it recharges a device on the owner by 10%."

/obj/item/slimecross/stabilized/darkpurple
	colour = "dark purple"
	effect_desc = "Gives you burning fingertips, automatically cooking any microwavable food you hold."

/obj/item/slimecross/stabilized/darkblue
	colour = "dark blue"
	effect_desc = "Slowly extinguishes the owner if they are on fire, also wets items like monkey cubes, creating a monkey."

/obj/item/slimecross/stabilized/silver
	colour = "silver"
	effect_desc = "Slows the rate at which the owner loses nutrition"

/obj/item/slimecross/stabilized/bluespace
	colour = "bluespace"
	effect_desc = "On a two minute cooldown, when the owner has taken enough damage, they are teleported to a safe place."

/obj/item/slimecross/stabilized/sepia
	colour = "sepia"
	effect_desc = "Randomly adjusts the owner's speed."

/obj/item/slimecross/stabilized/cerulean
	colour = "cerulean"
	effect_desc = "Creates a duplicate of the owner. If the owner dies they will take control of the duplicate, unless the death was from beheading or gibbing."

/obj/item/slimecross/stabilized/pyrite
	colour = "pyrite"
	effect_desc = "Randomly colors the owner every few seconds."

/obj/item/slimecross/stabilized/red
	colour = "red"
	effect_desc = "Nullifies all equipment based slowdowns."

/obj/item/slimecross/stabilized/green
	colour = "green"
	effect_desc = "Changes the owner's name and appearance while holding this extract."

/obj/item/slimecross/stabilized/pink
	colour = "pink"
	effect_desc = "As long as no creatures are harmed in the owner's presense, they will not attack you. If the peace is broken it takes two minutes to restore."

/obj/item/slimecross/stabilized/rainbow
	colour = "rainbow"
	effect_desc = "Accepts a regenerative extract and automatically uses it if the owner enters a critical condition."
	var/obj/item/slimecross/regenerative/regencore

/obj/item/slimecross/stabilized/rainbow/attackby(obj/item/O, mob/user)
	var/obj/item/slimecross/regenerative/regen = O
	if(istype(regen) && !regencore)
		to_chat(user, "<span class='notice'>You place [O] in [src], prepping the extract for automatic application!</span>")
		regencore = regen
		regen.forceMove(src)
		return
	return ..()

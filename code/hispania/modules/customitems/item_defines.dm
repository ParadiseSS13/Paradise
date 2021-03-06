// Agregamos los items aqui en base a su categoria
// A�adimos los custom items a la DB directamente

///////////////////////////////////////////////////////////////////////
/////////////////////HISPANIA CUSTOM ITEMS/////////////////////
///////////////////////////////////////////////////////////////////////

//////////////////////////////////
////////// Usable Items //////////
//////////////////////////////////


//Codex Arcanum STARTS HERE
/obj/item/toy/codex_arcanum // PapayasTehSkeletor: Codex Arcanun
	name = "codex arcanum"
	desc = "Old book with metal, frame you can't understand the language thats inside"
	icon = 'icons/hispania/obj/items.dmi'
	icon_state = "codex_arcanum"
	item_state = "codex_arcanum"
	var/cooldown = 0

/obj/item/toy/codex_arcanum/attack_self(mob/user)
	if(cooldown < world.time - 60)
		to_chat(user, "<span class='notice'>You try to understand the knowledge from [src]</span>")
		playsound(user, 'sound/hallucinations/behind_you1.ogg', 20, 1)
		cooldown = world.time
	else
		to_chat(user, "<span class='notice'> You fear breaking [src] if you keep using it so you give it a rest</span>")
//Codex Arcanum ENDS HERE

//Gigi STARTS HERE
/mob/living/simple_animal/mouse/white/gigi // Alejodbort: Gigi
	name = "Gigi"
	desc = "A simple white mouse named Gigi."
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "splats"
	can_collar = FALSE
	gold_core_spawnable = NO_SPAWN
//Gigi ENDS HERE

//////////////////////////////////
//////////// Clothing ////////////
//////////////////////////////////

//////////// Gloves //////////////

//////////// Eye Wear ////////////

//////////// Hats ////////////

//////////// Suits ////////////

//KANS WINTERCOAT//

/obj/item/fluff/kans_winter_coat_kit //PLAYER: Kans / CKEY: Magmabros
	name = "Winter-Coat Conversion Kit(Kans)"
	desc = "Flaps of white fabric, probably used to somehow modify a winter coat. Won't help with protection, though."
	icon_state = "modkit"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/fluff/kans_winter_coat_kit/afterattack(atom/target, mob/user, proximity)
	if(!proximity || !ishuman(user) || user.incapacitated())
		return

	if(!istype(target, /obj/item/clothing/suit/hooded/wintercoat))
		to_chat(user, "<span class='warning'>You can't modify [target]!</span>")
		return

	to_chat(user, "<span class='notice'>You modify the appearance of [target].</span>")
	var/obj/item/clothing/suit/hooded/wintercoat = target
	wintercoat.desc = "A custom winter coat made with synthethic materials, it is lighter and softer than normal winter coats, it has a nametag that says: (Kans Windinds)"
	wintercoat.hispania_icon = TRUE
	wintercoat.item_state = "wintercoatkans"
	wintercoat.icon_state = "wintercoatkans"
	wintercoat.icon = 'icons/hispania/obj/custom_items.dmi'
	wintercoat.base_icon = "wintercoatkans"
	wintercoat.hood.hispania_icon = TRUE
	wintercoat.hood.icon_state = "winterhoodkans"
	wintercoat.hood.item_state = "winterhoodkans"
	wintercoat.hood.icon = 'icons/hispania/obj/custom_items.dmi'
	qdel(src)

//Kans wintercoat ENDS HERE

//////////// Uniforms ////////////

//////////// Masks ////////////

//////////// Shoes ////////////

//////////// Sets ////////////

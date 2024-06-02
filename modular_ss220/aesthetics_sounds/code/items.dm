//TODO: /obj/item generic drop & pickup sound from list (cannot figure out how to put it better in list)

/* MISCELLANEOUS */
/obj/item/card
	drop_sound = 'modular_ss220/aesthetics_sounds/sound/handling/drop/card.ogg'
	pickup_sound =  'modular_ss220/aesthetics_sounds/sound/handling/pickup/card.ogg'

/obj/item/coin
	drop_sound = 'modular_ss220/aesthetics_sounds/sound/handling/drop/ring.ogg'
	pickup_sound =  'modular_ss220/aesthetics_sounds/sound/handling/pickup/ring.ogg'

/obj/item/bedsheet
	drop_sound = 'sound/items/handling/cloth_drop.ogg'
	pickup_sound =  'sound/items/handling/cloth_pickup.ogg'

/obj/item/stock_parts
	drop_sound = 'sound/items/handling/component_drop.ogg'
	pickup_sound =  'sound/items/handling/component_pickup.ogg'

/obj/item/beach_ball
	drop_sound = 'modular_ss220/aesthetics_sounds/sound/handling/drop/basketball.ogg'
	pickup_sound =  'modular_ss220/aesthetics_sounds/sound/handling/pickup/basketball.ogg'

/obj/item/ammo_box
	drop_sound = 'modular_ss220/aesthetics_sounds/sound/handling/drop/ammobox.ogg'
	pickup_sound =  'modular_ss220/aesthetics_sounds/sound/handling/pickup/ammobox.ogg'

/* KNIFE */
/obj/item/nullrod/tribal_knife
	drop_sound = 'modular_ss220/aesthetics_sounds/sound/handling/drop/knife.ogg'
	pickup_sound =  'modular_ss220/aesthetics_sounds/sound/handling/pickup/knife.ogg'

/obj/item/kitchen/knife
	drop_sound = 'modular_ss220/aesthetics_sounds/sound/handling/drop/knife.ogg'
	pickup_sound =  'modular_ss220/aesthetics_sounds/sound/handling/pickup/knife.ogg'

/obj/item/kitchen/knife/plastic
	drop_sound = 'modular_ss220/aesthetics_sounds/sound/handling/drop/generic1.ogg'
	pickup_sound = 'modular_ss220/aesthetics_sounds/sound/handling/pickup/generic1.ogg'

/obj/item/kitchen/knife/shiv/carrot
	drop_sound = 'modular_ss220/aesthetics_sounds/sound/handling/drop/generic1.ogg'
	pickup_sound = 'modular_ss220/aesthetics_sounds/sound/handling/pickup/generic1.ogg'

/* CLOTHING */
/obj/item/clothing
	drop_sound = 'modular_ss220/aesthetics_sounds/sound/handling/drop/clothing.ogg'
	pickup_sound =  'modular_ss220/aesthetics_sounds/sound/handling/pickup/clothing.ogg'

/obj/item/clothing/head/helmet
	drop_sound = 'modular_ss220/aesthetics_sounds/sound/handling/drop/helmet.ogg'
	pickup_sound =  'modular_ss220/aesthetics_sounds/sound/handling/pickup/helmet.ogg'

/obj/item/clothing/shoes
	drop_sound = 'modular_ss220/aesthetics_sounds/sound/handling/drop/shoes.ogg'
	pickup_sound =  'modular_ss220/aesthetics_sounds/sound/handling/pickup/shoes.ogg'

/obj/item/clothing/shoes/combat
	drop_sound = 'modular_ss220/aesthetics_sounds/sound/handling/drop/boots.ogg'
	pickup_sound =  'modular_ss220/aesthetics_sounds/sound/handling/pickup/boots.ogg'

/obj/item/clothing/shoes/jackboots
	drop_sound = 'modular_ss220/aesthetics_sounds/sound/handling/drop/boots.ogg'
	pickup_sound =  'modular_ss220/aesthetics_sounds/sound/handling/pickup/boots.ogg'

/obj/item/clothing/shoes/workboots
	drop_sound = 'modular_ss220/aesthetics_sounds/sound/handling/drop/boots.ogg'
	pickup_sound =  'modular_ss220/aesthetics_sounds/sound/handling/pickup/boots.ogg'

/obj/item/clothing/shoes/cowboy
	drop_sound = 'modular_ss220/aesthetics_sounds/sound/handling/drop/boots.ogg'
	pickup_sound =  'modular_ss220/aesthetics_sounds/sound/handling/pickup/boots.ogg'

/obj/item/clothing/shoes/magboots
	drop_sound = 'modular_ss220/aesthetics_sounds/sound/handling/drop/boots.ogg'
	pickup_sound =  'modular_ss220/aesthetics_sounds/sound/handling/pickup/boots.ogg'

/obj/item/clothing/shoes/magboots/clown
	drop_sound = 'modular_ss220/aesthetics_sounds/sound/handling/drop/shoes.ogg'
	pickup_sound =  'modular_ss220/aesthetics_sounds/sound/handling/pickup/shoes.ogg'

/obj/item/clothing/gloves/ring
	drop_sound = 'modular_ss220/aesthetics_sounds/sound/handling/drop/ring.ogg'
	pickup_sound =  'modular_ss220/aesthetics_sounds/sound/handling/pickup/ring.ogg'

/* ACCESSORIES */

/obj/item/clothing/accessory/holster
	var/sound_holster = 'modular_ss220/aesthetics_sounds/sound/handling/holsterin.ogg'
	var/sound_unholster = 'modular_ss220/aesthetics_sounds/sound/handling/holsterout.ogg'

/obj/item/clothing/accessory/holster/holster(obj/item/I, mob/user as mob)
	. = ..()
	var/obj/item/gun/W = I
	if(isgun(I) && can_holster(W) && user.canUnEquip(W, 0))
		playsound(user.loc, sound_holster, 20, 1)

/obj/item/clothing/accessory/holster/unholster(mob/user as mob)
	. = ..()
	playsound(user.loc, sound_unholster, 20, 1)

/obj/item/clothing/accessory/holobadge
	drop_sound = 'modular_ss220/aesthetics_sounds/sound/handling/drop/accessory.ogg'
	pickup_sound =  'modular_ss220/aesthetics_sounds/sound/handling/pickup/accessory.ogg'

/obj/item/clothing/accessory/lawyers_badge
	drop_sound = 'modular_ss220/aesthetics_sounds/sound/handling/drop/accessory.ogg'
	pickup_sound =  'modular_ss220/aesthetics_sounds/sound/handling/pickup/accessory.ogg'

/obj/item/clothing/accessory/medal
	drop_sound = 'modular_ss220/aesthetics_sounds/sound/handling/drop/accessory.ogg'
	pickup_sound =  'modular_ss220/aesthetics_sounds/sound/handling/pickup/accessory.ogg'

/obj/item/clothing/accessory/necklace
	drop_sound = 'modular_ss220/aesthetics_sounds/sound/handling/drop/accessory.ogg'
	pickup_sound =  'modular_ss220/aesthetics_sounds/sound/handling/pickup/accessory.ogg'

/obj/item/clothing/accessory/holster
	drop_sound = 'modular_ss220/aesthetics_sounds/sound/handling/drop/backpack.ogg'
	pickup_sound =  'modular_ss220/aesthetics_sounds/sound/handling/pickup/backpack.ogg'

/obj/item/clothing/accessory/storage
	drop_sound = 'modular_ss220/aesthetics_sounds/sound/handling/drop/backpack.ogg'
	pickup_sound =  'modular_ss220/aesthetics_sounds/sound/handling/pickup/backpack.ogg'

/* GUNS */
/obj/item/gun
	drop_sound = 'modular_ss220/aesthetics_sounds/sound/handling/drop/gun.ogg'
	pickup_sound =  'modular_ss220/aesthetics_sounds/sound/handling/pickup/gun.ogg'

/obj/item/gun/magic
	drop_sound = 'modular_ss220/aesthetics_sounds/sound/handling/drop/generic1.ogg'
	pickup_sound = 'modular_ss220/aesthetics_sounds/sound/handling/pickup/generic1.ogg'

/obj/item/gun/projectile/shotgun/toy
	drop_sound = 'modular_ss220/aesthetics_sounds/sound/handling/drop/generic1.ogg'
	pickup_sound = 'modular_ss220/aesthetics_sounds/sound/handling/pickup/generic1.ogg'

/obj/item/gun/projectile/automatic/toy
	drop_sound = 'modular_ss220/aesthetics_sounds/sound/handling/drop/generic1.ogg'
	pickup_sound = 'modular_ss220/aesthetics_sounds/sound/handling/pickup/generic1.ogg'

/obj/item/gun/projectile/automatic/c20r/toy
	drop_sound = 'modular_ss220/aesthetics_sounds/sound/handling/drop/generic1.ogg'
	pickup_sound = 'modular_ss220/aesthetics_sounds/sound/handling/pickup/generic1.ogg'

/obj/item/gun/projectile/automatic/l6_saw/toy
	drop_sound = 'modular_ss220/aesthetics_sounds/sound/handling/drop/generic1.ogg'
	pickup_sound = 'modular_ss220/aesthetics_sounds/sound/handling/pickup/generic1.ogg'

/obj/item/gun/projectile/automatic/sniper_rifle/toy
	drop_sound = 'modular_ss220/aesthetics_sounds/sound/handling/drop/generic1.ogg'
	pickup_sound = 'modular_ss220/aesthetics_sounds/sound/handling/pickup/generic1.ogg'

/* FIREAXE */
/obj/item/fireaxe
	drop_sound = 'modular_ss220/aesthetics_sounds/sound/handling/drop/axe.ogg'
	pickup_sound =  'modular_ss220/aesthetics_sounds/sound/handling/pickup/axe.ogg'

/obj/item/fireaxe/boneaxe
	drop_sound = 'modular_ss220/aesthetics_sounds/sound/handling/drop/generic1.ogg'
	pickup_sound = 'modular_ss220/aesthetics_sounds/sound/handling/pickup/generic1.ogg'

/obj/item/pickaxe
	drop_sound = 'modular_ss220/aesthetics_sounds/sound/handling/drop/axe.ogg'
	pickup_sound =  'modular_ss220/aesthetics_sounds/sound/handling/pickup/axe.ogg'

/obj/item/pickaxe/bone
	drop_sound = 'modular_ss220/aesthetics_sounds/sound/handling/drop/generic1.ogg'
	pickup_sound = 'modular_ss220/aesthetics_sounds/sound/handling/pickup/generic1.ogg'

/* BACKPACKS */
/obj/item/storage/backpack
	drop_sound = 'modular_ss220/aesthetics_sounds/sound/handling/drop/backpack.ogg'
	pickup_sound =  'modular_ss220/aesthetics_sounds/sound/handling/pickup/backpack.ogg'

/obj/item/storage/bag
	drop_sound = 'modular_ss220/aesthetics_sounds/sound/handling/drop/backpack.ogg'
	pickup_sound =  'modular_ss220/aesthetics_sounds/sound/handling/pickup/backpack.ogg'

/obj/item/storage/belt
	drop_sound = 'modular_ss220/aesthetics_sounds/sound/handling/drop/backpack.ogg'
	pickup_sound =  'modular_ss220/aesthetics_sounds/sound/handling/pickup/backpack.ogg'

/* ORGANS */
/obj/item/organ
	drop_sound = 'modular_ss220/aesthetics_sounds/sound/handling/drop/flesh.ogg'
	pickup_sound =  'modular_ss220/aesthetics_sounds/sound/handling/pickup/flesh.ogg'

/obj/item/organ/internal/cell
	drop_sound = 'sound/items/handling/component_drop.ogg'
	pickup_sound =  'sound/items/handling/component_pickup.ogg'

/obj/item/organ/internal/cyberimp
	drop_sound = 'sound/items/handling/component_drop.ogg'
	pickup_sound =  'sound/items/handling/component_pickup.ogg'

/obj/item/organ/internal/ears/cybernetic
	drop_sound = 'sound/items/handling/component_drop.ogg'
	pickup_sound =  'sound/items/handling/component_pickup.ogg'

/obj/item/organ/internal/ears/microphone
	drop_sound = 'sound/items/handling/component_drop.ogg'
	pickup_sound =  'sound/items/handling/component_pickup.ogg'

/obj/item/organ/internal/eyes/cybernetic
	drop_sound = 'sound/items/handling/component_drop.ogg'
	pickup_sound =  'sound/items/handling/component_pickup.ogg'

/obj/item/organ/internal/heart/cybernetic
	drop_sound = 'sound/items/handling/component_drop.ogg'
	pickup_sound =  'sound/items/handling/component_pickup.ogg'

/obj/item/organ/internal/kidneys/cybernetic
	drop_sound = 'sound/items/handling/component_drop.ogg'
	pickup_sound =  'sound/items/handling/component_pickup.ogg'

/obj/item/organ/internal/liver/cybernetic
	drop_sound = 'sound/items/handling/component_drop.ogg'
	pickup_sound =  'sound/items/handling/component_pickup.ogg'

/obj/item/organ/internal/lungs/cybernetic
	drop_sound = 'sound/items/handling/component_drop.ogg'
	pickup_sound =  'sound/items/handling/component_pickup.ogg'

/datum/game_mode/heist

	var/list/weapons = list(
				list(/obj/item/ammo_box/magazine/wt550m9/wttx,//wt550, 4 mags - 80 rounds
					/obj/item/ammo_box/magazine/wt550m9/wtic,
					/obj/item/ammo_box/magazine/wt550m9/wtap,
					/obj/item/weapon/melee/energy/sword/pirate,
					/obj/item/weapon/gun/projectile/automatic/wt550),

				list(/obj/item/ammo_box/magazine/uzim9mm,//uzi, 3 mags - 96 rounds
					/obj/item/ammo_box/magazine/uzim9mm,
					/obj/item/weapon/melee/energy/sword/pirate,
					/obj/item/weapon/gun/projectile/automatic/mini_uzi),

				list(/obj/item/ammo_box/magazine/ap10,//ap10, 3 mags - 72 rounds
					/obj/item/ammo_box/magazine/ap10,
					/obj/item/weapon/gun/projectile/automatic/ap10),

				list(/obj/item/ammo_box/magazine/m12g,//bulldog shotty, 24 rounds
					/obj/item/ammo_box/magazine/m12g/buckshot,
					/obj/item/weapon/gun/projectile/automatic/shotgun/bulldog),

				list(/obj/item/ammo_box/shotgun/buck,//combat shotty, 27 rounds
					/obj/item/ammo_box/shotgun/buck,
					/obj/item/weapon/gun/projectile/shotgun/automatic/combat),

				list(/obj/item/ammo_box/a357,//mateba, 4 mags - 28 rounds, a classic baton (the one that stuns, but isn't collapsible)
					/obj/item/ammo_box/a357,
					/obj/item/ammo_box/a357,
					/obj/item/weapon/gun/projectile/revolver/mateba,
					/obj/item/weapon/melee/classic_baton),

				list(/obj/item/ammo_box/magazine/m45,//m1911, 5 mags - 40 rounds, plus an ESABER, YARRRR
					/obj/item/ammo_box/magazine/m45,
					/obj/item/ammo_box/magazine/m45,
					/obj/item/ammo_box/magazine/m45,
					/obj/item/weapon/gun/projectile/automatic/pistol/m1911,
					/obj/item/weapon/melee/energy/sword/pirate),
					)

	var/list/space_suits = list(
				list(/obj/item/clothing/suit/space/syndicate/black/orange,
					/obj/item/clothing/head/helmet/space/syndicate/black/orange),

				list(/obj/item/clothing/suit/space/syndicate/black/engie,
					/obj/item/clothing/head/helmet/space/syndicate/black/engie),

				list(/obj/item/clothing/suit/space/syndicate/black/med,
					/obj/item/clothing/head/helmet/space/syndicate/black/med),

				list(/obj/item/clothing/suit/space/syndicate/black/blue,
					/obj/item/clothing/head/helmet/space/syndicate/black/blue),

				list(/obj/item/clothing/suit/space/syndicate/blue,
					/obj/item/clothing/head/helmet/space/syndicate/blue),

				list(/obj/item/clothing/suit/space/syndicate/orange,
					/obj/item/clothing/head/helmet/space/syndicate/orange),

				list(/obj/item/clothing/suit/space/syndicate/green/dark,
					/obj/item/clothing/head/helmet/space/syndicate/green/dark),

				list(/obj/item/clothing/suit/space/syndicate/green,
					/obj/item/clothing/head/helmet/space/syndicate/green),

				list(/obj/item/clothing/suit/space/syndicate,
					/obj/item/clothing/head/helmet/space/syndicate)
					)

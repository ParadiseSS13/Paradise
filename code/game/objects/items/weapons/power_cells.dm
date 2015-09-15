/obj/item/weapon/stock_parts/cell
	name = "power cell"
	desc = "A rechargable electrochemical power cell."
	icon = 'icons/obj/power.dmi'
	icon_state = "cell"
	item_state = "cell"
	origin_tech = "powerstorage=1"
	force = 5.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	w_class = 3.0
	var/charge = 0	// note %age conveted to actual charge in New
	var/maxcharge = 10000
	rating = 1
	materials = list(MAT_METAL=700, MAT_GLASS=50)
	var/rigged = 0		// true if rigged to explode
	var/minor_fault = 0 //If not 100% reliable, it will build up faults.

	suicide_act(mob/user)
		viewers(user) << "<span class='suicide'>[user] is licking the electrodes of the [src.name]! It looks like \he's trying to commit suicide.</span>"
		return (FIRELOSS)

/obj/item/weapon/stock_parts/cell/crap
	name = "\improper Nanotrasen brand rechargable AA battery"
	desc = "You can't top the plasma top." //TOTALLY TRADEMARK INFRINGEMENT
	origin_tech = "powerstorage=0"
	maxcharge = 5000
	rating = 2
	materials = list(MAT_GLASS=40)

/obj/item/weapon/stock_parts/cell/crap/empty/New()
	..()
	charge = 0

/obj/item/weapon/stock_parts/cell/secborg
	name = "\improper Security borg rechargable D battery"
	origin_tech = "powerstorage=0"
	maxcharge = 6000	//6000 max charge / 1000 charge per shot = six shots
	rating = 2.5
	materials = list(MAT_GLASS=40)

/obj/item/weapon/stock_parts/cell/secborg/empty/New()
	..()
	charge = 0

/obj/item/weapon/stock_parts/cell/high
	name = "high-capacity power cell"
	origin_tech = "powerstorage=2"
	icon_state = "hcell"
	maxcharge = 15000
	rating = 3
	materials = list(MAT_GLASS=60)

/obj/item/weapon/stock_parts/cell/high/empty/New()
	..()
	charge = 0

/obj/item/weapon/stock_parts/cell/super
	name = "super-capacity power cell"
	origin_tech = "powerstorage=5"
	icon_state = "scell"
	maxcharge = 20000
	materials = list(MAT_GLASS=70)
	rating = 4

/obj/item/weapon/stock_parts/cell/super/empty/New()
	..()
	charge = 0

/obj/item/weapon/stock_parts/cell/hyper
	name = "hyper-capacity power cell"
	origin_tech = "powerstorage=6"
	icon_state = "hpcell"
	maxcharge = 30000
	rating = 5
	materials = list(MAT_GLASS=80)

/obj/item/weapon/stock_parts/cell/hyper/empty/New()
	..()
	charge = 0

/obj/item/weapon/stock_parts/cell/bluespace
	name = "bluespace power cell"
	origin_tech = "powerstorage=7"
	icon_state = "bscell"
	maxcharge = 40000
	materials = list(MAT_GLASS=80)
	rating = 6

/obj/item/weapon/stock_parts/cell/bluespace/empty/New()
	..()
	charge = 0

/obj/item/weapon/stock_parts/cell/infinite
	name = "infinite-capacity power cell!"
	icon_state = "icell"
	origin_tech =  null
	maxcharge = 30000
	rating = 6
	materials = list(MAT_GLASS=80)
	use()
		return 1

/obj/item/weapon/stock_parts/cell/potato
	name = "potato battery"
	desc = "A rechargable starch based power cell."
	origin_tech = "powerstorage=1"
	icon = 'icons/obj/power.dmi' //'icons/obj/harvest.dmi'
	icon_state = "potato_cell" //"potato_battery"
	charge = 100
	maxcharge = 3000
	rating = 1
	materials = list()
	minor_fault = 1


/obj/item/weapon/stock_parts/cell/slime
	name = "charged slime core"
	desc = "A yellow slime core infused with plasma, it crackles with power."
	origin_tech = "powerstorage=2;biotech=4"
	icon = 'icons/mob/slimes.dmi' //'icons/obj/harvest.dmi'
	icon_state = "yellow slime extract" //"potato_battery"
	maxcharge = 10000
	rating = 3
	materials = list()

/obj/item/weapon/stock_parts/cell/pulse/carbine
	name = "pulse carbine power cell"
	maxcharge = 4000

/obj/item/weapon/stock_parts/cell/pulse/pistol
	name = "pulse pistol power cell"
	maxcharge = 1600

/obj/item/weapon/stock_parts/cell/ninja
	name = "spider-clan power cell"
	desc = "A standard ninja-suit power cell."
	maxcharge = 10000
	rating = 3
	materials = list(MAT_GLASS=60)

/obj/item/weapon/stock_parts/cell/emproof
	name = "\improper EMP-proof cell"
	desc = "An EMP-proof cell."
	maxcharge = 5000
	rating = 2

/obj/item/weapon/stock_parts/cell/emproof/empty/New()
	..()
	charge = 0

/obj/item/weapon/stock_parts/cell/emproof/emp_act(severity)
	return

/obj/item/weapon/stock_parts/cell/emproof/corrupt()
	return

/obj/item/weapon/stock_parts/cell/temperaturegun
	name = "temperature gun cell"
	desc = "A specially designed power cell for heating and cooling projectiles"
	icon_state = "icell"
	maxcharge = 900	
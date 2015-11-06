/obj/item/weapon/spacecash
	name = "0 credit chip"
	desc = "It's worth 0 credits."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "spacecash"
	opacity = 0
	density = 0
	anchored = 0.0
	force = 1.0
	throwforce = 1.0
	throw_speed = 1
	throw_range = 2
	w_class = 1.0
	var/access = list()
	access = access_crate_cash
	var/worth = 0

/obj/item/weapon/spacecash/c1
	icon_state = "spacecash"
	worth = 1

/obj/item/weapon/spacecash/c10
	icon_state = "spacecash10"
	worth = 10

/obj/item/weapon/spacecash/c20
	icon_state = "spacecash20"
	worth = 20

/obj/item/weapon/spacecash/c50
	icon_state = "spacecash50"
	worth = 50

/obj/item/weapon/spacecash/c100
	icon_state = "spacecash100"
	worth = 100

/obj/item/weapon/spacecash/c200
	icon_state = "spacecash200"
	worth = 200

/obj/item/weapon/spacecash/c500
	icon_state = "spacecash500"
	worth = 500

/obj/item/weapon/spacecash/c1000
	icon_state = "spacecash1000"
	worth = 1000


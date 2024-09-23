/**
  * # Rep Purchase
  *
  * Describes something that can be purchased with Contractor Rep.
  */
/datum/rep_purchase
	/// The display name of the purchase.
	var/name = ""
	/// The description of the purchase.
	var/description = "This shouldn't appear."
	/// The price in Contractor Rep of the purchase.
	var/cost = 0
	/// How many times the purchase can be made.
	/// -1 means infinite stock.
	var/stock = -1

/**
  * Attempts to perform the purchase.
  *
  * Returns TRUE or FALSE depending on whether the purchase succeeded.
  *
  * Arguments:
  * * hub - The contractor hub.
  * * user - The user who is making the purchase.
  */
/datum/rep_purchase/proc/buy(datum/contractor_hub/hub, mob/living/carbon/human/user)
	. = FALSE
	if(hub.owner.current != user)
		to_chat(user, "<span class='warning'>You were not recognized as this hub's original user.</span>")
		return
	if(hub.rep < cost)
		to_chat(user, "<span class='warning'>You do not have enough Rep.</span>")
		return
	if(stock == 0)
		to_chat(user, "<span class='warning'>This item is out of stock.</span>")
		return
	else if(stock > 0)
		stock--
	hub.rep -= cost
	on_buy(hub, user)
	return TRUE

/**
  * Called when the purchase was made successfully.
  *
  * Arguments:
  * * hub - The contractor hub.
  * * user - The user who made the purchase.
  */
/datum/rep_purchase/proc/on_buy(datum/contractor_hub/hub, mob/living/carbon/human/user)
	return

/**
  * # Rep Purchase - Item
  *
  * Describes an item that can be purchased with Contractor Rep.
  */
/datum/rep_purchase/item
	/// The typepath of the item to instantiate and give to the buyer on purchase.
	var/obj/item/item_type = null

/datum/rep_purchase/item/on_buy(datum/contractor_hub/hub, mob/living/carbon/human/user)
	..()
	var/obj/item/I = new item_type(user)
	user.put_in_hands(I)

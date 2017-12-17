//////////////
//OBJECTION!//
//////////////

/obj/item/clothing/accessory/lawyers_badge
	name = "attorney's badge"
	desc = "Fills you with the conviction of JUSTICE. Lawyers tend to want to show it to everyone they meet."
	icon = 'hyntatmta/icons/obj/clothing/ties.dmi'
	icon_override = 'hyntatmta/icons/mob/ties.dmi'
	icon_state = "lawyerbadge"
	item_color = "lawyerbadge"

/obj/item/clothing/accessory/lawyers_badge/on_attached(obj/item/clothing/under/U, mob/user as mob)
	..()
	user.bubble_icon = "lawyer"

/obj/item/clothing/accessory/lawyers_badge/on_removed(mob/user as mob)
	..()
	user.bubble_icon = initial(user.bubble_icon)

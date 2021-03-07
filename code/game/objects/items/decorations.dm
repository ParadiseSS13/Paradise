/obj/item/decorations
	icon = 'icons/obj/decorations.dmi'


//duct tape decorations
/obj/item/decorations/sticky_decorations
	w_class = WEIGHT_CLASS_TINY

/obj/item/decorations/sticky_decorations/New()
	. = ..()
	AddComponent(/datum/component/ducttape, src, null, 0, 0, TRUE)//add this to something to make it sticky but without the tape overlay



/obj/item/decorations/sticky_decorations/flammable
	resistance_flags = FLAMMABLE


//Non-holiday decorations

/obj/item/decorations/sticky_decorations/flammable/heart
	name = "paper heart"
	desc = "Do not break."
	icon_state = "decoration_heart"

/obj/item/decorations/sticky_decorations/flammable/star
	name = "paper star"
	desc = "Throw it and make a wish!"
	icon_state = "decoration_star"

/obj/item/decorations/sticky_decorations/flammable/singleeye
	name = "paper eye"
	desc = "Feels like it stares into your soul."
	icon_state = "paper_eye"

/obj/item/decorations/sticky_decorations/flammable/googlyeyes
	name = "paper googly eyes"
	desc = "Seems to be looking at something with interest."
	icon_state = "paper_googly_eyes"

/obj/item/decorations/sticky_decorations/flammable/paperclock
	name = "paper clock"
	desc = "A paper clock. Right at least twice a day."
	icon_state = "paper_clock"


//Holiday decorations

//Halloween decorations

/obj/item/decorations/sticky_decorations/flammable/jack_o_lantern
	name = "paper jack o'lantern"
	desc = "A paper jack o'lantern. Although you can't put a candle in him he has a fun loving smile none the less!"
	icon_state = "decoration_jack_o_lantern"

/obj/item/decorations/sticky_decorations/flammable/ghost
	name = "paper ghost"
	desc = "A paper ghost. If it starts moving on its own, you know who to call."
	icon_state = "decoration_ghost"

/obj/item/decorations/sticky_decorations/flammable/spider
	name = "paper spider"
	desc = "A paper spider. Creepy but not venomous, thankfully."
	icon_state = "decoration_spider"

/obj/item/decorations/sticky_decorations/flammable/spiderweb
	name = "paper spiderweb"
	desc = "A paper spiderweb. You see someone wrote 'For Rent' on it."
	icon_state = "decoration_spider_web"

/obj/item/decorations/sticky_decorations/flammable/skull
	name = "paper skull"
	desc = "A paper skull. Seems a paper skeleton lost their head!"
	icon_state = "decoration_skull"

/obj/item/decorations/sticky_decorations/flammable/skeleton
	name = "paper skeleton"
	desc = "A paper skeleton. Instead of rattling, his bones rustle."
	icon_state = "decoration_skeleton"

/obj/item/decorations/sticky_decorations/flammable/cauldron
	name = "paper cauldron"
	desc = "A paper cauldron. Careful, a paper witch might be about."
	icon_state = "paper_cauldron"

//Christmas decorations

/obj/item/decorations/sticky_decorations/flammable/snowman
	name = "paper snowman"
	desc = "A paper snowman. This one won't melt when it gets warm."
	icon_state = "decoration_snowman"

/obj/item/decorations/sticky_decorations/flammable/christmas_stocking
	name = "paper stocking"
	desc = "A paper Christmas stocking. Sadly you won't find gifts in it but at least you won't find coal either."
	icon_state = "decoration_christmas_stocking"

/obj/item/decorations/sticky_decorations/flammable/christmas_tree
	name = "paper christmas tree"
	desc = "A paper Christmas tree. Maybe someone will leave a present under it?"
	icon_state = "decoration_christmas_tree"

/obj/item/decorations/sticky_decorations/flammable/snowflake
	name = "paper snowflake"
	desc = "A paper snowflake. Imagine if snow was this big!"
	icon_state = "decoration_snowflake"

/obj/item/decorations/sticky_decorations/flammable/candy_cane
	name = "paper candy cane"
	desc = "A paper candy cane. Sadly, non-edible."
	icon_state = "decoration_candy_cane"

/obj/item/decorations/sticky_decorations/flammable/mistletoe
	name = "paper mistletoe"
	desc = "Paper mistletoe. If you stand next to this, expect to be kissed."
	icon_state = "decoration_mistletoe"

/obj/item/decorations/sticky_decorations/flammable/holly
	name = "paper holly"
	desc = "Paper holly. Wait is it the red berries or the white ones you kiss under?"
	icon_state = "decoration_holly"

//Tinsel

/obj/item/decorations/sticky_decorations/flammable/tinsel
	name = "paper tinsel"
	desc = "Paper tinsel, because Nanotrasen is too cheap to buy the real deal."
	icon_state = "decoration_tinsel_white"

/obj/item/decorations/sticky_decorations/flammable/tinsel/red
	icon_state = "decoration_tinsel_red"

/obj/item/decorations/sticky_decorations/flammable/tinsel/blue
	icon_state = "decoration_tinsel_blue"

/obj/item/decorations/sticky_decorations/flammable/tinsel/yellow
	icon_state = "decoration_tinsel_yellow"

/obj/item/decorations/sticky_decorations/flammable/tinsel/purple
	icon_state = "decoration_tinsel_purple"

/obj/item/decorations/sticky_decorations/flammable/tinsel/green
	icon_state = "decoration_tinsel_green"

/obj/item/decorations/sticky_decorations/flammable/tinsel/orange
	icon_state = "decoration_tinsel_orange"

/obj/item/decorations/sticky_decorations/flammable/tinsel/black
	icon_state = "decoration_tinsel_black"

/obj/item/decorations/sticky_decorations/flammable/tinsel/halloween
	desc = "Paper tinsel, because Nanotrasen is too cheap to buy the real deal. At least this one is spooky."
	icon_state = "decoration_tinsel_halloween"

//Valentines decorations



/obj/item/decorations/sticky_decorations/flammable/arrowed_heart
	name = "paper heart"
	desc = "A paper heart. It's been shot through and Cupid is to blame!"
	icon_state = "decoration_arrow_heart"

/obj/item/decorations/sticky_decorations/flammable/heart_chain
	name = "paper heart chain"
	desc = "A paper chain of hearts. May our hearts always be together."
	icon_state = "decoration_heart_chain"

//St. Patrick's day

/obj/item/decorations/sticky_decorations/flammable/four_leaf_clover
	name = "paper four leaf clover"
	desc = "A paper four leaf clover. Take it with you, it might bring good luck!"
	icon_state = "decoration_four_leaf_clover"

/obj/item/decorations/sticky_decorations/flammable/pot_of_gold
	name = "paper pot of gold"
	desc = "A paper pot of gold. You found the end of the paper rainbow!"
	icon_state = "decoration_pot_o_gold"

/obj/item/decorations/sticky_decorations/flammable/leprechaun_hat
	name = "paper leprechaun hat"
	desc = "A paper leprechaun hat. If you find the paper leprechaun that dropped this they might give you their pot of paper gold!"
	icon_state = "decoration_leprechaun_hat"

//Easter

/obj/item/decorations/sticky_decorations/flammable/easter_bunny
	name = "paper Easter bunny"
	desc = "A paper Easter bunny. Help him find his lost eggs!"
	icon_state = "decoration_easter_bunny"

/obj/item/decorations/sticky_decorations/flammable/easter_egg
	name = "paper Easter egg"
	desc = "A paper Easter egg. If the chef won't let us use their eggs, then this will have to do."
	icon_state = "decoration_easter_egg_blue"

/obj/item/decorations/sticky_decorations/flammable/easter_egg/yellow
	icon_state = "decoration_easter_egg_yellow"

/obj/item/decorations/sticky_decorations/flammable/easter_egg/red
	icon_state = "decoration_easter_egg_red"

/obj/item/decorations/sticky_decorations/flammable/easter_egg/purple
	icon_state = "decoration_easter_egg_purple"

/obj/item/decorations/sticky_decorations/flammable/easter_egg/orange
	icon_state = "decoration_easter_egg_orange"




///////
//Decorative structures
///////


/obj/structure/decorative_structures
	icon = 'icons/obj/decorations.dmi'
	icon_state = ""
	density = 1
	anchored = 0
	max_integrity = 100

/obj/structure/decorative_structures/metal
	flags = CONDUCT

/obj/structure/decorative_structures/metal/statue/metal_angel
	name = "metal angel statue"
	desc = "You feel a holy presence looking back at you."
	icon_state = "metal_angel_statue"

/obj/structure/decorative_structures/metal/statue/golden_disk
	name = "golden disk statue"
	desc = "You aren't sure what the runes say around the large plasma crystal."
	icon_state = "golden_disk_statue"

/obj/structure/decorative_structures/metal/statue/sun
	name = "sun statue"
	desc = "You wonder if you could be so grossly incandescent."
	icon_state = "sun_statue"

/obj/structure/decorative_structures/metal/statue/tesla
	name = "tesla statue"
	desc = "Lady Tesla, a powerful and dangerous mistress."
	icon_state = "tesla_statue"

/obj/structure/decorative_structures/metal/statue/moon
	name = "moon statue"
	desc = "Expect a lot of Vulps to howl around this thing."
	icon_state = "moon_statue"

/obj/structure/decorative_structures/metal/statue/tesla_monument
	name = "tesla monument"
	desc = "Praise be to lady Tesla!"
	icon_state = "tesla_monument"


/obj/structure/decorative_structures/flammable
	resistance_flags = FLAMMABLE
	max_integrity = 50


/obj/structure/decorative_structures/flammable/grandfather_clock
	name = "grandfather clock"
	desc = "Seems the hands have stopped."
	icon_state = "grandfather_clock"

/obj/structure/decorative_structures/flammable/lava_land_display
	name = "lava land display"
	desc = "The tomb of many a miner and possibly a home for much worse things."
	icon_state = "lava_land_display"



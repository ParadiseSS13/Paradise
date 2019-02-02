/*	Hispania bags
 *	These absorb the functionality of the plant bag, ore satchel, etc.
 *	They use the use_to_pickup, quick_gather, and quick_empty functions
 *	that were already defined in weapon/storage, but which had been
 *	re-implemented in other classes.
 *
 *	Contains:
 *		Cookies Tray
 *
 *	-Ume
 */


/obj/item/storage/bag/tray/cookies_tray/New() /// By Azule Utama, thank you a lot!
    ..()
    for(var/i in 1 to 6)
        var/obj/item/C = new /obj/item/reagent_containers/food/snacks/cookie(src)
        handle_item_insertion(C)    // Done this way so the tray actually has the cookies visible when spawned
    rebuild_overlays()
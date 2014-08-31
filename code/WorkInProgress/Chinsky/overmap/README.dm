/*
The overmap system allows adding new maps to the big 'galaxy' map.
Idea is that new sectors can be added by just ticking in new maps and recompiling.
Not real hot-plugging, but still pretty modular.
It uses the fact that all ticked in .dme maps are melded together into one as different zlevels.
Metaobjects are used to make it not affected by map order in .dme and carry some additional info.

*************************************************************
Metaobject
*************************************************************
/obj/effect/mapinfo, sectors.dm
Used to build overmap in beginning, has basic information needed to create overmap objects and make shuttles work.
Its name and icon (if non-standard) vars will be applied to resulting overmap object.
'mapy' and 'mapx' vars are optional, sector will be assigned random overmap coordinates if they are not set.
Has two important vars:
	obj_type	-	type of overmap object it spawns. Could be overriden for custom overmap objects.
	landing_area -	type of area used as inbound shuttle landing, null if no shuttle landing area.

Object could be placed anywhere on zlevel. Should only be placed on zlevel that should appear on overmap as a separate entitety.
Right after creation it sends itself to nullspace and creates an overmap object, corresponding to this zlevel.

*************************************************************
Overmap object
*************************************************************
/obj/effect/map, sectors.dm
Represents a zlevel on the overmap. Spawned by metaobjects at the startup.
	var/area/shuttle/shuttle_landing - keeps a reference to the area of where inbound shuttles should land

-CanPass should be overriden for access restrictions
-Crossed/Uncrossed can be overriden for applying custom effects.
Remember to call ..() in children, it updates ship's current sector.

subtype /ship of this object represents spacefaring vessels.
It has 'current_sector' var that keeps refernce to, well, sector ship currently in.

*************************************************************
Helm console
*************************************************************
/obj/machinery/computer/helm, helm.dm
On creation console seeks a ship overmap object corresponding to this zlevel and links it.
Clicking with empty hand on it starts steering, Cancel-Camera-View stops it.
Helm console relays movement of mob to the linked overmap object.
Helm console currently has no interface. All travel happens instanceously too.
Sector shuttles are not supported currently, only ship shuttles.

*************************************************************
Exploration shuttle terminal
*************************************************************
A generic shuttle controller.
Has a var landing_type defining type of area shuttle should be landing at.
On initalizing, checks for a shuttle corresponding to this zlevel, and creates one if it's not there.
Changes desitnation area depending on current sector ship is in.
Currently updating is called in attack_hand(), until a better place is found.
Currently no modifications were made to interface to display availability of landing area in sector.


*************************************************************
Guide to how make new sector
*************************************************************
0.Map
Remember to define shuttle areas if you want sector be accessible via shuttles.
Currently there are no other ways to reach sectors from ships.
In examples, 4x6 shuttle area is used. In case of shuttle area being too big, it will apear in bottom left corner of it.

Remember to put a helm console and engine control console on ship maps.
Ships need engines to move. Currently there are only thermal engines.
Thermal engines are just a unary atmopheric machine, like a vent. They need high-pressure gas input to produce more thrust.


1.Metaobject
All vars needed for it to work could be set directly in map editor, so in most cases you won't have to define new in code.
Remember to set landing_area var for sectors.

2.Overmap object
If you need custom behaviour on entering/leaving this sector, or restricting access to it, you can define your custom map object.
Remember to put this new type into spawn_type var of metaobject.

3.Shuttle console
Remember to place one on the actual shuttle too, or it won't be able to return from sector without ship-side recall.
Remember to set landing_type var to ship-side shuttle area type.
shuttle_tag can be set to custom name (it shows up in console interface)

5.Engines
Actual engines could be any type of machinery, as long as it creates a ship_engine datum for itself.

6.Tick map in and compile.
Sector should appear on overmap (in random place if you didn't set mapx,mapy)


TODO:
more mechanics to moving ship:
	actually working engine objects
		unary atmospheric machinery
		give more thrust the more pressure gas has
		ships have mass var, which is used to caalculate how much acceleration those engines give
better space travel / stragglers handling
shuttle console:
	checking occupied pad or not with docking controllers
	?landing pad size detection
non-zlevel overmap objects
	field generator
		meteor fields
			speed-based chance for a rock in the ship
		debris fields
			speed-based chance of
				debirs in the ship
				a drone
				EMP
		nebulaes
*/
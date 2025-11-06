# Mapping Design Guide

The purpose of this guide is to instruct how to design maps for Paradise. While
there are many resources on the technical aspects of mapping, this guide instead
focuses on considering mapping from a thematic, functional, and balance
perspective.

## Design Guidelines

Maps are one of the most visible ways of conveying the world and setting of the
server to players. Maps should work to preserve that setting. Paradise Station
takes place in a 26th century universe where multiple space-faring species work
on stations owned by a pangalactic corporate conglomerate. New maps, ruins, and
remaps should make sense within that world.

1. ***Use the appropriate decorative elements and turf types.*** Department
   flooring should use their associated colors: red for Security, brown for
   Cargo, blue for Medbay, and so on. Stations should always use standard walls
   and reinforced walls, and not e.g. plastitanium walls. Stations should always
   use standard airlocks, and not e.g. syndicate hatches or Centcomm airlocks.

2. ***Avoid excessive use of decals or floor tile variants.*** Using too many
   decals or floor tile variants causes unnecessary visual noise. Only use
   decals such as warning tape where it is sensible, e.g. around airlocks that
   lead to space. Decal overuse contributes to maptick slowdown.

2. ***Avoid "Big Room Disease".*** "Big Room Disease" refers to areas on a map
   that are unnecessarily large, empty, and/or square. Rooms should be large
   enough to handle crew foot traffic and facilitate their use, but no larger.
   Furniture should be placed appropriately inside rooms, not just lined along
   their walls. Large rooms should rarely be perfectly square or rectangular.

3. ***Public areas should be interesting.*** "Interesting" is subjective, but
   generally, areas such as public hallways should include space for crew
   interaction; decorations  such as posters, flags, and other decorative
   structures; windows that look out onto space, and floor tiles and decals that
   delineate the space.

4. ***Use appropriate hall sizes.*** Primary hallways should be three tiles
   wide. Arterial hallways off the primary halls should be two tiles wide.
   Intradepartmental corridors should be one or two tiles wide. Exceptions to
   this include the Brig, Medbay, and Science, whose main halls can be three
   tiles wide due to the amount of foot traffic and number of sub departments
   within their space.

5. ***Properly signpost maintenance areas.*** "Signposting" refers to
   environmental factors that make it clear what part of maintenance the player
   is in. For example, while "med maints" on Cyberiad is the area around medbay,
   it is also distinguishable  from its abandoned cryo tube, medical dufflebag,
   operating table, and so on. Note however that this signposting does not need
   to be directly related to nearby departments: for example, mining maints on
   Cyberiad has a small abandoned gambling room, a laundry room, and several
   abandoned shower/bathroom areas. This distinguishes it from other maintenance
   areas despite not directly referencing mining, as players will eventually
   associate these distinct features with that area of maintenance.

6. ***Ensure continuity of scale.*** The size of rooms should make sense
   relative to one another. The chef’s freezer should not be larger than their
   kitchen. The dorm’s bathroom should not be larger than the Captain’s office.
   The scale of rooms should make sense for their expected occupancy and
   purpose. For example, the Heads of Staff Meeting Room should be large enough
   to seat all staff comfortably around a table, with extra space for navigating
   foot traffic around the table.


## Balance Guidelines

Maps should be an unbiased playing field for players, whether ordinary crew,
silicon, antagonists, or midrounds. Players should not be able to rely on a
specific station layout to gain unique advantages over other players.

1. ***Maintain consistent loot counts and opportunities.*** The amount of
   maintenance loot drops should remain consistent, with a slight scaling factor
   based on expected station population. There should be no "treasure troves" or
   hoards of loot hidden that can only be found with specific map knowledge.
   Department supplies should be consistent across maps. Do not place any
   syndicate items/traitor tools on station; always use the provided maintenance
   loot spawners to maintain proper statistical likelihood of rare loot spawns.

2. ***Use appropriate reinforcement.*** Most of the station should be delineated
   with ordinary walls and reinforced windows. Only secure areas should use
   reinforced walls and grilled spawners, and electrified windows should only be
   used in rare cases: department head offices, technical storage, brig,
   xenobio, and AI satellite.

3. ***AI cameras should not have full coverage.*** The AI should not be
   permitted to see into every single room. This makes it challenging for
   antagonists to accomplish their objectives _in situ_. It is not enough to
   have cameras that antagonists can disable, since an AI will notice that the
   camera is out, when it is not usually. Areas appropriate for lacking cameras
   include Operating Rooms, the Therapist’s office, the Execution Chamber, and
   Dormitory bathrooms and shower rooms. Similarly:

4. ***AI cameras should never be placed in maints.*** This is prohibited
   completely. It provides a disproportionately competitive advantage for sec
   against antagonists. Currently there is one exception to this, and that is
   the cameras immediately outside the solar array maintenance areas on
   Cyberiad. These give AI only a vague hint of what is happening nearby, and
   very limited visibility into events in maints.

5. ***Weak points are expected.*** The station is not a battle fortress, and it
   is not fun for antagonists to attempt to ingress/egress deliberately
   impenetrable areas. For example, Permabrig areas will typically have one or
   two tools just out of reach for prisoners to attempt escape. There is a
   toolbox in the far end of the gulag island to give gulag prisoners a chance
   to escape. The Head of Security’s Office is bordered by outer space on two
   station maps. Attempting to break into and out of sensitive areas should be
   challenging, but not impossible.

6. ***Occasionally place vents and scrubbers under furniture.*** Having all
   vents and scrubbers prominently visible hinders ventcrawling antagonists. It
   is easy for crew to forget to weld vents they cannot see.

7. ***Ensure security/antag balance for maintenance tunnels.*** This includes
   but is not limited to: having a primary path that allows navigability from
   all entrances; providing ways for security to flank antagonists and
   coordinate ambushes at maintenance entrances; ensuring that the majority of
   the primary corridors are 2 tiles wide to allow for serpentine movement and
   avoiding projectiles; ensuring that dead ends are rare; and providing places
   for antagonists to hide using hidden walls or similarly difficult to find
   places.

8. ***Allow for escape routes and antag break-in routes.*** Departments should
   be connected to maintenance through a back or side door. This lets players
   escape and allows antags to break in. If this is not possible, departments
   should have extra entry and exit points.

## Functional Guidelines

Stations are malleable. Players can build, rebuild, decorate, upholster, and
equip the station in many ways. Mappers should take this into account when
designing areas and departments. This goes doubly so for ruins: players will
always find a way to work around the restrictions and intended flow of your
ruin. Attempting to enforce a "correct" way of interacting with a map without
deviation is impossible.

1. ***Rooms should have specific and clear functions.*** Public rooms should
   have a clear purpose. Large maintenance areas should appear to have had a
   clear purpose—an abandoned robotics department, for example, or a disused
   monkey-fighting ring. The `/area/station` subtypes enumerate most of what
   rooms are expected within a station and its departments. Even if a room is
   largely meant for player expansion, it should use an appropriate type and
   name, such as the Vacant Office.

2. ***Do not create "perfect" departments.*** The stations are not ideal
   workplaces, not state-of-the-art, and not diligently maintained by
   Nanotrasen. There should always be a gap between the ideal station and how
   the maps are designed. Departments should not come fully featured and
   configured, and should require crew interaction to set up and use
   effectively. Examples of this include Medbay preparing Operating Rooms, Cargo
   arranging the office to make access to the autolathe more convenient, and
   Engineering reconfiguring the supermatter’s pipenet. This scarcity is also
   critical to crew interactions: the Kitchen should have to rely on botany to
   make the full range of recipes, etc.

3. ***Provide surfaces.*** All jobs require managing many different objects,
   items, and pieces of equipment. There should be an adequate number of tables
   and racks available for department members to place things down and drop
   things off.

4. ***Place emergency lockers at appropriate intervals.*** Emergency closets and
   fire-safety closets should be accessible to crew at regular intervals in
   primary hallways, or just off primary hallways in adjacent maintenance
   tunnels.

## Ruin-Specific Guidance

1. ***Balance the risk/reward ratio of a ruin appropriately.*** If a player
   decides that the risk of running a ruin is not worth the reward, they will
   stop running it.

2. ***Not all ruins should provide rare loot.*** "Low-reward" ruins should exist
   to balance out random generation, so that every ruin in a round is not a loot
   resource. These ruins can be purely decorative, provide a place for
   role-play, or provide diegetic/environmental storytelling.

3. ***Ruins should fit the setting, and have a well signposted purpose.*** If,
   for example, your ruin is some kind of abandoned technical/research facility,
   it should should have appropriately defined areas: an obvious entrance, a
   working area for staff and crew, a testing lab, containment area for living
   specimens, some way for staff to have food, restrooms, and living
   quarters/showers if they are intended to stay on the facility for extended
   periods of time.

4. ***Avoid ‘magic’ power whenever possible.*** While infinitely regenerating
   APCs and SMES units exist, they should be used sparingly. Ruins should be as
   realistic as possible and afford players the ability to take advantage of
   being powered or unpowered to navigate or exploit the ruin when possible.

## Shuttle-Specific Guidance

1. ***Shuttles should have clearly defined secure areas and bridges.*** Secure
   areas are for security and prisoner seating. Bridges are for all Command and
   dignitaries, and include the emergency shuttle console. Consideration should
   be given for hijackers and accessibility to the emergency shuttle console, as
   well as the ability of crew to storm the bridge if necessary to prevent a
   hijack.

# Submap-Specific Guidance

1. Submaps should be used to increase variety and add an element of chance to
   player mechanics. They should not be used with an intention to confuse
   players, or to cut off the primary path through the maintenance tunnels.
   Primary paths through maints can make detours but must return to their
   original ingress and egress points. Paths which lead to department maints
   airlocks must remain obvious and easily accessible.

2. All pre-existing balance guidelines regarding mapping apply to submaps. Loot
   counts must remain consistent. Walls should only be reinforced in appropriate
   places. There should be no "treasure troves" or hoards only accessible with
   detailed map knowledge. AI cameras cannot be placed in maints submaps.
   Antag/sec balance, tactical flexibility, and navigability must be considered.
   Dead ends are to be avoided. Department maintenance airlocks may not be moved
   or removed.
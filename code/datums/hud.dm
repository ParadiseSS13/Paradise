/*
HUDs working have like five levels of indirections to them, and can be confusing. Let me try and explain.

Let's take medhud as an example.
We want to display some medical related information (whether the mob is alive, and how much hp it has)
as an icon overlay on the mob sprite.
For that we need:
- several icons (one for hp, one for "alive/dead" indicator)
- which change their `icon_state` depending on the mob's condition
- which accompany every mob
- and are shown to every person with medhud glasses on

`/datum/atom_hud` is a hud *manager*. It stores:
- icon ids
- list of mobs which have those icons shown on them (use `add_to_hud` / `remove_from_hud` to manage)
- and the list of people who can see those icons (use `add_hud_to` / `remove_hud_from` to manage)
There are only few of these managers total, and all of them are in `GLOB.huds`

Each atom that has possible hud icons displayed on top of it, stores those
icons in its `hud_list` var.
These icons get updated whenever the atom itself sees fit, based on some
atom-specific logic.
For example `/mob/living/proc/med_hud_set_health()` gets called whenever mob hp changes,
and that updates the icon by the id of `HEALTH_HUD` in the atom's `hud_list` (makes the hp bar shorter or longer).
This update automatically (i.e. with no extra DM code) makes all the people subscribed
to that icon ID see the updated version of it.

The /datum/atom_hud *sub-types* are merely just presets for "easier" code organization.
If you look at `GLOB.huds` definition you see that, say,
both `ANTAG_HUD_CULT` and `ANTAG_CULT_WIZ` are the same type. But they are different managers!
They display the same icon ID (effectively: their antag icon indicator is in the same place on their sprite),
but they show it to different people (because different hud managers have different people subscribed to them).
And, as a reminder, the icon_state that they are displaying is managed by the atom themselves, so it's the
responsibility of the antag code to set them right. See `/proc/set_antag_hud()` and its callsites for details.


Now, managing whether someone sees other mobs hp bar via the raw `.add_hud_to()` / `.remove_hud_from()`
is rather brittle since we have different *sources* of medhuds (implants, hud glasses, odysseus, etc) -
simply calling `.remove_hud_from()` would remove the hp bar even if you *also* have medhud implant.
In come TRAIT_SEESHUD_FOO traits. These provide an extra level of abstraction; you simply add/remove
the trait when you add / remove a new source of the HUD vision, and the trait/signal magic ensures
that you only lose the vision when the last source gets removed. See `/mob/proc/prepare_seeing_huds()` for more details.

*/

/* HUD DATUMS */
GLOBAL_LIST_EMPTY(all_huds)

///GLOBAL HUD MANAGER LIST
GLOBAL_LIST_INIT(huds, list(
	DATA_HUD_SECURITY_BASIC = new/datum/atom_hud/data/human/security/basic(),
	DATA_HUD_SECURITY_ADVANCED = new/datum/atom_hud/data/human/security/advanced(),
	DATA_HUD_MEDICAL_BASIC = new/datum/atom_hud/data/human/medical/basic(),
	DATA_HUD_MEDICAL_ADVANCED = new/datum/atom_hud/data/human/medical/advanced(),
	DATA_HUD_DIAGNOSTIC_BASIC = new/datum/atom_hud/data/diagnostic/basic(),
	DATA_HUD_DIAGNOSTIC_ADVANCED = new/datum/atom_hud/data/diagnostic/advanced(),
	DATA_HUD_HYDROPONIC = new/datum/atom_hud/data/hydroponic(),
	ANTAG_HUD_CULT = new/datum/atom_hud/antag(),
	ANTAG_HUD_REV = new/datum/atom_hud/antag(),
	ANTAG_HUD_OPS = new/datum/atom_hud/antag(),
	ANTAG_HUD_WIZ  = new/datum/atom_hud/antag(),
	ANTAG_HUD_SHADOW  = new/datum/atom_hud/antag(),
	ANTAG_HUD_TRAITOR = new/datum/atom_hud/antag/hidden(),
	ANTAG_HUD_NINJA = new/datum/atom_hud/antag/hidden(),
	ANTAG_HUD_CHANGELING = new/datum/atom_hud/antag/hidden(),
	ANTAG_HUD_VAMPIRE = new/datum/atom_hud/antag/hidden(),
	ANTAG_HUD_ABDUCTOR = new/datum/atom_hud/antag/hidden(),
	DATA_HUD_ABDUCTOR = new/datum/atom_hud/abductor(),
	ANTAG_HUD_EVENTMISC = new/datum/atom_hud/antag/hidden(),
	ANTAG_HUD_BLOB = new/datum/atom_hud/antag/hidden()
	))

/// TRAIT_SEESHUD_FOO => HUD_FOO conversion list.
// shorter than the above; since there is often exactly one source of HUD vision,
// so no fear of losing it due to multiple sources conflicting.
GLOBAL_LIST_INIT(seeshud_trait_to_hud, list(
	TRAIT_SEESHUD_MEDICAL = DATA_HUD_MEDICAL_ADVANCED,
	TRAIT_SEESHUD_JOB = DATA_HUD_SECURITY_BASIC,
	TRAIT_SEESHUD_SECURITY = DATA_HUD_SECURITY_ADVANCED,
	TRAIT_SEESHUD_HYDROPONIC = DATA_HUD_HYDROPONIC,
	TRAIT_SEESHUD_DIAGNOSTIC = DATA_HUD_DIAGNOSTIC_BASIC,
	TRAIT_SEESHUD_DIAGNOSTIC_ADVANCED = DATA_HUD_DIAGNOSTIC_ADVANCED,
))

/datum/atom_hud
	var/list/atom/hudatoms = list() //list of all atoms which display this hud
	var/list/mob/hudusers = list() //list with all mobs who can see the hud
	var/list/hud_icons = list() //these will be the indexes for the atom's hud_list


/datum/atom_hud/New()
	GLOB.all_huds += src

/datum/atom_hud/Destroy()
	for(var/v in hudusers)
		remove_hud_from(v)
	for(var/v in hudatoms)
		remove_from_hud(v)
	GLOB.all_huds -= src
	return ..()

/// Makes mob M stop seeing the hud icons
/datum/atom_hud/proc/remove_hud_from(mob/M)
	if(!M)
		return
	for(var/atom/A in hudatoms)
		remove_from_single_hud(M, A)
	hudusers -= M

/// Makes hud icons no longer display over atom A
/datum/atom_hud/proc/remove_from_hud(atom/A)
	if(!A)
		return
	for(var/mob/M in hudusers)
		remove_from_single_hud(M, A)
	hudatoms -= A

/datum/atom_hud/proc/remove_from_single_hud(mob/M, atom/A) //unsafe, no sanity apart from client
	if(!M || !M.client || !A)
		return
	for(var/i in hud_icons)
		M.client.images -= A.hud_list[i]

/// Makes mob M see the hud icons
/datum/atom_hud/proc/add_hud_to(mob/M)
	if(!M)
		return
	hudusers |= M
	for(var/atom/A in hudatoms)
		add_to_single_hud(M, A)

/// Makes atom A display icons on top of it
/datum/atom_hud/proc/add_to_hud(atom/A)
	if(!A)
		return
	hudatoms |= A
	for(var/mob/M in hudusers)
		add_to_single_hud(M, A)

/datum/atom_hud/proc/add_to_single_hud(mob/M, atom/A) //unsafe, no sanity apart from client
	if(!M || !M.client || !A)
		return
	for(var/i in hud_icons)
		if(A.hud_list[i])
			M.client.images |= A.hud_list[i]

//MOB PROCS
/mob/proc/reload_huds()
	var/serv_huds = list()//mindslaves and/or vampire thralls
	if(SSticker.mode)
		for(var/datum/mindslaves/serv in (SSticker.mode.vampires | SSticker.mode.traitors))
			serv_huds += serv.thrallhud


	for(var/datum/atom_hud/hud in (GLOB.all_huds|serv_huds))
		if(src in hud.hudusers)
			hud.add_hud_to(src)

/mob/new_player/reload_huds()
	return

/mob/proc/add_click_catcher()
	client.screen += client.void

/mob/new_player/add_click_catcher()
	return

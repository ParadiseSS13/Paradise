# Spawn Pools

Mappers have many useful random spawners to provide variety to their maps.
However, if these spawners provide high-value loot, or rare loot, it can become
difficult to ensure that these spawners are generally balanced.

In some cases this doesn't matter so much. Maintenance loot spawners have free
reign to spawn loot of varying value and the only balancing done is to adjust
the weights of these loots, and scale the amount of spawners to reasonably work
for a given map's size and expected population.

In other situations, like explorer loot in space, a surplus of valuable loot
spawners can quickly give players enormous advantages. This is compounded by the
fact that ruins are generally reviewed for balance in a vacuum, because it would
be too difficult to try and reason through what could spawn on any given round
across all ruins.

Spawn pools were written as an attempt to solve this problem. Pool spawners are
assigned a point value, and registered to a global pool. Spawn pools track these
spawners, and deduct points from a central budget every time one of them spawns
loot. Once the budget runs out, no more spawners from that pool are activated.

## Example

Let's take our explorer loot scenario as before. If we want to register all
explorer loot to a pool, we first need to create the pool as a distinct
`/datum/spawn_pool` subtype:

```dm
/datum/spawn_pool/space_loot
	available_points = 200
```

And then we create the spawners we want, all subtypes of
`/obj/effect/spawner/random/pool`:

```dm
/obj/effect/spawner/random/pool/space_loot
	spawn_pool = /datum/spawn_pool/space_loot

/obj/effect/spawner/random/pool/space_loot/tier1
	point_value = 5
	loot = list(
		/obj/item/soap/syndie,
		/obj/item/stamp/chameleon,
	)

/obj/effect/spawner/random/pool/space_loot/tier2
	point_value = 60
	loot = list(
		/obj/item/ammo_box/magazine/smgm45,
		/obj/item/ammo_box/magazine/apsm10mm/hp,
	)

/obj/effect/spawner/random/pool/space_loot/tier3
	point_value = 100
	loot = list(
		/obj/item/gun/projectile/automatic/pistol/type_230 = 2,
		/obj/item/gun/projectile/automatic/l6_saw = 1,
	)
```

Here we have three different tiers of loot. The lowest tier has low-value items
and a low point value of 5. The middle tier has ammo and a point value of 50.
The highest tier has guns and a point value of 100. Note that you can continue
to use weights in these spawners, as well as all the other features of
`/obj/effect/spawner/random`.

Armed with these three spawners, we can now use them on any ruin we want, in any
quantity. We may put the tier 3 spawner in a difficult, popular ruin, and the
tier 1 spawner in a less popular ruin. Importantly, we can place many of these
spawners, with a guarantee that only a handful will actually receive loot.

Let's examine through some sample runs. Let's say we have:

- two tier 1 spawners
- two tier 2 spawners
- two tier 3 spawners

### Example Scenarios

Spawners are selected at random, so one run might look like this:

1. Pool budget is 200.
2. Tier 3 spawner chosen, gun spawns, budget is now 100.
3. Tier 2 spawner chosen, ammo spawns, budget is now 40.
4. Tier 1 spawner chosen, soap spawns, budget is now 35.

At this point, neither tier 2 or tier 3 spawners can be afforded. If they are
chosen in the random selection, they are discarded, and do not spawn anything.
When the pool reaches the remainin tier 1 spawner, it will proc:

4. Tier 2 spawner chosen, cost too high, does not spawn.
5. Tier 3 spawner chosen, cost too high, does not spawn.
6. Tier 1 spawner chosen, chameleon stamp spawns, budget is now 30.

The pool has now exhausted all its spawners and stops.

Another run may look like this:

1. Pool budget is 200.
2. Tier 3 spawner chosen, gun spawns, budget is now 100.
3. Tier 3 spawner chosen, gun spawns, budget is now 0.

The budget has been exhausted and no more spawners are chosen. Obviously this
second scenario is not ideal, as now only high-value loot has spawned. One of
the ways to fix this is to set the tier 3 cost to 110, rather than 100. That
way, the pool can only afford to ever spawn one of them.

## Nested Spawners

This is not a great usage of the spawn pool. It still means that high value
ruins will have high value loot, and less often explored ruins are still not
worth visiting. What we want to do is expand the amount of variety and
randomness across all ruins.

To do this, we can nest our spawners. Create a new subtype:

```dm
/obj/effect/spawner/random/pool/space_loot/mixed
	loot = list(
		/obj/effect/spawner/random/pool/space_loot/tier1 = 5,
		/obj/effect/spawner/random/pool/space_loot/tier2 = 2,
		/obj/effect/spawner/random/pool/space_loot/tier3 = 1,
	)
```

This works much better for our purposes. Not only are we decreasing the weight
of tier 3 spawns, but we can place one spawner type everywhere, meaning any of
the spawners has a chance of spawning great or passable loot.

By nesting spawners, we gain the fine-grained control we want over drop
likelihood: the budget system, much like ruin placement, is concerned only about
how much loot it should attempt to spawn. The nested spawner's weights dictate
what it is we want to spawn more or less often.

## Unique and Guaranteed Spawners

Pool spawners also expose two other important features: guaranteed and unique
spawns.

If we have ruins that have specialized, valuable loot, we always want the pool
to spawn loot there, no matter what. It would be bad to run a difficult, unique
ruin only to be left with nothing or generic loot from the table.

_Guaranteed spawns_ are a way to fix that. For example, let's say we have a mech
themed ruin and we want the loot to be exosuit parts, but we don't want those
parts spawning anywhere else. We create a distinct subtype:

```dm
/obj/effect/spawner/random/pool/space_loot/mech_ruin
	point_value = 100
	guaranteed = TRUE
	loot = list(
		/obj/item/mecha_parts/mecha_equipment/drill/diamonddrill,
		/obj/item/mecha_parts/mecha_equipment/extinguisher,
		/obj/item/mecha_parts/mecha_equipment/medical/sleeper,
	)
```

By placing this spawner in our ruin, we can guarantee that loot is spawned there
before any other spawners are checked. But we can also include a point value
with it, so that it still counts as part of the overall budget.

Let's say we have an item that we want to be part of the generic pool, but we
only want it to spawn once. This is what _unique spawns_ are for. For example,
say we want to spawn a Syndicate Elite MODsuit, but we only want one spawning
anywhere in space. We create a unique subtype:

```dm
/obj/effect/spawner/random/pool/space_loot/elite_modsuit
	point_value = 100
	unique_picks = TRUE
	loot = list(/obj/item/mod/control/pre_equipped/traitor_elite)
```

If this spawner is chosen, it will spawn the MODsuit, and then the MODsuit will
be removed from the list. Spawners with empty lists are no-ops, so any other
spawners of this type will simply be dropped. By providing rare unique spawns
like this, you can give players motivation to search high and low for elusive
loot, while continuing to ensure the global budget of the spawn pool is
respected.

## Conclusion

Spawn pools are useful and flexible, but they are not magic. Balancing their
spawner values against their budget requires careful consideration and testing,
and you will not get them right on the first try. There are various subtle
things you will have to watch out for. For example, if you make high-value loot
too high in cost but low-value loot too low, then if the budget is too high
you'll end up with a tiny amount of high-value loot (good) but a
disproportionately enormous amount of low-value loot (bad). If you have more
budget than spawners to accomodate it, then you'll end up with unused budget
which will skew balance. Be sure to tweak and experiment.

# The Attack Chain

The vast majority of things that happen when a player performs an action on an
object or another player occurs within the _attack chain_. The attack chain is
the set of procs and signals that determine what should happen when an action is
performed, if an attack should occur, and what to do afterwards.

## Overview

The attack chain is made up of multiple procs and signals which are expected to
respect each other's responses as to how the attack chain should be executed.
For most mobs, this begins in [`/mob/proc/ClickOn`][clickon].

First, any click performed with a modifier key such as `SHIFT` or `ALT` is
handled first in separate procs. A handful of global use cases are handled next,
such as if the user is in a mech, if they are restrained, if they are throwing
an item, or if the thing they're interacting with is an SSD player.

The core of the attack chain commences:

1. If the user is holding the item and clicking on it,
   `/obj/item/activate_self()` is called. This sends `COMSIG_ACTIVATE_SELF` and
   cancels the rest of the attack chain if `COMPONENT_CANCEL_ATTACK_CHAIN` is
   returned by any listeners.
2. If the user can reach the item or it is in relatively accessible inventory
   (three levels deep), the melee attack chain is called via
   `/obj/item/melee_attack_chain()`.
3. If the user is on HELP intent and the item is a tool, the various
   `multitool_act()`/`welder_act()`/`screwdriver_act()`/etc. methods are called
   depending on the tool type. This typically causes the attack chain to end.
4. Several signals are sent: `COMSIG_INTERACT_TARGET`, `COMSIG_INTERACTING`, and
   `COMSIG_INTERACT_USER`. If any listeners request it (usually by returning a
   non-null value), the attack chain may end here.
5. If the target implements `item_interaction()`, it is called here, and can
   return one of the `ITEM_INTERACT_` flags to end the attack chain.
6. If the item being used on the target implements `interact_with_atom()`, it is
   called here, and can return one of the `ITEM_INTERACT_` flags to end the
   attack chain.

The above steps can generally be considered the "item interaction phase", when
the action is not meant to cause in-game harm to the target. If the attack chain
has not been ended, this means we are in the "attack phase":

1. `pre_attack()` is called on the used item, which sends `COMSIG_PRE_ATTACK`,
   and cancels the rest of the attack chain if any listeners return
   `COMPONENT_CANCEL_ATTACK_CHAIN`.
2. `attack_by()` is called on the target. This sends `COMSIG_ATTACKBY`, and
   cancels the rest of the attack chain if any listeners return
   `COMPONENT_SKIP_AFTERATTACK`.
3. `attacked_by()` is called on the target.
4. `COMSIG_AFTER_ATTACK` is sent on the used item, and
   `COMSIG_AFTER_ATTACKED_BY` is sent on the target.

The benefits of this approach is that it allows an enormous amount of
flexibility when it comes to dealing with attacks, while ensuring that behaviors
that are always expected occur consistently.

For a high-level flowchart of the attack chain, see below. Note that this
flowchart may not be 100% accurate/up-to-date. When in doubt, check the
implementation.

<!-- To modify this flowchart, see the file `attack_chain_flowchart.drawio` -->
<!-- The flowchart may be modified with draw.io for Desktop:                -->
<!-- https://github.com/jgraph/drawio-desktop/releases/                     -->

![](./images/attack_chain_flowchart.png)

[clickon]: https://codedocs.paradisestation.org/mob.html#proc/ClickOn

## Why?

A reasonable question to ask would be, why do we need all of these procs and
signals?

A good way to think of the attack chain is as a series of suggestions, rather
than a series of instructions. If a player attacks a mob with an object, there
are many things in the game world that may want to have a say in whether that
will happen, and how it will happen.

For example, there may be a component attached to the player that wants to
intercept whenever an attack is attempted in order to cancel it or substitute
its own action. The item being used to attack may want to cancel the attack
based on its own internal state. The mob or object being attacked may have
specific ways to react to the attack.

By having as many procs and signals as we do, we're allowing all involved
objects and any attached components or elements to contribute their own behavior
into the attack chain.

### ITEM_INTERACT flags

One may also ask why there are several `ITEM_INTERACT_` flags if returning any
of them always results in the end of the attack chain. This is for two reasons:

1. To make it clear at the call site what the intent of the code is, and
2. So that in the future, if we do wish to separate the behavior of these flags,
   we do not need to refactor all of the call sites.

## Attack Chain Refactor

The attack chain was overhauled in [#26834][]. This overhaul introduced several
safeties, renamed many procs and signals, and helped to ensure consistent
handling of signals in order to help make the attack chain more reliable.

[#26834]: https://github.com/ParadiseSS13/Paradise/pull/26834

Prior to the attack chain refactoring, this system was disorganized and its
behavior was not unified. Some procs would call their parent procs, some
wouldn't. Some would send out signals at the right time, some wouldn't. The
attack chain refactor unified all this behavior, but it did not do it across the
entire codebase, all at once.

Instead, a separate codepath was introduced, and all existing uses of the attack
chain were placed in separate procs. These are easily identified by procs which
contain `legacy__attackchain` in the name. The goal is to move all uses of the
legacy attack chain onto the new one, but it would be infeasible to attempt to
do this all at once.

Anyone can choose to migrate attack chains if they so desire to help complete
the migration.

> [!NOTE]
>
> If you are working in code that touches the legacy attack chain, it is
> expected that you migrate the code to the new attack chain first.

## Performing Migrations

Procs with the `__legacy__attackchain` suffix must be carefully understood in
order to migrate them properly. This is not just a matter of renaming procs; it
is expected that a migration preserve all existing behavior while fixing any
potential bugs that were a result of the original implementation.

It is also important to remember: any subtype which is being migrated must have
all of its parent types (up to but not including `/obj/item`) migrated as well.

If you are migrating
`/obj/item/foo/bar/baz/proc/attacked_by__legacy__attackchain()`, then you must
also migrate `/obj/item/foo/bar/proc/attacked_by__legacy__attackchain()` and
`/obj/item/foo/proc/attacked_by__legacy__attackchain()`.

While this may seem overwhelming, the good news is that most migrations are
straightforward, and because you are only migrating a small part of the codebase
at a time, it is easy to test the results.

In order to make this process easier, we'll examine some sample migrations that
have already been performed.

### `attackby`

Many interactions are, in fact, not attacks, and can be migrated over to
`item_interaction()` instead of attempting to fit them in the attack phase of
the chain. Look for cases of `attackby()` where items are being used in ways not
meant to cause damage. These are typically easier migrations.

For our purposes, we'll look at a slightly trickier one: `/obj/item/attackby()`.

Before the migration, this proc included snowflake code both for storage items
and for duct tape. The full proc is too long to show here, but the basic
structure was this:

```dm
/obj/item/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	if(isstorage(I))
		// ... handle putting the item in storage
	else if(istype(I, /obj/item/stack/tape_roll))
		if(isstorage(src)) // Don't tape the bag if we can put the duct tape inside it instead
		var/obj/item/storage/bag = src
		if(bag.can_be_inserted(I))
			return

		// ... apply duct tape to item
```

The first thing worth noting is that none of this has anything to do with
`/obj/item`. This is all subtype specific behavior. That gives us the first clue
what should happen here. The second thing worth noting is we want to
short-circuit the duct-taping if we instead put the duct tape in a bag. The
third thing worth nothing is that none of this is part of the attack phase of
the chain; these are all straightforward item interactions.

Recall that the item interaction order is:

1. Call `target.item_interaction(user, used_item)` and return any
   `ITEM_INTERACT_` flag to cancel the rest of the chain.
2. Call `used_item.interact_with_atom(target, user)` and return any
   `ITEM_INTERACT_` flag to cancel the rest of the chain.

So we first want to put the duct taping code into
`/obj/item/stack/tape_roll/interact_with_atom()`, and the storage pickup code in
`/obj/item/storage/interact_with_atom()`, as those are the default behaviors we
expect. Then, we short-circuit the duct tape's `interact_with_atom()` in the
storage's `item_interaction()` to allow it to handle the case of inserting duct
tape, then skipping the rest of the attack chain.

```dm
/obj/item/stack/tape_roll/interact_with_atom(obj/item/interacting_with, mob/living/user, list/modifiers)
	// ... apply duct tape to item

/obj/item/storage/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	// ... handle putting the item in storage

/obj/item/storage/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/stack/tape_roll) && can_be_inserted(used))
		handle_item_insertion(used, user)
		// Don't tape the bag if we can put the duct tape inside it instead
		return ITEM_INTERACT_SUCCESS
```

Not only does this make the resultant code much more clear, but we don't even
need an `/obj/item/attackby` anymore. We can simply remove it.

> [!NOTE]
>
> When migrating to `interact_with_atom()` and `item_interaction()`, it is not
> necessary to set `new_attack_chain` to `TRUE` if they have no other
> legacy attack chain procs. These procs are exclusive to the new attack chain.

### `attack_self`

`attack_self` is, typically, not part of the chain's attack phase at all. In the
new attack chain, the proc is called `activate_self` to reflect this.

Let's examine the case of airlock electronics, `/obj/item/airlock_electronics`.
This is a good example because it has no parent types we need to migrate. Here
is the proc before the migration:

```dm
/obj/item/airlock_electronics/attack_self__legacy__attackchain(mob/user)
	if(!ishuman(user) && !isrobot(user))
		return ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.getBrainLoss() >= max_brain_damage)
			to_chat(user, "<span class='warning'>You forget how to use [src].</span>")
			return
	ui_interact(user)
```

There's a couple things to note here:

1. Currently, the parent proc is only called if the player is in a mob that
   isn't meant to interact with the electronics; which means the signal
   `COMSIG_ACTIVATE_SELF` is only sent if the electronics _aren't_ activated by
   the user!
2. The behavior regarding brain damage and being unable to use the electronics
   seems like it would be much more useful if generalized into a component, but
   we can ignore that for now.

The first thing we do is ensure that the parent proc is called at the correct
time, and correctly respond to its requests if the interaction should be cancelled:

```diff
/obj/item/airlock_electronics/attack_self__legacy__attackchain(mob/user)
+	if(..())
+		return

	if(!ishuman(user) && !isrobot(user))
		return ..()
```

Secondly, we can pull the other guard clause into the conditional, since it
returns in the same manner:

```diff
/obj/item/airlock_electronics/attack_self__legacy__attackchain(mob/user)
-	if(..())
+	if(..() || (!ishuman(user) && !isrobot(user)))
		return

-	if(!ishuman(user) && !isrobot(user))
-		return ..()
```

Then, we rename the proc:

```diff
-/obj/item/airlock_electronics/attack_self__legacy__attackchain(mob/user)
+/obj/item/airlock_electronics/activate_self(mob/user)
```

And, importantly, we change the value of `var/new_attack_chain` in the
object declaration to let the attack chain know to use the new proc:

```diff
/obj/item/airlock_electronics
	name = "airlock electronics"
	icon = 'icons/obj/doors/door_assembly.dmi'
	// ...

+	new_attack_chain = TRUE
```

The migration is complete. The proc now looks like this:

```dm
/obj/item/airlock_electronics/activate_self(mob/user)
	if(..() || (!ishuman(user) && !isrobot(user)))
		return

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.getBrainLoss() >= max_brain_damage)
			to_chat(user, "<span class='warning'>You forget how to use [src].</span>")
			return
	ui_interact(user)
```

### `attack`

Let's now look at a more complex example, the cult dagger,
`/obj/item/melee/cultblade/dagger`. This is the code as it exists before the
migration:

```dm
/obj/item/melee/cultblade/dagger/attack__legacy__attackchain(mob/living/M, mob/living/user)
	if(IS_CULTIST(M))
		if(M.reagents && M.reagents.has_reagent("holywater")) //allows cultists to be rescued from the clutches of ordained religion
			if(M == user) // Targeting yourself
				to_chat(user, "<span class='warning'>You can't remove holy water from yourself!</span>")
			else // Targeting someone else
				to_chat(user, "<span class='cult'>You remove the taint from [M].</span>")
				to_chat(M, "<span class='cult'>[user] removes the taint from your body.</span>")
				M.reagents.del_reagent("holywater")
				add_attack_logs(user, M, "Hit with [src], removing the holy water from them")
		return FALSE
	else
		var/datum/status_effect/cult_stun_mark/S = M.has_status_effect(STATUS_EFFECT_CULT_STUN)
		if(S)
			S.trigger()
	. = ..()
```

Because the dagger has a parent proc, let's also examine that:

```dm
/obj/item/melee/cultblade/attack__legacy__attackchain(mob/living/target, mob/living/carbon/human/user)
	if(!IS_CULTIST(user))
		user.Weaken(10 SECONDS)
		user.unEquip(src, 1)
		user.visible_message("<span class='warning'>A powerful force shoves [user] away from [target]!</span>",
							"<span class='cultlarge'>\"You shouldn't play with sharp things. You'll poke someone's eye out.\"</span>")
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(rand(force/2, force), BRUTE, pick("l_arm", "r_arm"))
		else
			user.adjustBruteLoss(rand(force/2, force))
		return
	if(!IS_CULTIST(target))
		var/datum/status_effect/cult_stun_mark/S = target.has_status_effect(STATUS_EFFECT_CULT_STUN)
		if(S)
			S.trigger()
	..()
```

There are several codepaths happening here:

1. If a non-cultist attacks with the dagger, they are forced to drop it, gain
   several status effects, and receive brute damage.
2. If a cultist attacks another cultist, it removes holy water from the target.
   If the target has no holy water in them, it does nothing.
3. If a cultist attacks a non-cultist, and the non-cultist has a cult-stun
   status effect, it is prolonged.

Several issues should become apparent while reading through this. First let's
determine when the root `attack()` proc is actually called:

1. In `cultblade/dagger/attack()`, there is an early return if the target is a cultist.
2. In `cultblade/attack()`, there is an early return if the user is _not_ a cultist.

This means that we only wish to follow through with an attack if the user is a
cultist and the target is not. This suggests to us that the code for the first
two codepaths above should come before the `attack()`, logically, the
`pre_attack()`.

(You may also notice a bug in the code. We'll point it out below but see if you
can spot it yourself.)

The first thing we'll do is handle the first codepath, in the dagger's parent
type:

```diff
-/obj/item/melee/cultblade/attack__legacy__attackchain(mob/living/target, mob/living/carbon/human/user)
+/obj/item/melee/cultblade/pre_attack(atom/target, mob/living/user, params)
+	if(..())
+		return FINISH_ATTACK

	if(!IS_CULTIST(user))
		// ...

+		return FINISH_ATTACK
```

We return early if our parent proc asks us to, and we return early if the user
isn't a cultist, because the user can't perform an attack.

We adjust the attack proc itself to check its parent, and perform the cult-stun
trigger. We return nothing to let the attack chain know to continue:

```diff
+/obj/item/melee/cultblade/attack(mob/living/target, mob/living/carbon/human/user)
+       if(..())
+               return FINISH_ATTACK
+
        if(!IS_CULTIST(target))
                var/datum/status_effect/cult_stun_mark/S = target.has_status_effect(STATUS_EFFECT_CULT_STUN)
                if(S)
                        S.trigger()
-       ..()
```

Then we'll handle the dagger itself. Again, we want to cancel the attack chain
if a cultist user is attacking a cultist target, one way or another:

```diff
-/obj/item/melee/cultblade/dagger/attack(mob/living/M, mob/living/user)
-	if(IS_CULTIST(M))
-		if(M.reagents && M.reagents.has_reagent("holywater"))
-			if(M == user) // Targeting yourself
+/obj/item/melee/cultblade/dagger/pre_attack(atom/target, mob/living/user, params)
+	if(..())
+		return FINISH_ATTACK
+
+	if(IS_CULTIST(target))
+		if(target.reagents && target.reagents.has_reagent("holywater"))
+			if(target == user) // Targeting yourself

		// ...

+		return FINISH_ATTACK
```

By regularly calling the parent proc first, it's easier to think through the
process of what's happening. It's much easier to tell that the parent proc
handles failed attacks by non-cultists first, and only if that's not the case
does the holy-water removal behavior run. Since we know we're not a non-cultist
at this point, we don't need to perform a second check for that, either.

This also fixes a bug in the original code. Because the code to re-trigger
cult-stuns on targets was duplicated in both attack procs, it was being called
twice. It's now much easier to tell when that is happening.

The resultant code looks like this:

```dm
/obj/item/melee/cultblade/pre_attack(atom/target, mob/living/user, params)
	if(..())
		return FINISH_ATTACK

	if(!IS_CULTIST(user))
		user.Weaken(10 SECONDS)
		user.unEquip(src, 1)
		user.visible_message("<span class='warning'>A powerful force shoves [user] away from [target]!</span>",
							"<span class='cultlarge'>\"You shouldn't play with sharp things. You'll poke someone's eye out.\"</span>")
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(rand(force/2, force), BRUTE, pick("l_arm", "r_arm"))
		else
			user.adjustBruteLoss(rand(force/2, force))

		return FINISH_ATTACK

/obj/item/melee/cultblade/attack(mob/living/target, mob/living/carbon/human/user)
	if(..())
		return FINISH_ATTACK

	if(!IS_CULTIST(target))
		var/datum/status_effect/cult_stun_mark/S = target.has_status_effect(STATUS_EFFECT_CULT_STUN)
		if(S)
			S.trigger()

/obj/item/melee/cultblade/dagger/pre_attack(atom/target, mob/living/user, params)
	if(..())
		return FINISH_ATTACK

	if(IS_CULTIST(target))
		if(target.reagents && target.reagents.has_reagent("holywater")) //allows cultists to be rescued from the clutches of ordained religion
			if(target == user) // Targeting yourself
				to_chat(user, "<span class='warning'>You can't remove holy water from yourself!</span>")

			else // Targeting someone else
				to_chat(user, "<span class='cult'>You remove the taint from [target].</span>")
				to_chat(target, "<span class='cult'>[user] removes the taint from your body.</span>")
				target.reagents.del_reagent("holywater")
				add_attack_logs(user, target, "Hit with [src], removing the holy water from them")

		return FINISH_ATTACK
```

Not only is it much easier to read and understand what is happening, it is also
divided up into smaller, more manageable procs with clear names to explain the
sequence of events. Finally, because we constantly check the parent proc, all
signals that are expected to be sent, are, so any other components or listeners
can take appropriate action and cancel the attack chain themselves, if requested.

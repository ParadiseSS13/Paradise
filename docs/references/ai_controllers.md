# AI Controllers

!!! note

    This documentation is based off the README and tutorial for AI controllers
    from TG. It has been edited and adapted for Paradise where necessary.

## Introduction

The AI controller system is an attempt at making it possible to create
modularized AI that stores its behavior in datums, while keeping state and
decision making in a controller.

Prior to AI controllers, mob AI was built into the `/mob/living/simple_animal`
subtype, which were generally used as non-player controlled mobs. But by coding
AI directly into the mob, there was so little ability to make unique or
complicated AI, and even when it was pulled off the code was hacky and
non-reusable. The AI controller system was made to rectify these problems, and
expand AI beyond just mobs.

## AI Controllers

AI _controllers_ are datums that can be added to any atom in the game. Similarly
to components, they might only support a given subtype (e.g. `/mob/living`), but
the idea is that theoretically, you could apply a specific AI controller to as
big a group of different types as possible and it would still work.

These datums handle both the normal movement of mobs, but also their decision
making, deciding which actions they will take based on the checks you put into
their `select_behaviors()` proc.

If behaviors are selected, and the AI is in range, it will try to perform them.
It runs all the behaviors it currently has in parallel, allowing for it to, for
example, screech at someone while trying to attack them. As long as it has
behaviors running, it will not try to generate new plans, making it not waste
CPU when it already has an active goal.

They also hold data for any of the actions they might need to use, such as
cooldowns, whether or not they're currently fighting, etc. This data is stored
in the _blackboard_.

### Blackboard

The blackboard is an associated list keyed with strings and with values of
whatever you want. These store information the mob has such as "am I attacking
someone?", "do I have a weapon?", or "what kind of food do I like?". By using an
associated list like this, no data needs to be stored on the actions themselves,
and you could make actions that work on multiple AI controllers if you so
pleased by making the key to use a variable.

## AI Behavior

AI _behaviors_ are the actions an AI can take. These can range from "do an
emote" to "attack this target until he is dead". They are singletons, and should
contain nothing but static data. Any dynamic data should be stored in the
blackboard, to allow different controllers to use the same behaviors.

## Making Your AI

Here we will show an example of some simple AI controller and behavior
implementations.

### Attaching an AI Controller

Any atom can have an AI controller. I'm choosing a basic mob for this guide,
because basic mobs stand as a nice "blank canvas" for AI on mobs. Simple animals
come with AI built into the mob; basic mobs don't, which is great for us adding
AI on top of it.

Anyways, we just define the type of AI this mob has on the `ai_controller` var.
It starts as a type, but is turned into an instance once the mob is
instantiated.

```dm
/mob/living/basic/cow
	name = "cow"
	desc = "Known for their milk, just don't tip them over."
	// a lot more variables defining for us what a cow is

	ai_controller = /datum/ai_controller/basic/cow
```

### Controllers Themselves

First, let's look at the blackboard.

```dm
/datum/ai_controller/basic/cow
	blackboard = list(
		BB_TARGETING_STRATEGY = new /datum/targeting_strategy/basic/allow_items(),
		BB_BASIC_MOB_TIP_REACTING = FALSE,
		BB_BASIC_MOB_TIPPER = null,
	)
```

Think of the blackboard as the unique format for variables. They are set
initially, or by behaviors, **but never in subtrees.** Because we check
`blackboard[BB_SOME_KEY]` instead of a variable, we can wipe out variables and
slap new ones onto the AI as it runs. For example, this cow uses
`BB_BASIC_MOB_TIP_REACTING` and `BB_BASIC_MOB_TIPPER` because cows can get
tipped, and the AI needs to know that in the subtrees when it plans behavior.
And in fact, those two keys aren't required to be defined initially, it's just
for clarity that they are.

Speaking of subtrees, let's look at that now.

```dm
/datum/ai_controller/basic/cow
	planning_subtrees = list(
		// Goes first...
		/datum/ai_planning_subtree/tip_reaction,

		// Goes second...
		/datum/ai_planning_subtree/find_and_eat_food,

		// Goes last. But at any point, a previous subtree can end the chain.
		// If a cow is tipped over, it shouldn't make random noises
		// or try finding food!
		/datum/ai_planning_subtree/random_speech/cow,
	)
	// By the end, for however many subtrees ran,
	// each one that did may have planned behavior for the AI to act on.
```

AIs work by planning specific behaviors, and subtrees are datums that bundle the
planning of behavior together. They run from top to bottom, and they can cancel
future subtrees. As an example, cows have their very first consideration be
tip_reaction, a subtree that prevents further subtrees like eating food and
random speech, as well as planning out how the cow reacts (looking sad at the
person who tipped it).

```dm
/datum/ai_controller/basic/cow
	ai_traits = null
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = null
```

Finally, we have some more minor things.

- `ai_traits` are flags for the AI, things like `AI_FLAG_STOP_MOVING_WHEN_PULLED`,
  slightly modifying how the AI acts under some situations.
- `ai_movement` is how the mob moves to its movement target. This can range from
  simple behaviors like `ai_movement/dumb` that always moves in the direction of
  the target and hopes there's nothing in the way, all the way to
  `ai_movement/jps`, that plans and occasionally recalcuates more complicated
  paths, at the cost of more lag.
- `idle_behavior` is just some simpler behavior to perform when nothing has been
  planned at all, like `idle_behavior/idle_random_walk` making a mob wander
  passively.

### Subtrees and Behaviors

Okay, so we have blackboard variables, which are considered by subtrees to plan
behaviors. Let's actually look at a subtree planning behaviors, and behaviors
themselves.

```dm
/// This subtree checks if the mob has a target.
/// If it doesn't, it plans looking for food.
/// If it does, it tries to eat the food via attacking it.
/datum/ai_planning_subtree/find_and_eat_food/select_behaviors(
		datum/ai_controller/controller, seconds_per_tick)
	// Get things out of blackboard
	var/atom/target = locateUID(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET])
	var/list/wanted = controller.blackboard[BB_BASIC_FOODS]

	// We see if we have a target
	// (remember, anything can be in that blackboard, it's not a hard reference).
	if(!target || QDELETED(target))
		// We need to find some food
		controller.queue_behavior(
			/datum/ai_behavior/find_and_set/in_list,
			BB_BASIC_MOB_CURRENT_TARGET,
			wanted
		)
		// This allows further subtrees to plan, since we're doing
		// a non-invasive behavior like checking the vicinity for food.
		return

	// Now we know we have a target but should let a hostile
	// subtree plan attacking humans. Let's check if it's actually food.
	if(target in wanted)
		controller.queue_behavior(
			/datum/ai_behavior/basic_melee_attack,
			BB_BASIC_MOB_CURRENT_TARGET,
			BB_TARGETING_STRATEGY,
			BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION
		)
		// This prevents further subtrees from planning
		// since we want to focus on eating the food.
		return SUBTREE_RETURN_FINISH_PLANNING
```

And one of those behaviors, `basic_melee_attack`. As I have been doing so far,
I've dumped in a bunch of comments explaining how this one behavior gets mobs to
chase a target and slap it if in range.

```dm
/// This behavior makes an AI get close to their movement target,
/// and attack every time perform() is called.
/datum/ai_behavior/basic_melee_attack
	action_cooldown = 0.6 SECONDS
	// Flag tells the AI it needs to have a movement target to work,
	// and since it doesn't have "AI_BEHAVIOR_MOVE_AND_PERFORM", it
	// won't call perform() every 0.6 seconds until it is in melee range. Smart!
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/basic_melee_attack/setup(
		datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key)
	. = ..()
	// All this is doing in setup is setting the movement target.
	// Setup is called once when the behavior is first planned,
	// and returning FALSE can cancel the behavior if something isn't right.

	// Hiding location is priority.
	var/target_key = controller.blackboard[hiding_location_key] || controller.blackboard[target_key]
	var/atom/target = locateUID(target_key)
	if(!target)
		return FALSE
	// Now the AI_BEHAVIOR_REQUIRE_MOVEMENT flag will be happy;
	// we have a target to always be moving towards.
	controller.current_movement_target = target

/// perform() will run every "action_cooldown" deciseconds as long as the
/// conditions are good for it to do so (we set "AI_BEHAVIOR_REQUIRE_MOVEMENT",
/// so it won't perform until in range).
/datum/ai_behavior/basic_melee_attack/perform(
		seconds_per_tick, datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key)
	. = ..()
	var/mob/living/basic/basic_mob = controller.pawn
	// Targeting strategy will kill the action if not real anymore
	var/atom/target = locateUID(controller.blackboard[target_key])
	var/datum/targeting_strategy/targeting_strategy = controller.blackboard[targeting_strategy_key]

	if(!targeting_strategy.can_attack(basic_mob, target))
		// We have a target that is no longer valid to attack.
		// Remember that returning doesn't end the behavior,
		// JUST this single performance. So we call "finish_action"
		// with whether it succeeded in doing what it wanted to do
		// (it didn't, so FALSE) and the blackboard keys passed
		// into this behavior.
		finish_action(controller, FALSE, target_key)
		return // don't forget to end the performance too

	// If this is valid, they're hidden in something!
	var/hiding_target = targeting_strategy.find_hidden_mobs(basic_mob, target)

	controller.set_blackboard_key(hiding_location_key, hiding_target)

	// And finally, we're in range, we have a valid target, we can attack.
	// When they fall into crit, they will no longer be a valid target,
	// so the melee behavior will end.
	if(hiding_target)
		basic_mob.melee_attack(hiding_target)
	else
		basic_mob.melee_attack(target)

/// And so the action has ended. We can now clean up the AI's blackboard
/// based on the success of the action, and the keys passed in.
/datum/ai_behavior/basic_melee_attack/finish_action(
		datum/ai_controller/controller, succeeded, target_key, targeting_strategy_key, hiding_location_key)
	. = ..()
	// If the behavior failed, the target is no longer valid, so we should
	// lose aggro. We remove the target_key (which could be anything; it's
	// whatever key was passed into the behavior by the subtree) from the blackboard.
	if(!succeeded)
		controller.clear_blackboard_key(target_key)
```

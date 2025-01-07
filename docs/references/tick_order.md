# BYOND Tick Order

This document roughly describes the order in which BYOND performs operations in a given tick.

The BYOND tick proceeds as follows:

1. Procs sleeping via `walk()` are resumed (I don't know why these are first).

2. Normal sleeping procs are resumed, in the order they went to sleep in the
   first place. This is where the MC wakes up and processes subsystems. A
   consequence of this is that the MC almost never resumes before other sleeping
   procs, because it only goes to sleep for 1 tick 99% of the time, and 99% of
   procs either go to sleep for less time than the MC (which guarantees that
   they entered the sleep queue earlier when its time to wake up) and/or were
   called synchronously from the MC's execution, almost all of the time the MC
   is the last sleeping proc to resume in any given tick. This is good because
   it means the MC can account for the cost of previous resuming procs in the
   tick, and minimizes overtime.

3. Control is passed to BYOND after all of our code's procs stop execution for this tick.

4. A few small things happen in BYOND internals.

5. SendMaps is called for this tick, which processes the game state for all
   clients connected to the game and handles sending them changes in appearances
   within their view range. This is expensive and takes up a significant portion
   of our tick, about 0.45% per connected player as of 3/20/2022. This means
   that with 50 players, 22.5% of our tick is being used up by just SendMaps,
   after all of our code has stopped executing. That's only the average across
   all rounds, for most high-pop rounds it can look like 0.6% of the tick per
   player, which is 30% for 50 players.

6. After SendMaps ends, client verbs sent to the server are executed, and it's
   the last major step before the next tick begins. During the course of the
   tick, a client can send a command to the server saying that they have
   executed any verb. The actual code defined for that /verb/name() proc isn't
   executed until this point, and the way the MC is designed makes this
   especially likely to make verbs "overrun" the bounds of the tick they
   executed in, stopping the other tick from starting and thus delaying the MC
   firing in that tick.

The master controller can derive how much of the tick was used in: procs
executing before it woke up (because of world.tick_usage), and SendMaps (because
of world.map_cpu, since this is a running average you cant derive the tick spent
on maptick on any particular tick). It cannot derive how much of the tick was
used for sleeping procs resuming after the MC ran, or for verbs executing after
SendMaps.

It is for these reasons why you should heavily limit processing done in verbs.
While procs resuming after the MC are rare, verbs are not, and are much more
likely to cause overtime since they're literally at the end of the tick. If you
make a verb, try to offload any expensive work to the beginning of the next tick
via a verb management subsystem.

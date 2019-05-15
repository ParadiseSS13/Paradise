# New Object Damage System
If you're looking through this folder its likely you want to create a new object, This readme will guide you through making that object compatible with the new object damaging system.

### Variables
1. obj_integrity: This is the "health" of the object or how strong it is, when it hits zero the object is deleted. if you want the object to do special behaviour when deleted you have to modify the deconstruct proc in obj_defense.dm

2. max_integrity: This is the maximum "health" of the object it can be used for calculations and also to check how damaged an item is through variables.

3. integrity_failure: When your object breaks but is not destroyed. used for broken sprites or different behaviour on damaged objects.

4. resistance_flags: This is kind of self-explanatory, this sets the resistance of the object, if an object is not resistant to anything it is treated like normal. Keep in mind objects with no resistance won't catch on fire but objects that are fireproof do not take fire damage at all. If you want an object to not catch on fire but still take damage from it you'll want to use NONE instead of FIRE_PROOF. The same goes for UNACIDABLE and ACID_PROOF, if an object is UNACIDABLE acid can not be spilled on it at all, ACID_PROOF objects simply do not take damage from acid. List of resistance flags: INDESTRUCTIBLE, LAVA_PROOF,FIRE_PROOF,ON_FIRE,UNACIDABLE,ACID_PROOF,FLAMMABLE

### Procs
Their native behaviour can be found in obj_defense.dm but should be redefined in your object directory

1. take_damage: called whenever an object takes damage. Modify this in your object to make it react to damage differently.

2. run_obj_armor: this check is run before the object takes damage and be used to reduce or increase damage taken.

3. play_attack_sound: self-explanatory, modify it to change how your object sounds when hit.

4. hitby: called when something is thrown at your object, can be used to make something that is instantly destroyed by a certain object thrown at it like mount doom and the ring.

5. ex_act: called when the object is caught in an explosion.

6. bullet_act: called when the object is hit by a bullet.

7. attack_hulk: called when object is hit by someone with the HULK mutation.

8. blob_act: called when object is hit by a blob.

9. attack_generic: called when object is punched.

10. attack_alien: called when object is attacked by a xenomorph.

11. attack_animal: called when an animal attacks an object.

12. attack_slime: called when an object is attacked by a xenobiology slime.

13. mech_melee_attack: called when a mech melee attacks an object.

14. singularity_act: called when singularity comes in contact with object.

15. acid_act: called when acid is on the object.

16. acid_processing: used by the acid subsystem, not suggested to modify.

17. acid_melt: called when the object is destroyed by acid.

18. fire_act: called when the object is in fire.

19. burn: called when the object has been destroyed by fire.

20. extinguish: called when an burning object has been extinguished.

21. tesla_act: called when object is hit by tesla.

22. deconstruct: called when the object is destroyed. modify to change what you want your object to drop or do when destroyed.

23: obj_break: called when the obj_integrity is less than the integrity_failure.

24. obj_destruction: called when the obj_integrity reaches zero.
 
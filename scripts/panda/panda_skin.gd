class_name PandaSkin
extends Resource

## One picture per pose, keeping the panda's look separate from its
## behaviour so another skin (e.g. a blue panda) can be added later without
## touching Panda. RUN_1 is the base every other pose falls back to when its
## own picture is missing, so texture_for always resolves to something
## drawable once RUN_1 is set.

enum Pose { RUN_1, RUN_2, JUMP_TAKEOFF, JUMP_AIR, HURT }

@export var run_1: Texture2D
@export var run_2: Texture2D
@export var jump_takeoff: Texture2D
@export var jump_air: Texture2D
@export var hurt: Texture2D


## Returns the picture for `pose`, falling back when it is missing:
## RUN_2 -> RUN_1, JUMP_TAKEOFF -> RUN_1, JUMP_AIR -> JUMP_TAKEOFF -> RUN_1,
## HURT -> RUN_1.
func texture_for(pose: Pose) -> Texture2D:
	match pose:
		Pose.RUN_1:
			return run_1
		Pose.RUN_2:
			return run_2 if run_2 else run_1
		Pose.JUMP_TAKEOFF:
			return jump_takeoff if jump_takeoff else run_1
		Pose.JUMP_AIR:
			if jump_air:
				return jump_air
			return jump_takeoff if jump_takeoff else run_1
		Pose.HURT:
			return hurt if hurt else run_1
		_:
			return run_1

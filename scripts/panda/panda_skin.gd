class_name PandaSkin
extends Resource

## One picture per pose, keeping the panda's look separate from its
## behaviour so another skin (e.g. a blue panda) can be added later without
## touching Panda. Only `standing` is drawn so far, so texture_for falls
## back through simpler poses until it finds a set texture.

enum Pose { STANDING, RUN_1, RUN_2, JUMP_TAKEOFF, JUMP_AIR, HURT }

@export var standing: Texture2D
@export var run_1: Texture2D
@export var run_2: Texture2D
@export var jump_takeoff: Texture2D
@export var jump_air: Texture2D
@export var hurt: Texture2D


## Returns the picture for `pose`, falling back when it is missing:
## RUN_2 -> RUN_1 -> STANDING, JUMP_AIR -> JUMP_TAKEOFF -> STANDING,
## everything else -> STANDING.
func texture_for(pose: Pose) -> Texture2D:
	match pose:
		Pose.RUN_1:
			return run_1 if run_1 else standing
		Pose.RUN_2:
			if run_2:
				return run_2
			return run_1 if run_1 else standing
		Pose.JUMP_TAKEOFF:
			return jump_takeoff if jump_takeoff else standing
		Pose.JUMP_AIR:
			if jump_air:
				return jump_air
			return jump_takeoff if jump_takeoff else standing
		Pose.HURT:
			return hurt if hurt else standing
		_:
			return standing

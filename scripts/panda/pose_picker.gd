class_name PosePicker
extends RefCounted

## Chooses which PandaSkin.Pose to show for the current physics state. Pure
## and static (no scene dependencies) so the artist's drawings can be wired
## in against a fast, deterministic test instead of eyeballing the game.

## Picks the pose for a panda that is on_floor or not, moving at velocity_y
## (negative is rising), hurt or not, and has been running for run_time
## seconds. frame_time is how long each run frame is shown (Tuning's
## run_frame_time), passed in rather than read from a resource so this stays
## pure.
static func pick(on_floor: bool, velocity_y: float, hurt: bool, run_time: float, frame_time: float) -> PandaSkin.Pose:
	if hurt:
		return PandaSkin.Pose.HURT

	if not on_floor:
		return PandaSkin.Pose.JUMP_TAKEOFF if velocity_y < 0.0 else PandaSkin.Pose.JUMP_AIR

	var frame := int(run_time / frame_time)
	return PandaSkin.Pose.RUN_1 if frame % 2 == 0 else PandaSkin.Pose.RUN_2

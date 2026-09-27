extends GutTest

# Issue #15: PosePicker chooses which PandaSkin.Pose to show, from floor/air
# state, vertical velocity, whether the panda was just hurt, and how long
# it's been running (for the run-cycle alternation). It's pure/static so it's
# testable without a scene tree.

const FRAME_TIME := 0.15


func test_pick_on_floor_at_start_of_run_time_is_run_1():
	assert_eq(PosePicker.pick(true, 0.0, false, 0.0, FRAME_TIME), PandaSkin.Pose.RUN_1, "run_time 0 is RUN_1")


func test_pick_alternates_run_frames_every_frame_time():
	assert_eq(PosePicker.pick(true, 0.0, false, 0.2, FRAME_TIME), PandaSkin.Pose.RUN_2, "0.2s is into the second frame")
	assert_eq(PosePicker.pick(true, 0.0, false, 0.31, FRAME_TIME), PandaSkin.Pose.RUN_1, "0.31s is back to the first frame")


func test_pick_in_air_depends_on_vertical_velocity():
	assert_eq(PosePicker.pick(false, -300.0, false, 0.0, FRAME_TIME), PandaSkin.Pose.JUMP_TAKEOFF, "rising is takeoff")
	assert_eq(PosePicker.pick(false, 200.0, false, 0.0, FRAME_TIME), PandaSkin.Pose.JUMP_AIR, "falling is air")


func test_pick_hurt_overrides_everything():
	assert_eq(PosePicker.pick(false, -300.0, true, 0.0, FRAME_TIME), PandaSkin.Pose.HURT, "hurt overrides airborne rising")
	assert_eq(PosePicker.pick(true, 0.0, true, 0.2, FRAME_TIME), PandaSkin.Pose.HURT, "hurt overrides running")


func test_pick_at_the_apex_counts_as_falling():
	assert_eq(PosePicker.pick(false, 0.0, false, 0.0, FRAME_TIME), PandaSkin.Pose.JUMP_AIR, "velocity_y == 0 counts as falling")

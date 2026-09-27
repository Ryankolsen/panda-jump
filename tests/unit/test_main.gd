extends GutTest

# Issue #7: the first barrel must enter off-screen just like every later
# one, instead of at the raw first gap distance (which can land on screen,
# even on top of the panda at x=96). Main.off_screen_spawn_x is the same
# threshold `_spawn_if_due`'s lookahead uses, kept static and pure so it's
# testable without a scene tree.

func test_off_screen_spawn_x_is_beyond_the_viewport():
	var spawn_x := Main.off_screen_spawn_x(480.0)
	assert_gt(spawn_x, 480.0, "the first spawn point sits past the right edge of a 480px viewport")


func test_off_screen_spawn_x_matches_the_lookahead_threshold():
	assert_eq(Main.off_screen_spawn_x(480.0), 480.0 + Main.SPAWN_LOOKAHEAD, "matches the same viewport_width + lookahead every later barrel spawns at")

extends GutTest

# Issue #12: jump_apex() gives the highest point a jump reaches, so bamboo
# placed at bamboo_float_height can be checked against it for reachability.

func test_jump_apex_matches_default_tuning():
	var tuning := Tuning.new()
	# jump_velocity^2 / (2 * gravity) with defaults 520.0 and 1400.0.
	assert_almost_eq(tuning.jump_apex(), 520.0 * 520.0 / (2.0 * 1400.0), 0.01, "apex follows the physics formula")


func test_bamboo_float_height_leaves_margin_below_apex():
	var tuning := Tuning.new()
	assert_true(tuning.bamboo_float_height <= tuning.jump_apex() - 12.0, "floating bamboo stays reachable by a normal jump")


func test_jump_apex_follows_tuning_not_a_constant():
	var tuning := Tuning.new()
	tuning.jump_velocity = 400.0
	assert_almost_eq(tuning.jump_apex(), 400.0 * 400.0 / (2.0 * 1400.0), 0.01, "apex recomputes from the tuning's own jump_velocity")


# Issue #24: leaderboard_size caps how many entries Leaderboard keeps.

func test_leaderboard_size_defaults_to_five():
	var tuning := Tuning.new()
	assert_eq(tuning.leaderboard_size, 5, "default leaderboard_size is 5")

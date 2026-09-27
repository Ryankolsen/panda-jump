extends GutTest

# Issue #8: barrel hits cost hearts, the panda blinks during its invincible
# period, and hearts are shown on screen. Both Panda.blink_visible and
# Hud.heart_states are pure/static so they're testable without a scene tree.

func test_heart_states_all_full_at_start():
	assert_eq(Hud.heart_states(3, 3), [true, true, true], "3 of 3 hearts are all full")


func test_heart_states_matches_partial_and_zero_hearts():
	assert_eq(Hud.heart_states(1, 3), [true, false, false], "1 of 3 hearts leaves two empty")
	assert_eq(Hud.heart_states(0, 3), [false, false, false], "0 of 3 hearts are all empty")


func test_blink_visible_is_always_true_when_not_invincible():
	assert_true(Panda.blink_visible(0.0, 0.1), "time_left <= 0 means always visible")


func test_blink_visible_toggles_every_interval():
	var a := Panda.blink_visible(0.95, 0.1)
	var b := Panda.blink_visible(0.85, 0.1)
	assert_ne(a, b, "visibility toggles as time_left crosses an interval boundary")


func test_heart_states_never_exceeds_max_hearts():
	var states: Array[bool] = Hud.heart_states(5, 3)
	assert_eq(states.size(), 3, "never more heart states than max_hearts")
	assert_eq(states, [true, true, true], "clamped hearts still shows all full")

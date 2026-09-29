extends GutTest

# Pause button: PauseState tracks whether the player has paused the run and
# whether pausing is still allowed. Pure logic — PauseMenu applies it to the
# scene tree. Locked once the run ends, since Game Over owns the freeze then.

func test_new_state_is_not_paused():
	var state := PauseState.new()
	assert_false(state.paused, "a run starts unpaused")


func test_toggle_pauses():
	var state := PauseState.new()
	state.toggle()
	assert_true(state.paused, "one toggle pauses")


func test_second_toggle_resumes():
	var state := PauseState.new()
	state.toggle()
	state.toggle()
	assert_false(state.paused, "a second toggle resumes")


func test_toggle_does_nothing_once_locked():
	var state := PauseState.new()
	state.lock()
	state.toggle()
	assert_false(state.paused, "no pausing after Game Over")


func test_lock_clears_a_pause():
	var state := PauseState.new()
	state.toggle()
	state.lock()
	assert_false(state.paused, "locking drops the player's pause so it can't fight Game Over's freeze")
	assert_true(state.is_locked(), "lock() is reported")

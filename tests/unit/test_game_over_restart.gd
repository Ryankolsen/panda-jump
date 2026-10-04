extends GutTest

# Issue #33: the Game Over card's "Play again" button. It and a keyboard
# jump/ui_accept press are the only ways to restart now — a mouse/touch tap
# anywhere on the card (previously routed through the `jump` action, which
# also maps to a mouse button) no longer does, so a death-tap can't skip
# straight past the card. See GameOver._restart() and _unhandled_input().

const DELAY := 0.2


func _space_key(pressed: bool) -> InputEventKey:
	var event := InputEventKey.new()
	event.keycode = KEY_SPACE
	event.physical_keycode = KEY_SPACE
	event.pressed = pressed
	return event


func _left_click(pressed: bool) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	return event


func test_play_again_button_exists_and_is_shaped_right():
	var go: GameOver = add_child_autofree(preload("res://scenes/ui/game_over.tscn").instantiate())
	var button: Button = go.get_node("Margin/VBox/Columns/Left/PlayAgainButton")

	assert_eq(button.text, "Play again", "the button reads Play again")
	assert_eq(button.focus_mode, Control.FOCUS_NONE, "focus_mode is NONE so Space can't press it directly")


func test_play_again_button_is_visible_when_ranked_and_when_off_board():
	var go: GameOver = add_child_autofree(preload("res://scenes/ui/game_over.tscn").instantiate())
	var button: Button = go.get_node("Margin/VBox/Columns/Left/PlayAgainButton")
	var board := Leaderboard.new(Tuning.new())
	board.submit(1240, "🐼")

	go.show_game_over(1240, board, 1, DELAY)
	assert_true(button.visible, "visible when the run made the board")

	go.show_game_over(10, board, -1, DELAY)
	assert_true(button.visible, "visible when the run missed the board")


func test_play_again_button_disabled_until_the_input_delay_elapses():
	var go: GameOver = add_child_autofree(preload("res://scenes/ui/game_over.tscn").instantiate())
	var button: Button = go.get_node("Margin/VBox/Columns/Left/PlayAgainButton")
	var board := Leaderboard.new(Tuning.new())
	board.submit(1240, "🐼")

	go.show_game_over(1240, board, 1, DELAY)
	assert_true(button.disabled, "disabled right after show_game_over")

	go._on_input_delay_timeout()
	assert_false(button.disabled, "enabled once the input delay elapses")


func test_pressing_play_again_restarts():
	var go: GameOver = add_child_autofree(preload("res://scenes/ui/game_over.tscn").instantiate())
	go.reload_on_restart = false
	var button: Button = go.get_node("Margin/VBox/Columns/Left/PlayAgainButton")
	var board := Leaderboard.new(Tuning.new())
	board.submit(1240, "🐼")
	go.show_game_over(1240, board, 1, DELAY)
	go._on_input_delay_timeout()
	watch_signals(go)

	button.pressed.emit()

	assert_signal_emitted(go, "restart_requested", "pressing Play again restarts")


func test_mouse_click_after_the_delay_does_not_restart():
	var go: GameOver = add_child_autofree(preload("res://scenes/ui/game_over.tscn").instantiate())
	go.reload_on_restart = false
	var board := Leaderboard.new(Tuning.new())
	board.submit(1240, "🐼")
	go.show_game_over(1240, board, 1, DELAY)
	go._on_input_delay_timeout()
	watch_signals(go)

	go._unhandled_input(_left_click(true))

	assert_signal_not_emitted(go, "restart_requested", "a mouse click no longer restarts")


func test_space_key_after_the_delay_restarts():
	var go: GameOver = add_child_autofree(preload("res://scenes/ui/game_over.tscn").instantiate())
	go.reload_on_restart = false
	var board := Leaderboard.new(Tuning.new())
	board.submit(1240, "🐼")
	go.show_game_over(1240, board, 1, DELAY)
	go._on_input_delay_timeout()
	watch_signals(go)

	go._unhandled_input(_space_key(true))

	assert_signal_emitted(go, "restart_requested", "a Space key press restarts")


func test_space_key_before_the_delay_does_not_restart():
	var go: GameOver = add_child_autofree(preload("res://scenes/ui/game_over.tscn").instantiate())
	go.reload_on_restart = false
	var board := Leaderboard.new(Tuning.new())
	board.submit(1240, "🐼")
	go.show_game_over(1240, board, 1, DELAY)
	watch_signals(go)

	go._unhandled_input(_space_key(true))

	assert_signal_not_emitted(go, "restart_requested", "a key press before the delay doesn't restart")


func test_play_again_button_is_horizontally_centred_in_the_left_column():
	var go: GameOver = add_child_autofree(preload("res://scenes/ui/game_over.tscn").instantiate())
	var board := Leaderboard.new(Tuning.new())
	board.submit(1240, "🐼")
	go.show_game_over(1240, board, 1, DELAY)
	await wait_process_frames(2)

	var left_column: VBoxContainer = go.get_node("Margin/VBox/Columns/Left")
	var button: Button = go.get_node("Margin/VBox/Columns/Left/PlayAgainButton")

	var button_centre: float = button.global_position.x + button.size.x / 2.0
	var column_centre: float = left_column.global_position.x + left_column.size.x / 2.0
	assert_almost_eq(button_centre, column_centre, 1.0, "the Play again button is horizontally centred in the left column")

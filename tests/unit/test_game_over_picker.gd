extends GutTest

# Issue #31: the Game Over card's emoji picker. Visible only when the run
# made the board (rank >= 1), lets the player re-tag their board entry by
# tapping one of the 8 Leaderboard.PICKER_EMOJI buttons.

func test_pressing_an_emoji_button_sets_the_entry_and_emits_signal():
	var go: GameOver = add_child_autofree(preload("res://scenes/ui/game_over.tscn").instantiate())
	var board := Leaderboard.new(Tuning.new())
	board.submit(1240, "🐼")
	go.show_game_over(1240, board, 1, 0.5)
	watch_signals(go)

	var buttons: Array[Button] = go.picker_buttons()
	var fox_button: Button = buttons[Leaderboard.PICKER_EMOJI.find("🦊")]
	fox_button.pressed.emit()

	assert_eq(board.entries()[0]["emoji"], "🦊", "pressing the fox button re-tags the entry")
	assert_signal_emitted_with_parameters(go, "emoji_picked", ["🦊"])


func test_picker_content_details():
	var go: GameOver = add_child_autofree(preload("res://scenes/ui/game_over.tscn").instantiate())
	var board := Leaderboard.new(Tuning.new())
	board.submit(1240, "🐼")
	board.submit(1100, "🐼")
	go.show_game_over(1100, board, 2, 0.5)

	assert_true(go.get_node("Margin/VBox/Columns/Left/PickLabel").visible, "the picker label shows when ranked")
	assert_true(go.get_node("Margin/VBox/Columns/Left/Picker").visible, "the picker grid shows when ranked")

	var buttons: Array[Button] = go.picker_buttons()
	assert_eq(buttons.size(), 8, "there are 8 picker buttons")
	var texts: Array[String] = []
	for button in buttons:
		texts.append(button.text)
	assert_eq(texts, Leaderboard.PICKER_EMOJI, "button texts match PICKER_EMOJI in order")

	var grid: GridContainer = go.get_node("Margin/VBox/Columns/Left/Picker")
	assert_eq(grid.columns, 4, "the grid has 4 columns")

	for button in buttons:
		assert_eq(button.focus_mode, Control.FOCUS_NONE, "each button has FOCUS_NONE so Space can't press it")
		assert_true(button.custom_minimum_size.x >= 32, "each button is at least 32px wide")
		assert_true(button.custom_minimum_size.y >= 32, "each button is at least 32px tall")


func test_pressing_fox_updates_the_highlighted_row_label():
	var go: GameOver = add_child_autofree(preload("res://scenes/ui/game_over.tscn").instantiate())
	var board := Leaderboard.new(Tuning.new())
	board.submit(1240, "🐼")
	go.show_game_over(1240, board, 1, 0.5)

	var buttons: Array[Button] = go.picker_buttons()
	var fox_button: Button = buttons[Leaderboard.PICKER_EMOJI.find("🦊")]
	fox_button.pressed.emit()

	var board_grid: GridContainer = go.get_node("Margin/VBox/Columns/Right/Board")
	# Row 1 is columns [rank, emoji, score]; the emoji label is the 2nd child.
	var emoji_label: Label = board_grid.get_child(1)
	assert_eq(emoji_label.text, "🦊", "the highlighted row's emoji label updates immediately")


func test_picker_grid_is_horizontally_centred_in_the_left_column():
	var go: GameOver = add_child_autofree(preload("res://scenes/ui/game_over.tscn").instantiate())
	var board := Leaderboard.new(Tuning.new())
	board.submit(1240, "🐼")
	go.show_game_over(1240, board, 1, 0.5)
	await wait_process_frames(2)

	var left_column: VBoxContainer = go.get_node("Margin/VBox/Columns/Left")
	var buttons: Array[Button] = go.picker_buttons()

	# The grid's own rect fills the column by default (Containers stretch to
	# fit their parent), so measuring the grid node's bounds against the
	# column's bounds can't tell a centred button block from a left-aligned
	# one. The buttons' own bounding box is what actually has to be centred.
	var left_edge: float = buttons[0].global_position.x
	var right_edge: float = left_edge
	for button in buttons:
		left_edge = min(left_edge, button.global_position.x)
		right_edge = max(right_edge, button.global_position.x + button.size.x)
	var buttons_centre: float = (left_edge + right_edge) / 2.0
	var column_centre: float = left_column.global_position.x + left_column.size.x / 2.0
	assert_almost_eq(buttons_centre, column_centre, 1.0, "the picker buttons are horizontally centred in the left column")


func test_picker_is_hidden_when_the_run_missed_the_board():
	var go: GameOver = add_child_autofree(preload("res://scenes/ui/game_over.tscn").instantiate())
	var board := Leaderboard.new(Tuning.new())
	go.show_game_over(10, board, -1, 0.5)

	assert_false(go.get_node("Margin/VBox/Columns/Left/PickLabel").visible, "the picker label hides when the run missed the board")
	assert_false(go.get_node("Margin/VBox/Columns/Left/Picker").visible, "the picker grid hides when the run missed the board")


func test_pressing_fox_then_frog_leaves_the_entry_as_frog_and_fires_twice():
	var go: GameOver = add_child_autofree(preload("res://scenes/ui/game_over.tscn").instantiate())
	var board := Leaderboard.new(Tuning.new())
	board.submit(1240, "🐼")
	go.show_game_over(1240, board, 1, 0.5)
	watch_signals(go)

	var buttons: Array[Button] = go.picker_buttons()
	var fox_button: Button = buttons[Leaderboard.PICKER_EMOJI.find("🦊")]
	var frog_button: Button = buttons[Leaderboard.PICKER_EMOJI.find("🐸")]
	fox_button.pressed.emit()
	frog_button.pressed.emit()

	assert_eq(board.entries()[0]["emoji"], "🐸", "the later pick wins")
	assert_signal_emit_count(go, "emoji_picked", 2, "the signal fired once per press")

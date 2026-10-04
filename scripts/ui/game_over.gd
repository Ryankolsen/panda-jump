class_name GameOver
extends CanvasLayer

## Shown once Health.died fires (see #6): a semi-transparent panel over the
## whole screen, freezing behind it because Main pauses the tree at the
## same moment. This layer (and its input-delay timer) must keep running
## while paused, so process_mode is set to ALWAYS in the scene — Panda, the
## HUD and everything else stay on the default PAUSABLE mode and simply
## stop, which is what makes the freeze work.
##
## Laid out as two columns between a title and a restart prompt (#26): the
## left column is this run's score and (when it ranks #1) a "New best!"
## badge; the right column is the in-memory Leaderboard, always rendered
## as leaderboard.size() rows, blank slots and all. The board row matching
## this run's returned rank, and the badge, are picked out in gold; nothing
## here persists it to disk — a reload (restarting, see #10) drops it,
## which is expected until #27.
##
## No reset method: restarting reloads the scene (#10), which builds a
## fresh Main, Health, Pace, Spawner and this screen hidden again.

const TITLE_TEXT := "Game Over"
const PROMPT_TEXT := "Tap to play again"
const HIGHLIGHT_COLOR := Color("FFD94A")
const NORMAL_COLOR := Color(1, 1, 1, 1)

@onready var _title_label: Label = $Margin/VBox/TitleLabel
@onready var _prompt_label: Label = $Margin/VBox/PromptLabel
@onready var _run_header_label: Label = $Margin/VBox/Columns/Left/RunHeader
@onready var _run_score_label: Label = $Margin/VBox/Columns/Left/RunScore
@onready var _run_badge_label: Label = $Margin/VBox/Columns/Left/RunBadge
@onready var _board_header_label: Label = $Margin/VBox/Columns/Right/BoardHeader
@onready var _board_grid: GridContainer = $Margin/VBox/Columns/Right/Board
@onready var _input_delay_timer: Timer = $InputDelayTimer

var _accepting_input: bool = false


func _ready() -> void:
	visible = false
	_input_delay_timer.one_shot = true
	_input_delay_timer.timeout.connect(_on_input_delay_timeout)


## This run's column copy, kept as a static pure function so it's testable
## without a scene tree: the column header, the final score (grouped via
## NumberFormat), and the "New best!" badge — shown only when `rank` is 1,
## blank otherwise (a rank of -1 means the run didn't make the board at
## all, which also reads as blank here; dedicated missed-board copy is a
## later slice, #28).
static func run_lines(score: int, rank: int) -> Array[String]:
	var badge := "New best!" if rank == 1 else ""
	return ["This run", NumberFormat.thousands(score), badge]


## The leaderboard column's rows, one `[rank, emoji, score]` array of
## Strings per slot, always exactly `size` rows regardless of how many
## `entries` there are. `entries` is in rank order (best first), as
## returned by Leaderboard.entries(); slots beyond the entries given show
## an em dash for both emoji and score. Static and pure so it's testable
## without a scene tree.
static func board_rows(entries: Array, size: int) -> Array:
	var rows: Array = []
	for i in range(size):
		var rank := i + 1
		if i < entries.size():
			var entry: Dictionary = entries[i]
			rows.append([str(rank), entry["emoji"], NumberFormat.thousands(entry["score"])])
		else:
			rows.append([str(rank), "—", "—"])
	return rows


## Shows the screen with this run's final `score`, the `leaderboard` it was
## just submitted to, and the 1-based `rank` Leaderboard.submit() returned
## (-1 if it didn't make the board). `jump` is ignored for the first
## `input_delay` seconds, so a tap already in progress when the last heart
## goes doesn't skip straight past the screen.
func show_game_over(score: int, leaderboard: Leaderboard, rank: int, input_delay: float) -> void:
	_title_label.text = TITLE_TEXT
	_prompt_label.text = PROMPT_TEXT

	var run_lines: Array[String] = GameOver.run_lines(score, rank)
	_run_header_label.text = run_lines[0]
	_run_score_label.text = run_lines[1]
	_run_badge_label.text = run_lines[2]
	_run_badge_label.add_theme_color_override("font_color", HIGHLIGHT_COLOR)

	_board_header_label.text = "Top Scores"
	_rebuild_board(leaderboard, rank)

	_accepting_input = false
	visible = true
	_input_delay_timer.start(input_delay)


## Replaces the board grid's rows with `leaderboard`'s current entries,
## padded to its configured size by GameOver.board_rows. The row at
## `highlighted_rank` (this run's, if it made the board) is picked out in
## gold; every other row stays white.
func _rebuild_board(leaderboard: Leaderboard, highlighted_rank: int) -> void:
	for child in _board_grid.get_children():
		child.queue_free()

	var rows: Array = GameOver.board_rows(leaderboard.entries(), leaderboard.size())
	for i in range(rows.size()):
		var row: Array = rows[i]
		var highlighted: bool = (i + 1) == highlighted_rank
		var color: Color = HIGHLIGHT_COLOR if highlighted else NORMAL_COLOR
		for column in range(3):
			var label := Label.new()
			label.text = row[column]
			label.add_theme_color_override("font_color", color)
			label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
			label.add_theme_constant_override("outline_size", 4)
			label.add_theme_font_size_override("font_size", 16)
			if column == 2:
				label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
				label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			_board_grid.add_child(label)


func _on_input_delay_timeout() -> void:
	_accepting_input = true


func _unhandled_input(event: InputEvent) -> void:
	if not visible or not _accepting_input:
		return
	if event.is_action_pressed("jump"):
		get_viewport().set_input_as_handled()
		_restart()


func _restart() -> void:
	_accepting_input = false
	visible = false
	get_tree().paused = false
	get_tree().reload_current_scene()

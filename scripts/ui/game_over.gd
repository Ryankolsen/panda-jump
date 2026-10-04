class_name GameOver
extends CanvasLayer

## Shown once Health.died fires (see #6): a semi-transparent panel over the
## whole screen, freezing behind it because Main pauses the tree at the
## same moment. This layer (and its input-delay timer) must keep running
## while paused, so process_mode is set to ALWAYS in the scene — Panda, the
## HUD and everything else stay on the default PAUSABLE mode and simply
## stop, which is what makes the freeze work.
##
## Laid out as two columns under a title: the left column is this run's
## score, either a "New best!" badge (rank #1) or, when the run missed the
## board entirely (rank -1), the best score on record and how many points
## it needed to make the board (#28), the emoji picker when ranked, and a
## "Play again" button at the bottom; the right column is the in-memory
## Leaderboard, always rendered as leaderboard.size() rows, blank slots and
## all. The board row matching this run's returned rank, and the badge,
## are picked out in gold; nothing here persists it to disk — a reload
## (restarting, see #10) drops it, which is expected until #27.
##
## No reset method: restarting reloads the scene (#10), which builds a
## fresh Main, Health, Pace, Spawner and this screen hidden again.

const TITLE_TEXT := "Game Over"
const HIGHLIGHT_COLOR := Color("FFD94A")
const NORMAL_COLOR := Color(1, 1, 1, 1)

const EMOJI_FONT_PATH := "res://assets/fonts/emoji_subset.ttf"
const PICKER_BUTTON_SIZE := Vector2(32, 32)

## Emitted every time a picker button is tapped, after the leaderboard
## entry has been re-tagged and the board re-rendered. Main listens so it
## can persist both the board and the last-picked emoji (#31).
signal emoji_picked(emoji: String)

## Emitted every time _restart() runs, before the scene tree is actually
## reloaded. Tests set reload_on_restart to false first so they can assert
## on this signal without reload_current_scene() tearing down the test
## run itself (see tests/unit/test_game_over_restart.gd) — the real game
## always leaves reload_on_restart at its default of true.
signal restart_requested

## See restart_requested's doc comment above.
var reload_on_restart: bool = true

@onready var _card_root: MarginContainer = $Margin
@onready var _title_label: Label = $Margin/VBox/TitleLabel
@onready var _run_header_label: Label = $Margin/VBox/Columns/Left/RunHeader
@onready var _run_score_label: Label = $Margin/VBox/Columns/Left/RunScore
@onready var _run_badge_label: Label = $Margin/VBox/Columns/Left/RunBadge
@onready var _pick_label: Label = $Margin/VBox/Columns/Left/PickLabel
@onready var _picker_grid: GridContainer = $Margin/VBox/Columns/Left/Picker
@onready var _run_best_label: Label = $Margin/VBox/Columns/Left/RunBest
@onready var _run_gap_label: Label = $Margin/VBox/Columns/Left/RunGap
@onready var _play_again_button: Button = $Margin/VBox/Columns/Left/PlayAgainButton
@onready var _board_header_label: Label = $Margin/VBox/Columns/Right/BoardHeader
@onready var _board_grid: GridContainer = $Margin/VBox/Columns/Right/Board
@onready var _input_delay_timer: Timer = $InputDelayTimer

var _accepting_input: bool = false
var _leaderboard: Leaderboard
var _picker_rank: int = -1


func _ready() -> void:
	visible = false
	_input_delay_timer.one_shot = true
	_input_delay_timer.timeout.connect(_on_input_delay_timeout)
	_play_again_button.pressed.connect(_restart)

	# #30: applied once to Margin, the ancestor Control of both the board's
	# emoji column and the picker buttons, rather than per label — see
	# card_font()'s doc comment.
	var card_theme := Theme.new()
	card_theme.default_font = card_font()
	_card_root.theme = card_theme

	# Built once from Leaderboard.PICKER_EMOJI, the single source of truth
	# for the picker's emoji set — see that constant's doc comment.
	# focus_mode is NONE like pause_menu.gd's button, so Space (also bound
	# to jump) can never press one.
	for emoji in Leaderboard.PICKER_EMOJI:
		var button := Button.new()
		button.text = emoji
		button.custom_minimum_size = PICKER_BUTTON_SIZE
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(_on_picker_button_pressed.bind(emoji))
		_picker_grid.add_child(button)


## The Game Over card's font: the engine's own default font, falling back
## to the bundled emoji subset font (res://assets/fonts/emoji_subset.ttf)
## for glyphs the default font can't draw — notably Leaderboard.PICKER_EMOJI,
## shown in the board's emoji column and the picker buttons (#31). Applied
## once in _ready() as a Theme on the card's root Control, not per label,
## so both columns pick it up for free. Existing per-label overrides
## (size, colour, outline) still apply on top of this.
##
## A static pure function so it's testable without a scene tree.
static func card_font() -> Font:
	var font := FontVariation.new()
	font.base_font = ThemeDB.fallback_font
	font.fallbacks = [load(EMOJI_FONT_PATH)]
	return font


## This run's column copy, kept as a static pure function so it's testable
## without a scene tree: the column header, the final score (grouped via
## NumberFormat), and the "New best!" badge — shown only when `rank` is 1,
## blank otherwise (a rank of -1 means the run didn't make the board at
## all, which also reads as blank here; a run that missed the board
## instead gets missed_lines() below, shown separately).
static func run_lines(score: int, rank: int) -> Array[String]:
	var badge := "New best!" if rank == 1 else ""
	return ["This run", NumberFormat.thousands(score), badge]


## Copy for a run that missed the board (rank == -1): the best score on
## record and how many more points this run needed to rank — see
## Leaderboard.gap_to_board(). Static and pure so it's testable without a
## scene tree.
static func missed_lines(best: int, gap: int) -> Array[String]:
	return ["Best: " + NumberFormat.thousands(best), NumberFormat.thousands(gap) + " to make the board"]


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
## (-1 if it didn't make the board). Restarting (the PlayAgainButton, or a
## keyboard jump/ui_accept press) is ignored for the first `input_delay`
## seconds, so a death-tap already in progress when the last heart goes
## doesn't skip straight past the screen.
func show_game_over(score: int, leaderboard: Leaderboard, rank: int, input_delay: float) -> void:
	_title_label.text = TITLE_TEXT
	_play_again_button.disabled = true

	var run_lines: Array[String] = GameOver.run_lines(score, rank)
	_run_header_label.text = run_lines[0]
	_run_score_label.text = run_lines[1]
	_run_badge_label.text = run_lines[2]
	_run_badge_label.add_theme_color_override("font_color", HIGHLIGHT_COLOR)

	var missed := rank == -1
	_run_best_label.visible = missed
	_run_gap_label.visible = missed
	if missed:
		var missed_lines: Array[String] = GameOver.missed_lines(leaderboard.best(), leaderboard.gap_to_board(score))
		_run_best_label.text = missed_lines[0]
		_run_gap_label.text = missed_lines[1]

	var ranked := rank >= 1
	_pick_label.visible = ranked
	_picker_grid.visible = ranked
	_leaderboard = leaderboard
	_picker_rank = rank

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
	# free(), not queue_free(): a picker tap rebuilds the board again in the
	# same frame as the initial show_game_over() rebuild, and new rows are
	# added right below this loop — a deferred free would leave both sets
	# of labels in the grid until the next frame.
	for child in _board_grid.get_children():
		child.free()

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


## The picker's 8 buttons, in Leaderboard.PICKER_EMOJI order. Exposed so
## tests can drive and inspect them without relying on node paths into the
## GridContainer.
func picker_buttons() -> Array[Button]:
	var buttons: Array[Button] = []
	for child in _picker_grid.get_children():
		if child is Button:
			buttons.append(child)
	return buttons


## Re-tags this run's board entry with `emoji`, re-renders the board so the
## highlighted row shows it immediately, and emits emoji_picked so Main can
## persist both the board and the last-picked emoji. The player can tap
## again to change it — there is no limit.
func _on_picker_button_pressed(emoji: String) -> void:
	_leaderboard.set_emoji(_picker_rank, emoji)
	_rebuild_board(_leaderboard, _picker_rank)
	emoji_picked.emit(emoji)


func _on_input_delay_timeout() -> void:
	_accepting_input = true
	_play_again_button.disabled = false


## Restarts on a keyboard press only — the `jump` action or `ui_accept`
## (Space / Enter) — gated on _accepting_input like PlayAgainButton's
## disabled state above. `jump` also maps to a mouse button (see
## project.godot), but an InputEventMouseButton is filtered out below
## before the action check, same as a touch tap arriving via mouse
## emulation: those restart only through PlayAgainButton now, so a tap
## anywhere on the card can't be mistaken for a deliberate restart.
func _unhandled_input(event: InputEvent) -> void:
	if not visible or not _accepting_input:
		return
	if not event is InputEventKey:
		return
	if event.is_action_pressed("jump") or event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		_restart()


func _restart() -> void:
	_accepting_input = false
	visible = false
	restart_requested.emit()
	if reload_on_restart:
		get_tree().paused = false
		get_tree().reload_current_scene()

class_name Main
extends Node2D

## Root of the game. Owns the run's Pace (built from an exported Tuning
## resource) and drives it every physics frame, then hands the resulting
## distance to World (so barrels/bamboo scroll for free) and to the
## background. Ground is a StaticBody2D whose top surface sits at
## Tuning.ground_y so the panda's feet rest on the painted path; Panda is
## fixed on screen and handles its own gravity and jump. Also owns a
## Spawner (seeded from randi() so runs vary) and rolls in barrels as
## children of World, placed at their spawn distance so Pace's scroll
## carries them for free — see issue #7.

const BARREL_SCENE: PackedScene = preload("res://scenes/hazards/barrel.tscn")
const BAMBOO_SCENE: PackedScene = preload("res://scenes/pickups/bamboo.tscn")
const HUD_SCENE: PackedScene = preload("res://scenes/ui/hud.tscn")
const GAME_OVER_SCENE: PackedScene = preload("res://scenes/ui/game_over.tscn")
const PAUSE_MENU_SCENE: PackedScene = preload("res://scenes/ui/pause_menu.tscn")
const SPAWN_LOOKAHEAD := 64.0

@export var tuning: Tuning

var pace: Pace
var health: Health
var _spawner: Spawner
var _next_spawn_at: float = 0.0

@onready var world: Node2D = $World
@onready var background: ForestBackground = $Background
@onready var ground_shape: CollisionShape2D = $Ground/CollisionShape2D
@onready var panda: Panda = $Panda

var _hud: Hud
var _game_over: GameOver
var _pause_menu: PauseMenu
var leaderboard: Leaderboard
var _score_store: ScoreStore


func _ready() -> void:
	pace = Pace.new(tuning)
	# Ground's shape is a fixed-size rectangle; center it so its top edge
	# lands on Tuning.ground_y, whatever that value is set to.
	var half_height: float = ground_shape.shape.size.y / 2.0
	ground_shape.position.y = tuning.ground_y + half_height

	health = Health.new(tuning)
	panda.health = health
	health.died.connect(_on_health_died)

	_hud = HUD_SCENE.instantiate()
	add_child(_hud)
	_hud.setup(health)

	_pause_menu = PAUSE_MENU_SCENE.instantiate()
	add_child(_pause_menu)

	_game_over = GAME_OVER_SCENE.instantiate()
	add_child(_game_over)

	var rng := RandomNumberGenerator.new()
	rng.seed = randi()
	_spawner = Spawner.new(tuning, rng)
	# The first barrel gets no "previous spawn" to gap from, so start it at
	# the same just-off-the-right-edge distance every later barrel arrives
	# at via the lookahead below, rather than the raw first gap (which can
	# land on screen, even on top of the panda).
	_next_spawn_at = Main.off_screen_spawn_x(get_viewport_rect().size.x)


func _physics_process(delta: float) -> void:
	pace.tick(delta)
	health.tick(delta)
	_hud.set_score(pace.score)
	world.position.x = -pace.distance
	background.set_distance(pace.distance)
	_spawn_if_due()


## The distance at which a spawn is just barely off the right edge of a
## `viewport_width`-wide viewport — the same threshold `_spawn_if_due` uses
## for every later barrel via its lookahead check. Static and pure so it's
## testable without a scene tree.
static func off_screen_spawn_x(viewport_width: float) -> float:
	return viewport_width + SPAWN_LOOKAHEAD


func _spawn_if_due() -> void:
	var viewport_width: float = get_viewport_rect().size.x
	while pace.distance + viewport_width + SPAWN_LOOKAHEAD >= _next_spawn_at:
		var spawn_x := _next_spawn_at
		var result: Dictionary = _spawner.next(pace.speed)
		_next_spawn_at += result.offset
		match result.kind:
			Spawner.Kind.BARREL:
				var barrel: Barrel = BARREL_SCENE.instantiate()
				barrel.position = Vector2(spawn_x, tuning.ground_y - Barrel.PICTURE_RADIUS)
				barrel.hit_panda.connect(_on_barrel_hit_panda)
				world.add_child(barrel)
			Spawner.Kind.BAMBOO_GROUND:
				_spawn_bamboo(spawn_x, tuning.ground_y)
			Spawner.Kind.BAMBOO_FLOAT:
				_spawn_bamboo(spawn_x, tuning.ground_y - tuning.bamboo_float_height)


## Instances bamboo at spawn_x with its bottom (the node's origin) at
## bottom_y, and connects eaten to healing so touching it restores a heart.
func _spawn_bamboo(spawn_x: float, bottom_y: float) -> void:
	var bamboo: Bamboo = BAMBOO_SCENE.instantiate()
	bamboo.position = Vector2(spawn_x, bottom_y)
	bamboo.eaten.connect(_on_bamboo_eaten)
	world.add_child(bamboo)


func _on_bamboo_eaten() -> void:
	health.heal()


func _on_barrel_hit_panda(_body: Node2D) -> void:
	health.hit()


## Freezes the run, submits the final score to a fresh Leaderboard, and
## shows the Game Over screen with this run's rank on it. The screen
## itself (process_mode ALWAYS) keeps running while paused so its
## input-delay timer and restart tap still work; everything else here
## (Main, Panda, the HUD, barrels) is left on the default PAUSABLE mode and
## simply stops, which is what makes the freeze work. The pause button is
## locked first so it can't unfreeze the tree from under Game Over.
##
## The board is loaded fresh from disk here (never cached across runs —
## restarting reloads the scene per #10, which builds a new Leaderboard),
## then saved again before Game Over is shown, so this run's score survives
## even if the app is closed while the Game Over card is still up.
func _on_health_died() -> void:
	_pause_menu.lock()
	get_tree().paused = true
	leaderboard = Leaderboard.new(tuning)
	_score_store = ScoreStore.new()
	leaderboard.load_data(_score_store.load_data())
	var rank: int = leaderboard.submit(pace.score, _score_store.load_last_emoji())
	_score_store.save_data(leaderboard.to_data())
	_game_over.show_game_over(pace.score, leaderboard, rank, tuning.game_over_input_delay)

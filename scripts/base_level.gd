extends Node2D
class_name BaseLevel ## Base level node for Second Set

# Game State
enum GAME_STATE {
	LEVEL_START,
	KEY_HELD,
	VAULT_OPENED,
	CAUGHT,
	ESCAPED,
}

# Nodes
@onready var sinatra := $Sinatra
# @onready var frank := $Frank
@onready var pcam2d := $PhantomCamera2D

# AI
var position_array : Array = [] # Contains positions that player (Sinatra) had
var animstate_array : Array # Contains animation states that player (Sinatra) had

# Tracker
var active_state : GAME_STATE = GAME_STATE.LEVEL_START

func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	match active_state: # State machine
		GAME_STATE.LEVEL_START:
			pass
		GAME_STATE.KEY_HELD:
			position_array.append(sinatra.position)
		GAME_STATE.VAULT_OPENED:
			pass

func restart_level() -> void:
	get_tree().reload_current_scene()

func switch_state(to_state: GAME_STATE) -> void:
	active_state = to_state

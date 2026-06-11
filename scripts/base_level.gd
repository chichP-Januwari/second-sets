extends Node2D
class_name BaseLevel ## Base level node for Second Set

# Game State
enum GAME_STATE {
	LEVEL_START,
	KEY_HELD,
	VAULT_OPENED,
	WON
}

# Nodes
@onready var sinatra := $Sinatra
@onready var frank := $Frank
@onready var pcam2d := $PhantomCamera2D
@onready var bg_tile_map_layer := $BGTileMapLayer
@onready var fg_tile_map_layer := $FGTileMapLayer

# AI
var position_array : PackedVector2Array # Contains positions that player (Sinatra) had
var animstate_array : Array[Player.STATE] # Contains animation states that player (Sinatra) had

# Tracker
var active_state : GAME_STATE = GAME_STATE.LEVEL_START

func _ready() -> void:
	fg_tile_map_layer.interacted.connect(_interacted_with_level)
	
	sinatra.position = fg_tile_map_layer.spawn_point

func _physics_process(_delta: float) -> void:
	match active_state: # State machine
		GAME_STATE.LEVEL_START:
			pass
		GAME_STATE.KEY_HELD:
			position_array.append(sinatra.position)
			animstate_array.append(sinatra.active_state)
		GAME_STATE.VAULT_OPENED:
			position_array.append(sinatra.position)
			animstate_array.append(sinatra.active_state)

func restart_level() -> void:
	# Placeholder
	get_tree().reload_current_scene()

func switch_game_state(to_state: GAME_STATE) -> void:
	active_state = to_state
	print(str(to_state))

func _interacted_with_level(interactable: String) -> void:
	match active_state:
		GAME_STATE.LEVEL_START:
			if interactable == "Key":
				switch_game_state(GAME_STATE.KEY_HELD)
		GAME_STATE.KEY_HELD:
			if interactable == "Vault":
				switch_game_state(GAME_STATE.VAULT_OPENED)
		GAME_STATE.VAULT_OPENED:
			if interactable == "Exit":
				switch_game_state(GAME_STATE.WON)

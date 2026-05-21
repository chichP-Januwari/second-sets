extends Node2D
class_name BaseLevel ## Base level node for Second Set

# Game State
enum GAME_STATE {
	FUCK,
	SHIT
}

# Nodes
@onready var sinatra := $Sinatra
# @onready var frank := $Frank
@onready var pcam2d := $PhantomCamera2D

# AI
var position_array : Array = [] # Contains positions that player (Sinatra) had
var animstate_array : Array # Contains animation states that player (Sinatra) had


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func _physics_process(_delta: float) -> void:
	pass

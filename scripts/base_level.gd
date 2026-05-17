extends Node2D

@export var initial_player_position : Vector2 ## Where the player (Sinatra) spawns.

var sinatra : Node2D
var sinatra_scene = preload("res://scenes/sinatra.tscn")
var sinatra_instance = sinatra_scene.instantiate()
"""
# var frank : Node2D
# var frank_scene = preload("res://scenes/frank.tscn")
# var frank_instance = frank_scene.instantiate()
"""

var key_collected := false


var position_array : Array = [] # Contains positions that player (Sinatra) had
var animstate_array : Array # Contains animation states that player (Sinatra) had

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(sinatra_instance)
	sinatra = get_node("Sinatra")
	sinatra.position = initial_player_position
	
	"""
	add_child(frank_instance)
	frank = get_node("Frank")
	sinatra.position = initial_player_position
	"""


func _physics_process(_delta: float) -> void:
	if key_collected == true:
		position_array.append(position)

extends Camera2D
"""
Camera2D custom script for Second Set
2026 chichP
"""
enum CAMERA {
	FIXED, ## Static camera. Does not change position except for programmed cutscenes.
	DYNAMIC, ## Camera has ability to change position.
}

const LEFTFACE_OFFSET := Vector2(120, 0)
const RIGHTFACE_OFFSET := Vector2(-120, 0)

@export var camera_type : CAMERA = CAMERA.FIXED ## Sets whether or not camera is fixed or dynamic.
@export var initial_position : Vector2 = Vector2(0, 0) ## Initial position of the camera, useful for fixed cameras.

@onready var sinatra = get_parent().get_node("Sinatra")

func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	if $CutsceneTimer.is_stopped():
		pass


func cutscene_switch_target(target : Vector2, time_seconds : float):
	$CutsceneTimer.start(time_seconds)

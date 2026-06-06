extends Area2D

# States
enum AI_STATE {
	DISABLED,
	APPEARING,
	ENABLED
}

enum ANIM_STATE {
	IDLE,
	RUN,
	JUMP,
	FALL,
	SLIDE,
	WALLSLIDE,
	WALLJUMP,
}

# Trackers
var position_array : PackedVector2Array

func _physics_process(delta: float) -> void:
	match AI_STATE:
		AI_STATE.DISABLED:
			pass
		AI_STATE.APPEARING:
			pass
		AI_STATE.ENABLED:
			pass

func switch_ai_state(to_state: AI_STATE):
	pass

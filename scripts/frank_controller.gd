class_name Enemy
extends Area2D

# States
enum AI_STATE {
	DISABLED,
	APPEARING,
	ENABLED
}

# Nodes
@onready var collision := $Collision
@onready var sprite := $AnimatedSprite2D

# Trackers
var active_state := AI_STATE.DISABLED

# Arrays
var position_array : PackedVector2Array
var animation_state_array : Array[Player.STATE]

func _physics_process(_delta: float) -> void:
	match active_state:
		AI_STATE.DISABLED:
			pass
		AI_STATE.APPEARING:
			pass
		AI_STATE.ENABLED:
			for index in position_array:
				position = index
			
			for index in animation_state_array.size():
				if animation_state_array[index + 1] == animation_state_array[index]:
					switch_anim_state(animation_state_array[index])
				elif animation_state_array[index + 1] != animation_state_array[index]:
					pass

func switch_ai_state(to_state: AI_STATE):
	match to_state:
		AI_STATE.DISABLED:
			pass
		AI_STATE.APPEARING:
			pass
		AI_STATE.ENABLED:
			pass

func switch_anim_state(to_state: Player.STATE):
	match to_state:
		Player.STATE.IDLE:
			sprite.play("sinatra_idle")
		Player.STATE.RUN:
			sprite.play("sinatra_run")
		Player.STATE.JUMP:
			sprite.play("sinatra_jump")
		Player.STATE.FALL:
			sprite.play("sinatra_fall")
		Player.STATE.SLIDE:
			sprite.play("sinatra_slide")
		Player.STATE.WALLSLIDE:
			sprite.play("sinatra_wallslide")
		Player.STATE.WALLJUMP:
			sprite.play("sinatra_wall")

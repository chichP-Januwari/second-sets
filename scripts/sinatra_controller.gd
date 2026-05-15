extends CharacterBody2D

enum STATE {
	IDLE,
	RUN,
	JUMP,
	FALL,
	SLIDE
}

const WALK_VELOCITY := 200.0
const JUMP_VELOCITY := -200.0
const GRAVITY := 1000.0

var active_state := STATE.IDLE

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("left", "right")
	
	match active_state:
		STATE.IDLE:
			if direction: # To RUN
				switch_state(STATE.RUN) 
			
			if Input.is_action_just_pressed("jump"): # To JUMP
				switch_state(STATE.JUMP)
			
			if !is_on_floor(): # To FALL
				switch_state(STATE.FALL)
			
			"""
			if Input.is_action_just_pressed("slide"): # To SLIDE
				switch_state(STATE.SLIDE)
			"""
		STATE.RUN:
			velocity.x = direction * WALK_VELOCITY
			if !direction: # To IDLE
				switch_state(STATE.IDLE) 
			
			if Input.is_action_just_pressed("jump"): # To JUMP
				switch_state(STATE.JUMP) 
			
			if !is_on_floor(): # To FALL
				$CoyoteTimer.start()
				switch_state(STATE.FALL)
			
			"""
			if Input.is_action_just_pressed("slide"): # To SLIDE
				switch_state(STATE.SLIDE)
			"""
			
		STATE.JUMP:
			velocity.x = direction * WALK_VELOCITY
			velocity.y = JUMP_VELOCITY
			
			if Input.is_action_just_released("jump") or velocity.y >= 0:
				switch_state(STATE.FALL)
			
		STATE.FALL:
			velocity.x = direction * WALK_VELOCITY
			velocity.y += GRAVITY * delta
			
			if !$CoyoteTimer.is_stopped():
				if Input.is_action_just_pressed("jump"): # To JUMP
					switch_state(STATE.JUMP) 
			
			if is_on_floor(): # To IDLE
				switch_state(STATE.IDLE)
			
		STATE.SLIDE:
			pass
			
	
	move_and_slide()

func switch_state(to_state: STATE) -> void: # Handles switching and animation
	active_state = to_state
	
	match active_state:
		STATE.IDLE:
			$AnimatedSprite2D.play("sinatra_idle")
			
		STATE.RUN:
			$AnimatedSprite2D.play("sinatra_run")
			
		STATE.JUMP:
			$AnimatedSprite2D.play("sinatra_fall")
			
		STATE.FALL:
			$AnimatedSprite2D.play("sinatra_fall")
			
		STATE.SLIDE:
			$AnimatedSprite2D.play()
			

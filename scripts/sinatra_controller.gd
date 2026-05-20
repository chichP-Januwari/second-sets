extends CharacterBody2D

enum STATE {
	IDLE,
	RUN,
	JUMP,
	FALL,
	SLIDE,
	WALLSLIDE,
	WALLJUMP,
}

var walk_velocity := 220.0
var jump_velocity := -200.0
var roll_speed := 300.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var active_state := STATE.IDLE
var facing_direction := 0 # Right

func _physics_process(delta: float) -> void:
	var direction : float
	if !active_state == STATE.SLIDE:
		direction = Input.get_axis("left", "right")
	# Only for animations
	if direction == 1:
		facing_direction = 0 # Right
	elif direction == -1:
		facing_direction = 1 # Left
	
	$AnimatedSprite2D.flip_h = facing_direction
	
	match active_state:
		STATE.IDLE:
			velocity.x = 0
			if direction: # To RUN
				switch_state(STATE.RUN) 
			
			if Input.is_action_just_pressed("jump") or !$JumpBuffer.is_stopped(): # To JUMP
				switch_state(STATE.JUMP) 
			
			if !is_on_floor(): # To FALL
				$CoyoteTimer.start()
				switch_state(STATE.FALL)
			
			if Input.is_action_just_pressed("slide"): # To SLIDE
				switch_state(STATE.SLIDE)
			
		STATE.RUN:
			velocity.x = direction * walk_velocity
			
			if !direction: # To IDLE
				switch_state(STATE.IDLE) 
			
			if Input.is_action_just_pressed("jump") or !$JumpBuffer.is_stopped(): # To JUMP
				switch_state(STATE.JUMP) 
			
			if !is_on_floor(): # To FALL
				$CoyoteTimer.start()
				switch_state(STATE.FALL)
			
			if Input.is_action_just_pressed("slide"): # To SLIDE
				switch_state(STATE.SLIDE)
			
		STATE.JUMP:
			velocity.x = direction * walk_velocity
			velocity.y = jump_velocity
			
			if Input.is_action_just_released("jump") or !Input.is_action_pressed("jump") or $MaxJumpTime.is_stopped() or is_on_ceiling_only(): # To FALL
				switch_state(STATE.FALL)
			
		STATE.FALL:
			velocity.x = direction * walk_velocity
			velocity.y += gravity * delta
			
			if Input.is_action_just_pressed("jump"): # To JUMP
				if !$CoyoteTimer.is_stopped():
					$CoyoteTimer.stop()
					switch_state(STATE.JUMP)
				else:
					$JumpBuffer.start()
			
			if is_on_floor(): # To IDLE
				switch_state(STATE.IDLE)
			
			if is_on_wall_only():
				switch_state(STATE.WALLSLIDE)
			
		STATE.SLIDE: # Travels 10~ tiles
			if facing_direction == 0: # Right
				velocity.x = roll_speed * 1
			elif facing_direction == 1: # Left
				velocity.x = roll_speed * -1
			
			if $SlideMinimum.is_stopped() or !is_on_floor() or is_on_wall(): # To IDLE
				switch_state(STATE.IDLE)
			
		STATE.WALLSLIDE:
			velocity.x = direction * walk_velocity
			velocity.y = 40
			
			if !is_on_wall_only(): # To FALL
				$CoyoteTimer.start()
				switch_state(STATE.FALL)
			
			if is_on_floor(): # To IDLE
				switch_state(STATE.IDLE)
			
			if Input.is_action_just_pressed("jump"): # To JUMP
				if $LeftWallRay.is_colliding() == true:
					$LeftWallRay.enabled = false
				elif $RightWallRay.is_colliding() == true:
					$RightWallRay.enabled = false
				switch_state(STATE.JUMP)
	
	$State.text = STATE.keys()[active_state]
	move_and_slide()


func switch_state(to_state: STATE) -> void: ## Handles switching and animation
	active_state = to_state
	
	match active_state:
		STATE.IDLE:
			$SlideMinimum.stop()
			$LeftWallRay.enabled = true
			$RightWallRay.enabled = true
			$Collision.shape.size = Vector2(12, 31)
			$Collision.position = Vector2(0, 0.5)
			$AnimatedSprite2D.play("sinatra_idle")
			
		STATE.RUN:
			$AnimatedSprite2D.play("sinatra_run")
			
		STATE.JUMP:
			$MaxJumpTime.start()
			$AnimatedSprite2D.play("sinatra_fall")
			
		STATE.FALL:
			$MaxJumpTime.stop()
			$AnimatedSprite2D.play("sinatra_fall")
			
		STATE.SLIDE:
			$SlideMinimum.start()
			$Collision.shape.size = Vector2(12, 7)
			$Collision.position = Vector2(0, 12.5)
			$AnimatedSprite2D.play("sinatra_slide")
		
		STATE.WALLSLIDE:
			$AnimatedSprite2D.play("sinatra_wallslide")
			

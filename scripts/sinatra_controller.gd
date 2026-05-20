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
var walljump_velocity := -250.0
var last_walljump := 0.0

var roll_speed := 300.0 # Also used for walljump
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var active_state := STATE.IDLE
var facing_direction := 0 # For animations and sliding, Right

func _physics_process(delta: float) -> void:
	var direction : float
	if active_state != STATE.SLIDE and active_state != STATE.WALLJUMP:
		direction = Input.get_axis("left", "right")
	# For sprite flipping
	if active_state != STATE.WALLSLIDE:
		if sign(direction) == 1:
			facing_direction = 0 # Right
		elif sign(direction) == -1:
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
			
			if !Input.is_action_pressed("jump") or $MaxJumpTime.is_stopped() or is_on_ceiling_only(): # To FALL
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
			
			if is_on_wall_only(): # To WALLSLIDE
				switch_state(STATE.WALLSLIDE)
			
		STATE.SLIDE: # Travels 10~ tiles
			if facing_direction == 0: # Right
				direction = 1
			elif facing_direction == 1: # Left
				direction = -1
			velocity.x = roll_speed * direction
			
			if $SlideMinimum.is_stopped() or !is_on_floor() or is_on_wall(): # To IDLE
				switch_state(STATE.IDLE)
			
		STATE.WALLSLIDE:
			velocity.x = direction * walk_velocity
			velocity.y = 30
			
			if sign(get_wall_normal().x) == 1:
				facing_direction = 1
			elif sign(get_wall_normal().x) == -1:
				facing_direction = 0
			
			if !is_on_wall_only(): # To FALL
				switch_state(STATE.FALL)
			
			if is_on_floor(): # To IDLE
				switch_state(STATE.IDLE)
			
			if Input.is_action_just_pressed("jump"): # To WALLJUMP
				switch_state(STATE.WALLJUMP)
		
		STATE.WALLJUMP:
			direction = get_wall_normal().x
			velocity.x = roll_speed * direction
			velocity.y = walljump_velocity
			
			if !Input.is_action_pressed("jump") or $WallJumpTimer.is_stopped() or is_on_ceiling_only(): # To FALL
				switch_state(STATE.FALL)
			
			if direction != last_walljump and is_on_wall_only(): # Charge that motherfucker to the WALL!
				velocity.x = roll_speed * last_walljump
				switch_state(STATE.WALLSLIDE)
	
	$State.text = STATE.keys()[active_state]
	move_and_slide()


func switch_state(to_state: STATE) -> void: ## Handles switching and animation
	active_state = to_state
	
	match active_state:
		STATE.IDLE:
			$SlideMinimum.stop()
			$Collision.shape.size = Vector2(12, 31)
			$Collision.position = Vector2(0, 0.5)
			$AnimatedSprite2D.play("sinatra_idle")
			
		STATE.RUN:
			$AnimatedSprite2D.play("sinatra_run")
			
		STATE.JUMP:
			$MaxJumpTime.start()
			$AnimatedSprite2D.play("sinatra_jump")
			
		STATE.FALL:
			$MaxJumpTime.stop()
			$WallJumpTimer.stop()
			$AnimatedSprite2D.play("sinatra_fall")
			
		STATE.SLIDE:
			$SlideMinimum.start()
			$Collision.shape.size = Vector2(12, 7)
			$Collision.position = Vector2(0, 12.5)
			$AnimatedSprite2D.play("sinatra_slide")
		
		STATE.WALLSLIDE:
			$AnimatedSprite2D.play("sinatra_wallslide")
		
		STATE.WALLJUMP:
			last_walljump = get_wall_normal().x
			$WallJumpTimer.start()
			$AnimatedSprite2D.play("sinatra_walljump")

extends CharacterBody2D

# Game State
enum STATE {
	IDLE,
	RUN,
	JUMP,
	FALL,
	SLIDE,
	WALLSLIDE,
	WALLJUMP,
}

# Nodes
@onready var collision: CollisionShape2D = $Collision
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_buffer: Timer = $JumpBuffer
@onready var max_jump_time: Timer = $MaxJumpTime
@onready var slide_minimum: Timer = $SlideMinimum
@onready var wall_jump_timer: Timer = $WallJumpTimer

# Speeds
var walk_velocity := 220.0
var jump_velocity := -200.0
var walljump_velocity := -220.0
var roll_speed := 300.0 # Also used for walljump
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Trackers
var facing_direction := 0 # For animations and sliding, Right
var last_walljump := 0.0
var active_state := STATE.IDLE # Default


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
	
	animated_sprite_2d.flip_h = facing_direction
	
	match active_state:
		STATE.IDLE:
			velocity.x = 0
			if direction: # To RUN
				switch_state(STATE.RUN) 
			
			if Input.is_action_just_pressed("jump") or !jump_buffer.is_stopped(): # To JUMP
				switch_state(STATE.JUMP) 
			
			if !is_on_floor(): # To FALL
				coyote_timer.start()
				switch_state(STATE.FALL)
			
			if Input.is_action_just_pressed("slide"): # To SLIDE
				switch_state(STATE.SLIDE)
			
		STATE.RUN:
			velocity.x = direction * walk_velocity
			
			if !direction: # To IDLE
				switch_state(STATE.IDLE) 
			
			if Input.is_action_just_pressed("jump") or !jump_buffer.is_stopped(): # To JUMP
				switch_state(STATE.JUMP) 
			
			if !is_on_floor(): # To FALL
				coyote_timer.start()
				switch_state(STATE.FALL)
			
			if Input.is_action_just_pressed("slide"): # To SLIDE
				switch_state(STATE.SLIDE)
			
		STATE.JUMP:
			velocity.x = direction * walk_velocity
			velocity.y = jump_velocity
			
			if !Input.is_action_pressed("jump") or max_jump_time.is_stopped() or is_on_ceiling_only(): # To FALL
				switch_state(STATE.FALL)
			
		STATE.FALL:
			velocity.x = direction * walk_velocity
			velocity.y += gravity * delta
			
			if Input.is_action_just_pressed("jump"): # To JUMP
				if !coyote_timer.is_stopped():
					coyote_timer.stop()
					switch_state(STATE.JUMP)
				else:
					jump_buffer.start()
			
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
			
			if slide_minimum.is_stopped() or !is_on_floor() or is_on_wall(): # To IDLE
				switch_state(STATE.IDLE)
			
		STATE.WALLSLIDE:
			velocity.x = direction * walk_velocity
			velocity.y = 30
			
			if sign(get_wall_normal().x) == 1: # If wall is on left
				facing_direction = 1 # Face right
			elif sign(get_wall_normal().x) == -1: # If wall is on right
				facing_direction = 0 # Face left
			
			if !is_on_wall(): # To FALL
				switch_state(STATE.FALL)
			
			if is_on_floor(): # To IDLE
				switch_state(STATE.IDLE)
			
			if Input.is_action_just_pressed("jump"): # To WALLJUMP
				switch_state(STATE.WALLJUMP)
		
		STATE.WALLJUMP:
			direction = get_wall_normal().x
			velocity.x = roll_speed * direction
			velocity.y = walljump_velocity
			
			if !Input.is_action_pressed("jump") or wall_jump_timer.is_stopped() or is_on_ceiling_only(): # To FALL
				switch_state(STATE.FALL)
			
			if direction != last_walljump and is_on_wall_only(): # Charge that motherfucker to the WALL!
				velocity.x = roll_speed * last_walljump
				switch_state(STATE.WALLSLIDE)
	
	move_and_slide()


func switch_state(to_state: STATE) -> void: ## Handles switching and animation
	active_state = to_state
	
	match active_state:
		STATE.IDLE:
			slide_minimum.stop()
			collision.shape.size = Vector2(12, 31)
			collision.position = Vector2(0, 0.5)
			animated_sprite_2d.play("sinatra_idle")
			
		STATE.RUN:
			animated_sprite_2d.play("sinatra_run")
			
		STATE.JUMP:
			max_jump_time.start()
			animated_sprite_2d.play("sinatra_jump")
			
		STATE.FALL:
			max_jump_time.stop()
			wall_jump_timer.stop()
			animated_sprite_2d.play("sinatra_fall")
			
		STATE.SLIDE:
			slide_minimum.start()
			collision.shape.size = Vector2(12, 7)
			collision.position = Vector2(0, 12.5)
			animated_sprite_2d.play("sinatra_slide")
		
		STATE.WALLSLIDE:
			animated_sprite_2d.play("sinatra_wallslide")
		
		STATE.WALLJUMP:
			last_walljump = get_wall_normal().x
			wall_jump_timer.start()
			animated_sprite_2d.play("sinatra_walljump")

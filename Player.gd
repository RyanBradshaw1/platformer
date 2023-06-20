extends KinematicBody2D

export(int) var JUMP_FORCE = -200
export(int) var JUMP_RELEASE_FORCE = -70
export(int) var MAX_SPEED = 500
export(int) var MAX_SPRINT_SPEED = 1500
export(int) var ACCELERATION = 100
export(int) var FRICTION = 10
export(int) var GRAVITY = 4
export(int) var ADDITIONAL_FALL_GRAVITY = 3

var velocity = Vector2.ZERO

onready var animatedSprite = $AnimatedSprite
func _ready():
	pass
	# animatedSprite.frames = load("res://PlayerPinkSkin.tres")
	
func _physics_process(delta):
	apply_gravity()
	
	# input.x = -1 if move left, 0 if no movement, 1 if move right
	var input = Vector2.ZERO
	input.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	if input.x == 0:
		animatedSprite.animation = "Idle"
		apply_friction()
	else:
		apply_acceleration(input.x)
		animatedSprite.animation = "Run"
		if input.x > 0:
			animatedSprite.flip_h = true
		elif input.x < 0:
			animatedSprite.flip_h = false
	
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
		
	if is_on_floor():
		if Input.is_action_pressed("jump"):
			velocity.y = JUMP_FORCE
	else:
		animatedSprite.animation = "Jump"
		if Input.is_action_just_released("ui_up") and velocity.y < JUMP_RELEASE_FORCE:
			velocity.y = JUMP_RELEASE_FORCE
			
		if velocity.y > 0:
			velocity.y += ADDITIONAL_FALL_GRAVITY
			
	var was_in_air = not is_on_floor() # is player in air before calling move_and_slide
	velocity = move_and_slide(velocity, Vector2.UP)
	# is player on floor after calling move_and_slide
	# and in air before calling move_and_slide
	var just_landed = is_on_floor() and was_in_air 
	if just_landed:
		animatedSprite.animation = "Run"
		animatedSprite.frame = 1
		
func apply_gravity():
	velocity.y += GRAVITY
	velocity.y = min(velocity.y, 200)
	
func apply_friction():
	velocity.x = move_toward(velocity.x, 0, FRICTION)
	
func apply_acceleration(amount):
	# velocity.x = move_toward(velocity.x, MAX_SPEED * amount, ACCELERATION)
	if Input.is_action_pressed("sprint"):
		velocity.x = move_toward(velocity.x, MAX_SPRINT_SPEED * amount, ACCELERATION)
	else:
		velocity.x = move_toward(velocity.x, MAX_SPEED * amount, ACCELERATION)

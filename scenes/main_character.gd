extends CharacterBody2D

var SPEED_CAP = 1
const SPEED = 250.0
const JUMP_VELOCITY = -150.0
const MAX_JUMP_CHARGE_TIME = 1.0  # Maximum time in seconds for charging the jump
const JUMP_FORCE_INCREMENT = -300.0  # Additional jump force added per second of charge

@onready var sprite_2d = $AnimatedSprite2D
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jump_charge_duration = 0.0
var is_charging_jump = false

func _physics_process(delta):
	# Add the gravity.
	
	# Update animation.
	if (velocity.x > 1 || velocity.x < -1):
		sprite_2d.animation = "running"
	else:
		sprite_2d.animation = "default"
		
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump charging.
	if Input.is_action_pressed("jump") and is_on_floor():
		if !is_charging_jump:
			is_charging_jump = true
			jump_charge_duration = 0.0  # Reset the charge duration
		else:
			jump_charge_duration = min(jump_charge_duration + delta, MAX_JUMP_CHARGE_TIME)

	if is_charging_jump and !Input.is_action_pressed("jump"):
		velocity.y = JUMP_VELOCITY + JUMP_FORCE_INCREMENT * jump_charge_duration
		is_charging_jump = false

	# Handle movement and animation.
	var direction = Input.get_axis("left", "right")
	if direction:
		if is_on_floor():
			SPEED_CAP = 0.2
		else:
			SPEED_CAP = 1
		velocity.x = direction * SPEED * SPEED_CAP
		sprite_2d.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, 15)

	move_and_slide()

	# Reset vertical velocity when on the ground.
	if is_on_floor() and velocity.y > 0:
		velocity.y = 0

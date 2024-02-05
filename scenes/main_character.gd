extends CharacterBody2D

const SPEED = 400.0
const JUMP_VELOCITY = -200.0
const MAX_JUMP_CHARGE_TIME = 1.0  # Maximum time in seconds for charging the jump
const JUMP_FORCE_INCREMENT = -450.0  # Additional jump force added per second of charge
const BOUNCE_FACTOR = 0.7  # Adjust this value for the desired bounce effect
const DEFAULT_PHYSICS_LAYER = 1 << 0  # Bit flag for physics layer 0
var SPEED_CAP = 1

@onready var sprite_2d = $AnimatedSprite2D
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jump_charge_duration = 0.0
var is_charging_jump = false
var incapacitated = false  # New variable to track incapacitation state
	
func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		# Reset vertical velocity when on the ground.
		velocity.y = 0
		if incapacitated:
			# Reset incapacitation state if on the floor
			incapacitated = false

	# Handle jump charging
	if not incapacitated and Input.is_action_pressed("jump") and is_on_floor():
		if not is_charging_jump:
			is_charging_jump = true
			jump_charge_duration = 0.0
		else:
			jump_charge_duration = min(jump_charge_duration + delta, MAX_JUMP_CHARGE_TIME)

	if is_charging_jump and not Input.is_action_pressed("jump"):
		velocity.y = JUMP_VELOCITY + JUMP_FORCE_INCREMENT * jump_charge_duration
		is_charging_jump = false

	# Handle movement and animation if not incapacitated.
	if not incapacitated:
		var direction = Input.get_axis("left", "right")
		if direction:
			if is_on_floor():
				SPEED_CAP = 0.4
			else:
				SPEED_CAP = 1.0
			velocity.x = direction * SPEED * SPEED_CAP
			sprite_2d.flip_h = direction < 0
		else:
			velocity.x = move_toward(velocity.x, 0, 30)
	
	# Update animation.
	if velocity.x > 1 || velocity.x < -1:
		sprite_2d.animation = "running"
	else:
		sprite_2d.animation = "default"

	move_and_slide()

	if not incapacitated:
		for index in range(get_slide_collision_count()):
			var collider = get_slide_collision(index).collider
			if collider is TileMap:
				velocity.x = -velocity.x * BOUNCE_FACTOR
				incapacitated = true
				break

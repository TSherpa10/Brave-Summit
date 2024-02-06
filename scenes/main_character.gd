extends CharacterBody2D

const SPEED = 450.0
const JUMP_VELOCITY = -200.0
const MAX_JUMP_CHARGE_TIME = 1.0  # Maximum time in seconds for charging the jump
const JUMP_FORCE_INCREMENT = -450.0  # Additional jump force added per second of charge
const BOUNCE_FACTOR = 0.6  # Adjust this value for the desired bounce effect
var SPEED_CAP = 1

@onready var sprite_2d = $AnimatedSprite2D
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jump_charge_duration = 0.0
var is_charging_jump = false
var incapacitated = false  # New variable to track incapacitation state
var bouncing = false
var bounce_velocity = -100
@onready var collidable = get_node("../Collidable")

func _ready():
	# Connect the area_entered signal from each Area2D to this character script.
	for area in collidable.get_children():
		if area is Area2D:
			print("hardyharhar")
			area.connect("body_entered", Callable(self, "_on_body_entered"))

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
	
	if bouncing:
		velocity.x = bounce_velocity
		bouncing = false
		
	if not incapacitated:
		var direction = Input.get_axis("left", "right")
		if direction: sprite_2d.flip_h = direction < 0
		if direction and not Input.is_action_pressed("jump"):
			if is_on_floor():
				SPEED_CAP = 0.4
			else:
				SPEED_CAP = 1.0
			velocity.x = direction * SPEED * SPEED_CAP
		else:
			velocity.x = move_toward(velocity.x, 0, 30)
	
	# Update animation.
	if velocity.x > 1 || velocity.x < -1:
		sprite_2d.animation = "running"
	else:
		sprite_2d.animation = "default"

	move_and_slide()
	
func _on_body_entered(body):
	#print("velocity right now", velocity.x)
	if body == self and not is_on_floor() and abs(velocity.x) > 1:
		bounce_velocity = -velocity.x * BOUNCE_FACTOR
		incapacitated = true
		bouncing = true

extends CharacterBody2D

# Constants
const SPEED = 450.0
const JUMP_VELOCITY = -200.0
const MAX_JUMP_CHARGE_TIME = 0.8 # Maximum time in seconds for charging the jump
const JUMP_FORCE_INCREMENT = -600  # Additional jump force added per second of charge
const BOUNCE_FACTOR = 0.4  # Adjust this value for the desired bounce effect
var SPEED_CAP = 1

# Jump variables.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jump_charge_duration = 0.0
var is_charging_jump = false

# Bouncing off walls base variables.
var incapacitated = false
var bouncing = false
var bounce_velocity = -100

# Sliding variables:
var slide_exited = false
var sliding = false
var slide_direction = Vector2.ZERO
var slide_velocity = Vector2.ZERO
var slide_acceleration = 400.0
var max_slide_speed = 1000.0
var on_ice = false

# Player Sprite + Area2Ds + ChargeBar
@onready var sprite_2d = $AnimatedSprite2D
@onready var collidable = get_node("../Collidable")
@onready var slide_surfaces = get_node("../SlideSurfaces")
@onready var special_blocks = get_node("../SpecialBlocks")
@onready var charge_bar = %ChargeBar

func _ready():
	# Connect the area_entered signal from each Area2D to this character script.
	if collidable:
		for area in collidable.get_children():
			if area is Area2D:
				area.connect("body_entered", Callable(self, "_on_wall_entered"))
	if slide_surfaces:
		for area in slide_surfaces.get_children():
			if area is Area2D:
				var slope_type = "normal"  # Default value
				if area.name.begins_with("Gentle"):
					slope_type = "gentle"
				elif area.name.begins_with("Steep"):
					slope_type = "steep"
				var orientation = "right" if area.name.ends_with("Right") else "left"
				var callable1 = Callable(self, "_on_slide_surface_entered").bind(slope_type, orientation)
				var callable2 = Callable(self, "_on_slide_surface_exited")
				area.connect("body_entered", callable1)
				area.connect("body_exited", callable2)
	if special_blocks:
		for area in special_blocks.get_children():
			if area is Area2D:
				var block_type = "ice" # for now.
				var callable1 = Callable(self, "_on_block_entered").bind(block_type)
				var callable2 = Callable(self, "_on_block_exited").bind(block_type)
				area.connect("body_entered", callable1)
				area.connect("body_exited", callable2)
	charge_bar.visible = false

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		if (velocity.y > 0):
			velocity.y += (gravity * 1.5) * delta
		else:
			velocity.y += gravity * delta
	else:
		# Reset vertical velocity when on the ground.
		velocity.y = 0
		if incapacitated and velocity.x == 0 and not sliding: # velocity.x > 0 and on floor when sliding, need to check this.
			# Reset incapacitation state if on the floor
			incapacitated = false
	
	# Handle Sliding Logic
	if sliding:
		if not slide_exited:
			slide_velocity += slide_direction * slide_acceleration * delta
			if slide_velocity.length() > max_slide_speed:
				slide_velocity = slide_velocity.normalized() * max_slide_speed
			velocity.x = slide_velocity.x
			velocity.y = 600
		else:
			if is_on_floor():
				incapacitated = false
				sliding = false
				velocity.x = 0
	
	# Handle Jump Charging	
	if not incapacitated and Input.is_action_pressed("jump") and is_on_floor():
		# play charge jump animation.
		charge_bar.visible = true
		charge_bar.play("charge_animation")
		if not is_charging_jump:
			is_charging_jump = true
			jump_charge_duration = 0.0
		else:
			jump_charge_duration = min(jump_charge_duration + delta, MAX_JUMP_CHARGE_TIME)
	else: 
		# if not pressing jump, or incapacitated, or not on floor, stop animation and reset frames.
		charge_bar.stop()
		charge_bar.visible = false
		charge_bar.frame = 0
		
	if is_charging_jump and not Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY + JUMP_FORCE_INCREMENT * jump_charge_duration
		is_charging_jump = false
	# Handle movement and animation if not incapacitated.
	
	if bouncing:
		velocity.x = bounce_velocity
		bouncing = false

	if not incapacitated:
		var direction = Input.get_axis("left", "right")
		if direction: sprite_2d.flip_h = direction < 0
		if direction and (not Input.is_action_pressed("jump") or (Input.is_action_pressed("jump") and not is_on_floor())):
			if is_on_floor():
				SPEED_CAP = 0.6
			else:
				SPEED_CAP = 1.0
			velocity.x = direction * SPEED * SPEED_CAP
		else:
			if not on_ice:
				velocity.x = move_toward(velocity.x, 0, 100)
			else:
				velocity.x = move_toward(velocity.x, 0, 3)

	# Update animation.
	if is_on_floor() and (velocity.x > 1 || velocity.x < -1):
		sprite_2d.animation = "running"
	elif not is_on_floor():
		if velocity.y > 0:
			sprite_2d.animation = "jump_down"
		else:
			sprite_2d.animation = "jump_up"
		if sprite_2d.frame == 1:
			sprite_2d.frame = 1 # keep it at 1.
	else:
		sprite_2d.animation = "default"

	move_and_slide()

func _on_wall_entered(body):
	if body == self and not is_on_floor() and abs(velocity.x) > 1:
		bounce_velocity = -velocity.x * BOUNCE_FACTOR
		incapacitated = true
		bouncing = true
		
func _on_slide_surface_entered(body, slope_type, orientation):
	if body == self and is_on_floor():
		# slide logic
		incapacitated = true
		sliding = true
		slide_exited = false
		
		var slide_surface_normal = Vector2.ZERO
		match slope_type:
			"gentle":
				slide_surface_normal = Vector2(cos(deg_to_rad(112.5)), sin(deg_to_rad(112.5)))
			"steep":
				slide_surface_normal = Vector2(cos(deg_to_rad(157.5)), sin(deg_to_rad(157.5)))
			_:
				slide_surface_normal = Vector2(cos(deg_to_rad(135)), sin(deg_to_rad(135)))
		slide_surface_normal.y = slide_surface_normal.y if orientation == "left" else -slide_surface_normal.y
		slide_direction = Vector2(slide_surface_normal.y, -slide_surface_normal.x).normalized()
		slide_velocity = slide_direction * slide_acceleration

func _on_slide_surface_exited(body):
	if body == self:
		slide_exited = true
		
func _on_block_entered(body, block_type):
	if is_on_floor() and block_type == "ice":
		on_ice = true
		
func _on_block_exited(body, block_type):
	if block_type == "ice":
		on_ice = false

func _on_charge_bar_animation_finished():
	# when the animation finishes, pause at last frame.
	charge_bar.frame = 10

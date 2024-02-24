extends TextureRect

var follow_speed = 0.1  # Determines how quickly the background follows the player
var initial_offset = Vector2.ZERO  # The initial offset from the origin

# Reference to the player node
@onready var player = get_node("../CharacterBody2D")  # Adjust the path to your player node

func _ready():
	# Calculate the initial offset based on the current position and player's starting position
	initial_offset = global_position - player.global_position

func _process(delta):
	# Calculate the target position with the offset
	var target_position = player.global_position + initial_offset
	
	# This will make the background follow both vertically and horizontally
	global_position.y += (target_position.y - global_position.y) * follow_speed

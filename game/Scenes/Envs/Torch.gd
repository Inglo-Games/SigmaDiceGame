extends Node3D

const LIGHT_ENERGY_OFFSET := 1.80
const LIGHT_ENERGY_SCALE := 5.0

@export_color_no_alpha var color := Color("c3781c")

@onready var light : OmniLight3D = $OmniLight3D

var noise_img : NoiseTexture2D
var counter := 0.0

func _ready() -> void:
	# Set light color to export var
	light.light_color = color
	
	# Generate grainy noise to simulate the flickering
	noise_img = NoiseTexture2D.new()
	noise_img.seamless = true
	noise_img.noise = FastNoiseLite.new()
	noise_img.noise.seed = randi()
	noise_img.noise.frequency = 0.55
	
	# Make point size of flame material larger
	$GPUParticles3D.draw_pass_1.material.set_point_size(2.0)

func _process(delta: float) -> void:
	counter += delta
	if(noise_img):
		light.light_energy = LIGHT_ENERGY_OFFSET + \
				abs(noise_img.noise.get_noise_1d(counter)) * LIGHT_ENERGY_SCALE

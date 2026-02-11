## ParticleFactory — Reusable Particle Effect Generator (Autoload)
##
## Creates and fires one-shot particle effects at given positions.
## All particles are pooled and reused to avoid GC hits.
##
## Usage:
##   ParticleFactory.dust(global_position)
##   ParticleFactory.impact(global_position, Color.RED)
##   ParticleFactory.speed_lines(player_node)
extends Node


# ─── Pool ────────────────────────────────────────────────────────────────────

const POOL_SIZE: int = 20
var _dust_pool: Array[GPUParticles2D] = []
var _pool_index: int = 0


# ─── Lifecycle ──────────────────────────────────────────────────────────────

func _ready() -> void:
	for i in POOL_SIZE:
		var p := _create_dust_emitter()
		p.emitting = false
		add_child(p)
		_dust_pool.append(p)


# ─── Public API ─────────────────────────────────────────────────────────────

## Emit a small dust poof at the given world position.
func dust(pos: Vector2, color: Color = Color.WHITE) -> void:
	var emitter := _get_from_pool()
	emitter.global_position = pos
	emitter.modulate = color
	emitter.amount = 6
	emitter.lifetime = 0.3
	emitter.emitting = true


## Emit a stronger impact burst (for landing, death, etc.)
func impact(pos: Vector2, color: Color = Color.WHITE, amount: int = 12) -> void:
	var emitter := _get_from_pool()
	emitter.global_position = pos
	emitter.modulate = color
	emitter.amount = amount
	emitter.lifetime = 0.5
	emitter.emitting = true


## Emit landing dust: wider spread, more particles.
func land_dust(pos: Vector2) -> void:
	var emitter := _get_from_pool()
	emitter.global_position = pos
	emitter.modulate = Color(1, 1, 1, 0.7)
	emitter.amount = 8
	emitter.lifetime = 0.4
	emitter.emitting = true


## Emit a physics-change glitch burst with the state's colour.
func physics_change_burst(pos: Vector2, color: Color) -> void:
	var emitter := _get_from_pool()
	emitter.global_position = pos
	emitter.modulate = color
	emitter.amount = 16
	emitter.lifetime = 0.6
	emitter.emitting = true


# ─── Pool Management ───────────────────────────────────────────────────────

func _get_from_pool() -> GPUParticles2D:
	var emitter := _dust_pool[_pool_index]
	_pool_index = (_pool_index + 1) % POOL_SIZE
	return emitter


# ─── Factory ────────────────────────────────────────────────────────────────

func _create_dust_emitter() -> GPUParticles2D:
	var p := GPUParticles2D.new()
	p.one_shot = true
	p.explosiveness = 0.9
	p.amount = 6
	p.lifetime = 0.3

	# Use a ParticleProcessMaterial for simple dust
	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, -1, 0)
	mat.spread = 180.0
	mat.initial_velocity_min = 30.0
	mat.initial_velocity_max = 80.0
	mat.gravity = Vector3(0, 200, 0)
	mat.scale_min = 1.0
	mat.scale_max = 3.0
	mat.color = Color.WHITE

	# Fade out
	var gradient := Gradient.new()
	gradient.set_offset(0, 0.0)
	gradient.set_color(0, Color(1, 1, 1, 1))
	gradient.add_point(1.0, Color(1, 1, 1, 0))
	var tex := GradientTexture1D.new()
	tex.gradient = gradient
	mat.color_ramp = tex

	p.process_material = mat
	return p

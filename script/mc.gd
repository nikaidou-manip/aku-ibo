extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const DASH_SPEED = 1200.0       # Kecepatan meluncur
var is_dashing = false         # Status sedang dash
var can_dash = true            # Cooldown dash
var dash_direction = 1         # Arah dash terakhir

# Referensi ke node AnimatedSprite2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	
	if is_dashing:
		velocity.x = dash_direction * DASH_SPEED
		velocity.y = 0  # Kunci sumbu Y agar tidak jatuh/naik saat dash
		animated_sprite.play("dash") # Jalankan animasi dash
		move_and_slide()
		return
		
	# 1. Menambahkan Gravitasi
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 2. Menangani Melompat
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 3. Menangani Pergerakan Horizontal (Maju/Mundur)
	var direction := Input.get_axis("mundur", "maju")
	if direction != 0:
		velocity.x = direction * SPEED
		dash_direction = sign(direction) # Simpan arah pergerakan
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if Input.is_action_just_pressed("dashtrigger") and can_dash:
		start_dash()

	# 4. Menangani Flip (Membalik arah sprite ke kiri/kanan)
	if direction > 0:
		animated_sprite.flip_h = false # Menghadap kanan
	elif direction < 0:
		animated_sprite.flip_h = true  # Menghadap kiri (flip)

	# 5. Menangani Animasi
	update_animation(direction)

	move_and_slide()


func start_dash() -> void:
	is_dashing = true
	can_dash = false
	
	# Tentukan arah dash berdasarkan sprite jika sedang diam
	if animated_sprite.flip_h:
		dash_direction = -1
	else:
		dash_direction = 1
	
	# Durasi dash meluncur (0.15 detik)
	await get_tree().create_timer(0.15).timeout
	is_dashing = false
	
	# Cooldown sebelum bisa dash lagi (0.6 detik)
	await get_tree().create_timer(0.6).timeout
	can_dash = true

# Fungsi terpisah untuk mengatur logika animasi
func update_animation(direction: float) -> void:
	if is_dashing:
		animated_sprite.play("dash")
	elif not is_on_floor():
		if velocity.y < 0:
			animated_sprite.play("jump_up")
		else:
			animated_sprite.play("jump_fall")
	else:
		if direction != 0:
			animated_sprite.play("run")
		else:
			animated_sprite.play("idle")

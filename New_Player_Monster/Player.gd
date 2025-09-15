extends CharacterBody3D

signal hit

@export var speed := 14.0
@export var fall_acceleration := 75.0
@export var jump_impulse := 20.0
@export var bounce_impulse := 16.0

var target_velocity := Vector3.ZERO

# ชี้ไปที่ AnimationPlayer ของ Cat.glb
@onready var anim_player: AnimationPlayer = $Pivot/PlayerCat/AnimationPlayer2

func _physics_process(delta):
	var direction := Vector3.ZERO

	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1

	# การหมุนตัว
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		$Pivot.basis = Basis.looking_at(direction)
		if anim_player.current_animation != "CharacterArmature|Walk":
			anim_player.play("CharacterArmature|Walk")
	else:
		if anim_player.current_animation != "CharacterArmature|Idle":
			anim_player.play("CharacterArmature|Idle")

	# ความเร็วแกน XZ
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	# ความเร็วแกน Y
	if not is_on_floor():
		target_velocity.y -= fall_acceleration * delta
	else:
		if Input.is_action_just_pressed("jump"):
			target_velocity.y = jump_impulse
			anim_player.play("CharacterArmature|Jump")

	# ตรวจการชน
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision.get_collider() and collision.get_collider().is_in_group("mob"):
			if Vector3.UP.dot(collision.get_normal()) > 0.1:
				var mob = collision.get_collider()
				mob.squash()
				target_velocity.y = bounce_impulse
				break

	# อัปเดตความเร็ว
	velocity = target_velocity
	move_and_slide()

# ตาย
func die():
	if anim_player.has_animation("CharacterArmature|Death"):
		anim_player.play("CharacterArmature|Death")
	hit.emit()
	queue_free()

func _on_mob_detector_body_entered(body):
	die()

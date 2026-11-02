extends Node2D

@onready var btn_level_1 = $papan_level/btn_level1
@onready var btn_level_2 = $papan_level/btn_level2
@onready var btn_level_3 = $papan_level/btn_level3

# --- TAMBAHAN: Referensi ke node papan pengaturan ---
@onready var papan_pengaturan = $papan # Pastikan namamu node-nya adalah "papan"

# Siapkan gambar bintang kecil untuk menu (pastikan kamu punya file ini)
@export var tex_bintang_kosong_kecil: Texture2D
@export var tex_bintang_kuning_kecil: Texture2D
@onready var color_rect_redup = $ColorRect

func _ready() -> void:
	# --- TAMBAHKAN BARIS INI DI SINI ---
	if color_rect_redup:
		color_rect_redup.visible = false
		
	# --- TAMBAHAN: Sembunyikan papan pengaturan saat menu level pertama kali dibuka ---
	if papan_pengaturan:
		papan_pengaturan.visible = false
	# --- TAMBAHAN: Sembunyikan papan pengaturan saat menu level pertama kali dibuka ---
	if papan_pengaturan:
		papan_pengaturan.visible = false

	# 1. Buka atau kunci tombol berdasarkan progres di Global
	btn_level_2.disabled = Global.level_terbuka < 2
	btn_level_3.disabled = Global.level_terbuka < 3
	
	# 2. Perbarui gambar 3 bintang kecil di bawah setiap tombol
	tampilkan_bintang(btn_level_1, Global.bintang_level[1])
	tampilkan_bintang(btn_level_2, Global.bintang_level[2])
	tampilkan_bintang(btn_level_3, Global.bintang_level[3])

func tampilkan_bintang(tombol: TextureButton, jumlah_kuning: int) -> void:
	# Asumsi: Setiap TextureButton memiliki 3 anak node bertipe TextureRect bernama 'bintang1', 'bintang2', 'bintang3'
	# Sesuaikan jalur ($) di bawah ini jika struktur nodemu berbeda
	if tombol.has_node("bintang1") and tombol.has_node("bintang2") and tombol.has_node("bintang3"):
		var b1 = tombol.get_node("bintang1")
		var b2 = tombol.get_node("bintang2")
		var b3 = tombol.get_node("bintang3")
		
		# Reset semua jadi kosong dulu
		b1.texture = tex_bintang_kosong_kecil
		b2.texture = tex_bintang_kosong_kecil
		b3.texture = tex_bintang_kosong_kecil
		
		# Nyalakan kuning sesuai jumlah yang didapat (1-3)
		if jumlah_kuning >= 1: b1.texture = tex_bintang_kuning_kecil
		if jumlah_kuning >= 2: b2.texture = tex_bintang_kuning_kecil
		if jumlah_kuning >= 3: b3.texture = tex_bintang_kuning_kecil

# --- FUNGSI KLIK TOMBOL LEVEL ---
func _on_btn_level_1_pressed() -> void:
	mulai_gameplay(1)

func _on_btn_level_2_pressed() -> void:
	mulai_gameplay(2)

func _on_btn_level_3_pressed() -> void:
	mulai_gameplay(3)

func mulai_gameplay(level_terpilih: int) -> void:
	Global.level_pilihan = level_terpilih 
	get_tree().change_scene_to_file("res://GamePlay/GamePlay.tscn")

# Jika ini adalah tombol "X" di papan level yang juga untuk kembali ke menu utama
func _on_btn_close_pressed() -> void:
	get_tree().change_scene_to_file("res://Halaman_Utama/Halaman_Utama.tscn")


# ==========================================
# --- TAMBAHAN: FUNGSI PENGATURAN & BACK ---
# ==========================================

# Fungsi untuk tombol panah kembali (pojok kiri atas)
func _on_btn_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Halaman_Utama/Halaman_Utama.tscn")

# Fungsi untuk tombol roda gigi (pojok kanan atas)
func _on_btn_setting_pressed() -> void:
	if papan_pengaturan:
		papan_pengaturan.visible = true
	if color_rect_redup:
		color_rect_redup.visible = true # Munculkan layar gelap redup

# Saat tombol 'X' (btn_cl) di dalam pengaturan diklik
func _on_btn_cl_pressed() -> void:
	if papan_pengaturan:
		papan_pengaturan.visible = false
	if color_rect_redup:
		color_rect_redup.visible = false # Sembunyikan layar gelap redup


func _on_replay_pressed() -> void:
	pass # Replace with function body.

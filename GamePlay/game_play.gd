extends Control

@export var keping_kiri: TextureRect
@export var keping_kanan: TextureRect

@export_category("Pengaturan Level")
#@export_range(1, 3) var level: int = 1

@export_category("Gambar Hint / Transparan")
@export var node_gambar_transparan: TextureRect
@export var hint_level_1: Texture2D
@export var hint_level_2: Texture2D
@export var hint_level_3: Texture2D

@export_category("Data Kepingan Per Level")
@export var kepingan_level_1: Array[Texture2D] # 4 keping (2x2)
@export var kepingan_level_2: Array[Texture2D] # 9 keping (3x3)
@export var kepingan_level_3: Array[Texture2D] # 16 keping (4x4)

@export_category("Animasi Bintang Menang")
@export var tex_bintang_kosong: Texture2D
@export var tex_bintang_kuning: Texture2D

@onready var color_rect_redup = $ColorRect
@onready var node_level_1 = $Papan/GambarTransparan/level_1
@onready var node_level_2 = $Papan/GambarTransparan/level_2
@onready var node_level_3 = $Papan/GambarTransparan/level_3

# Referensi Node Papan & UI
@onready var papan_pengaturan = $papan
@onready var papan_menang = $papan_menang
@onready var bintang_1 = $papan_menang/bintang1
@onready var bintang_2 = $papan_menang/bintang2
@onready var bintang_3 = $papan_menang/bintang3

# Referensi Node Game Over
@onready var papan_game_over = $papan_gameover
@onready var label_game_over = $papan_gameover/LabelGameOver
@onready var video_game_over = $papan_gameover/VideoGameOver

# Referensi Node UI Skor, Waktu, & Timer
@onready var label_score = $score/Label_score
@onready var label_score_menang = $papan_menang/LabelScoreMenang
@onready var label_waktu = $durasi/Label_waktu
@onready var timer_level = $Timer_level

var antrean_gambar: Array[Texture2D] = []
var indeks_antrean = 0
var total_kepingan_dipasang = 0
var target_kepingan = 4

var total_score: int = 0
var sisa_waktu: int = 0
var level: int = 1
var permainan_selesai: bool = false
var jumlah_percobaan_gagal: int = 0
var bintang_saat_ini: int = 0

func _ready():
	if color_rect_redup:
		color_rect_redup.visible = false
	if papan_pengaturan:
		papan_pengaturan.visible = false

	level = Global.level_pilihan
	if papan_pengaturan:
		papan_pengaturan.visible = false
	if papan_menang:
		papan_menang.visible = false
	if papan_game_over:
		papan_game_over.visible = false
		
	muat_level()

func muat_level():
	permainan_selesai = false
	
	indeks_antrean = 0
	total_kepingan_dipasang = 0
	
	bersihkan_papan()
	if level == 1:
		sisa_waktu = 15  
		if node_gambar_transparan: node_gambar_transparan.texture = hint_level_1
		antrean_gambar = kepingan_level_1
		target_kepingan = 4
		if node_level_1: node_level_1.visible = true
		if node_level_2: node_level_2.visible = false
		if node_level_3: node_level_3.visible = false
	elif level == 2:
		sisa_waktu = 30 
		if node_gambar_transparan: node_gambar_transparan.texture = hint_level_2
		antrean_gambar = kepingan_level_2
		target_kepingan = 9
		if node_level_1: node_level_1.visible = false
		if node_level_2: node_level_2.visible = true
		if node_level_3: node_level_3.visible = false
	elif level == 3:
		sisa_waktu = 60 
		if node_gambar_transparan: node_gambar_transparan.texture = hint_level_3
		antrean_gambar = kepingan_level_3
		target_kepingan = 16
		if node_level_1: node_level_1.visible = false
		if node_level_2: node_level_2.visible = false
		if node_level_3: node_level_3.visible = true
		
	update_ui_score()
	update_ui_waktu()
	if timer_level:
		timer_level.start()
		
	keping_kiri.texture = null
	keping_kanan.texture = null
	isi_slot_bawah()
	
func _process(delta):
	update_ui_waktu()
	update_ui_score()

func isi_slot_bawah():
	if keping_kiri.texture == null and indeks_antrean < antrean_gambar.size():
		keping_kiri.texture = antrean_gambar[indeks_antrean]
		indeks_antrean += 1
		
	if keping_kanan.texture == null and indeks_antrean < antrean_gambar.size():
		keping_kanan.texture = antrean_gambar[indeks_antrean]
		indeks_antrean += 1

# --- UBAH FUNGSI kepingan_berhasil_dipasang() MENJADI SEPERTI INI ---

func kepingan_berhasil_dipasang():
	total_score += 50
	update_ui_score()
	
	total_kepingan_dipasang += 1
	isi_slot_bawah()
	
	# Jika SEMUA kepingan sudah ditempatkan di papan
	if total_kepingan_dipasang >= target_kepingan:
		if timer_level:
			timer_level.stop() # Hentikan waktu
		
		# Jalankan fungsi pengecekan kebenaran posisi kepingan
		cek_hasil_puzzle()


# --- FUNGSI BARU UNTUK CEK KUNCI JAWABAN ---

func cek_hasil_puzzle():
	var jumlah_salah: int = 0
	var node_papan_aktif = get_node_papan_aktif()
	
	if node_papan_aktif:
		for slot in node_papan_aktif.get_children():
			if slot.has_method("apakah_kepingan_benar"):
				if not slot.apakah_kepingan_benar():
					jumlah_salah += 1 # Hitung berapa kepingan yang salah slot
					
	# --- SISTEM PENILAIAN BINTANG ---
	if jumlah_salah == 0:
		bintang_saat_ini = 3
	elif jumlah_salah == 1:
		bintang_saat_ini = 2
	else:
		bintang_saat_ini = 1 # Salah 2, 3, 4 dst dapat 1 bintang
		
	# --- SISTEM GAME OVER (3 KALI SALAH) ---
	if jumlah_salah > 0:
		jumlah_percobaan_gagal += 1
		
		# Jika sudah 3 kali percobaan dan masih salah, langsung Game Over
		if jumlah_percobaan_gagal >= 3:
			if timer_level:
				timer_level.stop()
			game_over()
			return # Hentikan fungsi di sini, jangan munculkan papan menang
			
	# Jika benar semua ATAU masih ada kesempatan percobaan
	if timer_level:
		timer_level.stop()
	munculkan_papan_menang()


# --- FUNGSI BANTUAN UNTUK MENDAPATKAN PAPAN LEVEL YANG AKTIF ---
func bersihkan_papan():
	var node_papan_aktif = get_node_papan_aktif()
	if node_papan_aktif:
		# Cari semua kotak slot di dalam papan aktif dan kosongkan gambarnya
		for slot in node_papan_aktif.get_children():
			slot.texture = null
			
func get_node_papan_aktif() -> Node:
	if level == 1:
		return node_level_1
	elif level == 2:
		return node_level_2
	elif level == 3:
		return node_level_3
	return null

# --- LOGIKA UI & TIMER ---

func update_ui_score():
	if label_score:
		label_score.text = "SCORE " + str(total_score)

func update_ui_waktu():
	if label_waktu:
		var menit = sisa_waktu / 60
		var detik = sisa_waktu % 60
		label_waktu.text = str(menit) + ":" + str(detik).pad_zeros(2)

func _on_timer_level_timeout():
	if permainan_selesai == true:
		if timer_level:
			timer_level.stop()
		return 
		
	if sisa_waktu > 0:
		sisa_waktu -= 1
		update_ui_waktu()
	else:
		game_over()

# --- LOGIKA GAME OVER & ANIMASI ---

func game_over():
	if not papan_game_over: return
	
	papan_game_over.visible = true
	
	# Putar video animasi
	if video_game_over:
		video_game_over.play()
	
	# Transisi Teks Game Over Meredup ke Jelas (Fade In)
	if label_game_over:
		label_game_over.modulate.a = 0.0 # Bikin teks transparan total dulu
		var tween = create_tween()
		tween.tween_property(label_game_over, "modulate:a", 1.0, 1.5) # Transisi ke terlihat dalam 1.5 detik

func _on_btn_ayo_main_lagi_pressed() -> void:
	if video_game_over:
		video_game_over.stop()
	papan_game_over.visible = false
	
	total_score = 0
	jumlah_percobaan_gagal = 0
	muat_level() # Ulangi level yang sedang dimainkan

# --- PAPAN MENANG ---

func munculkan_papan_menang():
	permainan_selesai = true
	if not papan_menang: return
	papan_menang.visible = true
	
	if timer_level:
		timer_level.stop()
	# Simpan rekor bintang ke memori Global jika lebih baik dari sebelumnya
	if bintang_saat_ini > Global.bintang_level[level]:
		Global.bintang_level[level] = bintang_saat_ini
		
	# Buka kunci level berikutnya
	if level == Global.level_terbuka and level < 3:
		Global.level_terbuka += 1
		
	if label_score_menang:
		label_score_menang.text = "0"
		var tween_skor = create_tween()
		tween_skor.tween_method(update_animasi_skor, 0, total_score, 1.5)
		
	# --- ANIMASI BINTANG DINAMIS ---
	bintang_1.texture = tex_bintang_kosong
	bintang_2.texture = tex_bintang_kosong
	bintang_3.texture = tex_bintang_kosong
	
	# Bintang menyala satu per satu SESUAI jumlah yang didapat
	if bintang_saat_ini >= 1:
		await get_tree().create_timer(0.5).timeout
		bintang_1.texture = tex_bintang_kuning
	if bintang_saat_ini >= 2:
		await get_tree().create_timer(0.5).timeout
		bintang_2.texture = tex_bintang_kuning
	if bintang_saat_ini >= 3:
		await get_tree().create_timer(0.5).timeout
		bintang_3.texture = tex_bintang_kuning

func update_animasi_skor(nilai: int):
	if label_score_menang:
		label_score_menang.text = str(nilai)
		
func _on_btn_next_pressed() -> void:
	# Sekarang, tombol Lanjut akan mengembalikan pemain ke menu pilihan level
	jumlah_percobaan_gagal = 0
	get_tree().change_scene_to_file("res://halaman_level/Halaman_Menu_Level.tscn")

func _on_btn_back_pressed() -> void:
	get_tree().change_scene_to_file("res://halaman_level/Halaman_Menu_Level.tscn")

# --- TOMBOL PENGATURAN ---

func _on_pengaturan_pressed() -> void:
	if papan_pengaturan:
		papan_pengaturan.visible = true
	if color_rect_redup:
		color_rect_redup.visible = true

func _on_btn_close_pressed() -> void:
	if papan_pengaturan:
		papan_pengaturan.visible = false
	if color_rect_redup:
		color_rect_redup.visible = false

func _on_musik_toggled(toggled_on: bool) -> void:
	pass

func _on_sound_toggled(toggled_on: bool) -> void:
	pass


func _on_replay_pressed() -> void:
	# 1. Sembunyikan papan pengaturan dan layar redupnya
	if papan_pengaturan:
		papan_pengaturan.visible = false
	if color_rect_redup:
		color_rect_redup.visible = false
		
	# 2. Reset skor dan jatah percobaan gagal ke angka 0
	total_score = 0
	jumlah_percobaan_gagal = 0
	
	# 3. Muat ulang permainan dari awal untuk level yang sedang aktif
	muat_level()
	

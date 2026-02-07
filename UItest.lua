<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Wind UI - Felux</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', system-ui, sans-serif;
        }
        
        body {
            background-color: #fef9e7; /* Kuning muda untuk kontras dengan transparansi */
            color: #333;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
            background-image: linear-gradient(45deg, rgba(255,255,224,0.8), rgba(255,255,204,0.8)), 
                              url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100" viewBox="0 0 100 100"><rect width="100" height="100" fill="%23fef9e7"/><path d="M0,0 L100,100 M100,0 L0,100" stroke="%23f0e68c" stroke-width="1"/></svg>');
        }
        
        .container {
            width: 100%;
            max-width: 900px;
            background-color: rgba(255, 255, 224, 0.85); /* Transparan kuning */
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
            overflow: hidden;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 215, 0, 0.2);
        }
        
        /* Header */
        .header {
            background: rgba(255, 215, 0, 0.9);
            padding: 24px 32px;
            text-align: center;
            border-bottom: 1px solid rgba(184, 134, 11, 0.3);
        }
        
        .header h1 {
            color: #333;
            font-weight: 700;
            font-size: 2.2rem;
            letter-spacing: 1px;
        }
        
        .header p {
            color: #555;
            margin-top: 8px;
            font-size: 1.1rem;
        }
        
        /* Tabs Navigation */
        .tabs {
            display: flex;
            background: rgba(255, 255, 240, 0.9);
            border-bottom: 1px solid rgba(255, 215, 0, 0.3);
        }
        
        .tab-button {
            padding: 18px 30px;
            background: none;
            border: none;
            font-size: 1.1rem;
            font-weight: 600;
            color: #666;
            cursor: pointer;
            transition: all 0.3s ease;
            position: relative;
        }
        
        .tab-button:hover {
            background: rgba(255, 255, 255, 0.7);
            color: #333;
        }
        
        .tab-button.active {
            color: #333;
            background: rgba(255, 255, 255, 0.95);
        }
        
        .tab-button.active::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            width: 100%;
            height: 3px;
            background: linear-gradient(90deg, #ffd700, #ffa500);
        }
        
        /* Tab Content */
        .tab-content {
            padding: 32px;
            min-height: 450px;
        }
        
        .tab-pane {
            display: none;
        }
        
        .tab-pane.active {
            display: block;
            animation: fadeIn 0.5s ease;
        }
        
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        /* Tab Content Styling */
        .tab-pane h2 {
            color: #333;
            margin-bottom: 20px;
            padding-bottom: 12px;
            border-bottom: 2px solid rgba(255, 215, 0, 0.4);
        }
        
        .tab-pane p {
            line-height: 1.6;
            margin-bottom: 20px;
            color: #444;
        }
        
        /* Tombol Fungsi */
        .function-buttons {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 18px;
            margin-top: 30px;
        }
        
        .function-button {
            padding: 16px 20px;
            background: rgba(255, 255, 255, 0.9);
            border: 1px solid rgba(255, 215, 0, 0.5);
            border-radius: 10px;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            text-align: center;
            color: #333;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.05);
        }
        
        .function-button:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1);
            background: rgba(255, 255, 255, 1);
            border-color: #ffd700;
        }
        
        .function-button i {
            font-size: 2rem;
            margin-bottom: 12px;
            color: #daa520;
        }
        
        .function-button span {
            font-weight: 600;
            font-size: 1.1rem;
        }
        
        .function-button p {
            font-size: 0.9rem;
            margin-top: 8px;
            color: #666;
        }
        
        /* Output Area */
        .output-area {
            background: rgba(255, 255, 255, 0.9);
            border-radius: 10px;
            padding: 20px;
            margin-top: 30px;
            border: 1px solid rgba(255, 215, 0, 0.3);
            min-height: 120px;
        }
        
        .output-area h3 {
            color: #333;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .output-area h3 i {
            color: #daa520;
        }
        
        #outputText {
            color: #444;
            line-height: 1.5;
        }
        
        /* Footer */
        .footer {
            text-align: center;
            padding: 20px;
            background: rgba(255, 255, 240, 0.9);
            border-top: 1px solid rgba(255, 215, 0, 0.3);
            color: #666;
            font-size: 0.95rem;
        }
        
        /* Responsiveness */
        @media (max-width: 768px) {
            .tabs {
                flex-wrap: wrap;
            }
            
            .tab-button {
                flex: 1;
                min-width: 120px;
                padding: 15px 10px;
                font-size: 1rem;
            }
            
            .function-buttons {
                grid-template-columns: repeat(2, 1fr);
            }
            
            .tab-content {
                padding: 20px;
            }
        }
        
        @media (max-width: 480px) {
            .function-buttons {
                grid-template-columns: 1fr;
            }
            
            .header h1 {
                font-size: 1.8rem;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1><i class="fas fa-wind"></i> Wind UI - Felux</h1>
            <p>Antarmuka dengan tab Felux dan tombol fungsi lengkap</p>
        </div>
        
        <div class="tabs">
            <button class="tab-button active" data-tab="felux1">Felux Utama</button>
            <button class="tab-button" data-tab="felux2">Felux Data</button>
            <button class="tab-button" data-tab="felux3">Felux Pengaturan</button>
            <button class="tab-button" data-tab="felux4">Felux Bantuan</button>
        </div>
        
        <div class="tab-content">
            <!-- Tab 1: Felux Utama -->
            <div id="felux1" class="tab-pane active">
                <h2>Felux Utama</h2>
                <p>Ini adalah tab utama Felux. Semua fungsi utama dapat diakses melalui tombol di bawah ini. Setiap tombol memiliki fungsi yang berbeda dan akan menampilkan output di area bawah.</p>
                
                <div class="function-buttons">
                    <div class="function-button" onclick="runFunction('loadData')">
                        <i class="fas fa-database"></i>
                        <span>Muat Data</span>
                        <p>Memuat data dari sumber eksternal</p>
                    </div>
                    
                    <div class="function-button" onclick="runFunction('processData')">
                        <i class="fas fa-cogs"></i>
                        <span>Proses Data</span>
                        <p>Memproses data yang telah dimuat</p>
                    </div>
                    
                    <div class="function-button" onclick="runFunction('exportReport')">
                        <i class="fas fa-file-export"></i>
                        <span>Ekspor Laporan</span>
                        <p>Membuat laporan dalam format PDF</p>
                    </div>
                    
                    <div class="function-button" onclick="runFunction('sendNotification')">
                        <i class="fas fa-bell"></i>
                        <span>Kirim Notifikasi</span>
                        <p>Mengirim notifikasi ke pengguna</p>
                    </div>
                </div>
            </div>
            
            <!-- Tab 2: Felux Data -->
            <div id="felux2" class="tab-pane">
                <h2>Felux Data</h2>
                <p>Kelola data Anda di tab ini. Anda dapat menambah, mengedit, menghapus, atau melihat statistik data yang tersimpan.</p>
                
                <div class="function-buttons">
                    <div class="function-button" onclick="runFunction('addData')">
                        <i class="fas fa-plus-circle"></i>
                        <span>Tambah Data</span>
                        <p>Menambah data baru ke sistem</p>
                    </div>
                    
                    <div class="function-button" onclick="runFunction('editData')">
                        <i class="fas fa-edit"></i>
                        <span>Edit Data</span>
                        <p>Mengubah data yang sudah ada</p>
                    </div>
                    
                    <div class="function-button" onclick="runFunction('deleteData')">
                        <i class="fas fa-trash-alt"></i>
                        <span>Hapus Data</span>
                        <p>Menghapus data dari sistem</p>
                    </div>
                    
                    <div class="function-button" onclick="runFunction('viewStats')">
                        <i class="fas fa-chart-bar"></i>
                        <span>Lihat Statistik</span>
                        <p>Menampilkan statistik data</p>
                    </div>
                </div>
            </div>
            
            <!-- Tab 3: Felux Pengaturan -->
            <div id="felux3" class="tab-pane">
                <h2>Felux Pengaturan</h2>
                <p>Atur preferensi dan konfigurasi aplikasi Anda di sini. Semua pengaturan akan disimpan secara otomatis.</p>
                
                <div class="function-buttons">
                    <div class="function-button" onclick="runFunction('userSettings')">
                        <i class="fas fa-user-cog"></i>
                        <span>Pengguna</span>
                        <p>Pengaturan profil pengguna</p>
                    </div>
                    
                    <div class="function-button" onclick="runFunction('systemSettings')">
                        <i class="fas fa-sliders-h"></i>
                        <span>Sistem</span>
                        <p>Konfigurasi sistem aplikasi</p>
                    </div>
                    
                    <div class="function-button" onclick="runFunction('privacySettings')">
                        <i class="fas fa-shield-alt"></i>
                        <span>Privasi</span>
                        <p>Pengaturan keamanan dan privasi</p>
                    </div>
                    
                    <div class="function-button" onclick="runFunction('backupData')">
                        <i class="fas fa-save"></i>
                        <span>Cadangkan Data</span>
                        <p>Membuat cadangan data sistem</p>
                    </div>
                </div>
            </div>
            
            <!-- Tab 4: Felux Bantuan -->
            <div id="felux4" class="tab-pane">
                <h2>Felux Bantuan</h2>
                <p>Temukan bantuan dan informasi tentang aplikasi Felux. Pelajari cara menggunakan fitur-fitur yang tersedia.</p>
                
                <div class="function-buttons">
                    <div class="function-button" onclick="runFunction('showGuide')">
                        <i class="fas fa-book"></i>
                        <span>Panduan</span>
                        <p>Panduan penggunaan aplikasi</p>
                    </div>
                    
                    <div class="function-button" onclick="runFunction('contactSupport')">
                        <i class="fas fa-headset"></i>
                        <span>Dukungan</span>
                        <p>Hubungi tim dukungan kami</p>
                    </div>
                    
                    <div class="function-button" onclick="runFunction('checkUpdates')">
                        <i class="fas fa-sync-alt"></i>
                        <span>Perbarui</span>
                        <p>Periksa pembaruan aplikasi</p>
                    </div>
                    
                    <div class="function-button" onclick="runFunction('aboutFelux')">
                        <i class="fas fa-info-circle"></i>
                        <span>Tentang</span>
                        <p>Informasi tentang aplikasi Felux</p>
                    </div>
                </div>
            </div>
            
            <!-- Output Area -->
            <div class="output-area">
                <h3><i class="fas fa-terminal"></i> Output Fungsi</h3>
                <div id="outputText">Silakan klik salah satu tombol fungsi di atas untuk melihat output di sini.</div>
            </div>
        </div>
        
        <div class="footer">
            <p>Wind UI dengan Tab Felux &copy; 2023 | Semua tombol fungsi berjalan dengan baik</p>
        </div>
    </div>

    <script>
        // Fungsi untuk mengelola tab
        document.querySelectorAll('.tab-button').forEach(button => {
            button.addEventListener('click', () => {
                // Hapus class active dari semua tab button
                document.querySelectorAll('.tab-button').forEach(btn => {
                    btn.classList.remove('active');
                });
                
                // Tambah class active ke tab button yang diklik
                button.classList.add('active');
                
                // Sembunyikan semua tab pane
                document.querySelectorAll('.tab-pane').forEach(pane => {
                    pane.classList.remove('active');
                });
                
                // Tampilkan tab pane yang sesuai
                const tabId = button.getAttribute('data-tab');
                document.getElementById(tabId).classList.add('active');
                
                // Update output
                updateOutput(`Beralih ke tab: ${button.textContent}`);
            });
        });
        
        // Fungsi untuk menjalankan aksi tombol
        function runFunction(functionName) {
            let outputMessage = "";
            let icon = "";
            
            switch(functionName) {
                case 'loadData':
                    outputMessage = "Data berhasil dimuat dari server. 1.245 records ditemukan.";
                    icon = "📊";
                    break;
                case 'processData':
                    outputMessage = "Data sedang diproses... Selesai dalam 3 detik.";
                    icon = "⚙️";
                    // Simulasi proses dengan timeout
                    setTimeout(() => {
                        updateOutput(`${icon} Proses data selesai! Data berhasil diolah.`);
                    }, 3000);
                    break;
                case 'exportReport':
                    outputMessage = "Laporan berhasil diekspor ke format PDF. File disimpan di folder 'Laporan'.";
                    icon = "📄";
                    break;
                case 'sendNotification':
                    outputMessage = "Notifikasi telah dikirim ke 5 pengguna terdaftar.";
                    icon = "🔔";
                    break;
                case 'addData':
                    outputMessage = "Form tambah data dibuka. Silakan isi informasi yang diperlukan.";
                    icon = "➕";
                    break;
                case 'editData':
                    outputMessage = "Pilih data yang ingin diedit dari daftar yang tersedia.";
                    icon = "✏️";
                    break;
                case 'deleteData':
                    outputMessage = "Peringatan: Anda akan menghapus data. Konfirmasi tindakan ini.";
                    icon = "🗑️";
                    break;
                case 'viewStats':
                    outputMessage = "Statistik data ditampilkan: 45% peningkatan dari bulan lalu.";
                    icon = "📈";
                    break;
                case 'userSettings':
                    outputMessage = "Pengaturan pengguna berhasil dibuka. Perubahan akan disimpan otomatis.";
                    icon = "👤";
                    break;
                case 'systemSettings':
                    outputMessage = "Konfigurasi sistem sedang dimuat. Hati-hati dengan perubahan penting.";
                    icon = "⚙️";
                    break;
                case 'privacySettings':
                    outputMessage = "Pengaturan privasi diperbarui. Semua data dienkripsi dengan aman.";
                    icon = "🔒";
                    break;
                case 'backupData':
                    outputMessage = "Proses backup data dimulai. Estimasi waktu: 2 menit.";
                    icon = "💾";
                    break;
                case 'showGuide':
                    outputMessage = "Panduan penggunaan Felux dibuka di tab baru.";
                    icon = "📖";
                    break;
                case 'contactSupport':
                    outputMessage = "Membuka formulir kontak dukungan. Tim kami akan membalas dalam 24 jam.";
                    icon = "📞";
                    break;
                case 'checkUpdates':
                    outputMessage = "Memeriksa pembaruan... Felux sudah menggunakan versi terbaru.";
                    icon = "🔄";
                    break;
                case 'aboutFelux':
                    outputMessage = "Felux v2.1.0 - Aplikasi manajemen data dengan antarmuka Wind UI.";
                    icon = "ℹ️";
                    break;
                default:
                    outputMessage = "Fungsi dijalankan. Aksi berhasil diproses.";
                    icon = "✅";
            }
            
            if (functionName !== 'processData') {
                updateOutput(`${icon} ${outputMessage}`);
            } else {
                updateOutput(`${icon} ${outputMessage}`);
            }
            
            // Tambah efek visual pada tombol yang diklik
            const clickedButton = event.currentTarget;
            clickedButton.style.transform = "scale(0.95)";
            clickedButton.style.backgroundColor = "rgba(255, 215, 0, 0.2)";
            
            setTimeout(() => {
                clickedButton.style.transform = "";
                clickedButton.style.backgroundColor = "";
            }, 300);
        }
        
        // Fungsi untuk memperbarui output
        function updateOutput(message) {
            const outputElement = document.getElementById('outputText');
            outputElement.innerHTML = message;
            
            // Tambah efek transisi
            outputElement.style.opacity = "0.7";
            setTimeout(() => {
                outputElement.style.opacity = "1";
            }, 150);
        }
        
        // Inisialisasi dengan output default
        updateOutput("Selamat datang di Wind UI Felux! Silakan klik tombol fungsi di atas untuk mulai menggunakan.");
    </script>
</body>
</html>

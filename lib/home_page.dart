import 'package:flutter/material.dart';
import 'post_list_page.dart';
import 'login_page.dart';
import 'database_helper.dart';

//widget utama homepage
class HomePage extends StatefulWidget {
  final String currentUserId;
  final String userRole;
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  HomePage({
    required this.currentUserId,
    required this.userRole,
    required this.isDarkMode,
    required this.toggleTheme,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

//state buat homepage
class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> categories = [];
  
  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final dbHelper = DatabaseHelper();
    final loadedCategories = await dbHelper.getAllCategories();
    setState(() {
      categories = loadedCategories;
    });
  }

  // Tambahkan method untuk menambah kategori
  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    final colors = [
      {'name': 'Biru', 'value': 'blue'},
      {'name': 'Merah', 'value': 'red'},
      {'name': 'Hijau', 'value': 'green'},
      {'name': 'Ungu', 'value': 'purple'},
      {'name': 'Oranye', 'value': 'orange'},
      {'name': 'Pink', 'value': 'pink'},
    ];
    
    final icons = [
      {'name': 'Buku', 'value': 'menu_book'},
      {'name': 'Kalkulator', 'value': 'calculate'},
      {'name': 'Sains', 'value': 'science'},
      {'name': 'Bahasa', 'value': 'translate'},
      {'name': 'Sejarah', 'value': 'history_edu'},
      {'name': 'Seni', 'value': 'palette'},
      {'name': 'Musik', 'value': 'music_note'},
      {'name': 'Olahraga', 'value': 'sports'},
      {'name': 'Komputer', 'value': 'computer'},
      {'name': 'Geografi', 'value': 'public'},
      {'name': 'Umum', 'value': 'school'},
    ];
    
    String selectedColor = 'blue';
    String selectedIcon = 'menu_book';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Tambah Kategori'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Kategori',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedColor,
                  decoration: InputDecoration(
                    labelText: 'Warna',
                    border: OutlineInputBorder(),
                  ),
                  items: colors.map((color) {
                    return DropdownMenuItem(
                      value: color['value'],
                      child: Text(color['name']!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedColor = value!;
                    });
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedIcon,
                  decoration: InputDecoration(
                    labelText: 'Icon',
                    border: OutlineInputBorder(),
                  ),
                  items: icons.map((icon) {
                    return DropdownMenuItem(
                      value: icon['value'],
                      child: Row(
                        children: [
                          Icon(_getIconData(icon['value']!)),
                          SizedBox(width: 8),
                          Text(icon['name']!),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedIcon = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  final dbHelper = DatabaseHelper();
                  await dbHelper.addCategory(
                    nameController.text, 
                    selectedColor,
                    selectedIcon,
                  );
                  Navigator.pop(context);
                  _loadCategories();
                }
              },
              child: Text('Tambah'),
            ),
          ],
        ),
      ),
    );
  }

  //pindah ke halaman kategori
  void _navigateToCategory(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostListPage(
          category: category,
          currentUserId: widget.currentUserId,
          userRole: widget.userRole,
          isDarkMode: widget.isDarkMode,
          toggleTheme: widget.toggleTheme,
        ),
      ),
    );
  }

  //fungsi logout
  void _logout() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.logoutUser(widget.currentUserId);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(
          toggleTheme: widget.toggleTheme,
          isDarkMode: widget.isDarkMode,
        ),
      ),
    );
  }

  //ganti tema gelap/terang
  void _toggleTheme() {
    widget.toggleTheme();
    setState(() {});
  }

  //nampilin dialog kelola user
  void _showUserManagement() {
    showDialog(
      context: context,
      builder: (context) => UserManagementDialog(),
    );
  }

  // Tambahkan method untuk handle back button
  Future<bool> _onWillPop() async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi'),
        content: Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Tidak'),
          ),
          TextButton(
            onPressed: () async {
              // Logout dan kembali ke halaman login
              final dbHelper = DatabaseHelper();
              await dbHelper.logoutUser(widget.currentUserId);
              Navigator.of(context).pop(true);
            },
            child: Text('Ya'),
          ),
        ],
      ),
    );
    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return WillPopScope( // Tambahkan WillPopScope
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
        //bikin app bar
        appBar: AppBar(
          title: Text('Forum Pelajar'),
          backgroundColor: isDark ? Colors.grey[850] : Colors.blue,
          actions: [
            //tombol ganti tema
            IconButton(
              icon: Icon(isDark ? Icons.brightness_7 : Icons.brightness_2),
              onPressed: _toggleTheme,
              tooltip: isDark ? 'Mode Terang' : 'Mode Gelap',
            ),
            //tombol logout
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Keluar',
            ),
            //tombol kelola user khusus admin
            if (widget.userRole == 'server')
              IconButton(
                icon: Icon(Icons.manage_accounts),
                onPressed: _showUserManagement,
                tooltip: 'Kelola User',
              ),
          ],
        ),
        //isi halaman
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //kartu welcome
              Card(
                elevation: 4,
                color: isDark ? Colors.grey[850] : Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat Datang,',
                        style: TextStyle(
                          fontSize: 18,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        widget.currentUserId,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.blue[200] : Colors.blue,
                        ),
                      ),
                      //badge admin
                      if (widget.userRole == 'server')
                        Container(
                          margin: EdgeInsets.only(top: 8),
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red[400],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Server Admin',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              
              //judul kategori
              Text(
                'Kategori Mata Pelajaran',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              
              //grid kategori mapel
              GridView.builder(
                padding: EdgeInsets.all(16),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemCount: categories.length + (widget.userRole == 'server' ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == categories.length && widget.userRole == 'server') {
                    // Tombol tambah kategori untuk admin
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: InkWell(
                        onTap: _showAddCategoryDialog,
                        borderRadius: BorderRadius.circular(15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              size: 48,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tambah\nKategori',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final category = categories[index];
                  Color cardColor = _getCategoryColor(category['color']);
                  IconData categoryIcon = _getIconData(category['icon'] ?? 'school');

                  return _buildCategoryCard(
                    category['name'],
                    categoryIcon,
                    cardColor,
                    isDark,
                    isAdmin: widget.userRole == 'server',
                    onDelete: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Hapus Kategori'),
                          content: Text('Yakin ingin menghapus kategori ini? Semua post dalam kategori ini akan terhapus.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text('Hapus', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      
                      if (confirm == true) {
                        final dbHelper = DatabaseHelper();
                        await dbHelper.deleteCategory(category['name']);
                        _loadCategories();
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  //bikin kartu kategori
  Widget _buildCategoryCard(String category, IconData? icon, Color color, bool isDark, {bool isAdmin = false, VoidCallback? onDelete}) {
    final categoryIcon = icon ?? Icons.school; // Default icon jika null
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () => _navigateToCategory(category),
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [color.withOpacity(0.8), color.withOpacity(0.6)]
                      : [color, color.withOpacity(0.7)],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    categoryIcon,
                    size: 48,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8),
                  Text(
                    category,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 2,
                          color: Colors.black.withOpacity(0.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isAdmin && onDelete != null)
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.white),
                  onPressed: onDelete,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Tambahkan method untuk mendapatkan icon berdasarkan kategori
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'bahasa':
        return Icons.translate;
      case 'sains':
        return Icons.science;
      case 'matematika':
        return Icons.calculate;
      case 'lainnya':
        return Icons.menu_book;
      default:
        return Icons.school; // Icon default untuk kategori baru
    }
  }

  // Tambahkan method untuk mendapatkan warna kategori
  Color _getCategoryColor(String? colorName) {
    switch (colorName) {
      case 'red':
        return Colors.red[400]!;
      case 'green':
        return Colors.green[400]!;
      case 'blue':
        return Colors.blue[400]!;
      case 'purple':
        return Colors.purple[400]!;
      case 'orange':
        return Colors.orange[400]!;
      case 'pink':
        return Colors.pink[400]!;
      default:
        return Colors.blue[400]!;
    }
  }

  // Helper method untuk mendapatkan IconData dari string
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'menu_book':
        return Icons.menu_book;
      case 'calculate':
        return Icons.calculate;
      case 'science':
        return Icons.science;
      case 'translate':
        return Icons.translate;
      case 'history_edu':
        return Icons.history_edu;
      case 'palette':
        return Icons.palette;
      case 'music_note':
        return Icons.music_note;
      case 'sports':
        return Icons.sports;
      case 'computer':
        return Icons.computer;
      case 'public':
        return Icons.public;
      default:
        return Icons.school;
    }
  }
}

//widget dialog kelola user
class UserManagementDialog extends StatefulWidget {
  @override
  _UserManagementDialogState createState() => _UserManagementDialogState();
}

//state buat dialog kelola user
class _UserManagementDialogState extends State<UserManagementDialog> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> users = [];
  
  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  //ambil data user dari database
  Future<void> _loadUsers() async {
    final loadedUsers = await dbHelper.getAllUsers();
    setState(() {
      users = loadedUsers;
    });
  }

  //ganti badge user
  Future<void> _updateBadge(String username) async {
    final badges = [
      'Siswa',
      'Aktif',
      'Guru',
      null, //opsi hapus badge
    ];

    final selectedBadge = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pilih Badge untuk $username'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: badges.map((badge) => 
            ListTile(
              title: Text(badge ?? 'Hapus Badge'),
              onTap: () => Navigator.pop(context, badge),
            ),
          ).toList(),
        ),
      ),
    );

    if (selectedBadge != null) {
      await dbHelper.updateUserBadge(username, selectedBadge);
      _loadUsers(); //refresh list
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Badge berhasil diperbarui')),
      );
    }
  }

  //konfirmasi hapus user
  Future<void> _confirmDeleteUser(String username) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Hapus'),
        content: Text('Anda yakin ingin menghapus akun "$username"? Semua data terkait akun ini akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await dbHelper.deleteUser(username);
        _loadUsers(); //refresh list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Akun berhasil dihapus')),
        );
      } catch (e) {
        print('Error deleting user: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus akun')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AlertDialog(
      title: Text('Kelola User'),
      backgroundColor: isDark ? Colors.grey[850] : Colors.white,
      //konten dialog
      content: Container(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              title: Text(
                user['username'],
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              subtitle: Text(
                user['badge'] ?? 'Tidak ada badge',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //tombol edit badge
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _updateBadge(user['username']),
                    tooltip: 'Edit Badge',
                  ),
                  //tombol hapus akun
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDeleteUser(user['username']),
                    tooltip: 'Hapus Akun',
                  ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Tutup'),
        ),
      ],
    );
  }
}
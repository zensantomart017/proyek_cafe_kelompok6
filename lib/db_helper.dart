import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;

  // Getter untuk database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Inisialisasi database
  Future<Database> _initDatabase() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'items.db');

    // Membuka database dan membuat tabel jika belum ada
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _onCreate(db, version); // Membuat tabel dan menambah data awal
      },
    );
  }

  // Membuat tabel `items`
  Future<void> _onCreate(Database db, int version) async {
    await db.execute(''' 
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        image TEXT NOT NULL
      )
    ''');

    // Menambahkan data awal setelah tabel dibuat
    await _saveItemsToDatabase(db);
  }

  // Menyimpan data awal ke tabel `items`
  Future<void> _saveItemsToDatabase(Database db) async {
    final List<String> names = [
      'Latte', 'Expresso', 'Black Coffee', 'Cappuccino', 'Susu'
    ];
    final List<double> prices = [5.0, 4.0, 3.5, 6.0, 7.0];
    final List<String> images = [
      "images/Latte.png", "images/Expresso.png", "images/Black_Coffee.png", 
      "images/Cappuccino.png", "images/Susu.png"  
    ];

    // Menambahkan data baru setiap kali
    for (int i = 0; i < names.length; i++) {
      await db.insert(
        'items',
        {
          'name': names[i],
          'price': prices[i],
          'image': images[i], // Pastikan image sesuai dengan path yang benar
        },
        conflictAlgorithm: ConflictAlgorithm.replace, // Mengganti data yang sudah ada
      );
    }
    
    // Debugging log untuk memeriksa data di tabel
    final items = await db.query('items');
    print(items); // Log semua data untuk memastikan
  }

  // Fungsi untuk menambah item
  Future<int> insertItem(Map<String, dynamic> item) async {
    final db = await database;
    return await db.insert(
      'items',
      item,
      conflictAlgorithm: ConflictAlgorithm.replace, // Ganti item jika sudah ada
    );
  }

  // Fungsi untuk mengambil semua item dari database
  Future<List<Map<String, dynamic>>> getItems() async {
    final db = await database;
    return await db.query('items');
  }

  // Fungsi untuk mengupdate item berdasarkan id
  Future<int> updateItem(int id, Map<String, dynamic> newValues) async {
    final db = await database;
    return await db.update(
      'items',
      newValues,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Fungsi untuk menghapus item berdasarkan id
  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

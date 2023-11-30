import "package:flutter_sqlite/model/produto.dart";
import "package:flutter_sqlite/model/usuario.dart";
import "package:sqflite/sqflite.dart";
import "package:path/path.dart";
import 'package:http/http.dart' as http;
import 'dart:convert';

class DB {
  late Database _database;
  static late final DB _instance = DB._();

  DB._();

  static DB get instance => _instance;

  late List<String> inserts = [
    "INSERT INTO usuarios(id, nome, email, senha) VALUES(1,'Mariana', 'mariana@gmail.com', 'senha')",
    "INSERT INTO usuarios(id, nome, email, senha) VALUES(2,'Tais', 'tais@gmail.com','senha')",
    "INSERT INTO usuarios(id, nome, email, senha) VALUES(3,'Matheus', 'matheus@gmail.com','senha')",
    "INSERT INTO usuarios(id, nome, email, senha) VALUES(4,'Nathan', 'nathan@gmail.com','senha')",
    "INSERT INTO usuarios(id, nome, email, senha) VALUES(5,'Gabriel', 'gabriel@gmail.com','senha')",
    "INSERT INTO usuarios(id, nome, email, senha) VALUES(6,'Maria Clara', 'maria@gmail.com','senha')"
  ];

  Future<void> openDatabaseConnection() async {
    final String path = join(await getDatabasesPath(), 'database.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('DROP TABLE IF EXISTS usuarios');
        await db.execute('DROP TABLE IF EXISTS produtos');
        await db.execute(
          '''CREATE TABLE usuarios(
              id INTEGER PRIMARY KEY AUTOINCREMENT, 
              nome TEXT, 
              email TEXT, 
              senha TEXT
            )
          ''',
        );

        await db.execute('''
          CREATE TABLE produtos(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            title TEXT,
            price INTEGER,
            description TEXT
          )
      ''');
      },
    );

      print("Executando inserts...");
      for (int i = 0; i < inserts.length; i++) {
        String query = inserts[i];
        await _database.execute(query);
      }
    List<Usuario> users = await getAllUsuarios();
    print(users);
    getProductsFromApi();
  }

  Future<List<Usuario>> getAllUsuarios() async {
    final List<Map<String, dynamic>> maps = await _database.query('usuarios');
    return List.generate(maps.length, (i) {
      return Usuario(
          id: maps[i]['id'],
          nome: maps[i]['nome'],
          email: maps[i]["email"],
          senha: maps[i]['senha']);
    });
  }

  Future<List<Usuario>> getUserByEmailAndPassword(String email, String senha) async {
    String query = "SELECT * FROM usuarios WHERE email = ? AND senha = ?";
    final List<Map<String, dynamic>> maps = await _database.rawQuery(query, ['$email', '$senha']);
    if (maps.isNotEmpty) {
      return List.generate(maps.length, (i) {
        return Usuario(
            id: maps[i]['id'],
            nome: maps[i]['nome'],
            email: maps[i]["email"],
            senha: maps[i]['senha']);
      });
    }else{
      return [];
    }
  }

Future<void> getProductsFromApi() async {
  final response = await http.get(Uri.parse('https://fakestoreapi.com/products'));
  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    for (int i = 0; i < jsonResponse.length; i++) {
      String title = jsonResponse[i]['title'].toString();
      String description = jsonResponse[i]['description'].toString();
      double price = double.parse(jsonResponse[i]['price'].toString());
      
      String query =
          "INSERT INTO produtos(title, price, description) VALUES(?, ?, ?)";
      await _database.execute(query, [title, price.toInt(), description]);
    }
    print('Request successful, products updated.');
  } else {
    print('Request failed with status: ${response.statusCode}.');
  }
}

Future<List<Produto>> getProductByName(String title) async {
  String query = "SELECT * FROM produtos WHERE title LIKE ?";
  final List<Map<String, dynamic>> maps =
      await _database.rawQuery(query, ['%$title%']);

  if (maps.isEmpty) {
    return [];
  } else {
    return List.generate(maps.length, (i) {
      return Produto(
        id: maps[i]['id'],
        title: maps[i]['title'],
        price: maps[i]['price'],
        description: maps[i]['description'],
      );
    });
  }
}


Future<List<Produto>> getProdutcts() async {
  final List<Map<String, dynamic>> maps = await _database.query('produtos');
  return List.generate(maps.length, (i) {
    return Produto(
      id: maps[i]['id'],
      title: maps[i]['title'],
      price: maps[i]['price'],
      description: maps[i]['description'],
    );
  });
}

}
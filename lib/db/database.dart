import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

part 'database.g.dart';

class Words extends Table {
  TextColumn get strQuestion => text()();

  TextColumn get strAnswer => text()();

  BoolColumn get isMemorized => boolean().withDefault(const Constant(false))();

  @override
  // TODO: implement primaryKey
  Set<Column>? get primaryKey => {strQuestion};
}

@DriftDatabase(tables: [Words])
class MyDatabase extends _$MyDatabase {
  // we tell the database where to store the data with this constructor
  MyDatabase() : super(_openConnection());

  // you should bump this number whenever you change or add a table definition.
  // Migrations are covered later in the documentation.
  @override
  int get schemaVersion => 2;

  //統合処理
  @override
  MigrationStrategy get migration => MigrationStrategy(onCreate: (Migrator m) {
        return m.createAll();
      }, onUpgrade: (Migrator m, int from, int to) async {
        if (from == 1) {
          await m.addColumn(words, words.isMemorized);
        }
      });

  //Create
  Future addWord(Word word) => into(words).insert(word);

  //Read
  Future<List<Word>> get allWords => select(words).get();

  Future<List<Word>> get allWordsExcludedMemorized =>
      (select(words)..where((table) => table.isMemorized.equals(false))).get();

  //Update
  Future updateWord(Word word) => update(words).replace(word);

  //Delete
  Future deleteWord(Word word) => (delete(words)
        ..where((table) => table.strQuestion.equals(word.strQuestion)))
      .go();
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'words.db'));
    return NativeDatabase(file);
  });
}

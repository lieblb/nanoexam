import 'dart:async';

import 'package:aqueduct/aqueduct.dart';   

class Migration1 extends Migration { 
  @override
  Future upgrade() async {
   database.createTable(SchemaTable("_Exam", [
SchemaColumn("id", ManagedPropertyType.bigInteger, isPrimaryKey: true, autoincrement: true, isIndexed: false, isNullable: false, isUnique: false),
SchemaColumn("name", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),
SchemaColumn("qti", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),
SchemaColumn("createdAt", ManagedPropertyType.datetime, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),
SchemaColumn("maxAllowedPassCount", ManagedPropertyType.integer, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),
SchemaColumn("password", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),
SchemaColumn("maxAllowedTimePerPass", ManagedPropertyType.integer, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),
],
));

database.createTable(SchemaTable("_User", [
SchemaColumn("id", ManagedPropertyType.bigInteger, isPrimaryKey: true, autoincrement: true, isIndexed: false, isNullable: false, isUnique: false),
SchemaColumn("login", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: true, isNullable: false, isUnique: true),
SchemaColumn("fullName", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),
],
));

database.createTable(SchemaTable("_Pass", [
SchemaColumn("id", ManagedPropertyType.bigInteger, isPrimaryKey: true, autoincrement: true, isIndexed: false, isNullable: false, isUnique: false),
SchemaColumn("passIndex", ManagedPropertyType.integer, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),
SchemaColumn("startTime", ManagedPropertyType.datetime, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),
SchemaColumn("extraTime", ManagedPropertyType.integer, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),
SchemaColumn("finishTime", ManagedPropertyType.datetime, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false),
SchemaColumn.relationship("user", ManagedPropertyType.bigInteger, relatedTableName: "_User", relatedColumnName: "id", rule: DeleteRule.nullify, isNullable: true, isUnique: false),
SchemaColumn.relationship("exam", ManagedPropertyType.bigInteger, relatedTableName: "_Exam", relatedColumnName: "id", rule: DeleteRule.nullify, isNullable: true, isUnique: false),
],
uniqueColumnSetNames: ["exam","passIndex","user"],
));

database.createTable(SchemaTable("_Answer", [
SchemaColumn("id", ManagedPropertyType.bigInteger, isPrimaryKey: true, autoincrement: true, isIndexed: false, isNullable: false, isUnique: false),
SchemaColumn("questionId", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),
SchemaColumn("version", ManagedPropertyType.integer, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),
SchemaColumn("timestamp", ManagedPropertyType.datetime, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),
SchemaColumn("data", ManagedPropertyType.document, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),
SchemaColumn.relationship("pass", ManagedPropertyType.bigInteger, relatedTableName: "_Pass", relatedColumnName: "id", rule: DeleteRule.nullify, isNullable: true, isUnique: false),
],
uniqueColumnSetNames: ["pass","questionId","timestamp","version"],
));


  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    
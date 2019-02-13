import 'package:server/server.dart';

import "Pass.dart";

class Exam extends ManagedObject<_Exam> implements _Exam {
	@override
	void willInsert() {
		createdAt = DateTime.now().toUtc();
	}
}

class _Exam {
	@primaryKey
	int id;

	String name;

	String qti;

	DateTime createdAt;

	int maxAllowedPassCount; // 0 if infinite

	String password;

	int maxAllowedTimePerPass; // in seconds, 0 if infinite

	ManagedSet<Pass> passes;
}

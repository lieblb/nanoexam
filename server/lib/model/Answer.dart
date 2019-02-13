import 'package:server/server.dart';

import "Pass.dart";

class Answer extends ManagedObject<_Answer> implements _Answer {}

@Table.unique([#pass, #questionId, #version, #timestamp])
class _Answer {
	@primaryKey
	int id;

	@Relate(#answers)
	@Relate.deferred(DeleteRule.cascade)
	Pass pass;

	String questionId; // refers to unique question id from QTI

	int version; // 1-based

	DateTime timestamp; // creation time of this version

	Document data; // the actual responses
}

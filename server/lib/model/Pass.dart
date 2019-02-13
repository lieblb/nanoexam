import 'package:server/server.dart';

import "Answer.dart";
import "Exam.dart";
import "User.dart";

class Pass extends ManagedObject<_Pass> implements _Pass {}

@Table.unique([#user, #exam, #passIndex])
class _Pass {
	@primaryKey
	int id;

	@Relate(#passes)
	@Relate.deferred(DeleteRule.cascade)
	User user;

	@Relate(#passes)
	@Relate.deferred(DeleteRule.cascade)
	Exam exam;

	int passIndex; // 1-based

	DateTime startTime;
	int extraTime;

	@Column(nullable: true)
	DateTime finishTime;

	ManagedSet<Answer> answers;
}

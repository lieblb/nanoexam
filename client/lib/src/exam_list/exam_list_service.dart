import 'dart:async';
import 'dart:html';
import 'dart:convert';

import 'package:angular/core.dart';

import 'exam_spec.dart';

@Injectable()
class ExamListService {
  Future<List<ExamSpec>> getExamList() async {

		String json = await HttpRequest.getString("/api/v1/exams");
		List<ExamSpec> exams = <ExamSpec>[];
		for (final exam in jsonDecode(json)) {
			exams.add(ExamSpec(exam['id'] as int, exam['name']));
		}
		return exams;
  }
}

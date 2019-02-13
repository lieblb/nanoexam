import 'dart:async';
import 'dart:convert';

import 'package:aqueduct/aqueduct.dart';
import 'package:server/model/Exam.dart';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:qti/qti.dart' as qti;

class ExamController extends ResourceController {
	ExamController(this.context);

	final ManagedContext context;

	@Operation.post()
	Future<Response> createExam() async {
		final Map<String, dynamic> body = await request.body.decode();
		final bytes = base64.decode(body["data"] as String);
		final archive = ZipDecoder().decodeBytes(bytes);

		final exp = RegExp(r"__qti__[0-9]+\.xml");
		for (ArchiveFile file in archive) {
			if (file.isFile && exp.hasMatch(file.name)) {
				final xml = utf8.decode(file.content as List<int>);
				final ass = qti.parse(xml);

				final insertQuery = Query<Exam>(context)
					..values.qti = xml
					..values.password = ass.password
					..values.maxAllowedPassCount = ass.numberOfTries
					..values.maxAllowedTimePerPass = ass.processingTime
					..values.name = ass.title;

				final insertedExam = await insertQuery.insert();
				return Response.ok(insertedExam);
			}
		}

		return Response.badRequest();
	}

	@Operation.delete('id')
	Future<Response> deleteExamByID(@Bind.path('id') int id) async {
		final examQuery = Query<Exam>(context)
			..where((h) => h.id).equalTo(id);

		if (await examQuery.delete() == 1) {
			return Response.ok("OK");
		} else {
			return Response.notFound();
		}
	}

	@Operation.get()
  Future<Response> getAllExams() async {
		final examQuery = Query<Exam>(context)
			..returningProperties((exam) => [exam.id, exam.name]);
		final exams = await examQuery.fetch();
		return Response.ok(exams);
	}

  @Operation.get('id')
	Future<Response> getExamByID(@Bind.path('id') int id) async {
		final examQuery = Query<Exam>(context)
			..where((h) => h.id).equalTo(id);

		final exam = await examQuery.fetchOne();

		if (exam == null) {
			return Response.notFound();
		}
		return Response.ok(exam);
	}
}

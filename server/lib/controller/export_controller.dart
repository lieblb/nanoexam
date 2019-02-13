import 'dart:async';

import 'package:aqueduct/aqueduct.dart';
import 'package:qti/qti.dart' as qti;
import 'package:decimal/decimal.dart';

import '../model/Exam.dart';
import '../model/Pass.dart';
import 'answer_controller.dart';

class Score {
  Decimal reached;
  Decimal maximum;
}

class ExportController extends ResourceController {
  ExportController(this.context);

  final ManagedContext context;

  @Operation.get('passId')
  Future<Response> getScores(@Bind.path('passId') int passId) async {
    try {
      final passQuery = Query<Pass>(context)
        ..where((p) => p.id).equalTo(passId);
      final pass = await passQuery.fetchOne();

      final examQuery = Query<Exam>(context)
        ..where((e) => e.id).equalTo(pass.exam.id);
      final exam = await examQuery.fetchOne();

      final assessment = qti.parse(exam.qti);

      final answers = await AnswerController.fetchAnswers(context, passId);

      final Map<String, Responses> answersByQuestion = {};
      for (final a in answers) {
        answersByQuestion[a.questionId] = a;
      }

      final Map<String, Map<String, String>> scores = {};

      for (var i = 0; i < assessment.items.length; i++) {
        final Map<String, Decimal> reached = {};
        final Map<String, Decimal> maximum = {};

        final item = assessment.items[i];
        final questionId = item.ident;
        final itemResponses = answersByQuestion[questionId].responses;

        for (final p in item.processing) {
          bool previousWasTrue = false;

          for (final c in p.conditions) {
            if (previousWasTrue && !c.shouldContinue) {
              break;
            }

            final isConditionTrue = c.conditionVar.test(itemResponses);

            if (isConditionTrue) {
              c.setVar.execute(reached);
            }

            previousWasTrue = isConditionTrue;
          }

          // determine the maximum by applying all conditions. this
          // is only correct for a defined subset of ILIAS exports.
          for (final c in p.conditions) {
            c.setVar.execute(maximum);
          }
        }

        scores[questionId] = {
          'reached': reached['SCORE'].toString() ?? '0',
          'maximum': maximum['SCORE'].toString() ?? '0'
        };
      }

      return Response.ok(scores);
    } catch (e) {
      return Response.serverError();
    }
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:decimal/decimal.dart';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular/security.dart';

import '../answer_model/answer_model.dart';
import '../answer_model/response_path.dart';
import 'package:qti/qti.dart' as qti;

import '../exam_page/page.dart';

class Score {
  final Decimal reached;
  final Decimal maximum;

  Score(this.reached, this.maximum);

  static Score fromStrings(String reached, String maximum) {
    return Score(Decimal.parse(reached), Decimal.parse(maximum));
  }

  String get percentage {
    return ((reached * Decimal.fromInt(100)) / maximum).toStringAsPrecision(3) + '%';
  }

  static Score sum(Score a, Score b) {
    return Score(a.reached + b.reached, a.maximum + b.maximum);
  }
}

@Component(
  selector: 'exam-results',
  styleUrls: ['exam_results_component.css'],
  templateUrl: 'exam_results_component.html',
  directives: [
    NgFor,
    NgIf,
  ],
  providers: const <dynamic>[materialProviders],
)
class ExamResultsComponent implements OnInit {
  @Input()
  int passId;

  @Input()
  List<Page> pages;

  Map<String, Score> scores = {};
  Score totalScore;

  final client = BrowserClient();

  @override
  Future<Null> ngOnInit() async {
    final r = await client.get("/api/v1/export/${passId}");
    if (r.statusCode != 200) {
      throw HttpException("could not retrieve scores ${r.statusCode}");
    }
    print(r.body);
    final jsonScores = jsonDecode(r.body) as Map;

    for (final k in jsonScores.keys) {
      final Map v = jsonScores[k];
      scores[k] = Score.fromStrings(v['reached'], v['maximum']);
    }

    totalScore = Score(Decimal.fromInt(0), Decimal.fromInt(0));
    for (final v in scores.values) {
      totalScore = Score.sum(totalScore, v);
    }
  }

  String reachedScoreForQuestion(String ident) {
    return scores[ident]?.reached.toString() ?? '0';
  }

  String maximumScoreForQuestion(String ident) {
    return scores[ident]?.maximum.toString() ?? '0';
  }

  String questionScoreAsPercentage(String ident) {
    return scores[ident]?.percentage ?? '';
  }

  Iterable<qti.Item> get items sync* {
    for (final page in pages) {
      for (final item in page.items) {
        yield item;
      }
    }
  }
}

import 'dart:async';

import 'package:angular/angular.dart';
import 'package:qti/qti.dart' as qti;

import 'page.dart';
import '../answer_model/answer_model.dart';

import '../single_choice_question/single_choice_question_component.dart';

@Component(
  selector: 'exam-page',
  styleUrls: ['exam_page_component.css'],
  templateUrl: 'exam_page_component.html',
  directives: [
    SingleChoiceQuestionComponent,

    NgFor,
    NgIf,
  ],
)
class ExamPageComponent implements OnInit {
  @Input()
  Page page;

  @Input()
  AnswerModel answerModel;

  @override
  Future<Null> ngOnInit() async {
  }

  qti.QuestionType get SingleChoice {
     return qti.QuestionType.SingleChoice;
  }
}

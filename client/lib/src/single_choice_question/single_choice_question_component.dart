import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular/security.dart';

import "../answer_model/answer_model.dart";
import "../answer_model/response_path.dart";
import 'package:qti/qti.dart' as qti;

@Component(
	selector: 'single-choice-question',
	styleUrls: ['single_choice_question_component.css'],
	templateUrl: 'single_choice_question_component.html',
	directives: [
		MaterialRadioComponent,
		MaterialRadioGroupComponent,
		materialInputDirectives,
		NgModel,
		NgFor,
		NgIf,
		SafeInnerHtmlDirective,
	],
)
class SingleChoiceQuestionComponent implements OnInit {
	String questionId;
	String title = "";
	SafeHtml stem = null;
	final DomSanitizationService dss;
	Map<String, String> selected = {};

	@Input()
	qti.Item item = null;

	@Input()
	AnswerModel answerModel = null;

	SingleChoiceQuestionComponent(this.dss);

	String debug;

	void changeAnswer(String lidIdent, String labelIdent) {
		selected[lidIdent] = labelIdent;
		if (answerModel != null) {
			answerModel[ResponsePath(questionId, lidIdent)] = labelIdent;
			//debug = "stored ${responseLabelIdent}";
		}
	}

	@override
	Future<Null> ngOnInit() async {
		questionId = item.ident;

		for (final element in item.presentation.elements) {
			if (element.isResponseLid) {
				final id = ResponsePath(questionId, element.ident);
				if (answerModel.containsKey(id)) {
					selected[element.ident] = answerModel[id];
				}
			}
		}

		title = item.title;
	}
}

import 'package:tuple/tuple.dart';

class ResponsePath extends Tuple2<String, String> {
  ResponsePath(String questionId, String responseId) :
    super(questionId, responseId);

  String get questionId {
    return item1;
  }

  String get responseId {
    return item2;
  }
}

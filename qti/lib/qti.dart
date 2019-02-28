import 'package:xml/xml.dart' as xml;
import 'package:decimal/decimal.dart';

// see http://www.imsproject.org/question/qtiv1p2/imsqti_litev1p2.html

abstract class AbstractSetVar {
  void execute(Map<String, Decimal> vars);
}

class SetVar extends AbstractSetVar {
  final String varName;
  final Decimal value;

  SetVar(String varName, String value) :
    varName = varName, value = Decimal.parse(value);

  void execute(Map<String, Decimal> vars) {
    vars[varName] = value;
  }
}

class AddVar extends AbstractSetVar {
  final String varName;
  final Decimal value;

  AddVar(String varName, String value) :
      varName = varName, value = Decimal.parse(value);

  void execute(Map<String, Decimal> vars) {
    if (!vars.containsKey(varName)) {
      vars[varName] = value;
    } else {
      vars[varName] = vars[varName] + value;
    }
  }
}

class ResponseLabel {
  final String ident;
  final List<Material> materials;

  ResponseLabel(this.ident, this.materials);

  String toHtml() {
    return materials.map((m) => m.toHtml()).join('');
  }

  serialize() {
    return {
      'ident': ident,
      'materials': materials.map((x) => x.serialize()).toList()
    };
  }

  static ResponseLabel deserialize(x) {
    return ResponseLabel(x['ident'],
        x['materials'].map<Material>(
          (y) => Material.deserialize(y)).toList());
  }
}

class Presentable {
  String toHtml() {
    return '';
  }

  serialize() {
    return null;
  }

  static Presentable deserialize(x) {
    switch (x['type']) {
      case 'material':
        return Material.deserialize(x);
      case 'responseLid':
        return ResponseLid.deserialize(x);
    }
    throw Exception("cannot deserialize ${x}");
  }

  bool get isMaterial {
    return false;
  }

  bool get isResponseLid {
    return false;
  }

  String get ident {
    return '';
  }

  List<ResponseLabel> get labels {
    return [];
  }
}

class MaterialElement {
  String toHtml() {
    return '';
  }

  serialize() {
    return null;
  }

  static MaterialElement deserialize(x) {
    switch (x['type']) {
      case 'text':
        return MaterialText.deserialize(x);
      case 'image':
        return MaterialImage.deserialize(x);
    }
    throw Exception("cannot deserialize ${x}");
  }
}

class MaterialText extends MaterialElement {
  final String text;

  MaterialText(this.text);

  String toHtml() {
    return text;
  }

  serialize() {
    return {
      'type': 'text',
      'text': text
    };
  }

  static MaterialText deserialize(x) {
    assert(x['type'] == 'text');
    return MaterialText(x['text']);
  }
}

class MaterialImage extends MaterialElement {
  final String data;

  MaterialImage(this.data);

  serialize() {
    return {
      'type': 'image',
      'data': data
    };
  }

  static MaterialImage deserialize(x) {
    assert(x['type'] == 'image');
    return MaterialImage(x['data']);
  }
}

class Material extends Presentable {
  final List<MaterialElement> elements;

  Material(this.elements);

  String toHtml() {
    return elements.map((e) => e.toHtml()).join('');
  }

  serialize() {
    return {
      'type': 'material',
      'elements': elements.map((x) => x.serialize()).toList()
    };
  }

  static Material deserialize(x) {
    assert(x['type'] == 'material');
    return Material(x['elements'].map<MaterialElement>(
            (y) => MaterialElement.deserialize(y)).toList());
  }

  bool get isMaterial {
    return true;
  }
}

class ResponseLid extends Presentable {
  final String _ident;
  final List<ResponseLabel> _labels;
  bool shuffle = false;

  ResponseLid(this._ident, this._labels, [this.shuffle = false]);

  serialize() {
    return {
      'type': 'responseLid',
      'ident': ident,
      'shuffle': shuffle,
      'labels': labels.map((x) => x.serialize()).toList()
    };
  }

  static ResponseLid deserialize(x) {
    assert(x['type'] == 'responseLid');
    return ResponseLid(x['ident'],
        x['labels'].map<ResponseLabel>(
                (y) => ResponseLabel.deserialize(y)).toList(), x['shuffle']);
  }

  bool get isResponseLid {
    return true;
  }

  String get ident {
    return _ident;
  }

  List<ResponseLabel> get labels {
    return _labels;
  }
}

class Presentation {
  final String label;
  final List<Presentable> elements;

  Presentation(this.label, this.elements);

  serialize() {
    return {
      'label': label,
      'elements': elements.map((x) => x.serialize()).toList()
    };
  }

  static Presentation deserialize(x) {
    if (x == null) {
      return null;
    } else {
      return Presentation(x['label'],
          x['elements'].map<Presentable>(
                  (y) => Presentable.deserialize(y)).toList());
    }
  }
}

class ConditionVar {
  bool test(Map<String, String> vars) {
    return false;
  }
}

class AndCondition extends ConditionVar {
  final List<ConditionVar> conditions;

  AndCondition(this.conditions);

  bool test(Map<String, String> vars) {
    for (final c in conditions) {
      if (!c.test(vars)) {
        return false;
      }
    }
    return true;
  }
}

class NotCondition extends ConditionVar {
  final ConditionVar condition;

  NotCondition(this.condition);

  bool test(Map<String, String> vars) {
    return !condition.test(vars);
  }
}

class VarEqual extends ConditionVar {
  final String respIdent;
  final String value;

  VarEqual(this.respIdent, this.value);

  bool test(Map<String, String> vars) {
    return vars[respIdent] == value;
  }
}

class UnansweredCondition extends ConditionVar {
  final String respIdent;

  UnansweredCondition(this.respIdent);

  bool test(Map<String, String> vars) {
    return !vars.containsKey(respIdent);
  }
}

class ResponseCondition {
  final bool shouldContinue;
  final ConditionVar conditionVar;
  final AbstractSetVar setVar;

  ResponseCondition(this.shouldContinue, this.conditionVar, this.setVar);
}

class ResponseProcessing {
  final List<ResponseCondition> conditions;

  ResponseProcessing(this.conditions);
}

Map toStringMap(Map m) {
  return m.map((k, v) => MapEntry<String, String>(k.toString(), v.toString()));
}

enum QuestionType {
  SingleChoice
}

class Item {
  final String ident;
  final String title;
  final Map<String, String> metadata;
  final Presentation presentation;
  final List<ResponseProcessing> processing;

  Item(this.ident, this.title, this.metadata,
      this.presentation, this.processing);

  serialize() {
    return {
      'ident': ident,
      'title': title,
      'metadata': metadata,
      'presentation': presentation != null ? presentation.serialize() : null
    };
  }

  static Item deserialize(x) {
    return Item(x['ident'], x['title'], toStringMap(x['metadata']),
        Presentation.deserialize(x['presentation']), []);
  }

  QuestionType get questionType { // specific to ILIAS
    if (metadata == null) {
      return null;
    }
    switch (metadata['QUESTIONTYPE'] ?? '') {
      case 'SINGLE CHOICE QUESTION': {
        return QuestionType.SingleChoice;
      }
    }
    return null;
  }
}

class Assessment {
  final String ident;
  final String title;
  final Map<String, String> metadata;
  final List<Item> items;
  final Map<String, Item> _itemByIdent = {};

  Assessment(this.ident, this.title, this.metadata, this.items) {
    for (final item in items) {
      _itemByIdent[item.ident] = item;
    }
  }

  serialize() {
    return {
      'ident': ident,
      'title': title,
      'metadata': metadata,
      'items': items.map((i) => i.serialize()).toList()
    };
  }

  Item getItemByIdent(String ident) {
    return _itemByIdent[ident];
  }

  static Assessment deserialize(x) {
    return Assessment(x['ident'], x['title'], toStringMap(x['metadata']),
        x['items'].map<Item>((y) => Item.deserialize(y)).toList());
  }

  int get numberOfTries { // ILIAS specific
    if (metadata != null) {
      final s = metadata['metadata'] ?? '';
      if (!s.isEmpty) {
        return int.parse(s);
      }
    }
    return 0;
  }

  String get password { // ILIAS specific
    return metadata != null ? (metadata["password"] ?? '') : '';
  }

  int get processingTime { // ILIAS specific
    if (metadata == null) {
      return 0;
    }
    if (int.tryParse(metadata["enable_processing_time"]) == 1) {
      final re = RegExp(r"^(\d\d):(\d\d):(\d\d)$");
      final match = re.allMatches(metadata["processing_time"]);
      final h = int.parse(match.first.group(1));
      final m = int.parse(match.first.group(2));
      final s = int.parse(match.first.group(3));
      return h * 3600 + m * 60 + s;
    } else {
      return 0;
    }
  }
}

void parseChildren(xml.XmlElement node, Map func) {
  for (final child in node.children) {
    if (child.nodeType == xml.XmlNodeType.ELEMENT) {
      final c = child as xml.XmlElement;
      final k = c.name.toString();
      if (func.containsKey(k)) {
        func[k](c);
      }
    }
  }
}

bool parseBool(String s, bool def) {
  if (s == null) {
    return def;
  } else {
    return s == 'Yes';
  }
}

Material parseMaterial(xml.XmlElement node) {
  final material = Material([]);
  parseChildren(node, {
    'mattext': (xml.XmlElement node) {
      material.elements.add(MaterialText(node.text));
    },
    'matimage': (xml.XmlElement node) {
      material.elements.add(MaterialImage(node.text));
    }
  });
  return material;
}

ResponseLabel parseResponseLabel(xml.XmlElement node) {
  final List<Material> materials = [];
  parseChildren(node, {
    'material': (xml.XmlElement node) {
      materials.add(parseMaterial(node));
    }
  });
  return ResponseLabel(node.getAttribute('ident'), materials);
}

void parseRenderChoice(xml.XmlElement node,  lid) {
  lid.shuffle = parseBool(node.getAttribute('shuffle'), false);
  parseChildren(node, {
    'response_label': (xml.XmlElement node) {
      lid.labels.add(parseResponseLabel(node));
    }
  });
}

ResponseLid parseResponseLid(xml.XmlElement node) {
  ResponseLid lid = ResponseLid(node.getAttribute('ident'), []);
  parseChildren(node, {
    'material': (xml.XmlElement node) => null, // ignore
    'render_choice': (xml.XmlElement node) {
      parseRenderChoice(node, lid);
    }
  });
  return lid;
}

Presentation parsePresentation(xml.XmlElement node) {
  final label = node.getAttribute('label'); // optional
  final presentation = Presentation(label, []);

  var parse;
  parse = (xml.XmlElement node) {
    parseChildren(node, {
      'material': (xml.XmlElement node) {
        presentation.elements.add(parseMaterial(node));
      },
      'response_lid': (xml.XmlElement node) {
        presentation.elements.add(parseResponseLid(node));
      },
      'flow': parse // not in QTI lite
    });
  };

  parse(node);
  return presentation;
}

Map<String, String> parseMetadata(xml.XmlElement node) {
  Map<String, String> entries = {};
  for (final field in node.findAllElements("qtimetadatafield")) {
    String label = field.findElements('fieldlabel').first.text;
    String entry = field.findElements('fieldentry').first.text;
    entries[label] = entry;
  }
  return entries;
}

AbstractSetVar parseSetVar(xml.XmlElement node) {
  final varName = node.getAttribute('varname') ?? 'SCORE';
  switch (node.getAttribute('action') ?? 'Set') {
    case 'Set':
      return SetVar(varName, node.text);
    case 'Add':
      return AddVar(varName, node.text);
    default:
      throw Exception("illegal action ${node.getAttribute('action')}");
  }
}

ConditionVar parseConditionVar(xml.XmlElement node) {
  List<ConditionVar> conditions = [];
  parseChildren(node, {
    'not': (xml.XmlElement node) {
      conditions.add(NotCondition(parseConditionVar(node)));
    },
    'unanswered': (xml.XmlElement node) {
      conditions.add(UnansweredCondition(node.getAttribute('respident')));
     },
    'varequal': (xml.XmlElement node) {
      conditions.add(VarEqual(node.getAttribute('respident'), node.text));
    }
  });
  return AndCondition(conditions);
}

ResponseCondition parseResponseCondition(xml.XmlElement node) {
  final continue_ = parseBool(node.getAttribute('continue'), false);
  var condition;
  AbstractSetVar setVar;
  parseChildren(node, {
    'conditionvar': (xml.XmlElement node) {
      condition = parseConditionVar(node);
    },
    'setvar': (xml.XmlElement node) {
      setVar = parseSetVar(node);
    },
    'displayfeedback': (xml.XmlElement node) => null // ignore
  });
  return ResponseCondition(continue_, condition, setVar);
}

ResponseProcessing parseResponseProcessing(xml.XmlElement node) {
  List<ResponseCondition> conditions = [];
  parseChildren(node, {
    'outcomes': (xml.XmlElement node) => null, // ignore
    'respcondition':  (xml.XmlElement node) {
      conditions.add(parseResponseCondition(node));
    }
  });
  return ResponseProcessing(conditions);
}

zeroOrOnce(xml.XmlElement parent, String tagName, dynamic parse) {
  for (final presentation in parent.findAllElements(tagName)) {
    return parse(presentation);
  }
  return null;
}

Item parseItem(xml.XmlElement item) {
  final ident = item.getAttribute("ident");
  final title = item.getAttribute("title");

  final metadata = zeroOrOnce(
      item, 'itemmetadata', parseMetadata);

  final presentation = zeroOrOnce(
      item, 'presentation', parsePresentation);

  List<ResponseProcessing> processing = [];
  for (final resProcessing in item.findAllElements('resprocessing')) {
    processing.add(parseResponseProcessing(resProcessing));
  }

  return Item(ident, title, metadata, presentation, processing);
}

Assessment parse(String qti) {
  final document = xml.parse(qti);

  for (final assessment in document.findAllElements("assessment")) {
    final ident = assessment.getAttribute('ident');
    final title = assessment.getAttribute('title');

    final metadata = zeroOrOnce(
        assessment, 'qtimetadata', parseMetadata);
    final List<Item> items = [];

    for (final section in assessment.findAllElements("section")) {
      for (final item in section.findAllElements("item")) {
        items.add(parseItem(item));
      }
    }

    return Assessment(ident, title, metadata, items);
  }

  return null;
}

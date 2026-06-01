// مكتبة المتصفح — بدل dart:io
import 'dart:html';
import 'dart:js' as js;

// ─────────────────────────────────────────
// التوكن — زي قطعة ليغو
// ─────────────────────────────────────────
class Tocken {
  final String type;
  final String value;
  Tocken(this.type, this.value);
}

// ─────────────────────────────────────────
// بفصل الكلمات ويحافظ على الـ quotes
// ─────────────────────────────────────────
List<String> splitWords(String input) {
  List<String> words = [];
  String current = '';
  bool inQuote = false;

  for (int i = 0; i < input.length; i++) {
    if (input[i] == '"') {
      inQuote = !inQuote;
    } else if (input[i] == ' ' && !inQuote) {
      if (current.isNotEmpty) {
        words.add(current);
        current = '';
      }
    } else {
      current += input[i];
    }
  }
  if (current.isNotEmpty) words.add(current);
  return words;
}

// ─────────────────────────────────────────
// الـ Lexer
// ─────────────────────────────────────────
List<Tocken> lexer(String input) {
  List<Tocken> tockens = [];
  List<String> words = splitWords(input);

  for (var word in words) {
    if (word == "print") {
      tockens.add(Tocken("PRINT", word));
    } else if (int.tryParse(word) != null) {
      tockens.add(Tocken("NUMBER", word));
    } else if (double.tryParse(word) != null) {
      tockens.add(Tocken("DOUBLE", word));
    } else if (word == '+') {
      tockens.add(Tocken("PLUS", word));
    } else if (word == '-') {
      tockens.add(Tocken("MINUS", word));
    } else if (word == '*') {
      tockens.add(Tocken("MULTIPLY", word));
    } else if (word == '/') {
      tockens.add(Tocken("DIVIDE", word));
    } else if (word == "v") {
      tockens.add(Tocken("VARIABLE", word));
    } else if (word == "int") {
      tockens.add(Tocken("Type", word));
    } else if (word == "double") {
      tockens.add(Tocken("Type", word));
    } else if (word == "bool") {
      tockens.add(Tocken("Type", word));
    } else if (word == "string") {
      tockens.add(Tocken("Type", word));
    } else if (word == "=") {
      tockens.add(Tocken("ASSIGNMENT", word));
    } else if (word == "true" || word == "false") {
      tockens.add(Tocken("BOOL", word));
    } else if (word == "if") {
      tockens.add(Tocken("IF", word));
    } else if (word == "else") {
      tockens.add(Tocken("ELSE", word));
    } else if (word == ">" ||
        word == "<" ||
        word == "A=" ||
        word == "!=" ||
        word == "&&" ||
        word == "||" ||
        word == "!") {
      tockens.add(Tocken("COMPARISON", word));
    } else if (word == "{") {
      tockens.add(Tocken("OPEN_BRACE", word));
    } else if (word == "}") {
      tockens.add(Tocken("CLOSE_BRACE", word));
    } else if (word == "Loop") {
      tockens.add(Tocken("WHILE", word));
    } else if (word == "func") {
      tockens.add(Tocken("FUNC", word));
    } else if (word == "call") {
      tockens.add(Tocken("CALL", word));
    } else if (word == "n") {
      tockens.add(Tocken("REASSIGN", word));
    } else if (word == "r") {
      tockens.add(Tocken("Read", word));
    } else if (word.contains(' ')) {
      tockens.add(Tocken("QUOTED_STRING", word));
    } else {
      tockens.add(Tocken("STRING", word));
    }
  }

  return tockens;
}

// ─────────────────────────────────────────
// الذاكرة والـ functions
// ─────────────────────────────────────────
Map<String, dynamic> memory = {};
Map<String, List<String>> functions = {};

// ─────────────────────────────────────────
// بدل print() — بنكتب في الـ output buffer
// ─────────────────────────────────────────
StringBuffer _output = StringBuffer();

void outputLine(dynamic value) {
  _output.writeln(value.toString());
}

// ─────────────────────────────────────────
// الـ Interpreter
// ─────────────────────────────────────────
void interpret(List<Tocken> tokens) {
  if (tokens[0].type == "PRINT") {
    if (tokens.length == 2) {
      if (tokens[1].type == "QUOTED_STRING") {
        outputLine(tokens[1].value);
        return;
      }
      outputLine(
        memory.containsKey(tokens[1].value)
            ? memory[tokens[1].value]
            : tokens[1].value,
      );
      return;
    }

    int result = 0;
    String operation = 'PLUS';

    for (int i = 1; i < tokens.length; i += 2) {
      int number = tokens[i].type == "NUMBER"
          ? int.parse(tokens[i].value)
          : memory[tokens[i].value] ?? 0;

      if (operation == 'PLUS') result += number;
      if (operation == 'MINUS') result -= number;
      if (operation == 'MULTIPLY') result *= number;
      if (operation == 'DIVIDE') result ~/= number;

      if (i + 1 < tokens.length) operation = tokens[i + 1].type;
    }

    outputLine(result);
  }

  if (tokens[0].type == "VARIABLE") {
    String varType = tokens[1].value;
    String varName = tokens[2].value;
    String varValue = tokens[4].value;

    if (varType == "int") {
      memory[varName] = int.parse(varValue);
    } else if (varType == "double") {
      memory[varName] = double.parse(varValue);
    } else if (varType == "bool") {
      memory[varName] = varValue == "true";
    } else if (varType == "string") {
      memory[varName] = varValue;
    }
  }

  if (tokens[0].type == "REASSIGN") {
    String varName = tokens[2].value;
    int result = 0;
    String operation = 'PLUS';

    for (int i = 4; i < tokens.length; i += 2) {
      int number = tokens[i].type == "NUMBER"
          ? int.parse(tokens[i].value)
          : memory[tokens[i].value] ?? 0;

      if (operation == 'PLUS') result += number;
      if (operation == 'MINUS') result -= number;
      if (operation == 'MULTIPLY') result *= number;
      if (operation == 'DIVIDE') result ~/= number;

      if (i + 1 < tokens.length) operation = tokens[i + 1].type;
    }

    memory[varName] = result;
  }

  // r x — بيطلب input من المستخدم عن طريق popup في المتصفح
  if (tokens[0].type == "Read") {
    String varName = tokens[1].value;
    var existingValue = memory[varName];

    // js.context.callMethod('prompt') بيفتح popup صغيرة في المتصفح
    var result = js.context.callMethod('prompt', ['Enter value for $varName:']);
    String input = result?.toString() ?? '';

    if (existingValue is int) {
      memory[varName] = int.tryParse(input) ?? 0;
    } else if (existingValue is double) {
      memory[varName] = double.tryParse(input) ?? 0;
    } else if (existingValue is bool) {
      memory[varName] = input == "true";
    } else {
      memory[varName] = input;
    }
  }
}

// ─────────────────────────────────────────
// checkCondition
// ─────────────────────────────────────────
bool checkCondition(List<Tocken> tokens) {
  var left = memory[tokens[1].value];
  var operation = tokens[2].value;
  var right = int.tryParse(tokens[3].value) ?? memory[tokens[3].value] ?? 0;

  if (operation == ">") return left > right;
  if (operation == "<") return left < right;
  if (operation == "A=") return left == right;
  if (operation == "!=") return left != right;
  if (operation == ">=") return left >= right;
  if (operation == "<=") return left <= right;
  return false;
}

// ─────────────────────────────────────────
// runCode — بياخد الكود كـ String وينفذه
// ─────────────────────────────────────────
void runCode(String codeText) {
  List<Tocken> loopToken = [];
  bool isWhile = false;
  bool inBlock = false;
  bool shouldExecute = false;
  bool lastIfTrue = false;
  List<String> block = [];
  bool inFunc = false;
  String funcName = '';
  List<String> funcBody = [];

  List<String> lines = codeText.split('\n');

  for (var raw in lines) {
    var input = raw.trim();

    if (input == "end") break;
    if (input.isEmpty) continue;

    if (inFunc) {
      if (input == "}") {
        functions[funcName] = List.from(funcBody);
        funcBody = [];
        inFunc = false;
      } else {
        funcBody.add(input);
      }
    } else if (inBlock) {
      if (input == "}") {
        if (isWhile) {
          int safetyLimit = 10000; // عشان منعملش loop للأبد
          while (checkCondition(loopToken) && safetyLimit-- > 0) {
            for (var line in block) {
              interpret(lexer(line));
            }
          }
          isWhile = false;
        } else if (shouldExecute) {
          for (var line in block) {
            interpret(lexer(line));
          }
        }
        block = [];
        inBlock = false;
      } else {
        block.add(input);
      }
    } else {
      var tokens = lexer(input);
      if (tokens.isEmpty) continue;

      if (tokens[0].type == "IF") {
        lastIfTrue = checkCondition(tokens);
        shouldExecute = lastIfTrue;
        if (input.contains('{') && input.contains('}')) {
          if (shouldExecute) {
            var body = input
                .substring(input.indexOf('{') + 1, input.indexOf('}'))
                .trim();
            interpret(lexer(body));
          }
        } else {
          inBlock = true;
        }
      } else if (tokens[0].type == "ELSE") {
        shouldExecute = !lastIfTrue;
        inBlock = true;
      } else if (tokens[0].type == "WHILE") {
        loopToken = tokens;
        isWhile = true;
        inBlock = true;
      } else if (tokens[0].type == "FUNC") {
        funcName = tokens[1].value;
        inFunc = true;
      } else if (tokens[0].type == "CALL") {
        String name = tokens[1].value;
        if (functions.containsKey(name)) {
          for (var line in functions[name]!) {
            interpret(lexer(line));
          }
        }
      } else {
        interpret(tokens);
      }
    }
  }
}

// ─────────────────────────────────────────
// main — بيربط الكود بالصفحة
// ─────────────────────────────────────────
void main() {
  final runBtn = document.getElementById('run-btn') as ButtonElement;
  final codeInput = document.getElementById('code-input') as TextAreaElement;
  final outputDiv = document.getElementById('output') as PreElement;
  final clearBtn = document.getElementById('clear-btn') as ButtonElement;

  runBtn.onClick.listen((_) {
    // نظف الذاكرة والـ output قبل كل تشغيل
    _output.clear();
    memory.clear();
    functions.clear();

    try {
      runCode(codeInput.value ?? '');
      outputDiv.text = _output.toString().trim();
    } catch (e) {
      outputDiv.text = 'Error: $e';
    }
  });

  clearBtn.onClick.listen((_) {
    codeInput.value = '';
    outputDiv.text = '';
  });
}

// Standard I/O library — used for reading from keyboard and writing to terminal
import 'dart:io';

// Token — the smallest unit of the language, like a LEGO brick
// Every word in the source code gets converted into a Token
// A Token has two properties: its type and its value
class Tocken {
  final String type;  // token type  — e.g. PRINT, NUMBER, VARIABLE
  final String value; // token value — e.g. "print", "5", "x"
  Tocken(this.type, this.value);
  @override
  String toString() {
    return 'Tocken(type: $type, value: $value)';
  }
}

// ─────────────────────────────────────────────────────────────
// splitWords — splits a line into words while respecting quotes
// Quoted strings are kept together as a single token
// Example: print "Hello World" → ["print", "Hello World"]
// ─────────────────────────────────────────────────────────────
List<String> splitWords(String input) {
  List<String> words = [];
  String current = '';
  bool inQuote = false;

  for (int i = 0; i < input.length; i++) {
    if (input[i] == '"') {
      inQuote = !inQuote; // toggle: entering or leaving a quoted string
    } else if (input[i] == ' ' && !inQuote) {
      if (current.isNotEmpty) {
        words.add(current); // word is complete — add it to the list
        current = '';
      }
    } else {
      current += input[i]; // append character to the current word
    }
  }
  if (current.isNotEmpty) words.add(current);
  return words;
}

// ─────────────────────────────────────────────────────────────
// lexer — converts a line of source code into a list of Tokens
// ─────────────────────────────────────────────────────────────
List<Tocken> lexer(String input) {
  List<Tocken> tockens = [];

  // use splitWords so quoted strings are treated as one token
  List<String> words = splitWords(input);

  for (var word in words) {
    if (word == "print") {
      tockens.add(Tocken("PRINT", word));        // print command
    } else if (int.tryParse(word) != null) {
      tockens.add(Tocken("NUMBER", word));        // integer literal
    } else if (double.tryParse(word) != null) {
      tockens.add(Tocken("DOUBLE", word));        // decimal literal
    } else if (word == '+') {
      tockens.add(Tocken("PLUS", word));          // addition operator
    } else if (word == '-') {
      tockens.add(Tocken("MINUS", word));         // subtraction operator
    } else if (word == '*') {
      tockens.add(Tocken("MULTIPLY", word));      // multiplication operator
    } else if (word == '/') {
      tockens.add(Tocken("DIVIDE", word));        // division operator
    } else if (word == "v") {
      tockens.add(Tocken("VARIABLE", word));      // variable declaration keyword
    } else if (word == "int") {
      tockens.add(Tocken("Type", word));          // type: whole number
    } else if (word == "double") {
      tockens.add(Tocken("Type", word));          // type: decimal number
    } else if (word == "bool") {
      tockens.add(Tocken("Type", word));          // type: true or false
    } else if (word == "string") {
      tockens.add(Tocken("Type", word));          // type: text
    } else if (word == "=") {
      tockens.add(Tocken("ASSIGNMENT", word));    // assignment operator
    } else if (word == "true" || word == "false") {
      tockens.add(Tocken("BOOL", word));          // boolean literal
    } else if (word == "if") {
      tockens.add(Tocken("IF", word));            // if keyword
    } else if (word == "else") {
      tockens.add(Tocken("ELSE", word));          // else block — runs when if was false
    } else if (word == ">" ||
        word == "<" ||
        word == "A=" ||
        word == "!=" ||
        word == "&&" ||
        word == "||" ||
        word == "!") {
      tockens.add(Tocken("COMPARISON", word));    // comparison / logical operator
    } else if (word == "{") {
      tockens.add(Tocken("OPEN_BRACE", word));    // block start
    } else if (word == "}") {
      tockens.add(Tocken("CLOSE_BRACE", word));   // block end
    } else if (word == "Loop") {
      // Loop keyword — tells the program "repeat the block inside {} while the condition is true"
      tockens.add(Tocken("WHILE", word));
    } else if (word == "func") {
      // func keyword — defines a new named function
      tockens.add(Tocken("FUNC", word));
    } else if (word == "call") {
      // call keyword — invokes a previously defined function by name
      tockens.add(Tocken("CALL", word));
    } else if (word == "n") {
      tockens.add(
        Tocken("REASSIGN", word),
      ); // n keyword — reassigns an existing variable to a new value
    } else if (word == "r") {
      tockens.add(
        Tocken("Read", word),
      ); // r keyword — reads a value from the keyboard into a variable
    } else if (word.contains(' ')) {
      // word contains a space — it came from inside quotes — full quoted string
      tockens.add(Tocken("QUOTED_STRING", word));
    } else {
      tockens.add(Tocken("STRING", word)); // plain text or variable name
    }
  }

  return tockens;
}

// Memory — stores every variable name and its current value
Map<String, dynamic> memory = {};

// Function registry — stores every function name and its list of body lines
// Example: functions["greet"] = ["print Hello", "print World"]
Map<String, List<String>> functions = {};

// ─────────────────────────────────────────────────────────────
// interpret — receives a token list and executes the command
// ─────────────────────────────────────────────────────────────
void interpret(List<Tocken> tokens) {
  // ── PRINT ────────────────────────────────────────────────────
  if (tokens[0].type == "PRINT") {
    if (tokens.length == 2) {
      // if it's a QUOTED_STRING — print the whole string directly
      if (tokens[1].type == "QUOTED_STRING") {
        print(tokens[1].value);
        return;
      }
      // if the name exists in memory — print its value, otherwise print it as text
      print(
        memory.containsKey(tokens[1].value)
            ? memory[tokens[1].value]
            : tokens[1].value,
      );
      return;
    }

    int result = 0;
    // start with PLUS so the first number is simply added to zero
    String operation = 'PLUS';

    for (int i = 1; i < tokens.length; i += 2) {
      // if it's a literal number — parse it directly
      // if it's a variable name — look up its value in memory
      int number = tokens[i].type == "NUMBER"
          ? int.parse(tokens[i].value)
          : memory[tokens[i].value] ?? 0;

      // apply the stored operation to the current number
      if (operation == 'PLUS') result += number;
      if (operation == 'MINUS') result -= number;
      if (operation == 'MULTIPLY') result *= number;
      if (operation == 'DIVIDE') result ~/= number; // ~/ = integer division

      // save the next operator so it's ready for the following number
      if (i + 1 < tokens.length) operation = tokens[i + 1].type;
    }

    print(result);
  }

  // ────────────────────────────────────────────────────────────
  // VARIABLE — declare a new variable
  // Example: v int x = 5
  // Meaning: "create a variable named x of type int with value 5"
  // ────────────────────────────────────────────────────────────
  if (tokens[0].type == "VARIABLE") {
    String varType  = tokens[1].value; // type  — int / double / bool / string
    String varName  = tokens[2].value; // name  — e.g. x, y, age
    String varValue = tokens[4].value; // value — e.g. 5, 3.14, true

    // convert the raw string value to the correct Dart type before storing
    if (varType == "int") {
      memory[varName] = int.parse(varValue);    // "5"     → 5
    } else if (varType == "double") {
      memory[varName] = double.parse(varValue); // "3.14"  → 3.14
    } else if (varType == "bool") {
      memory[varName] = varValue == "true";     // "true"  → true
    } else if (varType == "string") {
      memory[varName] = varValue;               // "Ahmed" → "Ahmed"
    }
  }

  // ────────────────────────────────────────────────────────────
  // REASSIGN — update the value of an existing variable
  // Example: n v x = x + 1
  // Meaning: "change x's current value to x + 1"
  // Difference from VARIABLE: no type needed — the variable already exists
  // ────────────────────────────────────────────────────────────
  if (tokens[0].type == "REASSIGN") {
    // Step 1: get the name of the variable to update
    // Example: n v x = x + 1  →  tokens[2] = "x"
    String varName = tokens[2].value;

    // Step 2: prepare to evaluate the right-hand expression
    // start at 0 and accumulate the result
    int result = 0;

    // start with PLUS so the first operand is added to zero
    // Example: x + 1 → result = 0 + x = x, then result = x + 1
    String operation = 'PLUS';

    // Step 3: iterate over the tokens after '='
    // start at i=4 to skip: n(0) v(1) x(2) =(3)
    // step by 2 to skip over operands and land on operators
    for (int i = 4; i < tokens.length; i += 2) {
      // if the token is a literal number — parse it
      // if it's a variable name — read its value from memory
      // ?? 0 means: if the variable doesn't exist, use 0 as a fallback
      int number = tokens[i].type == "NUMBER"
          ? int.parse(tokens[i].value)
          : memory[tokens[i].value] ?? 0;

      // apply the stored operation
      if (operation == 'PLUS')     result += number;  // result = result + number
      if (operation == 'MINUS')    result -= number;  // result = result - number
      if (operation == 'MULTIPLY') result *= number;  // result = result * number
      if (operation == 'DIVIDE')   result ~/= number; // result = result / number

      // save the next operator for the following iteration
      // Example: x + 1 — when we see '+', store PLUS to use with '1' next
      if (i + 1 < tokens.length) operation = tokens[i + 1].type;
    }

    // Step 4: write the result back into memory
    // same as PRINT but we store instead of printing
    memory[varName] = result;
  }

  // ────────────────────────────────────────────────────────────
  // READ — read a value from the keyboard into a variable
  // Example: r x
  // Meaning: "wait for the user to type something and store it in x"
  // ────────────────────────────────────────────────────────────
  if (tokens[0].type == "Read") {
    // Step 1: get the target variable name
    // Example: r x → tokens[1] = "x"
    String varName = tokens[1].value;

    // Step 2: look up the variable's current type in memory
    // the variable must be declared first with 'v'
    // Example: v int x = 0 → memory["x"] = 0 (int)
    var existingValue = memory[varName];

    // Step 3: print ">>" so the user knows input is expected
    stdout.write(">> ");

    // Step 4: read one line from the keyboard
    String input = stdin.readLineSync() ?? '';

    // Step 5: convert the raw string to the correct type based on what's already stored
    if (existingValue is int) {
      memory[varName] = int.tryParse(input) ?? 0;    // int    → parse as integer
    } else if (existingValue is double) {
      memory[varName] = double.tryParse(input) ?? 0; // double → parse as decimal
    } else if (existingValue is bool) {
      memory[varName] = input == "true";             // bool   → true only if user typed "true"
    } else {
      memory[varName] = input;                       // string → store as-is
    }
  }
}

// ─────────────────────────────────────────────────────────────
// checkCondition — evaluates a comparison and returns true/false
// ─────────────────────────────────────────────────────────────
bool checkCondition(List<Tocken> tokens) {
  var left      = memory[tokens[1].value]; // left operand  — always a variable
  var operation = tokens[2].value;         // operator      — e.g. >, <, A=
  var right     = int.parse(tokens[3].value); // right operand — always a literal number

  if (operation == ">")  return left > right;
  if (operation == "<")  return left < right;
  if (operation == "A=") return left == right; // A= means "equals"
  if (operation == "!=") return left != right;
  if (operation == ">=") return left >= right;
  if (operation == "<=") return left <= right;
  return false;
}

void main(List<String> args) {
  List<Tocken> loopToken  = [];
  bool isWhile            = false;
  bool inBlock            = false;
  bool shouldExecute      = false;
  bool lastIfTrue         = false;
  List<String> block      = [];
  bool inFunc             = false;
  String funcName         = '';
  List<String> funcBody   = [];

  // if a filename was passed — read all its lines
  // otherwise — run in interactive REPL mode from the terminal
  List<String> fileLines = args.isNotEmpty
      ? File(args[0]).readAsLinesSync()
      : [];
  int lineIndex = 0;

  // helper: returns the next line — from the file or from stdin
  String? nextLine() {
    if (args.isNotEmpty) {
      if (lineIndex >= fileLines.length) return null;
      return fileLines[lineIndex++];
    }
    return stdin.readLineSync();
  }

  while (true) {
    var raw = nextLine();
    if (raw == null) break;
    var input = raw.trim();

    if (input == "end") break;
    if (input.isEmpty) continue;

    // ── inside a function definition — collect body lines ──
    if (inFunc) {
      if (input == "}") {
        // found the closing brace — save the function and reset
        functions[funcName] = List.from(funcBody);
        funcBody = [];
        inFunc   = false;
      } else {
        // still inside the function — add line to its body
        funcBody.add(input);
      }
    }
    // ── inside an if/else/loop block — collect body lines ──
    else if (inBlock) {
      if (input == "}") {
        // found the closing brace — execute the collected block
        if (isWhile) {
          // it's a Loop — keep running the block while the condition holds
          while (checkCondition(loopToken)) {
            for (var line in block) {
              interpret(lexer(line));
            }
          }
          isWhile = false; // loop finished — reset the flag
        } else if (shouldExecute) {
          // it's an if/else — run the block exactly once
          for (var line in block) {
            interpret(lexer(line));
          }
        }
        block   = [];
        inBlock = false;
      } else {
        // still inside the block — collect the line for later execution
        block.add(input);
      }
    } else {
      var tokens = lexer(input);

      // skip empty token lists
      if (tokens.isEmpty) continue;

      // ── if statement — evaluate the condition and start collecting the block ──
      if (tokens[0].type == "IF") {
        lastIfTrue     = checkCondition(tokens);
        shouldExecute  = lastIfTrue;

        // if both braces are on the same line — execute immediately
        if (input.contains('{') && input.contains('}')) {
          if (shouldExecute) {
            // extract the code between { and }
            var body = input
                .substring(input.indexOf('{') + 1, input.indexOf('}'))
                .trim();
            interpret(lexer(body));
          }
        } else {
          inBlock = true;
        }

      // ── else if — runs only when the previous if was false ──
      } else if (tokens[0].type == "ELSE_IF") {
        shouldExecute = !lastIfTrue && checkCondition(tokens);
        inBlock       = true;

      // ── else — runs only when the previous if was false ──
      } else if (tokens[0].type == "ELSE") {
        shouldExecute = !lastIfTrue;
        inBlock       = true;

      // ── Loop — save the condition tokens and start collecting the block ──
      } else if (tokens[0].type == "WHILE") {
        loopToken = tokens;
        isWhile   = true;
        inBlock   = true;

      // ── func — save the function name and start collecting its body ──
      } else if (tokens[0].type == "FUNC") {
        funcName = tokens[1].value; // function name — e.g. greet, sayHello
        inFunc   = true;            // start collecting body lines

      // ── call — look up the function and execute its body ──
      } else if (tokens[0].type == "CALL") {
        String name = tokens[1].value; // name of the function to invoke
        if (functions.containsKey(name)) {
          // found it — run every line in its body
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

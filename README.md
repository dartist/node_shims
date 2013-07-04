Node and JavaScript API Shims
=============================

Common node and js utils to help in porting of node.js and javascript libs to dart.
Behavior of libs should match the js implementation as closely as dart allows.

## [Installing via Pub](http://pub.dartlang.org/packages/node_shims)	

Add this to your package's pubspec.yaml file:

	dependencies:
	  node_shims: 0.1.1

## Public API

## [Path](https://github.com/dartist/node_shims/blob/master/lib/path.dart)

 - [docs](http://nodejs.org/api/path.html)
 - [tests](https://github.com/dartist/node_shims/blob/master/test/test_path.dart)


### Usage:

	import "pacakge:node_shims/path.dart" as path; 

Normalize a string path, taking care of '..' and '.' parts.
```dart
String normalize(String path)
```

Join all arguments together and normalize the resulting path.
```dart
String join(List paths)
```

Resolves `to` to an absolute path.
```dart
String resolve(List paths)
```

Solve the relative path from `from` to `to`.
```dart
String relative(String from, String to)
```

Return the directory name of a path. Similar to the Unix `dirname` command.
```dart
String dirname(String path)
```

Return the last portion of a path. Similar to the Unix `basename` command.
```dart
String basename(String path, [String ext])
```

Return the extension of the path, from the last '.' to end of string in the last portion of the path.
```dart
String extname(String path)
```

Check if it's an absolute path.
```dart
bool isAbsolute(String path)
```

Check if a file exists.
```dart
void exists(String path, void callback(bool)) 
bool existsSync (String path) 
```

The platform-specific file separator. '\\' or '/'.
```dart
String sep;
```

The platform-specific path delimiter, ; or ':'.
```dart
String delimiter;
```

## [JS](https://github.com/dartist/node_shims/blob/master/lib/js.dart)

### Usage:

	import "package:node_shims/js.dart";

### Core JS functions 

If value is truthy return value, otherwise return defaultValue. 
If defaultValue is a function it's result is returned. 
```dart
or(value, defaultValue)

//js
value || defaultValue

//Usage
or(null, 1)
or(null, () => 1)
```

Return true if `value` is "falsey":
```dart
bool falsey(value) => 
  value == null || value == false || value == '' || value == 0 || value == double.NAN;
  
//Usage
if (falsey(''))
```

Return true if `value` is "truthy":
```dart
bool truthy(value) => !falsey(value);

//Usage
if (truthy(1))
```

### Array functions

Changes the content of an array, adding new elements while removing old elements. 
[docs](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/splice).
```dart
List splice(List list, int index, [num howMany=0, dynamic elements])
```

Returns a new array comprised of this array joined with other array(s) and/or value(s).
[docs](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/concat).
```dart
List concat(List lists)
```

Removes the last element from an array and returns that element.
[docs](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/pop)
```dart
dynamic pop(List list)
```

Mutates an array by appending the given elements and returning the new length of the array.
[docs](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/push)
```dart
int push(List list, item)
```

Reverses an array in place.  The first array element becomes the last and the last becomes the first.
[docs](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/reverse)
```dart
List reverse(List list)
```

Removes the first element from an array and returns that element. This method changes the length of the array.
[docs](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/shift)
```dart
dynamic shift(List list)
```

Adds one or more elements to the beginning of an array and returns the new length of the array.
[docs](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/unshift)
```dart
int unshift(List list, item)
```

Returns a shallow copy of a portion of an array.
[docs](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/slice)
```dart
List slice(List list, int begin, [int end])
```

Tests whether all elements in the array passes (truthy) the test implemented by the provided function.
[docs](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/every)
```dart
bool every(List list, fn(e)) => list.every((x) => truthy(fn(x)));
```

Tests whether some element in the array passes (truthy) the test implemented by the provided function.
[docs](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/some)
```dart
bool some(List list, fn(e)) => list.any((x) => truthy(fn(x)));
```

Creates a new array with all elements that pass the test implemented by the provided function.
[docs](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/filter)
```dart
List filter(List list, fn(e)) => list.where((x) => truthy(fn(x))).toList();
```

Apply a function against an accumulator and each value of the array (from left-to-right) as to reduce it to a single value.
[docs](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/reduce)
```dart
dynamic reduce(List list, fn(prev, curr, int index, List list), [initialValue])
```

Apply a function simultaneously against two values of the array (from right-to-left) as to reduce it to a single value.
[docs](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/reduceRight)
```dart
dynamic reduceRight(List list, fn(prev, curr, int index, List list), [initialValue])
```

### Strings

Returns the character at the specified index.
[docs](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/charAt)
```dart
String charAt(String str, int atPos) => str.substring(atPos, 1);
```

Returns a number indicating the Unicode value of the character at the given index.
[docs](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/charCodeAt)
```dart
int charCodeAt(String str, int atPos) => str.codeUnitAt(atPos);
```

Wraps the string in double quotes (""").
[docs](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/quote)
```dart
String quote(String str) => '"$str"';
```

Used to find a match between a regular expression and a string, and to replace the matched substring with a new substring.
[docs](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/replace)
```dart
String replace(String str, pattern) => str.replaceAll(str, pattern);
```

Executes the search for a match between a regular expression and a specified string.
[docs](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/search)
```dart
int search(String str, RegExp pattern) => str.indexOf(pattern);
```

Returns the characters in a string beginning at the specified location through the specified number of characters.
[docs](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/substr)
```dart
String substr(String str, int start, [int length=null])
```

Trims whitespace from the left side of the string.
[docs](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/trimLeft)
```dart
String trimLeft(String str) => str.replaceAll(new RegExp(r'^\s+'), '');
```

Trims whitespace from the right side of the string.
[docs](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/trimRight)
```dart
String trimRight(String str) => str.replaceAll(new RegExp(r'\s+$'), '');
```

HTML Encode `html` string.
```dart
String escapeHtml(String html)
```

## [Process](https://github.com/dartist/node_shims/blob/master/lib/process.dart)

 - [docs](http://nodejs.org/api/process.html)

### Usage:

	import "pacakge:node_shims/process.dart" as process; 

Returns the current working directory of the process.
```dart
String cwd()
```

An object containing the user environment.
```dart
Map<String,String> env
```

A Writable Stream to stdout.
```dart
IOSink get stdout
```

A writable stream to stderr.
```dart
IOSink get stderr
```

A Readable Stream for stdin.
```dart
Stream get stdin
```

An array containing the command line arguments.
```dart
List<String> get argv
```

This is the absolute pathname of the executable that started the process.
```dart
String get execPath
```

Changes the current working directory of the process or throws an exception if that fails.
```dart
void chdir(String directory)
```

Exit the Dart VM process immediately with the given `code`.
```dart
void exit([int code=0])
```

## [Utils](https://github.com/dartist/node_shims/blob/master/lib/utils.dart)

Useful helper utils extracted from the [101 LINQ Samples](https://github.com/dartist/101LinqSamples).

### Usage:

	import "package:node_shims/utils.dart";

Order a sequance by comparators or expressions.
[docs](https://github.com/dartist/101LinqSamples#linq---ordering-operators)
```dart
order(List seq, {Comparator by, List<Comparator> byAll, on(x), List<Function> onAll})
```

A case-insensitive comparer that can be used in ordering and grouping functions.
```dart
caseInsensitiveComparer(a,b) => a.toUpperCase().compareTo(b.toUpperCase());
```

Group a sequance by comparators or expressions.
[docs](https://github.com/dartist/101LinqSamples#linq---grouping-operators)
```dart
List<Group> group(Iterable seq, {by(x):null, Comparator matchWith:null, valuesAs(x):null})
```

Capture an expression and invoke it in the supplied function.
```dart
wrap(value, fn(x)) => fn(value);
```

Trim the start of a string if it matches the specified string.
```dart
String trimStart(String str, String start)
```

Trim the end of a string if it matches the specified string.
```dart
String trimEnd(String str, String end)
```

-------

Pull requests for missing js or node.js utils welcome.

### Contributors

  - [mythz](https://github.com/mythz) (Demis Bellot)
 
  
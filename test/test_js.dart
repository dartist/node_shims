import 'package:test/test.dart' as TEST; //ignore: library_prefixes

import 'package:node_shims/node_shims.dart';

void main() {
  const MAX_VALUE = 0x7FFFFFFF;

  TEST.group('js tests', () {
    TEST.test('splice', () {
      var myFish = ['angel', 'clown', 'mandarin', 'surgeon'];

      //removes 0 elements from index 2, and inserts 'drum'
      var removed = splice(myFish, 2, 0, 'drum');
      //myFish is ['angel', 'clown', 'drum', 'mandarin', 'surgeon']
      //removed is [], no elements removed
      TEST.expect(removed,
          TEST.equals(['angel', 'clown', 'drum', 'mandarin', 'surgeon']));

      //removes 1 element from index 3
      removed = splice(myFish, 3, 1);
      //myFish is ['angel', 'clown', 'drum', 'surgeon']
      //removed is ['mandarin']
      TEST.expect(removed, TEST.equals(['angel', 'clown', 'drum', 'surgeon']));

      //removes 1 element from index 2, and inserts 'trumpet'
      removed = splice(myFish, 2, 1, 'trumpet');
      //myFish is ['angel', 'clown', 'trumpet', 'surgeon']
      //removed is ['drum']
      TEST.expect(
          removed, TEST.equals(['angel', 'clown', 'trumpet', 'surgeon']));

      //removes 2 elements from index 0, and inserts 'parrot', 'anemone' and 'blue'
      removed = splice(myFish, 0, 2, ['parrot', 'anemone', 'blue']);
      //myFish is ['parrot', 'anemone', 'blue', 'trumpet', 'surgeon']
      //removed is ['angel', 'clown']
      TEST.expect(removed,
          TEST.equals(['parrot', 'anemone', 'blue', 'trumpet', 'surgeon']));

      //removes 2 elements from index 3
      removed = splice(myFish, 3, MAX_VALUE);
      //myFish is ['parrot', 'anemone', 'blue']
      //removed is ['trumpet', 'surgeon']
      TEST.expect(removed, TEST.equals(['parrot', 'anemone', 'blue']));
    });

    TEST.test('slice', () {
      var fruits = ['Banana', 'Orange', 'Lemon', 'Apple', 'Mango'];
      var citrus = slice(fruits, 1, 3);
      TEST.expect(citrus, TEST.equals(['Orange', 'Lemon']));
    });

    TEST.test('substr', () {
      var str = 'abcdefghij';
      TEST.expect(substr(str, 1, 2), TEST.equals('bc'));
      TEST.expect(substr(str, -3, 2), TEST.equals('hi'));
      TEST.expect(substr(str, -3), TEST.equals('hij'));
      TEST.expect(substr(str, 1), TEST.equals('bcdefghij'));
      TEST.expect(substr(str, -20, 2), TEST.equals('ab'));
      TEST.expect(substr(str, 20, 2), TEST.equals(''));
    });
  });
}

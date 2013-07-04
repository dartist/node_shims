import "package:unittest/unittest.dart";

import "../lib/js.dart";



main(){
  const int MAX_VALUE = 0x7FFFFFFF;
  
  group('js tests',(){
    
    test('splice',(){
      
      var myFish = ["angel", "clown", "mandarin", "surgeon"];

      //removes 0 elements from index 2, and inserts "drum"
      var removed = splice(myFish, 2, 0, "drum");
      //myFish is ["angel", "clown", "drum", "mandarin", "surgeon"]
      //removed is [], no elements removed
      expect(removed, equals(["angel", "clown", "drum", "mandarin", "surgeon"]));

      //removes 1 element from index 3
      removed = splice(myFish, 3, 1);
      //myFish is ["angel", "clown", "drum", "surgeon"]
      //removed is ["mandarin"]
      expect(removed, equals(["angel", "clown", "drum", "surgeon"]));
      
      //removes 1 element from index 2, and inserts "trumpet"
      removed = splice(myFish, 2, 1, "trumpet");
      //myFish is ["angel", "clown", "trumpet", "surgeon"]
      //removed is ["drum"]
      expect(removed, equals(["angel", "clown", "trumpet", "surgeon"]));
      
      //removes 2 elements from index 0, and inserts "parrot", "anemone" and "blue"
      removed = splice(myFish, 0, 2, ["parrot", "anemone", "blue"]);
      //myFish is ["parrot", "anemone", "blue", "trumpet", "surgeon"]
      //removed is ["angel", "clown"]
      expect(removed, equals(["parrot", "anemone", "blue", "trumpet", "surgeon"]));
      
      //removes 2 elements from index 3
      removed = splice(myFish, 3, MAX_VALUE);
      //myFish is ["parrot", "anemone", "blue"]
      //removed is ["trumpet", "surgeon"]      
      expect(removed, equals(["parrot", "anemone", "blue"]));
    });
    
    test('slice', (){
      var fruits = ["Banana", "Orange", "Lemon", "Apple", "Mango"];
      var citrus = slice(fruits, 1, 3);
      expect(citrus, equals(["Orange","Lemon"]));          
    });
    
    test('substr',(){
      var str = "abcdefghij";
      expect(substr(str, 1,2), equals("bc"));
      expect(substr(str, -3,2), equals("hi"));
      expect(substr(str, -3), equals("hij"));
      expect(substr(str, 1), equals("bcdefghij"));
      expect(substr(str, -20,2), equals("ab"));
      expect(substr(str, 20,2), equals(""));
    });
    
  });
  
}
library utils;

import "dart:collection";

String safeTrimStart(String str, String start) {
  if (str.startsWith(start) && str.length >= start.length) {
    return str.substring(start.length);
  }
  return str;
}

String safeTrimEnd(String str, String end) {
  if (str.endsWith(end) && str.length >= end.length) {
    return str.substring(0, str.length - end.length);
  }
  return str;
}

List<Group> group(Iterable seq, {by(x):null, Comparator matchWith:null, valuesAs(x):null}){
  var ret = [];
  var map = new Map<dynamic, Group>();
  seq.forEach((x){
    var val = by(x);
    var key = matchWith != null
      ? map.keys.firstWhere((k) => matchWith(val, k) == 0, orElse:() => val)
      : val;

    if (!map.containsKey(key))
      map[key] = new Group(val);

    if (valuesAs != null)
      x = valuesAs(x);

    map[key].add(x);
  });
  return map.values.toList();
}

class Group extends IterableBase {
  var key;
  List _list;
  Group(this.key) : _list = [];

  get iterator => _list.iterator;
  void add(e) => _list.add(e);  
  get values => _list;
}

wrap(value, fn(x)) => fn(value);

order(List seq, {Comparator by, List<Comparator> byAll, on(x), List<Function> onAll}) =>
  by != null ? 
    (seq..sort(by)) 
  : byAll != null ?
    (seq..sort((a,b) => byAll
      .firstWhere((compare) => compare(a,b) != 0, orElse:() => (x,y) => 0)(a,b)))
  : on != null ? 
    (seq..sort((a,b) => on(a).compareTo(on(b)))) 
  : onAll != null ?
    (seq..sort((a,b) =>
      wrap(onAll.firstWhere((_on) => _on(a).compareTo(_on(b)) != 0, orElse:() => (x) => 0),
        (_on) => _on(a).compareTo(_on(b)) 
    ))) 
  : (seq..sort()); 

caseInsensitiveComparer(a,b) => 
  a.toUpperCase().compareTo(b.toUpperCase());

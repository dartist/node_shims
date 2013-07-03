library js;

escapeHtml(html) => "$html"
  .replaceAll("&", '&amp;')
  .replaceAll("<", '&lt;')
  .replaceAll(">", '&gt;')
  .replaceAll('"', '&quot;');

List<String> exec(RegExp regex, String str){
  var m = regex.firstMatch(str);
  if (m == null) return null;
  
  var groups = [];
  for (var i=0; i<=m.groupCount; i++)
    groups.add(i);

  return m.groups(groups);
}

List splice(List list, int index, [num howMany=0, dynamic elements]){
  var endIndex = index + howMany.truncate();
  list.removeRange(index, endIndex >= list.length ? list.length : endIndex);
  if (elements != null)
    list.insertAll(index, elements is List ? elements : [elements]);
  return list;
}

List slice(List list, int begin, [int end]) =>
  list.getRange(begin, end == null ? list.length : end < 0 ? list.length + end : end).toList();

List concat(List lists) {
  var ret = [];
  for (var item in lists){
    if (item is Iterable)
      ret.addAll(item);
    else
      ret.add(item);
  }
  return ret;
}

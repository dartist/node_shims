library utils;

or(value, defaultValue) =>
  value != null && value != false && value != '' && value != 0 
    ? value 
    : defaultValue is Function ? defaultValue() : defaultValue; 

String trimStart(String str, String start) {
  if (str.startsWith(start) && str.length >= start.length) {
    return str.substring(start.length);
  }
  return str;
}

String trimEnd(String str, String end) {
  if (str.endsWith(end) && str.length >= end.length) {
    return str.substring(0, str.length - end.length);
  }
  return str;
}


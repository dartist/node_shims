library path;

import "utils.dart";

/// path utils similar to http://nodejs.org/api/path.html 

String join(List paths){
  var sb = new StringBuffer();
  bool endsWithSlash = false;
  for (var oPath in paths){
    if (oPath == null) continue;
    String path = oPath.toString();
    if (path.isEmpty) continue;
    
    if (sb.length > 0 && !endsWithSlash)
      sb.write('/');
    
    String sanitizedPath = trimStart(path.replaceAll("\\", "/"), "/");
    sb.write(sanitizedPath);
    endsWithSlash = sanitizedPath.endsWith("/");
  }
  return sb.toString();
}

var _trailingSlashes = new RegExp(r"[/]+$"); 

String dirname(String path){
  if (path == null) return path;
  if (path.isEmpty) return '.';
  
  path = path.replaceAll(_trailingSlashes, '');
  if (path.isEmpty) return '/';
  var pos = path.lastIndexOf('/');
  if (pos == 0) pos = 1;
  return path.substring(0, pos);
}

String basename(String path, [String trimExt]){
  if (path == null || path.isEmpty) return path;
  path = path.replaceAll(_trailingSlashes, '');
  var pos = path.lastIndexOf('/');
  var basename = path.substring(pos + 1);
  return trimExt != null && basename.endsWith(trimExt)
    ? basename.substring(0, basename.length - trimExt.length)
    : basename;   
}

String extname(String path){
  path = path.replaceAll(_trailingSlashes, '');
  if (path == '..') return '';

  var dirPos = path.lastIndexOf('/');
  if (dirPos >= 0)
    path = path.substring(dirPos + 1); 
  
  path = trimStart(path, '.');
  var extPos = path.lastIndexOf('.');
  if (extPos == -1) return '';
  return path.substring(extPos);
}

// Copyright Joyent, Inc. and other Node contributors.
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to permit
// persons to whom the Software is furnished to do so, subject to the
// following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
// NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
// USE OR OTHER DEALINGS IN THE SOFTWARE.

// resolves . and .. elements in a path array with directory names there
// must be no slashes, empty elements, or device names (c:\) in the array
// (so also no leading and trailing slashes - it does not distinguish
// relative and absolute paths)

library path;

import "dart:io";
import "dart:math" as Math;

import "js.dart";
import "utils.dart";
import "process.dart" as process;

normalizeArray(Iterable<String> paths, bool allowAboveRoot) {
  // if the path tries to go above the root, `up` ends up > 0
  var parts = paths.toList();
  var up = 0;
  for (var i = parts.length - 1; i >= 0; i--) {
    var last = parts[i];
    if (last == '.') {
      splice(parts, i, 1);
    } else if (last == '..') {
      splice(parts, i, 1);
      up++;
    } else if (up > 0) {
      splice(parts, i, 1);
      up--;
    }
  }

  // if the path is allowed to go above the root, restore leading ..s
  if (allowAboveRoot) {
    for (; up > 0; up--) {
      parts.insert(0, '..');
    }
  }

  return parts;
}

typedef String _listStringFn(List arguments);
typedef List<String> _stringListFn(String path);
typedef String _stringFn(String path);
typedef String _string2Fn(String path1, String path2);
typedef bool _stringBoolFn(String path);

class _PathExports {
  String sep;
  String delimiter;
  _listStringFn resolve;
  _listStringFn join;
  _stringFn normalize;
  _stringBoolFn isAbsolute;
  _string2Fn relative;
  _stringListFn splitPath;
}

_PathExports _exports = _factory();
String sep = _exports.sep;
String delimiter = _exports.delimiter;
_listStringFn resolve = _exports.resolve;
_listStringFn join = _exports.join;
_stringFn normalize = _exports.normalize;
_stringBoolFn isAbsolute = _exports.isAbsolute;
_string2Fn relative = _exports.relative;
_stringListFn splitPath = _exports.splitPath;

_PathExports _factory(){
  var exports = new _PathExports();

  var isWindows = Platform.operatingSystem == 'win32';
  
  if (isWindows) {
    // Regex to split a windows path into three parts: [*, device, slash,
    // tail] windows-only
    var splitDeviceRe =
      new RegExp(r"^([a-zA-Z]:|[\\\/]{2}[^\\\/]+[\\\/]+[^\\\/]+)?([\\\/])?([\s\S]*?)$");
  
    // Regex to split the tail part of the above into [*, dir, basename, ext]
    var splitTailRe =
      new RegExp(r"^([\s\S]*?)((?:\.{1,2}|[^\\\/]+?|)(\.[^.\/\\]*|))(?:[\\\/]*)$");
  
    // Function to split a filename into [root, dir, basename, ext]
    // windows version
    exports.splitPath = (String filename){
      // Separate device+slash from tail
      var result = exec(splitDeviceRe, filename);
      var device = or(result[1], '') + or(result[2], '');
      var tail = or(result[3], '');
      // Split the tail into dir, basename and extension
      var result2 = exec(splitTailRe, tail);
      var dir = result2[1];
      var basename = result2[2];
      var ext = result2[3];
      return [device, dir, basename, ext];
    };
  
    normalizeUNCRoot(String device) {
      return '\\\\' + device
        .replaceFirst(new RegExp(r"^[\\\/]+"), '')
        .replaceAll(new RegExp(r"[\\\/]+"), '\\');
    };
  
    // path.resolve([from ...], to)
    // windows version
    exports.resolve = (List arguments) {
      var resolvedDevice = '';
      var resolvedTail = '';
      var resolvedAbsolute = false;
      bool isUnc = false;
  
      for (var i = arguments.length - 1; i >= -1; i--) {
        var path;
        if (i >= 0) {
          path = arguments[i];
        } else if (!resolvedDevice) {
          path = process.path;
        } else {
          // Windows has the concept of drive-specific current working
          // directories. If we've resolved a drive letter but not yet an
          // absolute path, get cwd for that drive. We're sure the device is not
          // an unc path at this points, because unc paths are always absolute.
          path = process.env['=' + resolvedDevice];
          // Verify that a drive-local cwd was found and that it actually points
          // to our drive. If not, default to the drive's root.
          if (path == null || path.substring(0, 3).toLowerCase() !=
              resolvedDevice.toLowerCase() + '\\') {
            path = resolvedDevice + '\\';
          }
        }
  
        // Skip empty and invalid entries
        if (path is! String) {
          throw new TypeError(); //'Arguments to path.resolve must be strings'
        } else if (!path) {
          continue;
        }
  
        var result = splitDeviceRe.exec(path);
        var device = or(result[1], '');
        isUnc = device && device.substring(1,1) != ':';
        var isAbsolute = exports.isAbsolute(path);
        var tail = result[3];
  
        if (device &&
            resolvedDevice &&
            device.toLowerCase() != resolvedDevice.toLowerCase()) {
          // This path points to another device so it is not applicable
          continue;
        }
  
        if (!resolvedDevice) {
          resolvedDevice = device;
        }
        if (!resolvedAbsolute) {
          resolvedTail = tail + '\\' + resolvedTail;
          resolvedAbsolute = isAbsolute;
        }
  
        if (resolvedDevice && resolvedAbsolute) {
          break;
        }
      }
  
      // Convert slashes to backslashes when `resolvedDevice` points to an UNC
      // root. Also squash multiple slashes into a single one where appropriate.
      if (isUnc) {
        resolvedDevice = normalizeUNCRoot(resolvedDevice);
      }
  
      // At this point the path should be resolved to a full absolute path,
      // but handle relative paths to be safe (might happen when process.cwd()
      // fails)
  
      // Normalize the tail path
      f(p) => p != null && p != false;
  
      resolvedTail = normalizeArray(resolvedTail.split(new RegExp(r"[\\\/]+")).where(f),
                                    !resolvedAbsolute).join('\\');
  
      return or((resolvedDevice + (resolvedAbsolute ? '\\' : '') + resolvedTail), '.');
    };
  
    // windows version
    exports.normalize = (String path) {
      var result = splitDeviceRe.exec(path);
      var device = or(result[1], '');
      var isUnc = device != null && device.substring(1,1) != ':';
      var isAbsolute = exports.isAbsolute(path);
      var tail = result[3];
      var trailingSlash = new RegExp(r"[\\\/]$").hasMatch(tail);
  
      // If device is a drive letter, we'll normalize to lower case.
      if (device != null && device.substring(1,1) == ':') {
        device = device[0].toLowerCase() + device.substring(1);
      }
  
      // Normalize the tail path
      tail = normalizeArray(tail.split(new RegExp(r"[\\\/]+")).where((p) {
        return p != null;
      }), !isAbsolute).join('\\');
  
      if (!tail && !isAbsolute) {
        tail = '.';
      }
      if (tail && trailingSlash) {
        tail += '\\';
      }
  
      // Convert slashes to backslashes when `device` points to an UNC root.
      // Also squash multiple slashes into a single one where appropriate.
      if (isUnc) {
        device = normalizeUNCRoot(device);
      }
  
      return device + (isAbsolute ? '\\' : '') + tail;
    };
  
    // windows version
    exports.isAbsolute = (path) {
      var result = splitDeviceRe.exec(path),
          device = result[1] || '',
          isUnc = device && device.charAt(1) != ':';
      // UNC paths are always absolute
      return !!result[2] || isUnc;
    };
  
    // windows version
    exports.join = (List arguments) {
       f(p) {
        if (p is! String) {
          throw new TypeError(); //'Arguments to path.join must be strings'
        }
        return p;
      }
  
      var paths = arguments.where((x) => f(x));
      var joined = paths.join('\\');
  
      // Make sure that the joined path doesn't start with two slashes, because
      // normalize() will mistake it for an UNC path then.
      //
      // This step is skipped when it is very clear that the user actually
      // intended to point at an UNC path. This is assumed when the first
      // non-empty string arguments starts with exactly two slashes followed by
      // at least one more non-slash character.
      //
      // Note that for normalize() to treat a path as an UNC path it needs to
      // have at least 2 components, so we don't filter for that here.
      // This means that the user can use join to construct UNC paths from
      // a server name and a share name; for example:
      //   path.join('//server', 'share') -> '\\\\server\\share\')
      if (!new RegExp(r"^[\\\/]{2}[^\\\/]").hasMatch(paths[0])) {
        joined = joined.replaceFirst(new RegExp(r"^[\\\/]{2,}"), '\\');
      }
  
      return exports.normalize(joined);
    };
  
    // path.relative(from, to)
    // it will solve the relative path from 'from' to 'to', for instance:
    // from = 'C:\\orandea\\test\\aaa'
    // to = 'C:\\orandea\\impl\\bbb'
    // The output of the function should be: '..\\..\\impl\\bbb'
    // windows version
    exports.relative = (String from, String to) {
      from = exports.resolve(from);
      to = exports.resolve(to);
  
      // windows is not case sensitive
      var lowerFrom = from.toLowerCase();
      var lowerTo = to.toLowerCase();
  
       trim(arr) {
        var start = 0;
        for (; start < arr.length; start++) {
          if (arr[start] != '') break;
        }
  
        var end = arr.length - 1;
        for (; end >= 0; end--) {
          if (arr[end] != '') break;
        }
  
        if (start > end) return [];
        return arr.slice(start, end - start + 1);
      }
  
      var toParts = trim(to.split('\\'));
  
      var lowerFromParts = trim(lowerFrom.split('\\'));
      var lowerToParts = trim(lowerTo.split('\\'));
  
      var length = Math.min(lowerFromParts.length, lowerToParts.length);
      var samePartsLength = length;
      for (var i = 0; i < length; i++) {
        if (lowerFromParts[i] != lowerToParts[i]) {
          samePartsLength = i;
          break;
        }
      }
  
      if (samePartsLength == 0) {
        return to;
      }
  
      var outputParts = [];
      for (var i = samePartsLength; i < lowerFromParts.length; i++) {
        outputParts.push('..');
      }
  
      outputParts = concat([outputParts, slice(toParts, samePartsLength)]);
  
      return outputParts.join('\\');
    };
  
    exports.sep = '\\';
    exports.delimiter = ';';
  
  } else /* posix */ {
  
    // Split a filename into [root, dir, basename, ext], unix version
    // 'root' is just a slash, or nothing.
    var splitPathRe =
        new RegExp(r"^(\/?|)([\s\S]*?)((?:\.{1,2}|[^\/]+?|)(\.[^.\/]*|))(?:[\/]*)$");
    
    exports.splitPath = (String filename) {
      var matches = exec(splitPathRe, filename);
      //bug: https://code.google.com/p/dart/issues/detail?id=11674&thanks=11674&ts=1372835984
      if (matches.length == 5 && matches[3] == matches[4])
        matches[4] = '';
      return slice(matches, 1);
    };
  
    // path.resolve([from ...], to)
    // posix version
    exports.resolve = (List arguments) {
      var resolvedPath = '',
          resolvedAbsolute = false;
  
      for (var i = arguments.length - 1; i >= -1 && !resolvedAbsolute; i--) {
        var path = (i >= 0) ? arguments[i] : process.cwd();
  
        // Skip empty and invalid entries
        if (path is! String) {
          throw new TypeError(); //'Arguments to path.resolve must be strings'
        } else if (path == null || path.isEmpty) {
          continue;
        }
  
        resolvedPath = path + '/' + resolvedPath;
        resolvedAbsolute = path.startsWith('/');
      }
  
      // At this point the path should be resolved to a full absolute path, but
      // handle relative paths to be safe (might happen when process.cwd() fails)
  
      // Normalize the path
      resolvedPath = normalizeArray(
          resolvedPath.split('/').where((p) => p != null && !p.isEmpty), 
          !resolvedAbsolute).join('/');
  
      return or(((resolvedAbsolute ? '/' : '') + resolvedPath), '.');
    };
  
    // path.normalize(path)
    // posix version
    exports.normalize = (String path) {
      var isAbsolute = exports.isAbsolute(path);
      var trailingSlash = path.endsWith('/');
  
      // Normalize the path
      path = normalizeArray(path.split('/').where((p) => p != null && !p.isEmpty), !isAbsolute).join('/');
  
      if ((path == null || path.isEmpty) && !isAbsolute) {
        path = '.';
      }
      if ((path != null && !path.isEmpty) && trailingSlash) {
        path += '/';
      }
  
      return (isAbsolute ? '/' : '') + path;
    };
  
    // posix version
    exports.isAbsolute = (String path) {
      return path != null && path.startsWith('/');
    };
  
    // posix version
    exports.join = (List arguments) {
      var paths = arguments.where((p) {
        if (p is! String) {
          throw new TypeError(); //'Arguments to path.join must be strings'
        }
        return p != null && !p.isEmpty;
      }).toList();
      int index = 0;
      return exports.normalize(paths.join('/'));
    };
  
  
    // path.relative(from, to)
    // posix version
    exports.relative = (String from, String to) {
      from = exports.resolve([from]).substring(1);
      to = exports.resolve([to]).substring(1);
  
       trim(arr) {
        var start = 0;
        for (; start < arr.length; start++) {
          if (arr[start] != '') break;
        }
  
        var end = arr.length - 1;
        for (; end >= 0; end--) {
          if (arr[end] != '') break;
        }
  
        if (start > end) return [];
        return slice(arr, start, end - start + 1);
      }
  
      var fromParts = trim(from.split('/'));
      var toParts = trim(to.split('/'));
  
      var length = Math.min(fromParts.length, toParts.length);
      var samePartsLength = length;
      for (var i = 0; i < length; i++) {
        if (fromParts[i] != toParts[i]) {
          samePartsLength = i;
          break;
        }
      }
  
      var outputParts = [];
      for (var i = samePartsLength; i < fromParts.length; i++) {
        outputParts.add('..');
      }
  
      outputParts = concat([outputParts, slice(toParts, samePartsLength)]);
  
      return outputParts.join('/');
    };
  
    exports.sep = '/';
    exports.delimiter = ':';
  }
  return exports; 
}

String dirname(String path) {
  var result = splitPath(path);
  var root = result[0];
  var dir = result[1];

  if ((root == null || root.isEmpty) && (dir == null || dir.isEmpty)) {
    // No dirname whatsoever
    return '.';
  }

  if (dir != null && dir.isNotEmpty) {
    // It has a dirname, strip trailing slash
    dir = dir.substring(0, dir.length - 1);
  }

  return root + dir;
}


String basename(String path, [String ext]) {
  var f = splitPath(path)[2];
  // TODO: make this comparison case-insensitive on windows?  
  if (ext != null && f.endsWith(ext)) {
    f = f.substring(0, f.length - ext.length);
  }
  return f;
}


String extname(String path) {
  return splitPath(path)[3];
}


void exists(String path, void callback(bool)) {
  File.isFile(path).then(callback);
}

bool existsSync (String path) {
  return File.isFileSync(path);
}

// Copyright Joyent, Inc. and other Node contributors.
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the
// 'Software'), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to permit
// persons to whom the Software is furnished to do so, subject to the
// following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
// NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
// USE OR OTHER DEALINGS IN THE SOFTWARE.

import 'dart:io';
import 'package:node_shims/node_shims.dart';
import 'package:test/test.dart' as TEST; //ignore: library_prefixes
import 'dart:convert';

void main() {
  // var splitPathRe = RegExp(
  //     r'^(\/?|)([\s\S]*?)((?:\.{1,2}|[^\/]+?|)(\.[^.\/]*|))(?:[\/]*)$');

  // splitPath(String filename) {
  //   var matches = exec(splitPathRe, filename);
  //   return slice(matches, 1);
  // }

  // var controlCharFilename = 'Icon' + String.fromCharCode(13);
//  var m = splitPathRe.firstMatch(controlCharFilename);
//  print(controlCharFilename);
//  print(m.groups([0,1,2,3]));
//  print(exec(splitPathRe, controlCharFilename));
//  print(splitPath(controlCharFilename));
//  return;

  TEST.group('path tests', () {
    var isWindows = Platform.operatingSystem == 'win32';
    print(Directory.current.path);
    var f = join([Directory.current.path, 'test_path.dart']);

    TEST.test('basename', () {
      TEST.expect(basename(f), TEST.equals('test_path.dart'));
      TEST.expect(basename(f, '.dart'), TEST.equals('test_path'));
      TEST.expect(basename(''), '');
      TEST.expect(basename('/dir/basename.ext'), TEST.equals('basename.ext'));
      TEST.expect(basename('/basename.ext'), TEST.equals('basename.ext'));
      TEST.expect(basename('basename.ext'), TEST.equals('basename.ext'));
      TEST.expect(basename('basename.ext/'), TEST.equals('basename.ext'));
      TEST.expect(basename('basename.ext//'), TEST.equals('basename.ext'));

      if (isWindows) {
        // On Windows a backslash acts as a path separator.
        TEST.expect(
            basename('\\dir\\basename.ext'), TEST.equals('basename.ext'));
        TEST.expect(basename('\\basename.ext'), TEST.equals('basename.ext'));
        TEST.expect(basename('basename.ext'), TEST.equals('basename.ext'));
        TEST.expect(basename('basename.ext\\'), TEST.equals('basename.ext'));
        TEST.expect(basename('basename.ext\\\\'), TEST.equals('basename.ext'));
      } else {
        // On unix a backslash is just treated as any other character.
        TEST.expect(basename('\\dir\\basename.ext'),
            TEST.equals('\\dir\\basename.ext'));
        TEST.expect(basename('\\basename.ext'), TEST.equals('\\basename.ext'));
        TEST.expect(basename('basename.ext'), TEST.equals('basename.ext'));
        TEST.expect(basename('basename.ext\\'), TEST.equals('basename.ext\\'));
        TEST.expect(
            basename('basename.ext\\\\'), TEST.equals('basename.ext\\\\'));
      }

      // POSIX filenames may include control characters
      // c.f. http://www.dwheeler.com/essays/fixing-unix-linux-filenames.html
      if (!isWindows) {
//        var controlCharFilename = 'Icon' + String.fromCharCode(13);
//        TEST.expect(basename('/a/b/' + controlCharFilename),
//            TEST.equals(controlCharFilename));
      }
    });

    TEST.test('dirname', () {
      TEST.expect(dirname('/a/b/'), TEST.equals('/a'));
      TEST.expect(dirname('/a/b'), TEST.equals('/a'));
      TEST.expect(dirname('/a'), TEST.equals('/'));
      TEST.expect(dirname(''), TEST.equals('.'));
      TEST.expect(dirname('/'), TEST.equals('/'));
      TEST.expect(dirname('////'), TEST.equals('/'));

      if (isWindows) {
        TEST.expect(dirname('c:\\'), TEST.equals('c:\\'));
        TEST.expect(dirname('c:\\foo'), TEST.equals('c:\\'));
        TEST.expect(dirname('c:\\foo\\'), TEST.equals('c:\\'));
        TEST.expect(dirname('c:\\foo\\bar'), TEST.equals('c:\\foo'));
        TEST.expect(dirname('c:\\foo\\bar\\'), TEST.equals('c:\\foo'));
        TEST.expect(dirname('c:\\foo\\bar\\baz'), 'c:\\foo\\bar');
        TEST.expect(dirname('\\'), TEST.equals('\\'));
        TEST.expect(dirname('\\foo'), TEST.equals('\\'));
        TEST.expect(dirname('\\foo\\'), TEST.equals('\\'));
        TEST.expect(dirname('\\foo\\bar'), TEST.equals('\\foo'));
        TEST.expect(dirname('\\foo\\bar\\'), TEST.equals('\\foo'));
        TEST.expect(dirname('\\foo\\bar\\baz'), TEST.equals('\\foo\\bar'));
        TEST.expect(dirname('c:'), TEST.equals('c:'));
        TEST.expect(dirname('c:foo'), TEST.equals('c:'));
        TEST.expect(dirname('c:foo\\'), TEST.equals('c:'));
        TEST.expect(dirname('c:foo\\bar'), TEST.equals('c:foo'));
        TEST.expect(dirname('c:foo\\bar\\'), TEST.equals('c:foo'));
        TEST.expect(dirname('c:foo\\bar\\baz'), TEST.equals('c:foo\\bar'));
        TEST.expect(dirname('\\\\unc\\share'), TEST.equals('\\\\unc\\share'));
        TEST.expect(
            dirname('\\\\unc\\share\\foo'), TEST.equals('\\\\unc\\share\\'));
        TEST.expect(
            dirname('\\\\unc\\share\\foo\\'), TEST.equals('\\\\unc\\share\\'));
        TEST.expect(dirname('\\\\unc\\share\\foo\\bar'),
            TEST.equals('\\\\unc\\share\\foo'));
        TEST.expect(dirname('\\\\unc\\share\\foo\\bar\\'),
            TEST.equals('\\\\unc\\share\\foo'));
        TEST.expect(dirname('\\\\unc\\share\\foo\\bar\\baz'),
            TEST.equals('\\\\unc\\share\\foo\\bar'));
      }
    });

    TEST.test('extname', () {
      TEST.expect(extname(f), TEST.equals('.dart'));
      TEST.expect(extname(''), TEST.equals(''));
      TEST.expect(extname('/path/to/file'), TEST.equals(''));
      TEST.expect(extname('/path/to/file.ext'), TEST.equals('.ext'));
      TEST.expect(extname('/to/file.ext'), TEST.equals('.ext'));
      TEST.expect(extname('/to/file'), TEST.equals(''));
      TEST.expect(extname('/to/.file'), TEST.equals(''));
      TEST.expect(extname('/to/.file.ext'), TEST.equals('.ext'));
      TEST.expect(extname('/path/to/f.ext'), TEST.equals('.ext'));
      TEST.expect(extname('/path/to/..ext'), TEST.equals('.ext'));
      TEST.expect(extname('file'), TEST.equals(''));
      TEST.expect(extname('file.ext'), TEST.equals('.ext'));
      TEST.expect(extname('.file'), TEST.equals(''));
      TEST.expect(extname('.file.ext'), TEST.equals('.ext'));
      TEST.expect(extname('/file'), TEST.equals(''));
      TEST.expect(extname('/file.ext'), TEST.equals('.ext'));
      TEST.expect(extname('/.file'), TEST.equals(''));
      TEST.expect(extname('/.file.ext'), TEST.equals('.ext'));
      TEST.expect(extname('.path/file.ext'), TEST.equals('.ext'));
      TEST.expect(extname('file.ext.ext'), TEST.equals('.ext'));
      TEST.expect(extname('file.'), TEST.equals('.'));
      TEST.expect(extname('.'), TEST.equals(''));
      TEST.expect(extname('./'), TEST.equals(''));
      TEST.expect(extname('.file.ext'), TEST.equals('.ext'));
      TEST.expect(extname('.file'), TEST.equals(''));
      TEST.expect(extname('.file.'), TEST.equals('.'));
      TEST.expect(extname('.file..'), TEST.equals('.'));
      TEST.expect(extname('..'), TEST.equals(''));
      TEST.expect(extname('../'), TEST.equals(''));
      TEST.expect(extname('..file.ext'), TEST.equals('.ext'));
      TEST.expect(extname('..file'), TEST.equals('.file'));
      TEST.expect(extname('..file.'), TEST.equals('.'));
      TEST.expect(extname('..file..'), TEST.equals('.'));
      TEST.expect(extname('...'), TEST.equals('.'));
      TEST.expect(extname('...ext'), TEST.equals('.ext'));
      TEST.expect(extname('....'), TEST.equals('.'));
      TEST.expect(extname('file.ext/'), TEST.equals('.ext'));
      TEST.expect(extname('file.ext//'), TEST.equals('.ext'));
      TEST.expect(extname('file/'), TEST.equals(''));
      TEST.expect(extname('file//'), TEST.equals(''));
      TEST.expect(extname('file./'), TEST.equals('.'));
      TEST.expect(extname('file.//'), TEST.equals('.'));

      if (isWindows) {
        // On windows, backspace is a path separator.
        TEST.expect(extname('.\\'), TEST.equals(''));
        TEST.expect(extname('..\\'), TEST.equals(''));
        TEST.expect(extname('file.ext\\'), TEST.equals('.ext'));
        TEST.expect(extname('file.ext\\\\'), TEST.equals('.ext'));
        TEST.expect(extname('file\\'), TEST.equals(''));
        TEST.expect(extname('file\\\\'), TEST.equals(''));
        TEST.expect(extname('file.\\'), TEST.equals('.'));
        TEST.expect(extname('file.\\\\'), TEST.equals('.'));
      } else {
        // On unix, backspace is a valid name component like any other character.
        TEST.expect(extname('.\\'), TEST.equals(''));
        TEST.expect(extname('..\\'), TEST.equals('.\\'));
        TEST.expect(extname('file.ext\\'), TEST.equals('.ext\\'));
        TEST.expect(extname('file.ext\\\\'), TEST.equals('.ext\\\\'));
        TEST.expect(extname('file\\'), TEST.equals(''));
        TEST.expect(extname('file\\\\'), TEST.equals(''));
        TEST.expect(extname('file.\\'), TEST.equals('.\\'));
        TEST.expect(extname('file.\\\\'), TEST.equals('.\\\\'));
      }
    });

    TEST.test('join', () {
      /// join tests
      var failures = [];
      var joinTests =
          // arguments                     result
          [
        [
          ['.', 'x/b', '..', '/b/c.js'],
          ['x/b/c.js']
        ],
        [
          ['/.', 'x/b', '..', '/b/c.js'],
          ['/x/b/c.js']
        ],
        [
          ['/foo', '../../../bar'],
          ['/bar']
        ],
        [
          ['foo', '../../../bar'],
          ['../../bar']
        ],
        [
          ['foo/', '../../../bar'],
          ['../../bar']
        ],
        [
          ['foo/x', '../../../bar'],
          ['../bar']
        ],
        [
          ['foo/x', './bar'],
          ['foo/x/bar']
        ],
        [
          ['foo/x/', './bar'],
          ['foo/x/bar']
        ],
        [
          ['foo/x/', '.', 'bar'],
          ['foo/x/bar']
        ],
        [
          ['./'],
          ['./']
        ],
        [
          ['.', './'],
          ['./']
        ],
        [
          ['.', '.', '.'],
          ['.']
        ],
        [
          ['.', './', '.'],
          ['.']
        ],
        [
          ['.', '/./', '.'],
          ['.']
        ],
        [
          ['.', '/////./', '.'],
          ['.']
        ],
        [
          ['.'],
          ['.']
        ],
        [
          ['', '.'],
          ['.']
        ],
        [
          ['', 'foo'],
          ['foo']
        ],
        [
          ['foo', '/bar'],
          ['foo/bar']
        ],
        [
          ['', '/foo'],
          ['/foo']
        ],
        [
          ['', '', '/foo'],
          ['/foo']
        ],
        [
          ['', '', 'foo'],
          ['foo']
        ],
        [
          ['foo', ''],
          ['foo']
        ],
        [
          ['foo/', ''],
          ['foo/']
        ],
        [
          ['foo', '', '/bar'],
          ['foo/bar']
        ],
        [
          ['./', '..', '/foo'],
          ['../foo']
        ],
        [
          ['./', '..', '..', '/foo'],
          ['../../foo']
        ],
        [
          ['.', '..', '..', '/foo'],
          ['../../foo']
        ],
        [
          ['', '..', '..', '/foo'],
          ['../../foo']
        ],
        [
          ['/'],
          ['/']
        ],
        [
          ['/', '.'],
          ['/']
        ],
        [
          ['/', '..'],
          ['/']
        ],
        [
          ['/', '..', '..'],
          ['/']
        ],
        [
          [''],
          ['.']
        ],
        [
          ['', ''],
          ['.']
        ],
        [
          [' /foo'],
          [' /foo']
        ],
        [
          [' ', 'foo'],
          [' /foo']
        ],
        [
          [' ', '.'],
          [' ']
        ],
        [
          [' ', '/'],
          [' /']
        ],
        [
          [' ', ''],
          [' ']
        ],
        [
          ['/', 'foo'],
          ['/foo']
        ],
        [
          ['/', '/foo'],
          ['/foo']
        ],
        [
          ['/', '//foo'],
          ['/foo']
        ],
        [
          ['/', '', '/foo'],
          ['/foo']
        ],
        [
          ['', '/', 'foo'],
          ['/foo']
        ],
        [
          ['', '/', '/foo'],
          ['/foo']
        ]
      ];

      /// Windows-specific join tests
      if (isWindows) {
        joinTests.addAll([
          // UNC path TEST.expected
          [
            ['//foo/bar'],
            ['//foo/bar/']
          ],
          [
            ['\\/foo/bar'],
            ['//foo/bar/']
          ],
          [
            ['\\\\foo/bar'],
            ['//foo/bar/']
          ],
          // UNC path TEST.expected - server and share separate
          [
            ['//foo', 'bar'],
            ['//foo/bar/']
          ],
          [
            ['//foo/', 'bar'],
            ['//foo/bar/']
          ],
          [
            ['//foo', '/bar'],
            ['//foo/bar/']
          ],
          // UNC path TEST.expected - questionable
          [
            ['//foo', '', 'bar'],
            ['//foo/bar/']
          ],
          [
            ['//foo/', '', 'bar'],
            ['//foo/bar/']
          ],
          [
            ['//foo/', '', '/bar'],
            ['//foo/bar/']
          ],
          // UNC path TEST.expected - even more questionable
          [
            ['', '//foo', 'bar'],
            ['//foo/bar/']
          ],
          [
            ['', '//foo/', 'bar'],
            ['//foo/bar/']
          ],
          [
            ['', '//foo/', '/bar'],
            ['//foo/bar/']
          ],
          // No UNC path TEST.expected (no double slash in first component)
          [
            ['\\', 'foo/bar'],
            ['/foo/bar']
          ],
          [
            ['\\', '/foo/bar'],
            ['/foo/bar']
          ],
          [
            ['', '/', '/foo/bar'],
            ['/foo/bar']
          ],
          // No UNC path TEST.expected (no non-slashes in first component - questionable)
          [
            ['//', 'foo/bar'],
            ['/foo/bar']
          ],
          [
            ['//', '/foo/bar'],
            ['/foo/bar']
          ],
          [
            ['\\\\', '/', '/foo/bar'],
            ['/foo/bar']
          ],
          [
            ['//'],
            ['/']
          ],
          // No UNC path TEST.expected (share name missing - questionable).
          [
            ['//foo'],
            ['/foo']
          ],
          [
            ['//foo/'],
            ['/foo/']
          ],
          [
            ['//foo', '/'],
            ['/foo/']
          ],
          [
            ['//foo', '', '/'],
            ['/foo/']
          ],
          // No UNC path TEST.expected (too many leading slashes - questionable)
          [
            ['///foo/bar'],
            ['/foo/bar']
          ],
          [
            ['////foo', 'bar'],
            ['/foo/bar']
          ],
          [
            ['\\\\\\/foo/bar'],
            ['/foo/bar']
          ],
          // Drive-relative vs drive-absolute paths. This merely describes the
          // status quo, rather than being obviously right
          [
            ['c:'],
            ['c:.']
          ],
          [
            ['c:.'],
            ['c:.']
          ],
          [
            ['c:', ''],
            ['c:.']
          ],
          [
            ['', 'c:'],
            ['c:.']
          ],
          [
            ['c:.', '/'],
            ['c:./']
          ],
          [
            ['c:.', 'file'],
            ['c:file']
          ],
          [
            ['c:', '/'],
            ['c:/']
          ],
          [
            ['c:', 'file'],
            ['c:/file']
          ]
        ]);
      }
      var jtCounter = 0;

      /// Run the join tests.
      joinTests.forEach((t) {
        var actual = join(t[0]);
        var expected =
            // TODO: check the addition of .toString()
            isWindows ? t[1][0].replaceAll(RegExp(r'\/'), '\\') : t[1][0];
        var message = 'join(' +
            // TODO: test the addition of as List
            t[0].map(json.encode).join(',') +
            ')' +
            '\n  TEST.expect=' +
            json.encode(expected) +
            '\n  actual=' +
            json.encode(actual);
        if (actual != expected) failures.add('\n' + message);
        // TEST.expect(actual, TEST.expected, message);

        TEST.expect(failures.length, TEST.equals(0), reason: failures.join());

        jtCounter++;
      });
    });

    TEST.test('normalize', () {
      //// path normalize tests
      if (isWindows) {
        TEST.expect(normalize('./fixtures///b/../b/c.js'),
            TEST.equals('fixtures\\b\\c.js'));
        TEST.expect(normalize('/foo/../../../bar'), TEST.equals('\\bar'));
        TEST.expect(normalize('a//b//../b'), TEST.equals('a\\b'));
        TEST.expect(normalize('a//b//./c'), TEST.equals('a\\b\\c'));
        TEST.expect(normalize('a//b//.'), TEST.equals('a\\b'));
        TEST.expect(normalize('//server/share/dir/file.ext'),
            TEST.equals('\\\\server\\share\\dir\\file.ext'));
      } else {
        TEST.expect(normalize('./fixtures///b/../b/c.js'),
            TEST.equals('fixtures/b/c.js'));
        TEST.expect(normalize('/foo/../../../bar'), TEST.equals('/bar'));
        TEST.expect(normalize('a//b//../b'), TEST.equals('a/b'));
        TEST.expect(normalize('a//b//./c'), TEST.equals('a/b/c'));
        TEST.expect(normalize('a//b//.'), TEST.equals('a/b'));
      }
    });

    TEST.test('resolve', () {
      //// resolve tests
      var resolveTests = [];
      if (isWindows) {
        // windows
        resolveTests =
            // arguments                                    result
            [
          [
            ['c:/blah\\blah', 'd:/games', 'c:../a'],
            ['c:\\blah\\a']
          ],
          [
            ['c:/ignore', 'd:\\a/b\\c/d', '\\e.exe'],
            ['d:\\e.exe']
          ],
          [
            ['c:/ignore', 'c:/some/file'],
            ['c:\\some\\file']
          ],
          [
            ['d:/ignore', 'd:some/dir//'],
            ['d:\\ignore\\some\\dir']
          ],
          [
            ['.'],
            [cwd()]
          ],
          [
            ['//server/share', '..', 'relative\\'],
            ['\\\\server\\share\\relative']
          ],
          [
            ['c:/', '//'],
            ['c:\\']
          ],
          [
            ['c:/', '//dir'],
            ['c:\\dir']
          ],
          [
            ['c:/', '//server/share'],
            ['\\\\server\\share\\']
          ],
          [
            ['c:/', '//server//share'],
            ['\\\\server\\share\\']
          ],
          [
            ['c:/', '///some//dir'],
            ['c:\\some\\dir']
          ]
        ];
      } else {
        // Posix
        resolveTests =
            // arguments                                    result
            [
          [
            ['/var/lib', '../', 'file/'],
            ['/var/file']
          ],
          [
            ['/var/lib', '/../', 'file/'],
            ['/file']
          ],
          [
            ['a/b/c/', '../../..'],
            [cwd()]
          ],
          [
            ['.'],
            [cwd()]
          ],
          [
            ['/some/dir', '.', '/absolute/'],
            ['/absolute']
          ]
        ];
      }
      var failures = [];
      // var rtCounter = 0;
      resolveTests.forEach((t) {
        var actual = resolve(t[0]);
        var expected = t[1][0];
        var message = 'resolve(' +
            t[0].map(json.encode).join(',') +
            ')' +
            '\n  TEST.expect=' +
            json.encode(expected) +
            '\n  actual=' +
            json.encode(actual);
        if (actual != expected) push(failures, '\n' + message);
        // TEST.expect(actual, TEST.expected, message);
      });

      TEST.expect(failures.length, TEST.equals(0), reason: failures.join(''));
    });

    TEST.test('isAbsolute', () {
      // isAbsolute tests
      if (isWindows) {
        TEST.expect(isAbsolute('//server/file'), TEST.equals(true));
        TEST.expect(isAbsolute('\\\\server\\file'), TEST.equals(true));
        TEST.expect(isAbsolute('C:/Users/'), TEST.equals(true));
        TEST.expect(isAbsolute('C:\\Users\\'), TEST.equals(true));
        TEST.expect(isAbsolute('C:cwd/another'), TEST.equals(false));
        TEST.expect(isAbsolute('C:cwd\\another'), TEST.equals(false));
        TEST.expect(isAbsolute('directory/directory'), TEST.equals(false));
        TEST.expect(isAbsolute('directory\\directory'), TEST.equals(false));
      } else {
        TEST.expect(isAbsolute('/home/foo'), TEST.equals(true));
        TEST.expect(isAbsolute('/home/foo/..'), TEST.equals(true));
        TEST.expect(isAbsolute('bar/'), TEST.equals(false));
        TEST.expect(isAbsolute('./baz'), TEST.equals(false));
      }
    });

    TEST.test('relative', () {
      // relative tests
      var relativeTests = [];
      if (isWindows) {
        // windows
        relativeTests =
            // arguments                     result
            [
          ['c:/blah\\blah', 'd:/games', 'd:\\games'],
          ['c:/aaaa/bbbb', 'c:/aaaa', '..'],
          ['c:/aaaa/bbbb', 'c:/cccc', '..\\..\\cccc'],
          ['c:/aaaa/bbbb', 'c:/aaaa/bbbb', ''],
          ['c:/aaaa/bbbb', 'c:/aaaa/cccc', '..\\cccc'],
          ['c:/aaaa/', 'c:/aaaa/cccc', 'cccc'],
          ['c:/', 'c:\\aaaa\\bbbb', 'aaaa\\bbbb'],
          ['c:/aaaa/bbbb', 'd:\\', 'd:\\']
        ];
      } else {
        // posix
        relativeTests =
            // arguments                    result
            [
          ['/var/lib', '/var', '..'],
          ['/var/lib', '/bin', '../../bin'],
          ['/var/lib', '/var/lib', ''],
          ['/var/lib', '/var/apache', '../apache'],
          ['/var/', '/var/lib', 'lib'],
          ['/', '/var/lib', 'var/lib']
        ];
      }
      var failures = [];
      relativeTests.forEach((t) {
        var actual = relative(t[0], t[1]);
        var expected = t[2];
        var message = 'relative(' +
            slice(t, 0, 2).map(json.encode).join(',') +
            ')' +
            '\n  TEST.expect=' +
            json.encode(expected) +
            '\n  actual=' +
            json.encode(actual);
        if (actual != expected) push(failures, '\n' + message);
      });
      TEST.expect(failures.length, TEST.equals(0), reason: failures.join(''));
    });

    TEST.test('sep', () {
      // sep tests
      if (isWindows) {
        // windows
        TEST.expect(sep, TEST.equals('\\'));
      } else {
        // posix
        TEST.expect(sep, '/');
      }
    });

    TEST.test('delimiter', () {
      // delimiter tests
      if (isWindows) {
        // windows
        TEST.expect(delimiter, ';');
      } else {
        // posix
        TEST.expect(delimiter, ':');
      }
    });
  });
}

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

import "dart:io";
import "package:unittest/unittest.dart";
import "package:node_shims/path.dart" as path; 
import "dart:json" as JSON;

main(){
  group('path tests',(){
    var isWindows = Platform.operatingSystem == 'win32';
    print(Directory.current.path);
    var f = path.join([Directory.current.path, "test_path.dart"]);
    
    test('basename',(){

      expect(path.basename(f), equals('test_path.dart'));
      expect(path.basename(f, '.dart'), equals('test_path'));
      expect(path.basename(''), '');
      expect(path.basename('/dir/basename.ext'), equals('basename.ext'));
      expect(path.basename('/basename.ext'), equals('basename.ext'));
      expect(path.basename('basename.ext'), equals('basename.ext'));
      expect(path.basename('basename.ext/'), equals('basename.ext'));
      expect(path.basename('basename.ext//'), equals('basename.ext'));

      if (isWindows) {
        // On Windows a backslash acts as a path separator.
        expect(path.basename('\\dir\\basename.ext'), equals('basename.ext'));
        expect(path.basename('\\basename.ext'), equals('basename.ext'));
        expect(path.basename('basename.ext'), equals('basename.ext'));
        expect(path.basename('basename.ext\\'), equals('basename.ext'));
        expect(path.basename('basename.ext\\\\'), equals('basename.ext'));

      } else {
        // On unix a backslash is just treated as any other character.
        expect(path.basename('\\dir\\basename.ext'), equals('\\dir\\basename.ext'));
        expect(path.basename('\\basename.ext'), equals('\\basename.ext'));
        expect(path.basename('basename.ext'), equals('basename.ext'));
        expect(path.basename('basename.ext\\'), equals('basename.ext\\'));
        expect(path.basename('basename.ext\\\\'), equals('basename.ext\\\\'));
      }

      // POSIX filenames may include control characters
      // c.f. http://www.dwheeler.com/essays/fixing-unix-linux-filenames.html
      if (!isWindows) {
        var controlCharFilename = 'Icon' + new String.fromCharCode(13);
        expect(path.basename('/a/b/' + controlCharFilename),
            equals(controlCharFilename));
      }
   });

    
    test('dirname',(){

      expect(path.dirname('/a/b/'), equals('/a'));
      expect(path.dirname('/a/b'), equals('/a'));
      expect(path.dirname('/a'), equals('/'));
      expect(path.dirname(''), equals('.'));
      expect(path.dirname('/'), equals('/'));
      expect(path.dirname('////'), equals('/'));

      if (isWindows) {
        expect(path.dirname('c:\\'), equals('c:\\'));
        expect(path.dirname('c:\\foo'), equals('c:\\'));
        expect(path.dirname('c:\\foo\\'), equals('c:\\'));
        expect(path.dirname('c:\\foo\\bar'), equals('c:\\foo'));
        expect(path.dirname('c:\\foo\\bar\\'), equals('c:\\foo'));
        expect(path.dirname('c:\\foo\\bar\\baz'), 'c:\\foo\\bar');
        expect(path.dirname('\\'), equals('\\'));
        expect(path.dirname('\\foo'), equals('\\'));
        expect(path.dirname('\\foo\\'), equals('\\'));
        expect(path.dirname('\\foo\\bar'), equals('\\foo'));
        expect(path.dirname('\\foo\\bar\\'), equals('\\foo'));
        expect(path.dirname('\\foo\\bar\\baz'), equals('\\foo\\bar'));
        expect(path.dirname('c:'), equals('c:'));
        expect(path.dirname('c:foo'), equals('c:'));
        expect(path.dirname('c:foo\\'), equals('c:'));
        expect(path.dirname('c:foo\\bar'), equals('c:foo'));
        expect(path.dirname('c:foo\\bar\\'), equals('c:foo'));
        expect(path.dirname('c:foo\\bar\\baz'), equals('c:foo\\bar'));
        expect(path.dirname('\\\\unc\\share'), equals('\\\\unc\\share'));
        expect(path.dirname('\\\\unc\\share\\foo'), equals('\\\\unc\\share\\'));
        expect(path.dirname('\\\\unc\\share\\foo\\'), equals('\\\\unc\\share\\'));
        expect(path.dirname('\\\\unc\\share\\foo\\bar'), equals('\\\\unc\\share\\foo'));
        expect(path.dirname('\\\\unc\\share\\foo\\bar\\'), equals('\\\\unc\\share\\foo'));
        expect(path.dirname('\\\\unc\\share\\foo\\bar\\baz'), equals('\\\\unc\\share\\foo\\bar'));
      }      
    });


    test('extname',(){
      expect(path.extname(f), equals('.dart'));
      expect(path.extname(''), equals(''));
      expect(path.extname('/path/to/file'), equals(''));
      expect(path.extname('/path/to/file.ext'), equals('.ext'));
      expect(path.extname('/path.to/file.ext'), equals('.ext'));
      expect(path.extname('/path.to/file'), equals(''));
      expect(path.extname('/path.to/.file'), equals(''));
      expect(path.extname('/path.to/.file.ext'), equals('.ext'));
      expect(path.extname('/path/to/f.ext'), equals('.ext'));
      expect(path.extname('/path/to/..ext'), equals('.ext'));
      expect(path.extname('file'), equals(''));
      expect(path.extname('file.ext'), equals('.ext'));
      expect(path.extname('.file'), equals(''));
      expect(path.extname('.file.ext'), equals('.ext'));
      expect(path.extname('/file'), equals(''));
      expect(path.extname('/file.ext'), equals('.ext'));
      expect(path.extname('/.file'), equals(''));
      expect(path.extname('/.file.ext'), equals('.ext'));
      expect(path.extname('.path/file.ext'), equals('.ext'));
      expect(path.extname('file.ext.ext'), equals('.ext'));
      expect(path.extname('file.'), equals('.'));
      expect(path.extname('.'), equals(''));
      expect(path.extname('./'), equals(''));
      expect(path.extname('.file.ext'), equals('.ext'));
      expect(path.extname('.file'), equals(''));
      expect(path.extname('.file.'), equals('.'));
      expect(path.extname('.file..'), equals('.'));
      expect(path.extname('..'), equals(''));
      expect(path.extname('../'), equals(''));
      expect(path.extname('..file.ext'), equals('.ext'));
      expect(path.extname('..file'), equals('.file'));
      expect(path.extname('..file.'), equals('.'));
      expect(path.extname('..file..'), equals('.'));
      expect(path.extname('...'), equals('.'));
      expect(path.extname('...ext'), equals('.ext'));
      expect(path.extname('....'), equals('.'));
      expect(path.extname('file.ext/'), equals('.ext'));
      expect(path.extname('file.ext//'), equals('.ext'));
      expect(path.extname('file/'), equals(''));
      expect(path.extname('file//'), equals(''));
      expect(path.extname('file./'), equals('.'));
      expect(path.extname('file.//'), equals('.'));

      if (isWindows) {
        // On windows, backspace is a path separator.
        expect(path.extname('.\\'), equals(''));
        expect(path.extname('..\\'), equals(''));
        expect(path.extname('file.ext\\'), equals('.ext'));
        expect(path.extname('file.ext\\\\'), equals('.ext'));
        expect(path.extname('file\\'), equals(''));
        expect(path.extname('file\\\\'), equals(''));
        expect(path.extname('file.\\'), equals('.'));
        expect(path.extname('file.\\\\'), equals('.'));

      } else {
        // On unix, backspace is a valid name component like any other character.
        expect(path.extname('.\\'), equals(''));
        expect(path.extname('..\\'), equals('.\\'));
        expect(path.extname('file.ext\\'), equals('.ext\\'));
        expect(path.extname('file.ext\\\\'), equals('.ext\\\\'));
        expect(path.extname('file\\'), equals(''));
        expect(path.extname('file\\\\'), equals(''));
        expect(path.extname('file.\\'), equals('.\\'));
        expect(path.extname('file.\\\\'), equals('.\\\\'));
      }
    });
    
    test('join', (){
      
    });
    
    /// path.join tests
    var failures = [];
    var joinTests =
        // arguments                     result
        [[['.', 'x/b', '..', '/b/c.js'], 'x/b/c.js'],
         [['/.', 'x/b', '..', '/b/c.js'], '/x/b/c.js'],
         [['/foo', '../../../bar'], '/bar'],
         [['foo', '../../../bar'], '../../bar'],
         [['foo/', '../../../bar'], '../../bar'],
         [['foo/x', '../../../bar'], '../bar'],
         [['foo/x', './bar'], 'foo/x/bar'],
         [['foo/x/', './bar'], 'foo/x/bar'],
         [['foo/x/', '.', 'bar'], 'foo/x/bar'],
         [['./'], './'],
         [['.', './'], './'],
         [['.', '.', '.'], '.'],
         [['.', './', '.'], '.'],
         [['.', '/./', '.'], '.'],
         [['.', '/////./', '.'], '.'],
         [['.'], '.'],
         [['', '.'], '.'],
         [['', 'foo'], 'foo'],
         [['foo', '/bar'], 'foo/bar'],
         [['', '/foo'], '/foo'],
         [['', '', '/foo'], '/foo'],
         [['', '', 'foo'], 'foo'],
         [['foo', ''], 'foo'],
         [['foo/', ''], 'foo/'],
         [['foo', '', '/bar'], 'foo/bar'],
         [['./', '..', '/foo'], '../foo'],
         [['./', '..', '..', '/foo'], '../../foo'],
         [['.', '..', '..', '/foo'], '../../foo'],
         [['', '..', '..', '/foo'], '../../foo'],
         [['/'], '/'],
         [['/', '.'], '/'],
         [['/', '..'], '/'],
         [['/', '..', '..'], '/'],
         [[''], '.'],
         [['', ''], '.'],
         [[' /foo'], ' /foo'],
         [[' ', 'foo'], ' /foo'],
         [[' ', '.'], ' '],
         [[' ', '/'], ' /'],
         [[' ', ''], ' '],
         [['/', 'foo'], '/foo'],
         [['/', '/foo'], '/foo'],
         [['/', '//foo'], '/foo'],
         [['/', '', '/foo'], '/foo'],
         [['', '/', 'foo'], '/foo'],
         [['', '/', '/foo'], '/foo']
        ];

    /// Windows-specific join tests
    if (isWindows) {
      joinTests.addAll(
          [// UNC path expected
           [['//foo/bar'], '//foo/bar/'],
           [['\\/foo/bar'], '//foo/bar/'],
           [['\\\\foo/bar'], '//foo/bar/'],
           // UNC path expected - server and share separate
           [['//foo', 'bar'], '//foo/bar/'],
           [['//foo/', 'bar'], '//foo/bar/'],
           [['//foo', '/bar'], '//foo/bar/'],
           // UNC path expected - questionable
           [['//foo', '', 'bar'], '//foo/bar/'],
           [['//foo/', '', 'bar'], '//foo/bar/'],
           [['//foo/', '', '/bar'], '//foo/bar/'],
           // UNC path expected - even more questionable
           [['', '//foo', 'bar'], '//foo/bar/'],
           [['', '//foo/', 'bar'], '//foo/bar/'],
           [['', '//foo/', '/bar'], '//foo/bar/'],
           // No UNC path expected (no double slash in first component)
           [['\\', 'foo/bar'], '/foo/bar'],
           [['\\', '/foo/bar'], '/foo/bar'],
           [['', '/', '/foo/bar'], '/foo/bar'],
           // No UNC path expected (no non-slashes in first component - questionable)
           [['//', 'foo/bar'], '/foo/bar'],
           [['//', '/foo/bar'], '/foo/bar'],
           [['\\\\', '/', '/foo/bar'], '/foo/bar'],
           [['//'], '/'],
           // No UNC path expected (share name missing - questionable).
           [['//foo'], '/foo'],
           [['//foo/'], '/foo/'],
           [['//foo', '/'], '/foo/'],
           [['//foo', '', '/'], '/foo/'],
           // No UNC path expected (too many leading slashes - questionable)
           [['///foo/bar'], '/foo/bar'],
           [['////foo', 'bar'], '/foo/bar'],
           [['\\\\\\/foo/bar'], '/foo/bar'],
           // Drive-relative vs drive-absolute paths. This merely describes the
           // status quo, rather than being obviously right
           [['c:'], 'c:.'],
           [['c:.'], 'c:.'],
           [['c:', ''], 'c:.'],
           [['', 'c:'], 'c:.'],
           [['c:.', '/'], 'c:./'],
           [['c:.', 'file'], 'c:file'],
           [['c:', '/'], 'c:/'],
           [['c:', 'file'], 'c:/file']
           ]);
    }

    /// Run the join tests.
    joinTests.forEach((test) {
      var actual = path.join(test[0]);
      var expected = isWindows ? test[1].replaceAll(new RegExp(r"\/"), '\\') : test[1];
          var message = 'path.join(' + test[0].map(JSON.stringify).join(',') + ')' +
          '\n  expect=' + JSON.stringify(expected) +
          '\n  actual=' + JSON.stringify(actual);
      if (actual != expected) failures.add('\n' + message);
      // expect(actual, expected, message);
    });
    expect(failures.length, equals(0), reason:failures.join(''));
    
//    var joinThrowTests = [true, false, 7, null, {}, [], double.NAN];
//    joinThrowTests.forEach((test) {
//      assert.throws(() {
//        path.join(test);
//      }, TypeError);
//      assert.throws(() {
//        path.resolve(test);
//      }, TypeError);
//    });


//// path normalize tests
//      if (isWindows) {
//        expect(path.normalize('./fixtures///b/../b/c.js'),
//        'fixtures\\b\\c.js');
//        expect(path.normalize('/foo/../../../bar'), '\\bar');
//        expect(path.normalize('a//b//../b'), 'a\\b');
//        expect(path.normalize('a//b//./c'), 'a\\b\\c');
//        expect(path.normalize('a//b//.'), 'a\\b');
//        expect(path.normalize('//server/share/dir/file.ext'),
//        '\\\\server\\share\\dir\\file.ext');
//      } else {
//        expect(path.normalize('./fixtures///b/../b/c.js'),
//        'fixtures/b/c.js');
//        expect(path.normalize('/foo/../../../bar'), '/bar');
//        expect(path.normalize('a//b//../b'), 'a/b');
//        expect(path.normalize('a//b//./c'), 'a/b/c');
//        expect(path.normalize('a//b//.'), 'a/b');
//      }
//
//// path.resolve tests
//      if (isWindows) {
//        // windows
//        var resolveTests =
//            // arguments                                    result
//            [[['c:/blah\\blah', 'd:/games', 'c:../a'], 'c:\\blah\\a'],
//             [['c:/ignore', 'd:\\a/b\\c/d', '\\e.exe'], 'd:\\e.exe'],
//             [['c:/ignore', 'c:/some/file'], 'c:\\some\\file'],
//             [['d:/ignore', 'd:some/dir//'], 'd:\\ignore\\some\\dir'],
//             [['.'], process.cwd()],
//             [['//server/share', '..', 'relative\\'], '\\\\server\\share\\relative'],
//             [['c:/', '//'], 'c:\\'],
//             [['c:/', '//dir'], 'c:\\dir'],
//             [['c:/', '//server/share'], '\\\\server\\share\\'],
//             [['c:/', '//server//share'], '\\\\server\\share\\'],
//             [['c:/', '///some//dir'], 'c:\\some\\dir']
//            ];
//      } else {
//        // Posix
//        var resolveTests =
//            // arguments                                    result
//            [[['/var/lib', '../', 'file/'], '/var/file'],
//             [['/var/lib', '/../', 'file/'], '/file'],
//             [['a/b/c/', '../../..'], process.cwd()],
//             [['.'], process.cwd()],
//             [['/some/dir', '.', '/absolute/'], '/absolute']];
//      }
//      var failures = [];
//      resolveTests.forEach(function(test) {
//        var actual = path.resolve.apply(path, test[0]);
//        var expected = test[1];
//        var message = 'path.resolve(' + test[0].map(JSON.stringify).join(',') + ')' +
//            '\n  expect=' + JSON.stringify(expected) +
//            '\n  actual=' + JSON.stringify(actual);
//        if (actual != expected) failures.push('\n' + message);
//        // expect(actual, expected, message);
//      });
//      expect(failures.length, 0, failures.join(''));
//
//// path.isAbsolute tests
//      if (isWindows) {
//        expect(path.isAbsolute('//server/file'), true);
//        expect(path.isAbsolute('\\\\server\\file'), true);
//        expect(path.isAbsolute('C:/Users/'), true);
//        expect(path.isAbsolute('C:\\Users\\'), true);
//        expect(path.isAbsolute('C:cwd/another'), false);
//        expect(path.isAbsolute('C:cwd\\another'), false);
//        expect(path.isAbsolute('directory/directory'), false);
//        expect(path.isAbsolute('directory\\directory'), false);
//      } else {
//        expect(path.isAbsolute('/home/foo'), true);
//        expect(path.isAbsolute('/home/foo/..'), true);
//        expect(path.isAbsolute('bar/'), false);
//        expect(path.isAbsolute('./baz'), false);
//      }
//
//// path.relative tests
//      if (isWindows) {
//        // windows
//        var relativeTests =
//            // arguments                     result
//            [['c:/blah\\blah', 'd:/games', 'd:\\games'],
//             ['c:/aaaa/bbbb', 'c:/aaaa', '..'],
//             ['c:/aaaa/bbbb', 'c:/cccc', '..\\..\\cccc'],
//             ['c:/aaaa/bbbb', 'c:/aaaa/bbbb', ''],
//             ['c:/aaaa/bbbb', 'c:/aaaa/cccc', '..\\cccc'],
//             ['c:/aaaa/', 'c:/aaaa/cccc', 'cccc'],
//             ['c:/', 'c:\\aaaa\\bbbb', 'aaaa\\bbbb'],
//             ['c:/aaaa/bbbb', 'd:\\', 'd:\\']];
//      } else {
//        // posix
//        var relativeTests =
//            // arguments                    result
//            [['/var/lib', '/var', '..'],
//             ['/var/lib', '/bin', '../../bin'],
//             ['/var/lib', '/var/lib', ''],
//             ['/var/lib', '/var/apache', '../apache'],
//             ['/var/', '/var/lib', 'lib'],
//             ['/', '/var/lib', 'var/lib']];
//      }
//      var failures = [];
//      relativeTests.forEach(function(test) {
//        var actual = path.relative(test[0], test[1]);
//        var expected = test[2];
//        var message = 'path.relative(' +
//            test.slice(0, 2).map(JSON.stringify).join(',') +
//            ')' +
//            '\n  expect=' + JSON.stringify(expected) +
//            '\n  actual=' + JSON.stringify(actual);
//        if (actual != expected) failures.push('\n' + message);
//      });
//      expect(failures.length, 0, failures.join(''));
//
//// path.sep tests
//      if (isWindows) {
//        // windows
//        expect(path.sep, equals('\\'));
//      } else {
//        // posix
//        expect(path.sep, '/');
//      }
//
//// path.delimiter tests
//      if (isWindows) {
//        // windows
//        expect(path.delimiter, ';');
//      } else {
//        // posix
//        expect(path.delimiter, ':');
//      }    
  });  
}



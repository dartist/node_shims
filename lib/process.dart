library process;

import "dart:io";

cwd() => Directory.current.path;

Map<String,String> env = Platform.environment;

get path => new Options().script;
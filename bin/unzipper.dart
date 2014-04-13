library pub_serv_impl;
import 'dart:io' as Io;
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;
/**
 * extract gz file and put to proxy folder
 * monitor folder event and automatic move file to target proxy folder
 */
class PubLibExtractor{

//repository folder
String reposDir ;
//folder store library that extracted and processed
String finishDir ;
// folder that store library download from browser
String inputDir;
/**
 * perodic load package
 *
 *
 */
 PubLibExtractor({this.reposDir : '/Users/peter/dart/proxy',
                  this.finishDir:'/Users/peter/dart/proxy_finish' ,
                  this.inputDir : '/Users/peter/dart/proxy_tmp'}) {

  _createEnv();
  //list files in proxy_download
  Io.Directory dir = new Io.Directory(inputDir);
  dir.watch(events:Io.FileSystemEvent.CREATE).forEach((var evnt){
    if(evnt.path.endsWith('.tar.gz')){
      print('proess:' + evnt.path);
      _processOneGz(path.basename(evnt.path));
    }
  });
  dir.list(followLinks: false).forEach((Io.FileSystemEntity fse) {
    if (fse.path.endsWith('.tar.gz')) {
      print('proess:' + fse.path);
      _processOneGz(path.basename(fse.path));
    }
  });
}
/**
 * recreate gz folder
 */
_processOneGz(String inputFile) {
  //should create folder lists/0.0.3
  //move file to 0.0.3 and rename to lists.tar.gz
  String packageName = inputFile.split('-').first;
  String versionName = inputFile.split('-').last.replaceFirst('.tar.gz', '');
  String destDir = path.join(reposDir, packageName, versionName);
  new Io.Directory(destDir).createSync(recursive: true);


  Io.File f = new Io.File(path.join(inputDir, inputFile));
  List<int> bytes = f.readAsBytesSync();

  // Decode the Zip file
  Archive archive = new TarDecoder().decodeBytes(new GZipDecoder().decodeBytes(bytes));

  // Extract the contents of the Zip archive to disk.
  for (ArchiveFile file in archive) {
    String filename = file.name;
    if (filename == 'pubspec.yaml') {
      List<int> data = file.content;
      new Io.File(path.join(destDir, filename))
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      break;
    }
  }

  f.copySync(path.join(destDir, packageName + '.tar.gz'));

  f.renameSync(path.join(finishDir, inputFile));
}
_createEnv() {
  new Io.Directory(reposDir).createSync(recursive: true);
  new Io.Directory(finishDir).createSync(recursive: true);
}
}
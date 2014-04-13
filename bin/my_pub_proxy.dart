import 'package:logging/logging.dart';
import 'package:pub_proxy_server/pub_proxy_server.dart';
import 'dart:io';
import 'unzipper.dart';
void main() {
  initLog();
  PermissionStore store = new PermissionStore();
  store.addPermission(new UserPermission("me", "mypassword"));
 // store.addPermission(new UserPermission("me@gmail.com", "")); //necessary to publish

  var repos = [new PubRepoImpl(new Store(new StoreSettings.fromDir("/Users/peter/dart/proxy","/Users/peter/dart/proxy_tmp")))
                 ,new DartLangRemoteRepo(new Store(new StoreSettings.fromRepoDirPrefix('cache')), new HttpClient())];
  PubFederatedRepo pubrepo = new PubFederatedRepo(repos);
  //start_pub_proxy_server(pubrepo, port:8042, permissionStore:store, isSecure:false);
  start_pub_proxy_server(pubrepo, port:8042, isSecure:false);
  new PubLibExtractor();
//  InitializeSSL();
//  start_pub_proxy_server(pubrepo, port:443, permissionStore:store, isSecure:true);
}

initLog(){
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}:${rec.loggerName}: ${rec.time}: ${rec.message}');
    if (rec.error != null) print(rec.error);
    if (rec.stackTrace != null) print(rec.stackTrace);
  });
}

void InitializeSSL() {
  var testPkcertDatabase = Platform.script.resolve('pkcert').toFilePath();
  SecureSocket.initialize(database: testPkcertDatabase, password: 'a');
}

//class MyPermissionStore extends PermissionStore{
//  final Logger log = new Logger('PermissionStore');
//  List<UserPermission> _userPermissions = [];
//
//  bool isValidUser(username, password){
//    return true;
//  }
//
//  bool isValideUserName(String email){
//    return true;
//  }
//
//  addPermission(UserPermission perm){
//    _userPermissions.add(perm);
//  }
//
//}
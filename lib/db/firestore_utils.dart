import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proxy_core/core.dart';

class FirestoreUtils {
  static const String PROXY_UNIVERSE_NODE = "universe";

  static DocumentReference accountRootRef(String accountId, {String proxyUniverse}) {
    assert(accountId != null);
    final root = Firestore.instance.collection('accounts').document(accountId);
    if (proxyUniverse == null || proxyUniverse == ProxyUniverse.PRODUCTION) {
      return root;
    } else {
      return root.collection(PROXY_UNIVERSE_NODE).document(proxyUniverse);
    }
  }

  static DocumentReference userRootRef(String uid) {
    assert(uid != null);
    return Firestore.instance.collection('users').document('$uid');
  }
}

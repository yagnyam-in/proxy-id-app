import 'package:meta/meta.dart';
import 'package:proxy_id/config/app_configuration.dart';
import 'package:proxy_id/identity/model/deposit_entity.dart';
import 'package:proxy_id/identity/model/payment_authorization_entity.dart';
import 'package:proxy_id/identity/model/proxy_account_entity.dart';
import 'package:proxy_id/model/enticement.dart';
import 'package:proxy_id/services/enticement_service.dart';

// Don't use this for business functionality
class CleanupService {
  final AppConfiguration _appConfiguration;

  CleanupService(this._appConfiguration);

  Future<void> onProxyAccount(ProxyAccountEntity proxyAccount) async {
    if (proxyAccount != null) {
      return dismissEnticementById(
        proxyUniverse: proxyAccount.proxyUniverse,
        enticementId: Enticement.NO_PROXY_ACCOUNTS,
      );
    }
  }

  Future<void> onPaymentAuthorization(PaymentAuthorizationEntity paymentAuthorization) async {
    if (paymentAuthorization != null) {
      return Future.wait([
        dismissEnticementById(
          proxyUniverse: paymentAuthorization.proxyUniverse,
          enticementId: Enticement.MAKE_PAYMENT,
        ),
        dismissEnticementById(
          proxyUniverse: paymentAuthorization.proxyUniverse,
          enticementId: Enticement.NO_PROXY_ACCOUNTS,
        ),
      ]);
    }
  }

  Future<void> onDeposit(DepositEntity deposit) async {
    if (deposit != null) {
      return Future.wait([
        dismissEnticementById(
          proxyUniverse: deposit.proxyUniverse,
          enticementId: Enticement.ADD_FUNDS,
        ),
        dismissEnticementById(
          proxyUniverse: deposit.proxyUniverse,
          enticementId: Enticement.NO_PROXY_ACCOUNTS,
        ),
      ]);
    }
  }

  Future<void> dismissEnticementById({@required String proxyUniverse, @required String enticementId}) {
    print("Dimissing $proxyUniverse:$enticementId");
    return EnticementService(_appConfiguration).dismissEnticement(
      enticementId: enticementId,
      proxyUniverse: proxyUniverse,
    );
  }
}
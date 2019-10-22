import 'package:proxy_core/core.dart';
import 'package:proxy_core/services.dart';
import 'package:proxy_id/config/app_configuration.dart';

import 'service_factory.dart';

class BootService with ProxyUtils, HttpClientUtils, DebugUtils {
  final String backendHealthCheck;
  final HttpClientFactory httpClientFactory;

  BootService({
    String backendHealthCheck,
    HttpClientFactory httpClientFactory,
  })  : backendHealthCheck = backendHealthCheck ?? "https://app.pid.yagnyam.in/health-check",
        httpClientFactory = httpClientFactory ?? ProxyHttpClient.client {
    assert(isNotEmpty(this.backendHealthCheck));
  }

  void warmUpBackends() {
    get(httpClientFactory(), backendHealthCheck).then((health) {
      print("PiD Backend Health Check $health");
    }, onError: (error) {
      print("PiD Backend Health Check $error");
    });
  }

  void subscribeForAlerts() {
    print("subscribe for alerts");
    ServiceFactory.notificationService().start();
  }

  void processPendingAlerts(AppConfiguration appConfiguration) {
    print("process pending alerts");
    ServiceFactory.alertService(appConfiguration).processPendingAlerts();
  }
}

class ApiConstants {
  const ApiConstants._();

  static const String baseUrl = 'https://saasbackend-1-f6v3.onrender.com';
  static const Duration requestTimeout = Duration(seconds: 20);
  static const Duration loginRequestTimeout = Duration(seconds: 60);

  static const String acceptHeader = 'accept';
  static const String authorizationHeader = 'Authorization';
  static const String contentTypeHeader = 'Content-Type';
  static const String jsonMimeType = 'application/json';
  static const String bearerPrefix = 'Bearer';

  static const Map<String, String> defaultHeaders = {
    acceptHeader: jsonMimeType,
    contentTypeHeader: jsonMimeType,
  };

  static Map<String, String> authorizedHeaders(String token) {
    return {...defaultHeaders, authorizationHeader: '$bearerPrefix $token'};
  }
}

class ApiEndpoints {
  const ApiEndpoints._();

  static const String health = '/health';

  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authMe = '/auth/me';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';
  static const String authChangePassword = '/auth/change-password';
  static const String plansList = '/plans';
  static const String rolesList = '/roles';
  static const String organizationsMe = '/organizations/me';
  static const String organizationsSettings = '/organizations/settings';
  static const String organizationsSettingsUploadFile =
      '/organizations/settings/upload-file';
  static const String organizationsSettingsLogo =
      '/organizations/settings/logo';
  static const String filesUpload = '/files/upload';

  static const String customersList = '/customers';
  static const String customersCreate = '/customers';
  static const String customersDetailTemplate = '/customers/{customer_id}';
  static const String customersUpdateTemplate = '/customers/{customer_id}';
  static const String customersDeleteTemplate = '/customers/{customer_id}';
  static const String customersStatusTemplate =
      '/customers/{customer_id}/status';
  static const String customersLedgerTemplate =
      '/customers/{customer_id}/ledger';
  static const String customersPaymentsTemplate =
      '/customers/{customer_id}/payments';
  static const String customersDocumentsTemplate =
      '/customers/{customer_id}/documents';
  static const String ordersList = '/orders';
  static const String leadsList = '/leads';
  static const String quotationsList = '/quotations';
  static const String suppliersList = '/suppliers';
  static const String categoriesList = '/categories';
  static const String brandsList = '/brands';
  static const String productsList = '/products';

  static const String usersList = '/users';
  static const String usersCreate = '/users';
  static const String usersDetailTemplate = '/users/{user_id}';
  static const String usersUpdateTemplate = '/users/{user_id}';
  static const String usersDeleteTemplate = '/users/{user_id}';
  static const String usersStatusTemplate = '/users/{user_id}/status';
  static const String usersIdentityProofTemplate =
      '/users/{user_id}/identity-proof';
  static const String usersFilesTemplate = '/users/{user_id}/files/{field}';
  static const String usersResetPasswordTemplate =
      '/users/{user_id}/reset-password';

  static const String plans = plansList;
  static const String roles = rolesList;
  static const String customers = customersList;
  static const String users = usersList;

  static String customersDetail(String customerId) =>
      customersDetailTemplate.replaceFirst('{customer_id}', customerId);

  static String customersUpdate(String customerId) =>
      customersUpdateTemplate.replaceFirst('{customer_id}', customerId);

  static String customersDelete(String customerId) =>
      customersDeleteTemplate.replaceFirst('{customer_id}', customerId);

  static String customersStatus(String customerId) =>
      customersStatusTemplate.replaceFirst('{customer_id}', customerId);

  static String customersLedger(String customerId) =>
      customersLedgerTemplate.replaceFirst('{customer_id}', customerId);

  static String customersPayments(String customerId) =>
      customersPaymentsTemplate.replaceFirst('{customer_id}', customerId);

  static String customersDocuments(String customerId) =>
      customersDocumentsTemplate.replaceFirst('{customer_id}', customerId);

  static String usersDetail(String userId) =>
      usersDetailTemplate.replaceFirst('{user_id}', userId);

  static String usersUpdate(String userId) =>
      usersUpdateTemplate.replaceFirst('{user_id}', userId);

  static String usersDelete(String userId) =>
      usersDeleteTemplate.replaceFirst('{user_id}', userId);

  static String usersStatus(String userId) =>
      usersStatusTemplate.replaceFirst('{user_id}', userId);

  static String usersIdentityProof(String userId) =>
      usersIdentityProofTemplate.replaceFirst('{user_id}', userId);

  static String usersFiles(String userId, String field) => usersFilesTemplate
      .replaceFirst('{user_id}', userId)
      .replaceFirst('{field}', field);

  static String usersResetPassword(String userId) =>
      usersResetPasswordTemplate.replaceFirst('{user_id}', userId);
}

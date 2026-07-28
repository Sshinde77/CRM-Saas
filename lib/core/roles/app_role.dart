enum AppRole {
  admin,
  salesManager,
  delivery,
  accountant,
  unknown;

  static AppRole fromRaw(String? rawRole) {
    final normalized = rawRole?.trim().toLowerCase().replaceAll(
      RegExp(r'[\s_-]+'),
      '',
    );

    switch (normalized) {
      case 'admin':
      case 'businessowner':
      case 'adminbusinessowner':
        return AppRole.admin;
      case 'salesmanager':
      case 'salesofficer':
      case 'sales':
        return AppRole.salesManager;
      case 'delivery':
      case 'deliverypartner':
        return AppRole.delivery;
      case 'accountant':
      case 'accounts':
        return AppRole.accountant;
      default:
        return AppRole.unknown;
    }
  }
}

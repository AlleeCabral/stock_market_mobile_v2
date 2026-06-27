/// Marketstack account configuration for quota distribution.
///
/// Fill this list with API keys from your team members' accounts.
/// Keep this file local/private and never share real keys publicly.
class MarketstackAccounts {
  static const List<MarketstackAccount> accounts = [
    MarketstackAccount(label: 'member_1', accessKey: '3ddb062d21ac3eb2da536681d7afc0ef'),
    MarketstackAccount(label: 'member_2', accessKey: '378b37f4e2b708d3714a070787273dd7'),
    MarketstackAccount(label: 'member_3', accessKey: '', enabled: false),
    MarketstackAccount(label: 'member_4', accessKey: '', enabled: false),
  ];

  static List<String> get activeAccessKeys => accounts
      .where((account) => account.enabled)
      .map((account) => account.accessKey)
      .toList();
}

class MarketstackAccount {
  final String label;
  final String accessKey;
  final bool enabled;

  const MarketstackAccount({
    required this.label,
    required this.accessKey,
    this.enabled = true,
  });
}

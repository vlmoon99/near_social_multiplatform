abstract class WebWalletService {
  bool get isAvailable;
  Future<WalletCredentials?> connectWallet();
}

class WalletCredentials {
  final String accountId;
  final String secretKey;

  const WalletCredentials({
    required this.accountId,
    required this.secretKey,
  });
}

class StubWebWalletService implements WebWalletService {
  @override
  bool get isAvailable => false;

  @override
  Future<WalletCredentials?> connectWallet() {
    throw UnsupportedError('Wallet selector not available on this platform');
  }
}

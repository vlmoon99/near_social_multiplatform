import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:near_social_mobile/features/chat/presentation/providers/chat_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class TeeAttestationBadge extends ConsumerWidget {
  const TeeAttestationBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatControllerProvider);

    final hasAttestation = chatState.signalingConnected &&
        chatState.teeAttestation != null &&
        chatState.teeAttestation!.isNotEmpty;

    if (!hasAttestation) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => _showAttestationDialog(context, chatState.teeAttestation),
      child: const Icon(
        Icons.verified_user,
        size: 18,
        color: Colors.green,
      ),
    );
  }

  void _showAttestationDialog(BuildContext context, String? attestation) {
    showDialog(
      context: context,
      builder: (ctx) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: AlertDialog(
            backgroundColor: const Color(0xFF1A1A2E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.verified_user, color: Colors.green),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'TEE Verified (Intel TDX)',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'The signaling server is running inside a Trusted Execution Environment. Your connection is hardware-attested and tamper-proof.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Attestation Quote:',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  constraints: const BoxConstraints(maxHeight: 80),
                  child: SingleChildScrollView(
                    child: Text(
                      attestation ?? '',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => _openVerifier('https://proof.t16z.com/'),
                child: const Text(
                  'Verify (t16z)',
                  style: TextStyle(color: Colors.blueAccent, fontSize: 12),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openVerifier(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

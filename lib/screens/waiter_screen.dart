import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../services/request_service.dart';
import '../services/socket_service.dart';
import '../services/vibration_service.dart';

const _ink = Color(0xFF192B28);
const _mutedInk = Color(0xFF71807C);
const _green = Color(0xFF16856F);
const _canvas = Color(0xFFF5F7F4);
const _line = Color(0xFFE7ECE8);

class WaiterScreen extends StatefulWidget {
  const WaiterScreen({super.key});

  @override
  State<WaiterScreen> createState() => _WaiterScreenState();
}

class _WaiterScreenState extends State<WaiterScreen> {
  final SocketService _socketService = SocketService();
  final RequestService _requestService = RequestService();

  bool connected = false;
  bool hasRequest = false;
  bool accepted = false;
  bool isAccepting = false;

  String? requestId;
  String? tableNumber;
  String? acceptError;

  @override
  void initState() {
    super.initState();

    _socketService.connect(
      onConnectionChanged: (isConnected) {
        if (!mounted) return;

        setState(() {
          connected = isConnected;
        });
      },
      onNewRequest: (request) async {
        if (!mounted) return;

        final incomingRestaurantId = request['restaurantId']?.toString();
        if (incomingRestaurantId != ApiConfig.restaurantId) return;
        if (request['status']?.toString() != 'pending') return;

        final incomingRequestId = request['id']?.toString();
        if (incomingRequestId == null || incomingRequestId.isEmpty) {
          debugPrint('Received request without an ID: $request');
          return;
        }

        setState(() {
          requestId = incomingRequestId;
          tableNumber = request['tableNumber']?.toString() ?? '?';
          hasRequest = true;
          accepted = false;
          isAccepting = false;
          acceptError = null;
        });

        await VibrationService.alert();
      },
    );
  }

  Future<void> acceptCurrentRequest() async {
    final currentRequestId = requestId;
    if (currentRequestId == null || isAccepting || accepted) return;

    setState(() {
      isAccepting = true;
      acceptError = null;
    });

    try {
      await _requestService.acceptRequest(requestId: currentRequestId);
      if (!mounted) return;

      await VibrationService.stop();
      if (!mounted) return;

      setState(() {
        isAccepting = false;
        accepted = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request accepted successfully!')),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isAccepting = false;
        acceptError = error.toString();
      });
    }
  }

  void resetRequest() {
    if (isAccepting) return;

    setState(() {
      hasRequest = false;
      accepted = false;
      requestId = null;
      tableNumber = null;
      acceptError = null;
    });
  }

  @override
  void dispose() {
    _socketService.disconnect();
    VibrationService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _canvas,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 34),
                  if (hasRequest) _buildRequestCard() else _buildWaitingCard(),
                  const SizedBox(height: 22),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _green,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _green.withValues(alpha: 0.2),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.room_service_rounded,
            color: Colors.white,
            size: 25,
          ),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TapWait',
              style: TextStyle(
                color: _ink,
                fontSize: 21,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 1),
            Text(
              'WAITER CONSOLE',
              style: TextStyle(
                color: _mutedInk,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const Spacer(),
        _ConnectionBadge(connected: connected),
      ],
    );
  }

  Widget _buildWaitingCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _line),
        boxShadow: [
          BoxShadow(
            color: _ink.withValues(alpha: 0.045),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 124,
            height: 124,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF5F0),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD8EBE2), width: 1.5),
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              size: 54,
              color: _green,
            ),
          ),
          const SizedBox(height: 26),
          Text(
            connected ? 'You’re all set' : 'Getting things ready',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _ink,
              fontSize: 27,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            connected
                ? 'New table requests will appear here. Stay close and we’ll let you know when a guest needs you.'
                : 'Reconnecting now. Your request screen will be ready as soon as you’re back online.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _mutedInk,
              fontSize: 15,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 26),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              color: _canvas,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt_rounded, color: _green, size: 19),
                SizedBox(width: 8),
                Text(
                  'Ready to take care of your guests',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard() {
    final table = tableNumber ?? '?';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _line),
        boxShadow: [
          BoxShadow(
            color: _ink.withValues(alpha: 0.045),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _StateIcon(
                icon: accepted
                    ? Icons.check_rounded
                    : Icons.notifications_active_rounded,
                color: accepted ? _green : const Color(0xFFE9A543),
                background: accepted
                    ? const Color(0xFFEAF5F0)
                    : const Color(0xFFFFF5E6),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      accepted ? 'You’re on your way' : 'New guest request',
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.35,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      accepted
                          ? 'Request accepted successfully'
                          : 'A guest is waiting for your help',
                      style: const TextStyle(color: _mutedInk, fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (!accepted)
                Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE9A543),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 26),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: _canvas,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.table_restaurant_rounded,
                  color: _green,
                  size: 34,
                ),
                const SizedBox(height: 8),
                Text(
                  'TABLE $table',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  accepted ? 'You’ve got this' : 'Needs your attention',
                  style: const TextStyle(color: _mutedInk, fontSize: 13),
                ),
              ],
            ),
          ),
          if (acceptError != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0EE),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF5D4CF)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Couldn’t accept this request',
                    style: TextStyle(
                      color: Color(0xFF9A392D),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    acceptError!,
                    style: const TextStyle(
                      color: Color(0xFF9A392D),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Check your connection and try again.',
                    style: TextStyle(color: Color(0xFF9A392D), fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          if (!accepted)
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: isAccepting ? null : acceptCurrentRequest,
                style: FilledButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _green.withValues(alpha: 0.55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                icon: isAccepting
                    ? const SizedBox(
                        width: 19,
                        height: 19,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline_rounded),
                label: Text(
                  isAccepting ? 'Accepting request…' : 'Accept request',
                ),
              ),
            )
          else
            SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                onPressed: resetRequest,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _green,
                  side: const BorderSide(color: Color(0xFFC9DED5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                icon: const Icon(Icons.done_all_rounded),
                label: const Text('Done · clear request'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.person_outline_rounded, size: 17, color: _mutedInk),
        const SizedBox(width: 6),
        Text(
          'Signed in as ${ApiConfig.waiterName}',
          style: const TextStyle(
            color: _mutedInk,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ConnectionBadge extends StatelessWidget {
  const _ConnectionBadge({required this.connected});

  final bool connected;

  @override
  Widget build(BuildContext context) {
    final color = connected ? _green : const Color(0xFF9A7651);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: connected ? const Color(0xFFEAF5F0) : const Color(0xFFF5EFE7),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            connected ? Icons.wifi_rounded : Icons.wifi_off_rounded,
            size: 15,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            connected ? 'Online' : 'Reconnecting',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StateIcon extends StatelessWidget {
  const _StateIcon({
    required this.icon,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: color, size: 25),
    );
  }
}

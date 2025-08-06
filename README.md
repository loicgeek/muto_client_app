import 'package:pusher_client/pusher_client.dart';

void main() {
  // Pusher options - match your Laravel config and Nginx proxy
  final options = PusherOptions(
    cluster: 'mt1',  // can be any string, used by Pusher for clustering but not used by Laravel WebSockets itself
    host: 'muto-services.com',
    port: 443,
    encrypted: true,  // use TLS (wss)
    wsPath: '/app/',  // important to match the proxy location in Nginx
  );

  // Your Pusher key from .env PUSHER_APP_KEY
  final pusher = PusherClient(
    'your-pusher-app-key',
    options,
    enableLogging: true,
  );

  // Subscribe to the delivery channel with ID 123 (example)
  final channel = pusher.subscribe('delivery.123');

  // Bind to your event name exactly as Laravel broadcasts it
  channel.bind('CourierLocationUpdated', (PusherEvent? event) {
    if (event != null && event.data != null) {
      print('Received event data: ${event.data}');
      // Parse JSON and update your Flutter UI accordingly
    }
  });

  pusher.connect();
}

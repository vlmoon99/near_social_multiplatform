self.addEventListener('push', (event) => {
  const data = event.data.json();
  // console.log('Push received:', data);

  const options = {
    body: data.body,
    icon: 'favicon.png',
  };

  event.waitUntil(
    (async () => {
      // Show the notification
      await self.registration.showNotification(data.title, options);

      // Send the data to the clients
      const allClients = await clients.matchAll({ includeUncontrolled: true });
      allClients.forEach(client => {
        client.postMessage({
          type: 'PUSH_NOTIFICATION',
          payload: data
        });
      });
    })()
  );
});


self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  event.waitUntil(
    clients.openWindow('/')
  );
});

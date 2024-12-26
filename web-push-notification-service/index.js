const express = require('express');
const bodyParser = require('body-parser');
const webPush = require('web-push');
const cors = require('cors');

const app = express();
const port = 3000;

const vapidKeys = webPush.generateVAPIDKeys();
console.log('VAPID Public Key:', vapidKeys.publicKey);
console.log('VAPID Private Key:', vapidKeys.privateKey);

webPush.setVapidDetails(
    'mailto:example@yourdomain.com', 
    vapidKeys.publicKey,
    vapidKeys.privateKey
);

app.use(cors({ origin: 'http://localhost:46011' }));
app.use(bodyParser.json());

app.get('/vapidPublicKey', (req, res) => {
    res.send(vapidKeys.publicKey);
});

app.post('/register', (req, res) => {
    const subscription = req.body.subscription;

    if (!subscription) {
        return res.status(400).send('Subscription object is required');
    }

    console.log('New Subscription:', subscription);

    const payload = JSON.stringify({ title: 'Welcome!', body: 'Thank you for subscribing to notifications!' });
    const options = { TTL: 60 }; 

    const notificationCount = 10;
    const notificationDelay = 10 * 1000;

    for (let i = 0; i < notificationCount; i++) {
        setTimeout(() => {
            webPush.sendNotification(subscription, payload, options)
                .then(() => {
                    console.log(`Notification ${i + 1} sent successfully.`);
                })
                .catch(err => {
                    console.error(`Error sending notification ${i + 1}:`, err);
                });
        }, i * notificationDelay); // Delay increases with each iteration
    }

    // webPush.sendNotification(subscription, payload, options)
    //     .then(() => {
    //         console.log('Notification sent to new subscriber.');
    //         res.status(201).send('Subscription registered and notification sent.');
    //     })
    //     .catch(err => {
    //         console.error('Error sending notification:', err);
    //         res.status(500).send('Failed to send notification.');
    //     });
});

// Endpoint to send notifications manually (optional)
app.post('/sendNotification', (req, res) => {
    const { subscription, payload, ttl, delay } = req.body;

    if (!subscription || !payload) {
        return res.status(400).send('Subscription and payload are required');
    }

    const options = { TTL: ttl || 60 };

    setTimeout(() => {
        webPush.sendNotification(subscription, payload, options)
            .then(() => {
                console.log('Notification sent successfully.');
                res.sendStatus(201);
            })
            .catch(err => {
                console.error('Error sending notification:', err);
                res.sendStatus(500);
            });
    }, (delay || 0) * 5000);
});

// Start the server
app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
});

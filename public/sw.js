// Comdira Lifecoach - Service Worker for Offline Support
const CACHE_NAME = 'comdira-v1';
const STATIC_ASSETS = [
    '/',
    '/index.html',
    '/dashboard.html',
    '/checkin.html',
    '/wellness.html',
    '/goals.html',
    '/habits.html',
    '/journal.html',
    '/coach.html',
    '/assets/css/style.css',
    '/assets/css/sidebar-v2.css',
    '/assets/js/app.js'
];

// Install - cache static assets
self.addEventListener('install', (event) => {
    event.waitUntil(
        caches.open(CACHE_NAME)
            .then((cache) => {
                console.log('Service Worker: Caching static assets');
                return cache.addAll(STATIC_ASSETS);
            })
            .then(() => self.skipWaiting())
    );
});

// Activate - clean up old caches
self.addEventListener('activate', (event) => {
    event.waitUntil(
        caches.keys().then((cacheNames) => {
            return Promise.all(
                cacheNames
                    .filter((name) => name !== CACHE_NAME)
                    .map((name) => caches.delete(name))
            );
        })
        .then(() => self.clients.claim())
    );
});

// Fetch - serve from cache or network
self.addEventListener('fetch', (event) => {
    // Skip non-GET requests
    if (event.request.method !== 'GET') return;

    // Skip Chrome extensions
    if (event.request.url.startsWith('chrome-extension://')) return;

    event.respondWith(
        caches.match(event.request)
            .then((cached) => {
                // Return cached version or fetch from network
                const fetchPromise = fetch(event.request)
                    .then((networkResponse) => {
                        // Cache successful responses
                        if (networkResponse && networkResponse.status === 200) {
                            const clone = networkResponse.clone();
                            caches.open(CACHE_NAME).then((cache) => {
                                cache.put(event.request, clone);
                            });
                        }
                        return networkResponse;
                    })
                    .catch(() => {
                        // Network failed - return cached or offline page
                        console.log('Service Worker: Serving from cache');
                        return cached;
                    });

                return cached || fetchPromise;
            })
    );
});

// Background sync for offline actions
self.addEventListener('sync', (event) => {
    if (event.tag === 'sync-checkins') {
        event.waitUntil(syncCheckins());
    }
});

async function syncCheckins() {
    const checkins = await getPendingCheckins();
    for (const checkin of checkins) {
        try {
            await fetch('/api/checkin', {
                method: 'POST',
                body: JSON.stringify(checkin),
                headers: { 'Content-Type': 'application/json' }
            });
            await markCheckinSynced(checkin.id);
        } catch (error) {
            console.error('Sync failed for checkin:', checkin.id);
        }
    }
}

// Helper functions for IndexedDB
function getPendingCheckins() {
    return new Promise((resolve) => {
        // Simplified - would use IndexedDB in production
        resolve([]);
    });
}

function markCheckinSynced(id) {
    return new Promise((resolve) => {
        // Simplified - would use IndexedDB in production
        resolve();
    });
}

// Push notifications (future feature)
self.addEventListener('push', (event) => {
    const data = event.data.json();
    event.waitUntil(
        self.registration.showNotification(data.title, {
            body: data.body,
            icon: '/assets/icons/icon-192x192.png',
            badge: '/assets/icons/badge-72x72.png',
            data: data.data
        })
    );
});

// Notification click handler
self.addEventListener('notificationclick', (event) => {
    event.notification.close();
    event.waitUntil(
        clients.openWindow(event.notification.data.url || '/')
    );
});

import { useState, useEffect } from 'react';
import { useTranslation } from '@/components/useTranslations';

export default function PWAInstallButton() {
    const { t: text } = useTranslation("common");
    const [deferredPrompt, setDeferredPrompt] = useState(null);
    const [showButton, setShowButton] = useState(false);
    const [isInstalled, setIsInstalled] = useState(false);

    useEffect(() => {
        // Check if already installed
        if (window.matchMedia('(display-mode: standalone)').matches) {
            setIsInstalled(true);
            return;
        }

        // Listen for the beforeinstallprompt event
        const handleBeforeInstallPrompt = (e) => {
            // Prevent the mini-infobar from appearing on mobile
            e.preventDefault();
            // Stash the event so it can be triggered later
            setDeferredPrompt(e);
            setShowButton(true);
        };

        // Listen for custom event from _app.js
        const handlePWAInstallable = (e) => {
            setDeferredPrompt(e.detail);
            setShowButton(true);
        };

        // Listen for successful installation
        const handleAppInstalled = () => {
            setIsInstalled(true);
            setShowButton(false);
            setDeferredPrompt(null);
        };

        window.addEventListener('beforeinstallprompt', handleBeforeInstallPrompt);
        window.addEventListener('pwa-installable', handlePWAInstallable);
        window.addEventListener('appinstalled', handleAppInstalled);

        return () => {
            window.removeEventListener('beforeinstallprompt', handleBeforeInstallPrompt);
            window.removeEventListener('pwa-installable', handlePWAInstallable);
            window.removeEventListener('appinstalled', handleAppInstalled);
        };
    }, []);

    const handleInstallClick = async () => {
        if (!deferredPrompt) {
            // Fallback: show instructions
            if (/iPhone|iPad|iPod/.test(navigator.userAgent)) {
                alert('To install: Tap the Share button, then "Add to Home Screen"');
            } else if (/Android/.test(navigator.userAgent)) {
                alert('To install: Tap the menu (⋮) and select "Install app" or "Add to Home screen"');
            } else {
                alert('To install: Look for the install icon in your browser\'s address bar');
            }
            return;
        }

        // Show the install prompt
        deferredPrompt.prompt();

        // Wait for the user to respond to the prompt
        const { outcome } = await deferredPrompt.userChoice;

        if (outcome === 'accepted') {
            console.log('[PWA] User accepted the install prompt');
        } else {
            console.log('[PWA] User dismissed the install prompt');
        }

        // Clear the deferredPrompt
        setDeferredPrompt(null);
        setShowButton(false);
    };

    // Don't show if already installed or if button shouldn't be shown
    if (isInstalled || !showButton) {
        return null;
    }

    return (
        <button
            className="homeBtn home__install_pwa_btn"
            onClick={handleInstallClick}
            style={{
                background: 'linear-gradient(135deg, #7046e3 0%, #5532c6 100%)',
                color: 'white',
                border: 'none',
                borderRadius: '12px',
                padding: '12px 24px',
                fontSize: '1em',
                fontWeight: '600',
                cursor: 'pointer',
                boxShadow: '0 4px 15px rgba(112, 70, 227, 0.4)',
                transition: 'all 0.3s ease',
                marginTop: '10px'
            }}
            onMouseEnter={(e) => {
                e.target.style.transform = 'translateY(-2px)';
                e.target.style.boxShadow = '0 6px 20px rgba(112, 70, 227, 0.5)';
            }}
            onMouseLeave={(e) => {
                e.target.style.transform = 'translateY(0)';
                e.target.style.boxShadow = '0 4px 15px rgba(112, 70, 227, 0.4)';
            }}
        >
            📱 Install App
        </button>
    );
}


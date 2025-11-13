import "@/styles/globals.scss";
import "@/styles/multiPlayerModal.css";
import "@/styles/accountModal.css";
import "@/styles/mapModal.css";
import '@/styles/duel.css';

import { GoogleAnalytics } from "nextjs-google-analytics";
import { GoogleOAuthProvider } from '@react-oauth/google';
import { useEffect } from "react";
import { Workbox } from "workbox-window";

import '@smastrom/react-rating/style.css'
import Seo from "@/components/Seo";
import { initializeMsStartSdk } from "@/utils/msStartSdk";

function App({ Component, pageProps }) {
  const disableDefaultSeo = Component.disableDefaultSeo || pageProps.disableDefaultSeo;
  const seoProps = Component.seo || pageProps.seo || {};

  useEffect(() => {
    if (typeof window === "undefined") return;
    if (!("serviceWorker" in navigator)) return;

    // Handle incognito mode - service workers may not be available
    const registerServiceWorker = async () => {
      try {
        const wb = new Workbox("/sw.js");

        const promptUpdate = () => {
          wb.addEventListener("controlling", () => {
            window.location.reload();
          });
          wb.messageSW({ type: "SKIP_WAITING" });
        };

        wb.addEventListener("waiting", promptUpdate);
        await wb.register();
      } catch (error) {
        // Silently fail in incognito mode or when service workers are unavailable
        if (process.env.NODE_ENV !== "production") {
          console.log("[PWA] Service worker registration failed (may be incognito mode):", error);
        }
      }
    };

    registerServiceWorker();
  }, []);

  useEffect(() => {
    initializeMsStartSdk();
  }, []);

  return (
    <>
      {!disableDefaultSeo && <Seo {...seoProps} />}
      <GoogleAnalytics trackPageViews gaMeasurementId="G-KFK0S0RXG5" />
      { process.env.NEXT_PUBLIC_GOOGLE_CLIENT_ID  ? (
      <GoogleOAuthProvider clientId={process.env.NEXT_PUBLIC_GOOGLE_CLIENT_ID}>
      <Component {...pageProps} />
      </GoogleOAuthProvider>
      ) : (
        <Component {...pageProps} />
      )}
    </>
  );
}

export default App;
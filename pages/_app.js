import "@/styles/globals.scss";
import "@/styles/multiPlayerModal.css";
import "@/styles/accountModal.css";
import "@/styles/mapModal.css";
import '@/styles/duel.css';

import { GoogleAnalytics } from "nextjs-google-analytics";
import { GoogleOAuthProvider } from '@react-oauth/google';
import { useEffect } from "react";

import '@smastrom/react-rating/style.css'
import Seo from "@/components/Seo";
import { initializeMsStartSdk } from "@/utils/msStartSdk";

function App({ Component, pageProps }) {
  const disableDefaultSeo = Component.disableDefaultSeo || pageProps.disableDefaultSeo;
  const seoProps = Component.seo || pageProps.seo || {};

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
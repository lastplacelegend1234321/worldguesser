import { Html, Head, Main, NextScript } from "next/document";
import React, { useEffect } from "react";

export default function Document() {
  return (
    <Html lang="en" style={{ backgroundColor: '#000000' }}>
      <Head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
        <link
          rel="stylesheet"
          href="https://fonts.googleapis.com/css2?family=Montserrat:wght@300;400;500;600;700;800&display=swap"
        />
        <style dangerouslySetInnerHTML={{
          __html: `
            html, body {
              background-color: #000000 !important;
              margin: 0;
              padding: 0;
            }
          `
        }} />
      </Head>
      <body className="mainBody" style={{ backgroundColor: '#000000' }}>
        <Main />
        <NextScript />
      </body>
    </Html>
  );
}

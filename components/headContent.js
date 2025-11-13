import Head from "next/head";
import { useEffect } from "react";
import Seo from "@/components/Seo";

const SITE_URL = process.env.NEXT_PUBLIC_SITE_URL || "https://worldguessr.com";

export default function HeadContent({ text, inCoolMathGames }) {
  useEffect(() => {
    if (
      !window.location.search.includes("crazygames") &&
      !process.env.NEXT_PUBLIC_POKI &&
      !process.env.NEXT_PUBLIC_COOLMATH
    ) {
      // Ads are intentionally disabled. Keeping the previous implementation below for future reference.
      /*
      window.nitroAds = window.nitroAds || {
        createAd: function () {
          return new Promise((resolve) => {
            window.nitroAds.queue.push(["createAd", arguments, resolve]);
          });
        },
        addUserToken: function () {
          window.nitroAds.queue.push(["addUserToken", arguments]);
        },
        queue: [],
      };

      const script = document.createElement("script");
      script.src = "https://s.nitropay.com/ads-2071.js";
      script.async = true;
      document.head.appendChild(script);

      const script2 = document.createElement("script");
      script2.src =
        "https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-3340825671684972";
      script2.async = true;
      script2.crossorigin = "anonymous";
      document.body.appendChild(script2);

      return () => {
        document.head.removeChild(script);
        document.body.removeChild(script2);
      };
      */
    } else if(window.location.search.includes("crazygames")) {
      console.log("CrazyGames detected");
    //<script src="https://sdk.crazygames.com/crazygames-sdk-v3.js"></script>
    const script = document.createElement('script');
    script.src = "https://sdk.crazygames.com/crazygames-sdk-v3.js";
    script.async = false;
    console.log(window.CrazyGames)
    // on script load
    script.onload=() => {
      console.log("sdk loaded", window.CrazyGames)
      if(window.onCrazyload) {
        window.onCrazyload();
      }
    }
    document.body.appendChild(script);
    return () => {
      document.body.removeChild(script);
    }
    } else if(process.env.NEXT_PUBLIC_COOLMATH === "true") {
      /*<script
src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.3/jquery.min.js"></script>
<script type="text/ja
vascript"
src="https://www.coolmathgames.com/sites/default/files/cmg
-
ads.js"></script>*/

      const script = document.createElement('script');
      script.src = "https://ajax.googleapis.com/ajax/libs/jquery/3.6.3/jquery.min.js";
      script.async = false;
      document.body.appendChild(script);

      const script2 = document.createElement('script');
      script2.src = "https://www.coolmathgames.com/sites/default/files/cmg-ads.js";
      script2.async = false;
      document.body.appendChild(script2);

      return () => {
        document.body.removeChild(script);
        document.body.removeChild(script2);
      }

    }else if(process.env.NEXT_PUBLIC_POKI === "true") {
      //
      const script = document.createElement('script');
      script.src = "https://game-cdn.poki.com/scripts/v2/poki-sdk.js";
      script.async = true;
      document.body.appendChild(script);



      return () => {
        document.body.removeChild(script);
      }

    }
  }, []);

  const gameSchema = {
    "@context": "https://schema.org",
    "@type": "VideoGame",
    name: "Proguessr",
    url: SITE_URL,
    image: `${SITE_URL}/worldguessr-thumbnail.png`,
    description: text("fullDescMeta"),
    genre: ["Geography", "Trivia", "Education"],
    applicationCategory: "GameApplication",
    operatingSystem: "Web",
  };

  return (
    <>
      <Seo
        title={
          inCoolMathGames
            ? "Proguessr - Play it now at CoolmathGames.com"
            : text("tabTitle")
        }
        description={text("shortDescMeta")}
        image={`${SITE_URL}/worldguessr-thumbnail.png`}
        schema={[gameSchema]}
      />
      <Head>
        <meta
          name="viewport"
          content="width=device-width, height=device-height, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, viewport-fit=cover, user-scalable=no"
        />
        <link rel="icon" type="image/png" href="/proguessr_favicon.png" />
        <meta
          name="google-site-verification"
          content="7s9wNJJCXTQqp6yr1GiQxREhloXKjtlbOIPTHZhtY04"
        />
        <meta
          name="yandex-verification"
          content="2eb7e8ef6fb55e24"
        />
        <link
          href="https://fonts.googleapis.com/css2?family=Montserrat:wght@300;400;500;600;700;800&display=swap"
          rel="stylesheet"
        />
      </Head>
    </>
  );
}

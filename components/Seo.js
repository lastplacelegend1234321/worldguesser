import Head from "next/head";
import { useRouter } from "next/router";
import { useMemo } from "react";

const SITE_URL = process.env.NEXT_PUBLIC_SITE_URL || "https://worldguessr.com";
const DEFAULT_IMAGE = `${SITE_URL}/worldguessr-thumbnail.png`;
const DEFAULT_TITLE = "WorldGuessr | Free Geography Guessing Game";
const DEFAULT_DESCRIPTION =
    "Play WorldGuessr, the free geography guessing game inspired by GeoGuessr. Explore unlimited Street View locations, compete with friends, and sharpen your world knowledge.";
const DEFAULT_KEYWORDS = [
    "WorldGuessr",
    "geography game",
    "GeoGuessr alternative",
    "street view game",
    "map quiz",
    "free guessing game",
    "multiplayer geography",
].join(", ");

const defaultSchema = [
    {
        "@context": "https://schema.org",
        "@type": "WebSite",
        name: "WorldGuessr",
        url: SITE_URL,
        description: DEFAULT_DESCRIPTION,
        potentialAction: {
            "@type": "SearchAction",
            target: `${SITE_URL}/search?query={search_term_string}`,
            "query-input": "required name=search_term_string",
        },
    },
    {
        "@context": "https://schema.org",
        "@type": "Organization",
        name: "WorldGuessr",
        url: SITE_URL,
        logo: `${SITE_URL}/icon.png`,
        sameAs: ["https://discord.gg/azbS3F2wmb"],
    },
];

export default function Seo({
    title = DEFAULT_TITLE,
    description = DEFAULT_DESCRIPTION,
    image = DEFAULT_IMAGE,
    canonical,
    noindex = false,
    ogType = "website",
    twitterCard = "summary_large_image",
    schema = [],
    keywords = DEFAULT_KEYWORDS,
    publishedTime,
    modifiedTime,
}) {
    const router = useRouter();
    const asPath = router.asPath || "/";
    const pathWithoutQuery = asPath.split("?")[0];
    const canonicalUrl =
        canonical || `${SITE_URL}${pathWithoutQuery === "/" ? "" : pathWithoutQuery}`;
    const robotsValue = noindex ? "noindex, nofollow" : "index, follow";
    const images = Array.isArray(image) ? image : [image];

    const jsonLd = useMemo(() => {
        const schemas = Array.isArray(schema) ? schema : [schema];
        return JSON.stringify([...defaultSchema, ...schemas], null, 2);
    }, [schema]);

    return (
        <Head>
            <title>{title}</title>
            <meta name="description" content={description} />
            <meta name="keywords" content={keywords} />
            <meta name="robots" content={robotsValue} />
            <link rel="canonical" href={canonicalUrl} />

            <meta property="og:title" content={title} />
            <meta property="og:description" content={description} />
            <meta property="og:url" content={canonicalUrl} />
            <meta property="og:type" content={ogType} />
            {images.map((img, index) => (
                <meta key={img + index} property="og:image" content={img} />
            ))}
            {publishedTime && (
                <meta property="article:published_time" content={publishedTime} />
            )}
            {modifiedTime && (
                <meta property="article:modified_time" content={modifiedTime} />
            )}

            <meta name="twitter:card" content={twitterCard} />
            <meta name="twitter:title" content={title} />
            <meta name="twitter:description" content={description} />
            <meta name="twitter:image" content={images[0]} />
            <meta name="twitter:site" content="@worldguessr" />

            <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: jsonLd }} />
        </Head>
    );
}


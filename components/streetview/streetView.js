import React, { useState, useEffect, useRef } from "react";

const StreetView = ({
  nm = false,
  npz = false,
  showRoadLabels = true,
  lat,
  long,
  panoId,
  heading,
  pitch,
  showAnswer = false,
  hidden = false,
  onLoad
}) => {
  const [loading, setLoading] = useState(true);
  const iframeRef = useRef(null);

  // Reset loading state when location changes
  useEffect(() => {
    if (lat && long || panoId) {
      setLoading(true);
    }
  }, [lat, long, panoId]);

  // Get Google Maps API key from environment variable (ProGuessr customization)
  const GOOGLE_MAPS_API_KEY = process.env.NEXT_PUBLIC_GOOGLE_MAPS_API_KEY || "AIzaSyA2fHNuyc768n9ZJLTrfbkWLNK3sLOK-iQ";

  // Update iframe src when location changes (improved from upstream)
  useEffect(() => {
    if (iframeRef.current && (lat && long || panoId)) {
      const newSrc = panoId ?
        `https://www.google.com/maps/embed/v1/streetview?pano=${panoId}&key=${GOOGLE_MAPS_API_KEY}&fov=100&language=iw${heading !== null ? `&heading=${heading}` : ''}${pitch !== null ? `&pitch=${pitch}` : ''}` :
        `https://www.google.com/maps/embed/v1/streetview?location=${lat},${long}&key=${GOOGLE_MAPS_API_KEY}&fov=100&language=iw${heading !== null ? `&heading=${heading}` : ''}${pitch !== null ? `&pitch=${pitch}` : ''}`;

      // Only update if src actually changed to avoid unnecessary reloads
      if (iframeRef.current.src !== newSrc) {
        setLoading(true);
        iframeRef.current.src = newSrc;
      }
    }
  }, [lat, long, panoId, heading, pitch, GOOGLE_MAPS_API_KEY]);

  // Reload location logic
  const reloadLocation = () => {
    const iframe = document.getElementById("streetview");
    if (iframe) iframe.src = iframe.src;
  };
  if(typeof window !== 'undefined')  window.reloadLoc = reloadLocation;

  if((!lat || !long) && !panoId) {
    return null;
  }

  const iframeSrc = panoId ?
    `https://www.google.com/maps/embed/v1/streetview?pano=${panoId}&key=${GOOGLE_MAPS_API_KEY}&fov=100&language=iw${heading !== null ? `&heading=${heading}` : ''}${pitch !== null ? `&pitch=${pitch}` : ''}` :
    `https://www.google.com/maps/embed/v1/streetview?location=${lat},${long}&key=${GOOGLE_MAPS_API_KEY}&fov=100&language=iw${heading !== null ? `&heading=${heading}` : ''}${pitch !== null ? `&pitch=${pitch}` : ''}`;

  return (
    <iframe
      ref={iframeRef}
      className={`${(npz && nm && !showAnswer) ? 'nmpz' : ''} ${hidden ? "hidden" : ""} streetview`}
      src={iframeSrc}
      referrerPolicy="origin" // ProGuessr customization: fixes incognito mode
      allow="accelerometer; autoplay; clipboard-write; encrypted-media; picture-in-picture"
      onLoad={() => {
        setLoading(false);
        if (onLoad && (lat && long || panoId)) {
          onLoad();
        }
      }}
      style={{
        width: "100vw",
        height: "calc(100vh + 300px)",
        zIndex: 100,
        transform: "translateY(-285px)",
      }}
      id="streetview"
    />
  );
};

export default StreetView;
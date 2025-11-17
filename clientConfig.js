export default function config() {
  const isHttps = window ? (window.location.protocol === "https:") : true;
  const prefixHttp = (isHttps ? "https" : "http")+"://";
  const prefixWs = (isHttps ? "wss" : "ws")+"://";

  // In production, use the current hostname if env vars aren't set
  const isDevelopment = typeof window !== 'undefined' && (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1');
  
  // Determine API URL
  let apiUrl = process.env.NEXT_PUBLIC_API_URL;
  if (!apiUrl) {
    if (isDevelopment) {
      apiUrl = "localhost:3001";
    } else {
      // In production, use current hostname
      apiUrl = typeof window !== 'undefined' ? window.location.hostname : "localhost:3001";
    }
  }
  
  // Determine WebSocket host
  let wsHost = process.env.NEXT_PUBLIC_WS_HOST;
  if (!wsHost) {
    if (process.env.NEXT_PUBLIC_API_URL) {
      wsHost = process.env.NEXT_PUBLIC_API_URL;
    } else if (isDevelopment) {
      wsHost = "localhost:3002";
    } else {
      // In production, use current hostname
      wsHost = typeof window !== 'undefined' ? window.location.hostname : "localhost:3002";
    }
  }

  const websocketUrl = prefixWs + wsHost + '/wg';
  
  // Debug logging
  if (typeof window !== 'undefined') {
    console.log("[ClientConfig] WebSocket URL:", websocketUrl, {
      NEXT_PUBLIC_WS_HOST: process.env.NEXT_PUBLIC_WS_HOST,
      NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL,
      hostname: window.location.hostname,
      isDevelopment,
      wsHost
    });
  }

  return {
    "apiUrl": prefixHttp + apiUrl,
    "websocketUrl": websocketUrl,
  }
}
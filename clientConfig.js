
export default function config() {
  const isHttps = window ? (window.location.protocol === "https:") : true;
const prefixHttp = (isHttps ? "https" : "http")+"://";
const prefixWs = (isHttps ? "wss" : "ws")+"://";

  // Use current hostname if NEXT_PUBLIC_API_URL is not set (for production)
  const getApiUrl = () => {
    if (process.env.NEXT_PUBLIC_API_URL) {
      return process.env.NEXT_PUBLIC_API_URL;
    }
    // In production, use the same hostname as the current page
    if (typeof window !== 'undefined') {
      return window.location.hostname;
    }
    return "localhost:3001"; // Fallback for SSR
  };

  const getWsHost = () => {
    if (process.env.NEXT_PUBLIC_WS_HOST) {
      return process.env.NEXT_PUBLIC_WS_HOST;
    }
    if (process.env.NEXT_PUBLIC_API_URL) {
      return process.env.NEXT_PUBLIC_API_URL;
    }
    // In production, use the same hostname as the current page
    if (typeof window !== 'undefined') {
      return window.location.hostname;
    }
    return "localhost:3002"; // Fallback for SSR
  };

  return {
  "apiUrl": prefixHttp + getApiUrl(),
  "websocketUrl": prefixWs + getWsHost() + '/wg',
  }
}
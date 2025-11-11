const DEFAULT_SDK_URL =
    process.env.NEXT_PUBLIC_MSSTART_SDK_URL ||
    "https://assets.msn.com/bundles/msstart.games.sdk/msstart.games.sdk.min.js";

let sdkPromise = null;

const ensureWindow = () => typeof window !== "undefined";

const resolveSdk = () => {
    if (!ensureWindow()) return null;
    return window.$msstart || null;
};

export const initializeMsStartSdk = () => {
    if (!ensureWindow()) return Promise.resolve(null);

    if (sdkPromise) {
        return sdkPromise;
    }

    if (resolveSdk()) {
        sdkPromise = Promise.resolve(resolveSdk());
        return sdkPromise;
    }

    if (!DEFAULT_SDK_URL) {
        sdkPromise = Promise.resolve(null);
        return sdkPromise;
    }

    sdkPromise = new Promise((resolve) => {
        const script = document.createElement("script");
        script.src = DEFAULT_SDK_URL;
        script.async = true;
        script.onload = () => resolve(resolveSdk());
        script.onerror = () => resolve(null);
        document.head.appendChild(script);
    });

    return sdkPromise;
};

const callSdkMethod = async (method, ...args) => {
    const sdk = await initializeMsStartSdk();
    if (!sdk || typeof sdk[method] !== "function") {
        return null;
    }

    try {
        return await sdk[method](...args);
    } catch (error) {
        console.error(`[MS Start SDK] ${method} failed`, error);
        return null;
    }
};

export const isRunningInMsStart = async () => {
    const sdk = await initializeMsStartSdk();
    if (!sdk || typeof sdk.isInMicrosoftStart !== "function") {
        return false;
    }

    try {
        return !!(await sdk.isInMicrosoftStart());
    } catch (error) {
        console.error("[MS Start SDK] isInMicrosoftStart failed", error);
        return false;
    }
};

export const pingMsStartAsync = () => callSdkMethod("pingAsync");

export const fetchMsStartEntryPointInfo = () => callSdkMethod("getEntryPointInfo");

export const promptMsStartInstallAsync = () => callSdkMethod("promptInstallAsync");

export const fetchMsStartLocale = async () => {
    const locale = await callSdkMethod("getLocale");
    return locale || null;
};

export const fetchMsStartShareSourceId = async () => {
    const id = await callSdkMethod("getSourceShareId");
    return id || null;
};

export const fetchMsStartConsentString = async () => {
    const consent = await callSdkMethod("getConsentStringAsync");
    return consent || null;
};

export const getMsStartSdk = () => resolveSdk();

export const resetMsStartSdkForTesting = () => {
    sdkPromise = null;
    if (ensureWindow()) {
        delete window.$msstart;
    }
};


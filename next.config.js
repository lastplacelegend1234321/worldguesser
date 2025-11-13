// const path = require('path');
// const process = require('process');
// const CopyWebpackPlugin = require('copy-webpack-plugin');

import path from 'path';
import process from 'process';
import { execSync } from 'child_process';
import withPWAInit from 'next-pwa';

const pathBuilder = (subpath) => path.join(process.cwd(), subpath);

// Get commit hash and build time
const getCommitHash = () => {
    try {
        return execSync('git rev-parse --short HEAD').toString().trim();
    } catch (error) {
        return 'unknown';
    }
};

const getBuildTime = () => {
    return new Date().toISOString();
};

const __dirname = path.resolve();
const withPWA = withPWAInit({
    dest: 'public',
    disable: true, // Temporarily disabled to fix build timeout
    register: false,
    skipWaiting: true,
    buildExcludes: [/middleware-manifest\.json$/],
});
/** @type {import('next').NextConfig} */
const nextConfig = {
    env: {
        NEXT_PUBLIC_COMMIT_HASH: getCommitHash(),
        NEXT_PUBLIC_BUILD_TIME: getBuildTime(),
    },
    webpack: (config, { webpack }) => {
        return config
    },
    sassOptions: {
        includePaths: [path.join(__dirname, 'styles')],
    },
    images: {
        unoptimized: true,
    },
    output: 'export',
    async rewrites() {
        return [
            {
                source: '/map/:slug',
                destination: '/map?s=:slug',
            },
        ];
    },

    // assetPrefix: './', we cant use this because it breaks dynamic paths (https://nextjs.org/docs/app/api-reference/config/next-config-js/assetPrefix)
};

// module.exports = nextConfig;
export default withPWA(nextConfig);
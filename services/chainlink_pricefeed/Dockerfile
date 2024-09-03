# ---- Base Node ----
FROM node:20 AS base
# Create app directory
WORKDIR /usr/src/app

# ---- Dependencies ----
FROM base AS dependencies
# Copy package files
COPY package*.json ./
# Install app dependencies including TypeScript
RUN npm install --production --ignore-scripts
RUN npm install typescript --save-dev
# Copy production dependencies aside
RUN cp -R node_modules /tmp/node_modules

# ---- Build ----
FROM base AS build
# Copy app sources
COPY . .
# Copy production dependencies
COPY --from=dependencies /tmp/node_modules ./node_modules

# Build the application - compile TypeScript to JavaScript
RUN npm run build

# ---- Release ----
FROM base AS release
# Create a non-root user
RUN useradd -m appuser
USER appuser
# Copy app build (from 'build' stage)
COPY --from=build /usr/src/app/dist ./dist
COPY --from=build /usr/src/app/node_modules ./node_modules
# Set environment variable for PORT
ENV PORT=$PORT
# Expose the port (this is optional and only for documentation purposes)
EXPOSE $PORT
# Start the app
CMD ["node", "dist/index.js"]
# Future Prime Frontend

This folder contains the frontend app for Future Prime.

## Stack
- React Native
- React Native Web for browser delivery
- Vite for local development and production builds

## Run locally
1. Install dependencies:
   - `npm install`
2. Start the app:
   - `npm run dev`
3. If your backend is on a different host or port, set:
   - `VITE_API_BASE_URL=http://localhost:8080`

## Production handoff
Run one of the repo-root scripts:
- Windows: `.\build-ui.ps1`
- Linux/macOS: `./build-ui.sh`

It builds the frontend, copies the compiled files into `backend/src/main/resources/static`, and packages the backend so the final JAR is ready in `backend/target`.

## Notes
- Home page: `#/home`
- Login page: `#/login`
- Backend auth endpoints remain under `http://localhost:8080/api/v1/auth`

# Future Prime

This repository contains planning documentation for the Future Prime business automation application.

## Included documents
- `future-prime-technical-plan.md` — technical implementation plan
- `future-prime-owner-plan.md` — owner-facing requirements and review plan
- `future-prime-project-plan.md` — detailed project roadmap and architecture
- `requirement.txt` — original business requirement notes

## Purpose
The goal is to build a centralized, mobile-first application for:
- quote generation
- inventory and spare parts management
- inbound import and outbound local shipment tracking
- order/import and customs clearance tracking
- service and warranty management
- technician attendance and expense tracking
- remote access for multiple user roles

## Repository layout
- `backend/` — Spring Boot API and authentication
- `frontend/` — React Native Web app for the home and login experience
- `bruno-collections/` — API request collections for manual verification
- `build-ui.ps1` — Builds the frontend and copies the compiled assets into the backend static folder

## Next steps
1. Install Git locally and initialize the repository.
2. Create a GitHub repository and add it as a remote.
3. Commit the files and push to GitHub.

## UI build flow
1. Run `.\build-ui.ps1` on Windows or `./build-ui.sh` on Linux/macOS
2. Start the backend Spring Boot app, or use the packaged JAR in `backend/target`
3. Open `http://localhost:8080`

The backend serves the compiled frontend from `backend/src/main/resources/static`, and the build scripts package a ready-to-run JAR in `backend/target`.

## Suggested commands
```powershell
cd "c:\Users\ASUS\OneDrive\Documents\future-prime"
git init
git add .
git commit -m "Add Future Prime plan documents"
git branch -M main
git remote add origin <YOUR_GITHUB_REMOTE_URL>
git push -u origin main
```

If you want, I can also help you prepare the GitHub repo name, description, and README content for the initial repository.   

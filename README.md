# X12O

A premium hybrid strategy game built around a 12×12 XO battlefield.

## Classic rules
- X starts; players alternate placing one mark in any empty cell.
- Each distinct contiguous window of three identical marks in a straight line scores one point.
- A run of four contains two overlapping scoring windows; a run of five contains three.
- Horizontal, vertical and both diagonal directions count. Crossing lines score independently.
- Classic matches end when all 144 cells are filled. The higher score wins; equal scores draw.

## Play modes
- **Classic local:** two players share one device.
- **AI Challenge:** offline opponent with Easy, Medium and Hard difficulty choices.
- **Arena local:** tactical two-player mode with energy-powered Eraser, Shield, Block, Swap, Double Move and Scanner abilities. Arena ends when no playable cells remain.

## Player progress
- Completed Classic, AI and Arena matches are saved locally on the device.
- The profile shows match totals, X-side wins/losses/draws, win rate, points and recent results.
- The local history keeps the latest 50 completed matches. It is not synced to a server or other devices.
- Daily missions grant a one-time 50 XP reward, track consecutive completion streaks and preserve the personal best streak locally.
- Seven-day and 30-day streak milestones unlock profile achievements.

## Technology
Flutter and Dart, Android-first. Custom Material 3 identity with electric cyan, coral and warm-gold accents. Animated Flutter UI and a pure Dart rules engine isolated from presentation. Local persistence uses shared_preferences. Unit tests and GitHub Actions CI build the Android release APK.

## Run locally
Install Flutter and Android SDK, then run:
    flutter create --platforms=android --project-name=x12o .
    flutter pub get
    flutter analyze
    flutter test
    flutter run

## Roadmap
1. **Foundation:** playable Classic, Arena and offline AI modes, scoring engine, rules, profile and CI.
2. **Game feel:** line-completion effects, haptics, sound controls, onboarding and accessibility.
3. **Retention:** daily challenges, achievements, richer progression, match analysis and Arena balance simulations.
4. **Social:** private rooms, invitations, matchmaking, server-authoritative matches and ranked seasons.
5. **Release:** Arabic, English and French localization, privacy disclosures, store assets and device QA.

Online multiplayer, private rooms, matchmaking and online rankings are not active yet. Daily challenges currently run locally on the device.

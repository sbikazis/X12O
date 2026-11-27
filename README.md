# X12O

A premium hybrid strategy game built around a 12×12 XO battlefield.

## Classic rules
- X starts; players alternate placing one mark in any empty cell.
- Each distinct contiguous window of three identical marks in a straight line scores one point.
- A run of four contains two overlapping scoring windows; a run of five contains three.
- Horizontal, vertical and both diagonal directions count. Crossing lines score independently.
- The match ends when all 144 cells are filled. The higher score wins; equal scores draw.

## Technology
Flutter and Dart, Android-first. Custom Material 3 identity with electric cyan, coral and warm-gold accents. Animated Flutter UI and a pure Dart engine isolated from presentation. Unit tests and GitHub Actions CI.

## Run locally
Install Flutter and Android SDK, then run:
    flutter create --platforms=android --project-name=x12o .
    flutter pub get
    flutter analyze
    flutter test
    flutter run

## Roadmap
1. Foundation: playable Classic match, scoring engine, rules, profile shell and CI.
2. Game feel: line-completion effects, haptics, sound controls, onboarding and accessibility.
3. Depth: balanced Arena abilities, AI opponents, daily challenges, achievements and local match history.
4. Social: private rooms, invitations, matchmaking, server-authoritative matches and ranked seasons.
5. Release: Arabic, English and French localization, privacy disclosures, store assets and QA.

Online play and progression features are planned, not simulated in this foundation.

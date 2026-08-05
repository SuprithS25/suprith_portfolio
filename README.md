# Suprith S — Portfolio

A responsive, cross-platform personal portfolio built with Flutter Web. Features a minimalist Apple/Vercel-inspired design with light and dark themes, animated project cards, and a live contact form.

**🔗 Live site:** [suprith-portfolio.vercel.app](https://suprith-portfolio-opal.vercel.app/) 

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![Vercel](https://img.shields.io/badge/Deployed%20on-Vercel-000000?logo=vercel&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green.svg)

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Environment & Configuration](#environment--configuration)
- [Build & Deployment](#build--deployment)
- [Roadmap](#roadmap)
- [License](#license)
- [Contact](#contact)

---

## Overview

This is a single-page Flutter Web application showcasing my projects, work experience, and technical skills. It's built to be fully responsive across desktop and mobile, with smooth scroll navigation, a typing-effect hero section, and an integrated contact form that delivers messages via Formspree — no backend required.

## Features

- 🌗 **Light/Dark theme toggle** with an Apple/Vercel-inspired visual style
- 📱 **Fully responsive layout** — adaptive nav bar and drawer for mobile
- ⌨️ **Animated typing hero text** cycling through role titles
- 🗂️ **Interactive project cards** with hover animation, tags, and click-through to GitHub repositories
- 📈 **Skill proficiency bars** with animated progress indicators
- 🕒 **Experience timeline** for internships and work history
- 📩 **Functional contact form** — submissions are sent via [Formspree](https://formspree.io), including client-side validation, loading state, and error handling
- 📄 **Resume download** button linking to a hosted PDF
- ♿ Smooth-scroll section navigation with `GlobalKey`-based anchors

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | [Flutter](https://flutter.dev) (Web) |
| Language | [Dart](https://dart.dev) |
| HTTP Client | [`http`](https://pub.dev/packages/http) |
| External Links | [`url_launcher`](https://pub.dev/packages/url_launcher) |
| Form Backend | [Formspree](https://formspree.io) |
| Hosting / CI-CD | [Vercel](https://vercel.com) (auto-deploy on push to `main`) |
| Version Control | Git + GitHub |

## Project Structure

```
suprith_portfolio/
├── android/                # Android platform files (unused for web build)
├── ios/                    # iOS platform files (unused for web build)
├── web/                    # Web-specific assets (index.html, icons, manifest)
├── lib/
│   └── main.dart           # Entire app: theming, sections, and reusable widgets
├── pubspec.yaml            # Project dependencies and metadata
├── vercel.json             # Vercel build configuration
└── README.md
```

> **Note:** The app currently lives in a single `main.dart` file for simplicity. See [Roadmap](#roadmap) for planned structural improvements.

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel, 3.x+)
- A modern browser (Chrome recommended for local development)

### Installation

```bash
# Clone the repository
git clone https://github.com/SuprithS25/suprith_portfolio.git
cd suprith_portfolio

# Install dependencies
flutter pub get

# Run locally in Chrome
flutter run -d chrome
```

### Build for production

```bash
flutter build web --release
```

Output is generated in `build/web/`.

## Environment & Configuration

This project doesn't use `.env` files — external service endpoints are defined as constants in `lib/main.dart`:

| Constant | Purpose |
|---|---|
| `kResumeUrl` | Direct-download link to the hosted resume PDF |
| `kFormspreeUrl` | Formspree endpoint the contact form submits to |

> ⚠️ If you fork this project, update both constants with your own resume link and Formspree form ID before deploying.

## Build & Deployment

This project is configured for **Vercel**, which doesn't natively support Flutter. The `vercel.json` build command clones the Flutter SDK inside the build container before compiling:

```json
{
  "buildCommand": "git clone https://github.com/flutter/flutter.git -b stable --depth 1 && export PATH=\"$PATH:`pwd`/flutter/bin\" && flutter doctor && flutter build web --release",
  "outputDirectory": "build/web",
  "rewrites": [
    { "source": "/(.*)", "destination": "/index.html" }
  ]
}
```

Every push to `main` triggers an automatic rebuild and redeploy via Vercel's GitHub integration. Preview deployments are generated automatically for other branches and pull requests.

## Roadmap

- [ ] Split `main.dart` into feature-based files (`widgets/`, `screens/`, `theme/`) for better maintainability
- [ ] Extract project/skill/experience data into a config file or JSON, rather than hardcoding in the widget tree
- [ ] Add unit/widget tests
- [ ] Add CI checks (`flutter analyze`, `flutter test`) via GitHub Actions before Vercel deploy
- [ ] SEO metadata and Open Graph tags for link previews

## License

This project is licensed under the [MIT License](LICENSE).

## Contact

**Suprith S**
- GitHub: [@SuprithS25](https://github.com/SuprithS25)
- LinkedIn: [linkedin.com/in/suprith25](https://linkedin.com/in/suprith25)
- Portfolio: [suprith-portfolio.vercel.app](https://suprith-portfolio-opal.vercel.app)
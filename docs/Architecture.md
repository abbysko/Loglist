# Architecture

## Current state

This project is a browser-first web app that also ships as a native iOS app: `ios/Loglist` wraps the same `/web` code in a SwiftUI shell using `WKWebView`, so the browser demo and the iOS app run identical HTML/CSS/JS. State is persisted in browser storage (`localStorage`), and the UI is split into page-like screens.

- Primary codebase: JavaScript, HTML, and CSS under `/web`
- Current runtime model: static web app served locally in a browser, and the same web app hosted in a native `WKWebView` on iOS
- Current persistence: browser `localStorage`, used identically whether the app is running in a browser tab or inside the iOS `WKWebView`
- iOS-only native layer (implemented): a `WKScriptMessageHandler` bridge for CSV session sharing and for starting/updating/ending an ActivityKit Live Activity, plus a WidgetKit extension that renders that Live Activity
- Future target: a native persistence backend (e.g. SwiftData) behind the same repository interface, so storage is not tied to `localStorage`/`WKWebView`

The architecture is intentionally simple: the UI layer talks to a repository abstraction, while the repository implementation is currently browser-storage-based (`localStorage`) regardless of whether it runs in a browser tab or the iOS wrapper.

## Directory layout

### `/web` — shared web app (runs in both the browser and the iOS `WKWebView`)

- `/web/index.html` — public marketing/landing page (published to https://abbysko.github.io/Loglist/)
- `/web/app.html` — app shell entry point loaded by the browser demo and by the iOS `WKWebView`
- `/web/app.js` — app bootstrap, theme initialization, and screen routing
- `/web/styles.css` — base styles, theme tokens, and screen styling
- `/web/marketing-content.html`, `/web/marketing.js`, `/web/landing.css` — marketing page content and styling, loaded by index.html and the app's "About" tab
- `/web/design-system.html` — visual reference for shared UI components and tokens (reference available from index.html)
- `/web/screens/` — one HTML + JS pair for each of 4 app tabs (`lists`, `track`, `history`, `about`)
- `/web/repository/index.js` — the repository implementation, currently backed by `localStorage`
- `/web/data/builtins.json` — seeded built-in list definitions
- `/web/assets/` — images, icons, and other static resources
- `/web/vendor/` — vendored third-party scripts (Feather icons, Chart.js, SortableJS)

### `/ios/Loglist` — native iOS wrapper (Xcode project)

- `Loglist.xcodeproj/` — the Xcode project, with an app target and a widget-extension target
- `Loglist/` — the app target:
  - `LoglistApp.swift` — SwiftUI app entry point
  - `ContentView.swift` — hosts the `WKWebView`, the `LiveActivityManager`, and the `WKScriptMessageHandler` bridge (`shareSession`, `liveActivity`)
  - `LocalWebView.swift` — the `WKURLSchemeHandler` that serves the bundled `/web` folder over the `loglist://` scheme
  - `Assets.xcassets/` — app icon assets
- `LoglistLiveActivity/` — the WidgetKit extension target that renders the Live Activity on the Lock Screen and in the Dynamic Island

## Runtime architecture

The application follows a lightweight layered structure:

- App shell: `web/app.js` initializes route state, theme preferences, and the active screen.
- Screen layer: the screen modules render the Lists, Track, and History interfaces and handle user interaction.
- Repository layer: `web/repository/index.js` exposes repository methods such as loading lists, saving custom lists, and storing history entries.
- Storage layer: browser storage (`localStorage`) is the current persistence mechanism.

This keeps the UI logic portable while still being simple enough for a prototype.

## Persistence (current implementation)

The current implementation is intentionally minimal: lists, history, and active tracking state are all plain JSON stored in `localStorage`.

- Built-in lists are loaded from `web/data/builtins.json`.
- Custom lists and saved history are stored in `localStorage`.
- Active tracking state is also stored in `localStorage` while a session is in progress, so an in-progress session survives the app being backgrounded or terminated.
- The repository abstraction exists, but it is currently a browser-only implementation rather than a full cross-platform persistence layer.

## Repository pattern

The intended design is already visible in the code:

- UI code calls repository methods instead of reading browser storage directly.
- The repository layer is the boundary between app logic and persistence.
- This makes later replacement with a native-backed implementation more straightforward.
- Exception: active-tracking state (current list, session name, per-item counts) is read/written directly via `localStorage` in the screen modules rather than through the repository.

In other words, the repository concept is present and useful, but the implementation remains a lightweight prototype.

## Future native architecture

What remains as future native work:

- Move persistence off `localStorage` and behind a native backend (e.g. SwiftData), exposed to the JS repository layer through the same kind of bridge already used for `shareSession`/`liveActivity`.
- Bring active-tracking state (current list, session name, per-item counts) into the repository as a proper method (e.g. `loadActiveSession()` / `saveActiveSession()`), instead of the screen modules reading/writing `localStorage` directly.

## Build & deployment

Web development flow:

- `npm install` also runs `postinstall` (`scripts/sync-vendor.mjs`), which copies Feather, SortableJS, and Chart.js from `node_modules` into `web/vendor`.
- `npm start` runs a static dev server (`http-server ./web`).
- Open `index.html` (marketing page) or `app.html` (the app) at the local dev port.
- The repository stays a simple `localStorage`-backed prototype in this flow.

iOS build flow:

- Open `ios/Loglist/Loglist.xcodeproj` in Xcode.
- A build-phase shell script on the `Loglist` target copies the repo's `/web` folder into the app bundle on every build, so the iOS app always runs the same web code as the browser demo.
- Build and run the `Loglist` app target on a simulator or device; the `LoglistLiveActivityExtension` widget target is embedded automatically via the "Embed Foundation Extensions" build phase.

GitHub Pages deployment:

- `.github/workflows/deploy-pages.yml` publishes the `/web` folder as-is to GitHub Pages, with no build step.
- It runs on every push to `main` that touches `web/**`, and can also be triggered manually.
- Because the whole `/web` folder is published, both the marketing site (`index.html`) and the app demo (`app.html`) are live on GitHub Pages, not just the marketing page.

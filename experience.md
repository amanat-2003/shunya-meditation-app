# Shunya — Resume Experience Points

Here are informational and keyword-dense bullet points you can use for your resume, customized for different technical focuses (Full-Stack, Mobile/Frontend, or Architecture). Pick the 3-4 bullets that best fit the role you are applying for.

## Links (Proof of Work)
* **Play Store:** [Shunya on Google Play](https://play.google.com/store/apps/details?id=com.anamiapps.shunya)
* **Web App:** [Shunya on GitHub Pages](https://amanat-2003.github.io/shunya-meditation-app/)
* **GitHub Repository:** [amanat-2003/shunya-meditation-app](https://github.com/amanat-2003/shunya-meditation-app)

---

## Technical Stack
**Flutter, Dart, Riverpod, Hive (NoSQL), Supabase, PostgreSQL, GoRouter, OAuth 2.0, GitHub Actions**

---

## Resume Bullet Points

### Option 1: Full-Stack / Mobile Engineering Focus (Recommended)
* **Architected and successfully deployed** an offline-first meditation and habit-tracking application using **Flutter** and **Dart**, securing publications on the Google Play Store and web via GitHub Pages.
* **Engineered a robust background sync architecture** integrating **Hive (Local NoSQL)** for zero-latency offline data persistence and **Supabase (PostgreSQL)** for secure cloud synchronization and cross-device data continuity.
* **Implemented comprehensive authentication flows** including Google OAuth 2.0 and Apple Sign-In via Supabase Auth, employing declarative routing with **GoRouter** to enforce secure session guards.
* **Designed a high-performance, battery-efficient UI/UX** utilizing a pitch-black "Screen-Off" mode, integrating native OS haptic feedback APIs to track user progress without visual reliance.
* **Managed complex application state** and dependency injection utilizing **Riverpod**, ensuring strict memory management padding and zero cross-account data leakage across global state providers.

### Option 2: Architecture & Performance Focus
* **Designed an offline-first data synchronization engine** bridging local **Hive** databases with **Supabase**, enabling users to interact seamlessly in airplane mode while guaranteeing eventual consistency on reconnection.
* **Optimized read/write performance** by writing manual Hive binary adapters, eliminating dependencies on code generation and circumventing costly versioning conflicts.
* **Built a custom data visualization dashboard** featuring bespoke heatmap and bar chart implementations to handle monthly and weekly statistical aggregations directly on the client.
* **Established a streamlined CI/CD pipeline** for web deployment utilizing GitHub Actions (Pages), significantly accelerating cross-platform testing iterations and progressive web application (PWA) parity.
* **Secured application assets and user data** by enforcing Supabase Row Level Security (RLS) policies and leveraging environment configurations (`--dart-define`) to protect OAuth client keys across independent compilation targets.

### Option 3: Product & Impact Focus
* **Developed and launched a cross-platform lifestyle application** from concept to production, capturing user engagement through a minimalist, purely haptic-driven user experience.
* **Drove app store deployment pipelines** handling Play Console release management, Android App Bundle (AAB) building, secure keystore signing, and regulatory compliance.
* **Delivered a seamless multi-platform experience** (Android, iOS Simulator, Web) from a single code base, resolving critical platform-specific edge cases such as cross-browser Supabase OAuth redirection anomalies.
* **Prioritized core functionality under constrained network environments** by explicitly treating the local device as the source of truth, gracefully deferring network payloads for optimal user experience.

---

### Pro-Tips for adding this to your resume:
1. **Quantify if you can:** If you have user numbers (e.g., "Scaled to 100+ active users" or "Achieved 5-star rating"), add those to the start of the bullet.
2. **Contextualize the "Why":** Mentions of the *haptic feedback* and *offline-first* nature stand out because they solve specific user problems (meditating without looking at a phone, meditating with airplane mode on).

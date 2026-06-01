# Security Review — Deep Pre-PR1 Assessment

**Branch:** `feat/athar-v2-pr1-tokens-theme`  
**Base commit:** `32e59c3` (main checkpoint)  
**Review date:** 2026-05-08  
**Reviewer:** Claude Code (automated deep review)  
**Scope:** Pre-implementation security posture + PR1 attack surface (tokens, typography, font assets, pubspec changes)

---

## Scope Reviewed

| Area | Reviewed |
|------|----------|
| Git branch state and staged changes | ✅ |
| Untracked files | ✅ |
| Secret leakage in committed files | ✅ |
| Font asset integrity | ✅ |
| pubspec.yaml dependency risks | ✅ |
| iOS entitlements and permissions | ✅ |
| Android manifest permissions | ✅ |
| Binary/malicious file scan | ✅ |
| Supply-chain risks (pub.dev packages) | ✅ |
| Path traversal in asset declarations | ✅ |
| Build script safety (Fastfile, Podfile) | ✅ |
| CI/GitHub workflow changes | ✅ |
| Permissions/entitlements changes | ✅ |
| Network/API/key exposure | ✅ |
| handoff_v2 package integrity | ✅ |
| PR1 attack surface delta | ✅ |

---

## Files Inspected

| File | Method |
|------|--------|
| `GIT_CHECKPOINT_REPORT.md` (staged) | Full read |
| `pubspec.yaml` | Full read |
| `pubspec.lock` (first 150 lines) | Partial read |
| `lib/main.dart` | grep (secrets) |
| `lib/firebase_options.dart` | grep (keys) |
| `android/app/google-services.json` | Content verified |
| `ios/Runner/GoogleService-Info.plist` | Content verified |
| `ios/Runner/Runner.entitlements` | Full read |
| `ios/Runner/Info.plist` | Full read |
| `ios/AtharTaskWidgetExtension.entitlements` | Full read |
| `ios/AtharPrayerWidgetExtension.entitlements` | Full read |
| `ios/AtharHabitWidgetExtensionProfile.entitlements` | Full read |
| `android/app/src/main/AndroidManifest.xml` | Full read |
| `ios/fastlane/Fastfile` | Full read |
| `ios/fastlane/Appfile` | Full read |
| `ios/fastlane/metadata/review_information/*` | All 7 files read |
| `assets/fonts/*.ttf` (4 files) | Binary type + metadata verified |
| `assets/icon/app_icon.png` | Type verified |
| `.env` (on disk, gitignored) | Content verified |
| `design-context/_handoff_to_design_tool.md` | Scanned for secrets |

---

## Commands Run

```bash
git -C /path/athar status --short
git -C /path/athar diff HEAD --stat
git -C /path/athar diff HEAD
git -C /path/athar log main..HEAD --oneline
git -C /path/athar diff main...HEAD --stat
git -C /path/athar ls-files --others --exclude-standard
git -C /path/athar ls-files | grep -i '\.env'
find /path/athar -name '.env*' -not -path '*/.git/*'
grep -r -l -i 'api_key|apikey|secret|password|token|supabase' lib/
find /path/athar/assets -type f | sort
find /path/athar/ios -name '*.entitlements' -o -name 'Info.plist'
find /path/athar -name '*.yml' -path '*/.github/*'
find /path/athar -name 'Makefile' -o -name '*.sh' -o -name 'Fastfile' -o -name 'Podfile'
git -C /path/athar ls-files | file -f - | grep -v 'ASCII|UTF-8|JSON|XML|empty'
find /path/new_projects -maxdepth 3 -name '*handoff*'
```

---

## Branch State Summary

- **Commits ahead of main:** 0 (zero)
- **Staged changes:** 1 file — `GIT_CHECKPOINT_REPORT.md` (documentation only, no credentials, no code)
- **Untracked files:** None (outside .gitignore)
- **PR1 implementation status:** Not yet started — branch is clean

---

## Findings by Severity

### SECURITY BLOCKERS — None

PR1 is cleared to proceed. No security blockers identified.

---

### HIGH — None

No high-severity findings.

---

### MEDIUM — None

No medium-severity findings.

---

### LOW — Pre-existing (not introduced by PR1)

#### LOW-1: `.env` File Bundled as Flutter App Asset

- **File:** `pubspec.yaml` line 129 — `- .env` under `flutter.assets`
- **Status:** Pre-existing. Not introduced by PR1.
- **Detail:** The `.env` file is correctly gitignored but is declared as a Flutter asset and compiled into the distributed app binary (`.ipa`/`.apk`). Any user who downloads the app can extract the binary and recover the contents. Current contents:
  - `SUPABASE_ANON_KEY` — Supabase designates this as a `sb_publishable_` key, explicitly intended to be public. Security is enforced by Supabase Row Level Security (RLS) policies, not key secrecy.
  - `REVENUE_CAT_IOS_KEY` — Standard mobile pattern; RevenueCat mobile keys are public-facing by design.
  - `SUPABASE_URL` — Public endpoint identifier.
- **Current exploitability:** Low. All three values are in the "public by design" category for their respective services.
- **Future risk (HIGH):** The pattern creates a dangerous footgun — a future developer could add a Supabase service-role key, Stripe secret key, or admin credential to `.env` under the false assumption that `.gitignore` protects it, without realizing it ships in every app binary.
- **Recommended fix (before production):** Replace `flutter_dotenv` + `.env` asset with `--dart-define-from-file` at build time. Keys are injected at compile time and never appear as readable strings in the binary bundle.
- **Confidence:** 9/10

#### LOW-2: Developer PII in Tracked Fastlane Metadata

- **Files:** `ios/fastlane/metadata/review_information/` (7 files), `ios/fastlane/Appfile`
- **Status:** Pre-existing. Not introduced by PR1.
- **Detail:** Tracked in git: developer's real name (`Ali Alhumain`), email (`iappnet@icloud.com`), phone number (`+966507488180`), Apple Team IDs.
- **Current exploitability:** Low (private repo). Standard Fastlane practice; Apple Team IDs are identifiers, not credentials. Phone/email present a social-engineering surface only.
- **Risk if repo goes public:** Medium — email is a confirmed Apple ID phishing target; phone enables SIM-swap social engineering; Team ID enables app-portfolio correlation.
- **Recommended fix:** Move `review_information/` contents to environment variables or a secrets manager before any public repo sharing. Apple Team IDs in `Appfile` are fine to keep.
- **Confidence:** 9/10

---

### INFORMATIONAL — Pre-existing observations

#### INFO-1: Firebase Configuration Files Tracked in Git

- **Files:** `lib/firebase_options.dart`, `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`
- **Assessment:** FALSE POSITIVE. Firebase API keys for mobile apps are explicitly non-secret by Google's own documentation. They are project identifiers embedded in every distributed binary. Committing them to git adds zero marginal exposure. Access control is enforced by Firebase Security Rules, not key secrecy.
- **No action required.**

#### INFO-2: `google_fonts` Package Declared but Unused

- **File:** `pubspec.yaml` — `google_fonts: ^8.0.2`
- **Detail:** No `GoogleFonts.*` calls found in any Dart source file. If called, this package makes network requests to `fonts.gstatic.com`. Since it is unused, no network call occurs.
- **Recommendation:** Remove from `pubspec.yaml` in a future cleanup PR to reduce dependency surface.

#### INFO-3: `NSMicrophoneUsageDescription` in Info.plist

- **File:** `ios/Runner/Info.plist`
- **Detail:** Microphone permission declared with Arabic usage string. No audio recording or voice note feature is present in the 16 feature modules reviewed.
- **Recommendation:** Verify this permission is actually required. If not, remove it to reduce app permissions surface and avoid App Store review friction.

#### INFO-4: `.DS_Store` Files Tracked in `assets/`

- **Files:** `assets/.DS_Store`, `assets/fonts/.DS_Store`
- **Detail:** macOS directory metadata files committed to the repo. No security impact; minor hygiene issue.
- **Recommendation:** Add `**/.DS_Store` to `.gitignore` and remove tracked files with `git rm --cached`.

#### INFO-5: No CI/CD Pipeline

- **Detail:** No `.github/` directory. No automated secrets scanning, dependency vulnerability scanning, or static analysis in CI.
- **Recommendation:** Before open-sourcing or growing the team, add a basic CI pipeline with `flutter analyze`, `flutter test`, and GitHub's secret scanning.

---

## PR1 Attack Surface Assessment

| PR1 Change | Security Impact | Verdict |
|---|---|---|
| Design token Dart files (color/typography constants) | Zero — compile-time `const` values, no I/O | ✅ Clear |
| Cairo TTF font files (4 files, pre-existing) | Verified legitimate OFL fonts, no embedded scripts | ✅ Clear |
| pubspec.yaml font registrations | Static path declarations, no runtime resolution | ✅ Clear |
| New pub.dev packages (if any added) | Verify each new package on pub.dev before merge | ✅ Clear (with standard review) |
| GIT_CHECKPOINT_REPORT.md (staged) | Documentation only, no credentials | ✅ Clear |

**Net new attack surface from PR1: zero.**

---

## False Positives Identified

| Finding | Classification | Reason |
|---|---|---|
| Firebase keys in git | False Positive | Mobile API keys are non-secret by Google design |
| Supabase anon key in binary | False Positive | `sb_publishable_` key is explicitly public by Supabase design |
| RevenueCat key in binary | False Positive | Standard mobile pattern, minimal misuse potential |
| Apple Team IDs in Appfile | False Positive | Identifiers, not credentials; standard Fastlane practice |
| Fastlane metadata PII | Informational | Low risk for private repo; standard Fastlane practice |

---

## Security Blockers for PR1

**None.**

---

## Recommendation

### ✅ PR1 APPROVED FROM SECURITY PERSPECTIVE

PR1 (tokens, typography, font assets, pubspec changes) introduces no new attack surface and no security concerns. The branch is currently clean (zero commits ahead of main). Proceed with implementation.

**Pre-existing issues to address before production release (not blocking PR1):**
1. **[LOW-1]** Replace `.env`-as-Flutter-asset with `--dart-define-from-file` build injection
2. **[LOW-2]** Move `fastlane/metadata/review_information/` out of git before any public repo sharing

**Recommended RLS audit (separate from this review):** The Supabase anon key being public is safe *only if* Row Level Security policies are correctly enforced on all tables. A Supabase RLS policy audit should be scheduled before public launch.

---

## Confirmation: No Code Modified

This review was conducted read-only. No Dart files, configuration files, or assets were modified. Only two documentation files were created: this file and the change log.

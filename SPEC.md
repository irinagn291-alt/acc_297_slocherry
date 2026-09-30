# Tondino — Build Specification

> Portfolio app 92, batch pending. This document is the complete brief for
> building this application. Read all of it before writing any code. Anything
> not specified here is your decision, but must stay consistent with section 3.

**One-line positioning:** Tap the full painting that owns the circular excerpt so that work files as lodged.

| Field | Value |
| --- | --- |
| Product name | Tondino |
| Bundle identifier | `com.tondino.field` |
| Domain | https://tondino-field.pro |
| Contact URL | https://tondino-field.pro/contact-us |
| Deployment target | iOS 17.0 |
| Swift version | 6.2, strict concurrency `complete` |
| Devices | iPhone and iPad, portrait |
| Interface style | Light |
| Asset prefix | `tnd_` |
| User-Agent | `Tondino/1.0 (iOS; +https://tondino-field.pro)` |

---

## 1. Non-negotiable constraints

1. **No CocoaPods.** Dependencies come from Swift Package Manager, a local
   in-repo package, a vendored source folder, or nothing at all — per section 3.
2. **No shared code with other portfolio apps.** Business rules are re-implemented
   here under this app's own type names.
3. **All code, identifiers, comments, UI copy and the README are in English.**
4. **No launch gate, no WebView shell, no remote configuration, no analytics.**
   Guideline 4.2 (Minimum Functionality): this is a native SwiftUI product, not
   a web browsing experience. WKWebView / SFSafariViewController as UI is a
   reject. Push notifications, Core Location, and sharing do not make a
   browser or a thin catalog into an App Store app.
5. **Guideline 5.1.1 (Privacy):** never direct the user to grant camera access.
   A pre-permission screen may exist; the proceed button is **Continue** or
   **Next**, never "Allow camera", "Enable camera", "Grant camera", or a bare
   Allow/Enable that triggers `requestAccess`. The system alert is the only Allow.
6. **No CI files.** No `bitrise.yml`, no `Scripts/`, no `metadata/` folder.
7. **Assets are AI-generated.** No stock photography. SF Symbols may support
   small affordances but must never be the primary iconography.
8. **The app must build clean** with
   `xcodegen generate && xcodebuild -scheme Tondino -destination 'generic/platform=iOS' build`.
9. **Nothing may echo another app in this batch** in naming, layout or visuals.
10. **This is not a calorie meal-slot tracker** unless family is `food_tracker`.
   Do not invent food logging to fill the brief.

---

## 2. Product core

The product is offline-first. No account, no sign-in, no ads, no in-app purchase,
no analytics SDK, no remote config. All user data stays on the device.

A student taps the full panel that owns the circular excerpt so that work files as lodged.

### 2.1 User flow

1. Tap the full panel that owns the circular excerpt
2. Open Explore and save another work into the crate
3. Cut a new tondo from a work that is not yet lodged
4. Review lodged works and chip misses on Saved
5. Open Settings for the collection source

### 2.2 Essential behaviour

- Explore searches one museum catalog and saves works locally
- Quiz punches a circular excerpt from a saved work and hangs four full grounds
- A correct ground files a LodgeMark; a miss files a ChipMark and stays on the same excerpt
- Saved lists lodged works with artist and title plus reviewable chips
- Undo peels the latest LodgeMark or ChipMark
- Seed already cuts one tondo so the first ground tap can file
- No shop and no grade field

---

## 3. Uniqueness assignment for Tondino

| Axis | Assigned value |
| --- | --- |
| Architecture | **Tondo ADT fold (Idle | Cut | Lodged); the field is a fold over Works; Cut writes a Shard and hangs four Grounds; Lodge writes a LodgeMark when the tapped Ground is the donor and folds Cut to Lodged; a miss writes a ChipMark and keeps the Shard; Lodge on Idle is refused; Cut samples a Work that is not Lodged; a crate under four Works writes Idle** |
| UI approach | **SwiftUI pure · take field** |
| Naming convention | **Tondo / roundel lexicon** |
| File organization | **By tondo role (Field, Work, Shard, Ground, LodgeMark, ChipMark)** |
| Dependency strategy | **None** |
| Design direction | **Soft card daylight · take field** |
| Typography | **SF Pro** |
| Navigation pattern | **Tondo-locked chrome (the excerpt never leaves; Explore, Saved and Settings arrive as sheets; cut and lodge fuse on Quiz)** |
| AI art style | **3D glass render glassmorphism · take field** |
| Functional twist | **Cut-then-lodge (Cut punches a circular Shard from a Work that is not Lodged and hangs four Grounds; Lodge writes a LodgeMark when the tapped Ground is the donor and folds Cut to Lodged; a miss writes a ChipMark and keeps the Shard; Lodge on Idle is refused; Cut on fewer than four Works writes Idle)** |
| Persistence | **UserDefaults+Codable** |
| Screen composition | see 3.6 |

### 3.0 Product concept

This is the product the contracts below are assigned to. Do not substitute another.

**Family** — art_quiz

**Core** — A student taps the full panel that owns the circular excerpt so that work files as lodged.

**Audience** — People who remember a painting from a detail and want to lodge that fragment onto a work they already saved, not name a maker from a wall label.

**User flow**

1. Tap the full panel that owns the circular excerpt
2. Open Explore and save another work into the crate
3. Cut a new tondo from a work that is not yet lodged
4. Review lodged works and chip misses on Saved
5. Open Settings for the collection source

**Essential features**

- Explore searches one museum catalog and saves works locally
- Quiz punches a circular excerpt from a saved work and hangs four full grounds
- A correct ground files a LodgeMark; a miss files a ChipMark and stays on the same excerpt
- Saved lists lodged works with artist and title plus reviewable chips
- Undo peels the latest LodgeMark or ChipMark
- Seed already cuts one tondo so the first ground tap can file
- No shop and no grade field

**Twist** — Cut-then-lodge. Home is the field. Cut punches a circular Shard from a saved Work that is not Lodged and hangs four Grounds: the donor plus three others. Lodge writes a LodgeMark when the tapped Ground is the donor and folds Cut to Lodged. A miss writes a ChipMark, cools that Ground, and keeps the same Shard. Lodge while Idle is refused. A second Cut while a Shard is live is refused. Explore writes a Work as Loose; a duplicate accession focuses that row. Lodged works rest on Saved and leave the cut pool. Undo lifts the latest LodgeMark or ChipMark. Cut with fewer than four Works writes Idle. Seed stores several Works and punches one Tondo so the first Ground tap can file. Home verb: lodge-the-tondo, not name-the-hanging-work. Saved counts LodgeMarks and ChipMarks. Settings credits the J. Paul Getty Museum. There is no grade field and no crate-shop field.

**Why this is not a repeat** — This is still art_quiz (Explore, crate, Quiz, Saved, one museum voice, no shop) but the home verb is lodge-the-tondo: a stable circular excerpt must be seated on its donor among four full grounds. Nearby products ask for artist chips, title chips, a canvas under a written cue, a caption line under a full slide, a timed afterimage, or letter glyphs. Those jobs do not appear here. Closed axes reuse catalog leftovers with take-tokens (SwiftUI pure / glassmorphism artquiz5, Soft card daylight take artquiz). New unique axes are the Tondo fold, roundel lexicon, tondo-role folders, tondo-locked chrome, Cut-then-lodge, and Tondo-root sheets. Getty is an unused collection voice.

### 3.0a Craft from the shipped portfolio

Full craft is in KNOWLEDGE.md. Follow it. Do not copy type names or layouts.
- Home: Explore → saved → quiz artist or title.
- Invariant: Quiz draws from saved works. Misses are reviewable. Collecting without a test is the crate clone.
- Never: One collection voice. No shop.
- Taste DNA is section 7.6. Do not invent a second look.
- A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

### 3.1 Architecture contract

Tondo is a closed algebraic fold with cases Idle, Cut, and Lodged; a fourth case is a defect. The field is a fold over Works: Cut samples one saved Work that is not Lodged, punches a circular Shard from that donor, hangs four Grounds as the donor plus three other saved Works, Cut with fewer than four Works writes Idle, and a second Cut while a Shard is live is refused. Lodge writes a LodgeMark when the tapped Ground is the donor and folds Cut to Lodged so the Work leaves the cut pool for Saved. A miss writes a ChipMark, cools that Ground, and keeps the same Shard and Grounds; Lodge on Idle is refused. Undo lifts the latest LodgeMark or ChipMark so a LodgeMark returns Lodged to Loose and the cut pool, and a ChipMark reheats that Ground; Explore writes a Work as Loose with daykey Int YYYYMMDD from Calendar.current.startOfDay, and a duplicate accession focuses the existing Work without resetting Tondo. One observable FieldStore pattern-matches the fold; views call cutTondo, lodgeGround, chipGround, and liftLastMark and never keep a second role enum; unit tests prove not-Lodged sampling, four Grounds with a donor, Lodge-on-Idle refuse, Cut-while-Cut refuse, under-four Idle, miss keep, Undo fold-back, Lodged leaving the pool, duplicate focus, and reviewable ChipMarks.

Put a short comment block at the top of each principal type stating the role it
plays in this architecture. The README must justify the pattern for this product.

### 3.2 UI contract

100 percent SwiftUI, Light. No UIViewRepresentable, no WKWebView, no Safari sheet, no camera preview, no TabView. The ui axis restates SwiftUI pure with take-token field: first of this take, so compose an original circular excerpt over four full grounds, not a name-chip row, not a four-face lineup, not a caption under a full slide, not a timed afterimage, not letter glyphs, and not a museum browser. Do not copy holder file trees, type names, or layouts. Do not ship a title screen named Tondino or SwiftUI. Home is the mechanic and follows Soft card daylight hero-rail: Quiz is one large circular Shard photo-tile filling remaining height and the iPad width, a short caption under the tile not on it, a grounds rail of four full panels, and one secondary LodgeMark plus ChipMark stat. Adjacent blocks do not share a column. The shard is the hero. The four Grounds are a secondary rail, not four equal cards matching the hero. Soft shadow only on the shard. Every other surface is flat fill. One Ground is the donor. Three distractors come from other saved Works or the bundled Getty shelf. Cut and Lodge fuse on that field. Cut does not auto-advance after Lodged. Confine custom drawing to that one Quiz hero, a circular mask with Shape or Path. Explore, Saved, and Settings are stock sheets, List and Form. Kit is Soft card daylight: radius 20, radius_small 12, one shadow elevation, soft-card chrome through one accessor. Primary Cut is a full-width pill ButtonStyle with default, pressed, disabled, and loading. Each Ground is a native Button on the whole panel with contentShape, min 44pt, one target. Undo is not the destructive variant. resetAllData is. Empty Quiz as Idle, empty Explore, and empty Saved are full pages, frame maxHeight infinity, with generated cutout art, one headline, one line, and a bottom full-width pill CTA. Snap motion: press scale 0.97 in 140 to 180ms ease-out, sheets scale 0.96 to 1 plus fade. Reduce Motion is opacity only. Colour is never the only miss signal. A miss also cools and strikes that Ground. One haptic on a successful LodgeMark, none on ChipMark, none on presenting a sheet. VoiceOver labels on every icon-only sheet control. Warm voice, short verbs, no em dash, no emoji. The ui axis string is never a section title.

### 3.3 Naming contract

Convention: Tondo / roundel lexicon.

Examples to follow: `Tondo`, `lodgeGround(_:)`, `LodgeMark`, `liftLastMark()`

### 3.4 Dependency contract

None. project.yml has no packages key. No SPM, no CocoaPods, no bundled font. SF Pro is the system face. Foundation, SwiftUI, and URLSession only. The leftover AVCaptureMetadataOutput scanner stays unused: do not import AVFoundation or Vision for capture, do not request camera access, and do not ship a live NSCameraUsageDescription flow. Honor the cgi search pl assignment as paginated JSON search: query, json, page, page_size mapped onto GET https://data.getty.edu/museum/sparql with query and format=json, LIMIT page_size, OFFSET (page minus 1) times page_size, then hydrate each object URI with GET https://data.getty.edu/museum/collection/object/{id}. Never call world.openfoodfacts.org or /cgi/search.pl. Never Open Food Facts, calories, meal slots, or a food catalog. Never api.artic.edu, collectionapi.metmuseum.org, openaccess-api.clevelandart.org, www.rijksmuseum.nl, api.harvardartmuseums.org, or api.nga.gov. Dedicated JSONDecoder. DTO CodingKeys map Getty Linked Art JSON-LD (identified_by, produced_by, representation, _label) without convertFromSnakeCase, then map to domain Work. Identity is the Getty accession number. Maker is produced_by carried_out_by _label. Title is _label. Prefer a non-empty IIIF representation. Thumbs use https://media.getty.edu/iiif/image/{id}/full/843,/0/default.jpg. Set User-Agent Tondino/1.0 (iOS; +https://tondino-field.pro) on every request. Debounce search about 500 ms, cancel the previous Task, empty query does not hit the network. Cache resolved works locally so empty or failed search still cuts from the bundled Getty shelf. Settings credits the J. Paul Getty Museum as tappable source links (https://www.getty.edu and https://www.getty.edu/projects/open-content-program/).

### 3.5 Navigation contract

Tondo-locked chrome: Quiz is the root field and never leaves. The circular excerpt stays on Quiz. There is no TabView and no pushed museum detail. Cut, Lodge on a Ground, and Undo fuse on Quiz. Explore, Saved, and Settings arrive as sheets over the field. Four destinations, never exactly three tabs. App Intents open Quiz, Explore, Saved, or Settings, or fire cutTondo or lodgeGround in place. Custom URL scheme tondino routes tondino://quiz, tondino://explore, tondino://saved, tondino://settings, and the matching https://tondino-field.pro paths into those same jobs. One haptic on a successful LodgeMark, none on presenting a sheet. Contact URL https://tondino-field.pro/contact-us lives on Settings. Undo is also reachable from Settings. After onboarding, read ProcessInfo.processInfo.arguments once: -ReviewScreen today stays on Quiz, log presents Saved, goals presents Settings. Extra key explore presents Explore. Skip onboarding on Simulator after the tnd.demo.v1 seed so the hook can fire.

### 3.6 Screen composition contract

Tondo-root fused quiz (Quiz holds the excerpt and grounds; Explore, Saved and Settings are sheets). Physical screens: Quiz, Explore, Saved, Settings. Quiz is the locked field (ReviewScreen today): Cut punches a circular Shard from a Work that is not Lodged and hangs four Grounds; Lodge files the donor Ground; Undo lifts the latest mark; status shows Idle, Cut, Lodged, Chip. Explore is a sheet that searches the J. Paul Getty Museum and writes a Loose Work, with a local Getty shelf when search is empty or fails (deep link explore). Saved is a sheet of Lodged works with artist and title plus reviewable ChipMarks (ReviewScreen log). Settings is a Form for Getty credit, Undo, contact URL at https://tondino-field.pro/contact-us, re-run onboarding, and resetAllData (ReviewScreen goals). Onboarding is a one-shot cover of three pages with Continue or Next at the bottom full width. Empty Quiz with fewer than four Works is Idle as a full page: generated cutout art, headline Field waiting., one line Save four works, then cut., full-width bottom Explore. Empty Explore and empty Saved are full pages of their own. Seeded Quiz already punches one Tondo so Lodge is live; Idle is a test fixture, not the first frame. No Today, Scan, Search, or Goals screens. ReviewScreen today, log, and goals must open three different screens.

Section 5 lists the logical functions that must exist. This section decides how
they are grouped into actual screens. Where the two disagree, this section wins.

A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

---

## 4. Target file organization

Scheme: **By tondo role (Field, Work, Shard, Ground, LodgeMark, ChipMark)**

```
Tondino/
  Field/
  Field.swift
  Tondo.swift
  FieldStore.swift
  QuizView.swift
  FieldLinks.swift
  SettingsView.swift
Work/
  Work.swift
  ExploreView.swift
  SavedView.swift
  CatalogClient.swift
  GettyShelf.swift
Shard/
  Shard.swift
Ground/
  Ground.swift
LodgeMark/
  LodgeMark.swift
ChipMark/
  ChipMark.swift
  Assets.xcassets/
```

Adapt the leaf files to the architecture, but the top-level shape is fixed. Do
not create a `Utils/` or `Helpers/` dumping ground.

---

## 5. Screens

Build the screens named in section 3.6. The labels below are logical;
actual type names follow this app's naming convention.

### 5.1 Onboarding
Three to four pages. Explains the product, writes initial settings, sets a
completion flag. Skip still writes sensible defaults. Re-runnable from Settings.

### 5.2 Explore
A first-class screen for **Explore**. Must render empty, populated and error states.

### 5.3 Saved
A first-class screen for **Saved**. Must render empty, populated and error states.

### 5.4 Quiz
A first-class screen for **Quiz**. Must render empty, populated and error states.

### 5.5 Settings
A first-class screen for **Settings**. Must render empty, populated and error states.

### 5.6 Settings
Holds: re-run onboarding, reset all data (confirmed), and the contact link to
the domain contact-us URL.

### 5.7 Twist screen
See section 12. The twist needs at least one screen of its own plus a surface on the home screen.


---

## 6. Domain model

Minimum entities, named per this app's convention:

- **Work** — named per this app's convention.
- **QuizCard** — named per this app's convention.
- Plus whatever the twist in section 12 requires.


---

## 7. Design system

Direction: **Soft card daylight · take field**

### 7.1 Palette

| Token | Hex | Use |
| --- | --- | --- |
| `background` | `#FAF7F5` | Screen background |
| `surface` | `#FEFEFD` | Cards, rows, sheets |
| `ink` | `#392818` | Primary text and icons |
| `accent` | `#CC6D19` | Primary action, key figure, progress fill |
| `muted` | `#816C5A` | Secondary text, dividers, disabled |

Define these as named colours in `Assets.xcassets` and reach them through one
typed accessor. Never hard-code a hex string anywhere else.

### 7.2 Typography

Family: **SF Pro**

SF Pro via Font.system as the short-display type move: at most four words on the display line, tight leading, a small body line under the tondo. Display is Lodge and the caption under the shard, short and wide, one or two lines, never more than four words, never above 34pt. Body is SF Pro about 17pt for Saved lodged artist and title lines and Explore rows. Caption and micro sit under the tile for Idle, Cut, Lodged, Chip. At most six named steps behind one accessor: display, title, headline, body, caption, micro. Weights and step carry hierarchy. No Font.custom, no fixedSize, never below 12pt, no serif, no second family. LodgeMark counts, ChipMark counts, and day keys go through NumberFormatter with tabular figures. Dynamic Type; at AX5 Lodge may drop a step so it never clips; names truncate, numbers win. @ScaledMetric for any custom size. Day edges use Calendar.current.startOfDay then fold to Int YYYYMMDD.

Define a type scale of at most six steps behind one accessor and use only those
steps. Text stays legible at the largest Dynamic Type size.

### 7.3 Layout

- One base spacing unit (4 or 8 pt); only multiples of it.
- Corner radius and elevation are fixed by section 7.4, not chosen per screen.
- Every interactive element is at least 44x44 pt.

### 7.4 Component contract

Corner radius: **20pt** for cards, sheets and primary surfaces; **12pt** for chips, badges and small controls. Reach both through one accessor. Never a bare literal number, and never zero — a hard edge is not this app's design direction.

Elevation: **shadow** — a single soft drop-shadow token, reused everywhere a surface sits above another.

Primary control: **soft card** — primary actions live inside a rounded card using the radius below, not a flat row with no fill.

This is arithmetic, not a suggestion: every card, sheet, chip and button in this app uses these two radii and this elevation style. Do not introduce a second radius or a second elevation style.

This assignment restates a catalog technique another app already holds. Write a new composition: new types, new layout, new motion. Do not copy source, file trees, or type names from the holder.

### 7.5 Custom rendering scope

This app's `ui` axis is **SwiftUI pure · take field**.

If that approach uses anything beyond stock SwiftUI/UIKit controls — `Canvas`, `CALayer`, Metal, SceneKit, SpriteKit, RealityKit, a hand-drawn `UIViewRepresentable`, or any other pixel-level custom rendering — confine it to exactly one hero surface on one screen (the mechanic's home view, or the one screen this axis exists to showcase). Every other screen — every list, every settings screen, every sheet, every secondary surface — is built from stock components: `List`, `Form`, `NavigationStack`, `TabView`, `Button`, `.sheet`, native `Text`/`Image`. A second custom-rendered surface elsewhere in the app is a defect, not a stylistic choice.

If **SwiftUI pure · take field** is already fully native (no custom drawing layer), this section is satisfied automatically — there is nothing to confine.

The `ui` axis value is an implementation choice. It must never appear as a user-visible section title or label.

This assignment restates a catalog technique another app already holds. Write a new composition: new types, new layout, new motion. Do not copy source, file trees, or type names from the holder.

### 7.6 Taste DNA

Aesthetic: **warm** (Warm soft: friendly radii, comfortable pad, one playful moment.)

Reference system: **airbnb** — steal rhythm and restraint, not their colours or logos.

Mood: **hospitable**.

Home rhythm (`hero-rail`, comfortable): One large photo-tile mechanic, a recent rail, one secondary stat. Uneven 2+1.

Photography-first home. Caption sits under the tile, not on it. Pill CTA. Soft shadow only on the hero; every other surface is flat fill.

Type move: Short display (max four words), tight leading, small body under it.

Motion (`snap`): Press scale 0.97, 140-180ms ease-out. Sheets scale 0.96 to 1 plus fade. Reduce Motion: opacity only.

Voice (`warm`): Human and brief. Empty states invite. Errors stay calm and useful.

Anti-slop from KNOWLEDGE.md applies. Taste never overrides contrast, 44pt hits, VoiceOver labels, or Reduce Motion.

This assignment restates a catalog technique another app already holds. Write a new composition: new types, new layout, new motion. Do not copy source, file trees, or type names from the holder.

---

## 8. UI and UX quality bar

Every item here is a defect if it is missing. Do not treat this as advice.

**Layout**

- Respect safe areas on every screen. Nothing sits under the notch, the Dynamic
  Island or the home indicator.
- The app is portrait-only on iPhone. Lock it in the Info settings and do not
  write rotation-dependent layout.
- No layout shift when asynchronous data arrives. Reserve the final size up
  front, or use a redacted placeholder of the same dimensions.
- Long product names must truncate gracefully, never push a number off screen.
  Numbers win; names truncate.
- Minimum tap target 44x44 pt for every interactive element, including small
  icon buttons and list accessories.
- Pick one base spacing unit and use only multiples of it. No arbitrary values.

**Keyboard**

- The grams field uses `.decimalPad`, and the decimal separator matches the
  user's locale.
- Content scrolls out from under the keyboard. The focused field is always
  visible.
- Tapping outside the field, or scrolling, dismisses the keyboard.
- Validate on the fly: reject negative and non-numeric input rather than
  crashing the parser later.

**Loading and state**

- Every asynchronous operation has a visible loading state.
- Guard against the spinner flash: if the work finishes in under 150 ms, do not
  show a spinner at all.
- Every list has a designed empty state containing a primary action, not just a
  sentence of text.
- Every error state offers a retry, and states plainly what failed.
- Disable the primary button while its action is in flight so it cannot be
  double-tapped into a double push or a duplicate entry.

**Typography and accessibility**

- All text scales with Dynamic Type. Verify at the largest accessibility size:
  nothing may clip or overlap.
- Every icon-only control has an `accessibilityLabel`. Decorative images are
  marked as decorative so VoiceOver skips them.
- Colour is never the only signal. Pair it with a label, a shape or an icon.
- Honour Reduce Motion: replace movement-heavy transitions with a fade.
- Meet contrast requirements against the palette in section 7. Check the muted
  colour against the background specifically; that is where these palettes fail.

**Formatting**

- Format every number with `NumberFormatter`, never string interpolation. Group
  separators and decimal separators must follow the locale.
- Energy is shown as a whole number of kcal. Macros are shown with at most one
  decimal place.
- Round only at the point of display. Stored values keep full precision.
- Day boundaries use `Calendar.current.startOfDay(for:)` in the user's current
  time zone. Handle the day changing while the app is open, and handle the
  short and long days that daylight saving produces.
- Unknown macro values render as a dash or the word "unknown", never as 0.

**Motion and feedback**

- One haptic on a successful commit (a food logged, a target saved). No haptic
  on navigation.
- Animations are short (0.2 to 0.35 s) and use a single shared easing curve.
- Nothing animates on first appearance of a screen except an intentional entry
  transition.

**Navigation**

- Back always works and never loses entered data without asking.
- A destructive action (delete a log row, reset all data) is confirmed.
- Modal sheets can always be dismissed; there is no dead end.
- Deep state is restorable: relaunching returns the user to a sane screen.


Every item here is a defect if it is missing. Section 7.4 fixed the numbers —
this is where they have to show up on screen.

**Hierarchy and density**

- Every screen has exactly one dominant element (a hero number, a canvas, a
  primary card) that the eye lands on first. A screen where every element has
  equal weight reads as a spreadsheet, not a product.
- Related content is grouped into a card or a section with the elevation
  style from 7.4, not left floating on the bare background.
- Unused flat background is not "minimal" — see the density rule in
  `KNOWLEDGE.md`. If a screen has room left after the mechanic and the
  content, add a secondary surface (a stat strip, a recent-activity card, a
  related-item row), not a `Spacer`.

**Components**

- Every card, sheet, chip, row and button in the app uses the corner radius
  and elevation from section 7.4. No screen introduces its own radius or its
  own shadow value "just for this one card".
- Buttons have a pressed state (`ButtonStyle` with a scale or opacity change
  on `isPressed`) and a disabled state that is visibly different, not just
  non-interactive.
- Chips and badges are pill or rounded-rect shaped per 7.4, never a bare
  `Text` with no background sitting where a control is expected.
- A functional control (add, filter, sort, close, more, share, delete) is an
  SF Symbol inside a properly hit-targeted `Button`. SF Symbols are fine and
  expected here — section 16 only bans them as the app's primary brand
  iconography (app icon, empty-state hero, onboarding art), which is what the
  generated assets in section 13 are for.

**Depth and material**

- At least one surface in the app (a sheet, a modal, a floating toolbar) uses
  the elevation style from 7.4 to visibly sit above the content behind it.
  A flat app with no depth anywhere reads as a wireframe.
- Icons and generated art sit on the surface colour from 7.1, never directly
  on a colour that makes their edges disappear.

**Motion as feedback, not decoration**

- The one dominant element in a screen (7.4's primary control, the mechanic's
  hero) responds visibly to touch: a scale, a colour shift, a haptic — pick
  at least one. A control that looks identical pressed and unpressed reads as
  broken, not calm.

**Taste DNA (section 7.6)**

- Home uses the assigned layout family and density. Three identical equal-weight
  cards, a leftover bento hole, or a second column structure copied down the
  page is a defect.
- Copy follows the assigned voice. No em-dash, no elevate/unlock/seamless, no
  emoji, no SECTION 01 labels.
- Motion follows the assigned personality and honours Reduce Motion with a fade.
  One signature motion per view. No glow stacked on glass stacked on spring.
- Tokens by intent: the live verb wears accent; delete does not wear primary.


---

## 9. Concurrency

The target builds with Swift 6.2 and `SWIFT_STRICT_CONCURRENCY = complete`. It
must compile with **zero concurrency warnings**. Warnings here become crashes
later, so they are not negotiable.

- All UI types are `@MainActor`. Annotate the type, not individual methods.
- Any value crossing an actor boundary is `Sendable`. Prefer immutable structs
  of primitives.
- Do not use `@unchecked Sendable`. If it is genuinely unavoidable, it needs a
  comment explaining what guarantees the safety.
- No mutable global state. No `static var` that is written after launch.
- Networking and storage APIs are `async` and honour cancellation. When the
  search query changes, cancel the in-flight task; do not let a stale response
  overwrite fresh results.
- Use structured concurrency. Avoid `Task.detached` unless there is a stated
  reason. Never fire a `Task` that outlives the view without owning it.
- Never use `DispatchQueue.main.asyncAfter` to paper over an ordering problem.
  Fix the ordering.
- `Timer` and notification observers are invalidated in `deinit` or on
  disappear.


---

## 10. Persistence engineering

Chosen technology: **UserDefaults+Codable**

One Codable FieldDocument (schemaVersion from 1, Works with role Loose or Lodged, live Shard, Grounds, LodgeMarks, ChipMarks, cached catalog rows, daykeys as Int YYYYMMDD) encoded to JSON Data in UserDefaults under tnd.field.v1. Tondo case is stored on the field; lodged-ness is the Work role, not a parallel bool. Idle is a field write, not a stored Work case. In-memory FieldStore is the source of truth; UserDefaults is the projection. Views never touch UserDefaults. Debounce writes. Flush when scenePhase becomes inactive or background, and after Cut, LodgeMark, ChipMark, Undo, Explore save, or reset. Decoding failure falls back to tnd.field.v1.backup, then an empty field, never a crash. resetAllData() is reachable from Settings. Tests use a private UserDefaults suite. Simulator seed only once behind tnd.demo.v1 writes several Works from the local Getty shelf so Cut can hang four Grounds, punches one Tondo so Lodge is live, files several LodgeMarks and ChipMarks so Saved is a used product, marks onboarding complete, and never seeds Idle as the first frame. Never seed on a device. Cached works catch empty or failed Getty search.

This app persists to **files on disk**. The following are mandatory.

- Write atomically. Either `Data.write(to:options: .atomic)` or write to a
  temporary file and `FileManager.replaceItemAt`. A non-atomic write that is
  interrupted leaves a truncated file and the app will not launch.
- Create the containing directory with
  `withIntermediateDirectories: true` before the first write.
- Every document carries a `schemaVersion` field from version 1, and the decoder
  switches on it.
- Decoding failure must be recoverable: keep the previous good file as a
  `.backup`, fall back to it, and if that also fails start from empty state and
  tell the user. Never crash on a corrupt file.
- All file IO happens off the main thread. The main thread never blocks on disk.
- Debounce writes during rapid edits, but force a flush when `scenePhase`
  becomes `.inactive` or `.background`, and after any destructive action.
- Exclude caches from backup with `URLResourceValues.isExcludedFromBackup` where
  appropriate; user data belongs in Application Support and should be backed up.
- Keep an explicit in-memory source of truth and treat the file as a projection
  of it, so a failed write never leaves the UI showing data that does not exist.


Regardless of technology:

- One seam between domain logic and storage; the UI never touches storage types.
- Writes survive a force-quit. Do not rely on `applicationWillTerminate`.
- Provide `resetAllData()`, used by tests and reachable from Settings.

---

## 11. Networking

- One client type owns both Open Food Facts endpoints.
- Set `User-Agent` on every request. Open Food Facts throttles clients that do
  not identify themselves.
- 15 second timeout. One retry on a transient transport failure, then a typed
  error. Do not retry a 404.
- Cancel the in-flight search when the query changes. Debounce input by roughly
  300 ms.
- Decode into DTO types that mirror the JSON exactly, then map to domain types.
  Never decode straight into your domain model.
- Dedicated `JSONDecoder` with `.useDefaultKeys`. Never `convertFromSnakeCase` —
  Open Food Facts keys like `energy-kcal_100g` break snake_case conversion.
- Resolve a scanned code with `GET /api/v2/product/<barcode>.json`, not a search.
- Open Food Facts data is user-contributed and frequently incomplete. Every
  numeric field is optional. A product with no energy value is a normal case
  that the UI must present, not an error.
- Some numeric fields arrive as strings. The decoder must accept both a number
  and a numeric string for every nutriment.
- `status` of `0` in the product response means not found. Map it to a distinct
  error case so the UI can offer manual entry.
- Never crash on malformed JSON. A decoding failure is a handled error.
- Cache every resolved product locally on success, so the app degrades to a
  working offline catalogue.


Set `User-Agent: Tondino/1.0 (iOS; +https://tondino-field.pro)` on every request. Never reuse another app's string.
Use the **cgi search pl** search endpoint for this app.

---

## 11b. App Store readiness

The app must be submittable without further work.

- `PrivacyInfo.xcprivacy` in the target, declaring the UserDefaults access API
  reason `CA92.1` and the file timestamp reason `C617.1`, with
  `NSPrivacyTracking` false and no collected data types.
- `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO` in the pbxproj so TestFlight
  does not sit on Missing Compliance.
- `NSCameraUsageDescription` written specifically for this app. Generic strings
  get rejected.
- `LSApplicationCategoryType` of `public.app-category.healthcare-fitness`.
- Portrait only, iPhone and iPad (`TARGETED_DEVICE_FAMILY = "1,2"`).
- No account, no sign-in, no delete-account flow, no in-app purchase, no ads, no
  user-generated content, and therefore no report or block UI.
- App Tracking Transparency is never invoked.
- The camera is the only sensitive permission requested.
- Guideline 5.1.1 (Privacy): do not encourage or direct the user to grant camera
  access. A pre-permission screen may exist, but the proceed button must be
  **Continue** or **Next** — never "Allow camera", "Enable camera",
  "Grant camera", or a bare Allow/Enable that calls `requestAccess`. The
  system dialog is the only Allow. Denied/restricted offers Open Settings.
- The app must not present itself as a clinician or as medical advice.
- Guideline 4.2 (Design — Minimum Functionality): the binary must be a native
  product, not a web browsing experience. No WKWebView / SFSafariViewController
  / UIWebView as home, a tab, or the primary UX. A content catalog, article
  reader, or site wrapper that could be a website is a reject. Push
  notifications, Core Location, and sharing do not make that acceptable.
- Guideline 1.4.1 (Safety — Physical Harm): if the binary shows health or
  medical recommendations, body-based targets, dosages, "you should" guidance,
  or product health claims (food, drink, supplement, remedy), put citations
  in the app. Tappable links to the sources, easy to find: same screen as the
  claim, or a Sources row one tap from Settings. Name the source (Open Food
  Facts, USDA FoodData Central, WHO, NIH MedlinePlus, …) and link it. A
  "not medical advice" footer without sources is a reject. A personal log
  that never advises does not invent claims to cite.
- Nutrition catalog data is credited to the database this app actually uses
  (Open Food Facts unless the spec names another). Credit is a tappable link,
  not a dead "OpenFoodFacts" label.


Ignore the food-log and Open Food Facts lines above when they conflict with this
family. Category for this app is `public.app-category.education`. Camera permission only if the
product actually captures.

Project settings that follow from the above:

```yaml
INFOPLIST_KEY_UIUserInterfaceStyle: Light
INFOPLIST_KEY_UISupportedInterfaceOrientations: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UIRequiresFullScreen: YES
INFOPLIST_KEY_ITSAppUsesNonExemptEncryption: NO
INFOPLIST_KEY_LSApplicationCategoryType: public.app-category.education
TARGETED_DEVICE_FAMILY: "1,2"
SWIFT_STRICT_CONCURRENCY: complete
```

---

## 12. Functional twist: Cut-then-lodge (Cut punches a circular Shard from a Work that is not Lodged and hangs four Grounds; Lodge writes a LodgeMark when the tapped Ground is the donor and folds Cut to Lodged; a miss writes a ChipMark and keeps the Shard; Lodge on Idle is refused; Cut on fewer than four Works writes Idle)

Home is lodge-the-tondo: Cut punches a circular Shard from a saved Work that is not Lodged and hangs four full Grounds, the donor plus three others, so the student seats the excerpt on its panel, not a name chip and not a hanging-work label. Lodge writes a LodgeMark when the tapped Ground is the donor and folds Cut to Lodged; a miss writes a ChipMark, cools that Ground, and keeps the same Shard. Lodge while Idle is refused; a second Cut while a Shard is live is refused; Cut with fewer than four Works writes Idle. Explore writes a Work as Loose from the J. Paul Getty Museum or the local Getty shelf; a duplicate accession focuses that row; Lodged works rest on Saved and leave the cut pool; Undo lifts the latest LodgeMark or ChipMark. Simulator seed stores several Works and punches one Tondo so the first Ground tap can file; Saved counts LodgeMarks and ChipMarks; Settings credits the J. Paul Getty Museum; there is no grade field, no crate-shop field, and no WebView museum.

This is the app's marketed differentiator. It must be:

- visible on the home screen, not buried in settings;
- backed by real persisted data, not a cosmetic flourish;
- covered by at least one unit test;
- described in the README as the reason a user would pick this app.

---

## 13. AI-generated assets

Art style: **3D glass render glassmorphism · take field**


This assignment restates a catalog technique another app already holds. Write a new composition: new types, new layout, new motion. Do not copy source, file trees, or type names from the holder.

Base prompt, reused and extended for every asset:

```
3D glass render, glassmorphism, studio-lit circular tondo over four full grounds, frosted roundel refraction and soft bloom, isolated subjects, quiet uncluttered ground, no text, no letters, no logo, no photoreal stock, no specified colours, one circular excerpt over full panels not a name-chip row, not a four-face lineup, and not a museum grid
```

All 15 images below are required. Generate each one, export
as PNG, and add it to `Assets.xcassets` as its own image set named exactly as
given. Every name carries the `tnd_` prefix.

### 13.1 App icon rules (strict)

The icon is rejected by App Store Connect if any of these are wrong:

- Exactly **1024 x 1024 px**.
- **No alpha channel.**
- sRGB colour profile, 8 bits per channel, PNG.
- **No text and no words** in the artwork.
- **No rounded corners and no built-in mask.**
- The subject stays inside the middle 80%.

### 13.2 Full asset list

| # | Image set | Size (px) | Alpha | Purpose |
| --- | --- | --- | --- | --- |
| 1 | `tnd_AppIcon` | 1024x1024 | **NO** | App Store icon. NO alpha channel, NO transparency, NO text, NO rounded corners, NO drop shadow outside the canvas. |
| 2 | `tnd_Splash` | 1290x2796 | fill | Launch background. The middle third must stay quiet so the wordmark reads on top. |
| 3 | `tnd_Onboarding1` | 1024x1536 | **required cutout** | Onboarding page 1 illustration: what the app is for. |
| 4 | `tnd_Onboarding2` | 1024x1536 | **required cutout** | Onboarding page 2 illustration: the main verb. |
| 5 | `tnd_Onboarding3` | 1024x1536 | **required cutout** | Onboarding page 3 illustration: why they stay. |
| 6 | `tnd_EmptyHome` | 1024x1024 | **required cutout** | Empty state: the home screen has nothing yet. Calm and inviting, never sad. |
| 7 | `tnd_EmptyList` | 1024x1024 | **required cutout** | Empty state: a secondary list has no rows. |
| 8 | `tnd_CardBackdrop` | 1200x800 | fill | Backdrop art for a primary card. Low contrast so text stays readable. |
| 9 | `tnd_ControlFace` | 512x512 | **required cutout** | Custom control artwork used for the primary interactive element. |
| 10 | `tnd_TwistHero` | 1024x1024 | **required cutout** | Hero art for the 'Cut-then-lodge (Cut punches a circular Shard from a Work that is not Lodged and hangs four Grounds; Lodge writes a LodgeMark when the tapped Ground is the donor and folds Cut to Lodged; a miss writes a ChipMark and keeps the Shard; Lodge on Idle is refused; Cut on fewer than four Works writes Idle)' feature screen. |
| 11 | `tnd_SuccessMark` | 512x512 | **required cutout** | Shown briefly when the primary action succeeds. |
| 12 | `tnd_HeaderDecor` | 1200x600 | **required cutout** | Decorative header accent on the main screen. |
| 13 | `tnd_TondoHoop` | 1024x1024 | **required cutout** | Isolated solid wooden circular tondo hoop, cutout, transparent corners, opaque wood filling the center, no plate, no hollow frame, no text |
| 14 | `tnd_CircularShard` | 1024x1024 | **required cutout** | Isolated solid circular linen excerpt disc, cutout, opaque cloth filling the center, transparent corners, no plate, no text |
| 15 | `tnd_GroundPanel` | 1024x1024 | **required cutout** | Isolated solid rectangular linen panel on a stretcher, cutout, opaque fabric and wood, transparent corners, no plate, no text |

### Prompt per asset

**`tnd_AppIcon`** — 1024x1024

```
A single 3D glass circular tondo, a roundel filling the canvas edge to edge, glassmorphism, subject centred, no text, no letters, no words, no alpha, no transparency, no rounded corners, no drop shadow outside the canvas
```

**`tnd_Splash`** — 1290x2796

```
A tall vertical 3D glass field, one circular tondo receding, quiet uncluttered centre band for a wordmark, glassmorphism, no readable text
```

**`tnd_Onboarding1`** — 1024x1536

```
Solid linen circular tondo on a stretcher, the product in one glance, isolated cutout, opaque cloth in the center, transparent corners, no glass box, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`tnd_Onboarding2`** — 1024x1536

```
A hand tapping one solid full panel under a circular linen excerpt, cut then lodge, isolated cutout, opaque subject in the center, no hollow frame, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`tnd_Onboarding3`** — 1024x1536

```
A short stack of lodged roundel panels beside one circular excerpt, meaning accumulated, isolated cutout, opaque subjects, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`tnd_EmptyHome`** — 1024x1024

```
A solid empty wooden tondo hoop with no excerpt, waiting, calm and inviting, never sad, isolated cutout, opaque wood in the center, no hollow glass, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`tnd_EmptyList`** — 1024x1024

```
A solid empty salon shelf with no lodged panels, calm, isolated cutout, opaque wood, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`tnd_CardBackdrop`** — 1200x800

```
Abstract low-contrast 3D frosted glass roundel bloom, quiet enough for text on top, filling the canvas, no letters
```

**`tnd_ControlFace`** — 512x512

```
The face of a small solid wooden tondo hoop as a physical control, isolated cutout, opaque wood, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`tnd_TwistHero`** — 1024x1024

```
Solid circular linen excerpt seated over four full panels, cut-then-lodge emblem, isolated cutout, opaque subjects, no hollow glass, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`tnd_SuccessMark`** — 512x512

```
A small solid wooden roundel seated after a true lodge, confirmation not fireworks, isolated cutout, no letters

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`tnd_HeaderDecor`** — 1200x600

```
A wide low solid wooden tondo rail with linen tape edges, isolated cutout, opaque wood and cloth in the center, transparent corners, no glass pane, no readable text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`tnd_TondoHoop`** — 1024x1024

```
Isolated solid wooden circular tondo hoop, cutout, transparent corners, opaque wood filling the center, no plate, no hollow frame, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`tnd_CircularShard`** — 1024x1024

```
Isolated solid circular linen excerpt disc, cutout, opaque cloth filling the center, transparent corners, no plate, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`tnd_GroundPanel`** — 1024x1024

```
Isolated solid rectangular linen panel on a stretcher, cutout, opaque fabric and wood, transparent corners, no plate, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```


### 13.3 Asset rules

- Cut-outs (everything except AppIcon, Splash, CardBackdrop): isolated subject,
  real PNG alpha, all four corners transparent. No square plate.
- Assets must be semantically different from each other.
- Record the exact prompt used for every asset in the README.
- SF Symbols are permitted only for close, chevron, share and similar system
  affordances.

Scanner frames, reticles, and seamless tiles are drawn in SwiftUI via `Path` or `Shape`. GenerateImage is not used for those. Every other in-app graphic (except AppIcon, Splash, CardBackdrop) is a **cutout**: isolated SOLID opaque subject in the center, real PNG alpha, all four corners transparent. An opaque square plate inside a circle or pentagon is a fail. A hollow glass box or wire frame with a transparent center is a fail.

---

## 14. Demo data

Seed a small local demo dataset for this family's entities so Simulator
screenshots are not empty. The same seed must mark onboarding complete and
fill the primary surface — otherwise `-ReviewScreen` never fires. Never seed
on a physical device. Guard with `#if targetEnvironment(simulator)` and
`tnd.demo.v1`.

Seed the happy path: the home primary verb is enabled. The blocked / gated /
error state is a unit-test fixture, not Simulator home. Home chrome names the
job and the next tap in words a stranger knows. Axis values (`ui`, `naming`,
`architecture`) never become user-visible titles. A card that looks tappable
is a `Button`. A readout does not use button chrome.

---

## 16. Anti-patterns

The following will fail review:

- `try!`, `as!`, or force-unwrapping anything derived from the network, the
  database or a file.
- `fatalError` anywhere reachable at runtime. It is acceptable only for a
  programmer error in an initialiser that cannot fail in practice, and needs a
  comment.
- Swallowing an error with an empty `catch`.
- `print` used as production logging.
- A hard-coded hex colour outside the single colour accessor.
- A hard-coded font name outside the single typography accessor.
- An SF Symbol used as the app's brand iconography — the app icon, the
  empty-state hero, or onboarding art. Those come from section 13. SF Symbols
  are the right choice for every functional control (add, filter, sort,
  close, share, delete) — leaving those as bare text instead of a symbol is
  also a defect.
- Storing a value that can be computed (day totals, remaining budget, macro
  percentages).
- Blocking the main thread on disk or network work.
- `UIScreen.main` for sizing. Use the geometry the layout system gives you.
- Index positions used as list identity. Identity is a stable identifier.
- A view that reaches into the persistence layer directly, bypassing the
  architecture's designated seam.
- Business logic inside a `View` body or a `UIViewController` method, when the
  assigned architecture places it elsewhere.
- Copying a source file from another app in this batch.
- A `TabView` with exactly three tabs. That is the factory stamp — two or
  four-to-five destinations, or a different chrome. ReviewScreen keys are
  not tabs.


---

## 17. Tests

Add a unit test target `TondinoTests` covering at minimum:

1. The core domain invariant of this family (the thing that would be wrong if
   the calculator, decay, crate, or log lied).
2. Empty, populated and invalid input paths for the primary verb.
3. The section 12 twist logic.
4. One architecture-specific test proving the pattern holds.
5. A persistence round-trip: write, relaunch-equivalent reload, verify.
6. Parse `ProcessInfo.processInfo.arguments` once after onboarding. 
   `-ReviewScreen today|log|goals` switches the running app's live navigation. Extra cover slugs open those screens.
   Cover that parser with a unit test. Do not host a `View` in the test.

---

## 18. README.md

Write `README.md` at the app folder root covering:

1. What the app does and who it is for.
2. The architecture used and **why** it suits this product.
3. The unique feature added and how it works.
4. The AI art style and the exact prompt used for every asset.
5. How this app differs from others in the batch.
6. Build instructions.

---

## 19. Definition of done

**Build**
- [ ] `xcodegen generate` succeeds.
- [ ] `xcodebuild -scheme Tondino -destination 'generic/platform=iOS' build` succeeds.
- [ ] Zero new compiler warnings.
- [ ] Strict concurrency `complete` compiles clean.
- [ ] Test target passes.

**Function**
- [ ] Onboarding to first successful primary action works on a clean install.
- [ ] Every screen in section 3.6 exists and handles empty / filled / error.
- [ ] Reset and contact link live in Settings.
- [ ] Force-quitting immediately after a write loses nothing.
- [ ] Seeded home names the job and next tap; primary verb enabled.
- [ ] App reads `-ReviewScreen today|log|goals` after onboarding.

**Uniqueness**
- [ ] Architecture matches **Tondo ADT fold (Idle | Cut | Lodged); the field is a fold over Works; Cut writes a Shard and hangs four Grounds; Lodge writes a LodgeMark when the tapped Ground is the donor and folds Cut to Lodged; a miss writes a ChipMark and keeps the Shard; Lodge on Idle is refused; Cut samples a Work that is not Lodged; a crate under four Works writes Idle** with no leakage across layers.
- [ ] UI approach matches **SwiftUI pure · take field**.
- [ ] Custom rendering, if any, is confined to one hero surface (section 7.5).
- [ ] Navigation matches **Tondo-locked chrome (the excerpt never leaves; Explore, Saved and Settings arrive as sheets; cut and lodge fuse on Quiz)**.
- [ ] Screen composition follows section 3.6.
- [ ] Typography uses **SF Pro** and nothing else.
- [ ] Palette matches section 7.1 exactly.
- [ ] Home rhythm and motion match section 7.6. No second look.

**Quality**
- [ ] Section 8 UI/UX bar satisfied end to end.
- [ ] Contact link present.
- [ ] `PrivacyInfo.xcprivacy` present and correct.
- [ ] README complete.

---

## 20. Build commands

```bash
cd Tondino
xcodegen generate
xcodebuild -scheme Tondino -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
xcrun simctl list devices available
xcodebuild -scheme Tondino -destination 'platform=iOS Simulator,id=<UDID>' test
```

Signing is off only on that command line. Do not put CODE_SIGNING_ALLOWED, CODE_SIGNING_REQUIRED, CODE_SIGN_IDENTITY or DEVELOPMENT_TEAM in project.yml — CI signs the archive. Leave CODE_SIGN_STYLE: Automatic as the scaffold set it. The exact simulator does not matter — use any available UDID from the list.

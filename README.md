# Tondino

A field for people who remember a painting from a detail and want to lodge that fragment onto a work they already saved. Tap the full panel that owns the circular excerpt so that work files as lodged. Lodged works move to Saved. Misses stay reviewable as ChipMarks.

Audience: students of looking, not people naming a maker from a wall label, and not a museum website.

## Architecture

Tondo is a closed algebraic fold with three cases: Idle, Cut, Lodged. A fourth case is a defect. The field is a fold over Works.

This pattern fits the product because the home verb is seating a roundel, not browsing a catalog:

1. **Cut** samples a saved Work that is not Lodged, punches a circular Shard from that donor, hangs four Grounds as the donor plus three others, and folds Idle to Cut. Fewer than four Works writes Idle. A second Cut while a Shard is live is refused.
2. **Lodge** writes a LodgeMark when the tapped Ground is the donor and folds Cut to Lodged so the Work leaves the cut pool for Saved. Lodge on Idle is refused.
3. **Chip** writes a ChipMark on a miss, cools and strikes that Ground, and keeps the same Shard. Colour is never the only miss signal.
4. **Undo** peels the newest LodgeMark or ChipMark. A LodgeMark returns Lodged to Loose. A ChipMark reheats that Ground.

`FieldStore` is the one observable owner. Views call `cutTondo`, `lodgeGround`, `chipGround`, and `liftLastMark`. They never keep a second Tondo enum. Persistence is UserDefaults plus an atomic Application Support file. Getty search is one `CatalogClient`. There are no packages.

Quiz never leaves. Explore, Saved, and Settings arrive as sheets. That is four destinations, never a three-tab bar.

## Cut then lodge

This is why someone would pick Tondino over another art quiz. Home is the field. After seed a circular excerpt already sits over four full grounds, so the first Ground tap can file. Explore stocks Loose works. Lodged works leave the cut pool. ChipMarks stay on Saved. Grades, a shop, and a WebView museum stay out.

The twist has a surface on Quiz (the circular shard plus the four grounds) and a dedicated sheet that names the job.

## Design

Soft card daylight. SF Pro. Warm hospitable field: one circular photo-tile hero, caption under the tile, four full grounds as a rail, then one LodgeMark plus ChipMark stat. Soft shadow only on the shard. Custom drawing is confined to that circular mask. Empty Quiz, Explore, and Saved are full pages.

Art style: 3D glass render, glassmorphism, studio-lit circular tondo over four full grounds. Assets are generated later. Empty imagesets already exist as `tnd_*`.

Base prompt:

```
3D glass render, glassmorphism, studio-lit circular tondo over four full grounds, frosted roundel refraction and soft bloom, isolated subjects, quiet uncluttered ground, no text, no letters, no logo, no photoreal stock, no specified colours, one circular excerpt over full panels not a name-chip row, not a four-face lineup, and not a museum grid
```

Exact per-asset prompts:

**tnd_AppIcon** — A single 3D glass circular tondo, a roundel filling the canvas edge to edge, glassmorphism, subject centred, no text, no letters, no words, no alpha, no transparency, no rounded corners, no drop shadow outside the canvas

**tnd_Splash** — A tall vertical 3D glass field, one circular tondo receding, quiet uncluttered centre band for a wordmark, glassmorphism, no readable text

**tnd_Onboarding1** — Solid linen circular tondo on a stretcher, the product in one glance, isolated cutout, opaque cloth in the center, transparent corners, no glass box, no text

**tnd_Onboarding2** — A hand tapping one solid full panel under a circular linen excerpt, cut then lodge, isolated cutout, opaque subject in the center, no hollow frame, no text

**tnd_Onboarding3** — A short stack of lodged roundel panels beside one circular excerpt, meaning accumulated, isolated cutout, opaque subjects, no text

**tnd_EmptyHome** — A solid empty wooden tondo hoop with no excerpt, waiting, calm and inviting, never sad, isolated cutout, opaque wood in the center, no hollow glass, no text

**tnd_EmptyList** — A solid empty salon shelf with no lodged panels, calm, isolated cutout, opaque wood, no text

**tnd_CardBackdrop** — Abstract low-contrast 3D frosted glass roundel bloom, quiet enough for text on top, filling the canvas, no letters

**tnd_ControlFace** — The face of a small solid wooden tondo hoop as a physical control, isolated cutout, opaque wood, no text

**tnd_TwistHero** — Solid circular linen excerpt seated over four full panels, cut-then-lodge emblem, isolated cutout, opaque subjects, no hollow glass, no text

**tnd_SuccessMark** — A small solid wooden roundel seated after a true lodge, confirmation not fireworks, isolated cutout, no letters

**tnd_HeaderDecor** — A wide low solid wooden tondo rail with linen tape edges, isolated cutout, opaque wood and cloth in the center, transparent corners, no glass pane, no readable text

**tnd_TondoHoop** — Isolated solid wooden circular tondo hoop, cutout, transparent corners, opaque wood filling the center, no plate, no hollow frame, no text

**tnd_CircularShard** — Isolated solid circular linen excerpt disc, cutout, opaque cloth filling the center, transparent corners, no plate, no text

**tnd_GroundPanel** — Isolated solid rectangular linen panel on a stretcher, cutout, opaque fabric and wood, transparent corners, no plate, no text

## How this differs

Still art_quiz: Explore saves a work, Quiz draws from that crate, misses stay reviewable, one catalog voice, no shop. The home commit is lodge-the-tondo: a stable circular excerpt must be seated on its donor among four full grounds, not artist chips, not title chips, not a caption under a full slide, and not letter glyphs. Locked field plus sheets, never a three-tab bar. Catalog voice is the J. Paul Getty Museum.

## Build

```bash
cd Tondino
xcodegen generate
xcodebuild -scheme Tondino -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
```

Simulator seed is once, behind `tnd.demo.v1`, and skips onboarding so `-ReviewScreen today|log|goals` can open Quiz, Saved, and Settings. Extra key `explore` opens Explore. Custom URL scheme `tondino` routes `tondino://quiz`, `tondino://explore`, `tondino://saved`, `tondino://settings`, plus the matching `https://tondino-field.pro` paths. Contact: https://tondino-field.pro/contact-us

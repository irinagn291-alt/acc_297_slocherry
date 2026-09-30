<!-- gf-brief source=c5116f346b3ef0a54ca23942862d8ba403c65ca63068ec39986e974caafdab12 written=2026-09-30T03:17:03+03:00 -->
# Slocherry
## What it is
Slocherry is a looking quiz for people who remember a painting from a circular detail and want to seat that fragment on the full work they already saved. You save public-domain panels from the J. Paul Getty Museum, cut a round excerpt, and tap the full panel that owns it so that work files as lodged. It is for students of looking, not people naming a maker from a wall label.

## Launch and onboarding
A cold launch can sit on a brief empty screen, then a full-screen splash illustration with no words.

On a physical device, first launch then shows a three-page intro. Page dots sit above a full-width “Continue”. On pages 1 and 2, “Skip” (spoken as “Skip onboarding”) finishes the intro and writes the same finished state as the last “Continue”. On page 3, “Skip” is gone; “Continue” finishes.

1. Headline “Lodge the tondo.” Line “A circular excerpt sits over four full panels. Tap the panel that owns it.” Button “Continue”.
2. Headline “Cut then lodge.” Line “Cut punches a roundel from a work you have not lodged yet, then hangs four grounds.” Button “Continue”.
3. Headline “Keep your crate.” Line “Lodged works rest on Saved. A miss writes a ChipMark and the excerpt stays.” Button “Continue”.

VoiceOver on the dots: “Page 1 of 3”, “Page 2 of 3”, “Page 3 of 3”.

After Skip or the last Continue, the field opens. If fewer than four works are saved, that is the empty field (“Field waiting.”). If four or more are already saved, the populated field opens.

On Simulator only, the first run can skip this intro and open a field that already has works, a live excerpt, and counts (see Starter content). “Re-run onboarding” and “Reset the field” can show the intro again.

There is no sign-in.

## Screens
There is no tab bar. The field is the home. Explore, Saved, Settings, and Cut then lodge arrive as sheets on iPhone and as full-screen covers on iPad.

### Field (home)
No navigation title. Light appearance.

**Empty (fewer than four saved works)**  
Top row: status chip, Undo, Explore, Saved, Settings.  
Headline “Field waiting.” Line “Save four works, then cut.” Button “Explore” opens Explore.  
If the last field could not be restored: headline “Field could not be read.” Line “Start a fresh field. Save four works, then cut.” Same “Explore”.

**Populated (four or more saved works)**  
Top row, left to right:

- Status chip: shows “Waiting”, “Crop ready”, “Filed”, or “Missed”. Tap opens “Cut then lodge”. Spoken as “Cut then lodge.” plus that stamp.
- Undo (back-turn icon, spoken “Undo”). Peels the newest filed lodge or missed chip. Dimmed when there is nothing to peel.
- Explore (magnifying-glass icon). Opens Explore.
- Saved (bookmark icon). Opens Saved.
- Settings (gear icon). Opens Settings.

A large circular excerpt fills the remaining height (placeholder hoop if nothing is cut yet). Spoken “Circular excerpt”. After a correct lodge, a success mark flashes on the excerpt for about a second, with a light haptic.

Under the excerpt:

- “Waiting”: “Cut a tondo.” and “Cut a tondo from a loose work.” (or “Field waiting.” and “Save four works, then cut.” if Cut is not available).
- “Crop ready” or “Missed”: “Lodge this tondo” and either “Tap the panel that owns this excerpt.” or “That panel missed. The excerpt stays.”
- “Filed”: “Tondo lodged.” and “Filed. Cut the next tondo.”

If a write failed or the field could not be read, a rule can show “Write failed. Try again.”, “Field could not be read.”, or another refusal line listed under Behaviours.

Four full grounds (phone: a row; iPad: a two-by-two grid). Spoken “Four full grounds”. Each panel is the work’s picture. Tap the panel that owns the excerpt to lodge; tap a wrong panel to miss. A missed panel darkens and gets a diagonal strike, then ignores further taps. Grounds are inert unless the stamp is “Crop ready” or “Missed”.

Counts plate: “Filed” with the lodge count, “Missed” with the miss count and today’s date in the device’s date style.

“Cut” (full-width) appears only when a new excerpt can be punched: at least four saved works, at least one not yet lodged, and no live excerpt. While cutting, the button shows a spinner and will not take another tap.

### Explore
Title “Explore”. Close is an X (spoken “Close”). Drag indicator on the sheet.

Label “J. Paul Getty Museum”. Field “Search a work” (keyboard Search; toolbar “Done” dismisses the keyboard). A spinner can appear while search runs.

Under the field, a note can read “Saved as Loose.”, “Already on the field.”, or a refusal. If search failed but the local shelf is still showing, a banner can read “Search cancelled.”, “Search missed. Local shelf is hanging.”, “Search failed. Local shelf is hanging.”, or “Search could not be read. Local shelf is hanging.”

With results (phone list, iPad three-column grid): each row is title, maker, and “Save”. Tap the row or “Save” to keep that work as Loose. While one save is in flight, other rows are dimmed and that row shows a spinner instead of “Save”.

Empty: “Shelf is quiet.” “Search the Getty, or save from the local shelf.” “Show shelf” clears the query and shows the local shelf.

Search failed with nothing to show: “Search failed.” plus the fault line (or “Try again. Local shelf is hanging.”). “Retry” searches again.

An empty query shows the local shelf (and any works already remembered from earlier searches), not a blank list.

### Saved
Title “Saved”. Close is an X (spoken “Close”).

Empty: “Nothing filed yet.” “Lodge a matching panel. Missed guesses wait here too.” “Lodge” closes Saved and returns to the field.

If Saved cannot load and there is nothing to show: “Saved could not load.” plus the fault line. “Close” dismisses.

With content: “Your tondos”, then “N excerpts filed. M missed.” (N and M in the device’s number style), then “Tap a work to open it.” A write fault can appear here too. Section “Filed” then section “Missed”. Each row is title, maker, a “Filed” or “Missed” chip, and the day that mark was written. Tap opens that work.

On iPad only, a “Next tondo” plate repeats “N filed. M missed.” plus the same next-tap line as the field.

### Opened work (from Saved)
Title is the work’s title. Picture, title, maker, “Filed” or “Missed”, the mark’s date, then “This excerpt was lodged.” or “This panel was a missed guess.”

“Open this work” opens that panel’s Getty record in the system browser when a record exists. If there is no record, “Back to Saved” returns to the list.

### Settings
Title “Settings”. Close is an X (spoken “Close”). Phone is a form; iPad is two columns of the same copy.

If nothing is saved and nothing is marked: “Field waiting.” “Save four works, then cut.” “Explore” opens Explore.

Otherwise, section “Progress”: “Filed” and “Missed” with counts.

Section “Write” appears only when a write fault is showing, with that fault line.

Section “Collection”: “J. Paul Getty Museum” / “getty.edu” opens the Getty home page. “Open Content Program” / “getty.edu/projects/open-content-program” opens that program page. Footer “Public-domain works hang from the J. Paul Getty Museum.”

“Undo” peels the newest filed or missed mark (spinner while it runs; dimmed when there is nothing to peel). “Re-run onboarding” closes Settings and shows the intro again; works and marks stay. Footer: “Undo peels the newest filed or missed tondo. Re-run onboarding shows the intro again. Reset removes works and marks on this device.”

“Reset the field” asks “Reset the field?” Message: “This removes works, shards, filed tondos, and missed guesses on this device. It cannot be undone.” Buttons “Keep” (cancel) and “Reset the field” (destructive). Reset empties the crate and shows the intro again.

“Contact” with “tondino-field.pro/contact-us” opens that contact page.

### Cut then lodge
Title “Cut then lodge”. Close is an X (spoken “Close”).

Headline “Cut then lodge.” Line “Cut punches a circular shard from a loose work and hangs four full grounds. Lodge files the donor. A miss writes a ChipMark and the excerpt stays.”

Counts: “LodgeMarks” and “ChipMarks”.

A plate repeats the field stamp (“Waiting”, “Crop ready”, “Filed”, or “Missed”) and the same next-tap line as the field.

If a new excerpt can be cut: “Cut” closes this screen and punches the excerpt on the field (spinner while cutting).  
Otherwise: “Lodge” only closes this screen and returns to the four grounds. It does not file a work. Filing happens by tapping the matching panel on the field.

## Features
- Lodge the tondo: tap the full panel that owns the circular excerpt so that work files as lodged.
- Cut then lodge: Cut punches a circular excerpt from a work that is not yet lodged and hangs four full grounds; Lodge files the donor; a miss writes a ChipMark and the excerpt stays.
- Explore the J. Paul Getty Museum and “Save” a work as Loose.
- Local shelf of Getty works when search is empty or misses.
- Saved crate of “Filed” excerpts and “Missed” guesses; open a work; “Open this work” for the Getty record.
- Filed and Missed counts on the field, on Saved, and in Settings.
- Undo peels the newest filed or missed tondo.
- Re-run onboarding (works and marks stay).
- Reset the field (everything on this device; cannot be undone).
- Collection credit: J. Paul Getty Museum and Open Content Program.
- Contact.
- Shortcuts (system): “Open Quiz”, “Open Explore”, “Open Saved”, “Open Settings”, “Cut a tondo”, “Lodge the tondo”, with short titles “Quiz”, “Explore”, “Saved”, “Settings”, “Cut”, “Lodge”.

## Behaviours that can look like bugs
- The field stays on “Field waiting.” / “Save four works, then cut.” until four works are saved. Open Explore, tap “Save” on four works, then Cut.
- “Cut” is hidden until there are four saved works, at least one still Loose, and no live excerpt. After a lodge, Cut returns if a Loose work remains. If every saved work is already Filed, save another work first.
- While an excerpt is live, a second Cut is refused. The field can show “A shard is live. Lodge it first.” Tap the matching panel, or Undo, before cutting again.
- “Cut” shows a spinner and ignores extra taps while a cut is running. Wait for the excerpt and four grounds.
- Undo is dimmed until something has been filed or missed. After a lodge or a miss, Undo works. “Nothing to Undo.” can appear if Undo is used with an empty peel stack.
- Grounds do nothing unless the stamp is “Crop ready” or “Missed”. Cut first, then tap a panel.
- A wrong panel dims, takes a strike, and will not accept another tap. The excerpt stays. Status becomes “Missed” with “That panel missed. The excerpt stays.” Tap a different panel, or Undo to reheat that panel.
- A correct lodge files the donor, shows the success mark, and sets “Filed” / “Tondo lodged.” / “Filed. Cut the next tondo.” The grounds stay on screen but are inert until the next Cut.
- “Lodge” on Cut then lodge only closes the sheet. It does not file. File by tapping the matching panel on the field. “Cut a tondo first. Lodge is refused.” can appear if Lodge is asked while Waiting.
- Other refusals that can appear: “Already lodged. Cut the next tondo.”, “That panel is not hanging.”, “The donor files as Lodge, not Chip.”, “That panel is already chipped.”, “Cut a tondo first. Chip is refused.”, “No accession.”, “Write failed. Try again.”
- “Save” is dimmed while another save is running. Wait for “Saved as Loose.” or “Already on the field.”
- Saving a work already on the field does not add a second copy; the note is “Already on the field.”
- Empty or failed Getty search still shows the local shelf, with “Search missed. Local shelf is hanging.”, “Search failed. Local shelf is hanging.”, or “Search could not be read. Local shelf is hanging.” That is fallback, not a blank catalog.
- “Show shelf” clears the query so the local shelf hangs again.
- “Re-run onboarding” loops the three intro pages on purpose. Skip or Continue returns to the same crate.
- “Reset the field” returns to the intro and an empty crate. “Keep” leaves everything as it was.
- If the field could not be read: “Field could not be read.” Save four works and cut, or reset and start again.
- On Simulator, first launch can skip the intro and already show a live excerpt. That is the demo crate, not a stuck install.
- Numbers and dates follow the device locale, so counts and day labels change with region settings.

## Starter content and resume
A local Getty shelf is always available in Explore when the query is empty (and after a missed or failed search):

- “Irises”, “Vincent van Gogh”
- “Portrait of a Halberdier”, “Pontormo (Jacopo Carucci)”
- “The Abduction of Europa”, “Rembrandt Harmensz. van Rijn”
- “Christ's Entry into Brussels in 1889”, “James Ensor”
- “Still Life with Apples”, “Paul Cézanne”
- “Portrait of Agostino Pallavicini”, “Anthony van Dyck”
- “Wheatstacks, Snow Effect, Morning”, “Claude Monet”
- “Madame Seurat, the Artist's Mother”, “Georges Seurat”

On a physical device, the crate starts empty. Nothing is filed or missed until the person saves and plays.

On Simulator only, the first run can plant that shelf as saved works, mark Monet and Seurat as already lodged, write three missed guesses, finish onboarding, and leave one excerpt already cut so the first ground tap can file.

Unfinished work resumes: saved works, the live excerpt and four grounds, Filed and Missed marks, and whether onboarding is done come back after the app is left and reopened. After Reset the field, there is nothing to resume.

## Permissions
None. The app never asks for camera, photos, microphone, location, or tracking. A camera usage string exists in the build (“This app does not use the camera.”) but no camera prompt is shown.

## Absent
Genuinely absent: login or accounts, in-app purchase, ads, analytics, user-generated content (no posts, comments, or photos the person creates), account deletion flow, App Tracking Transparency prompt.

## Data and support
Works, marks, and onboarding state stay on this device. Reset copy says the wipe is on this device and cannot be undone.

On-screen support: Settings → “Contact” / “tondino-field.pro/contact-us”.

## Scanning and health
None. The app does not scan barcodes or QR codes. It does not show health, medical, or product-health information.

## Platform
English copy only. Counts and dates follow the device’s locale. No region lock.

Portrait only, light appearance, full screen. iPhone and iPad. Not offered as a Mac or Apple Vision “designed for iPhone” app. Minimum iOS 17.0.

## Category
Education.

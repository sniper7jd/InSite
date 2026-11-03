# InSite roadmap

## Implementation order

1. Preserve GPU backend baseline.
2. Freeze response contract to `localize.schema.json`.
3. Establish metric scale (Stray odometry + measured lengths).
4. Create Xcode app on a Mac; add `ios/InSite` sources; run on a physical iPhone.
5. Capture one `ARFrame` (image + intrinsics + `T_W_from_A`); upload; parse status explicitly.
6. Verify one surveyed AR anchor via `PoseAligner`.
7. Add verified floor graph + accessible routing (2D first).
8. Accessibility polish; then profile GPU latency.

## Demo integrity rules

- Mock localization is for UI/routing development only and must stay visibly labeled.
- Do not claim a virtual object is aligned with a physical doorway until measured on site.
- Do not describe unverified graph edges as accessible.
- Prefer a clear “Locating…” and failure path over a fast but misaligned arrow.

# InSite

**Step-free indoor navigation from a single phone photo — no beacons, QR codes, or indoor GPS.**

GPS stops working at the front door, and most indoor maps don't know where the stairs are. For wheelchair users that means guessing which hallway has a ramp or an elevator. InSite takes a photo from an iPhone, figures out exactly where you are inside the building, and routes you along paths with no steps.

<!--
Add visuals here — they are the first thing visitors look at:
![InSite route on the 2D floor map](docs/images/map-route.png)
![Sparse COLMAP reconstruction of Whalen Center, floor 1](docs/images/whalen-pointcloud.png)
-->

## How it works

1. **Locate:** the iPhone sends one camera frame (plus lens intrinsics and its ARKit pose) to a GPU server.
2. **Match:** the server matches it against a 3D map of the building built with Structure-from-Motion (SuperPoint → NetVLAD → LightGlue → PnP) and returns the camera's pose in the map.
3. **Route:** the app aligns the map to the ARKit world, runs accessibility-aware Dijkstra on a floor graph that skips stairs, and guides you on a 2D map, with spoken directions and optional AR.

**Tech:** Swift · SwiftUI · ARKit · RealityKit · Python · FastAPI · COLMAP · hloc · SuperPoint · LightGlue · NVIDIA A100

**Status:** research prototype covering the first floor of Whalen Center (Ithaca College). Live localization works end-to-end on test images; metric scale and on-device verification are next. See [milestones](#milestone-status).

---

## System architecture

```text
[iPhone]
  │  JPEG + intrinsics + capture-time ARKit pose
  ▼
[NVIDIA GPU — FastAPI POST /localize]
  SuperPoint → NetVLAD → LightGlue/PnP
  returns T_M_from_C (map ← COLMAP camera)
  ▲
[Native iOS — SwiftUI + ARKit + RealityKit]
  PoseAligner: T_W_from_M = T_W_from_A · C_A_from_C · T_M_from_C⁻¹
  2D floor map (primary) · optional AR · accessible Dijkstra · speech
```

### Coordinate frames

| Symbol | Meaning |
|--------|---------|
| `M` | Whalen reconstructed map frame |
| `C` | COLMAP camera (`X` right, `Y` down, `Z` forward) |
| `A` | ARKit camera (`Y` up, local `Z` toward user) |
| `W` | ARKit session world |

Camera-axis conversion (not a substitute for metric scale):

```text
C_A_from_C = diag(1, -1, -1, 1)
T_W_from_M = T_W_from_A · C_A_from_C · inverse(T_M_from_C)
```

---

## Repository layout

```text
InSite/
├── backend/          # GPU localization service notes (HLoc / COLMAP / FastAPI)
├── ios/InSite/       # SwiftUI + ARKit client sources and unit tests
├── shared/api/       # localize.schema.json — the Python ↔ Swift contract, with examples
└── docs/ROADMAP.md   # Implementation order and demo integrity rules
```

To run the iOS client, see [`ios/README.md`](ios/README.md).

---

## API contract

See [`shared/api/localize.schema.json`](shared/api/localize.schema.json).

- Authoritative pose: `transform_matrix_map_from_camera` (`T_M_from_C`, JSON row-major).
- Quaternion: `quaternion_xyzw` (xyzw).
- Failure: `status: "failed"` with `error_code` and `error` — **no pose fields**.
- Never treat HTTP 200 alone as successful localization.
- Client sends JPEG plus `image_width_px`, `image_height_px`, and `intrinsics_3x3` (no EXIF reliance).

---

## Milestone status

| Phase | Milestone | Status | Notes |
|-------|-----------|--------|-------|
| 1 | A100 GPU environment | Complete | PyTorch, LightGlue, SuperPoint on CUDA |
| 2 | Stray Scanner captures | Complete | 4 Whalen 1st-floor sessions |
| 3 | SfM map construction | Complete | Sparse COLMAP model |
| 4 | Live `/localize` | Complete (preliminary) | 21/21 batch; ~166 avg inliers; ~6.3 s — **not** proof of absolute accuracy |
| 5 | Metric scale + map version | Not started | Required before physical AR anchors |
| 6 | iOS client shell | In progress | Mock UI only until contract + scale + device verification |
| 7 | Accessible 2D / voice | Pending | After verified graph |

**Batch test snapshot (preliminary):** 21 success / 0 fail, avg inliers 165.8, avg latency 6.315 s. These pass the API success criteria on the current test set; they do not establish navigation-grade absolute positioning.

Scope is Whalen Center first floor only. The Business School, H&S, and outdoor links are future graph extensions once Whalen localization and routing are trustworthy. Next steps are in [`docs/ROADMAP.md`](docs/ROADMAP.md).

## Team

Built by [@sniper7jd](https://github.com/sniper7jd) and Himaloy Mondal.

## License

[MIT](LICENSE)

# Buddy: Character Model

Buddy is the Curious Buddy mascot. This is the reference for keeping Buddy
consistent everywhere: in code today, and in any final artwork later.

## Status

- **Today:** Buddy is drawn in code by `lib/ui/core/widgets/buddy/buddy_painter.dart`.
  It is scalable, animatable and consistent, but it is an **interim
  stand-in**, not the final premium 3D art from the mascot brief.
- **Final art:** to be produced by a character artist or a tool whose
  output you have clear rights to use commercially. It must be original and
  must not resemble any existing character or brand. In particular, avoid
  plush-toy fur and leaf/sprout tops, which resemble another kids' product
  we saw during design.

## Model

| Feature | Definition |
| --- | --- |
| Species | Small fictional creature. Not a human, robot or existing character. |
| Body | One compact, rounded oval (head and body together), slightly wider than tall in the upper half. Face takes the upper ~55%. |
| Colour | Turquoise-teal `#2BB3A8`; light `#6FDDD2`, deep `#15807A`, outline `#0D5550`, belly `#A6F0E7`. |
| Ears | Two small round ears at the top corners with lighter inner circles. |
| Eyes | Large, glossy, white sclera, deep blue iris, dark pupil, one large and one small white reflection. |
| Cheeks | Soft pink blush (`#FF9BB3`), no hard edge. |
| Mouth | Small and warm. Never shows teeth. |
| Arms / feet | Two short rounded arms, two small rounded feet. |
| Backpack | Tiny golden-yellow explorer pack (`#FFC43D`, shade `#E0960F`) behind the right side, one strap over the right shoulder with a buckle, flap and front pocket. |
| Surface | Smooth and soft, lit from the top left; gentle shadow underneath. No textures or fur. |
| Avoid | Teeth, sharp shapes, extra accessories, clutter. Buddy's default look has no accessories; outfits appear only when a child chooses them in the Wardrobe. |

## Expressions

All use the same model; only the face and arms change.

| Mood | Use for | Face | Arms |
| --- | --- | --- | --- |
| `neutral` | Default, front-facing | Soft smile, eyes forward | At sides |
| `happy` | Welcome, Home | Open smile | Right arm half raised (waves on appear) |
| `curious` | Coming soon, exploring | One eye bigger, brow raised, sideways smile; whole body tilts | At sides |
| `surprised` | Errors, "oops", reveals | Big eyes, high brows, small "o" mouth | Out to the sides |
| `thoughtful` | Puzzles, Parent Zone | Eyes up and to the side, flat mouth | Right hand to cheek |
| `excited` | Celebrations, tap reaction | Eyes squeezed shut, big open smile | Both up |

The app icon uses `happy`, cropped to head and shoulders.

## Swapping in final art later

1. Deliver transparent PNGs per mood at 1x/2x/3x (for example 300/600/900px
   tall), same canvas size and baseline (feet) for every mood, named
   `buddy_<mood>.png`, plus a 1024px icon master and a 432px adaptive
   foreground with content inside the central 66%.
2. Add them under `assets/buddy/` and change the `Buddy` widget to show the
   image for its mood, keeping `BuddyPainter` as the fallback if an image
   fails to load.
3. Keep the `Buddy` widget's API (`mood`, `height`, wave, tap and
   reduced-motion behaviour) so no screen needs to change.
4. Replace the launcher icons and update this document.

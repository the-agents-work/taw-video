# Intent router — /taw-video single-entrypoint

You are inside `/taw-video`. This file maps free-form user prose (EN or VN) to exactly ONE branch. Load the matching branch file and follow it. If ambiguous, ask ONE short clarifying question.

## Tier 1 — 5 top-level intents

Pick exactly one.

| Intent | Load | Signals (VN + EN) |
|---|---|---|
| `CREATE` | `@branches/create.md` | làm, tạo, lam, tao, make, create, new video, scaffold video, video về, video gioi thieu, video tutorial, lam clip, tao clip, "cho tôi 1 video", kinetic typography, motion graphic, faceless |
| `EDIT` | `@branches/edit.md` | sửa, sua, edit, đổi, doi, change, rewrite, shorten, longer, "rút ngắn", "kéo dài", "đổi nhạc", "sửa cảnh", "đổi text", "đổi font", "đổi màu", "thêm cảnh", "xoá cảnh", "ghép cảnh" |
| `RENDER` | `@branches/render.md` | render, xuất, xuat, export, convert, "9:16", "1:1", "16:9", shorts, tiktok, instagram, "ra mp4", "ra gif", "ra webm", "xuất 1080p", "xuất 4k" |
| `REMIX` | `@branches/remix.md` | remix, "làm giống", "lam giong", "dùng lại template", "dung lai template", "lam tuong tu", "copy phong cách", "khác nội dung nhưng giữ phong cách", "use template", "based on previous" |
| `ADVISOR` | `@branches/advisor.md` | review, đánh giá, danh gia, "video có ổn không", "video có đẹp không", "feedback", "kiểm tra dấu", "check storyboard", "audit video", "góp ý video" |

## Disambiguation — when keywords clash

Common overlaps:

- **"sửa video"** (edit/render) — if user mentions a specific scene/text/style change → EDIT. If user mentions output format/aspect ratio → RENDER. If unclear: ask "Anh muốn em sửa nội dung cảnh hay xuất lại tỉ lệ khác?"
- **"làm lại video"** (create/remix) — if user keeps the same topic AND mentions previous video → REMIX. If new topic → CREATE. If unclear: ask "Anh muốn làm video mới hoàn toàn hay remix bản cũ?"
- **"thêm cảnh"** (edit/create) — always EDIT (adding to existing video, not a new product).
- **"render đẹp hơn"** (render/edit) — RENDER if it's about quality/bitrate/codec; EDIT if about visual changes (colors, animation).
- no match → ask: "Anh muốn em làm gì? Ví dụ: tạo video mới / sửa cảnh / render khác tỉ lệ / remix template cũ / review video."

## Empty args

If `/taw-video` is invoked with empty args, emit (VN default):

```
taw-video: anh muốn làm gì? Ví dụ:
  /taw-video làm video tutorial 60s về ChatGPT     (tạo mới)
  /taw-video sửa cảnh 2 ngắn lại 1 giây             (edit)
  /taw-video render 9:16 cho TikTok                 (render)
  /taw-video remix template news tuần trước         (remix)
  /taw-video review video vừa làm xong              (advisor)
```

For EN:

```
taw-video: what do you want to do? Examples:
  /taw-video make 60s tutorial about ChatGPT       (create)
  /taw-video shorten scene 2 by 1 second            (edit)
  /taw-video render 9:16 for TikTok                 (render)
  /taw-video remix last week's news template        (remix)
  /taw-video review the video I just made           (advisor)
```

Then wait for reply and re-run classification.

## Mode detection (applies to CREATE + EDIT + REMIX)

Scan user text for YOLO triggers:
- EN: `yolo`, `--yolo`, `--fast`, `auto`
- VN: `nhanh nha`, `nhanh đi`, `lam luon`, `làm luôn`, `khoi hoi`, `khỏi hỏi`, `không cần hỏi`, `chạy luôn`, `chay luon`
- Args literally starting with `yolo`

Match → `mode = "yolo"` (branch will skip clarify + approval gate where applicable). Else `mode = "safe"`.

RENDER + ADVISOR ignore mode (RENDER is mechanical; ADVISOR is read-only).

## What to write after routing

Record the routing decision in `.taw-video/intent.json`:

```json
{
  "tier1": "CREATE",
  "raw": "<user text>",
  "mode": "safe",
  "branch_loaded": "branches/create.md"
}
```

Then stop executing this file and follow the loaded branch from its Step 1.

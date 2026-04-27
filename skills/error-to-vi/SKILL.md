---
name: error-to-vi
description: >
  Translate common Remotion, ffmpeg, npm, and Node errors into plain Vietnamese
  with actionable fix hints. Used by /taw-video orchestrator and every branch
  so non-dev users never see raw English error messages.
argument-hint: "[error message text]"
---

# error-to-vi — Error Translation to Vietnamese

## Purpose

Take raw English error output and return a plain Vietnamese explanation with a simple fix instruction. Non-dev users see "Bị lỗi X, làm Y để sửa" — not a stack trace.

## Translation table

### Remotion errors

| English error | Vietnamese | Fix hint |
|---|---|---|
| `Composition with id "X" not found` | "Không tìm thấy composition `X` trong src/Root.tsx" | "Đăng ký composition vào Root.tsx hoặc gõ `/taw-video edit` để em fix." |
| `Cannot find module '@remotion/...'` | "Chưa cài package Remotion `<tên>`" | `npm install @remotion/<tên>` |
| `The duration of the video is X but composition is Y` | "Tổng độ dài video không khớp với composition" | "Em sẽ tự đồng bộ — chạy `/taw-video edit pacing`." |
| `Cannot use audio file in this context` | "BGM file không hợp lệ hoặc thiếu" | "Kiểm tra `public/bgm.mp3` có tồn tại không. Nếu không cần BGM, xoá `<Audio>` import trong Root.tsx." |
| `Hydration failed because the initial UI does not match` | "Lỗi React hydration — thường do dùng `Math.random()` trong scene" | "Thay `Math.random()` bằng `random(frame)` từ remotion lib." |

### ffmpeg errors

| English error | Vietnamese | Fix hint |
|---|---|---|
| `Unknown encoder 'libx264'` | "ffmpeg trên máy thiếu encoder H.264 (libx264)" | "Cài lại ffmpeg full: `brew reinstall ffmpeg --with-x264`. Hoặc đổi codec: `/taw-video render --codec=vp9`" |
| `Unable to find a suitable output format for ...` | "ffmpeg không nhận format file output" | "Kiểm tra extension đuôi file (.mp4 / .mov / .webm). Hoặc thêm `-f mp4` thủ công." |
| `Conversion failed!` (generic) | "Convert video thất bại — xem stderr ở trên để biết lý do cụ thể" | "Thử lại với codec khác hoặc giảm độ phân giải." |

### Font errors (VN diacritic rendering)

| English error | Vietnamese | Fix hint |
|---|---|---|
| `Font 'Be Vietnam Pro' not found` | "Font Be Vietnam Pro chưa cài → text VN có thể bị lỗi dấu" | "Cài: `brew install --cask font-be-vietnam-pro`. Sau đó `fc-cache -f` (Linux)." |
| Missing glyph warning | "Một số ký tự VN (đ, ầ, ố...) không render đúng" | "Đổi sang Inter hoặc Noto Sans Vietnamese trong `.taw-video/design.json`." |

### npm / Node errors

| English error | Vietnamese | Fix hint |
|---|---|---|
| `EACCES: permission denied` | "Không có quyền truy cập. Không dùng sudo với npm." | "Chạy: `npm config set prefix ~/.npm-global`" |
| `npm ERR! peer dep missing` | "Thiếu thư viện phụ thuộc" | "Chạy: `npm install --legacy-peer-deps`" |
| `Cannot find module 'remotion'` | "Chưa cài Remotion" | `npm install` (hoặc `/taw-video setup`) |
| `Error: listen EADDRINUSE :::3000` | "Cổng 3000 đang được dùng" | "Chạy: `npx kill-port 3000` rồi thử lại" |
| `ENOSPC: no space left on device` | "Máy hết dung lượng đĩa" | "Xoá `node_modules/` + `out/`, chạy `npm install` lại." |
| `esbuild platform mismatch` | "esbuild không match architecture máy (x86 vs ARM64)" | "`rm -rf node_modules package-lock.json && npm install --include=optional`" |

### Generic / fallback

If no match → return:

```
Có lỗi xảy ra: <giữ nguyên dòng đầu của stderr>.
Em đã ghi log đầy đủ vào .taw-video/error.log.
Thử lại với `/taw-video <lệnh cũ>` — nếu vẫn lỗi, gõ `/taw-video debug` em check chi tiết.
```

## Usage pattern

When error encountered:
1. Match error text against table above (partial match OK).
2. Return: VN explanation + fix instruction (≤2 sentences).
3. If no match: generic fallback.
4. Always log original English error to `.taw-video/error.log`.
5. NEVER hide the raw error in dev logs (debugging needs it). Show VN to user, English to log.

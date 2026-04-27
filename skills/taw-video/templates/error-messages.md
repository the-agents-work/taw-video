# Error message templates — /taw-video

Translate these to Vietnamese (default) when emitting to user. Internal logs stay English.

## Generic failure

```
Em gặp lỗi khi <việc>. Lý do (rút gọn): <≤100 token error>.
Em đã thử lại 1 lần — vẫn lỗi.

Bước tiếp gợi ý:
  /taw-video <suggested verb>

Hoặc gõ `/taw-video debug` để em check chi tiết hơn.
```

## ffmpeg not installed

```
Máy anh chưa có ffmpeg — taw-video không render được video nếu thiếu.
Cài ffmpeg trước nhé:

  macOS:    brew install ffmpeg
  Ubuntu:   sudo apt install ffmpeg
  Windows:  choco install ffmpeg-full   (hoặc dùng WSL2)

Cài xong gõ lại `/taw-video <lệnh cũ>` em chạy tiếp.
```

## ffmpeg encoder missing (libx264 etc)

```
ffmpeg trên máy anh thiếu encoder H.264 (libx264) — bản minimal.
Cài lại bản full:

  macOS:    brew reinstall ffmpeg --with-x264 --with-x265
  Ubuntu:   sudo apt install ffmpeg libx264-dev libx265-dev

Hoặc đổi codec sang VP9 (open-source): `/taw-video render --codec=vp9`.
```

## Remotion install fail (esbuild architecture)

```
Remotion cài không xong — esbuild không match architecture máy anh.
Thử:

  rm -rf node_modules package-lock.json
  npm install --include=optional

Nếu vẫn lỗi: máy anh dùng Apple Silicon nhưng Node x86? Cài Node native ARM lại:
  brew uninstall node && brew install node
```

## Remotion: Composition not found

```
Em scaffold chưa xong — composition <id> chưa đăng ký trong src/Root.tsx.
Em sẽ tự fix:
  1. Đọc src/scenes/*
  2. Re-register vào Root.tsx
  3. Render lại

Đợi 30s nhé.
```

## TTS: insufficient credits

```
Tài khoản TTS (<provider>) hết credit rồi anh.

Lựa chọn:
  1. Top up tại: <provider URL>
  2. Đổi provider: /taw-video edit voice provider=fpt-ai
     (FPT.AI có free tier ~5000 ký tự/tháng, giọng VN tốt nhất)
  3. Skip voice tạm: /taw-video edit voice off
     (chỉ render visual + sub, voice add sau)
```

## TTS: Vietnamese voice not available

```
Provider <X> không hỗ trợ giọng tiếng Việt. Đổi sang FPT.AI hoặc OpenAI:

  /taw-video edit voice provider=fpt-ai voice=leminh   (nam Bắc)
  /taw-video edit voice provider=fpt-ai voice=banmai   (nữ Bắc)
  /taw-video edit voice provider=fpt-ai voice=minhquang (nam Nam)
  /taw-video edit voice provider=fpt-ai voice=lannhi   (nữ Nam)

Hoặc OpenAI (giọng đọc trung tính, khá tự nhiên):
  /taw-video edit voice provider=openai voice=nova
```

## Subtitle: missing diacritics in burn-in

```
Sub bị lỗi dấu tiếng Việt (chữ ô/ê/đ hiển thị thành □ hoặc ?).
Lý do: font không có Unicode đầy đủ.

Em đổi sang Be Vietnam Pro (full Unicode + open-source) rồi render lại:
  /taw-video render captions=be-vietnam-pro

Hoặc dùng font khác có VN: Inter, Noto Sans Vietnamese.
```

## Render takes too long

```
Render đang chậm (~<X> phút ước tính cho <duration>s video).
Lý do thường gặp:
  - Scene quá phức tạp (nhiều layer, particle, blur)
  - CPU yếu / concurrency mặc định quá cao

Tăng tốc:
  /taw-video render --concurrency=2          (giảm tải CPU)
  /taw-video render --quality=draft          (preview nhanh, chất thấp)
  /taw-video render --resolution=720p        (sau preview ok thì render full)
```

## Disk full

```
Ổ cứng đầy — cần ít nhất 2GB cho render + cache.

Em scan giúp folder out/ và .taw-video/render-cache/:
  - <X> file MP4 cũ (~<Y>GB)
  - <Z> frame cache

Xoá file cũ?
  /taw-video clean renders         (xoá out/ trừ render mới nhất)
  /taw-video clean cache           (xoá .taw-video/render-cache/)
```

## User cancelled mid-render

```
Đã dừng render. Trạng thái lưu ở .taw-video/checkpoint.json.

Tiếp tục:
  /taw-video render --resume       (chạy tiếp từ frame đã render)
Hoặc bắt đầu lại:
  /taw-video render
```

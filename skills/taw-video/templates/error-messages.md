# Error message templates — /taw-video

Translate to Vietnamese (default) when emitting to user. Internal logs stay English.

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

## Font missing (VN diacritics broken)

```
Font Be Vietnam Pro chưa có trên máy → text VN có thể bị lỗi dấu (□ hoặc ?).

Cài font:
  macOS:   brew install --cask font-be-vietnam-pro
  Linux:   curl -L https://fonts.google.com/download?family=Be%20Vietnam%20Pro -o /tmp/bvp.zip
           unzip /tmp/bvp.zip -d ~/.local/share/fonts/ && fc-cache -f

Em fallback sang Inter nếu không có. Cài xong render lại sẽ ngon hơn.
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

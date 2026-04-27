# Clarify-question bank — /taw-video CREATE

Pick 3–4 questions matching the format. Phrase them in user's input language (VN by default). Numbered, ONE message, then wait.

## Universal (ask in every CREATE)

1. **Tỉ lệ chính**: 16:9 ngang (web/YouTube), 9:16 dọc (TikTok/Shorts), hay 1:1 (IG feed)? — chọn 1 thôi, sau có thể render thêm tỉ lệ khác.
2. **Thời lượng mong muốn**: dưới 30s, 30–60s, hay 60–120s?
3. **Nhạc nền**: có muốn BGM royalty-free không? (yes/no). Mood gì: chill / hype / cinematic / không có?

## Format-specific (pick 1 question)

### `tutorial-explainer`
4. **Tone**: nghiêm túc, vui tươi gen-Z, hay chill-trung lập?

### `faceless-channel`
4. **Niche + tone**: niche là gì (AI tools / productivity / finance / lifestyle / history) và tone catchy/hype kiểu MrBeast hay chill kiểu Kurzgesagt?

### `news-recap`
4. **Nguồn tin**: link bài cụ thể (paste URL) hay tóm tắt 3 câu?

### `product-demo`
4. **Sản phẩm + audience**: tên sản phẩm + 1 câu USP, audience là B2B hay B2C?

### `kinetic-typography`
4. **Văn bản chính** (1–3 câu, ưu tiên có dấu tiếng Việt nếu có để test diacritic motion). + mood nhạc (trap / lofi / cinematic).

## Phrasing rules

- Numbered, không dùng bullet.
- Hỏi ngắn — mỗi câu ≤ 1.5 dòng.
- Cho ví dụ 2–3 lựa chọn nếu câu hỏi mở.
- Cuối tin nhắn nhắc: "Trả lời xong em chạy storyboard cho anh duyệt. Hoặc gõ `default` / `mặc định` để dùng smart defaults."
- Lưu ý quan trọng (trừ kinetic-typography): "Video sẽ silent — anh thêm voice trong CapCut/Premiere/DaVinci nếu muốn nhé."

## YOLO mode bypass

If `mode == "yolo"`, skip this entirely and emit:

```
⚡ YOLO mode — dùng smart defaults:
  - Aspect: <smart-default>
  - Duration: <smart-default>
  - BGM: <smart-default>
  - Palette: <smart-default>
  (silent video — voice add ngoài nếu cần)
```

Then proceed.

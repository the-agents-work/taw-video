# Clarify-question bank — /taw-video CREATE

Pick 3–5 questions matching the format. Phrase them in user's input language (VN by default). Numbered, ONE message, then wait.

## Universal (ask in every CREATE)

1. **Tỉ lệ chính**: 16:9 ngang (web/YouTube), 9:16 dọc (TikTok/Shorts), hay 1:1 (IG feed)? — chọn 1 thôi, sau có thể render thêm tỉ lệ khác.
2. **Thời lượng mong muốn**: dưới 30s, 30–60s, hay 60–180s?
3. **Voice / nhạc**: anh muốn có giọng đọc không? (yes/no). Nếu có: nam hay nữ, miền Bắc hay miền Nam?

## Format-specific

### `tutorial-explainer`
4. **Kiến thức nền của người xem**: hoàn toàn mới, biết cơ bản, hay đã ở mức trung-cao?
5. **Tone**: nghiêm túc, vui tươi gen-Z, hay chill-trung lập?

### `faceless-channel`
4. **Niche**: AI tools, productivity, finance, lifestyle, history, hay khác?
5. **Tone**: catchy/hype kiểu MrBeast clone, chill kiểu Kurzgesagt, hay storytelling kiểu Veritasium?

### `news-recap`
4. **Nguồn tin**: có link bài cụ thể không (paste URL hoặc tóm tắt 3 câu)?
5. **Mood**: trung lập (báo chí), urgent (breaking news), hay analytical (phân tích sâu)?

### `product-demo`
4. **Sản phẩm là gì**: tên + 1 câu mô tả USP?
5. **Audience**: nội bộ team, khách hàng tiềm năng B2B, hay end-user B2C?

### `kinetic-typography`
4. **Văn bản chính** (1–3 câu, ưu tiên có dấu tiếng Việt nếu có để test diacritic motion).
5. **Mood âm nhạc**: aggressive/trap, chill/lofi, cinematic/orchestral, hay không có nhạc?

## Phrasing rules

- Numbered, không dùng bullet.
- Hỏi ngắn — mỗi câu ≤ 1.5 dòng.
- Cho ví dụ 2–3 lựa chọn nếu câu hỏi mở.
- Cuối tin nhắn nhắc: "Trả lời xong em chạy storyboard cho anh duyệt. Hoặc gõ `default` / `mặc định` để dùng smart defaults."

## YOLO mode bypass

If `mode == "yolo"`, skip this entirely and emit:

```
⚡ YOLO mode — dùng smart defaults:
  - Voice: <smart-default>
  - Aspect: <smart-default>
  - BGM: <smart-default>
  - Palette: <smart-default>
```

Then proceed.

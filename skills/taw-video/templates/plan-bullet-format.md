# Storyboard bullet format — /taw-video CREATE Step 3

Used by `storyboard-planner` agent to render the scene plan. Always echo to user as a code block before approval gate.

## Required structure (3–5 bullets max + scene table)

```
## Storyboard

**Tổng quan**
- Format: <tutorial-explainer | faceless-channel | news-recap | product-demo | kinetic-typography>
- Thời lượng: ~<duration>s
- Tỉ lệ chính: <16:9 | 9:16 | 1:1>
- Palette: <color1> · <color2> · <color3>
- Font: <display> + <body>
- Nhạc nền: <BGM mood> (royalty-free) hoặc không có

**Cảnh**

| # | Tên | Thời lượng | Mô tả ngắn | Beat |
|---|---|---|---|---|
| 1 | title-card | 3s | "Logo + tiêu đề chính lướt từ trái sang" | 3/5 |
| 2 | hook-quote | 5s | "Câu hỏi/thống kê gây sốc, kinetic typography" | 5/5 |
| 3 | data-bar | 12s | "Bar chart so sánh 3 phương án" | 4/5 |
| 4 | comparison-split | 10s | "Split-screen: cách cũ vs cách mới" | 3/5 |
| 5 | end-card | 5s | "CTA + outro logo" | 4/5 |

**Tổng**: <sum>s
**Lưu ý**: video silent — anh thêm voice trong CapCut/Premiere/DaVinci nếu muốn.
```

## Rules

- Beat (energy level) 1–5: 1 = chill, 5 = peak hype. Curve must rise then resolve, NOT flat.
- Scene names from `scene-presets` library when possible (title-card, lower-third, kinetic-quote, data-bar, comparison-split, end-card, etc) — promotes reuse.
- Mô tả ngắn: ≤ 80 ký tự, hành động cụ thể (động từ + chủ ngữ).
- Sum of durations = video total ± 1s tolerance (transitions overlap).

## After table, prompt for approval

```
Storyboard này ok chưa anh? (gõ: yes / sửa / huỷ)
```

(See `branches/create.md` Step 4 for gate logic.)

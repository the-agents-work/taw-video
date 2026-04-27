# taw-video

> Bộ kit Claude Code cho người không biết code — tạo video motion graphic chất lượng cao chỉ bằng một câu `/taw-video <ý tưởng>`.

**Website:** [theagents.work](https://www.theagents.work/)
**Repo anh em:** [taw-kit](https://github.com/the-agents-work/taw-kit) — bộ kit cho web/app
**Discord:** [tham gia cộng đồng](https://discord.gg/6nhMhhMV)

> English version: [README.en.md](./README.en.md)

```
/taw-video làm cho tôi 1 video tutorial 60s về cách dùng ChatGPT
  → hỏi lại cho rõ (3–5 câu): voice nam/nữ, màu chủ đạo, nền nhạc?
  → lập storyboard 5 cảnh, anh duyệt
  → Claude code Remotion + render scene + ghép TTS + sub
  → trả về file MP4 (1080p hoặc 9:16 cho TikTok/Shorts)
```

**Chỉ 1 lệnh duy nhất: `/taw-video`.** Anh nói gì bằng tiếng Việt cũng được — tạo mới, sửa cảnh, render lại, remix template — kit tự hiểu và chạy đúng nhánh.

```
/taw-video làm 1 video kinetic typography 30s     → tạo mới
/taw-video sửa cảnh 3 ngắn lại 1 giây             → edit scene
/taw-video render 9:16 cho TikTok                 → re-render khác tỉ lệ
/taw-video remix template news từ video tuần trước → remix
/taw-video voice nữ trẻ tiếng miền Nam            → đổi giọng đọc
/taw-video sub vàng to hơn                         → tinh chỉnh sub
```

> Demo: video motion graphic 60s — từ ý tưởng tới MP4 ~1 tiếng. Toàn bộ animation do Claude code bằng React (Remotion), không cần After Effects.

---

## Bộ này khác gì taw-kit?

| | **taw-kit** | **taw-video** |
|---|---|---|
| Output | Website / app | Video MP4 / MOV / GIF |
| Stack | Next.js + Supabase + Polar | **Remotion** (React → video) + ffmpeg + TTS |
| Deploy | Vercel / Docker / VPS | Render local hoặc Remotion Lambda |
| Phù hợp | Landing page, shop, CRM, blog | Tutorial, faceless channel, news recap, product demo, kinetic typography |

Hai kit độc lập — cài cái nào cần cái đó. Một số "meta-skill" (taw-commit, vietnamese-copy, error-to-vi, terse-internal) được copy sang để hai kit không phụ thuộc nhau.

---

## Bạn nhận được gì

- **~25 skills, 5 agents, 3 hooks** — cài sẵn vào `~/.claude/`
- **1 lệnh duy nhất `/taw-video`** — router 2 tầng: CREATE / EDIT / RENDER / REMIX
- **Stack mặc định**: Remotion 4 (React) + Tailwind cho scene + ffmpeg cho mux/compress + TTS provider tự chọn (ElevenLabs / FPT.AI / OpenAI)
- **Tự detect**: nếu folder đang có Motion Canvas / pure SVG / Manim, kit sẽ adapt thay vì cài đè Remotion
- **Voice tiếng Việt**: skill `voice-tts-vi` cho phép chọn giọng nam/nữ Bắc/Nam, tốc độ, emotion. Mặc định khuyến nghị **FPT.AI** vì giọng Việt tự nhiên nhất.
- **Sub tiếng Việt chuẩn dấu**: `captions-vi-burn` xử lý dấu tiếng Việt không bị cắt khi burn-in (bug phổ biến với ffmpeg + font không full-Unicode).
- **5 preset format**: tutorial-explainer, faceless-channel, news-recap, product-demo, kinetic-typography
- **9:16 / 1:1 / 16:9** — render đa tỉ lệ trong 1 lần build (1 source code → nhiều output)
- **License thương mại** — làm và bán bao nhiêu video cũng được

---

## Cài đặt

### Trước khi bắt đầu

| Thứ | Để làm gì | Cài ở đâu |
|---|---|---|
| **Claude Code** | CLI để chạy skill | [docs.claude.com/claude-code](https://docs.claude.com/claude-code) |
| **Node.js ≥ 20** | Chạy Remotion | [nodejs.org](https://nodejs.org) |
| **ffmpeg** | Mux + compress + convert format | `brew install ffmpeg` / `apt install ffmpeg` |
| **git** | Để clone repo | `brew install git` / `apt install git` |
| **Gói Claude Pro/Max** | Để Claude Code đăng nhập được | [claude.ai](https://claude.ai) |

> taw-video chưa hỗ trợ API key Anthropic trực tiếp — chỉ qua Claude Code login.

**Hệ điều hành:** macOS, Linux, hoặc Windows qua WSL2.

```bash
git clone https://github.com/the-agents-work/taw-video.git ~/.taw-video
bash ~/.taw-video/scripts/install.sh
```

Trình cài đặt sẽ:

1. Phát hiện hệ điều hành.
2. Kiểm tra ffmpeg + Node.js + Claude Code.
3. Cài skills, agents, hooks, templates vào `~/.claude/`.
4. (Tuỳ chọn) Tạo symlink `taw-video` vào `/usr/local/bin/`.

---

## Chạy lần đầu

Mở Claude Code trong một thư mục trống:

```bash
mkdir my-first-video && cd my-first-video
claude
```

Trong Claude Code:

```
/taw-video làm cho tôi 1 video tutorial 60s về cách dùng ChatGPT cho dân văn phòng
```

taw-video sẽ:

1. Hỏi 3–5 câu cho rõ (giọng đọc, màu chủ đạo, có nhạc nền không, tỉ lệ video).
2. Hiển thị storyboard ~5 cảnh, đợi anh duyệt.
3. Chạy chuỗi agent: `script-writer` → `storyboard-planner` → `scene-coder` → `motion-tuner` → `renderer` → `reviewer`.
4. Trả về file MP4 sẵn để upload.

Hoặc bắt đầu từ preset:

```
/taw-video preset:faceless-channel chủ đề về AI tools 2026
```

---

## Render đa tỉ lệ

Sau khi có source code video, render khác tỉ lệ chỉ cần 1 lệnh:

```
/taw-video render 9:16        # cho TikTok / YouTube Shorts / Reels
/taw-video render 1:1         # cho Instagram feed
/taw-video render 16:9        # cho YouTube ngang / web
```

Kit dùng Remotion compositions tách rời nên 1 source = 3 output mà không phải code lại. Layout responsive (text auto-shrink, padding adapt) đã set sẵn trong scene presets.

---

## Skills và agents chính

### Agents (chuỗi pipeline)

| Agent | Việc |
|---|---|
| `script-writer` | Đọc ý tưởng → ra script lời thoại tiếng Việt theo giọng phù hợp (informational / hype / chill / news) |
| `storyboard-planner` | Chia script thành 4–8 scenes với timing, beat, transition |
| `scene-coder` | Code Remotion JSX/TSX cho từng scene — animation, easing, layout |
| `motion-tuner` | Tinh chỉnh easing curves, đồng bộ animation với voice |
| `renderer` | Chạy `npx remotion render`, mux audio/sub bằng ffmpeg, compress |
| `reviewer` | Check chất lượng visual + đồng bộ audio + sub có đúng dấu không |

### Skills chính

| Skill | Để làm gì |
|---|---|
| `remotion-setup` | Khởi tạo Remotion 4 project (tsconfig, compositions, root) |
| `motion-presets-vi` | Thư viện animation kinetic typography đã lo phần dấu tiếng Việt (đ, ê, ô, ơ, ư, ă, â + dấu sắc/huyền/hỏi/ngã/nặng) |
| `voice-tts-vi` | Chọn provider TTS, gen voice từ script, output WAV/MP3 |
| `captions-vi-burn` | Burn-in subtitle với font full-Unicode (Be Vietnam Pro / Inter VN), tránh bug ffmpeg cắt dấu |
| `ffmpeg-pipeline` | Mux video + audio + sub, scale, encode H.264/H.265, target bitrate |
| `scene-presets` | Library scene tái dùng: title-card, lower-third, kinetic-quote, data-bar, comparison-split, end-card |
| `bgm-picker` | Gợi ý nhạc nền theo mood (royalty-free) + sidechain với voice |
| `youtube-shorts-9x16` | Layout + safe-area + thumbnail cho Shorts |
| `tiktok-export` | Spec output theo guideline TikTok hiện tại |
| `manim-fallback` | Khi cảnh cần math/data-viz phức tạp mà Remotion vất vả |

---

## Tài liệu

- **Quickstart:** [docs/quickstart.md](./docs/quickstart.md) — 10 phút từ ý tưởng tới video MP4
- **Architecture (EN):** [docs/en/architecture.md](./docs/en/architecture.md) — pipeline + agent chain (cho dev)
- **Voice setup:** [docs/voice-setup.md](./docs/voice-setup.md) — cấu hình ElevenLabs / FPT.AI / OpenAI

---

## License

Source-available — free dùng trong public beta. Xem [LICENSE](./LICENSE).

- **Được:** clone, dùng taw-video làm bao nhiêu video cũng được. Video bạn làm ra là của bạn 100%, không cần trích dẫn.
- **Không được:** phân phối lại repo này, bán lại taw-video hay bản rebrand.

> Lưu ý: Remotion có license riêng (free cho cá nhân + công ty < $10M ARR, trên đó cần mua). Xem [THIRD-PARTY-NOTICES.md](./THIRD-PARTY-NOTICES.md).

## Hỗ trợ

namkent1612000@gmail.com hoặc Discord [theagents.work](https://www.theagents.work/).

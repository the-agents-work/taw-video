---
name: voice-tts-vi
description: >
  Generate Vietnamese voiceover from script text using a pluggable TTS provider:
  FPT.AI (default — best VN tones, free tier), ElevenLabs (best emotion control),
  OpenAI TTS (cheapest, decent quality). Outputs MP3/WAV ready for Remotion <Audio>.
  Handles SSML for pacing, emphasis, and the dấu-nặng quirk (some providers swallow
  glottal stops). Used by scene-coder + edit branch.
  Trigger phrases (EN + VN): "tts", "voice over", "doc tieng viet", "giong noi",
  "voice", "narration", "doc loi thoai", "giong nu", "giong nam".
allowed-tools: Read, Write, Bash, WebFetch
---

# voice-tts-vi

TTS abstraction over 3 Vietnamese-capable providers. You don't memorize API shapes — pick the provider, pass the text, get back an audio file path.

## Step 0 — Detect provider config

Read `.env.local` (keys only) and `.taw-video/intent.json` voice config. Priority:

1. `intent.json.voice.provider` if explicit
2. First provider with valid env key (in this preference order: FPT_AI > ELEVENLABS > OPENAI)
3. If no key found → emit error template asking user to add a key

```bash
# Detect available
[ -n "$FPT_API_KEY" ]      && echo "fpt-ai available"
[ -n "$ELEVENLABS_API_KEY" ] && echo "elevenlabs available"
[ -n "$OPENAI_API_KEY" ]   && echo "openai available"
```

## Provider 1 — FPT.AI (recommended default)

**Why default**: best VN tones (lemented genuinely Vietnamese, not Anglicized), free 5000 chars/month, supports Bắc/Trung/Nam regions, low latency.

**Endpoint**: `POST https://api.fpt.ai/hmi/tts/v5`

**Voices** (most-used):

| Voice ID | Gender | Region | Use case |
|---|---|---|---|
| `banmai` | F | Bắc | News, formal |
| `leminh` | M | Bắc | Tutorial, authoritative |
| `lannhi` | F | Nam | Friendly, gen-Z, lifestyle |
| `minhquang` | M | Nam | Casual, faceless channel |
| `ngoclam` | F | Trung | Storytelling |
| `myan` | F | Bắc | Hype, energetic |

**Headers**:

```
api-key: $FPT_API_KEY
voice: <voice-id>
speed: 0  (range -3 to +3; 0 = natural)
format: mp3
```

**Request body**: raw text (UTF-8). Max 5000 chars per request — split at punctuation if longer.

**Sample call**:

```bash
curl -X POST https://api.fpt.ai/hmi/tts/v5 \
  -H "api-key: $FPT_API_KEY" \
  -H "voice: banmai" \
  -H "speed: 0" \
  -H "format: mp3" \
  --data-binary @.taw-video/script.txt \
  -o public/voice.mp3
```

Response is async — returns a JSON with `async` URL, poll until ready, then download.

**Real implementation** (write to `src/tts/fpt.ts`):

```ts
export async function fptTts(text: string, voice = 'banmai'): Promise<string> {
  const res = await fetch('https://api.fpt.ai/hmi/tts/v5', {
    method: 'POST',
    headers: {
      'api-key': process.env.FPT_API_KEY!,
      voice,
      speed: '0',
      format: 'mp3',
    },
    body: text,
  });
  const { async: pollUrl } = await res.json();

  // Poll
  for (let i = 0; i < 30; i++) {
    await new Promise((r) => setTimeout(r, 2000));
    const ready = await fetch(pollUrl);
    if (ready.ok) {
      const buf = await ready.arrayBuffer();
      const fs = await import('node:fs/promises');
      await fs.writeFile('public/voice.mp3', Buffer.from(buf));
      return 'public/voice.mp3';
    }
  }
  throw new Error('FPT TTS poll timeout');
}
```

## Provider 2 — ElevenLabs

**Why use**: best emotion / inflection control, multilingual model handles VN well in v2 (`eleven_multilingual_v2`).

**Endpoint**: `POST https://api.elevenlabs.io/v1/text-to-speech/<voice_id>`

**VN-capable voice IDs** (their multilingual voices speak VN passably):

- `XB0fDUnXU5powFXDhCwa` — Charlotte (F, soft)
- `pNInz6obpgDQGcFmaJgB` — Adam (M, deep)

**SDK install**:

```bash
npm install elevenlabs
```

**Code**:

```ts
import { ElevenLabs } from 'elevenlabs';

const eleven = new ElevenLabs({ apiKey: process.env.ELEVENLABS_API_KEY! });

export async function elevenTts(text: string, voiceId: string) {
  const stream = await eleven.generate({
    voice: voiceId,
    text,
    model_id: 'eleven_multilingual_v2',
    voice_settings: { stability: 0.5, similarity_boost: 0.75 },
  });
  // stream is Readable<Buffer>; pipe to file
  const fs = await import('node:fs');
  return new Promise<string>((res, rej) => {
    const out = fs.createWriteStream('public/voice.mp3');
    stream.pipe(out);
    out.on('finish', () => res('public/voice.mp3'));
    out.on('error', rej);
  });
}
```

**Cost**: ~$0.30 per 1000 chars on Creator plan.

## Provider 3 — OpenAI TTS

**Why use**: cheapest of the three (~$0.015 per 1000 chars), decent VN intonation, fastest API.

**Voices**: `nova` (F, friendly), `onyx` (M, deep), `alloy` (neutral). All multilingual.

**Code** (using `openai` SDK):

```ts
import OpenAI from 'openai';

const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

export async function openaiTts(text: string, voice: 'nova' | 'onyx' | 'alloy' = 'nova') {
  const mp3 = await openai.audio.speech.create({
    model: 'tts-1-hd',
    voice,
    input: text,
    response_format: 'mp3',
  });
  const buf = Buffer.from(await mp3.arrayBuffer());
  const fs = await import('node:fs/promises');
  await fs.writeFile('public/voice.mp3', buf);
  return 'public/voice.mp3';
}
```

## SSML / pacing tricks (provider-specific)

VN-specific tricks to avoid robot voice:

### 1. Insert breath marks at clause boundaries

After commas and before subordinate clauses, insert `,` (comma + space). All providers respect punctuation timing. Without this, long sentences read as monotone runs.

### 2. Spell-out numbers with units

"5 phút" → providers often read as "năm phút" (correct), but "5km" gets read as "five kilomet" (wrong). Replace with "5 ki-lô-mét" before TTS. Skill maintains a substitution dict at `src/tts/vi-pronounce.ts`.

### 3. Emphasis via SSML (ElevenLabs only)

```xml
<speak>
  Đây là <emphasis level="strong">điều quan trọng nhất</emphasis>.
</speak>
```

FPT.AI doesn't support SSML — workaround: capitalize for emphasis ("ĐIỀU QUAN TRỌNG NHẤT"). OpenAI: ignores SSML, but accepts repeated emphasis text in script.

### 4. Avoid English code-switching mid-sentence

"Sử dụng React để build app" — VN providers stumble on "React" + "build" + "app". Workaround:
- Romanize: "Sử dụng Ri-ác để xây ứng dụng"
- Or split: gen 2 audio segments + concat (more work, better quality)
- Or accept slight unnaturalness if the term is widely known

## Cost estimation (call before generation)

For any text > 1000 chars, emit estimate:

```
Voice gen sẽ tốn ~$<X> (<provider>, <Y> chars). Tiếp tục? (y/n)
```

Reference rates (April 2026):

| Provider | $/1000 chars | Free tier |
|---|---|---|
| FPT.AI | ~free | 5000/month |
| ElevenLabs Creator | $0.30 | 10K/month |
| OpenAI tts-1-hd | $0.030 | none |
| OpenAI tts-1 (lower q) | $0.015 | none |

## Output convention

Always write to `public/voice.mp3` (Remotion's `<Audio src={staticFile('voice.mp3')}>` looks here). For multi-segment, write `public/voice-<n>.mp3` then concat via `ffmpeg-pipeline`.

Set sample rate via env: `TAW_VIDEO_TTS_SR=44100` (default) — match Remotion's audio target.

## Skill output

Return JSON:

```json
{
  "status": "ok",
  "provider": "fpt-ai",
  "voice": "banmai",
  "duration_sec": 47.3,
  "char_count": 612,
  "cost_estimate_usd": 0.0,
  "output_path": "public/voice.mp3"
}
```

## Constraints

- NEVER store API keys in `.taw-video/`. Read from `.env.local` only.
- If user has no key for any provider, escalate via `error-to-vi` template "TTS: insufficient credits" with provider sign-up links.
- For text > 5000 chars (FPT.AI hard limit) → split at sentence boundaries via Intl.Segmenter, gen each, concat with `ffmpeg-pipeline`.
- Always run sample-rate check on output: `ffprobe -i public/voice.mp3` should report 44100Hz. If not, re-encode.

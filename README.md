# faegentic-x

Unreal Engine feature'larını iki model ailesiyle çaprazlama geliştiren bir agent skill'i. Claude Code'da da Codex'te de aynı dosyayla çalışır.

- Hangi ajanla başlatırsan o **orkestratör** olur: planlar, mimari kararı verir, build alır, commit atar.
- Kodu **karşı aile** yazar (Claude başlattıysa GPT, GPT başlattıysa Claude).
- Yazılan kodu **orkestratörün ailesi** denetler.

Böylece her alt özellik, yazandan farklı bir modelin gözünden geçer.

## Akış

```
Orkestratör (Opus 5.5 veya GPT-6.1-Sol)
  │  plan + mimari kararlar
  │
  ├─ alt iş 01 ── brief.md
  │     ├─ yazıcı   : karşı aile  (scripts/cross.ps1 → codex exec / claude -p)
  │     ├─ denetçi  : kendi ailen (native subagent, temiz context)
  │     ├─ CHANGES ise düzeltme turu (en fazla 2)
  │     └─ orkestratör build + test → commit
  │
  ├─ alt iş 02 ...
  └─ son diff incelemesi + docs
```

| Rol | Claude ile başlatınca | Codex ile başlatınca |
| --- | --- | --- |
| Orkestratör | `claude-opus-5-5` | `gpt-6.1-sol` |
| Yazıcı | `gpt-6.1-sol` (`codex exec`) | `claude-opus-5-5` (`claude -p`) |
| Denetçi | Claude subagent | Codex subagent |

## Kullanım

Unreal projenin klasöründe ajana yaz:

| Komut | Yazan | Denetleyen |
| --- | --- | --- |
| `faegentic-x on kapı etkileşimi` | Karşı aile | Kendi ailen |
| `faegentic-x on kapı etkileşimi claude` | Claude | Claude |
| `faegentic-x on kapı etkileşimi gpt` | GPT | GPT |
| `faegentic-x off` | Normal ajan akışına döner | |

Son kelime `claude` veya `gpt` ise feature adına dahil edilmez; o aileyi kilitler. Kendi ailen kilitliyse karşı CLI hiç çağrılmaz.

Ek seçenekler (sıra önemli değil):

| Seçenek | Varsayılan | Etki |
| --- | --- | --- |
| `tutor on/off` | `on` | `learn.md` üretir |
| `docs on/off` | `on` | `Docs/<feature>-<tarih>/` üretir |
| `effort <seviye>` | `max` | Yazıcının reasoning seviyesi |
| `parallel on/off` | `off` | Bağımsız alt işleri ayrı worktree'lerde paralel yazdırır |

Örnek:

```text
faegentic-x on Kapılara E tuşuyla etkileşim ekle, kilitli kapılar anahtar istesin. tutor off
```

Commit biçimi:

```text
feature. <ana özellik> - [<yazıcı model> <effort> / review <denetçi model>] - [<alt özellik> - <yapılan iş>]
```

## Gereksinimler

- Git
- PowerShell 7 (`pwsh`)
- [Claude Code](https://claude.com/claude-code) ve [Codex CLI](https://github.com/openai/codex), ikisi de giriş yapılmış
- Çapraz modda iki tarafın da kotası. Kota biterse skill durur ve sorar; sessizce diğer modele geçmez.

## Kurulum

Aynı repo iki ajanın skill klasörüne klonlanır.

**Windows (PowerShell)**

```powershell
git clone https://github.com/dogancanokur/faegentic.git "$env:USERPROFILE\.claude\skills\faegentic-x"
git clone https://github.com/dogancanokur/faegentic.git "$env:USERPROFILE\.codex\skills\faegentic-x"
```

**macOS / Linux**

```bash
git clone https://github.com/dogancanokur/faegentic.git ~/.claude/skills/faegentic-x
git clone https://github.com/dogancanokur/faegentic.git ~/.codex/skills/faegentic-x
```

Kurduktan sonra iki ajanda da yeni oturum aç. Güncellemek için iki klasörde `git pull`.

Köprüyü tek başına denemek için:

```bash
pwsh -NoProfile -File ~/.claude/skills/faegentic-x/scripts/cross.ps1 -To claude -Role write -Brief <brief.md> -Dir . -Effort low
```

## Dosyalar

| Dosya | İş |
| --- | --- |
| `SKILL.md` | Akış kuralları, roller, aile kilidi, commit ve docs kuralları |
| `scripts/cross.ps1` | Karşı aileyi headless çağıran köprü (`write`, `fix`, `review`) |
| `references/brief-template.md` | Orkestratörün her alt iş için doldurduğu brief |
| `references/writer-preamble.md` | Yazıcı kuralları ve rapor biçimi |
| `references/reviewer-preamble.md` | Denetçi kontrol listesi ve `PASS` / `CHANGES` biçimi |
| `references/review-template.md` | Denetçiye giden girdi |
| `agents/openai.yaml` | Codex arayüz bilgisi |

Çalışma dosyaları projede `.faegentic/` altına yazılır ve `.git/info/exclude` ile git dışında tutulur.

## Bilinen notlar

- Microsoft Store'dan kurulan `pwsh`, `AppData\Roaming` altındaki dosyaları göremez. Skill'i ev dizininde tut (`~/.claude/skills`, `~/.codex/skills`).
- `claude -p` global hook'larını da yükler; yazıcı çıktısının başında hook mesajları görünebilir. Rapor bloğu (`## Report`) etkilenmez.

## Lisans

[MIT](LICENSE)

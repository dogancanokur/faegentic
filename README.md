# faegentic

Unreal Engine projelerinde yeni özellik geliştirmek için hazırlanmış bir Codex skill’i. `faegentic` komutu kullanıldığında işi önce planlar, ardından küçük alt özelliklere ayırarak Luna subagent’larına dağıtır.

## Sürümler

- **Standart:** [SKILL.md](SKILL.md). Plan, ana agent tarafından yazılan subplanlar, Luna alt ajanları ve alt özellik commit’leri.
- **Beyinli:** [beyinli/SKILL.md](beyinli/SKILL.md). Standart akışa ek olarak planı ve aşamaları Beyin’e kaydeder; feature ve alt task sınırlarında kullanım limitini kontrol eder, durursa devam notu bırakır.
- **Beyinli + öğretici:** [beyinli-ogretici/SKILL.md](beyinli-ogretici/SKILL.md). Beyinli akışa C++/Blueprint sorumluluk sözleşmesi ve ana agent'ın feature sonunda hazırladığı ownership handoff'u ekler. Veri akışı, Blueprint bağlantıları, kullanılan Unreal C++ kavramları ve manuel Editor testleri açıklanır. Bu varyant yalnız açık çağrıyla etkinleşir.

Üç varyantın skill adı `faegentic`tir. Seçtiğiniz varyantı yerel `faegentic` klasörüne kurun; öğretici varyantın `references` ve `agents` dosyaları da gereklidir. Beyinli varyantlar için çalışan bir Beyin kurulumu ve `beyin` skill’i gerekir.

## Neden yapıldı?

Büyük bir özelliği tek seferde kodlamak, hangi parçanın tamamlandığını ve neyin inceleneceğini belirsizleştirebilir. faegentic; planı görünür kılmak, alt özellikleri ayrı commit’lerle izlemek ve tamamlanan işi review’e hazır halde sunmak için oluşturuldu.

## Ne için kullanılır?

Yeni bir Unreal Engine özelliği istediğinizde kullanılır. Akış şöyledir:

1. Projeyi ve isteği inceleyip uygulanabilir bir plan hazırlar.
2. İşi küçük, bağımsız alt özelliklere böler.
3. Ana agent, her alt özellik için uygulanacak adımları, dosya sınırlarını ve kabul ölçütlerini içeren subplanı hazırlar.
4. Hazır subplanı `gpt-6-luna` modeli ve `max` reasoning kullanan subagent’a vererek parçayı uygulatır.
5. Her tamamlanan alt özelliği ayrı commit’ler; sonunda “review’e hazır” diye bildirir.

Bir parçanın akışı Luna’yı aşarsa daha büyük modele geçmeden önce sizden onay ister. Ayrıntılı kurallar seçtiğiniz sürümün SKILL.md dosyasındadır.

## Kurulum

Codex skill’leri `~/.codex/skills` klasöründen yüklenir. Git ve Codex’in subagent desteği gerekir; Luna modelinin `max` reasoning seçeneği hesabınızda kullanılabilir olmalıdır.

**Windows (PowerShell)**

```powershell
git clone https://github.com/dogancanokur/faegentic.git "$env:USERPROFILE\.codex\skills\faegentic"
```

**macOS / Linux**

```bash
git clone https://github.com/dogancanokur/faegentic.git ~/.codex/skills/faegentic
```

Bu komutlar **standart sürümü** kurar. **Beyinli sürüm** için onun SKILL.md dosyasını doğrudan indirin:

**Windows (PowerShell)**

```powershell
$skillDir = "$env:USERPROFILE\.codex\skills\faegentic"
New-Item -ItemType Directory -Force $skillDir | Out-Null
Invoke-WebRequest "https://raw.githubusercontent.com/dogancanokur/faegentic/main/beyinli/SKILL.md" -OutFile (Join-Path $skillDir "SKILL.md")
```

**macOS / Linux**

```bash
mkdir -p ~/.codex/skills/faegentic
curl -fsSL https://raw.githubusercontent.com/dogancanokur/faegentic/main/beyinli/SKILL.md -o ~/.codex/skills/faegentic/SKILL.md
```

Özel bir `CODEX_HOME` kullanıyorsanız hedefi `$CODEX_HOME/skills/faegentic` olarak uyarlayın. Yalnızca bir sürümü etkin tutun ve kurulumdan sonra Codex’te yeni bir oturum açın. Beyinli sürümü güncellemek için indirme komutunu yeniden çalıştırın.

### Beyinli + öğretici varyantı kurma

Bu varyantın üç dosyasını birlikte indirin. Mevcut yerel skill'inizi değiştirecekseniz önce yedeğini alın.

**Windows (PowerShell)**

```powershell
$skillDir = "$env:USERPROFILE\.codex\skills\faegentic"
$variantUrl = 'https://raw.githubusercontent.com/dogancanokur/faegentic/main/beyinli-ogretici'
foreach ($relativeFile in @('SKILL.md', 'references/ownership-handoff.md', 'agents/openai.yaml')) {
    $targetFile = Join-Path $skillDir $relativeFile
    New-Item -ItemType Directory -Force (Split-Path $targetFile -Parent) | Out-Null
    Invoke-WebRequest "$variantUrl/$relativeFile" -OutFile $targetFile
}
```

**macOS / Linux**

```bash
skill_dir="${CODEX_HOME:-$HOME/.codex}/skills/faegentic"
variant_url='https://raw.githubusercontent.com/dogancanokur/faegentic/main/beyinli-ogretici'
mkdir -p "$skill_dir/references" "$skill_dir/agents"
for relative_file in SKILL.md references/ownership-handoff.md agents/openai.yaml; do
  curl -fsSL "$variant_url/$relative_file" -o "$skill_dir/$relative_file" || exit 1
done
```

Özel bir `CODEX_HOME` için PowerShell'de de `$skillDir` hedefini uyarlayın. Kurulumdan sonra yeni bir Codex oturumu açın. Aynı üç dosyayı indirerek varyantı güncelleyebilirsiniz.

### Öğretici varyantın mod komutları

Komutları Codex sohbetine yazın; bunlar terminal veya yerleşik slash komutları değildir.

| Sohbet komutu | Sonuç |
| --- | --- |
| `$faegentic off` | Bu sohbette Faegentic akışını kapatır; normal agent çalışmasına döner. |
| `normal çalış` veya `normal moda geç` | Aynı kapatma işlemi; Beyin profilini değiştirmez. |
| `$faegentic on` | Bu sohbet için akışı açar; tek başına yeni feature başlatmaz. |
| `$faegentic <feature açıklaması>` | Akışı açar ve belirtilen feature'ı başlatır. |

Mod başka sohbetlere uygulanmış sayılmaz. Kapatma mevcut kodu veya kurulu skill dosyalarını silmez. Beyin ekonomik/normal ayarı ayrı yönetilir.

## Kullanım

Unreal Engine projenizin klasöründe Codex’e örneğin şunu yazın:

```text
$faegentic Kapılara E tuşuyla etkileşim ekle. Kilitli kapılar anahtar gerektirsin.
```

Planı inceleyebilir, alt özelliklerin ayrı commit’lerini review edebilirsiniz. Commit biçimi:

```text
feature. <ana özellik> - [luna max] - [<alt özellik> - <yapılan iş>]
```

## Lisans

[MIT](LICENSE).

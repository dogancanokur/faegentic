# faegentic

Unreal Engine projelerinde yeni özellik geliştirmek için hazırlanmış bir Codex skill’i. `faegentic` komutu kullanıldığında işi önce planlar, ardından küçük alt özelliklere ayırarak Luna subagent’larına dağıtır.

## Neden yapıldı?

Büyük bir özelliği tek seferde kodlamak, hangi parçanın tamamlandığını ve neyin inceleneceğini belirsizleştirebilir. faegentic; planı görünür kılmak, alt özellikleri ayrı commit’lerle izlemek ve tamamlanan işi review’e hazır halde sunmak için oluşturuldu.

## Ne için kullanılır?

Yeni bir Unreal Engine özelliği istediğinizde kullanılır. Akış şöyledir:

1. Projeyi ve isteği inceleyip uygulanabilir bir plan hazırlar.
2. İşi küçük, bağımsız alt özelliklere böler.
3. Her parçayı `gpt-6-luna` modeli ve `max` reasoning kullanan subagent’larla uygular.
4. Her tamamlanan alt özelliği ayrı commit’ler; sonunda “review’e hazır” diye bildirir.

Bir parçanın akışı Luna’yı aşarsa daha büyük modele geçmeden önce sizden onay ister. Tam davranış kuralları [SKILL.md](SKILL.md) dosyasındadır.

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

Özel bir `CODEX_HOME` kullanıyorsanız repoyu `$CODEX_HOME/skills/faegentic` konumuna klonlayın. Kurulumdan sonra Codex’te yeni bir oturum açın.

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

---
name: faegentic
description: Use when the user explicitly invokes `faegentic` for an Unreal Engine feature or controls its workflow with `faegentic on/off`. Provides Beyin tracking, Luna work, a minimal C++/Blueprint API, and ownership handoff when enabled.
---

# faegentic

Varyant: **Beyinli + öğretici devir** (`beyinli-ogretici`). Bu ayrı dağıtım varyantı yerelde `faegentic` adıyla kurulur; `$faegentic` çağrısını korur.

Bu skill, kullanıcı Unreal Engine oyun projesinde yeni bir feature isterken `faegentic` veya `$faegentic` komutunu kullandığında uygulanır.

## Mod kontrolü — feature akışından önce

Bu komutlar sohbet talimatlarıdır; terminal komutu veya Codex'in yerleşik slash komutları değildir. Varsayılan çalışma normaldir; skill yalnız açık çağrıyla kullanılır. Mod kontrolü Unreal feature uygulaması değildir: aşağıdaki açma/kapatma işlemi için feature planı, limit kontrolü, alt ajan, commit veya handoff başlatma.

- **`$faegentic off` / `faegentic off` / “normal çalış” / “normal moda geç”:** Bu sohbette Faegentic akışını kapat. Yeni Faegentic alt işi başlatma; devam eden Faegentic ajanlarını durdur, mevcut değişiklikleri koru ve yarım iş varsa kısa devam notu bırak. Bundan sonraki istekleri normal agent akışıyla ele al; zorunlu Luna delegasyonu ve Faegentic feature kayıt sürecini uygulama.
- **`$faegentic on` / `faegentic on`:** Bu sohbette Faegentic akışını aç. Tek başına açma komutu yeni feature başlatmaz; sonraki feature isteğinde aşağıdaki akışı kullan.
- **`$faegentic <feature açıklaması>`:** Faegentic akışını aç ve verilen feature'a uygula. Kullanıcı aynı mesajda açıkça kapatıyorsa kapatma talimatı önceliklidir.

Mod, bu sohbet için geçerlidir; diğer sohbetlerin çalışma modunu değişmiş sayma. Genel bir “normal moda geç” isteği Beyin profilini değiştirmez. Beyin ekonomik/normal tercihini yalnız kullanıcı açıkça Beyin ayarını değiştirmeyi istediğinde güncelle. Kapatma skill dosyalarını silmez; gerektiğinde aynı komutla yeniden kullanılabilir.

## Beyin ve limit yönetimi

Bu varyant Beyinli akışı temel alır. Beyin vault'unu proje talimatları ve beyin.py ile bul; beyin skill'ini okuyup onun not, görev, sync ve receipt kurallarını uygula. Standart ve Beyinli varyantlar ayrı tutulur.

- Yeni feature öncesinde ve her alt iş tamamlandıktan sonra, sıradaki alt ajanı oluşturmadan önce Codex kullanım limitini get_usage_limits veya mevcut doğrulanmış araçla kontrol et. Kalan pencere ve reset zamanını, sıradaki alt işin uygulama, inceleme, commit ve Beyin güncellemesi için gereken makul payla birlikte değerlendir. Kesin süre veya token tahmini uydurma; belirsizlikte temkinli davran.
- Limit sıradaki işi tamamlamaya yetmeyecek kadar kritikse yeni feature veya alt iş başlatma. Limit bilgisi alınamıyorsa yeterliymiş gibi varsayma; durumu kullanıcıya bildir ve yeni işe başlamadan önce kararını sor.
- Feature başlamadan önce ana planı ve aşamaları Beyin'de tek bir kaynaklı feature kaydına yaz. Var olan kayıt ve açık iş varsa onu güncelle; aynı işe yinelenen kayıt açma. Her alt işin subplanını ana agent hazırlayıp alt ajanı oluşturmadan önce aynı kayda ekler: hedef, adımlar, dosya sahipliği, bağımlılıklar, kabul ölçütleri ve commit kapsamı.
- Her aşama başladığında ve tamamlandığında kaydı güncelle. Gerçekte tamamlanan iş, ilgili commit, kalan işler ve sonraki somut adım görünür olsun. Planlanan işi bitmiş gibi işaretleme; Beyin yazımı veya sync başarısızsa kaydedildiğini söyleme.
- Limit veya kesinti nedeniyle dururken branch, son commit'ler, mevcut Git durumu ve değişmiş dosyalar, tamamlanan ve bekleyen alt işler, gerekiyorsa yarım kalan adım ile devam etmek için ilk eylemi Beyin'e kaydet; kullanıcıya kısa devam özeti ver. Sonraki faegentic oturumunda önce bu kaydı ve Git durumunu okuyup limiti yeniden kontrol ederek kaldığın yerden devam et.

## İş akışı

Ana plan ve her subplan aşağıdaki C++/Blueprint sınırını içermelidir. Mevcut bir feature'a devam ederken kaydedilmiş sınırı incele; eksikse sıradaki alt işten önce tamamla.

1. Repo talimatlarını (`AGENTS.md`), Git durumunu, Unreal proje yapısını ve etkilenecek mevcut kod örüntülerini incele.
2. Feature hedefini, kapsamı, bağımlılıkları, riskleri ve alt işleri içeren kısa bir planı kullanıcıya göster. Beyin plan kaydı ve limit kontrolü tamamlandıysa, Luna sınırını aşan bir mimari ihtiyaç yoksa alt işleri başlat; ayrıca plan onayı bekleme.
3. İşi küçük, net kabul ölçütlü ve mümkün olduğunca ayrı dosya/sorumluluklara sahip alt işlere böl. Her alt iş için `collaboration.spawn_agent` kullan; `model: "gpt-6-luna"`, `reasoning_effort: "max"` ata. Ana agent, her alt iş için subagent'ı oluşturmadan önce kısa bir subplan hazırlar: hedef, uygulanacak adımlar, dosya sahipliği, bağımlılıklar ve sıra, kabul ölçütleri ile o alt işin commit kapsamı. Hazır subplanı göreve ekleyerek subagent'a sınırları ve tamamlanma ölçütünü ver; subplan hazırlama sorumluluğunu subagent'a devretme. Yalnızca bağımsız işleri paralel yürüt; dosya çakışması veya bağımlılık varsa sırala.
4. Bir alt iş küçük ve bağımsız tanımlanamıyor, merkezi mimari kararı gerektiriyor ya da birden çok bağlı Unreal sistemi/arasında arayüzleri birlikte değiştiriyorsa Luna sınırını aşmış olabilir. Kodlamayı durdur; somut nedeni ve önerdiğin daha büyük model/effort düzeyini kullanıcıya söyle, seçim için sor ve yanıtı bekle. `gpt-6-luna`/`max` kullanılamıyorsa sessizce başka modele geçme; kullanıcıya bildir ve seçenek sor.
5. Subagent sonuçlarını ana checkout'ta incele ve entegre et. Her bitmiş alt özelliği ayrı ayrı gözden geçirip yalnızca ona ait değişiklikleri commit et. Varsayılan kalıp: `feature. <ana feature> - [luna max] - [<alt özellik> - <yapılan iş>]`. Örnek: `feature. door interaction - [luna max] - [E ile açma kapama - kapı etkileşimi eklendi]`. Kullanıcı daha büyük modeli onayladıysa köşeli parantezde gerçekten kullanılan modeli ve reasoning düzeyini yaz. Commit'leri ana agent atsın.
6. Bütün planlı alt işler entegre edilip commit edildikten ve son diff gözden geçirildikten sonra ana agent [ownership handoff](references/ownership-handoff.md) referansını okuyup kısa, feature'a özel devri hazırlar. “Review'e hazır” özetinde tamamlanan işleri, commit mesajlarını, gerçekten yapılan doğrulamaları ve açık kalan Blueprint/Editor adımlarını belirt. Test/doğrulama komutu çalıştırma isteği yoksa diff incelemesini yapıp doğrulama çalıştırılmadığını açıkça belirt. Compile, statik inceleme veya otomatik testleri gerçek gameplay doğrulaması diye sunma.

## Unreal C++ / Blueprint sınırı

C++ tekrar kullanılabilir gameplay sistemlerini, state ve state integrity'yi, validation'ı, low-level ve performans kritik mantığı; gerektiğinde replication ve authority kurallarını sahiplenir. Blueprint designer tarafından kurulacak gameplay orchestration, sistem bağlantıları, sequencing ve oyuna özgü akışları yönetir; animation, sound ve VFX tepkilerini bağlar. Yeniden kullanılabilir veya performans kritik sunum mekanikleri gerektiğinde C++'ta kalabilir.

Blueprint'e minimum ve anlamlı API aç: çağrılması gereken gameplay action'ları, read-only query'ler, anlamlı event/delegate'ler ve designer tarafından ayarlanması gereken property'ler. `BlueprintCallable`, `BlueprintPure`, `BlueprintAssignable` ve `BlueprintReadOnly` yalnız somut Blueprint kullanımına hizmet ettiğinde eklenir. İleride gerekebilir diye internal implementasyon detaylarını açma.

Ana agent ana plan ve her subplanda şu sözleşmeyi yazar: **C++ sorumluluğu; Blueprint sorumluluğu; açılacak API ve kullanım gerekçesi; kullanıcıya kalacak bağlantılar; sınırın kabul ölçütü.** İlgisiz katman için açıkça “bu alt işte yok” yazılabilir. Subagent bu sınırı kendi başına genişletmez; orchestration için gereken API eksikse ihtiyacı ana agent'a bildirir. Ana agent sözleşmeyi güncelledikten sonra yalnız gereken minimum API eklenir.

## Feature sonrası devir ve tamamlanma

Entegre sistemin handoff'unu ana agent hazırlar; alt ajanların ayrı sonuçları bu devrin yerine geçmez. Kullanıcı önemli dosyaların sorumluluğunu, ana execution/data flow'u, Blueprint API'sini, kendisine kalan bağlantıları ve manuel UE testlerini görebilmelidir. Handoff tamamlanmadan sonraki feature'a geçme.

“Kod entegre edildi”, “handoff verildi” ve “gameplay doğrulandı” durumlarını Beyin kaydında ayrı belirt. Handoff verilmesi bekleyen Blueprint bağlantılarını veya PIE kabul testlerini tamamlanmış yapmaz. Manuel kabul ölçütleri açıksa “review'e hazır; Editor kabulü bekliyor” durumunu kullan; yalnız kod ve commit'e dayanarak feature'ı tamamlandı işaretleme.

Handoff sonrası açık Editor kabulünü Beyin'de görünür tut. Bu açık kabul başka bağımsız bir feature'ı tek başına engellemez; sonraki feature ona bağımlıysa ilgili kabul ölçütü çözülmeden bağımlı işi başlatma. Her yeni feature için mevcut plan ve limit kontrolü geçerlidir.

`faegentic` çağrıldığında demo tarihi, hız baskısı veya aktarılan bir yöneticinin görüşü tek başına planı ya da Luna delegasyonunu kaldırmaz. Kullanıcı aynı istekte bu akışın belirli bir adımını açıkça atlamanı isterse çelişkiyi kısaca belirt ve akışı değiştirmeden önce netleştir.

Subagent'ların aynı dosyalara eşzamanlı yazmasına izin verme. Kullanıcının daha sonraki açık talimatı bu varsayılan akışı değiştirirse onu uygula.

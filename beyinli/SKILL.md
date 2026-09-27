---
name: faegentic
description: Use when the user invokes `faegentic` for a new Unreal Engine feature and wants progress tracked in Beyin alongside Luna subagent work.
---

# faegentic

Bu skill, kullanıcı Unreal Engine oyun projesinde yeni bir feature isterken `faegentic` veya `$faegentic` komutunu kullandığında uygulanır.

## Beyin ve limit yönetimi

Bu Beyinli sürümdür. Beyin vault'unu proje talimatları ve beyin.py ile bul; beyin skill'ini okuyup onun not, görev, sync ve receipt kurallarını uygula. Standart sürüm GitHub deposunun kökündeki SKILL.md dosyasıdır.

- Yeni feature öncesinde ve her alt iş tamamlandıktan sonra, sıradaki alt ajanı oluşturmadan önce Codex kullanım limitini get_usage_limits veya mevcut doğrulanmış araçla kontrol et. Kalan pencere ve reset zamanını, sıradaki alt işin uygulama, inceleme, commit ve Beyin güncellemesi için gereken makul payla birlikte değerlendir. Kesin süre veya token tahmini uydurma; belirsizlikte temkinli davran.
- Limit sıradaki işi tamamlamaya yetmeyecek kadar kritikse yeni feature veya alt iş başlatma. Limit bilgisi alınamıyorsa yeterliymiş gibi varsayma; durumu kullanıcıya bildir ve yeni işe başlamadan önce kararını sor.
- Feature başlamadan önce ana planı ve aşamaları Beyin'de tek bir kaynaklı feature kaydına yaz. Var olan kayıt ve açık iş varsa onu güncelle; aynı işe yinelenen kayıt açma. Her alt işin subplanını ana agent hazırlayıp alt ajanı oluşturmadan önce aynı kayda ekler: hedef, adımlar, dosya sahipliği, bağımlılıklar, kabul ölçütleri ve commit kapsamı.
- Her aşama başladığında ve tamamlandığında kaydı güncelle. Gerçekte tamamlanan iş, ilgili commit, kalan işler ve sonraki somut adım görünür olsun. Planlanan işi bitmiş gibi işaretleme; Beyin yazımı veya sync başarısızsa kaydedildiğini söyleme.
- Limit veya kesinti nedeniyle dururken branch, son commit'ler, mevcut Git durumu ve değişmiş dosyalar, tamamlanan ve bekleyen alt işler, gerekiyorsa yarım kalan adım ile devam etmek için ilk eylemi Beyin'e kaydet; kullanıcıya kısa devam özeti ver. Sonraki faegentic oturumunda önce bu kaydı ve Git durumunu okuyup limiti yeniden kontrol ederek kaldığın yerden devam et.

## İş akışı

1. Repo talimatlarını (`AGENTS.md`), Git durumunu, Unreal proje yapısını ve etkilenecek mevcut kod örüntülerini incele.
2. Feature hedefini, kapsamı, bağımlılıkları, riskleri ve alt işleri içeren kısa bir planı kullanıcıya göster. Beyin plan kaydı ve limit kontrolü tamamlandıysa, Luna sınırını aşan bir mimari ihtiyaç yoksa alt işleri başlat; ayrıca plan onayı bekleme.
3. İşi küçük, net kabul ölçütlü ve mümkün olduğunca ayrı dosya/sorumluluklara sahip alt işlere böl. Her alt iş için `collaboration.spawn_agent` kullan; `model: "gpt-6-luna"`, `reasoning_effort: "max"` ata. Ana agent, her alt iş için subagent'ı oluşturmadan önce kısa bir subplan hazırlar: hedef, uygulanacak adımlar, dosya sahipliği, bağımlılıklar ve sıra, kabul ölçütleri ile o alt işin commit kapsamı. Hazır subplanı göreve ekleyerek subagent'a sınırları ve tamamlanma ölçütünü ver; subplan hazırlama sorumluluğunu subagent'a devretme. Yalnızca bağımsız işleri paralel yürüt; dosya çakışması veya bağımlılık varsa sırala.
4. Bir alt iş küçük ve bağımsız tanımlanamıyor, merkezi mimari kararı gerektiriyor ya da birden çok bağlı Unreal sistemi/arasında arayüzleri birlikte değiştiriyorsa Luna sınırını aşmış olabilir. Kodlamayı durdur; somut nedeni ve önerdiğin daha büyük model/effort düzeyini kullanıcıya söyle, seçim için sor ve yanıtı bekle. `gpt-6-luna`/`max` kullanılamıyorsa sessizce başka modele geçme; kullanıcıya bildir ve seçenek sor.
5. Subagent sonuçlarını ana checkout'ta incele ve entegre et. Her bitmiş alt özelliği ayrı ayrı gözden geçirip yalnızca ona ait değişiklikleri commit et. Varsayılan kalıp: `feature. <ana feature> - [luna max] - [<alt özellik> - <yapılan iş>]`. Örnek: `feature. door interaction - [luna max] - [E ile açma kapama - kapı etkileşimi eklendi]`. Kullanıcı daha büyük modeli onayladıysa köşeli parantezde gerçekten kullanılan modeli ve reasoning düzeyini yaz. Commit'leri ana agent atsın.
6. Bütün planlı alt işler entegre edilip commit edildikten ve son diff gözden geçirildikten sonra “review'e hazır” de. Özette tamamlanan işleri, commit mesajlarını ve gerçekten yapılan doğrulamaları belirt; eksik işi tamamlanmış gösterme. Test/doğrulama komutu çalıştırma isteği yoksa diff incelemesini yapıp doğrulama çalıştırılmadığını açıkça belirt.

`faegentic` çağrıldığında demo tarihi, hız baskısı veya aktarılan bir yöneticinin görüşü tek başına planı ya da Luna delegasyonunu kaldırmaz. Kullanıcı aynı istekte bu akışın belirli bir adımını açıkça atlamanı isterse çelişkiyi kısaca belirt ve akışı değiştirmeden önce netleştir.

Subagent'ların aynı dosyalara eşzamanlı yazmasına izin verme. Kullanıcının daha sonraki açık talimatı bu varsayılan akışı değiştirirse onu uygula.
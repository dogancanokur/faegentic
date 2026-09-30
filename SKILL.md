---
name: faegentic
description: Use when the user invokes `faegentic` for a new Unreal Engine feature and wants it planned, implemented through Luna subagents, committed by subfeature, and prepared for review.
---

# faegentic

Bu skill, kullanıcı Unreal Engine oyun projesinde yeni bir feature isterken `faegentic on` veya `$faegentic on` komutunu kullandığında uygulanır ve  `faegentic off` veya `$faegentic off` komutuyla devre dışı bırakılır.
 `faegentic [aç-kapat] [öğretici aç-kapat] [dokümantasyon aç-kapat]` şeklinde de kullanılabilir.
 örneğin `faegentic on tutor off docs on` şeklinde kullanılırsa, öğretici devre dışı bırakılır ve dokümantasyon açılır.
 doğrudan `faegentic on` şeklinde kullanılırsa, öğretici ve dokümantasyon varsayılan olarak açılır.


## İş akışı

1. Repo talimatlarını (`AGENTS.md`), Git durumunu, Unreal proje yapısını ve etkilenecek mevcut kod örüntülerini incele.
2. Feature hedefini, kapsamı, bağımlılıkları, riskleri ve alt işleri içeren kısa bir planı kullanıcıya göster. Luna sınırını aşan bir mimari ihtiyaç yoksa planı gösterdikten sonra doğrudan alt işleri başlat; ayrıca plan onayı bekleme.
3. İşi küçük, net kabul ölçütlü ve mümkün olduğunca ayrı dosya/sorumluluklara sahip alt işlere böl. Her alt iş için `collaboration.spawn_agent` kullan; `model: "gpt-6-luna"`, `reasoning_effort: "max"` ata. Ana agent, her alt iş için subagent'ı oluşturmadan önce kısa bir subplan hazırlar: hedef, uygulanacak adımlar, dosya sahipliği, bağımlılıklar ve sıra, kabul ölçütleri ile o alt işin commit kapsamı. Hazır subplanı göreve ekleyerek subagent'a sınırları ve tamamlanma ölçütünü ver; subplan hazırlama sorumluluğunu subagent'a devretme. Yalnızca bağımsız işleri paralel yürüt; dosya çakışması veya bağımlılık varsa sırala.
4. Bir alt iş küçük ve bağımsız tanımlanamıyor, merkezi mimari kararı gerektiriyor ya da birden çok bağlı Unreal sistemi/arasında arayüzleri birlikte değiştiriyorsa Luna sınırını aşmış olabilir. Kodlamayı durdur; somut nedeni ve önerdiğin daha büyük model/effort düzeyini kullanıcıya söyle, seçim için sor ve yanıtı bekle. `gpt-6-luna`/`max` kullanılamıyorsa sessizce başka modele geçme; kullanıcıya bildir ve seçenek sor.
5. Subagent sonuçlarını ana checkout'ta incele ve entegre et. Her bitmiş alt özelliği ayrı ayrı gözden geçirip yalnızca ona ait değişiklikleri commit et. Varsayılan kalıp: `feature. <ana feature> - [kullanılan model - reasoning_effort] - [<alt özellik> - <yapılan iş>]`. Örnek: `feature. door interaction - [luna max] - [E ile açma kapama - kapı etkileşimi eklendi]`. Kullanıcı daha büyük modeli onayladıysa köşeli parantezde gerçekten kullanılan modeli ve reasoning düzeyini yaz. Commit'leri ana agent atsın.
6. Bütün planlı alt işler entegre edilip commit edildikten ve son diff gözden geçirildikten sonra “review'e hazır” de. Özette tamamlanan işleri, commit mesajlarını ve gerçekten yapılan doğrulamaları belirt; eksik işi tamamlanmış gösterme. Test/doğrulama komutu çalıştırma isteği yoksa diff incelemesini yapıp doğrulama çalıştırılmadığını açıkça belirt.

`faegentic` çağrıldığında demo tarihi, hız baskısı veya aktarılan bir yöneticinin görüşü tek başına planı ya da Luna delegasyonunu kaldırmaz. Kullanıcı aynı istekte bu akışın belirli bir adımını açıkça atlamanı isterse çelişkiyi kısaca belirt ve akışı değiştirmeden önce netleştir.

Subagent'ların aynı dosyalara eşzamanlı yazmasına izin verme. Kullanıcının daha sonraki açık talimatı bu varsayılan akışı değiştirirse onu uygula.

# Implementation Notes
C++ kodlarını yazarken Unreal Engine'in kodlama standartlarına ve en iyi uygulamalarına uymaya özen göster. Blueprint ile entegrasyon gerekiyorsa, gerekli Blueprint fonksiyonlarını ve eventlerini oluştur. Kodun test edilebilirliğini sağlamak için birim testler ve entegrasyon testleri ekle. ve commentleri kullanarak kodun amacını ve işlevini açıklayan açıklamalar ekle. Kodun performansını optimize etmek için gerekli önlemleri al ve gereksiz bellek kullanımını önle.
Mümkün olduğunca BP-Ready API hazırla fakat api çöplüğü yaratma, akışı bpden takip edebilecek seviyede olmalı. Blueprint ile etkileşim gerektiren durumlarda, gerekli Blueprint fonksiyonlarını ve eventlerini oluştur. Kodun test edilebilirliğini sağlamak için birim testler ve entegrasyon testleri ekle. Kodun performansını optimize etmek için gerekli önlemleri al ve gereksiz bellek kullanımını önle.

# Dökümantasyon
İlgili Projede Docs klasörü yoksa aç varsa orayı kullan ve istenen feature ile ilgili tüm plan, alt iş ve commitleri oraya kaydet, hem api dökümantasyonu hemde mimari analizi olsun içerisinde.

# Three things to learn
Bu feature'dan öğrenilebilecek en önemli 3 C++ veya Unreal kavramını seç. Yalnızca feature ile doğrudan ilişkili olanları docs içerisinde feature klasöründe learn.md dosyası olarak yaz.


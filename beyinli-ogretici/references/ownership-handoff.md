# Feature ownership handoff

Feature entegrasyonu ve son diff incelemesinden sonra ana agent bu referansı kullanır. Kullanıcının kısa bir açıklamayla sistemi sürdürebilmesini sağla; genel C++ eğitimi veya fonksiyon kataloğu üretme. Gerçek dosya, sembol ve bağlantıları kullan; yapılmayan işi yapılmış gösterme.

## Önemli dosyalar

Feature'ı anlamak için gerekli dosyaları tıklanabilir yollarla ver; her birinin sorumluluğunu tek cümleyle açıkla. Boilerplate'i listeleme.

## Ana veri / execution akışı

Entry point'ten gameplay sonucuna kadar ana akışı kısa bir zincirle göster. Yalnız gerçek implementasyonda bulunan adımları kullan. Örnek biçim:

`Player interaction → InventoryComponent::TryAddItem() → C++ validation ve state değişimi → OnInventoryChanged → Blueprint/UI tepkisi`

Kullanıcının bağlayacağı veya henüz eksik olan adımı zincirde açıkça işaretle; her fonksiyonu açıklama.

## Blueprint integration

Önemli node, event/delegate veya property için ne yaptığını, Blueprint'in ne zaman kullandığını ve hangi sorumluluğun C++'ta kaldığını belirt. Kullanıcıya kalan Blueprint orchestration adımlarını ayrı, sıralı eylemler olarak ver. Blueprint'e yeni API açılmadıysa bunu kısaca söyle.

## Unreal C++ ve öğrenilecek kavramlar

Feature'da gerçekten kullanılan en fazla üç önemli C++/Unreal kavramını seç; uygulamadaki sembolü ve neden gerekli olduğunu göster. Lifecycle, delegates, reflection, UObject ownership/garbage collection veya replication gibi kavramları yalnız gerçekten kullanıldıklarında anlat.

Kullanıcının Java geçmişi biliniyorsa veya Java karşılaştırması istiyorsa yalnız Java'dan farklı veya şaşırtıcı noktaları kısa açıklamalarla ilişkilendir: pointer/reference, `const`, header/source, Unreal macro'ları, lifecycle ve delegate/listener farkları. Bu referans kullanıcının deneyimi hakkında yeni bir olgu varsaydırmaz. Temel programlama kavramlarını tekrar öğretme; öğrenme amacıyla implementasyonu yeniden yazdırma.

## Manuel Unreal Editor doğrulaması

Feature'a özel kısa gameplay testlerini ver. Her testte kullanıcı eylemi ve gözlenebilir beklenen sonuç bulunsun; feature'a bağlı başarısızlık/kenar durumlarını dahil et. Agent'ın yaptığı build veya otomatik test sonuçlarını ayrı belirt. Editor/PIE çalıştırılmadıysa bunu açık yaz; test tarifini başarılı test sonucu olarak sunma.

Teslim sonunda kod durumu, handoff durumu ve bekleyen gameplay kabulünü görünür kıl. Sonraki eylem, kullanıcıya kalan ilk somut Blueprint bağlantısı veya Editor testi olmalıdır.

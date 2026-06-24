import '../models/vendor.dart';

/// Seed data vendor dari informasi publik (Google Maps / Instagram).
/// Hanya mencantumkan: nama bisnis, kategori, kota, range harga umum, username IG.
final List<Vendor> seedVendors = [
  // === WEDDING ORGANIZER ===
  Vendor(id: '', name: 'Mosaic Wedding', category: VendorCategory.wo, city: 'Jakarta', priceRange: '30-80 juta', instagram: 'mosaicwedding'),
  Vendor(id: '', name: 'Elior Design', category: VendorCategory.wo, city: 'Jakarta', priceRange: '25-60 juta', instagram: 'elikiurniadesign'),
  Vendor(id: '', name: 'Jenius WO', category: VendorCategory.wo, city: 'Bandung', priceRange: '15-40 juta', instagram: 'jeniuswo'),
  Vendor(id: '', name: 'Bali Brides WO', category: VendorCategory.wo, city: 'Bali', priceRange: '40-100 juta', instagram: 'balibrides'),
  Vendor(id: '', name: 'Fedora WO', category: VendorCategory.wo, city: 'Surabaya', priceRange: '15-35 juta', instagram: 'fedorawo'),

  // === CATERING ===
  Vendor(id: '', name: 'Sriboga Catering', category: VendorCategory.catering, city: 'Jakarta', priceRange: '80-150rb/pax', instagram: 'sribogacatering'),
  Vendor(id: '', name: 'Sonokembang Catering', category: VendorCategory.catering, city: 'Surabaya', priceRange: '60-120rb/pax', instagram: 'sonokembangcatering'),
  Vendor(id: '', name: 'Nendia Primarasa', category: VendorCategory.catering, city: 'Bandung', priceRange: '70-130rb/pax', instagram: 'nendiaprimarasa'),
  Vendor(id: '', name: 'Mina Catering', category: VendorCategory.catering, city: 'Yogyakarta', priceRange: '50-100rb/pax', instagram: 'minacatering'),
  Vendor(id: '', name: 'Royal Catering Bali', category: VendorCategory.catering, city: 'Bali', priceRange: '90-160rb/pax', instagram: 'royalcateringbali'),

  // === DEKORASI ===
  Vendor(id: '', name: 'Lotus Design', category: VendorCategory.dekorasi, city: 'Jakarta', priceRange: '20-80 juta', instagram: 'lotusdesigndecor'),
  Vendor(id: '', name: 'Airy Designs', category: VendorCategory.dekorasi, city: 'Jakarta', priceRange: '30-100 juta', instagram: 'airydesigns'),
  Vendor(id: '', name: 'Steve Decor', category: VendorCategory.dekorasi, city: 'Bandung', priceRange: '15-50 juta', instagram: 'stevedecor'),
  Vendor(id: '', name: 'Bali Eve Decor', category: VendorCategory.dekorasi, city: 'Bali', priceRange: '25-70 juta', instagram: 'balievedecor'),
  Vendor(id: '', name: 'Flavor Decoration', category: VendorCategory.dekorasi, city: 'Surabaya', priceRange: '15-45 juta', instagram: 'flavordecoration'),

  // === FOTOGRAFER & VIDEOGRAFER ===
  Vendor(id: '', name: 'Axioo', category: VendorCategory.fotografer, city: 'Jakarta', priceRange: '30-80 juta', instagram: 'axioo'),
  Vendor(id: '', name: 'Antijitters Photo', category: VendorCategory.fotografer, city: 'Jakarta', priceRange: '20-50 juta', instagram: 'antijitters'),
  Vendor(id: '', name: 'Donawita Photography', category: VendorCategory.fotografer, city: 'Bandung', priceRange: '10-25 juta', instagram: 'donawitaphoto'),
  Vendor(id: '', name: 'Bali Pixtura', category: VendorCategory.fotografer, city: 'Bali', priceRange: '15-40 juta', instagram: 'balipixtura'),
  Vendor(id: '', name: 'Monoqrom Studio', category: VendorCategory.fotografer, city: 'Surabaya', priceRange: '10-30 juta', instagram: 'monoqrom'),

  // === MUA ===
  Vendor(id: '', name: 'Adi Adrian', category: VendorCategory.mua, city: 'Jakarta', priceRange: '15-50 juta', instagram: 'adiadrian'),
  Vendor(id: '', name: 'Marlene Hariman', category: VendorCategory.mua, city: 'Jakarta', priceRange: '20-60 juta', instagram: 'marlenehariman'),
  Vendor(id: '', name: 'Upan Duvan', category: VendorCategory.mua, city: 'Bandung', priceRange: '8-20 juta', instagram: 'upanduvan'),
  Vendor(id: '', name: 'Elly Bali MUA', category: VendorCategory.mua, city: 'Bali', priceRange: '10-25 juta', instagram: 'ellybalimua'),
  Vendor(id: '', name: 'Dian MUA Surabaya', category: VendorCategory.mua, city: 'Surabaya', priceRange: '5-15 juta', instagram: 'dianmuasby'),

  // === VENUE ===
  Vendor(id: '', name: 'The Ritz-Carlton Jakarta', category: VendorCategory.venue, city: 'Jakarta', priceRange: '200-500 juta', instagram: 'ritzcarltonjkt'),
  Vendor(id: '', name: 'Ayana Midplaza', category: VendorCategory.venue, city: 'Jakarta', priceRange: '150-350 juta', instagram: 'aaborubudur'),
  Vendor(id: '', name: 'Padma Hotel Bandung', category: VendorCategory.venue, city: 'Bandung', priceRange: '80-200 juta', instagram: 'padmahotelbandung'),
  Vendor(id: '', name: 'AYANA Bali', category: VendorCategory.venue, city: 'Bali', priceRange: '200-600 juta', instagram: 'ayanaresort'),
  Vendor(id: '', name: 'Shangri-La Surabaya', category: VendorCategory.venue, city: 'Surabaya', priceRange: '100-300 juta', instagram: 'shangrila_sby'),

  // === MUSIK ===
  Vendor(id: '', name: 'All About Music', category: VendorCategory.musik, city: 'Jakarta', priceRange: '10-30 juta', instagram: 'allaboutmusic_id'),
  Vendor(id: '', name: 'Lemon Tree Entertainment', category: VendorCategory.musik, city: 'Jakarta', priceRange: '15-40 juta', instagram: 'lemontreemusic'),
  Vendor(id: '', name: 'Soul Music Entertainment', category: VendorCategory.musik, city: 'Bandung', priceRange: '8-20 juta', instagram: 'soulmusicentertainment'),

  // === UNDANGAN ===
  Vendor(id: '', name: 'Vanas Design', category: VendorCategory.undangan, city: 'Jakarta', priceRange: '5-20rb/pcs', instagram: 'vanasdesign'),
  Vendor(id: '', name: 'Membee Invitation', category: VendorCategory.undangan, city: 'Bandung', priceRange: '3-15rb/pcs', instagram: 'membeeinvitation'),
  Vendor(id: '', name: 'Honey Card', category: VendorCategory.undangan, city: 'Surabaya', priceRange: '4-12rb/pcs', instagram: 'honeycard.id'),
];

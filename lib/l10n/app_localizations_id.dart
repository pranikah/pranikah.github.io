// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Persiapan Nikah';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get timeline => 'Timeline';

  @override
  String get budget => 'Budget';

  @override
  String get vendor => 'Vendor';

  @override
  String get daysToGo => 'Hari Menuju Hari H';

  @override
  String get preparationProgress => 'Progress Persiapan';

  @override
  String tasksCompleted(Object completed, Object total) {
    return '$completed dari $total tugas selesai';
  }

  @override
  String get budgetSummary => 'Ringkasan Budget';

  @override
  String get totalBudget => 'Total Budget';

  @override
  String get allocated => 'Dialokasi';

  @override
  String get spent => 'Terpakai';

  @override
  String get remaining => 'Sisa';

  @override
  String get upcomingTasks => 'Tugas Mendatang';

  @override
  String get allTasksDone => 'Semua tugas selesai! 🎉';

  @override
  String get statusNotStarted => 'Belum Mulai';

  @override
  String get statusInProgress => 'Sedang Proses';

  @override
  String get statusDone => 'Selesai';

  @override
  String get phase12Months => '12 Bulan Sebelum';

  @override
  String get phase6Months => '6 Bulan Sebelum';

  @override
  String get phase3Months => '3 Bulan Sebelum';

  @override
  String get phase1Month => '1 Bulan Sebelum';

  @override
  String get phase1Week => '1 Minggu Sebelum';

  @override
  String get priorityHigh => 'Tinggi';

  @override
  String get priorityMedium => 'Sedang';

  @override
  String get priorityLow => 'Rendah';

  @override
  String get addTask => 'Tambah Tugas';

  @override
  String get taskName => 'Nama tugas';

  @override
  String get phase => 'Fase';

  @override
  String get cancel => 'Batal';

  @override
  String get add => 'Tambah';

  @override
  String get save => 'Simpan';

  @override
  String get delete => 'Hapus';

  @override
  String get noTasks => 'Belum ada tugas';

  @override
  String get tasksAppearAfterSetup => 'Tugas akan muncul setelah setup selesai';

  @override
  String get editProfile => 'Edit Profil';

  @override
  String get groomName => 'Nama Calon Suami';

  @override
  String get brideName => 'Nama Calon Istri';

  @override
  String get weddingDate => 'Tanggal Pernikahan';

  @override
  String get selectDate => 'Pilih tanggal';

  @override
  String get startDate => 'Mulai Persiapan';

  @override
  String get totalBudgetLabel => 'Total Budget';

  @override
  String preparationDuration(Object days) {
    return 'Durasi persiapan: $days hari';
  }

  @override
  String get startPreparation => 'Mulai Persiapan';

  @override
  String get completeAllData => 'Lengkapi semua data';

  @override
  String get editTotalBudget => 'Edit Total Budget';

  @override
  String get budgetAllocated => 'Budget Dialokasi';

  @override
  String get actualCost => 'Biaya Aktual';

  @override
  String get premiumFeature => 'Fitur Premium';

  @override
  String get premiumDescription =>
      'Fitur ini tersedia untuk pengguna premium.\nHubungi admin untuk aktivasi setelah donasi.';

  @override
  String get loginWithGoogle => 'Login dengan Google';

  @override
  String loginFailed(Object error) {
    return 'Gagal login: $error';
  }

  @override
  String get noVendors => 'Belum ada vendor.';

  @override
  String get all => 'Semua';

  @override
  String get onboardingTitle1 => 'Persiapan Nikah';

  @override
  String get onboardingDesc1 =>
      'Rencanakan pernikahan impianmu dengan mudah. Semua yang kamu butuhkan dalam satu aplikasi.';

  @override
  String get onboardingTitle2 => 'Timeline & Checklist';

  @override
  String get onboardingDesc2 =>
      'Pantau setiap tahapan persiapan dari 12 bulan hingga H-1. Tidak ada yang terlewat.';

  @override
  String get onboardingTitle3 => 'Kelola Budget';

  @override
  String get onboardingDesc3 =>
      'Atur anggaran pernikahan dengan detail. Tahu persis berapa yang sudah dan belum dikeluarkan.';

  @override
  String get onboardingTitle4 => 'Fitur Premium';

  @override
  String get onboardingDesc4 =>
      'Akses fitur lanjutan seperti analitik budget, rekomendasi vendor, dan template undangan.';

  @override
  String get skip => 'Lewati';

  @override
  String get next => 'Lanjut';

  @override
  String get getStarted => 'Mulai';

  @override
  String get taskDetermBudget => 'Tentukan budget keseluruhan';

  @override
  String get taskFindVenue => 'Cari dan booking venue';

  @override
  String get taskGuestList => 'Buat daftar tamu undangan';

  @override
  String get taskFindWO => 'Cari wedding organizer';

  @override
  String get taskBookCatering => 'Pilih dan booking vendor catering';

  @override
  String get taskDecorVendor => 'Pilih vendor dekorasi';

  @override
  String get taskBookPhotographer => 'Booking fotografer & videografer';

  @override
  String get taskInvitationDesign => 'Pilih desain undangan';

  @override
  String get taskFittingDress => 'Fitting baju pengantin';

  @override
  String get taskPrewedding => 'Sesi foto prewedding';

  @override
  String get taskSendInvitations => 'Kirim undangan';

  @override
  String get taskMarriageDocs => 'Urus dokumen pernikahan';

  @override
  String get taskConfirmVendors => 'Konfirmasi semua vendor';

  @override
  String get taskFinalFitting => 'Fitting baju final';

  @override
  String get taskRundown => 'Rundown acara detail';

  @override
  String get taskTechMeeting => 'Technical meeting vendor';

  @override
  String get taskSeserahan => 'Persiapan seserahan/hantaran';

  @override
  String get taskRehearsal => 'Rehearsal & doa bersama';
}

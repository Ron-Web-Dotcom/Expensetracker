import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// Service for managing localization and formatting
class LocaleService {
  static const String _localeKey = 'app_locale';

  /// Get current locale from settings
  Future<Locale> getCurrentLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final language = prefs.getString('selected_language') ?? 'English (US)';
    return _getLocaleFromLanguage(language);
  }

  /// Convert language string to Locale
  Locale _getLocaleFromLanguage(String language) {
    switch (language) {
      case 'English (US)':
        return const Locale('en', 'US');
      case 'Spanish':
        return const Locale('es', 'ES');
      case 'French':
        return const Locale('fr', 'FR');
      case 'German':
        return const Locale('de', 'DE');
      case 'Chinese':
        return const Locale('zh', 'CN');
      case 'Japanese':
        return const Locale('ja', 'JP');
      default:
        return const Locale('en', 'US');
    }
  }

  /// Format currency based on locale and currency setting
  Future<String> formatCurrency(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    final currency =
        prefs.getString('selected_currency') ?? 'USD - United States Dollar';
    final currencyCode = currency.split(' - ')[0];
    final locale = await getCurrentLocale();

    final formatter = NumberFormat.currency(
      locale: locale.toString(),
      symbol: _getCurrencySymbol(currencyCode),
      decimalDigits: 2,
    );

    return formatter.format(amount);
  }

  /// Format number based on locale and number format setting
  Future<String> formatNumber(double number) async {
    final prefs = await SharedPreferences.getInstance();
    final numberFormat =
        prefs.getString('selected_number_format') ?? '1,000.00';

    NumberFormat formatter;
    if (numberFormat == '1.000,00') {
      formatter = NumberFormat('#,##0.00', 'de_DE');
    } else if (numberFormat == '1 000.00') {
      formatter = NumberFormat('#,##0.00', 'fr_FR');
    } else {
      formatter = NumberFormat('#,##0.00', 'en_US');
    }

    return formatter.format(number);
  }

  /// Format date based on date format setting
  Future<String> formatDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final dateFormat = prefs.getString('selected_date_format') ?? 'MM/DD/YYYY';

    String pattern;
    switch (dateFormat) {
      case 'DD/MM/YYYY':
        pattern = 'dd/MM/yyyy';
        break;
      case 'YYYY-MM-DD':
        pattern = 'yyyy-MM-dd';
        break;
      default:
        pattern = 'MM/dd/yyyy';
    }

    return DateFormat(pattern).format(date);
  }

  /// Get currency symbol from currency code
  String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'CAD':
        return 'CA\$';
      case 'AUD':
        return 'A\$';
      case 'INR':
        return '₹';
      default:
        return '\$';
    }
  }

  /// Get comprehensive translations for all app screens
  static Map<String, String> getTranslations(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return getTranslationsForLocale(locale.languageCode);
  }

  /// Get translations by language code (public method)
  static Map<String, String> getTranslationsForLocale(String languageCode) {
    switch (languageCode) {
      case 'es':
        return _spanishTranslations;
      case 'fr':
        return _frenchTranslations;
      case 'de':
        return _germanTranslations;
      case 'zh':
        return _chineseTranslations;
      case 'ja':
        return _japaneseTranslations;
      default:
        return {};
    }
  }

  /// Spanish translations
  static const Map<String, String> _spanishTranslations = {
    // Common
    'Settings': 'Configuración',
    'Cancel': 'Cancelar',
    'Save': 'Guardar',
    'Delete': 'Eliminar',
    'Edit': 'Editar',
    'Done': 'Hecho',
    'Back': 'Atrás',
    'Next': 'Siguiente',
    'Skip': 'Omitir',
    'Continue': 'Continuar',

    // Settings sections
    'SECURITY': 'SEGURIDAD',
    'ACCOUNT SETTINGS': 'CONFIGURACIÓN DE CUENTA',
    'NOTIFICATION PREFERENCES': 'PREFERENCIAS DE NOTIFICACIÓN',
    'APP PREFERENCES': 'PREFERENCIAS DE APLICACIÓN',
    'DATA MANAGEMENT': 'GESTIÓN DE DATOS',
    'SUPPORT & LEGAL': 'SOPORTE Y LEGAL',

    // Settings items
    'Biometric Authentication': 'Autenticación Biométrica',
    'Use fingerprint or face recognition':
        'Usar huella digital o reconocimiento facial',
    'Login Alerts': 'Alertas de Inicio de Sesión',
    'Get notified of login attempts':
        'Recibir notificaciones de intentos de inicio de sesión',
    'Login History': 'Historial de Inicio de Sesión',
    'View recent login attempts': 'Ver intentos recientes de inicio de sesión',
    'Change Password': 'Cambiar Contraseña',
    'Update your account password': 'Actualizar la contraseña de tu cuenta',
    'Currency': 'Moneda',
    'Date Format': 'Formato de Fecha',
    'Number Format': 'Formato de Número',
    'Delete Account': 'Eliminar Cuenta',
    'Permanently delete your account': 'Eliminar permanentemente tu cuenta',
    'Theme': 'Tema',
    'Choose your preferred theme': 'Elige tu tema preferido',
    'Language': 'Idioma',
    'Select your language': 'Selecciona tu idioma',
    'Default Category': 'Categoría Predeterminada',
    'Set default expense category':
        'Establecer categoría de gasto predeterminada',
    'Reset Tutorial': 'Restablecer Tutorial',
    'Show onboarding screens again':
        'Mostrar pantallas de bienvenida nuevamente',
    'Export Data': 'Exportar Datos',
    'Download your data as CSV': 'Descargar tus datos como CSV',
    'Help Center': 'Centro de Ayuda',
    'Get help and support': 'Obtener ayuda y soporte',
    'Privacy Policy': 'Política de Privacidad',
    'Read our privacy policy': 'Leer nuestra política de privacidad',
    'Terms of Service': 'Términos de Servicio',
    'Read our terms of service': 'Leer nuestros términos de servicio',
    'App Version': 'Versión de la Aplicación',

    // Theme options
    'Light': 'Claro',
    'Dark': 'Oscuro',
    'System': 'Sistema',

    // Dashboard
    'Dashboard': 'Panel',
    'Transactions': 'Transacciones',
    'Analytics': 'Análisis',
    'Budget': 'Presupuesto',
    'Add Expense': 'Agregar Gasto',
    'Monthly Spending': 'Gasto Mensual',
    'Recent Transactions': 'Transacciones Recientes',
    'Quick Actions': 'Acciones Rápidas',

    // Notifications
    'Budget Alerts': 'Alertas de Presupuesto',
    'Get notified when approaching budget limits':
        'Recibir notificaciones al acercarse a los límites del presupuesto',
    'Weekly Summary': 'Resumen Semanal',
    'Receive weekly spending summaries':
        'Recevoir resúmenes semanales de gastos',

    // Messages
    'Theme changed to': 'Tema cambiado a',
    'Language changed to': 'Idioma cambiado a',
    'Biometric authentication enabled': 'Autenticación biométrica habilitada',
    'Biometric authentication disabled':
        'Autenticación biométrica deshabilitada',
    'Login alerts enabled': 'Alertas de inicio de sesión habilitadas',
    'Login alerts disabled': 'Alertas de inicio de sesión deshabilitadas',
  };

  /// French translations
  static const Map<String, String> _frenchTranslations = {
    // Common
    'Settings': 'Paramètres',
    'Cancel': 'Annuler',
    'Save': 'Enregistrer',
    'Delete': 'Supprimer',
    'Edit': 'Modifier',
    'Done': 'Terminé',
    'Back': 'Retour',
    'Next': 'Suivant',
    'Skip': 'Passer',
    'Continue': 'Continuer',

    // Settings sections
    'SECURITY': 'SÉCURITÉ',
    'ACCOUNT SETTINGS': 'PARAMÈTRES DU COMPTE',
    'NOTIFICATION PREFERENCES': 'PRÉFÉRENCES DE NOTIFICATION',
    'APP PREFERENCES': 'PRÉFÉRENCES DE L\'APPLICATION',
    'DATA MANAGEMENT': 'GESTION DES DONNÉES',
    'SUPPORT & LEGAL': 'SUPPORT ET JURIDIQUE',

    // Settings items
    'Biometric Authentication': 'Authentification Biométrique',
    'Use fingerprint or face recognition':
        'Utiliser l\'empreinte digitale ou la reconnaissance faciale',
    'Login Alerts': 'Alertes de Connexion',
    'Get notified of login attempts':
        'Être notifié des tentatives de connexion',
    'Login History': 'Historique de Connexion',
    'View recent login attempts': 'Voir les tentatives de connexion récentes',
    'Change Password': 'Changer le Mot de Passe',
    'Update your account password':
        'Mettre à jour le mot de passe de votre compte',
    'Currency': 'Devise',
    'Date Format': 'Format de Date',
    'Number Format': 'Format de Nombre',
    'Delete Account': 'Supprimer le Compte',
    'Permanently delete your account': 'Supprimer définitivement votre compte',
    'Theme': 'Thème',
    'Choose your preferred theme': 'Choisissez votre thème préféré',
    'Language': 'Langue',
    'Select your language': 'Sélectionnez votre langue',
    'Default Category': 'Catégorie par Défaut',
    'Set default expense category':
        'Définir la catégorie de dépense par défaut',
    'Reset Tutorial': 'Réinitialiser le Tutoriel',
    'Show onboarding screens again': 'Afficher à nouveau les écrans d\'accueil',
    'Export Data': 'Exporter les Données',
    'Download your data as CSV': 'Télécharger vos données au format CSV',
    'Help Center': 'Centre d\'Aide',
    'Get help and support': 'Obtenir de l\'aide et du support',
    'Privacy Policy': 'Politique de Confidentialité',
    'Read our privacy policy': 'Lire notre politique de confidentialité',
    'Terms of Service': 'Conditions d\'Utilisation',
    'Read our terms of service': 'Lire nos conditions d\'utilisation',
    'App Version': 'Version de l\'Application',

    // Theme options
    'Light': 'Clair',
    'Dark': 'Sombre',
    'System': 'Système',

    // Dashboard
    'Dashboard': 'Tableau de Bord',
    'Transactions': 'Transactions',
    'Analytics': 'Analyses',
    'Budget': 'Budget',
    'Add Expense': 'Ajouter une Dépense',
    'Monthly Spending': 'Dépenses Mensuelles',
    'Recent Transactions': 'Transactions Récentes',
    'Quick Actions': 'Actions Rapides',

    // Notifications
    'Budget Alerts': 'Alertes de Budget',
    'Get notified when approaching budget limits':
        'Être notifié lors de l\'approche des limites du budget',
    'Weekly Summary': 'Résumé Hebdomadaire',
    'Receive weekly spending summaries':
        'Recevoir des résumés hebdomadaires des dépenses',

    // Messages
    'Theme changed to': 'Thème changé en',
    'Language changed to': 'Langue changée en',
    'Biometric authentication enabled': 'Authentification biométrique activée',
    'Biometric authentication disabled':
        'Authentification biométrique désactivée',
    'Login alerts enabled': 'Alertes de connexion activées',
    'Login alerts disabled': 'Alertes de connexion désactivées',
  };

  /// German translations
  static const Map<String, String> _germanTranslations = {
    // Common
    'Settings': 'Einstellungen',
    'Cancel': 'Abbrechen',
    'Save': 'Speichern',
    'Delete': 'Löschen',
    'Edit': 'Bearbeiten',
    'Done': 'Fertig',
    'Back': 'Zurück',
    'Next': 'Weiter',
    'Skip': 'Überspringen',
    'Continue': 'Fortfahren',

    // Settings sections
    'SECURITY': 'SICHERHEIT',
    'ACCOUNT SETTINGS': 'KONTOEINSTELLUNGEN',
    'NOTIFICATION PREFERENCES': 'BENACHRICHTIGUNGSEINSTELLUNGEN',
    'APP PREFERENCES': 'APP-EINSTELLUNGEN',
    'DATA MANAGEMENT': 'DATENVERWALTUNG',
    'SUPPORT & LEGAL': 'SUPPORT UND RECHTLICHES',

    // Settings items
    'Biometric Authentication': 'Biometrische Authentifizierung',
    'Use fingerprint or face recognition':
        'Fingerabdruck oder Gesichtserkennung verwenden',
    'Login Alerts': 'Anmeldewarnungen',
    'Get notified of login attempts':
        'Benachrichtigung über Anmeldeversuche erhalten',
    'Login History': 'Anmeldeverlauf',
    'View recent login attempts': 'Letzte Anmeldeversuche anzeigen',
    'Change Password': 'Passwort Ändern',
    'Update your account password': 'Ihr Kontopasswort aktualisieren',
    'Currency': 'Währung',
    'Date Format': 'Datumsformat',
    'Number Format': 'Zahlenformat',
    'Delete Account': 'Konto Löschen',
    'Permanently delete your account': 'Ihr Konto dauerhaft löschen',
    'Theme': 'Design',
    'Choose your preferred theme': 'Wählen Sie Ihr bevorzugtes Design',
    'Language': 'Sprache',
    'Select your language': 'Wählen Sie Ihre Sprache',
    'Default Category': 'Standardkategorie',
    'Set default expense category': 'Standard-Ausgabenkategorie festlegen',
    'Reset Tutorial': 'Tutorial Zurücksetzen',
    'Show onboarding screens again': 'Einführungsbildschirme erneut anzeigen',
    'Export Data': 'Daten Exportieren',
    'Download your data as CSV': 'Ihre Daten als CSV herunterladen',
    'Help Center': 'Hilfezentrum',
    'Get help and support': 'Hilfe und Unterstützung erhalten',
    'Privacy Policy': 'Datenschutzrichtlinie',
    'Read our privacy policy': 'Unsere Datenschutzrichtlinie lesen',
    'Terms of Service': 'Nutzungsbedingungen',
    'Read our terms of service': 'Unsere Nutzungsbedingungen lesen',
    'App Version': 'App-Version',

    // Theme options
    'Light': 'Hell',
    'Dark': 'Dunkel',
    'System': 'System',

    // Dashboard
    'Dashboard': 'Dashboard',
    'Transactions': 'Transaktionen',
    'Analytics': 'Analysen',
    'Budget': 'Budget',
    'Add Expense': 'Ausgabe Hinzufügen',
    'Monthly Spending': 'Monatliche Ausgaben',
    'Recent Transactions': 'Letzte Transaktionen',
    'Quick Actions': 'Schnellaktionen',

    // Notifications
    'Budget Alerts': 'Budgetwarnungen',
    'Get notified when approaching budget limits':
        'Benachrichtigung bei Annäherung an Budgetgrenzen',
    'Weekly Summary': 'Wöchentliche Zusammenfassung',
    'Receive weekly spending summaries':
        'Wöchentliche Ausgabenzusammenfassungen erhalten',

    // Messages
    'Theme changed to': 'Design geändert zu',
    'Language changed to': 'Sprache geändert zu',
    'Biometric authentication enabled':
        'Biometrische Authentifizierung aktiviert',
    'Biometric authentication disabled':
        'Biometrische Authentifizierung deaktiviert',
    'Login alerts enabled': 'Anmeldewarnungen aktiviert',
    'Login alerts disabled': 'Anmeldewarnungen deaktiviert',
  };

  /// Chinese translations
  static const Map<String, String> _chineseTranslations = {
    // Common
    'Settings': '设置',
    'Cancel': '取消',
    'Save': '保存',
    'Delete': '删除',
    'Edit': '编辑',
    'Done': '完成',
    'Back': '返回',
    'Next': '下一步',
    'Skip': '跳过',
    'Continue': '继续',

    // Settings sections
    'SECURITY': '安全',
    'ACCOUNT SETTINGS': '账户设置',
    'NOTIFICATION PREFERENCES': '通知偏好',
    'APP PREFERENCES': '应用偏好',
    'DATA MANAGEMENT': '数据管理',
    'SUPPORT & LEGAL': '支持与法律',

    // Settings items
    'Biometric Authentication': '生物识别认证',
    'Use fingerprint or face recognition': '使用指纹或面部识别',
    'Login Alerts': '登录提醒',
    'Get notified of login attempts': '获取登录尝试通知',
    'Login History': '登录历史',
    'View recent login attempts': '查看最近的登录尝试',
    'Change Password': '更改密码',
    'Update your account password': '更新您的账户密码',
    'Currency': '货币',
    'Date Format': '日期格式',
    'Number Format': '数字格式',
    'Delete Account': '删除账户',
    'Permanently delete your account': '永久删除您的账户',
    'Theme': '主题',
    'Choose your preferred theme': '选择您喜欢的主题',
    'Language': '语言',
    'Select your language': '选择您的语言',
    'Default Category': '默认类别',
    'Set default expense category': '设置默认支出类别',
    'Reset Tutorial': '重置教程',
    'Show onboarding screens again': '再次显示引导屏幕',
    'Export Data': '导出数据',
    'Download your data as CSV': '将您的数据下载为CSV',
    'Help Center': '帮助中心',
    'Get help and support': '获取帮助和支持',
    'Privacy Policy': '隐私政策',
    'Read our privacy policy': '阅读我们的隐私政策',
    'Terms of Service': '服务条款',
    'Read our terms of service': '阅读我们的服务条款',
    'App Version': '应用版本',

    // Theme options
    'Light': '浅色',
    'Dark': '深色',
    'System': '系统',

    // Dashboard
    'Dashboard': '仪表板',
    'Transactions': '交易',
    'Analytics': '分析',
    'Budget': '预算',
    'Add Expense': '添加支出',
    'Monthly Spending': '月度支出',
    'Recent Transactions': '最近交易',
    'Quick Actions': '快速操作',

    // Notifications
    'Budget Alerts': '预算提醒',
    'Get notified when approaching budget limits': '接近预算限制时获得通知',
    'Weekly Summary': '每周摘要',
    'Receive weekly spending summaries': '接收每周支出摘要',

    // Messages
    'Theme changed to': '主题已更改为',
    'Language changed to': '语言已更改为',
    'Biometric authentication enabled': '生物识别认证已启用',
    'Biometric authentication disabled': '生物识别认证已禁用',
    'Login alerts enabled': '登录提醒已启用',
    'Login alerts disabled': '登录提醒已禁用',
  };

  /// Japanese translations
  static const Map<String, String> _japaneseTranslations = {
    // Common
    'Settings': '設定',
    'Cancel': 'キャンセル',
    'Save': '保存',
    'Delete': '削除',
    'Edit': '編集',
    'Done': '完了',
    'Back': '戻る',
    'Next': '次へ',
    'Skip': 'スキップ',
    'Continue': '続ける',

    // Settings sections
    'SECURITY': 'セキュリティ',
    'ACCOUNT SETTINGS': 'アカウント設定',
    'NOTIFICATION PREFERENCES': '通知設定',
    'APP PREFERENCES': 'アプリ設定',
    'DATA MANAGEMENT': 'データ管理',
    'SUPPORT & LEGAL': 'サポートと法的事項',

    // Settings items
    'Biometric Authentication': '生体認証',
    'Use fingerprint or face recognition': '指紋または顔認識を使用',
    'Login Alerts': 'ログインアラート',
    'Get notified of login attempts': 'ログイン試行の通知を受け取る',
    'Login History': 'ログイン履歴',
    'View recent login attempts': '最近のログイン試行を表示',
    'Change Password': 'パスワード変更',
    'Update your account password': 'アカウントのパスワードを更新',
    'Currency': '通貨',
    'Date Format': '日付形式',
    'Number Format': '数値形式',
    'Delete Account': 'アカウント削除',
    'Permanently delete your account': 'アカウントを完全に削除',
    'Theme': 'テーマ',
    'Choose your preferred theme': '好みのテーマを選択',
    'Language': '言語',
    'Select your language': '言語を選択',
    'Default Category': 'デフォルトカテゴリ',
    'Set default expense category': 'デフォルトの支出カテゴリを設定',
    'Reset Tutorial': 'チュートリアルをリセット',
    'Show onboarding screens again': 'オンボーディング画面を再表示',
    'Export Data': 'データをエクスポート',
    'Download your data as CSV': 'データをCSVとしてダウンロード',
    'Help Center': 'ヘルプセンター',
    'Get help and support': 'ヘルプとサポートを取得',
    'Privacy Policy': 'プライバシーポリシー',
    'Read our privacy policy': 'プライバシーポリシーを読む',
    'Terms of Service': '利用規約',
    'Read our terms of service': '利用規約を読む',
    'App Version': 'アプリバージョン',

    // Theme options
    'Light': 'ライト',
    'Dark': 'ダーク',
    'System': 'システム',

    // Dashboard
    'Dashboard': 'ダッシュボード',
    'Transactions': '取引',
    'Analytics': '分析',
    'Budget': '予算',
    'Add Expense': '支出を追加',
    'Monthly Spending': '月間支出',
    'Recent Transactions': '最近の取引',
    'Quick Actions': 'クイックアクション',

    // Notifications
    'Budget Alerts': '予算アラート',
    'Get notified when approaching budget limits': '予算制限に近づいたときに通知を受け取る',
    'Weekly Summary': '週間サマリー',
    'Receive weekly spending summaries': '週間支出サマリーを受け取る',

    // Messages
    'Theme changed to': 'テーマを変更しました:',
    'Language changed to': '言語を変更しました:',
    'Biometric authentication enabled': '生体認証が有効になりました',
    'Biometric authentication disabled': '生体認証が無効になりました',
    'Login alerts enabled': 'ログインアラートが有効になりました',
    'Login alerts disabled': 'ログインアラートが無効になりました',
  };
}

/// Extension to easily get translated text
extension TranslationExtension on String {
  String tr(BuildContext context) {
    final translations = LocaleService.getTranslations(context);
    return translations[this] ?? this;
  }
}

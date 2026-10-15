// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Stylper';

  @override
  String get welcomeTagline => 'Мы помогаем людям найти свой стиль';

  @override
  String get signIn => 'Войти';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get skipForNow => 'Пропустить';

  @override
  String get signInTitle => 'С возвращением';

  @override
  String get signInSubtitle => 'Войдите в аккаунт, чтобы найти свой стиль';

  @override
  String get emailLabel => 'Электронная почта';

  @override
  String get emailHint => 'name@example.com';

  @override
  String get passwordLabel => 'Пароль';

  @override
  String get passwordHint => 'Введите пароль';

  @override
  String get showPassword => 'Показать пароль';

  @override
  String get hidePassword => 'Скрыть пароль';

  @override
  String get forgotPasswordLink => 'Забыли пароль?';

  @override
  String get orSignInWith => 'или войдите через';

  @override
  String get google => 'Google';

  @override
  String get apple => 'Apple';

  @override
  String noAccountPrompt(String link) {
    return 'Нет аккаунта? $link';
  }

  @override
  String get signUpLink => 'Зарегистрироваться';

  @override
  String get signUpSubtitle =>
      'Зарегистрируйтесь, чтобы открывать и настраивать свой уникальный стиль';

  @override
  String get confirmPasswordLabel => 'Повторите пароль';

  @override
  String get confirmPasswordHint => 'Введите пароль ещё раз';

  @override
  String termsAcceptance(String terms, String privacy) {
    return 'Я принимаю $terms и $privacy';
  }

  @override
  String get termsOfService => 'Условия использования';

  @override
  String get privacyPolicy => 'Политику конфиденциальности';

  @override
  String get orSignUpWith => 'или зарегистрируйтесь через';

  @override
  String haveAccountPrompt(String link) {
    return 'Уже есть аккаунт? $link';
  }

  @override
  String get signInLink => 'Войти';

  @override
  String get forgotPasswordTitle => 'Забыли пароль?';

  @override
  String get forgotPasswordSubtitle =>
      'Введите адрес электронной почты, и мы отправим ссылку для сброса пароля и восстановления доступа к аккаунту.';

  @override
  String get resetLinkHint =>
      'Защищённая ссылка для сброса пароля будет действовать 60 минут.';

  @override
  String get sendResetLink => 'Отправить ссылку';

  @override
  String resetLinkSent(String email) {
    return 'Мы отправили ссылку для сброса на $email. Проверьте почту.';
  }

  @override
  String backToSignIn(String link) {
    return 'Вернуться ко $link';
  }

  @override
  String get backToSignInLink => 'входу';

  @override
  String get back => 'Назад';

  @override
  String get profileSetupTitle => 'Настройте профиль';

  @override
  String get profileSetupSubtitle =>
      'Помогите нам подобрать рекомендации и размеры под ваш стиль';

  @override
  String get usernameLabel => 'Имя пользователя';

  @override
  String get usernameHint => '@your_username';

  @override
  String get genderLabel => 'Пол';

  @override
  String get genderMale => 'Мужской';

  @override
  String get genderFemale => 'Женский';

  @override
  String get ageLabel => 'Возраст';

  @override
  String get ageHint => 'напр. 24';

  @override
  String get heightLabel => 'Рост';

  @override
  String get heightHint => 'Рост в см';

  @override
  String get weightLabel => 'Вес';

  @override
  String get weightHint => 'Вес в кг';

  @override
  String get continueButton => 'Продолжить';

  @override
  String styleQuizTitle(String you) {
    return 'Одевайся как $you.';
  }

  @override
  String get styleQuizTitleEmphasis => 'ты';

  @override
  String likeThisOutfit(String outfit) {
    return 'Мне нравится этот $outfit';
  }

  @override
  String get likeThisOutfitEmphasis => 'образ...';

  @override
  String previousItem(String item) {
    return 'Предыдущий: $item';
  }

  @override
  String nextItem(String item) {
    return 'Следующий: $item';
  }

  @override
  String get topsCategory => 'верх';

  @override
  String get bottomsCategory => 'низ';

  @override
  String get homeForYou => 'Для вас';

  @override
  String get homeFollowing => 'Подписки';

  @override
  String get homeForYouTitle => 'Вдохновение на сегодня';

  @override
  String get homePeopleWearing => 'Что носят';

  @override
  String homeTrendingIn(String city) {
    return 'В тренде: $city';
  }

  @override
  String get retry => 'Повторить';

  @override
  String get comingSoon => 'Скоро';

  @override
  String get tabHome => 'Главная';

  @override
  String get tabSearch => 'Поиск';

  @override
  String get tabCreate => 'Новый пост';

  @override
  String get tabExplore => 'Обзор';

  @override
  String get tabProfile => 'Профиль';

  @override
  String get postOutfitDetails => 'Детали образа';

  @override
  String get postSimilar => 'Похожие';

  @override
  String get postShop => 'Купить';

  @override
  String get postAddToWardrobe => 'В гардероб';

  @override
  String get postSeeLooks => 'Образы';

  @override
  String get postSave => 'Сохранить';

  @override
  String postStyledCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count человек примерили это',
      few: '$count человека примерили это',
      one: '$count человек примерил это',
    );
    return '$_temp0';
  }

  @override
  String get postLike => 'Нравится';

  @override
  String get postComments => 'Комментарии';

  @override
  String get postShare => 'Поделиться';

  @override
  String get postMore => 'Ещё';

  @override
  String get signInToInteract =>
      'Войдите, чтобы ставить лайки и сохранять посты.';

  @override
  String get errorPostNotFound => 'Этот пост больше недоступен.';

  @override
  String get profilePlaceholderTitle => 'Ваш профиль скоро появится';

  @override
  String get profileGuestMessage => 'Вы просматриваете как гость.';

  @override
  String profileSignedInMessage(String name) {
    return 'Вы вошли как $name';
  }

  @override
  String get signOut => 'Выйти';

  @override
  String get errorInvalidCredentials => 'Неверная почта или пароль.';

  @override
  String get errorEmailInUse => 'Аккаунт с этой почтой уже существует.';

  @override
  String get errorWeakPassword =>
      'Слишком простой пароль. Используйте не менее 8 символов.';

  @override
  String get errorUserDisabled => 'Этот аккаунт заблокирован.';

  @override
  String get errorTooManyRequests => 'Слишком много попыток. Попробуйте позже.';

  @override
  String get errorNetwork =>
      'Нет подключения к интернету. Проверьте сеть и попробуйте снова.';

  @override
  String get errorProviderUnavailable => 'Этот способ входа пока недоступен.';

  @override
  String get errorUsernameTaken => 'Это имя пользователя уже занято.';

  @override
  String get errorUnknown => 'Что-то пошло не так. Попробуйте снова.';

  @override
  String get validationRequired => 'Обязательное поле.';

  @override
  String get validationEmail => 'Введите корректный адрес почты.';

  @override
  String validationPasswordLength(int min) {
    return 'Минимум $min символов.';
  }

  @override
  String get validationPasswordsMismatch => 'Пароли не совпадают.';

  @override
  String get validationUsername =>
      '3–20 символов: латинские буквы, цифры, _ или .';

  @override
  String validationNumberRange(int min, int max) {
    return 'Введите число от $min до $max.';
  }

  @override
  String get validationGender => 'Выберите вариант.';

  @override
  String get validationTerms =>
      'Примите Условия использования и Политику конфиденциальности.';
}

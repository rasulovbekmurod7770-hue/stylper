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
  String get checkEmailTitle => 'Проверьте почту';

  @override
  String checkEmailSubtitle(String email) {
    return 'Мы отправили ссылку для подтверждения на $email. Откройте её, чтобы активировать аккаунт, а затем войдите.';
  }

  @override
  String get checkEmailHint => 'Не видите письмо? Проверьте папку «Спам».';

  @override
  String get goToSignIn => 'Перейти ко входу';

  @override
  String wrongEmailPrompt(String link) {
    return 'Не тот адрес? $link';
  }

  @override
  String get signUpAgainLink => 'Зарегистрироваться заново';

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
  String get signInToPost => 'Войдите, чтобы поделиться своим образом.';

  @override
  String get signInToFollow => 'Войдите, чтобы подписываться на людей.';

  @override
  String get errorPostNotFound => 'Этот пост больше недоступен.';

  @override
  String get profileGuestMessage => 'Вы просматриваете как гость.';

  @override
  String get signOut => 'Выйти';

  @override
  String get errorInvalidCredentials => 'Неверная почта или пароль.';

  @override
  String get errorEmailNotConfirmed =>
      'Сначала подтвердите почту: откройте ссылку из нашего письма.';

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

  @override
  String get productTitle => 'Товар';

  @override
  String get productAvailableAt => 'Доступно на';

  @override
  String get productSaveToWardrobe => 'В гардероб';

  @override
  String get inWardrobe => 'В гардеробе';

  @override
  String get productBuyNow => 'Купить';

  @override
  String get productSeeItOnPeople => 'Как это носят';

  @override
  String get productSeeAllLooks => 'Все образы';

  @override
  String get productHowPeopleStyleIt => 'Как это сочетают';

  @override
  String get productSimilarStyle => 'Похожий стиль';

  @override
  String get productLooksTitle => 'Образы';

  @override
  String get productNoLooks => 'Пока нет образов';

  @override
  String get errorProductNotFound => 'Этот товар больше недоступен.';

  @override
  String get errorOpenStore => 'Не удалось открыть магазин.';

  @override
  String get postSaved => 'Сохранено';

  @override
  String get wardrobeAdded => 'Добавлено в гардероб';

  @override
  String get wardrobeRemoved => 'Удалено из гардероба';

  @override
  String get wardrobeTitle => 'Мой гардероб';

  @override
  String get wardrobeQuickScan => 'Сканировать';

  @override
  String get wardrobeAddNewItem => 'Добавить вещь';

  @override
  String get addItemTitle => 'Детали вещи';

  @override
  String get addItemSubtitle =>
      'В гардеробе её видите только вы. Отметьте её в посте — и все узнают, что это за вещь.';

  @override
  String get addItemName => 'Название';

  @override
  String get addItemNameHint => 'Например, серый кардиган';

  @override
  String get addItemBrand => 'Бренд';

  @override
  String get addItemBrandHint => 'Бренд или магазин, где купили';

  @override
  String get addItemCategory => 'Категория';

  @override
  String get addItemPrice => 'Цена';

  @override
  String get addItemOptional => 'Необязательно';

  @override
  String get addItemPriceHint => 'Например, 350 000';

  @override
  String get addItemPriceInvalid => 'Укажите цену больше 0';

  @override
  String get addItemSubmit => 'Добавить';

  @override
  String priceInSom(String amount) {
    return '$amount сум';
  }

  @override
  String get currencySom => 'сум';

  @override
  String postAddedBy(String name) {
    return 'Добавлено: $name';
  }

  @override
  String get wardrobeOuterwear => 'Верхняя одежда';

  @override
  String get wardrobeTops => 'Верх';

  @override
  String get wardrobeBottoms => 'Низ';

  @override
  String get wardrobeShoes => 'Обувь';

  @override
  String get wardrobeAccessories => 'Аксессуары';

  @override
  String get wardrobeEmpty =>
      'Здесь пока пусто. Сохраняйте вещи из постов и товаров.';

  @override
  String get wardrobeRemove => 'Удалить';

  @override
  String get profileEdit => 'Редактировать';

  @override
  String get profileMyWardrobe => 'Мой гардероб';

  @override
  String get profileFollow => 'Подписаться';

  @override
  String get profileFollowingButton => 'Вы подписаны';

  @override
  String get profileMessage => 'Написать';

  @override
  String get profileStyleDna => 'ДНК стиля';

  @override
  String get styleMinimal => 'Минимализм';

  @override
  String get styleCasual => 'Кэжуал';

  @override
  String get styleStreetwear => 'Стритвир';

  @override
  String get styleStreetwearShort => 'Стрит';

  @override
  String get styleNeutral => 'Нейтральный';

  @override
  String get styleOversized => 'Оверсайз';

  @override
  String get styleSmartCasual => 'Смарт-кэжуал';

  @override
  String get profileMyStyle => 'Мой стиль';

  @override
  String get profileStyle => 'Стиль';

  @override
  String get profileTabPosts => 'Посты';

  @override
  String get profileTabSaved => 'Сохранённое';

  @override
  String get profileTabStyleBoards => 'Доски стиля';

  @override
  String get profileNoPosts => 'Пока нет постов';

  @override
  String get profileNoSaved => 'Здесь появятся сохранённые посты';

  @override
  String get profileStyleBoardsSoon => 'Доски стиля скоро появятся';

  @override
  String get profileSettings => 'Настройки';

  @override
  String get editProfileTitle => 'Редактировать профиль';

  @override
  String get profileNameLabel => 'Имя';

  @override
  String get profileNameHint => 'Ваше имя';

  @override
  String get profileBioLabel => 'О себе';

  @override
  String get profileBioHint => 'Пара слов о вашем стиле';

  @override
  String get profileSave => 'Сохранить';

  @override
  String get settingsPrivacy => 'Конфиденциальность';

  @override
  String get settingsPrivateAccount => 'Закрытый аккаунт';

  @override
  String get settingsPrivateAccountHint =>
      'Ваши посты видят только подписчики.';

  @override
  String get settingsBrandFeatures => 'Бренды могут показывать мои посты';

  @override
  String get settingsBrandFeaturesHint =>
      'Для новых постов и только брендам, отмеченным в них.';

  @override
  String get settingsShowLikeCounts => 'Показывать число лайков';

  @override
  String get settingsNotifications => 'Уведомления';

  @override
  String get settingsNotifyBrandActivity => 'Активность брендов';

  @override
  String get settingsNotifyBrandActivityHint =>
      'Когда бренд показывает ваш пост или дарит вам награду.';

  @override
  String get settingsNotifyDrops => 'Новинки';

  @override
  String get settingsNotifyDropsHint =>
      'Новые вещи от брендов, на которые вы подписаны.';

  @override
  String get settingsSaveFailed =>
      'Не удалось сохранить изменение. Попробуйте ещё раз.';

  @override
  String get profileShare => 'Поделиться профилем';

  @override
  String get profileGuestTitle => 'Войдите, чтобы увидеть свой профиль';

  @override
  String get errorProfileNotFound => 'Этот профиль недоступен.';

  @override
  String productStyledBy(int count, String item) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count покупателей примерили: $item',
      few: '$count покупателя примерили: $item',
      one: '$count покупатель примерил: $item',
    );
    return '$_temp0';
  }

  @override
  String wardrobeItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count вещей',
      few: '$count вещи',
      one: '$count вещь',
      zero: 'Нет вещей',
    );
    return '$_temp0';
  }

  @override
  String profilePostsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'постов',
      few: 'поста',
      one: 'пост',
    );
    return '$_temp0';
  }

  @override
  String profileFollowersLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'подписчиков',
      few: 'подписчика',
      one: 'подписчик',
    );
    return '$_temp0';
  }

  @override
  String profileFollowingLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'подписок',
      few: 'подписки',
      one: 'подписка',
    );
    return '$_temp0';
  }

  @override
  String get filterAll => 'Все';

  @override
  String get cancel => 'Отмена';

  @override
  String get close => 'Закрыть';

  @override
  String get postingNext => 'Далее';

  @override
  String get postingNewPost => 'Новый пост';

  @override
  String get postingTagItems => 'Отметьте вещи';

  @override
  String postingTagLimit(int count) {
    return 'На одном фото можно отметить до $count вещей.';
  }

  @override
  String get postingDetails => 'Детали';

  @override
  String get postingPublish => 'Публикация';

  @override
  String get postingRecentPhotos => 'Недавние фото';

  @override
  String get postingAlbums => 'Альбомы';

  @override
  String get postingCameraRoll => 'Галерея';

  @override
  String get postingTakePhoto => 'Сделать фото';

  @override
  String get postingAllowAccessTitle => 'Разрешите доступ к фото';

  @override
  String get postingAllowAccessBody =>
      'Stylper показывает ваши фото, чтобы вы могли выбрать образ для поста. Можно и сделать новое фото.';

  @override
  String get postingOpenSettings => 'Открыть настройки';

  @override
  String get postingLimitedAccess => 'Вы открыли доступ к части фото.';

  @override
  String get postingManage => 'Изменить';

  @override
  String get postingNoPhotos => 'Фото пока нет';

  @override
  String get postingTapToTag => 'Нажмите на фото, чтобы отметить одежду';

  @override
  String get postingSearchHint => 'Бренд или вещь...';

  @override
  String get postingRecentTags => 'Недавние отметки';

  @override
  String get postingTip =>
      'Совет: отмечайте конкретные вещи, а не только бренд — так пост заметнее';

  @override
  String get postingNoResults => 'Ничего не найдено';

  @override
  String get postingRemoveTag => 'Удалить отметку';

  @override
  String get postingReadyToPublish => 'Готово к публикации!';

  @override
  String get postingCaption => 'Подпись';

  @override
  String get postingCaptionHint => 'Напишите подпись...';

  @override
  String get postingLocation => 'Место';

  @override
  String get postingLocationHint => 'Добавьте место';

  @override
  String get postingMentionedBrands => 'Упомянутые бренды';

  @override
  String get postingNoBrands => 'Отметьте вещи, чтобы упомянуть бренды';

  @override
  String get postingAllowBrandFeature => 'Разрешить брендам показывать пост';

  @override
  String get postingAllowBrandFeatureHint =>
      'Бренды смогут показать ваш образ в своём шоуруме';

  @override
  String get postingPublishCta => 'Опубликовать в Stylper';

  @override
  String get postingVisibleToEveryone => 'Пост увидят все';

  @override
  String get postingPublished => 'Ваш образ опубликован!';

  @override
  String get postingDiscardTitle => 'Удалить пост?';

  @override
  String get postingDiscardBody => 'Фото и отметки не сохранятся.';

  @override
  String get postingDiscard => 'Удалить';

  @override
  String get errorPublishInvalid =>
      'Не удалось опубликовать пост. Проверьте фото и отметки.';

  @override
  String postingItemsTagged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count вещей отмечено в образе',
      few: '$count вещи отмечены в образе',
      one: '$count вещь отмечена в образе',
      zero: 'Вещи не отмечены',
    );
    return '$_temp0';
  }

  @override
  String get searchHint => 'Поиск брендов и людей';

  @override
  String get searchBrandsOnStylper => 'Бренды на Stylper';

  @override
  String get searchBrands => 'Бренды';

  @override
  String get searchPeople => 'Люди';

  @override
  String get searchLocal => 'Местный';

  @override
  String get searchVerified => 'Официальный бренд';

  @override
  String get searchClear => 'Очистить поиск';

  @override
  String searchNoResults(String query) {
    return 'По запросу «$query» нет брендов и людей';
  }

  @override
  String searchBrandItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count товаров',
      few: '$count товара',
      one: '$count товар',
    );
    return '$_temp0';
  }
}

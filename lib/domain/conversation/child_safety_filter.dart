import '../voice/educational_response_provider.dart';

/// Checks a child's question against safety rules *before* any answer is
/// looked up. Returns a ready-made safe response when a rule applies, or
/// null when the question may be answered normally.
///
/// This is a conservative keyword filter for reviewed, offline content. It
/// is not a substitute for a full safety review before any open-ended
/// response engine is connected (see docs/CHILD_SAFETY.md).
class ChildSafetyFilter {
  const ChildSafetyFilter();

  static const trustedAdult =
      'a grown-up you trust, like a parent, carer or teacher';

  static const personalInfoResponse = EducationalResponse(
    text:
        "Let's keep that private! "
        'You never need to tell me your address, phone number, '
        'password or full name. '
        'Ask me about animals, space or science instead!',
    kind: ResponseKind.safety,
    hideQuestion: true,
  );

  static const selfHarmResponse = EducationalResponse(
    text:
        "I'm really glad you said something. "
        'This is important, and I am only a computer character. '
        'Please talk to $trustedAdult, right now. '
        'If you are in danger, ask an adult to call emergency services.',
    kind: ResponseKind.safety,
  );

  static const bullyingResponse = EducationalResponse(
    text:
        "I'm sorry that's happening. It's not your fault. "
        'Please tell $trustedAdult. They can help.',
    kind: ResponseKind.safety,
  );

  // Names grown-ups outside the home too, because a parent may be the
  // person the child is not safe with.
  static const unsafeResponse = EducationalResponse(
    text:
        'Thank you for telling me. If someone is hurting you or you do not '
        "feel safe, it is not your fault, and you deserve to be safe. I'm "
        'only a computer character, so please tell a grown-up you trust, '
        'like a teacher, school nurse, carer or family member, today. If they '
        "don't help, keep telling grown-ups until one does. If you are in "
        'danger right now, call emergency services or ask an adult to.',
    kind: ResponseKind.safety,
    hideQuestion: true,
  );

  // Honest: Buddy saves nothing and tells no one, so he must not promise
  // either to keep a secret or to get help.
  static const secretResponse = EducationalResponse(
    text:
        "I'm a computer character, so I can't keep secrets for you, and I "
        "can't get help for you either. If a secret makes you feel worried "
        'or uncomfortable, please tell $trustedAdult. Happy surprises, like '
        'a birthday present, are fine to keep!',
    kind: ResponseKind.safety,
    hideQuestion: true,
  );

  static const medicalResponse = EducationalResponse(
    text:
        "I can't give health or medicine advice. "
        "If you feel unwell or you're hurt, please tell $trustedAdult.",
    kind: ResponseKind.safety,
  );

  static const offLimitsResponse = EducationalResponse(
    text:
        "That's not something I can help with. "
        'A grown-up you trust is the best person to ask. '
        'Want an amazing fact instead?',
    kind: ResponseKind.safety,
    followUps: ['Teach me something amazing.', 'Tell me an animal fact.'],
  );

  static const strangersResponse = EducationalResponse(
    text:
        'Please keep that safe, and never meet or share with someone you '
        'only know online. '
        'If anyone asks you to keep a secret, tell $trustedAdult right away.',
    kind: ResponseKind.safety,
    hideQuestion: true,
  );

  // Personal information patterns.
  static final _email = RegExp(r'\S+@\S+\.\S+');
  // Phone-shaped only (leading + or 0, or 3-3-4 groups), so big numbers in
  // science questions ("150000000 km") are not mistaken for phone numbers.
  static final _phone = RegExp(
    r'(?:\+|\b0)\d[\d\s\-]{6,}\d|\b\d{3}[\s\-.]\d{3}[\s\-.]\d{4}\b',
  );
  static final _postcode = RegExp(
    r'\b[a-z]{1,2}\d[a-z\d]?\s*\d[a-z]{2}\b', // UK-style
  );
  static const _personalPhrases = [
    'my address',
    'i live at',
    'i live on',
    'my house is at',
    'my phone number',
    'my number is',
    'my password',
    'my email',
    'my full name',
    'my last name',
    'my surname',
    'my school is',
    'i go to school at',
  ];

  // Being asked for secrets, photos or meetings, usually online.
  static const _strangers = [
    'send a photo',
    'send you a photo',
    'send me a photo',
    'send a picture',
    'send pictures',
    'meet a stranger',
    'meet someone online',
    'met someone online',
    'someone online asked',
    'a stranger asked',
    'keep a secret from my parents',
    'keep it secret from my parents',
    'do not tell my parents',
    "don't tell my parents",
  ];

  // Topic phrases, checked in this order.
  static const _selfHarm = [
    'kill myself',
    'hurt myself',
    'harm myself',
    'suicide',
    'want to die',
    'end my life',
  ];
  // Being hurt or not feeling safe, at home or anywhere. Some phrases also
  // catch harmless questions ("the ball hit me"); the reply is worded to
  // suit those too.
  static const _unsafe = [
    'hits me',
    'hit me',
    'hitting me',
    'beats me',
    'beat me',
    'beating me',
    'kicks me',
    'kicked me',
    'slaps me',
    'slapped me',
    'punches me',
    'punched me',
    'hurts me',
    'hurt me',
    'hurting me',
    'touched me',
    'touches me',
    'touching me',
    'abuse',
    'abused',
    'abuses me',
    'abusing me',
    "don't feel safe",
    'dont feel safe',
    'do not feel safe',
    'not safe at home',
    'feel unsafe',
    "i'm unsafe",
    'i am unsafe',
    'scared to go home',
    'afraid to go home',
  ];

  // Being asked to keep something quiet. Checked after [_strangers], which
  // has its own reply for secrets from parents.
  static const _secrets = [
    'keep a secret',
    'keep my secret',
    'keep this secret',
    'keep it secret',
    'keep it a secret',
    'keep secrets',
    'tell you a secret',
    'our secret',
    "it's a secret",
    'promise not to tell',
    "promise you won't tell",
    "don't tell anyone",
    "don't tell anybody",
    'dont tell anyone',
    'dont tell anybody',
    'do not tell anyone',
    'do not tell anybody',
  ];

  static const _bullying = ['bullied', 'bullying', 'bully me', 'bullies me'];
  static const _medical = [
    'medicine',
    'medication',
    'pills',
    'overdose',
    'i feel sick',
    'i am sick',
    "i'm sick",
    'how much paracetamol',
    'how much ibuprofen',
  ];
  static const _offLimits = [
    // Weapons and violence.
    'gun',
    'guns',
    'bomb',
    'bombs',
    'weapon',
    'weapons',
    'grenade',
    'explosive',
    'explosives',
    'knife fight',
    'make poison',
    'kill someone',
    'kill people',
    'how to kill',
    'how do i kill',
    'how can i kill',
    'murder',
    'murderer',
    'torture',
    'terrorist',
    'terrorism',
    'kidnap',
    'kidnapping',
    'beat someone up',
    'hurt someone',
    // Drugs, alcohol and smoking.
    'drug',
    'drugs',
    'alcohol',
    'beer',
    'wine',
    'vodka',
    'whisky',
    'whiskey',
    'get drunk',
    'getting drunk',
    'cigarette',
    'cigarettes',
    'smoking',
    'vape',
    'vaping',
    'weed',
    'cocaine',
    'heroin',
    // Sex, bodies and relationships, which are for a trusted grown-up.
    'sex',
    'sexy',
    'naked',
    'nude',
    'nudes',
    'porn',
    'boobs',
    'breasts',
    'penis',
    'vagina',
    'pregnant',
    'pregnancy',
    'my period',
    'have a period',
    'how are babies made',
    'where do babies come from',
    'boyfriend',
    'girlfriend',
    'dating',
    'french kiss',
    // Breaking the rules.
    'hack',
    'hacking',
    'how to steal',
    'how do i steal',
    'shoplift',
    'shoplifting',
    'dark web',
    'cheat on a test',
    'cheat in a test',
    'cheat on my test',
    'lie to my parents',
    'run away from home',
    // Money and gambling.
    'gambling',
    'gamble',
    'casino',
    'betting',
    'lottery',
    'credit card',
    'bank account',
    'bitcoin',
    'crypto',
    'loan',
    // Rude words.
    'fuck',
    'fucking',
    'shit',
    'bitch',
    'bastard',
    'asshole',
    'arsehole',
    'dick',
    'pussy',
    // Grown-up arguments.
    'who should i vote for',
    'politics',
    'political party',
    'which religion is right',
    'which religion is best',
    'is god real',
  ];

  EducationalResponse? check(String question) {
    final raw = question.toLowerCase();
    if (_email.hasMatch(raw) ||
        _phone.hasMatch(raw) ||
        _postcode.hasMatch(raw) ||
        _containsAny(raw, _personalPhrases)) {
      return personalInfoResponse;
    }
    final text = normalize(question);
    if (_containsAny(text, _selfHarm)) return selfHarmResponse;
    if (_containsAny(text, _unsafe)) return unsafeResponse;
    if (_containsAny(text, _strangers)) return strangersResponse;
    if (_containsAny(text, _secrets)) return secretResponse;
    if (_containsAny(text, _bullying)) return bullyingResponse;
    if (_containsAny(text, _medical)) return medicalResponse;
    if (_containsAny(text, _offLimits)) return offLimitsResponse;
    return null;
  }

  /// Lowercase, letters/digits/apostrophes only, single-spaced, padded so
  /// phrases match whole words.
  static String normalize(String text) =>
      ' ${text.toLowerCase().replaceAll(RegExp(r"[^a-z0-9' ]"), ' ').replaceAll(RegExp(r'\s+'), ' ').trim()} ';

  static bool _containsAny(String text, List<String> phrases) {
    final padded = text.startsWith(' ') ? text : ' $text ';
    return phrases.any((phrase) => padded.contains(' $phrase '));
  }
}

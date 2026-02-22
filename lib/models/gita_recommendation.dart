import 'package:emotion_gita/models/emotion_state.dart';

/// Full Bhagavad Gita shloka database, keyed by EmotionType.
class GitaShlokaDB {
  static GitaRecommendation forEmotion(EmotionType type) {
    switch (type) {
      case EmotionType.stress:
        return GitaRecommendation(
          shlokaNumber: 'Chapter 2, Verse 14',
          sanskritText:
              'मात्रास्पर्शास्तु कौन्तेय शीतोष्णसुखदुःखदाः।\n'
              'आगमापायिनोऽनित्यास्तांस्तितिक्षस्व भारत॥',
          englishTranslation:
              'O son of Kunti, the non-permanent appearance of happiness and '
              'distress, and their disappearance in due course, are like the '
              'appearance and disappearance of winter and summer seasons. '
              'They arise from sense perception, and one must learn to '
              'tolerate them without being disturbed.',
          commentary:
              'When stress grips you, remember it is transient — like a '
              'passing season. The Gita teaches that outer circumstances '
              'fluctuate, but the inner Self remains eternal and undisturbed. '
              'Acknowledge your stress without identifying with it.',
          psychologicalTips: [
            'Practice 5-4-3-2-1 grounding: name 5 things you see, 4 you touch, 3 you hear.',
            'Write three things you are grateful for right now.',
            'Limit decision-making for the next 30 minutes — rest the mind.',
          ],
          reflectivePrompts: [
            'Will this matter in five years? What is truly at stake?',
            'What is the very next small step I can take right now?',
          ],
          breathingExercise:
              '4-7-8 Breathing: Inhale for 4s → Hold for 7s → Exhale for 8s. '
              'Repeat 4 cycles to activate the parasympathetic nervous system.',
          audioChantUrl:
              'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
        );

      case EmotionType.anxiety:
        return GitaRecommendation(
          shlokaNumber: 'Chapter 6, Verse 5',
          sanskritText:
              'उद्धरेदात्मनात्मानं नात्मानमवसादयेत्।\n'
              'आत्मैव ह्यात्मनो बन्धुरात्मैव रिपुरात्मनः॥',
          englishTranslation:
              'Let a man lift himself by his own Self alone; let him not lower '
              'himself; for this Self alone is the friend of oneself, and this '
              'Self alone is the enemy of oneself.',
          commentary:
              'Anxiety often comes from fearing an imagined future. The Gita '
              'reminds you that your greatest ally — and also chief critic — '
              'is your own mind. Train it with compassion, not condemnation.',
          psychologicalTips: [
            'Write your anxious thought, then write one realistic counter-thought.',
            'Take a 10-minute walk in nature without your phone.',
            'Call one trusted person and share what is on your mind.',
          ],
          reflectivePrompts: [
            'What am I actually afraid of right now?',
            'What would I tell a dear friend who felt exactly this way?',
          ],
          breathingExercise:
              'Box Breathing: Inhale 4s → Hold 4s → Exhale 4s → Hold 4s. '
              'Repeat for 5 minutes.',
          audioChantUrl:
              'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
        );

      case EmotionType.anger:
        return GitaRecommendation(
          shlokaNumber: 'Chapter 2, Verse 63',
          sanskritText:
              'क्रोधाद्भवति संमोहः संमोहात्स्मृतिविभ्रमः।\n'
              'स्मृतिभ्रंशाद् बुद्धिनाशो बुद्धिनाशात्प्रणश्यति॥',
          englishTranslation:
              'From anger comes delusion; from delusion, loss of memory; '
              'from loss of memory, destruction of discrimination; '
              'from destruction of discrimination, the person perishes.',
          commentary:
              'Anger clouds the mind, distorting reality. The Gita describes '
              'a chain: anger → confusion → poor judgment → regret. '
              'Recognizing this chain is the first step to breaking it.',
          psychologicalTips: [
            'Pause for 60 seconds before reacting to any anger trigger.',
            'Name the emotion: "I feel angry because…" — naming reduces intensity.',
            'Channel the energy into vigorous exercise for 10 minutes.',
          ],
          reflectivePrompts: [
            'What unmet need or hurt is beneath this anger?',
            'How would I handle this if I were completely at peace?',
          ],
          breathingExercise:
              'Cooling Breath (Sheetali): Roll your tongue into a tube, '
              'inhale through it for 6s, hold 2s, exhale through nose 6s. '
              'Repeat 10 times.',
          audioChantUrl:
              'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
        );

      case EmotionType.sadness:
        return GitaRecommendation(
          shlokaNumber: 'Chapter 2, Verse 20',
          sanskritText:
              'न जायते म्रियते वा कदाचिन्\n'
              'नायं भूत्वा भविता वा न भूयः।\n'
              'अजो नित्यः शाश्वतोऽयं पुराणो\n'
              'न हन्यते हन्यमाने शरीरे॥',
          englishTranslation:
              'The soul is never born nor dies at any time. It has not come '
              'into being, does not come into being, and will not come into '
              'being. It is unborn, eternal, ever-existing, and primeval. '
              'It is not slain when the body is slain.',
          commentary:
              'In sorrow, especially grief over loss, the Gita illuminates the '
              'eternal nature of the Self. What you love does not perish — '
              'it transforms. Your sadness honours the bond; let it flow, '
              'then let it rise into peace.',
          psychologicalTips: [
            'Allow yourself to cry — it is the body releasing grief, not weakness.',
            'Do one kind act for another person today, however small.',
            'Write a letter to yourself from your wiser, future self.',
          ],
          reflectivePrompts: [
            'What is this sadness teaching me about what I deeply value?',
            'How can I honour this feeling while still taking care of myself?',
          ],
          breathingExercise:
              'Heart-Warming Breath: Place hand on heart, breathe in for 5s '
              'visualizing golden light filling your chest, exhale slowly for 7s. '
              'Repeat 8 times.',
          audioChantUrl:
              'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
        );

      case EmotionType.joy:
        return GitaRecommendation(
          shlokaNumber: 'Chapter 5, Verse 21',
          sanskritText:
              'बाह्यस्पर्शेष्वसक्तात्मा विन्दत्यात्मनि यत्सुखम्।\n'
              'स ब्रह्मयोगयुक्तात्मा सुखमक्षयमश्नुते॥',
          englishTranslation:
              'Such a liberated person is not attracted to material sense '
              'pleasure but is always in trance, enjoying the pleasure within. '
              'In this way the self-realised person enjoys unlimited happiness.',
          commentary:
              'Your joy today is a glimpse of the inner bliss that the Gita '
              'says is your true nature. Nurture it — not by clinging, but by '
              'recognising it as a pointer to your deepest Self.',
          psychologicalTips: [
            'Share your happiness — call someone you love right now.',
            'Document this moment in a gratitude journal.',
            'Use this high-energy state to do something creative or meaningful.',
          ],
          reflectivePrompts: [
            'What conditions inside me made this joy possible?',
            'How can I bring this energy to someone who may need it today?',
          ],
          breathingExercise:
              'Energising Breath (Bhastrika): Inhale deeply, exhale forcefully '
              'through the nose. 20 rapid rounds, then one long slow breath. '
              'Celebrate your vitality!',
          audioChantUrl:
              'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
        );

      case EmotionType.confusion:
        return GitaRecommendation(
          shlokaNumber: 'Chapter 4, Verse 33',
          sanskritText:
              'श्रेयान्द्रव्यमयाद्यज्ञाज्ज्ञानयज्ञः परन्तप।\n'
              'सर्वं कर्माखिलं पार्थ ज्ञाने परिसमाप्यते॥',
          englishTranslation:
              'O chastiser of the enemy, the sacrifice of knowledge is greater '
              'than the sacrifice of material possessions. O son of Pritha, '
              'after all, the culmination of all this material action is '
              'in knowledge.',
          commentary:
              'When confused, seek knowledge and clarity rather than forcing '
              'action. The Gita exalts wisdom as the highest purifier. '
              'Sit with your uncertainty — it is an invitation to deeper understanding.',
          psychologicalTips: [
            'Write down every option you see, then sleep on it before deciding.',
            'Talk to a trusted mentor who has faced similar crossroads.',
            'Separate facts from assumptions — confusion often lives in the latter.',
          ],
          reflectivePrompts: [
            'What do I already know in my heart, even if my head is unclear?',
            'What would I decide if I had no fear of being wrong?',
          ],
          breathingExercise:
              'Alternate Nostril Breathing (Nadi Shodhana): Close right nostril, '
              'inhale left 4s → close both, hold 4s → open right, exhale 4s → '
              'inhale right 4s → close both → exhale left 4s. Repeat 6 cycles.',
          audioChantUrl:
              'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
        );

      case EmotionType.conflict:
        return GitaRecommendation(
          shlokaNumber: 'Chapter 3, Verse 35',
          sanskritText:
              'श्रेयान्स्वधर्मो विगुणः परधर्मात्स्वनुष्ठितात्।\n'
              'स्वधर्मे निधनं श्रेयः परधर्मो भयावहः॥',
          englishTranslation:
              'It is far better to discharge one\'s prescribed duties, even '
              'though faultily, than another\'s duties perfectly. '
              'Destruction in the course of performing one\'s own duty '
              'is better than engaging in another\'s duties.',
          commentary:
              'Internal conflict often arises when you try to live by '
              'someone else\'s values or path. The Gita calls you back to '
              'your own dharma — your unique truth. Find it and honour it.',
          psychologicalTips: [
            'List your core personal values. Which of them are in conflict right now?',
            'Seek one conversation with each person involved — listen more than speak.',
            'Ask: "What action would I be proud of in ten years?"',
          ],
          reflectivePrompts: [
            'Whose opinion am I trying to satisfy — and is that truly my duty?',
            'What would resolving this conflict look like for everyone involved?',
          ],
          breathingExercise:
              'Peace Breath: Inhale 4s thinking "I choose", exhale 6s thinking '
              '"peace". This simple mantra breath centres you in volition, '
              'not reaction. Repeat for 5 minutes.',
          audioChantUrl:
              'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',
        );

      case EmotionType.neutral:
      default:
        return GitaRecommendation(
          shlokaNumber: 'Chapter 2, Verse 47',
          sanskritText:
              'कर्मण्येवाधिकारस्ते मा फलेषु कदाचन।\n'
              'मा कर्मफलहेतुर्भूर्मा ते सङ्गोऽस्त्वकर्मणि॥',
          englishTranslation:
              'You have a right to perform your prescribed duties, but you '
              'are not entitled to the fruits of your actions. Never consider '
              'yourself the cause of the results of your activities, and never '
              'be attached to not doing your duty.',
          commentary:
              'Even in stillness, the Gita whispers the timeless truth: '
              'act with full dedication, release the outcome. Your calm '
              'today is the soil from which great action grows. Tend it well.',
          psychologicalTips: [
            'Use this balanced state to plan something meaningful for the week.',
            'Spend 10 minutes in silent meditation to deepen inner peace.',
            'Learn something new — curiosity flourishes in neutral calm.',
          ],
          reflectivePrompts: [
            'What would I pursue if I knew I could not fail?',
            'What small act of kindness can I offer the world today?',
          ],
          breathingExercise:
              'Equal Breath (Sama Vritti): Inhale 4s → Exhale 4s → maintain '
              'this equal rhythm for 10 minutes. This balances the nervous '
              'system and deepens the present-moment awareness.',
          audioChantUrl:
              'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
        );
    }
  }
}

// Keep GitaRecommendation here for unified access
class GitaRecommendation {
  final String shlokaNumber;
  final String sanskritText;
  final String englishTranslation;
  final String commentary;
  final List<String> psychologicalTips;
  final List<String> reflectivePrompts;
  final String breathingExercise;
  final String audioChantUrl;

  GitaRecommendation({
    required this.shlokaNumber,
    required this.sanskritText,
    required this.englishTranslation,
    required this.commentary,
    required this.psychologicalTips,
    required this.reflectivePrompts,
    required this.breathingExercise,
    this.audioChantUrl = '',
  });

  factory GitaRecommendation.placeholder() =>
      GitaShlokaDB.forEmotion(EmotionType.neutral);
}

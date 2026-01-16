-- ====================================================================
-- POPULATE ALL COMPETENCY RICH INSIGHTS FOR PDF REPORTS
-- ====================================================================
-- 
-- This script populates detailed, contextual insights for ALL competencies
-- at different performance levels (advanced, developing, foundational)
-- These insights are used to generate rich, personalized PDF reports
--
-- Date: 2025-08-12
-- ====================================================================

-- Clear existing data for clean population
TRUNCATE TABLE competency_rich_insights CASCADE;

-- Insert rich insights for ALL competencies
INSERT INTO competency_rich_insights (
    competency_area, framework, difficulty_level, performance_level,
    primary_insight, coaching_impact, key_observation, development_focus,
    practice_recommendation, growth_pathway, practical_application,
    supervision_focus, learning_approach, sort_order
) VALUES

-- ====================================================================
-- ACTIVE LISTENING INSIGHTS
-- ====================================================================

-- Active Listening - Advanced (80%+)
(
    'Active Listening', 'core', 'beginner', 'advanced',
    'Your active listening skills demonstrate exceptional coaching presence. You consistently create a safe, non-judgmental space where clients feel truly heard and understood. Your ability to listen beyond words—picking up on emotions, energy shifts, and unspoken concerns—elevates your coaching to a transformative level.',
    'This mastery of active listening enables you to facilitate profound client insights. Clients likely experience breakthrough moments as you reflect back not just what they say, but what they mean. Your listening creates the conditions for deep self-exploration and authentic change.',
    'You demonstrate the rare ability to hold silence comfortably, allowing clients the space to process and discover. Your listening is active yet unobtrusive, creating a powerful container for client growth.',
    'Focus on using your advanced listening skills to identify systemic patterns and organizational dynamics. Consider how you might apply these skills in team coaching or organizational consulting contexts.',
    'Experiment with somatic listening—tuning into what the client''s body language and energy are communicating. Practice reflecting these observations back: "I notice your energy shifted when you mentioned that project."',
    'Your next evolution involves teaching and mentoring others in this competency. Consider how you might model and transfer these skills to emerging coaches or use them in supervisor roles.',
    'In complex coaching scenarios, use your listening skills to identify recursive patterns—themes that appear across different contexts in the client''s life. This meta-level listening can unlock systemic change.',
    'In supervision, explore how your listening skills might have blind spots. Are there certain emotions or topics where your listening becomes less effective?',
    'Study advanced modalities like Focusing or Somatic Experiencing to deepen your embodied listening practices.',
    1
),

-- Active Listening - Developing (60-79%)
(
    'Active Listening', 'core', 'beginner', 'developing',
    'Your active listening skills show solid development with clear potential for growth. You grasp the fundamentals of attentive listening and demonstrate genuine interest in your clients'' experiences. The foundation is strong, and with focused practice, you can elevate this crucial competency.',
    'Your current listening level supports effective coaching conversations, though you may occasionally miss deeper emotional currents or subtle cues. Clients feel heard on a surface level, but there''s opportunity to create more profound connection and insight through deeper listening.',
    'You tend to listen well to content and facts, but may need to develop your capacity to hear emotions, values, and beliefs that underlie the client''s words. Your listening is functional but not yet transformative.',
    'Develop your capacity for "Level 2" listening—listening to the client rather than through your own filters. Practice setting aside your own agenda and assumptions to hear the client''s unique perspective.',
    'Practice the "pause and reflect" technique: After the client speaks, pause for 3 seconds before responding. Use this time to truly process what was said rather than formulating your next question.',
    'Work toward listening for themes and patterns across the conversation. Begin noting recurring words, emotions, or concerns that might indicate deeper issues worth exploring.',
    'In your next coaching sessions, challenge yourself to ask fewer questions and make more reflective observations. Try: "I''m hearing that trust is really important to you" rather than immediately asking another question.',
    'Seek feedback from a mentor on your listening presence. Are there moments when you appear distracted or when your own agenda interferes with hearing the client?',
    'Study the Co-Active Coaching model''s three levels of listening. Practice identifying which level you''re operating from moment to moment.',
    2
),

-- Active Listening - Foundational (0-59%)
(
    'Active Listening', 'core', 'beginner', 'foundational',
    'Active listening is the cornerstone of effective coaching, and this is an area requiring significant development. Currently, you may find yourself planning responses while the client speaks, or focusing more on your coaching agenda than the client''s actual needs. This is normal for developing coaches and represents an important growth opportunity.',
    'Limited listening skills can create missed opportunities in coaching. Clients may feel rushed, unheard, or sense that you''re following a script rather than responding to their unique situation. This can limit the depth and effectiveness of your coaching relationships.',
    'You may find yourself interrupting, offering advice, or jumping to solutions before fully understanding the client''s perspective. Your listening might be filtered through your own experiences rather than staying with the client''s reality.',
    'Start with the basics: Focus on being fully present without planning your next question. Practice summarizing what you hear before moving forward. Build the discipline of listening without judging or evaluating.',
    'Use the "mirror and confirm" technique: Reflect back exactly what you heard and ask "Did I get that right?" This ensures understanding and shows the client you''re truly listening.',
    'Begin by mastering the fundamentals: maintain appropriate eye contact, minimize distractions, and practice patience. Set a goal to speak less than 30% of the time in coaching sessions.',
    'Record practice sessions (with permission) and review them focusing solely on listening behaviors. Count interruptions, notice when you stop listening to plan questions, and identify missed opportunities to explore deeper.',
    'Work with a mentor to practice pure listening exercises. Have them speak for 5 minutes while you only listen, then reflect back what you heard without adding interpretation.',
    'Read "The Lost Art of Listening" by Michael Nichols. Practice mindfulness meditation to develop presence and reduce mental chatter during conversations.',
    3
),

-- ====================================================================
-- POWERFUL QUESTIONS INSIGHTS
-- ====================================================================

-- Powerful Questions - Advanced (80%+)
(
    'Powerful Questions', 'core', 'beginner', 'advanced',
    'Your questioning technique represents mastery-level coaching artistry. You possess the rare ability to craft questions that slice through surface narratives and illuminate the deeper truths beneath. Your questions create profound "aha moments" and consistently catalyze breakthrough insights that clients remember long after sessions end. You demonstrate exquisite timing - knowing when to probe deeper, when to pause, and when to shift perspective through skillful inquiry.',
    'Your sophisticated questioning ability transforms lives. Clients frequently experience paradigm shifts and deep revelations because your questions access wisdom they didn''t know they possessed. You create safety for exploration of difficult territory while maintaining gentle pressure toward growth. Your questions become catalysts for sustainable change, helping clients develop new neural pathways and ways of thinking that serve them far beyond coaching.',
    'You demonstrate exceptional skill in asking questions that emerge spontaneously from deep listening rather than formulaic approaches. Your questions feel effortless yet profound, simple yet multi-layered. You intuitively know how to follow the client''s energy and ask questions that unlock their specific patterns and blocks.',
    'Expand into systemic and organizational questioning techniques. Your mastery positions you to work with complex adaptive systems, team dynamics, and organizational transformation. Consider how your questioning skills might serve leadership development, team coaching, or organizational consulting contexts where multiple perspectives and stakeholders are involved.',
    'Experiment with emergent questioning techniques that access different ways of knowing. Try somatic questions: "What does your body know about this decision?" Metaphorical questions: "If this challenge were a landscape, what would you see?" Future-focused questions: "When you''ve successfully navigated this, what will you notice first?" Practice questions that work with paradox and polarities.',
    'Your evolution involves becoming a teacher and mentor of this competency. Consider developing signature questioning methodologies or writing about the art of powerful inquiry. You''re positioned to contribute to the field through training other coaches, developing assessment tools, or creating questioning frameworks that others can learn from.',
    'In complex coaching scenarios, use meta-questioning to work with the client''s thinking patterns themselves. Ask questions about their questions, explore their assumptions about problem-solving, and help them develop their own capacity for self-inquiry. Focus on questions that reveal blind spots and unconscious competencies.',
    'Explore the edge cases where your questioning might be too sophisticated for certain clients. How do you calibrate question complexity to client readiness? Examine whether your mastery might sometimes intimidate rather than empower. Consider your own attachment to "powerful" questions versus simple curiosity.',
    'Study advanced modalities like Clean Language, Appreciative Inquiry, or Systemic Coaching approaches. Consider training in therapeutic questioning techniques, philosophical inquiry methods, or organizational development questioning frameworks. Your learning edge involves integration across disciplines.',
    4
),

-- Powerful Questions - Developing (60-79%)
(
    'Powerful Questions', 'core', 'beginner', 'developing',
    'Your questioning skills demonstrate solid competency with clear potential for breakthrough to the next level. You consistently ask relevant, thoughtful questions that move conversations forward and support client exploration. While you grasp the fundamentals of powerful inquiry, you sometimes rely on familiar question patterns rather than responding spontaneously to the unique energy and needs of each moment. Your questions are functional and helpful, creating a foundation for growth into more intuitive and transformational questioning.',
    'Your questions create meaningful dialogue and often lead to valuable insights for clients. They feel heard and guided through your thoughtful inquiry, though the questioning might sometimes feel structured rather than deeply emergent. Clients appreciate your curiosity and find your questions helpful for gaining clarity, though breakthrough moments may be less frequent than with more advanced questioning techniques.',
    'You demonstrate competence in asking "what" and "how" questions that gather information and support exploration. However, you may need to develop greater comfort with questions that probe emotional territory, challenge assumptions, or invite clients into unknown territory. Your questioning tends to be cognitive rather than somatic or intuitive.',
    'Transition from information-gathering questions toward questions that facilitate discovery and transformation. Practice questions that help clients access their inner wisdom rather than just organizing their thinking. Develop comfort with questions that might temporarily destabilize or challenge clients in service of their growth.',
    'Before asking your next question, pause and sense what this client most needs to discover right now. Let this intuitive sense guide your question rather than following a logical sequence. Practice questions that begin with: "What if...?" "How might...?" "What would it mean if...?" Notice the difference in client responses when you ask from curiosity versus agenda.',
    'Develop greater tolerance for silence after asking questions. Many developing coaches rush to fill space or ask follow-up questions too quickly. Practice letting powerful questions land and reverberate. Begin to notice which of your questions generate the deepest client insights and replicate those patterns.',
    'During your next three coaching sessions, focus entirely on question quality over quantity. Challenge yourself to ask fewer but more impactful questions. After each session, review: Which question led to the client''s biggest insight? What made that question different from your others?',
    'Work with a mentor to review recordings of your sessions, focusing exclusively on your questions. Identify patterns in your questioning style. What types of questions do you avoid? When do you default to advice-giving disguised as questions? Practice reformulating advice as genuine inquiry.',
    'Study the distinction between powerful questions and leading questions. Read "The Art of Powerful Questions" and practice question construction exercises. Develop skills in different questioning approaches: appreciative, clean language, solution-focused, and systemic questioning techniques.',
    5
),

-- Powerful Questions - Foundational (0-59%)
(
    'Powerful Questions', 'core', 'beginner', 'foundational',
    'Developing the capacity for powerful questioning represents one of your most important growth opportunities as a coach. Currently, your questions may inadvertently direct clients toward predetermined solutions, seek to confirm your own hypotheses, or be disguised advice-giving. You might find yourself asking leading questions, compound questions that confuse rather than clarify, or "why" questions that put clients in defensive or analytical modes. This pattern is completely normal for developing coaches and represents rich territory for skill development.',
    'Your current questioning approach may create subtle dependency patterns where clients look to you for direction rather than developing their own insight-generating capacity. Questions that contain implicit advice or solutions can undermine client empowerment and reduce the transformational potential of coaching conversations. This can limit client ownership of insights and reduce the sustainability of coaching outcomes.',
    'You likely find yourself asking multiple questions in succession without allowing processing time, or asking questions that arise from your own curiosity or agenda rather than the client''s emerging needs. Your questions may be more focused on gathering information than facilitating discovery, and you might struggle to tolerate the silence that follows truly powerful questions.',
    'Begin with the foundation: learning to ask one clear, open-ended question at a time. Focus on developing genuine curiosity about your client''s inner world rather than trying to solve their problems through questioning. Practice the discipline of asking questions that you genuinely don''t know the answer to.',
    'Implement the "one question rule" rigorously: Ask one clear question, then remain completely silent until the client finishes their response. Count to five after they stop speaking before asking another question. Practice basic discovery questions: "What''s most important to you about this?" "How are you feeling about that?" "What would you like to explore?"',
    'Master the fundamentals before attempting sophisticated techniques. Focus on asking clean, simple questions that begin with "what" or "how" rather than "why." Learn to recognize when you''re about to give advice and practice converting those impulses into genuine questions. Develop comfort with not knowing where questions will lead.',
    'Record practice sessions and review them with a focus on question quality. Count how many questions you ask versus statements you make. Identify moments where you asked leading questions or gave advice disguised as questions. Practice reformulating these as clean, open inquiries.',
    'Work intensively with a mentor on question formation. Role-play scenarios where you practice asking only clean, curious questions without any agenda. Have your mentor interrupt you whenever you slip into advice-giving or leading questions. Practice recovering from question "mistakes" gracefully.',
    'Study the fundamental principles of powerful questioning. Read "The Coaching Habit" by Michael Bungay Stanier for practical frameworks. Take a course specifically focused on questioning skills. Practice with the ICF Core Competency framework and study examples of masterful coaching questions.',
    6
),

-- ====================================================================
-- PRESENT MOMENT AWARENESS INSIGHTS
-- ====================================================================

-- Present Moment Awareness - Advanced (80%+)
(
    'Present Moment Awareness', 'core', 'beginner', 'advanced',
    'Your present moment awareness represents a rare and profound coaching gift. You consistently create a field of presence so palpable that clients often comment on feeling immediately calmer and more centered in your company. Your exquisite attunement to subtle energetic shifts, micro-expressions, breathing patterns, and emotional undercurrents enables you to track what''s happening beneath the surface of conversations. This embodied presence becomes a powerful intervention in itself, creating safety for clients to access deeper truths and authentic feelings.',
    'Your advanced presence creates transformational coaching experiences. Clients feel truly seen and met at their deepest level, enabling them to access parts of themselves they may have never shared with another person. Your presence creates the conditions for profound healing, insight, and growth. Clients often experience somatic releases, emotional breakthroughs, and access to inner wisdom simply through being witnessed with such quality attention.',
    'You demonstrate masterful ability to track multiple levels of experience simultaneously - cognitive content, emotional undercurrents, somatic shifts, energetic changes, and relational dynamics. Your presence is simultaneously spacious and focused, allowing you to hold complexity without becoming overwhelmed or losing your center.',
    'Explore applications of your presence in systemic and organizational contexts. Your advanced awareness positions you for group facilitation, team coaching, and organizational transformation work where tracking collective energy and group dynamics becomes crucial. Consider how your presence might serve conflict resolution, leadership development, or community healing work.',
    'Experiment with explicitly sharing your moment-to-moment awareness: "I''m noticing your breathing has shifted," "There''s a quality of stillness that just entered the room," "I sense something wants to be said that hasn''t been spoken yet." Practice using your somatic awareness as a coaching intervention, helping clients connect with their own embodied experience.',
    'Your mastery positions you for leadership in presence-based coaching approaches. Consider advanced training in somatic coaching, mindfulness-based interventions, or body-oriented therapeutic modalities. You''re positioned to teach presence to other coaches, develop mindfulness-based coaching programs, or contribute to the integration of contemplative practices in professional development.',
    'Use your present moment awareness to track patterns across sessions and over time. Notice how a client''s energy signature changes as they grow. Pay attention to your own energetic responses as information about the client''s system. Practice using presence as a form of systemic assessment - what does this person''s nervous system tell you about their life circumstances?',
    'Explore the boundaries and ethics of presence-based coaching. How do you work with the intimate information that emerges through somatic awareness? Examine counter-transference and projection - how do you distinguish between client material and your own responses? Consider how your advanced sensitivity might sometimes be overwhelming for certain clients.',
    'Deepen your understanding through advanced somatic and mindfulness-based training. Study modalities like Hakomi, Somatic Experiencing, Focusing, or Mindfulness-Based Stress Reduction. Consider training in trauma-informed approaches given the depth of material that your presence tends to evoke.',
    7
),

-- Present Moment Awareness - Developing (60-79%)
(
    'Present Moment Awareness', 'core', 'beginner', 'developing',
    'Your present moment awareness is developing well, with increasing capacity to stay attuned to what''s happening in real-time during coaching conversations. You notice obvious shifts in client energy and can generally maintain presence when conversations flow smoothly. However, you may find your awareness fragmenting when faced with challenging coaching moments, difficult emotions, or your own performance anxiety. Your developing presence creates good connection with clients, though you sometimes miss subtler cues that could deepen the coaching experience.',
    'Your growing presence supports meaningful coaching relationships and enables clients to feel seen and heard. You catch significant emotional shifts and energy changes, which allows you to respond appropriately to client needs. However, opportunities for deeper impact may be missed when your attention gets pulled into planning your next intervention or analyzing the client''s situation rather than staying with immediate experience.',
    'You tend to maintain good presence when feeling confident and connected, but may lose awareness when encountering unfamiliar territory, strong emotions, or moments of not knowing how to proceed. Your attention might default to problem-solving mode rather than staying with whatever is emerging in the present moment.',
    'Practice returning to presence when you notice your mind has wandered into planning, analyzing, or judging. Develop skills for staying grounded during emotionally charged moments or when clients share difficult material. Learn to use your own nervous system as a barometer for what''s happening in the coaching relationship.',
    'Use breath awareness as an anchor to the present moment. Take one conscious breath between client statements to center yourself and return to presence. Practice the "STOP" technique: Stop, Take a breath, Observe what''s happening right now, Proceed with awareness. Notice your tendency to leave the present moment and gently return without self-judgment.',
    'Develop comfort with naming what you''re noticing in real-time: "I notice some tension in the room right now," "Something shifted when you mentioned your boss," "I''m aware of feeling moved by what you just shared." Practice distinguishing between your own emotional responses and information about the client''s system.',
    'Set an intention to make at least one "here and now" observation per coaching session. Practice tracking your own presence throughout sessions - notice when you''re truly present versus when you''re in your head. Experiment with using silence as a tool for deepening presence rather than filling space with words.',
    'Identify your specific triggers for leaving the present moment. What client behaviors, emotions, or coaching challenges consistently pull you into mental activity? Work with a supervisor to practice staying present during these triggering moments.',
    'Establish a consistent daily mindfulness practice to build your baseline capacity for present moment awareness. Study presence-based coaching literature and consider taking courses in mindfulness-based coaching approaches. Practice mindful listening exercises outside of coaching contexts.',
    8
),

-- Present Moment Awareness - Foundational (0-59%)
(
    'Present Moment Awareness', 'core', 'beginner', 'foundational',
    'Developing present moment awareness represents foundational work that will enhance every other aspect of your coaching competency. Currently, you may find your mind frequently occupied with planning your next question, reviewing coaching models, analyzing the client''s situation, or evaluating your own performance during sessions. This mental activity, while normal for beginning coaches, creates a barrier between you and your client that limits the depth and authenticity of connection possible in coaching relationships.',
    'Limited presence creates subtle disconnection that clients can feel, even if they can''t articulate it. You may miss important nonverbal cues, emotional shifts, or energetic information that could inform your coaching responses. The quality of attention you bring directly impacts the client''s sense of safety and their willingness to explore vulnerable territory. Distracted presence can make coaching feel mechanical rather than relational.',
    'You likely notice being "in your head" frequently during coaching sessions - planning, analyzing, worrying about saying the right thing, or getting caught in your own thoughts about the client''s situation. Your attention may feel fragmented, split between the client and your own internal coaching commentary.',
    'Begin with basic presence practices that anchor you in immediate sensory experience. Focus on breath awareness, physical sensations, and simple attention to what you can see and hear. Practice recognizing when your mind has wandered and gently returning attention to the present moment without self-criticism.',
    'Start each coaching session with 30 seconds of conscious centering: Take three slow, deep breaths while setting an intention to stay present with your client. When you notice your mind wandering during sessions, use breath as an anchor to return to the here and now. Practice the basic mindfulness instruction: Notice when attention has moved to thinking, and gently return to presence.',
    'Establish a daily mindfulness practice outside of coaching to build your baseline capacity for sustained attention. Start with just 5-10 minutes daily of simple breath awareness or body scan meditation. As this foundation strengthens, your capacity for presence during coaching will naturally improve.',
    'Practice mindful transitions: Take one conscious breath between each client response and your next intervention. When you notice mental activity during sessions, silently name it ("planning," "analyzing," "worrying") and return attention to your client''s words and presence.',
    'Work with a mentor to identify your specific patterns of distraction. What triggers you to leave the present moment? Practice presence-building exercises during supervision sessions. Learn to recognize the felt sense of being present versus being distracted.',
    'Begin a foundational mindfulness practice using guided meditations or mindfulness apps. Read "Presence-Based Coaching" by Doug Silsbee. Practice mindful listening exercises in daily life. Consider taking a Mindfulness-Based Stress Reduction (MBSR) course to build fundamental presence skills.',
    9
);
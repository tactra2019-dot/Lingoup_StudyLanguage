"""
Database seed script for LingoUp.
Run: python seed.py
Creates all required content: 1 language, 4 levels, 8 A1 units, 3+ lessons each,
120+ vocabulary, 100+ questions.
"""
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app.core.database import engine, SessionLocal, Base
import app.models  # noqa: register all models
from app.models import (
    Language, Level, Unit, Lesson, Vocabulary, Question, QuestionOption, Achievement
)


def seed():
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()

    try:
        # Clear existing data
        for model in [Achievement, QuestionOption, Question, Vocabulary, Lesson, Unit, Level, Language]:
            db.query(model).delete()
        db.commit()

        # =========================================================
        # LANGUAGE
        # =========================================================
        english = Language(code="en", name="English", native_name="English", flag_emoji="🇺🇸", is_active=True)
        db.add(english)
        db.flush()

        # =========================================================
        # LEVELS
        # =========================================================
        a1 = Level(language_id=english.id, code="A1", name="Beginner", description="Basic everyday expressions", order_index=0)
        a2 = Level(language_id=english.id, code="A2", name="Elementary", description="Simple routine tasks", order_index=1)
        b1 = Level(language_id=english.id, code="B1", name="Intermediate", description="Main points in context", order_index=2)
        b2 = Level(language_id=english.id, code="B2", name="Upper Intermediate", description="Complex texts", order_index=3)
        db.add_all([a1, a2, b1, b2])
        db.flush()

        # =========================================================
        # UNITS (8 for A1)
        # =========================================================
        unit_data = [
            (a1.id, "Introductions", "Greet people and introduce yourself", 0, "👋"),
            (a1.id, "Family & Friends", "Talk about people you know", 1, "👨‍👩‍👧‍👦"),
            (a1.id, "Travel", "Navigate airports, trains, and buses", 2, "✈️"),
            (a1.id, "Food & Drink", "Order food and talk about meals", 3, "🍽️"),
            (a1.id, "Daily Activities", "Describe your everyday routine", 4, "📅"),
            (a1.id, "Shopping", "Buy things and ask about prices", 5, "🛍️"),
            (a1.id, "Work & Study", "Talk about jobs and education", 6, "💼"),
            (a1.id, "Health & Lifestyle", "Describe health and body", 7, "💪"),
        ]

        units = []
        for level_id, title, desc, idx, emoji in unit_data:
            u = Unit(level_id=level_id, title=title, description=desc, order_index=idx, emoji=emoji)
            db.add(u)
            units.append(u)
        db.flush()

        # =========================================================
        # LESSONS + VOCABULARY + QUESTIONS
        # =========================================================

        def add_lesson(unit, title, desc, objectives, order_idx, xp=20, ltype="mixed"):
            l = Lesson(unit_id=unit.id, title=title, description=desc,
                       objectives=objectives, order_index=order_idx,
                       xp_reward=xp, lesson_type=ltype)
            db.add(l)
            db.flush()
            return l

        def add_vocab(lesson, word, translation, pronunciation, example_sent, example_trans, meaning, pos, idx):
            v = Vocabulary(
                lesson_id=lesson.id, word=word, translation=translation,
                pronunciation=pronunciation, example_sentence=example_sent,
                example_translation=example_trans, meaning=meaning,
                part_of_speech=pos, order_index=idx
            )
            db.add(v)
            return v

        def add_question(lesson, prompt, options_data, q_type="single_choice", explanation="", difficulty=1, idx=0):
            """options_data: list of (text, is_correct)"""
            q = Question(lesson_id=lesson.id, question_type=q_type,
                         prompt=prompt, explanation=explanation,
                         difficulty=difficulty, order_index=idx)
            db.add(q)
            db.flush()
            for opt_idx, (text, is_correct) in enumerate(options_data):
                opt = QuestionOption(question_id=q.id, text=text, is_correct=is_correct, order_index=opt_idx)
                db.add(opt)

        # =============================================
        # UNIT 1: Introductions
        # =============================================
        unit1 = units[0]

        # Lesson 1.1 - Saying Hello
        l1_1 = add_lesson(unit1, "Saying Hello", "Learn basic greetings", "Greet people in English", 0, 20)
        add_vocab(l1_1, "Hello", "Xin chào", "/həˈloʊ/", "Hello! How are you?", "Xin chào! Bạn khỏe không?", "A common greeting", "interjection", 0)
        add_vocab(l1_1, "Hi", "Chào", "/haɪ/", "Hi! Nice to meet you.", "Chào! Rất vui được gặp bạn.", "Informal greeting", "interjection", 1)
        add_vocab(l1_1, "Good morning", "Chào buổi sáng", "/ɡʊd ˈmɔːrnɪŋ/", "Good morning, everyone!", "Chào buổi sáng mọi người!", "Morning greeting", "phrase", 2)
        add_vocab(l1_1, "Good afternoon", "Chào buổi chiều", "/ɡʊd ˌæftərˈnuːn/", "Good afternoon, sir.", "Chào buổi chiều, thưa ông.", "Afternoon greeting", "phrase", 3)
        add_vocab(l1_1, "Good evening", "Chào buổi tối", "/ɡʊd ˈiːvnɪŋ/", "Good evening, madam.", "Chào buổi tối, thưa bà.", "Evening greeting", "phrase", 4)

        add_question(l1_1, "What does 'Hello' mean in Vietnamese?",
                     [("Xin chào", True), ("Tạm biệt", False), ("Cảm ơn", False), ("Xin lỗi", False)],
                     explanation="'Hello' means 'Xin chào' in Vietnamese.", idx=0)
        add_question(l1_1, "Which greeting is used in the morning?",
                     [("Good morning", True), ("Good evening", False), ("Good night", False), ("Goodbye", False)],
                     explanation="'Good morning' is used before noon.", idx=1)
        add_question(l1_1, "How do you say 'Chào buổi tối' in English?",
                     [("Good evening", True), ("Good morning", False), ("Good afternoon", False), ("Hello", False)],
                     explanation="'Good evening' is 'Chào buổi tối'.", idx=2)
        add_question(l1_1, "Which is an informal greeting?",
                     [("Hi", True), ("Good morning", False), ("Good afternoon", False), ("Good evening", False)],
                     explanation="'Hi' is casual/informal.", idx=3)
        add_question(l1_1, "What time do you use 'Good afternoon'?",
                     [("After noon until evening", True), ("In the morning", False), ("At night", False), ("At midnight", False)],
                     explanation="Good afternoon is used from noon to about 6 PM.", idx=4)

        # Lesson 1.2 - Introducing Yourself
        l1_2 = add_lesson(unit1, "Introducing Yourself", "Say who you are", "Introduce yourself in English", 1, 20)
        add_vocab(l1_2, "My name is", "Tên tôi là", "/maɪ neɪm ɪz/", "My name is Anna.", "Tên tôi là Anna.", "Introduce your name", "phrase", 0)
        add_vocab(l1_2, "I am", "Tôi là", "/aɪ æm/", "I am a student.", "Tôi là một học sinh.", "State your identity", "phrase", 1)
        add_vocab(l1_2, "Nice to meet you", "Rất vui được gặp bạn", "/naɪs tə miːt juː/", "Nice to meet you, John!", "Rất vui được gặp bạn, John!", "Polite greeting when meeting", "phrase", 2)
        add_vocab(l1_2, "How are you?", "Bạn khỏe không?", "/haʊ ɑːr juː/", "How are you today?", "Hôm nay bạn khỏe không?", "Asking about wellbeing", "phrase", 3)
        add_vocab(l1_2, "I'm fine", "Tôi khỏe", "/aɪm faɪn/", "I'm fine, thank you!", "Tôi khỏe, cảm ơn!", "Response to 'how are you'", "phrase", 4)

        add_question(l1_2, "How do you introduce your name?",
                     [("My name is...", True), ("I like...", False), ("I want...", False), ("She is...", False)], idx=0)
        add_question(l1_2, "What does 'Nice to meet you' express?",
                     [("Pleasure of meeting someone", True), ("Saying goodbye", False), ("Asking for help", False), ("Ordering food", False)], idx=1)
        add_question(l1_2, "Complete: '___ are you?'",
                     [("How", True), ("What", False), ("Where", False), ("When", False)], idx=2)
        add_question(l1_2, "What is the correct response to 'How are you?'",
                     [("I'm fine, thank you", True), ("My name is Anna", False), ("Good morning", False), ("Goodbye", False)], idx=3)
        add_question(l1_2, "Translate: 'Tôi là học sinh'",
                     [("I am a student", True), ("I am a teacher", False), ("I am a doctor", False), ("She is a student", False)], idx=4)

        # Lesson 1.3 - Farewells
        l1_3 = add_lesson(unit1, "Saying Goodbye", "Learn how to say farewell", "Use farewell expressions", 2, 20)
        add_vocab(l1_3, "Goodbye", "Tạm biệt", "/ˌɡʊdˈbaɪ/", "Goodbye! See you tomorrow.", "Tạm biệt! Hẹn gặp lại ngày mai.", "Formal farewell", "interjection", 0)
        add_vocab(l1_3, "See you later", "Hẹn gặp lại", "/siː juː ˈleɪtər/", "See you later, friend!", "Hẹn gặp lại, bạn ơi!", "Informal farewell", "phrase", 1)
        add_vocab(l1_3, "Good night", "Chúc ngủ ngon", "/ɡʊd naɪt/", "Good night, sleep well!", "Chúc ngủ ngon, ngủ ngon nhé!", "Nighttime farewell", "phrase", 2)
        add_vocab(l1_3, "Take care", "Bảo trọng", "/teɪk ker/", "Take care of yourself!", "Hãy bảo trọng bản thân!", "Caring farewell", "phrase", 3)
        add_vocab(l1_3, "Bye", "Tạm biệt", "/baɪ/", "Bye! Talk soon.", "Tạm biệt! Nói chuyện sau nhé.", "Casual farewell", "interjection", 4)

        add_question(l1_3, "Which phrase means 'Tạm biệt'?",
                     [("Goodbye", True), ("Hello", False), ("Thank you", False), ("Please", False)], idx=0)
        add_question(l1_3, "When do you say 'Good night'?",
                     [("Before going to sleep", True), ("In the morning", False), ("After lunch", False), ("At work", False)], idx=1)
        add_question(l1_3, "What does 'See you later' mean?",
                     [("Hẹn gặp lại", True), ("Tạm biệt mãi mãi", False), ("Xin chào", False), ("Cảm ơn", False)], idx=2)
        add_question(l1_3, "Which is a casual farewell?",
                     [("Bye", True), ("Good evening", False), ("How are you?", False), ("Nice to meet you", False)], idx=3)
        add_question(l1_3, "'Take care' means?",
                     [("Bảo trọng", True), ("Cẩn thận", False), ("Chờ đợi", False), ("Nhanh lên", False)], idx=4)

        # =============================================
        # UNIT 2: Family & Friends
        # =============================================
        unit2 = units[1]

        l2_1 = add_lesson(unit2, "Family Members", "Learn family vocabulary", "Name family members", 0, 20)
        add_vocab(l2_1, "Mother", "Mẹ", "/ˈmʌðər/", "My mother is a nurse.", "Mẹ tôi là y tá.", "Female parent", "noun", 0)
        add_vocab(l2_1, "Father", "Bố", "/ˈfɑːðər/", "My father works at a bank.", "Bố tôi làm ở ngân hàng.", "Male parent", "noun", 1)
        add_vocab(l2_1, "Sister", "Chị/em gái", "/ˈsɪstər/", "My sister is older than me.", "Chị gái tôi lớn hơn tôi.", "Female sibling", "noun", 2)
        add_vocab(l2_1, "Brother", "Anh/em trai", "/ˈbrʌðər/", "My brother likes football.", "Anh trai tôi thích bóng đá.", "Male sibling", "noun", 3)
        add_vocab(l2_1, "Grandmother", "Bà", "/ˈɡrænmʌðər/", "My grandmother tells good stories.", "Bà tôi kể chuyện hay lắm.", "Mother's or father's mother", "noun", 4)
        add_vocab(l2_1, "Grandfather", "Ông", "/ˈɡrænfɑːðər/", "My grandfather is 75 years old.", "Ông tôi 75 tuổi.", "Mother's or father's father", "noun", 5)

        add_question(l2_1, "What is 'Mẹ' in English?",
                     [("Mother", True), ("Father", False), ("Sister", False), ("Grandmother", False)], idx=0)
        add_question(l2_1, "Who is a 'Sister'?",
                     [("Female sibling", True), ("Male sibling", False), ("Female parent", False), ("Male parent", False)], idx=1)
        add_question(l2_1, "What is 'Ông' in English?",
                     [("Grandfather", True), ("Grandmother", False), ("Father", False), ("Uncle", False)], idx=2)
        add_question(l2_1, "My ___ likes football (Anh trai)",
                     [("Brother", True), ("Sister", False), ("Father", False), ("Mother", False)], idx=3)
        add_question(l2_1, "Who is a 'Grandmother'?",
                     [("Your parent's mother", True), ("Your parent's father", False), ("Your sibling", False), ("Your aunt", False)], idx=4)

        l2_2 = add_lesson(unit2, "Describing People", "Learn adjectives for people", "Describe people's appearance", 1, 20)
        add_vocab(l2_2, "Tall", "Cao", "/tɔːl/", "My father is very tall.", "Bố tôi rất cao.", "Of great height", "adjective", 0)
        add_vocab(l2_2, "Short", "Thấp", "/ʃɔːrt/", "She is a short girl.", "Cô ấy là cô gái thấp.", "Not tall", "adjective", 1)
        add_vocab(l2_2, "Young", "Trẻ", "/jʌŋ/", "My brother is very young.", "Anh trai tôi rất trẻ.", "Not old", "adjective", 2)
        add_vocab(l2_2, "Old", "Già", "/oʊld/", "My grandmother is old.", "Bà tôi đã già.", "Having lived for a long time", "adjective", 3)
        add_vocab(l2_2, "Kind", "Tốt bụng", "/kaɪnd/", "She is a kind person.", "Cô ấy là người tốt bụng.", "Friendly and generous", "adjective", 4)

        add_question(l2_2, "What does 'Tall' mean?",
                     [("Cao", True), ("Thấp", False), ("Trẻ", False), ("Già", False)], idx=0)
        add_question(l2_2, "Opposite of 'Young' is?",
                     [("Old", True), ("Tall", False), ("Kind", False), ("Short", False)], idx=1)
        add_question(l2_2, "My grandmother is ___ (Già)",
                     [("Old", True), ("Young", False), ("Tall", False), ("Short", False)], idx=2)
        add_question(l2_2, "'Kind' means?",
                     [("Tốt bụng", True), ("Lười biếng", False), ("Thông minh", False), ("Dũng cảm", False)], idx=3)
        add_question(l2_2, "She is ___ (Thấp)",
                     [("Short", True), ("Tall", False), ("Kind", False), ("Old", False)], idx=4)

        l2_3 = add_lesson(unit2, "Friends and Relationships", "Talk about friendships", "Describe relationships", 2, 20)
        add_vocab(l2_3, "Friend", "Bạn bè", "/frend/", "She is my best friend.", "Cô ấy là bạn thân nhất của tôi.", "A person you like and trust", "noun", 0)
        add_vocab(l2_3, "Classmate", "Bạn học", "/ˈklæsmeɪt/", "He is my classmate.", "Anh ấy là bạn học của tôi.", "Someone in same class", "noun", 1)
        add_vocab(l2_3, "Neighbor", "Hàng xóm", "/ˈneɪbər/", "My neighbor is very friendly.", "Hàng xóm tôi rất thân thiện.", "Person who lives nearby", "noun", 2)
        add_vocab(l2_3, "Colleague", "Đồng nghiệp", "/ˈkɒliːɡ/", "My colleague helps me a lot.", "Đồng nghiệp tôi giúp đỡ tôi rất nhiều.", "Person you work with", "noun", 3)
        add_vocab(l2_3, "Best friend", "Bạn thân", "/best frend/", "My best friend is Anna.", "Bạn thân nhất của tôi là Anna.", "Closest friend", "phrase", 4)

        add_question(l2_3, "What is a 'Classmate'?",
                     [("Someone in the same class", True), ("Someone at work", False), ("A neighbor", False), ("A family member", False)], idx=0)
        add_question(l2_3, "'Hàng xóm' means?",
                     [("Neighbor", True), ("Friend", False), ("Colleague", False), ("Classmate", False)], idx=1)
        add_question(l2_3, "She is my ___ friend (Bạn thân nhất)",
                     [("Best", True), ("Old", False), ("New", False), ("Kind", False)], idx=2)
        add_question(l2_3, "A 'Colleague' is someone you...?",
                     [("Work with", True), ("Study with", False), ("Live near", False), ("Play with", False)], idx=3)
        add_question(l2_3, "'Bạn bè' means?",
                     [("Friend", True), ("Family", False), ("Enemy", False), ("Teacher", False)], idx=4)

        # =============================================
        # UNIT 3: Travel
        # =============================================
        unit3 = units[2]

        l3_1 = add_lesson(unit3, "Transportation", "Learn travel vocabulary", "Name transport methods", 0, 25)
        add_vocab(l3_1, "Airplane", "Máy bay", "/ˈeɪrpleɪn/", "I took the airplane to Paris.", "Tôi đi máy bay đến Paris.", "Aircraft for flying", "noun", 0)
        add_vocab(l3_1, "Train", "Tàu hỏa", "/treɪn/", "The train is fast.", "Tàu hỏa rất nhanh.", "Rail transport", "noun", 1)
        add_vocab(l3_1, "Bus", "Xe buýt", "/bʌs/", "I take the bus to school.", "Tôi đi xe buýt đến trường.", "Public road transport", "noun", 2)
        add_vocab(l3_1, "Taxi", "Taxi", "/ˈtæksi/", "Let's take a taxi!", "Hãy bắt taxi!", "Hired car with driver", "noun", 3)
        add_vocab(l3_1, "Ticket", "Vé", "/ˈtɪkɪt/", "I need a train ticket.", "Tôi cần một vé tàu hỏa.", "Entry document", "noun", 4)
        add_vocab(l3_1, "Passport", "Hộ chiếu", "/ˈpæspɔːrt/", "Don't forget your passport!", "Đừng quên hộ chiếu của bạn!", "Official travel document", "noun", 5)

        add_question(l3_1, "What is 'Máy bay' in English?",
                     [("Airplane", True), ("Train", False), ("Bus", False), ("Taxi", False)], idx=0)
        add_question(l3_1, "You need this to travel abroad:",
                     [("Passport", True), ("Ticket", False), ("Bus", False), ("Train", False)], idx=1)
        add_question(l3_1, "'Vé' in English is?",
                     [("Ticket", True), ("Passport", False), ("Train", False), ("Bus", False)], idx=2)
        add_question(l3_1, "Which is public road transport?",
                     [("Bus", True), ("Airplane", False), ("Train", False), ("Taxi", False)], idx=3)
        add_question(l3_1, "I ___ the bus to school.",
                     [("Take", True), ("Drive", False), ("Fly", False), ("Swim", False)], idx=4)

        l3_2 = add_lesson(unit3, "At the Airport", "Navigate airport situations", "Communicate at an airport", 1, 25)
        add_vocab(l3_2, "Check-in", "Làm thủ tục", "/tʃek ɪn/", "Please go to check-in.", "Vui lòng đến làm thủ tục.", "Process before boarding", "verb", 0)
        add_vocab(l3_2, "Boarding gate", "Cửa lên máy bay", "/ˈbɔːrdɪŋ ɡeɪt/", "Go to boarding gate 5.", "Hãy đến cửa số 5 để lên máy bay.", "Where you board the plane", "noun", 1)
        add_vocab(l3_2, "Luggage", "Hành lý", "/ˈlʌɡɪdʒ/", "My luggage is heavy.", "Hành lý của tôi rất nặng.", "Bags for travel", "noun", 2)
        add_vocab(l3_2, "Departure", "Khởi hành", "/dɪˈpɑːrtʃər/", "The departure is at 10 AM.", "Khởi hành lúc 10 giờ sáng.", "Time/act of leaving", "noun", 3)
        add_vocab(l3_2, "Arrival", "Đến nơi", "/əˈraɪvəl/", "What time is the arrival?", "Mấy giờ đến nơi?", "Act of arriving", "noun", 4)

        add_question(l3_2, "'Hành lý' in English is?",
                     [("Luggage", True), ("Ticket", False), ("Passport", False), ("Gate", False)], idx=0)
        add_question(l3_2, "Where do you board the plane?",
                     [("Boarding gate", True), ("Check-in counter", False), ("Baggage claim", False), ("Departure lounge", False)], idx=1)
        add_question(l3_2, "Opposite of 'Departure' is?",
                     [("Arrival", True), ("Check-in", False), ("Boarding", False), ("Landing", False)], idx=2)
        add_question(l3_2, "'Khởi hành' means?",
                     [("Departure", True), ("Arrival", False), ("Landing", False), ("Waiting", False)], idx=3)
        add_question(l3_2, "My ___ is heavy.",
                     [("Luggage", True), ("Passport", False), ("Ticket", False), ("Gate", False)], idx=4)

        l3_3 = add_lesson(unit3, "Asking for Directions", "Get around in English", "Ask and give directions", 2, 25)
        add_vocab(l3_3, "Where is...?", "Ở đâu...?", "/wer ɪz/", "Where is the hotel?", "Khách sạn ở đâu?", "Asking location", "phrase", 0)
        add_vocab(l3_3, "Turn left", "Rẽ trái", "/tɜːrn left/", "Turn left at the traffic light.", "Rẽ trái tại đèn giao thông.", "Direction instruction", "phrase", 1)
        add_vocab(l3_3, "Turn right", "Rẽ phải", "/tɜːrn raɪt/", "Turn right after the bridge.", "Rẽ phải sau cây cầu.", "Direction instruction", "phrase", 2)
        add_vocab(l3_3, "Straight ahead", "Thẳng", "/streɪt əˈhed/", "Go straight ahead.", "Đi thẳng.", "Continue in same direction", "phrase", 3)
        add_vocab(l3_3, "Near", "Gần", "/nɪr/", "The station is near here.", "Nhà ga gần đây.", "Not far", "adjective", 4)

        add_question(l3_3, "How do you ask for location?",
                     [("Where is...?", True), ("How much is...?", False), ("What time is...?", False), ("Who is...?", False)], idx=0)
        add_question(l3_3, "'Rẽ trái' in English?",
                     [("Turn left", True), ("Turn right", False), ("Go straight", False), ("Stop here", False)], idx=1)
        add_question(l3_3, "'Thẳng' in English means?",
                     [("Straight ahead", True), ("Turn left", False), ("Near", False), ("Far", False)], idx=2)
        add_question(l3_3, "Opposite of 'Near' is?",
                     [("Far", True), ("Close", False), ("Here", False), ("There", False)], idx=3)
        add_question(l3_3, "Turn ___ at the traffic light (Rẽ phải)",
                     [("Right", True), ("Left", False), ("Around", False), ("Back", False)], idx=4)

        # =============================================
        # UNIT 4: Food & Drink
        # =============================================
        unit4 = units[3]

        l4_1 = add_lesson(unit4, "Common Foods", "Learn food vocabulary", "Name common foods", 0, 20)
        add_vocab(l4_1, "Rice", "Cơm", "/raɪs/", "I eat rice every day.", "Tôi ăn cơm mỗi ngày.", "Staple grain", "noun", 0)
        add_vocab(l4_1, "Bread", "Bánh mì", "/bred/", "I eat bread for breakfast.", "Tôi ăn bánh mì vào bữa sáng.", "Baked food from flour", "noun", 1)
        add_vocab(l4_1, "Chicken", "Thịt gà", "/ˈtʃɪkɪn/", "I love fried chicken.", "Tôi thích gà rán.", "Poultry meat", "noun", 2)
        add_vocab(l4_1, "Fish", "Cá", "/fɪʃ/", "She eats fish for dinner.", "Cô ấy ăn cá vào bữa tối.", "Aquatic animal food", "noun", 3)
        add_vocab(l4_1, "Vegetables", "Rau củ", "/ˈvedʒtəbəlz/", "Eat more vegetables!", "Hãy ăn nhiều rau củ hơn!", "Plant-based foods", "noun", 4)
        add_vocab(l4_1, "Fruit", "Hoa quả", "/fruːt/", "I love tropical fruit.", "Tôi thích hoa quả nhiệt đới.", "Sweet plant produce", "noun", 5)

        add_question(l4_1, "'Cơm' in English is?",
                     [("Rice", True), ("Bread", False), ("Fish", False), ("Chicken", False)], idx=0)
        add_question(l4_1, "Which is a staple grain?",
                     [("Rice", True), ("Chicken", False), ("Fish", False), ("Bread", False)], idx=1)
        add_question(l4_1, "'Bánh mì' in English?",
                     [("Bread", True), ("Rice", False), ("Cake", False), ("Cookie", False)], idx=2)
        add_question(l4_1, "'Rau củ' means?",
                     [("Vegetables", True), ("Fruit", False), ("Meat", False), ("Fish", False)], idx=3)
        add_question(l4_1, "She eats ___ for dinner (Cá)",
                     [("Fish", True), ("Rice", False), ("Bread", False), ("Chicken", False)], idx=4)

        l4_2 = add_lesson(unit4, "Ordering at a Restaurant", "Order food in English", "Order food confidently", 1, 20)
        add_vocab(l4_2, "Menu", "Thực đơn", "/ˈmenjuː/", "Can I see the menu, please?", "Cho tôi xem thực đơn được không?", "List of available dishes", "noun", 0)
        add_vocab(l4_2, "Order", "Gọi món", "/ˈɔːrdər/", "I'd like to order now.", "Tôi muốn gọi món ngay bây giờ.", "Request food/drinks", "verb", 1)
        add_vocab(l4_2, "Bill", "Hóa đơn", "/bɪl/", "Can I have the bill, please?", "Tôi có thể lấy hóa đơn không?", "Receipt for payment", "noun", 2)
        add_vocab(l4_2, "Delicious", "Ngon", "/dɪˈlɪʃəs/", "This food is delicious!", "Thức ăn này ngon tuyệt!", "Very tasty", "adjective", 3)
        add_vocab(l4_2, "Hungry", "Đói", "/ˈhʌŋɡri/", "I am very hungry.", "Tôi rất đói.", "Feeling the need to eat", "adjective", 4)

        add_question(l4_2, "What is 'Thực đơn' in English?",
                     [("Menu", True), ("Bill", False), ("Order", False), ("Receipt", False)], idx=0)
        add_question(l4_2, "How do you ask for the bill?",
                     [("Can I have the bill, please?", True), ("What's on the menu?", False), ("I am hungry.", False), ("This is delicious.", False)], idx=1)
        add_question(l4_2, "'Ngon' in English is?",
                     [("Delicious", True), ("Hungry", False), ("Full", False), ("Spicy", False)], idx=2)
        add_question(l4_2, "I am very ___ (Đói)",
                     [("Hungry", True), ("Full", False), ("Thirsty", False), ("Tired", False)], idx=3)
        add_question(l4_2, "To 'Order' at a restaurant means?",
                     [("Request food/drinks", True), ("Pay the bill", False), ("Read the menu", False), ("Cook food", False)], idx=4)

        l4_3 = add_lesson(unit4, "Drinks & Beverages", "Learn drink vocabulary", "Order drinks in English", 2, 20)
        add_vocab(l4_3, "Water", "Nước", "/ˈwɔːtər/", "I need a glass of water.", "Tôi cần một ly nước.", "Essential liquid", "noun", 0)
        add_vocab(l4_3, "Coffee", "Cà phê", "/ˈkɒfi/", "I drink coffee every morning.", "Tôi uống cà phê mỗi buổi sáng.", "Hot caffeinated drink", "noun", 1)
        add_vocab(l4_3, "Tea", "Trà", "/tiː/", "Would you like some tea?", "Bạn có muốn uống trà không?", "Hot brewed drink", "noun", 2)
        add_vocab(l4_3, "Juice", "Nước ép", "/dʒuːs/", "Orange juice is my favorite.", "Nước cam ép là yêu thích của tôi.", "Liquid from fruits", "noun", 3)
        add_vocab(l4_3, "Milk", "Sữa", "/mɪlk/", "Children drink milk every day.", "Trẻ em uống sữa mỗi ngày.", "White dairy drink", "noun", 4)

        add_question(l4_3, "'Cà phê' in English?",
                     [("Coffee", True), ("Tea", False), ("Milk", False), ("Juice", False)], idx=0)
        add_question(l4_3, "Which is an essential liquid?",
                     [("Water", True), ("Coffee", False), ("Juice", False), ("Tea", False)], idx=1)
        add_question(l4_3, "'Sữa' in English?",
                     [("Milk", True), ("Water", False), ("Tea", False), ("Coffee", False)], idx=2)
        add_question(l4_3, "I drink ___ every morning (Cà phê)",
                     [("Coffee", True), ("Tea", False), ("Juice", False), ("Milk", False)], idx=3)
        add_question(l4_3, "Orange ___ is my favorite.",
                     [("Juice", True), ("Tea", False), ("Milk", False), ("Coffee", False)], idx=4)

        # =============================================
        # UNIT 5: Daily Activities
        # =============================================
        unit5 = units[4]

        l5_1 = add_lesson(unit5, "Daily Routine", "Talk about your day", "Describe daily activities", 0, 20)
        add_vocab(l5_1, "Wake up", "Thức dậy", "/weɪk ʌp/", "I wake up at 6 AM.", "Tôi thức dậy lúc 6 giờ sáng.", "Stop sleeping", "verb phrase", 0)
        add_vocab(l5_1, "Have breakfast", "Ăn sáng", "/hæv ˈbrekfəst/", "I have breakfast at 7 AM.", "Tôi ăn sáng lúc 7 giờ sáng.", "Eat the morning meal", "phrase", 1)
        add_vocab(l5_1, "Go to work", "Đi làm", "/ɡoʊ tə wɜːrk/", "I go to work by bus.", "Tôi đi làm bằng xe buýt.", "Travel to workplace", "phrase", 2)
        add_vocab(l5_1, "Have lunch", "Ăn trưa", "/hæv lʌntʃ/", "We have lunch at noon.", "Chúng tôi ăn trưa vào buổi trưa.", "Eat the midday meal", "phrase", 3)
        add_vocab(l5_1, "Go to bed", "Đi ngủ", "/ɡoʊ tə bed/", "I go to bed at 10 PM.", "Tôi đi ngủ lúc 10 giờ tối.", "Start sleeping", "phrase", 4)
        add_vocab(l5_1, "Exercise", "Tập thể dục", "/ˈeksərsaɪz/", "I exercise in the morning.", "Tôi tập thể dục vào buổi sáng.", "Physical activity", "verb", 5)

        add_question(l5_1, "'Thức dậy' in English is?",
                     [("Wake up", True), ("Go to bed", False), ("Have breakfast", False), ("Exercise", False)], idx=0)
        add_question(l5_1, "What do you do first in the morning?",
                     [("Wake up", True), ("Go to work", False), ("Have lunch", False), ("Go to bed", False)], idx=1)
        add_question(l5_1, "'Ăn trưa' in English?",
                     [("Have lunch", True), ("Have breakfast", False), ("Have dinner", False), ("Go to bed", False)], idx=2)
        add_question(l5_1, "I ___ at 10 PM (Đi ngủ)",
                     [("Go to bed", True), ("Wake up", False), ("Go to work", False), ("Exercise", False)], idx=3)
        add_question(l5_1, "I exercise ___ the morning.",
                     [("In", True), ("At", False), ("On", False), ("By", False)], idx=4)

        l5_2 = add_lesson(unit5, "Time Expressions", "Talk about time", "Use time expressions correctly", 1, 20)
        add_vocab(l5_2, "In the morning", "Vào buổi sáng", "/ɪn ðə ˈmɔːrnɪŋ/", "I study in the morning.", "Tôi học vào buổi sáng.", "Morning time reference", "phrase", 0)
        add_vocab(l5_2, "In the afternoon", "Vào buổi chiều", "/ɪn ðə ˌæftərˈnuːn/", "I nap in the afternoon.", "Tôi ngủ trưa vào buổi chiều.", "Afternoon time reference", "phrase", 1)
        add_vocab(l5_2, "At night", "Vào ban đêm", "/æt naɪt/", "I read books at night.", "Tôi đọc sách vào ban đêm.", "Nighttime reference", "phrase", 2)
        add_vocab(l5_2, "Every day", "Mỗi ngày", "/ˈevri deɪ/", "I brush my teeth every day.", "Tôi đánh răng mỗi ngày.", "Daily frequency", "phrase", 3)
        add_vocab(l5_2, "Sometimes", "Đôi khi", "/ˈsʌmtaɪmz/", "I sometimes cook dinner.", "Đôi khi tôi nấu ăn tối.", "Occasionally", "adverb", 4)

        add_question(l5_2, "'Vào buổi sáng' in English?",
                     [("In the morning", True), ("In the afternoon", False), ("At night", False), ("Every day", False)], idx=0)
        add_question(l5_2, "'Every day' means?",
                     [("Mỗi ngày", True), ("Đôi khi", False), ("Đôi ngày", False), ("Hàng tuần", False)], idx=1)
        add_question(l5_2, "I read books ___ night.",
                     [("At", True), ("In", False), ("On", False), ("By", False)], idx=2)
        add_question(l5_2, "'Sometimes' means?",
                     [("Occasionally", True), ("Always", False), ("Never", False), ("Usually", False)], idx=3)
        add_question(l5_2, "I study ___ the morning.",
                     [("In", True), ("At", False), ("On", False), ("By", False)], idx=4)

        l5_3 = add_lesson(unit5, "Hobbies & Leisure", "Talk about free time", "Describe hobbies", 2, 20)
        add_vocab(l5_3, "Read books", "Đọc sách", "/riːd bʊks/", "I love to read books.", "Tôi thích đọc sách.", "Reading for pleasure", "phrase", 0)
        add_vocab(l5_3, "Watch TV", "Xem tivi", "/wɒtʃ tiːˌviː/", "I watch TV in the evening.", "Tôi xem tivi vào buổi tối.", "Watch television", "phrase", 1)
        add_vocab(l5_3, "Play sports", "Chơi thể thao", "/pleɪ spɔːrts/", "He plays sports on weekends.", "Anh ấy chơi thể thao vào cuối tuần.", "Engage in athletics", "phrase", 2)
        add_vocab(l5_3, "Listen to music", "Nghe nhạc", "/ˈlɪsən tə ˈmjuːzɪk/", "I listen to music every day.", "Tôi nghe nhạc mỗi ngày.", "Enjoy audio music", "phrase", 3)
        add_vocab(l5_3, "Cook", "Nấu ăn", "/kʊk/", "My mother loves to cook.", "Mẹ tôi thích nấu ăn.", "Prepare food", "verb", 4)

        add_question(l5_3, "'Đọc sách' in English?",
                     [("Read books", True), ("Watch TV", False), ("Play sports", False), ("Cook", False)], idx=0)
        add_question(l5_3, "He ___ sports on weekends.",
                     [("Plays", True), ("Reads", False), ("Watches", False), ("Cooks", False)], idx=1)
        add_question(l5_3, "'Nghe nhạc' means?",
                     [("Listen to music", True), ("Play music", False), ("Sing music", False), ("Write music", False)], idx=2)
        add_question(l5_3, "My mother loves to ___. (Nấu ăn)",
                     [("Cook", True), ("Read", False), ("Watch", False), ("Play", False)], idx=3)
        add_question(l5_3, "I ___ TV in the evening. (Xem)",
                     [("Watch", True), ("Listen", False), ("Read", False), ("Cook", False)], idx=4)

        # =============================================
        # UNIT 6: Shopping
        # =============================================
        unit6 = units[5]

        l6_1 = add_lesson(unit6, "Shopping Vocabulary", "Learn shopping terms", "Name shopping items and places", 0, 20)
        add_vocab(l6_1, "Shop / Store", "Cửa hàng", "/ʃɒp/", "I go to the shop.", "Tôi đến cửa hàng.", "Place to buy things", "noun", 0)
        add_vocab(l6_1, "Price", "Giá", "/praɪs/", "What is the price of this?", "Cái này giá bao nhiêu?", "Cost of something", "noun", 1)
        add_vocab(l6_1, "Expensive", "Đắt", "/ɪkˈspensɪv/", "This watch is too expensive.", "Cái đồng hồ này quá đắt.", "High cost", "adjective", 2)
        add_vocab(l6_1, "Cheap", "Rẻ", "/tʃiːp/", "These shoes are very cheap.", "Đôi giày này rất rẻ.", "Low cost", "adjective", 3)
        add_vocab(l6_1, "Buy", "Mua", "/baɪ/", "I want to buy a shirt.", "Tôi muốn mua một chiếc áo.", "Purchase", "verb", 4)
        add_vocab(l6_1, "Pay", "Trả tiền", "/peɪ/", "How do you want to pay?", "Bạn muốn trả tiền như thế nào?", "Give money for goods", "verb", 5)

        add_question(l6_1, "'Giá' in English is?",
                     [("Price", True), ("Shop", False), ("Pay", False), ("Buy", False)], idx=0)
        add_question(l6_1, "Opposite of 'Expensive' is?",
                     [("Cheap", True), ("Costly", False), ("Pricey", False), ("Valuable", False)], idx=1)
        add_question(l6_1, "'Mua' in English?",
                     [("Buy", True), ("Pay", False), ("Sell", False), ("Shop", False)], idx=2)
        add_question(l6_1, "These shoes are very ___ (Rẻ)",
                     [("Cheap", True), ("Expensive", False), ("Nice", False), ("Old", False)], idx=3)
        add_question(l6_1, "How do you want to ___? (Trả tiền)",
                     [("Pay", True), ("Buy", False), ("Shop", False), ("Order", False)], idx=4)

        l6_2 = add_lesson(unit6, "Asking About Prices", "Negotiate prices", "Ask about and discuss prices", 1, 20)
        add_vocab(l6_2, "How much?", "Bao nhiêu?", "/haʊ mʌtʃ/", "How much is this jacket?", "Áo khoác này bao nhiêu?", "Ask for price", "phrase", 0)
        add_vocab(l6_2, "Discount", "Giảm giá", "/ˈdɪskaʊnt/", "Is there a discount?", "Có giảm giá không?", "Reduction in price", "noun", 1)
        add_vocab(l6_2, "Receipt", "Biên lai", "/rɪˈsiːt/", "Can I have a receipt?", "Tôi có thể lấy biên lai không?", "Proof of purchase", "noun", 2)
        add_vocab(l6_2, "Cash", "Tiền mặt", "/kæʃ/", "I will pay in cash.", "Tôi sẽ trả bằng tiền mặt.", "Physical money", "noun", 3)
        add_vocab(l6_2, "Credit card", "Thẻ tín dụng", "/ˈkredɪt kɑːrd/", "Do you accept credit cards?", "Bạn có chấp nhận thẻ tín dụng không?", "Electronic payment card", "noun", 4)

        add_question(l6_2, "How do you ask the price?",
                     [("How much?", True), ("How many?", False), ("How long?", False), ("How often?", False)], idx=0)
        add_question(l6_2, "'Giảm giá' in English?",
                     [("Discount", True), ("Receipt", False), ("Cash", False), ("Price", False)], idx=1)
        add_question(l6_2, "'Biên lai' means?",
                     [("Receipt", True), ("Discount", False), ("Cash", False), ("Credit", False)], idx=2)
        add_question(l6_2, "I will pay in ___ (Tiền mặt)",
                     [("Cash", True), ("Card", False), ("Check", False), ("Credit", False)], idx=3)
        add_question(l6_2, "Do you accept ___ cards? (Thẻ tín dụng)",
                     [("Credit", True), ("Debit", False), ("Gift", False), ("Loyalty", False)], idx=4)

        l6_3 = add_lesson(unit6, "Clothing & Fashion", "Shop for clothes", "Buy clothes in English", 2, 20)
        add_vocab(l6_3, "Shirt", "Áo sơ mi", "/ʃɜːrt/", "I need a white shirt.", "Tôi cần một chiếc áo sơ mi trắng.", "Upper body garment", "noun", 0)
        add_vocab(l6_3, "Trousers / Pants", "Quần", "/ˈtraʊzərz/", "These trousers are too long.", "Những chiếc quần này quá dài.", "Lower body garment", "noun", 1)
        add_vocab(l6_3, "Shoes", "Giày", "/ʃuːz/", "I love these red shoes.", "Tôi thích đôi giày đỏ này.", "Foot coverings", "noun", 2)
        add_vocab(l6_3, "Size", "Kích cỡ", "/saɪz/", "What size do you need?", "Bạn cần kích cỡ nào?", "Measurement of clothing", "noun", 3)
        add_vocab(l6_3, "Try on", "Thử mặc", "/traɪ ɒn/", "Can I try this on?", "Tôi có thể thử mặc cái này không?", "Test fit of clothing", "phrase", 4)

        add_question(l6_3, "'Áo sơ mi' in English?",
                     [("Shirt", True), ("Trousers", False), ("Shoes", False), ("Jacket", False)], idx=0)
        add_question(l6_3, "What size ___ you need?",
                     [("Do", True), ("Does", False), ("Is", False), ("Are", False)], idx=1)
        add_question(l6_3, "'Thử mặc' means?",
                     [("Try on", True), ("Buy", False), ("Wear", False), ("Wash", False)], idx=2)
        add_question(l6_3, "'Giày' in English?",
                     [("Shoes", True), ("Shirt", False), ("Socks", False), ("Pants", False)], idx=3)
        add_question(l6_3, "These trousers are too ___.",
                     [("Long", True), ("Short", False), ("Tight", False), ("Loose", False)], idx=4)

        # =============================================
        # UNIT 7: Work & Study
        # =============================================
        unit7 = units[6]

        l7_1 = add_lesson(unit7, "Jobs & Occupations", "Learn job vocabulary", "Name different occupations", 0, 25)
        add_vocab(l7_1, "Teacher", "Giáo viên", "/ˈtiːtʃər/", "She is a kind teacher.", "Cô ấy là giáo viên tốt bụng.", "Person who teaches", "noun", 0)
        add_vocab(l7_1, "Doctor", "Bác sĩ", "/ˈdɒktər/", "The doctor helps sick people.", "Bác sĩ giúp người bệnh.", "Medical professional", "noun", 1)
        add_vocab(l7_1, "Engineer", "Kỹ sư", "/ˌendʒɪˈnɪər/", "My father is an engineer.", "Bố tôi là kỹ sư.", "Technical professional", "noun", 2)
        add_vocab(l7_1, "Student", "Sinh viên", "/ˈstjuːdənt/", "I am a university student.", "Tôi là sinh viên đại học.", "Person who studies", "noun", 3)
        add_vocab(l7_1, "Manager", "Quản lý", "/ˈmænɪdʒər/", "She is the team manager.", "Cô ấy là quản lý nhóm.", "Person who manages", "noun", 4)
        add_vocab(l7_1, "Nurse", "Y tá", "/nɜːrs/", "The nurse is very helpful.", "Y tá rất nhiệt tình.", "Medical care provider", "noun", 5)

        add_question(l7_1, "'Bác sĩ' in English?",
                     [("Doctor", True), ("Nurse", False), ("Teacher", False), ("Engineer", False)], idx=0)
        add_question(l7_1, "Person who teaches is a?",
                     [("Teacher", True), ("Doctor", False), ("Engineer", False), ("Manager", False)], idx=1)
        add_question(l7_1, "'Sinh viên' means?",
                     [("Student", True), ("Teacher", False), ("Worker", False), ("Manager", False)], idx=2)
        add_question(l7_1, "My father is an ___. (Kỹ sư)",
                     [("Engineer", True), ("Doctor", False), ("Teacher", False), ("Manager", False)], idx=3)
        add_question(l7_1, "'Y tá' in English?",
                     [("Nurse", True), ("Doctor", False), ("Teacher", False), ("Worker", False)], idx=4)

        l7_2 = add_lesson(unit7, "At School / University", "Talk about studying", "Discuss school activities", 1, 25)
        add_vocab(l7_2, "Classroom", "Phòng học", "/ˈklɑːsruːm/", "The classroom is on the second floor.", "Phòng học ở tầng hai.", "Room for learning", "noun", 0)
        add_vocab(l7_2, "Homework", "Bài tập về nhà", "/ˈhoʊmwɜːrk/", "I do homework after school.", "Tôi làm bài tập về nhà sau khi tan học.", "School work at home", "noun", 1)
        add_vocab(l7_2, "Exam", "Bài kiểm tra", "/ɪɡˈzæm/", "The final exam is tomorrow.", "Bài kiểm tra cuối kỳ là ngày mai.", "Formal test", "noun", 2)
        add_vocab(l7_2, "Library", "Thư viện", "/ˈlaɪbrəri/", "I study in the library.", "Tôi học ở thư viện.", "Collection of books", "noun", 3)
        add_vocab(l7_2, "Degree", "Bằng cấp", "/dɪˈɡriː/", "She has a university degree.", "Cô ấy có bằng đại học.", "Academic qualification", "noun", 4)

        add_question(l7_2, "'Phòng học' in English?",
                     [("Classroom", True), ("Library", False), ("Office", False), ("Lab", False)], idx=0)
        add_question(l7_2, "I do ___ after school. (Bài tập về nhà)",
                     [("Homework", True), ("Exam", False), ("Degree", False), ("Library", False)], idx=1)
        add_question(l7_2, "'Thư viện' in English?",
                     [("Library", True), ("Classroom", False), ("Bookstore", False), ("Museum", False)], idx=2)
        add_question(l7_2, "The final ___ is tomorrow. (Bài kiểm tra)",
                     [("Exam", True), ("Homework", False), ("Degree", False), ("Class", False)], idx=3)
        add_question(l7_2, "She has a university ___. (Bằng cấp)",
                     [("Degree", True), ("Exam", False), ("Class", False), ("Library", False)], idx=4)

        l7_3 = add_lesson(unit7, "Work Expressions", "Talk about work tasks", "Describe workplace activities", 2, 25)
        add_vocab(l7_3, "Meeting", "Cuộc họp", "/ˈmiːtɪŋ/", "I have a meeting at 9 AM.", "Tôi có cuộc họp lúc 9 giờ sáng.", "Formal gathering", "noun", 0)
        add_vocab(l7_3, "Deadline", "Hạn chót", "/ˈdedlaɪn/", "The deadline is Friday.", "Hạn chót là thứ Sáu.", "Final due date", "noun", 1)
        add_vocab(l7_3, "Project", "Dự án", "/ˈprɒdʒekt/", "We are working on a new project.", "Chúng tôi đang làm một dự án mới.", "Planned work task", "noun", 2)
        add_vocab(l7_3, "Team", "Nhóm", "/tiːm/", "My team is very talented.", "Nhóm của tôi rất tài năng.", "Group working together", "noun", 3)
        add_vocab(l7_3, "Presentation", "Bài thuyết trình", "/ˌprezənˈteɪʃən/", "I will give a presentation.", "Tôi sẽ thuyết trình.", "Formal display of information", "noun", 4)

        add_question(l7_3, "'Cuộc họp' in English?",
                     [("Meeting", True), ("Project", False), ("Team", False), ("Deadline", False)], idx=0)
        add_question(l7_3, "'Hạn chót' means?",
                     [("Deadline", True), ("Meeting", False), ("Project", False), ("Presentation", False)], idx=1)
        add_question(l7_3, "My ___ is very talented. (Nhóm)",
                     [("Team", True), ("Manager", False), ("Project", False), ("Meeting", False)], idx=2)
        add_question(l7_3, "I will give a ___. (Bài thuyết trình)",
                     [("Presentation", True), ("Meeting", False), ("Project", False), ("Deadline", False)], idx=3)
        add_question(l7_3, "'Dự án' in English?",
                     [("Project", True), ("Team", False), ("Meeting", False), ("Task", False)], idx=4)

        # =============================================
        # UNIT 8: Health & Lifestyle
        # =============================================
        unit8 = units[7]

        l8_1 = add_lesson(unit8, "Body Parts", "Learn body vocabulary", "Name body parts in English", 0, 20)
        add_vocab(l8_1, "Head", "Đầu", "/hed/", "My head hurts.", "Đầu tôi đau.", "Top of body", "noun", 0)
        add_vocab(l8_1, "Hand", "Tay", "/hænd/", "Wash your hands!", "Hãy rửa tay!", "End of arm", "noun", 1)
        add_vocab(l8_1, "Eye", "Mắt", "/aɪ/", "She has blue eyes.", "Cô ấy có đôi mắt xanh.", "Organ for seeing", "noun", 2)
        add_vocab(l8_1, "Mouth", "Miệng", "/maʊθ/", "Open your mouth.", "Mở miệng ra.", "Opening for eating", "noun", 3)
        add_vocab(l8_1, "Back", "Lưng", "/bæk/", "My back is sore.", "Lưng tôi đau.", "Rear of torso", "noun", 4)
        add_vocab(l8_1, "Leg", "Chân", "/leɡ/", "He broke his leg.", "Anh ấy gãy chân.", "Lower limb", "noun", 5)

        add_question(l8_1, "'Đầu' in English?",
                     [("Head", True), ("Hand", False), ("Leg", False), ("Eye", False)], idx=0)
        add_question(l8_1, "Organ for seeing is?",
                     [("Eye", True), ("Ear", False), ("Mouth", False), ("Nose", False)], idx=1)
        add_question(l8_1, "'Miệng' means?",
                     [("Mouth", True), ("Ear", False), ("Eye", False), ("Nose", False)], idx=2)
        add_question(l8_1, "He broke his ___ (Chân)",
                     [("Leg", True), ("Hand", False), ("Head", False), ("Back", False)], idx=3)
        add_question(l8_1, "My ___ is sore. (Lưng)",
                     [("Back", True), ("Head", False), ("Hand", False), ("Leg", False)], idx=4)

        l8_2 = add_lesson(unit8, "Common Illnesses", "Talk about health problems", "Describe illnesses and symptoms", 1, 20)
        add_vocab(l8_2, "Sick", "Bệnh", "/sɪk/", "I feel sick today.", "Hôm nay tôi cảm thấy bệnh.", "Not healthy", "adjective", 0)
        add_vocab(l8_2, "Headache", "Đau đầu", "/ˈhedeɪk/", "I have a terrible headache.", "Tôi bị đau đầu kinh khủng.", "Pain in the head", "noun", 1)
        add_vocab(l8_2, "Fever", "Sốt", "/ˈfiːvər/", "She has a high fever.", "Cô ấy bị sốt cao.", "High body temperature", "noun", 2)
        add_vocab(l8_2, "Cold", "Cảm lạnh", "/koʊld/", "I have a cold.", "Tôi bị cảm lạnh.", "Common illness", "noun", 3)
        add_vocab(l8_2, "Doctor", "Bác sĩ", "/ˈdɒktər/", "I need to see a doctor.", "Tôi cần gặp bác sĩ.", "Medical professional", "noun", 4)

        add_question(l8_2, "'Sốt' in English?",
                     [("Fever", True), ("Cold", False), ("Headache", False), ("Sick", False)], idx=0)
        add_question(l8_2, "I have a terrible ___. (Đau đầu)",
                     [("Headache", True), ("Fever", False), ("Cold", False), ("Stomachache", False)], idx=1)
        add_question(l8_2, "'Cảm lạnh' in English?",
                     [("Cold", True), ("Fever", False), ("Flu", False), ("Sick", False)], idx=2)
        add_question(l8_2, "'Bệnh' as an adjective means?",
                     [("Sick", True), ("Tired", False), ("Sad", False), ("Busy", False)], idx=3)
        add_question(l8_2, "She has a high ___. (Sốt)",
                     [("Fever", True), ("Cold", False), ("Headache", False), ("Pressure", False)], idx=4)

        l8_3 = add_lesson(unit8, "Healthy Habits", "Talk about health choices", "Describe healthy lifestyle choices", 2, 20)
        add_vocab(l8_3, "Sleep", "Ngủ", "/sliːp/", "I sleep 8 hours a day.", "Tôi ngủ 8 tiếng mỗi ngày.", "Rest in sleep state", "verb", 0)
        add_vocab(l8_3, "Eat healthy", "Ăn lành mạnh", "/iːt ˈhelθi/", "Try to eat healthy every day.", "Hãy ăn lành mạnh mỗi ngày.", "Consume nutritious food", "phrase", 1)
        add_vocab(l8_3, "Drink water", "Uống nước", "/drɪŋk ˈwɔːtər/", "Drink at least 8 glasses of water.", "Uống ít nhất 8 ly nước.", "Consume water", "phrase", 2)
        add_vocab(l8_3, "Avoid stress", "Tránh stress", "/əˈvɔɪd stres/", "Try to avoid stress.", "Hãy cố tránh stress.", "Minimize anxiety", "phrase", 3)
        add_vocab(l8_3, "Meditate", "Thiền định", "/ˈmedɪteɪt/", "She meditates every morning.", "Cô ấy thiền định mỗi buổi sáng.", "Practice meditation", "verb", 4)

        add_question(l8_3, "I ___ 8 hours a day. (Ngủ)",
                     [("Sleep", True), ("Eat", False), ("Drink", False), ("Exercise", False)], idx=0)
        add_question(l8_3, "'Ăn lành mạnh' means?",
                     [("Eat healthy", True), ("Eat a lot", False), ("Avoid food", False), ("Cook well", False)], idx=1)
        add_question(l8_3, "Drink at least 8 glasses of ___.",
                     [("Water", True), ("Juice", False), ("Milk", False), ("Coffee", False)], idx=2)
        add_question(l8_3, "'Thiền định' in English?",
                     [("Meditate", True), ("Exercise", False), ("Sleep", False), ("Relax", False)], idx=3)
        add_question(l8_3, "'Avoid stress' means?",
                     [("Tránh stress", True), ("Thích stress", False), ("Tạo stress", False), ("Chịu đựng stress", False)], idx=4)

        # =========================================================
        # ACHIEVEMENTS
        # =========================================================
        achievements_data = [
            ("first_lesson", "First Step! 🎯", "Complete your first lesson", "🎯", 10, "lessons", 1),
            ("five_lessons", "Learning Streak! 📚", "Complete 5 lessons", "📚", 25, "lessons", 5),
            ("ten_lessons", "Knowledge Builder! 🧠", "Complete 10 lessons", "🧠", 50, "lessons", 10),
            ("twenty_lessons", "Dedicated Learner! ⭐", "Complete 20 lessons", "⭐", 100, "lessons", 20),
            ("first_streak", "On Fire! 🔥", "Get a 3-day streak", "🔥", 15, "streak", 3),
            ("week_streak", "Week Warrior! 📅", "Get a 7-day streak", "📅", 50, "streak", 7),
            ("month_streak", "Month Master! 🏆", "Get a 30-day streak", "🏆", 200, "streak", 30),
            ("hundred_xp", "XP Earner! 💎", "Earn 100 XP", "💎", 0, "xp", 100),
            ("five_hundred_xp", "XP Champion! 👑", "Earn 500 XP", "👑", 0, "xp", 500),
            ("thousand_xp", "XP Legend! 🌟", "Earn 1000 XP", "🌟", 0, "xp", 1000),
        ]

        for code, title, desc, emoji, xp_reward, ctype, cvalue in achievements_data:
            ach = Achievement(
                code=code, title=title, description=desc,
                icon_emoji=emoji, xp_reward=xp_reward,
                criteria_type=ctype, criteria_value=cvalue,
            )
            db.add(ach)

        db.commit()
        print("[SUCCESS] Seed complete!")
        print(f"  - 1 language (English)")
        print(f"  - 4 levels (A1-B2)")
        print(f"  - 8 A1 units")
        print(f"  - 24 lessons (3 per unit)")
        print(f"  - 120+ vocabulary entries")
        print(f"  - 120 practice questions")
        print(f"  - 10 achievement definitions")

    except Exception as e:
        db.rollback()
        print(f"[ERROR] Seed failed: {e}")
        raise
    finally:
        db.close()


if __name__ == "__main__":
    seed()

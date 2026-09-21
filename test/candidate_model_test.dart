import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:jobUp24/features/main/data/models/candidate_model.dart';

/// `GET /mobile/employer/candidates/:id` — ochilgan nomzodning haqiqiy javobi.
const _detailResponse = '''
{
  "id": 86,
  "public_id": 10032,
  "fullname": "Muhiddin Xaratqulov",
  "gender": "male",
  "age": 26,
  "birthday": "2000-02-02",
  "photo": null,
  "region_id": 2,
  "district_id": 16,
  "job_type_id": null,
  "region": { "id": 2, "name": "Andijon viloyati" },
  "district": { "id": 16, "name": "Andijon shahri" },
  "job_type": null,
  "professions": [
    { "job_type_id": 1, "name": "Oshpaz", "experience_year": 4 }
  ],
  "profession_text": null,
  "expected_salary": 4000000,
  "last_salary": 3500000,
  "experience_year": null,
  "information": "oliy",
  "languages": ["uz", "ru", "en"],
  "has_license": true,
  "has_car": true,
  "computer_literacy": true,
  "physical_work_ok": true,
  "motivation": null,
  "previous_job_reason": null,
  "work_status": "ishsiz",
  "work_schedule": ["full", "part", "flex"],
  "candidate_category": "premium_a",
  "is_blacklisted": false,
  "work_history": [],
  "is_unlocked": true,
  "locked": false,
  "phone": "+998907788769",
  "additional_contact": null,
  "capabilities": {
    "phone": "+998907788769",
    "chat": { "session_key": "direct:e36:a86" },
    "interview": true
  }
}
''';

void main() {
  group('CandidateModel.fromJson — ochilgan nomzod', () {
    late CandidateModel c;

    setUp(() {
      c = CandidateModel.fromJson(
          jsonDecode(_detailResponse) as Map<String, dynamic>);
    });

    test('bool bo\'lib kelgan computer_literacy parse\'ni yiqitmaydi', () {
      expect(c.computerLiteracy, isTrue);
      expect(c.hasLicense, isTrue);
      expect(c.hasCar, isTrue);
      expect(c.physicalWorkOk, isTrue);
      expect(c.isBlacklisted, isFalse);
    });

    test('ochilgan kontakt maydonlari o\'qiladi', () {
      expect(c.isUnlocked, isTrue);
      expect(c.locked, isFalse);
      expect(c.phoneRaw, '+998907788769');
      expect(c.capabilities?.chatSessionKey, 'direct:e36:a86');
      expect(c.capabilities?.interview, isTrue);
    });

    test('tajriba ildizda null bo\'lsa professions[] dan olinadi', () {
      expect(c.rawExperienceYear, isNull);
      expect(c.experienceYear, 4);
    });

    test('kasb nomi job_type null bo\'lsa professions[] dan olinadi', () {
      expect(c.jobTypeName, 'Oshpaz');
      expect(c.jobTypeId, 1);
    });

    test('ro\'yxatlar o\'qiladigan nomga o\'giriladi', () {
      expect(c.languageLabels, ["O'zbek", 'Rus', 'Ingliz']);
      expect(c.workScheduleLabels, ["To'liq kun", 'Yarim kun', 'Erkin grafik']);
      expect(c.workStatusLabel, 'Ishsiz');
      expect(c.candidateCategoryLabel, 'Premium A');
    });

    test('hudud va oylik maydonlari joyida', () {
      expect(c.region?.name, 'Andijon viloyati');
      expect(c.district?.name, 'Andijon shahri');
      expect(c.expectedSalary, 4000000);
      expect(c.lastSalary, 3500000);
    });
  });

  test('bool maydonlar string/son ko\'rinishida kelsa ham o\'qiladi', () {
    final c = CandidateModel.fromJson({
      'id': 1,
      'has_license': 'ha',
      'has_car': 0,
      'computer_literacy': 'true',
      'physical_work_ok': 1,
    });
    expect(c.hasLicense, isTrue);
    expect(c.hasCar, isFalse);
    expect(c.computerLiteracy, isTrue);
    expect(c.physicalWorkOk, isTrue);
  });

  // ⚠ REGRESSIYA (2026-09-20): `anketas.experience_year` bazada `decimal(4,1)`,
  // ya'ni `0.5` (yarim yil) normal qiymat. Model uni `int?` deb o'qigani uchun
  // "type 'double' is not a subtype of type 'int?'" bilan YIQILARDI va bitta
  // shunday nomzod butun "Mos nomzodlar" ro'yxatini o'ldirardi.
  test("kasrli tajriba (decimal) fromJson ni yiqitmaydi", () {
    final c = CandidateModel.fromJson({
      'id': 1,
      'experience_year': 0.5,
      'expected_salary': 3000000.0,
    });
    expect(c.rawExperienceYear, 0.5);
    expect(c.experienceYear, 0.5);
    expect(c.experienceDisplay, '0.5');
    expect(c.expectedSalary, 3000000);
  });

  test("kasblardagi tajriba yig'indisi kasrni saqlaydi, butun son chiroyli chiqadi",
      () {
    final c = CandidateModel.fromJson({
      'id': 2,
      'professions': [
        {'job_type_id': 1, 'name': 'Oshpaz', 'experience_year': 1.5},
        {'job_type_id': 2, 'name': 'Kassir', 'experience_year': 1.5},
      ],
    });
    expect(c.experienceYear, 3.0);
    expect(c.experienceDisplay, '3'); // "3.0 yil" deb chiqmasin
    expect(c.professions.first.experienceDisplay, '1.5');
  });

  test("raqamlar MATN bo'lib kelsa ham o'qiladi (Sequelize DECIMAL)", () {
    final c = CandidateModel.fromJson({
      'id': 3,
      'experience_year': '2.5',
      'expected_salary': '4000000.00',
    });
    expect(c.experienceYear, 2.5);
    expect(c.expectedSalary, 4000000);
  });
}

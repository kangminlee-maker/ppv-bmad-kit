# PPV VALIDATE - Multi-Phase Verification Pipeline

Entropy Tolerance에 따라 검증 밀도를 조절하는 다차원 검증 파이프라인이다.

## Prerequisites
- PPV PARALLEL 완료: 모든 Worker 태스크 done
- 코드가 메인 브랜치에 merge 완료
- 빌드 성공

## Execution Steps

### Phase 1: 자동 검증 (모든 태스크)
모든 Entropy 레벨에 적용:
1. BMad QA Agent (Quinn) 생성 테스트 실행
2. Dev Agent 단위 테스트 실행
3. 린터/타입 체크 실행
4. 빌드 성공 여부 확인

```bash
# 실행 예시
npm run lint
npm run type-check
npm run test
npm run build
```

Phase 1 실패 시 → 해당 파일의 Worker에게 수정 요청 → 수정 후 Phase 1 재실행

### Phase 2: AI Judge 검증 (Medium + Low Entropy)
Judge 에이전트를 병렬로 실행한다:

1. **Code Quality Judge** (`ppv-judge-quality`):
   - 코드 구조, 패턴, 중복 검증
   - 프로젝트 컨벤션 준수 여부

2. **Security Judge** (`ppv-judge-security`):
   - OWASP Top 10 취약점 검증
   - 인젝션, XSS, 인증 우회

3. **Business Logic Judge** (`ppv-judge-business`):
   - BMad PRD 수용 기준 대비 구현 검증
   - Architecture ADR 준수 여부

Judge 실행 방법:
```
각 Judge를 Task tool로 병렬 실행
→ 결과를 수집
→ Critical finding이 있으면 FAIL
→ Worker에게 수정 요청 → 수정 후 해당 Judge 재실행
```

### Phase 3: 시각적 검증 (UI 관련 태스크)
UI가 있는 태스크에만 적용:
1. BMad UX Design 대비 시각적 회귀 확인
2. 반응형 디자인 확인
3. 접근성 기본 체크

### Phase 4: BMad Adversarial Review (Low Entropy 태스크)
Low Entropy (Dense) 태스크에만 적용:
1. BMad `/code-review` 워크플로우 실행
2. 최소 3개 문제 발견 목표 (adversarial)
3. 핵심 비즈니스 로직 집중 리뷰
4. 최종 승인/반려

## Entropy-Based Phase Matrix

| Entropy | Phase 1 | Phase 2 | Phase 3 | Phase 4 |
|---------|---------|---------|---------|---------|
| High    | O       | -       | -       | -       |
| Medium  | O       | O       | (UI시)  | -       |
| Low     | O       | O       | (UI시)  | O       |

## Failure Handling
- Phase 1-3 실패: Worker에게 수정 요청 → 재검증 (최대 50회 반복)
- Phase 4 실패: 수정 요청 또는 Circuit Breaker 발동 판단
- 동일 카테고리 3회 연속 실패 → Circuit Breaker 자동 발동

## Output
검증 결과 리포트:
```markdown
## VALIDATE Report: {feature}
- Phase 1 (Auto): PASS/FAIL — [details]
- Phase 2 (Judge): PASS/FAIL — [X critical, Y warnings]
- Phase 3 (Visual): PASS/FAIL/SKIP
- Phase 4 (Adversarial): PASS/FAIL/SKIP
- **Overall: PASS/FAIL**
```

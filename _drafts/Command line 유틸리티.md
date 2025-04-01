---
tags:
  - tool
  - macOs
gh-page: true
created: 2025-03-20 11:34
updated: 2025-03-31 13:22
---
# memo
mac 터미널에서 사용할 수 있는 다양한 command line 유틸리티를 소개한다. 최대한 단순하게 설명하고, 바로 사용할 수 있게 스크립트 스니펫 형식으로 남기도록 하자.
## mac /usr/libexec/java_home
OS 에 설치되어있는 다양한 JDK, JRE 버전을 관리하는 유틸리티이다. 자바 버전 리스팅은 물론, 특정 버전이 설치된 경로도 확인할 수 있으며, 특정 자바 버전으로 command 를 실행하는것도 가능하다.
```
# 시스템에 설치된 자바 버전 확인
/usr/libexec/java_home -V

# 특정 자바 버전 경로 확인
/usr/libexec/java_home -v 1.8

# 특정 자바 버전으로 자바 명령어 수행
/usr/libexec/java_home --exec mvn clean
```

## fzf 
(( 더 많이 사용해보고 적기 ))

## Task woriors
(( 사용해보고 적기 ))
```
# task 생성
task add 장보기 project:daily due:0d

# task 리스트
task list

ID Age   Project          Due        Description                            Urg
-- ----- ---------------- ---------- -------------------------------------- ----
 1 13min                  2025-03-20 레몬베이스 작성하기                     8.8
 8  5min                             CTMS 아키텍쳐 다이어그램 그리기           0
 2  8min CTMS_CI_PIPELINE            webapp                                    1

# task 수정
task modify 1 장보기 말고 보자기 project:job due:2d

# 오늘 완료된 task 보기
task end.after:yesterday completed
```
- docs: https://taskwarrior.org/docs/
# references
- 
# connections
- 
---
at: 2024-08-19 22:30
tags:
  - JVM
  - Java
  - kotlin
created: 2024-08-19 22:26
updated: 2025-03-31 13:15
gh-page: true
---
### memo
JVM 의 @Volatile 변수 란?
- **Thread safety 한 변수 선언.** 단, 항상 Safe 한 것은 아님
- JVM 에 적제된 변수 메모리를 caching 하지 않음
	- 보통은 cache 에 적재 후 수정하고 언제 main 메모리에 재적재할 지 알 수 없음
- 어떤 이유때문인지 다음의 상황에서만 Thread safety 함
	1. 한 쓰레드만 쓰고, 다른 쓰레드들은 읽기만 할 때
	2. 여러쓰레드가 Atomic 하게 값을 쓰는 경우. 새로운 값이 이전 값에 의존하지 않는 상황.
		- ex. 다음은 원자적이지 않다 `value = value + 1` (읽고, 더하고, 쓰고)
		- 단순 대입은 원자적이다

사용법
- JAVA - volatile 한정자 사용
	- ex. `private volatile Boolean flag`
- Kotlin - @Volatile 어노테이션 사용
	- ex.
	  ```
	  @Volatile
	  val flag: Boolean;
		```

### references
- 
### connections
- 
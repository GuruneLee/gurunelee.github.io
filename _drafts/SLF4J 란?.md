---
create: 2025-01-14 23:28
update: 2025-01-14 23:28
tags:
  - Java
gh-page: true
created: 2025-01-14 23:27
updated: 2025-03-31 13:17
---
# memo
> Simple Logging Facade for Java (SLF4J)

다양한 로깅 프레임워크의 공통화된 추상화 레이어를 제공하는 라이브러리 (e.g `java.util.loggin`, `log4j 1.x`, `reload4j`, `logback` ...). 
- **개발 단계**에선 SLF4J 에서 제공하는 API 를 이용해 **단일한 로깅 코드**를 작성할 수 있음
```java
import org.slf4j.Logger; 
import org.slf4j.LoggerFactory; 
public class HelloWorld { 
	public static void main(String[] args) { 
		Logger logger = LoggerFactory.getLogger(HelloWorld.class);
		logger.info("Hello World"); 
	} 
}
```
- **배포 단계**에서 SLF4J API와 함께 실제 로깅 프레임워크(구현체)의 JAR 파일을 포함하여 실행 환경에서 동작하도록 설정함.
	- 예를 들어, 다음과 같이 logback 의존성을 추가했다면 logback 을 구현체로 사용하게 됨
	- `To switch logging frameworks, just replace slf4j bindings on your class path.`
```xml
<!-- logging -->  
<dependency>  
    <groupId>ch.qos.logback</groupId>  
    <artifactId>logback-classic</artifactId>  
    <version>1.2.11</version>  
</dependency>  
<dependency>  
    <groupId>org.slf4j</groupId>  
    <artifactId>slf4j-api</artifactId>  
    <version>1.7.36</version>  
</dependency>
```
## MDC (Mapped Diagnostic Context)
MDC 란, 진단 정보를 관리를 의미하는 **개념적 용어** 로, 로그가 실제 발생하는 코드 외에 스레드별 추가 진단 정보를 관리하고, 이를 로그 출력에 활용할 수 있도록 설계된 패턴이다.

SLF4J 는 MDC 를 지원하며, 특히 Java 의 `ThreadLocal` 을 활용하여 쓰레드별 정보를 관리한다. 특히 `logback` 설정 파일 (e.g `logback.xml`) 에선 특정 문자열 (e.g `%X{_KEY_NAME_}`) 을 사용해 MDC 값을 참조할 수 있다.
### MDC 활용 사례
1. 트랜잭션 추적: 분산 시스템에서 요청 ID(`traceId`) 를 MDC에 저장해 로그를 통해 특정 요청의 흐름을 추적.
2. 사용자 세션 정보 로깅: 사용자 ID나 세션 ID를 로그 메시지에 추가. 장애가 발생해 실패한 요청 추적 가능.
3. 멀티스레드 환경: 스레드별 데이터를 독립적으로 유지하여, 동시에 처리되는 요청 간의 충돌을 방지.
### MDC 사용 시 주의사항
1. **쓰레드 풀** 사용 시 MDC 전파: 
    - 쓰레드 풀 환경에선 MDC 데이터가 전파되지 않을 수 있다 (e.g `reactor`). 이땐, `MDCAdapter` 또는 다른 라이브러리 (`TaskDecorator`) 를 사용하여 해결 가능.
	- 쓰레드 풀에 대한 내용은 [[cubeCTMS 쓰레드 풀 (feat. UserContext)]] 를 참고하자
2. **코루틴** 사용 시 MDC 전파
	- 코루틴은 기본적으로 하나의 쓰레드에서 여러 코루틴이, 하나의 코루틴이 여러 쓰레드를재사용하며 수행될 수 있어서 MDC 가 자동으로 전파되지 않는다.
	- 해결책으로는 `CoruutineContext` 를 MDC 용으로 구현하여 전파하는 방법 (`TaskDecorator` 와 비슷함) 과 `CoroutineDispatcher` 를 사용하여 MDC 데이터를 전달하는 방법이 있다 (from chagGPT)

# references
- [SLF4J user manual](https://www.slf4j.org/manual.html)
# connections
- 
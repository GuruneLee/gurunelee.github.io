---
at: 2024-08-22 23:56
tags:
  - Spring
  - springboot
gh-page: true
created: 2024-08-22 23:56
updated: 2025-03-31 13:18
---
- https://medium.com/@tecnicorabi/why-configurationproperties-beats-value-in-spring-boot-a-simple-guide-for-developers-a88548013046 내용 참고해서 보충 ㄱㄱ
	-  테스트시 스프링컨텍스트는 mockk mockito로 커버가 가능함

# memo
## Spring 과 Spring boot 의 Properties
Spring 에선 @PropertySource 어노테이션에 classpath 하위의 설정파일 경로를 입력함으로써 설정파일을 추가(register)하고, @Configuration 을 해당 클래스에 적용해서 연결하는 방법이 사용되었다
```java
@Configuration
@PropertySource("classpath:foo.properties")
public class PropertiesWithJavaConfig {
    //...
}
```
이렇게 추가된 설정파일에서 값을 가져올 땐, @Value 어노테이션을 사용하였다.
```java
@Value( "${jdbc.url:aDefaultUrl}" )
String jdbcUrl;
```

Spring boot 에선 src/main/resources 하위의 application.properties 를 자동으로 프로퍼티 파일로 인식하여 파일경로와 @PropertySource 없이 설정파일을 유치(register)할 수 있게 개선되었다. 이로써 src/main/resources 하위에 추가된 파일의 property 라면, 경로입력 없이 @Value 를 사용할 수 있게 된 것이다.
( 더 자세한, Spring 과 Spring boot 의 Properties 관련 내용은 다음 [블로그](https://www.baeldung.com/properties-with-spring)를 살피자)

## @ConfigurationProperties for Hierarchical Properties
이렇게 편리해진 Spring boot 기능엔 계층적으로 그룹화된 Properties 를 한 번에 가져올 수 있는 @CofigurationProperties 가 포함되어있다. 이를 활용하면 prefix 선언 만으로, 해당 prefix 를 가진 프로퍼티를 한 번에 [[POJO 란?|POJO]] 로 가져올 수 있게된다. Spring 과 마찬가지로 @Configuration 을 적용해 Bean 으로 등록할 수 있다
```java
@Configuration
@ConfigurationProperties(prefix = "mail")
public class ConfigProperties {
    
    private String hostName;
    private int port;
    private String from;

    // standard getters and setters
}
```

특히 Spring boot 에선 @Value 대신 @ConfigurationProperties 를 사용할 것을 권장한다 (공식문서에서 각 프로퍼티를 독립된 POJO 로 관리하는것을 추천한다고 한다 ([여기](https://www.baeldung.com/configuration-properties-in-spring-boot#simple-properties)))
![[Pasted image 20240823010106.png| Spring docs > Injection-configuration-properties에서 발췌]]
# references
- [Spring docs > @Value annotation](https://docs.spring.io/spring-framework/reference/core/beans/annotation-config/value-annotations.html#page-title)
- [Spring boot 의 @ConfigurationProperties 에 대한 모든것](https://www.baeldung.com/configuration-properties-in-spring-boot)
- [Spring, Spring boot 의 Proprties 에 대한 모든 것](https://www.baeldung.com/properties-with-spring)
- [Spring docs > Injecting-configuration-propeprties](https://docs.spring.io/spring-framework/reference/languages/kotlin/spring-projects-in.html#injecting-configuration-properties)
# connections
- 
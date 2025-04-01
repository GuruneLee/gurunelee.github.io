---
gh-page: true
created: 2024-07-11 15:05
updated: 2025-03-31 13:18
---


# 네 종류의 요청, 응답 객체 변환 방법
**Spring Converter** 등록 (WebMvcConfigurer)
- request param 을 Argument 로 변환
- source -> @RequestParam 변수명 (requestParam 이름)
**Spring ArgumentResolver** 등록 (WebMvcConfigurer)
- Http 의 정보(주로 Header)를 Argument 로 변환
**Jackson Serializer / Deserializer** 선언 (class, dto 어노테이션 선언)
- Jackson 의 Object mapper 동작을 결정
- Json 타입의 Message converter 에서 사용
**Spring message converter** 구현하기 (여러 방법)
- Http 의 타입에 따라 Message converter 를 결정하여 Java 객체로 변경
- [[Message converter (aka. mc)]] 참고

## Converter 와 Formatter 에 관해서
### Converter 란? (Formatter 도 비슷함)
[Spring Type Conversion](https://docs.spring.io/spring-framework/reference/core/validation/convert.html)
- core.convert 패키지: Spring 의 type 변환 시스템을 제공하는 패키지 
- Converter 인터페이스: convert 패키지에 포함된 type 변환 인터페이스. Spring 시스템에서 활용할 수 있는 컨버터를 구현할 수 있다
	- 여러 관련 인터페이스 존재: ConverterFactory, GenericConverter, ConditionalGenericConverter, *ConversionService*

### Spring MVC 활용
 WebMVC 설정([MVC Config](https://docs.spring.io/spring-framework/reference/web/webmvc/mvc-config.html)) 중 FormatterRegistry에 등록해서 핸들러 Argument 타입 변환에 사용할 수 있다
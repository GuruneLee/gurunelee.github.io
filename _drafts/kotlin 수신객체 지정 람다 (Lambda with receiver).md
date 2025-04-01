---
at: 2024-08-23 15:06
tags:
  - kotlin
gh-page: true
created: 2024-08-23 15:06
updated: 2025-03-31 13:13
---
# memo
수신객체 지정 람다 (Lambda with receiver) 에 대해 알아보자

Kotlin 의 Function type 중, `A.(B) -> C` 이렇게 생긴게 있는데, 여기에 있는 `A` 가 바로 **receiver** 다.
- `A.() -> C`: A 객체에서 호출하고 C 를 반환하는 함수 타입
	- functions that can be called on a receiver object `A` and return a value `C`
	- 이런 타입을 갖는 람다를 **수신객체 지정 람다** 라고 한다

리시버를 정확히 이해하기 위해선 `A.() -> C`(리시버) 와 `(A) -> C`(파라미터) 의 차이를 알아야 한다. 가장 큰 차이는 리시버 람다는 수신객체를 this 로, 파라미터 람다는 파라미터를 it 으로 참조한다는 것이다
```kotlin
// Kotlin 의 scope function, also 와 apply
/** 
 * 리시버 람다를 받는 apply
 * public inline fun <T> T.apply(block: T.() -> Unit): T {  
 *     block()  
 *     return this  
 * } */
person.also {
	println("hi, ${it.name}")
}

/** 
 * 파라미터 람다를 받는 also
 * public inline fun <T> T.also(block: (T) -> Unit): T {  
 *     block(this)  
 *     return this  
 * } */
person.also {
	println("hi, ${this.name}") //this 생략 가능
}
```

이름 그대로 **리시버가 있는 람다**를 **수신객체 지정 람다 (Lambda with receiver)** 라고 한다.
`this` 와 `it` 의 차이는 [[kotlin scope function - this 와 it]] 에서 살펴보자


# references
- https://jaeyeong951.medium.com/kotlin-lambda-with-receiver-5c2cccd8265a
- https://kotlinlang.org/docs/lambdas.html
# connections
- [[kotlin scope function]]

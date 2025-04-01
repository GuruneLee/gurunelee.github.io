---
at: 2024-09-26 13:49
tags:
  - uml
  - tool
  - cs
gh-page: true
created: 2024-09-26 13:49
updated: 2025-03-31 13:23
---
# memo
UML 의 Class Diagram 에선 화살표를 사용해 클래스간 연관관계를 표시한다. 자세하게 알아보도록 하자

- [[UML Class Diagram 화살표 종류#연관 관계|연관관계]]
	- [[UML Class Diagram 화살표 종류#Association|연관 (Association)]]
	- [[UML Class Diagram 화살표 종류#Dependency|의존 (Dependency)]]
- [[UML Class Diagram 화살표 종류#부분-전체 관계|부분-전체 관계]]
	- [[UML Class Diagram 화살표 종류#Aggregation|집합(Aggregation)]]
	- [[UML Class Diagram 화살표 종류#Composition|합성(Composition)]]
- [[UML Class Diagram 화살표 종류#Inheritance|상속 (Inheritance)]]
- [[UML Class Diagram 화살표 종류#Realization / Implementation|구현 (Implementation)]]

## 연관 관계
> [!tldr] 
> **Association**은 두 클래스가 상호 연관된 상태로 존재할 수 있지만 독립적입니다.
> **Dependency**는 클래스가 다른 클래스를 일시적으로 참조하는 느슨한 관계로, 지속적인 관계가 아닙니다.
### Association
> 두 클래스가 연관되어 있다
- 참조 관계를 의미하며 Directed / Undirected 로 표현할 수 있다
- 클래스간 생명주기는 관리되지 않는다 (독립적 존재)
	- Driver 가 Car 를 사용하지만, 생명주기는 관리하지 않는다
```plantuml
class Car
class Driver

Driver --> Car :Driver 에서 Car 를 참조하고 있다 
```

### Dependency
> 한 클래스가 다른 클래스에 일시적으로 의존하고 있다
- 일시적 의존관계를 의미한다
	- 결합은 없다
- B 클래스가 A 클래스의 메서드 파라미터, 반환값, 로컬변수 등으로 사용되고 있다
```plantuml
class A
class B

A ..> B : A 에서 B 를 의존하고있다
```

## 부분-전체 관계
> [!tldr] 
> **Aggregation**은 부분 객체가 독립적으로 존재할 수 있는 약한 "부분-전체" 관계입니다. (집합 관계)
> **Composition**은 전체 객체가 사라지면 부분 객체도 사라지는 강한 "부분-전체" 관계입니다. (합성 관계)
### Aggregation
> 한 클래스가 다른 클래스와 약한 전체-부분 관계에 있다
- 전체 클래스와 부분 클래스 사이의 약한 포함관계
	- 약한 포함관계: 전체가 사라져도 부분이 남아있을 수 있다 (독립적 존재)
```plantuml
class Library
class Book

Library --o Book
```

### Composition
> 한 클래스가 다른 클래스와 강한 전체-부분 관계에 있다
- 전체 클래스와 부분 클래스 사이의 강한 포함관계
	- 강한 포함관계: 전체가 사라지면 부분도 함께 사라진다
```plantuml
class House
class Room

House --* Room
```

## Inheritance
> 한 클래스가 다른 클래스를 상속하고 있다
- 빈 삼각형 머리와 실선으로 표현한다 
- Generalization (일반화) 라고 표현하기도 한다
```plantuml
class Parent
class Child

Child --|> Parent : Child 가 Parent 를 상속하고 있다
```

## Realization / Implementation
> 한 클래스가 어떤 인터페이스를 구현하고있다
- 빈 삼각형과 점선으로 표현한다
```plantuml
interface Drivable
class Car

Car ..|> Drivable : Car 가 Drivable 을 구현하고있다
```



# references
- 
# connections
- 
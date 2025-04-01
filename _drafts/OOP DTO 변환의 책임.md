---
at: 2024-09-11 11:06
tags:
  - oop
created: 2024-09-11 11:05
updated: 2025-03-31 13:16
gh-page: true
---
# memo
> Q 도메인 엔티티랑 request dto 관계가 있을 때, 
> 도메인 엔티티가 dto 변환을 담당해야할까?  dto가 도메인 엔티티를 받아서 [[Factory Method Pattern 과 Static Factory Method|정적 팩토리 메서드]]로 생성하게끔 할까?

A.   
의존 관계가  
1. 엔티티 <- dto
2. dto <- 엔티티
일 때1이 더 맞는거 같아요. 엔티티가 Dto 에 의존하는건 주객전도에요
dto 가 도메인 엔티티를 받는게 맞지 않나요?

아예 DTO 의 책임에서 제거하는게 맞는것 같다.
![[Pasted image 20250312121254.png]]
![[Pasted image 20250312121327.png]]

:: 확장함수 혹은 private 메서드를 사용하자


# references
- 
# connections
- 
---
at: 2024-09-19 23:07
tags:
  - Hibernate
  - JPA
gh-page: true
created: 2024-08-05 23:14
updated: 2025-03-31 13:11
---
# memo
> ORM 에서 특정 객체를 대상으로 수행한 쿼리가, 해당 객체와 연관관계를 가진 객체들 또한 조회하게 되며, 추가적인 N번의 쿼리가 발생하는 문제

## TL;DR
> 1) **1:1 연관관계**는 최대한 **fetch join**을 활용하고 **컬렉션 연관관계**는 **default_batch_fetch_size**활용.
> 2) 많은 컬럼 중 **특정 컬럼만 조회**해야 할 경우나 **커버링 인덱스를 활용**하고 싶은 경우 데이터 전송량을 줄이고 싶으면 일반 Join을 하고 Projection하여 Dto로 바로 변환. 
> 	다만 이 경우 DAO객체를 분리하여 작성하는 것이 좋음


## 원인
JPA 의 N+1 은 의도하지 않은 연쇄 쿼리가 발생하는 문제이다.
근본적인 원인으론 **ORM와 RDB의 패러다임 차이** 라고 생각할 수 있다. 객체에선 연관관계에 언제든지 *Random Access* 로 접근할 수 있지만 RDB 는 `SELECT` 쿼리를 통해서만 조회가 가능하기 때문이다.

## 예시
아래 코드에서 `Article` 은 `Opinion` 리스트를 가지고 있다. `ArticleRepository`에서 `Article` 을 조회하는 메서드를 실행하면, 1개의 `SELECT` 문이 발행될 것이라 생각되지만,
*FetchType.Lazy* 설정으로 인해 연관된 `Opinion` 리스트는 *프록시 객체*로 존재하고 있다가, 해당 컬렉션을 코드내에서 조회하는 순간 (`article.opinions`) `Opinion` 객체에 대한 N개의 쿼리가 발생하게 된다.
```java
@Entity
public class Article extends BaseEntity{
    @OneToMany(mappedBy = "article", fetch = FetchType.LAZY, cascade = CascadeType.REMOVE)
    private List<Opinion> opinions = new ArrayList<>();
}
```

```sql
// Article 조회
select (생략)
from article

// Opinion 리스트 Random access
select (생략)
from opinion op0_
where op0_.arcicle_id=?

select (생략)
from opinion op1_
where op1_.arcicle_id=?

-- N개의 SELECT 발행
```

이렇게 N 배의 쿼리가 한 번에 발행됨은 물론, `Opinion` 객체에 또 다른 연관관계가 있다면 다중 레퍼런싱으로 인해 N^2, N^3 개의 쿼리도 발생할 수 있다.

## 해결방법
### 1. Eager loading (하면 안돼)
`JOIN` 을 사용하여 연관된 객체를 한 번에 가져오는 기능.
```java
@Entity
public class Article extends BaseEntity{
    @OneToMany(mappedBy = "article", fetch = FetchType.EAGER, cascade = CascadeType.REMOVE)
    private List<Opinion> opinions = new ArrayList<>();
}
```

어떤 범위까지 Join 쿼리로 조회할 지 예상하기 힘들어 필요없는 데이터를 로딩할 수 있고, 
복잡한 Entity 관계에 대해선 더 큰 N+1 문제를 야기할 수 있다.

### 2. Fetch Join + Lazy Loading
*Fetch Join* 은 Root Entity 에 대해서 조회할 때, Lazy Loading 으로 설정된 연관관계를 Join 쿼리를 발생시켜 한 번에 조회하는 *JPQL* 기능이다.
```java
@Query("select Distinct art from Article art join fetch art.opinions")
List<Article> findAllArticleFetchJoinOpinion();
```

```sql
// 결과 쿼리
select
        distinct article0_.article_id as article_1_2_0_,
        opinions1_.opinion_id as opinion_1_11_1_,
        article0_.created_at as created_2_2_0_,
        article0_.updated_at as updated_3_2_0_,
        opinions1_.article_id as article10_11_1_,
        ...
        opinions1_.opinion_id as opinion_1_11_0__ 
    from
        article article0_ 
    inner join
        opinion opinions1_ 
            on article0_.article_id=opinions1_.article_id
```

SELECT ARTICLE, SELECT OPINION-1, SELECT OPINION-2 이렇게 세 번 발생하던 쿼리를 
SELECT ARTICLE JOIN OPNION ON ART_ID 이렇게 한 번에 조회할 수 있게 해준다

*Fetch Join* 에 관련한 자세한 개념은 [[JPA Fetch Join]] 을 확인하자

### 3. default_batch_fetch_size, @BatchSize 옵션 사용하기
> Lazy Loading 시 프록시 객체를 조회할 때 where in 절로 묶어서 한 번에 조회할 수 있게 해주는 옵션

yml 에 전역옵션으로 적용할 수도 있고 (autoconfig), `@BatchSize` 어노테이션으로 연관관계 BatchSize 를 다르게 적용할 수 있다 ([[Cursor]])
```yml
spring:
  jpa:
    properties:
        default_batch_fetch_size: 100
```
```java
@Target({TYPE, METHOD, FIELD})
@Retention(RUNTIME) 
public @interface BatchSize { 
	int size(); 
}
```

Fetch Join 과 BatchSize 의 비교는 [[JPA Fetch Join vs Batch Size]] 에서 정리한다

### 4. @EntityGraph
> Lazy loading 을 부분적으로 Eager Loading 으로 전환하는 옵션

Fetch Join 과의 차이점
- 여러 1:N 관계를 *한 번에* Join 해올 수 있다 (Fetch Join 의 경우 Collection 한 개만 Join 가능)

```java
public interface ArticleRepository extends JpaRepository<Article, Long> , ArticleRepositoryCustom {
    @EntityGraph(attributePaths = {"articleMatchConditions"}) // Entity 멤버 이름
    Optional<Article> findEntityGraphArticleMatchConditionsByApiIdAndIsDeletedIsFalse(String articleId);

    @EntityGraph(attributePaths = {"articleMembers"})
    Optional<Article> findEntityGraphArticleMembersByApiIdAndIsDeletedIsFalse(String articleId);
    }
```

### 5. 일반 Join 후 Projection 하여 특정 칼럼만 Dto 로 조회
```kotlin
@Query("""
	select new 패키지 경로.ArticleDto(원하는 필드) 
	from Article ar
	join ar.opinions op
	where op.article_id = ar.id
""")
```
1. 장점: Entity Column이 많을 때 Projection하여 특정 컬럼만 조회할 수 있음, 커버링 인덱스 활용가능성 상승.
2. 단점: 영속성 컨텍스트와 무관하게 동작하고 Repository가 Dto에 의존하게 되기 때문에 API변경에 DAO도 수정되어야 할 수 있음.
-> 이 방식을 사용하는 쿼리는 DAO를 분리하는 것이 좋음.

# references
- [JPA N+1 문제와 해결법 총정리](https://velog.io/@xogml951/JPA-N1-%EB%AC%B8%EC%A0%9C-%ED%95%B4%EA%B2%B0-%EC%B4%9D%EC%A0%95%EB%A6%AC)
- [커버링 인덱스란](https://velog.io/@boo105/%EC%BB%A4%EB%B2%84%EB%A7%81-%EC%9D%B8%EB%8D%B1%EC%8A%A4)
# connections
- [cubeCTMS 엑셀 다운로드 로직 개선 mr](https://gitlab.crsdev.io/ctms/ctms-api/-/merge_requests/1044) 과 연관이 있다고 생각했는데 Batch size 가 아니라 Fetch size 였네요

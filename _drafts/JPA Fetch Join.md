---
at: 2024-09-19 23:33
tags:
  - JPA
gh-page: true
created: 2024-09-19 23:33
updated: 2025-03-31 13:10
---
# memo
## Fetch Join 과 Join 의 차이
> Fetch Join 은 ORM 과 RDB 의 패러다임의 차이를 줄이기 위한 JPQL 의 문법이다

`Fetch Join` 은 JPQL 에만 존재하는 문법으로, ORM 에서의 사용을 전제로 DB Schema 를 Entity 로 자동 변환 해주고, 영속성 컨텍스트에 영속화해준다.
- Fetch Join 을 통해 조회하면 연관관계가 영속성 컨텍스트 1차 캐시에 저장되어, 다시 엔티티 그래프를 탐색하더라도 조회 쿼리가 수행되지 않는다 (**엔티티 그래프 유지**)
- Join 쿼리는 단순 sql 쿼리이므로, 연관관계가 영속화 되지 않아서, 재접근 시 다시 SELECT 문을 날린다 (*확인필요*)

## Collection 연관관계 Fetch Join 시 주의사항
### 0. 조회의 결과
1대다 매핑에 Fetch Join 을 사용할 경우, SQL Native Join 쿼리가 발생하게 되고, 1쪽의 Root Entity 는 중복된 상태로 조회하게 된다.

| 레코드 | Article | Opinion |
| --- | ------- | ------- |
| 1   | Art-1   | Op-1    |
| 2   | Art-1   | Op-2    |
| 3   | Art-1   | Op-3    |
### 1. JPQL의 Distinct 절을 사용해야 한다
위 조회결과대로 객체를 생성하게 되면, 동일한 Article 객체가 N 개 존재하게 된다.
따라서, `JPQL` 에서 지원하는 `Distinct` 절을 사용하여, 이 문제를 막아야 한다
- JPQL 의 Distinct 절은 Root Entity 에 대해서만 distinct 를 수행한다
- 따라서, 위 조회결과에선 Article 한 개, Opinion 객체 세 개가 생성된다
```java
@Query("select Distinct art from Article art join fetch art.opinions")
List<Article> findAllArticleFetchJoinOpinion();
```

### 2. Collection Fetch Join 은 하나까지만 가능하다
여러 Collection 에 대해 Fetch join 을 하면 잘못된 결과가 발생하기 때문에, 꼭 한 연관관계에 대해서만 사용해야한다
```java
// 잘못된 사용
@Query("select Distinct art from Article art join fetch art.opinions join fetch art.articleRefs")
List<Article> findAllArticleFetchJoinOpinionFetchJoinArticleRef();
```

### 3. paging 을 사용해선 안된다 (OOM 발생가능)
Collection Fetch Join 에서 Paging 할 경우 다음과 같이 *Paging 을 Memory 위에서 하고 있다* 라는 Warning 이 발생한다
```null
2022-01-16 12:37:18.309  WARN 39536 --- [           main] o.h.h.internal.ast.QueryTranslatorImpl   : HHH000104: firstResult/maxResults specified with collection fetch; applying in memory!
```

블로그 내용이 길다. 그대로 첨부할테니 읽어보자
- [[JPA Collection Fetch Join 에 paging 을 사용하면 안되는 이유]]



# references
- https://velog.io/@xogml951/JPA-N1-%EB%AC%B8%EC%A0%9C-%ED%95%B4%EA%B2%B0-%EC%B4%9D%EC%A0%95%EB%A6%AC#%EC%9E%90%EC%84%B8%ED%95%9C-%EA%B0%9C%EB%85%90
# connections
- 
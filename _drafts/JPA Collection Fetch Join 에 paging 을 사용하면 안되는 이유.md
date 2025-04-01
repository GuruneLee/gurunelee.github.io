---
at: 2024-09-19 23:49
tags:
  - JPA
gh-page: true
created: 2024-09-19 23:49
updated: 2025-03-31 13:10
---
# memo
- Collection Fetch Join에서 Paging을 할 경우 다음과 같은 발생하게 됩니다. 이를 해석해보면 'Paging을 Memory에서 하고 있다.'라는 의미입니다.
```null
2022-01-16 12:37:18.309  WARN 39536 --- [           main] o.h.h.internal.ast.QueryTranslatorImpl   : HHH000104: firstResult/maxResults specified with collection fetch; applying in memory!
```

- 이런 문제가 발생하는 이유는 첫번째로 JPA는 DB table에서 레코드 관계를 영속화된 Entity형태로 완벽하게 표현하는 것을 전제로 하기 때문입니다. 예를 들어 Article1에 2개의 댓글이 써있고 Article2에 2개의 댓글이 써 있다면 영속화 되어있는 Entity는 무조건 이 관계를 그대로 표현하여 Article1 Entity의 Collection에는 2개의 Opinion이 있고 Article2 Entity의 Collection에는 2개의 Opinion이 있어야 합니다.
- 하지만, 만약 paging을 위에서 Native SQL Join쿼리에 의해서 생긴 스키마에 대해서 하게 된다면 Application, JPA입장에서는 실제 DB 레코드의 관계와 다른 데이터를 받게 될 수 있고 누락된 레코드 관계가 있다는 것을 알 수가 없게 됩니다. page size를 3으로 적용하면 다음과 같이 데이터를 가져오게 되고 Article2는 Opinion을 1개만 가지고 있는것으로 알게 됩니다.

|레코드|Article|Opinion|
|---|---|---|
|1|Article1|Opinion1|
|2|Article1|Opinion2|
|3|Article2|Opinion3|
- 이러한 문제를 방지하고 객체 관점에서 paging을 적용하기 위해 JPA에서 Paging을 하게 되면 join쿼리 레코드 관점이 아니라 조회 주 대상 Entity에 대해서(Select 단어 바로 다음에 나오는 객체) paging을 적용합니다. 이 경우에는 Article이 대상이 될 것입니다.
- 만약, 해당 JPQL에서 page size 3을 하면 Article을 3개까지만 가져오는 의미이고 Article이 두개 이므로 모두 가져올 수 있게 됩니다.
- 여기 까지는 별 문제가 없는 것 같은데 이러한 동작 방식이 Out Of Memory를 일으킬 수 있고 이는 처음에 보았던 경고 문구와 완계가 있습니다.
- **JPA에서 Join으로 받아온 데이터를 JPQL관점에서 주 Entity를 기준으로 Pagination을 하려면 테이블의 모든 데이터를 Application Server의 Memory로 로딩해야하기 때문입니다. 이 때문에 앞전에 보았던 경고문구가 발생한 것이고 이는 메모리 과부하로 장애 요인이 될 수 있습니다**.
- 따라서 컬렉션 Fetch Join에서는 Paging을 절대로 해서는 안됩니다.
- 꼭 paging이 필요하다면 일반 Join쿼리를 활용하거나 아니면 뒤에 나올 BatchSize 옵션을 설정하여 활용하는 것이 바람직합니다.

# references
- https://velog.io/@xogml951/JPA-N1-%EB%AC%B8%EC%A0%9C-%ED%95%B4%EA%B2%B0-%EC%B4%9D%EC%A0%95%EB%A6%AC#%EC%9E%90%EC%84%B8%ED%95%9C-%EA%B0%9C%EB%85%90
# connections
- 
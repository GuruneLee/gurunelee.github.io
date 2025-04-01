---
at: 2024-09-20 00:05
tags:
  - JPA
gh-page: true
created: 2024-09-20 00:05
updated: 2025-03-31 13:11
---
# memo
## Fetch Join의 한계를 Batch Size으로 해결가능
- Collection Fetch Join시 **paging문제**나 **1개까지만 Fetch Join을 할 수 있는 문제**를 해결할 수 있습니다.
## 쿼리 개수 관점으로는 Fetch Join 이 유리
- *쿼리 개수*는 Fetch Join이 유리합니다. Batch Size의 경우 몇번의 쿼리가 더 발생될 수 있습니다.

## 데이터 전송량 관점
- *데이터 전송량* 관점에서는 Batch Size가 유리합니다. 
- Fetch Join은 Join을 하고 나서 가져오기 때문에 중복 데이터를 많이 가져와야하기 때문입니다.

### Fetch Join의 경우

|레코드|Article|Opinion|
|---|---|---|
|1|Article1|Opinion1|
|2|Article1|Opinion2|
|3|Article2|Opinion3|
|4|Article2|Opinion4|
### BatchSize의 경우

|레코드|Article|
|---|---|
|1|Article1|
|2|Article2|

|레코드|Opinion|
|---|---|
|1|Opinion1|
|2|Opinion2|
|3|Opinion3|
|4|Opinion4|

# references
- https://velog.io/@xogml951/JPA-N1-%EB%AC%B8%EC%A0%9C-%ED%95%B4%EA%B2%B0-%EC%B4%9D%EC%A0%95%EB%A6%AC#fetch-join-vs-batch-size
# connections
- 
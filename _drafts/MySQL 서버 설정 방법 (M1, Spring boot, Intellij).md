---
at: 2024-05-19 22:59
tags:
  - config
  - mysql
  - springboot
  - intellij
gh-page: true
created: 2024-06-16 23:54
updated: 2025-03-31 13:16
---
# memo
## docker 로 My SQL 실행 (Mac M1)
1. open -a Docker
	 - Docker desktop app 실행
2. docker pull arm64v8/mysql:8.0.37
	- M1 은 arm64v8 버전으로 받아야함 ( processor 별 mysql 이미지 있으니 찾아서 사용하기 [Official images -  Architectures other than amd64?](https://github.com/docker-library/official-images?tab=readme-ov-file#architectures-other-than-amd64) )
3. docker run -p 3306:3306 --name local-mysql -e MYSQL_ROOT_PASSWORD="0216" -d arm64v8/mysql:8.0.37 --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci --lower_case_table_names=1
	- MYSQL_ROOT_PASSWORD
	- --character-set-server
	- --collation-server
	- lower_case_tabe_name

## Intellij Mysql 프로필 등록
- 사용자를 등록하지 않았다면 root 사용자로 프로필 생성
- database 를 생성하지 않았으므로 프로토콜과 도메인 주속까지만 입력
	- `jdbc:mysql://` : JDBC가 MySQL에 연결하기 위한 프로토콜
	- `127.0.0.1:3306` : Local MySQL 서버의 호스트와 포트
![[Pasted image 20240524003342.png]]


## spring boot 설정 (application.yml) 
```
spring:
  datasource:
    hikari:
      max-lifetime: 420000
      connection-timeout: 10000
      validation-timeout: 10000
      idle-timeout: 30000
      username: root
      password: "0216"    
      driver-class-name: org.mariadb.jdbc.Driver
      maximum-pool-size: 50
      jdbc-url: jdbc:mariadb://127.0.0.1:3306/DEMO
    url: jdbc:mariadb://127.0.0.1:3306/DEMO
  jpa:
    hibernate:
      ddl-auto: validate
    properties:
      org.hibernate.envers.audit_table_suffix: _HIS
      org.hibernate.envers.modified_flag_suffix: _CHANGED
      hibernate.jdbc.time_zone: UTC
      hibernate.format_sql: true
      hibernate.jdbc.batch_size: 100
      hibernate.jdbc.order_inserts: true
      hibernate.query.in_clause_parameter_padding: true
    open-in-view: false
```


# references
- 
# connections
- 
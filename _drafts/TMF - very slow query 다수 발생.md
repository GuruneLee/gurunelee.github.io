---
at: 2024-06-27 16:26
tags:
  - bug-report
  - crscube
  - cubeTMF
  - database
gh-page: true
created: 2024-06-27 16:25
updated: 2025-03-31 13:36
---
# Report
## 현상
- TMF Very slow query 다수 발생
	- 응답시간 밀리는것은 물론, 모두 실패함
	- 문제 발생 유력 원인 = 대량 파일 업로드
	- ![[Pasted image 20240627164439.png]]
	- ![[Pasted image 20240627164348.png]]
## 원인
1. DB Connection Timeout 설정이 '-1' 로 되어있음
   ```xml
    <!-- run.sh - 프로젝트 실행 스크립트 -->
    cat > META-INF/context.xml << EOL
	<?xml version="1.0" encoding="UTF-8"?>
	<Context privileged="true">
	<Resource name="jdbc/tmfDS"
	              auth="Container"
	              type="javax.sql.DataSource"
	              driverClassName="oracle.jdbc.OracleDriver"
	              url="${DBCP_URL}"
	              username="${DBCP_USER}"
	              password="${DBCP_PASSWORD}"
	              maxTotal="20"
	              maxIdle="10"
	              maxWaitMillis="-1"/>
	</Context>
	EOL
	```
2. Transaction Requires_new 로 DB Connection 을 물고있는 상태에서 새로운 Connection 을 요청한다
3. file uploads API 의 응답속도는 느리고, 트랜잭션을 오래 붙잡고 있다
	- addFile 소스코드 / pinpoint 로그
		- `uploadFileToS3andMakeCubeFile` 이 시간이 오래걸림
		 ![[Pasted image 20240627171052.png]]	  

	```java
	@Override
	@Transactional
	public CubeFile addFile(MultipartFile multipartFile, CubeFileType fileType, CubeFile cubeFileKeys) {
		// 1 - 351ms
		CubeFile cubeFile = uploadFileToS3andMakeCubeFile(multipartFile, fileType);
		// 2 - 9ms
		Long companyKey = getCurrentUserCompanyKey();
		if (companyKey != null) {
			cubeFile.setCompanyKey(companyKey);
		}
	
		if (cubeFileKeys != null) {
			setFileInfo(cubeFileKeys, cubeFile);
		}
		CubeFile addedCubeFile = addFileByType(cubeFile);
		if (cubeFile.getOriginalFile() != null && cubeFileKeys != null) {
			CubeFile originCubeFile = cubeFile.getOriginalFile();
			setFileInfo(cubeFileKeys, originCubeFile);
			originCubeFile.setFileType(CubeFileType.DOCUMENT);
			addedCubeFile.setOriginalFile(addFileByType(originCubeFile));
		}
		return addedCubeFile;
	}
	```
-> **커넥션 경합이 발생하여 DB Connection pool 고갈, 요청 대기, 응답시간 증가**

### 예상되는 다른 문제
- insert / update 할 때 sequence 받아오는 쿼리도 Trasaction requires_new 로 새로운 TX 를 연다
	- 따라서, 위와 동일한 문제 발생 가능성 높음
	  ```
	    @Override
	    @Transactional(propagation = Propagation.REQUIRES_NEW)
	    public Long getSequence(SequenceType sequenceType) {
	        return sequenceMapper.getSequence(sequenceType.getValue());
	    }
		```

## 해결책
- `uploadFileToS3andMakeCubeFile` 메서드는 DB 조회나 업데이트를 하지 않는다. 따라서 트랜잭션에 존재할 이유는 없으므로 분리한다.
- connection timeout 을 적절히 넣어서 경합이 풀릴 수 있도록 한다
- TX requires_new 를 제거하여 경합을 없앤다
	- Mabatis cache 때문이라면 [이 글](https://crscube.atlassian.net/wiki/spaces/TEAM3/pages/3458951493/006.+Mybatis+LocalCache)을 보자
# references
- [Spring Transaction REQUIRES_NEW Propagation 지옥 (with Mybatis Local session cache)](https://medium.com/@taesulee93/spring-transaction-requires-new-propagation-%EC%A7%80%EC%98%A5-with-mybatis-local-session-cache-cf71415889c8)
# connections
- 
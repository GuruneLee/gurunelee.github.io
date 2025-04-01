---
create: 2024-12-16 09:51
update: 2025-03-13T17:40:00
tags:
  - cubeCTMS
  - git
  - gitlab
created: 2024-12-16 09:51
updated: 2025-03-31 13:34
gh-page: true
---
# memo
## ::branch 원칙
- master 의 변경사항은 education 에 모두 반영되어야 한다.
- education 의 변경사항은 staging 에 모두 반영되어야 한다.
- staging 의 변경사항은 develop 에 모두 반영되어야 한다
### 변경사항 확인 방법
> `git log A..B --oneline`

![[Pasted image 20250313173219.png]] ![[Pasted image 20250313173224.png]]

## ::브랜치 관리 (git-flow)
### git-flow 다이어그램
```mermaid
---
title: 정기 브랜치 전략
---
%%{
	init: { 
		'theme': 'base', 
		'gitGraph': {
			'mainBranchName': 'master', 
			'titleTopMargin': 50
		}, 
		'themeVariables': { 
			'lineWidth': 1 
		} 
	}
}%%
gitGraph
	%% 정기 %%
	commit id: "initial commit" tag: "v1.1_B20241222"
	branch develop order: 4
	branch staging order: 2
	branch education order: 1
	commit
	checkout staging
	commit
	commit id: "Merge request for feture00"
	branch feature01 order: 3
	checkout feature01
	commit
	commit
	checkout develop
	merge feature01 id: "(optional) playground"
	
	checkout staging
	merge feature01 id: "Request leader review"
	checkout feature01
	commit id: "QA TC Fail"
	checkout staging
	merge feature01
	checkout develop
	merge staging id: "AUTO_MERGE (s->d)" type: HIGHLIGHT

	checkout education
	merge staging id: "Edu 이관"
	checkout master
	merge education id: "Real 이관" tag: "v1.1_B20250323"
```

```mermaid
---
title: 비정기 브랜치 전략
---
%%{
	init: { 
		'theme': 'base', 
		'gitGraph': {
			'mainBranchName': 'master', 
			'titleTopMargin': 50
		}, 
		'themeVariables': { 
			'lineWidth': 1 
		} 
	}
}%%
gitGraph
	%% 비정기 %%
	commit id: "initial commit" tag: "Initial version"
	branch education order: 1
	commit
	checkout master
	branch staging order: 2
	commit
	checkout master
	branch develop order: 5
	
	checkout master
	commit
	commit
	commit tag: "v1.1_B20250323"
	branch hotfix-250401 order: 3
	checkout hotfix-250401
	
	branch hotfix_feature1 order: 4
	checkout hotfix_feature1
	commit id: "bugfixes"
	commit

	checkout hotfix-250401
	merge hotfix_feature1
	
	checkout master
	merge hotfix-250401 tag: "v1.1_B20250629_20250123"
	checkout education
	merge master
	checkout staging
	merge education id: "Test here"
	checkout develop
	merge staging id: "AUTO_MERGE (s->d)" type: HIGHLIGHT
```
- 'Edu 서버 배포 / Real 서버 미배포' 기간의 테스트 및 배포 절차
	- 1) STG 서버엔 항상 정기이관 변경건과 비정기이관 변경건이 함께 배포되어있어야 한다.
	- 2) 비정기 변경건은 master 브랜치부터 staging 브랜치 까지 Top-down 으로 merge 되어야 한다.
	- -> **비정기 변경건을 staging 브랜치까지 모두 반영 후, staging 브랜치를 STG 서버에 배포하여 Test 한다. Test 가 통과하면 Edu 서버와 Real 서버를 차례대로 배포한다.**

```mermaid
---
title: cubeCTMS 브랜치 전략 (w/o develop)
---
%%{
	init: { 
		'theme': 'base', 
		'gitGraph': {
			'mainBranchName': 'master', 
			'titleTopMargin': 50
		}, 
		'themeVariables': { 
			'lineWidth': 1 
		} 
	}
}%%
gitGraph
	%% 정기 %%
	commit id: "initial commit" tag: "v1.1_B20241222"
	branch staging order: 2
	branch education order: 1
	
	commit
	checkout staging
	commit
	commit id: "Merge request for feture00"

	checkout education
	merge staging
	checkout master
	merge education

	%% 비정기 %%
	checkout master
	commit
	commit
	commit tag: "v1.1_B20250323"
	branch hotfix-250401 order: 3
	
	checkout hotfix-250401
	commit
	
	checkout master
	merge hotfix-250401 tag: "v1.1_B20250629_20250123"
	checkout education
	merge master
	checkout staging
	merge education
```

### develop 브랜치에 관하여
develop 브랜치엔 **Dev 서버에 제약없이 배포**할 수 있도록 파이프라인을 연결하였습니다. **신규 기능 및 설정의 PoC 를 주로 수행**하게 됩니다. 
(QA TC 는 Dev 서버에서 수행하면 안됩니다. TC 수행을 위해선 stgaing 에 머지 하여 Staging beta / real 서버에 배포해주세요.)

develop 브랜치엔 팀장/그룹장 리뷰 없이 merge 가 가능하여 개발자 스스로 Dev 배포가 가능하지만, **develop 브랜치에 merge할 때에도 Merge request (MR)** 흐름을 따라주시길 바랍니다.
CLI 를 통해 직접 revert 하는 것도 힘들 뿐 더러, 로컬에서 병합 후 리모트에 푸시 하는 것 보다 MR 을 통해 merge 이력을 남기는 것이 관리가 쉽습니다.
#### DB 스키마 변경 / PLSQL 변경 반영
DB 스키마 변경, PLSQL 스크립트 변경, 데이터 마이그레이션 등의 데이터베이스 관련 변경 건은 develop 머지 여부와 관련 없이 Dev DB 공간에 반영해야 합니다.
DB 변경 이력은 개발자가 직접 프로젝트 파일로 남기기 때문에 추적이 어렵고, CTMS 의 경우 CDMS 와 같은 DB 공간을 사용하므로 스키마 등 DB 오브젝트를 STG 에서 내려받는 것이 어렵습니다.
(\* 현재 Dev real 공간의 스키마가 다수 깨져있어 사용이 어려운 점 참고)

### 이관 태그 규칙
- 정기 이관 : `${수정버전.replace(' ', '_')}`
    - i.e. v1.1_B20241222
- 비정기 이관 : `${수정버전.replace(' ', '_')}_${비정기 날짜.format('YYYYMMDD')}`
    - i.e. v1.1_B20241222_20241231

### 특이사항::머지 자동화 (staging -> develop)
- Access token : 개인: `gitcube-dr-xBjhyjX1-pzccV2BT` 
	- WEBAPP: `gitcube-ZswxDAdX7dmd7dBsuKvp`
	- API: `gitcube-2iYsRWf4aQ5N84R1gd6X`
	- BATCH: `gitcube-XMDqsG3PSm89BEhHu_M8`
- ![[Pasted image 20250114170815.png]]

## ::CI/CD 파이프라인 구성
- Dev 서버: 개발자 테스트 공간 (AWS 등 CSP 설정 적용 테스트, EFS 사용기능 테스트)
- Stg 서버: QA 테스트 공간 (TC 등)
- Edu 서버: 교육 공간
- Prod 서버: 실제 서비스
### WEBAPP
```mermaid
---
title: ctms-webapp CI/CD
---
flowchart LR
	merge2[merge staging to develop]

	br1((develop))
	dev1[install]
	dev2[build:dev]
	dev3[deploy:dev]
    br1---dev1
    dev1-->dev2
    dev2-->dev3

	br2((staging))
	stg1[install]
	stg2[build:stg_beta]
	stg3[deploy:stg_beta]
	stg4[build:stg_real]
	stg5[deploy:stg_real]
    br2---stg1
    stg1-->stg2
    stg2-->stg3
    stg3-->stg4
    stg4-->stg5
    stg5-->merge2
    
	br3((educatn))
	edu1[install]
	edu2[build:prod_beta]
	edu3[deploy:prod_beta]
	br3---edu1
	edu1-->edu2
	edu2-->edu3

	br4((master))
	mst1[install]
	mst2[build:prod_real]
	mst3[deploy:prod_real]
	br4---mst1
	mst1-->mst2
	mst2-->mst3

	style br1 stroke:green,stroke-width:2px
	style br2 stroke:#333,stroke-width:2px
	style br3 stroke:#333,stroke-width:2px
	style br4 stroke:#333,stroke-width:2px
	style merge2 stroke:blue,stroke-width:2px
```
### API / BATCH
```mermaid
---
title: ctms-api CI/CD, ctms-batch CI/CD
---
flowchart LR
	merge2[merge staging to develop]

	br1((develop))
	dev1[build:development]
	dev2[deploy:development]
    br1---dev1
    dev1-->dev2

	br2((staging))
	stg1[build:stg_beta]
	stg2[deploy:stg_beta]
	stg3[build:stg_real]
	stg4[deploy:stg_real]
    br2---stg1
    stg1-->stg2
    stg2-->stg3
    stg3-->stg4
    stg4-->merge2
    
	br3((educatn))
	edu1[build:prod_beta]
	edu2[deploy:prod_beta]
	br3---edu1
	edu1-->edu2

	br4((master))
	mst1[build:prod_real]
	mst2[deploy:prod_real]
	br4---mst1
	mst1-->mst2

	style br1 stroke:green,stroke-width:2px
	style br2 stroke:#333,stroke-width:2px
	style br3 stroke:#333,stroke-width:2px
	style br4 stroke:#333,stroke-width:2px
	style merge2 stroke:blue,stroke-width:2px
```

### Auto-merge
gitlab-ci Job 에 CLI 를 통한 머지 자동화 Job 이 설정되어있습니다 (`staging` -> `develop`). `staging` 의 변경사항은 `develop` 에 항상 반영되어있어야 합니다.

`manual` Job 이므로 개발자가 직접 action 해야합니다. Merge conflict 가 발생하면 `develop` 에서 해소해주세요.

Auto merge 를 위한 Access token 은 각 리포지토리의 Setting > CI/CD > Variables > `AUTOMERGE_TOKEN` 에서 관리합니다.
신규 Access token 이 필요한 경우, Setting > Access tokens > Project access tokens 에서 생성해주세요 (개인 Access token 사용 x).

# references
- [Confluence > cubeCTMS 브랜치 관리 가이드](https://crscube.atlassian.net/wiki/spaces/TEAM3/pages/4061724842/cubeCTMS)
# connections
- [[PM6597 서버별 파이프라인 분리]]
- [[cubeCTMS 배포 태그 및 gitlab 릴리즈 관리]][[]]
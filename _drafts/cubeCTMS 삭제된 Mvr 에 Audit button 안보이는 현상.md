---
create: 2025-01-09 11:18
update: 2025-01-09 11:18
tags:
  - error
  - cubeCTMS
created: 2025-01-09 11:18
updated: 2025-03-31 13:36
gh-page: true
---
# memo
## 현상
MVR List 에서 삭제된 row 의 Audit trail 버튼(`BaseIconButtom.bue`)에 display: none; 스타일이 붙어서 안보이는 현상.
Local 에서 HMR 모드로 실행한 동작에선 문제가 발생하지 않고, S3 에 배포된 버전에서 문제 발생.
- https://stg-beta-ctms.crscube.io/en/sponsor/1/project/1107/mvr/IMVR/list
	- 계정: shan+001@crscube.co.kr
![[Pasted image 20250109112054.png]]
1. Admin Edit 권한 줘도 안됨![[Pasted image 20250109112302.png]]
2. Admin Edit + Read 안됨![[Pasted image 20250109112354.png]]
3. 그런데, IMVR Edit 권한을 주면 다시 보임
## Trouble shooting
### 프로덕션 빌드 - 브라우저 디버깅
우선, 프로덕션 빌드된 소스(`vite build`)와 HMR 모드로 실행한 동작의 차이가 있었으므로, 로컬에서 프로덕션 빌드를 통해 서버를 띄워서 문제를 재현해보기로 하였다.
1. 난독화 중지
```
// vite.config.js
build: {
minify: false,                 // 코드 난독화 및 축소 비활성화
sourcemap: true,               // 소스맵 활성화
cssCodeSplit: false,           // CSS 분할 비활성화
rollupOptions: {
  output: {
	manualChunks: undefined,   // 코드 분할 비활성화
  }
}
```
2. stg-beta 모드로 빌드: `vite build --mode stg_beta`
3. 로컬에서 서버 실행: `npx http-server ./dist -p 3000

프로덕션 빌드 실행결과 로컬에서도 문제가 재현되었음을 확인할 수 있었다.![[Pasted image 20250109144105.png]]
같은 소스코드에서 프로덕션 빌드된 소스에서만 문제가 발생하였으므로, vite 번들러의 문제라 판단하였다.
Root cause 를 확인하기 위해 문제가 발생한 컴포넌트를 그리는 VNode 메서드의 콜스택을 쭉 살펴 보았지만 
해당 콜스택에 style 주입하는 로직은 발견할 수 없었고, 최종 반환값에도 style 프로퍼티는 없었다
![[Pasted image 20250109144712.png]]![[Pasted image 20250109144931.png]]

한 가지 주안점은 MVR 에 Edit 권한을 부여하면 해당 컴포넌트가 정상적으로 동작, 즉 Audit button 이 잘 보였다는 점이다.
하지만 삭제된 row 에대한 Audit button 을 그리는 그 어떤 개발자 코드에도 Edit 권한을 검사하는 부분이 없고, 해당 컴포넌트를 그리는 `rowButtonGroupRenderer` 에서 삭제되지 않은 row 에 대해 Edit 권한을 검사하여 style: "display: none" 을 부여하는 로직만 있을 뿐이다.

### 가설 수립: Virtual DOM 노드 패치 과정에서 이전 노드의 속성을 재사용한다
![[Pasted image 20250109153918.png]]
Vue3 에서 render function (`h`) 를 통해 만들어진 virtual DOM tree 는 기존 tree 와 비교되어 필수적인 변경사항이 있는경우 actual DOM 에 반영된다 (patch). 이 과정에서 컴포넌트에 할당된 `key` 가 없으면 patch 알고리즘은 DOM 노드 이동을 최소화 하고 같은 위치의 노드를 적극적으로 재사용하는 방향으로 수행된다 ([doc](https://vuejs.org/api/built-in-special-attributes.html#key)).

1. 현재 사용되는 BaseIconButton renderer 함수는 생성되는 컴포넌트 별로 key 를 부여하지 않고 있다.
```typescript
  public static baseIconButtonRenderer(baseIconButtonProps?: any, handlers?: Record<any, AnyFunction>) {
    return h(BaseIconButton, {
      ...baseIconButtonProps,
      ...handlers
    });
  }
```
2. 문제가 발생하는 페이지를 보면 똑같은 위치에 버튼 컴포넌트를 연속해서 그리고 있고, MVR Edit 권한이 없는 경우 Tree 에서 똑같은 곳에 위치하는 Save 버튼에 style="display: none" 이 부여된다.

정황상 Show deleted 버튼을 누르기 전 Save 버튼이 display:none 상태로 렌더링 되었고, Show deleted 버튼을 누른 후 같은 자리에 렌더링 되는 deleted row > Audit 버튼에 이전 자리에 먹여져 있던 style="display:none" 프로퍼티가 재사용 된 것이라 생각된다.
![[Pasted image 20250109160623.png]]
![[Pasted image 20250109160654.png]]
![[patch.gif]]

### 가설 검증 1: key 부여
BaseIconButton renderer 가 새로운 버튼 생성시 UUID key 를 부여하도록 개선하였다.
```ts
public static baseIconButtonRenderer(baseIconButtonProps?: any, handlers?: Record<any, AnyFunction>) {
    const key = useGenerateUuid();
    return h(BaseIconButton, {
      ... {
        key,
        ...baseIconButtonProps,
      },
      ...handlers
    });
  }
```

정상적으로 동작함을 확인하였다
![[patch 1.gif]]

### 가설 검증 2: `BaseIconButton` 컴포넌트에 명시적으로 style 프로퍼티 부여
```vue
interface BaseIconButtonProps {
  className: string;
  label: string;       // a11y
  text?: boolean;
  size?: 'large' | 'default' | 'small';
  loading?: boolean;
  disabled?: boolean;
  eventPreventDefault?: boolean;
  style?: any;
}

<template>
  <el-button
    :aria-label="label"
    :text="text"
    :size="size"
    :loading="loading"
    :disabled="disabled"
    :style="style"
    @click="onClick"
  >
    <BaseIcon :class-name="className"></BaseIcon>
  </el-button>
</template>
```

명시적으로 style 프로퍼티를 추가하여 이전 node 의 프로퍼티가 재사용되는것을 막을 수 있다.

## Follow up
프로퍼티가 재사용되는 현상을 소스코드 레벨에서 확인할 수 있다면 더 확실하게 가설을 검증 할 수 있을 것이다. 
또, 해당 패턴으로 문제가 발생할 수 있는 코드를 미리 알 수 있다면 좋을 것 같다.
마지막으로, Vite 의 HMR 모드와 프로덕션 빌드 실행 모드의 patch 알고리즘이 다른 것 같은데, 이것도 확인할 수 있으면 좋을듯.

# references
- 
# connections
- [[cubeCTMS WEBAPP 'select input' placeholder 안보이는 현상]]